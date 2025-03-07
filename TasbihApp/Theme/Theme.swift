import SwiftUI

struct Theme {
    let primary: Color
    let secondary: Color
    let headerColor: Color
    let buttonBackground: Color
    let textColor: Color
    let name: String
    let background: ThemeBackground
    
    // Enhanced text colors
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
    
    // New computed properties for enhanced UI
    var surfaceColor: Color {
        switch background {
        case .solid(let color):
            return isColorLight(color) ? 
                Color.white.opacity(0.7) : 
                Color.black.opacity(0.3)
        case .gradient, .pattern:
            return Color.black.opacity(0.2)
        }
    }
    
    var shadowColor: Color {
        switch background {
        case .solid(let color):
            return isColorLight(color) ? 
                Color.black.opacity(0.1) : 
                Color.white.opacity(0.1)
        case .gradient, .pattern:
            return Color.black.opacity(0.15)
        }
    }
    
    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [primary, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var isDark: Bool {
        !isColorLight(background.color)
    }
    
    // Enhanced color helpers
    var primaryVariant: Color {
        primary.opacity(0.8)
    }
    
    var secondaryVariant: Color {
        secondary.opacity(0.8)
    }
    
    var onSurface: Color {
        adaptiveTextColor
    }
    
    var onSurfaceVariant: Color {
        adaptiveTextColor.opacity(0.6)
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
    
    // Enhanced background colors for different states
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
    
    // New helper methods for UI states
    func opacity(for state: ThemeState) -> Double {
        switch state {
        case .normal:
            return 1.0
        case .pressed:
            return 0.8
        case .disabled:
            return 0.4
        case .highlighted:
            return 0.9
        }
    }
    
    func elevation(for level: ThemeElevation) -> Double {
        switch level {
        case .none:
            return 0
        case .low:
            return 2
        case .medium:
            return 4
        case .high:
            return 8
        }
    }
}

// New enums for theme states
enum ThemeState {
    case normal
    case pressed
    case disabled
    case highlighted
}

enum ThemeElevation {
    case none
    case low
    case medium
    case high
}

enum ThemeBackground {
    case solid(Color)
    case gradient([Color])
    case pattern(String)
    
    var color: Color {
        switch self {
        case .solid(let color):
            return color
        case .gradient(let colors):
            return colors.first ?? .clear
        case .pattern:
            return .clear
        }
    }
    
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
    // OLED Dark (Default)
    Theme(
        primary: Color(hex: "00BCD4"),      // Vibrant cyan
        secondary: Color(hex: "80DEEA"),     // Light cyan
        headerColor: Color(hex: "E0F7FA"),   // Very light cyan for header text
        buttonBackground: Color(hex: "00ACC1"), // Medium cyan
        textColor: Color(hex: "FFFFFF"),     // Pure white
        name: "OLED Dark",
        background: .solid(Color(hex: "000000")) // True black for OLED
    ),
    
    // Midnight Blue
    Theme(
        primary: Color(hex: "4A90E2"),      // Ocean blue
        secondary: Color(hex: "5B9EED"),     // Light ocean blue
        headerColor: Color(hex: "BBE1FF"),   // Light blue for header text
        buttonBackground: Color(hex: "4A90E2"), // Ocean blue
        textColor: Color(hex: "FFFFFF"),     // White
        name: "Midnight Blue",
        background: .solid(Color(hex: "1A1B2E")) // Dark navy
    ),
    
    // Nature Dark
    Theme(
        primary: Color(hex: "4CAF50"),      // Forest green
        secondary: Color(hex: "81C784"),     // Light green
        headerColor: Color(hex: "C8E6C9"),   // Light green for header text
        buttonBackground: Color(hex: "43A047"), // Medium green
        textColor: Color(hex: "FFFFFF"),     // White
        name: "Nature Dark",
        background: .solid(Color(hex: "1C1C1C")) // Soft black
    ),
    
    // Sepia Light
    Theme(
        primary: Color(hex: "8B4513"),      // Sepia brown
        secondary: Color(hex: "A0522D"),     // Light sepia
        headerColor: Color(hex: "3E2723"),   // Dark brown for header text
        buttonBackground: Color(hex: "8B4513"), // Sepia brown
        textColor: Color(hex: "3E2723"),     // Dark brown text
        name: "Sepia Light",
        background: .solid(Color(hex: "FDF5E6")) // Old paper
    ),
    
    // Pure Light
    Theme(
        primary: Color(hex: "2196F3"),      // Sky blue
        secondary: Color(hex: "64B5F6"),     // Light blue
        headerColor: Color(hex: "0D47A1"),   // Deep blue for header text
        buttonBackground: Color(hex: "2196F3"), // Sky blue
        textColor: Color(hex: "212121"),     // Near black
        name: "Pure Light",
        background: .solid(Color(hex: "FFFFFF")) // Pure white
    ),
    
    // Royal Dark
    Theme(
        primary: Color(hex: "9C27B0"),      // Purple
        secondary: Color(hex: "BA68C8"),     // Light purple
        headerColor: Color(hex: "E1BEE7"),   // Light purple for header text
        buttonBackground: Color(hex: "9C27B0"), // Purple
        textColor: Color(hex: "FFFFFF"),     // White
        name: "Royal Dark",
        background: .solid(Color(hex: "121212")) // Material dark
    ),
    
    // Golden Dark
    Theme(
        primary: Color(hex: "FFD700"),      // Gold
        secondary: Color(hex: "FFC107"),     // Amber
        headerColor: Color(hex: "FFE57F"),   // Light gold for header text
        buttonBackground: Color(hex: "FFD700"), // Gold
        textColor: Color(hex: "FFFFFF"),     // White
        name: "Golden Dark",
        background: .solid(Color(hex: "1A1A1A")) // Soft black
    ),
    
    // High Contrast Light
    Theme(
        primary: Color(hex: "000000"),      // Pure black
        secondary: Color(hex: "212121"),     // Dark gray
        headerColor: Color(hex: "000000"),   // Pure black for header text
        buttonBackground: Color(hex: "000000"), // Pure black
        textColor: Color(hex: "000000"),     // Pure black
        name: "High Contrast",
        background: .solid(Color(hex: "FFFFFF")) // Pure white
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

// UI Extensions for Theme
extension View {
    func themedSurface(_ theme: Theme, elevation: ThemeElevation = .none) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surfaceColor)
                .shadow(
                    color: theme.shadowColor,
                    radius: theme.elevation(for: elevation),
                    x: 0,
                    y: theme.elevation(for: elevation) / 2
                )
        )
    }
    
    func themedButton(_ theme: Theme) -> some View {
        self.buttonStyle(ThemedButtonStyle(theme: theme))
    }
    
    func themedText(_ theme: Theme, isSecondary: Bool = false) -> some View {
        self.foregroundColor(isSecondary ? theme.adaptiveSecondaryColor : theme.adaptiveTextColor)
    }
    
    func themedGlassmorphic(_ theme: Theme) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.surfaceColor)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 0.5)
                )
                .blur(radius: 3)
        )
    }
}

// Custom button style
struct ThemedButtonStyle: ButtonStyle {
    let theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.accentGradient)
                    .opacity(configuration.isPressed ? theme.opacity(for: .pressed) : theme.opacity(for: .normal))
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Theme animation modifier
struct ThemeTransition: ViewModifier {
    let theme: Theme
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: 0.3), value: theme.name)
    }
}

extension View {
    func withThemeTransition(_ theme: Theme) -> some View {
        self.modifier(ThemeTransition(theme: theme))
    }
}

// Theme color scheme detection
extension Theme {
    var preferredColorScheme: ColorScheme? {
        isDark ? .dark : .light
    }
    
    func adaptiveColor(_ light: Color, _ dark: Color) -> Color {
        isDark ? dark : light
    }
}

// Theme-aware modifiers
extension View {
    func themedCard(_ theme: Theme) -> some View {
        self
            .padding()
            .background(theme.surfaceColor)
            .cornerRadius(16)
            .shadow(
                color: theme.shadowColor,
                radius: theme.elevation(for: .low),
                x: 0,
                y: 2
            )
    }
    
    func themedOverlay(_ theme: Theme) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    theme.isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1),
                    lineWidth: 0.5
                )
        )
    }
} 