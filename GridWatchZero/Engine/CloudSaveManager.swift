// CloudSaveManager.swift
// GridWatchZero
// iCloud sync for campaign progress using NSUbiquitousKeyValueStore

import Foundation
import Combine
import os.log

// MARK: - Cloud Save Logger

private let cloudLogger = Logger(subsystem: "GridWatchZero", category: "CloudSync")

// MARK: - Cloud Save Status

enum CloudSaveStatus: Equatable {
    case available
    case unavailable(reason: String)
    case syncing
    case synced(lastSync: Date)
    case conflict(localDate: Date, cloudDate: Date)
    case error(message: String)

    var isAvailable: Bool {
        if case .available = self { return true }
        if case .synced = self { return true }
        if case .syncing = self { return true }
        return false
    }

    var displayText: String {
        switch self {
        case .available:
            return "iCloud Ready"
        case .unavailable(let reason):
            return reason
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return "Synced \(formatter.localizedString(for: date, relativeTo: Date()))"
        case .conflict:
            return "Sync Conflict"
        case .error(let message):
            return message
        }
    }
}

// MARK: - Syncable Data

struct SyncableProgress: Codable {
    let progress: CampaignProgress
    let storyState: StoryState
    let timestamp: Date
    let deviceId: String

    static var currentDeviceId: String {
        if let id = UserDefaults.standard.string(forKey: "GridWatchZero.DeviceId") {
            return id
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "GridWatchZero.DeviceId")
        return newId
    }

    init(progress: CampaignProgress, storyState: StoryState) {
        self.progress = progress
        self.storyState = storyState
        self.timestamp = Date()
        self.deviceId = Self.currentDeviceId
    }
}

// MARK: - Cloud Save Manager

@MainActor
class CloudSaveManager: ObservableObject {
    @MainActor static let shared = CloudSaveManager()

    // Published state
    @Published private(set) var status: CloudSaveStatus = .unavailable(reason: "Checking...")
    @Published private(set) var lastSyncDate: Date?
    @Published var pendingConflict: SyncConflict?

    // iCloud store
    private let cloudStore = NSUbiquitousKeyValueStore.default
    private let cloudKey = "GridWatchZero.SyncableProgress.v1"

    // Local keys
    private let localTimestampKey = "GridWatchZero.LastCloudSync"

    // Observers
    private var changeObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupCloudSync()
    }

    deinit {
        if let observer = changeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Setup

    private func setupCloudSync() {
        cloudLogger.info("🔵 setupCloudSync() started")
        
        // Check if iCloud is available
        let token = FileManager.default.ubiquityIdentityToken
        guard token != nil else {
            cloudLogger.error("❌ iCloud unavailable: ubiquityIdentityToken is nil")
            status = .unavailable(reason: "iCloud not signed in")
            return
        }
        cloudLogger.info("✅ iCloud token present")

        // Register for external changes
        changeObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore,
            queue: .main
        ) { [weak self] notification in
            // Extract only the change reason (Int) to avoid Sendable issues with [AnyHashable: Any]
            let changeReason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
            cloudLogger.info("📨 External change notification received, reason: \(changeReason ?? -1)")
            Task { @MainActor [weak self] in
                self?.handleExternalChange(reason: changeReason)
            }
        }
        cloudLogger.info("✅ External change observer registered")

        // Synchronize to get latest data
        let synchronized = cloudStore.synchronize()
        cloudLogger.info("🔄 cloudStore.synchronize() returned: \(synchronized)")

        if synchronized {
            status = .available
            // Check for existing cloud data
            if let existingData = cloudStore.data(forKey: cloudKey) {
                cloudLogger.info("✅ Found existing cloud data: \(existingData.count) bytes")
                lastSyncDate = UserDefaults.standard.object(forKey: localTimestampKey) as? Date
                if let date = lastSyncDate {
                    status = .synced(lastSync: date)
                    cloudLogger.info("✅ Status: synced, lastSync: \(date)")
                }
            } else {
                cloudLogger.info("ℹ️ No existing cloud data found (first sync)")
            }
        } else {
            cloudLogger.error("❌ cloudStore.synchronize() returned false")
            status = .unavailable(reason: "iCloud sync failed")
        }
        
        cloudLogger.info("🔵 setupCloudSync() completed, status: \(self.status.displayText)")
    }

    // MARK: - Sync Operations

    /// Upload current progress to iCloud
    func uploadProgress(_ progress: CampaignProgress, storyState: StoryState) {
        cloudLogger.info("📤 uploadProgress() called, levels: \(progress.completedLevels.count)")
        
        guard status.isAvailable else {
            cloudLogger.warning("⚠️ Upload skipped: status not available (\(self.status.displayText))")
            return
        }

        status = .syncing

        let syncable = SyncableProgress(progress: progress, storyState: storyState)

        do {
            let data = try JSONEncoder().encode(syncable)
            cloudLogger.info("📦 Encoded data: \(data.count) bytes")
            cloudStore.set(data, forKey: cloudKey)

            // Force sync
            let syncResult = cloudStore.synchronize()
            cloudLogger.info("🔄 Upload synchronize() returned: \(syncResult)")
            
            if syncResult {
                let now = Date()
                UserDefaults.standard.set(now, forKey: localTimestampKey)
                lastSyncDate = now
                status = .synced(lastSync: now)
                cloudLogger.info("✅ Upload successful at \(now)")
            } else {
                cloudLogger.error("❌ Upload failed: synchronize() returned false")
                status = .error(message: "Upload failed")
            }
        } catch {
            cloudLogger.error("❌ Encoding failed: \(error.localizedDescription)")
            status = .error(message: "Encoding failed")
        }
    }

    /// Download progress from iCloud
    func downloadProgress() -> SyncableProgress? {
        cloudLogger.info("📥 downloadProgress() called")
        
        guard let data = cloudStore.data(forKey: cloudKey) else {
            cloudLogger.info("ℹ️ No cloud data found for key: \(self.cloudKey)")
            return nil
        }
        
        cloudLogger.info("📦 Found cloud data: \(data.count) bytes")

        do {
            let decoded = try JSONDecoder().decode(SyncableProgress.self, from: data)
            cloudLogger.info("✅ Decoded successfully: \(decoded.progress.completedLevels.count) levels, device: \(decoded.deviceId.prefix(8))...")
            return decoded
        } catch {
            cloudLogger.error("❌ Decoding failed: \(error.localizedDescription)")
            status = .error(message: "Decoding failed")
            return nil
        }
    }

    /// Sync with conflict resolution
    func syncProgress(local: CampaignProgress, localStory: StoryState) async -> SyncResult {
        guard status.isAvailable else {
            return .offline
        }

        status = .syncing

        // Force download latest
        cloudStore.synchronize()

        guard let cloudData = downloadProgress() else {
            // No cloud data - upload local
            uploadProgress(local, storyState: localStory)
            return .uploaded
        }

        // Compare timestamps
        let localDate = local.lastPlayDate ?? Date.distantPast
        let cloudDate = cloudData.timestamp

        // Check for conflict (both modified recently)
        let timeDiff = abs(localDate.timeIntervalSince(cloudDate))
        let recentThreshold: TimeInterval = 60 // 1 minute

        if timeDiff < recentThreshold && cloudData.deviceId != SyncableProgress.currentDeviceId {
            // Potential conflict - let user decide
            pendingConflict = SyncConflict(
                localProgress: local,
                localStory: localStory,
                localDate: localDate,
                cloudProgress: cloudData.progress,
                cloudStory: cloudData.storyState,
                cloudDate: cloudDate,
                cloudDevice: cloudData.deviceId
            )
            status = .conflict(localDate: localDate, cloudDate: cloudDate)
            return .conflict
        }

        // Latest timestamp wins
        if localDate > cloudDate {
            // Local is newer - upload
            uploadProgress(local, storyState: localStory)
            return .uploaded
        } else {
            // Cloud is newer - download
            let now = Date()
            UserDefaults.standard.set(now, forKey: localTimestampKey)
            lastSyncDate = now
            status = .synced(lastSync: now)
            return .downloaded(progress: cloudData.progress, storyState: cloudData.storyState)
        }
    }

    /// Resolve a conflict by choosing local or cloud
    func resolveConflict(useLocal: Bool) {
        guard let conflict = pendingConflict else { return }

        if useLocal {
            uploadProgress(conflict.localProgress, storyState: conflict.localStory)
        } else {
            let now = Date()
            UserDefaults.standard.set(now, forKey: localTimestampKey)
            lastSyncDate = now
            status = .synced(lastSync: now)
        }

        pendingConflict = nil
    }

    // MARK: - External Change Handling

    private func handleExternalChange(reason: Int?) {
        guard let changeReason = reason else {
            return
        }

        switch changeReason {
        case NSUbiquitousKeyValueStoreServerChange:
            // Data changed on server - notify interested parties
            NotificationCenter.default.post(
                name: .cloudDataChanged,
                object: nil,
                userInfo: ["cloudData": downloadProgress() as Any]
            )

        case NSUbiquitousKeyValueStoreInitialSyncChange:
            // Initial sync completed
            if let data = downloadProgress() {
                status = .synced(lastSync: data.timestamp)
            }

        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            status = .error(message: "iCloud quota exceeded")

        case NSUbiquitousKeyValueStoreAccountChange:
            // Account changed - re-setup
            setupCloudSync()

        default:
            break
        }
    }

    // MARK: - Utilities

    /// Check if iCloud is available
    var isCloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    /// Force a sync
    func forceSync() {
        cloudStore.synchronize()
    }

    /// Clear cloud data
    func clearCloudData() {
        cloudStore.removeObject(forKey: cloudKey)
        cloudStore.synchronize()
        status = .available
        lastSyncDate = nil
    }
}

// MARK: - Sync Result

enum SyncResult {
    case uploaded
    case downloaded(progress: CampaignProgress, storyState: StoryState)
    case conflict
    case offline
    case noChange
}

// MARK: - Sync Conflict

struct SyncConflict {
    let localProgress: CampaignProgress
    let localStory: StoryState
    let localDate: Date
    let cloudProgress: CampaignProgress
    let cloudStory: StoryState
    let cloudDate: Date
    let cloudDevice: String

    var localSummary: String {
        "Local: \(localProgress.completedLevels.count)/20 levels, \(localProgress.lifetimeStats.playtimeFormatted)"
    }

    var cloudSummary: String {
        "Cloud: \(cloudProgress.completedLevels.count)/20 levels, \(cloudProgress.lifetimeStats.playtimeFormatted)"
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let cloudDataChanged = Notification.Name("GridWatchZero.CloudDataChanged")
}

