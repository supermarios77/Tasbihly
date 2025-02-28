import SwiftUI

struct Theme {
    let primary: Color
    let secondary: Color
    let headerColor: Color
    let buttonBackground: Color
    let textColor: Color
    let name: String
    let background: ThemeBackground
    
    // Add computed property for text colors
    var adaptiveTextColor: Color {
        switch background {
        case .solid(let color):
            return isColorLight(color) ? .black : .white
        case .gradient(let colors):
            guard let firstColor = colors.first else { return .white }
            return isColorLight(firstColor) ? .black : .white
        case .pattern:
            return .white
        }
    }
    
    var adaptiveSecondaryColor: Color {
        adaptiveTextColor.opacity(0.7)
    }
    
    // Helper function to determine if a color is light
    private func isColorLight(_ color: Color) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // Using perceived brightness formula
        let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        return brightness > 0.6
    }
    
    // Add computed property for dark mode background
    func backgroundColors(for colorScheme: ColorScheme) -> [Color] {
        switch background {
        case .solid(let color):
            return [color]
        case .gradient(let colors):
            return colors
        case .pattern(let name):
            return [Color(name)]
        }
    }
}

enum ThemeBackground {
    case solid(Color)
    case gradient([Color])
    case pattern(String)
    
    var isLight: Bool {
        switch self {
        case .solid(let color):
            return color.brightness > 0.6
        case .gradient(let colors):
            return (colors.first?.brightness ?? 0) > 0.6
        case .pattern:
            return false
        }
    }
}

let appThemes: [Theme] = [
    // Pure White
    Theme(
        primary: Color(hex: "2ECC71"),
        secondary: Color(hex: "27AE60"),
        headerColor: Color(hex: "1D8348"),
        buttonBackground: Color(hex: "2ECC71"),
        textColor: Color(hex: "1A1A1A"),
        name: "Pure White",
        background: .solid(Color(hex: "FFFFFF"))
    ),
    
    // Deep Black
    Theme(
        primary: Color(hex: "00BCD4"),
        secondary: Color(hex: "0097A7"),
        headerColor: Color(hex: "00838F"),
        buttonBackground: Color(hex: "00BCD4"),
        textColor: Color(hex: "FFFFFF"),
        name: "Deep Black",
        background: .solid(Color(hex: "121212")) // Darker background for better contrast
    ),
    
    // Classic Paper
    Theme(
        primary: Color(hex: "8B4513"),  // Saddle brown
        secondary: Color(hex: "654321"),  // Dark brown
        headerColor: Color(hex: "4A2C1A"),
        buttonBackground: Color(hex: "8B4513"),
        textColor: Color(hex: "3E2723"),  // Dark brown
        name: "Classic Paper",
        background: .solid(Color(hex: "FDF5E6"))  // Old paper
    ),
    
    // Midnight Oil
    Theme(
        primary: Color(hex: "FFD700"),  // Gold
        secondary: Color(hex: "FFB300"),  // Orange
        headerColor: Color(hex: "CC9200"),
        buttonBackground: Color(hex: "FFD700"),
        textColor: Color(hex: "FFFFFF"),  // White
        name: "Midnight Oil",
        background: .solid(Color(hex: "1A1A1A"))  // Soft black
    ),
    
    // Modern Contrast
    Theme(
        primary: Color(hex: "E91E63"),  // Pink
        secondary: Color(hex: "C2185B"),  // Dark pink
        headerColor: Color(hex: "9A1451"),
        buttonBackground: Color(hex: "E91E63"),
        textColor: Color(hex: "212121"),  // Dark gray
        name: "Modern Contrast",
        background: .solid(Color(hex: "F5F5F5"))  // Light gray
    ),
    
    // Professional Dark
    Theme(
        primary: Color(hex: "4CAF50"),  // Green
        secondary: Color(hex: "388E3C"),  // Dark green
        headerColor: Color(hex: "2E7D32"),
        buttonBackground: Color(hex: "4CAF50"),
        textColor: Color(hex: "FFFFFF"),  // White
        name: "Professional Dark",
        background: .solid(Color(hex: "121212"))  // Rich black
    ),
    
    // Clean Light
    Theme(
        primary: Color(hex: "2196F3"),  // Blue
        secondary: Color(hex: "1976D2"),  // Dark blue
        headerColor: Color(hex: "1565C0"),
        buttonBackground: Color(hex: "2196F3"),
        textColor: Color(hex: "212121"),  // Dark gray
        name: "Clean Light",
        background: .solid(Color(hex: "FFFFFF"))  // Pure white
    ),
    
    // High Contrast
    Theme(
        primary: Color(hex: "FF5722"),  // Orange
        secondary: Color(hex: "E64A19"),  // Dark orange
        headerColor: Color(hex: "BF360C"),
        buttonBackground: Color(hex: "FF5722"),
        textColor: Color(hex: "000000"),  // Pure black
        name: "High Contrast",
        background: .solid(Color(hex: "FFFFFF"))  // Pure white
    )
]

// Helper for color brightness
extension Color {
    var brightness: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        return ((red * 299) + (green * 587) + (blue * 114)) / 1000
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Add these extensions for global access
extension Theme {
    var backgroundView: some View {
        Group {
            switch background {
            case .solid(let color):
                color
            case .gradient(let colors):
                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .pattern(let name):
                Image(name)
                    .resizable()
            }
        }
    }
    
    var color: Color {
        switch background {
        case .solid(let color): return color
        case .gradient(let colors): return colors.first ?? .clear
        case .pattern: return .clear
        }
    }
}

// Add theme environment key
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = appThemes[0]
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
} 