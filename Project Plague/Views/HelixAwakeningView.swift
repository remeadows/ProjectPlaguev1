// HelixAwakeningView.swift
// GridWatchZero
// Cinematic sequence for Helix awakening after Level 7 completion

import SwiftUI
import AVFoundation

// MARK: - Helix Awakening View

struct HelixAwakeningView: View {
    var onComplete: () -> Void

    // Animation states
    @State private var phase: AwakeningPhase = .dormant
    @State private var glowIntensity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var eyeGlowOpacity: Double = 0.0
    @State private var environmentShift: Double = 0.0
    @State private var imageOpacity: Double = 1.0
    @State private var awakenedOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var showSkipButton: Bool = false
    @State private var particleOffset: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Audio manager for cinematic (not observed, just used for playback)
    @State private var cinematicAudio = CinematicAudioManager()

    enum AwakeningPhase {
        case dormant      // 0-3s: Dark, quiet
        case powerBuild   // 3-8s: Glow intensifies, pulse begins
        case awakening    // 8-12s: Eyes glow, environment shifts
        case revealed     // 12-15s: Crossfade to awakened image
    }

    var body: some View {
        ZStack {
            // Background gradient that shifts during awakening
            backgroundGradient

            // Particle effects
            if !reduceMotion {
                particleField
            }

            // Main content
            VStack {
                Spacer()

                // Helix images with effects
                helixImageStack

                Spacer()

                // Awakening text
                awakeningText
                    .padding(.bottom, 60)
            }

            // Skip button
            VStack {
                HStack {
                    Spacer()
                    if showSkipButton {
                        skipButton
                            .padding(.top, 60)
                            .padding(.trailing, 24)
                    }
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAwakeningSequence()
        }
        .onDisappear {
            cinematicAudio.stopCinematicAudio()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(white: 0.05).opacity(1.0 - environmentShift * 0.3),
                Color.blue.opacity(0.1 + environmentShift * 0.2),
                Color.cyan.opacity(0.05 + environmentShift * 0.15)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .animation(.easeInOut(duration: 3.0), value: environmentShift)
    }

    // MARK: - Particle Field

    private var particleField: some View {
        GeometryReader { geo in
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(Color.cyan.opacity(0.3 * glowIntensity))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: (CGFloat(i) * geo.size.height / 20 + particleOffset).truncatingRemainder(dividingBy: geo.size.height)
                    )
                    .blur(radius: 1)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Helix Image Stack

    private var helixImageStack: some View {
        ZStack {
            // Power aura (behind images)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(glowIntensity * 0.6),
                            Color.blue.opacity(glowIntensity * 0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 250
                    )
                )
                .scaleEffect(pulseScale)
                .blur(radius: 40)
                .frame(width: 400, height: 400)

            // Dormant Helix (Helixv2)
            Image("Helixv2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 320, maxHeight: 480)
                .opacity(imageOpacity)
                .overlay(
                    // Eye glow overlay
                    Color.cyan
                        .opacity(eyeGlowOpacity * 0.7)
                        .blur(radius: 20)
                        .mask(
                            // Approximate eye area with gradient
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.8), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(height: 30)
                            .offset(y: -80) // Position near eyes
                        )
                )
                .shadow(color: .cyan.opacity(glowIntensity * 0.5), radius: 30)

            // Awakened Helix (crossfade target)
            Image("Helix_Awakened")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 320, maxHeight: 480)
                .opacity(awakenedOpacity)
                .shadow(color: .cyan.opacity(0.8), radius: 40)
        }
    }

    // MARK: - Awakening Text

    private var awakeningText: some View {
        VStack(spacing: 12) {
            Text("HELIX")
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .cyan, radius: 10)

            Text("AWAKENING")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.cyan)
                .tracking(8)
        }
        .opacity(textOpacity)
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        Button(action: {
            completeSequence()
        }) {
            HStack(spacing: 6) {
                Text("SKIP")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                Image(systemName: "forward.fill")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
        .transition(.opacity)
    }

    // MARK: - Animation Sequence

    private func startAwakeningSequence() {
        // Start cinematic audio
        cinematicAudio.startCinematicAudio()

        // Show skip button after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeIn(duration: 0.5)) {
                showSkipButton = true
            }
        }

        if reduceMotion {
            // Simplified sequence for reduced motion
            runReducedMotionSequence()
        } else {
            // Full cinematic sequence
            runFullSequence()
        }
    }

    private func runFullSequence() {
        // Phase 1: Dormant (0-3s)
        phase = .dormant

        // Start slow particle drift
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            particleOffset = 1000
        }

        // Phase 2: Power Build (3-8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            phase = .powerBuild

            withAnimation(.easeIn(duration: 5.0)) {
                glowIntensity = 0.7
                environmentShift = 0.3
            }

            // Start pulse animation
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.2
            }

            // Show text
            withAnimation(.easeIn(duration: 2.0)) {
                textOpacity = 1.0
            }
        }

        // Phase 3: Awakening (8-12s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            phase = .awakening

            withAnimation(.easeOut(duration: 2.0)) {
                eyeGlowOpacity = 1.0
                glowIntensity = 1.0
                environmentShift = 0.6
            }

            // Haptic feedback for awakening moment
            Task { @MainActor in
                HapticManager.notification(.success)
            }
        }

        // Phase 4: Revealed (12-15s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            phase = .revealed

            // Crossfade to awakened image
            withAnimation(.easeInOut(duration: 2.5)) {
                imageOpacity = 0.0
                awakenedOpacity = 1.0
                environmentShift = 0.8
            }
        }

        // Complete sequence (15s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            completeSequence()
        }
    }

    private func runReducedMotionSequence() {
        // Instant setup for reduced motion
        glowIntensity = 0.5
        textOpacity = 1.0
        environmentShift = 0.4

        // Quick fade to awakened
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                imageOpacity = 0.0
                awakenedOpacity = 1.0
                glowIntensity = 0.8
            }
        }

        // Complete after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            completeSequence()
        }
    }

    private func completeSequence() {
        cinematicAudio.stopCinematicAudio()

        withAnimation(.easeOut(duration: 0.5)) {
            showSkipButton = false
        }

        // Brief delay then complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
}

// MARK: - Cinematic Audio Manager

class CinematicAudioManager {
    private var audioEngine: AVAudioEngine?
    private var toneNode: AVAudioSourceNode?
    private var isPlaying: Bool = false

    // Tone parameters for dramatic cyberpunk music
    private var phase1: Double = 0.0
    private var phase2: Double = 0.0
    private var phase3: Double = 0.0
    private var lfoPhase: Double = 0.0
    private var time: Double = 0.0
    private let volume: Float = 0.25

    func startCinematicAudio() {
        guard !isPlaying else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Cinematic audio session setup failed: \(error)")
            return
        }

        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }

        let mainMixer = engine.mainMixerNode
        let outputFormat = mainMixer.outputFormat(forBus: 0)
        let sampleRate = outputFormat.sampleRate

        // Create dramatic cyberpunk tone generator
        toneNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                self.time += 1.0 / sampleRate

                // Very slow LFO for tension building
                self.lfoPhase += 0.05 / sampleRate
                if self.lfoPhase > 1.0 { self.lfoPhase -= 1.0 }
                let lfo = sin(self.lfoPhase * 2.0 * .pi)

                // Gradually increasing intensity over 15 seconds
                let intensity = min(1.0, self.time / 15.0)

                // Deep bass drone (A1 = 55Hz)
                let bassFreq = 55.0 + lfo * 2.0
                self.phase1 += bassFreq / sampleRate
                if self.phase1 > 1.0 { self.phase1 -= 1.0 }
                let bass = sin(self.phase1 * 2.0 * .pi) * 0.4

                // Mid harmonic (perfect fifth above, E2 = 82.5Hz)
                let midFreq = 82.5 + lfo * 3.0
                self.phase2 += midFreq / sampleRate
                if self.phase2 > 1.0 { self.phase2 -= 1.0 }
                let mid = sin(self.phase2 * 2.0 * .pi) * 0.2 * intensity

                // High shimmer (A3 = 220Hz, fades in later)
                let highIntensity = max(0, (intensity - 0.5) * 2.0)
                let highFreq = 220.0 + lfo * 10.0
                self.phase3 += highFreq / sampleRate
                if self.phase3 > 1.0 { self.phase3 -= 1.0 }
                let high = sin(self.phase3 * 2.0 * .pi) * 0.15 * highIntensity

                // Combine with soft saturation
                var sample = Float((bass + mid + high) * Double(self.volume))
                sample = tanh(sample * 1.5) // Soft clip for warmth

                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sample
                }
            }

            return noErr
        }

        guard let toneNode = toneNode else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.attach(toneNode)
        engine.connect(toneNode, to: mainMixer, format: format)

        mainMixer.outputVolume = 1.0

        do {
            try engine.start()
            isPlaying = true
        } catch {
            print("Cinematic audio engine start failed: \(error)")
        }
    }

    func stopCinematicAudio() {
        audioEngine?.stop()
        if let toneNode = toneNode {
            audioEngine?.detach(toneNode)
        }
        toneNode = nil
        audioEngine = nil
        isPlaying = false
        time = 0.0
    }
}

// MARK: - Preview

#Preview {
    HelixAwakeningView {
        print("Awakening complete")
    }
}
