// DefenseApplicationView.swift
// GridWatchZero
// UI components for defense application display

import SwiftUI

// MARK: - Defense Stack View

struct DefenseStackView: View {
    let stack: DefenseStack
    let credits: Double
    let maxTierAvailable: Int  // Maximum tier available in current level (defaults to 6 for sandbox)
    let onUpgrade: (DefenseCategory) -> Void
    let onDeploy: (DefenseAppTier) -> Void
    let onUnlock: (DefenseAppTier) -> Void

    init(stack: DefenseStack, credits: Double, maxTierAvailable: Int = 6, onUpgrade: @escaping (DefenseCategory) -> Void, onDeploy: @escaping (DefenseAppTier) -> Void, onUnlock: @escaping (DefenseAppTier) -> Void) {
        self.stack = stack
        self.credits = credits
        self.maxTierAvailable = maxTierAvailable
        self.onUpgrade = onUpgrade
        self.onDeploy = onDeploy
        self.onUnlock = onUnlock
    }

    var body: some View {
        VStack(spacing: 8) {
            // Section header
            HStack {
                Text("[ SECURITY APPLICATIONS ]")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Rectangle()
                    .fill(Color.terminalGray.opacity(0.3))
                    .frame(height: 1)
            }

            // Stack status summary
            DefenseStackSummary(stack: stack)

            // Application grid (2 columns)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(DefenseCategory.allCases, id: \.self) { category in
                    DefenseAppCard(
                        category: category,
                        application: stack.application(for: category),
                        stack: stack,
                        credits: credits,
                        maxTierAvailable: maxTierAvailable,
                        onUpgrade: { onUpgrade(category) },
                        onDeploy: { tier in onDeploy(tier) },
                        onUnlock: { tier in onUnlock(tier) }
                    )
                }
            }
        }
    }
}

// MARK: - Defense Stack Summary

struct DefenseStackSummary: View {
    let stack: DefenseStack

    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            HStack(spacing: 4) {
                Image(systemName: stack.overallStatus.icon)
                    .font(.system(size: 10))
                    .foregroundColor(statusColor)
                Text(stack.overallStatus.rawValue)
                    .font(.terminalMicro)
                    .foregroundColor(statusColor)
            }

            Spacer()

            // Deployed count
            VStack(alignment: .trailing, spacing: 2) {
                Text("DEPLOYED")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(.terminalGray)
                Text("\(stack.deployedCount)/6")
                    .font(.terminalSmall)
                    .foregroundColor(.neonCyan)
            }

            // Defense points
            VStack(alignment: .trailing, spacing: 2) {
                Text("DEF PTS")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(.terminalGray)
                Text(stack.totalDefensePoints.formatted)
                    .font(.terminalSmall)
                    .foregroundColor(.neonGreen)
            }

            // Damage reduction
            VStack(alignment: .trailing, spacing: 2) {
                Text("DR")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(.terminalGray)
                Text(stack.totalDamageReduction.percentFormatted)
                    .font(.terminalSmall)
                    .foregroundColor(.neonRed)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.terminalDarkGray.opacity(0.5))
        .cornerRadius(4)
    }

    private var statusColor: Color {
        switch stack.overallStatus {
        case .nominal: return .neonGreen
        case .degraded, .alert: return .neonAmber
        case .critical: return .neonRed
        case .offline: return .terminalGray
        }
    }
}

// MARK: - Defense App Card

struct DefenseAppCard: View {
    let category: DefenseCategory
    let application: DefenseApplication?
    let stack: DefenseStack
    let credits: Double
    let maxTierAvailable: Int  // Maximum tier available in this level
    let onUpgrade: () -> Void
    let onDeploy: (DefenseAppTier) -> Void
    let onUnlock: (DefenseAppTier) -> Void

    @State private var showingTierSheet = false

    private var cardColor: Color {
        guard let app = application else { return .terminalGray }
        switch app.status {
        case .nominal: return .neonGreen
        case .degraded, .alert: return .neonAmber
        case .critical: return .neonRed
        case .offline: return .terminalGray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 10))
                    .foregroundColor(application != nil ? cardColor : .terminalGray)

                Text(category.rawValue)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Spacer()

                if let app = application {
                    Text("LVL \(app.level)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(cardColor)
                        .cornerRadius(2)
                }
            }

            if let app = application {
                // Deployed application
                VStack(alignment: .leading, spacing: 4) {
                    // Name and tier indicator
                    HStack {
                        Text(app.shortName)
                            .font(.terminalBody)
                            .foregroundColor(cardColor)
                            .glow(cardColor, radius: 2)

                        Spacer()

                        // Show tier badge
                        Text("T\(app.tier.tierNumber)")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(.terminalBlack)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background(cardColor.opacity(0.8))
                            .cornerRadius(2)

                        Image(systemName: app.status.icon)
                            .font(.system(size: 8))
                            .foregroundColor(cardColor)
                    }

                    // Stats row
                    HStack(spacing: 8) {
                        // Defense points
                        VStack(alignment: .leading, spacing: 1) {
                            Text("DEF")
                                .font(.system(size: 6, design: .monospaced))
                                .foregroundColor(.terminalGray)
                            Text("+\(Int(app.defensePoints))")
                                .font(.terminalMicro)
                                .foregroundColor(.neonGreen)
                        }

                        // Damage reduction
                        VStack(alignment: .leading, spacing: 1) {
                            Text("DR")
                                .font(.system(size: 6, design: .monospaced))
                                .foregroundColor(.terminalGray)
                            Text(app.damageReduction.percentFormatted)
                                .font(.terminalMicro)
                                .foregroundColor(.neonRed)
                        }

                        Spacer()

                        // Level upgrade button or MAX badge
                        if app.isAtMaxLevel {
                            Text("MAX")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.terminalBlack)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.neonGreen.opacity(0.8))
                                .cornerRadius(2)
                        } else {
                            Button(action: onUpgrade) {
                                HStack(spacing: 2) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 7))
                                    Text("¢\(app.upgradeCost.formatted)")
                                        .font(.system(size: 8, design: .monospaced))
                                }
                                .foregroundColor(credits >= app.upgradeCost ? .terminalBlack : .terminalGray)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 3)
                                .background(credits >= app.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < app.upgradeCost)
                        }
                    }

                    // Tier upgrade section - show if higher tier is available
                    if let nextTier = app.tier.nextTier, nextTier.tierNumber <= maxTierAvailable {
                        let isNextUnlocked = stack.isUnlocked(nextTier)
                        let canUnlockNext = stack.canUnlock(nextTier)
                        let gateReason = stack.tierGateReason(for: nextTier)

                        Divider()
                            .background(Color.terminalGray.opacity(0.3))

                        if isNextUnlocked {
                            // Can deploy next tier directly
                            Button(action: { onDeploy(nextTier) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 8))
                                    Text("UPGRADE TO T\(nextTier.tierNumber)")
                                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(.terminalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .background(Color.neonCyan)
                                .cornerRadius(2)
                            }
                        } else if canUnlockNext {
                            // Need to unlock first (current tier is at max)
                            Button(action: { onUnlock(nextTier) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.open.fill")
                                        .font(.system(size: 8))
                                    Text("UNLOCK T\(nextTier.tierNumber) ¢\(nextTier.unlockCost.formatted)")
                                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(credits >= nextTier.unlockCost ? .terminalBlack : .terminalGray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .background(credits >= nextTier.unlockCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < nextTier.unlockCost)
                        } else if let reason = gateReason {
                            // Show why can't unlock (need to max current tier)
                            Text(reason)
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(.terminalGray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                    }
                }
            } else {
                // Empty slot - show first available tier
                let firstTier = category.progressionChain.first!
                let canUnlockFirst = stack.canUnlock(firstTier)
                let isUnlocked = stack.isUnlocked(firstTier)

                VStack(alignment: .leading, spacing: 4) {
                    Text(isUnlocked ? firstTier.shortName : "LOCKED")
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    if isUnlocked {
                        Button(action: { onDeploy(firstTier) }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 8))
                                Text("DEPLOY")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(.terminalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .background(Color.neonCyan)
                            .cornerRadius(2)
                        }
                    } else if canUnlockFirst {
                        Button(action: { onUnlock(firstTier) }) {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.open.fill")
                                    .font(.system(size: 8))
                                Text("¢\(firstTier.unlockCost.formatted)")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(credits >= firstTier.unlockCost ? .terminalBlack : .terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .background(credits >= firstTier.unlockCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                            .cornerRadius(2)
                        }
                        .disabled(credits < firstTier.unlockCost)
                    } else {
                        Text("Prereq required")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                    }
                }
            }
        }
        .padding(8)
        .background(Color.terminalDarkGray)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(application != nil ? cardColor.opacity(0.5) : Color.terminalGray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(4)
    }
}

// MARK: - Network Topology View (Enhanced)

struct NetworkTopologyView: View {
    let source: SourceNode
    let link: TransportLink
    let sink: SinkNode
    let stack: DefenseStack
    let isRunning: Bool
    var tickStats: TickStats?
    var threatLevel: ThreatLevel?
    var activeAttack: Attack?
    var malusIntel: MalusIntelligence?

    @State private var flowOffset: CGFloat = 0
    @State private var attackPulse: Bool = false

    // Calculate network efficiency
    private var efficiency: Double {
        guard let stats = tickStats, stats.dataGenerated > 0 else { return 1.0 }
        return 1.0 - stats.dropRate
    }

    // Determine bottleneck
    private var bottleneck: NetworkBottleneck {
        let srcOutput = source.productionPerTick
        let linkCap = link.bandwidth
        let sinkCap = sink.processingPerTick

        if linkCap < srcOutput && linkCap < sinkCap {
            return .link
        } else if sinkCap < srcOutput && sinkCap < linkCap {
            return .sink
        } else if srcOutput < linkCap * 0.5 {
            return .source
        }
        return .none
    }

    private var efficiencyColor: Color {
        if efficiency >= 0.8 { return .neonGreen }
        if efficiency >= 0.5 { return .neonAmber }
        return .neonRed
    }

    var body: some View {
        VStack(spacing: 4) {
            // Section header with live stats
            HStack {
                Text("[ NETWORK TOPOLOGY ]")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Spacer()

                // Live efficiency indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(efficiencyColor)
                        .frame(width: 6, height: 6)
                        .glow(efficiencyColor, radius: isRunning ? 3 : 0)

                    Text("\(Int(efficiency * 100))% EFF")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(efficiencyColor)
                }

                // Bottleneck indicator
                if bottleneck != .none {
                    Text("[\(bottleneck.label)]")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.neonAmber)
                }
            }

            // Main topology diagram
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height

                ZStack {
                    // Background grid
                    TopologyGrid()

                    // Data flow pipeline (main horizontal line)
                    DataFlowPipeline(
                        width: width,
                        height: height,
                        efficiency: efficiency,
                        isRunning: isRunning,
                        flowOffset: flowOffset
                    )

                    // Defense shield overlay
                    if stack.deployedCount > 0 {
                        DefenseShieldOverlay(
                            width: width,
                            height: height,
                            damageReduction: stack.totalDamageReduction,
                            isUnderAttack: activeAttack != nil
                        )
                    }

                    // Attack indicator
                    if let attack = activeAttack {
                        TopologyAttackIndicator(
                            width: width,
                            height: height,
                            attack: attack,
                            pulse: attackPulse
                        )
                    }

                    // === NODE: SOURCE ===
                    EnhancedTopologyNode(
                        icon: "antenna.radiowaves.left.and.right",
                        label: "SOURCE",
                        primaryStat: "\(source.productionPerTick.formatted)/t",
                        secondaryStat: "T\(source.tier)",
                        color: bottleneck == .source ? .neonAmber : .neonGreen,
                        isBottleneck: bottleneck == .source
                    )
                    .position(x: width * 0.12, y: height * 0.55)

                    // === NODE: LINK ===
                    EnhancedTopologyNode(
                        icon: "arrow.left.arrow.right.circle.fill",
                        label: "LINK",
                        primaryStat: "BW:\(link.bandwidth.formatted)",
                        secondaryStat: tickStats.map { "-\($0.dataDropped.formatted)" } ?? "",
                        color: bottleneck == .link ? .neonRed : .neonCyan,
                        isBottleneck: bottleneck == .link,
                        showDropWarning: (tickStats?.dropRate ?? 0) > 0.1
                    )
                    .position(x: width * 0.40, y: height * 0.55)

                    // === NODE: SINK ===
                    EnhancedTopologyNode(
                        icon: "cpu.fill",
                        label: "SINK",
                        primaryStat: "\(sink.processingPerTick.formatted)/t",
                        secondaryStat: "₵\(sink.conversionRate.formatted)",
                        color: bottleneck == .sink ? .neonAmber : .neonAmber,
                        isBottleneck: bottleneck == .sink
                    )
                    .position(x: width * 0.68, y: height * 0.55)

                    // === NODE: DEFENSE STACK ===
                    DefenseStackNode(
                        stack: stack,
                        malusIntel: malusIntel
                    )
                    .position(x: width * 0.90, y: height * 0.35)

                    // === NODE: THREAT CLOUD ===
                    ThreatCloudNode(
                        threatLevel: threatLevel ?? .ghost,
                        isUnderAttack: activeAttack != nil,
                        attackType: activeAttack?.type
                    )
                    .position(x: width * 0.12, y: height * 0.15)

                    // Threat connection line (animated when under attack)
                    ThreatConnectionLine(
                        width: width,
                        height: height,
                        isUnderAttack: activeAttack != nil
                    )

                    // Flow rate labels between nodes
                    if let stats = tickStats, isRunning {
                        // Source → Link flow
                        Text("\(stats.dataGenerated.formatted)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.neonGreen)
                            .position(x: width * 0.26, y: height * 0.42)

                        // Link → Sink flow
                        Text("\(stats.dataTransferred.formatted)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.neonCyan)
                            .position(x: width * 0.54, y: height * 0.42)

                        // Credits earned
                        Text("+₵\(stats.creditsEarned.formatted)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.neonAmber)
                            .position(x: width * 0.78, y: height * 0.70)
                    }
                }
            }
            .frame(height: 120)
            .padding(8)
            .background(Color.terminalDarkGray.opacity(0.7))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(activeAttack != nil ? Color.neonRed.opacity(0.7) : Color.neonGreen.opacity(0.4), lineWidth: activeAttack != nil ? 2 : 1)
            )
            .onAppear {
                if isRunning {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        flowOffset = 1
                    }
                }
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    attackPulse.toggle()
                }
            }

            // Bottom stats bar
            TopologyStatsBar(
                source: source,
                link: link,
                sink: sink,
                stack: stack,
                tickStats: tickStats
            )
        }
    }
}

// MARK: - Network Bottleneck

enum NetworkBottleneck {
    case none
    case source
    case link
    case sink

    var label: String {
        switch self {
        case .none: return ""
        case .source: return "LOW INPUT"
        case .link: return "BW LIMIT"
        case .sink: return "PROC LIMIT"
        }
    }
}

// MARK: - Data Flow Pipeline

struct DataFlowPipeline: View {
    let width: CGFloat
    let height: CGFloat
    let efficiency: Double
    let isRunning: Bool
    let flowOffset: CGFloat

    var body: some View {
        ZStack {
            // Main pipeline background
            Path { path in
                path.move(to: CGPoint(x: width * 0.18, y: height * 0.55))
                path.addLine(to: CGPoint(x: width * 0.34, y: height * 0.55))
            }
            .stroke(Color.neonGreen.opacity(0.2), lineWidth: 4)

            Path { path in
                path.move(to: CGPoint(x: width * 0.46, y: height * 0.55))
                path.addLine(to: CGPoint(x: width * 0.62, y: height * 0.55))
            }
            .stroke(Color.neonCyan.opacity(0.2), lineWidth: 4)

            // Animated flow particles
            if isRunning {
                // Source to Link particles
                ForEach(0..<4, id: \.self) { i in
                    let progress = (flowOffset + CGFloat(i) * 0.25).truncatingRemainder(dividingBy: 1)
                    Circle()
                        .fill(Color.neonGreen)
                        .frame(width: 3, height: 3)
                        .glow(.neonGreen, radius: 2)
                        .position(
                            x: width * (0.18 + 0.16 * progress),
                            y: height * 0.55
                        )
                        .opacity(efficiency > 0.3 ? 1 : 0.3)
                }

                // Link to Sink particles (fewer if dropping packets)
                let particleCount = Int(max(1, 4 * efficiency))
                ForEach(0..<particleCount, id: \.self) { i in
                    let progress = (flowOffset + CGFloat(i) * (1.0 / CGFloat(particleCount))).truncatingRemainder(dividingBy: 1)
                    Circle()
                        .fill(Color.neonCyan)
                        .frame(width: 3, height: 3)
                        .glow(.neonCyan, radius: 2)
                        .position(
                            x: width * (0.46 + 0.16 * progress),
                            y: height * 0.55
                        )
                }

                // Dropped packet indicators (red particles falling)
                if efficiency < 0.9 {
                    ForEach(0..<Int(3 * (1 - efficiency)), id: \.self) { i in
                        let dropProgress = (flowOffset * 1.5 + CGFloat(i) * 0.33).truncatingRemainder(dividingBy: 1)
                        Circle()
                            .fill(Color.neonRed.opacity(0.6))
                            .frame(width: 2, height: 2)
                            .position(
                                x: width * 0.40,
                                y: height * (0.55 + 0.25 * dropProgress)
                            )
                            .opacity(1 - dropProgress)
                    }
                }
            }
        }
    }
}

// MARK: - Defense Shield Overlay

struct DefenseShieldOverlay: View {
    let width: CGFloat
    let height: CGFloat
    let damageReduction: Double
    let isUnderAttack: Bool

    var body: some View {
        // Shield arc around the network
        Path { path in
            path.addArc(
                center: CGPoint(x: width * 0.45, y: height * 0.55),
                radius: width * 0.38,
                startAngle: .degrees(160),
                endAngle: .degrees(20),
                clockwise: true
            )
        }
        .stroke(
            Color.neonCyan.opacity(isUnderAttack ? 0.4 : 0.15),
            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
        )
        .overlay(
            // DR percentage label
            Text("\(Int(damageReduction * 100))% DR")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.neonCyan.opacity(0.6))
                .position(x: width * 0.45, y: height * 0.12)
        )
    }
}

// MARK: - Topology Attack Indicator

struct TopologyAttackIndicator: View {
    let width: CGFloat
    let height: CGFloat
    let attack: Attack
    let pulse: Bool

    var body: some View {
        // Attack beam from threat to network
        Path { path in
            path.move(to: CGPoint(x: width * 0.12, y: height * 0.25))
            path.addLine(to: CGPoint(x: width * 0.40, y: height * 0.45))
        }
        .stroke(
            Color.neonRed,
            style: StrokeStyle(lineWidth: pulse ? 3 : 2, dash: [6, 3])
        )
        .opacity(pulse ? 1.0 : 0.6)

        // Attack type label
        Text(attack.type.rawValue)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundColor(.neonRed)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.terminalBlack.opacity(0.8))
            .cornerRadius(2)
            .position(x: width * 0.26, y: height * 0.30)

        // Progress bar
        let progress = attack.progress
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.terminalGray.opacity(0.3))
                .frame(width: 40, height: 3)
            Rectangle()
                .fill(Color.neonRed)
                .frame(width: 40 * progress, height: 3)
        }
        .position(x: width * 0.26, y: height * 0.38)
    }
}

// MARK: - Enhanced Topology Node

struct EnhancedTopologyNode: View {
    let icon: String
    let label: String
    let primaryStat: String
    let secondaryStat: String
    let color: Color
    var isBottleneck: Bool = false
    var showDropWarning: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Outer ring (pulses if bottleneck)
                Circle()
                    .stroke(color.opacity(isBottleneck ? 0.9 : 0.5), lineWidth: isBottleneck ? 2 : 1.5)
                    .frame(width: 36, height: 36)

                // Inner fill
                Circle()
                    .fill(Color.terminalDarkGray)
                    .frame(width: 32, height: 32)

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)

                // Drop warning indicator
                if showDropWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonRed)
                        .offset(x: 14, y: -14)
                }
            }

            // Label
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(color)

            // Primary stat
            Text(primaryStat)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            // Secondary stat
            if !secondaryStat.isEmpty {
                Text(secondaryStat)
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(secondaryStat.contains("-") ? .neonRed : .terminalGray)
            }
        }
    }
}

// MARK: - Defense Stack Node

struct DefenseStackNode: View {
    let stack: DefenseStack
    let malusIntel: MalusIntelligence?

    var body: some View {
        VStack(spacing: 1) {
            ZStack {
                // Shield icon with fill based on coverage
                Circle()
                    .fill(Color.terminalDarkGray)
                    .frame(width: 32, height: 32)

                Circle()
                    .trim(from: 0, to: CGFloat(stack.deployedCount) / 6.0)
                    .stroke(Color.neonCyan, lineWidth: 3)
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "shield.checkered")
                    .font(.system(size: 12))
                    .foregroundColor(stack.deployedCount > 0 ? .neonCyan : .terminalGray)
            }

            Text("DEFENSE")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.neonCyan)

            // Defense stats
            Text("\(stack.deployedCount)/6")
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            // Intel indicator if available
            if let intel = malusIntel, intel.reportsSent > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 6))
                    Text("\(intel.reportsSent)")
                        .font(.system(size: 6, design: .monospaced))
                }
                .foregroundColor(.neonAmber)
            }
        }
    }
}

// MARK: - Threat Cloud Node

struct ThreatCloudNode: View {
    let threatLevel: ThreatLevel
    let isUnderAttack: Bool
    let attackType: AttackType?

    private var threatColor: Color {
        // Use the tier color from Theme.swift for all threat levels
        Color.tierColor(named: threatLevel.color)
    }

    var body: some View {
        VStack(spacing: 1) {
            ZStack {
                // Cloud with threat color
                Image(systemName: isUnderAttack ? "cloud.bolt.fill" : "cloud.fill")
                    .font(.system(size: 20))
                    .foregroundColor(threatColor)
                    .shadow(color: isUnderAttack ? .neonRed : .clear, radius: 4)
            }

            Text(threatLevel.name)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(threatColor)

            if let attack = attackType {
                Text(attack.rawValue)
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.neonRed)
            }
        }
    }
}

// MARK: - Threat Connection Line

struct ThreatConnectionLine: View {
    let width: CGFloat
    let height: CGFloat
    let isUnderAttack: Bool

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: width * 0.12, y: height * 0.25))
            path.addLine(to: CGPoint(x: width * 0.12, y: height * 0.42))
        }
        .stroke(
            isUnderAttack ? Color.neonRed : Color.neonRed.opacity(0.3),
            style: StrokeStyle(lineWidth: isUnderAttack ? 2 : 1, dash: [4, 2])
        )
    }
}

// MARK: - Topology Stats Bar

struct TopologyStatsBar: View {
    let source: SourceNode
    let link: TransportLink
    let sink: SinkNode
    let stack: DefenseStack
    let tickStats: TickStats?

    var body: some View {
        HStack(spacing: 12) {
            // Input rate
            TopologyStatPill(
                icon: "arrow.down.circle",
                label: "IN",
                value: "\(source.productionPerTick.formatted)/t",
                color: .neonGreen
            )

            // Throughput
            TopologyStatPill(
                icon: "arrow.right.circle",
                label: "THRU",
                value: "\(link.bandwidth.formatted)",
                color: .neonCyan
            )

            // Output/Credits
            TopologyStatPill(
                icon: "creditcard",
                label: "OUT",
                value: tickStats.map { "₵\($0.creditsEarned.formatted)" } ?? "₵0",
                color: .neonAmber
            )

            Spacer()

            // Defense coverage
            if stack.deployedCount > 0 {
                TopologyStatPill(
                    icon: "shield",
                    label: "DR",
                    value: "\(Int(stack.totalDamageReduction * 100))%",
                    color: .neonCyan
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.terminalDarkGray.opacity(0.3))
        .cornerRadius(4)
    }
}

// MARK: - Topology Stat Pill

struct TopologyStatPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        HStack(spacing: isIPad ? 4 : 3) {
            Image(systemName: icon)
                .font(.system(size: isIPad ? 10 : 8))
                .foregroundColor(color.opacity(0.8))

            Text(label)
                .font(.system(size: isIPad ? 9 : 7, design: .monospaced))
                .foregroundColor(.terminalGray)

            Text(value)
                .font(.system(size: isIPad ? 10 : 8, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

// MARK: - Topology Grid

struct TopologyGrid: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // Vertical lines
                for x in stride(from: 0, to: size.width, by: 20) {
                    let path = Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(path, with: .color(.terminalGray.opacity(0.15)), lineWidth: 0.5)
                }
                // Horizontal lines
                for y in stride(from: 0, to: size.height, by: 20) {
                    let path = Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(.terminalGray.opacity(0.15)), lineWidth: 0.5)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        NetworkTopologyView(
            source: UnitFactory.createPublicMeshSniffer(),
            link: UnitFactory.createCopperVPNTunnel(),
            sink: UnitFactory.createDataBroker(),
            stack: DefenseStack(),
            isRunning: true,
            tickStats: TickStats(
                dataGenerated: 50,
                dataTransferred: 42,
                dataDropped: 8,
                creditsEarned: 63,
                creditsDrained: 0,
                damageAbsorbed: 0,
                bufferUtilization: 0.4
            ),
            threatLevel: .target,
            activeAttack: nil,
            malusIntel: MalusIntelligence()
        )

        DefenseStackView(
            stack: DefenseStack(),
            credits: 10000,
            onUpgrade: { _ in },
            onDeploy: { _ in },
            onUnlock: { _ in }
        )
    }
    .padding()
    .background(Color.terminalBlack)
}
