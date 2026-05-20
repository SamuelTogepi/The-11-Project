//
//  Calendar.swift
//  iOS11Remake
//
//  Created by Samuel Bowers on 5/20/2026.
//  Modified for iOS 11 Remake.
//

import SwiftUI

// MARK: - Data Models
struct CalendarEvent: Identifiable {
    let id = UUID()
    var title: String
    var location: String
    var startDate: Date
    var endDate: Date
    var notes: String?
}

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var showAddEventSheet = false
    @State private var events: [CalendarEvent] = [
        CalendarEvent(
            title: "WWDC 17 Keynote",
            location: "McEnery Convention Center",
            startDate: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date(),
            endDate: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(),
            notes: "Introducing iOS 11, macOS High Sierra, and watchOS 4!"
        ),
        CalendarEvent(
            title: "Lunch with Zane",
            location: "Apple Park Visitor Center",
            startDate: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date(),
            endDate: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date()
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // System status bar spacer
            status_bar_in_app()
                .frame(minHeight: 24, maxHeight: 24)
                .zIndex(2)
            
            // iOS 11 Calendar Header
            iOS11CalendarHeader(selectedDate: $selectedDate, showAddEventSheet: $showAddEventSheet)
                .background(Color(.systemBackground))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Day Selector Grid
                    iOS11MonthGridView(selectedDate: $selectedDate)
                        .padding(.top, 10)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Events for the selected Day
                    iOS11AgendaListView(selectedDate: selectedDate, events: $events)
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showAddEventSheet) {
            AddEventSheet(events: $events, selectedDate: selectedDate)
        }
    }
}

// MARK: - iOS 11 Header
struct iOS11CalendarHeader: View {
    @Binding var selectedDate: Date
    @Binding var showAddEventSheet: Bool
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Large left-aligned Month & Year
                Text(monthYearString)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Red Accent "+" button characteristic of iOS 11 Calendar
                Button(action: { showAddEventSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
        }
    }
}

// MARK: - iOS 11 Style Month Grid View
struct iOS11MonthGridView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var daysInMonth: [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))
        else { return [] }
        
        let firstWeekdayOffset = calendar.component(.weekday, from: firstOfMonth) - 1
        var days: [Date] = []
        
        // Pad previous month's days
        for i in (0..<firstWeekdayOffset).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Add current month's days
        for day in 0..<monthRange.count {
            if let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Days of the week headers (S M T W T F S)
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 10)
            
            // 7-Column Grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let isCurrentMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
                    
                    Button(action: { selectedDate = date }) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? .white : (isToday ? .red : (isCurrentMonth ? .primary : .secondary.opacity(0.5))))
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(isSelected ? Color.red : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

// MARK: - iOS 11 Style Agenda View
struct iOS11AgendaListView: View {
    let selectedDate: Date
    @Binding var events: [CalendarEvent]
    
    private var filteredEvents: [CalendarEvent] {
        events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Agenda")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            if filteredEvents.isEmpty {
                VStack(spacing: 8) {
                    Text("No Events Today")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredEvents) { event in
                        HStack(spacing: 15) {
                            // Red calendar category stripe
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.red)
                                .frame(width: 4, height: 45)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                if !event.location.isEmpty {
                                    Text(event.location)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(formatTime(event.startDate))
                                    .font(.system(size: 14, weight: .medium))
                                Text(formatTime(event.endDate))
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                            .padding(.leading, 39)
                    }
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Interactive Event Creation Sheet
struct AddEventSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var events: [CalendarEvent]
    var selectedDate: Date
    
    @State private var title = ""
    @State private var location = ""
    @State private var allDay = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var notes = ""
    
    init(events: Binding<[CalendarEvent]>, selectedDate: Date) {
        self._events = events
        self.selectedDate = selectedDate
        self._startDate = State(initialValue: selectedDate)
        self._endDate = State(initialValue: selectedDate.addingTimeInterval(3600))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                }
                
                Section {
                    Toggle("All-day", isOn: $allDay)
                    DatePicker("Starts", selection: $startDate, displayedComponents: allDay ? [.date] : [.date, .hourAndMinute])
                    DatePicker("Ends", selection: $endDate, displayedComponents: allDay ? [.date] : [.date, .hourAndMinute])
                }
                
                Section {
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newEvent = CalendarEvent(
                            title: title.isEmpty ? "New Event" : title,
                            location: location,
                            startDate: startDate,
                            endDate: endDate,
                            notes: notes.isEmpty ? nil : notes
                        )
                        events.append(newEvent)
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .font(.system(size: 17, weight: .bold))
                }
            }
        }
    }
}
