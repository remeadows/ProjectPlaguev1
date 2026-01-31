// AlertBannerView.swift
// GridWatchZero
// Animated alert banner for attacks and Malus messages

import SwiftUI

struct AlertBannerView: View {
    let event: GameEvent?
    @State private var isVisible = false
    @State private var glitchOffset: CGFloat = 0

    var body: some View {
        Group {
            if let event = event, shouldShowBanner(for: event) {
                bannerContent(for: event)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: event)
    }

    private func shouldShowBanner(for event: GameEvent) -> Bool {
        switch event {
        case .attackStarted, .malusMessage, .nodeDisabled, .milestone,
             .randomEvent, .loreUnlocked, .milestoneCompleted:
            return true
        default:
            return false
        }
    }

    @ViewBuilder
    private func bannerContent(for event: GameEvent) -> some View {
        switch event {
        case .attackStarted(let type):
            AttackBanner(attackType: type)

        case .malusMessage(let message):
            MalusBanner(message: message)

        case .nodeDisabled(let message):
            SystemAlertBanner(message: message, color: .neonAmber)

        case .milestone(let message):
            MilestoneBanner(message: message)

        case .randomEvent(let title, let message):
            RandomEventBanner(title: title, message: message)

        case .loreUnlocked(let title):
            LoreUnlockedBanner(title: title)

        case .milestoneCompleted(let title):
            MilestoneCompletedBanner(title: title)

        default:
            EmptyView()
        }
    }
}

// MARK: - Attack Banner

struct AttackBanner: View {
    let attackType: AttackType
    @State private var isFlashing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: attackType.icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.neonRed)
                .opacity(reduceMotion ? 1.0 : (isFlashing ? 0.5 : 1.0))

            VStack(alignment: .leading, spacing: 2) {
                Text("⚠ INCOMING \(attackType.rawValue)")
                    .font(.terminalSmall)
                    .foregroundColor(.neonRed)

                Text(attackType.description)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.dimRed.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonRed, lineWidth: 2)
                        .opacity(reduceMotion ? 1.0 : (isFlashing ? 0.5 : 1.0))
                )
        )
        .padding(.horizontal)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                Animation.easeInOut(duration: 0.2)
                    .repeatForever(autoreverses: true)
            ) {
                isFlashing = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: Incoming \(attackType.rawValue) attack. \(attackType.description)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Malus Banner

struct MalusBanner: View {
    let message: String
    @State private var glitchOffset: CGFloat = 0
    @State private var displayedText: String = ""
    @State private var isGlitching = false
    @State private var glitchTimer: Timer?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            // Malus icon (skull or similar)
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.neonRed)
                .offset(x: reduceMotion ? 0 : glitchOffset)

            VStack(alignment: .leading, spacing: 2) {
                Text("MALUS")
                    .font(.terminalSmall)
                    .foregroundColor(.neonRed)
                    .glow(.neonRed, radius: 4)

                Text(displayedText)
                    .font(.terminalBody)
                    .foregroundColor(.neonGreen)
                    .offset(x: reduceMotion ? 0 : (isGlitching ? CGFloat.random(in: -2...2) : 0))
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.terminalBlack.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonRed, lineWidth: 2)
                )
        )
        .overlay(
            // Scanline effect (skip if reduce motion)
            Group {
                if !reduceMotion {
                    ScanlineOverlay()
                        .opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        )
        .padding(.horizontal)
        .onAppear {
            if reduceMotion {
                displayedText = message
            } else {
                typewriterEffect()
                startGlitch()
            }
        }
        .onDisappear {
            glitchTimer?.invalidate()
            glitchTimer = nil
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Malus message: \(message)")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private func typewriterEffect() {
        displayedText = ""
        for (index, char) in message.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                displayedText += String(char)
            }
        }
    }

    private func startGlitch() {
        withAnimation(
            Animation.easeInOut(duration: 0.05)
                .repeatForever(autoreverses: true)
        ) {
            glitchOffset = CGFloat.random(in: -3...3)
        }

        glitchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                isGlitching = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isGlitching = false
            }
        }
    }
}

// MARK: - System Alert Banner

struct SystemAlertBanner: View {
    let message: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(color)

            Text(message)
                .font(.terminalSmall)
                .foregroundColor(color)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.terminalDarkGray.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("System alert: \(message)")
    }
}

// MARK: - Milestone Banner

struct MilestoneBanner: View {
    let message: String
    @State private var isGlowing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 20))
                .foregroundColor(.neonAmber)
                .glow(.neonAmber, radius: reduceMotion ? 4 : (isGlowing ? 8 : 2))

            Text(message)
                .font(.terminalBody)
                .foregroundColor(.neonAmber)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.dimAmber.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonAmber, lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
            ) {
                isGlowing = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Milestone: \(message)")
    }
}

// MARK: - Random Event Banner

struct RandomEventBanner: View {
    let title: String
    let message: String

    private var isPositive: Bool {
        !title.contains("GLITCH") && !title.contains("CRASH") &&
        !title.contains("CORRUPTION") && !title.contains("CONGESTION")
    }

    private var color: Color {
        if title.contains("MALUS") { return .neonRed }
        if title.contains("HELIX") { return .neonCyan }
        if title.contains("TEAM") { return .neonGreen }
        if title.contains("WHISPER") { return .neonCyan }
        return isPositive ? .neonGreen : .neonAmber
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isPositive ? "bolt.fill" : "exclamationmark.triangle")
                .font(.system(size: 18))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.terminalSmall)
                    .foregroundColor(color)

                Text(message)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(isPositive ? "Event" : "Warning"): \(title). \(message)")
    }
}

// MARK: - Lore Unlocked Banner

struct LoreUnlockedBanner: View {
    let title: String
    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 18))
                .foregroundColor(.neonCyan)
                .glow(.neonCyan, radius: reduceMotion ? 4 : (isPulsing ? 6 : 2))

            VStack(alignment: .leading, spacing: 2) {
                Text("INTEL ACQUIRED")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Text(title.uppercased())
                    .font(.terminalSmall)
                    .foregroundColor(.neonCyan)
            }

            Spacer()

            Text("TAP TO READ")
                .font(.terminalMicro)
                .foregroundColor(.neonCyan.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.neonCyan.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Intel acquired: \(title). Tap to read.")
    }
}

// MARK: - Milestone Completed Banner

struct MilestoneCompletedBanner: View {
    let title: String
    @State private var isGlowing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 20))
                .foregroundColor(.neonAmber)
                .glow(.neonAmber, radius: reduceMotion ? 4 : (isGlowing ? 8 : 2))

            VStack(alignment: .leading, spacing: 2) {
                Text("MILESTONE COMPLETE")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Text(title.uppercased())
                    .font(.terminalSmall)
                    .foregroundColor(.neonAmber)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.dimAmber.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonAmber, lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
            ) {
                isGlowing = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Milestone complete: \(title)")
    }
}

#Preview {
    VStack(spacing: 20) {
        AttackBanner(attackType: .ddos)
        MalusBanner(message: "> target acquired. monitoring.")
        SystemAlertBanner(message: "Node temporarily disabled", color: .neonAmber)
        MilestoneBanner(message: "1,000 Credits Earned!")
        RandomEventBanner(title: "DATA SURGE", message: "> Corporate firewall breach detected.")
        LoreUnlockedBanner(title: "The Mission")
        MilestoneCompletedBanner(title: "First Payday")
    }
    .background(Color.terminalBlack)
}
