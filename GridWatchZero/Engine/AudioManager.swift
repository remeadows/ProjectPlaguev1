// AudioManager.swift
// GridWatchZero
// Sound effects and audio management

import AVFoundation
import UIKit
import SwiftUI

// MARK: - Sound Types

enum SoundEffect: String, CaseIterable {
    case upgrade = "upgrade"
    case attackIncoming = "attack_incoming"
    case attackEnd = "attack_end"
    case malusMessage = "malus_message"
    case tick = "button_tap"  // Use button tap for tick
    case error = "error"
    case milestone = "milestone"
    case warning = "warning"

    /// File name for the sound effect (without extension)
    var fileName: String {
        return rawValue
    }
}

// MARK: - Audio Manager

final class AudioManager: @unchecked Sendable {
    static let shared = AudioManager()

    private var isSoundEnabled: Bool = true
    private var isHapticsEnabled: Bool = true
    private var soundVolume: Float = 0.7

    // Cache for preloaded audio players
    private var soundPlayers: [SoundEffect: AVAudioPlayer] = [:]

    // Pool of players for overlapping sounds
    private var activePlayers: [AVAudioPlayer] = []

    private init() {
        setupAudioSession()
        preloadSounds()
    }

    private func setupAudioSession() {
        do {
            // Use playback category to ensure sounds play even in silent mode
            // Mix with others allows background music to continue
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    /// Preload all sound effects for instant playback
    private func preloadSounds() {
        for sound in SoundEffect.allCases {
            if let url = Bundle.main.url(forResource: sound.fileName, withExtension: "m4a") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = soundVolume
                    soundPlayers[sound] = player
                } catch {
                    print("Failed to preload sound \(sound.fileName): \(error)")
                }
            } else {
                print("Sound file not found: \(sound.fileName).m4a")
            }
        }
        print("Preloaded \(soundPlayers.count) sound effects")
    }

    func playSound(_ sound: SoundEffect) {
        guard isSoundEnabled else { return }

        // Check if device volume is muted - respect user's volume settings
        guard AVAudioSession.sharedInstance().outputVolume > 0 else { return }

        // Play the sound using a fresh player instance for overlapping support
        if let url = Bundle.main.url(forResource: sound.fileName, withExtension: "m4a") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = soundVolume
                player.prepareToPlay()
                player.play()

                // Keep reference to prevent deallocation
                activePlayers.append(player)

                // Clean up finished players
                activePlayers.removeAll { !$0.isPlaying }
            } catch {
                print("Failed to play sound \(sound.fileName): \(error)")
            }
        }

        // Add haptic feedback for important events (if enabled)
        guard isHapticsEnabled else { return }
        Task { @MainActor in
            switch sound {
            case .attackIncoming, .warning:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            case .malusMessage:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            case .upgrade, .milestone:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            default:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }

    /// Play button tap sound - lightweight for frequent use
    func playButtonTap() {
        playSound(.tick)
    }

    /// Speak text with distorted "AI" voice for Malus
    func speakMalusMessage(_ text: String) {
        guard isSoundEnabled else { return }
        playSound(.malusMessage)
    }

    func toggleSound() {
        isSoundEnabled.toggle()
    }

    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
    }

    func setHapticsEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
    }

    func toggleHaptics() {
        isHapticsEnabled.toggle()
    }

    func setVolume(_ volume: Float) {
        soundVolume = max(0, min(1, volume))
        // Update preloaded players
        for player in soundPlayers.values {
            player.volume = soundVolume
        }
    }

    var isEnabled: Bool {
        isSoundEnabled
    }

    var hapticsEnabled: Bool {
        isHapticsEnabled
    }
}

// MARK: - Background Music Manager

/// Plays background music from audio file with looping
final class AmbientAudioManager: @unchecked Sendable {
    static let shared = AmbientAudioManager()

    private var audioPlayer: AVAudioPlayer?
    private var isPlaying: Bool = false
    private var volume: Float = 0.3  // Default volume for background music

    private init() {}

    func startAmbient() {
        guard !isPlaying else { return }

        // Check if device volume is muted - respect user's volume settings
        guard AVAudioSession.sharedInstance().outputVolume > 0 else {
            print("Device volume is muted, skipping music playback")
            return
        }

        do {
            // Use playback category with mixWithOthers to layer with sound effects
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Background music audio session setup failed: \(error)")
            return
        }

        // Load the background music file from bundle
        guard let musicURL = Bundle.main.url(forResource: "background_music", withExtension: "m4a") else {
            print("Background music file not found in bundle")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            audioPlayer?.numberOfLoops = -1  // Loop indefinitely
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            print("Background music started playing")
        } catch {
            print("Failed to create audio player: \(error)")
        }
    }

    func stopAmbient() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        print("Background music stopped")
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
        audioPlayer?.volume = volume
    }

    func toggleAmbient() {
        if isPlaying {
            stopAmbient()
        } else {
            startAmbient()
        }
    }

    var isAmbientPlaying: Bool {
        isPlaying
    }

    /// Pause music (for when app goes to background)
    func pause() {
        audioPlayer?.pause()
    }

    /// Resume music (for when app returns to foreground)
    func resume() {
        guard isPlaying else { return }
        // Check volume again in case user changed it while paused
        guard AVAudioSession.sharedInstance().outputVolume > 0 else { return }
        audioPlayer?.play()
    }
}

// MARK: - Haptic Manager

struct HapticManager {
    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard AudioManager.shared.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    @MainActor
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard AudioManager.shared.hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    @MainActor
    static func selection() {
        guard AudioManager.shared.hapticsEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
