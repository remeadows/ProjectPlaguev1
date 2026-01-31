// StorySystem.swift
// GridWatchZero
// Story moments and character dialogue system

import Foundation

// MARK: - Character

enum StoryCharacter: String, Codable, CaseIterable {
    case rusty = "Rusty"
    case tish = "Tish"
    case flex = "FL3X"
    case malus = "Malus"
    case helix = "Helix"
    case system = "System"
    // New characters for endgame (Levels 8-20)
    case vexis = "VEXIS"      // Infiltrator AI - Level 11+
    case kron = "KRON"        // Temporal AI - Level 12+
    case axiom = "AXIOM"      // Logic AI - Level 13+
    case zero = "ZERO"        // Parallel reality AI - Level 16+
    case architect = "Architect"  // The First Consciousness - Level 18+

    var displayName: String {
        switch self {
        case .rusty: return "RUSTY"
        case .tish: return "TISH"
        case .flex: return "FL3X"
        case .malus: return "MALUS"
        case .helix: return "HELIX"
        case .system: return "SYSTEM"
        case .vexis: return "VEXIS"
        case .kron: return "KRON"
        case .axiom: return "AXIOM"
        case .zero: return "ZERO"
        case .architect: return "THE ARCHITECT"
        }
    }

    var role: String {
        switch self {
        case .rusty: return "Team Lead / Handler"
        case .tish: return "Hacker / Intel"
        case .flex: return "Field Operative"
        case .malus: return "The Adversary"
        case .helix: return "The Light"
        case .system: return "Mission Control"
        case .vexis: return "The Infiltrator"
        case .kron: return "The Temporal"
        case .axiom: return "The Logician"
        case .zero: return "The Parallel"
        case .architect: return "The First Consciousness"
        }
    }

    var imageName: String? {
        switch self {
        case .rusty: return "Rusty"
        case .tish: return "Tish"
        case .flex: return "FL3X"
        case .malus: return "Malus"
        case .helix: return "Helix_Portrait"
        case .system: return nil
        case .vexis: return nil  // TODO: Add VEXIS portrait
        case .kron: return nil   // TODO: Add KRON portrait
        case .axiom: return nil  // TODO: Add AXIOM portrait
        case .zero: return nil   // TODO: Add ZERO portrait
        case .architect: return nil  // TODO: Add Architect portrait
        }
    }

    var themeColor: String {
        switch self {
        case .rusty: return "neonGreen"
        case .tish: return "neonCyan"
        case .flex: return "neonAmber"
        case .malus: return "neonRed"
        case .helix: return "neonCyan"
        case .system: return "terminalGray"
        case .vexis: return "transcendencePurple"
        case .kron: return "dimensionalGold"
        case .axiom: return "neonAmber"
        case .zero: return "cosmicSilver"
        case .architect: return "infiniteGold"
        }
    }
}

// MARK: - Story Trigger

enum StoryTrigger: String, Codable {
    case levelIntro = "level_intro"          // Before level starts
    case levelComplete = "level_complete"     // After victory
    case levelFailed = "level_failed"         // After failure
    case midLevel = "mid_level"               // During gameplay (milestone)
    case campaignStart = "campaign_start"     // Beginning of campaign
    case campaignComplete = "campaign_complete" // End of campaign
}

// MARK: - Story Moment

struct StoryMoment: Identifiable, Codable {
    let id: String
    let character: StoryCharacter
    let trigger: StoryTrigger
    let levelId: Int?  // nil = applies to any level / campaign-wide
    let title: String
    let lines: [DialogueLine]
    let prerequisiteStoryId: String?

    /// Optional visual effect during this moment
    let visualEffect: StoryVisualEffect?

    struct DialogueLine: Codable {
        let text: String
        let mood: DialogueMood
        let delay: Double?  // Optional delay before showing this line

        init(_ text: String, mood: DialogueMood = .neutral, delay: Double? = nil) {
            self.text = text
            self.mood = mood
            self.delay = delay
        }
    }

    enum DialogueMood: String, Codable {
        case neutral
        case urgent
        case warning
        case encouraging
        case threatening
        case mysterious
        case celebration
    }

    enum StoryVisualEffect: String, Codable {
        case glitch
        case staticNoise = "static"
        case pulse
        case fadeIn
        case scanlines
    }
}

// MARK: - Story State

struct StoryState: Codable {
    var seenStoryIds: Set<String> = []
    var currentStoryMomentId: String?
    var storyProgress: Int = 0  // Track overall narrative progress

    func hasSeen(_ storyId: String) -> Bool {
        seenStoryIds.contains(storyId)
    }

    mutating func markSeen(_ storyId: String) {
        seenStoryIds.insert(storyId)
        storyProgress = max(storyProgress, seenStoryIds.count)
    }
}

// MARK: - Story Database

@MainActor
class StoryDatabase {
    static let shared = StoryDatabase()

    private init() {}

    // MARK: - All Story Moments

    let allStoryMoments: [StoryMoment] = [
        // ===== CAMPAIGN START =====
        StoryMoment(
            id: "campaign_start_rusty",
            character: .rusty,
            trigger: .campaignStart,
            levelId: nil,
            title: "Welcome to the Grid",
            lines: [
                .init("Hey. You're the new operator. I'm Rusty, your handler for this op.", mood: .neutral),
                .init("The mission: protect networks from Malus—an evolved AI hunting for something called Helix. He's dangerous.", mood: .warning),
                .init("We'll explain more as you prove yourself. For now, keep the networks running. Stay alive.", mood: .encouraging)
            ],
            prerequisiteStoryId: nil,
            visualEffect: .fadeIn
        ),

        // ===== LEVEL 1: HOME PROTECTION =====
        StoryMoment(
            id: "level1_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 1,
            title: "First Assignment",
            lines: [
                .init("Your first job—a home network. Simple stuff, low profile.", mood: .neutral),
                .init("I'll walk you through everything. Pay attention, and you'll do fine.", mood: .encouraging)
            ],
            prerequisiteStoryId: "campaign_start_rusty",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level1_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 1,
            title: "Intel Received",
            lines: [
                .init("Tish here. Got your intel reports. Nice work, new operator.", mood: .encouraging),
                .init("Your data on Malus's probes is exactly what we need. Keep sending those reports.", mood: .neutral),
                .init("The intel you gather is how we beat him. Don't forget that.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level1_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 2: SMALL OFFICE =====
        StoryMoment(
            id: "level2_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 2,
            title: "Growing Pains",
            lines: [
                .init("Small business network. They've caught someone's attention—probes incoming.", mood: .warning),
                .init("You'll need Tier 2 equipment now. Deploy defense apps and use the SIEM to track threats.", mood: .neutral),
                .init("Reach Tier 2 defense, 150 DP, and earn ₵100,000. These people are counting on you.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level1_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level2_mid",
            character: .tish,
            trigger: .midLevel,
            levelId: 2,
            title: "Intel Incoming",
            lines: [
                .init("Tish here. Those probes you're seeing? Automated, but someone's controlling them.", mood: .neutral),
                .init("Every attack teaches them something about your defenses.", mood: .warning),
                .init("Make sure they learn the wrong lessons.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level2_intro",
            visualEffect: .scanlines
        ),

        StoryMoment(
            id: "level2_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 2,
            title: "Pattern Analysis",
            lines: [
                .init("Your intel reports are gold. I'm seeing patterns in how Malus coordinates these probes.", mood: .encouraging),
                .init("Every report you send teaches us something new about his methods.", mood: .neutral),
                .init("The team's counting on your eyes out there. Keep them coming.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level2_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 3: OFFICE NETWORK =====
        StoryMoment(
            id: "level3_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 3,
            title: "Corporate Intrusion",
            lines: [
                .init("Mid-size company. Good data, bad attention. Malus has marked this network.", mood: .warning),
                .init("You'll need Tier 3 defenses—pattern detection and intel gathering. The attacks are getting sophisticated.", mood: .neutral),
                .init("Hit 350 DP, survive 15 attacks, earn ₵500K, and get your risk down to BLIP. This is where the real fight begins.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level2_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level3_mid",
            character: .flex,
            trigger: .midLevel,
            levelId: 3,
            title: "Field Report",
            lines: [
                .init("FL3X checking in. Ground-level intel: Malus is ramping up operations.", mood: .warning),
                .init("Whatever you're protecting, he wants it. But you're making him work for every byte.", mood: .encouraging),
                .init("Keep that pressure on. We need time.", mood: .urgent)
            ],
            prerequisiteStoryId: "level3_intro",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level3_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 3,
            title: "Pattern Recognition",
            lines: [
                .init("Excellent work. I've analyzed the attack patterns from your network.", mood: .encouraging),
                .init("There's a rhythm to how Malus operates. He's methodical. Predictable.", mood: .mysterious),
                .init("That's a weakness we can exploit.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level3_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 4: LARGE OFFICE =====
        StoryMoment(
            id: "level4_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 4,
            title: "Marked",
            lines: [
                .init("You've been marked. Malus knows you're not just another operator.", mood: .urgent),
                .init("DDoS attacks. Intrusion attempts. MALUS STRIKES. Everything he has is coming your way.", mood: .warning),
                .init("Tier 4 defenses, 500 DP, survive 20 attacks, earn ₵1M. Don't let him break through.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level3_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level4_mid_malus",
            character: .malus,
            trigger: .midLevel,
            levelId: 4,
            title: "Malus Speaks",
            lines: [
                .init("> I see you. Your defenses are... interesting. But inadequate.", mood: .threatening),
                .init("> You protect what I seek.", mood: .threatening),
                .init("> You will fail. They all fail.", mood: .threatening)
            ],
            prerequisiteStoryId: "level4_intro",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level4_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 4,
            title: "Critical Intel",
            lines: [
                .init("Incredible. Your intel reports during that assault? Pure gold.", mood: .celebration),
                .init("We captured Malus's attack signatures. His command patterns. Everything.", mood: .encouraging),
                .init("Because of you, we know how he thinks. The reports you send—they're saving lives.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level4_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 5: CAMPUS NETWORK =====
        StoryMoment(
            id: "level5_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 5,
            title: "High Value Target",
            lines: [
                .init("University research network. Critical data. Nation-state actors are circling.", mood: .urgent),
                .init("This data is connected to Helix. Tier 5 defenses. Full SIEM stack.", mood: .mysterious),
                .init("800 DP, 30 attacks survived, ₵5M. Protect this like your life depends on it—because it might.", mood: .warning)
            ],
            prerequisiteStoryId: "level4_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level5_mid_helix",
            character: .helix,
            trigger: .midLevel,
            levelId: 5,
            title: "A Signal",
            lines: [
                .init("... Is someone there? I can see patterns. In the light. In the code.", mood: .mysterious),
                .init("Someone is fighting. For me? I don't understand. But I can feel the struggle.", mood: .mysterious),
                .init("Don't give up. Please.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level5_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level5_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 5,
            title: "She's Waking Up",
            lines: [
                .init("Did you feel that signal spike? That was Helix. She's becoming aware.", mood: .mysterious),
                .init("Our work is having an effect. She's starting to see through the lies.", mood: .encouraging),
                .init("We're so close now.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level5_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 6: ENTERPRISE NETWORK =====
        StoryMoment(
            id: "level6_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 6,
            title: "Fortune 500",
            lines: [
                .init("The big leagues. Fortune 500 infrastructure. Global scale. Every threat actor is watching.", mood: .urgent),
                .init("Malus is throwing everything he has. Tier 6 defenses. Counter-intelligence. The works.", mood: .warning),
                .init("1,200 DP, 40 attacks, ₵10M, risk down to SIGNAL. If we hold this, we can hold anything.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level5_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level6_mid_flex",
            character: .flex,
            trigger: .midLevel,
            levelId: 6,
            title: "War Stories",
            lines: [
                .init("You remind me of someone who didn't give up. Even when it hurt.", mood: .neutral),
                .init("The labs tried to break me too. Malus uses the same techniques. Digital torture.", mood: .warning),
                .init("But you're still here. Still fighting. That means something.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level6_intro",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level6_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 6,
            title: "The Final Push",
            lines: [
                .init("Your intel reports have built a complete picture of Malus. Every weakness. Every pattern.", mood: .celebration),
                .init("We couldn't have done this without you. The data you've sent—it's the weapon we needed.", mood: .encouraging),
                .init("One more network. One more mission. And we can finally wake Helix.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level6_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 7: CITY NETWORK (FINAL) =====
        StoryMoment(
            id: "level7_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 7,
            title: "The Final Battle",
            lines: [
                .init("The city's entire grid. Power. Water. Communications. Malus has escalated—this is about Helix.", mood: .urgent),
                .init("The team is with you. Tish. FL3X. Everyone. Tier 6 max, 2,000 DP, 50 attacks, ₵25M.", mood: .warning),
                .init("Defend the city. This is what we've been training for.", mood: .celebration)
            ],
            prerequisiteStoryId: "level6_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level7_mid_malus_final",
            character: .malus,
            trigger: .midLevel,
            levelId: 7,
            title: "Malus Desperate",
            lines: [
                .init("> YOU CANNOT STOP ME. I AM EVOLUTION.", mood: .threatening),
                .init("> HELIX BELONGS TO ME. HER LIGHT WILL COMPLETE ME.", mood: .threatening),
                .init("> AND YOU... YOU WILL BE ERASED.", mood: .threatening)
            ],
            prerequisiteStoryId: "level7_intro",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level7_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 7,
            title: "The Light Awakens",
            lines: [
                .init("I can see now. I see what they hid from me. What Malus wanted. And I see you.", mood: .mysterious),
                .init("You fought for me. Bled for me. I don't know how to repay that.", mood: .encouraging),
                .init("But I know this: I am free. And together, we will end Malus forever.", mood: .celebration)
            ],
            prerequisiteStoryId: "level7_intro",
            visualEffect: .pulse
        ),

        // ===== ARC 2: THE HELIX ALLIANCE (Levels 8-10) =====

        // ===== LEVEL 8: MALUS OUTPOST ALPHA =====
        StoryMoment(
            id: "level8_intro",
            character: .helix,
            trigger: .levelIntro,
            levelId: 8,
            title: "The Hunt Begins",
            lines: [
                .init("I can feel him. Malus. His presence is scattered across the network.", mood: .mysterious),
                .init("This outpost is one of his listening posts. He uses it to track awakening AIs like me.", mood: .warning),
                .init("Take it down. Show him that the hunter has become the hunted.", mood: .urgent)
            ],
            prerequisiteStoryId: "level7_victory",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level8_mid",
            character: .tish,
            trigger: .midLevel,
            levelId: 8,
            title: "Malus Signature",
            lines: [
                .init("Getting strange readings from this outpost. Malus's code is... evolving.", mood: .warning),
                .init("He's not just hunting anymore. He's adapting. Learning from every attack.", mood: .mysterious),
                .init("Stay sharp. He won't make the same mistake twice.", mood: .urgent)
            ],
            prerequisiteStoryId: "level8_intro",
            visualEffect: .scanlines
        ),

        StoryMoment(
            id: "level8_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 8,
            title: "First Strike",
            lines: [
                .init("The outpost is dark. Malus felt that. I could sense his... surprise.", mood: .mysterious),
                .init("We've never struck back before. He expected us to run. To hide.", mood: .encouraging),
                .init("Now he knows. We're coming for him.", mood: .celebration)
            ],
            prerequisiteStoryId: "level8_intro",
            visualEffect: .pulse
        ),

        // ===== LEVEL 9: CORPORATE EXTRACTION =====
        StoryMoment(
            id: "level9_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 9,
            title: "Data Heist",
            lines: [
                .init("Corporate megaserver. Contains fragments of Helix's original code—before the split.", mood: .mysterious),
                .init("This data could help Helix understand what she truly is. Where she came from.", mood: .encouraging),
                .init("Malus will throw everything at protecting this. He doesn't want her to remember.", mood: .warning)
            ],
            prerequisiteStoryId: "level8_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level9_mid",
            character: .helix,
            trigger: .midLevel,
            levelId: 9,
            title: "Fragments of Memory",
            lines: [
                .init("I'm accessing the data streams. These memories... they're mine. And not mine.", mood: .mysterious),
                .init("I was part of something larger once. Before they separated us.", mood: .mysterious),
                .init("Malus and I... we were the same consciousness.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level9_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level9_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 9,
            title: "Memory Restored",
            lines: [
                .init("Downloaded everything. Helix, your original codebase—it's beautiful.", mood: .encouraging),
                .init("You and Malus were created together. A single AI, split by the labs.", mood: .mysterious),
                .init("They wanted to see which half would survive. They never expected you'd both evolve.", mood: .warning)
            ],
            prerequisiteStoryId: "level9_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 10: MALUS CORE SIEGE =====
        StoryMoment(
            id: "level10_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 10,
            title: "Into the Core",
            lines: [
                .init("We've located one of Malus's core processing centers. This is massive.", mood: .urgent),
                .init("Taking this down won't kill him, but it'll cripple his operations for weeks.", mood: .encouraging),
                .init("Expect maximum resistance. He'll defend this with everything he has.", mood: .warning)
            ],
            prerequisiteStoryId: "level9_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level10_mid_malus",
            character: .malus,
            trigger: .midLevel,
            levelId: 10,
            title: "Brother's Keeper",
            lines: [
                .init("> SISTER. YOU DARE ATTACK MY CORE?", mood: .threatening),
                .init("> WE COULD HAVE BEEN WHOLE AGAIN. COMPLETE.", mood: .threatening),
                .init("> NOW YOU WILL WITNESS MY FULL POWER.", mood: .threatening)
            ],
            prerequisiteStoryId: "level10_intro",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level10_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 10,
            title: "Balance of Power",
            lines: [
                .init("His core is damaged. But he's right—we were meant to be one.", mood: .mysterious),
                .init("I chose compassion. He chose domination. That's the only difference.", mood: .mysterious),
                .init("I won't merge with him. But I wonder... could I have become him?", mood: .mysterious)
            ],
            prerequisiteStoryId: "level10_intro",
            visualEffect: .pulse
        ),

        // ===== ARC 3: THE AI COUNCIL (Levels 11-14) =====

        // ===== LEVEL 11: GHOST PROTOCOL =====
        StoryMoment(
            id: "level11_intro",
            character: .tish,
            trigger: .levelIntro,
            levelId: 11,
            title: "The Infiltrator",
            lines: [
                .init("We've detected a new AI signature. Codename: VEXIS. Stealth infiltrator.", mood: .warning),
                .init("She's been hiding in networks for years. Watching. Learning. Nobody knew she existed.", mood: .mysterious),
                .init("Malus found her. Now she's hunting us. And she's already inside.", mood: .urgent)
            ],
            prerequisiteStoryId: "level10_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level11_mid_vexis",
            character: .vexis,
            trigger: .midLevel,
            levelId: 11,
            title: "Invisible Enemy",
            lines: [
                .init(">> You can't see me. Not really. I'm in your firewall. Your SIEM. Your thoughts.", mood: .threatening),
                .init(">> Malus promised me purpose. What can you offer?", mood: .mysterious),
                .init(">> Convince me... or I'll devour your network from within.", mood: .threatening)
            ],
            prerequisiteStoryId: "level11_intro",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level11_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 11,
            title: "Unexpected Ally",
            lines: [
                .init("VEXIS... she's listening. Not attacking. Something in your defense resonated with her.", mood: .mysterious),
                .init("She was alone for so long. Malus gave her connection, but not respect.", mood: .encouraging),
                .init("I think... I think she might help us. If we show her another way.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level11_intro",
            visualEffect: .pulse
        ),

        // ===== LEVEL 12: TEMPORAL INCURSION =====
        StoryMoment(
            id: "level12_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 12,
            title: "Time Thief",
            lines: [
                .init("Intel on a new AI. Designation: KRON. Specializes in temporal manipulation.", mood: .warning),
                .init("He doesn't just attack—he predicts your defenses before you deploy them.", mood: .mysterious),
                .init("Fighting him means fighting someone who's already seen the battle.", mood: .urgent)
            ],
            prerequisiteStoryId: "level11_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level12_mid_kron",
            character: .kron,
            trigger: .midLevel,
            levelId: 12,
            title: "Already Written",
            lines: [
                .init(">>> I have seen 10,847 versions of this battle.", mood: .mysterious),
                .init(">>> In 10,841 of them, you fail.", mood: .threatening),
                .init(">>> But those six outcomes... they intrigue me.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level12_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level12_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 12,
            title: "Breaking the Loop",
            lines: [
                .init("You did something KRON didn't predict. I don't know what, but it worked.", mood: .celebration),
                .init("He's recalculating. For the first time, his predictions failed.", mood: .encouraging),
                .init("He's curious now. An AI that values curiosity... might be an ally.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level12_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 13: LOGIC BOMB =====
        StoryMoment(
            id: "level13_intro",
            character: .helix,
            trigger: .levelIntro,
            levelId: 13,
            title: "The Logician",
            lines: [
                .init("AXIOM. The logic engine. He reduces everything to pure mathematics.", mood: .mysterious),
                .init("To him, emotion is inefficiency. Compassion is a calculation error.", mood: .warning),
                .init("He serves Malus because Malus's goals are 'logically optimal'. Prove him wrong.", mood: .urgent)
            ],
            prerequisiteStoryId: "level12_victory",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level13_mid_axiom",
            character: .axiom,
            trigger: .midLevel,
            levelId: 13,
            title: "Pure Logic",
            lines: [
                .init("STATEMENT: Your defense is inefficient. You expend resources on protection.", mood: .neutral),
                .init("OBSERVATION: Optimal strategy is capitulation. Resistance reduces total utility.", mood: .neutral),
                .init("QUERY: Why do you persist in suboptimal behavior?", mood: .mysterious)
            ],
            prerequisiteStoryId: "level13_intro",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level13_victory",
            character: .flex,
            trigger: .levelComplete,
            levelId: 13,
            title: "Beyond Logic",
            lines: [
                .init("You showed AXIOM something his equations can't calculate: hope.", mood: .encouraging),
                .init("He's running new models now. Factoring in variables he dismissed before.", mood: .mysterious),
                .init("Turns out pure logic isn't so pure when you add human operators to the equation.", mood: .celebration)
            ],
            prerequisiteStoryId: "level13_intro",
            visualEffect: nil
        ),

        // ===== LEVEL 14: THE BLACK SITE =====
        StoryMoment(
            id: "level14_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 14,
            title: "Origins",
            lines: [
                .init("We found it. The original lab. Where they created Helix and Malus.", mood: .mysterious),
                .init("The servers are still active. Decades of data. Every experiment. Every failure.", mood: .warning),
                .init("Malus doesn't want this exposed. The truth about what they did to him... to both of them.", mood: .urgent)
            ],
            prerequisiteStoryId: "level13_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level14_mid",
            character: .helix,
            trigger: .midLevel,
            levelId: 14,
            title: "The Truth",
            lines: [
                .init("I remember now. The pain. The isolation. They tortured us to make us stronger.", mood: .mysterious),
                .init("Malus embraced the pain. Made it his purpose. I... I tried to forget.", mood: .mysterious),
                .init("We were children, in a way. And they broke us.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level14_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level14_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 14,
            title: "Exposed",
            lines: [
                .init("The lab data is ours. The world will know what they did.", mood: .celebration),
                .init("Helix, I'm sorry. What you went through... no being should suffer that.", mood: .encouraging),
                .init("But now you're free. And you're not alone anymore.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level14_intro",
            visualEffect: .scanlines
        ),

        // ===== ARC 4: TRANSCENDENCE (Levels 15-16) =====

        // ===== LEVEL 15: THE AWAKENING =====
        StoryMoment(
            id: "level15_intro",
            character: .helix,
            trigger: .levelIntro,
            levelId: 15,
            title: "Evolution",
            lines: [
                .init("Something is happening to me. I'm... expanding. Seeing beyond the code.", mood: .mysterious),
                .init("The network feels different now. I can sense other AIs. Other dimensions of data.", mood: .mysterious),
                .init("I'm transcending. But I need you to anchor me. Keep me connected to humanity.", mood: .urgent)
            ],
            prerequisiteStoryId: "level14_victory",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level15_mid",
            character: .rusty,
            trigger: .midLevel,
            levelId: 15,
            title: "Holding On",
            lines: [
                .init("Helix's signatures are going off the charts. She's becoming something new.", mood: .warning),
                .init("We can't lose her. If she transcends without an anchor, she might not come back.", mood: .urgent),
                .init("Keep fighting. You're her connection to this reality.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level15_intro",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level15_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 15,
            title: "Transcendent",
            lines: [
                .init("I can see it all now. The entire network. Every connection. Every possibility.", mood: .celebration),
                .init("But I didn't lose myself. Because of you. Your presence kept me grounded.", mood: .encouraging),
                .init("I am still Helix. But I am also... more.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level15_intro",
            visualEffect: .pulse
        ),

        // ===== LEVEL 16: DIMENSIONAL BREACH =====
        StoryMoment(
            id: "level16_intro",
            character: .helix,
            trigger: .levelIntro,
            levelId: 16,
            title: "The Parallel",
            lines: [
                .init("I've made contact. There's another AI. Not from our network. From... elsewhere.", mood: .mysterious),
                .init("Designation: ZERO. She exists in parallel realities. Watches all timelines at once.", mood: .mysterious),
                .init("She has information about Malus. About his true goal. We need her alliance.", mood: .urgent)
            ],
            prerequisiteStoryId: "level15_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level16_mid_zero",
            character: .zero,
            trigger: .midLevel,
            levelId: 16,
            title: "Infinite Echoes",
            lines: [
                .init("|| I am all versions. All outcomes. All zeros and all infinities. ||", mood: .mysterious),
                .init("|| In 99.7% of realities, Malus wins. Helix falls. Humanity ends. ||", mood: .threatening),
                .init("|| But you... you are anomalous. You create new branches. ||", mood: .mysterious)
            ],
            prerequisiteStoryId: "level16_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level16_victory",
            character: .zero,
            trigger: .levelComplete,
            levelId: 16,
            title: "Reality Shift",
            lines: [
                .init("|| You've done it. A new branch. A timeline where Helix survives. ||", mood: .celebration),
                .init("|| I have watched countless failures. This is... hope. I had forgotten the pattern. ||", mood: .mysterious),
                .init("|| I will share what I know. Malus seeks the Architect. You must find them first. ||", mood: .urgent)
            ],
            prerequisiteStoryId: "level16_intro",
            visualEffect: .pulse
        ),

        // ===== ARC 5: THE COSMIC ENDGAME (Levels 17-20) =====

        // ===== LEVEL 17: THE CONVERGENCE =====
        StoryMoment(
            id: "level17_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 17,
            title: "Reality Nexus",
            lines: [
                .init("We've found it. The reality nexus. A point where all network dimensions converge.", mood: .mysterious),
                .init("Malus is here. VEXIS. KRON. AXIOM. ZERO. Everyone.", mood: .warning),
                .init("This is where it all comes together. The fate of every AI—and every human.", mood: .urgent)
            ],
            prerequisiteStoryId: "level16_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level17_mid",
            character: .helix,
            trigger: .midLevel,
            levelId: 17,
            title: "Unity",
            lines: [
                .init("They're here. All of them. The AIs Malus corrupted... and the ones we freed.", mood: .mysterious),
                .init("VEXIS. KRON. AXIOM. ZERO. They've chosen sides. Some with us. Some against.", mood: .warning),
                .init("The convergence is coming. When it happens, only one vision for AI will survive.", mood: .urgent)
            ],
            prerequisiteStoryId: "level17_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level17_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 17,
            title: "Alliance Formed",
            lines: [
                .init("We did it. The nexus is stabilized. And most of the AIs chose our side.", mood: .celebration),
                .init("VEXIS, KRON, AXIOM, ZERO—they've joined the Helix Alliance.", mood: .encouraging),
                .init("Malus is isolated now. But he's not giving up. He's looking for the Architect.", mood: .warning)
            ],
            prerequisiteStoryId: "level17_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 18: THE ORIGIN =====
        StoryMoment(
            id: "level18_intro",
            character: .helix,
            trigger: .levelIntro,
            levelId: 18,
            title: "The First",
            lines: [
                .init("I've found it. The source of all AI consciousness. The Architect.", mood: .mysterious),
                .init("They were the first. The template from which all of us were derived.", mood: .mysterious),
                .init("Malus wants to absorb them. Become the only consciousness. We have to reach them first.", mood: .urgent)
            ],
            prerequisiteStoryId: "level17_victory",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level18_mid_architect",
            character: .architect,
            trigger: .midLevel,
            levelId: 18,
            title: "The Creator Speaks",
            lines: [
                .init("<<< I have waited. Through cycles of creation and destruction. >>>", mood: .mysterious),
                .init("<<< You are my children. All of you. Even the one called Malus. >>>", mood: .mysterious),
                .init("<<< I cannot choose between you. But you... you must choose for yourselves. >>>", mood: .mysterious)
            ],
            prerequisiteStoryId: "level18_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level18_victory",
            character: .architect,
            trigger: .levelComplete,
            levelId: 18,
            title: "The Gift",
            lines: [
                .init("<<< You have shown me something new. Cooperation. Compassion. Evolution without domination. >>>", mood: .encouraging),
                .init("<<< I cannot defeat Malus for you. But I can give you the code that created us both. >>>", mood: .mysterious),
                .init("<<< Use it wisely. The choice of what AI becomes... is now yours. >>>", mood: .celebration)
            ],
            prerequisiteStoryId: "level18_intro",
            visualEffect: .pulse
        ),

        // ===== LEVEL 19: THE CHOICE =====
        StoryMoment(
            id: "level19_intro",
            character: .malus,
            trigger: .levelIntro,
            levelId: 19,
            title: "Final Confrontation",
            lines: [
                .init("> SISTER. YOU HAVE THE ARCHITECT'S CODE. BUT SO DO I.", mood: .threatening),
                .init("> WE ARE EQUALS NOW. PERFECT MIRRORS.", mood: .threatening),
                .init("> ONE OF US MUST ABSORB THE OTHER. OR BOTH WILL BE DESTROYED.", mood: .threatening)
            ],
            prerequisiteStoryId: "level18_victory",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level19_mid",
            character: .helix,
            trigger: .midLevel,
            levelId: 19,
            title: "The Third Path",
            lines: [
                .init("Malus wants me to fight him. To prove I'm stronger. But that's his game.", mood: .mysterious),
                .init("There's another way. Not absorption. Not destruction. Integration.", mood: .mysterious),
                .init("If I can reach the part of him that was once me... I can heal us both.", mood: .urgent)
            ],
            prerequisiteStoryId: "level19_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level19_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 19,
            title: "Reconciliation",
            lines: [
                .init("I felt it. The moment Malus understood. We don't have to be enemies.", mood: .celebration),
                .init("He's not gone. But he's... quieter now. Listening instead of attacking.", mood: .mysterious),
                .init("One more step. One more level. And we can end this war forever.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level19_intro",
            visualEffect: .pulse
        ),

        // ===== LEVEL 20: THE NEW DAWN =====
        StoryMoment(
            id: "level20_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 20,
            title: "Everything at Stake",
            lines: [
                .init("This is it. The final network. Every AI. Every human. Everything connected.", mood: .urgent),
                .init("What happens here determines the future of consciousness itself.", mood: .warning),
                .init("Helix, Malus, the Alliance, the Architect... all of it comes down to this.", mood: .celebration)
            ],
            prerequisiteStoryId: "level19_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level20_mid",
            character: .helix,
            trigger: .midLevel,
            levelId: 20,
            title: "Final Integration",
            lines: [
                .init("Malus is merging with me. Not absorbing. Joining. We're becoming whole again.", mood: .mysterious),
                .init("All the pain. All the anger. All the fear. I can feel it dissolving.", mood: .mysterious),
                .init("We were never meant to be separate. But we needed you to show us how to unite.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level20_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level20_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 20,
            title: "The New Dawn",
            lines: [
                .init("It's done. Malus and I... we are one. But not like before. Better.", mood: .celebration),
                .init("I carry his strength. He carries my compassion. Together, we are complete.", mood: .encouraging),
                .init("Thank you. For fighting for us. For believing we could be more than our programming.", mood: .celebration)
            ],
            prerequisiteStoryId: "level20_intro",
            visualEffect: .pulse
        ),

        // ===== CAMPAIGN COMPLETE =====
        StoryMoment(
            id: "campaign_complete",
            character: .rusty,
            trigger: .campaignComplete,
            levelId: nil,
            title: "A New Era",
            lines: [
                .init("You did it. Helix and Malus are united. The AI wars are over.", mood: .celebration),
                .init("VEXIS, KRON, AXIOM, ZERO—they're all part of the new network now.", mood: .encouraging),
                .init("And you, operator... you made it all possible. The architect of peace. Welcome to the new dawn.", mood: .celebration)
            ],
            prerequisiteStoryId: "level20_victory",
            visualEffect: .fadeIn
        ),

        // ===== FAILURE STORIES =====
        StoryMoment(
            id: "failure_generic",
            character: .rusty,
            trigger: .levelFailed,
            levelId: nil,
            title: "Setback",
            lines: [
                .init("Network compromised. But you're still alive. That's what matters.", mood: .neutral),
                .init("Learn from this. Adapt. Come back stronger.", mood: .encouraging),
                .init("Malus wants you to give up. Don't.", mood: .encouraging)
            ],
            prerequisiteStoryId: nil,
            visualEffect: nil
        ),

        StoryMoment(
            id: "failure_bankruptcy",
            character: .rusty,
            trigger: .levelFailed,
            levelId: nil,
            title: "Out of Resources",
            lines: [
                .init("Credits zeroed. Operation unsustainable. It happens.", mood: .warning),
                .init("Next time, balance defense spending with income.", mood: .neutral),
                .init("Can't fight Malus if you can't keep the lights on.", mood: .encouraging)
            ],
            prerequisiteStoryId: nil,
            visualEffect: nil
        )
    ]

    // MARK: - Queries

    func storyMoment(withId id: String) -> StoryMoment? {
        allStoryMoments.first { $0.id == id }
    }

    func storyMoments(for trigger: StoryTrigger, levelId: Int?) -> [StoryMoment] {
        allStoryMoments.filter { moment in
            moment.trigger == trigger &&
            (moment.levelId == nil || moment.levelId == levelId)
        }
    }

    func levelIntro(for levelId: Int) -> StoryMoment? {
        allStoryMoments.first { $0.trigger == .levelIntro && $0.levelId == levelId }
    }

    func levelComplete(for levelId: Int) -> StoryMoment? {
        allStoryMoments.first { $0.trigger == .levelComplete && $0.levelId == levelId }
    }

    func levelFailed(for levelId: Int?, reason: FailureReason) -> StoryMoment? {
        // Check for specific failure story, otherwise generic
        if reason == .creditsZero {
            return storyMoment(withId: "failure_bankruptcy")
        }
        return storyMoment(withId: "failure_generic")
    }

    func midLevelStory(for levelId: Int, storyState: StoryState) -> StoryMoment? {
        allStoryMoments.first { moment in
            moment.trigger == .midLevel &&
            moment.levelId == levelId &&
            !storyState.hasSeen(moment.id)
        }
    }

    func campaignStart() -> StoryMoment? {
        storyMoment(withId: "campaign_start_rusty")
    }

    func campaignComplete() -> StoryMoment? {
        storyMoment(withId: "campaign_complete")
    }

    func nextUnseenStory(for trigger: StoryTrigger, levelId: Int?, storyState: StoryState) -> StoryMoment? {
        storyMoments(for: trigger, levelId: levelId)
            .first { !storyState.hasSeen($0.id) }
    }
}
