// ConnectionLineView.swift
// GridWatchZero
// Visual connector between nodes showing data flow

import SwiftUI

struct ConnectionLineView: View {
    let isActive: Bool
    let throughput: Double
    let maxThroughput: Double

    @State private var animationPhase: CGFloat = 0

    private var flowIntensity: Double {
        guard maxThroughput > 0 else { return 0 }
        return min(throughput / maxThroughput, 1.0)
    }

    private var lineColor: Color {
        if !isActive { return .terminalGray }
        if flowIntensity >= 0.8 { return .neonGreen }
        if flowIntensity >= 0.4 { return .neonAmber }
        return .neonRed
    }

    // More particles for higher throughput
    private var particleCount: Int {
        if !isActive { return 0 }
        return max(2, min(3, Int(flowIntensity * 3) + 1))
    }

    // Animation speed based on flow intensity (faster = more throughput)
    private var animationDuration: Double {
        1.2 / (0.5 + flowIntensity * 0.5)
    }

    var body: some View {
        HStack(spacing: 4) {
            // Arrow indicator
            Image(systemName: "chevron.down")
                .font(.system(size: 10))
                .foregroundColor(lineColor)
                .glow(lineColor, radius: isActive ? 4 : 0)

            ZStack {
                // Background line with glow
                Rectangle()
                    .fill(Color.terminalDarkGray)
                    .frame(width: 40, height: 3)

                // Active flow glow
                if isActive {
                    Rectangle()
                        .fill(lineColor.opacity(0.4))
                        .frame(width: 40, height: 6)
                        .blur(radius: 3)
                }

                // Animated data packet particles
                if isActive {
                    ForEach(0..<particleCount, id: \.self) { i in
                        let phaseOffset = CGFloat(i) / CGFloat(particleCount)
                        let particlePhase = (animationPhase + phaseOffset).truncatingRemainder(dividingBy: 1.0)

                        Circle()
                            .fill(lineColor)
                            .frame(width: 4, height: 4)
                            .glow(lineColor, radius: 2)
                            .offset(x: -20 + particlePhase * 40)
                            .opacity(particlePhase > 0.05 && particlePhase < 0.95 ? 1 : 0)
                    }
                }
            }
            .frame(width: 50, height: 20)

            Image(systemName: "chevron.down")
                .font(.system(size: 10))
                .foregroundColor(lineColor)
                .glow(lineColor, radius: isActive ? 4 : 0)
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        guard isActive else { return }
        animationPhase = 0
        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
            animationPhase = 1.0
        }
    }
}

// MARK: - Data Packet Particle

struct DataPacketParticle: View {
    let color: Color
    let phase: CGFloat
    let speed: Double
    let size: CGFloat

    @State private var animatedPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Core
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: size, height: size * 0.6)

            // Glow
            RoundedRectangle(cornerRadius: 2)
                .fill(color.opacity(0.5))
                .frame(width: size * 1.5, height: size)
                .blur(radius: 3)
        }
        .offset(y: -20 + animatedPhase * 40)
        .opacity(animatedPhase > 0.1 && animatedPhase < 0.9 ? 1 : 0)
        .onAppear {
            animatedPhase = phase
            withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                animatedPhase = 1.0
            }
        }
    }
}

// MARK: - Safe Array Access

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    VStack(spacing: 20) {
        ConnectionLineView(isActive: true, throughput: 8, maxThroughput: 10)
        ConnectionLineView(isActive: true, throughput: 4, maxThroughput: 10)
        ConnectionLineView(isActive: false, throughput: 0, maxThroughput: 10)
    }
    .padding()
    .background(Color.terminalBlack)
}
