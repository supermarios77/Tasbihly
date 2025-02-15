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
                    // Progress Circle
                    Circle()
                        .stroke(Color.green.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: min(CGFloat(counter) / CGFloat(selectedDhikr.count), 1.0))
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.8),
                                    Color.green
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.3), value: counter)
                    
                    // Main Circle Background
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
                        .padding(15) // Padding inside progress ring
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
                                .padding(15)
                        )
                        .scaleEffect(isAnimating ? 0.92 : 1)
                    
                    // Counter and Dhikr Display
                    VStack(spacing: 4) {
                        Text("\(counter)")
                            .font(.system(size: 68, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.5)
                            .opacity(isAnimating ? 0.8 : 1)
                            .scaleEffect(isAnimating ? 0.95 : 1)
                        
                        Text("\(counter)/\(selectedDhikr.count)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(selectedDhikr.transliteration)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                            .opacity(0.9)
                            .padding(.top, 2)
                    }
                    .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Enhanced Floating Controls
            VStack {
                Spacer()
                HStack {
                    FloatingButton(
                        icon: "arrow.counterclockwise",
                        action: { showingResetConfirmation = true }
                    )
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                    
                    Spacer()
                    
                    FloatingButton(
                        icon: "text.justify",
                        action: { showingSettings.toggle() }
                    )
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
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
            
            // Enhanced haptic feedback
            if counter >= selectedDhikr.count {
                WKInterfaceDevice.current().play(.success)
                addCelebrationParticles()
                // Optional: Auto reset after reaching target
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        counter = 0
                    }
                }
            } else if counter % 10 == 0 {
                WKInterfaceDevice.current().play(.notification)
                addParticles()
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

// Enhanced FloatingButton
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
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
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
