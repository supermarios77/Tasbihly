import SwiftUI
import StoreKit

// MARK: - Premium Locked View
struct PremiumLockedView: View {
    @Environment(\.theme) private var theme
    let onPurchase: () -> Void
    let onRestore: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.primary)
            
            Text("Unlock Custom Dhikrs")
                .font(.title2)
                .foregroundColor(theme.textColor)
            
            Text("Create and save your own dhikrs for just $4.99")
                .font(.subheadline)
                .foregroundColor(theme.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onPurchase) {
                Text("Unlock Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button(action: onRestore) {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundColor(theme.primary)
            }
        }
        .padding()
    }
}

// MARK: - Custom Dhikr List View
struct CustomDhikrListView: View {
    @Environment(\.theme) private var theme
    @ObservedObject var customDhikrManager: CustomDhikrManager
    
    var body: some View {
        List {
            ForEach(customDhikrManager.customDhikrs) { dhikr in
                DhikrCard(
                    dhikr: dhikr.toDhikr(),
                    isSelected: false,
                    theme: theme,
                    isAnimating: false,
                    isFavorite: false,
                    onFavorite: {}
                )
                .contextMenu {
                    Button(action: {
                        customDhikrManager.deleteCustomDhikr(dhikr)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Main Custom Dhikr View
struct CustomDhikrView: View {
    @Environment(\.theme) private var theme
    @StateObject private var customDhikrManager = CustomDhikrManager.shared
    @State private var showingAddSheet = false
    @State private var showingPurchaseAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Group {
                if customDhikrManager.isPremiumUnlocked {
                    CustomDhikrListView(customDhikrManager: customDhikrManager)
                } else {
                    PremiumLockedView(
                        onPurchase: { showingPurchaseAlert = true },
                        onRestore: {
                            customDhikrManager.restorePurchases { result in
                                switch result {
                                case .success:
                                    break
                                case .failure:
                                    errorMessage = "Failed to restore purchases. Please try again."
                                    showingErrorAlert = true
                                }
                            }
                        }
                    )
                }
            }
            .navigationTitle("Custom Dhikrs")
            .navigationBarItems(trailing: 
                customDhikrManager.isPremiumUnlocked ?
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                } : nil
            )
            .sheet(isPresented: $showingAddSheet) {
                AddCustomDhikrView()
            }
            .alert(isPresented: $showingPurchaseAlert) {
                Alert(
                    title: Text("Purchase Custom Dhikrs"),
                    message: Text("Unlock the ability to create and save your own custom dhikrs for $4.99"),
                    primaryButton: .default(Text("Purchase")) {
                        customDhikrManager.purchasePremium { result in
                            switch result {
                            case .success:
                                break
                            case .failure:
                                errorMessage = "Failed to complete purchase. Please try again."
                                showingErrorAlert = true
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - Add Custom Dhikr View
struct AddCustomDhikrView: View {
    @Environment(\.theme) private var theme
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var customDhikrManager = CustomDhikrManager.shared
    
    @State private var phrase = ""
    @State private var transliteration = ""
    @State private var translation = ""
    @State private var count = 33
    @State private var selectedCategory: DhikrCategory = .general
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dhikr Details")) {
                    TextField("Arabic Phrase", text: $phrase)
                        .autocapitalization(.none)
                    TextField("Transliteration", text: $transliteration)
                        .autocapitalization(.none)
                    TextField("Translation", text: $translation)
                        .autocapitalization(.none)
                    Stepper("Count: \(count)", value: $count, in: 1...1000)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(DhikrCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Custom Dhikr")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard !phrase.isEmpty && !transliteration.isEmpty && !translation.isEmpty else {
                            errorMessage = "Please fill in all fields"
                            showingErrorAlert = true
                            return
                        }
                        
                        let customDhikr = CustomDhikr(
                            phrase: phrase,
                            transliteration: transliteration,
                            translation: translation,
                            count: count,
                            category: selectedCategory
                        )
                        customDhikrManager.addCustomDhikr(customDhikr)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct CustomDhikrView_Previews: PreviewProvider {
    static var previews: some View {
        CustomDhikrView()
    }
} 