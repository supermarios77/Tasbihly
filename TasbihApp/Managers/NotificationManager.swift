import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    @Published var isNotificationsEnabled = false
    @Published var reminderTime = Date()
    
    init() {
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
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = success
            }
            if success {
                self.scheduleNotification()
            }
        }
    }
    
    func scheduleNotification() {
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for Dhikr"
        content.body = "Remember Allah and find peace in your heart ☪️"
        content.sound = .default
        
        // Create daily trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "dailyDhikr",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request)
        
        // Save reminder time
        UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
    }
} 