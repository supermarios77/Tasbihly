import SwiftUI
import WatchKit

struct ContentView: View {
    @AppStorage("counter") private var counter: Int = 0
    @State private var selectedDhikr = dhikrList[0]
    @State private var showingSettings = false
    @State private var isAnimating = false
    @State private var showingResetConfirmation = false
    @State private var rotationAngle: Double = 0
    @State private var showingMilestone = false
    @State private var pulseEffect = false
    @State private var particleEffects: [ParticleEffect] = []
    
    private let milestones = [33, 99, 100, 500, 1000]
    
    var body: some View {
        ZStack {
            // Animated Background
            ZStack {
                // Rotating gradient
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.green.opacity(0.4),
                                Color.green.opacity(0.1),
                                Color.green.opacity(0.4)
                            ]),
                            center: .center,
                            startAngle: .degrees(rotationAngle),
                            endAngle: .degrees(rotationAngle + 360)
                        )
                    )
                    .blur(radius: 15)
                
                // Pulse effect
                Circle()
                    .fill(Color.green)
                    .opacity(pulseEffect ? 0.15 : 0)
                    .scaleEffect(pulseEffect ? 1.8 : 1)
                
                // Particle effects
                ForEach(particleEffects) { particle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: particle.size, height: particle.size)
                        .offset(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
            
            // Main Counter Button
            Button(action: {
                incrementCounter()
            }) {
                ZStack {
                    // Main Circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.95),
                                    Color.green
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(4)
                        .scaleEffect(isAnimating ? 0.92 : 1)
                    
                    // Counter and Dhikr
                    VStack(spacing: 6) {
                        // Total count
                        Text("\(counter)")
                            .font(.system(size: 76, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.5)
                            .opacity(isAnimating ? 0.8 : 1)
                            .scaleEffect(isAnimating ? 0.95 : 1)
                        
                        // Current set progress
                        Text("\(counter % selectedDhikr.count)/\(selectedDhikr.count)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Set counter
                        Text("Set \((counter / selectedDhikr.count) + 1)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(selectedDhikr.transliteration)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                            .opacity(0.9)
                    }
                    .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Bottom Controls with Floating Effect
            VStack {
                Spacer()
                HStack {
                    FloatingButton(
                        icon: "arrow.counterclockwise",
                        action: { showingResetConfirmation = true }
                    )
                    
                    Spacer()
                    
                    FloatingButton(
                        icon: "text.justify",
                        action: { showingSettings.toggle() }
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                WatchSettingsView(selectedDhikr: $selectedDhikr)
            }
        }
        .alert("Reset Counter?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    counter = 0
                    WKInterfaceDevice.current().play(.click)
                }
            }
        }
        .alert("Milestone!", isPresented: $showingMilestone) {
            Button("Continue", role: .cancel) { }
        } message: {
            Text("You've reached \(counter) dhikrs!")
        }
    }
    
    private func incrementCounter() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            counter += 1
            isAnimating = true
            pulseEffect = true
            
            // Add particle effects
            if counter.isMultiple(of: 10) {
                addParticles()
            }
            
            // Play different haptics for target completion
            if counter >= selectedDhikr.count {
                WKInterfaceDevice.current().play(.success)
                addCelebrationParticles()
            } else {
                WKInterfaceDevice.current().play(.click)
            }
        }
        
        // Reset animation states
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
            withAnimation(.easeOut(duration: 0.3)) {
                pulseEffect = false
            }
        }
    }
    
    private func addParticles() {
        for _ in 0..<5 {
            let particle = ParticleEffect()
            particleEffects.append(particle)
            
            // Animate particle
            withAnimation(.easeOut(duration: 0.5)) {
                particle.position = CGSize(
                    width: CGFloat.random(in: -100...100),
                    height: CGFloat.random(in: -100...100)
                )
                particle.opacity = 0
            }
            
            // Remove particle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                particleEffects.removeAll { $0.id == particle.id }
            }
        }
    }
    
    private func addCelebrationParticles() {
        for _ in 0..<15 {
            let particle = ParticleEffect()
            particleEffects.append(particle)
            
            // Animate celebration particle
            withAnimation(.easeOut(duration: 1.0)) {
                particle.position = CGSize(
                    width: CGFloat.random(in: -150...150),
                    height: CGFloat.random(in: -150...150)
                )
                particle.opacity = 0
            }
            
            // Remove particle
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                particleEffects.removeAll { $0.id == particle.id }
            }
        }
    }
}

// Particle Effect Model
class ParticleEffect: Identifiable {
    let id = UUID()
    var position: CGSize = .zero
    var opacity: Double = 0.8
    var size: CGFloat = CGFloat.random(in: 2...4)
}

// Floating Button Component
struct FloatingButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.9 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
