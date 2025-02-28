import SwiftUI

struct ContentView: View {
    @AppStorage("isSoundEnabled") private var isSoundEnabled = true
    @AppStorage("target") private var target = 33
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex: Int = 0
    @State private var showSettings = false
    
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
            currentTheme.backgroundView
                .ignoresSafeArea()
            
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
            .accentColor(currentTheme.primary)
            .onAppear {
                // Update navigation bar appearance to be transparent
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = .clear
                appearance.titleTextAttributes = [.foregroundColor: UIColor(currentTheme.textColor)]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(currentTheme.textColor)]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().tintColor = UIColor(currentTheme.primary)
                
                // Update tab bar appearance
                let tabAppearance = UITabBarAppearance()
                tabAppearance.configureWithTransparentBackground()
                tabAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
                UITabBar.appearance().standardAppearance = tabAppearance
                UITabBar.appearance().tintColor = UIColor(currentTheme.primary)
                
                // Other appearance updates
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(currentTheme.primary)
                UISwitch.appearance().onTintColor = UIColor(currentTheme.primary)
            }
        }
        .environment(\.theme, currentTheme)
        .accentColor(currentTheme.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
