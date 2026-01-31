// SettingsView.swift
// GridWatchZero
// Audio and game settings UI

import SwiftUI

struct SettingsView: View {
    @StateObject private var audioSettings = AudioSettingsManager.shared
    @EnvironmentObject var cloudManager: CloudSaveManager
    @EnvironmentObject var campaignState: CampaignState
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingCloudDiagnostics = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.terminalBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Audio Section
                        SettingsSection(title: "AUDIO", icon: "speaker.wave.3.fill") {
                            // Master Volume
                            VolumeSlider(
                                label: "Master Volume",
                                value: Binding(
                                    get: { audioSettings.settings.masterVolume },
                                    set: { audioSettings.setMasterVolume($0) }
                                ),
                                color: .neonGreen
                            )

                            Divider().background(Color.terminalGray.opacity(0.3))

                            // Music Toggle + Volume
                            SettingsToggleRow(
                                label: "Music",
                                icon: "music.note",
                                isOn: Binding(
                                    get: { audioSettings.settings.isMusicEnabled },
                                    set: { _ in audioSettings.toggleMusic() }
                                ),
                                color: .neonCyan
                            )

                            if audioSettings.settings.isMusicEnabled {
                                VolumeSlider(
                                    label: "Music Volume",
                                    value: Binding(
                                        get: { audioSettings.settings.musicVolume },
                                        set: { audioSettings.setMusicVolume($0) }
                                    ),
                                    color: .neonCyan,
                                    isIndented: true
                                )
                            }

                            Divider().background(Color.terminalGray.opacity(0.3))

                            // SFX Toggle + Volume
                            SettingsToggleRow(
                                label: "Sound Effects",
                                icon: "speaker.wave.2.fill",
                                isOn: Binding(
                                    get: { audioSettings.settings.isSFXEnabled },
                                    set: { _ in audioSettings.toggleSFX() }
                                ),
                                color: .neonAmber
                            )

                            if audioSettings.settings.isSFXEnabled {
                                VolumeSlider(
                                    label: "SFX Volume",
                                    value: Binding(
                                        get: { audioSettings.settings.sfxVolume },
                                        set: { audioSettings.setSFXVolume($0) }
                                    ),
                                    color: .neonAmber,
                                    isIndented: true
                                )
                            }
                        }

                        // Haptics Section
                        SettingsSection(title: "FEEDBACK", icon: "hand.tap.fill") {
                            SettingsToggleRow(
                                label: "Haptic Feedback",
                                icon: "iphone.radiowaves.left.and.right",
                                isOn: Binding(
                                    get: { audioSettings.settings.isHapticsEnabled },
                                    set: { _ in audioSettings.toggleHaptics() }
                                ),
                                color: .neonGreen
                            )

                            Text("Vibrate on button taps, upgrades, and alerts")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 4)
                        }

                        // Reset Section
                        SettingsSection(title: "RESET", icon: "arrow.counterclockwise") {
                            Button(action: {
                                audioSettings.resetToDefaults()
                                HapticManager.notification(.success)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(.neonAmber)
                                    Text("Reset Audio Settings")
                                        .font(.terminalBody)
                                        .foregroundColor(.neonAmber)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        // iCloud Section
                        SettingsSection(title: "ICLOUD SYNC", icon: "icloud.fill") {
                            // Sync Status Row
                            HStack(spacing: 12) {
                                Image(systemName: cloudStatusIcon)
                                    .font(.system(size: 16))
                                    .foregroundColor(cloudStatusColor)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Sync Status")
                                        .font(.terminalBody)
                                        .foregroundColor(.white)
                                    Text(cloudManager.status.displayText)
                                        .font(.terminalMicro)
                                        .foregroundColor(.terminalGray)
                                }
                                
                                Spacer()
                            }
                            
                            Divider().background(Color.terminalGray.opacity(0.3))
                            
                            // Diagnostics Button
                            Button(action: {
                                showingCloudDiagnostics = true
                            }) {
                                HStack {
                                    Image(systemName: "stethoscope")
                                        .foregroundColor(.neonCyan)
                                    Text("iCloud Diagnostics")
                                        .font(.terminalBody)
                                        .foregroundColor(.neonCyan)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.terminalGray)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            Text("Troubleshoot iCloud sync issues")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 4)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.terminalBody)
                    .foregroundColor(.neonGreen)
                }
            }
            .toolbarBackground(Color.terminalDarkGray, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingCloudDiagnostics) {
                CloudDiagnosticView()
                    .environmentObject(cloudManager)
                    .environmentObject(campaignState)
            }
        }
    }
    
    // MARK: - Cloud Status Helpers
    
    private var cloudStatusIcon: String {
        switch cloudManager.status {
        case .available, .synced:
            return "checkmark.icloud.fill"
        case .syncing:
            return "arrow.triangle.2.circlepath.icloud.fill"
        case .unavailable, .error:
            return "xmark.icloud.fill"
        case .conflict:
            return "exclamationmark.icloud.fill"
        }
    }
    
    private var cloudStatusColor: Color {
        switch cloudManager.status {
        case .available, .synced:
            return .neonGreen
        case .syncing:
            return .neonCyan
        case .unavailable, .error:
            return .neonRed
        case .conflict:
            return .neonAmber
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.neonGreen)
                Text(title)
                    .font(.terminalSmall)
                    .foregroundColor(.neonGreen)
                    .tracking(2)
            }

            // Section content
            VStack(spacing: 12) {
                content
            }
            .padding(16)
            .background(Color.terminalDarkGray)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.terminalGray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isOn ? color : .terminalGray)
                .frame(width: 24)

            Text(label)
                .font(.terminalBody)
                .foregroundColor(isOn ? .white : .terminalGray)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isOn.toggle()
            HapticManager.selection()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(isOn ? "enabled" : "disabled")")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Volume Slider

struct VolumeSlider: View {
    let label: String
    @Binding var value: Float
    let color: Color
    var isIndented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.terminalMicro)
                    .foregroundColor(color)
                    .monospacedDigit()
            }

            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.terminalGray)

                Slider(value: Binding(
                    get: { Double(value) },
                    set: { value = Float($0) }
                ), in: 0...1)
                .tint(color)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.terminalGray)
            }
        }
        .padding(.leading, isIndented ? 36 : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(Int(value * 100)) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                value = min(1, value + 0.1)
            case .decrement:
                value = max(0, value - 0.1)
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
