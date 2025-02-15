import SwiftUI

struct Dhikr: Identifiable, Equatable {
    let id = UUID()
    let phrase: String
    let transliteration: String
    let translation: String
    let count: Int  // Recommended count
}

let dhikrList = [
    // The most authentic and commonly used dhikr after prayers
    Dhikr(
        phrase: "سبحان الله",
        transliteration: "Subhan Allah",
        translation: "Glory be to Allah",
        count: 33
    ),
    Dhikr(
        phrase: "الحمد لله",
        transliteration: "Alhamdulillah",
        translation: "All praise is to Allah",
        count: 33
    ),
    Dhikr(
        phrase: "الله أكبر",
        transliteration: "Allahu Akbar",
        translation: "Allah is the Greatest",
        count: 34
    ),
    Dhikr(
        phrase: "لا إله إلا الله",
        transliteration: "La ilaha illallah",
        translation: "There is no god but Allah",
        count: 100
    ),
    Dhikr(
        phrase: "أستغفر الله",
        transliteration: "Astaghfirullah",
        translation: "I seek Allah's forgiveness",
        count: 100
    ),
    Dhikr(
        phrase: "سبحان الله وبحمده",
        transliteration: "Subhanallahi wa bihamdihi",
        translation: "Glory and praise to Allah",
        count: 100
    ),
    Dhikr(
        phrase: "حسبي الله",
        transliteration: "Hasbiyallah",
        translation: "Allah is sufficient for me",
        count: 7
    ),
    Dhikr(
        phrase: "لا حول ولا قوة إلا بالله",
        transliteration: "La hawla wala quwwata illa billah",
        translation: "There is no power but from Allah",
        count: 100
    )
]
