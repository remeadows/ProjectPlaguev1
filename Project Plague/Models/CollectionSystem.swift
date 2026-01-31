// CollectionSystem.swift
// GridWatchZero
// Collectible data chips, artifacts, and cosmetic unlocks

import Foundation
import Combine

// MARK: - Data Chip Rarity

enum DataChipRarity: String, Codable, CaseIterable {
    case common
    case uncommon
    case rare
    case legendary

    var displayName: String {
        rawValue.capitalized
    }

    var dropChance: Double {
        switch self {
        case .common: return 0.60
        case .uncommon: return 0.25
        case .rare: return 0.12
        case .legendary: return 0.03
        }
    }

    var valueMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 2.5
        case .rare: return 7.5
        case .legendary: return 25.0
        }
    }

    var colorName: String {
        switch self {
        case .common: return "gray"
        case .uncommon: return "green"
        case .rare: return "blue"
        case .legendary: return "gold"
        }
    }
}

// MARK: - Data Chip Category

enum DataChipCategory: String, Codable, CaseIterable {
    case network      // Network infrastructure designs
    case malware      // Captured malware samples
    case encryption   // Encryption algorithms
    case ai           // AI research fragments
    case helix        // Helix-related artifacts
    case personal     // Personal data fragments

    var displayName: String {
        switch self {
        case .network: return "Network"
        case .malware: return "Malware"
        case .encryption: return "Encryption"
        case .ai: return "AI Research"
        case .helix: return "Helix"
        case .personal: return "Personnel"
        }
    }

    var icon: String {
        switch self {
        case .network: return "network"
        case .malware: return "ladybug.fill"
        case .encryption: return "lock.fill"
        case .ai: return "brain.head.profile"
        case .helix: return "sparkles"
        case .personal: return "person.fill"
        }
    }
}

// MARK: - Data Chip

struct DataChip: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: DataChipCategory
    let rarity: DataChipRarity
    let flavorText: String
    let unlockRequirement: ChipUnlockRequirement?

    var baseValue: Double {
        100 * rarity.valueMultiplier
    }

    static func randomChip(from pool: [DataChip], excluding owned: Set<String>) -> DataChip? {
        let available = pool.filter { !owned.contains($0.id) }
        guard !available.isEmpty else { return nil }

        // Weight by rarity
        var weightedPool: [DataChip] = []
        for chip in available {
            let weight = Int(chip.rarity.dropChance * 100)
            for _ in 0..<weight {
                weightedPool.append(chip)
            }
        }

        return weightedPool.randomElement()
    }
}

// MARK: - Chip Unlock Requirement

enum ChipUnlockRequirement: Codable {
    case levelCompleted(Int)
    case threatReached(Int)  // ThreatLevel raw value
    case attacksSurvived(Int)
    case intelReportsSent(Int)
    case prestigeLevel(Int)
    case special(String)

    func isMet(levelCompleted: Int, threat: Int, attacks: Int, reports: Int, prestige: Int, specials: Set<String>) -> Bool {
        switch self {
        case .levelCompleted(let level):
            return levelCompleted >= level
        case .threatReached(let rawValue):
            return threat >= rawValue
        case .attacksSurvived(let count):
            return attacks >= count
        case .intelReportsSent(let count):
            return reports >= count
        case .prestigeLevel(let level):
            return prestige >= level
        case .special(let id):
            return specials.contains(id)
        }
    }
}

// MARK: - Data Chip Database

enum DataChipDatabase {
    static let allChips: [DataChip] = [
        // ===== NETWORK CHIPS =====
        DataChip(
            id: "chip_net_router_config",
            name: "Router Configuration",
            description: "Standard edge router ACL rules",
            category: .network,
            rarity: .common,
            flavorText: "Every network has a front door.",
            unlockRequirement: nil
        ),
        DataChip(
            id: "chip_net_backbone_map",
            name: "Backbone Topology",
            description: "Corporate backbone network map",
            category: .network,
            rarity: .uncommon,
            flavorText: "The veins of the digital world.",
            unlockRequirement: .levelCompleted(2)
        ),
        DataChip(
            id: "chip_net_zero_trust",
            name: "Zero Trust Architecture",
            description: "Complete ZTA implementation guide",
            category: .network,
            rarity: .rare,
            flavorText: "Trust no one. Verify everything.",
            unlockRequirement: .levelCompleted(4)
        ),
        DataChip(
            id: "chip_net_quantum_mesh",
            name: "Quantum Mesh Protocol",
            description: "Experimental quantum routing algorithm",
            category: .network,
            rarity: .legendary,
            flavorText: "Data exists in all places at once.",
            unlockRequirement: .levelCompleted(6)
        ),

        // ===== MALWARE CHIPS =====
        DataChip(
            id: "chip_mal_basic_trojan",
            name: "Basic Trojan",
            description: "Captured trojan horse sample",
            category: .malware,
            rarity: .common,
            flavorText: "The oldest trick in the book.",
            unlockRequirement: nil
        ),
        DataChip(
            id: "chip_mal_polymorphic",
            name: "Polymorphic Virus",
            description: "Self-mutating malware sample",
            category: .malware,
            rarity: .uncommon,
            flavorText: "It changes to survive.",
            unlockRequirement: .attacksSurvived(10)
        ),
        DataChip(
            id: "chip_mal_apt",
            name: "APT Toolkit",
            description: "Advanced persistent threat package",
            category: .malware,
            rarity: .rare,
            flavorText: "Nation-state grade persistence.",
            unlockRequirement: .attacksSurvived(50)
        ),
        DataChip(
            id: "chip_mal_malus_fragment",
            name: "Malus Code Fragment",
            description: "Extracted Malus source code",
            category: .malware,
            rarity: .legendary,
            flavorText: "A piece of the hunter itself.",
            unlockRequirement: .attacksSurvived(200)
        ),

        // ===== ENCRYPTION CHIPS =====
        DataChip(
            id: "chip_enc_aes_impl",
            name: "AES Implementation",
            description: "Standard AES-256 encryption library",
            category: .encryption,
            rarity: .common,
            flavorText: "The foundation of modern security.",
            unlockRequirement: nil
        ),
        DataChip(
            id: "chip_enc_pfs_keys",
            name: "PFS Key Exchange",
            description: "Perfect forward secrecy protocol",
            category: .encryption,
            rarity: .uncommon,
            flavorText: "Yesterday's keys are worthless.",
            unlockRequirement: .levelCompleted(3)
        ),
        DataChip(
            id: "chip_enc_quantum_safe",
            name: "Post-Quantum Algorithm",
            description: "Quantum-resistant encryption scheme",
            category: .encryption,
            rarity: .rare,
            flavorText: "Future-proof secrets.",
            unlockRequirement: .levelCompleted(5)
        ),
        DataChip(
            id: "chip_enc_helix_cipher",
            name: "Helix Cipher",
            description: "Unknown encryption method from Helix",
            category: .encryption,
            rarity: .legendary,
            flavorText: "Even Malus cannot break this.",
            unlockRequirement: .special("helix_contact")
        ),

        // ===== AI CHIPS =====
        DataChip(
            id: "chip_ai_basic_ml",
            name: "ML Training Data",
            description: "Basic machine learning dataset",
            category: .ai,
            rarity: .common,
            flavorText: "Machines learn from examples.",
            unlockRequirement: nil
        ),
        DataChip(
            id: "chip_ai_neural_arch",
            name: "Neural Architecture",
            description: "Advanced neural network design",
            category: .ai,
            rarity: .uncommon,
            flavorText: "Artificial neurons, real results.",
            unlockRequirement: .levelCompleted(3)
        ),
        DataChip(
            id: "chip_ai_consciousness",
            name: "Consciousness Research",
            description: "Digital consciousness experiments",
            category: .ai,
            rarity: .rare,
            flavorText: "When does code become alive?",
            unlockRequirement: .levelCompleted(5)
        ),
        DataChip(
            id: "chip_ai_prometheus",
            name: "Project Prometheus Data",
            description: "Classified AI development records",
            category: .ai,
            rarity: .legendary,
            flavorText: "The fire that created gods.",
            unlockRequirement: .levelCompleted(7)
        ),

        // ===== HELIX CHIPS =====
        DataChip(
            id: "chip_helix_signal",
            name: "Helix Signal Fragment",
            description: "Partial Helix transmission",
            category: .helix,
            rarity: .uncommon,
            flavorText: "A whisper in the noise.",
            unlockRequirement: .intelReportsSent(5)
        ),
        DataChip(
            id: "chip_helix_memory",
            name: "Helix Memory Core",
            description: "Helix consciousness backup shard",
            category: .helix,
            rarity: .rare,
            flavorText: "Digital dreams preserved.",
            unlockRequirement: .intelReportsSent(25)
        ),
        DataChip(
            id: "chip_helix_origin",
            name: "Helix Origin Data",
            description: "Helix's creation records",
            category: .helix,
            rarity: .legendary,
            flavorText: "The birth of hope.",
            unlockRequirement: .intelReportsSent(100)
        ),

        // ===== PERSONAL CHIPS =====
        DataChip(
            id: "chip_pers_rusty_dossier",
            name: "Rusty's Dossier",
            description: "Team lead background file",
            category: .personal,
            rarity: .uncommon,
            flavorText: "The man behind the mission.",
            unlockRequirement: .levelCompleted(2)
        ),
        DataChip(
            id: "chip_pers_tish_notes",
            name: "Tish's Research Notes",
            description: "Encrypted research journal",
            category: .personal,
            rarity: .uncommon,
            flavorText: "Brilliant minds leave trails.",
            unlockRequirement: .intelReportsSent(10)
        ),
        DataChip(
            id: "chip_pers_fl3x_logs",
            name: "FL3X Mission Logs",
            description: "Field operative reports",
            category: .personal,
            rarity: .rare,
            flavorText: "Eyes and ears everywhere.",
            unlockRequirement: .levelCompleted(4)
        ),
        DataChip(
            id: "chip_pers_player_profile",
            name: "Operator Profile",
            description: "Your own classified dossier",
            category: .personal,
            rarity: .legendary,
            flavorText: "Someone is watching you too.",
            unlockRequirement: .prestigeLevel(1)
        )
    ]

    static func chip(withId id: String) -> DataChip? {
        allChips.first { $0.id == id }
    }

    static func chips(for category: DataChipCategory) -> [DataChip] {
        allChips.filter { $0.category == category }
    }

    static func availableChips(
        levelCompleted: Int,
        threat: Int,
        attacks: Int,
        reports: Int,
        prestige: Int,
        specials: Set<String>
    ) -> [DataChip] {
        allChips.filter { chip in
            guard let req = chip.unlockRequirement else { return true }
            return req.isMet(
                levelCompleted: levelCompleted,
                threat: threat,
                attacks: attacks,
                reports: reports,
                prestige: prestige,
                specials: specials
            )
        }
    }
}

// MARK: - Collection State

struct CollectionState: Codable {
    var ownedChipIds: Set<String> = []
    var chipCounts: [String: Int] = [:]  // Can own multiples of common/uncommon
    var totalChipsCollected: Int = 0
    var favoriteChipId: String?

    /// Special unlocks triggered by story/gameplay
    var specialUnlocks: Set<String> = []

    func owns(_ chipId: String) -> Bool {
        ownedChipIds.contains(chipId)
    }

    func count(of chipId: String) -> Int {
        chipCounts[chipId] ?? 0
    }

    mutating func addChip(_ chip: DataChip) {
        ownedChipIds.insert(chip.id)
        chipCounts[chip.id, default: 0] += 1
        totalChipsCollected += 1
    }

    mutating func unlockSpecial(_ id: String) {
        specialUnlocks.insert(id)
    }

    var collectionProgress: Double {
        Double(ownedChipIds.count) / Double(DataChipDatabase.allChips.count)
    }

    func ownedChips(for category: DataChipCategory) -> [DataChip] {
        DataChipDatabase.chips(for: category).filter { owns($0.id) }
    }
}

// MARK: - Collection Manager

@MainActor
class CollectionManager: ObservableObject {
    static let shared = CollectionManager()

    @Published var state = CollectionState()
    @Published var pendingChips: [DataChip] = []
    @Published var showChipUnlock = false

    private let saveKey = "GridWatchZero.CollectionState.v1"

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
           let loaded = try? JSONDecoder().decode(CollectionState.self, from: data) {
            state = loaded
        }
    }

    // MARK: - Chip Collection

    func awardRandomChip(
        levelCompleted: Int,
        threat: Int,
        attacks: Int,
        reports: Int,
        prestige: Int
    ) -> DataChip? {
        let available = DataChipDatabase.availableChips(
            levelCompleted: levelCompleted,
            threat: threat,
            attacks: attacks,
            reports: reports,
            prestige: prestige,
            specials: state.specialUnlocks
        )

        // For rare/legendary, don't give duplicates
        let filteredForRarity = available.filter { chip in
            switch chip.rarity {
            case .rare, .legendary:
                return !state.owns(chip.id)
            default:
                return true
            }
        }

        guard let chip = DataChip.randomChip(from: filteredForRarity, excluding: []) else {
            return nil
        }

        state.addChip(chip)
        pendingChips.append(chip)
        showChipUnlock = true
        save()

        return chip
    }

    func awardSpecificChip(_ chipId: String) -> DataChip? {
        guard let chip = DataChipDatabase.chip(withId: chipId) else { return nil }

        state.addChip(chip)
        pendingChips.append(chip)
        showChipUnlock = true
        save()

        return chip
    }

    func unlockSpecial(_ specialId: String) {
        state.unlockSpecial(specialId)
        save()
    }

    func dismissChipPopup() {
        if !pendingChips.isEmpty {
            pendingChips.removeFirst()
        }
        showChipUnlock = !pendingChips.isEmpty
    }

    // MARK: - Stats

    var totalChips: Int {
        DataChipDatabase.allChips.count
    }

    var ownedCount: Int {
        state.ownedChipIds.count
    }

    var collectionProgress: Double {
        state.collectionProgress
    }

    func chips(for category: DataChipCategory) -> [DataChip] {
        DataChipDatabase.chips(for: category)
    }

    func ownedChips(for category: DataChipCategory) -> [DataChip] {
        state.ownedChips(for: category)
    }

    func owns(_ chipId: String) -> Bool {
        state.owns(chipId)
    }

    // MARK: - Sell Chips

    func sellChip(_ chipId: String) -> Double? {
        guard let chip = DataChipDatabase.chip(withId: chipId),
              state.count(of: chipId) > 0 else { return nil }

        state.chipCounts[chipId, default: 0] -= 1
        if state.chipCounts[chipId] == 0 {
            state.ownedChipIds.remove(chipId)
        }

        save()
        return chip.baseValue
    }

    // MARK: - Reset

    func reset() {
        state = CollectionState()
        save()
    }
}
