// PlayerProfileView.swift
// GridWatchZero
// Player profile with lifetime stats and iCloud sync status

import SwiftUI

// MARK: - Player Profile View

struct PlayerProfileView: View {
    @ObservedObject var campaignState: CampaignState
    @StateObject private var cloudManager = CloudSaveManager.shared
    @StateObject private var certificateManager = CertificateManager.shared
    @State private var showSyncConfirm = false
    @State private var showResetConfirm = false
    @State private var isRefreshing = false
    @State private var showCertificatesView = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection

                    // Cloud sync section
                    cloudSyncSection

                    // Campaign progress
                    campaignProgressSection

                    // Certificates section
                    certificatesSection

                    // Lifetime stats
                    lifetimeStatsSection

                    // Achievements summary
                    achievementsSummarySection

                    // Account actions
                    accountActionsSection
                }
                .padding(20)
            }
        }
        .alert("Sync Conflict", isPresented: .constant(cloudManager.pendingConflict != nil)) {
            Button("Use Local") {
                cloudManager.resolveConflict(useLocal: true)
            }
            Button("Use Cloud") {
                cloudManager.resolveConflict(useLocal: false)
                if let cloudProgress = cloudManager.pendingConflict?.cloudProgress {
                    campaignState.progress = cloudProgress
                    campaignState.save()
                }
            }
        } message: {
            if let conflict = cloudManager.pendingConflict {
                Text("\(conflict.localSummary)\n\(conflict.cloudSummary)\n\nWhich version would you like to keep?")
            }
        }
        .alert("Reset Progress?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                campaignState.resetProgress()
                cloudManager.clearCloudData()
            }
        } message: {
            Text("This will permanently delete all campaign progress and cannot be undone.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("PLAYER PROFILE")
                    .font(.terminalLarge)
                    .foregroundColor(.neonGreen)

                Text("Network Operator Stats")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.terminalGray)
                    .padding(8)
            }
            .accessibilityLabel("Close profile")
        }
    }

    // MARK: - Cloud Sync Section

    private var cloudSyncSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "CLOUD SYNC", icon: "icloud")

            VStack(spacing: 12) {
                // Status row
                HStack {
                    cloudStatusIcon
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(cloudManager.status.displayText)
                            .font(.terminalBody)
                            .foregroundColor(cloudStatusColor)

                        if cloudManager.isCloudAvailable {
                            Text("Progress syncs across all your devices")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                        } else {
                            Text("Sign in to iCloud in Settings to enable sync")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                        }
                    }

                    Spacer()

                    if cloudManager.isCloudAvailable {
                        Button {
                            syncNow()
                        } label: {
                            if isRefreshing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .neonCyan))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.terminalBody)
                                    .foregroundColor(.neonCyan)
                            }
                        }
                        .disabled(isRefreshing)
                        .accessibilityLabel("Sync now")
                    }
                }
            }
            .padding(16)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(cloudStatusColor.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var cloudStatusIcon: some View {
        Group {
            switch cloudManager.status {
            case .available, .synced:
                Image(systemName: "checkmark.icloud")
                    .foregroundColor(.neonGreen)
            case .syncing:
                Image(systemName: "icloud")
                    .foregroundColor(.neonCyan)
            case .unavailable:
                Image(systemName: "icloud.slash")
                    .foregroundColor(.terminalGray)
            case .conflict:
                Image(systemName: "exclamationmark.icloud")
                    .foregroundColor(.neonAmber)
            case .error:
                Image(systemName: "xmark.icloud")
                    .foregroundColor(.neonRed)
            }
        }
        .font(.title3)
    }

    private var cloudStatusColor: Color {
        switch cloudManager.status {
        case .available, .synced: return .neonGreen
        case .syncing: return .neonCyan
        case .unavailable: return .terminalGray
        case .conflict: return .neonAmber
        case .error: return .neonRed
        }
    }

    // MARK: - Campaign Progress Section

    private var campaignProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "CAMPAIGN", icon: "flag.fill")

            VStack(spacing: 16) {
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Story Progress")
                            .font(.terminalSmall)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text("\(Int(campaignState.progress.campaignProgress * 100))%")
                            .font(.terminalTitle)
                            .foregroundColor(.neonGreen)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.terminalDarkGray)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.neonGreen)
                                .frame(width: geo.size.width * campaignState.progress.campaignProgress)
                        }
                    }
                    .frame(height: 8)
                }

                // Stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ProfileStatCell(
                        value: "\(campaignState.progress.completedLevels.count)",
                        label: "Levels",
                        sublabel: "of 20",
                        color: .neonGreen
                    )

                    ProfileStatCell(
                        value: "\(campaignState.progress.insaneCompletedLevels.count)",
                        label: "Insane",
                        sublabel: "of 20",
                        color: .neonRed
                    )

                    ProfileStatCell(
                        value: "\(campaignState.progress.totalStars)",
                        label: "Stars",
                        sublabel: "of 60",
                        color: .neonAmber
                    )
                }

                // Best grades - scrollable for 20 levels
                if !campaignState.progress.levelStats.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(1...20, id: \.self) { levelId in
                                if let stats = campaignState.progress.levelStats[levelId] {
                                    GradeBadge(level: levelId, grade: stats.grade)
                                } else if campaignState.isLevelUnlocked(levelId) {
                                    GradeBadge(level: levelId, grade: nil)
                                } else {
                                    LockedBadge(level: levelId)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
        }
    }

    // MARK: - Certificates Section

    private var certificatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "CERTIFICATIONS", icon: "checkmark.seal.fill")

            VStack(spacing: 12) {
                // Summary badge
                CertificateSummaryBadge(certificateManager: certificateManager)

                // View all button
                Button {
                    showCertificatesView = true
                } label: {
                    HStack {
                        Text("View All Certificates")
                            .font(.terminalBody)
                            .foregroundColor(.neonCyan)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.neonCyan.opacity(0.5))
                    }
                    .padding(14)
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .sheet(isPresented: $showCertificatesView) {
            CertificatesFullView(certificateManager: certificateManager)
        }
    }

    // MARK: - Lifetime Stats Section

    private var lifetimeStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "LIFETIME STATS", icon: "chart.bar.fill")

            VStack(spacing: 12) {
                StatRowLarge(
                    icon: "clock.fill",
                    label: "Total Playtime",
                    value: campaignState.progress.lifetimeStats.playtimeFormatted,
                    color: .neonCyan
                )

                StatRowLarge(
                    icon: "creditcard.fill",
                    label: "Credits Earned",
                    value: "₵\(campaignState.progress.lifetimeStats.totalCreditsEarned.formatted)",
                    color: .neonGreen
                )

                StatRowLarge(
                    icon: "shield.fill",
                    label: "Attacks Survived",
                    value: "\(campaignState.progress.lifetimeStats.totalAttacksSurvived)",
                    color: .neonAmber
                )

                StatRowLarge(
                    icon: "bolt.shield.fill",
                    label: "Damage Blocked",
                    value: campaignState.progress.lifetimeStats.totalDamageBlocked.formatted,
                    color: .neonCyan
                )

                StatRowLarge(
                    icon: "flag.checkered",
                    label: "Levels Completed",
                    value: "\(campaignState.progress.lifetimeStats.totalLevelsCompleted)",
                    color: .neonGreen
                )

                StatRowLarge(
                    icon: "xmark.circle.fill",
                    label: "Deaths",
                    value: "\(campaignState.progress.lifetimeStats.totalDeaths)",
                    color: .neonRed
                )
            }
            .padding(16)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
        }
    }

    // MARK: - Achievements Summary

    private var achievementsSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "ACHIEVEMENTS", icon: "trophy.fill")

            VStack(spacing: 12) {
                // Favorite defense setup (most used tier)
                if let favoriteTier = calculateFavoriteTier() {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.neonAmber)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Favorite Defense Tier")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text("Tier \(favoriteTier)")
                                .font(.terminalTitle)
                                .foregroundColor(.neonAmber)
                        }

                        Spacer()
                    }
                }

                // Average completion time
                if let avgTime = calculateAverageCompletionTime() {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.neonCyan)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Average Clear Time")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text(formatTime(avgTime))
                                .font(.terminalTitle)
                                .foregroundColor(.neonCyan)
                        }

                        Spacer()
                    }
                }

                // Best grade achieved
                if let bestGrade = calculateBestGrade() {
                    HStack {
                        Image(systemName: "rosette")
                            .foregroundColor(gradeColor(bestGrade))
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Best Grade Achieved")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text("Grade \(bestGrade.rawValue)")
                                .font(.terminalTitle)
                                .foregroundColor(gradeColor(bestGrade))
                        }

                        Spacer()
                    }
                }

                // First play date
                if let firstPlay = campaignState.progress.firstPlayDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.terminalGray)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("First Connected")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text(formatDate(firstPlay))
                                .font(.terminalBody)
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
        }
    }

    // MARK: - Account Actions

    private var accountActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "ACCOUNT", icon: "gearshape.fill")

            VStack(spacing: 8) {
                Button {
                    showResetConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.neonRed)
                        Text("Reset All Progress")
                            .font(.terminalBody)
                            .foregroundColor(.neonRed)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.neonRed.opacity(0.5))
                    }
                    .padding(14)
                    .background(Color.dimRed.opacity(0.3))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.neonRed.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func syncNow() {
        guard !isRefreshing else { return }

        isRefreshing = true

        Task {
            let result = await cloudManager.syncProgress(
                local: campaignState.progress,
                localStory: StoryState() // Get from NavigationCoordinator
            )

            switch result {
            case .downloaded(let progress, _):
                campaignState.progress = progress
                campaignState.save()
            default:
                break
            }

            isRefreshing = false
        }
    }

    private func calculateFavoriteTier() -> Int? {
        let stats = campaignState.progress.levelStats.values
        guard !stats.isEmpty else { return nil }

        // For now, return the highest tier used (based on completed levels)
        let highestLevel = campaignState.progress.completedLevels.max() ?? 1
        return min(highestLevel, 4) // Cap at tier 4
    }

    private func calculateAverageCompletionTime() -> Int? {
        let times = campaignState.progress.levelStats.values.map { $0.ticksToComplete }
        guard !times.isEmpty else { return nil }
        return times.reduce(0, +) / times.count
    }

    private func calculateBestGrade() -> LevelGrade? {
        let grades = campaignState.progress.levelStats.values.map { $0.grade }
        return grades.min(by: { $0.rawValue < $1.rawValue })
    }

    private func gradeColor(_ grade: LevelGrade) -> Color {
        switch grade {
        case .s: return .neonAmber
        case .a: return .neonGreen
        case .b: return .neonCyan
        case .c: return .terminalGray
        }
    }

    private func formatTime(_ ticks: Int) -> String {
        let minutes = ticks / 60
        let seconds = ticks % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct ProfileStatCell: View {
    let value: String
    let label: String
    let sublabel: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.terminalLarge)
                .foregroundColor(color)

            Text(label)
                .font(.terminalMicro)
                .foregroundColor(.white)

            Text(sublabel)
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.terminalBlack.opacity(0.5))
        .cornerRadius(4)
    }
}

struct StatRowLarge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.terminalBody)
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.terminalBody)
                .foregroundColor(.terminalGray)

            Spacer()

            Text(value)
                .font(.terminalTitle)
                .foregroundColor(.white)
        }
    }
}

struct GradeBadge: View {
    let level: Int
    let grade: LevelGrade?

    var body: some View {
        VStack(spacing: 2) {
            Text("\(level)")
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)

            if let grade = grade {
                Text(grade.rawValue)
                    .font(.terminalSmall)
                    .foregroundColor(gradeColor)
            } else {
                Text("-")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
            }
        }
        .frame(width: 36, height: 36)
        .background(Color.terminalBlack.opacity(0.5))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(grade != nil ? gradeColor.opacity(0.5) : Color.terminalGray.opacity(0.3), lineWidth: 1)
        )
    }

    private var gradeColor: Color {
        guard let grade = grade else { return .terminalGray }
        switch grade {
        case .s: return .neonAmber
        case .a: return .neonGreen
        case .b: return .neonCyan
        case .c: return .terminalGray
        }
    }
}

struct LockedBadge: View {
    let level: Int

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "lock.fill")
                .font(.terminalMicro)
                .foregroundColor(.terminalGray.opacity(0.5))
        }
        .frame(width: 36, height: 36)
        .background(Color.terminalBlack.opacity(0.3))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.terminalGray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    PlayerProfileView(campaignState: CampaignState())
}
