import SwiftUI

struct SettingsView: View {
    @Binding var isSoundEnabled: Bool
    @Binding var target: Int
    
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
