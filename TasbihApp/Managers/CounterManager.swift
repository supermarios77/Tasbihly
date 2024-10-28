import Foundation
import SwiftUI

/// Manages counter state with proper persistence and thread safety
final class CounterManager: ObservableObject {
    static let shared = CounterManager()
    
    @Published private(set) var counter: Int = 0
    
    private let counterKey = "counter"
    private var saveTimer: Timer?
    private var observers: [NSObjectProtocol] = []
    
    private init() {
        // UserDefaults reading is thread-safe, so we can read synchronously
        // Writing is handled on main thread in saveCounter()
        loadCounter()
        setupAppLifecycleObservers()
    }
    
    // MARK: - Public Methods
    
    /// Increment the counter
    func increment() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.counter += 1
            self.scheduleSave()
        }
    }
    
    /// Reset the counter to zero
    func reset() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.counter = 0
            self.saveCounter()
        }
    }
    
    /// Set counter to a specific value
    func setCounter(_ value: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.counter = max(0, value) // Ensure non-negative
            self.saveCounter()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadCounter() {
        counter = UserDefaults.standard.integer(forKey: counterKey)
    }
    
    /// Debounced save to reduce UserDefaults writes
    private func scheduleSave() {
        // Ensure we're on main thread for timer scheduling
        // Timer.scheduledTimer automatically adds to current RunLoop, so we must be on main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.scheduleSave()
            }
            return
        }
        
        saveTimer?.invalidate()
        // scheduledTimer automatically adds to current RunLoop (main thread's RunLoop)
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.saveCounter()
        }
    }
    
    private func saveCounter() {
        // We're already on main thread (called from increment/reset/setCounter which wrap in DispatchQueue.main.async,
        // or from scheduleSave which ensures main thread, or from observer callbacks which are on .main queue)
        // No need for additional async wrapper
        UserDefaults.standard.set(counter, forKey: counterKey)
    }
    
    /// Save immediately when app goes to background
    private func setupAppLifecycleObservers() {
        // Store observer tokens to properly remove them later
        let resignActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.saveTimer?.invalidate()
            self?.saveCounter()
        }
        observers.append(resignActiveObserver)
        
        let terminateObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.saveTimer?.invalidate()
            self?.saveCounter()
        }
        observers.append(terminateObserver)
    }
    
    deinit {
        // Remove all observers using their tokens
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        saveTimer?.invalidate()
    }
}

