import SwiftUI

struct SettingsView: View {
    @Binding var isSoundEnabled: Bool
    @Binding var target: Int
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferences")) {
                    Toggle("Enable Sound", isOn: $isSoundEnabled)
                        .onChange(of: isSoundEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "isSoundEnabled")
                        }
                    
                    HStack {
                        Text("Target Count")
                        Spacer()
                        TextField("Set target", value: $target, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: target) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "target")
                            }
                    }
                    
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedThemeIndex) {
                        ForEach(0..<appThemes.count, id: \.self) { index in
                            Text(appThemes[index].name)
                                .tag(index)
                        }
                    }
                    .onChange(of: selectedThemeIndex) { newValue in
                        let safeIndex = min(max(newValue, 0), appThemes.count - 1)
                        if newValue != safeIndex {
                            selectedThemeIndex = safeIndex
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    Link("Rate App", destination: URL(string: "https://apps.apple.com")!)
                    Link("Share App", destination: URL(string: "https://apps.apple.com")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSoundEnabled: .constant(true), target: .constant(100))
    }
}
