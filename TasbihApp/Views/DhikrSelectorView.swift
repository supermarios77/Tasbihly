import SwiftUI

struct DhikrSelectorView: View {
    @Environment(\.theme) private var theme
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var selectedCategory: DhikrCategory = .afterPrayer
    @State private var searchText = ""
    @Binding var selectedDhikr: Dhikr
    @Binding var selectedTab: Int
    @State private var selectedDhikrId: UUID?
    @State private var isAnimating = false
    @State private var showFavorites = false
    @State private var isLoading = false
    @State private var showFavoriteToast = false
    @State private var lastFavoriteAction = ""
    @State private var selectedThemeIndex = 0
    @State private var showingAddSheet = false
    
    private var filteredDhikrList: [Dhikr] {
        let baseList = showFavorites ? 
            dhikrList.filter { favoritesManager.isFavorite($0) } :
            (searchText.isEmpty ? getDhikrByCategory(selectedCategory) : 
                dhikrList.filter { dhikr in
                    dhikr.phrase.localizedCaseInsensitiveContains(searchText) ||
                    dhikr.transliteration.localizedCaseInsensitiveContains(searchText) ||
                    dhikr.translation.localizedCaseInsensitiveContains(searchText)
                }
            )
        return baseList
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundView
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Categories ScrollView with improved scrolling
                    if !showFavorites {
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
                                                    isLoading = true
                                                }
                                                // Haptic feedback
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                // Simulate loading for smooth transition
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation { isLoading = false }
                                                }
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
                    }
                    
                    // Enhanced Search Bar with voice search option
                    if !showFavorites {
                        SearchBar(text: $searchText, theme: theme)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                    
                    // Category Stats with Favorites toggle
                    HStack {
                        if showFavorites {
                            Text("Favorites")
                                .font(.headline)
                                .foregroundColor(theme.textColor)
                        } else {
                            Text("\(filteredDhikrList.count) Dhikr\(filteredDhikrList.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(theme.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            if CustomDhikrManager.shared.isPremiumUnlocked {
                                Button(action: {
                                    showingAddSheet = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.primary)
                                }
                            }
                            // Haptic feedback
                            HapticManager.shared.mediumImpact()
                            // Simulate loading for smooth transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation { isLoading = false }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    
                    if isLoading {
                        LoadingView(theme: theme)
                    } else if filteredDhikrList.isEmpty {
                        EmptyStateView(
                            theme: theme,
                            title: showFavorites ? "No Favorites Yet" : 
                                  (searchText.isEmpty ? "No Dhikr in this category" : "No results found"),
                            subtitle: showFavorites ? "Add some dhikrs to your favorites" :
                                     (searchText.isEmpty ? "Try another category" : "Try different search terms"),
                            icon: showFavorites ? "heart" : 
                                  (searchText.isEmpty ? "book.closed" : "magnifyingglass")
                        )
                    } else {
                        // Dhikr List with improved scrolling
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    // Custom Dhikrs Section
                                    if CustomDhikrManager.shared.isPremiumUnlocked && !showFavorites {
                                        let customDhikrs = CustomDhikrManager.shared.customDhikrs.filter { 
                                            searchText.isEmpty ? $0.category == selectedCategory : 
                                            $0.phrase.localizedCaseInsensitiveContains(searchText) ||
                                            $0.transliteration.localizedCaseInsensitiveContains(searchText) ||
                                            $0.translation.localizedCaseInsensitiveContains(searchText)
                                        }
                                        
                                        if !customDhikrs.isEmpty {
                                            HStack {
                                                Text("Custom Dhikrs")
                                                    .font(.headline)
                                                    .foregroundColor(theme.textColor)
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                            
                                            ForEach(customDhikrs) { customDhikr in
                                                DhikrCard(
                                                    dhikr: customDhikr.toDhikr(),
                                                    isSelected: customDhikr.toDhikr() == selectedDhikr,
                                                    theme: theme,
                                                    isAnimating: selectedDhikrId == customDhikr.id && isAnimating,
                                                    isFavorite: false,
                                                    onFavorite: {}
                                                )
                                                .id(customDhikr.id)
                                                .onTapGesture {
                                                    selectDhikr(customDhikr.toDhikr())
                                                }
                                                .contextMenu {
                                                    Button(action: {
                                                        CustomDhikrManager.shared.deleteCustomDhikr(customDhikr)
                                                    }) {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Regular Dhikrs
                                    ForEach(filteredDhikrList) { dhikr in
                                        DhikrCard(
                                            dhikr: dhikr,
                                            isSelected: dhikr == selectedDhikr,
                                            theme: theme,
                                            isAnimating: selectedDhikrId == dhikr.id && isAnimating,
                                            isFavorite: favoritesManager.isFavorite(dhikr),
                                            onFavorite: { toggleFavorite(dhikr) }
                                        )
                                        .id(dhikr.id)
                                        .onTapGesture {
                                            selectDhikr(dhikr)
                                        }
                                        .transition(.scale.combined(with: .opacity))
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
                
                // Favorite Toast
                if showFavoriteToast {
                    VStack {
                        Spacer()
                        ToastView(message: lastFavoriteAction, theme: theme)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(showFavorites ? "Favorites" : "Dhikr Library")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: !showFavorites && CustomDhikrManager.shared.isPremiumUnlocked ?
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(theme.primary)
                    } : nil
            )
            .sheet(isPresented: $showingAddSheet) {
                AddCustomDhikrView()
            }
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    // Haptic feedback when search starts
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                // Show loading state briefly for smooth transition
                withAnimation { isLoading = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation { isLoading = false }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func toggleFavorite(_ dhikr: Dhikr) {
        let isFavorite = favoritesManager.isFavorite(dhikr)
        favoritesManager.toggleFavorite(dhikr)
        
        // Show toast
        lastFavoriteAction = isFavorite ? "Removed from favorites" : "Added to favorites"
        withAnimation(.spring()) {
            showFavoriteToast = true
        }
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring()) {
                showFavoriteToast = false
            }
        }
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

struct LoadingView: View {
    let theme: Theme
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.primary)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear { isAnimating = true }
            
            Text("Loading Dhikrs...")
                .font(.headline)
                .foregroundColor(theme.textColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.backgroundView)
    }
}

struct EmptyStateView: View {
    let theme: Theme
    let title: String
    let subtitle: String
    let icon: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(theme.primary.opacity(0.5))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear { isAnimating = true }
            
            Text(title)
                .font(.headline)
                .foregroundColor(theme.textColor)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(theme.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

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
    let isFavorite: Bool
    let onFavorite: () -> Void
    @State private var checkmarkScale: CGFloat = 1.0
    @State private var showDetails = false
    @State private var dragOffset = CGSize.zero
    
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
            
            if showDetails {
                Text(dhikr.translation)
                    .font(.footnote)
                    .foregroundColor(theme.adaptiveSecondaryColor)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
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
                
                Button(action: {
                    onFavorite()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(isFavorite ? .red : theme.secondary)
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: isFavorite)
                }
                .padding(.horizontal, 8)
                
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
        .offset(x: dragOffset.width)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let translation = gesture.translation
                    dragOffset = CGSize(width: translation.width, height: 0)
                }
                .onEnded { gesture in
                    withAnimation(.spring()) {
                        if abs(dragOffset.width) > 50 {
                            // Trigger favorite action if swiped far enough
                            onFavorite()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        dragOffset = .zero
                    }
                }
        )
        .onTapGesture(count: 2) {
            withAnimation(.spring()) {
                showDetails.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        .animation(.spring(response: 0.3), value: isAnimating)
        .animation(.spring(response: 0.3), value: showDetails)
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

struct ToastView: View {
    let message: String
    let theme: Theme
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
    }
}

struct DhikrSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DhikrSelectorView(selectedDhikr: .constant(dhikrList[0]), selectedTab: .constant(0))
    }
}
