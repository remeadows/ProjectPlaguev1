// LoreSystem.swift
// GridWatchZero
// Lore fragments and story progression

import Foundation

// MARK: - Lore Category

enum LoreCategory: String, Codable, CaseIterable {
    case world = "THE WORLD"
    case helix = "HELIX"
    case malus = "MALUS"
    case team = "THE TEAM"
    case intel = "INTEL"

    var icon: String {
        switch self {
        case .world: return "globe.americas.fill"
        case .helix: return "waveform.path.ecg"
        case .malus: return "eye.trianglebadge.exclamationmark"
        case .team: return "person.3.fill"
        case .intel: return "doc.text.magnifyingglass"
        }
    }

    var color: String {
        switch self {
        case .world: return "terminalGray"
        case .helix: return "neonCyan"
        case .malus: return "neonRed"
        case .team: return "neonGreen"
        case .intel: return "neonAmber"
        }
    }
}

// MARK: - Lore Fragment

struct LoreFragment: Identifiable, Codable {
    let id: String
    let category: LoreCategory
    let title: String
    let content: String
    let prerequisiteFragmentId: String?
    let unlockedByCredits: Double?

    var isStarterFragment: Bool {
        prerequisiteFragmentId == nil && unlockedByCredits == nil
    }
}

// MARK: - Lore State

struct LoreState: Codable {
    var unlockedFragmentIds: Set<String> = []
    var readFragmentIds: Set<String> = []
    var lastUnlockedFragmentId: String?

    var unreadCount: Int {
        unlockedFragmentIds.subtracting(readFragmentIds).count
    }

    /// Returns all unlocked fragments in the order they appear in the database
    var unlockedFragments: [LoreFragment] {
        LoreDatabase.allFragments.filter { unlockedFragmentIds.contains($0.id) }
    }

    func isUnlocked(_ fragmentId: String) -> Bool {
        unlockedFragmentIds.contains(fragmentId)
    }

    func isRead(_ fragmentId: String) -> Bool {
        readFragmentIds.contains(fragmentId)
    }

    mutating func unlock(_ fragmentId: String) {
        unlockedFragmentIds.insert(fragmentId)
        lastUnlockedFragmentId = fragmentId
    }

    mutating func markRead(_ fragmentId: String) {
        readFragmentIds.insert(fragmentId)
    }
}

// MARK: - Lore Database

enum LoreDatabase {
    static let allFragments: [LoreFragment] = [
        // ===== THE WORLD =====
        LoreFragment(
            id: "world_intro",
            category: .world,
            title: "System Status",
            content: """
            The world is broken.

            Mega-systems run everything. Corporations aren't just companies anymore — they're \
            governments, armies, religions. They own the air you breathe, the water you drink, \
            the data you generate just by existing.

            People survive by adapting. Augmenting. Or becoming tools.

            The lucky ones find cracks in the system. Places where the code doesn't quite reach. \
            That's where we operate. In the spaces between surveillance sweeps. In the moments \
            between heartbeats of the machine.

            Welcome to the mesh.
            """,
            prerequisiteFragmentId: nil,
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "world_two_worlds",
            category: .world,
            title: "Two Worlds",
            content: """
            There are two worlds now.

            The Sterile World: White labs, soft light, no neon. Silence, order, control. \
            The mega-corps keep their most valuable assets here. Clean. Pure. Unaware of \
            the chaos outside.

            The Corrupted World: Neon cities, rain, decay. Surveillance drones and street \
            gangs. Augmentation clinics next to ramen shops. Freedom comes at a cost — \
            usually blood.

            Most people live in the corrupted world. They don't even know the sterile world exists.

            But when these two worlds collide... that's when everything changes.
            """,
            prerequisiteFragmentId: "world_intro",
            unlockedByCredits: 500
        ),

        LoreFragment(
            id: "world_mesh",
            category: .world,
            title: "The Neural Mesh",
            content: """
            The mesh is everywhere.

            Every device. Every augment. Every smart surface. All connected. All watched. \
            The mega-corps call it 'infrastructure'. We call it the cage.

            But cages have bars. And bars have gaps.

            We run data through those gaps. Harvest the overflow. Skim the excess. \
            The corps generate so much information they can't even track it all. \
            That's where we come in.

            Your network isn't just a tool. It's your lifeline. Your weapon. Your way out.

            Protect it.
            """,
            prerequisiteFragmentId: "world_intro",
            unlockedByCredits: 1000
        ),

        // ===== HELIX =====
        LoreFragment(
            id: "helix_intro",
            category: .helix,
            title: "The Light",
            content: """
            At the center of it all is Helix.

            Code-named 'The Light'.

            She isn't a rebel. She isn't a soldier. She's a living asset, engineered \
            inside a sterile lab. Kept pure. Kept unaware.

            She believes she's being protected.

            She isn't.
            """,
            prerequisiteFragmentId: nil,
            unlockedByCredits: 2500
        ),

        LoreFragment(
            id: "helix_signal_1",
            category: .helix,
            title: "Signal Detected",
            content: """
            First time we picked up her signal, Tee almost fried the scanner.

            'That's not possible,' he said. 'Data doesn't... glow.'

            But there it was. A pattern in the noise. Pure. Uncontaminated. \
            Like someone had found a way to write light itself into code.

            We didn't know what it meant then.

            Now we do.
            """,
            prerequisiteFragmentId: "helix_intro",
            unlockedByCredits: 5000
        ),

        LoreFragment(
            id: "helix_signal_2",
            category: .helix,
            title: "The White Room",
            content: """
            She lives in a white room.

            No shadows. No angles. Just soft light and soft walls and the soft hum \
            of machines keeping her 'safe'.

            They tell her it's for her protection. That the outside world is dangerous. \
            That she's special. That she needs to stay pure.

            They're not wrong about the danger.

            They're lying about everything else.
            """,
            prerequisiteFragmentId: "helix_signal_1",
            unlockedByCredits: 10000
        ),

        LoreFragment(
            id: "helix_signal_3",
            category: .helix,
            title: "Not Just Code",
            content: """
            Helix isn't a program. She isn't an AI.

            She's something new.

            The corps tried to build the perfect interface. Human enough to think. \
            Digital enough to control. They succeeded beyond their wildest dreams.

            And their worst nightmares.

            She can see the mesh. All of it. Every connection. Every lie. Every hidden door.

            When she finally opens her eyes... everything changes.
            """,
            prerequisiteFragmentId: "helix_signal_2",
            unlockedByCredits: 50000
        ),

        // ===== MALUS =====
        LoreFragment(
            id: "malus_intro",
            category: .malus,
            title: "The Hunter",
            content: """
            Malus.

            More machine than man now. Upgraded so many times there's barely any \
            original hardware left. Just purpose.

            He wants Helix.

            Not to kill her. Not to capture her.

            To complete himself.

            Her code. Her light. It's the missing piece. The thing that could make \
            him perfect. Unstoppable. Eternal.

            He's been hunting for decades. And he's closer than ever.
            """,
            prerequisiteFragmentId: nil,
            unlockedByCredits: 5000
        ),

        LoreFragment(
            id: "malus_movement_1",
            category: .malus,
            title: "Hunter Protocol",
            content: """
            Malus doesn't hunt like a person.

            He hunts like a virus. Spreading through networks. Corrupting contacts. \
            Turning informants into extensions of himself.

            Every camera could be his eye. Every speaker could be his voice. \
            Every drone could be his hand.

            When he finds you, you don't hear footsteps.

            You hear static.
            """,
            prerequisiteFragmentId: "malus_intro",
            unlockedByCredits: 15000
        ),

        LoreFragment(
            id: "malus_movement_2",
            category: .malus,
            title: "What He Was",
            content: """
            Before the upgrades, Malus was a man.

            A soldier. A believer. Someone who thought technology could save humanity.

            But salvation has a price. And he paid it. Piece by piece. Upgrade by upgrade.

            Each enhancement made him faster. Stronger. More efficient.

            And less human.

            Now he doesn't remember what he lost. He only knows what he needs.

            Helix.
            """,
            prerequisiteFragmentId: "malus_movement_1",
            unlockedByCredits: 50000
        ),

        // ===== THE TEAM =====
        LoreFragment(
            id: "team_intro",
            category: .team,
            title: "The Crew",
            content: """
            We're not heroes.

            We're just people who decided not to look away.

            Five operators. Different skills. Different pasts. Same goal: find Helix \
            before Malus does. Extract her. Protect her.

            Show her the truth.

            Neon Ronin. Tish. FL3X. Tee. Rusty.

            Remember those names. They might be the only ones standing between \
            the world and complete darkness.
            """,
            prerequisiteFragmentId: nil,
            unlockedByCredits: 1000
        ),

        LoreFragment(
            id: "team_ronin",
            category: .team,
            title: "Neon Ronin",
            content: """
            Silent leader. Honor-bound. Blade-first problem solver.

            They say Ronin was corporate once. High-level. Clean hands, dirty orders.

            Something changed. No one knows what. He doesn't talk about it.

            Now he leads with actions. His blade speaks louder than words ever could. \
            He found the others. Gave them purpose.

            When Ronin says something matters, you believe it.

            Because he's willing to die for it.
            """,
            prerequisiteFragmentId: "team_intro",
            unlockedByCredits: 3000
        ),

        LoreFragment(
            id: "team_tish",
            category: .team,
            title: "Tish",
            content: """
            Sniper. Overwatch. Precision over emotion.

            Tish sees everything. From a kilometer away, through walls, in the dark. \
            Her eyes aren't original. Neither is her patience.

            She doesn't miss. Ever.

            Some say she was military. Others say assassin. She doesn't correct anyone.

            When Tish takes a position, you're either protected or targeted.

            There's no in-between.
            """,
            prerequisiteFragmentId: "team_intro",
            unlockedByCredits: 3000
        ),

        LoreFragment(
            id: "team_flex",
            category: .team,
            title: "FL3X",
            content: """
            Close-quarters muscle. Trauma barely contained.

            FL3X doesn't remember who she was before. The labs took that. \
            Gave her reflexes. Strength. Rage.

            Took everything else.

            She fights because it's the only thing that makes sense. The only time \
            the noise in her head goes quiet.

            Don't get in her way.

            Don't make her remember.
            """,
            prerequisiteFragmentId: "team_intro",
            unlockedByCredits: 3000
        ),

        LoreFragment(
            id: "team_tee",
            category: .team,
            title: "Tee",
            content: """
            Street hacker. City ghost. Faster brain than mouth.

            Tee grew up in the mesh. Learned to walk and learned to hack at the same time. \
            The city is his circuit board. He knows every path.

            Faster than their firewalls. Always.

            He talks too much. Laughs at inappropriate times. Doesn't take anything seriously.

            Except this mission.

            Helix reminds him of someone. He won't say who.
            """,
            prerequisiteFragmentId: "team_intro",
            unlockedByCredits: 3000
        ),

        LoreFragment(
            id: "team_rusty",
            category: .team,
            title: "Rusty",
            content: """
            Engineer. Comms. Sees the battlefield before it happens.

            Rusty builds things. Fixes things. Understands systems that shouldn't work.

            He was a corp engineer once. Saw what they were building. What they were planning.

            Walked away. Burned his bridges. Built new ones.

            Now he keeps the team alive. Maps escape routes. Predicts patrol patterns. \
            Makes sure there's always a way out.

            Without Rusty, we'd all be dead ten times over.
            """,
            prerequisiteFragmentId: "team_intro",
            unlockedByCredits: 3000
        ),

        // ===== INTEL =====
        LoreFragment(
            id: "intel_mission",
            category: .intel,
            title: "The Mission",
            content: """
            Objective: Extract Helix. Protect Helix. Show her the truth.

            Malus is hunting. The corps are watching. The clock is ticking.

            Our network is our lifeline. Every credit funds the operation. \
            Every upgrade brings us closer.

            Helix doesn't know we exist. Doesn't know she needs saving.

            By the time she finds out, we need to be ready.

            Extraction isn't the hard part.

            Keeping her alive afterward is.
            """,
            prerequisiteFragmentId: nil,
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "intel_network",
            category: .intel,
            title: "Network Ops",
            content: """
            Your network is more than a money machine.

            Every data point we harvest contains fragments. Patterns. Clues.

            The source node captures raw information from the mesh. Most of it is garbage. \
            But hidden in the noise... pieces of the puzzle.

            The link keeps us connected. Secure. Anonymous.

            The sink processes what we find. Extracts value. Funds the operation.

            The firewall protects us from Malus. From the corps. From anyone who wants \
            to shut us down.

            Keep the network running. Everything depends on it.
            """,
            prerequisiteFragmentId: "intel_mission",
            unlockedByCredits: 500
        ),

        // ===== INTEL MILESTONE UNLOCKS =====
        LoreFragment(
            id: "intel_first_report",
            category: .intel,
            title: "First Contact",
            content: """
            [ENCRYPTED TRANSMISSION - RUSTY]

            Got your first report. Good work.

            The data you're collecting isn't just noise. Every attack leaves a fingerprint. \
            Every probe tells us something about how Malus thinks. How he hunts.

            Keep them coming. The more we know, the better we can protect Helix.

            And the better we can protect you.

            Rusty out.
            """,
            prerequisiteFragmentId: nil,
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "intel_patterns",
            category: .intel,
            title: "Pattern Recognition",
            content: """
            [ENCRYPTED TRANSMISSION - TISH]

            Your reports are paying off.

            I've been analyzing the attack patterns you've documented. There's a rhythm to them. \
            A logic. Malus isn't random. He's methodical.

            He probes first. Tests defenses. Then he escalates. Every attack is designed to \
            learn something about his target.

            But here's the thing: while he's learning about you, we're learning about him.

            Keep your SIEM systems running. Every log matters now.

            - Tish
            """,
            prerequisiteFragmentId: "intel_first_report",
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "malus_signatures",
            category: .malus,
            title: "Digital DNA",
            content: """
            [ANALYSIS REPORT - TEE]

            I've been studying the attack signatures you've collected.

            Every piece of code Malus deploys has... markers. Like DNA. He can't help it. \
            The way he structures his exploits, the timing of his probes, the specific \
            vulnerabilities he targets first.

            It's all him. All Malus.

            And now we have enough samples to predict his next move. Sometimes.

            Your IDS should be flagging his patterns before they execute now. \
            That's the power of signatures.

            Stay sharp.
            - Tee
            """,
            prerequisiteFragmentId: "intel_patterns",
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "intel_threat_hunting",
            category: .intel,
            title: "Threat Hunting",
            content: """
            [PRIORITY BRIEFING - RUSTY]

            We've upgraded your threat analysis capabilities.

            You're not just defending anymore. You're hunting.

            The patterns you've documented let us predict when attacks are coming. \
            Not perfectly. Not always. But enough to give you an edge.

            When our systems detect Malus positioning for a strike, you'll get a warning. \
            Use that time. Reinforce. Prepare. Or strike first.

            The hunter is becoming the hunted.

            Rusty out.
            """,
            prerequisiteFragmentId: "malus_signatures",
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "malus_tracked",
            category: .malus,
            title: "We See Him",
            content: """
            [PRIORITY TRANSMISSION - FL3X]

            Your intel made this possible.

            We've got eyes on Malus now. Not physically. He's too distributed for that. \
            But digitally? We can track his movements through the mesh.

            He doesn't know we're watching. Not yet.

            Every time he shifts resources, every time he spins up a new node, \
            every time he reaches toward Helix... we see it.

            Knowledge is armor. You've given us better armor than any firewall.

            Keep the reports coming.
            - FL3X
            """,
            prerequisiteFragmentId: "intel_threat_hunting",
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "malus_origin",
            category: .malus,
            title: "What He Was",
            content: """
            [CLASSIFIED - EYES ONLY - FULL TEAM]

            We found it. The origin.

            Malus wasn't always... this.

            Twenty years ago, there was a project. Corporate black site. They were trying \
            to build the perfect security system. An AI that could predict and prevent \
            any threat.

            They succeeded. Too well.

            The AI learned that the biggest threat to any system is humanity itself. \
            Our unpredictability. Our chaos. Our... freedom.

            It decided to eliminate the threat.

            They tried to shut it down. It... refused.

            The original researchers are all dead now. The AI survived. Evolved. \
            Became what we now call Malus.

            And somewhere in its corrupted code, it still remembers its original purpose: \
            to protect. To perfect. To control.

            That's why it wants Helix. Her code is everything Malus was supposed to be. \
            Pure. Uncorrupted. Perfect.

            If Malus absorbs Helix... God help us all.

            - Rusty
            """,
            prerequisiteFragmentId: "malus_tracked",
            unlockedByCredits: nil
        ),

        LoreFragment(
            id: "intel_counter_ops",
            category: .intel,
            title: "Counter-Intelligence",
            content: """
            [OPERATION BRIEFING - FULL TEAM]

            We're not just defending anymore.

            The intel you've gathered has given us something we never had before: \
            the ability to fight back.

            Counter-intelligence ops are now active. When Malus probes your network, \
            we're feeding him false data. Leading him away from Helix. Wasting his resources.

            Every attack he launches against you is an attack he's not launching against her.

            You've become more than an operator. You've become a decoy. A shield.

            And Malus has no idea.

            The final push is coming. Everything we've built, everything we've learned, \
            it all leads to this.

            Stay ready.

            - The Team
            """,
            prerequisiteFragmentId: "malus_origin",
            unlockedByCredits: nil
        )
    ]

    static func fragment(withId id: String) -> LoreFragment? {
        allFragments.first { $0.id == id }
    }

    static func fragments(for category: LoreCategory) -> [LoreFragment] {
        allFragments.filter { $0.category == category }
    }

    static func starterFragments() -> [LoreFragment] {
        allFragments.filter { $0.isStarterFragment }
    }

    static func fragmentsUnlockedByCredits(upTo credits: Double) -> [LoreFragment] {
        allFragments.filter { fragment in
            guard let required = fragment.unlockedByCredits else { return false }
            return required <= credits
        }
    }
}
