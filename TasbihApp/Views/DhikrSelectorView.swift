import SwiftUI

struct DhikrSelectorView: View {
    @Environment(\.theme) private var theme
    @State private var selectedCategory: DhikrCategory = .afterPrayer
    @State private var searchText = ""
    @Binding var selectedDhikr: Dhikr
    @Binding var selectedTab: Int
    @State private var selectedDhikrId: UUID?
    @State private var isAnimating = false
    
    private var filteredDhikrList: [Dhikr] {
        if searchText.isEmpty {
            return getDhikrByCategory(selectedCategory)
        } else {
            return dhikrList.filter { dhikr in
                dhikr.phrase.localizedCaseInsensitiveContains(searchText) ||
                dhikr.transliteration.localizedCaseInsensitiveContains(searchText) ||
                dhikr.translation.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundView
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Categories ScrollView with improved scrolling
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(DhikrCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: category == selectedCategory,
                                        action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedCategory = category
                                            }
                                            // Haptic feedback
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    )
                                    .id(category)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .onChange(of: selectedCategory) { newCategory in
                            withAnimation {
                                proxy.scrollTo(newCategory, anchor: .center)
                            }
                        }
                    }
                    
                    // Enhanced Search Bar
                    SearchBar(text: $searchText, theme: theme)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    // Category Stats
                    if searchText.isEmpty {
                        HStack {
                            Text("\(filteredDhikrList.count) Dhikr\(filteredDhikrList.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(theme.secondary)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                    }
                    
                    // Dhikr List with improved scrolling
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredDhikrList) { dhikr in
                                    DhikrCard(
                                        dhikr: dhikr,
                                        isSelected: dhikr == selectedDhikr,
                                        theme: theme,
                                        isAnimating: selectedDhikrId == dhikr.id && isAnimating
                                    )
                                    .id(dhikr.id)
                                    .onTapGesture {
                                        selectDhikr(dhikr)
                                    }
                                }
                            }
                            .padding()
                        }
                        .onChange(of: selectedCategory) { _ in
                            if let firstDhikr = filteredDhikrList.first {
                                withAnimation {
                                    proxy.scrollTo(firstDhikr.id, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dhikr Library")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    // Haptic feedback when search starts
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func selectDhikr(_ dhikr: Dhikr) {
        // Visual feedback
        selectedDhikrId = dhikr.id
        isAnimating = true
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        
        withAnimation(.spring(response: 0.3)) {
            selectedDhikr = dhikr
            
            // Delay the tab switch slightly for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    selectedTab = 0 // Switch to Tasbih tab
                    generator.notificationOccurred(.success)
                }
            }
            
            // Reset animation state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }
}

// MARK: - Supporting Views

struct CategoryButton: View {
    @Environment(\.theme) private var theme
    let category: DhikrCategory
    let isSelected: Bool
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                Text(category.rawValue)
                    .font(.system(.subheadline, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? theme.primary : theme.primary.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 1)
            )
            .foregroundColor(isSelected ? .white : theme.primary)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isAnimating)
        }
        .buttonStyle(.plain)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let theme: Theme
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.secondary)
            
            TextField("Search by text or translation...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(theme.textColor)
            
            if !text.isEmpty {
                Button(action: { 
                    withAnimation(.spring(response: 0.3)) {
                        isAnimating = true
                        text = ""
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAnimating = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.secondary)
                        .scaleEffect(isAnimating ? 0.8 : 1.0)
                        .animation(.spring(response: 0.3), value: isAnimating)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primary.opacity(0.1))
        )
    }
}

struct DhikrCard: View {
    let dhikr: Dhikr
    let isSelected: Bool
    let theme: Theme
    let isAnimating: Bool
    @State private var checkmarkScale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dhikr.phrase)
                        .font(.title2)
                        .foregroundColor(theme.textColor)
                    
                    Text(dhikr.transliteration)
                        .font(.subheadline)
                        .foregroundColor(theme.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(theme.primary)
                        .scaleEffect(checkmarkScale)
                        .onAppear {
                            withAnimation(.spring(response: 0.3)) {
                                checkmarkScale = 1.2
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3)) {
                                    checkmarkScale = 1.0
                                }
                            }
                        }
                }
            }
            
            Text(dhikr.translation)
                .font(.footnote)
                .foregroundColor(theme.adaptiveSecondaryColor)
            
            HStack {
                Label(
                    title: { Text("\(dhikr.count)×").font(.caption.bold()) },
                    icon: { Image(systemName: "repeat") }
                )
                .foregroundColor(theme.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(theme.primary.opacity(0.1))
                )
                
                Spacer()
                
                CategoryTag(category: dhikr.category, theme: theme)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isAnimating ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isAnimating)
    }
}

struct CategoryTag: View {
    let category: DhikrCategory
    let theme: Theme
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 10))
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.spring(response: 0.3)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
            Text(category.rawValue)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(theme.primary.opacity(0.15))
        )
        .foregroundColor(theme.primary)
    }
}

struct DhikrSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DhikrSelectorView(selectedDhikr: .constant(dhikrList[0]), selectedTab: .constant(0))
    }
}
