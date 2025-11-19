import UIKit

/// Manages haptic feedback throughout the app
/// Provides a centralized, thread-safe way to trigger haptic feedback
final class HapticManager {
    static let shared = HapticManager()
    
    // Generators are created once and reused for better performance
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for reduced latency
        lightImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
        heavyImpactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    // MARK: - Impact Feedback
    
    /// Triggers a light impact haptic feedback
    func lightImpact() {
        DispatchQueue.main.async { [weak self] in
            self?.lightImpactGenerator.impactOccurred()
            self?.lightImpactGenerator.prepare() // Prepare for next use
        }
    }
    
    /// Triggers a medium impact haptic feedback
    func mediumImpact() {
        DispatchQueue.main.async { [weak self] in
            self?.mediumImpactGenerator.impactOccurred()
            self?.mediumImpactGenerator.prepare() // Prepare for next use
        }
    }
    
    /// Triggers a heavy impact haptic feedback
    func heavyImpact() {
        DispatchQueue.main.async { [weak self] in
            self?.heavyImpactGenerator.impactOccurred()
            self?.heavyImpactGenerator.prepare() // Prepare for next use
        }
    }
    
    // MARK: - Selection Feedback
    
    /// Triggers selection changed haptic feedback
    /// Use this for UI selections like picker changes, toggle switches, etc.
    func selectionChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.selectionGenerator.selectionChanged()
            self?.selectionGenerator.prepare() // Prepare for next use
        }
    }
    
    // MARK: - Notification Feedback
    
    /// Triggers a success notification haptic feedback
    func success() {
        DispatchQueue.main.async { [weak self] in
            self?.notificationGenerator.notificationOccurred(.success)
            self?.notificationGenerator.prepare() // Prepare for next use
        }
    }
    
    /// Triggers a warning notification haptic feedback
    func warning() {
        DispatchQueue.main.async { [weak self] in
            self?.notificationGenerator.notificationOccurred(.warning)
            self?.notificationGenerator.prepare() // Prepare for next use
        }
    }
    
    /// Triggers an error notification haptic feedback
    func error() {
        DispatchQueue.main.async { [weak self] in
            self?.notificationGenerator.notificationOccurred(.error)
            self?.notificationGenerator.prepare() // Prepare for next use
        }
    }
}

