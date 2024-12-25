import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Binding var isSoundEnabled: Bool
    @Binding var target: Int
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex: Int = 0
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = true
    @State private var reminderTime = Date()
    @AppStorage("reminderHour") private var reminderHour: Int = 12
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferences")) {
                    Toggle("Enable Sound", isOn: $isSoundEnabled)
                        .onChange(of: isSoundEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "isSoundEnabled")
                        }
                    
                    HStack {
                        Text("Target Count")
                        Spacer()
                        TextField("Set target", value: $target, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: target) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "target")
                            }
                    }
                    
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedThemeIndex) {
                        ForEach(0..<appThemes.count, id: \.self) { index in
                            Text(appThemes[index].name)
                                .tag(index)
                        }
                    }
                    .onChange(of: selectedThemeIndex) { newValue in
                        let safeIndex = min(max(newValue, 0), appThemes.count - 1)
                        if newValue != safeIndex {
                            selectedThemeIndex = safeIndex
                        }
                    }
                }
                
                Section(header: Text("Reminders")) {
                    Toggle("Daily Reminders", isOn: $remindersEnabled)
                        .onChange(of: remindersEnabled) { newValue in
                            if newValue {
                                rescheduleNotification()
                            } else {
                                cancelNotifications()
                            }
                        }
                    
                    if remindersEnabled {
                        DatePicker("Reminder Time", 
                                 selection: Binding(
                                    get: {
                                        Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date()
                                    },
                                    set: { newDate in
                                        reminderHour = Calendar.current.component(.hour, from: newDate)
                                        reminderMinute = Calendar.current.component(.minute, from: newDate)
                                        rescheduleNotification()
                                    }
                                 ),
                                 displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func rescheduleNotification() {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Dhikr"
        content.body = "Take a moment to remember Allah and earn rewards."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSoundEnabled: .constant(true), target: .constant(100))
    }
}
