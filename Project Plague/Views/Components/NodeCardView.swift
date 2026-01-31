// NodeCardView.swift
// GridWatchZero
// Reusable card component for displaying nodes

import SwiftUI

struct NodeCardView: View {
    let title: String
    let subtitle: String
    let level: Int
    let accentColor: Color

    let stats: [(label: String, value: String)]
    let upgradeCost: Double
    let canAfford: Bool
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.terminalLarge)
                        .foregroundColor(accentColor)
                        .glow(accentColor, radius: 4)

                    Text(subtitle)
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }

                Spacer()

                // Level badge
                Text("LVL \(level)")
                    .font(.terminalBody)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accentColor)
                    .cornerRadius(2)
            }

            Divider()
                .background(accentColor.opacity(0.3))

            // Stats grid
            ForEach(stats.indices, id: \.self) { index in
                HStack {
                    Text(stats[index].label)
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    Spacer()

                    Text(stats[index].value)
                        .font(.terminalReadable)
                        .foregroundColor(accentColor)
                }
            }

            // Upgrade button
            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("UPGRADE")
                    Spacer()
                    Text("¢\(upgradeCost.formatted)")
                }
                .terminalButton(isEnabled: canAfford)
            }
            .disabled(!canAfford)
        }
        .terminalCard(borderColor: accentColor)
    }
}

// MARK: - Specialized Node Cards

struct SourceCardView: View {
    let source: SourceNode
    let credits: Double
    let onUpgrade: () -> Void

    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var nextLevelOutput: Double {
        source.baseProduction * Double(source.level + 1) * 1.5
    }

    private var outputGain: Double {
        nextLevelOutput - source.productionPerTick
    }

    private var accessibilityDescription: String {
        if source.isAtMaxLevel {
            return "Source: \(source.name), level \(source.level), maximum level. Output: \(source.productionPerTick.formatted) data per tick."
        } else {
            return "Source: \(source.name), level \(source.level). Output: \(source.productionPerTick.formatted) data per tick."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - name on left, type and level on right
            HStack(spacing: 8) {
                Text(source.name)
                    .font(.terminalTitle)
                    .foregroundColor(.neonGreen)
                    .glow(.neonGreen, radius: 3)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 4)

                HStack(spacing: 6) {
                    Text("SOURCE")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)

                    Text("L\(source.level)")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.neonGreen)
                        .cornerRadius(2)
                }
                .layoutPriority(1)
            }
            .accessibilityHidden(true)

            // Output stat + Upgrade button - responsive layout
            Group {
                if isCompact {
                    // iPhone: Vertical layout with more breathing room
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 4) {
                            Text("Output:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text("\(source.productionPerTick.formatted)/tick")
                                .font(.terminalBody)
                                .foregroundColor(.neonGreen)
                        }

                        // Upgrade button or MAX badge - full width on compact
                        if source.isAtMaxLevel {
                            Text("MAX")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.neonGreen.opacity(0.8))
                                .cornerRadius(2)
                        } else {
                            Button(action: onUpgrade) {
                                HStack(spacing: 8) {
                                    Text("+\(outputGain.formatted)")
                                        .font(.terminalSmall)
                                    Spacer()
                                    Text("¢\(source.upgradeCost.formatted)")
                                        .font(.terminalSmall)
                                }
                                .foregroundColor(credits >= source.upgradeCost ? .terminalBlack : .terminalGray)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(credits >= source.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < source.upgradeCost)
                        }
                    }
                } else {
                    // iPad: Horizontal inline layout
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Text("Output:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text("\(source.productionPerTick.formatted)/tick")
                                .font(.terminalBody)
                                .foregroundColor(.neonGreen)
                        }

                        Spacer()

                        // Upgrade button or MAX badge
                        if source.isAtMaxLevel {
                            Text("MAX")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalBlack)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.neonGreen.opacity(0.8))
                                .cornerRadius(2)
                        } else {
                            Button(action: onUpgrade) {
                                HStack(spacing: 4) {
                                    Text("+\(outputGain.formatted)")
                                        .font(.terminalSmall)
                                    Text("¢\(source.upgradeCost.formatted)")
                                        .font(.terminalSmall)
                                }
                                .foregroundColor(credits >= source.upgradeCost ? .terminalBlack : .terminalGray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(credits >= source.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < source.upgradeCost)
                        }
                    }
                }
            }
            .accessibilityHidden(true)
        }
        .terminalCard(borderColor: .neonGreen)
        .shadow(color: .neonGreen.opacity(reduceMotion ? 0.1 : (isPulsing ? 0.3 : 0.1)), radius: reduceMotion ? 3 : (isPulsing ? 8 : 3))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityDescription)
    }
}

struct LinkCardView: View {
    let link: TransportLink
    let credits: Double
    let onUpgrade: () -> Void

    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var efficiencyColor: Color {
        if link.throughputEfficiency >= 0.9 {
            return .neonGreen
        } else if link.throughputEfficiency >= 0.5 {
            return .neonAmber
        } else {
            return .neonRed
        }
    }

    private var nextLevelBandwidth: Double {
        link.baseBandwidth * Double(link.level + 1) * 1.4
    }

    private var bandwidthGain: Double {
        nextLevelBandwidth - link.bandwidth
    }

    private var accessibilityDescription: String {
        let efficiencyStatus = link.throughputEfficiency >= 0.9 ? "good" : (link.throughputEfficiency >= 0.5 ? "moderate" : "poor")
        if link.isAtMaxLevel {
            return "Link: \(link.name), level \(link.level), maximum level. Bandwidth: \(link.bandwidth.formatted) per tick. Efficiency: \(link.throughputEfficiency.percentFormatted), \(efficiencyStatus)."
        } else {
            return "Link: \(link.name), level \(link.level). Bandwidth: \(link.bandwidth.formatted) per tick. Efficiency: \(link.throughputEfficiency.percentFormatted), \(efficiencyStatus)."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - name on left, type and level on right
            HStack(spacing: 8) {
                Text(link.name)
                    .font(.terminalTitle)
                    .foregroundColor(.neonCyan)
                    .glow(.neonCyan, radius: 3)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 4)

                HStack(spacing: 6) {
                    Text("LINK")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)

                    Text("L\(link.level)")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.neonCyan)
                        .cornerRadius(2)
                }
                .layoutPriority(1)
            }
            .accessibilityHidden(true)

            // Stats row - responsive layout
            Group {
                if isCompact {
                    // iPhone: Vertical layout with stats on top, button below
                    VStack(alignment: .leading, spacing: 10) {
                        // Stats row
                        HStack(spacing: 12) {
                            // Bandwidth
                            HStack(spacing: 4) {
                                Text("BW:")
                                    .font(.terminalSmall)
                                    .foregroundColor(.terminalGray)
                                Text("\(link.bandwidth.formatted)/t")
                                    .font(.terminalBody)
                                    .foregroundColor(.neonCyan)
                            }

                            // Efficiency with inline bar
                            HStack(spacing: 4) {
                                Text("EFF:")
                                    .font(.terminalSmall)
                                    .foregroundColor(.terminalGray)
                                Text(link.throughputEfficiency.percentFormatted)
                                    .font(.terminalBody)
                                    .foregroundColor(efficiencyColor)
                                Rectangle()
                                    .fill(efficiencyColor)
                                    .frame(width: 40 * link.throughputEfficiency, height: 6)
                                    .cornerRadius(2)
                            }
                        }

                        // Upgrade button or MAX badge - full width on compact
                        if link.isAtMaxLevel {
                            Text("MAX")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.neonCyan.opacity(0.8))
                                .cornerRadius(2)
                        } else {
                            Button(action: onUpgrade) {
                                HStack(spacing: 8) {
                                    Text("+\(bandwidthGain.formatted)")
                                        .font(.terminalSmall)
                                    Spacer()
                                    Text("¢\(link.upgradeCost.formatted)")
                                        .font(.terminalSmall)
                                }
                                .foregroundColor(credits >= link.upgradeCost ? .terminalBlack : .terminalGray)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(credits >= link.upgradeCost ? Color.neonCyan : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < link.upgradeCost)
                        }
                    }
                } else {
                    // iPad: Horizontal inline layout
                    HStack(spacing: 16) {
                        // Bandwidth
                        HStack(spacing: 4) {
                            Text("BW:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text("\(link.bandwidth.formatted)/t")
                                .font(.terminalBody)
                                .foregroundColor(.neonCyan)
                        }

                        // Efficiency with inline bar
                        HStack(spacing: 4) {
                            Text("EFF:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text(link.throughputEfficiency.percentFormatted)
                                .font(.terminalBody)
                                .foregroundColor(efficiencyColor)
                            Rectangle()
                                .fill(efficiencyColor)
                                .frame(width: 40 * link.throughputEfficiency, height: 6)
                                .cornerRadius(2)
                        }

                        Spacer()

                        // Upgrade button or MAX badge
                        if link.isAtMaxLevel {
                            Text("MAX")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalBlack)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.neonCyan.opacity(0.8))
                                .cornerRadius(2)
                        } else {
                            Button(action: onUpgrade) {
                                HStack(spacing: 4) {
                                    Text("+\(bandwidthGain.formatted)")
                                        .font(.terminalSmall)
                                    Text("¢\(link.upgradeCost.formatted)")
                                        .font(.terminalSmall)
                                }
                                .foregroundColor(credits >= link.upgradeCost ? .terminalBlack : .terminalGray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(credits >= link.upgradeCost ? Color.neonCyan : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < link.upgradeCost)
                        }
                    }
                }
            }
            .accessibilityHidden(true)
        }
        .terminalCard(borderColor: .neonCyan)
        .shadow(color: .neonCyan.opacity(reduceMotion ? 0.1 : (isPulsing ? 0.3 : 0.1)), radius: reduceMotion ? 3 : (isPulsing ? 8 : 3))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityDescription)
    }
}

struct SinkCardView: View {
    let sink: SinkNode
    let credits: Double
    let onUpgrade: () -> Void

    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var bufferColor: Color {
        if sink.loadPercentage >= 0.9 {
            return .neonRed
        } else if sink.loadPercentage >= 0.6 {
            return .neonAmber
        } else {
            return .neonAmber
        }
    }

    private var nextLevelProcessing: Double {
        sink.baseProcessingRate * Double(sink.level + 1) * 1.3
    }

    private var processingGain: Double {
        nextLevelProcessing - sink.processingPerTick
    }

    private var accessibilityDescription: String {
        let bufferStatus = sink.loadPercentage >= 0.9 ? "buffer full" : (sink.loadPercentage >= 0.6 ? "buffer filling" : "buffer normal")
        if sink.isAtMaxLevel {
            return "Sink: \(sink.name), level \(sink.level), maximum level. Processing: \(sink.processingPerTick.formatted) per tick. Conversion rate: \(sink.conversionRate.formatted) credits per data. Buffer: \(sink.loadPercentage.percentFormatted), \(bufferStatus)."
        } else {
            return "Sink: \(sink.name), level \(sink.level). Processing: \(sink.processingPerTick.formatted) per tick. Conversion rate: \(sink.conversionRate.formatted) credits per data. Buffer: \(sink.loadPercentage.percentFormatted), \(bufferStatus)."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - name on left, type and level on right
            HStack(spacing: 8) {
                Text(sink.name)
                    .font(.terminalTitle)
                    .foregroundColor(.neonAmber)
                    .glow(.neonAmber, radius: 3)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 4)

                HStack(spacing: 6) {
                    Text("SINK")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)

                    Text("L\(sink.level)")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.neonAmber)
                        .cornerRadius(2)
                }
                .layoutPriority(1)
            }
            .accessibilityHidden(true)

            // Stats row - responsive layout
            Group {
                if isCompact {
                    // iPhone: Vertical layout with stats on top, button below
                    VStack(alignment: .leading, spacing: 10) {
                        // Stats row - wrap on two lines for very narrow screens
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                // Processing
                                HStack(spacing: 4) {
                                    Text("PROC:")
                                        .font(.terminalSmall)
                                        .foregroundColor(.terminalGray)
                                    Text("\(sink.processingPerTick.formatted)/t")
                                        .font(.terminalBody)
                                        .foregroundColor(.neonAmber)
                                }

                                // Conversion rate
                                HStack(spacing: 4) {
                                    Text("RATE:")
                                        .font(.terminalSmall)
                                        .foregroundColor(.terminalGray)
                                    Text("¢\(sink.conversionRate.formatted)")
                                        .font(.terminalBody)
                                        .foregroundColor(.neonGreen)
                                }
                            }

                            // Buffer with inline bar
                            HStack(spacing: 4) {
                                Text("BUF:")
                                    .font(.terminalSmall)
                                    .foregroundColor(.terminalGray)
                                Rectangle()
                                    .fill(bufferColor)
                                    .frame(width: 60 * sink.loadPercentage, height: 6)
                                    .cornerRadius(2)
                                Text(sink.loadPercentage.percentFormatted)
                                    .font(.terminalSmall)
                                    .foregroundColor(bufferColor)
                            }
                        }

                        // Upgrade button or MAX badge - full width on compact
                        if sink.isAtMaxLevel {
                            Text("MAX")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.neonAmber.opacity(0.8))
                                .cornerRadius(2)
                        } else {
                            Button(action: onUpgrade) {
                                HStack(spacing: 8) {
                                    Text("+\(processingGain.formatted)")
                                        .font(.terminalSmall)
                                    Spacer()
                                    Text("¢\(sink.upgradeCost.formatted)")
                                        .font(.terminalSmall)
                                }
                                .foregroundColor(credits >= sink.upgradeCost ? .terminalBlack : .terminalGray)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(credits >= sink.upgradeCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < sink.upgradeCost)
                        }
                    }
                } else {
                    // iPad: Horizontal inline layout
                    HStack(spacing: 16) {
                        // Processing
                        HStack(spacing: 4) {
                            Text("PROC:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text("\(sink.processingPerTick.formatted)/t")
                                .font(.terminalBody)
                                .foregroundColor(.neonAmber)
                        }

                        // Conversion rate
                        HStack(spacing: 4) {
                            Text("RATE:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text("¢\(sink.conversionRate.formatted)")
                                .font(.terminalBody)
                                .foregroundColor(.neonGreen)
                        }

                        // Buffer with inline bar
                        HStack(spacing: 4) {
                            Text("BUF:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Rectangle()
                                .fill(bufferColor)
                                .frame(width: 40 * sink.loadPercentage, height: 6)
                                .cornerRadius(2)
                        }

                        Spacer()

                        // Upgrade button or MAX badge
                        if sink.isAtMaxLevel {
                            Text("MAX")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalBlack)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.neonAmber.opacity(0.8))
                                .cornerRadius(2)
                        } else {
                            Button(action: onUpgrade) {
                                HStack(spacing: 4) {
                                    Text("+\(processingGain.formatted)")
                                        .font(.terminalSmall)
                                    Text("¢\(sink.upgradeCost.formatted)")
                                        .font(.terminalSmall)
                                }
                                .foregroundColor(credits >= sink.upgradeCost ? .terminalBlack : .terminalGray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(credits >= sink.upgradeCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                                .cornerRadius(2)
                            }
                            .disabled(credits < sink.upgradeCost)
                        }
                    }
                }
            }
            .accessibilityHidden(true)
        }
        .terminalCard(borderColor: .neonAmber)
        .shadow(color: .neonAmber.opacity(reduceMotion ? 0.1 : (isPulsing ? 0.3 : 0.1)), radius: reduceMotion ? 3 : (isPulsing ? 8 : 3))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityDescription)
    }
}

#Preview {
    VStack(spacing: 20) {
        SourceCardView(
            source: UnitFactory.createPublicMeshSniffer(),
            credits: 100,
            onUpgrade: {}
        )

        LinkCardView(
            link: UnitFactory.createCopperVPNTunnel(),
            credits: 100,
            onUpgrade: {}
        )

        SinkCardView(
            sink: UnitFactory.createDataBroker(),
            credits: 100,
            onUpgrade: {}
        )
    }
    .padding()
    .background(Color.terminalBlack)
}
