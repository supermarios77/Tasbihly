import SwiftUI

struct Dhikr: Identifiable, Equatable {
    let id = UUID()
    let phrase: String
    let transliteration: String
    let translation: String
    let count: Int
    let category: DhikrCategory
}

enum DhikrCategory: String, CaseIterable {
    case morning = "Morning"
    case evening = "Evening"
    case afterPrayer = "After Prayer"
    case general = "General"
    case praise = "Praise"
    case forgiveness = "Forgiveness"
    
    var icon: String {
        switch self {
        case .morning:
            return "sun.and.horizon.fill"
        case .evening:
            return "moon.stars.fill"
        case .afterPrayer:
            return "person.fill.checkmark"
        case .general:
            return "heart.fill"
        case .praise:
            return "hands.sparkles.fill"
        case .forgiveness:
            return "arrow.counterclockwise.heart.fill"
        }
    }
}

let dhikrList = [
    // After Prayer Category
    Dhikr(
        phrase: "سبحان الله",
        transliteration: "Subhan Allah",
        translation: "Glory be to Allah",
        count: 33,
        category: .afterPrayer
    ),
    Dhikr(
        phrase: "الحمد لله",
        transliteration: "Alhamdulillah",
        translation: "All praise is to Allah",
        count: 33,
        category: .afterPrayer
    ),
    Dhikr(
        phrase: "الله أكبر",
        transliteration: "Allahu Akbar",
        translation: "Allah is the Greatest",
        count: 34,
        category: .afterPrayer
    ),
    
    // General Category
    Dhikr(
        phrase: "لا إله إلا الله",
        transliteration: "La ilaha illallah",
        translation: "There is no god but Allah",
        count: 100,
        category: .general
    ),
    
    // Forgiveness Category
    Dhikr(
        phrase: "أستغفر الله",
        transliteration: "Astaghfirullah",
        translation: "I seek Allah's forgiveness",
        count: 100,
        category: .forgiveness
    ),
    
    // Praise Category
    Dhikr(
        phrase: "سبحان الله وبحمده",
        transliteration: "Subhanallahi wa bihamdihi",
        translation: "Glory and praise to Allah",
        count: 100,
        category: .praise
    ),
    Dhikr(
        phrase: "حسبي الله",
        transliteration: "Hasbiyallah",
        translation: "Allah is sufficient for me",
        count: 7,
        category: .general
    ),
    Dhikr(
        phrase: "لا حول ولا قوة إلا بالله",
        transliteration: "La hawla wala quwwata illa billah",
        translation: "There is no power but from Allah",
        count: 100,
        category: .general
    ),
    
    // Morning Category
    Dhikr(
        phrase: "اللهم بك أصبحنا وبك أمسينا",
        transliteration: "Allahumma bika asbahna wa bika amsayna",
        translation: "O Allah, by You we enter the morning and by You we enter the evening",
        count: 1,
        category: .morning
    ),
    
    // Evening Category
    Dhikr(
        phrase: "اللهم بك أمسينا وبك أصبحنا",
        transliteration: "Allahumma bika amsayna wa bika asbahna",
        translation: "O Allah, by You we enter the evening and by You we enter the morning",
        count: 1,
        category: .evening
    )
]

// Helper function to get dhikr by category
func getDhikrByCategory(_ category: DhikrCategory) -> [Dhikr] {
    dhikrList.filter { $0.category == category }
}
