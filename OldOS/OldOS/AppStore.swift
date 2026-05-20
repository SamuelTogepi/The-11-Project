//
//  AppStore.swift
//  iOS11Remake
//
//  Created by Samuel Bowers on 5/20/2026.
//  Modified for iOS 11 Remake.
//

import SwiftUI
import WebKit
import FeedKit
import Foundation
import SDWebImageSwiftUI
import SwiftUIPager

struct AppStore: View {
    @State var selectedTab = "Today"
    @StateObject var featured_observer = FeaturedApplicationsObserver()
    @StateObject var top_paid_and_free_observer = TopPaidAndFreeApplicationsObserver()
    
    // Navigation state
    @State var selectedApplication: Application_Data.Results? = nil
    @State var showApplicationDetail: Bool = false
    @State var searchText: String = ""
    @State var searchResults = [Application_Data.Results]()
    @Binding var instant_multitasking_change: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // System Status Bar Space
                status_bar_in_app()
                    .frame(minHeight: 24, maxHeight: 24)
                    .zIndex(2)
                
                ZStack(alignment: .bottom) {
                    // Main Content View Switcher
                    TabView(selection: $selectedTab) {
                        TodayTabView(selectedApp: $selectedApplication, showDetail: $showApplicationDetail)
                            .tag("Today")
                        
                        GamesTabView(featured_observer: featured_observer, top_paid_and_free_observer: top_paid_and_free_observer, selectedApp: $selectedApplication, showDetail: $showApplicationDetail)
                            .tag("Games")
                        
                        AppsTabView(featured_observer: featured_observer, top_paid_and_free_observer: top_paid_and_free_observer, selectedApp: $selectedApplication, showDetail: $showApplicationDetail)
                            .tag("Apps")
                        
                        UpdatesTabView()
                            .tag("Updates")
                        
                        AppStoreSearchView(searchText: $searchText, searchResults: $searchResults, selectedApp: $selectedApplication, showDetail: $showApplicationDetail)
                            .tag("Search")
                    }
                    .tabViewStyle(StackTabViewStyle())
                    
                    // Detail view overlay sheet/transition
                    if showApplicationDetail, let appData = selectedApplication {
                        iOS11AppDetailView(application: appData, isPresented: $showApplicationDetail)
                            .transition(.move(edge: .bottom))
                            .zIndex(3)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Core Components & Headers

struct iOS11Header: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let subtitle = subtitle {
                Text(subtitle.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
            }
            HStack {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
}

// MARK: - Tab Views

// 1. TODAY TAB
struct TodayTabView: View {
    @Binding var selectedApp: Application_Data.Results?
    @Binding var showDetail: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                iOS11Header(title: "Today", subtitle: "Wednesday, June 7")
                
                // Card 1: Main Welcome Editorial Card
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FROM THE EDITORS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("Welcome to the\nAll-New App Store!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    }
                    .padding([.top, .horizontal], 20)
                    
                    Image("ios11_store_hero") // Add asset reference or placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(14)
                        .padding(.top, 12)
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                // Card 2: App of the Day
                Button(action: {
                    // Action triggers dynamic selection and pushes standard iOS 11 transition
                }) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image("monument_valley_hero")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                        
                        HStack(spacing: 12) {
                            Image("monument_valley_icon")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Monument Valley 2")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("The Art of the Impossible")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {}) {
                                Text("$4.99")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(16)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 80)
        }
    }
}

// 2. GAMES TAB
struct GamesTabView: View {
    @ObservedObject var featured_observer: FeaturedApplicationsObserver
    @ObservedObject var top_paid_and_free_observer: TopPaidAndFreeApplicationsObserver
    @Binding var selectedApp: Application_Data.Results?
    @Binding var showDetail: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                iOS11Header(title: "Games", subtitle: nil)
                
                // Feature Banner
                VStack(alignment: .leading) {
                    Text("NEW GAME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Injustice 2")
                        .font(.system(size: 22, weight: .regular))
                    Text("When iconic superheroes collide")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Image("injustice2_hero")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                Divider().padding(.horizontal, 20)
                
                // App List Row Wrapper
                VStack(alignment: .leading) {
                    HStack {
                        Text("New Games We Love")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Text("See All")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(featured_observer.featured_applications.prefix(5)) { app in
                                AppRowView(app: app)
                                    .onTapGesture {
                                        self.selectedApp = app
                                        self.showDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 80)
        }
    }
}

// 3. APPS TAB
struct AppsTabView: View {
    @ObservedObject var featured_observer: FeaturedApplicationsObserver
    @ObservedObject var top_paid_and_free_observer: TopPaidAndFreeApplicationsObserver
    @Binding var selectedApp: Application_Data.Results?
    @Binding var showDetail: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                iOS11Header(title: "Apps", subtitle: nil)
                
                // Hero Feature Card
                VStack(alignment: .leading) {
                    Text("REDISCOVER THIS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Airbnb")
                        .font(.system(size: 22, weight: .regular))
                    Text("New summer experiences to book")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Image("airbnb_hero")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                Divider().padding(.horizontal, 20)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("New Apps We Love")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Text("See All")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(top_paid_and_free_observer.top_free_applications.prefix(5)) { app in
                                AppRowView(app: app)
                                    .onTapGesture {
                                        self.selectedApp = app
                                        self.showDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 80)
        }
    }
}

// 4. UPDATES TAB
struct UpdatesTabView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                iOS11Header(title: "Updates", subtitle: nil)
                
                Divider().padding(.horizontal, 20)
                
                VStack(alignment: .center) {
                    Spacer().frame(height: 100)
                    Text("All Apps Are Up to Date")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.bottom, 80)
        }
    }
}

// 5. SEARCH TAB
struct AppStoreSearchView: View {
    @Binding var searchText: String
    @Binding var searchResults: [Application_Data.Results]
    @Binding var selectedApp: Application_Data.Results?
    @Binding var showDetail: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            iOS11Header(title: "Search", subtitle: nil)
            
            // Search Input Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("App Store", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(searchResults) { app in
                        HStack(spacing: 12) {
                            WebImage(url: app.artworkUrl100)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.trackName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(app.artistName)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                self.selectedApp = app
                                self.showDetail = true
                            }) {
                                Text(app.formattedPrice ?? "GET")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 80)
            }
        }
    }
}

// MARK: - Subviews & Elements

struct AppRowView: View {
    let app: Application_Data.Results
    
    var body: some View {
        HStack(spacing: 12) {
            WebImage(url: app.artworkUrl100)
                .resizable()
                .frame(width: 65, height: 65)
                .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.trackName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(app.artistName)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                Button(action: {}) {
                    Text(app.formattedPrice ?? "GET")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                }
            }
            .frame(height: 65)
        }
        .frame(width: 280, alignment: .leading)
    }
}

// MARK: - iOS 11 Dedicated App Detail View

struct iOS11AppDetailView: View {
    let application: Application_Data.Results
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Dimiss Button / Top bar
                HStack {
                    Button(action: { isPresented = false }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                        .font(.system(size: 17, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 44)
                
                // App Header Meta Section
                HStack(alignment: .top, spacing: 16) {
                    WebImage(url: application.artworkUrl512)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(application.trackName)
                            .font(.system(size: 22, weight: .bold))
                            .lineLimit(2)
                        Text(application.artistName)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text(application.formattedPrice ?? "GET")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Divider().padding(.horizontal, 20)
                
                // Description Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.system(size: 20, weight: .bold))
                    Text(application.description)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
