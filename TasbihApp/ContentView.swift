import SwiftUI

struct ContentView: View {
    @AppStorage("isSoundEnabled") private var isSoundEnabled: Bool = false
    @AppStorage("target") private var target: Int = 0
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex: Int = 0
    
    private var currentTheme: Theme {
        let safeIndex = min(max(selectedThemeIndex, 0), appThemes.count - 1)
        if selectedThemeIndex != safeIndex {
            selectedThemeIndex = safeIndex
        }
        return appThemes[safeIndex]
    }

    private var backgroundView: some View {
        Group {
            switch currentTheme.background {
            case .solid(let color):
                color.ignoresSafeArea()
            case .gradient(let colors):
                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            case .pattern(let imageName):
                Image(imageName)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
            }
        }
    }

    var body: some View {
        ZStack {
            backgroundView
            
            TabView {
                TasbihView(isSoundEnabled: $isSoundEnabled, target: $target)
                    .tabItem {
                        Label("Tasbih", systemImage: "circle.grid.3x3.fill")
                    }
                
                SettingsView(isSoundEnabled: $isSoundEnabled, target: $target)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        }
        .accentColor(currentTheme.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
