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
        }
        .padding(.horizontal)
    }
    
    private var counterButton: some View {
        Button(action: {
            counter += 1
            UserDefaults.standard.set(counter, forKey: "counter")
            if isSoundEnabled { playSound() }
            if counter >= target && target > 0 {
                triggerHapticFeedback()
            }
        }) {
            ZStack {
                Circle()
                    .fill(counter >= target && target > 0 ? Color.green : currentTheme.buttonBackground)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200, 
                           height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200)
                    .shadow(color: currentTheme.buttonBackground.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack {
                    Text("\(counter)")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 90 : 60, 
                                    weight: .bold, 
                                    design: .rounded))
                        .foregroundColor(.white)
                    
                    if counter >= target && target > 0 {
                        Text("Target reached!")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16, 
                                        weight: .semibold, 
                                        design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            .scaleEffect(counter % 2 == 0 ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: counter)
        }
        .accessibilityLabel("Count")
        .accessibilityHint("Tap to increase count")
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
    
    private func playSound() {
        audioPlayer?.play()
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct TasbihView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
