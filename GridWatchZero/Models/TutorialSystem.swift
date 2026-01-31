// TutorialSystem.swift
// GridWatchZero
// Tutorial step definitions and state management for Level 1

import Foundation
import Combine

// MARK: - Tutorial Step

enum TutorialStep: Int, CaseIterable, Codable {
    case welcome = 0           // Initial welcome after level starts
    case explainDataFlow = 1   // Source → Link → Sink explanation
    case upgradeSource = 2     // Upgrade the Source node
    case upgradeLink = 3       // Upgrade the Link node
    case upgradeSink = 4       // Upgrade the Sink node
    case explainCredits = 5    // Credits/income explanation
    case purchaseFirewall = 6  // Buy a firewall
    case explainDefense = 7    // Defense points explanation
    case deployDefenseApp = 8  // Deploy first defense app
    case explainIntel = 9      // Intel reports explanation
    case sendFirstReport = 10  // Send first intel report
    case victoryGoals = 11     // Final goals reminder
    case complete = 12         // Tutorial complete

    var title: String {
        switch self {
        case .welcome: return "Welcome, Operator"
        case .explainDataFlow: return "The Data Pipeline"
        case .upgradeSource: return "Upgrade Your Source"
        case .upgradeLink: return "Boost Your Bandwidth"
        case .upgradeSink: return "Increase Processing"
        case .explainCredits: return "Earning Credits"
        case .purchaseFirewall: return "Deploy Defenses"
        case .explainDefense: return "Defense Points"
        case .deployDefenseApp: return "Security Applications"
        case .explainIntel: return "Intel Reports"
        case .sendFirstReport: return "Send Intel"
        case .victoryGoals: return "Victory Conditions"
        case .complete: return "Tutorial Complete"
        }
    }

    var rustyDialogue: [String] {
        switch self {
        case .welcome:
            return [
                "Alright, new operator. Let me walk you through the basics.",
                "This is your network dashboard. Everything you need to protect the grid is here."
            ]
        case .explainDataFlow:
            return [
                "See those three cards? SOURCE, LINK, and SINK. That's your data pipeline.",
                "SOURCE harvests data. LINK transports it. SINK converts it to credits.",
                "Keep all three upgraded and balanced for maximum efficiency."
            ]
        case .upgradeSource:
            return [
                "Let's start with your SOURCE. Tap the upgrade button to increase data output.",
                "More data harvested means more credits earned."
            ]
        case .upgradeLink:
            return [
                "Good. Now upgrade your LINK to handle the extra bandwidth.",
                "If your link can't keep up with the source, you'll lose data."
            ]
        case .upgradeSink:
            return [
                "Now the SINK. It processes data into credits.",
                "A higher-level sink means better conversion rates."
            ]
        case .explainCredits:
            return [
                "See that credit counter at the top? That's your lifeline.",
                "Everything costs credits. Run out, and the operation fails.",
                "For this mission, you need to earn ₵100,000 total."
            ]
        case .purchaseFirewall:
            return [
                "Time for defense. Without a firewall, you're exposed.",
                "Tap the DEFENSE section to deploy your first firewall.",
                "It'll absorb attacks so your credits don't take the hit."
            ]
        case .explainDefense:
            return [
                "That Defense Points number? That's your security rating.",
                "Higher DP means better protection. You need 50 DP to complete this mission."
            ]
        case .deployDefenseApp:
            return [
                "Firewalls are good, but security apps are better.",
                "Deploy a defense application—they add DP and special bonuses.",
                "Without at least one app deployed, you can't collect intel."
            ]
        case .explainIntel:
            return [
                "Intel reports are how we fight Malus.",
                "Every attack you survive generates footprint data.",
                "The SEND REPORT button transmits that intel to Tish."
            ]
        case .sendFirstReport:
            return [
                "Once you have enough footprint data, send your first report.",
                "You need to send 5 intel reports to complete this mission.",
                "Each report also earns you bonus credits."
            ]
        case .victoryGoals:
            return [
                "Here's what you need to finish this mission:",
                "• Earn ₵100,000 total credits",
                "• Reach 50 Defense Points",
                "• Send 5 intel reports",
                "• Keep risk level at GHOST",
                "You've got this, operator. I'll be watching."
            ]
        case .complete:
            return [
                "That covers the basics. You're on your own now.",
                "Remember: balance income and defense. Stay alive.",
                "Good luck out there."
            ]
        }
    }

    /// The UI element to highlight during this step
    var highlightElement: TutorialHighlight? {
        switch self {
        case .welcome, .explainDataFlow, .explainCredits, .explainDefense, .explainIntel, .victoryGoals, .complete:
            return nil
        case .upgradeSource:
            return .sourceCard
        case .upgradeLink:
            return .linkCard
        case .upgradeSink:
            return .sinkCard
        case .purchaseFirewall:
            return .firewallSection
        case .deployDefenseApp:
            return .defenseApps
        case .sendFirstReport:
            return .intelPanel
        }
    }

    /// Whether this step requires an action to complete (vs just reading)
    var requiresAction: Bool {
        switch self {
        case .upgradeSource, .upgradeLink, .upgradeSink, .purchaseFirewall, .deployDefenseApp, .sendFirstReport:
            return true
        default:
            return false
        }
    }

    var nextStep: TutorialStep? {
        let allCases = TutorialStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex + 1 < allCases.count else {
            return nil
        }
        return allCases[currentIndex + 1]
    }
}

// MARK: - Tutorial Highlight

enum TutorialHighlight: String, Codable {
    case sourceCard = "source"
    case linkCard = "link"
    case sinkCard = "sink"
    case firewallSection = "firewall"
    case defenseApps = "defense_apps"
    case intelPanel = "intel"
    case creditsDisplay = "credits"
    case threatIndicator = "threat"
}

// MARK: - Tutorial State

struct TutorialState: Codable {
    var isActive: Bool = false
    var currentStep: TutorialStep = .welcome
    var completedSteps: Set<Int> = []
    var hasCompletedTutorial: Bool = false
    var showingDialogue: Bool = false
    var dialogueLineIndex: Int = 0

    // Track actions for step completion
    var hasUpgradedSource: Bool = false
    var hasUpgradedLink: Bool = false
    var hasUpgradedSink: Bool = false
    var hasPurchasedFirewall: Bool = false
    var hasDeployedDefenseApp: Bool = false
    var hasSentReport: Bool = false

    mutating func startTutorial() {
        isActive = true
        currentStep = .welcome
        completedSteps = []
        showingDialogue = true
        dialogueLineIndex = 0
    }

    mutating func completeCurrentStep() {
        completedSteps.insert(currentStep.rawValue)
        if let next = currentStep.nextStep {
            currentStep = next
            showingDialogue = true
            dialogueLineIndex = 0
        } else {
            // Tutorial finished
            isActive = false
            hasCompletedTutorial = true
        }
    }

    mutating func advanceDialogue() -> Bool {
        let maxLines = currentStep.rustyDialogue.count
        if dialogueLineIndex < maxLines - 1 {
            dialogueLineIndex += 1
            return true
        } else {
            // Finished current dialogue
            showingDialogue = false
            // If step doesn't require action, auto-advance
            if !currentStep.requiresAction {
                completeCurrentStep()
            }
            return false
        }
    }

    mutating func skipTutorial() {
        isActive = false
        hasCompletedTutorial = true
    }

    /// Check if an action completes the current step
    mutating func checkStepCompletion(action: TutorialAction) {
        guard isActive && !showingDialogue else { return }

        switch (currentStep, action) {
        case (.upgradeSource, .upgradedSource):
            hasUpgradedSource = true
            completeCurrentStep()
        case (.upgradeLink, .upgradedLink):
            hasUpgradedLink = true
            completeCurrentStep()
        case (.upgradeSink, .upgradedSink):
            hasUpgradedSink = true
            completeCurrentStep()
        case (.purchaseFirewall, .purchasedFirewall):
            hasPurchasedFirewall = true
            completeCurrentStep()
        case (.deployDefenseApp, .deployedDefenseApp):
            hasDeployedDefenseApp = true
            completeCurrentStep()
        case (.sendFirstReport, .sentReport):
            hasSentReport = true
            completeCurrentStep()
        default:
            break
        }
    }

    var currentDialogueLine: String {
        let lines = currentStep.rustyDialogue
        guard dialogueLineIndex < lines.count else { return "" }
        return lines[dialogueLineIndex]
    }

    var dialogueProgress: (current: Int, total: Int) {
        return (dialogueLineIndex + 1, currentStep.rustyDialogue.count)
    }
}

// MARK: - Tutorial Actions

enum TutorialAction {
    case upgradedSource
    case upgradedLink
    case upgradedSink
    case purchasedFirewall
    case deployedDefenseApp
    case sentReport
}

// MARK: - Tutorial Manager

@MainActor
class TutorialManager: ObservableObject {
    static let shared = TutorialManager()

    @Published var state = TutorialState()

    private let saveKey = "GridWatchZero.TutorialState.v1"

    private init() {
        load()
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let loaded = try? JSONDecoder().decode(TutorialState.self, from: data) {
            state = loaded
        }
    }

    // MARK: - Control

    func startTutorialForLevel1() {
        guard !state.hasCompletedTutorial else { return }
        state.startTutorial()
        save()
    }

    func advanceDialogue() {
        _ = state.advanceDialogue()
        save()
    }

    func skipTutorial() {
        state.skipTutorial()
        save()
    }

    func recordAction(_ action: TutorialAction) {
        state.checkStepCompletion(action: action)
        save()
    }

    func reset() {
        state = TutorialState()
        save()
    }

    // MARK: - Queries

    var shouldShowTutorial: Bool {
        state.isActive && !state.hasCompletedTutorial
    }

    var isShowingDialogue: Bool {
        state.isActive && state.showingDialogue
    }

    var currentHighlight: TutorialHighlight? {
        guard state.isActive && !state.showingDialogue else { return nil }
        return state.currentStep.highlightElement
    }
}
