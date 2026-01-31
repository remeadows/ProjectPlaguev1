// StatsHeaderView.swift
// GridWatchZero
// Top header showing credits and key stats

import SwiftUI

struct StatsHeaderView: View {
    let credits: Double
    let tickStats: TickStats
    let currentTick: Int
    let isRunning: Bool
    let unreadLore: Int
    let onToggle: () -> Void
    let onReset: () -> Void
    let onShop: () -> Void
    let onLore: () -> Void
    let onMilestones: () -> Void
    let onSettings: () -> Void

    // Campaign mode info (optional)
    var campaignLevelId: Int? = nil
    var campaignLevelName: String? = nil
    var isInsaneMode: Bool = false
    var onPauseCampaign: (() -> Void)? = nil

    @State private var showResetConfirm = false
    @StateObject private var audioSettings = AudioSettingsManager.shared

    var body: some View {
        VStack(spacing: 8) {
            // Title bar
            HStack(spacing: 8) {
                // Show campaign level info or game title
                if let levelId = campaignLevelId, let levelName = campaignLevelName {
                    // Campaign mode header
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text("LEVEL \(levelId)")
                                .font(.terminalMicro)
                                .foregroundColor(.neonCyan)

                            if isInsaneMode {
                                Text("INSANE")
                                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                                    .foregroundColor(.terminalBlack)
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 1)
                                    .background(Color.neonRed)
                                    .cornerRadius(2)
                            }
                        }
                        Text(levelName)
                            .font(.terminalSmall)
                            .foregroundColor(.white)
                    }
                    .accessibilityAddTraits(.isHeader)
                } else {
                    // Normal mode - show game title
                    Text("GRID WATCH ZERO")
                        .font(.terminalTitle)
                        .foregroundColor(.neonGreen)
                        .glow(.neonGreen, radius: 4)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .accessibilityAddTraits(.isHeader)
                }

                Spacer()

                // Controls - compact buttons
                HStack(spacing: 4) {
                    // Intel/Lore button
                    Button(action: onLore) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.neonCyan)
                                .frame(width: 30, height: 30)
                                .background(Color.terminalDarkGray)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                                )

                            // Unread badge
                            if unreadLore > 0 {
                                Circle()
                                    .fill(Color.neonAmber)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Text("\(min(unreadLore, 9))")
                                            .font(.system(size: 7, weight: .bold))
                                            .foregroundColor(.terminalBlack)
                                    )
                                    .offset(x: 3, y: -3)
                            }
                        }
                    }
                    .accessibilityLabel("Intel")
                    .accessibilityValue(unreadLore > 0 ? "\(unreadLore) unread" : "No unread")
                    .accessibilityHint("Opens intel and lore viewer")

                    // Milestones button
                    Button(action: onMilestones) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.neonAmber)
                            .frame(width: 30, height: 30)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Milestones")
                    .accessibilityHint("Opens achievements and milestones")

                    // Shop button
                    Button(action: onShop) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.neonAmber)
                            .frame(width: 30, height: 30)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Shop")
                    .accessibilityHint("Opens unit shop to buy upgrades")

                    // Settings button
                    Button(action: onSettings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.neonCyan)
                            .frame(width: 30, height: 30)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Opens audio and game settings")

                    Button(action: onToggle) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neonGreen)
                            .frame(width: 32, height: 30)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel(isRunning ? "Pause game" : "Resume game")
                    .accessibilityHint(isRunning ? "Pauses the game tick loop" : "Resumes the game tick loop")

                    // Show campaign exit or reset button
                    if let pauseAction = onPauseCampaign {
                        // Campaign mode - show exit/pause button
                        Button(action: pauseAction) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 12))
                                .foregroundColor(.neonRed)
                                .frame(width: 30, height: 30)
                                .background(Color.terminalDarkGray)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.neonRed.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .accessibilityLabel("Exit mission")
                        .accessibilityHint("Save and exit current mission")
                    } else {
                        // Endless mode - show reset button
                        Button(action: { showResetConfirm = true }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12))
                                .foregroundColor(.neonRed)
                                .frame(width: 30, height: 30)
                                .background(Color.terminalDarkGray)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.neonRed.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .accessibilityLabel("Reset game")
                        .accessibilityHint("Erases all progress and starts fresh")
                    }
                }
            }

            // Credits display - compact single row
            HStack(spacing: 12) {
                // Credits
                HStack(spacing: 4) {
                    Text("¢")
                        .font(.terminalBody)
                        .foregroundColor(.neonAmber)
                    Text(credits.formatted)
                        .font(.terminalTitle)
                        .foregroundColor(.neonAmber)
                        .glow(.neonAmber, radius: 3)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(credits.formatted) credits")

                Spacer()

                // Live stats - inline
                HStack(spacing: 10) {
                    MiniStatPill(label: "GEN", value: tickStats.dataGenerated.formatted, color: .neonGreen)
                    MiniStatPill(label: "TX", value: tickStats.dataTransferred.formatted, color: .neonCyan)
                    MiniStatPill(label: "DROP", value: tickStats.dataDropped.formatted, color: tickStats.dataDropped > 0 ? .neonRed : .terminalGray)
                    MiniStatPill(label: "EARN", value: "¢\(tickStats.creditsEarned.formatted)", color: .neonAmber)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Per tick: Generated \(tickStats.dataGenerated.formatted), transferred \(tickStats.dataTransferred.formatted), dropped \(tickStats.dataDropped.formatted), earned \(tickStats.creditsEarned.formatted) credits")

                // Tick counter
                HStack(spacing: 4) {
                    Circle()
                        .fill(isRunning ? Color.neonGreen : Color.neonRed)
                        .frame(width: 6, height: 6)
                        .glow(isRunning ? .neonGreen : .neonRed, radius: 2)

                    Text("\(currentTick)")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tick \(currentTick), \(isRunning ? "running" : "paused")")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.terminalDarkGray)
        .alert("Reset Game?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive, action: onReset)
        } message: {
            Text("This will erase all progress and start fresh.")
        }
    }
}

struct MiniStatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.terminalGray)
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Text(value)
                    .font(.terminalSmall)
                    .foregroundColor(color)
            }
        }
    }
}

#Preview {
    StatsHeaderView(
        credits: 1234.5,
        tickStats: TickStats(
            dataGenerated: 12,
            dataTransferred: 7,
            dataDropped: 5,
            creditsEarned: 10.5
        ),
        currentTick: 42,
        isRunning: true,
        unreadLore: 3,
        onToggle: {},
        onReset: {},
        onShop: {},
        onLore: {},
        onMilestones: {},
        onSettings: {}
    )
    .background(Color.terminalBlack)
}
