// EngagementSystem.swift
// GridWatchZero
// Daily rewards, streaks, and player engagement systems

import Foundation
import Combine

// MARK: - Daily Reward

struct DailyReward: Codable, Identifiable {
    let id: Int  // Day number (1-7)
    let credits: Double
    let bonusMultiplier: Double  // Multiplier for next session (1.0 = no bonus)
    let bonusDurationTicks: Int  // How long the multiplier lasts
    let specialReward: SpecialDailyReward?

    var description: String {
        var parts: [String] = []
        parts.append("₵\(credits.formatted)")
        if bonusMultiplier > 1.0 {
            parts.append("\(bonusMultiplier)x boost (\(bonusDurationTicks/60)min)")
        }
        if let special = specialReward {
            parts.append(special.description)
        }
        return parts.joined(separator: " + ")
    }
}

enum SpecialDailyReward: String, Codable {
    case dataChip       // Collectible chip
    case loreFragment   // Random lore unlock
    case defenseBoost   // Temporary defense increase
    case helixShard     // Prestige currency

    var description: String {
        switch self {
        case .dataChip: return "Data Chip"
        case .loreFragment: return "Intel Fragment"
        case .defenseBoost: return "Defense Boost"
        case .helixShard: return "Helix Shard"
        }
    }

    var icon: String {
        switch self {
        case .dataChip: return "memorychip.fill"
        case .loreFragment: return "doc.text.fill"
        case .defenseBoost: return "shield.fill"
        case .helixShard: return "sparkles"
        }
    }
}

// MARK: - Daily Rewards Database

enum DailyRewardsDatabase {
    /// Weekly cycle of daily rewards (repeats after day 7)
    static let weeklyRewards: [DailyReward] = [
        DailyReward(id: 1, credits: 500, bonusMultiplier: 1.0, bonusDurationTicks: 0, specialReward: nil),
        DailyReward(id: 2, credits: 750, bonusMultiplier: 1.2, bonusDurationTicks: 300, specialReward: nil),
        DailyReward(id: 3, credits: 1000, bonusMultiplier: 1.0, bonusDurationTicks: 0, specialReward: .dataChip),
        DailyReward(id: 4, credits: 1500, bonusMultiplier: 1.3, bonusDurationTicks: 600, specialReward: nil),
        DailyReward(id: 5, credits: 2000, bonusMultiplier: 1.0, bonusDurationTicks: 0, specialReward: .loreFragment),
        DailyReward(id: 6, credits: 3000, bonusMultiplier: 1.5, bonusDurationTicks: 900, specialReward: .defenseBoost),
        DailyReward(id: 7, credits: 5000, bonusMultiplier: 2.0, bonusDurationTicks: 1800, specialReward: .helixShard)
    ]

    static func reward(forDay day: Int) -> DailyReward {
        let index = ((day - 1) % 7)
        return weeklyRewards[index]
    }

    /// Streak bonus multiplier (applied on top of daily reward)
    static func streakBonus(forStreak streak: Int) -> Double {
        switch streak {
        case 0...6: return 1.0
        case 7...13: return 1.25   // 1 week streak
        case 14...20: return 1.5   // 2 week streak
        case 21...27: return 1.75  // 3 week streak
        default: return 2.0        // 4+ week streak
        }
    }
}

// MARK: - Login Streak State

struct LoginStreakState: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastLoginDate: Date?
    var totalLogins: Int = 0
    var currentWeekDay: Int = 1  // 1-7, resets after claiming day 7
    var hasClaimedToday: Bool = false

    /// Active bonus multiplier from daily reward
    var activeBonusMultiplier: Double = 1.0
    var bonusTicksRemaining: Int = 0

    /// Check if a new day has started since last login
    func isNewDay() -> Bool {
        guard let lastLogin = lastLoginDate else { return true }
        return !Calendar.current.isDateInToday(lastLogin)
    }

    /// Check if streak is maintained (logged in yesterday or today)
    func isStreakMaintained() -> Bool {
        guard let lastLogin = lastLoginDate else { return false }
        let calendar = Calendar.current
        if calendar.isDateInToday(lastLogin) { return true }
        if calendar.isDateInYesterday(lastLogin) { return true }
        return false
    }

    mutating func processLogin() {
        let isNew = isNewDay()
        let streakMaintained = isStreakMaintained()

        if isNew {
            totalLogins += 1
            hasClaimedToday = false

            if streakMaintained {
                currentStreak += 1
            } else {
                // Streak broken - reset
                currentStreak = 1
                currentWeekDay = 1
            }

            longestStreak = max(longestStreak, currentStreak)
        }

        lastLoginDate = Date()
    }

    mutating func claimDailyReward() -> DailyReward? {
        guard !hasClaimedToday else { return nil }

        let reward = DailyRewardsDatabase.reward(forDay: currentWeekDay)
        hasClaimedToday = true

        // Apply bonus if reward has one
        if reward.bonusMultiplier > 1.0 {
            activeBonusMultiplier = reward.bonusMultiplier
            bonusTicksRemaining = reward.bonusDurationTicks
        }

        // Advance week day
        currentWeekDay = (currentWeekDay % 7) + 1

        return reward
    }

    mutating func tickBonus() {
        if bonusTicksRemaining > 0 {
            bonusTicksRemaining -= 1
            if bonusTicksRemaining <= 0 {
                activeBonusMultiplier = 1.0
            }
        }
    }
}

// MARK: - Weekly Challenge

struct WeeklyChallenge: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let targetValue: Double
    var currentProgress: Double = 0
    let rewardCredits: Double
    let rewardDataChips: Int
    let challengeType: ChallengeType
    let weekStartDate: Date

    var isComplete: Bool {
        currentProgress >= targetValue
    }

    var progressPercentage: Double {
        min(1.0, currentProgress / targetValue)
    }

    var timeRemaining: TimeInterval {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStartDate) ?? Date()
        return weekEnd.timeIntervalSince(Date())
    }

    var isExpired: Bool {
        timeRemaining <= 0
    }
}

enum ChallengeType: String, Codable {
    case earnCredits
    case processData
    case surviveAttacks
    case sendReports
    case upgradeUnits
    case deployDefense
    case playMinutes

    var icon: String {
        switch self {
        case .earnCredits: return "dollarsign.circle.fill"
        case .processData: return "externaldrive.fill"
        case .surviveAttacks: return "shield.fill"
        case .sendReports: return "doc.text.fill"
        case .upgradeUnits: return "arrow.up.circle.fill"
        case .deployDefense: return "lock.shield.fill"
        case .playMinutes: return "clock.fill"
        }
    }
}

// MARK: - Weekly Challenges Database

enum WeeklyChallengesDatabase {
    static func generateWeeklyChallenges(forWeekStarting date: Date, playerLevel: Int) -> [WeeklyChallenge] {
        // Scale challenges based on player progression
        let creditMultiplier = pow(2.0, Double(playerLevel))
        let dataMultiplier = pow(1.5, Double(playerLevel))

        return [
            WeeklyChallenge(
                id: "weekly_credits_\(date.timeIntervalSince1970)",
                title: "Credit Collector",
                description: "Earn credits this week",
                targetValue: 50000 * creditMultiplier,
                rewardCredits: 10000 * creditMultiplier,
                rewardDataChips: 2,
                challengeType: .earnCredits,
                weekStartDate: date
            ),
            WeeklyChallenge(
                id: "weekly_data_\(date.timeIntervalSince1970)",
                title: "Data Harvester",
                description: "Process data packets",
                targetValue: 25000 * dataMultiplier,
                rewardCredits: 5000 * creditMultiplier,
                rewardDataChips: 1,
                challengeType: .processData,
                weekStartDate: date
            ),
            WeeklyChallenge(
                id: "weekly_defense_\(date.timeIntervalSince1970)",
                title: "Cyber Defender",
                description: "Survive Malus attacks",
                targetValue: Double(10 + playerLevel * 2),
                rewardCredits: 7500 * creditMultiplier,
                rewardDataChips: 2,
                challengeType: .surviveAttacks,
                weekStartDate: date
            )
        ]
    }
}

// MARK: - Engagement State

struct EngagementState: Codable {
    var loginStreak: LoginStreakState = LoginStreakState()
    var weeklyChallenges: [WeeklyChallenge] = []
    var lastWeeklyReset: Date?

    /// Data chips collected (collectible currency)
    var dataChipsCollected: Int = 0
    var totalDataChipsEarned: Int = 0

    /// Track if daily reward notification should show
    var pendingDailyReward: Bool = false
    var lastClaimedReward: DailyReward?

    mutating func processAppLaunch() {
        loginStreak.processLogin()

        if loginStreak.isNewDay() && !loginStreak.hasClaimedToday {
            pendingDailyReward = true
        }

        // Check for weekly reset
        checkWeeklyReset()
    }

    mutating func checkWeeklyReset() {
        let calendar = Calendar.current
        let now = Date()

        // Get start of current week (Monday)
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return
        }

        // Check if we need to reset weekly challenges
        if lastWeeklyReset == nil || weekStart > lastWeeklyReset! {
            // New week - generate new challenges
            let playerLevel = max(1, loginStreak.totalLogins / 7)  // Rough progression metric
            weeklyChallenges = WeeklyChallengesDatabase.generateWeeklyChallenges(
                forWeekStarting: weekStart,
                playerLevel: playerLevel
            )
            lastWeeklyReset = weekStart
        }
    }

    mutating func claimDailyReward() -> (reward: DailyReward, streakBonus: Double)? {
        guard pendingDailyReward else { return nil }
        guard let reward = loginStreak.claimDailyReward() else { return nil }

        let streakBonus = DailyRewardsDatabase.streakBonus(forStreak: loginStreak.currentStreak)
        pendingDailyReward = false
        lastClaimedReward = reward

        // Handle special rewards
        if let special = reward.specialReward {
            switch special {
            case .dataChip:
                dataChipsCollected += 1
                totalDataChipsEarned += 1
            case .helixShard:
                // Handled by GameEngine
                break
            default:
                break
            }
        }

        return (reward, streakBonus)
    }

    mutating func updateChallengeProgress(type: ChallengeType, amount: Double) {
        for index in weeklyChallenges.indices {
            if weeklyChallenges[index].challengeType == type && !weeklyChallenges[index].isComplete {
                weeklyChallenges[index].currentProgress += amount
            }
        }
    }

    mutating func claimChallengeReward(_ challengeId: String) -> WeeklyChallenge? {
        guard let index = weeklyChallenges.firstIndex(where: { $0.id == challengeId && $0.isComplete }) else {
            return nil
        }

        let challenge = weeklyChallenges[index]
        dataChipsCollected += challenge.rewardDataChips
        totalDataChipsEarned += challenge.rewardDataChips

        // Mark as claimed by setting progress beyond target
        weeklyChallenges[index].currentProgress = challenge.targetValue + 1

        return challenge
    }
}

// MARK: - Engagement Manager

@MainActor
class EngagementManager: ObservableObject {
    static let shared = EngagementManager()

    @Published var state = EngagementState()
    @Published var showDailyRewardPopup = false
    @Published var showWeeklyChallenges = false

    private let saveKey = "GridWatchZero.EngagementState.v1"

    private init() {
        load()
        processAppLaunch()
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let loaded = try? JSONDecoder().decode(EngagementState.self, from: data) {
            state = loaded
        }
    }

    // MARK: - App Lifecycle

    func processAppLaunch() {
        state.processAppLaunch()

        if state.pendingDailyReward {
            // Slight delay before showing popup
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showDailyRewardPopup = true
            }
        }

        save()
    }

    // MARK: - Daily Rewards

    func claimDailyReward() -> (credits: Double, multiplier: Double, specialReward: SpecialDailyReward?)? {
        guard let (reward, streakBonus) = state.claimDailyReward() else { return nil }

        let totalCredits = reward.credits * streakBonus
        save()

        return (totalCredits, reward.bonusMultiplier, reward.specialReward)
    }

    func dismissDailyRewardPopup() {
        showDailyRewardPopup = false
    }

    // MARK: - Weekly Challenges

    func updateProgress(type: ChallengeType, amount: Double) {
        state.updateChallengeProgress(type: type, amount: amount)
        save()
    }

    func claimChallengeReward(_ challengeId: String) -> Double? {
        guard let challenge = state.claimChallengeReward(challengeId) else { return nil }
        save()
        return challenge.rewardCredits
    }

    // MARK: - Bonus Multiplier

    func tickBonus() {
        state.loginStreak.tickBonus()
    }

    var activeMultiplier: Double {
        state.loginStreak.activeBonusMultiplier
    }

    var bonusTimeRemaining: Int {
        state.loginStreak.bonusTicksRemaining
    }

    // MARK: - Stats

    var currentStreak: Int {
        state.loginStreak.currentStreak
    }

    var longestStreak: Int {
        state.loginStreak.longestStreak
    }

    var totalLogins: Int {
        state.loginStreak.totalLogins
    }

    var dataChips: Int {
        state.dataChipsCollected
    }

    var pendingChallenges: [WeeklyChallenge] {
        state.weeklyChallenges.filter { !$0.isComplete && !$0.isExpired }
    }

    var completedChallenges: [WeeklyChallenge] {
        state.weeklyChallenges.filter { $0.isComplete }
    }

    // MARK: - Reset

    func reset() {
        state = EngagementState()
        save()
    }
}
