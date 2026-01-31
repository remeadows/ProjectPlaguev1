// EngagementView.swift
// GridWatchZero
// UI components for daily rewards, streaks, achievements, and collections

import SwiftUI

// MARK: - Daily Reward Popup

struct DailyRewardPopupView: View {
    @ObservedObject var engagementManager: EngagementManager
    let onClaim: (Double) -> Void

    @State private var showingReward = false
    @State private var claimedReward: (credits: Double, multiplier: Double, specialReward: SpecialDailyReward?)?

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { }  // Block background taps

            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.neonGreen)
                        .glow(.neonGreen, radius: 12)

                    Text("DAILY REWARD")
                        .font(.terminalLarge)
                        .foregroundColor(.neonGreen)
                        .glow(.neonGreen, radius: 8)

                    if engagementManager.currentStreak > 1 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.neonAmber)
                            Text("\(engagementManager.currentStreak) Day Streak!")
                                .foregroundColor(.neonAmber)
                        }
                        .font(.terminalSmall)
                    }
                }

                // Reward display
                if showingReward, let reward = claimedReward {
                    VStack(spacing: 16) {
                        // Credits
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.neonGreen)
                            Text("+₵\(reward.credits.formatted)")
                                .font(.terminalTitle)
                                .foregroundColor(.white)
                        }

                        // Multiplier bonus
                        if reward.multiplier > 1.0 {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.neonAmber)
                                Text("\(reward.multiplier, specifier: "%.1f")x Production Boost Active")
                                    .font(.terminalSmall)
                                    .foregroundColor(.neonAmber)
                            }
                        }

                        // Special reward
                        if let special = reward.specialReward {
                            HStack {
                                Image(systemName: special.icon)
                                    .foregroundColor(.neonCyan)
                                Text(special.description)
                                    .font(.terminalSmall)
                                    .foregroundColor(.neonCyan)
                            }
                        }
                    }
                    .padding()
                    .background(Color.terminalDarkGray)
                    .cornerRadius(8)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Pre-claim display
                    weeklyProgressView
                }

                // Action button
                Button(action: {
                    if showingReward {
                        engagementManager.dismissDailyRewardPopup()
                    } else {
                        claimReward()
                    }
                }) {
                    Text(showingReward ? "CONTINUE" : "CLAIM REWARD")
                        .font(.terminalTitle)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.neonGreen)
                        .cornerRadius(4)
                }
            }
            .padding(32)
            .background(Color.terminalDarkGray.opacity(0.95))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neonGreen.opacity(0.6), lineWidth: 2)
            )
            .shadow(color: .neonGreen.opacity(0.3), radius: 20)
            .padding(24)
        }
    }

    private var weeklyProgressView: some View {
        VStack(spacing: 12) {
            Text("Weekly Progress")
                .font(.terminalSmall)
                .foregroundColor(.terminalGray)

            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    let currentDay = engagementManager.state.loginStreak.currentWeekDay
                    let isCompleted = day < currentDay
                    let isCurrent = day == currentDay

                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(isCompleted ? Color.neonGreen : Color.terminalDarkGray)
                                .frame(width: 32, height: 32)

                            if isCurrent {
                                Circle()
                                    .stroke(Color.neonGreen, lineWidth: 2)
                                    .frame(width: 32, height: 32)
                                    .glow(.neonGreen, radius: 4)
                            }

                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.terminalBlack)
                            } else {
                                Text("\(day)")
                                    .font(.terminalMicro)
                                    .foregroundColor(isCurrent ? .neonGreen : .terminalGray)
                            }
                        }

                        // Day 7 special indicator
                        if day == 7 {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.neonAmber)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.terminalBlack.opacity(0.5))
        .cornerRadius(8)
    }

    private func claimReward() {
        if let result = engagementManager.claimDailyReward() {
            claimedReward = result
            withAnimation(.spring()) {
                showingReward = true
            }
            onClaim(result.credits)
            AudioManager.shared.playSound(.milestone)
        }
    }
}

// MARK: - Streak Badge View

struct StreakBadgeView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12))
                .foregroundColor(streakColor)

            Text("\(streak)")
                .font(.terminalSmall)
                .foregroundColor(streakColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(streakColor.opacity(0.2))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(streakColor.opacity(0.5), lineWidth: 1)
        )
    }

    private var streakColor: Color {
        switch streak {
        case 0...6: return .terminalGray
        case 7...13: return .neonGreen
        case 14...20: return .neonAmber
        case 21...27: return .neonCyan
        default: return .neonRed
        }
    }
}

// MARK: - Bonus Multiplier Indicator

struct BonusMultiplierView: View {
    @ObservedObject var engagementManager: EngagementManager

    var body: some View {
        if engagementManager.activeMultiplier > 1.0 {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.neonAmber)

                Text("\(engagementManager.activeMultiplier, specifier: "%.1f")x")
                    .font(.terminalMicro)
                    .foregroundColor(.neonAmber)

                Text("(\(formatTime(engagementManager.bonusTimeRemaining)))")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.neonAmber.opacity(0.15))
            .cornerRadius(2)
        }
    }

    private func formatTime(_ ticks: Int) -> String {
        let minutes = ticks / 60
        let seconds = ticks % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Weekly Challenge Card

struct WeeklyChallengeCardView: View {
    let challenge: WeeklyChallenge
    let onClaim: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: challenge.challengeType.icon)
                    .foregroundColor(.neonCyan)

                Text(challenge.title)
                    .font(.terminalSmall)
                    .foregroundColor(.white)

                Spacer()

                if challenge.isComplete {
                    Button(action: onClaim) {
                        Text("CLAIM")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalBlack)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.neonGreen)
                            .cornerRadius(2)
                    }
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.terminalDarkGray)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(challenge.isComplete ? Color.neonGreen : Color.neonCyan)
                        .frame(width: geo.size.width * challenge.progressPercentage)
                }
            }
            .frame(height: 4)

            HStack {
                Text(challenge.description)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Spacer()

                Text("\(Int(challenge.currentProgress))/\(Int(challenge.targetValue))")
                    .font(.terminalMicro)
                    .foregroundColor(challenge.isComplete ? .neonGreen : .terminalGray)
            }
        }
        .padding(12)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(challenge.isComplete ? Color.neonGreen.opacity(0.5) : Color.terminalGray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Achievement Unlock Popup

struct AchievementUnlockPopupView: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 16) {
                // Rarity indicator
                Text(achievement.rarity.displayName.uppercased())
                    .font(.terminalMicro)
                    .foregroundColor(rarityColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(rarityColor.opacity(0.2))
                    .cornerRadius(2)

                // Icon
                Image(systemName: achievement.category.icon)
                    .font(.system(size: 40))
                    .foregroundColor(rarityColor)
                    .glow(rarityColor, radius: 12)

                // Title
                Text("ACHIEVEMENT UNLOCKED")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Text(achievement.title)
                    .font(.terminalLarge)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(achievement.description)
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
                    .multilineTextAlignment(.center)

                // Rewards
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.neonGreen)
                        Text("+₵\(achievement.rewardCredits.formatted)")
                            .foregroundColor(.neonGreen)
                    }
                    .font(.terminalSmall)

                    if achievement.rewardDataChips > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "memorychip.fill")
                                .foregroundColor(.neonCyan)
                            Text("+\(achievement.rewardDataChips)")
                                .foregroundColor(.neonCyan)
                        }
                        .font(.terminalSmall)
                    }
                }

                Button(action: onDismiss) {
                    Text("AWESOME")
                        .font(.terminalTitle)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(rarityColor)
                        .cornerRadius(4)
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color.terminalDarkGray)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(rarityColor.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: rarityColor.opacity(0.3), radius: 20)
            .padding(24)
        }
    }

    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return .terminalGray
        case .uncommon: return .neonGreen
        case .rare: return .neonCyan
        case .epic: return Color(red: 0.7, green: 0.3, blue: 1.0)  // Purple
        case .legendary: return .neonAmber
        }
    }
}

// MARK: - Data Chip Unlock Popup

struct DataChipUnlockPopupView: View {
    let chip: DataChip
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 16) {
                // Rarity
                Text(chip.rarity.displayName.uppercased())
                    .font(.terminalMicro)
                    .foregroundColor(rarityColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(rarityColor.opacity(0.2))
                    .cornerRadius(2)

                // Chip icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.terminalBlack)
                        .frame(width: 80, height: 80)

                    Image(systemName: chip.category.icon)
                        .font(.system(size: 32))
                        .foregroundColor(rarityColor)
                        .glow(rarityColor, radius: 8)
                }

                Text("DATA CHIP FOUND")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Text(chip.name)
                    .font(.terminalLarge)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(chip.description)
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
                    .multilineTextAlignment(.center)

                // Flavor text
                Text("\"\(chip.flavorText)\"")
                    .font(.terminalMicro)
                    .foregroundColor(rarityColor.opacity(0.8))
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Button(action: onDismiss) {
                    Text("COLLECT")
                        .font(.terminalTitle)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(rarityColor)
                        .cornerRadius(4)
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color.terminalDarkGray)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(rarityColor.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: rarityColor.opacity(0.3), radius: 20)
            .padding(24)
        }
    }

    private var rarityColor: Color {
        switch chip.rarity {
        case .common: return .terminalGray
        case .uncommon: return .neonGreen
        case .rare: return .neonCyan
        case .legendary: return .neonAmber
        }
    }
}

// MARK: - Engagement Stats Summary

struct EngagementStatsSummaryView: View {
    @ObservedObject var engagementManager: EngagementManager
    @ObservedObject var achievementManager: AchievementManager
    @ObservedObject var collectionManager: CollectionManager

    var body: some View {
        HStack(spacing: 12) {
            // Streak
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonAmber)
                    Text("\(engagementManager.currentStreak)")
                        .font(.terminalSmall)
                        .foregroundColor(.neonAmber)
                }
                Text("Streak")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Divider()
                .frame(height: 24)
                .background(Color.terminalGray.opacity(0.3))

            // Achievements
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonGreen)
                    Text("\(achievementManager.unlockedCount)/\(achievementManager.totalAchievements)")
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen)
                }
                Text("Achievements")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Divider()
                .frame(height: 24)
                .background(Color.terminalGray.opacity(0.3))

            // Collection
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "memorychip.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonCyan)
                    Text("\(collectionManager.ownedCount)/\(collectionManager.totalChips)")
                        .font(.terminalSmall)
                        .foregroundColor(.neonCyan)
                }
                Text("Chips")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
    }
}

// MARK: - Preview

#Preview("Daily Reward") {
    ZStack {
        Color.terminalBlack.ignoresSafeArea()
        DailyRewardPopupView(
            engagementManager: EngagementManager.shared,
            onClaim: { _ in }
        )
    }
}

#Preview("Achievement Unlock") {
    ZStack {
        Color.terminalBlack.ignoresSafeArea()
        AchievementUnlockPopupView(
            achievement: AchievementDatabase.allAchievements[10],
            onDismiss: { }
        )
    }
}

#Preview("Data Chip Unlock") {
    ZStack {
        Color.terminalBlack.ignoresSafeArea()
        DataChipUnlockPopupView(
            chip: DataChipDatabase.allChips[3],
            onDismiss: { }
        )
    }
}
