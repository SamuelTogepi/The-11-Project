//
//  Camera.swift
//  iOS11Remake
//
//  Created by Samuel Bowers on 5/20/2026.
//  Modified for iOS 11 Remake.
//

import SwiftUI
import Camera_SwiftUI
import Combine
import AVKit
import Photos

struct Camera: View {
    @State var camera_state: camera_state = .photo
    @State var is_recording: Bool = false
    @State var recording_timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject var model = CameraModel()
    
    @State var currentZoomFactor: CGFloat = 1.0
    @Binding var instant_multitasking_change: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main Live Camera Preview filling the screen
                CameraPreview(session: model.session)
                    .onAppear {
                        model.configure()
                    }
                    .edgesIgnoringSafeArea(.all)
                
                // iOS 11 Styled Camera Interface Overlays
                VStack(spacing: 0) {
                    // Modern Translucent Top Control Bar
                    iOS11CameraHeader(model: model, cameraState: $camera_state)
                        .padding(.top, 44) // Offset for notch/status bar area
                    
                    Spacer()
                    
                    // Translucent Bottom Overlay Panel containing modes and controls
                    iOS11CameraBottomBar(
                        cameraState: $camera_state,
                        isRecording: $is_recording,
                        recordingTimer: $recording_timer,
                        model: model,
                        instantMultitaskingChange: $instant_multitasking_change,
                        geometry: geometry
                    )
                }
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onDisappear {
            model.end_session()
        }
    }
}

enum camera_state: String, CaseIterable {
    case video = "VIDEO"
    case photo = "PHOTO"
    case square = "SQUARE"
}

// MARK: - iOS 11 Translucent Top Bar
struct iOS11CameraHeader: View {
    @StateObject var model: CameraModel
    @Binding var cameraState: camera_state
    @State private var hdrMode: Int = 0 // 0: Auto, 1: On, 2: Off
    
    var body: some View {
        HStack {
            // Flash Toggle
            Button(action: {
                model.switchFlash()
            }) {
                Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(model.isFlashOn ? .yellow : .white)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            // HDR Cycle Toggle (Characteristic of iOS 11)
            Button(action: {
                hdrMode = (hdrMode + 1) % 3
            }) {
                HStack(spacing: 2) {
                    Text("HDR")
                        .font(.system(size: 14, weight: .bold))
                    Text(hdrMode == 0 ? "Auto" : (hdrMode == 1 ? "On" : "Off"))
                        .font(.system(size: 14))
                }
                .foregroundColor(hdrMode == 1 ? .yellow : .white)
            }
            
            Spacer()
            
            // Live Photo Indicator Toggle
            Button(action: {}) {
                Image(systemName: "livephoto")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 25)
        .frame(height: 50)
        .background(Color.black.opacity(0.15))
    }
}

// MARK: - iOS 11 Bottom Controller Panel
struct iOS11CameraBottomBar: View {
    @Binding var cameraState: camera_state
    @Binding var isRecording: Bool
    @Binding var recordingTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State var lastPhoto: UIImage?
    @State var recordingTime: TimeInterval = 0
    @StateObject var model: CameraModel
    @Binding var instantMultitaskingChange: Bool
    var geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. Swappable Mode Text Carousel (VIDEO / PHOTO / SQUARE)
            HStack(spacing: 24) {
                ForEach(camera_state.allCases, id: \.self) { state in
                    Button(action: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            cameraState = state
                        }
                    }) {
                        Text(state.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(cameraState == state ? .yellow : .white)
                            .tracking(1.5)
                    }
                }
            }
            .padding(.vertical, 8)
            
            // 2. Camera Controls Row (Thumbnail | Shutter | Switch)
            HStack {
                // Photo Gallery/Thumbnail Preview
                Group {
                    if let img = lastPhoto {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 48, height: 48)
                    }
                }
                .frame(width: geometry.size.width / 4, alignment: .leading)
                .padding(.leading, 30)
                
                Spacer()
                
                // Modern Shutter Button (Ring wrapper with internal triggering shape)
                Button(action: {
                    triggerAction()
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 76, height: 76)
                        
                        if cameraState == .video {
                            RoundedRectangle(cornerRadius: isRecording ? 8 : 28)
                                .fill(Color.red)
                                .frame(width: isRecording ? 32 : 56, height: isRecording ? 32 : 56)
                                .animation(.spring(), value: isRecording)
                        } else {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 58, height: 58)
                        }
                    }
                }
                
                Spacer()
                
                // Flip Camera Button
                Button(action: {
                    model.flipCamera()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "camera.rotate.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: geometry.size.width / 4, alignment: .trailing)
                .padding(.trailing, 30)
            }
            .padding(.bottom, 34) // Buffer for bottom home indicator context safe area
        }
        .background(Color.black.opacity(0.4))
        .onAppear {
            LastPhotoRetriever().queryLastPhoto(resizeTo: CGSize(width: 100, height: 100)) { image in
                self.lastPhoto = image
            }
        }
    }
    
    private func triggerAction() {
        if cameraState == .photo || cameraState == .square {
            model.capturePhoto()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                LastPhotoRetriever().queryLastPhoto(resizeTo: CGSize(width: 100, height: 100)) { image in
                    self.lastPhoto = image
                }
            }
        } else if cameraState == .video {
            isRecording.toggle()
            model.record()
            if isRecording {
                recordingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            } else {
                recordingTimer.upstream.connect().cancel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    LastPhotoRetriever().queryLastPhoto(resizeTo: CGSize(width: 100, height: 100)) { image in
                        self.lastPhoto = image
                    }
                }
            }
        }
    }
}
