// DashboardView.swift
// ProjectPlague
// Main game dashboard showing the neural grid network

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var engine: GameEngine
    @State private var showingEvent: GameEvent? = nil
    @State private var screenShake: CGFloat = 0
    @State private var showingShop = false
    @State private var showingLore = false
    @State private var showingMilestones = false
    @State private var showingOfflineProgress = false
    @State private var showingPrestige = false
    @State private var showingCriticalAlarm = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Campaign exit callback (nil for endless mode)
    var onCampaignExit: (() -> Void)? = nil

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
        HStack(spacing: 0) {
            // Left sidebar - Stats, Defense, Intel
            VStack(spacing: 0) {
                // Alert banner
                AlertBannerView(event: showingEvent)
                    .zIndex(100)

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

                        FirewallCardView(
                            firewall: engine.firewall,
                            credits: engine.resources.credits,
                            damageAbsorbed: engine.lastTickStats.damageAbsorbed,
                            onUpgrade: { _ = engine.upgradeFirewall() },
                            onRepair: { _ = engine.repairFirewall() },
                            onPurchase: { _ = engine.purchaseFirewall() }
                        )

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

                        // Malus Intel
                        MalusIntelPanel(
                            intel: engine.malusIntel,
                            onSendReport: {
                                _ = engine.sendMalusReport()
                            }
                        )

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
            .frame(width: 380)
            .background(Color.terminalDarkGray.opacity(0.5))

            // Divider
            Rectangle()
                .fill(Color.neonGreen.opacity(0.3))
                .frame(width: 1)

            // Right main area - Network Map
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
                        .padding(.horizontal, 40)
                        .padding(.top, 16)

                        // Node cards in a wider layout
                        HStack(alignment: .top, spacing: 20) {
                            // Source
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
                                .frame(height: 40)
                            }
                            .frame(maxWidth: .infinity)

                            // Link
                            VStack(spacing: 0) {
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
                                .frame(height: 40)
                            }
                            .frame(maxWidth: .infinity)

                            // Sink
                            VStack(spacing: 0) {
                                SinkCardView(
                                    sink: engine.sink,
                                    credits: engine.resources.credits,
                                    onUpgrade: { _ = engine.upgradeSink() }
                                )
                                Spacer()
                                    .frame(height: 40)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 24)

                        // Network stats at bottom
                        ThreatStatsView(
                            threatState: engine.threatState,
                            totalGenerated: engine.totalDataGenerated,
                            totalTransferred: engine.totalDataTransferred,
                            totalDropped: engine.totalDataDropped,
                            totalProcessed: engine.resources.totalDataProcessed
                        )
                        .padding(40)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .offset(x: reduceMotion ? 0 : screenShake)
    }

    // MARK: - iPhone Layout (Original stacked layout)

    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            // Alert banner (appears above header)
            AlertBannerView(event: showingEvent)
                .zIndex(100)

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
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Malus Intelligence Panel
                    MalusIntelPanel(
                        intel: engine.malusIntel,
                        onSendReport: {
                            _ = engine.sendMalusReport()
                        }
                    )
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
                    .padding()

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
        }
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
        HStack(spacing: 12) {
            // Title
            Text("PROJECT PLAGUE")
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
        switch threatState.currentLevel {
        case .ghost: return .dimGreen
        case .blip: return .neonGreen
        case .signal: return .neonCyan
        case .target, .priority: return .neonAmber
        case .hunted, .marked, .targeted, .hammered, .critical: return .neonRed
        }
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
        }
    }

    private var malusColor: Color {
        switch threatState.currentLevel {
        case .ghost, .blip: return .terminalGray
        case .signal, .target: return .neonAmber
        case .priority, .hunted, .marked, .targeted, .hammered, .critical: return .neonRed
        }
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
