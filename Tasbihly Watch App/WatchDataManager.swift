import Foundation
import SwiftUI
import WatchKit

class WatchDataManager: ObservableObject {
    @AppStorage("counter") private(set) var counter: Int = 0
    @AppStorage("selectedDhikrIndex") private var selectedDhikrIndex: Int = 0
    @AppStorage("isSoundEnabled") private(set) var isSoundEnabled: Bool = true
    @AppStorage("isHapticEnabled") private(set) var isHapticEnabled: Bool = true
    
    @Published private(set) var currentDhikr: Dhikr
    
    static let shared = WatchDataManager()
    
    private init() {
        self.currentDhikr = Dhikr.common[0]
        if let dhikr = (Dhikr.common + Dhikr.more).first(where: { Dhikr.common.firstIndex(of: $0) == selectedDhikrIndex }) {
            self.currentDhikr = dhikr
        }
    }
    
    var target: Int {
        currentDhikr.count
    }
    
    func setDhikr(_ dhikr: Dhikr) {
        if let index = (Dhikr.common + Dhikr.more).firstIndex(of: dhikr) {
            selectedDhikrIndex = index
            currentDhikr = dhikr
        }
    }
    
    func incrementCounter() {
        counter += 1
        
        if isHapticEnabled {
            if counter % currentDhikr.count == 0 {
                WKInterfaceDevice.current().play(.success)
            } else {
                WKInterfaceDevice.current().play(.click)
            }
        }
    }
    
    func resetCounter() {
        counter = 0
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func toggleHaptic() {
        isHapticEnabled.toggle()
    }
    
    func undoLastCount() {
        if counter > 0 {
            counter -= 1
        }
    }
} 