// TutorialOverlayView.swift
// GridWatchZero
// Tutorial dialogue and UI highlighting overlay

import SwiftUI

// MARK: - Tutorial Overlay View

struct TutorialOverlayView: View {
    @ObservedObject var tutorialManager: TutorialManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ZStack {
            // Semi-transparent background when showing dialogue
            if tutorialManager.isShowingDialogue {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        tutorialManager.advanceDialogue()
                        AudioManager.shared.playSound(.tick)
                    }
            }

            // Tutorial dialogue box
            if tutorialManager.isShowingDialogue {
                tutorialDialogueBox
            }
        }
    }

    // MARK: - Dialogue Box

    private var tutorialDialogueBox: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                // Character header
                HStack(spacing: isIPad ? 16 : 12) {
                    // Rusty portrait
                    ZStack {
                        RoundedRectangle(cornerRadius: isIPad ? 10 : 6)
                            .fill(Color.terminalDarkGray)
                            .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)

                        Image("Rusty")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: isIPad ? 72 : 54, height: isIPad ? 72 : 54)
                            .clipShape(RoundedRectangle(cornerRadius: isIPad ? 8 : 4))

                        RoundedRectangle(cornerRadius: isIPad ? 10 : 6)
                            .stroke(Color.neonGreen.opacity(0.8), lineWidth: 2)
                            .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)
                            .glow(.neonGreen, radius: 6)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("RUSTY")
                            .font(isIPad ? .system(size: 24, weight: .bold, design: .monospaced) : .terminalLarge)
                            .foregroundColor(.neonGreen)
                            .glow(.neonGreen, radius: 8)

                        Text(tutorialManager.state.currentStep.title)
                            .font(isIPad ? .system(size: 14, weight: .regular, design: .monospaced) : .terminalSmall)
                            .foregroundColor(.terminalGray)
                    }

                    Spacer()

                    // Skip button
                    Button(action: {
                        tutorialManager.skipTutorial()
                        AudioManager.shared.playSound(.upgrade)
                    }) {
                        Text("SKIP")
                            .font(.terminalSmall)
                            .foregroundColor(.terminalGray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.terminalGray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, isIPad ? 24 : 16)
                .padding(.top, isIPad ? 20 : 16)

                // Dialogue text
                Text(tutorialManager.state.currentDialogueLine)
                    .font(isIPad ? .system(size: 18, weight: .regular, design: .monospaced) : .terminalReadable)
                    .foregroundColor(.white)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, isIPad ? 24 : 16)
                    .padding(.vertical, isIPad ? 20 : 16)
                    .fixedSize(horizontal: false, vertical: true)

                // Progress and continue
                HStack {
                    // Line progress
                    let progress = tutorialManager.state.dialogueProgress
                    HStack(spacing: 6) {
                        ForEach(0..<progress.total, id: \.self) { index in
                            Circle()
                                .fill(index < progress.current ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Spacer()

                    // Continue indicator
                    HStack(spacing: 6) {
                        Text("TAP TO CONTINUE")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(.neonGreen)
                            .opacity(glowOpacity)
                    }
                }
                .padding(.horizontal, isIPad ? 24 : 16)
                .padding(.bottom, isIPad ? 20 : 16)
            }
            .background(Color.terminalDarkGray.opacity(0.95))
            .cornerRadius(isIPad ? 12 : 8)
            .overlay(
                RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                    .stroke(Color.neonGreen.opacity(0.6), lineWidth: 2)
            )
            .shadow(color: .neonGreen.opacity(0.3), radius: 20)
            .padding(.horizontal, isIPad ? 40 : 16)
            .padding(.bottom, isIPad ? 60 : 40)
        }
        .onAppear {
            startGlowAnimation()
        }
    }

    private func startGlowAnimation() {
        guard !reduceMotion else {
            glowOpacity = 1.0
            return
        }

        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            glowOpacity = 1.0
        }
    }
}

// MARK: - Tutorial Highlight Modifier

struct TutorialHighlightModifier: ViewModifier {
    let highlightType: TutorialHighlight
    @ObservedObject var tutorialManager: TutorialManager
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isHighlighted: Bool {
        tutorialManager.currentHighlight == highlightType
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isHighlighted {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neonGreen, lineWidth: 3)
                            .scaleEffect(pulseScale)
                            .opacity(glowOpacity)
                            .glow(.neonGreen, radius: 12)
                    }
                }
            )
            .overlay(
                Group {
                    if isHighlighted {
                        // Arrow indicator
                        VStack {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.neonGreen)
                                .glow(.neonGreen, radius: 8)
                                .offset(y: pulseScale > 1.0 ? -4 : 0)

                            Spacer()
                        }
                        .offset(y: -36)
                    }
                }
            )
            .zIndex(isHighlighted ? 100 : 0)
            .onChange(of: isHighlighted) { _, highlighted in
                if highlighted {
                    startPulseAnimation()
                }
            }
            .onAppear {
                if isHighlighted {
                    startPulseAnimation()
                }
            }
    }

    private func startPulseAnimation() {
        guard !reduceMotion else {
            pulseScale = 1.0
            glowOpacity = 1.0
            return
        }

        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.03
            glowOpacity = 1.0
        }
    }
}

extension View {
    func tutorialHighlight(_ type: TutorialHighlight, manager: TutorialManager) -> some View {
        modifier(TutorialHighlightModifier(highlightType: type, tutorialManager: manager))
    }
}

// MARK: - Tutorial Hint Banner

struct TutorialHintBanner: View {
    @ObservedObject var tutorialManager: TutorialManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        if let highlight = tutorialManager.currentHighlight,
           !tutorialManager.isShowingDialogue {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.neonGreen)

                Text(hintText(for: highlight))
                    .font(.terminalSmall)
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    tutorialManager.skipTutorial()
                }) {
                    Text("SKIP")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.neonGreen.opacity(0.15))
            .overlay(
                Rectangle()
                    .fill(Color.neonGreen)
                    .frame(height: 2),
                alignment: .bottom
            )
        }
    }

    private func hintText(for highlight: TutorialHighlight) -> String {
        switch highlight {
        case .sourceCard:
            return "Tap the upgrade button on your SOURCE"
        case .linkCard:
            return "Tap the upgrade button on your LINK"
        case .sinkCard:
            return "Tap the upgrade button on your SINK"
        case .firewallSection:
            return "Purchase a FIREWALL to protect your network"
        case .defenseApps:
            return "Deploy a DEFENSE APPLICATION"
        case .intelPanel:
            return "Send your first INTEL REPORT"
        case .creditsDisplay:
            return "Watch your credits grow"
        case .threatIndicator:
            return "Monitor your threat level"
        }
    }
}

// MARK: - Preview

#Preview("Tutorial Dialogue") {
    let manager = TutorialManager.shared
    manager.state.startTutorial()

    return ZStack {
        Color.terminalBlack
            .ignoresSafeArea()

        VStack {
            Text("Game Content Here")
                .foregroundColor(.white)
        }

        TutorialOverlayView(tutorialManager: manager)
    }
}

#Preview("Tutorial Hint") {
    let manager = TutorialManager.shared
    manager.state.isActive = true
    manager.state.showingDialogue = false
    manager.state.currentStep = .upgradeSource

    return VStack(spacing: 0) {
        TutorialHintBanner(tutorialManager: manager)

        Spacer()

        Text("Game Content")
            .foregroundColor(.white)

        Spacer()
    }
    .background(Color.terminalBlack)
}
