import SwiftUI

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteDhikrs: Set<UUID> = []
    
    private let favoritesKey = "favoriteDhikrs"
    
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
        if let encoded = try? JSONEncoder().encode(Array(favoriteDhikrs)) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            favoriteDhikrs = Set(decoded)
        }
    }
} 