// Node.swift
// GridWatchZero
// Protocol-oriented node system for the neural grid

import Foundation

// MARK: - Node Protocol

/// Base protocol for all grid nodes (sources, processors, sinks)
protocol NodeProtocol: Identifiable, Codable {
    var id: UUID { get }
    var name: String { get }
    var level: Int { get set }
    var currentLoad: Double { get set }
    var maxCapacity: Double { get }
    var isOnline: Bool { get set }

    /// Cost to upgrade to next level
    var upgradeCost: Double { get }

    /// Apply level-up effects
    mutating func upgrade()
}

extension NodeProtocol {
    var loadPercentage: Double {
        guard maxCapacity > 0 else { return 0 }
        return min(currentLoad / maxCapacity, 1.0)
    }

    var isOverloaded: Bool {
        currentLoad >= maxCapacity
    }
}

// MARK: - Source Node

/// Generates raw data each tick
struct SourceNode: NodeProtocol {
    let id: UUID
    var name: String
    var level: Int
    var currentLoad: Double = 0
    var isOnline: Bool = true

    /// Base production per tick at level 1
    let baseProduction: Double

    /// Resource type this source generates
    let outputType: ResourceType

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseProduction: Double,
        outputType: ResourceType
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseProduction = baseProduction
        self.outputType = outputType
    }

    var maxCapacity: Double {
        // Sources don't buffer, they push immediately
        productionPerTick * 2
    }

    /// Data generated per tick (scales with level)
    var productionPerTick: Double {
        baseProduction * Double(level) * 1.5
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        25.0 * pow(1.18, Double(level))
    }

    mutating func upgrade() {
        level += 1
    }

    /// Generate data for this tick
    mutating func produce(atTick tick: Int) -> DataPacket {
        let amount = productionPerTick
        currentLoad = amount
        return DataPacket(type: outputType, amount: amount, createdAtTick: tick)
    }
}

// MARK: - Processor/Sink Node

/// Processes incoming data and converts it to credits
struct SinkNode: NodeProtocol {
    let id: UUID
    var name: String
    var level: Int
    var currentLoad: Double = 0
    var isOnline: Bool = true

    /// Base processing rate per tick
    let baseProcessingRate: Double

    /// Credits earned per unit of data processed
    let conversionRate: Double

    /// Input buffer - data waiting to be processed
    var inputBuffer: Double = 0

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseProcessingRate: Double,
        conversionRate: Double
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseProcessingRate = baseProcessingRate
        self.conversionRate = conversionRate
    }

    var maxCapacity: Double {
        // Buffer capacity scales with level
        baseProcessingRate * Double(level) * 3.0
    }

    /// How much data can be processed per tick
    var processingPerTick: Double {
        baseProcessingRate * Double(level) * 1.3
    }

    var bufferRemaining: Double {
        max(0, maxCapacity - inputBuffer)
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        40.0 * pow(1.18, Double(level))
    }

    mutating func upgrade() {
        level += 1
    }

    /// Accept incoming data into buffer (returns amount actually accepted)
    mutating func receiveData(_ amount: Double) -> Double {
        let accepted = min(amount, bufferRemaining)
        inputBuffer += accepted
        currentLoad = inputBuffer
        return accepted
    }

    /// Process buffered data and return credits earned
    mutating func process() -> Double {
        let toProcess = min(inputBuffer, processingPerTick)
        inputBuffer -= toProcess
        currentLoad = inputBuffer
        let creditsEarned = toProcess * conversionRate
        return creditsEarned
    }
}

// MARK: - Firewall Node (Defense)

/// Absorbs incoming attack damage before it hits other systems
struct FirewallNode: NodeProtocol {
    let id: UUID
    var name: String
    var level: Int
    var currentLoad: Double = 0  // Current damage absorbed this tick
    var isOnline: Bool = true

    /// Base health pool at level 1
    let baseHealth: Double

    /// Current health (regenerates slowly)
    var currentHealth: Double

    /// Damage reduction percentage (0.0 - 1.0)
    let baseDamageReduction: Double

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseHealth: Double,
        baseDamageReduction: Double = 0.2
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseHealth = baseHealth
        self.currentHealth = baseHealth * Double(level)
        self.baseDamageReduction = baseDamageReduction
    }

    var maxCapacity: Double {
        // Max health scales with level
        baseHealth * Double(level) * 1.5
    }

    var maxHealth: Double {
        maxCapacity
    }

    var healthPercentage: Double {
        guard maxHealth > 0 else { return 0 }
        return currentHealth / maxHealth
    }

    /// Damage reduction increases with level
    var damageReduction: Double {
        min(0.6, baseDamageReduction + (Double(level) * 0.05))
    }

    /// Health regeneration per tick
    var regenPerTick: Double {
        maxHealth * 0.02 * Double(level) // 2% per tick per level
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        50.0 * pow(1.18, Double(level))
    }

    var isDestroyed: Bool {
        currentHealth <= 0
    }

    mutating func upgrade() {
        level += 1
        // Heal to new max on upgrade
        currentHealth = maxHealth
    }

    /// Absorb incoming damage, returns remaining damage that passes through
    mutating func absorbDamage(_ damage: Double) -> Double {
        guard isOnline && !isDestroyed else { return damage }

        // Apply damage reduction
        let reducedDamage = damage * (1.0 - damageReduction)

        // Absorb what we can
        let absorbed = min(currentHealth, reducedDamage)
        currentHealth -= absorbed
        currentLoad = absorbed

        // Return any damage that got through
        let passThrough = reducedDamage - absorbed
        return passThrough
    }

    /// Regenerate health each tick
    mutating func regenerate() {
        guard isOnline else { return }
        currentHealth = min(maxHealth, currentHealth + regenPerTick)
    }

    /// Repair firewall (costs credits, returns cost)
    mutating func repair() -> Double {
        let missingHealth = maxHealth - currentHealth
        let repairCost = missingHealth * 0.5
        currentHealth = maxHealth
        return repairCost
    }
}

// MARK: - Node Tier

enum NodeTier: Int, Codable, CaseIterable {
    // Real-world cybersecurity (T1-6)
    case tier1 = 1
    case tier2 = 2
    case tier3 = 3
    case tier4 = 4
    case tier5 = 5
    case tier6 = 6
    // Post-Helix Transcendence (T7-10)
    case tier7 = 7
    case tier8 = 8
    case tier9 = 9
    case tier10 = 10
    // Dimensional/Reality-bending (T11-15)
    case tier11 = 11
    case tier12 = 12
    case tier13 = 13
    case tier14 = 14
    case tier15 = 15
    // Cosmic/Universal scale (T16-20)
    case tier16 = 16
    case tier17 = 17
    case tier18 = 18
    case tier19 = 19
    case tier20 = 20
    // Absolute/Godlike (T21-25)
    case tier21 = 21
    case tier22 = 22
    case tier23 = 23
    case tier24 = 24
    case tier25 = 25

    var name: String {
        switch self {
        // Real-world cybersecurity (T1-6)
        case .tier1: return "Basic"
        case .tier2: return "Advanced"
        case .tier3: return "Elite"
        case .tier4: return "Helix"
        case .tier5: return "Quantum"
        case .tier6: return "Neural"
        // Post-Helix Transcendence (T7-10)
        case .tier7: return "Symbiont"
        case .tier8: return "Transcendence"
        case .tier9: return "Void"
        case .tier10: return "Dimensional"
        // Dimensional/Reality-bending (T11-15)
        case .tier11: return "Multiverse"
        case .tier12: return "Entropy"
        case .tier13: return "Causality"
        case .tier14: return "Timeline"
        case .tier15: return "Akashic"
        // Cosmic/Universal scale (T16-20)
        case .tier16: return "Cosmic"
        case .tier17: return "Dark Matter"
        case .tier18: return "Singularity"
        case .tier19: return "Omniscient"
        case .tier20: return "Reality"
        // Absolute/Godlike (T21-25)
        case .tier21: return "Prime"
        case .tier22: return "Absolute"
        case .tier23: return "Genesis"
        case .tier24: return "Omega"
        case .tier25: return "Infinite"
        }
    }

    var color: String {
        switch self {
        // Real-world cybersecurity - existing colors (T1-6)
        case .tier1: return "terminalGray"
        case .tier2: return "neonGreen"
        case .tier3: return "neonCyan"
        case .tier4: return "neonAmber"
        case .tier5: return "neonRed"
        case .tier6: return "neonAmber"
        // Post-Helix Transcendence - purple shades (T7-10)
        case .tier7: return "transcendencePurple"
        case .tier8: return "transcendencePurple"
        case .tier9: return "voidBlue"
        case .tier10: return "dimensionalGold"
        // Dimensional/Reality-bending - purple/gold (T11-15)
        case .tier11: return "multiversePink"
        case .tier12: return "dimensionalGold"
        case .tier13: return "multiversePink"
        case .tier14: return "dimensionalGold"
        case .tier15: return "akashicGold"
        // Cosmic/Universal scale - white/silver (T16-20)
        case .tier16: return "cosmicSilver"
        case .tier17: return "darkMatterPurple"
        case .tier18: return "singularityWhite"
        case .tier19: return "cosmicSilver"
        case .tier20: return "singularityWhite"
        // Absolute/Godlike - gold/black (T21-25)
        case .tier21: return "infiniteGold"
        case .tier22: return "infiniteGold"
        case .tier23: return "infiniteGold"
        case .tier24: return "omegaBlack"
        case .tier25: return "infiniteGold"
        }
    }

    /// Maximum level for this tier (hard cap)
    /// Players must reach max level before unlocking the next tier
    var maxLevel: Int {
        switch self {
        case .tier1: return 10
        case .tier2: return 15
        case .tier3: return 20
        case .tier4: return 25
        case .tier5: return 30
        case .tier6: return 40
        // T7-25 all have max level 50
        case .tier7, .tier8, .tier9, .tier10,
             .tier11, .tier12, .tier13, .tier14, .tier15,
             .tier16, .tier17, .tier18, .tier19, .tier20,
             .tier21, .tier22, .tier23, .tier24, .tier25:
            return 50
        }
    }

    /// Returns true if the given level is at or above the max for this tier
    func isAtMaxLevel(_ level: Int) -> Bool {
        level >= maxLevel
    }

    /// Tier range grouping for UI display
    var tierGroup: TierGroup {
        switch self {
        case .tier1, .tier2, .tier3, .tier4, .tier5, .tier6:
            return .realWorld
        case .tier7, .tier8, .tier9, .tier10:
            return .transcendence
        case .tier11, .tier12, .tier13, .tier14, .tier15:
            return .dimensional
        case .tier16, .tier17, .tier18, .tier19, .tier20:
            return .cosmic
        case .tier21, .tier22, .tier23, .tier24, .tier25:
            return .infinite
        }
    }
}

/// Grouping for tier ranges in UI
enum TierGroup: String, CaseIterable {
    case realWorld = "T1-6"
    case transcendence = "T7-10"
    case dimensional = "T11-15"
    case cosmic = "T16-20"
    case infinite = "T21-25"

    var displayName: String {
        switch self {
        case .realWorld: return "Real-World"
        case .transcendence: return "Transcendence"
        case .dimensional: return "Dimensional"
        case .cosmic: return "Cosmic"
        case .infinite: return "Infinite"
        }
    }

    var tiers: [NodeTier] {
        switch self {
        case .realWorld: return [.tier1, .tier2, .tier3, .tier4, .tier5, .tier6]
        case .transcendence: return [.tier7, .tier8, .tier9, .tier10]
        case .dimensional: return [.tier11, .tier12, .tier13, .tier14, .tier15]
        case .cosmic: return [.tier16, .tier17, .tier18, .tier19, .tier20]
        case .infinite: return [.tier21, .tier22, .tier23, .tier24, .tier25]
        }
    }
}

// MARK: - Source Variants (Tiers)

extension SourceNode {
    /// Tier of this source based on base production
    /// Production thresholds double each tier after T6
    var tier: NodeTier {
        switch baseProduction {
        // Real-world tiers (T1-6)
        case 0..<15: return .tier1
        case 15..<40: return .tier2
        case 40..<80: return .tier3
        case 80..<150: return .tier4
        case 150..<400: return .tier5
        case 400..<800: return .tier6
        // Transcendence tiers (T7-10) - base doubles each tier
        case 800..<1_500: return .tier7
        case 1_500..<3_000: return .tier8
        case 3_000..<6_000: return .tier9
        case 6_000..<12_000: return .tier10
        // Dimensional tiers (T11-15)
        case 12_000..<25_000: return .tier11
        case 25_000..<50_000: return .tier12
        case 50_000..<100_000: return .tier13
        case 100_000..<200_000: return .tier14
        case 200_000..<400_000: return .tier15
        // Cosmic tiers (T16-20)
        case 400_000..<800_000: return .tier16
        case 800_000..<1_600_000: return .tier17
        case 1_600_000..<3_200_000: return .tier18
        case 3_200_000..<6_400_000: return .tier19
        case 6_400_000..<12_800_000: return .tier20
        // Infinite tiers (T21-25)
        case 12_800_000..<25_600_000: return .tier21
        case 25_600_000..<51_200_000: return .tier22
        case 51_200_000..<102_400_000: return .tier23
        case 102_400_000..<204_800_000: return .tier24
        default: return .tier25
        }
    }

    /// Maximum level this source can be upgraded to
    var maxLevel: Int {
        tier.maxLevel
    }

    /// Whether this source can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this source is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        tier.isAtMaxLevel(level)
    }
}

// MARK: - Sink Variants (Tiers)

extension SinkNode {
    /// Tier of this sink based on conversion rate
    /// Conversion rates increase by 0.5x each tier after T6
    var tier: NodeTier {
        switch conversionRate {
        // Real-world tiers (T1-6)
        case 0..<1.8: return .tier1
        case 1.8..<2.3: return .tier2
        case 2.3..<2.8: return .tier3
        case 2.8..<3.3: return .tier4
        case 3.3..<4.0: return .tier5
        case 4.0..<4.8: return .tier6
        // Transcendence tiers (T7-10)
        case 4.8..<5.3: return .tier7
        case 5.3..<5.8: return .tier8
        case 5.8..<6.3: return .tier9
        case 6.3..<6.8: return .tier10
        // Dimensional tiers (T11-15)
        case 6.8..<7.3: return .tier11
        case 7.3..<7.8: return .tier12
        case 7.8..<8.3: return .tier13
        case 8.3..<8.8: return .tier14
        case 8.8..<9.3: return .tier15
        // Cosmic tiers (T16-20)
        case 9.3..<9.8: return .tier16
        case 9.8..<10.3: return .tier17
        case 10.3..<10.8: return .tier18
        case 10.8..<11.3: return .tier19
        case 11.3..<11.8: return .tier20
        // Infinite tiers (T21-25)
        case 11.8..<12.3: return .tier21
        case 12.3..<12.8: return .tier22
        case 12.8..<13.3: return .tier23
        case 13.3..<13.8: return .tier24
        default: return .tier25
        }
    }

    /// Maximum level this sink can be upgraded to
    var maxLevel: Int {
        tier.maxLevel
    }

    /// Whether this sink can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this sink is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        tier.isAtMaxLevel(level)
    }
}

// MARK: - Firewall Variants (Tiers)

extension FirewallNode {
    /// Tier of this firewall based on base health
    /// Health thresholds increase by 1.5x each tier after T6
    var tier: Int {
        switch baseHealth {
        // Real-world tiers (T1-6)
        case 0..<150: return 1
        case 150..<400: return 2
        case 400..<700: return 3
        case 700..<900: return 4
        case 900..<1500: return 5
        case 1500..<2500: return 6
        // Transcendence tiers (T7-10)
        case 2500..<4000: return 7
        case 4000..<6000: return 8
        case 6000..<9000: return 9
        case 9000..<13500: return 10
        // Dimensional tiers (T11-15)
        case 13500..<20000: return 11
        case 20000..<30000: return 12
        case 30000..<45000: return 13
        case 45000..<67500: return 14
        case 67500..<100000: return 15
        // Cosmic tiers (T16-20)
        case 100000..<150000: return 16
        case 150000..<225000: return 17
        case 225000..<337500: return 18
        case 337500..<506250: return 19
        case 506250..<760000: return 20
        // Infinite tiers (T21-25)
        case 760000..<1140000: return 21
        case 1140000..<1710000: return 22
        case 1710000..<2565000: return 23
        case 2565000..<3847500: return 24
        default: return 25
        }
    }

    /// Node tier enum for this firewall
    var nodeTier: NodeTier {
        NodeTier(rawValue: tier) ?? .tier1
    }

    /// Maximum level this firewall can be upgraded to
    var maxLevel: Int {
        nodeTier.maxLevel
    }

    /// Whether this firewall can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this firewall is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        nodeTier.isAtMaxLevel(level)
    }
}
