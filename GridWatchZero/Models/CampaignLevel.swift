// CampaignLevel.swift
// GridWatchZero
// Campaign level definitions and victory conditions

import Foundation

// MARK: - Campaign Level

struct CampaignLevel: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let subtitle: String
    let description: String

    // Starting conditions
    let startingCredits: Double
    let startingThreatLevel: ThreatLevel
    let availableTiers: [Int]  // Which defense/unit tiers are available

    // Victory conditions
    let victoryConditions: VictoryConditions

    // Unlock requirements
    let unlockRequirement: UnlockRequirement

    // Network configuration
    let networkSize: NetworkSize

    // Story hooks
    let introStoryId: String?
    let victoryStoryId: String?

    // Insane mode modifier
    let insaneModifiers: InsaneModifiers?

    // Balance tuning: minimum attack chance per tick (regardless of defense)
    // This ensures attacks keep happening even with high defense
    let minimumAttackChance: Double?

    static func == (lhs: CampaignLevel, rhs: CampaignLevel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Victory Conditions

struct VictoryConditions: Codable {
    // Defense requirements
    let requiredDefenseTier: Int          // Must have defense apps of this tier
    let requiredDefensePoints: Int        // Minimum defense points
    let requiredRiskLevel: ThreatLevel    // Must reduce risk to this level

    // Optional requirements
    let requiredCredits: Double?          // Must accumulate this many credits
    let requiredAttacksSurvived: Int?     // Must survive this many attacks
    let requiredReportsSent: Int?         // Must send this many intel reports to team
    let timeLimit: Int?                   // Optional tick limit (nil = no limit)

    // Check if conditions are met
    func isSatisfied(
        defenseStack: DefenseStack,
        riskLevel: ThreatLevel,
        totalCredits: Double,
        attacksSurvived: Int,
        reportsSent: Int,
        currentTick: Int
    ) -> Bool {
        // Check defense tier
        let highestTier = defenseStack.applications.values.map { $0.tier.tierNumber }.max() ?? 0
        guard highestTier >= requiredDefenseTier else { return false }

        // Check defense points
        guard Int(defenseStack.totalDefensePoints) >= requiredDefensePoints else { return false }

        // Check risk level (lower is better)
        guard riskLevel.rawValue <= requiredRiskLevel.rawValue else { return false }

        // Check optional credits
        if let required = requiredCredits, totalCredits < required {
            return false
        }

        // Check optional attacks survived
        if let required = requiredAttacksSurvived, attacksSurvived < required {
            return false
        }

        // Check intel reports sent (main objective - helping team stop Malus)
        if let required = requiredReportsSent, reportsSent < required {
            return false
        }

        // Check time limit (fail if exceeded - handled separately)
        return true
    }

    // Check if time limit exceeded (separate from victory check)
    func isTimeLimitExceeded(currentTick: Int) -> Bool {
        guard let limit = timeLimit else { return false }
        return currentTick > limit
    }
}

// MARK: - Unlock Requirement

enum UnlockRequirement: Codable, Equatable {
    case none                           // Always unlocked (Level 1)
    case previousLevel(Int)             // Complete previous level
    case previousLevelInsane(Int)       // Complete previous level on Insane
    case specificLevels([Int])          // Complete specific levels

    var description: String {
        switch self {
        case .none:
            return "Unlocked"
        case .previousLevel(let id):
            return "Complete Level \(id)"
        case .previousLevelInsane(let id):
            return "Complete Level \(id) on Insane"
        case .specificLevels(let ids):
            return "Complete Levels \(ids.map(String.init).joined(separator: ", "))"
        }
    }

    func isSatisfied(by progress: CampaignProgress) -> Bool {
        switch self {
        case .none:
            return true
        case .previousLevel(let id):
            return progress.completedLevels.contains(id)
        case .previousLevelInsane(let id):
            return progress.insaneCompletedLevels.contains(id)
        case .specificLevels(let ids):
            return ids.allSatisfy { progress.completedLevels.contains($0) }
        }
    }
}

// MARK: - Network Size

enum NetworkSize: String, Codable, CaseIterable {
    case smallHome = "Small Home"
    case smallOffice = "Small Office"
    case office = "Office"
    case largeOffice = "Large Office"
    case campus = "Campus"
    case enterprise = "Enterprise"
    case cityWide = "City-wide"

    var nodeCapacity: Int {
        switch self {
        case .smallHome: return 3
        case .smallOffice: return 4
        case .office: return 5
        case .largeOffice: return 6
        case .campus: return 8
        case .enterprise: return 10
        case .cityWide: return 12
        }
    }

    var defenseSlots: Int {
        switch self {
        case .smallHome: return 2
        case .smallOffice: return 3
        case .office: return 4
        case .largeOffice: return 5
        case .campus: return 6
        case .enterprise: return 8
        case .cityWide: return 10
        }
    }
}

// MARK: - Insane Mode Modifiers

struct InsaneModifiers: Codable {
    let threatFrequencyMultiplier: Double   // 2.0 = 2x more attacks
    let attackDamageMultiplier: Double      // 1.5 = 50% more damage
    let creditIncomeMultiplier: Double      // 0.75 = 25% less income

    static let standard = InsaneModifiers(
        threatFrequencyMultiplier: 2.0,
        attackDamageMultiplier: 1.5,
        creditIncomeMultiplier: 0.75
    )
}

// MARK: - Level State (Runtime)

enum LevelState: Equatable {
    case notStarted
    case inProgress(startTick: Int)
    case victory(stats: LevelCompletionStats)
    case failed(reason: FailureReason)
    case abandoned
}

enum FailureReason: String, Codable {
    case timeLimitExceeded = "Time limit exceeded"
    case networkedDestroyed = "Network compromised"
    case creditsZero = "Bankruptcy"
    case userQuit = "Mission abandoned"
}

// MARK: - Level Completion Stats

struct LevelCompletionStats: Codable, Equatable {
    let levelId: Int
    let isInsane: Bool
    let ticksToComplete: Int
    let creditsEarned: Double
    let attacksSurvived: Int
    let damageBlocked: Double
    let finalDefensePoints: Int
    let intelReportsSent: Int
    let completionDate: Date

    var grade: LevelGrade {
        // Grade based on efficiency
        // S: Under 50% of expected time, A: Under 75%, B: Under 100%, C: Over 100%
        let expectedTicks = 600 * levelId  // ~10 minutes per level baseline
        let timeRatio = Double(ticksToComplete) / Double(expectedTicks)

        if timeRatio < 0.5 { return .s }
        if timeRatio < 0.75 { return .a }
        if timeRatio < 1.0 { return .b }
        return .c
    }
}

enum LevelGrade: String, Codable, CaseIterable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"

    var color: String {
        switch self {
        case .s: return "neonAmber"
        case .a: return "neonGreen"
        case .b: return "neonCyan"
        case .c: return "terminalGray"
        }
    }
}

// MARK: - Level Configuration (For GameEngine)

struct LevelConfiguration {
    let level: CampaignLevel
    let isInsane: Bool

    // Computed modifiers
    var threatMultiplier: Double {
        isInsane ? (level.insaneModifiers?.threatFrequencyMultiplier ?? 2.0) : 1.0
    }

    var damageMultiplier: Double {
        isInsane ? (level.insaneModifiers?.attackDamageMultiplier ?? 1.5) : 1.0
    }

    var incomeMultiplier: Double {
        isInsane ? (level.insaneModifiers?.creditIncomeMultiplier ?? 0.75) : 1.0
    }

    var maxTier: Int {
        level.availableTiers.max() ?? 1
    }

    /// Minimum attack chance per tick (ensures attacks keep happening)
    var minimumAttackChance: Double {
        level.minimumAttackChance ?? 0.0
    }
}
