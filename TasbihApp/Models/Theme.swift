import Foundation
import SwiftUI
import UIKit

enum ThemeBackground {
    case solid(Color)
    case gradient([Color])
    case pattern(String) // Image name from assets
}

struct Theme: Identifiable {
    let id = UUID()
    let name: String
    let primary: Color
    let secondary: Color
    let background: ThemeBackground
    let buttonBackground: Color
    let textColor: Color
}

let appThemes = [
    Theme(
        name: "Classic",
        primary: .blue,
        secondary: .gray,
        background: .solid(.white),
        buttonBackground: .blue,
        textColor: .primary
    ),
    Theme(
        name: "Nature",
        primary: Color("AccentColor"),
        secondary: .green,
        background: .gradient([
            Color(red: 0.8, green: 0.9, blue: 0.8),
            Color(red: 0.9, green: 0.95, blue: 0.9)
        ]),
        buttonBackground: Color("AccentColor"),
        textColor: .primary
    ),
    Theme(
        name: "Forest",
        primary: Color(red: 0.2, green: 0.5, blue: 0.3),
        secondary: Color(red: 0.3, green: 0.6, blue: 0.4),
        background: .gradient([
            Color(red: 0.95, green: 0.98, blue: 0.95),
            Color(red: 0.9, green: 0.95, blue: 0.9)
        ]),
        buttonBackground: Color(red: 0.2, green: 0.5, blue: 0.3),
        textColor: Color(red: 0.1, green: 0.3, blue: 0.2)
    ),
    Theme(
        name: "Emerald",
        primary: Color(red: 0.0, green: 0.6, blue: 0.5),
        secondary: Color(red: 0.0, green: 0.5, blue: 0.4),
        background: .gradient([
            Color(red: 0.9, green: 1.0, blue: 0.98),
            Color(red: 0.85, green: 0.95, blue: 0.93)
        ]),
        buttonBackground: Color(red: 0.0, green: 0.6, blue: 0.5),
        textColor: Color(red: 0.0, green: 0.4, blue: 0.3)
    ),
    Theme(
        name: "Dark Elegance",
        primary: .purple,
        secondary: .gray,
        background: .gradient([Color(white: 0.1), Color(white: 0.2)]),
        buttonBackground: .purple,
        textColor: .white
    ),
    Theme(
        name: "Desert",
        primary: Color(red: 0.8, green: 0.6, blue: 0.4),
        secondary: Color(red: 0.6, green: 0.4, blue: 0.2),
        background: .gradient([
            Color(red: 0.95, green: 0.9, blue: 0.85),
            Color(red: 0.9, green: 0.85, blue: 0.8)
        ]),
        buttonBackground: Color(red: 0.8, green: 0.6, blue: 0.4),
        textColor: Color(red: 0.4, green: 0.2, blue: 0.0)
    ),
    Theme(
        name: "Ocean",
        primary: Color(red: 0.0, green: 0.5, blue: 0.8),
        secondary: Color(red: 0.0, green: 0.4, blue: 0.6),
        background: .gradient([
            Color(red: 0.9, green: 0.95, blue: 1.0),
            Color(red: 0.85, green: 0.9, blue: 0.95)
        ]),
        buttonBackground: Color(red: 0.0, green: 0.5, blue: 0.8),
        textColor: Color(red: 0.0, green: 0.3, blue: 0.5)
    ),
    Theme(
        name: "Olive Garden",
        primary: Color(red: 0.4, green: 0.5, blue: 0.2),
        secondary: Color(red: 0.5, green: 0.6, blue: 0.3),
        background: .gradient([
            Color(red: 0.95, green: 0.95, blue: 0.9),
            Color(red: 0.9, green: 0.9, blue: 0.85)
        ]),
        buttonBackground: Color(red: 0.4, green: 0.5, blue: 0.2),
        textColor: Color(red: 0.3, green: 0.4, blue: 0.1)
    ),
    Theme(
        name: "Mint",
        primary: Color(red: 0.2, green: 0.8, blue: 0.6),
        secondary: Color(red: 0.3, green: 0.7, blue: 0.5),
        background: .gradient([
            Color(red: 0.95, green: 1.0, blue: 0.98),
            Color(red: 0.9, green: 0.98, blue: 0.95)
        ]),
        buttonBackground: Color(red: 0.2, green: 0.8, blue: 0.6),
        textColor: Color(red: 0.1, green: 0.5, blue: 0.4)
    )
] 
