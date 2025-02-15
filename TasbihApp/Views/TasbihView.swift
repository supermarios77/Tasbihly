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
    @State private var pulseEffect = false
    @State private var particleEffects: [ParticleEffect] = []
    @State private var rotationAngle: Double = 0
    @State private var showingCelebration = false
    
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
            GeometryReader { geometry in
                ZStack {
                    // Animated Background
                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    currentTheme.buttonBackground.opacity(0.3),
                                    currentTheme.buttonBackground.opacity(0.1),
                                    currentTheme.buttonBackground.opacity(0.3)
                                ]),
                                center: .center,
                                startAngle: .degrees(rotationAngle),
                                endAngle: .degrees(rotationAngle + 360)
                            )
                        )
                        .blur(radius: 20)
                        .scaleEffect(1.5)
                    
                    // Pulse effect
                    Circle()
                        .fill(currentTheme.buttonBackground)
                        .opacity(pulseEffect ? 0.15 : 0)
                        .scaleEffect(pulseEffect ? 1.8 : 1)
                    
                    // Particle effects
                    ForEach(particleEffects) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .offset(particle.position)
                            .opacity(particle.opacity)
                            .rotationEffect(.degrees(particle.rotation))
                    }
                    
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
                    
                    if showingCelebration {
                        celebrationOverlay
                            .zIndex(2)
                    }
                }
                .onAppear {
                    withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            }
            .background(
                Group {
                    switch currentTheme.background {
                    case .solid(let color):
                        color
                    case .gradient(let colors):
                        LinearGradient(
                            colors: colors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    case .pattern(let imageName):
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .ignoresSafeArea()
            )
            .navigationTitle("Tasbihly")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDhikrSelector.toggle() }) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(currentTheme.primary)
                    }
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
        Button(action: {
            incrementCounter()
        }) {
            ZStack {
                // Progress Circle
                Circle()
                    .stroke(currentTheme.buttonBackground.opacity(0.3), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: min(CGFloat(counter) / CGFloat(selectedDhikr.count), 1.0))
                    .stroke(
                        counter >= selectedDhikr.count ? currentTheme.primary : currentTheme.buttonBackground,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.3), value: counter)

                // Main Circle
                Circle()
                    .fill(currentTheme.buttonBackground)
                    .padding(20)
                    .shadow(color: currentTheme.buttonBackground.opacity(0.3), radius: 10)
                    .scaleEffect(isAnimating ? 0.95 : 1.0)

                VStack(spacing: 12) {
                    Text("\(counter)")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 90 : 60, 
                                    weight: .bold, 
                                    design: .rounded))
                    
                    Text("\(counter)/\(selectedDhikr.count)")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, 
                                    weight: .medium,
                                    design: .rounded))
                        .opacity(0.9)
                }
                .foregroundColor(.white)
            }
            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200,
                   height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200)
        }
        .buttonStyle(CounterButtonStyle())
        .accessibilityLabel("Count")
        .accessibilityHint("Tap to increase count. Current count is \(counter) out of \(selectedDhikr.count)")
    }
    
    private func incrementCounter() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            counter += 1
            isAnimating = true
            pulseEffect = true
            
            // Play sound on every tap if enabled
            if isSoundEnabled { 
                playSound() 
            }
            
            if counter.isMultiple(of: 10) {
                addParticles()
            }
            
            if counter >= selectedDhikr.count {
                triggerHapticFeedback()
                addCelebrationParticles()
                
                // Show celebration
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showingCelebration = true
                }
                
                // Hide celebration after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showingCelebration = false
                    }
                }
            }
            
            UserDefaults.standard.set(counter, forKey: "counter")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
            withAnimation(.easeOut(duration: 0.3)) {
                pulseEffect = false
            }
        }
    }
    
    private func addParticles() {
        // Similar to watch app implementation
        for _ in 0..<10 {
            let particle = ParticleEffect()
            particleEffects.append(particle)
            
            withAnimation(.easeOut(duration: 1.0)) {
                particle.position = CGSize(
                    width: CGFloat.random(in: -150...150),
                    height: CGFloat.random(in: -150...150)
                )
                particle.opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                particleEffects.removeAll { $0.id == particle.id }
            }
        }
    }
    
    private func addCelebrationParticles() {
        let colors: [Color] = [
            currentTheme.primary,
            currentTheme.buttonBackground,
            currentTheme.textColor,
            .white
        ]
        
        for _ in 0..<30 {  // Increased particle count
            let particle = ParticleEffect()
            particle.color = colors.randomElement() ?? .white
            particleEffects.append(particle)
            
            withAnimation(.easeOut(duration: 2.0)) {  // Longer duration
                particle.position = CGSize(
                    width: CGFloat.random(in: -250...250),
                    height: CGFloat.random(in: -250...250)
                )
                particle.opacity = 0
                particle.rotation = Double.random(in: 0...360)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                particleEffects.removeAll { $0.id == particle.id }
            }
        }
    }
    
    private var resetButton: some View {
        Button(action: {
            counter = 0
            UserDefaults.standard.set(counter, forKey: "counter")
        }) {
            Text("Reset")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 35)
                .padding(.vertical, 15)
                .background(currentTheme.buttonBackground)
                .cornerRadius(25)
        }
        .accessibilityLabel("Reset Counter")
        .accessibilityHint("Tap to reset the count to zero")
    }
    
    private var celebrationOverlay: some View {
        VStack(spacing: 16) {
            Text("ما شاء الله")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(currentTheme.primary)
            
            Text("Well done!")
                .font(.title)
                .foregroundColor(currentTheme.textColor)
            
            Text("\(selectedDhikr.count) dhikrs completed")
                .font(.title3)
                .foregroundColor(currentTheme.secondary)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: currentTheme.buttonBackground.opacity(0.3), radius: 20)
        )
        .transition(.scale.combined(with: .opacity))
    }
    
    private func playSound() {
        audioPlayer?.play()
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// Add custom button style for better touch feedback
struct CounterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// Particle Effect Model (same as watch app)
class ParticleEffect: Identifiable {
    let id = UUID()
    var position: CGSize = .zero
    var opacity: Double = 0.8
    var size: CGFloat = CGFloat.random(in: 3...8)  // Slightly larger particles
    var color: Color = .white
    var rotation: Double = 0
}

struct TasbihView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
