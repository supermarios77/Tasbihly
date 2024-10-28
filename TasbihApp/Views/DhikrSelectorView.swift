import SwiftUI

struct DhikrSelectorView: View {
    let dhikrList: [Dhikr]
    @Binding var selectedDhikr: Dhikr
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dhikrList) { dhikr in
                    Button(action: {
                        selectedDhikr = dhikr
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dhikr.phrase)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(dhikr.translation)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if dhikr == selectedDhikr {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select Dhikr")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
