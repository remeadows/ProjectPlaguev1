// AudioSettings.swift
// GridWatchZero
// Persistent audio settings with separate controls for music, SFX, and haptics

import Foundation
import Combine

// MARK: - Audio Settings Model

/// Persistent audio settings with separate volume controls
struct AudioSettings: Codable, Equatable {
    var isMusicEnabled: Bool = true
    var isSFXEnabled: Bool = true
    var isHapticsEnabled: Bool = true

    var musicVolume: Float = 0.3      // 0.0 to 1.0
    var sfxVolume: Float = 0.7        // 0.0 to 1.0
    var masterVolume: Float = 1.0     // 0.0 to 1.0

    /// Effective music volume (master × music)
    var effectiveMusicVolume: Float {
        masterVolume * musicVolume
    }

    /// Effective SFX volume (master × sfx)
    var effectiveSFXVolume: Float {
        masterVolume * sfxVolume
    }
}

// MARK: - Audio Settings Manager

/// Manages audio settings with persistence and real-time updates
@MainActor
final class AudioSettingsManager: ObservableObject {
    static let shared = AudioSettingsManager()

    private static let saveKey = "GridWatchZero.AudioSettings.v1"

    @Published var settings: AudioSettings {
        didSet {
            saveAndApply()
        }
    }

    private init() {
        // Load saved settings or use defaults
        if let data = UserDefaults.standard.data(forKey: Self.saveKey),
           let decoded = try? JSONDecoder().decode(AudioSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = AudioSettings()
        }

        // Apply settings on init
        applySettingsToManagers()
    }

    /// Save and apply settings
    private func saveAndApply() {
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }

        // Apply to audio managers
        applySettingsToManagers()
    }

    /// Apply current settings to audio managers
    private func applySettingsToManagers() {
        // Update SFX manager
        AudioManager.shared.setSoundEnabled(settings.isSFXEnabled)
        AudioManager.shared.setVolume(settings.effectiveSFXVolume)
        AudioManager.shared.setHapticsEnabled(settings.isHapticsEnabled)

        // Update music manager
        AmbientAudioManager.shared.setVolume(settings.effectiveMusicVolume)
        if settings.isMusicEnabled {
            if !AmbientAudioManager.shared.isAmbientPlaying {
                AmbientAudioManager.shared.startAmbient()
            }
        } else {
            AmbientAudioManager.shared.stopAmbient()
        }
    }

    // MARK: - Convenience Methods

    func toggleMusic() {
        settings.isMusicEnabled.toggle()
    }

    func toggleSFX() {
        settings.isSFXEnabled.toggle()
    }

    func toggleHaptics() {
        settings.isHapticsEnabled.toggle()
    }

    func setMusicVolume(_ volume: Float) {
        settings.musicVolume = max(0, min(1, volume))
    }

    func setSFXVolume(_ volume: Float) {
        settings.sfxVolume = max(0, min(1, volume))
    }

    func setMasterVolume(_ volume: Float) {
        settings.masterVolume = max(0, min(1, volume))
    }

    /// Reset to default settings
    func resetToDefaults() {
        settings = AudioSettings()
    }
}
