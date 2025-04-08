import SwiftUI

struct CustomDhikr: Identifiable, Equatable, Codable {
    let id: UUID
    let phrase: String
    let transliteration: String
    let translation: String
    let count: Int
    let category: DhikrCategory
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, phrase, transliteration, translation, count, category, createdAt
    }
    
    init(phrase: String, transliteration: String, translation: String, count: Int, category: DhikrCategory) {
        self.id = UUID()
        self.phrase = phrase
        self.transliteration = transliteration
        self.translation = translation
        self.count = count
        self.category = category
        self.createdAt = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        phrase = try container.decode(String.self, forKey: .phrase)
        transliteration = try container.decode(String.self, forKey: .transliteration)
        translation = try container.decode(String.self, forKey: .translation)
        count = try container.decode(Int.self, forKey: .count)
        let categoryString = try container.decode(String.self, forKey: .category)
        category = DhikrCategory(rawValue: categoryString) ?? .general
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(phrase, forKey: .phrase)
        try container.encode(transliteration, forKey: .transliteration)
        try container.encode(translation, forKey: .translation)
        try container.encode(count, forKey: .count)
        try container.encode(category.rawValue, forKey: .category)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    func toDhikr() -> Dhikr {
        Dhikr(
            phrase: phrase,
            transliteration: transliteration,
            translation: translation,
            count: count,
            category: category
        )
    }
} 