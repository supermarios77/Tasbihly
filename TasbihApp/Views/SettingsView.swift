import SwiftUI
import UIKit

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
        theme.headerColor
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
                                soundToggle
                                .padding()
                                .background(listRowBackground)
                                
                                targetStepper()
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
                                .onChange(of: notificationManager.isNotificationsEnabled) { newValue in
                                    HapticManager.shared.selectionChanged()
                                    if newValue {
                                        // Additional success feedback when enabling notifications
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            HapticManager.shared.success()
                                        }
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
                                            .onChange(of: notificationManager.reminderTime) { _ in
                                                HapticManager.shared.selectionChanged()
                                            }
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(theme.headerColor)
                }
            }
            .accentColor(theme.primary)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Toggle with haptic feedback for sound
    private var soundToggle: some View {
        Toggle(isOn: $isSoundEnabled) {
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(theme.primary)
                    .font(.system(size: 22))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sound Effects")
                        .foregroundColor(theme.textColor)
                    
                    Text("Play sound on count")
                        .font(.caption)
                        .foregroundColor(theme.secondary)
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: theme.primary))
        .onChange(of: isSoundEnabled) { _ in
            HapticManager.shared.selectionChanged()
        }
    }
    
    // Target stepper with haptic feedback
    private func targetStepper() -> some View {
        HStack {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(theme.primary)
                    .font(.system(size: 22))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target")
                        .foregroundColor(theme.textColor)
                    
                    Text("Default count target")
                        .font(.caption)
                        .foregroundColor(theme.secondary)
                }
            }
            
            Spacer()
            
            Stepper("\(target)", value: $target, in: 11...999, step: 11)
                .onChange(of: target) { _ in
                    HapticManager.shared.selectionChanged()
                }
        }
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
                        HapticManager.shared.mediumImpact()
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

