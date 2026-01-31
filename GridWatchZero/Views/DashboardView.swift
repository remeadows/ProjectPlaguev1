// DashboardView.swift
// GridWatchZero
// Main game dashboard showing the neural grid network

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var engine: GameEngine
    @StateObject private var tutorialManager = TutorialManager.shared
    @StateObject private var engagementManager = EngagementManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var collectionManager = CollectionManager.shared
    @State private var showingEvent: GameEvent? = nil
    @State private var screenShake: CGFloat = 0
    @State private var showingShop = false
    @State private var showingLore = false
    @State private var showingMilestones = false
    @State private var showingOfflineProgress = false
    @State private var showingPrestige = false
    @State private var showingCriticalAlarm = false
    @State private var showingSettings = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Campaign exit callback (nil for endless mode)
    var onCampaignExit: (() -> Void)? = nil

    // iPad layout breakpoints
    private enum IPadLayoutStyle {
        case compact    // iPad Mini, iPad in slide-over
        case regular    // Standard iPad (10.9", 11")
        case expanded   // iPad Pro 12.9" and larger

        var sidebarWidth: CGFloat {
            switch self {
            case .compact: return 300
            case .regular: return 320
            case .expanded: return 340
            }
        }

        var showsThirdColumn: Bool {
            self == .expanded
        }

        var thirdColumnWidth: CGFloat {
            280
        }

        // Use vertical card layout when center panel is narrow
        var useVerticalCardLayout: Bool {
            self == .compact
        }
    }

    private func determineIPadLayout(for width: CGFloat) -> IPadLayoutStyle {
        if width >= 1200 {
            return .expanded  // iPad Pro 12.9" landscape
        } else if width >= 1000 {
            return .regular   // Standard iPad landscape
        } else {
            return .compact   // iPad portrait or smaller
        }
    }

    var body: some View {
        ZStack {
            // Background
            Color.terminalBlack
                .ignoresSafeArea()

            // Scanline overlay effect
            ScanlineOverlay()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // iPad uses split view, iPhone uses stacked view
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }

            // Critical Alarm Overlay
            if showingCriticalAlarm {
                CriticalAlarmView(
                    threatLevel: engine.threatState.currentLevel,
                    riskLevel: engine.threatState.effectiveRiskLevel,
                    activeAttack: engine.activeAttack,
                    defenseStack: engine.defenseStack,
                    onAcknowledge: {
                        engine.acknowledgeCriticalAlarm()
                        showingCriticalAlarm = false
                    },
                    onBoostDefenses: {
                        showingCriticalAlarm = false
                        showingShop = true
                    }
                )
                .transition(.opacity)
                .zIndex(200)
            }

            // Tutorial Overlay (Level 1 only)
            if tutorialManager.shouldShowTutorial {
                TutorialOverlayView(tutorialManager: tutorialManager)
                    .zIndex(300)
            }

            // Daily Reward Popup
            if engagementManager.showDailyRewardPopup {
                DailyRewardPopupView(
                    engagementManager: engagementManager,
                    onClaim: { credits in
                        engine.addCredits(credits)
                        AudioManager.shared.playSound(.milestone)
                    }
                )
                .zIndex(400)
            }

            // Achievement Unlock Popup
            if achievementManager.showAchievementPopup,
               let achievement = achievementManager.pendingUnlocks.first {
                AchievementUnlockPopupView(
                    achievement: achievement,
                    onDismiss: {
                        engine.addCredits(achievement.rewardCredits)
                        achievementManager.dismissAchievementPopup()
                    }
                )
                .zIndex(401)
            }

            // Data Chip Unlock Popup
            if collectionManager.showChipUnlock,
               let chip = collectionManager.pendingChips.first {
                DataChipUnlockPopupView(
                    chip: chip,
                    onDismiss: {
                        collectionManager.dismissChipPopup()
                    }
                )
                .zIndex(402)
            }
        }
        .onAppear {
            engine.start()
            // Check for offline progress
            if engine.offlineProgress != nil {
                showingOfflineProgress = true
            }
            // Check for critical alarm
            if engine.shouldShowCriticalAlarm {
                showingCriticalAlarm = true
            }
            // Start tutorial for Level 1 (if not completed)
            if engine.levelConfiguration?.level.id == 1 && !tutorialManager.state.hasCompletedTutorial {
                // Delay to let intro story finish
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    tutorialManager.startTutorialForLevel1()
                }
            }
        }
        .onChange(of: engine.lastEvent) { _, newEvent in
            handleEvent(newEvent)
        }
        .onChange(of: engine.showCriticalAlarm) { _, shouldShow in
            if shouldShow {
                withAnimation {
                    showingCriticalAlarm = true
                }
            }
        }
        .onChange(of: engine.offlineProgress) { _, newValue in
            if newValue != nil {
                showingOfflineProgress = true
            }
        }
        .sheet(isPresented: $showingShop) {
            UnitShopView(engine: engine)
        }
        .sheet(isPresented: $showingLore) {
            LoreView(engine: engine)
        }
        .sheet(isPresented: $showingMilestones) {
            MilestonesView(engine: engine)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingOfflineProgress) {
            if let progress = engine.offlineProgress {
                OfflineProgressView(progress: progress) {
                    engine.dismissOfflineProgress()
                    showingOfflineProgress = false
                }
            }
        }
        .sheet(isPresented: $showingPrestige) {
            PrestigeConfirmView(
                prestigeState: engine.prestigeState,
                totalCredits: engine.threatState.totalCreditsEarned,
                creditsRequired: engine.creditsRequiredForPrestige,
                helixCoresReward: engine.helixCoresFromPrestige,
                onConfirm: {
                    _ = engine.performPrestige()
                    showingPrestige = false
                },
                onCancel: {
                    showingPrestige = false
                }
            )
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - iPad Layout (Side-by-side panels)

    private var iPadLayout: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                let layoutMode = determineIPadLayout(for: geo.size.width)

                HStack(spacing: 0) {
                    // Left sidebar - Stats, Defense
                    iPadLeftSidebar(layoutMode: layoutMode)
                        .frame(width: layoutMode.sidebarWidth)
                        .background(Color.terminalDarkGray.opacity(0.5))

                    // Divider
                    Rectangle()
                        .fill(Color.neonGreen.opacity(0.3))
                        .frame(width: 1)

                    // Center main area - Network Map
                    iPadCenterPanel(layoutMode: layoutMode)
                        .frame(maxWidth: .infinity)
                        .background(Color.terminalDarkGray.opacity(0.3))

                    // Third column for expanded layout (Intel/Milestones)
                    if layoutMode.showsThirdColumn {
                        // Divider
                        Rectangle()
                            .fill(Color.neonCyan.opacity(0.3))
                            .frame(width: 1)

                        iPadRightSidebar
                            .frame(width: layoutMode.thirdColumnWidth)
                            .background(Color.terminalDarkGray.opacity(0.5))
                    }
                }
            }

            // Alert banner overlay (floats on top without pushing content)
            // Uses .overlay modifier approach for true floating behavior
            Color.clear
                .frame(height: 0)
                .overlay(alignment: .top) {
                    AlertBannerView(event: showingEvent)
                        .padding(.top, 60)  // Below the header
                }
                .allowsHitTesting(false)
                .zIndex(100)
        }
        .offset(x: reduceMotion ? 0 : screenShake)
    }

    // MARK: - iPad Left Sidebar

    private func iPadLeftSidebar(layoutMode: IPadLayoutStyle) -> some View {
        VStack(spacing: 0) {
            // Header with stats
            iPadHeaderView

            // Threat bar
            ThreatBarView(
                threatState: engine.threatState,
                activeAttack: engine.activeAttack,
                attacksSurvived: engine.threatState.attacksSurvived
            )

            // Sidebar content
            ScrollView {
                VStack(spacing: 16) {
                    // Quick stats panel
                    iPadQuickStatsPanel

                    // Defense section
                    sectionHeader("PERIMETER DEFENSE")

                    // Compact firewall card matching Source/Link/Sink design
                    iPadCompactFirewallCard

                    DefenseStackView(
                        stack: engine.defenseStack,
                        credits: engine.resources.credits,
                        maxTierAvailable: engine.maxTierAvailable,
                        onUpgrade: { category in
                            _ = engine.upgradeDefenseApp(category)
                        },
                        onDeploy: { tier in
                            _ = engine.deployDefenseApp(tier)
                        },
                        onUnlock: { tier in
                            _ = engine.unlockDefenseTier(tier)
                        }
                    )

                    // Prestige (only in endless mode, and only in 2-column)
                    if !layoutMode.showsThirdColumn && !engine.isInCampaignMode {
                        PrestigeCardView(
                            prestigeState: engine.prestigeState,
                            totalCredits: engine.threatState.totalCreditsEarned,
                            canPrestige: engine.canPrestige,
                            creditsRequired: engine.creditsRequiredForPrestige,
                            helixCoresReward: engine.helixCoresFromPrestige,
                            onPrestige: { showingPrestige = true }
                        )
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - iPad Center Panel (Network Map)

    private func iPadCenterPanel(layoutMode: IPadLayoutStyle) -> some View {
        VStack(spacing: 0) {
            sectionHeader("NETWORK MAP")
                .padding(.top, 16)
                .padding(.horizontal)

            // Network map with wider cards
            ScrollView {
                VStack(spacing: 0) {
                    // Network Topology at top for iPad
                    NetworkTopologyView(
                        source: engine.source,
                        link: engine.link,
                        sink: engine.sink,
                        stack: engine.defenseStack,
                        isRunning: engine.isRunning,
                        tickStats: engine.lastTickStats,
                        threatLevel: engine.threatState.currentLevel,
                        activeAttack: engine.activeAttack,
                        malusIntel: engine.malusIntel
                    )
                    .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                    .padding(.top, 16)

                    // Node cards - use horizontal layout with proper sizing
                    iPadNodeCards(layoutMode: layoutMode)
                        .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                        .padding(.top, 24)

                    // Network stats at bottom
                    ThreatStatsView(
                        threatState: engine.threatState,
                        totalGenerated: engine.totalDataGenerated,
                        totalTransferred: engine.totalDataTransferred,
                        totalDropped: engine.totalDataDropped,
                        totalProcessed: engine.resources.totalDataProcessed
                    )
                    .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                    .padding(.top, 24)

                    // Malus Intelligence - in center for 2-column, right sidebar for 3-column
                    if !layoutMode.showsThirdColumn {
                        MalusIntelPanel(
                            intel: engine.malusIntel,
                            onSendReport: {
                                _ = engine.sendMalusReport()
                            }
                        )
                        .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }

    // MARK: - iPad Node Cards Layout

    @ViewBuilder
    private func iPadNodeCards(layoutMode: IPadLayoutStyle) -> some View {
        if layoutMode.useVerticalCardLayout {
            // Vertical stack for compact mode (portrait)
            VStack(spacing: 0) {
                SourceCardView(
                    source: engine.source,
                    credits: engine.resources.credits,
                    onUpgrade: { _ = engine.upgradeSource() }
                )

                ConnectionLineView(
                    isActive: engine.isRunning,
                    throughput: engine.lastTickStats.dataGenerated,
                    maxThroughput: engine.source.productionPerTick
                )
                .frame(height: 30)

                ZStack {
                    LinkCardView(
                        link: engine.link,
                        credits: engine.resources.credits,
                        onUpgrade: { _ = engine.upgradeLink() }
                    )
                    if let attack = engine.activeAttack,
                       attack.type == .ddos && attack.isActive {
                        DDoSOverlay()
                    }
                }

                ConnectionLineView(
                    isActive: engine.isRunning,
                    throughput: engine.lastTickStats.dataTransferred,
                    maxThroughput: engine.link.bandwidth
                )
                .frame(height: 30)

                SinkCardView(
                    sink: engine.sink,
                    credits: engine.resources.credits,
                    onUpgrade: { _ = engine.upgradeSink() }
                )
            }
        } else {
            // Horizontal layout for regular/expanded mode (landscape)
            // Use compact inline cards that stack stats vertically
            HStack(alignment: .top, spacing: 12) {
                // Source Card - Compact
                iPadCompactSourceCard
                    .frame(minWidth: 180, maxWidth: .infinity)

                // Link Card - Compact
                iPadCompactLinkCard
                    .frame(minWidth: 180, maxWidth: .infinity)

                // Sink Card - Compact
                iPadCompactSinkCard
                    .frame(minWidth: 180, maxWidth: .infinity)
            }
        }
    }

    // MARK: - Compact iPad Cards

    private var iPadCompactSourceCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row
            HStack {
                Text(engine.source.name)
                    .font(.terminalSmall)
                    .foregroundColor(.neonGreen)
                    .lineLimit(1)
                Spacer()
                Text("L\(engine.source.level)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.neonGreen)
                    .cornerRadius(2)
            }

            // Stats
            HStack(spacing: 4) {
                Text("OUT:")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                Text("\(engine.source.productionPerTick.formatted)/t")
                    .font(.terminalSmall)
                    .foregroundColor(.neonGreen)
            }

            // Upgrade button
            if engine.source.isAtMaxLevel {
                Text("MAX")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.neonGreen.opacity(0.8))
                    .cornerRadius(2)
            } else {
                Button(action: { _ = engine.upgradeSource() }) {
                    HStack {
                        Text("+\((engine.source.baseProduction * Double(engine.source.level + 1) * 1.5 - engine.source.productionPerTick).formatted)")
                            .font(.terminalMicro)
                        Spacer()
                        Text("¢\(engine.source.upgradeCost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(engine.resources.credits >= engine.source.upgradeCost ? .terminalBlack : .terminalGray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(engine.resources.credits >= engine.source.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(engine.resources.credits < engine.source.upgradeCost)
            }
        }
        .padding(10)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
        )
    }

    private var iPadCompactLinkCard: some View {
        let efficiencyColor: Color = engine.link.throughputEfficiency >= 0.9 ? .neonGreen :
            (engine.link.throughputEfficiency >= 0.5 ? .neonAmber : .neonRed)

        return VStack(alignment: .leading, spacing: 6) {
            // Header row
            HStack {
                Text(engine.link.name)
                    .font(.terminalSmall)
                    .foregroundColor(.neonCyan)
                    .lineLimit(1)
                Spacer()
                Text("L\(engine.link.level)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.neonCyan)
                    .cornerRadius(2)
            }

            // Stats - two rows
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("BW:")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(engine.link.bandwidth.formatted)/t")
                        .font(.terminalSmall)
                        .foregroundColor(.neonCyan)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("EFF:")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text(engine.link.throughputEfficiency.percentFormatted)
                        .font(.terminalSmall)
                        .foregroundColor(efficiencyColor)
                }
            }

            // Upgrade button
            if engine.link.isAtMaxLevel {
                Text("MAX")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.neonCyan.opacity(0.8))
                    .cornerRadius(2)
            } else {
                Button(action: { _ = engine.upgradeLink() }) {
                    HStack {
                        Text("+\((engine.link.baseBandwidth * Double(engine.link.level + 1) * 1.4 - engine.link.bandwidth).formatted)")
                            .font(.terminalMicro)
                        Spacer()
                        Text("¢\(engine.link.upgradeCost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(engine.resources.credits >= engine.link.upgradeCost ? .terminalBlack : .terminalGray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(engine.resources.credits >= engine.link.upgradeCost ? Color.neonCyan : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(engine.resources.credits < engine.link.upgradeCost)
            }

            // DDoS overlay indicator
            if let attack = engine.activeAttack, attack.type == .ddos && attack.isActive {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                    Text("DDOS ATTACK")
                        .font(.terminalMicro)
                }
                .foregroundColor(.neonRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color.neonRed.opacity(0.2))
                .cornerRadius(2)
            }
        }
        .padding(10)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
        )
    }

    private var iPadCompactSinkCard: some View {
        let bufferColor: Color = engine.sink.loadPercentage >= 0.9 ? .neonRed :
            (engine.sink.loadPercentage >= 0.6 ? .neonAmber : .neonAmber)

        return VStack(alignment: .leading, spacing: 6) {
            // Header row
            HStack {
                Text(engine.sink.name)
                    .font(.terminalSmall)
                    .foregroundColor(.neonAmber)
                    .lineLimit(1)
                Spacer()
                Text("L\(engine.sink.level)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.neonAmber)
                    .cornerRadius(2)
            }

            // Stats - two rows
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("PROC:")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(engine.sink.processingPerTick.formatted)/t")
                        .font(.terminalSmall)
                        .foregroundColor(.neonAmber)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("¢")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text(engine.sink.conversionRate.formatted)
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen)
                }
            }

            // Buffer bar
            HStack(spacing: 4) {
                Text("BUF:")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.terminalGray.opacity(0.3))
                        Rectangle()
                            .fill(bufferColor)
                            .frame(width: geo.size.width * engine.sink.loadPercentage)
                    }
                }
                .frame(height: 6)
                .cornerRadius(2)
                Text(engine.sink.loadPercentage.percentFormatted)
                    .font(.terminalMicro)
                    .foregroundColor(bufferColor)
            }

            // Upgrade button
            if engine.sink.isAtMaxLevel {
                Text("MAX")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.neonAmber.opacity(0.8))
                    .cornerRadius(2)
            } else {
                Button(action: { _ = engine.upgradeSink() }) {
                    HStack {
                        Text("+\((engine.sink.baseProcessingRate * Double(engine.sink.level + 1) * 1.3 - engine.sink.processingPerTick).formatted)")
                            .font(.terminalMicro)
                        Spacer()
                        Text("¢\(engine.sink.upgradeCost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(engine.resources.credits >= engine.sink.upgradeCost ? .terminalBlack : .terminalGray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(engine.resources.credits >= engine.sink.upgradeCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(engine.resources.credits < engine.sink.upgradeCost)
            }
        }
        .padding(10)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Compact Firewall Card

    @ViewBuilder
    private var iPadCompactFirewallCard: some View {
        if let fw = engine.firewall {
            let healthColor: Color = fw.healthPercentage >= 0.6 ? .neonGreen :
                (fw.healthPercentage >= 0.3 ? .neonAmber : .neonRed)

            VStack(alignment: .leading, spacing: 6) {
                // Header row
                HStack {
                    Text(fw.name)
                        .font(.terminalSmall)
                        .foregroundColor(.neonRed)
                        .lineLimit(1)
                    Spacer()
                    Text("L\(fw.level)")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.neonRed)
                        .cornerRadius(2)
                }

                // Health bar row
                HStack(spacing: 4) {
                    Text("HP \(fw.currentHealth.formatted)/\(fw.maxHealth.formatted)")
                        .font(.terminalMicro)
                        .foregroundColor(healthColor)
                    Spacer()
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.terminalGray.opacity(0.3))
                            Rectangle()
                                .fill(healthColor)
                                .frame(width: geo.size.width * fw.healthPercentage)
                        }
                    }
                    .frame(width: 60, height: 6)
                    .cornerRadius(2)
                }

                // Stats row: DR + Regen
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("DR")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(fw.damageReduction.percentFormatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonRed)
                    }
                    HStack(spacing: 4) {
                        Text("REGEN")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text("+\(fw.regenPerTick.formatted)")
                            .font(.terminalSmall)
                            .foregroundColor(.neonGreen)
                    }
                    Spacer()
                }

                // Buttons row
                HStack(spacing: 6) {
                    // Repair button (if damaged)
                    if fw.currentHealth < fw.maxHealth {
                        let repairCost = (fw.maxHealth - fw.currentHealth) * 0.5
                        Button(action: { _ = engine.repairFirewall() }) {
                            HStack(spacing: 2) {
                                Image(systemName: "wrench.fill")
                                    .font(.system(size: 9))
                                Text("¢\(repairCost.formatted)")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(engine.resources.credits >= repairCost ? .terminalBlack : .terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(engine.resources.credits >= repairCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                            .cornerRadius(2)
                        }
                        .disabled(engine.resources.credits < repairCost)
                    }

                    // Upgrade button or MAX badge
                    if fw.isAtMaxLevel {
                        Text("MAX")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.neonGreen.opacity(0.8))
                            .cornerRadius(2)
                    } else {
                        Button(action: { _ = engine.upgradeFirewall() }) {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 9))
                                Text("¢\(fw.upgradeCost.formatted)")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(engine.resources.credits >= fw.upgradeCost ? .terminalBlack : .terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(engine.resources.credits >= fw.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                            .cornerRadius(2)
                        }
                        .disabled(engine.resources.credits < fw.upgradeCost)
                    }
                }
            }
            .padding(10)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.neonRed.opacity(0.5), lineWidth: 1)
            )
        } else {
            // No firewall - purchase prompt
            HStack(spacing: 8) {
                Image(systemName: "shield.slash")
                    .font(.system(size: 14))
                    .foregroundColor(.terminalGray)

                VStack(alignment: .leading, spacing: 2) {
                    Text("NO FIREWALL")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                    Text("Unprotected")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                }

                Spacer()

                let cost: Double = 500
                Button(action: { _ = engine.purchaseFirewall() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 10))
                        Text("¢\(cost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(engine.resources.credits >= cost ? .terminalBlack : .terminalGray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(engine.resources.credits >= cost ? Color.neonRed : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(engine.resources.credits < cost)
            }
            .padding(10)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.terminalGray.opacity(0.5), lineWidth: 1)
            )
        }
    }

    // MARK: - iPad Right Sidebar (Intel/Milestones - 3-column only)

    private var iPadRightSidebar: some View {
        VStack(spacing: 0) {
            // Section header
            sectionHeader("INTEL & PROGRESS")
                .padding(.horizontal)
                .padding(.top, 16)

            ScrollView {
                VStack(spacing: 16) {
                    // Malus Intel
                    MalusIntelPanel(
                        intel: engine.malusIntel,
                        onSendReport: {
                            _ = engine.sendMalusReport()
                        }
                    )

                    // Recent lore/intel teaser
                    iPadRecentIntelPanel

                    // Prestige (only in endless mode)
                    if !engine.isInCampaignMode {
                        PrestigeCardView(
                            prestigeState: engine.prestigeState,
                            totalCredits: engine.threatState.totalCreditsEarned,
                            canPrestige: engine.canPrestige,
                            creditsRequired: engine.creditsRequiredForPrestige,
                            helixCoresReward: engine.helixCoresFromPrestige,
                            onPrestige: { showingPrestige = true }
                        )
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - iPad Recent Intel Panel (for 3-column layout)

    private var iPadRecentIntelPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("[ RECENT INTEL ]")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Spacer()

                if engine.loreState.unreadCount > 0 {
                    Text("\(engine.loreState.unreadCount) NEW")
                        .font(.terminalMicro)
                        .foregroundColor(.neonAmber)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.neonAmber.opacity(0.2))
                        .cornerRadius(2)
                }
            }

            // Show last unlocked lore fragment preview
            if let lastFragment = engine.loreState.unlockedFragments.last {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: lastFragment.category.icon)
                            .font(.system(size: 12))
                            .foregroundColor(loreCategoryColor(lastFragment.category))

                        Text(lastFragment.title)
                            .font(.terminalSmall)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    Text(String(lastFragment.content.prefix(80)) + (lastFragment.content.count > 80 ? "..." : ""))
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                        .lineLimit(2)
                }
                .padding(10)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)
            }

            Button(action: { showingLore = true }) {
                HStack {
                    Image(systemName: "book.fill")
                    Text("VIEW ALL INTEL")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.terminalSmall)
                .foregroundColor(.neonCyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .terminalCard(borderColor: .terminalGray)
    }

    private func loreCategoryColor(_ category: LoreCategory) -> Color {
        switch category {
        case .world: return .terminalGray
        case .helix: return .neonCyan
        case .malus: return .neonRed
        case .team: return .neonGreen
        case .intel: return .neonAmber
        }
    }

    // MARK: - iPhone Layout (Original stacked layout)

    private var iPhoneLayout: some View {
        ZStack(alignment: .top) {
            // Main content in VStack
            VStack(spacing: 0) {
                // Tutorial hint banner (Level 1 only)
                if tutorialManager.shouldShowTutorial && !tutorialManager.isShowingDialogue {
                    TutorialHintBanner(tutorialManager: tutorialManager)
                }

                // Header with stats + threat indicator
                StatsHeaderView(
                credits: engine.resources.credits,
                tickStats: engine.lastTickStats,
                currentTick: engine.currentTick,
                isRunning: engine.isRunning,
                unreadLore: engine.loreState.unreadCount,
                onToggle: { engine.toggle() },
                onReset: { engine.resetGame() },
                onShop: { showingShop = true },
                onLore: { showingLore = true },
                onMilestones: { showingMilestones = true },
                onSettings: { showingSettings = true },
                campaignLevelId: engine.levelConfiguration?.level.id,
                campaignLevelName: engine.levelConfiguration?.level.name,
                isInsaneMode: engine.levelConfiguration?.isInsane ?? false,
                onPauseCampaign: onCampaignExit
            )

            // Threat / Defense / Risk bar
            ThreatBarView(
                threatState: engine.threatState,
                activeAttack: engine.activeAttack,
                attacksSurvived: engine.threatState.attacksSurvived
            )

            // Network Map
            ScrollView {
                VStack(spacing: 0) {
                    // Section header
                    sectionHeader("NETWORK MAP")
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    // Source Node
                    SourceCardView(
                        source: engine.source,
                        credits: engine.resources.credits,
                        onUpgrade: { _ = engine.upgradeSource() }
                    )
                    .tutorialHighlight(.sourceCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Source node: \(engine.source.name), level \(engine.source.level), output \(engine.source.productionPerTick.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(engine.source.upgradeCost.formatted) credits")

                    // Connection: Source -> Link
                    ConnectionLineView(
                        isActive: engine.isRunning,
                        throughput: engine.lastTickStats.dataGenerated,
                        maxThroughput: engine.source.productionPerTick
                    )
                    .frame(height: 30)
                    .accessibilityHidden(true)

                    // Link Node (with attack indicator overlay)
                    ZStack {
                        LinkCardView(
                            link: engine.link,
                            credits: engine.resources.credits,
                            onUpgrade: { _ = engine.upgradeLink() }
                        )

                        // DDoS attack overlay
                        if let attack = engine.activeAttack,
                           attack.type == .ddos && attack.isActive {
                            DDoSOverlay()
                        }
                    }
                    .tutorialHighlight(.linkCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Link node: \(engine.link.name), level \(engine.link.level), bandwidth \(engine.link.bandwidth.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(engine.link.upgradeCost.formatted) credits")

                    // Connection: Link -> Sink
                    ConnectionLineView(
                        isActive: engine.isRunning,
                        throughput: engine.lastTickStats.dataTransferred,
                        maxThroughput: engine.link.bandwidth
                    )
                    .frame(height: 30)
                    .accessibilityHidden(true)

                    // Sink Node
                    SinkCardView(
                        sink: engine.sink,
                        credits: engine.resources.credits,
                        onUpgrade: { _ = engine.upgradeSink() }
                    )
                    .tutorialHighlight(.sinkCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Sink node: \(engine.sink.name), level \(engine.sink.level), processing \(engine.sink.processingPerTick.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(engine.sink.upgradeCost.formatted) credits")

                    // Network Topology
                    NetworkTopologyView(
                        source: engine.source,
                        link: engine.link,
                        sink: engine.sink,
                        stack: engine.defenseStack,
                        isRunning: engine.isRunning,
                        tickStats: engine.lastTickStats,
                        threatLevel: engine.threatState.currentLevel,
                        activeAttack: engine.activeAttack,
                        malusIntel: engine.malusIntel
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .accessibilityLabel("Network topology visualization showing \(Int((1.0 - engine.lastTickStats.dropRate) * 100)) percent efficiency")

                    // Defense section header
                    sectionHeader("PERIMETER DEFENSE")
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                    // Firewall Node (legacy - still needed)
                    FirewallCardView(
                        firewall: engine.firewall,
                        credits: engine.resources.credits,
                        damageAbsorbed: engine.lastTickStats.damageAbsorbed,
                        onUpgrade: { _ = engine.upgradeFirewall() },
                        onRepair: { _ = engine.repairFirewall() },
                        onPurchase: { _ = engine.purchaseFirewall() }
                    )
                    .tutorialHighlight(.firewallSection, manager: tutorialManager)
                    .padding(.horizontal)

                    // Security Applications Stack
                    DefenseStackView(
                        stack: engine.defenseStack,
                        credits: engine.resources.credits,
                        maxTierAvailable: engine.maxTierAvailable,
                        onUpgrade: { category in
                            _ = engine.upgradeDefenseApp(category)
                        },
                        onDeploy: { tier in
                            _ = engine.deployDefenseApp(tier)
                        },
                        onUnlock: { tier in
                            _ = engine.unlockDefenseTier(tier)
                        }
                    )
                    .tutorialHighlight(.defenseApps, manager: tutorialManager)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Bottom stats
                    ThreatStatsView(
                        threatState: engine.threatState,
                        totalGenerated: engine.totalDataGenerated,
                        totalTransferred: engine.totalDataTransferred,
                        totalDropped: engine.totalDataDropped,
                        totalProcessed: engine.resources.totalDataProcessed
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Malus Intelligence Panel - moved after stats for stability
                    MalusIntelPanel(
                        intel: engine.malusIntel,
                        onSendReport: {
                            _ = engine.sendMalusReport()
                        }
                    )
                    .tutorialHighlight(.intelPanel, manager: tutorialManager)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Prestige section (only in endless mode)
                    if !engine.isInCampaignMode {
                        PrestigeCardView(
                            prestigeState: engine.prestigeState,
                            totalCredits: engine.threatState.totalCreditsEarned,
                            canPrestige: engine.canPrestige,
                            creditsRequired: engine.creditsRequiredForPrestige,
                            helixCoresReward: engine.helixCoresFromPrestige,
                            onPrestige: { showingPrestige = true }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            }  // End of main VStack

            // Alert banner overlay (floats on top without pushing content)
            // Uses .overlay modifier approach for true floating behavior
            Color.clear
                .frame(height: 0)
                .overlay(alignment: .top) {
                    AlertBannerView(event: showingEvent)
                        .padding(.top, tutorialManager.shouldShowTutorial && !tutorialManager.isShowingDialogue ? 44 : 0)
                }
                .allowsHitTesting(false)
                .zIndex(100)
        }  // End of ZStack
        .offset(x: reduceMotion ? 0 : screenShake)
    }

    // MARK: - Shared Components

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text("[ \(title) ]")
                .font(.terminalSmall)
                .foregroundColor(.terminalGray)

            Rectangle()
                .fill(Color.terminalGray.opacity(0.3))
                .frame(height: 1)
        }
    }

    private var iPadHeaderView: some View {
        VStack(spacing: 0) {
            // Campaign level bar (if in campaign mode)
            if let config = engine.levelConfiguration {
                HStack(spacing: 8) {
                    // Back button
                    if let exitAction = onCampaignExit {
                        Button(action: exitAction) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("EXIT")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(.neonCyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .accessibilityLabel("Exit to campaign menu")
                    }

                    // Level info
                    HStack(spacing: 6) {
                        Text("LEVEL \(config.level.id)")
                            .font(.terminalMicro)
                            .foregroundColor(.neonCyan)

                        Text("•")
                            .foregroundColor(.terminalGray)

                        Text(config.level.name.uppercased())
                            .font(.terminalMicro)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if config.isInsane {
                            Text("INSANE")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalBlack)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.neonRed)
                                .cornerRadius(2)
                        }
                    }

                    Spacer()

                    // Campaign objective progress
                    HStack(spacing: 12) {
                        // Credits progress (if required)
                        if let creditsRequired = config.level.victoryConditions.requiredCredits {
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.neonAmber)
                                Text("\(engine.resources.credits.formatted)/\(creditsRequired.formatted)")
                                    .font(.terminalMicro)
                                    .foregroundColor(engine.resources.credits >= creditsRequired ? .neonGreen : .terminalGray)
                            }
                        }

                        // Intel reports progress (if required)
                        if let reportsRequired = config.level.victoryConditions.requiredReportsSent {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.neonCyan)
                                Text("\(engine.malusIntel.reportsSent)/\(reportsRequired)")
                                    .font(.terminalMicro)
                                    .foregroundColor(engine.malusIntel.reportsSent >= reportsRequired ? .neonGreen : .terminalGray)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.neonCyan.opacity(0.1))
            }

            // Main header row
            HStack(spacing: 12) {
                // Title
                Text("GRID WATCH ZERO")
                    .font(.terminalTitle)
                    .foregroundColor(.neonGreen)
                    .glow(.neonGreen, radius: 4)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                // Credits
                HStack(spacing: 4) {
                    Text("¢")
                        .font(.terminalBody)
                        .foregroundColor(.neonAmber)
                    Text(engine.resources.credits.formatted)
                        .font(.terminalTitle)
                        .foregroundColor(.neonAmber)
                        .glow(.neonAmber, radius: 3)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(engine.resources.credits.formatted) credits")

                // Control buttons
                HStack(spacing: 4) {
                    Button(action: { showingLore = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.neonCyan)
                                .frame(width: 36, height: 36)
                                .background(Color.terminalDarkGray)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                                )

                            if engine.loreState.unreadCount > 0 {
                                Circle()
                                    .fill(Color.neonAmber)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Text("\(min(engine.loreState.unreadCount, 9))")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.terminalBlack)
                                    )
                                    .offset(x: 3, y: -3)
                            }
                        }
                    }
                    .accessibilityLabel("Intel. \(engine.loreState.unreadCount) unread")

                    Button(action: { showingMilestones = true }) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neonAmber)
                            .frame(width: 36, height: 36)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Milestones")

                    Button(action: { showingShop = true }) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neonAmber)
                            .frame(width: 36, height: 36)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Shop")

                    Button(action: { engine.toggle() }) {
                        Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.neonGreen)
                            .frame(width: 36, height: 36)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel(engine.isRunning ? "Pause game" : "Resume game")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Color.terminalDarkGray)
    }

    private var iPadQuickStatsPanel: some View {
        VStack(spacing: 12) {
            sectionHeader("LIVE STATS")

            HStack(spacing: 16) {
                iPadStatBox(label: "GEN", value: engine.lastTickStats.dataGenerated.formatted, color: .neonGreen)
                iPadStatBox(label: "TX", value: engine.lastTickStats.dataTransferred.formatted, color: .neonCyan)
                iPadStatBox(label: "DROP", value: engine.lastTickStats.dataDropped.formatted, color: engine.lastTickStats.dataDropped > 0 ? .neonRed : .terminalGray)
                iPadStatBox(label: "EARN", value: "¢\(engine.lastTickStats.creditsEarned.formatted)", color: .neonAmber)
            }

            // Tick indicator
            HStack {
                Circle()
                    .fill(engine.isRunning ? Color.neonGreen : Color.neonRed)
                    .frame(width: 8, height: 8)
                    .glow(engine.isRunning ? .neonGreen : .neonRed, radius: 3)

                Text("Tick \(engine.currentTick)")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Spacer()

                Text(engine.isRunning ? "RUNNING" : "PAUSED")
                    .font(.terminalMicro)
                    .foregroundColor(engine.isRunning ? .neonGreen : .neonRed)
            }
        }
        .terminalCard(borderColor: .terminalGray)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Live stats: Generated \(engine.lastTickStats.dataGenerated.formatted), transferred \(engine.lastTickStats.dataTransferred.formatted), dropped \(engine.lastTickStats.dataDropped.formatted), earned \(engine.lastTickStats.creditsEarned.formatted) credits. Tick \(engine.currentTick), \(engine.isRunning ? "running" : "paused")")
    }

    private func iPadStatBox(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)
            Text(value)
                .font(.terminalBody)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func handleEvent(_ event: GameEvent?) {
        guard let event = event else { return }

        // Show banner
        withAnimation {
            showingEvent = event
        }

        // Screen shake for attacks
        if case .attackStarted = event {
            triggerScreenShake()
        }

        // Auto-hide banner after delay
        let hideDelay: Double = {
            switch event {
            case .malusMessage: return 5.0
            case .attackStarted: return 3.0
            default: return 2.0
            }
        }()

        DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay) {
            withAnimation {
                if showingEvent == event {
                    showingEvent = nil
                }
            }
        }
    }

    private func triggerScreenShake() {
        let shakeAnimation = Animation.spring(response: 0.1, dampingFraction: 0.3)

        withAnimation(shakeAnimation) {
            screenShake = 8
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(shakeAnimation) {
                screenShake = -6
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(shakeAnimation) {
                screenShake = 4
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(shakeAnimation) {
                screenShake = 0
            }
        }
    }
}

// MARK: - Threat Bar View

struct ThreatBarView: View {
    let threatState: ThreatState
    let activeAttack: Attack?
    let attacksSurvived: Int

    var body: some View {
        HStack(spacing: 12) {
            // Threat / Defense / Risk indicator
            ThreatIndicatorView(
                threatState: threatState,
                activeAttack: activeAttack
            )

            Spacer()

            // Attacks survived counter
            if attacksSurvived > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonGreen)

                    Text("\(attacksSurvived)")
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.terminalDarkGray.opacity(0.8))
    }
}

// MARK: - DDoS Attack Overlay

struct DDoSOverlay: View {
    @State private var isGlitching = false

    var body: some View {
        Rectangle()
            .fill(Color.neonRed.opacity(0.15))
            .overlay(
                // Glitch lines
                VStack(spacing: 0) {
                    ForEach(0..<10, id: \.self) { i in
                        Rectangle()
                            .fill(Color.neonRed.opacity(isGlitching ? 0.3 : 0))
                            .frame(height: 2)
                            .offset(x: isGlitching ? CGFloat.random(in: -5...5) : 0)
                        Spacer()
                    }
                }
            )
            .cornerRadius(4)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 0.1)
                        .repeatForever(autoreverses: true)
                ) {
                    isGlitching = true
                }
            }
    }
}

// MARK: - Threat Stats View (replaces TotalStatsView)

struct ThreatStatsView: View {
    let threatState: ThreatState
    let totalGenerated: Double
    let totalTransferred: Double
    let totalDropped: Double
    let totalProcessed: Double

    private var efficiency: Double? {
        guard totalGenerated > 0 else { return nil }
        return totalTransferred / totalGenerated
    }

    var body: some View {
        VStack(spacing: 12) {
            // Threat section
            VStack(spacing: 8) {
                HStack {
                    Text("[ THREAT INTEL ]")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)

                    Rectangle()
                        .fill(Color.terminalGray.opacity(0.3))
                        .frame(height: 1)
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Threat Level")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(threatState.currentLevel.name)
                            .font(.terminalSmall)
                            .foregroundColor(threatLevelColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Attacks Survived")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text("\(threatState.attacksSurvived)")
                            .font(.terminalSmall)
                            .foregroundColor(.neonGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Damage Taken")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text("¢\(threatState.totalDamageReceived.formatted)")
                            .font(.terminalSmall)
                            .foregroundColor(.neonRed)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Malus Status")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(malusStatus)
                            .font(.terminalSmall)
                            .foregroundColor(malusColor)
                    }
                }
            }
            .terminalCard(borderColor: threatLevelColor)

            // Network stats section
            VStack(spacing: 8) {
                HStack {
                    Text("[ NETWORK STATS ]")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)

                    Rectangle()
                        .fill(Color.terminalGray.opacity(0.3))
                        .frame(height: 1)
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Generated")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(totalGenerated.formatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Processed")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(totalProcessed.formatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonAmber)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Packets Lost")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(totalDropped.formatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonRed)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Efficiency")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        if let eff = efficiency {
                            Text(eff.percentFormatted)
                                .font(.terminalSmall)
                                .foregroundColor(eff >= 0.8 ? .neonGreen : (eff >= 0.5 ? .neonAmber : .neonRed))
                        } else {
                            Text("--")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }
                    }
                }
            }
            .terminalCard(borderColor: .terminalGray)
        }
    }

    private var threatLevelColor: Color {
        // Use the tier color from Theme.swift for all threat levels
        Color.tierColor(named: threatState.currentLevel.color)
    }

    private var malusStatus: String {
        switch threatState.currentLevel {
        case .ghost: return "UNAWARE"
        case .blip: return "SCANNING"
        case .signal: return "CURIOUS"
        case .target: return "TRACKING"
        case .priority: return "HUNTING"
        case .hunted: return "ACTIVE"
        case .marked: return "LOCKED ON"
        case .targeted: return "COORDINATED"
        case .hammered: return "OVERWHELMING"
        case .critical: return "TOTAL WAR"
        // Transcendence Era (Campaign 8-10)
        case .ascended: return "TRANSCENDING"
        case .symbiont: return "SYMBIOTIC"
        case .transcendent: return "BEYOND"
        // Dimensional Era (Campaign 11-14)
        case .unknown: return "UNKNOWN"
        case .dimensional: return "DIMENSIONAL"
        case .cosmic: return "COSMIC"
        // Cosmic Era (Campaign 15-18)
        case .paradox: return "PARADOX"
        case .primordial: return "PRIMORDIAL"
        case .infinite: return "INFINITE"
        // Omega Era (Campaign 19-20)
        case .omega: return "OMEGA"
        }
    }

    private var malusColor: Color {
        // Use the tier color from Theme.swift for all threat levels
        Color.tierColor(named: threatState.currentLevel.color)
    }
}

// MARK: - Prestige Card View

struct PrestigeCardView: View {
    let prestigeState: PrestigeState
    let totalCredits: Double
    let canPrestige: Bool
    let creditsRequired: Double
    let helixCoresReward: Int
    let onPrestige: () -> Void

    @State private var isPulsing = false

    private var progressToPrestige: Double {
        min(totalCredits / creditsRequired, 1.0)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("[ NETWORK WIPE ]")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)

                    if prestigeState.prestigeLevel > 0 {
                        HStack(spacing: 8) {
                            Text("Helix Level \(prestigeState.prestigeLevel)")
                                .font(.terminalBody)
                                .foregroundColor(.neonCyan)

                            Image(systemName: "hexagon.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.neonCyan)

                            Text("\(prestigeState.totalHelixCores) Cores")
                                .font(.terminalSmall)
                                .foregroundColor(.neonCyan)
                        }
                    }
                }

                Spacer()

                // Bonus indicators
                if prestigeState.prestigeLevel > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("+\(Int((prestigeState.productionMultiplier - 1) * 100))% Prod")
                            .font(.terminalMicro)
                            .foregroundColor(.neonGreen)
                        Text("+\(Int((prestigeState.creditMultiplier - 1) * 100))% Credits")
                            .font(.terminalMicro)
                            .foregroundColor(.neonAmber)
                    }
                }
            }

            // Progress to next prestige
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress to Wipe:")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                    Spacer()
                    Text("¢\(totalCredits.formatted) / ¢\(creditsRequired.formatted)")
                        .font(.terminalSmall)
                        .foregroundColor(canPrestige ? .neonCyan : .terminalGray)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.terminalGray.opacity(0.3))

                        Rectangle()
                            .fill(canPrestige ? Color.neonCyan : Color.neonCyan.opacity(0.5))
                            .frame(width: geo.size.width * progressToPrestige)
                    }
                }
                .frame(height: 8)
                .cornerRadius(4)
            }

            // Prestige button
            Button(action: onPrestige) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("INITIATE NETWORK WIPE")
                    Spacer()
                    if canPrestige {
                        Text("+\(helixCoresReward) Helix")
                            .foregroundColor(.neonCyan)
                    }
                }
                .font(.terminalSmall)
                .foregroundColor(canPrestige ? .terminalBlack : .terminalGray)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(canPrestige ? Color.neonCyan : Color.terminalGray.opacity(0.3))
                .cornerRadius(4)
            }
            .disabled(!canPrestige)
            .opacity(canPrestige && isPulsing ? 0.8 : 1.0)
        }
        .terminalCard(borderColor: canPrestige ? .neonCyan : .terminalGray)
        .shadow(color: canPrestige ? .neonCyan.opacity(isPulsing ? 0.5 : 0.2) : .clear, radius: canPrestige ? 10 : 0)
        .onAppear {
            if canPrestige {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}

// MARK: - Prestige Confirm View

struct PrestigeConfirmView: View {
    let prestigeState: PrestigeState
    let totalCredits: Double
    let creditsRequired: Double
    let helixCoresReward: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Warning icon
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 12)

                    Text("NETWORK WIPE")
                        .font(.terminalLarge)
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Warning text
                VStack(spacing: 12) {
                    Text("This will reset your network:")
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("All credits will be lost", systemImage: "xmark.circle")
                            .foregroundColor(.neonRed)
                        Label("All units reset to Tier 1", systemImage: "xmark.circle")
                            .foregroundColor(.neonRed)
                        Label("Threat level returns to GHOST", systemImage: "xmark.circle")
                            .foregroundColor(.neonRed)
                        Label("Milestones and lore preserved", systemImage: "checkmark.circle")
                            .foregroundColor(.neonGreen)
                    }
                    .font(.terminalSmall)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Rewards
                VStack(spacing: 12) {
                    Text("You will receive:")
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Image(systemName: "hexagon.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.neonCyan)
                            Text("+\(helixCoresReward)")
                                .font(.terminalLarge)
                                .foregroundColor(.neonCyan)
                            Text("Helix Cores")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }

                        VStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.neonGreen)
                            Text("+10%")
                                .font(.terminalLarge)
                                .foregroundColor(.neonGreen)
                            Text("Production")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }

                        VStack(spacing: 4) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.neonAmber)
                            Text("+15%")
                                .font(.terminalLarge)
                                .foregroundColor(.neonAmber)
                            Text("Credits")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }
                    }
                    .padding()
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("CONFIRM WIPE")
                        }
                        .font(.terminalTitle)
                        .foregroundColor(.terminalBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonCyan)
                        .cornerRadius(4)
                        .glow(.neonCyan, radius: 8)
                    }

                    Button(action: onCancel) {
                        Text("CANCEL")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                    }
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding()
            .padding(.top, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Scanline Overlay

struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for y in stride(from: 0, to: size.height, by: 3) {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                    context.fill(Path(rect), with: .color(.black.opacity(0.15)))
                }
            }
        }
    }
}

// MARK: - Offline Progress View

struct OfflineProgressView: View {
    let progress: OfflineProgress
    let onDismiss: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 10)

                    Text("OFFLINE PROGRESS")
                        .font(.terminalLarge)
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 4)

                    Text("Your network kept running while you were away")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Stats
                VStack(spacing: 16) {
                    HStack {
                        Text("Time Away:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text(progress.formattedTimeAway)
                            .font(.terminalReadable)
                            .foregroundColor(.neonCyan)
                    }

                    Divider()
                        .background(Color.neonCyan.opacity(0.3))

                    HStack {
                        Text("Ticks Processed:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text("\(progress.ticksSimulated.formatted())")
                            .font(.terminalReadable)
                            .foregroundColor(.neonGreen)
                    }

                    HStack {
                        Text("Data Processed:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text("\(progress.dataProcessed.formatted)")
                            .font(.terminalReadable)
                            .foregroundColor(.neonAmber)
                    }

                    Divider()
                        .background(Color.neonCyan.opacity(0.3))

                    HStack {
                        Text("Credits Earned:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text("¢\(progress.creditsEarned.formatted)")
                            .font(.terminalLarge)
                            .foregroundColor(.neonAmber)
                            .glow(.neonAmber, radius: 4)
                    }
                }
                .padding()
                .terminalCard(borderColor: .neonCyan)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Note about efficiency
                Text("(50% efficiency while offline)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // Dismiss button
                Button(action: onDismiss) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("COLLECT")
                    }
                    .font(.terminalTitle)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.neonGreen)
                    .cornerRadius(4)
                    .glow(.neonGreen, radius: 8)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
            }
            .padding()
            .padding(.top, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
            AudioManager.shared.playSound(.milestone)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(GameEngine())
}
