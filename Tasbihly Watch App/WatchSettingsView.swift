import SwiftUI

struct WatchSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = WatchDataManager.shared
    
    var body: some View {
        TabView {
            // Dhikr Selection
            ScrollView {
                VStack(spacing: 12) {
                    Text("Select Dhikr")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(Dhikr.common) { dhikr in
                        DhikrCell(dhikr: dhikr, isSelected: dataManager.currentDhikr.id == dhikr.id) {
                            withAnimation(.spring(response: 0.3)) {
                                dataManager.setDhikr(dhikr)
                            }
                        }
                    }
                    
                    NavigationLink {
                        MoreDhikrsView()
                    } label: {
                        HStack {
                            Label("More Dhikrs", systemImage: "ellipsis.circle.fill")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            
            // Settings
            ScrollView {
                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        SettingsToggle(
                            title: "Haptic Feedback",
                            icon: "hand.tap.fill",
                            color: .blue,
                            isOn: .init(
                                get: { dataManager.isHapticEnabled },
                                set: { _ in
                                    withAnimation {
                                        dataManager.toggleHaptic()
                                    }
                                }
                            )
                        )
                        
                        SettingsToggle(
                            title: "Sound",
                            icon: "speaker.wave.2.fill",
                            color: .purple,
                            isOn: .init(
                                get: { dataManager.isSoundEnabled },
                                set: { _ in
                                    withAnimation {
                                        dataManager.toggleSound()
                                    }
                                }
                            )
                        )
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

struct DhikrCell: View {
    let dhikr: Dhikr
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(dhikr.name)
                        .font(.system(.headline, design: .rounded))
                        .minimumScaleFactor(0.8)
                    Spacer()
                    Text("\(dhikr.count)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Text(dhikr.transliteration)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggle: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(.body, design: .rounded))
                Text(title)
                    .font(.system(.body, design: .rounded))
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: color))
    }
}

struct MoreDhikrsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = WatchDataManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Dhikr.more) { dhikr in
                    DhikrCell(dhikr: dhikr, isSelected: dataManager.currentDhikr.id == dhikr.id) {
                        withAnimation(.spring(response: 0.3)) {
                            dataManager.setDhikr(dhikr)
                            dismiss()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("More Dhikrs")
    }
}

struct WatchSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchSettingsView()
    }
} 
