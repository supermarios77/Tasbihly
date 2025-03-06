import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isSoundEnabled: Bool
    @Binding var target: Int
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex = 0
    @StateObject private var notificationManager = NotificationManager()
    
    private var listRowBackground: some View {
        theme.background.isLight ? 
            Color.black.opacity(0.05) :
            Color.white.opacity(0.07)
    }
    
    private var sectionHeaderColor: Color {
        theme.background.isLight ?
            theme.primary :
            theme.primary.opacity(0.8)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundView
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Appearance Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Appearance")
                                .textCase(.uppercase)
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(sectionHeaderColor)
                                .padding(.horizontal)
                            
                            ThemePicker(selectedThemeIndex: $selectedThemeIndex)
                                .padding()
                                .background(listRowBackground)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                        
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preferences")
                                .textCase(.uppercase)
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(sectionHeaderColor)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                Toggle(isOn: $isSoundEnabled) {
                                    Label {
                                        Text("Sound Effects")
                                            .foregroundColor(theme.adaptiveTextColor)
                                    } icon: {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .foregroundColor(theme.primary)
                                    }
                                }
                                .padding()
                                .background(listRowBackground)
                                
                                HStack {
                                    Label {
                                        Text("Daily Target")
                                            .foregroundColor(theme.adaptiveTextColor)
                                    } icon: {
                                        Image(systemName: "target")
                                            .foregroundColor(theme.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(target)")
                                        .foregroundColor(theme.adaptiveSecondaryColor)
                                    
                                    Stepper("", value: $target, in: 33...1000)
                                        .labelsHidden()
                                }
                                .padding()
                                .background(listRowBackground)
                            }
                            .cornerRadius(10)
                        }
                        
                        // Notifications Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notifications")
                                .textCase(.uppercase)
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(sectionHeaderColor)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                Toggle(isOn: $notificationManager.isNotificationsEnabled) {
                                    Label {
                                        Text("Daily Reminders")
                                            .foregroundColor(theme.adaptiveTextColor)
                                    } icon: {
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(theme.primary)
                                    }
                                }
                                .padding()
                                .background(listRowBackground)
                                
                                if notificationManager.isNotificationsEnabled {
                                    HStack {
                                        Label {
                                            Text("Reminder Time")
                                                .foregroundColor(theme.adaptiveTextColor)
                                        } icon: {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(theme.primary)
                                        }
                                        
                                        Spacer()
                                        
                                        DatePicker("", 
                                                 selection: $notificationManager.reminderTime,
                                                 displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .accentColor(theme.primary)
                                    }
                                    .padding()
                                    .background(listRowBackground)
                                }
                            }
                            .cornerRadius(10)
                            
                            if notificationManager.isNotificationsEnabled {
                                Text("You will receive a daily reminder at the selected time")
                                    .font(.caption)
                                    .foregroundColor(theme.adaptiveSecondaryColor)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(theme.primary)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ThemePicker: View {
    @Binding var selectedThemeIndex: Int
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack {
            Label {
                Text("Theme")
                    .foregroundColor(theme.adaptiveTextColor)
            } icon: {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(theme.primary)
            }
            
            Spacer()
            
            Menu {
                ForEach(0..<appThemes.count, id: \.self) { index in
                    Button(action: {
                        selectedThemeIndex = index
                    }) {
                        HStack {
                            Text(appThemes[index].name)
                            if index == selectedThemeIndex {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(appThemes[selectedThemeIndex].name)
                    .foregroundColor(theme.adaptiveSecondaryColor)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSoundEnabled: .constant(true), target: .constant(100))
    }
}
