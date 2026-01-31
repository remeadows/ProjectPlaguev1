// CosmeticSystem.swift
// GridWatchZero
// Cosmetic unlocks and UI customization from Insane mode completion

import SwiftUI
import Combine

// MARK: - UI Theme

enum UITheme: String, Codable, CaseIterable {
    case classic = "Classic"            // Default green terminal
    case crimson = "Crimson Protocol"   // Red/orange theme (Insane Level 1)
    case arctic = "Arctic Frost"        // Cyan/white theme (Insane Level 3)
    case helix = "Helix Purity"         // White/gold theme (Insane Level 5)
    case malus = "Malus Shadow"         // Dark purple/red (All Insane)

    var description: String {
        switch self {
        case .classic:
            return "The original Neural Grid interface"
        case .crimson:
            return "Forged in the fires of Insane mode"
        case .arctic:
            return "Cold precision under pressure"
        case .helix:
            return "Touched by Helix's light"
        case .malus:
            return "Conquered the darkness itself"
        }
    }

    var primaryColor: Color {
        switch self {
        case .classic: return .neonGreen
        case .crimson: return Color(red: 1.0, green: 0.3, blue: 0.2)
        case .arctic: return Color(red: 0.4, green: 0.9, blue: 1.0)
        case .helix: return Color(red: 1.0, green: 0.95, blue: 0.8)
        case .malus: return Color(red: 0.7, green: 0.2, blue: 0.9)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .classic: return .neonCyan
        case .crimson: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .arctic: return Color(red: 0.7, green: 0.8, blue: 1.0)
        case .helix: return Color(red: 0.9, green: 0.8, blue: 0.5)
        case .malus: return Color(red: 0.9, green: 0.3, blue: 0.5)
        }
    }

    var accentColor: Color {
        switch self {
        case .classic: return .neonAmber
        case .crimson: return .neonRed
        case .arctic: return .white
        case .helix: return Color(red: 1.0, green: 0.85, blue: 0.3)
        case .malus: return Color(red: 0.4, green: 0.1, blue: 0.3)
        }
    }

    var unlockRequirement: InsaneUnlockRequirement {
        switch self {
        case .classic: return .none
        case .crimson: return .insaneLevels(1)
        case .arctic: return .insaneLevels(3)
        case .helix: return .insaneLevels(5)
        case .malus: return .insaneLevels(7)
        }
    }

    func isUnlocked(insaneCompleted: Int) -> Bool {
        unlockRequirement.isSatisfied(insaneCompleted: insaneCompleted)
    }
}

// MARK: - Node Skin

enum NodeSkin: String, Codable, CaseIterable {
    case standard = "Standard"
    case hardened = "Hardened"
    case quantum = "Quantum"
    case neural = "Neural"
    case helixCore = "Helix Core"

    var description: String {
        switch self {
        case .standard: return "Factory default appearance"
        case .hardened: return "Battle-scarred veteran"
        case .quantum: return "Shimmering quantum state"
        case .neural: return "Pulsing neural patterns"
        case .helixCore: return "Infused with Helix energy"
        }
    }

    var unlockRequirement: InsaneUnlockRequirement {
        switch self {
        case .standard: return .none
        case .hardened: return .insaneLevels(2)
        case .quantum: return .insaneLevels(4)
        case .neural: return .insaneLevels(6)
        case .helixCore: return .insaneLevels(7)
        }
    }

    func isUnlocked(insaneCompleted: Int) -> Bool {
        unlockRequirement.isSatisfied(insaneCompleted: insaneCompleted)
    }
}

// MARK: - Unlock Requirement

enum InsaneUnlockRequirement: Codable, Equatable {
    case none
    case insaneLevels(Int)

    func isSatisfied(insaneCompleted: Int) -> Bool {
        switch self {
        case .none:
            return true
        case .insaneLevels(let count):
            return insaneCompleted >= count
        }
    }

    var description: String {
        switch self {
        case .none:
            return "Unlocked"
        case .insaneLevels(let count):
            if count == 7 {
                return "Complete ALL levels on Insane"
            }
            return "Complete \(count) level\(count == 1 ? "" : "s") on Insane"
        }
    }
}

// MARK: - Cosmetic State

@MainActor
class CosmeticState: ObservableObject {
    static let shared = CosmeticState()

    private let saveKey = "GridWatchZero.CosmeticState.v1"

    @Published var selectedTheme: UITheme = .classic
    @Published var selectedNodeSkin: NodeSkin = .standard
    @Published var insaneLevelsCompleted: Int = 0

    private init() {
        load()
    }

    // MARK: - Theme Access

    var currentPrimaryColor: Color {
        selectedTheme.isUnlocked(insaneCompleted: insaneLevelsCompleted) ? selectedTheme.primaryColor : UITheme.classic.primaryColor
    }

    var currentSecondaryColor: Color {
        selectedTheme.isUnlocked(insaneCompleted: insaneLevelsCompleted) ? selectedTheme.secondaryColor : UITheme.classic.secondaryColor
    }

    var currentAccentColor: Color {
        selectedTheme.isUnlocked(insaneCompleted: insaneLevelsCompleted) ? selectedTheme.accentColor : UITheme.classic.accentColor
    }

    // MARK: - Unlocks

    var unlockedThemes: [UITheme] {
        UITheme.allCases.filter { $0.isUnlocked(insaneCompleted: insaneLevelsCompleted) }
    }

    var unlockedSkins: [NodeSkin] {
        NodeSkin.allCases.filter { $0.isUnlocked(insaneCompleted: insaneLevelsCompleted) }
    }

    func updateInsaneProgress(_ count: Int) {
        guard count > insaneLevelsCompleted else { return }
        insaneLevelsCompleted = count
        save()

        // Check for newly unlocked cosmetics
        objectWillChange.send()
    }

    // MARK: - Selection

    func selectTheme(_ theme: UITheme) {
        guard theme.isUnlocked(insaneCompleted: insaneLevelsCompleted) else { return }
        selectedTheme = theme
        save()
    }

    func selectNodeSkin(_ skin: NodeSkin) {
        guard skin.isUnlocked(insaneCompleted: insaneLevelsCompleted) else { return }
        selectedNodeSkin = skin
        save()
    }

    // MARK: - Persistence

    private func save() {
        let data = CosmeticSaveData(
            selectedTheme: selectedTheme,
            selectedNodeSkin: selectedNodeSkin,
            insaneLevelsCompleted: insaneLevelsCompleted
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode(CosmeticSaveData.self, from: data) else {
            return
        }
        selectedTheme = decoded.selectedTheme
        selectedNodeSkin = decoded.selectedNodeSkin
        insaneLevelsCompleted = decoded.insaneLevelsCompleted
    }
}

// MARK: - Save Data

private struct CosmeticSaveData: Codable {
    let selectedTheme: UITheme
    let selectedNodeSkin: NodeSkin
    let insaneLevelsCompleted: Int
}

// MARK: - Cosmetic Unlock View

struct CosmeticUnlockBanner: View {
    let title: String
    let description: String
    let color: Color

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(color)
                Text("COSMETIC UNLOCKED")
                    .font(.terminalMicro)
                    .foregroundColor(color)
                Image(systemName: "sparkles")
                    .foregroundColor(color)
            }

            Text(title)
                .font(.terminalTitle)
                .foregroundColor(.white)

            Text(description)
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.terminalDarkGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 2)
                )
        )
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}
