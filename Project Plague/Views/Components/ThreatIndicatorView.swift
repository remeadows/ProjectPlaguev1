// ThreatIndicatorView.swift
// GridWatchZero
// Visual indicator for current threat level, NetDefense, and effective Risk

import SwiftUI

struct ThreatIndicatorView: View {
    let threatState: ThreatState
    let activeAttack: Attack?

    @State private var isPulsing = false

    private var threatLevel: ThreatLevel { threatState.currentLevel }
    private var netDefense: NetDefenseLevel { threatState.netDefenseLevel }
    private var effectiveRisk: ThreatLevel { threatState.effectiveRiskLevel }

    private var threatColor: Color {
        colorFor(threatLevel)
    }

    private var riskColor: Color {
        colorFor(effectiveRisk)
    }

    private var defenseColor: Color {
        switch netDefense {
        case .exposed: return .neonRed
        case .minimal, .basic: return .neonAmber
        case .moderate, .strong: return .neonCyan
        case .fortified, .hardened: return .neonGreen
        case .quantum, .neural, .helix: return .neonGreen
        }
    }

    private func colorFor(_ level: ThreatLevel) -> Color {
        // Use the tier color from Theme.swift for T7+ threat levels
        Color.tierColor(named: level.color)
    }

    var body: some View {
        HStack(spacing: 8) {
            // Threat level (raw visibility)
            HStack(spacing: 4) {
                Circle()
                    .fill(threatColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .glow(threatColor, radius: isPulsing ? 4 : 1)

                Text("THR")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Text(threatLevel.name)
                    .font(.terminalSmall)
                    .foregroundColor(threatColor)
            }

            // Defense arrow
            if netDefense != .exposed {
                Image(systemName: "minus")
                    .font(.system(size: 8))
                    .foregroundColor(.terminalGray)

                // NetDefense level
                HStack(spacing: 4) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 8))
                        .foregroundColor(defenseColor)

                    Text(netDefense.name)
                        .font(.terminalSmall)
                        .foregroundColor(defenseColor)
                }
            }

            // Equals arrow
            Image(systemName: "arrow.right")
                .font(.system(size: 8))
                .foregroundColor(.terminalGray)

            // Effective Risk (what actually matters for attacks)
            HStack(spacing: 4) {
                Text("RISK")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Text(effectiveRisk.name)
                    .font(.terminalSmall)
                    .foregroundColor(riskColor)
                    .glow(riskColor, radius: 2)
            }

            // Active attack indicator
            if let attack = activeAttack, attack.isActive {
                Divider()
                    .frame(height: 10)
                    .background(Color.terminalGray)

                AttackIndicator(attack: attack)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
    }

    private var accessibilityDescription: String {
        var description = "Threat level \(threatLevel.name)"
        if netDefense != .exposed {
            description += ", defense level \(netDefense.name)"
        }
        description += ", effective risk \(effectiveRisk.name)"
        if let attack = activeAttack, attack.isActive {
            description += ". Active \(attack.type.rawValue) attack, \(Int(attack.progress * 100)) percent complete"
        }
        return description
    }
}

struct AttackIndicator: View {
    let attack: Attack

    @State private var isFlashing = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: attack.type.icon)
                .font(.system(size: 14))
                .foregroundColor(.neonRed)
                .opacity(isFlashing ? 0.4 : 1.0)

            Text(attack.type.rawValue)
                .font(.terminalSmall)
                .foregroundColor(.neonRed)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.terminalGray.opacity(0.3))

                    Rectangle()
                        .fill(Color.neonRed)
                        .frame(width: geo.size.width * (1.0 - attack.progress))
                }
            }
            .frame(width: 50, height: 6)
            .cornerRadius(3)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 0.3)
                    .repeatForever(autoreverses: true)
            ) {
                isFlashing = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Ghost threat, no defense
        ThreatIndicatorView(threatState: ThreatState(), activeAttack: nil)

        // Signal threat with basic defense = blip risk
        ThreatIndicatorView(
            threatState: {
                var state = ThreatState()
                state.currentLevel = .signal
                state.netDefenseLevel = .basic
                return state
            }(),
            activeAttack: nil
        )

        // Target threat with moderate defense = blip risk
        ThreatIndicatorView(
            threatState: {
                var state = ThreatState()
                state.currentLevel = .target
                state.netDefenseLevel = .moderate
                return state
            }(),
            activeAttack: Attack(type: .ddos, severity: 1.5, startTick: 0)
        )

        // Hunted with strong defense
        ThreatIndicatorView(
            threatState: {
                var state = ThreatState()
                state.currentLevel = .hunted
                state.netDefenseLevel = .strong
                return state
            }(),
            activeAttack: nil
        )
    }
    .padding()
    .background(Color.terminalBlack)
}
