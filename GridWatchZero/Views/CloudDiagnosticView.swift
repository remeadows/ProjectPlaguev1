// CloudDiagnosticView.swift
// GridWatchZero
// Diagnostic view for troubleshooting iCloud sync issues

import SwiftUI

struct CloudDiagnosticView: View {
    @EnvironmentObject var cloudManager: CloudSaveManager
    @EnvironmentObject var campaignState: CampaignState
    
    @State private var diagnosticLog: [DiagnosticEntry] = []
    @State private var isRunningDiagnostics = false
    @State private var manualSyncResult: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Status
                    statusHeader
                    
                    // Quick Diagnostics
                    quickDiagnosticsSection
                    
                    // Cloud Manager State
                    cloudManagerSection
                    
                    // Device Info
                    deviceInfoSection
                    
                    // Actions
                    actionsSection
                    
                    // Diagnostic Log
                    diagnosticLogSection
                }
                .padding()
            }
            .background(Color.terminalBlack)
            .navigationTitle("iCloud Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.terminalDarkGray, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            runQuickDiagnostics()
        }
    }
    
    // MARK: - Status Header
    
    private var statusHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.system(size: 48))
                .foregroundColor(statusColor)
            
            Text(statusTitle)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(cloudManager.status.displayText)
                .font(.caption)
                .foregroundColor(.terminalGray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.terminalDarkGray)
        .cornerRadius(12)
    }
    
    private var statusIcon: String {
        switch cloudManager.status {
        case .available, .synced:
            return "checkmark.icloud.fill"
        case .syncing:
            return "arrow.triangle.2.circlepath.icloud.fill"
        case .unavailable:
            return "xmark.icloud.fill"
        case .conflict:
            return "exclamationmark.icloud.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var statusColor: Color {
        switch cloudManager.status {
        case .available, .synced:
            return .neonGreen
        case .syncing:
            return .neonCyan
        case .unavailable, .error:
            return .neonRed
        case .conflict:
            return .neonAmber
        }
    }
    
    private var statusTitle: String {
        switch cloudManager.status {
        case .available:
            return "iCloud Available"
        case .synced:
            return "iCloud Synced"
        case .syncing:
            return "Syncing..."
        case .unavailable:
            return "iCloud Unavailable"
        case .conflict:
            return "Sync Conflict"
        case .error:
            return "Sync Error"
        }
    }
    
    // MARK: - Quick Diagnostics
    
    private var quickDiagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Quick Diagnostics")
            
            VStack(spacing: 8) {
                diagnosticRow(
                    "iCloud Token",
                    value: FileManager.default.ubiquityIdentityToken != nil ? "Present" : "Missing",
                    isGood: FileManager.default.ubiquityIdentityToken != nil
                )
                
                diagnosticRow(
                    "Cloud Available",
                    value: cloudManager.isCloudAvailable ? "Yes" : "No",
                    isGood: cloudManager.isCloudAvailable
                )
                
                diagnosticRow(
                    "Last Sync",
                    value: cloudManager.lastSyncDate?.formatted() ?? "Never",
                    isGood: cloudManager.lastSyncDate != nil
                )
                
                diagnosticRow(
                    "Pending Conflict",
                    value: cloudManager.pendingConflict != nil ? "Yes" : "No",
                    isGood: cloudManager.pendingConflict == nil
                )
            }
            .padding()
            .background(Color.terminalDarkGray)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Cloud Manager Section
    
    private var cloudManagerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("CloudSaveManager State")
            
            VStack(alignment: .leading, spacing: 8) {
                infoRow("Status", cloudManager.status.displayText)
                infoRow("Is Available", cloudManager.status.isAvailable ? "Yes" : "No")
                
                if let lastSync = cloudManager.lastSyncDate {
                    infoRow("Last Sync", lastSync.formatted(date: .abbreviated, time: .standard))
                }
                
                if let conflict = cloudManager.pendingConflict {
                    Divider().background(Color.terminalGray)
                    Text("⚠️ CONFLICT DETECTED")
                        .font(.caption.bold())
                        .foregroundColor(.neonAmber)
                    infoRow("Local", conflict.localSummary)
                    infoRow("Cloud", conflict.cloudSummary)
                }
            }
            .padding()
            .background(Color.terminalDarkGray)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Device Info
    
    private var deviceInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Device Info")
            
            VStack(alignment: .leading, spacing: 8) {
                infoRow("Device ID", String(SyncableProgress.currentDeviceId.prefix(8)) + "...")
                infoRow("Bundle ID", Bundle.main.bundleIdentifier ?? "Unknown")
                infoRow("App Version", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                infoRow("Build", Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                
                Divider().background(Color.terminalGray)
                
                infoRow("Completed Levels", "\(campaignState.progress.completedLevels.count)/20")
                infoRow("Insane Completed", "\(campaignState.progress.insaneCompletedLevels.count)/20")
            }
            .padding()
            .background(Color.terminalDarkGray)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Actions
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Actions")
            
            VStack(spacing: 12) {
                // Force Sync Button
                Button(action: performManualSync) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Force Sync Now")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.neonCyan.opacity(0.2))
                    .foregroundColor(.neonCyan)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neonCyan, lineWidth: 1)
                    )
                }
                
                // Run Full Diagnostics
                Button(action: runFullDiagnostics) {
                    HStack {
                        if isRunningDiagnostics {
                            ProgressView()
                                .tint(.neonGreen)
                        } else {
                            Image(systemName: "stethoscope")
                        }
                        Text(isRunningDiagnostics ? "Running..." : "Run Full Diagnostics")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.neonGreen.opacity(0.2))
                    .foregroundColor(.neonGreen)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neonGreen, lineWidth: 1)
                    )
                }
                .disabled(isRunningDiagnostics)
                
                // Test Write/Read
                Button(action: testWriteRead) {
                    HStack {
                        Image(systemName: "doc.badge.gearshape")
                        Text("Test KV Store Write/Read")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.neonAmber.opacity(0.2))
                    .foregroundColor(.neonAmber)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neonAmber, lineWidth: 1)
                    )
                }
                
                if let result = manualSyncResult {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(result.contains("✅") ? .neonGreen : .neonRed)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.terminalDarkGray)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.terminalDarkGray)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Diagnostic Log
    
    private var diagnosticLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Diagnostic Log")
                Spacer()
                Button("Clear") {
                    diagnosticLog.removeAll()
                }
                .font(.caption)
                .foregroundColor(.neonRed)
            }
            
            if diagnosticLog.isEmpty {
                Text("No diagnostics run yet. Tap 'Run Full Diagnostics' above.")
                    .font(.caption)
                    .foregroundColor(.terminalGray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.terminalDarkGray)
                    .cornerRadius(8)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(diagnosticLog) { entry in
                        HStack(alignment: .top, spacing: 8) {
                            Text(entry.icon)
                                .font(.caption)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                Text(entry.detail)
                                    .font(.caption2)
                                    .foregroundColor(.terminalGray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
                        if entry.id != diagnosticLog.last?.id {
                            Divider().background(Color.terminalGray.opacity(0.5))
                        }
                    }
                }
                .padding()
                .background(Color.terminalDarkGray)
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.bold())
            .foregroundColor(.neonCyan)
            .tracking(1)
    }
    
    private func diagnosticRow(_ title: String, value: String, isGood: Bool) -> some View {
        HStack {
            Image(systemName: isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isGood ? .neonGreen : .neonRed)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(isGood ? .neonGreen : .neonRed)
                .font(.caption.monospaced())
        }
        .font(.caption)
    }
    
    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.terminalGray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .font(.caption.monospaced())
        }
        .font(.caption)
    }
    
    // MARK: - Actions
    
    private func runQuickDiagnostics() {
        // Run on appear
    }
    
    private func runFullDiagnostics() {
        isRunningDiagnostics = true
        diagnosticLog.removeAll()
        
        // 1. Check iCloud Token
        let hasToken = FileManager.default.ubiquityIdentityToken != nil
        addLogEntry(
            hasToken ? "✅" : "❌",
            "iCloud Identity Token",
            hasToken ? "Token present - user is signed into iCloud" : "Token MISSING - user NOT signed into iCloud on this device"
        )
        
        // 2. Check CloudSaveManager availability
        addLogEntry(
            cloudManager.isCloudAvailable ? "✅" : "❌",
            "CloudSaveManager.isCloudAvailable",
            cloudManager.isCloudAvailable ? "Cloud manager reports available" : "Cloud manager reports UNAVAILABLE"
        )
        
        // 3. Check current status
        addLogEntry(
            cloudManager.status.isAvailable ? "✅" : "⚠️",
            "Current Status",
            cloudManager.status.displayText
        )
        
        // 4. Test NSUbiquitousKeyValueStore sync
        let store = NSUbiquitousKeyValueStore.default
        let syncResult = store.synchronize()
        addLogEntry(
            syncResult ? "✅" : "❌",
            "NSUbiquitousKeyValueStore.synchronize()",
            syncResult ? "Sync call returned TRUE" : "Sync call returned FALSE - iCloud KV store not syncing"
        )
        
        // 5. Check for existing cloud data
        let cloudKey = "GridWatchZero.SyncableProgress.v1"
        let hasCloudData = store.data(forKey: cloudKey) != nil
        addLogEntry(
            hasCloudData ? "✅" : "ℹ️",
            "Existing Cloud Data",
            hasCloudData ? "Found saved progress in iCloud" : "No saved progress found in iCloud (may be first sync)"
        )
        
        // 6. Check local progress
        let localLevels = campaignState.progress.completedLevels.count
        addLogEntry(
            "ℹ️",
            "Local Progress",
            "\(localLevels) levels completed locally"
        )
        
        // 7. Check bundle identifier
        let bundleId = Bundle.main.bundleIdentifier ?? "UNKNOWN"
        addLogEntry(
            bundleId.contains("GridWatchZero") ? "✅" : "⚠️",
            "Bundle Identifier",
            bundleId
        )
        
        // 8. Summary
        let issues = diagnosticLog.filter { $0.icon == "❌" }.count
        if issues == 0 {
            addLogEntry(
                "🎉",
                "DIAGNOSIS COMPLETE",
                "No critical issues found. If sync still fails, check device Settings → iCloud → Apps Using iCloud"
            )
        } else {
            addLogEntry(
                "🔴",
                "DIAGNOSIS COMPLETE",
                "\(issues) critical issue(s) found. See entries marked with ❌ above."
            )
        }
        
        isRunningDiagnostics = false
    }
    
    private func performManualSync() {
        manualSyncResult = nil
        
        Task {
            // Use empty StoryState for sync test - cloud will have the real one
            let result = await cloudManager.syncProgress(
                local: campaignState.progress,
                localStory: StoryState()
            )
            
            await MainActor.run {
                switch result {
                case .uploaded:
                    manualSyncResult = "✅ Uploaded local progress to iCloud"
                case .downloaded(let progress, _):
                    manualSyncResult = "✅ Downloaded from iCloud: \(progress.completedLevels.count) levels"
                case .conflict:
                    manualSyncResult = "⚠️ Sync conflict detected - resolve in UI"
                case .offline:
                    manualSyncResult = "❌ Offline - iCloud not available"
                case .noChange:
                    manualSyncResult = "ℹ️ No changes to sync"
                }
            }
        }
    }
    
    private func testWriteRead() {
        let store = NSUbiquitousKeyValueStore.default
        let testKey = "GridWatchZero.DiagnosticTest"
        let testValue = "test_\(Date().timeIntervalSince1970)"
        
        // Write
        store.set(testValue, forKey: testKey)
        let syncWrite = store.synchronize()
        
        // Small delay then read
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let readValue = store.string(forKey: testKey)
            
            if readValue == testValue {
                manualSyncResult = "✅ Write/Read test PASSED: '\(testValue)'"
                addLogEntry("✅", "KV Store Test", "Write and read successful")
            } else if readValue != nil {
                manualSyncResult = "⚠️ Read different value: '\(readValue ?? "nil")'"
                addLogEntry("⚠️", "KV Store Test", "Value mismatch - possible sync lag")
            } else {
                manualSyncResult = "❌ Write/Read test FAILED: sync=\(syncWrite), read=nil"
                addLogEntry("❌", "KV Store Test", "Failed to read back written value")
            }
            
            // Cleanup
            store.removeObject(forKey: testKey)
        }
    }
    
    private func addLogEntry(_ icon: String, _ title: String, _ detail: String) {
        diagnosticLog.append(DiagnosticEntry(icon: icon, title: title, detail: detail))
    }
}

// MARK: - Supporting Types

struct DiagnosticEntry: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

// MARK: - Preview

#Preview {
    CloudDiagnosticView()
        .environmentObject(CloudSaveManager.shared)
        .environmentObject(CampaignState())
}
