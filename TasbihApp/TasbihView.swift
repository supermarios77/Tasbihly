import SwiftUI
import AVFoundation

struct TasbihView: View {
    @State private var selectedDhikr = dhikrList[0]
    @State private var counter = UserDefaults.standard.integer(forKey: "counter")
    @Binding var isSoundEnabled: Bool
    @Binding var target: Int
    @State private var showDhikrSelector = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var audioPlayer: AVAudioPlayer?
    
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
            VStack(spacing: 40) {
                dhikrSection
                counterButton
                resetButton
            }
            .padding()
            .navigationTitle("Tasbihly")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDhikrSelector.toggle() }) {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showDhikrSelector) {
            DhikrSelectorView(dhikrList: dhikrList, selectedDhikr: $selectedDhikr)
        }
    }
    
    private var dhikrSection: some View {
        VStack(spacing: 10) {
            Text(selectedDhikr.phrase)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(selectedDhikr.transliteration)
                .font(.system(size: 24, design: .rounded))
                .foregroundColor(.secondary)
                .italic()
            
            Text(selectedDhikr.translation)
                .font(.system(size: 20, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var counterButton: some View {
        Button(action: {
            counter += 1
            UserDefaults.standard.set(counter, forKey: "counter")
            if isSoundEnabled { playSound() }
        }) {
            ZStack {
                Circle()
                    .fill(counter >= target && target > 0 ? Color.green : Color.accentColor)
                    .frame(width: 200, height: 200)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack {
                    Text("\(counter)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if counter >= target && target > 0 {
                        Text("Target reached!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
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
                .background(Color.accentColor)
                .cornerRadius(25)
        }
        .accessibilityLabel("Reset Counter")
        .accessibilityHint("Tap to reset the count to zero")
    }
    
    private func playSound() {
        audioPlayer?.play()
    }
}

struct TasbihView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
