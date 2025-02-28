import SwiftUI
import AVFoundation
import UIKit

struct TasbihView: View {
    @State private var selectedDhikr = dhikrList[0]
    @State private var counter = UserDefaults.standard.integer(forKey: "counter")
    @Binding var isSoundEnabled: Bool
    @Binding var target: Int
    @State private var showDhikrSelector = false
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex: Int = 0
    @State private var isAnimating = false
    @State private var showCompletion = false
    
    private var audioPlayer: AVAudioPlayer?
    
    private var currentTheme: Theme {
        appThemes[selectedThemeIndex]
    }
    
    init(isSoundEnabled: Binding<Bool>, target: Binding<Int>) {
        self._isSoundEnabled = isSoundEnabled
        self._target = target
        configureAudioSession()
        loadSound()
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private mutating func loadSound() {
        if let soundURL = Bundle.main.url(forResource: "tap", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound file: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        // Main content
                        VStack(spacing: geometry.size.height * 0.05) {
                            dhikrSection
                                .frame(maxWidth: 600)
                                .padding(.top, geometry.size.height * 0.05)
                            
                            Spacer()
                            
                            counterButton
                                .scaleEffect(geometry.size.width >= 768 ? 1.2 : 1.0)
                            
                            Spacer()
                            
                            resetButton
                                .padding(.bottom, geometry.size.height * 0.05)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .navigationTitle("Tasbihly")
                .navigationBarTitleDisplayMode(.inline)
                #if os(iOS16)
                .toolbarTitleMenu {
                    Text("Dhikr Counter")
                        .foregroundColor(currentTheme.headerColor)
                }
                #endif
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showDhikrSelector.toggle() }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(currentTheme.primary)
                        }
                    }
                }
                
                .alert(isPresented: $showCompletion) {
                    Alert(
                        title: Text("ما شاء الله"),
                        message: Text(
                            """
                            Set Complete!
                            
                            \(selectedDhikr.count) times
                            Total: \(counter)
                            Sets: \(counter / selectedDhikr.count)
                            """
                        ),
                        dismissButton: .default(Text("OK")) {
                            withAnimation { isAnimating = false }
                        }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showDhikrSelector) {
            DhikrSelectorView(dhikrList: dhikrList, selectedDhikr: $selectedDhikr)
        }
    }
    
    private var dhikrSection: some View {
        VStack(spacing: 16) {
            Text(selectedDhikr.phrase)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 48 : 32, 
                             weight: .bold, 
                             design: .rounded))
                .foregroundColor(currentTheme.textColor)
                .multilineTextAlignment(.center)
            
            Text(selectedDhikr.transliteration)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 36 : 24, 
                             design: .rounded))
                .foregroundColor(currentTheme.secondary)
                .italic()
            
            Text(selectedDhikr.translation)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 20, 
                             design: .rounded))
                .foregroundColor(currentTheme.textColor)
                .multilineTextAlignment(.center)
            
            Text("Recommended: \(selectedDhikr.count)×")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18,
                             weight: .medium,
                             design: .rounded))
                .foregroundColor(currentTheme.secondary)
                .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    private var counterButton: some View {
        Button(action: handleCounterTap) {
            CounterButtonContent(
                counter: counter,
                selectedDhikr: selectedDhikr,
                currentTheme: currentTheme,
                isAnimating: isAnimating
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Count")
        .accessibilityHint("Tap to increase count. Total count is \(counter). Current set: \(counter % selectedDhikr.count) out of \(selectedDhikr.count)")
    }
    
    private func handleCounterTap() {
        counter += 1
        UserDefaults.standard.set(counter, forKey: "counter")
        
        if isSoundEnabled {
            playSound()
        }
        
        triggerHapticFeedback()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isAnimating = true
        }
        
        // Check if set is complete
        if counter % selectedDhikr.count == 0 {
            showCompletion = true
        }
        
        // Reset animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                isAnimating = false
            }
        }
    }
    
    private struct CounterButtonContent: View {
        let counter: Int
        let selectedDhikr: Dhikr
        let currentTheme: Theme
        let isAnimating: Bool
        
        var body: some View {
            ZStack {
                // Neumorphic background
                Circle()
                    .fill(currentTheme.buttonBackground.opacity(0.1))
                    .shadow(
                        color: currentTheme.buttonBackground.opacity(0.2),
                        radius: 10,
                        x: -5,
                        y: -5
                    )
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: 10,
                        x: 5,
                        y: 5
                    )
                
                // Progress rings with glow effect
                ProgressRings(
                    counter: counter,
                    selectedDhikr: selectedDhikr,
                    currentTheme: currentTheme
                )
                
                // Counter display with improved typography
                CounterDisplay(
                    counter: counter,
                    selectedDhikr: selectedDhikr,
                    currentTheme: currentTheme
                )
                .scaleEffect(isAnimating ? 0.97 : 1.0)
                
                // Enhanced ripple effect
                if isAnimating {
                    Circle()
                        .stroke(currentTheme.primary.opacity(0.3), lineWidth: 3)
                        .scaleEffect(1.2)
                        .opacity(0)
                        .animation(.easeOut(duration: 0.6), value: isAnimating)
                }
            }
            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200)
        }
    }
    
    private var backgroundGradient: some View {
        Group {
            if case .solid(let color) = currentTheme.background {
                color.edgesIgnoringSafeArea(.all)
            } else {
                LinearGradient(
                    colors: currentTheme.backgroundColors(for: colorScheme),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private struct ProgressRings: View {
        @Environment(\.theme) private var theme
        let counter: Int
        let selectedDhikr: Dhikr
        let currentTheme: Theme
        
        var body: some View {
            ZStack {
                Circle()
                    .stroke(theme.primary.opacity(0.1), lineWidth: 15)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(theme.primary, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
        }
        
        private var progress: CGFloat {
            min(CGFloat(counter % selectedDhikr.count) / CGFloat(selectedDhikr.count), 1.0)
        }
    }
    
    private struct CounterDisplay: View {
        @Environment(\.theme) private var theme
        let counter: Int
        let selectedDhikr: Dhikr
        let currentTheme: Theme
        
        var body: some View {
            VStack(spacing: 4) {
                Text("\(counter)")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 90 : 60, 
                                weight: .heavy,
                                design: .rounded))
                    .foregroundColor(theme.textColor)
                    .shadow(color: theme.primary.opacity(0.1), radius: 5, x: 0, y: 3)
                
                // Progress indicator with custom layout
                HStack(spacing: 0) {
                    Text("\(counter % selectedDhikr.count)")
                        .font(.system(.title3, design: .monospaced).weight(.bold))
                        .foregroundColor(theme.textColor)
                    
                    Text("/\(selectedDhikr.count)")
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(theme.secondary)
                }
                .padding(6)
                .background(
                    Capsule()
                        .fill(theme.buttonBackground.opacity(0.1))
                )
                
                // Set counter with improved design
                Text("Set \((counter / selectedDhikr.count) + 1)")
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundColor(theme.adaptiveSecondaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(theme.primary.opacity(0.1))
                    )
            }
            .padding()
        }
    }
    
    private var resetButton: some View {
        Button(action: resetCounter) {
            Text("Reset")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(currentTheme.primary)
                )
                .shadow(color: currentTheme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func playSound() {
        audioPlayer?.play()
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func showCompletionAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showCompletion = true
            isAnimating = true
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.notificationOccurred(.success)
        }
    }

    private func resetCounter() {
        counter = 0
        UserDefaults.standard.set(counter, forKey: "counter")
        
        // Add haptic feedback for reset
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct TasbihView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Update the glassMorphic modifier
extension View {
    func glassMorphic(cornerRadius: CGFloat = 30) -> some View {
        self.background(
            ZStack {
                Color(UIColor.systemBackground)
                    .opacity(0.7)
                    .blur(radius: 8)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
            .cornerRadius(cornerRadius)
        )
    }
}

// Update StatCard to be iOS 14 compatible
private struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .background(
            ZStack {
                Color(UIColor.systemBackground)
                    .opacity(0.7)
                    .blur(radius: 8)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
        )
        .cornerRadius(16)
    }
}

// New component: CompletionBadge
private struct CompletionBadge: View {
    let currentTheme: Theme
    
    var body: some View {
        ZStack {
            Circle()
                .fill(currentTheme.primary.opacity(0.1))
                .frame(width: 80, height: 80)
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(currentTheme.primary)
                .modifier(BounceEffectModifier())
        }
    }
}

// Create compatibility modifier
struct BounceEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 17.0, *) {
                content
                    .symbolEffect(.bounce, options: .repeating)
            } else {
                content
            }
        }
    }
}

// New component: CompletionStats
private struct CompletionStats: View {
    let counter: Int
    let selectedDhikr: Dhikr
    let currentTheme: Theme
    
    var body: some View {
        VStack(spacing: 15) {
            Text("ما شاء الله")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(currentTheme.primary)
            
            VStack(spacing: 8) {
                StatItem(title: "Total Count", value: "\(counter)", theme: currentTheme)
                StatItem(title: "Completed Sets", value: "\(counter / selectedDhikr.count)", theme: currentTheme)
                StatItem(title: "Current Set", value: "\((counter % selectedDhikr.count))/\(selectedDhikr.count)", theme: currentTheme)
            }
        }
    }
}

// Enhanced StatItem component
private struct StatItem: View {
    let title: String
    let value: String
    let theme: Theme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.adaptiveSecondaryColor)
            
            Spacer()
            
            Text(value)
                .font(.system(.body, design: .monospaced).weight(.medium))
                .foregroundColor(theme.textColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.primary.opacity(0.05))
        )
    }
}

// Add compatibility extension
extension View {
    @ViewBuilder
    func ifAvailable<Content: View>(_ version: Double, _ transform: (Self) -> Content) -> some View {
        if #available(iOS 17.0, *) {
            transform(self)
        } else {
            self
        }
    }
}

// Add the missing ScaleButtonStyle
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
