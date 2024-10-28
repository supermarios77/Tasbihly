import AVFoundation
import Foundation

/// Manages audio playback for the app
final class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private let soundFileName = "tap"
    private let soundFileExtension = "mp3"
    
    private init() {
        configureAudioSession()
        loadSound()
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sound Loading
    
    private func loadSound() {
        guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: soundFileExtension) else {
            print("Sound file not found: \(soundFileName).\(soundFileExtension)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
            audioPlayer = nil
        }
    }
    
    // MARK: - Playback
    
    /// Play the tap sound if available
    func playTapSound() {
        guard let player = audioPlayer else {
            // Try to reload if player is nil
            loadSound()
            return
        }
        
        // Reset to beginning if already playing
        if player.isPlaying {
            player.currentTime = 0
        }
        
        player.play()
    }
    
    /// Stop any currently playing sound
    func stopSound() {
        audioPlayer?.stop()
    }
    
    deinit {
        // Cleanup resources (though singleton won't deallocate, this is good practice)
        audioPlayer?.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}

