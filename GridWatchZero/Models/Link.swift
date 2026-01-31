// Link.swift
// GridWatchZero
// Network links connecting nodes in the grid

import Foundation

// MARK: - Link Protocol

/// Represents a connection between nodes with bandwidth constraints
protocol LinkProtocol: Identifiable, Codable {
    var id: UUID { get }
    var name: String { get }
    var level: Int { get set }

    /// Maximum data throughput per tick
    var bandwidth: Double { get }

    /// Ticks of delay (not implemented in MVP, but ready for expansion)
    var latency: Int { get }

    /// Chance of packet loss (0.0 - 1.0) - applied to excess traffic
    var packetLossChance: Double { get }

    var upgradeCost: Double { get }

    mutating func upgrade()
}

// MARK: - Transport Link

/// Standard network link with bandwidth limitations
struct TransportLink: LinkProtocol {
    let id: UUID
    var name: String
    var level: Int

    /// Factory unit type ID for checkpoint restoration
    let unitTypeId: String

    /// Base bandwidth at level 1
    let baseBandwidth: Double

    /// Base latency in ticks
    let baseLatency: Int

    /// Stats for current tick
    var lastTickTransferred: Double = 0
    var lastTickDropped: Double = 0

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseBandwidth: Double,
        baseLatency: Int,
        unitTypeId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseBandwidth = baseBandwidth
        self.baseLatency = baseLatency
        // If unitTypeId not provided, look up from unit catalog by name
        self.unitTypeId = unitTypeId ?? UnitFactory.unitId(forName: name) ?? "link_t1_copper_vpn"
    }

    var bandwidth: Double {
        baseBandwidth * Double(level) * 1.4
    }

    var latency: Int {
        max(1, baseLatency - (level / 3))
    }

    /// Packet loss only applies to data exceeding bandwidth
    var packetLossChance: Double {
        // At higher levels, overflow handling improves slightly
        max(0.8, 1.0 - (Double(level) * 0.02))
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        30.0 * pow(1.18, Double(level))
    }

    var throughputEfficiency: Double {
        guard lastTickTransferred + lastTickDropped > 0 else { return 1.0 }
        return lastTickTransferred / (lastTickTransferred + lastTickDropped)
    }

    mutating func upgrade() {
        level += 1
    }

    /// Transfer data through the link, applying bandwidth cap and packet loss
    /// Returns: (transferred amount, dropped amount)
    mutating func transfer(_ packet: DataPacket, maxAcceptable: Double) -> (transferred: Double, dropped: Double) {
        let incoming = packet.amount

        // Calculate how much can pass through
        let effectiveBandwidth = min(bandwidth, maxAcceptable)
        let transferred = min(incoming, effectiveBandwidth)

        // Excess data is subject to packet loss
        let excess = incoming - transferred
        var dropped: Double = 0

        if excess > 0 {
            // Apply packet loss to excess
            dropped = excess * packetLossChance
        }

        lastTickTransferred = transferred
        lastTickDropped = dropped

        return (transferred, dropped)
    }
}

// MARK: - TransportLink Tier Extensions

extension TransportLink {
    /// Tier of this link based on base bandwidth
    var tier: NodeTier {
        switch baseBandwidth {
        case 0..<10: return .tier1
        case 10..<30: return .tier2
        case 30..<80: return .tier3
        case 80..<200: return .tier4
        case 200..<500: return .tier5
        default: return .tier6
        }
    }

    /// Maximum level this link can be upgraded to
    var maxLevel: Int {
        tier.maxLevel
    }

    /// Whether this link can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this link is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        tier.isAtMaxLevel(level)
    }
}
