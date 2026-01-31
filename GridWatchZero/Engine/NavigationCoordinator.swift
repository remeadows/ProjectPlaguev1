// NavigationCoordinator.swift
// GridWatchZero
// Manages app navigation flow between screens

import SwiftUI
import Combine

// MARK: - App Screen Enum

enum AppScreen: Hashable {
    case title
    case mainMenu
    case home
    case gameplay(levelId: Int?, isInsane: Bool) // nil = endless mode
    case levelComplete(levelId: Int, isInsane: Bool)
    case levelFailed(levelId: Int, reason: FailureReason, isInsane: Bool)
    case playerProfile
    case helixAwakening // Cinematic after Level 7 completion

    // Custom hash for FailureReason
    func hash(into hasher: inout Hasher) {
        switch self {
        case .title: hasher.combine(0)
        case .mainMenu: hasher.combine(1)
        case .home: hasher.combine(2)
        case .gameplay(let id, let insane): hasher.combine(3); hasher.combine(id); hasher.combine(insane)
        case .levelComplete(let id, let insane): hasher.combine(4); hasher.combine(id); hasher.combine(insane)
        case .levelFailed(let id, let reason, let insane): hasher.combine(5); hasher.combine(id); hasher.combine(reason.rawValue); hasher.combine(insane)
        case .playerProfile: hasher.combine(6)
        case .helixAwakening: hasher.combine(7)
        }
    }

    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.title, .title), (.mainMenu, .mainMenu), (.home, .home), (.playerProfile, .playerProfile), (.helixAwakening, .helixAwakening): return true
        case (.gameplay(let a, let ia), .gameplay(let b, let ib)): return a == b && ia == ib
        case (.levelComplete(let a, let ia), .levelComplete(let b, let ib)): return a == b && ia == ib
        case (.levelFailed(let a1, let r1, let i1), .levelFailed(let a2, let r2, let i2)): return a1 == a2 && r1 == r2 && i1 == i2
        default: return false
        }
    }
}

// MARK: - Navigation Coordinator

@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var currentScreen: AppScreen = .title
    @Published var navigationPath = NavigationPath()

    // Store completion stats for the level complete screen
    @Published var lastCompletionStats: LevelCompletionStats?

    // Story system state
    @Published var storyState: StoryState = StoryState()
    @Published var activeStoryMoment: StoryMoment?
    @Published var pendingNavigation: (() -> Void)?

    // Cloud sync
    private let cloudManager = CloudSaveManager.shared
    private var cloudSyncCancellable: AnyCancellable?

    // Track if user has seen title this session
    private var hasShownTitle = false
    private var hasShownCampaignStart = false

    private let storyDatabase = StoryDatabase.shared

    init() {
        setupCloudSync()
    }

    // MARK: - Cloud Sync Setup

    private func setupCloudSync() {
        // Listen for cloud data changes
        cloudSyncCancellable = NotificationCenter.default
            .publisher(for: .cloudDataChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleCloudDataChange(notification)
            }
    }

    private func handleCloudDataChange(_ notification: Notification) {
        // Cloud data changed externally - could prompt user to reload
        // For now, we handle this silently and let the next sync resolve it
    }

    /// Sync progress to cloud
    func syncToCloud(progress: CampaignProgress) {
        cloudManager.uploadProgress(progress, storyState: storyState)
    }

    /// Perform initial cloud sync on app launch
    func performInitialCloudSync(campaignState: CampaignState) async {
        // Capture progress state BEFORE async sync
        let progressBeforeSync = campaignState.progress.completedLevels
        let insaneProgressBeforeSync = campaignState.progress.insaneCompletedLevels

        let result = await cloudManager.syncProgress(
            local: campaignState.progress,
            localStory: storyState
        )

        switch result {
        case .downloaded(let progress, let story):
            // CRITICAL: Check if local progress advanced while sync was in flight
            // If user completed levels during the sync, don't overwrite their progress
            let currentCompleted = campaignState.progress.completedLevels
            let currentInsane = campaignState.progress.insaneCompletedLevels

            let localAdvanced = currentCompleted.count > progressBeforeSync.count ||
                               currentInsane.count > insaneProgressBeforeSync.count

            if localAdvanced {
                // Local progress advanced during sync - upload instead of overwrite
                print("[CloudSync] Local progress advanced during sync, uploading instead of downloading")
                cloudManager.uploadProgress(campaignState.progress, storyState: storyState)
                return
            }

            // Safe to apply cloud data - local hasn't changed
            campaignState.progress = progress
            campaignState.save()
            storyState = story
            saveStoryState()
        case .conflict:
            // Conflict will be handled by UI
            break
        default:
            break
        }
    }

    // MARK: - Navigation Methods

    func showTitle() {
        currentScreen = .title
        navigationPath = NavigationPath()
    }

    func showMainMenu() {
        hasShownTitle = true
        currentScreen = .mainMenu
    }

    func showHome() {
        currentScreen = .home
    }

    func startLevel(_ levelId: Int, isInsane: Bool = false) {
        currentScreen = .gameplay(levelId: levelId, isInsane: isInsane)
    }

    func startEndlessMode() {
        currentScreen = .gameplay(levelId: nil, isInsane: false)
    }

    func completeLevel(_ levelId: Int, stats: LevelCompletionStats) {
        lastCompletionStats = stats

        // Award certificate for level completion (only on first completion of normal mode)
        if !stats.isInsane {
            CertificateManager.shared.earnCertificateForLevel(levelId)
        }

        // Unlock character dossiers based on level completion
        DossierManager.shared.unlockDossiersForLevel(levelId)

        // For Level 7, show Helix awakening cinematic first
        if levelId == 7 {
            currentScreen = .helixAwakening
        } else {
            currentScreen = .levelComplete(levelId: levelId, isInsane: stats.isInsane)
        }
    }

    /// Called after Helix awakening cinematic completes
    func completeHelixAwakening() {
        // Now show the level 7 complete screen
        if let stats = lastCompletionStats {
            currentScreen = .levelComplete(levelId: 7, isInsane: stats.isInsane)
        } else {
            currentScreen = .levelComplete(levelId: 7, isInsane: false)
        }
    }

    func failLevel(_ levelId: Int, reason: FailureReason, isInsane: Bool) {
        currentScreen = .levelFailed(levelId: levelId, reason: reason, isInsane: isInsane)
    }

    func returnToHome() {
        currentScreen = .home
    }

    func returnToMainMenu() {
        currentScreen = .mainMenu
    }

    func showPlayerProfile() {
        currentScreen = .playerProfile
    }

    // MARK: - Game Flow Helpers

    /// Check if save data exists
    var hasSaveData: Bool {
        UserDefaults.standard.data(forKey: "GridWatchZero.GameState.v6") != nil
    }

    /// Called when "New Game" is selected
    func handleNewGame() {
        // Clear existing save data
        UserDefaults.standard.removeObject(forKey: "GridWatchZero.GameState.v6")
        // Reset story state for new game
        storyState = StoryState()
        hasShownCampaignStart = false
        // Show campaign start story, then go to home
        showStoryThenNavigate(.campaignStart, levelId: nil) {
            self.showHome()
        }
    }

    /// Called when "Continue" is selected
    func handleContinue() {
        // For now, go to home - later we can restore last position
        showHome()
    }

    // MARK: - Story Integration

    /// Show a story moment if one exists for the trigger, then execute navigation
    func showStoryThenNavigate(_ trigger: StoryTrigger, levelId: Int?, then navigate: @escaping () -> Void) {
        if let story = storyDatabase.nextUnseenStory(for: trigger, levelId: levelId, storyState: storyState) {
            activeStoryMoment = story
            pendingNavigation = navigate
        } else {
            navigate()
        }
    }

    /// Called when a story dialogue completes
    func dismissStory() {
        if let story = activeStoryMoment {
            storyState.markSeen(story.id)
        }
        activeStoryMoment = nil

        // Execute pending navigation if any
        if let pending = pendingNavigation {
            pendingNavigation = nil
            withAnimation(.easeInOut(duration: 0.3)) {
                pending()
            }
        }
    }

    /// Get the level intro story if not yet seen
    func levelIntroStory(for levelId: Int) -> StoryMoment? {
        guard let story = storyDatabase.levelIntro(for: levelId),
              !storyState.hasSeen(story.id) else {
            return nil
        }
        return story
    }

    /// Get the level complete story if not yet seen
    func levelCompleteStory(for levelId: Int) -> StoryMoment? {
        guard let story = storyDatabase.levelComplete(for: levelId),
              !storyState.hasSeen(story.id) else {
            return nil
        }
        return story
    }

    /// Get the failure story
    func levelFailedStory(for levelId: Int?, reason: FailureReason) -> StoryMoment? {
        storyDatabase.levelFailed(for: levelId, reason: reason)
    }

    /// Save story state
    func saveStoryState() {
        if let data = try? JSONEncoder().encode(storyState) {
            UserDefaults.standard.set(data, forKey: "GridWatchZero.StoryState.v1")
        }
    }

    /// Load story state
    func loadStoryState() {
        guard let data = UserDefaults.standard.data(forKey: "GridWatchZero.StoryState.v1"),
              let state = try? JSONDecoder().decode(StoryState.self, from: data) else {
            return
        }
        storyState = state
    }
}

// MARK: - Root Navigation View

struct RootNavigationView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @StateObject private var gameEngine = GameEngine()
    @StateObject private var campaignState = CampaignState()
    @StateObject private var cloudManager = CloudSaveManager.shared
    @State private var hasPerformedInitialSync = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .title:
                TitleScreenView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        coordinator.showMainMenu()
                    }
                }
                .transition(.opacity)

            case .mainMenu:
                MainMenuView(
                    onNewGame: {
                        coordinator.handleNewGame()
                    },
                    onContinue: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.handleContinue()
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            case .home:
                HomeView(
                    onStartLevel: { level, isInsane in
                        // Show level intro story, then start level
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: level.id) {
                            coordinator.startLevel(level.id, isInsane: isInsane)
                        }
                    },
                    onPlayEndless: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.startEndlessMode()
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            case .playerProfile:
                PlayerProfileView(campaignState: campaignState)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))

            case .gameplay(let levelId, let isInsane):
                GameplayContainerView(
                    gameEngine: gameEngine,
                    campaignState: campaignState,
                    levelId: levelId,
                    isInsane: isInsane,
                    onExit: {
                        gameEngine.exitCampaignMode()
                        // Ensure we return to hub state properly
                        campaignState.returnToHub()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.returnToHome()
                        }
                    },
                    onLevelComplete: { stats in
                        // Save progress first - this is critical
                        campaignState.completeCurrentLevel(stats: stats)

                        // Force save to persist immediately
                        campaignState.save()

                        // Update campaign milestones
                        gameEngine.updateCampaignMilestones(
                            campaignCompleted: campaignState.progress.completedLevels.count,
                            insaneCompleted: campaignState.progress.insaneCompletedLevels.count
                        )

                        // Update cosmetic unlocks
                        CosmeticState.shared.updateInsaneProgress(
                            campaignState.progress.insaneCompletedLevels.count
                        )

                        // Sync to cloud after saving locally
                        coordinator.syncToCloud(progress: campaignState.progress)

                        gameEngine.exitCampaignMode()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.completeLevel(stats.levelId, stats: stats)
                        }
                    },
                    onLevelFailed: { levelId, reason in
                        campaignState.failCurrentLevel(reason: reason)
                        // Force save on failure too
                        campaignState.save()
                        gameEngine.exitCampaignMode()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.failLevel(levelId, reason: reason, isInsane: isInsane)
                        }
                    }
                )
                .transition(.opacity)

            case .levelComplete(let levelId, let isInsane):
                LevelCompleteView(
                    levelId: levelId,
                    isInsane: isInsane,
                    stats: coordinator.lastCompletionStats,
                    onNextLevel: {
                        // Clear checkpoint since level is complete
                        campaignState.returnToHub(clearCheckpoint: true)
                        // Show next level intro, then start (normal mode for next level)
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: levelId + 1) {
                            coordinator.startLevel(levelId + 1, isInsane: false)
                        }
                    },
                    onReturnHome: {
                        // Clear checkpoint since level is complete
                        campaignState.returnToHub(clearCheckpoint: true)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.returnToHome()
                        }
                    }
                )
                .transition(.opacity)
                .onAppear {
                    // Show level complete story
                    if let story = coordinator.levelCompleteStory(for: levelId) {
                        coordinator.activeStoryMoment = story
                    }
                }

            case .levelFailed(let levelId, let reason, let isInsane):
                LevelFailedView(
                    levelId: levelId,
                    reason: reason,
                    onRetry: {
                        // Clear checkpoint on retry - start fresh
                        campaignState.returnToHub(clearCheckpoint: true)
                        // Retry with same insane mode setting
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: levelId) {
                            coordinator.startLevel(levelId, isInsane: isInsane)
                        }
                    },
                    onReturnHome: {
                        // Clear checkpoint since player gave up
                        campaignState.returnToHub(clearCheckpoint: true)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.returnToHome()
                        }
                    }
                )
                .transition(.opacity)
                .onAppear {
                    // Show failure story
                    if let story = coordinator.levelFailedStory(for: levelId, reason: reason) {
                        coordinator.activeStoryMoment = story
                    }
                }

            case .helixAwakening:
                HelixAwakeningView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        coordinator.completeHelixAwakening()
                    }
                }
                .transition(.opacity)
            }

            // Story overlay - shown on top of everything
            if let story = coordinator.activeStoryMoment {
                StoryDialogueView(storyMoment: story) {
                    coordinator.dismissStory()
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .environmentObject(coordinator)
        .environmentObject(campaignState)
        .environmentObject(cloudManager)
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen)
        .animation(.easeInOut(duration: 0.3), value: coordinator.activeStoryMoment?.id)
        .onAppear {
            coordinator.loadStoryState()
            // Perform initial cloud sync only once per app session
            if !hasPerformedInitialSync {
                hasPerformedInitialSync = true
                Task {
                    await coordinator.performInitialCloudSync(campaignState: campaignState)
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Auto-save when app goes to background or becomes inactive
            if newPhase == .background || newPhase == .inactive {
                gameEngine.pause()  // pause() calls saveGame()
                campaignState.save()
                coordinator.saveStoryState()
                AmbientAudioManager.shared.pause()
            } else if newPhase == .active && oldPhase != .active {
                // Resume music and game when returning to foreground
                AmbientAudioManager.shared.resume()

                // Auto-resume the game engine if we're on a gameplay screen
                if case .gameplay = coordinator.currentScreen {
                    gameEngine.start()
                }
            }
        }
    }
}

// MARK: - Gameplay Container

/// Wrapper that adds campaign UI elements around DashboardView
struct GameplayContainerView: View {
    @ObservedObject var gameEngine: GameEngine
    @ObservedObject var campaignState: CampaignState
    let levelId: Int?
    let isInsane: Bool
    var onExit: () -> Void
    var onLevelComplete: (LevelCompletionStats) -> Void
    var onLevelFailed: (Int, FailureReason) -> Void

    @State private var showExitConfirm = false
    @State private var showVictoryProgress = false

    var body: some View {
        ZStack {
            // Main gameplay (existing DashboardView)
            DashboardView(onCampaignExit: levelId != nil ? { showExitConfirm = true } : nil)
                .environmentObject(gameEngine)
                .environmentObject(campaignState)
                .environmentObject(CloudSaveManager.shared)
                // Add bottom padding for mission objectives bar
                .safeAreaInset(edge: .bottom) {
                    if levelId != nil, let progress = gameEngine.victoryProgress {
                        VictoryProgressBar(progress: progress)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                            .background(Color.terminalBlack.opacity(0.95))
                    }
                }

            // Endless mode overlay - only show exit button
            if levelId == nil {
                VStack {
                    endlessTopBar
                    Spacer()
                }
            }
        }
        .alert("Exit Mission?", isPresented: $showExitConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Save & Exit") {
                // Save checkpoint before exiting
                gameEngine.saveCampaignCheckpoint()
                gameEngine.pause()
                onExit()
            }
        } message: {
            Text("Your progress will be saved. You can resume this mission later.")
        }
        .onAppear {
            setupLevel()
        }
    }

    private func setupLevel() {
        if let levelId = levelId {
            // Campaign mode - configure and start level
            if let level = LevelDatabase.shared.level(forId: levelId) {
                // CRITICAL: Set up CampaignState tracking FIRST
                // This sets currentLevel so completeCurrentLevel() works properly
                campaignState.startLevel(levelId, isInsane: isInsane)

                let config = LevelConfiguration(level: level, isInsane: isInsane)

                // Unit unlocks do NOT persist across campaign levels
                // Each level is a fresh economic challenge - players must re-unlock units
                // Only base T1 units are available at the start of each level

                // Check if we have a valid checkpoint to resume from
                if let checkpoint = campaignState.validCheckpoint(for: levelId, isInsane: isInsane) {
                    // Resume from saved checkpoint (checkpoint stores unlocks earned THIS level)
                    gameEngine.resumeFromCheckpoint(checkpoint, config: config, persistedUnlocks: [])
                } else {
                    // Start fresh with no persisted unlocks
                    gameEngine.startCampaignLevel(config, persistedUnlocks: [])
                }

                // Unit unlocks are no longer persisted across campaign levels
                gameEngine.onUnitUnlocked = nil

                // Set up callbacks
                gameEngine.onLevelComplete = { stats in
                    onLevelComplete(stats)
                }
                gameEngine.onLevelFailed = { reason in
                    onLevelFailed(levelId, reason)
                }
            }
        } else {
            // Endless mode - just start normally
            gameEngine.onUnitUnlocked = nil  // No persistence needed in endless mode
            gameEngine.start()
        }
    }

    private var endlessTopBar: some View {
        HStack {
            // Endless mode indicator
            HStack(spacing: 6) {
                Image(systemName: "infinity")
                    .foregroundColor(.neonAmber)
                Text("ENDLESS")
                    .font(.terminalMicro)
                    .foregroundColor(.neonAmber)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.terminalBlack.opacity(0.9))
            .cornerRadius(4)

            Spacer()

            // Menu button
            Button {
                showExitConfirm = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title3)
                    .foregroundColor(.terminalGray)
                    .padding(8)
                    .background(Color.terminalBlack.opacity(0.9))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Victory Progress Bar

struct VictoryProgressBar: View {
    let progress: VictoryProgress
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Collapsed view - tap to expand
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Overall progress indicator
                    ZStack {
                        Circle()
                            .stroke(Color.terminalGray.opacity(0.3), lineWidth: 3)
                            .frame(width: 36, height: 36)
                        Circle()
                            .trim(from: 0, to: progress.overallProgress)
                            .stroke(progress.allConditionsMet ? Color.neonGreen : Color.neonCyan, lineWidth: 3)
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(progress.overallProgress * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(progress.allConditionsMet ? .neonGreen : .neonCyan)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(progress.allConditionsMet ? "VICTORY CONDITIONS MET!" : "MISSION OBJECTIVES")
                            .font(.terminalMicro)
                            .foregroundColor(progress.allConditionsMet ? .neonGreen : .terminalGray)

                        // Quick status
                        HStack(spacing: 8) {
                            // Clearer tier display: shows current → required when not met
                            ConditionPill(
                                label: progress.defenseTierCurrent == 0 ? "No App" :
                                       progress.defenseTierMet ? "T\(progress.defenseTierCurrent)+" :
                                       "T\(progress.defenseTierCurrent)→T\(progress.defenseTierRequired)",
                                met: progress.defenseTierMet
                            )
                            ConditionPill(label: "\(progress.defensePointsCurrent)/\(progress.defensePointsRequired)DP", met: progress.defensePointsMet)
                            ConditionPill(label: progress.riskLevelCurrent.name, met: progress.riskLevelMet)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }
                .padding(12)
                .background(Color.terminalBlack.opacity(0.95))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            // Expanded details
            if isExpanded {
                VStack(spacing: 8) {
                    // Defense Application Tier (clarified label)
                    GoalRow(
                        icon: "shield.lefthalf.filled",
                        label: "Defense App Tier",
                        current: progress.defenseTierCurrent == 0 ? "None" : "T\(progress.defenseTierCurrent)",
                        target: "T\(progress.defenseTierRequired)+",
                        progress: Double(progress.defenseTierCurrent) / Double(progress.defenseTierRequired),
                        met: progress.defenseTierMet,
                        hint: progress.defenseTierCurrent == 0 ? "Install a defense app!" :
                              !progress.defenseTierMet ? "Upgrade an app to Tier \(progress.defenseTierRequired)!" : nil
                    )

                    // Defense Points
                    GoalRow(
                        icon: "chart.bar.fill",
                        label: "Defense Points",
                        current: "\(progress.defensePointsCurrent) DP",
                        target: "\(progress.defensePointsRequired) DP",
                        progress: Double(progress.defensePointsCurrent) / Double(progress.defensePointsRequired),
                        met: progress.defensePointsMet,
                        hint: nil
                    )

                    // Risk Level
                    GoalRow(
                        icon: "exclamationmark.triangle.fill",
                        label: "Risk Level",
                        current: progress.riskLevelCurrent.name,
                        target: "≤ \(progress.riskLevelRequired.name)",
                        progress: progress.riskLevelMet ? 1.0 : max(0, 1.0 - Double(progress.riskLevelCurrent.rawValue - progress.riskLevelRequired.rawValue) * 0.2),
                        met: progress.riskLevelMet,
                        hint: nil
                    )

                    // Credits (if required)
                    if let required = progress.creditsRequired {
                        GoalRow(
                            icon: "creditcard.fill",
                            label: "Credits Earned",
                            current: "₵\(progress.creditsCurrent.formatted)",
                            target: "₵\(required.formatted)",
                            progress: min(1.0, progress.creditsCurrent / required),
                            met: progress.creditsMet,
                            hint: nil
                        )
                    }

                    // Attacks Survived (if required)
                    if let required = progress.attacksRequired {
                        GoalRow(
                            icon: "shield.checkered",
                            label: "Attacks Survived",
                            current: "\(progress.attacksCurrent)",
                            target: "\(required)",
                            progress: min(1.0, Double(progress.attacksCurrent) / Double(required)),
                            met: progress.attacksMet,
                            hint: nil
                        )
                    }

                    // Intel Reports Sent (if required) - MAIN OBJECTIVE
                    if let required = progress.reportsRequired {
                        GoalRow(
                            icon: "doc.text.magnifyingglass",
                            label: "Intel Reports",
                            current: "\(progress.reportsCurrent)",
                            target: "\(required)",
                            progress: min(1.0, Double(progress.reportsCurrent) / Double(required)),
                            met: progress.reportsMet,
                            hint: progress.reportsCurrent == 0 ? "Send intel to help stop Malus!" : nil
                        )
                    }
                }
                .padding(12)
                .background(Color.terminalDarkGray.opacity(0.95))
                .cornerRadius(8)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }
}

struct GoalRow: View {
    let icon: String
    let label: String
    let current: String
    let target: String
    let progress: Double
    let met: Bool
    let hint: String?

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(met ? .neonGreen : .neonCyan)
                .frame(width: 20)

            // Label and progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.terminalSmall)
                        .foregroundColor(.white)
                    Spacer()
                    Text(current)
                        .font(.terminalSmall)
                        .foregroundColor(met ? .neonGreen : .neonAmber)
                    Text("/")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text(target)
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.terminalGray.opacity(0.3))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(met ? Color.neonGreen : Color.neonCyan)
                            .frame(width: geo.size.width * min(1.0, progress))
                    }
                }
                .frame(height: 4)

                // Hint text when goal not met
                if let hint = hint, !met {
                    Text(hint)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.neonAmber)
                        .padding(.top, 2)
                }
            }

            // Checkmark
            if met {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.neonGreen)
            }
        }
    }
}

struct ConditionPill: View {
    let label: String
    let met: Bool

    var body: some View {
        Text(label)
            .font(.terminalMicro)
            .foregroundColor(met ? .neonGreen : .terminalGray)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(met ? Color.dimGreen : Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(met ? Color.neonGreen.opacity(0.5) : Color.clear, lineWidth: 1)
            )
    }
}

// MARK: - Level Complete View

struct LevelCompleteView: View {
    let levelId: Int
    let isInsane: Bool
    let stats: LevelCompletionStats?
    var onNextLevel: () -> Void
    var onReturnHome: () -> Void

    @State private var showContent = false
    @State private var showCertificatePopup = false

    private var accentColor: Color {
        isInsane ? .neonRed : .neonGreen
    }

    private var earnedCertificate: Certificate? {
        // Only show certificate for normal mode completions
        guard !isInsane else { return nil }
        return CertificateDatabase.certificate(for: levelId)
    }

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Success icon with animation
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .stroke(accentColor, lineWidth: 3)
                        .frame(width: 120, height: 120)
                    Image(systemName: isInsane ? "flame.fill" : "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(accentColor)
                }
                .glow(accentColor, radius: 20)
                .scaleEffect(showContent ? 1 : 0.5)

                // Title and grade
                VStack(spacing: 8) {
                    if isInsane {
                        Text("INSANE COMPLETE")
                            .font(.terminalLarge)
                            .foregroundColor(.neonRed)
                    } else {
                        Text("MISSION COMPLETE")
                            .font(.terminalLarge)
                            .foregroundColor(.neonGreen)
                    }

                    if let level = LevelDatabase.shared.level(forId: levelId) {
                        Text(level.name)
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                    }

                    if let stats = stats {
                        HStack(spacing: 4) {
                            Text("GRADE:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text(stats.grade.rawValue)
                                .font(.terminalLarge)
                                .foregroundColor(gradeColor(stats.grade))
                        }
                        .padding(.top, 8)
                    }
                }

                // Stats card
                if let stats = stats {
                    VStack(spacing: 12) {
                        StatDisplayRow(icon: "clock", label: "Time", value: formatTime(stats.ticksToComplete))
                        StatDisplayRow(icon: "creditcard", label: "Credits", value: "₵\(stats.creditsEarned.formatted)")
                        StatDisplayRow(icon: "shield", label: "Attacks Survived", value: "\(stats.attacksSurvived)")
                        StatDisplayRow(icon: "bolt.shield", label: "Damage Blocked", value: stats.damageBlocked.formatted)
                        StatDisplayRow(icon: "chart.bar", label: "Defense Points", value: "\(stats.finalDefensePoints)")
                    }
                    .padding(20)
                    .background(Color.terminalDarkGray)
                    .cornerRadius(8)
                }

                // Certificate earned (normal mode only)
                if let cert = earnedCertificate {
                    Button {
                        showCertificatePopup = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundColor(Color.tierColor(named: cert.tier.color))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("CERTIFICATE EARNED")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.tierColor(named: cert.tier.color))

                                Text(cert.abbreviation)
                                    .font(.terminalTitle)
                                    .foregroundColor(.white)

                                Text(cert.name)
                                    .font(.terminalSmall)
                                    .foregroundColor(.terminalGray)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.terminalGray)
                        }
                        .padding(16)
                        .background(Color.terminalDarkGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.tierColor(named: cert.tier.color).opacity(0.5), lineWidth: 1)
                        )
                    }
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    if levelId < 20 {
                        Button(action: onNextLevel) {
                            HStack {
                                Text("NEXT MISSION")
                                Image(systemName: "arrow.right")
                            }
                            .font(.terminalTitle)
                            .foregroundColor(.terminalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.neonGreen)
                            .cornerRadius(4)
                        }
                    } else {
                        // Final level complete!
                        Text("CAMPAIGN COMPLETE!")
                            .font(.terminalTitle)
                            .foregroundColor(.neonAmber)
                            .padding(.vertical, 14)
                    }

                    Button(action: onReturnHome) {
                        Text("RETURN TO HUB")
                            .font(.terminalTitle)
                            .foregroundColor(.neonGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            // Certificate popup overlay
            if showCertificatePopup, let cert = earnedCertificate {
                CertificateUnlockPopupView(certificate: cert) {
                    showCertificatePopup = false
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
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
}

struct StatDisplayRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.terminalSmall)
                .foregroundColor(.neonCyan)
                .frame(width: 20)

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

// MARK: - Level Failed View

struct LevelFailedView: View {
    let levelId: Int
    let reason: FailureReason
    var onRetry: () -> Void
    var onReturnHome: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Failure icon
                ZStack {
                    Circle()
                        .fill(Color.neonRed.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .stroke(Color.neonRed, lineWidth: 3)
                        .frame(width: 120, height: 120)
                    Image(systemName: failureIcon)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.neonRed)
                }
                .glow(.neonRed, radius: 20)
                .scaleEffect(showContent ? 1 : 0.5)

                // Title
                VStack(spacing: 8) {
                    Text("MISSION FAILED")
                        .font(.terminalLarge)
                        .foregroundColor(.neonRed)

                    if let level = LevelDatabase.shared.level(forId: levelId) {
                        Text(level.name)
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                    }
                }

                // Failure reason card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.neonRed)
                        Text(reason.rawValue.uppercased())
                            .font(.terminalTitle)
                            .foregroundColor(.neonRed)
                    }

                    Text(failureTip)
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.dimRed.opacity(0.3))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.neonRed.opacity(0.3), lineWidth: 1)
                )

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("RETRY MISSION")
                        }
                        .font(.terminalTitle)
                        .foregroundColor(.terminalBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonAmber)
                        .cornerRadius(4)
                    }

                    Button(action: onReturnHome) {
                        Text("RETURN TO HUB")
                            .font(.terminalTitle)
                            .foregroundColor(.terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.terminalGray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }

    private var failureIcon: String {
        switch reason {
        case .timeLimitExceeded: return "clock.badge.xmark"
        case .networkedDestroyed: return "network.slash"
        case .creditsZero: return "creditcard.trianglebadge.exclamationmark"
        case .userQuit: return "xmark.circle"
        }
    }

    private var failureTip: String {
        switch reason {
        case .timeLimitExceeded:
            return "You ran out of time. Try deploying defenses faster and prioritizing efficiency."
        case .networkedDestroyed:
            return "Your network was compromised. Focus on building stronger defenses and maintaining your firewall."
        case .creditsZero:
            return "You went bankrupt. Balance your spending on defenses with maintaining income flow."
        case .userQuit:
            return "Mission abandoned. Return when you're ready to try again."
        }
    }
}

#Preview("Root Navigation") {
    RootNavigationView()
}

#Preview("Level Complete") {
    LevelCompleteView(
        levelId: 1,
        isInsane: false,
        stats: LevelCompletionStats(
            levelId: 1,
            isInsane: false,
            ticksToComplete: 180,
            creditsEarned: 2500,
            attacksSurvived: 5,
            damageBlocked: 150,
            finalDefensePoints: 75,
            intelReportsSent: 5,
            completionDate: Date()
        ),
        onNextLevel: {},
        onReturnHome: {}
    )
}

#Preview("Level Failed") {
    LevelFailedView(
        levelId: 1,
        reason: .creditsZero,
        onRetry: {},
        onReturnHome: {}
    )
}
