import SwiftUI

struct DhikrSelectorView: View {
    @Environment(\.theme) private var theme
    let dhikrList: [Dhikr]
    @Binding var selectedDhikr: Dhikr
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(dhikrList) { dhikr in
                        DhikrRow(dhikr: dhikr, isSelected: dhikr == selectedDhikr)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(dhikr == selectedDhikr ? theme.primary.opacity(0.2) : theme.primary.opacity(0.05))
                            )
                            .onTapGesture {
                                selectedDhikr = dhikr
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                }
                .padding()
            }
            .background(theme.backgroundView.ignoresSafeArea())
            .navigationTitle("Select Dhikr")
            .navigationBarTitleDisplayMode(.inline)
            #if os(iOS16)
            .toolbarTitleMenu {
                Text("Choose Your Dhikr")
                    .foregroundColor(theme.headerColor)
            }
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(theme.primary)
                }
            }
        }
    }
    
    private struct DhikrRow: View {
        @Environment(\.theme) private var theme
        let dhikr: Dhikr
        let isSelected: Bool
        
        var body: some View {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dhikr.phrase)
                        .font(.headline)
                        .foregroundColor(theme.textColor)
                    
                    Text(dhikr.transliteration)
                        .font(.subheadline)
                        .foregroundColor(theme.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.primary)
                        .padding(6)
                        .background(Circle().fill(theme.primary.opacity(0.2)))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.primary.opacity(0.15) : theme.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? theme.primary : .clear, lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
