//
//  Dhikr.swift
//  Tasbihly
//
//  Created by mario on 24/12/2024.
//


import SwiftUI

struct Dhikr: Identifiable, Equatable {
    let id = UUID()
    let phrase: String
    let transliteration: String
    let translation: String
    let count: Int
}

let dhikrList = [
    Dhikr(phrase: "سبحان الله", transliteration: "Subhan Allah", translation: "Glory be to Allah", count: 33),
    Dhikr(phrase: "الحمد لله", transliteration: "Alhamdulillah", translation: "Praise be to Allah", count: 33),
    Dhikr(phrase: "الله أكبر", transliteration: "Allahu Akbar", translation: "Allah is the Greatest", count: 34),
    Dhikr(phrase: "لا إله إلا الله", transliteration: "La ilaha illallah", translation: "There is no god but Allah", count: 33),
    Dhikr(phrase: "أستغفر الله", transliteration: "Astaghfirullah", translation: "I seek forgiveness from Allah", count: 33),
    Dhikr(phrase: "بسم الله", transliteration: "Bismillah", translation: "In the name of Allah", count: 33),
    Dhikr(phrase: "ما شاء الله", transliteration: "Masha'Allah", translation: "As Allah has willed", count: 33),
    Dhikr(phrase: "إن شاء الله", transliteration: "Insha'Allah", translation: "If Allah wills", count: 33),
    Dhikr(phrase: "سبحان الله وبحمده", transliteration: "Subhan Allah wa bihamdi", translation: "Glory be to Allah and Praise Him", count: 33),
    Dhikr(phrase: "اللهم صل على محمد", transliteration: "Allahumma salli ala Muhammad", translation: "O Allah, send blessings upon Muhammad", count: 33),
    Dhikr(phrase: "اللهم بارك على محمد", transliteration: "Allahumma barik ala Muhammad", translation: "O Allah, bless Muhammad", count: 33),
    Dhikr(phrase: "الحمد لله رب العالمين", transliteration: "Alhamdulillahi Rabbil Alamin", translation: "Praise be to Allah, the Lord of the Worlds", count: 33),
    Dhikr(phrase: "أعوذ بالله من الشيطان الرجيم", transliteration: "A'udhu billahi min ash-shaytan ir-rajim", translation: "I seek refuge in Allah from the accursed devil", count: 33),
    Dhikr(phrase: "اللهم اجعلني من المتقين", transliteration: "Allahumma aj'alni min al-muttaqin", translation: "O Allah, make me among the righteous", count: 33)
]
