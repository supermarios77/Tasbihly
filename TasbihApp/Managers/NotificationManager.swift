import UserNotifications
import SwiftUI

/// Thread-safe singleton manager for notifications
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsEnabled = false
    @Published var reminderTime = Date()
    
    private init() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
        
        // Load saved reminder time
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            self.reminderTime = savedTime
        } else {
            // Default to 5:00 AM if not set
            var components = DateComponents()
            components.hour = 5
            components.minute = 0
            self.reminderTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    func requestAuthorization(completion: ((Bool, Error?) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = success
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
                completion?(success, error)
            }
            if success {
                // Capture reminderTime on main thread before scheduling
                let timeToSchedule = self.reminderTime
                DispatchQueue.main.async {
                    self.scheduleNotification(timeToSchedule)
                }
            }
        }
    }
    
    func scheduleNotification(_ time: Date? = nil) {
        // Use provided time or current reminderTime (both on main thread)
        let timeToUse = time ?? reminderTime
        
        // Remove only our app's notifications, not all notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["dailyDhikr"]
        )
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for Dhikr"
        content.body = "Remember Allah and find peace in your heart ☪️"
        content.sound = .default
        
        // Create daily trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: timeToUse)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "dailyDhikr",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification with error handling
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        
        // Save reminder time (we're already on main thread due to @MainActor)
        UserDefaults.standard.set(timeToUse, forKey: "reminderTime")
    }
} 