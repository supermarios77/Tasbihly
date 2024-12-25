import SwiftUI
import UserNotifications

@main
struct TasbihAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        requestNotificationPermissions()
        UNUserNotificationCenter.current().delegate = self
        
        // Schedule notification if it's first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            scheduleReminderNotification()
        }
        
        return true
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for Dhikr"
        content.body = "Take a moment to remember Allah and earn rewards."
        content.sound = .default
        
        // Create a daily trigger starting 24 hours from now
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        dateComponents.hour = Calendar.current.component(.hour, from: Date()) // Same hour as first launch
        dateComponents.minute = Calendar.current.component(.minute, from: Date()) // Same minute as first launch
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
