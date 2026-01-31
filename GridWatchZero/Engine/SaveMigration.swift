// SaveMigration.swift
// GridWatchZero
// Handles migration of save data between versions

import Foundation

// MARK: - Save Version

enum SaveVersion: Int, Comparable, CaseIterable {
    case v1 = 1  // Initial release
    case v2 = 2  // Added UnlockState
    case v3 = 3  // Added FirewallNode, DefenseStack
    case v4 = 4  // Added LoreState, MilestoneState
    case v5 = 5  // Added PrestigeState, MalusIntelligence, criticalAlarmAcknowledged
    case v6 = 6  // ENH-011/ENH-012: Expanded tiers to 25, campaign levels 8-20, new threat levels

    static let current: SaveVersion = .v6

    var saveKey: String {
        "GridWatchZero.GameState.v\(rawValue)"
    }

    static func < (lhs: SaveVersion, rhs: SaveVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Save Migration Manager

@MainActor
final class SaveMigrationManager {

    /// Attempts to load and migrate save data to the current version
    /// Returns the migrated GameState, or nil if no save exists
    static func loadAndMigrate() -> GameState? {
        // Try current version first (most common case)
        if let state = loadVersion(.current) {
            return state
        }

        // Check older versions in descending order
        for version in SaveVersion.allCases.reversed() where version < .current {
            if let data = UserDefaults.standard.data(forKey: version.saveKey) {
                print("[SaveMigration] Found save at version \(version.rawValue), migrating to v\(SaveVersion.current.rawValue)")

                if let migratedState = migrate(from: version, data: data) {
                    // Save migrated state to current version
                    saveToCurrentVersion(migratedState)

                    // Clean up old save key
                    UserDefaults.standard.removeObject(forKey: version.saveKey)

                    return migratedState
                } else {
                    print("[SaveMigration] Failed to migrate from v\(version.rawValue)")
                }
            }
        }

        return nil
    }

    /// Load GameState from a specific version
    private static func loadVersion(_ version: SaveVersion) -> GameState? {
        guard let data = UserDefaults.standard.data(forKey: version.saveKey) else {
            return nil
        }

        if version == .current {
            return try? JSONDecoder().decode(GameState.self, from: data)
        }

        return migrate(from: version, data: data)
    }

    /// Migrate save data from an older version to current
    private static func migrate(from version: SaveVersion, data: Data) -> GameState? {
        switch version {
        case .v1:
            return migrateFromV1(data)
        case .v2:
            return migrateFromV2(data)
        case .v3:
            return migrateFromV3(data)
        case .v4:
            return migrateFromV4(data)
        case .v5:
            return migrateFromV5(data)
        case .v6:
            return try? JSONDecoder().decode(GameState.self, from: data)
        }
    }

    private static func saveToCurrentVersion(_ state: GameState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: SaveVersion.current.saveKey)
        }
    }
}

// MARK: - Legacy Game States

/// V1: Basic resources, nodes, tick count
private struct GameStateV1: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var currentTick: Int
    var totalPlayTime: TimeInterval
}

/// V2: Added UnlockState, ThreatState
private struct GameStateV2: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
}

/// V3: Added FirewallNode
private struct GameStateV3: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
    var lastSaveTimestamp: Date?
}

/// V4: Added LoreState, MilestoneState
private struct GameStateV4: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
    var loreState: LoreState
    var milestoneState: MilestoneState
    var lastSaveTimestamp: Date?
}

// MARK: - Migration Functions

extension SaveMigrationManager {

    /// V1 → V5 (current)
    private static func migrateFromV1(_ data: Data) -> GameState? {
        guard let v1 = try? JSONDecoder().decode(GameStateV1.self, from: data) else {
            return nil
        }

        var loreState = LoreState()
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: v1.resources,
            source: v1.source,
            link: v1.link,
            sink: v1.sink,
            firewall: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v1.currentTick,
            totalPlayTime: v1.totalPlayTime,
            threatState: ThreatState(),
            unlockState: UnlockState(),
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: PrestigeState(),
            lastSaveTimestamp: nil,
            criticalAlarmAcknowledged: false
        )
    }

    /// V2 → V5 (current)
    private static func migrateFromV2(_ data: Data) -> GameState? {
        guard let v2 = try? JSONDecoder().decode(GameStateV2.self, from: data) else {
            return nil
        }

        var loreState = LoreState()
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: v2.resources,
            source: v2.source,
            link: v2.link,
            sink: v2.sink,
            firewall: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v2.currentTick,
            totalPlayTime: v2.totalPlayTime,
            threatState: v2.threatState,
            unlockState: v2.unlockState,
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: PrestigeState(),
            lastSaveTimestamp: nil,
            criticalAlarmAcknowledged: false
        )
    }

    /// V3 → V5 (current)
    private static func migrateFromV3(_ data: Data) -> GameState? {
        guard let v3 = try? JSONDecoder().decode(GameStateV3.self, from: data) else {
            return nil
        }

        var loreState = LoreState()
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: v3.resources,
            source: v3.source,
            link: v3.link,
            sink: v3.sink,
            firewall: v3.firewall,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v3.currentTick,
            totalPlayTime: v3.totalPlayTime,
            threatState: v3.threatState,
            unlockState: v3.unlockState,
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: PrestigeState(),
            lastSaveTimestamp: v3.lastSaveTimestamp,
            criticalAlarmAcknowledged: false
        )
    }

    /// V4 → V6 (current)
    private static func migrateFromV4(_ data: Data) -> GameState? {
        guard let v4 = try? JSONDecoder().decode(GameStateV4.self, from: data) else {
            return nil
        }

        return GameState(
            resources: v4.resources,
            source: v4.source,
            link: v4.link,
            sink: v4.sink,
            firewall: v4.firewall,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v4.currentTick,
            totalPlayTime: v4.totalPlayTime,
            threatState: v4.threatState,
            unlockState: v4.unlockState,
            loreState: v4.loreState,
            milestoneState: v4.milestoneState,
            prestigeState: PrestigeState(),
            lastSaveTimestamp: v4.lastSaveTimestamp,
            criticalAlarmAcknowledged: false
        )
    }

    /// V5 → V6 (current)
    /// ENH-011/ENH-012: Tier expansion to 25, new threat levels, campaign levels 8-20
    /// No structural changes to GameState - just enum expansions that are backwards compatible
    private static func migrateFromV5(_ data: Data) -> GameState? {
        // V5 and V6 have identical GameState structure
        // The only changes are expanded enum cases (tiers, threat levels, attack types)
        // which are backwards compatible with Codable
        return try? JSONDecoder().decode(GameState.self, from: data)
    }
}

// MARK: - Migration Result

struct MigrationResult {
    let fromVersion: SaveVersion
    let toVersion: SaveVersion
    let state: GameState

    var didMigrate: Bool {
        fromVersion != toVersion
    }

    var description: String {
        if didMigrate {
            return "Migrated save from v\(fromVersion.rawValue) to v\(toVersion.rawValue)"
        } else {
            return "Loaded save at v\(toVersion.rawValue)"
        }
    }
}

// MARK: - Save Utilities

extension SaveMigrationManager {

    /// Remove all save data (all versions)
    static func clearAllSaves() {
        for version in SaveVersion.allCases {
            UserDefaults.standard.removeObject(forKey: version.saveKey)
        }
    }

    /// Check if any save exists (any version)
    static func hasSave() -> Bool {
        for version in SaveVersion.allCases.reversed() {
            if UserDefaults.standard.data(forKey: version.saveKey) != nil {
                return true
            }
        }
        return false
    }

    /// Get the version of the existing save, if any
    static func existingSaveVersion() -> SaveVersion? {
        for version in SaveVersion.allCases.reversed() {
            if UserDefaults.standard.data(forKey: version.saveKey) != nil {
                return version
            }
        }
        return nil
    }
}

// MARK: - Brand Migration (Project Plague → Grid Watch Zero)

/// Handles one-time migration of UserDefaults keys from the old "ProjectPlague" brand
/// to the new "GridWatchZero" brand. This preserves all player data across the rename.
@MainActor
final class BrandMigrationManager {

    /// Key to track if brand migration has been completed
    private static let migrationCompleteKey = "GridWatchZero.BrandMigrationComplete"

    /// All key mappings from old brand to new brand
    private static let keyMappings: [(old: String, new: String)] = [
        // Game State (all versions)
        ("ProjectPlague.GameState.v1", "GridWatchZero.GameState.v1"),
        ("ProjectPlague.GameState.v2", "GridWatchZero.GameState.v2"),
        ("ProjectPlague.GameState.v3", "GridWatchZero.GameState.v3"),
        ("ProjectPlague.GameState.v4", "GridWatchZero.GameState.v4"),
        ("ProjectPlague.GameState.v5", "GridWatchZero.GameState.v5"),
        ("ProjectPlague.GameState.v6", "GridWatchZero.GameState.v6"),

        // Campaign & Story
        ("ProjectPlague.CampaignProgress.v1", "GridWatchZero.CampaignProgress.v1"),
        ("ProjectPlague.StoryState.v1", "GridWatchZero.StoryState.v1"),

        // Engagement Systems
        ("ProjectPlague.EngagementState.v1", "GridWatchZero.EngagementState.v1"),
        ("ProjectPlague.AchievementState.v1", "GridWatchZero.AchievementState.v1"),
        ("ProjectPlague.CollectionState.v1", "GridWatchZero.CollectionState.v1"),

        // Other Systems
        ("ProjectPlague.CertificateState", "GridWatchZero.CertificateState"),
        ("ProjectPlague.TutorialState.v1", "GridWatchZero.TutorialState.v1"),
        ("ProjectPlague.CosmeticState.v1", "GridWatchZero.CosmeticState.v1"),
        ("ProjectPlague.AudioSettings.v1", "GridWatchZero.AudioSettings.v1"),

        // Device & Cloud
        ("ProjectPlague.DeviceId", "GridWatchZero.DeviceId"),
        ("ProjectPlague.LastCloudSync", "GridWatchZero.LastCloudSync"),
    ]

    /// Check if brand migration has already been completed
    static var isMigrationComplete: Bool {
        UserDefaults.standard.bool(forKey: migrationCompleteKey)
    }

    /// Perform brand migration if needed (call once at app startup)
    /// Returns true if migration was performed, false if already complete or no data to migrate
    @discardableResult
    static func migrateIfNeeded() -> Bool {
        // Skip if already migrated
        guard !isMigrationComplete else {
            return false
        }

        // Check if there's any old data to migrate
        let hasOldData = keyMappings.contains { mapping in
            UserDefaults.standard.object(forKey: mapping.old) != nil
        }

        guard hasOldData else {
            // No old data, mark as complete and return
            markMigrationComplete()
            return false
        }

        print("[BrandMigration] Starting migration from ProjectPlague to GridWatchZero...")
        var migratedCount = 0

        for mapping in keyMappings {
            if let data = UserDefaults.standard.object(forKey: mapping.old) {
                // Only migrate if new key doesn't already exist (don't overwrite)
                if UserDefaults.standard.object(forKey: mapping.new) == nil {
                    UserDefaults.standard.set(data, forKey: mapping.new)
                    print("[BrandMigration] Migrated: \(mapping.old) → \(mapping.new)")
                    migratedCount += 1
                }

                // Remove old key after migration
                UserDefaults.standard.removeObject(forKey: mapping.old)
            }
        }

        // Also migrate iCloud keys if available
        migrateCloudKeys()

        markMigrationComplete()
        print("[BrandMigration] Migration complete. Migrated \(migratedCount) keys.")

        return migratedCount > 0
    }

    /// Migrate iCloud key-value store keys
    private static func migrateCloudKeys() {
        let cloudStore = NSUbiquitousKeyValueStore.default

        let cloudMappings: [(old: String, new: String)] = [
            ("ProjectPlague.SyncableProgress.v1", "GridWatchZero.SyncableProgress.v1"),
        ]

        for mapping in cloudMappings {
            if let data = cloudStore.object(forKey: mapping.old) {
                if cloudStore.object(forKey: mapping.new) == nil {
                    cloudStore.set(data, forKey: mapping.new)
                    print("[BrandMigration] Migrated iCloud: \(mapping.old) → \(mapping.new)")
                }
                cloudStore.removeObject(forKey: mapping.old)
            }
        }

        cloudStore.synchronize()
    }

    /// Mark migration as complete
    private static func markMigrationComplete() {
        UserDefaults.standard.set(true, forKey: migrationCompleteKey)
    }

    /// Reset migration flag (for testing purposes only)
    static func resetMigrationFlag() {
        UserDefaults.standard.removeObject(forKey: migrationCompleteKey)
    }

    /// Check if old brand data exists (useful for UI to show migration notice)
    static func hasOldBrandData() -> Bool {
        keyMappings.contains { mapping in
            UserDefaults.standard.object(forKey: mapping.old) != nil
        }
    }
}
