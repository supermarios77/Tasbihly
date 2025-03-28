import UIKit

/// A manager class to handle haptic feedback throughout the app
final class HapticManager {
    static let shared = HapticManager()
    
    // Prevent multiple instances
    private init() {}
    
    // MARK: - Impact Feedback
    
    /// Triggers impact feedback with specified style
    /// - Parameter style: UIImpactFeedbackGenerator.FeedbackStyle (light, medium, heavy, soft, rigid)
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a light impact feedback, suitable for frequent actions
    func lightImpact() {
        impact(style: .light)
    }
    
    /// Triggers a medium impact feedback, suitable for standard actions
    func mediumImpact() {
        impact(style: .medium)
    }
    
    /// Triggers a heavy impact feedback, suitable for significant actions
    func heavyImpact() {
        impact(style: .heavy)
    }
    
    /// Triggers a soft impact feedback (iOS 13+)
    func softImpact() {
        impact(style: .soft)
    }
    
    /// Triggers a rigid impact feedback (iOS 13+)
    func rigidImpact() {
        impact(style: .rigid)
    }
    
    // MARK: - Selection Feedback
    
    /// Triggers selection feedback
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    
    /// Triggers notification feedback with specified type
    /// - Parameter type: UINotificationFeedbackGenerator.FeedbackType (success, warning, error)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// Triggers success notification feedback
    func success() {
        notification(type: .success)
    }
    
    /// Triggers warning notification feedback
    func warning() {
        notification(type: .warning)
    }
    
    /// Triggers error notification feedback
    func error() {
        notification(type: .error)
    }
    
    // MARK: - Custom Patterns
    
    /// Triggers a subtle counter feedback pattern
    func counterTap() {
        // For tasbih counting, a light impact is appropriate
        lightImpact()
    }
    
    /// Triggers a milestone feedback pattern (every X counts)
    func milestoneTap() {
        // For milestone counts, use medium impact followed by success notification
        mediumImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
    }
    
    /// Triggers a set completion feedback pattern
    func setCompletion() {
        // For completing a full set, use a more pronounced feedback pattern
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.success()
        }
    }
    
    /// Triggers reset feedback
    func reset() {
        // For reset action, use a rigid impact followed by notification
        if #available(iOS 13.0, *) {
            rigidImpact()
        } else {
            heavyImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notification(type: .warning)
        }
    }
    
    /// Triggers a long press pattern with gradually increasing intensity
    func longPress() {
        // Start with light impact
        lightImpact()
        
        // Follow with medium impact after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.mediumImpact()
        }
        
        // End with heavy impact for confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.heavyImpact()
        }
    }
} 