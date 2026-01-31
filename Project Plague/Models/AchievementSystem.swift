// AchievementSystem.swift
// GridWatchZero
// Extended achievement system beyond basic milestones

import Foundation
import Combine

// MARK: - Achievement Category

enum AchievementCategory: String, Codable, CaseIterable {
    case combat       // Attack/defense related
    case economy      // Credit and data achievements
    case progression  // Level and upgrade achievements
    case collection   // Collecting items/lore
    case mastery      // Perfect runs, speed runs
    case social       // Sharing, comparing
    case secret       // Hidden achievements

    var title: String {
        switch self {
        case .combat: return "Combat"
        case .economy: return "Economy"
        case .progression: return "Progression"
        case .collection: return "Collection"
        case .mastery: return "Mastery"
        case .social: return "Social"
        case .secret: return "Secret"
        }
    }

    var icon: String {
        switch self {
        case .combat: return "shield.lefthalf.fill"
        case .economy: return "dollarsign.circle.fill"
        case .progression: return "arrow.up.forward.circle.fill"
        case .collection: return "folder.fill"
        case .mastery: return "crown.fill"
        case .social: return "person.2.fill"
        case .secret: return "questionmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .combat: return "red"
        case .economy: return "green"
        case .progression: return "blue"
        case .collection: return "purple"
        case .mastery: return "gold"
        case .social: return "cyan"
        case .secret: return "gray"
        }
    }
}

// MARK: - Achievement Rarity

enum AchievementRarity: String, Codable, CaseIterable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var displayName: String {
        rawValue.capitalized
    }

    var rewardMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.5
        case .epic: return 5.0
        case .legendary: return 10.0
        }
    }

    var icon: String {
        switch self {
        case .common: return "circle.fill"
        case .uncommon: return "diamond.fill"
        case .rare: return "star.fill"
        case .epic: return "sparkles"
        case .legendary: return "crown.fill"
        }
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let hiddenDescription: String?  // Shown before unlock for secret achievements
    let category: AchievementCategory
    let rarity: AchievementRarity
    let requirement: AchievementRequirement
    let rewardCredits: Double
    let rewardDataChips: Int
    let isSecret: Bool

    var displayDescription: String {
        if isSecret {
            return hiddenDescription ?? "???"
        }
        return description
    }
}

// MARK: - Achievement Requirement

enum AchievementRequirement: Codable {
    // Combat requirements
    case surviveAttacks(count: Int)
    case surviveWithoutDamage(count: Int)
    case defensePointsReached(points: Int)
    case firewallNeverBroken(levels: Int)
    case perfectDefense(attacks: Int)  // No credit damage for X attacks

    // Economy requirements
    case totalCreditsEarned(amount: Double)
    case creditsInSingleRun(amount: Double)
    case creditsPerSecond(rate: Double)
    case noCreditsLost(ticks: Int)

    // Progression requirements
    case levelCompleted(level: Int)
    case allLevelsCompleted
    case maxTierReached(tier: Int)
    case unitFullyUpgraded(count: Int)
    case prestigeLevel(level: Int)

    // Collection requirements
    case loreCollected(count: Int)
    case allLoreCollected
    case dataChipsCollected(count: Int)
    case intelReportsSent(count: Int)

    // Mastery requirements
    case speedRunLevel(level: Int, seconds: Int)
    case noUpgradesLevel(level: Int)
    case maxEfficiency(percentage: Double)
    case loginStreak(days: Int)
    case weeklyChallengePerfect  // Complete all weekly challenges

    // Social requirements
    case firstShare
    case inviteFriend

    // Secret requirements
    case easterEgg(id: String)
    case specificSequence(sequence: String)

    func isMet(by stats: AchievementStats) -> Bool {
        switch self {
        case .surviveAttacks(let count):
            return stats.totalAttacksSurvived >= count
        case .surviveWithoutDamage(let count):
            return stats.consecutiveNoDamageAttacks >= count
        case .defensePointsReached(let points):
            return stats.highestDefensePoints >= points
        case .firewallNeverBroken(let levels):
            return stats.levelsWithoutFirewallBreak >= levels
        case .perfectDefense(let attacks):
            return stats.perfectDefenseStreak >= attacks

        case .totalCreditsEarned(let amount):
            return stats.totalCreditsEarned >= amount
        case .creditsInSingleRun(let amount):
            return stats.highestSingleRunCredits >= amount
        case .creditsPerSecond(let rate):
            return stats.highestCreditsPerSecond >= rate
        case .noCreditsLost(let ticks):
            return stats.longestNoLossStreak >= ticks

        case .levelCompleted(let level):
            return stats.highestLevelCompleted >= level
        case .allLevelsCompleted:
            return stats.allLevelsCompleted
        case .maxTierReached(let tier):
            return stats.highestTierUnlocked >= tier
        case .unitFullyUpgraded(let count):
            return stats.fullyUpgradedUnits >= count
        case .prestigeLevel(let level):
            return stats.prestigeLevel >= level

        case .loreCollected(let count):
            return stats.loreFragmentsCollected >= count
        case .allLoreCollected:
            return stats.allLoreCollected
        case .dataChipsCollected(let count):
            return stats.dataChipsCollected >= count
        case .intelReportsSent(let count):
            return stats.intelReportsSent >= count

        case .speedRunLevel(let level, let seconds):
            return stats.levelCompletionTimes[level] ?? Int.max <= seconds
        case .noUpgradesLevel(let level):
            return stats.levelsCompletedNoUpgrades.contains(level)
        case .maxEfficiency(let percentage):
            return stats.highestEfficiency >= percentage
        case .loginStreak(let days):
            return stats.longestLoginStreak >= days
        case .weeklyChallengePerfect:
            return stats.perfectWeeks >= 1

        case .firstShare:
            return stats.hasShared
        case .inviteFriend:
            return stats.friendsInvited >= 1

        case .easterEgg(let id):
            return stats.easterEggsFound.contains(id)
        case .specificSequence(let sequence):
            return stats.sequencesCompleted.contains(sequence)
        }
    }
}

// MARK: - Achievement Stats

struct AchievementStats: Codable {
    // Combat stats
    var totalAttacksSurvived: Int = 0
    var consecutiveNoDamageAttacks: Int = 0
    var highestDefensePoints: Int = 0
    var levelsWithoutFirewallBreak: Int = 0
    var perfectDefenseStreak: Int = 0

    // Economy stats
    var totalCreditsEarned: Double = 0
    var highestSingleRunCredits: Double = 0
    var highestCreditsPerSecond: Double = 0
    var longestNoLossStreak: Int = 0

    // Progression stats
    var highestLevelCompleted: Int = 0
    var allLevelsCompleted: Bool = false
    var highestTierUnlocked: Int = 1
    var fullyUpgradedUnits: Int = 0
    var prestigeLevel: Int = 0

    // Collection stats
    var loreFragmentsCollected: Int = 0
    var allLoreCollected: Bool = false
    var dataChipsCollected: Int = 0
    var intelReportsSent: Int = 0

    // Mastery stats
    var levelCompletionTimes: [Int: Int] = [:]  // Level -> best time in ticks
    var levelsCompletedNoUpgrades: Set<Int> = []
    var highestEfficiency: Double = 0
    var longestLoginStreak: Int = 0
    var perfectWeeks: Int = 0

    // Social stats
    var hasShared: Bool = false
    var friendsInvited: Int = 0

    // Secret stats
    var easterEggsFound: Set<String> = []
    var sequencesCompleted: Set<String> = []
}

// MARK: - Achievement State

struct AchievementState: Codable {
    var unlockedAchievementIds: Set<String> = []
    var stats: AchievementStats = AchievementStats()
    var recentUnlocks: [String] = []  // Last 5 unlocked achievement IDs
    var totalPoints: Int = 0

    func isUnlocked(_ achievementId: String) -> Bool {
        unlockedAchievementIds.contains(achievementId)
    }

    mutating func unlock(_ achievement: Achievement) {
        guard !isUnlocked(achievement.id) else { return }

        unlockedAchievementIds.insert(achievement.id)
        recentUnlocks.insert(achievement.id, at: 0)
        if recentUnlocks.count > 5 {
            recentUnlocks.removeLast()
        }

        // Calculate points based on rarity
        let points = Int(100 * achievement.rarity.rewardMultiplier)
        totalPoints += points
    }
}

// MARK: - Achievement Database

enum AchievementDatabase {
    static let allAchievements: [Achievement] = [
        // ===== COMBAT =====
        Achievement(
            id: "combat_survivor_10",
            title: "Survivor",
            description: "Survive 10 attacks",
            hiddenDescription: nil,
            category: .combat,
            rarity: .common,
            requirement: .surviveAttacks(count: 10),
            rewardCredits: 500,
            rewardDataChips: 1,
            isSecret: false
        ),
        Achievement(
            id: "combat_survivor_100",
            title: "Battle Hardened",
            description: "Survive 100 attacks",
            hiddenDescription: nil,
            category: .combat,
            rarity: .uncommon,
            requirement: .surviveAttacks(count: 100),
            rewardCredits: 5000,
            rewardDataChips: 3,
            isSecret: false
        ),
        Achievement(
            id: "combat_survivor_500",
            title: "Unbreakable",
            description: "Survive 500 attacks",
            hiddenDescription: nil,
            category: .combat,
            rarity: .rare,
            requirement: .surviveAttacks(count: 500),
            rewardCredits: 25000,
            rewardDataChips: 5,
            isSecret: false
        ),
        Achievement(
            id: "combat_perfect_5",
            title: "Flawless Defense",
            description: "Survive 5 attacks without losing credits",
            hiddenDescription: nil,
            category: .combat,
            rarity: .uncommon,
            requirement: .perfectDefense(attacks: 5),
            rewardCredits: 2500,
            rewardDataChips: 2,
            isSecret: false
        ),
        Achievement(
            id: "combat_perfect_25",
            title: "Iron Wall",
            description: "Survive 25 attacks without losing credits",
            hiddenDescription: nil,
            category: .combat,
            rarity: .epic,
            requirement: .perfectDefense(attacks: 25),
            rewardCredits: 25000,
            rewardDataChips: 5,
            isSecret: false
        ),
        Achievement(
            id: "combat_defense_100",
            title: "Fortress",
            description: "Reach 100 Defense Points",
            hiddenDescription: nil,
            category: .combat,
            rarity: .uncommon,
            requirement: .defensePointsReached(points: 100),
            rewardCredits: 5000,
            rewardDataChips: 2,
            isSecret: false
        ),
        Achievement(
            id: "combat_defense_500",
            title: "Citadel",
            description: "Reach 500 Defense Points",
            hiddenDescription: nil,
            category: .combat,
            rarity: .rare,
            requirement: .defensePointsReached(points: 500),
            rewardCredits: 25000,
            rewardDataChips: 5,
            isSecret: false
        ),

        // ===== ECONOMY =====
        Achievement(
            id: "economy_first_million",
            title: "Millionaire",
            description: "Earn 1,000,000 credits total",
            hiddenDescription: nil,
            category: .economy,
            rarity: .uncommon,
            requirement: .totalCreditsEarned(amount: 1_000_000),
            rewardCredits: 10000,
            rewardDataChips: 3,
            isSecret: false
        ),
        Achievement(
            id: "economy_10_million",
            title: "Data Mogul",
            description: "Earn 10,000,000 credits total",
            hiddenDescription: nil,
            category: .economy,
            rarity: .rare,
            requirement: .totalCreditsEarned(amount: 10_000_000),
            rewardCredits: 100000,
            rewardDataChips: 5,
            isSecret: false
        ),
        Achievement(
            id: "economy_100_million",
            title: "Shadow Baron",
            description: "Earn 100,000,000 credits total",
            hiddenDescription: nil,
            category: .economy,
            rarity: .epic,
            requirement: .totalCreditsEarned(amount: 100_000_000),
            rewardCredits: 1000000,
            rewardDataChips: 10,
            isSecret: false
        ),
        Achievement(
            id: "economy_billion",
            title: "Digital Empire",
            description: "Earn 1,000,000,000 credits total",
            hiddenDescription: nil,
            category: .economy,
            rarity: .legendary,
            requirement: .totalCreditsEarned(amount: 1_000_000_000),
            rewardCredits: 10000000,
            rewardDataChips: 25,
            isSecret: false
        ),

        // ===== PROGRESSION =====
        Achievement(
            id: "progression_level_1",
            title: "First Mission",
            description: "Complete Level 1",
            hiddenDescription: nil,
            category: .progression,
            rarity: .common,
            requirement: .levelCompleted(level: 1),
            rewardCredits: 1000,
            rewardDataChips: 1,
            isSecret: false
        ),
        Achievement(
            id: "progression_level_3",
            title: "Rising Operator",
            description: "Complete Level 3",
            hiddenDescription: nil,
            category: .progression,
            rarity: .uncommon,
            requirement: .levelCompleted(level: 3),
            rewardCredits: 5000,
            rewardDataChips: 2,
            isSecret: false
        ),
        Achievement(
            id: "progression_level_5",
            title: "Veteran Defender",
            description: "Complete Level 5",
            hiddenDescription: nil,
            category: .progression,
            rarity: .rare,
            requirement: .levelCompleted(level: 5),
            rewardCredits: 25000,
            rewardDataChips: 5,
            isSecret: false
        ),
        Achievement(
            id: "progression_level_7",
            title: "Campaign Complete",
            description: "Complete all 7 levels",
            hiddenDescription: nil,
            category: .progression,
            rarity: .epic,
            requirement: .allLevelsCompleted,
            rewardCredits: 100000,
            rewardDataChips: 10,
            isSecret: false
        ),
        Achievement(
            id: "progression_prestige_1",
            title: "Network Wipe",
            description: "Prestige for the first time",
            hiddenDescription: nil,
            category: .progression,
            rarity: .uncommon,
            requirement: .prestigeLevel(level: 1),
            rewardCredits: 5000,
            rewardDataChips: 3,
            isSecret: false
        ),
        Achievement(
            id: "progression_prestige_5",
            title: "Helix Adept",
            description: "Reach prestige level 5",
            hiddenDescription: nil,
            category: .progression,
            rarity: .rare,
            requirement: .prestigeLevel(level: 5),
            rewardCredits: 50000,
            rewardDataChips: 10,
            isSecret: false
        ),
        Achievement(
            id: "progression_tier_3",
            title: "Elite Operator",
            description: "Unlock Tier 3 units",
            hiddenDescription: nil,
            category: .progression,
            rarity: .uncommon,
            requirement: .maxTierReached(tier: 3),
            rewardCredits: 10000,
            rewardDataChips: 3,
            isSecret: false
        ),
        Achievement(
            id: "progression_tier_6",
            title: "Helix Integration",
            description: "Unlock Tier 6 units",
            hiddenDescription: nil,
            category: .progression,
            rarity: .epic,
            requirement: .maxTierReached(tier: 6),
            rewardCredits: 100000,
            rewardDataChips: 10,
            isSecret: false
        ),

        // ===== COLLECTION =====
        Achievement(
            id: "collection_lore_10",
            title: "Intel Collector",
            description: "Collect 10 lore fragments",
            hiddenDescription: nil,
            category: .collection,
            rarity: .common,
            requirement: .loreCollected(count: 10),
            rewardCredits: 2500,
            rewardDataChips: 2,
            isSecret: false
        ),
        Achievement(
            id: "collection_lore_all",
            title: "Archivist",
            description: "Collect all lore fragments",
            hiddenDescription: nil,
            category: .collection,
            rarity: .epic,
            requirement: .allLoreCollected,
            rewardCredits: 50000,
            rewardDataChips: 10,
            isSecret: false
        ),
        Achievement(
            id: "collection_chips_25",
            title: "Chip Hoarder",
            description: "Collect 25 data chips",
            hiddenDescription: nil,
            category: .collection,
            rarity: .uncommon,
            requirement: .dataChipsCollected(count: 25),
            rewardCredits: 10000,
            rewardDataChips: 0,  // No chip reward for chip achievement
            isSecret: false
        ),
        Achievement(
            id: "collection_chips_100",
            title: "Data Vault",
            description: "Collect 100 data chips",
            hiddenDescription: nil,
            category: .collection,
            rarity: .rare,
            requirement: .dataChipsCollected(count: 100),
            rewardCredits: 50000,
            rewardDataChips: 0,
            isSecret: false
        ),
        Achievement(
            id: "collection_reports_50",
            title: "Intel Operative",
            description: "Send 50 intel reports",
            hiddenDescription: nil,
            category: .collection,
            rarity: .uncommon,
            requirement: .intelReportsSent(count: 50),
            rewardCredits: 10000,
            rewardDataChips: 3,
            isSecret: false
        ),
        Achievement(
            id: "collection_reports_250",
            title: "Shadow Informant",
            description: "Send 250 intel reports",
            hiddenDescription: nil,
            category: .collection,
            rarity: .rare,
            requirement: .intelReportsSent(count: 250),
            rewardCredits: 50000,
            rewardDataChips: 8,
            isSecret: false
        ),

        // ===== MASTERY =====
        Achievement(
            id: "mastery_efficiency_95",
            title: "Optimized",
            description: "Achieve 95% data efficiency",
            hiddenDescription: nil,
            category: .mastery,
            rarity: .uncommon,
            requirement: .maxEfficiency(percentage: 0.95),
            rewardCredits: 5000,
            rewardDataChips: 2,
            isSecret: false
        ),
        Achievement(
            id: "mastery_efficiency_99",
            title: "Perfect Pipeline",
            description: "Achieve 99% data efficiency",
            hiddenDescription: nil,
            category: .mastery,
            rarity: .rare,
            requirement: .maxEfficiency(percentage: 0.99),
            rewardCredits: 25000,
            rewardDataChips: 5,
            isSecret: false
        ),
        Achievement(
            id: "mastery_streak_7",
            title: "Dedicated",
            description: "Log in 7 days in a row",
            hiddenDescription: nil,
            category: .mastery,
            rarity: .uncommon,
            requirement: .loginStreak(days: 7),
            rewardCredits: 5000,
            rewardDataChips: 3,
            isSecret: false
        ),
        Achievement(
            id: "mastery_streak_30",
            title: "Obsessed",
            description: "Log in 30 days in a row",
            hiddenDescription: nil,
            category: .mastery,
            rarity: .rare,
            requirement: .loginStreak(days: 30),
            rewardCredits: 25000,
            rewardDataChips: 10,
            isSecret: false
        ),
        Achievement(
            id: "mastery_streak_100",
            title: "True Operator",
            description: "Log in 100 days in a row",
            hiddenDescription: nil,
            category: .mastery,
            rarity: .legendary,
            requirement: .loginStreak(days: 100),
            rewardCredits: 250000,
            rewardDataChips: 50,
            isSecret: false
        ),
        Achievement(
            id: "mastery_perfect_week",
            title: "Challenge Master",
            description: "Complete all weekly challenges in one week",
            hiddenDescription: nil,
            category: .mastery,
            rarity: .epic,
            requirement: .weeklyChallengePerfect,
            rewardCredits: 50000,
            rewardDataChips: 10,
            isSecret: false
        ),

        // ===== SECRET =====
        Achievement(
            id: "secret_helix_found",
            title: "Signal in the Noise",
            description: "Discover Helix's hidden message",
            hiddenDescription: "Something is watching...",
            category: .secret,
            rarity: .epic,
            requirement: .easterEgg(id: "helix_signal"),
            rewardCredits: 25000,
            rewardDataChips: 5,
            isSecret: true
        ),
        Achievement(
            id: "secret_malus_taunt",
            title: "I See You",
            description: "Receive a direct message from Malus",
            hiddenDescription: "The hunter becomes the hunted",
            category: .secret,
            rarity: .rare,
            requirement: .easterEgg(id: "malus_direct"),
            rewardCredits: 10000,
            rewardDataChips: 3,
            isSecret: true
        ),
        Achievement(
            id: "secret_konami",
            title: "Old School",
            description: "Enter the classic code",
            hiddenDescription: "↑↑↓↓←→←→BA",
            category: .secret,
            rarity: .uncommon,
            requirement: .specificSequence(sequence: "konami"),
            rewardCredits: 5000,
            rewardDataChips: 2,
            isSecret: true
        ),
        Achievement(
            id: "secret_night_owl",
            title: "Night Owl",
            description: "Play at 3:00 AM",
            hiddenDescription: "The network never sleeps",
            category: .secret,
            rarity: .uncommon,
            requirement: .easterEgg(id: "night_3am"),
            rewardCredits: 3000,
            rewardDataChips: 1,
            isSecret: true
        ),
        Achievement(
            id: "secret_perfect_level1",
            title: "Flawless Debut",
            description: "Complete Level 1 without taking any damage",
            hiddenDescription: "A perfect beginning",
            category: .secret,
            rarity: .rare,
            requirement: .easterEgg(id: "perfect_level1"),
            rewardCredits: 15000,
            rewardDataChips: 3,
            isSecret: true
        )
    ]

    static func achievement(withId id: String) -> Achievement? {
        allAchievements.first { $0.id == id }
    }

    static func achievements(for category: AchievementCategory) -> [Achievement] {
        allAchievements.filter { $0.category == category }
    }

    static func visibleAchievements() -> [Achievement] {
        allAchievements.filter { !$0.isSecret }
    }

    static func checkProgress(state: AchievementState) -> [Achievement] {
        allAchievements.filter { achievement in
            guard !state.isUnlocked(achievement.id) else { return false }
            return achievement.requirement.isMet(by: state.stats)
        }
    }
}

// MARK: - Achievement Manager

@MainActor
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()

    @Published var state = AchievementState()
    @Published var pendingUnlocks: [Achievement] = []
    @Published var showAchievementPopup = false

    private let saveKey = "GridWatchZero.AchievementState.v1"

    private init() {
        load()
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let loaded = try? JSONDecoder().decode(AchievementState.self, from: data) {
            state = loaded
        }
    }

    // MARK: - Progress Updates

    func updateStats(_ update: (inout AchievementStats) -> Void) {
        update(&state.stats)
        checkForNewUnlocks()
        save()
    }

    func checkForNewUnlocks() {
        let newUnlocks = AchievementDatabase.checkProgress(state: state)
        for achievement in newUnlocks {
            state.unlock(achievement)
            pendingUnlocks.append(achievement)
        }

        if !pendingUnlocks.isEmpty {
            showAchievementPopup = true
        }
    }

    func dismissAchievementPopup() {
        if !pendingUnlocks.isEmpty {
            pendingUnlocks.removeFirst()
        }
        showAchievementPopup = !pendingUnlocks.isEmpty
    }

    // MARK: - Stats

    var totalAchievements: Int {
        AchievementDatabase.allAchievements.count
    }

    var unlockedCount: Int {
        state.unlockedAchievementIds.count
    }

    var completionPercentage: Double {
        Double(unlockedCount) / Double(totalAchievements)
    }

    var totalPoints: Int {
        state.totalPoints
    }

    func achievements(for category: AchievementCategory) -> [Achievement] {
        AchievementDatabase.achievements(for: category)
    }

    func isUnlocked(_ achievementId: String) -> Bool {
        state.isUnlocked(achievementId)
    }

    // MARK: - Easter Eggs

    func triggerEasterEgg(_ eggId: String) {
        state.stats.easterEggsFound.insert(eggId)
        checkForNewUnlocks()
        save()
    }

    func triggerSequence(_ sequence: String) {
        state.stats.sequencesCompleted.insert(sequence)
        checkForNewUnlocks()
        save()
    }

    // MARK: - Reset

    func reset() {
        state = AchievementState()
        save()
    }
}
