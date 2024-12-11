import SwiftUI

struct ContentView: View {
    @AppStorage("isSoundEnabled") private var isSoundEnabled: Bool = false
    @AppStorage("target") private var target: Int = 0

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
