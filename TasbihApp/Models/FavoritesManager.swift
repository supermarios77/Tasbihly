import SwiftUI
import os.log

/// Thread-safe manager for favorite dhikrs
@MainActor
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteDhikrs: Set<UUID> = []
    
    private let favoritesKey = "favoriteDhikrs"
    private let logger = Logger(subsystem: "com.bytecraft.Tasbihly", category: "FavoritesManager")
    
    private init() {
        loadFavorites()
    }
    
    func toggleFavorite(_ dhikr: Dhikr) {
        withAnimation(.spring()) {
            if favoriteDhikrs.contains(dhikr.id) {
                favoriteDhikrs.remove(dhikr.id)
            } else {
                favoriteDhikrs.insert(dhikr.id)
            }
        }
        saveFavorites()
    }
    
    func isFavorite(_ dhikr: Dhikr) -> Bool {
        favoriteDhikrs.contains(dhikr.id)
    }
    
    private func saveFavorites() {
        do {
            let encoded = try JSONEncoder().encode(Array(favoriteDhikrs))
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        } catch {
            logger.error("Failed to encode favorites: \(error.localizedDescription)")
            // Silently fail - favorites are not critical, but log for debugging
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else {
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([UUID].self, from: data)
            favoriteDhikrs = Set(decoded)
        } catch {
            logger.error("Failed to decode favorites: \(error.localizedDescription)")
            // If decoding fails, start with empty set
            favoriteDhikrs = []
        }
    }
} 