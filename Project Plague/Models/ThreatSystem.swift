// ThreatSystem.swift
// GridWatchZero
// Threat level tracking and attack mechanics

import Foundation

// MARK: - Threat Level

enum ThreatLevel: Int, Codable, CaseIterable, Comparable {
    // T1-T6 Threat Levels (Campaign 1-7)
    case ghost = 1       // Starting - invisible
    case blip = 2        // Minor detection
    case signal = 3      // On the radar
    case target = 4      // Active interest
    case priority = 5    // High value target
    case hunted = 6      // Malus actively searching
    case marked = 7      // Malus locked on
    case targeted = 8    // Coordinated attack incoming
    case hammered = 9    // Sustained assault
    case critical = 10   // City-level threat response
    // T7-T10 Threat Levels (Campaign 8-10) - Transcendence Era
    case ascended = 11   // Post-Helix awakening threats
    case symbiont = 12   // Hybrid AI threats
    case transcendent = 13 // Beyond conventional threats
    // T11-T15 Threat Levels (Campaign 11-14) - Dimensional Era
    case unknown = 14    // Reality unstable
    case dimensional = 15 // Threats from other dimensions
    case cosmic = 16     // Universal-scale threats
    // T16-T20 Threat Levels (Campaign 15-18) - Cosmic Era
    case paradox = 17    // Quantum superposition threats
    case primordial = 18 // First threats from the origin
    case infinite = 19   // Limitless threat capacity
    // T21-T25 Threat Levels (Campaign 19-20) - Omega Era
    case omega = 20      // The final threat level

    static func < (lhs: ThreatLevel, rhs: ThreatLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var name: String {
        switch self {
        case .ghost: return "GHOST"
        case .blip: return "BLIP"
        case .signal: return "SIGNAL"
        case .target: return "TARGET"
        case .priority: return "PRIORITY"
        case .hunted: return "HUNTED"
        case .marked: return "MARKED"
        case .targeted: return "TARGETED"
        case .hammered: return "HAMMERED"
        case .critical: return "CRITICAL"
        case .ascended: return "ASCENDED"
        case .symbiont: return "SYMBIONT"
        case .transcendent: return "TRANSCENDENT"
        case .unknown: return "UNKNOWN"
        case .dimensional: return "DIMENSIONAL"
        case .cosmic: return "COSMIC"
        case .paradox: return "PARADOX"
        case .primordial: return "PRIMORDIAL"
        case .infinite: return "INFINITE"
        case .omega: return "OMEGA"
        }
    }

    var description: String {
        switch self {
        case .ghost: return "Invisible to threat actors"
        case .blip: return "Minor anomaly detected"
        case .signal: return "You're on someone's radar"
        case .target: return "Active interest in your operation"
        case .priority: return "High-value target designation"
        case .hunted: return "Malus is searching for you"
        case .marked: return "Malus has locked onto your signature"
        case .targeted: return "Coordinated strike inbound"
        case .hammered: return "Under sustained heavy assault"
        case .critical: return "City-wide threat response activated"
        case .ascended: return "Post-Helix awakening threats manifest"
        case .symbiont: return "Hybrid AI entities hunting you"
        case .transcendent: return "Beyond conventional threat classification"
        case .unknown: return "Reality itself is unstable"
        case .dimensional: return "Threats from parallel dimensions"
        case .cosmic: return "Universal-scale threat response"
        case .paradox: return "Quantum superposition of threats"
        case .primordial: return "First threats from the origin point"
        case .infinite: return "Limitless threat capacity engaged"
        case .omega: return "THE FINAL THREAT LEVEL"
        }
    }

    var color: String {
        switch self {
        case .ghost: return "dimGreen"
        case .blip: return "neonGreen"
        case .signal: return "neonCyan"
        case .target: return "neonAmber"
        case .priority: return "neonAmber"
        case .hunted: return "neonRed"
        case .marked: return "neonRed"
        case .targeted: return "neonRed"
        case .hammered: return "neonRed"
        case .critical: return "neonRed"
        // New threat level colors
        case .ascended: return "transcendencePurple"
        case .symbiont: return "transcendencePurple"
        case .transcendent: return "voidBlue"
        case .unknown: return "dimensionalGold"
        case .dimensional: return "multiversePink"
        case .cosmic: return "cosmicSilver"
        case .paradox: return "darkMatterPurple"
        case .primordial: return "singularityWhite"
        case .infinite: return "infiniteGold"
        case .omega: return "omegaBlack"
        }
    }

    /// Base chance of attack per tick (percentage)
    /// Even at GHOST, there's light probing/port scanning - the network is never truly safe
    /// NOTE: Defense no longer reduces attack frequency - it reduces DAMAGE instead
    /// Balanced for challenging but fair progression through all threat levels
    var attackChancePerTick: Double {
        switch self {
        case .ghost: return 0.2     // Light probing
        case .blip: return 0.5
        case .signal: return 1.0
        case .target: return 2.0
        case .priority: return 3.5
        case .hunted: return 5.0
        case .marked: return 8.0
        case .targeted: return 12.0
        case .hammered: return 18.0
        case .critical: return 25.0
        // Endgame threat levels (T7+)
        case .ascended: return 30.0
        case .symbiont: return 35.0
        case .transcendent: return 40.0
        case .unknown: return 45.0
        case .dimensional: return 50.0
        case .cosmic: return 55.0
        case .paradox: return 60.0
        case .primordial: return 65.0
        case .infinite: return 70.0
        case .omega: return 80.0  // Constant assault at omega level
        }
    }

    /// Multiplier for attack severity (damage scaling)
    /// Balanced so late-game is challenging but survivable with proper defense
    var severityMultiplier: Double {
        switch self {
        case .ghost: return 0.3     // Very light damage from probing attacks
        case .blip: return 0.5
        case .signal: return 1.0
        case .target: return 1.5
        case .priority: return 2.0
        case .hunted: return 2.5
        case .marked: return 4.0
        case .targeted: return 5.5
        case .hammered: return 7.5
        case .critical: return 10.0
        // Endgame severity (balanced for T7+ defense apps)
        case .ascended: return 12.0
        case .symbiont: return 15.0
        case .transcendent: return 18.0
        case .unknown: return 22.0
        case .dimensional: return 27.0
        case .cosmic: return 33.0
        case .paradox: return 40.0
        case .primordial: return 50.0
        case .infinite: return 65.0
        case .omega: return 100.0  // Ultimate threat severity
        }
    }

    static func forCredits(_ totalCredits: Double, hasT2: Bool = false, hasT3: Bool = false, hasT4: Bool = false, hasT5: Bool = false, hasT6: Bool = false, campaignLevel: Int = 1) -> ThreatLevel {
        // Omega era (Campaign 19-20, T21-25)
        if campaignLevel >= 20 || totalCredits >= 1_000_000_000_000_000_000 { return .omega }       // 1 Quintillion
        if campaignLevel >= 19 || totalCredits >= 100_000_000_000_000_000 { return .infinite }     // 100 Quadrillion
        // Cosmic era (Campaign 15-18, T16-20)
        if campaignLevel >= 18 || totalCredits >= 10_000_000_000_000_000 { return .primordial }    // 10 Quadrillion
        if campaignLevel >= 17 || totalCredits >= 1_000_000_000_000_000 { return .paradox }        // 1 Quadrillion
        if campaignLevel >= 16 || totalCredits >= 100_000_000_000_000 { return .cosmic }           // 100 Trillion
        if campaignLevel >= 15 || totalCredits >= 10_000_000_000_000 { return .dimensional }       // 10 Trillion
        // Dimensional era (Campaign 11-14, T11-15)
        if campaignLevel >= 14 || totalCredits >= 1_000_000_000_000 { return .unknown }            // 1 Trillion
        if campaignLevel >= 13 || totalCredits >= 500_000_000_000 { return .transcendent }         // 500 Billion
        if campaignLevel >= 12 || totalCredits >= 200_000_000_000 { return .symbiont }             // 200 Billion
        if campaignLevel >= 11 || totalCredits >= 100_000_000_000 { return .ascended }             // 100 Billion
        // Original threat levels (Campaign 1-10, T1-T6)
        if hasT6 || campaignLevel >= 10 || totalCredits >= 50_000_000_000 { return .critical }     // 50 Billion
        if hasT5 || campaignLevel >= 9 || totalCredits >= 10_000_000_000 { return .hammered }      // 10 Billion
        if campaignLevel >= 8 || totalCredits >= 1_000_000_000 { return .targeted }                // 1 Billion
        if hasT4 || hasT3 || totalCredits >= 1_000_000 { return .marked }
        if totalCredits >= 250_000 { return .hunted }
        if totalCredits >= 50_000 { return .priority }
        if hasT2 || totalCredits >= 10_000 { return .target }
        if totalCredits >= 1_000 { return .signal }
        if totalCredits >= 100 { return .blip }
        return .ghost
    }
}

// MARK: - NetDefense Level

/// Defense rating that counters threat level to determine actual risk
enum NetDefenseLevel: Int, Codable, CaseIterable, Comparable {
    case exposed = 0     // No defense
    case minimal = 1     // Basic firewall
    case basic = 2       // Upgraded firewall
    case moderate = 3    // Good defense
    case strong = 4      // Strong defense
    case fortified = 5   // Near-maximum protection
    case hardened = 6    // Military-grade protection
    case quantum = 7     // Quantum-encrypted defense (T5)
    case neural = 8      // Neural mesh protection (T5+)
    case helix = 9       // Helix-integrated defense (T6)

    static func < (lhs: NetDefenseLevel, rhs: NetDefenseLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var name: String {
        switch self {
        case .exposed: return "EXPOSED"
        case .minimal: return "MINIMAL"
        case .basic: return "BASIC"
        case .moderate: return "MODERATE"
        case .strong: return "STRONG"
        case .fortified: return "FORTIFIED"
        case .hardened: return "HARDENED"
        case .quantum: return "QUANTUM"
        case .neural: return "NEURAL"
        case .helix: return "HELIX"
        }
    }

    var description: String {
        switch self {
        case .exposed: return "No active defenses"
        case .minimal: return "Basic firewall protection"
        case .basic: return "Standard security measures"
        case .moderate: return "Improved defensive posture"
        case .strong: return "Robust security infrastructure"
        case .fortified: return "Advanced threat mitigation"
        case .hardened: return "Military-grade protection"
        case .quantum: return "Quantum-encrypted security mesh"
        case .neural: return "Adaptive neural defense network"
        case .helix: return "Helix consciousness protection"
        }
    }

    /// How many threat levels this defense can reduce (for risk display only)
    /// NOTE: This no longer affects attack FREQUENCY - only used for risk level display
    var threatReduction: Int {
        return rawValue
    }

    /// Damage reduction multiplier from defense level
    /// Higher defense = attacks hurt less (but still happen at same frequency)
    /// Formula: 8% reduction per level, max 72% at HELIX (level 9)
    var damageReductionMultiplier: Double {
        let reduction = Double(rawValue) * 0.08
        return min(0.72, reduction)  // Cap at 72% reduction
    }

    /// Calculate defense level based on firewall stats
    static func calculate(
        firewallTier: Int,
        firewallLevel: Int,
        firewallHealthPercent: Double
    ) -> NetDefenseLevel {
        // No firewall = exposed
        guard firewallTier > 0 else { return .exposed }

        // Base score from firewall tier (1-6 tiers available)
        var score = firewallTier

        // Bonus from firewall level (every 5 levels = +1)
        score += firewallLevel / 5

        // Penalty if firewall is damaged (below 50% = -1, below 25% = -2)
        if firewallHealthPercent < 0.25 {
            score -= 2
        } else if firewallHealthPercent < 0.5 {
            score -= 1
        }

        // Clamp to valid range (0-9)
        let clampedScore = max(0, min(9, score))
        return NetDefenseLevel(rawValue: clampedScore) ?? .exposed
    }
}

// MARK: - Risk Level (Effective Threat)

/// Actual risk = Threat - NetDefense (clamped to minimum GHOST)
/// NOTE: Defense now reduces DAMAGE, not attack frequency
/// - effectiveRiskLevel is used for UI display (shows risk reduction)
/// - attackChancePerTick uses RAW threat (attacks still happen)
/// - damageReduction reduces how much attacks hurt
struct RiskCalculation {
    let threatLevel: ThreatLevel
    let netDefenseLevel: NetDefenseLevel
    let effectiveRiskLevel: ThreatLevel

    /// Attack chance uses RAW threat level, not effective risk
    /// Defense reduces damage, not frequency - attacks keep coming!
    var attackChancePerTick: Double {
        threatLevel.attackChancePerTick
    }

    /// Severity uses raw threat level (damage reduction applied separately)
    var severityMultiplier: Double {
        threatLevel.severityMultiplier
    }

    /// Damage reduction from defense level (applied to all attack damage)
    var damageReduction: Double {
        netDefenseLevel.damageReductionMultiplier
    }

    init(threat: ThreatLevel, defense: NetDefenseLevel) {
        self.threatLevel = threat
        self.netDefenseLevel = defense

        // Calculate effective risk: threat level - defense reduction
        // This is now primarily for UI display purposes
        let effectiveRawValue = max(1, threat.rawValue - defense.threatReduction)
        self.effectiveRiskLevel = ThreatLevel(rawValue: effectiveRawValue) ?? .ghost
    }
}

// MARK: - Attack Types

enum AttackType: String, Codable, CaseIterable {
    // Original attack types (T1-T6)
    case probe = "PROBE"
    case ddos = "DDoS"
    case intrusion = "INTRUSION"
    case malusStrike = "MALUS_STRIKE"
    case coordinatedAssault = "COORDINATED_ASSAULT"
    case neuralHijack = "NEURAL_HIJACK"
    case quantumBreach = "QUANTUM_BREACH"
    // Transcendence era attacks (T7-T10)
    case symbioticInvasion = "SYMBIOTIC_INVASION"
    case voidRift = "VOID_RIFT"
    // Dimensional era attacks (T11-T15)
    case dimensionalTear = "DIMENSIONAL_TEAR"
    case causalityLoop = "CAUSALITY_LOOP"
    case timelineCollapse = "TIMELINE_COLLAPSE"
    // Cosmic era attacks (T16-T20)
    case singularityBomb = "SINGULARITY_BOMB"
    case realityUnravel = "REALITY_UNRAVEL"
    // Omega era attacks (T21-T25)
    case omegaStrike = "OMEGA_STRIKE"
    case existentialThreat = "EXISTENTIAL_THREAT"

    var displayName: String {
        switch self {
        case .probe: return "Network Probe"
        case .ddos: return "DDoS Attack"
        case .intrusion: return "Intrusion Attempt"
        case .malusStrike: return "MALUS STRIKE"
        case .coordinatedAssault: return "COORDINATED ASSAULT"
        case .neuralHijack: return "NEURAL HIJACK"
        case .quantumBreach: return "QUANTUM BREACH"
        case .symbioticInvasion: return "SYMBIOTIC INVASION"
        case .voidRift: return "VOID RIFT"
        case .dimensionalTear: return "DIMENSIONAL TEAR"
        case .causalityLoop: return "CAUSALITY LOOP"
        case .timelineCollapse: return "TIMELINE COLLAPSE"
        case .singularityBomb: return "SINGULARITY BOMB"
        case .realityUnravel: return "REALITY UNRAVEL"
        case .omegaStrike: return "OMEGA STRIKE"
        case .existentialThreat: return "EXISTENTIAL THREAT"
        }
    }

    var description: String {
        switch self {
        case .probe: return "Scanning your network..."
        case .ddos: return "Flooding your bandwidth..."
        case .intrusion: return "Attempting system access..."
        case .malusStrike: return ">> MALUS HAS FOUND YOU <<"
        case .coordinatedAssault: return ">> MULTIPLE ATTACK VECTORS <<"
        case .neuralHijack: return ">> AI OVERRIDE DETECTED <<"
        case .quantumBreach: return ">> QUANTUM DECRYPTION IN PROGRESS <<"
        case .symbioticInvasion: return ">> HYBRID ENTITIES MERGING WITH SYSTEMS <<"
        case .voidRift: return ">> REALITY FRACTURE DETECTED <<"
        case .dimensionalTear: return ">> PARALLEL UNIVERSE INTRUSION <<"
        case .causalityLoop: return ">> TEMPORAL PARADOX FORMING <<"
        case .timelineCollapse: return ">> TIMELINE DESTABILIZING <<"
        case .singularityBomb: return ">> GRAVITATIONAL ANOMALY DETECTED <<"
        case .realityUnravel: return ">> EXISTENCE MATRICES FAILING <<"
        case .omegaStrike: return ">> THE END IS HERE <<"
        case .existentialThreat: return ">> BEYOND COMPREHENSION <<"
        }
    }

    var icon: String {
        switch self {
        case .probe: return "eye.fill"
        case .ddos: return "bolt.fill"
        case .intrusion: return "lock.open.fill"
        case .malusStrike: return "exclamationmark.triangle.fill"
        case .coordinatedAssault: return "arrow.triangle.merge"
        case .neuralHijack: return "brain.head.profile"
        case .quantumBreach: return "atom"
        case .symbioticInvasion: return "allergens"
        case .voidRift: return "tornado"
        case .dimensionalTear: return "rectangle.on.rectangle.angled"
        case .causalityLoop: return "arrow.2.circlepath"
        case .timelineCollapse: return "clock.arrow.circlepath"
        case .singularityBomb: return "circle.dashed.inset.filled"
        case .realityUnravel: return "waveform.path.ecg"
        case .omegaStrike: return "burst.fill"
        case .existentialThreat: return "infinity"
        }
    }

    /// Duration in ticks
    var baseDuration: Int {
        switch self {
        case .probe: return 3
        case .ddos: return 8
        case .intrusion: return 5
        case .malusStrike: return 15
        case .coordinatedAssault: return 20
        case .neuralHijack: return 12
        case .quantumBreach: return 25
        case .symbioticInvasion: return 18
        case .voidRift: return 22
        case .dimensionalTear: return 30
        case .causalityLoop: return 28
        case .timelineCollapse: return 35
        case .singularityBomb: return 40
        case .realityUnravel: return 45
        case .omegaStrike: return 50
        case .existentialThreat: return 60
        }
    }

    /// Minimum threat level required
    var minThreatLevel: ThreatLevel {
        switch self {
        case .probe: return .blip
        case .ddos: return .signal
        case .intrusion: return .target
        case .malusStrike: return .hunted
        case .coordinatedAssault: return .targeted
        case .neuralHijack: return .hammered
        case .quantumBreach: return .critical
        case .symbioticInvasion: return .ascended
        case .voidRift: return .transcendent
        case .dimensionalTear: return .unknown
        case .causalityLoop: return .dimensional
        case .timelineCollapse: return .cosmic
        case .singularityBomb: return .paradox
        case .realityUnravel: return .primordial
        case .omegaStrike: return .infinite
        case .existentialThreat: return .omega
        }
    }

    /// Weight for random selection (higher = more common)
    var weight: Int {
        switch self {
        case .probe: return 50
        case .ddos: return 30
        case .intrusion: return 15
        case .malusStrike: return 5
        case .coordinatedAssault: return 8
        case .neuralHijack: return 4
        case .quantumBreach: return 2
        case .symbioticInvasion: return 6
        case .voidRift: return 4
        case .dimensionalTear: return 5
        case .causalityLoop: return 3
        case .timelineCollapse: return 2
        case .singularityBomb: return 2
        case .realityUnravel: return 1
        case .omegaStrike: return 1
        case .existentialThreat: return 1
        }
    }
}

// MARK: - Attack Instance

struct Attack: Identifiable, Codable {
    let id: UUID
    let type: AttackType
    let severity: Double      // 0.5 - 3.0 multiplier
    let startTick: Int
    let duration: Int
    var ticksRemaining: Int
    var damageDealt: Double = 0
    var blocked: Double = 0

    var isActive: Bool { ticksRemaining > 0 }
    var progress: Double { 1.0 - (Double(ticksRemaining) / Double(duration)) }

    init(type: AttackType, severity: Double, startTick: Int) {
        self.id = UUID()
        self.type = type
        self.severity = severity
        self.startTick = startTick
        self.duration = type.baseDuration
        self.ticksRemaining = type.baseDuration
    }

    /// Calculate damage for this tick
    /// - Parameter playerIncomePerTick: Current player income for scaling (optional)
    func damagePerTick(playerIncomePerTick: Double = 0) -> AttackDamage {
        // Income-based scaling: attacks scale to remain threatening
        // Base scaling: 1.0 at 10 credits/tick, scales up with income
        let incomeScale = max(1.0, playerIncomePerTick / 10.0)
        // Cap the scaling to prevent absurd damage at high incomes
        let cappedScale = min(incomeScale, 100.0)  // Higher cap for endgame attacks
        // Blend: 70% base damage + 30% income-scaled damage
        let effectiveScale = 0.7 + (0.3 * cappedScale)

        switch type {
        case .probe:
            // Probes steal credits (scales with income to stay relevant)
            let baseDrain = 5 * severity
            return AttackDamage(creditDrain: baseDrain * effectiveScale)

        case .ddos:
            // DDoS reduces bandwidth by percentage (doesn't need income scaling)
            return AttackDamage(bandwidthReduction: 0.3 * severity)

        case .intrusion:
            // Intrusions steal credits and can disable nodes
            let baseDrain = 20 * severity
            return AttackDamage(creditDrain: baseDrain * effectiveScale, nodeDisableChance: 0.1 * severity)

        case .malusStrike:
            // Malus hits everything hard (scales with income)
            let baseDrain = 50 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.5 * severity,
                nodeDisableChance: 0.2 * severity
            )

        case .coordinatedAssault:
            // Multi-vector attack: hits credits, bandwidth, and processing
            let baseDrain = 100 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.4 * severity,
                nodeDisableChance: 0.15 * severity,
                processingReduction: 0.3 * severity
            )

        case .neuralHijack:
            // AI-targeted attack: heavy processing reduction, node hijack
            let baseDrain = 75 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                nodeDisableChance: 0.3 * severity,
                processingReduction: 0.5 * severity
            )

        case .quantumBreach:
            // Ultimate T1-6 attack: devastating across all vectors
            let baseDrain = 200 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.6 * severity,
                nodeDisableChance: 0.25 * severity,
                processingReduction: 0.4 * severity
            )

        // Transcendence era attacks (T7-T10)
        case .symbioticInvasion:
            let baseDrain = 300 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.5 * severity,
                nodeDisableChance: 0.35 * severity,
                processingReduction: 0.45 * severity
            )

        case .voidRift:
            let baseDrain = 400 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.65 * severity,
                nodeDisableChance: 0.3 * severity,
                processingReduction: 0.5 * severity
            )

        // Dimensional era attacks (T11-T15)
        case .dimensionalTear:
            let baseDrain = 500 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.7 * severity,
                nodeDisableChance: 0.4 * severity,
                processingReduction: 0.55 * severity
            )

        case .causalityLoop:
            // Loops back damage, heavy credit drain
            let baseDrain = 600 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.5 * severity,
                nodeDisableChance: 0.45 * severity,
                processingReduction: 0.6 * severity
            )

        case .timelineCollapse:
            let baseDrain = 800 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.75 * severity,
                nodeDisableChance: 0.5 * severity,
                processingReduction: 0.65 * severity
            )

        // Cosmic era attacks (T16-T20)
        case .singularityBomb:
            let baseDrain = 1000 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.8 * severity,
                nodeDisableChance: 0.55 * severity,
                processingReduction: 0.7 * severity
            )

        case .realityUnravel:
            let baseDrain = 1500 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.85 * severity,
                nodeDisableChance: 0.6 * severity,
                processingReduction: 0.75 * severity
            )

        // Omega era attacks (T21-T25)
        case .omegaStrike:
            let baseDrain = 2000 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.9 * severity,
                nodeDisableChance: 0.7 * severity,
                processingReduction: 0.8 * severity
            )

        case .existentialThreat:
            // The ultimate attack - threatens existence itself
            let baseDrain = 5000 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.95 * severity,
                nodeDisableChance: 0.8 * severity,
                processingReduction: 0.9 * severity
            )
        }
    }

    mutating func tick() {
        ticksRemaining = max(0, ticksRemaining - 1)
    }
}

// MARK: - Attack Damage

struct AttackDamage {
    var creditDrain: Double = 0
    var bandwidthReduction: Double = 0  // 0.0 - 1.0 percentage
    var nodeDisableChance: Double = 0   // 0.0 - 1.0 percentage
    var processingReduction: Double = 0

    static let zero = AttackDamage()
}

// MARK: - Defense Stats

struct DefenseStats: Codable {
    var firewallHealth: Double = 0
    var firewallMaxHealth: Double = 0
    var idsLevel: Int = 0
    var honeypotActive: Bool = false
    var encryptionLevel: Int = 0

    var hasFirewall: Bool { firewallMaxHealth > 0 }

    /// Chance to detect attack early (0.0 - 1.0)
    var detectionChance: Double {
        Double(idsLevel) * 0.15
    }

    /// Chance to redirect attack to honeypot
    var redirectChance: Double {
        honeypotActive ? 0.25 : 0.0
    }

    /// Damage reduction from encryption
    var damageReduction: Double {
        min(0.5, Double(encryptionLevel) * 0.1)
    }

    mutating func absorbDamage(_ amount: Double) -> Double {
        guard firewallHealth > 0 else { return amount }
        let absorbed = min(firewallHealth, amount)
        firewallHealth -= absorbed
        return amount - absorbed
    }
}

// MARK: - Threat State

struct ThreatState: Codable {
    var currentLevel: ThreatLevel = .ghost
    var totalCreditsEarned: Double = 0
    var attacksSurvived: Int = 0
    var totalDamageReceived: Double = 0
    var totalDamageBlocked: Double = 0
    var activeAttacks: [Attack] = []
    var defenseStats: DefenseStats = DefenseStats()

    // NetDefense tracking
    var netDefenseLevel: NetDefenseLevel = .exposed

    // Malus tracking
    var malusAwareness: Double = 0  // 0-100, triggers events
    var malusEncounters: Int = 0
    var lastMalusMessageTick: Int = 0

    mutating func updateThreatLevel() {
        let newLevel = ThreatLevel.forCredits(totalCreditsEarned)
        if newLevel.rawValue > currentLevel.rawValue {
            currentLevel = newLevel
        }
    }

    /// Update NetDefense based on current firewall state
    mutating func updateNetDefense(firewallTier: Int, firewallLevel: Int, firewallHealthPercent: Double) {
        netDefenseLevel = NetDefenseLevel.calculate(
            firewallTier: firewallTier,
            firewallLevel: firewallLevel,
            firewallHealthPercent: firewallHealthPercent
        )
    }

    /// Calculate current risk (threat reduced by defense)
    var riskCalculation: RiskCalculation {
        RiskCalculation(threat: currentLevel, defense: netDefenseLevel)
    }

    /// Effective risk level after defense mitigation
    var effectiveRiskLevel: ThreatLevel {
        riskCalculation.effectiveRiskLevel
    }

    /// Attack chance based on effective risk (not raw threat)
    var effectiveAttackChance: Double {
        riskCalculation.attackChancePerTick
    }
}

// MARK: - Attack Generator

struct AttackGenerator {
    /// Attempt to generate an attack based on threat level
    /// - Parameters:
    ///   - threatLevel: Current RAW threat level (not effective risk)
    ///   - currentTick: Game tick for attack timing
    ///   - random: Random number generator
    ///   - frequencyReduction: Reduction to attack chance (legacy, now unused - defense reduces damage instead)
    ///   - frequencyMultiplier: Multiplier for attack frequency (e.g., 2.0 for Insane mode)
    ///   - minimumChance: Minimum attack chance per tick (from level config)
    static func tryGenerateAttack(
        threatLevel: ThreatLevel,
        currentTick: Int,
        random: inout RandomNumberGenerator,
        frequencyReduction: Double = 0,
        frequencyMultiplier: Double = 1.0,
        minimumChance: Double = 0.0
    ) -> Attack? {
        // Roll for attack chance (multiplied by insane mode, with minimum floor)
        let baseChance = threatLevel.attackChancePerTick * frequencyMultiplier
        let reducedChance = baseChance * (1.0 - frequencyReduction)
        // Apply minimum attack chance floor (ensures attacks keep happening)
        let effectiveChance = max(reducedChance, minimumChance)
        let roll = Double.random(in: 0...100, using: &random)
        guard roll < effectiveChance else { return nil }

        // Select attack type based on threat level and weights
        let availableTypes = AttackType.allCases.filter {
            $0.minThreatLevel.rawValue <= threatLevel.rawValue
        }

        guard !availableTypes.isEmpty else { return nil }

        // Weighted random selection
        let totalWeight = availableTypes.reduce(0) { $0 + $1.weight }
        var selection = Int.random(in: 0..<totalWeight, using: &random)

        var selectedType: AttackType = .probe
        for type in availableTypes {
            selection -= type.weight
            if selection < 0 {
                selectedType = type
                break
            }
        }

        // Calculate severity based on threat level
        let baseSeverity = threatLevel.severityMultiplier
        let variance = Double.random(in: 0.8...1.2, using: &random)
        let severity = baseSeverity * variance

        return Attack(type: selectedType, severity: severity, startTick: currentTick)
    }
}
