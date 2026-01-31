// FirewallCardView.swift
// GridWatchZero
// UI card for firewall defense node

import SwiftUI

struct FirewallCardView: View {
    let firewall: FirewallNode?
    let credits: Double
    let damageAbsorbed: Double
    let onUpgrade: () -> Void
    let onRepair: () -> Void
    let onPurchase: () -> Void

    private var healthColor: Color {
        guard let fw = firewall else { return .terminalGray }
        if fw.healthPercentage >= 0.6 { return .neonGreen }
        if fw.healthPercentage >= 0.3 { return .neonAmber }
        return .neonRed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let fw = firewall {
                // Active firewall display
                activeFirewallView(fw)
            } else {
                // Purchase prompt
                purchasePromptView
            }
        }
        .terminalCard(borderColor: firewall != nil ? .neonRed : .terminalGray)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(firewallAccessibilityLabel)
    }

    private var firewallAccessibilityLabel: String {
        if let fw = firewall {
            return "Firewall: \(fw.name), level \(fw.level). Health \(Int(fw.healthPercentage * 100)) percent. Damage reduction \(Int(fw.damageReduction * 100)) percent. Regeneration \(fw.regenPerTick.formatted) per tick"
        } else {
            return "No firewall installed. Network unprotected. Install for 500 credits"
        }
    }

    // MARK: - Active Firewall

    @ViewBuilder
    private func activeFirewallView(_ fw: FirewallNode) -> some View {
        // Header - compact single line
        HStack {
            Text(fw.name)
                .font(.terminalTitle)
                .foregroundColor(.neonRed)
                .glow(.neonRed, radius: 3)
                .lineLimit(1)

            Text("[ DEF ]")
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)

            Spacer()

            Text("LVL \(fw.level)")
                .font(.terminalSmall)
                .foregroundColor(.terminalBlack)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.neonRed)
                .cornerRadius(2)
        }

        // Stats row: Health bar + DR + Regen + Buttons
        HStack(spacing: 10) {
            // Health bar
            VStack(alignment: .leading, spacing: 2) {
                Text("HP \(fw.currentHealth.formatted)/\(fw.maxHealth.formatted)")
                    .font(.terminalMicro)
                    .foregroundColor(healthColor)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.terminalGray.opacity(0.3))
                        Rectangle()
                            .fill(healthColor)
                            .frame(width: geo.size.width * fw.healthPercentage)
                        if damageAbsorbed > 0 {
                            Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: geo.size.width * fw.healthPercentage)
                                .animation(.easeOut(duration: 0.2), value: damageAbsorbed)
                        }
                    }
                }
                .frame(height: 4)
                .cornerRadius(2)
            }
            .frame(width: 90)

            // DR + Regen
            VStack(alignment: .leading, spacing: 2) {
                Text("DR")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                Text("\(fw.damageReduction.percentFormatted)")
                    .font(.terminalBody)
                    .foregroundColor(.neonRed)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("REGEN")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                Text("+\(fw.regenPerTick.formatted)")
                    .font(.terminalBody)
                    .foregroundColor(.neonGreen)
            }

            Spacer()

            // Buttons
            HStack(spacing: 4) {
                // Repair button (if damaged)
                if fw.currentHealth < fw.maxHealth {
                    let repairCost = (fw.maxHealth - fw.currentHealth) * 0.5
                    Button(action: onRepair) {
                        HStack(spacing: 2) {
                            Image(systemName: "wrench.fill")
                                .font(.system(size: 9))
                            Text("¢\(repairCost.formatted)")
                                .font(.terminalMicro)
                        }
                        .foregroundColor(credits >= repairCost ? .terminalBlack : .terminalGray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(credits >= repairCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                        .cornerRadius(2)
                    }
                    .disabled(credits < repairCost)
                    .accessibilityLabel("Repair firewall")
                    .accessibilityValue("Cost \(repairCost.formatted) credits")
                    .accessibilityHint(credits >= repairCost ? "Restores firewall to full health" : "Not enough credits")
                }

                // Upgrade button or MAX badge
                if fw.isAtMaxLevel {
                    Text("MAX")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.neonGreen.opacity(0.8))
                        .cornerRadius(2)
                        .accessibilityLabel("Firewall at maximum level")
                } else {
                    Button(action: onUpgrade) {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 9))
                            Text("¢\(fw.upgradeCost.formatted)")
                                .font(.terminalMicro)
                        }
                        .foregroundColor(credits >= fw.upgradeCost ? .terminalBlack : .terminalGray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(credits >= fw.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                        .cornerRadius(2)
                    }
                    .disabled(credits < fw.upgradeCost)
                    .accessibilityLabel("Upgrade firewall")
                    .accessibilityValue("Cost \(fw.upgradeCost.formatted) credits")
                    .accessibilityHint(credits >= fw.upgradeCost ? "Increases firewall level to \(fw.level + 1)" : "Not enough credits")
                }
            }
        }
    }

    // MARK: - Purchase Prompt

    private var purchasePromptView: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.slash")
                .font(.system(size: 18))
                .foregroundColor(.terminalGray)

            VStack(alignment: .leading, spacing: 2) {
                Text("NO FIREWALL")
                    .font(.terminalTitle)
                    .foregroundColor(.terminalGray)
                Text("Network unprotected")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            let cost: Double = 500
            Button(action: onPurchase) {
                HStack(spacing: 4) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 10))
                    Text("INSTALL")
                        .font(.terminalSmall)
                    Text("¢\(cost.formatted)")
                        .font(.terminalSmall)
                }
                .foregroundColor(credits >= cost ? .terminalBlack : .terminalGray)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(credits >= cost ? Color.neonRed : Color.terminalGray.opacity(0.3))
                .cornerRadius(2)
            }
            .disabled(credits < cost)
            .accessibilityLabel("Install firewall")
            .accessibilityValue("Cost \(cost.formatted) credits")
            .accessibilityHint(credits >= cost ? "Protects your network from attacks" : "Not enough credits")
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FirewallCardView(
            firewall: UnitFactory.createBasicFirewall(),
            credits: 1000,
            damageAbsorbed: 0,
            onUpgrade: {},
            onRepair: {},
            onPurchase: {}
        )

        FirewallCardView(
            firewall: nil,
            credits: 600,
            damageAbsorbed: 0,
            onUpgrade: {},
            onRepair: {},
            onPurchase: {}
        )
    }
    .padding()
    .background(Color.terminalBlack)
}
