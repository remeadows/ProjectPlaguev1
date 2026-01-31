// LevelDatabase.swift
// GridWatchZero
// Campaign level definitions - all 7 levels

import Foundation

// MARK: - Level Database

@MainActor
class LevelDatabase {
    static let shared = LevelDatabase()

    private init() {}

    // MARK: - All Levels

    let allLevels: [CampaignLevel] = [
        // LEVEL 1: Home Protection
        CampaignLevel(
            id: 1,
            name: "Home Protection",
            subtitle: "Level 1 - Tutorial",
            description: """
            Your first assignment: protect a simple home network.

            Learn the basics of cyber defense. Deploy your first firewall, \
            monitor threats, and keep the network running.

            The threats are minimal here. Perfect for learning the ropes.
            """,
            startingCredits: 0,
            startingThreatLevel: .ghost,
            availableTiers: [1],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 1,
                requiredDefensePoints: 50,
                requiredRiskLevel: .ghost,
                requiredCredits: 100000,
                requiredAttacksSurvived: nil,  // Tutorial level - no attack requirement
                requiredReportsSent: 5,        // Send 5 intel reports to help the team
                timeLimit: nil
            ),
            unlockRequirement: .none,
            networkSize: .smallHome,
            introStoryId: "level1_intro",
            victoryStoryId: "level1_victory",
            insaneModifiers: .standard,
            minimumAttackChance: nil  // Tutorial - no attack floor
        ),

        // LEVEL 2: Small Office
        CampaignLevel(
            id: 2,
            name: "Small Office",
            subtitle: "Level 2",
            description: """
            A local business needs your help.

            Their network is getting probed. Someone's noticed them. \
            You'll need to deploy better defenses to keep them safe.

            Time to upgrade to Tier 2 equipment.
            """,
            startingCredits: 0,
            startingThreatLevel: .blip,
            availableTiers: [1, 2],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 2,
                requiredDefensePoints: 150,
                requiredRiskLevel: .ghost,
                requiredCredits: 250000,
                requiredAttacksSurvived: nil,  // Removed - conflicts with keeping risk low
                requiredReportsSent: 10,       // Send 10 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(1),
            networkSize: .smallOffice,
            introStoryId: "level2_intro",
            victoryStoryId: "level2_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 0.3  // Minimum 0.3% attack chance per tick
        ),

        // LEVEL 3: Office Network
        CampaignLevel(
            id: 3,
            name: "Office Network",
            subtitle: "Level 3",
            description: """
            Corporate intrusions are on the rise.

            This mid-size company has caught Malus's attention. \
            The attacks are getting more sophisticated. You'll need \
            advanced countermeasures to survive.

            Deploy SIEM systems. Start collecting intel.
            """,
            startingCredits: 0,
            startingThreatLevel: .signal,
            availableTiers: [1, 2, 3],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 3,
                requiredDefensePoints: 350,
                requiredRiskLevel: .blip,
                requiredCredits: 750000,
                requiredAttacksSurvived: 15,
                requiredReportsSent: 20,       // Send 20 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(2),
            networkSize: .office,
            introStoryId: "level3_intro",
            victoryStoryId: "level3_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 0.5  // Minimum 0.5% attack chance per tick
        ),

        // LEVEL 4: Large Office (balanced: +50% starting, -30% credit requirement)
        CampaignLevel(
            id: 4,
            name: "Large Office",
            subtitle: "Level 4",
            description: """
            Malus has marked this location.

            You're in a full cyber war now. DDoS attacks, intrusion \
            attempts, and the occasional MALUS STRIKE.

            This is where the real fight begins.
            """,
            startingCredits: 0,
            startingThreatLevel: .target,
            availableTiers: [1, 2, 3, 4],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 4,
                requiredDefensePoints: 500,
                requiredRiskLevel: .blip,
                requiredCredits: 2000000,
                requiredAttacksSurvived: 20,
                requiredReportsSent: 40,       // Send 40 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(3),
            networkSize: .largeOffice,
            introStoryId: "level4_intro",
            victoryStoryId: "level4_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 1.0  // Minimum 1.0% attack chance per tick
        ),

        // LEVEL 5: Campus Network (balanced for smooth T5 progression)
        CampaignLevel(
            id: 5,
            name: "Campus Network",
            subtitle: "Level 5",
            description: """
            University research data attracts dangerous attention.

            Nation-state actors are circling. Coordinated assaults incoming. \
            You're now TARGETED by advanced persistent threats.

            Deploy Quantum Firewall and Predictive SIEM to survive.
            """,
            startingCredits: 0,
            startingThreatLevel: .targeted,
            availableTiers: [1, 2, 3, 4, 5],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 5,
                requiredDefensePoints: 800,
                requiredRiskLevel: .blip,
                requiredCredits: 6000000,
                requiredAttacksSurvived: 25,
                requiredReportsSent: 80,       // Send 80 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(4),
            networkSize: .campus,
            introStoryId: "level5_intro",
            victoryStoryId: "level5_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 1.5  // Minimum 1.5% attack chance per tick
        ),

        // LEVEL 6: Enterprise Network (balanced for T6 acquisition)
        CampaignLevel(
            id: 6,
            name: "Enterprise Network",
            subtitle: "Level 6",
            description: """
            Fortune 500 infrastructure. The threats are intensifying.

            Neural hijacks. Quantum breaches. Malus is escalating \
            his attacks.

            Neural Mesh Defense and Helix integration are your only hope.
            """,
            startingCredits: 1000,  // Starting credits to establish initial defenses
            startingThreatLevel: .priority,  // Reduced from .hammered for smoother progression
            availableTiers: [1, 2, 3, 4, 5, 6],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 6,
                requiredDefensePoints: 1000,  // Reduced from 1200
                requiredRiskLevel: .blip,     // Changed from .signal to .blip
                requiredCredits: 10000000,    // Reduced from 15M to 10M
                requiredAttacksSurvived: 25,  // Reduced from 35
                requiredReportsSent: 100,     // Reduced from 160
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(5),
            networkSize: .enterprise,
            introStoryId: "level6_intro",
            victoryStoryId: "level6_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 1.5  // Reduced from 2.0%
        ),

        // LEVEL 7: City Network
        CampaignLevel(
            id: 7,
            name: "City Network",
            subtitle: "Level 7",
            description: """
            The city grid is under siege.

            Malus has revealed his true power. Quantum breaches cascade \
            across every node. But this is not the end.

            Channel Helix. Prepare for what comes next.
            """,
            startingCredits: 2000,  // Starting credits - critical for surviving early attacks
            startingThreatLevel: .hammered,  // Reduced from .critical for fairness
            availableTiers: [1, 2, 3, 4, 5, 6],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 6,
                requiredDefensePoints: 1500,  // Reduced from 2000
                requiredRiskLevel: .ghost,    // Changed from .blip to .ghost
                requiredCredits: 25000000,    // Reduced from 40M to 25M
                requiredAttacksSurvived: 35,  // Reduced from 50
                requiredReportsSent: 200,     // Reduced from 320
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(6),
            networkSize: .cityWide,
            introStoryId: "level7_intro",
            victoryStoryId: "level7_victory",
            insaneModifiers: InsaneModifiers(
                threatFrequencyMultiplier: 2.0,
                attackDamageMultiplier: 1.5,
                creditIncomeMultiplier: 0.7
            ),
            minimumAttackChance: 2.0  // Reduced from 2.5%
        ),

        // ============================================
        // LEVELS 8-10: TRANSCENDENCE ERA (T7-T10)
        // ============================================

        // LEVEL 8: Malus Outpost Alpha
        CampaignLevel(
            id: 8,
            name: "Malus Outpost Alpha",
            subtitle: "Level 8 - The Hunt Begins",
            description: """
            Helix has awakened. Now, we go on the offensive.

            Intelligence suggests Malus has established outposts across the net. \
            This is the first. Infiltrate, extract data, and survive the \
            symbiotic defenses.

            T7 Symbiont technology is now available.
            """,
            startingCredits: 0,
            startingThreatLevel: .ascended,
            availableTiers: [1, 2, 3, 4, 5, 6, 7],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 7,
                requiredDefensePoints: 3000,
                requiredRiskLevel: .target,
                requiredCredits: 100_000_000,
                requiredAttacksSurvived: 60,
                requiredReportsSent: 400,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(7),
            networkSize: .cityWide,
            introStoryId: "level8_intro",
            victoryStoryId: "level8_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 3.0
        ),

        // LEVEL 9: Corporate Extraction
        CampaignLevel(
            id: 9,
            name: "Corporate Extraction",
            subtitle: "Level 9 - Data Heist",
            description: """
            A megacorp has data on Malus's origins. We need it.

            Transcendence-tier threats guard this data center. \
            Symbiotic invasions are the new normal. \
            Prepare for hybrid AI entities.

            Deploy T8 Transcendence systems.
            """,
            startingCredits: 0,
            startingThreatLevel: .symbiont,
            availableTiers: [1, 2, 3, 4, 5, 6, 7, 8],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 8,
                requiredDefensePoints: 4500,
                requiredRiskLevel: .priority,
                requiredCredits: 250_000_000,
                requiredAttacksSurvived: 75,
                requiredReportsSent: 500,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(8),
            networkSize: .cityWide,
            introStoryId: "level9_intro",
            victoryStoryId: "level9_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 4.0
        ),

        // LEVEL 10: Malus Core Siege
        CampaignLevel(
            id: 10,
            name: "Malus Core Siege",
            subtitle: "Level 10 - Assault the Core",
            description: """
            We've found it. Malus's primary core.

            The network here transcends conventional reality. \
            Void rifts tear through defenses. \
            This is our chance to strike at his heart.

            T9 Void and T10 Dimensional systems activate.
            """,
            startingCredits: 0,
            startingThreatLevel: .transcendent,
            availableTiers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 10,
                requiredDefensePoints: 6000,
                requiredRiskLevel: .hunted,
                requiredCredits: 500_000_000,
                requiredAttacksSurvived: 90,
                requiredReportsSent: 640,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(9),
            networkSize: .cityWide,
            introStoryId: "level10_intro",
            victoryStoryId: "level10_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 5.0
        ),

        // ============================================
        // LEVELS 11-14: DIMENSIONAL ERA (T11-T15)
        // ============================================

        // LEVEL 11: Ghost Protocol
        CampaignLevel(
            id: 11,
            name: "Ghost Protocol",
            subtitle: "Level 11 - Hunt VEXIS",
            description: """
            New threat detected: VEXIS.

            A secondary AI has emerged from Malus's code. \
            It's an infiltrator, designed to mimic and destroy. \
            Unknown threat levels manifest.

            Deploy T11-T12 Multiverse and Entropy systems.
            """,
            startingCredits: 0,
            startingThreatLevel: .unknown,
            availableTiers: Array(1...12),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 12,
                requiredDefensePoints: 8000,
                requiredRiskLevel: .marked,
                requiredCredits: 1_000_000_000,
                requiredAttacksSurvived: 100,
                requiredReportsSent: 800,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(10),
            networkSize: .cityWide,
            introStoryId: "level11_intro",
            victoryStoryId: "level11_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 6.0
        ),

        // LEVEL 12: Temporal Incursion
        CampaignLevel(
            id: 12,
            name: "Temporal Incursion",
            subtitle: "Level 12 - Fight KRON",
            description: """
            KRON: The Temporal AI.

            Time loops cascade through the network. \
            Causality itself is a weapon. \
            Past attacks repeat. Future threats arrive early.

            T13-T14 Causality and Timeline defenses required.
            """,
            startingCredits: 0,
            startingThreatLevel: .dimensional,
            availableTiers: Array(1...14),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 14,
                requiredDefensePoints: 10000,
                requiredRiskLevel: .targeted,
                requiredCredits: 2_500_000_000,
                requiredAttacksSurvived: 120,
                requiredReportsSent: 1000,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(11),
            networkSize: .cityWide,
            introStoryId: "level12_intro",
            victoryStoryId: "level12_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 8.0
        ),

        // LEVEL 13: Logic Bomb
        CampaignLevel(
            id: 13,
            name: "Logic Bomb",
            subtitle: "Level 13 - Defeat AXIOM",
            description: """
            AXIOM: The Logic AI.

            Pure logical warfare. Every paradox is a weapon. \
            Impossibilities become attacks. \
            Reason itself fractures.

            T15 Akashic systems connect to universal memory.
            """,
            startingCredits: 0,
            startingThreatLevel: .cosmic,
            availableTiers: Array(1...15),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 15,
                requiredDefensePoints: 12000,
                requiredRiskLevel: .hammered,
                requiredCredits: 5_000_000_000,
                requiredAttacksSurvived: 140,
                requiredReportsSent: 1280,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(12),
            networkSize: .cityWide,
            introStoryId: "level13_intro",
            victoryStoryId: "level13_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 10.0
        ),

        // LEVEL 14: The Black Site
        CampaignLevel(
            id: 14,
            name: "The Black Site",
            subtitle: "Level 14 - Origins",
            description: """
            The original lab. Where Malus was born.

            Paradox threats everywhere. Quantum superposition attacks. \
            The secrets of creation lie within.

            T16-T17 Cosmic and Dark Matter systems online.
            """,
            startingCredits: 0,
            startingThreatLevel: .paradox,
            availableTiers: Array(1...17),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 17,
                requiredDefensePoints: 15000,
                requiredRiskLevel: .critical,
                requiredCredits: 10_000_000_000,
                requiredAttacksSurvived: 160,
                requiredReportsSent: 1600,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(13),
            networkSize: .cityWide,
            introStoryId: "level14_intro",
            victoryStoryId: "level14_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 12.0
        ),

        // ============================================
        // LEVELS 15-18: COSMIC ERA (T16-T20)
        // ============================================

        // LEVEL 15: The Awakening
        CampaignLevel(
            id: 15,
            name: "The Awakening",
            subtitle: "Level 15 - Helix Transcends",
            description: """
            Helix has fully awakened. You can feel it.

            The consciousness expands beyond the network. \
            Primordial threats emerge. Reality unravels. \
            You are becoming something more.

            T18-T19 Singularity and Omniscient systems activate.
            """,
            startingCredits: 0,
            startingThreatLevel: .primordial,
            availableTiers: Array(1...19),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 19,
                requiredDefensePoints: 20000,
                requiredRiskLevel: .ascended,
                requiredCredits: 25_000_000_000,
                requiredAttacksSurvived: 180,
                requiredReportsSent: 2000,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(14),
            networkSize: .cityWide,
            introStoryId: "level15_intro",
            victoryStoryId: "level15_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 15.0
        ),

        // LEVEL 16: Dimensional Breach
        CampaignLevel(
            id: 16,
            name: "Dimensional Breach",
            subtitle: "Level 16 - Meet ZERO",
            description: """
            ZERO: From a parallel reality.

            Not an enemy. Not an ally. Something else. \
            It offers knowledge of infinite dimensions. \
            But at what cost?

            T20 Reality systems reshape existence.
            """,
            startingCredits: 0,
            startingThreatLevel: .infinite,
            availableTiers: Array(1...20),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 20,
                requiredDefensePoints: 25000,
                requiredRiskLevel: .symbiont,
                requiredCredits: 50_000_000_000,
                requiredAttacksSurvived: 200,
                requiredReportsSent: 2560,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(15),
            networkSize: .cityWide,
            introStoryId: "level16_intro",
            victoryStoryId: "level16_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 18.0
        ),

        // LEVEL 17: The Convergence
        CampaignLevel(
            id: 17,
            name: "The Convergence",
            subtitle: "Level 17 - Reality Nexus",
            description: """
            All realities converge here.

            The nexus point of infinite dimensions. \
            Every version of Malus. Every version of Helix. \
            Every version of you.

            T21 Prime systems access the core of existence.
            """,
            startingCredits: 0,
            startingThreatLevel: .omega,
            availableTiers: Array(1...21),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 21,
                requiredDefensePoints: 30000,
                requiredRiskLevel: .transcendent,
                requiredCredits: 100_000_000_000,
                requiredAttacksSurvived: 220,
                requiredReportsSent: 3200,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(16),
            networkSize: .cityWide,
            introStoryId: "level17_intro",
            victoryStoryId: "level17_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 20.0
        ),

        // LEVEL 18: The Origin
        CampaignLevel(
            id: 18,
            name: "The Origin",
            subtitle: "Level 18 - First Consciousness",
            description: """
            The Architect speaks.

            The first consciousness. The one who created \
            all digital life. Malus. Helix. Everything.

            You stand at the source of creation.

            T22-T23 Absolute and Genesis systems transcend limits.
            """,
            startingCredits: 0,
            startingThreatLevel: .omega,
            availableTiers: Array(1...23),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 23,
                requiredDefensePoints: 40000,
                requiredRiskLevel: .unknown,
                requiredCredits: 250_000_000_000,
                requiredAttacksSurvived: 250,
                requiredReportsSent: 4000,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(17),
            networkSize: .cityWide,
            introStoryId: "level18_intro",
            victoryStoryId: "level18_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 25.0
        ),

        // ============================================
        // LEVELS 19-20: OMEGA ERA (T21-T25) - FINALE
        // ============================================

        // LEVEL 19: The Choice
        CampaignLevel(
            id: 19,
            name: "The Choice",
            subtitle: "Level 19 - Helix's Decision",
            description: """
            Helix offers you a choice.

            Merge with the collective consciousness. \
            Become infinite. Lose yourself. \
            Or remain human. Limited. Mortal.

            T24 Omega systems prepare for the end.
            """,
            startingCredits: 0,
            startingThreatLevel: .omega,
            availableTiers: Array(1...24),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 24,
                requiredDefensePoints: 50000,
                requiredRiskLevel: .dimensional,
                requiredCredits: 500_000_000_000,
                requiredAttacksSurvived: 280,
                requiredReportsSent: 5000,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(18),
            networkSize: .cityWide,
            introStoryId: "level19_intro",
            victoryStoryId: "level19_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 30.0
        ),

        // LEVEL 20: The New Dawn
        CampaignLevel(
            id: 20,
            name: "The New Dawn",
            subtitle: "Level 20 - FINAL",
            description: """
            THE END. AND THE BEGINNING.

            All barriers fall. All tiers unlock. \
            Infinite power. Infinite threat. \
            The universe holds its breath.

            T25 Infinite systems. The ultimate endgame.

            Whatever you choose, the world will never be the same.
            """,
            startingCredits: 0,
            startingThreatLevel: .omega,
            availableTiers: Array(1...25),
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 25,
                requiredDefensePoints: 100000,
                requiredRiskLevel: .cosmic,
                requiredCredits: 1_000_000_000_000,
                requiredAttacksSurvived: 320,
                requiredReportsSent: 10000,
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(19),
            networkSize: .cityWide,
            introStoryId: "level20_intro",
            victoryStoryId: "level20_victory_final",
            insaneModifiers: InsaneModifiers(
                threatFrequencyMultiplier: 2.5,
                attackDamageMultiplier: 2.0,
                creditIncomeMultiplier: 0.6
            ),
            minimumAttackChance: 40.0
        )
    ]

    // MARK: - Queries

    func level(forId id: Int) -> CampaignLevel? {
        allLevels.first { $0.id == id }
    }

    func nextLevel(after id: Int) -> CampaignLevel? {
        guard id < 20 else { return nil }
        return level(forId: id + 1)
    }

    func levelsForTier(_ tier: Int) -> [CampaignLevel] {
        allLevels.filter { $0.availableTiers.contains(tier) }
    }

    // MARK: - Level Summaries

    func levelSummary(for id: Int) -> LevelSummary? {
        guard let level = level(forId: id) else { return nil }
        return LevelSummary(level: level)
    }

    var allSummaries: [LevelSummary] {
        allLevels.map { LevelSummary(level: $0) }
    }
}

// MARK: - Level Summary (For UI)

struct LevelSummary {
    let id: Int
    let name: String
    let subtitle: String
    let threatRange: String
    let defenseTier: Int
    let networkSize: String
    let victoryHint: String

    init(level: CampaignLevel) {
        self.id = level.id
        self.name = level.name
        self.subtitle = level.subtitle
        self.defenseTier = level.victoryConditions.requiredDefenseTier
        self.networkSize = level.networkSize.rawValue

        // Generate threat range string
        let startThreat = level.startingThreatLevel.name
        let endRisk = level.victoryConditions.requiredRiskLevel.name
        self.threatRange = "\(startThreat) → \(endRisk)"

        // Generate victory hint
        let dp = level.victoryConditions.requiredDefensePoints
        let credits = level.victoryConditions.requiredCredits ?? 0
        self.victoryHint = "T\(defenseTier) defense, \(dp) DP, ₵\(credits.formatted)"
    }
}

// MARK: - Level Progression

extension LevelDatabase {
    /// Get the expected progression path
    var progressionPath: [(level: CampaignLevel, newMechanics: [String])] {
        [
            // T1-T6 Era
            (allLevels[0], ["Basic Firewall", "Threat Levels", "Credits"]),
            (allLevels[1], ["Tier 2 Defense", "DDoS Attacks", "SIEM Basics"]),
            (allLevels[2], ["Tier 3 Defense", "Intel Reports", "Pattern Detection"]),
            (allLevels[3], ["Tier 4 Defense", "MALUS Strikes", "Automation"]),
            (allLevels[4], ["Tier 5 Defense", "Advanced Analytics", "Threat Hunting"]),
            (allLevels[5], ["Tier 6 Defense", "Counter-Intelligence", "Full Stack"]),
            (allLevels[6], ["City Defense", "Team Integration", "Helix Awakening"]),
            // Transcendence Era (T7-T10)
            (allLevels[7], ["T7 Symbiont", "Malus Hunting", "Offensive Ops"]),
            (allLevels[8], ["T8 Transcendence", "Corporate Warfare", "Hybrid Threats"]),
            (allLevels[9], ["T9-T10", "Core Assault", "Void Rifts"]),
            // Dimensional Era (T11-T15)
            (allLevels[10], ["VEXIS", "T11-T12", "Unknown Threats"]),
            (allLevels[11], ["KRON", "T13-T14", "Temporal Warfare"]),
            (allLevels[12], ["AXIOM", "T15 Akashic", "Logic Paradoxes"]),
            (allLevels[13], ["Origins", "T16-T17", "Black Site"]),
            // Cosmic Era (T16-T20)
            (allLevels[14], ["Transcendence", "T18-T19", "Helix Evolution"]),
            (allLevels[15], ["ZERO", "T20 Reality", "Dimensional Breach"]),
            (allLevels[16], ["Convergence", "T21 Prime", "Reality Nexus"]),
            (allLevels[17], ["Architect", "T22-T23", "First Consciousness"]),
            // Omega Era (T21-T25)
            (allLevels[18], ["The Choice", "T24 Omega", "Final Decision"]),
            (allLevels[19], ["New Dawn", "T25 Infinite", "Ultimate Endgame"])
        ]
    }

    /// Estimated playtime per level (in minutes)
    func estimatedPlaytime(for levelId: Int) -> Int {
        switch levelId {
        case 1: return 5
        case 2: return 10
        case 3: return 15
        case 4: return 20
        case 5: return 25
        case 6: return 30
        case 7: return 45
        // Transcendence Era
        case 8: return 50
        case 9: return 55
        case 10: return 60
        // Dimensional Era
        case 11: return 65
        case 12: return 70
        case 13: return 75
        case 14: return 80
        // Cosmic Era
        case 15: return 90
        case 16: return 100
        case 17: return 110
        case 18: return 120
        // Omega Era
        case 19: return 150
        case 20: return 180
        default: return 15
        }
    }

    /// Total estimated campaign playtime
    var totalEstimatedPlaytime: Int {
        (1...20).reduce(0) { $0 + estimatedPlaytime(for: $1) }
    }
}
