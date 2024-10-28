import SwiftUI

struct ContentView: View {
    @State private var isSoundEnabled = UserDefaults.standard.bool(forKey: "isSoundEnabled")
    @State private var target = UserDefaults.standard.integer(forKey: "target")

    var body: some View {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
