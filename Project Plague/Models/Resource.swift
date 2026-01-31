// Resource.swift
// GridWatchZero
// Core resource types flowing through the neural grid

import Foundation

/// Represents different types of data resources in the network
enum ResourceType: String, Codable, CaseIterable {
    case rawNoise = "Raw Noise"
    case credits = "Credits"

    var color: String {
        switch self {
        case .rawNoise: return "neonGreen"
        case .credits: return "neonAmber"
        }
    }
}

/// A packet of data flowing through the network
struct DataPacket: Identifiable, Codable {
    let id: UUID
    let type: ResourceType
    var amount: Double
    let createdAtTick: Int

    init(type: ResourceType, amount: Double, createdAtTick: Int) {
        self.id = UUID()
        self.type = type
        self.amount = amount
        self.createdAtTick = createdAtTick
    }
}

/// Tracks all player resources
struct PlayerResources: Codable {
    var credits: Double = 0
    var totalDataProcessed: Double = 0
    var totalPacketsLost: Double = 0

    mutating func addCredits(_ amount: Double) {
        credits += amount
    }

    mutating func spendCredits(_ amount: Double) -> Bool {
        guard credits >= amount else { return false }
        credits -= amount
        return true
    }
}
