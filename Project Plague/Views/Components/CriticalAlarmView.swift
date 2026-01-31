// CriticalAlarmView.swift
// GridWatchZero
// Full-screen alarm overlay when threat is critical

import SwiftUI

struct CriticalAlarmView: View {
    let threatLevel: ThreatLevel
    let riskLevel: ThreatLevel
    let activeAttack: Attack?
    let defenseStack: DefenseStack
    let onAcknowledge: () -> Void
    let onBoostDefenses: () -> Void

    @State private var isPulsing = false
    @State private var glitchOffset: CGFloat = 0
    @State private var showDetails = false

    var body: some View {
        ZStack {
            // Dark overlay with red tint
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            // Glitch/static effect
            GlitchOverlay(intensity: isPulsing ? 1.0 : 0.5)
                .ignoresSafeArea()

            // Red pulsing vignette
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.neonRed.opacity(isPulsing ? 0.4 : 0.2)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Warning icon with pulse
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(Color.neonRed.opacity(isPulsing ? 0.3 : 0), lineWidth: 3)
                        .frame(width: 150, height: 150)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)

                    // Inner ring
                    Circle()
                        .stroke(Color.neonRed, lineWidth: 2)
                        .frame(width: 100, height: 100)

                    // Icon
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.neonRed)
                        .glow(.neonRed, radius: isPulsing ? 20 : 10)
                        .offset(x: glitchOffset)
                }

                // CRITICAL text with glitch effect
                VStack(spacing: 8) {
                    Text("CRITICAL THREAT")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.neonRed)
                        .glow(.neonRed, radius: 8)
                        .offset(x: glitchOffset)

                    Text("ACTION REQUIRED")
                        .font(.terminalTitle)
                        .foregroundColor(.white)
                        .opacity(isPulsing ? 1 : 0.7)
                }

                // Threat info box
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("THREAT LEVEL")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(threatLevel.name)
                                .font(.terminalTitle)
                                .foregroundColor(.neonRed)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("RISK LEVEL")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(riskLevel.name)
                                .font(.terminalTitle)
                                .foregroundColor(.neonRed)
                        }
                    }

                    if let attack = activeAttack {
                        Divider()
                            .background(Color.neonRed.opacity(0.5))

                        HStack {
                            Image(systemName: attack.type.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.neonRed)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(attack.type.displayName)
                                    .font(.terminalBody)
                                    .foregroundColor(.white)
                                Text(attack.type.description)
                                    .font(.terminalMicro)
                                    .foregroundColor(.terminalGray)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("SEVERITY")
                                    .font(.terminalMicro)
                                    .foregroundColor(.terminalGray)
                                Text(String(format: "%.1fx", attack.severity))
                                    .font(.terminalBody)
                                    .foregroundColor(.neonRed)
                            }
                        }
                    }

                    Divider()
                        .background(Color.neonRed.opacity(0.5))

                    // Defense status
                    HStack {
                        Text("DEFENSE STATUS:")
                            .font(.terminalSmall)
                            .foregroundColor(.terminalGray)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: defenseStack.overallStatus.icon)
                                .font(.system(size: 12))
                            Text(defenseStack.overallStatus.rawValue)
                                .font(.terminalSmall)
                        }
                        .foregroundColor(defenseStatusColor)
                    }

                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("DEPLOYED")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text("\(defenseStack.deployedCount)/6")
                                .font(.terminalSmall)
                                .foregroundColor(.neonCyan)
                        }

                        VStack(spacing: 2) {
                            Text("DEF PTS")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(defenseStack.totalDefensePoints.formatted)
                                .font(.terminalSmall)
                                .foregroundColor(.neonGreen)
                        }

                        VStack(spacing: 2) {
                            Text("DAMAGE RED")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(defenseStack.totalDamageReduction.percentFormatted)
                                .font(.terminalSmall)
                                .foregroundColor(.neonRed)
                        }
                    }
                }
                .padding()
                .background(Color.terminalDarkGray.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonRed, lineWidth: 2)
                )
                .cornerRadius(4)
                .padding(.horizontal)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    // Boost defenses button
                    if defenseStack.deployedCount < 6 {
                        Button(action: onBoostDefenses) {
                            HStack {
                                Image(systemName: "shield.fill")
                                Text("BOOST DEFENSES")
                            }
                            .font(.terminalTitle)
                            .foregroundColor(.terminalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.neonCyan)
                            .cornerRadius(4)
                            .glow(.neonCyan, radius: 8)
                        }
                    }

                    // Acknowledge button
                    Button(action: onAcknowledge) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("ACKNOWLEDGE")
                        }
                        .font(.terminalBody)
                        .foregroundColor(.neonRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.terminalDarkGray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.neonRed, lineWidth: 1)
                        )
                        .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }

            // Glitch effect
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if Bool.random() {
                    glitchOffset = CGFloat.random(in: -3...3)
                } else {
                    glitchOffset = 0
                }
            }

            // Play alarm sound
            AudioManager.shared.playSound(.attackIncoming)
        }
    }

    private var defenseStatusColor: Color {
        switch defenseStack.overallStatus {
        case .nominal: return .neonGreen
        case .degraded, .alert: return .neonAmber
        case .critical, .offline: return .neonRed
        }
    }
}

// MARK: - Glitch Overlay

struct GlitchOverlay: View {
    let intensity: Double

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // Random horizontal lines
                for _ in 0..<Int(intensity * 20) {
                    let y = CGFloat.random(in: 0..<size.height)
                    let height = CGFloat.random(in: 1...3)
                    let offset = CGFloat.random(in: -5...5)

                    let rect = CGRect(x: offset, y: y, width: size.width, height: height)
                    context.fill(
                        Path(rect),
                        with: .color(.neonRed.opacity(Double.random(in: 0.1...0.3)))
                    )
                }

                // Static noise
                for _ in 0..<Int(intensity * 50) {
                    let x = CGFloat.random(in: 0..<size.width)
                    let y = CGFloat.random(in: 0..<size.height)
                    let pixel = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(
                        Path(pixel),
                        with: .color(.white.opacity(Double.random(in: 0...0.1)))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Malus Intel Panel

struct MalusIntelPanel: View {
    let intel: MalusIntelligence
    let onSendReport: () -> Void

    @State private var showingInfo = false

    private var nextReward: Double {
        // Base reward scales with patterns known
        100.0 + (Double(intel.patternsIdentified) * 10.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with mission context
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 12))
                    .foregroundColor(.neonAmber)

                Text("[ MALUS INTELLIGENCE ]")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Rectangle()
                    .fill(Color.terminalGray.opacity(0.3))
                    .frame(height: 1)

                // Info button
                Button(action: { showingInfo.toggle() }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.terminalGray)
                }
            }

            // Mission context (collapsible)
            if showingInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MISSION: Track the source of Malus attacks")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.neonAmber)

                    Text("Every attack leaves traces. Your SIEM and IDS systems collect footprint data when you survive attacks. Send reports to help Ronin's team locate Malus and rescue Helix.")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.terminalGray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)
                .background(Color.terminalDarkGray.opacity(0.5))
                .cornerRadius(4)
            }

            // Collection Stats
            HStack(spacing: 0) {
                // Footprint Data (main resource)
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 10))
                        .foregroundColor(.neonCyan)
                    Text(intel.footprintData.formatted)
                        .font(.terminalBody)
                        .foregroundColor(.neonCyan)
                    Text("DATA")
                        .font(.system(size: 6, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }
                .frame(maxWidth: .infinity)

                // Patterns Identified
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 10))
                        .foregroundColor(.neonAmber)
                    Text("\(intel.patternsIdentified)")
                        .font(.terminalBody)
                        .foregroundColor(.neonAmber)
                    Text("PATTERNS")
                        .font(.system(size: 6, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }
                .frame(maxWidth: .infinity)

                // Reports Sent
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonGreen)
                    Text("\(intel.reportsSent)")
                        .font(.terminalBody)
                        .foregroundColor(.neonGreen)
                    Text("REPORTS")
                        .font(.system(size: 6, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }
                .frame(maxWidth: .infinity)

                // Credits Earned
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonGreen)
                    Text("₵\(intel.totalIntelCredits.formatted)")
                        .font(.terminalBody)
                        .foregroundColor(.neonGreen)
                    Text("EARNED")
                        .font(.system(size: 6, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            .background(Color.terminalDarkGray.opacity(0.3))
            .cornerRadius(4)

            // Milestone Progress
            if let nextMilestone = intel.nextMilestone {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 8))
                            .foregroundColor(.neonAmber)
                        Text("NEXT MILESTONE: \(nextMilestone.name)")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.neonAmber)
                        Spacer()
                        Text("\(intel.reportsSent)/\(nextMilestone.rawValue) reports")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.terminalGray)
                    }

                    // Progress bar to next milestone
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.terminalGray.opacity(0.3))

                            let progress = Double(intel.reportsSent) / Double(nextMilestone.rawValue)
                            Rectangle()
                                .fill(Color.neonAmber)
                                .frame(width: geo.size.width * min(1.0, progress))
                        }
                    }
                    .frame(height: 4)
                    .cornerRadius(2)

                    // Milestone reward preview
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 7))
                            .foregroundColor(.neonGreen)
                        Text("Reward: ₵\(nextMilestone.creditReward.formatted) + \(nextMilestone.bonusDescription)")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.terminalGray)
                    }
                }
            } else {
                // All milestones complete!
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonGreen)
                    Text("ALL MILESTONES COMPLETE")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.neonGreen)
                }
            }

            // Send report button with reward preview
            Button(action: onSendReport) {
                HStack {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 10))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("SEND INTEL REPORT")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        if intel.canSendReport {
                            Text("Reward: ~₵\(Int(nextReward))")
                                .font(.system(size: 7, design: .monospaced))
                                .opacity(0.8)
                        }
                    }
                    Spacer()
                    if intel.canSendReport {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("READY")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                            Text("-\(Int(intel.reportCost)) data")
                                .font(.system(size: 7, design: .monospaced))
                                .opacity(0.8)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("NEED DATA")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                            Text("\(Int(intel.footprintData))/\(Int(intel.reportCost))")
                                .font(.system(size: 7, design: .monospaced))
                                .opacity(0.8)
                        }
                    }
                }
                .foregroundColor(intel.canSendReport ? .terminalBlack : .terminalGray)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(intel.canSendReport ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                .cornerRadius(4)
            }
            .disabled(!intel.canSendReport)

            // Tip for new players
            if intel.reportsSent == 0 && intel.footprintData < 50 {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.neonAmber)
                    Text("Tip: Survive attacks to collect footprint data. SIEM & IDS boost collection!")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }
            }
        }
        .terminalCard(borderColor: .neonCyan)
    }
}

#Preview {
    CriticalAlarmView(
        threatLevel: .marked,
        riskLevel: .hunted,
        activeAttack: Attack(type: .malusStrike, severity: 2.5, startTick: 100),
        defenseStack: DefenseStack(),
        onAcknowledge: {},
        onBoostDefenses: {}
    )
}
