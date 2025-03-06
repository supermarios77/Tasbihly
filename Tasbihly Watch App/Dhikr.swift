//
//  Dhikr.swift
//  Tasbihly
//
//  Created by mario on 24/12/2024.
//


import SwiftUI
import Foundation

struct Dhikr: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let transliteration: String
    let translation: String
    let count: Int
    
    static let common: [Dhikr] = [
        Dhikr(
            name: "سُبْحَانَ ٱللَّٰهِ",
            transliteration: "Subhan Allah",
            translation: "Glory be to Allah",
            count: 33
        ),
        Dhikr(
            name: "ٱلْحَمْدُ لِلَّٰهِ",
            transliteration: "Alhamdulillah",
            translation: "Praise be to Allah",
            count: 33
        ),
        Dhikr(
            name: "ٱللَّٰهُ أَكْبَرُ",
            transliteration: "Allahu Akbar",
            translation: "Allah is Greater",
            count: 33
        )
    ]
    
    static let more: [Dhikr] = [
        Dhikr(
            name: "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
            transliteration: "La ilaha illa Allah",
            translation: "There is no deity except Allah",
            count: 100
        ),
        Dhikr(
            name: "أَسْتَغْفِرُ ٱللَّٰهَ",
            transliteration: "Astaghfirullah",
            translation: "I seek forgiveness from Allah",
            count: 100
        ),
        Dhikr(
            name: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّٰهِ",
            transliteration: "La hawla wala quwwata illa billah",
            translation: "There is no power nor strength except through Allah",
            count: 100
        )
    ]
    
    static let all: [Dhikr] = [
        Dhikr(name: "سبحان الله", transliteration: "Subhan Allah", translation: "Glory be to Allah", count: 33),
        Dhikr(name: "الحمد لله", transliteration: "Alhamdulillah", translation: "Praise be to Allah", count: 33),
        Dhikr(name: "الله أكبر", transliteration: "Allahu Akbar", translation: "Allah is the Greatest", count: 34),
        Dhikr(name: "لا إله إلا الله", transliteration: "La ilaha illallah", translation: "There is no god but Allah", count: 33),
        Dhikr(name: "أستغفر الله", transliteration: "Astaghfirullah", translation: "I seek forgiveness from Allah", count: 33),
        Dhikr(name: "بسم الله", transliteration: "Bismillah", translation: "In the name of Allah", count: 33),
        Dhikr(name: "ما شاء الله", transliteration: "Masha'Allah", translation: "As Allah has willed", count: 33),
        Dhikr(name: "إن شاء الله", transliteration: "Insha'Allah", translation: "If Allah wills", count: 33),
        Dhikr(name: "سبحان الله وبحمده", transliteration: "Subhan Allah wa bihamdi", translation: "Glory be to Allah and Praise Him", count: 33),
        Dhikr(name: "اللهم صل على محمد", transliteration: "Allahumma salli ala Muhammad", translation: "O Allah, send blessings upon Muhammad", count: 33),
        Dhikr(name: "اللهم بارك على محمد", transliteration: "Allahumma barik ala Muhammad", translation: "O Allah, bless Muhammad", count: 33),
        Dhikr(name: "الحمد لله رب العالمين", transliteration: "Alhamdulillahi Rabbil Alamin", translation: "Praise be to Allah, the Lord of the Worlds", count: 33),
        Dhikr(name: "أعوذ بالله من الشيطان الرجيم", transliteration: "A'udhu billahi min ash-shaytan ir-rajim", translation: "I seek refuge in Allah from the accursed devil", count: 33),
        Dhikr(name: "اللهم اجعلني من المتقين", transliteration: "Allahumma aj'alni min al-muttaqin", translation: "O Allah, make me among the righteous", count: 33)
    ]
}
