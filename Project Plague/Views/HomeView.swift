// HomeView.swift
// GridWatchZero
// Campaign home screen with level select, stats, and team info

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var campaignState: CampaignState
    @EnvironmentObject var cloudManager: CloudSaveManager
    @State private var selectedLevelId: Int?
    @State private var showTeamSheet = false
    @State private var showProfileSheet = false
    @State private var showSettingsSheet = false

    var onStartLevel: (CampaignLevel, Bool) -> Void  // (level, isInsane)
    var onPlayEndless: () -> Void

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Campaign section
                        campaignSection

                        // Endless mode
                        endlessModeSection

                        // Team section
                        teamSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
        }
        .sheet(item: $selectedLevelId) { levelId in
            if let level = LevelDatabase.shared.level(forId: levelId) {
                LevelDetailSheet(
                    level: level,
                    isUnlocked: campaignState.isLevelUnlocked(levelId),
                    isCompleted: campaignState.isLevelCompleted(levelId),
                    isInsaneCompleted: campaignState.isInsaneCompleted(levelId),
                    stats: campaignState.statsForLevel(levelId),
                    insaneStats: campaignState.statsForLevel(levelId, isInsane: true),
                    hasCheckpoint: campaignState.hasValidCheckpoint(for: levelId, isInsane: false),
                    onStartNormal: {
                        // Clear any existing checkpoint when starting fresh
                        campaignState.clearCheckpoint()
                        selectedLevelId = nil
                        onStartLevel(level, false)
                    },
                    onStartInsane: {
                        // Clear any existing checkpoint when starting insane
                        campaignState.clearCheckpoint()
                        selectedLevelId = nil
                        onStartLevel(level, true)
                    },
                    onResume: {
                        // Resume from checkpoint - don't clear it
                        selectedLevelId = nil
                        onStartLevel(level, false)
                    }
                )
            }
        }
        .sheet(isPresented: $showTeamSheet) {
            TeamRosterSheet()
        }
        .sheet(isPresented: $showProfileSheet) {
            PlayerProfileView(campaignState: campaignState)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("NEURAL GRID")
                    .font(.terminalLarge)
                    .foregroundColor(.neonGreen)
                Text("Campaign Hub")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            // Progress indicator with cloud sync status
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text("\(campaignState.progress.completedLevels.count)/7")
                        .font(.terminalTitle)
                        .foregroundColor(.neonCyan)

                    // Cloud sync indicator
                    cloudSyncIndicator
                }
                Text("COMPLETE")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            // Settings button
            Button {
                showSettingsSheet = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.neonCyan)
                    .padding(8)
            }
            .accessibilityLabel("Open settings")

            // Profile button
            Button {
                showProfileSheet = true
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundColor(.neonCyan)
                    .padding(8)
            }
            .accessibilityLabel("View player profile")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.terminalDarkGray)
    }

    // MARK: - Cloud Sync Indicator

    private var cloudSyncIndicator: some View {
        Group {
            switch cloudManager.status {
            case .synced:
                Image(systemName: "checkmark.icloud")
                    .font(.terminalMicro)
                    .foregroundColor(.neonGreen.opacity(0.6))
            case .syncing:
                Image(systemName: "icloud")
                    .font(.terminalMicro)
                    .foregroundColor(.neonCyan.opacity(0.6))
            case .conflict:
                Image(systemName: "exclamationmark.icloud")
                    .font(.terminalMicro)
                    .foregroundColor(.neonAmber)
            case .error:
                Image(systemName: "xmark.icloud")
                    .font(.terminalMicro)
                    .foregroundColor(.neonRed.opacity(0.6))
            default:
                EmptyView()
            }
        }
        .accessibilityLabel(cloudManager.status.displayText)
    }

    // MARK: - Campaign Section

    private var campaignSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "CAMPAIGN", icon: "flag.fill")

            LazyVStack(spacing: 8) {
                ForEach(LevelDatabase.shared.allLevels) { level in
                    LevelRowView(
                        level: level,
                        isUnlocked: campaignState.isLevelUnlocked(level.id),
                        isCompleted: campaignState.isLevelCompleted(level.id),
                        isInsaneCompleted: campaignState.isInsaneCompleted(level.id)
                    ) {
                        selectedLevelId = level.id
                    }
                }
            }
        }
    }

    // MARK: - Endless Mode Section

    private var endlessModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "ENDLESS", icon: "infinity")

            Button(action: onPlayEndless) {
                HStack(spacing: 12) {
                    Image(systemName: "waveform.path")
                        .font(.title2)
                        .foregroundColor(.neonAmber)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("ENDLESS MODE")
                            .font(.terminalTitle)
                            .foregroundColor(.neonAmber)
                        Text("Classic idle gameplay with no end condition")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.neonAmber.opacity(0.5))
                }
                .padding(16)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonAmber.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Team Section

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "THE TEAM", icon: "person.3.fill")

            Button {
                showTeamSheet = true
            } label: {
                HStack(spacing: 12) {
                    // Team avatars - show all 5 members
                    HStack(spacing: -8) {
                        ForEach(TeamMember.allMembers) { member in
                            TeamAvatarCircle(member: member)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("View Team Roster")
                            .font(.terminalBody)
                            .foregroundColor(.white)
                        Text("5 Operators")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.terminalGray)
                }
                .padding(16)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.dimGreen, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.terminalSmall)
                .foregroundColor(.neonGreen)
            Text(title)
                .font(.terminalSmall)
                .foregroundColor(.terminalGray)

            Rectangle()
                .fill(Color.terminalGray.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Level Row

struct LevelRowView: View {
    let level: CampaignLevel
    let isUnlocked: Bool
    let isCompleted: Bool
    let isInsaneCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Level number
                ZStack {
                    Circle()
                        .fill(isUnlocked ? Color.neonGreen.opacity(0.2) : Color.terminalDarkGray)
                        .frame(width: 44, height: 44)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.terminalTitle)
                            .foregroundColor(.neonGreen)
                    } else if isUnlocked {
                        Text("\(level.id)")
                            .font(.terminalTitle)
                            .foregroundColor(.neonGreen)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.terminalSmall)
                            .foregroundColor(.terminalGray)
                    }
                }

                // Level info
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.name)
                        .font(.terminalBody)
                        .foregroundColor(isUnlocked ? .white : .terminalGray)

                    HStack(spacing: 8) {
                        Text(threatRangeText)
                            .font(.terminalMicro)
                            .foregroundColor(threatColor)

                        Text("•")
                            .foregroundColor(.terminalGray)

                        Text("T\(level.victoryConditions.requiredDefenseTier)")
                            .font(.terminalMicro)
                            .foregroundColor(.neonCyan)
                    }
                }

                Spacer()

                // Insane badge
                if isInsaneCompleted {
                    Text("INSANE")
                        .font(.terminalMicro)
                        .foregroundColor(.neonRed)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.dimRed)
                        .cornerRadius(2)
                }

                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }
            }
            .padding(12)
            .background(Color.terminalDarkGray.opacity(isUnlocked ? 1 : 0.5))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        isCompleted ? Color.neonGreen.opacity(0.5) :
                        isUnlocked ? Color.dimGreen :
                        Color.terminalGray.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }

    private var threatRangeText: String {
        let start = level.startingThreatLevel.name
        let end = level.victoryConditions.requiredRiskLevel.name
        return "\(start) → \(end)"
    }

    private var threatColor: Color {
        // Use the tier color from Theme.swift for all threat levels
        Color.tierColor(named: level.startingThreatLevel.color)
    }
}

// MARK: - Team Avatar

struct TeamAvatarCircle: View {
    let member: TeamMember

    var body: some View {
        ZStack {
            if let imageName = member.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(member.color, lineWidth: 2)
                    )
            } else {
                Circle()
                    .fill(Color.terminalDarkGray)
                    .frame(width: 32, height: 32)
                Circle()
                    .stroke(member.color, lineWidth: 2)
                    .frame(width: 32, height: 32)
                Text(member.initial)
                    .font(.terminalSmall)
                    .foregroundColor(member.color)
            }
        }
        .frame(width: 32, height: 32)
    }
}

// MARK: - Level Detail Sheet

struct LevelDetailSheet: View {
    let level: CampaignLevel
    let isUnlocked: Bool
    let isCompleted: Bool
    let isInsaneCompleted: Bool
    let stats: LevelCompletionStats?
    let insaneStats: LevelCompletionStats?
    let hasCheckpoint: Bool
    let onStartNormal: () -> Void
    let onStartInsane: () -> Void
    let onResume: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.subtitle.uppercased())
                            .font(.terminalSmall)
                            .foregroundColor(.terminalGray)
                        Text(level.name)
                            .font(.terminalLarge)
                            .foregroundColor(.neonGreen)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.terminalGray)
                    }
                }

                // Description
                Text(level.description)
                    .font(.terminalBody)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Stats
                VStack(spacing: 12) {
                    LevelStatRow(
                        label: "Threat Level",
                        value: "\(level.startingThreatLevel.name) → \(level.victoryConditions.requiredRiskLevel.name)",
                        color: .neonRed
                    )
                    LevelStatRow(
                        label: "Defense Tier",
                        value: "Tier \(level.victoryConditions.requiredDefenseTier)",
                        color: .neonCyan
                    )
                    LevelStatRow(
                        label: "Network Size",
                        value: level.networkSize.rawValue,
                        color: .neonAmber
                    )
                    LevelStatRow(
                        label: "Defense Points",
                        value: "\(level.victoryConditions.requiredDefensePoints) DP",
                        color: .neonGreen
                    )
                    if let credits = level.victoryConditions.requiredCredits {
                        LevelStatRow(
                            label: "Credits",
                            value: "₵\(credits.formatted)",
                            color: .neonGreen
                        )
                    }
                    if let attacks = level.victoryConditions.requiredAttacksSurvived {
                        LevelStatRow(
                            label: "Attacks Survived",
                            value: "\(attacks)",
                            color: .neonAmber
                        )
                    }
                }
                .padding(16)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)

                // Best stats if completed
                if let stats = stats {
                    bestRunSection(stats: stats, title: "BEST RUN", color: Color.dimGreen)
                }

                // Insane best stats
                if let insaneStats = insaneStats {
                    bestRunSection(stats: insaneStats, title: "INSANE BEST", color: Color.dimRed)
                }

                Spacer()

                // Start buttons
                VStack(spacing: 12) {
                    if isUnlocked {
                        // Show Continue button if there's a saved checkpoint
                        if hasCheckpoint {
                            Button(action: onResume) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("CONTINUE MISSION")
                                }
                                .font(.terminalTitle)
                                .foregroundColor(.terminalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.neonGreen)
                                .cornerRadius(4)
                            }

                            // Option to restart fresh
                            Button(action: onStartNormal) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("RESTART MISSION")
                                }
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.terminalDarkGray)
                                .cornerRadius(4)
                            }
                        } else {
                            Button(action: onStartNormal) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text(isCompleted ? "REPLAY MISSION" : "START MISSION")
                                }
                                .font(.terminalTitle)
                                .foregroundColor(.terminalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.neonGreen)
                                .cornerRadius(4)
                            }
                        }

                        if isCompleted {
                            Button(action: onStartInsane) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                    Text(isInsaneCompleted ? "REPLAY INSANE" : "INSANE MODE")
                                }
                                .font(.terminalTitle)
                                .foregroundColor(.neonRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.dimRed)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.neonRed.opacity(0.5), lineWidth: 1)
                                )
                            }

                            // Insane mode modifiers info
                            insaneModifiersInfo
                        }
                    } else {
                        Text("Complete previous level to unlock")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
            }
            .padding(20)
        }
        .presentationDetents([.medium, .large])
    }

    private func bestRunSection(stats: LevelCompletionStats, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
                Spacer()
                Text("Grade \(stats.grade.rawValue)")
                    .font(.terminalTitle)
                    .foregroundColor(gradeColor(stats.grade))
            }
            HStack {
                Text("Time: \(formatTicks(stats.ticksToComplete))")
                    .font(.terminalMicro)
                Spacer()
                Text("₵\(stats.creditsEarned.formatted)")
                    .font(.terminalMicro)
            }
            .foregroundColor(.terminalGray)
        }
        .padding(12)
        .background(color.opacity(0.3))
        .cornerRadius(4)
    }

    private var insaneModifiersInfo: some View {
        let modifiers = level.insaneModifiers ?? InsaneModifiers.standard
        return VStack(spacing: 4) {
            Text("INSANE MODIFIERS")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.neonRed.opacity(0.7))

            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("\(Int(modifiers.threatFrequencyMultiplier))x")
                        .font(.terminalSmall)
                        .foregroundColor(.neonRed)
                    Text("THREAT")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }

                VStack(spacing: 2) {
                    Text("\(Int(modifiers.attackDamageMultiplier * 100))%")
                        .font(.terminalSmall)
                        .foregroundColor(.neonRed)
                    Text("DAMAGE")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }

                VStack(spacing: 2) {
                    Text("\(Int(modifiers.creditIncomeMultiplier * 100))%")
                        .font(.terminalSmall)
                        .foregroundColor(.neonAmber)
                    Text("INCOME")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }
            }
        }
        .padding(8)
        .background(Color.dimRed.opacity(0.2))
        .cornerRadius(4)
    }

    private func gradeColor(_ grade: LevelGrade) -> Color {
        switch grade {
        case .s: return .neonAmber
        case .a: return .neonGreen
        case .b: return .neonCyan
        case .c: return .terminalGray
        }
    }

    private func formatTicks(_ ticks: Int) -> String {
        let minutes = ticks / 60
        let seconds = ticks % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct LevelStatRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.terminalSmall)
                .foregroundColor(.terminalGray)
            Spacer()
            Text(value)
                .font(.terminalBody)
                .foregroundColor(color)
        }
    }
}

// MARK: - Team Member Model

struct TeamMember: Identifiable {
    let id: String
    let name: String
    let role: String
    let initial: String
    let color: Color
    let imageName: String?  // Asset catalog image name, nil if not available
    let loreFragmentId: String  // Links to bio in LoreSystem

    static let allMembers: [TeamMember] = [
        TeamMember(
            id: "ronin",
            name: "Neon Ronin",
            role: "Team Leader",
            initial: "R",
            color: .neonRed,
            imageName: "Ronin",
            loreFragmentId: "team_ronin"
        ),
        TeamMember(
            id: "tish",
            name: "Tish",
            role: "Sniper / Overwatch",
            initial: "T",
            color: .neonCyan,
            imageName: "Tish",
            loreFragmentId: "team_tish"
        ),
        TeamMember(
            id: "flex",
            name: "FL3X",
            role: "Close-Quarters Muscle",
            initial: "F",
            color: .neonAmber,
            imageName: "FL3X_v1",
            loreFragmentId: "team_flex"
        ),
        TeamMember(
            id: "tee",
            name: "Tee",
            role: "Street Hacker",
            initial: "T",
            color: .neonGreen,
            imageName: "Tee_v1",
            loreFragmentId: "team_tee"
        ),
        TeamMember(
            id: "rusty",
            name: "Rusty",
            role: "Engineer / Comms",
            initial: "R",
            color: .neonGreen,
            imageName: "Rusty",
            loreFragmentId: "team_rusty"
        )
    ]
}

// MARK: - Team Roster Sheet

struct TeamRosterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMember: TeamMember?

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("THE TEAM")
                        .font(.terminalLarge)
                        .foregroundColor(.neonGreen)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.terminalGray)
                    }
                }

                // Team members
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(TeamMember.allMembers) { member in
                            Button {
                                selectedMember = member
                            } label: {
                                TeamMemberRow(member: member)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Note about Helix/Malus
                VStack(spacing: 8) {
                    Text("[ CLASSIFIED ]")
                        .font(.terminalMicro)
                        .foregroundColor(.neonRed)
                    Text("Intelligence on Helix and Malus available in Intel logs")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
        }
        .presentationDetents([.medium, .large])
        .sheet(item: $selectedMember) { member in
            TeamMemberDetailView(member: member)
        }
    }
}

// MARK: - Team Member Row

struct TeamMemberRow: View {
    let member: TeamMember

    var body: some View {
        HStack(spacing: 16) {
            // Avatar with image or initial fallback
            TeamMemberAvatar(member: member, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.terminalTitle)
                    .foregroundColor(.white)
                Text(member.role)
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.terminalSmall)
                .foregroundColor(.terminalGray)
        }
        .padding(12)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(member.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Team Member Avatar

struct TeamMemberAvatar: View {
    let member: TeamMember
    let size: CGFloat

    var body: some View {
        ZStack {
            if let imageName = member.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(member.color, lineWidth: 2)
                    )
            } else {
                // Fallback to initial
                Circle()
                    .fill(Color.terminalDarkGray)
                    .frame(width: size, height: size)
                Circle()
                    .stroke(member.color, lineWidth: 2)
                    .frame(width: size, height: size)
                Text(member.initial)
                    .font(size > 50 ? .terminalLarge : .terminalBody)
                    .foregroundColor(member.color)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Team Member Detail View

struct TeamMemberDetailView: View {
    let member: TeamMember
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    private var bio: String {
        if let fragment = LoreDatabase.fragment(withId: member.loreFragmentId) {
            return fragment.content
        }
        return "Intel file not found."
    }

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.terminalGray)
                            .padding(16)
                    }
                }

                ScrollView {
                    VStack(spacing: isIPad ? 32 : 24) {
                        // Character portrait
                        characterPortrait

                        // Name and role
                        VStack(spacing: 8) {
                            Text(member.name.uppercased())
                                .font(isIPad ? .system(size: 32, weight: .bold, design: .monospaced) : .terminalLarge)
                                .foregroundColor(member.color)
                                .glow(member.color, radius: 8)

                            Text(member.role)
                                .font(isIPad ? .system(size: 18, weight: .regular, design: .monospaced) : .terminalBody)
                                .foregroundColor(.terminalGray)
                        }

                        // Divider
                        Rectangle()
                            .fill(member.color.opacity(0.3))
                            .frame(height: 1)
                            .padding(.horizontal, isIPad ? 60 : 40)

                        // Bio content
                        Text(bio)
                            .font(isIPad ? .system(size: 16, weight: .regular, design: .monospaced) : .terminalReadable)
                            .foregroundColor(.white)
                            .lineSpacing(isIPad ? 8 : 6)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: isIPad ? 600 : .infinity, alignment: .leading)
                            .padding(.horizontal, isIPad ? 40 : 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var characterPortrait: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(member.color.opacity(0.1))
                .frame(width: isIPad ? 220 : 160, height: isIPad ? 220 : 160)
                .blur(radius: 20)

            if let imageName = member.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isIPad ? 180 : 140, height: isIPad ? 180 : 140)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(member.color, lineWidth: isIPad ? 4 : 3)
                    )
                    .shadow(color: member.color.opacity(0.5), radius: 20)
            } else {
                // Large initial fallback
                ZStack {
                    Circle()
                        .fill(Color.terminalDarkGray)
                        .frame(width: isIPad ? 180 : 140, height: isIPad ? 180 : 140)

                    Circle()
                        .stroke(member.color, lineWidth: isIPad ? 4 : 3)
                        .frame(width: isIPad ? 180 : 140, height: isIPad ? 180 : 140)

                    Text(member.initial)
                        .font(.system(size: isIPad ? 72 : 56, weight: .bold, design: .monospaced))
                        .foregroundColor(member.color)
                }
                .shadow(color: member.color.opacity(0.5), radius: 20)
            }
        }
    }
}

// MARK: - Player Stats Sheet

struct PlayerStatsSheet: View {
    let progress: CampaignProgress
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("PLAYER STATS")
                        .font(.terminalLarge)
                        .foregroundColor(.neonGreen)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.terminalGray)
                    }
                }

                // Campaign progress
                VStack(spacing: 12) {
                    StatRow(label: "Levels Completed", value: "\(progress.completedLevels.count)/7")
                    StatRow(label: "Insane Completed", value: "\(progress.insaneCompletedLevels.count)/7")
                    StatRow(label: "Total Stars", value: "\(progress.totalStars)/21")
                }
                .padding(16)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)

                // Lifetime stats
                VStack(spacing: 12) {
                    Text("LIFETIME STATS")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    StatRow(label: "Total Playtime", value: progress.lifetimeStats.playtimeFormatted)
                    StatRow(label: "Credits Earned", value: "₵\(progress.lifetimeStats.totalCreditsEarned.formatted)")
                    StatRow(label: "Attacks Survived", value: "\(progress.lifetimeStats.totalAttacksSurvived)")
                    StatRow(label: "Damage Blocked", value: progress.lifetimeStats.totalDamageBlocked.formatted)
                }
                .padding(16)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)

                Spacer()
            }
            .padding(20)
        }
        .presentationDetents([.medium])
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.terminalBody)
                .foregroundColor(.terminalGray)
            Spacer()
            Text(value)
                .font(.terminalTitle)
                .foregroundColor(.neonGreen)
        }
    }
}

// MARK: - Int Identifiable Extension

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    HomeView(
        onStartLevel: { level, isInsane in print("Start level \(level.id), insane: \(isInsane)") },
        onPlayEndless: { print("Endless mode") }
    )
    .environmentObject(CampaignState())
    .environmentObject(CloudSaveManager.shared)
}
