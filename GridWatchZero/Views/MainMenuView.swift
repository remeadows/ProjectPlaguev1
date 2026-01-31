// MainMenuView.swift
// GridWatchZero
// Main menu with New Game / Continue Game options

import SwiftUI

struct MainMenuView: View {
    @State private var showButtons = false
    @State private var hasSaveData: Bool = false
    @State private var pulseOpacity: Double = 0.3

    var onNewGame: () -> Void
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            // Background
            Color.terminalBlack
                .ignoresSafeArea()

            // Grid overlay
            gridBackground

            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.top, 60)

                Spacer()

                // Menu buttons
                if showButtons {
                    menuButtons
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                // Footer
                footerSection
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            checkSaveData()
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showButtons = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.8
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("GRID WATCH ")
                    .foregroundColor(.neonGreen)
                Text("ZERO")
                    .foregroundColor(.neonAmber)
            }
            .font(.system(size: 28, weight: .bold, design: .monospaced))
            .glow(.neonGreen, radius: 8)

            Text("NEURAL GRID")
                .font(.terminalSmall)
                .foregroundColor(.terminalGray)
                .tracking(4)
        }
    }

    // MARK: - Menu Buttons

    private var menuButtons: some View {
        VStack(spacing: 20) {
            // Continue Game (only if save exists)
            if hasSaveData {
                MenuButton(
                    title: "CONTINUE",
                    subtitle: "Resume your operation",
                    icon: "play.fill",
                    color: .neonGreen,
                    pulseOpacity: pulseOpacity
                ) {
                    onContinue()
                }
            }

            // New Game
            MenuButton(
                title: "NEW GAME",
                subtitle: hasSaveData ? "Start fresh (overwrites save)" : "Begin your operation",
                icon: "plus.circle.fill",
                color: hasSaveData ? .neonAmber : .neonGreen,
                pulseOpacity: hasSaveData ? 0.3 : pulseOpacity
            ) {
                onNewGame()
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 8) {
            // Connection status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.neonGreen)
                    .frame(width: 6, height: 6)
                    .glow(.neonGreen, radius: 4)
                Text("SYSTEM ONLINE")
                    .font(.terminalMicro)
                    .foregroundColor(.dimGreen)
            }

            Text("v1.0.0")
                .font(.terminalMicro)
                .foregroundColor(.terminalGray.opacity(0.5))
        }
    }

    // MARK: - Grid Background

    private var gridBackground: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 40
                // Vertical lines
                for x in stride(from: 0, to: geo.size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                // Horizontal lines
                for y in stride(from: 0, to: geo.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.neonGreen.opacity(0.05), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Helpers

    private func checkSaveData() {
        // Check if save data exists
        hasSaveData = UserDefaults.standard.data(forKey: "GridWatchZero.GameState.v6") != nil
    }
}

// MARK: - Menu Button Component

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let pulseOpacity: Double
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40)

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.terminalTitle)
                        .foregroundColor(color)

                    Text(subtitle)
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.terminalBody)
                    .foregroundColor(color.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.terminalDarkGray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(pulseOpacity), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

#Preview {
    MainMenuView(
        onNewGame: { print("New Game") },
        onContinue: { print("Continue") }
    )
}
