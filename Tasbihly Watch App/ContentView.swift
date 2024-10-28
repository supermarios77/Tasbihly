import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var dataManager = WatchDataManager.shared
    @State private var showingSettings = false
    @State private var showingResetConfirmation = false
    @State private var isAnimating = false
    @State private var rotationDegrees = -90.0
    
    // Digital Crown Support
    @State private var crownValue = 0.0
    @State private var crownAccumulator = 0.0
    
    private var progressValue: Double {
        Double(dataManager.counter % dataManager.target) / Double(dataManager.target)
    }
    
    private var counterGradient: LinearGradient {
        LinearGradient(
            colors: [.white, .white.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Main Counter Interface
            VStack(spacing: 16) {
                // Reset Button
                HStack {
                    Button(action: {
                        withAnimation {
                            showingResetConfirmation = true
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.05))
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Counter Display
                ZStack {
                    // Outer Glow
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .blur(radius: 15)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    // Progress Ring Background
                    Circle()
                        .stroke(
                            Color.white.opacity(0.1),
                            lineWidth: 6
                        )
                    
                    // Progress Ring
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(
                                lineWidth: 6,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(rotationDegrees))
                    
                    // Progress Ring Cap
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .offset(y: -62)
                        .rotationEffect(.degrees(360 * progressValue + -90))
                        .opacity(progressValue > 0 ? 1 : 0)
                    
                    // Counter Background
                    Circle()
                        .fill(Color.black)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                        .padding(12)
                    
                    // Counter Value
                    VStack(spacing: 6) {
                        Text("\(dataManager.counter)")
                            .font(.system(size: 44, weight: .medium, design: .rounded))
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(counterGradient)
                            .scaleEffect(isAnimating ? 0.9 : 1)
                        
                        VStack(spacing: 3) {
                            Text(dataManager.currentDhikr.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                            
                            Text("\(dataManager.counter % dataManager.target)/\(dataManager.target)")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: 110)
                }
                .frame(width: 150, height: 150)
                .scaleEffect(isAnimating ? 0.97 : 1)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isAnimating)
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.05))
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
        }
        .focusable(true)
        .digitalCrownRotation(
            $crownValue,
            from: 0.0,
            through: 360.0,
            by: 1.0,
            sensitivity: .high,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { newValue in
            let delta = newValue - crownAccumulator
            if abs(delta) >= 20.0 {
                withAnimation(.spring(response: 0.2)) {
                    if delta > 0 {
                        incrementCounter()
                    } else {
                        dataManager.undoLastCount()
                    }
                }
                crownAccumulator = newValue
            }
        }
        .gesture(
            TapGesture()
                .onEnded { _ in
                    incrementCounter()
                }
        )
        .sheet(isPresented: $showingSettings) {
            WatchSettingsView()
        }
        .alert("Reset Counter?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation(.spring(response: 0.3)) {
                    rotationDegrees -= 360
                    dataManager.resetCounter()
                    
                    // Reset rotation after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.none) {
                            rotationDegrees = -90
                        }
                    }
                }
            }
        }
    }
    
    private func incrementCounter() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            isAnimating = true
            dataManager.incrementCounter()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
