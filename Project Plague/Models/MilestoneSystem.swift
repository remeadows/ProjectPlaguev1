// MilestoneSystem.swift
// GridWatchZero
// Achievement and milestone tracking

import Foundation

// MARK: - Milestone Type

enum MilestoneType: String, Codable, CaseIterable {
    case credits        // Total credits earned
    case data           // Total data processed
    case survival       // Attacks survived
    case threat         // Threat levels reached
    case units          // Units unlocked
    case upgrades       // Total upgrades purchased
    case time           // Total play time
    case lore           // Lore fragments collected
    case special        // Story/special milestones
    case campaign       // Campaign level completions
    case insane         // Insane mode completions

    var icon: String {
        switch self {
        case .credits: return "dollarsign.circle.fill"
        case .data: return "externaldrive.fill"
        case .survival: return "shield.fill"
        case .threat: return "exclamationmark.triangle.fill"
        case .units: return "cpu.fill"
        case .upgrades: return "arrow.up.circle.fill"
        case .time: return "clock.fill"
        case .lore: return "book.fill"
        case .special: return "star.fill"
        case .campaign: return "flag.fill"
        case .insane: return "flame.fill"
        }
    }
}

// MARK: - Milestone

struct Milestone: Identifiable, Codable {
    let id: String
    let type: MilestoneType
    let title: String
    let description: String
    let requirement: Double
    let reward: MilestoneReward
    let isHidden: Bool

    init(
        id: String,
        type: MilestoneType,
        title: String,
        description: String,
        requirement: Double,
        reward: MilestoneReward = .credits(100),
        isHidden: Bool = false
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.requirement = requirement
        self.reward = reward
        self.isHidden = isHidden
    }
}

// MARK: - Milestone Reward

enum MilestoneReward: Codable {
    case credits(Double)
    case loreUnlock(String)
    case unitUnlock(String)
    case multiplier(Double, Int)  // Multiplier and duration in ticks

    var description: String {
        switch self {
        case .credits(let amount):
            return "¢\(amount.formatted)"
        case .loreUnlock(_):
            return "Intel unlocked"
        case .unitUnlock(_):
            return "Unit unlocked"
        case .multiplier(let mult, let duration):
            return "\(mult)x for \(duration)s"
        }
    }
}

// MARK: - Milestone State

struct MilestoneState: Codable {
    var completedMilestoneIds: Set<String> = []
    var lastCompletedMilestoneId: String?

    // Progress tracking
    var totalCreditsEarned: Double = 0
    var totalDataProcessed: Double = 0
    var attacksSurvived: Int = 0
    var highestThreatLevel: ThreatLevel = .ghost
    var unitsUnlocked: Int = 3  // Starter units
    var totalUpgrades: Int = 0
    var totalPlayTimeSeconds: Int = 0
    var loreFragmentsCollected: Int = 0

    // Campaign tracking
    var campaignLevelsCompleted: Int = 0
    var insaneLevelsCompleted: Int = 0

    func isCompleted(_ milestoneId: String) -> Bool {
        completedMilestoneIds.contains(milestoneId)
    }

    mutating func complete(_ milestoneId: String) {
        completedMilestoneIds.insert(milestoneId)
        lastCompletedMilestoneId = milestoneId
    }

    func progress(for milestone: Milestone) -> Double {
        let current: Double
        switch milestone.type {
        case .credits:
            current = totalCreditsEarned
        case .data:
            current = totalDataProcessed
        case .survival:
            current = Double(attacksSurvived)
        case .threat:
            current = Double(highestThreatLevel.rawValue)
        case .units:
            current = Double(unitsUnlocked)
        case .upgrades:
            current = Double(totalUpgrades)
        case .time:
            current = Double(totalPlayTimeSeconds)
        case .lore:
            current = Double(loreFragmentsCollected)
        case .special:
            return isCompleted(milestone.id) ? 1.0 : 0.0
        case .campaign:
            current = Double(campaignLevelsCompleted)
        case .insane:
            current = Double(insaneLevelsCompleted)
        }
        return min(1.0, current / milestone.requirement)
    }
}

// MARK: - Milestone Database

enum MilestoneDatabase {
    static let allMilestones: [Milestone] = [
        // ===== CREDITS =====
        Milestone(
            id: "credits_100",
            type: .credits,
            title: "First Payday",
            description: "Earn 100 credits total",
            requirement: 100,
            reward: .credits(50)
        ),
        Milestone(
            id: "credits_1000",
            type: .credits,
            title: "Making Rent",
            description: "Earn 1,000 credits total",
            requirement: 1000,
            reward: .credits(250)
        ),
        Milestone(
            id: "credits_10000",
            type: .credits,
            title: "Street Cred",
            description: "Earn 10,000 credits total",
            requirement: 10000,
            reward: .credits(1000)
        ),
        Milestone(
            id: "credits_100000",
            type: .credits,
            title: "Shadow Banker",
            description: "Earn 100,000 credits total",
            requirement: 100000,
            reward: .credits(5000)
        ),
        Milestone(
            id: "credits_1000000",
            type: .credits,
            title: "Digital Mogul",
            description: "Earn 1,000,000 credits total",
            requirement: 1000000,
            reward: .loreUnlock("helix_signal_3")
        ),

        // ===== DATA =====
        Milestone(
            id: "data_1000",
            type: .data,
            title: "Data Miner",
            description: "Process 1,000 data units",
            requirement: 1000,
            reward: .credits(100)
        ),
        Milestone(
            id: "data_10000",
            type: .data,
            title: "Information Broker",
            description: "Process 10,000 data units",
            requirement: 10000,
            reward: .credits(500)
        ),
        Milestone(
            id: "data_100000",
            type: .data,
            title: "Data Baron",
            description: "Process 100,000 data units",
            requirement: 100000,
            reward: .credits(2500)
        ),

        // ===== SURVIVAL =====
        Milestone(
            id: "survival_1",
            type: .survival,
            title: "First Blood",
            description: "Survive your first attack",
            requirement: 1,
            reward: .credits(100)
        ),
        Milestone(
            id: "survival_10",
            type: .survival,
            title: "Battle Tested",
            description: "Survive 10 attacks",
            requirement: 10,
            reward: .credits(500)
        ),
        Milestone(
            id: "survival_50",
            type: .survival,
            title: "Hardened",
            description: "Survive 50 attacks",
            requirement: 50,
            reward: .credits(2500)
        ),
        Milestone(
            id: "survival_100",
            type: .survival,
            title: "Unbreakable",
            description: "Survive 100 attacks",
            requirement: 100,
            reward: .loreUnlock("malus_movement_2")
        ),

        // ===== THREAT =====
        Milestone(
            id: "threat_blip",
            type: .threat,
            title: "On the Radar",
            description: "Reach BLIP threat level",
            requirement: Double(ThreatLevel.blip.rawValue),
            reward: .loreUnlock("world_intro")
        ),
        Milestone(
            id: "threat_signal",
            type: .threat,
            title: "Getting Noticed",
            description: "Reach SIGNAL threat level",
            requirement: Double(ThreatLevel.signal.rawValue),
            reward: .loreUnlock("malus_intro")
        ),
        Milestone(
            id: "threat_target",
            type: .threat,
            title: "Target Acquired",
            description: "Reach TARGET threat level",
            requirement: Double(ThreatLevel.target.rawValue),
            reward: .credits(1000)
        ),
        Milestone(
            id: "threat_priority",
            type: .threat,
            title: "Priority Target",
            description: "Reach PRIORITY threat level",
            requirement: Double(ThreatLevel.priority.rawValue),
            reward: .loreUnlock("helix_signal_2")
        ),
        Milestone(
            id: "threat_hunted",
            type: .threat,
            title: "The Hunt Begins",
            description: "Reach HUNTED threat level",
            requirement: Double(ThreatLevel.hunted.rawValue),
            reward: .loreUnlock("malus_movement_1")
        ),
        Milestone(
            id: "threat_marked",
            type: .threat,
            title: "Marked for Death",
            description: "Reach MARKED threat level",
            requirement: Double(ThreatLevel.marked.rawValue),
            reward: .credits(10000),
            isHidden: true
        ),

        // ===== UNITS =====
        Milestone(
            id: "units_5",
            type: .units,
            title: "Building a Network",
            description: "Unlock 5 units",
            requirement: 5,
            reward: .credits(500)
        ),
        Milestone(
            id: "units_10",
            type: .units,
            title: "Hardware Collector",
            description: "Unlock 10 units",
            requirement: 10,
            reward: .credits(2500)
        ),
        Milestone(
            id: "units_15",
            type: .units,
            title: "Full Arsenal",
            description: "Unlock all 15 units",
            requirement: 15,
            reward: .credits(10000)
        ),

        // ===== UPGRADES =====
        Milestone(
            id: "upgrades_10",
            type: .upgrades,
            title: "Tinkerer",
            description: "Purchase 10 upgrades",
            requirement: 10,
            reward: .credits(200)
        ),
        Milestone(
            id: "upgrades_50",
            type: .upgrades,
            title: "Optimizer",
            description: "Purchase 50 upgrades",
            requirement: 50,
            reward: .credits(1000)
        ),
        Milestone(
            id: "upgrades_100",
            type: .upgrades,
            title: "Overclocked",
            description: "Purchase 100 upgrades",
            requirement: 100,
            reward: .credits(5000)
        ),

        // ===== TIME =====
        Milestone(
            id: "time_300",
            type: .time,
            title: "Getting Started",
            description: "Play for 5 minutes",
            requirement: 300,
            reward: .credits(50)
        ),
        Milestone(
            id: "time_3600",
            type: .time,
            title: "Dedicated",
            description: "Play for 1 hour",
            requirement: 3600,
            reward: .credits(500)
        ),
        Milestone(
            id: "time_36000",
            type: .time,
            title: "Obsessed",
            description: "Play for 10 hours",
            requirement: 36000,
            reward: .loreUnlock("team_intro")
        ),

        // ===== LORE =====
        Milestone(
            id: "lore_5",
            type: .lore,
            title: "Curious",
            description: "Collect 5 lore fragments",
            requirement: 5,
            reward: .credits(250)
        ),
        Milestone(
            id: "lore_10",
            type: .lore,
            title: "Informed",
            description: "Collect 10 lore fragments",
            requirement: 10,
            reward: .credits(1000)
        ),
        Milestone(
            id: "lore_20",
            type: .lore,
            title: "Archivist",
            description: "Collect 20 lore fragments",
            requirement: 20,
            reward: .credits(5000)
        ),

        // ===== SPECIAL =====
        Milestone(
            id: "special_first_attack",
            type: .special,
            title: "Wake Up Call",
            description: "Experience your first attack from Malus",
            requirement: 1,
            reward: .loreUnlock("intel_mission"),
            isHidden: true
        ),
        Milestone(
            id: "special_first_firewall",
            type: .special,
            title: "Defense Online",
            description: "Install your first firewall",
            requirement: 1,
            reward: .loreUnlock("intel_network")
        ),
        Milestone(
            id: "special_tier2_complete",
            type: .special,
            title: "Tier 2 Operator",
            description: "Equip a full set of Tier 2 units",
            requirement: 1,
            reward: .credits(5000),
            isHidden: true
        ),
        Milestone(
            id: "special_helix_discovered",
            type: .special,
            title: "Signal Found",
            description: "Discover Helix's signal in the mesh",
            requirement: 1,
            reward: .loreUnlock("helix_intro"),
            isHidden: true
        ),

        // ===== CAMPAIGN =====
        Milestone(
            id: "campaign_1",
            type: .campaign,
            title: "First Mission",
            description: "Complete your first campaign level",
            requirement: 1,
            reward: .credits(500)
        ),
        Milestone(
            id: "campaign_3",
            type: .campaign,
            title: "Rising Defender",
            description: "Complete 3 campaign levels",
            requirement: 3,
            reward: .credits(2500)
        ),
        Milestone(
            id: "campaign_5",
            type: .campaign,
            title: "Seasoned Operator",
            description: "Complete 5 campaign levels",
            requirement: 5,
            reward: .credits(10000)
        ),
        Milestone(
            id: "campaign_7",
            type: .campaign,
            title: "Campaign Victor",
            description: "Complete all 7 campaign levels",
            requirement: 7,
            reward: .credits(50000)
        ),

        // ===== INSANE MODE =====
        Milestone(
            id: "insane_1",
            type: .insane,
            title: "Into the Fire",
            description: "Complete your first level on Insane difficulty",
            requirement: 1,
            reward: .credits(5000)
        ),
        Milestone(
            id: "insane_3",
            type: .insane,
            title: "Forged in Chaos",
            description: "Complete 3 levels on Insane difficulty",
            requirement: 3,
            reward: .credits(25000)
        ),
        Milestone(
            id: "insane_5",
            type: .insane,
            title: "Master of Madness",
            description: "Complete 5 levels on Insane difficulty",
            requirement: 5,
            reward: .credits(100000)
        ),
        Milestone(
            id: "insane_7",
            type: .insane,
            title: "HELIX GUARDIAN",
            description: "Complete all 7 levels on Insane difficulty",
            requirement: 7,
            reward: .credits(500000),
            isHidden: true
        )
    ]

    static func milestone(withId id: String) -> Milestone? {
        allMilestones.first { $0.id == id }
    }

    static func milestones(for type: MilestoneType) -> [Milestone] {
        allMilestones.filter { $0.type == type }
    }

    static func visibleMilestones() -> [Milestone] {
        allMilestones.filter { !$0.isHidden }
    }

    static func checkProgress(state: MilestoneState) -> [Milestone] {
        // Return milestones that are newly completable
        allMilestones.filter { milestone in
            guard !state.isCompleted(milestone.id) else { return false }
            return state.progress(for: milestone) >= 1.0
        }
    }
}
