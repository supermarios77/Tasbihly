import SwiftUI

struct WatchSettingsView: View {
    @Binding var selectedDhikr: Dhikr
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: Dhikr?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(dhikrList) { dhikr in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedItem = dhikr
                            WKInterfaceDevice.current().play(.click)
                            
                            // Delay to show selection before dismissing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                selectedDhikr = dhikr
                                dismiss()
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dhikr.transliteration)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isSelected(dhikr) ? .green : .white)
                                
                                Text(dhikr.phrase)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if isSelected(dhikr) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isSelected(dhikr) ? Color.green.opacity(0.4) : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: isSelected(dhikr) ? .green.opacity(0.2) : .clear, radius: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(selectedItem == dhikr ? 0.95 : 1)
                    .animation(.spring(response: 0.3), value: selectedItem)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .navigationTitle("Select Dhikr")
    }
    
    private func isSelected(_ dhikr: Dhikr) -> Bool {
        dhikr.id == selectedDhikr.id || dhikr.id == selectedItem?.id
    }
} 