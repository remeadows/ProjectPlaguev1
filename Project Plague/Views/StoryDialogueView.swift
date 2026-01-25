// StoryDialogueView.swift
// ProjectPlague
// Character dialogue presentation with typewriter effect

import SwiftUI

// MARK: - Story Dialogue View

struct StoryDialogueView: View {
    let storyMoment: StoryMoment
    var onComplete: () -> Void

    @State private var currentLineIndex: Int = 0
    @State private var displayedText: String = ""
    @State private var isTyping: Bool = false
    @State private var showContinue: Bool = false
    @State private var glitchOffset: CGFloat = 0
    @State private var scanlinePhase: CGFloat = 0
    @State private var typewriterTimer: Timer?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let typewriterSpeed: Double = 0.03

    var body: some View {
        ZStack {
            // Background
            Color.terminalBlack
                .ignoresSafeArea()

            // Visual effects layer
            visualEffectsOverlay

            VStack(spacing: 0) {
                // Top bar with character name
                characterHeader
                    .padding(.top, 16)

                Spacer()

                // Main dialogue area
                dialogueContent

                Spacer()

                // Continue / Skip indicator
                continueIndicator
                    .padding(.bottom, 32)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            startDialogue()
        }
    }

    // MARK: - Character Header

    private var characterHeader: some View {
        HStack(spacing: 16) {
            // Character portrait
            characterPortrait

            VStack(alignment: .leading, spacing: 4) {
                Text(storyMoment.character.displayName)
                    .font(.terminalLarge)
                    .foregroundColor(characterColor)
                    .glow(characterColor, radius: 10)

                Text(storyMoment.character.role)
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                if !storyMoment.title.isEmpty {
                    Text(storyMoment.title)
                        .font(.terminalBody)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var characterPortrait: some View {
        ZStack {
            // Portrait background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.terminalDarkGray)
                .frame(width: 80, height: 80)

            // Character image or fallback
            if let imageName = storyMoment.character.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                // System character fallback
                Image(systemName: "terminal.fill")
                    .font(.system(size: 30))
                    .foregroundColor(characterColor)
            }

            // Border glow
            RoundedRectangle(cornerRadius: 8)
                .stroke(characterColor.opacity(0.8), lineWidth: 2)
                .frame(width: 80, height: 80)
                .glow(characterColor, radius: 8)
        }
        .offset(x: glitchOffset)
    }

    // MARK: - Dialogue Content

    private var dialogueContent: some View {
        VStack(spacing: 16) {
            // Dialogue box
            VStack(alignment: .leading, spacing: 12) {
                // Current line with typewriter effect
                Text(displayedText)
                    .font(.terminalReadable)
                    .foregroundColor(.white)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Typing cursor
                if isTyping {
                    Rectangle()
                        .fill(characterColor)
                        .frame(width: 8, height: 16)
                        .opacity(cursorOpacity)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color.terminalDarkGray.opacity(0.9))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(characterColor.opacity(0.5), lineWidth: 1)
            )

            // Line progress indicator
            HStack(spacing: 8) {
                ForEach(0..<storyMoment.lines.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentLineIndex ? characterColor : Color.terminalGray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Continue Indicator

    private var continueIndicator: some View {
        VStack(spacing: 8) {
            if showContinue {
                if currentLineIndex < storyMoment.lines.count - 1 {
                    Text("TAP TO CONTINUE")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                } else {
                    Text("TAP TO CLOSE")
                        .font(.terminalSmall)
                        .foregroundColor(characterColor)
                }

                Image(systemName: "chevron.down")
                    .font(.terminalSmall)
                    .foregroundColor(characterColor)
                    .opacity(pulseOpacity)
            } else if isTyping {
                Text("TAP TO SKIP")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray.opacity(0.5))
            }
        }
    }

    // MARK: - Visual Effects

    @ViewBuilder
    private var visualEffectsOverlay: some View {
        if let effect = storyMoment.visualEffect, !reduceMotion {
            switch effect {
            case .glitch:
                glitchOverlay
            case .staticNoise:
                staticOverlay
            case .pulse:
                pulseOverlay
            case .fadeIn:
                EmptyView()
            case .scanlines:
                scanlinesOverlay
            }
        }
    }

    private var glitchOverlay: some View {
        Color.clear
            .onAppear {
                startGlitchAnimation()
            }
    }

    private var staticOverlay: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.02), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
    }

    private var pulseOverlay: some View {
        Circle()
            .stroke(characterColor.opacity(0.2), lineWidth: 100)
            .frame(width: 300, height: 300)
            .scaleEffect(pulseScale)
            .opacity(Double(1.0 - pulseScale / 3.0))
    }

    private var scanlinesOverlay: some View {
        GeometryReader { geo in
            VStack(spacing: 2) {
                ForEach(0..<Int(geo.size.height / 3), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                    Spacer().frame(height: 2)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Animation States

    @State private var cursorBlink: Bool = true
    @State private var pulseScale: CGFloat = 1.0

    private var cursorOpacity: Double {
        cursorBlink ? 1.0 : 0.0
    }

    private var pulseOpacity: Double {
        showContinue ? (cursorBlink ? 1.0 : 0.5) : 0
    }

    // MARK: - Logic

    private var characterColor: Color {
        switch storyMoment.character.themeColor {
        case "neonGreen": return .neonGreen
        case "neonCyan": return .neonCyan
        case "neonAmber": return .neonAmber
        case "neonRed": return .neonRed
        default: return .terminalGray
        }
    }

    private var currentLine: StoryMoment.DialogueLine {
        guard currentLineIndex < storyMoment.lines.count else {
            return .init("", mood: .neutral)
        }
        return storyMoment.lines[currentLineIndex]
    }

    private func startDialogue() {
        currentLineIndex = 0
        displayCurrentLine()
        startCursorBlink()
        startPulseAnimation()
    }

    private func displayCurrentLine() {
        guard currentLineIndex < storyMoment.lines.count else {
            onComplete()
            return
        }

        let line = currentLine
        displayedText = ""
        isTyping = true
        showContinue = false

        // Handle delay if specified
        let delay = line.delay ?? 0

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if reduceMotion {
                // No typewriter effect with reduce motion
                displayedText = line.text
                isTyping = false
                showContinue = true
            } else {
                typewriterEffect(text: line.text)
            }
        }
    }

    private func typewriterEffect(text: String) {
        // Cancel any existing timer first
        typewriterTimer?.invalidate()
        typewriterTimer = nil

        let characters = Array(text)
        var index = 0

        typewriterTimer = Timer.scheduledTimer(withTimeInterval: typewriterSpeed, repeats: true) { timer in
            guard index < characters.count else {
                timer.invalidate()
                typewriterTimer = nil
                isTyping = false
                showContinue = true
                return
            }

            displayedText += String(characters[index])
            index += 1

            // Play subtle typing sound
            if index % 3 == 0 {
                AudioManager.shared.playSound(.tick)
            }
        }
    }

    private func handleTap() {
        if isTyping {
            // Stop the typewriter timer first
            typewriterTimer?.invalidate()
            typewriterTimer = nil

            // Skip to end of current line
            displayedText = currentLine.text
            isTyping = false
            showContinue = true
        } else if currentLineIndex < storyMoment.lines.count - 1 {
            // Next line
            currentLineIndex += 1
            displayCurrentLine()
        } else {
            // Complete dialogue
            AudioManager.shared.playSound(.upgrade)
            onComplete()
        }
    }

    private func startCursorBlink() {
        guard !reduceMotion else { return }

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            cursorBlink.toggle()
        }
    }

    private func startPulseAnimation() {
        guard !reduceMotion, storyMoment.visualEffect == .pulse else { return }

        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 2.0
        }
    }

    private func startGlitchAnimation() {
        guard !reduceMotion else { return }

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if Double.random(in: 0...1) < 0.1 {
                withAnimation(.easeOut(duration: 0.05)) {
                    glitchOffset = CGFloat.random(in: -5...5)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeIn(duration: 0.05)) {
                        glitchOffset = 0
                    }
                }
            }
        }
    }
}

// MARK: - Story Overlay Modifier

struct StoryOverlayModifier: ViewModifier {
    @Binding var storyMoment: StoryMoment?
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let moment = storyMoment {
                StoryDialogueView(storyMoment: moment) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        storyMoment = nil
                    }
                    onDismiss?()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
}

extension View {
    func storyOverlay(_ moment: Binding<StoryMoment?>, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(StoryOverlayModifier(storyMoment: moment, onDismiss: onDismiss))
    }
}

// MARK: - Previews

#Preview("Rusty Intro") {
    StoryDialogueView(
        storyMoment: StoryMoment(
            id: "preview_rusty",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 1,
            title: "First Assignment",
            lines: [
                .init("Your first job. Simple stuff.", mood: .neutral),
                .init("A home network. Low profile. Should be safe.", mood: .neutral),
                .init("Deploy your firewall. Monitor the traffic.", mood: .neutral),
                .init("Malus hasn't noticed this one yet. Let's keep it that way.", mood: .warning)
            ],
            prerequisiteStoryId: nil,
            visualEffect: nil
        )
    ) {
        print("Dialogue complete")
    }
}

#Preview("Malus Threatening") {
    StoryDialogueView(
        storyMoment: StoryMoment(
            id: "preview_malus",
            character: .malus,
            trigger: .midLevel,
            levelId: 4,
            title: "Malus Speaks",
            lines: [
                .init("> I see you.", mood: .threatening),
                .init("> Your defenses are... interesting.", mood: .threatening),
                .init("> But inadequate.", mood: .threatening)
            ],
            prerequisiteStoryId: nil,
            visualEffect: .staticNoise
        )
    ) {
        print("Dialogue complete")
    }
}

#Preview("Helix Mysterious") {
    StoryDialogueView(
        storyMoment: StoryMoment(
            id: "preview_helix",
            character: .helix,
            trigger: .midLevel,
            levelId: 5,
            title: "A Signal",
            lines: [
                .init("...", mood: .mysterious, delay: 1.0),
                .init("Is... someone there?", mood: .mysterious),
                .init("I can see patterns. In the light. In the code.", mood: .mysterious)
            ],
            prerequisiteStoryId: nil,
            visualEffect: .pulse
        )
    ) {
        print("Dialogue complete")
    }
}
