// CampaignProgress.swift
// GridWatchZero
// Campaign progression tracking and persistence

import Foundation

// MARK: - Level Checkpoint (Mid-level Save)

/// Saves the game state during a campaign level for resume capability
struct LevelCheckpoint: Codable {
    let levelId: Int
    let isInsane: Bool
    let savedAt: Date

    // Game state snapshot
    let credits: Double
    let data: Double
    let ticksElapsed: Int
    let attacksSurvived: Int
    let damageBlocked: Double
    let creditsEarned: Double  // Track total earned for level objective

    // Node states - save actual unit IDs and levels for proper restoration
    let sourceUnitId: String
    let sourceLevel: Int
    let linkUnitId: String
    let linkLevel: Int
    let sinkUnitId: String
    let sinkLevel: Int
    let firewallUnitId: String?
    let firewallHealth: Double?
    let firewallMaxHealth: Double?
    let firewallLevel: Int?

    // Defense applications - save the full state
    let defenseStack: DefenseStack
    let malusIntel: MalusIntelligence

    // Units unlocked during THIS level (not persisted across levels)
    // This allows checkpoint resume to restore mid-level unlock progress
    let unlockedUnits: Set<String>

    /// Check if checkpoint is recent enough to resume (within 24 hours)
    var isValid: Bool {
        let hoursSinceSave = Date().timeIntervalSince(savedAt) / 3600
        return hoursSinceSave < 24
    }
}

// MARK: - Campaign Progress

struct CampaignProgress: Codable {
    // Completed levels
    var completedLevels: Set<Int> = []
    var insaneCompletedLevels: Set<Int> = []

    // Best stats per level
    var levelStats: [Int: LevelCompletionStats] = [:]
    var insaneLevelStats: [Int: LevelCompletionStats] = [:]

    // Lifetime stats across all campaign runs
    var lifetimeStats: LifetimeStats = LifetimeStats()

    // Current campaign state
    var currentLevelId: Int?
    var isInsaneMode: Bool = false

    // Mid-level checkpoint (allows resuming interrupted levels)
    var activeCheckpoint: LevelCheckpoint?

    // Unlocked content
    var unlockedTiers: Set<Int> = [1]  // Start with tier 1
    var unlockedUnits: Set<String> = []

    // Timestamps
    var firstPlayDate: Date?
    var lastPlayDate: Date?

    // MARK: - Level Completion

    mutating func completeLevel(_ levelId: Int, stats: LevelCompletionStats, isInsane: Bool) {
        if isInsane {
            insaneCompletedLevels.insert(levelId)
            // Only update if better grade or first completion
            if let existing = insaneLevelStats[levelId] {
                if stats.grade.rawValue < existing.grade.rawValue ||
                   (stats.grade == existing.grade && stats.ticksToComplete < existing.ticksToComplete) {
                    insaneLevelStats[levelId] = stats
                }
            } else {
                insaneLevelStats[levelId] = stats
            }
        } else {
            completedLevels.insert(levelId)
            if let existing = levelStats[levelId] {
                if stats.grade.rawValue < existing.grade.rawValue ||
                   (stats.grade == existing.grade && stats.ticksToComplete < existing.ticksToComplete) {
                    levelStats[levelId] = stats
                }
            } else {
                levelStats[levelId] = stats
            }
        }

        // Update lifetime stats
        lifetimeStats.totalCreditsEarned += stats.creditsEarned
        lifetimeStats.totalAttacksSurvived += stats.attacksSurvived
        lifetimeStats.totalDamageBlocked += stats.damageBlocked
        lifetimeStats.totalPlaytimeTicks += stats.ticksToComplete
        lifetimeStats.totalLevelsCompleted += 1
        if isInsane {
            lifetimeStats.totalInsaneLevelsCompleted += 1
        }
        // Track highest defense points achieved
        if stats.finalDefensePoints > lifetimeStats.highestDefensePoints {
            lifetimeStats.highestDefensePoints = stats.finalDefensePoints
        }
        // Track intel reports sent
        lifetimeStats.totalIntelReportsSent += stats.intelReportsSent

        lastPlayDate = Date()
    }

    // MARK: - Unit Unlocks

    /// Record that a unit was unlocked (persists across campaign levels)
    mutating func unlockUnit(_ unitId: String) {
        unlockedUnits.insert(unitId)
    }

    // MARK: - Unlock Checks

    func isLevelUnlocked(_ levelId: Int, database: LevelDatabase) -> Bool {
        guard let level = database.level(forId: levelId) else { return false }
        return level.unlockRequirement.isSatisfied(by: self)
    }

    func isInsaneModeUnlocked(for levelId: Int) -> Bool {
        // Must complete normal mode first
        completedLevels.contains(levelId)
    }

    // MARK: - Progress Summary

    var totalStars: Int {
        // 3 stars per level: 1 for complete, 1 for grade A+, 1 for insane
        var stars = 0
        for levelId in completedLevels {
            stars += 1  // Completion star
            if let stats = levelStats[levelId], stats.grade == .s || stats.grade == .a {
                stars += 1  // Grade star
            }
            if insaneCompletedLevels.contains(levelId) {
                stars += 1  // Insane star
            }
        }
        return stars
    }

    var campaignProgress: Double {
        // Percentage of levels completed (normal mode) - 20 total levels
        Double(completedLevels.count) / 20.0
    }

    var fullCompletionProgress: Double {
        // Percentage including insane mode (40 total completions)
        Double(completedLevels.count + insaneCompletedLevels.count) / 40.0
    }

    // MARK: - Next Level

    func nextUnlockedLevel(database: LevelDatabase) -> Int? {
        for id in 1...7 {
            if !completedLevels.contains(id) && isLevelUnlocked(id, database: database) {
                return id
            }
        }
        return nil
    }
}

// MARK: - Lifetime Stats

struct LifetimeStats: Codable {
    var totalCreditsEarned: Double = 0
    var totalAttacksSurvived: Int = 0
    var totalDamageBlocked: Double = 0
    var totalPlaytimeTicks: Int = 0
    var totalLevelsCompleted: Int = 0
    var totalInsaneLevelsCompleted: Int = 0
    var totalDeaths: Int = 0
    var totalIntelReportsSent: Int = 0
    var highestDefensePoints: Int = 0

    var playtimeFormatted: String {
        let totalSeconds = totalPlaytimeTicks  // 1 tick = 1 second
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Campaign Save Manager

@MainActor
class CampaignSaveManager {
    static let shared = CampaignSaveManager()

    private let progressKey = "GridWatchZero.CampaignProgress.v1"

    private init() {}

    // MARK: - Save/Load

    func save(_ progress: CampaignProgress) {
        do {
            let data = try JSONEncoder().encode(progress)
            UserDefaults.standard.set(data, forKey: progressKey)
            // Force immediate write to disk (deprecated but ensures persistence)
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to save campaign progress: \(error)")
        }
    }

    func load() -> CampaignProgress {
        guard let data = UserDefaults.standard.data(forKey: progressKey) else {
            return CampaignProgress()
        }

        do {
            return try JSONDecoder().decode(CampaignProgress.self, from: data)
        } catch {
            print("Failed to load campaign progress: \(error)")
            return CampaignProgress()
        }
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: progressKey)
    }

    // MARK: - Quick Checks

    var hasSaveData: Bool {
        UserDefaults.standard.data(forKey: progressKey) != nil
    }
}

// MARK: - Campaign State (Observable)

import Combine

@MainActor
class CampaignState: ObservableObject {
    @Published var progress: CampaignProgress
    @Published var currentLevel: CampaignLevel?
    @Published var levelState: LevelState = .notStarted

    private let database: LevelDatabase

    init(database: LevelDatabase? = nil) {
        self.database = database ?? LevelDatabase.shared
        self.progress = CampaignSaveManager.shared.load()

        // Set first play date if new
        if progress.firstPlayDate == nil {
            progress.firstPlayDate = Date()
            save()
        }
    }

    // MARK: - Level Management

    func startLevel(_ levelId: Int, isInsane: Bool = false) {
        guard let level = database.level(forId: levelId) else { return }
        guard progress.isLevelUnlocked(levelId, database: database) else { return }
        guard !isInsane || progress.isInsaneModeUnlocked(for: levelId) else { return }

        currentLevel = level
        progress.currentLevelId = levelId
        progress.isInsaneMode = isInsane
        levelState = .inProgress(startTick: 0)
        save()
    }

    func completeCurrentLevel(stats: LevelCompletionStats) {
        guard let level = currentLevel else { return }

        // CRITICAL: Complete level and add to completed set
        progress.completeLevel(level.id, stats: stats, isInsane: progress.isInsaneMode)
        levelState = .victory(stats: stats)

        // Unlock next tier if available
        if let nextTier = level.availableTiers.max(), nextTier + 1 <= 6 {
            progress.unlockedTiers.insert(nextTier + 1)
        }

        // Log for debugging
        print("[CampaignState] Level \(level.id) completed. Completed levels: \(progress.completedLevels)")

        // Save immediately and synchronously
        save()

        // Double-check save was successful
        let reloaded = CampaignSaveManager.shared.load()
        print("[CampaignState] After save, reloaded completed levels: \(reloaded.completedLevels)")
    }

    func failCurrentLevel(reason: FailureReason) {
        guard currentLevel != nil else { return }

        levelState = .failed(reason: reason)
        progress.lifetimeStats.totalDeaths += 1
        save()
    }

    func abandonCurrentLevel() {
        levelState = .abandoned
        currentLevel = nil
        progress.currentLevelId = nil
        progress.activeCheckpoint = nil  // Clear checkpoint on abandon
        save()
    }

    func returnToHub(clearCheckpoint: Bool = false) {
        currentLevel = nil
        levelState = .notStarted

        // Force a reload from disk to ensure we have latest saved state
        // This ensures any saves from level completion are reflected
        // CRITICAL: We must replace the entire progress struct (not just fields)
        // to properly trigger @Published and update SwiftUI views
        var freshProgress = CampaignSaveManager.shared.load()

        // Clear the current level state on the fresh copy
        freshProgress.currentLevelId = nil

        // Only clear checkpoint if explicitly requested (e.g., level complete/fail)
        // Keep checkpoint if user chose "Save & Exit"
        if clearCheckpoint {
            freshProgress.activeCheckpoint = nil
        }

        // Replace the entire struct - this properly triggers @Published
        progress = freshProgress

        print("[CampaignState] Returned to hub. Completed levels: \(progress.completedLevels), checkpoint: \(progress.activeCheckpoint != nil ? "saved" : "none")")
    }

    // MARK: - Unit Unlocks

    /// Record a unit unlock and persist it
    func unlockUnit(_ unitId: String) {
        progress.unlockUnit(unitId)
        save()
    }

    // MARK: - Queries

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        progress.isLevelUnlocked(levelId, database: database)
    }

    func isLevelCompleted(_ levelId: Int) -> Bool {
        progress.completedLevels.contains(levelId)
    }

    func isInsaneCompleted(_ levelId: Int) -> Bool {
        progress.insaneCompletedLevels.contains(levelId)
    }

    func statsForLevel(_ levelId: Int, isInsane: Bool = false) -> LevelCompletionStats? {
        isInsane ? progress.insaneLevelStats[levelId] : progress.levelStats[levelId]
    }

    var allLevels: [CampaignLevel] {
        database.allLevels
    }

    // MARK: - Checkpoint Management

    /// Check if there's a valid checkpoint for a level
    func hasValidCheckpoint(for levelId: Int, isInsane: Bool) -> Bool {
        guard let checkpoint = progress.activeCheckpoint else { return false }
        return checkpoint.levelId == levelId &&
               checkpoint.isInsane == isInsane &&
               checkpoint.isValid
    }

    /// Get the active checkpoint if valid
    func validCheckpoint(for levelId: Int, isInsane: Bool) -> LevelCheckpoint? {
        guard hasValidCheckpoint(for: levelId, isInsane: isInsane) else { return nil }
        return progress.activeCheckpoint
    }

    /// Clear any active checkpoint
    func clearCheckpoint() {
        progress.activeCheckpoint = nil
        save()
    }

    // MARK: - Persistence

    func save() {
        progress.lastPlayDate = Date()
        CampaignSaveManager.shared.save(progress)

        // Also sync to cloud
        // TODO: Pass actual story state - currently creates empty StoryState which doesn't sync story progress
        // Story state is managed by NavigationCoordinator, so this would need architectural refactoring
        CloudSaveManager.shared.uploadProgress(progress, storyState: StoryState())
    }

    func resetProgress() {
        CampaignSaveManager.shared.reset()
        progress = CampaignProgress()
        progress.firstPlayDate = Date()
        currentLevel = nil
        levelState = .notStarted
    }
}
