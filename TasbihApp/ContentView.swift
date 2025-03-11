import SwiftUI

struct ContentView: View {
    @AppStorage("isSoundEnabled") private var isSoundEnabled = true
    @AppStorage("target") private var target = 33
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex: Int = 0
    @State private var showSettings = false
    @State private var selectedDhikr = dhikrList[0]
    @State private var selectedTab = 0
    
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
            
            TabView(selection: $selectedTab) {
                TasbihView(isSoundEnabled: $isSoundEnabled, target: $target, selectedDhikr: $selectedDhikr)
                    .tabItem {
                        Label("Counter", systemImage: "circle.grid.3x3.fill")
                    }
                    .tag(0)
                
                DhikrSelectorView(selectedDhikr: $selectedDhikr, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Library", systemImage: "books.vertical.fill")
                    }
                    .tag(1)
                
                SettingsView(isSoundEnabled: $isSoundEnabled, target: $target)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .accentColor(currentTheme.primary)
            .onAppear(perform: updateAppearance)
            .onChange(of: selectedThemeIndex) { _ in
                updateAppearance()
            }
        }
        .environment(\.theme, currentTheme)
        .accentColor(currentTheme.primary)
    }
    
    private func updateAppearance() {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
