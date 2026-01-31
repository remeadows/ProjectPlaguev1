// EventSystem.swift
// GridWatchZero
// Random events that occur during gameplay

import Foundation

// MARK: - Random Event Types

enum RandomEventType: String, Codable, CaseIterable {
    // Positive events
    case dataSurge          // Temporary boost to source output
    case clearChannel       // Temporary bandwidth boost
    case marketSpike        // Temporary credit multiplier
    case luckyFind          // Instant credit bonus
    case shadowContact      // Team member intel

    // Negative events
    case networkGlitch      // Temporary source reduction
    case congestion         // Temporary bandwidth reduction
    case marketCrash        // Temporary credit penalty
    case dataCorruption     // Lose some buffered data

    // Neutral/Story events
    case cityWhisper        // Lore fragment hint
    case malusMovement      // Malus sighting
    case teamComms          // Team chatter
    case helixSignal        // Helix-related event

    var isPositive: Bool {
        switch self {
        case .dataSurge, .clearChannel, .marketSpike, .luckyFind, .shadowContact:
            return true
        case .networkGlitch, .congestion, .marketCrash, .dataCorruption:
            return false
        case .cityWhisper, .malusMovement, .teamComms, .helixSignal:
            return true // Neutral but valuable
        }
    }

    var icon: String {
        switch self {
        case .dataSurge: return "bolt.fill"
        case .clearChannel: return "arrow.up.arrow.down"
        case .marketSpike: return "chart.line.uptrend.xyaxis"
        case .luckyFind: return "sparkles"
        case .shadowContact: return "person.fill.questionmark"
        case .networkGlitch: return "exclamationmark.triangle"
        case .congestion: return "tortoise.fill"
        case .marketCrash: return "chart.line.downtrend.xyaxis"
        case .dataCorruption: return "xmark.octagon"
        case .cityWhisper: return "ear.fill"
        case .malusMovement: return "eye.fill"
        case .teamComms: return "antenna.radiowaves.left.and.right"
        case .helixSignal: return "waveform.path.ecg"
        }
    }
}

// MARK: - Random Event

struct RandomEvent: Identifiable, Codable {
    let id: UUID
    let type: RandomEventType
    let title: String
    let message: String
    let effect: EventEffect
    let triggeredAtTick: Int
    var expiresAtTick: Int?
    var isActive: Bool

    init(
        id: UUID = UUID(),
        type: RandomEventType,
        title: String,
        message: String,
        effect: EventEffect,
        triggeredAtTick: Int,
        duration: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.effect = effect
        self.triggeredAtTick = triggeredAtTick
        self.expiresAtTick = duration.map { triggeredAtTick + $0 }
        self.isActive = true
    }

    var remainingTicks: Int? {
        guard let expires = expiresAtTick else { return nil }
        return max(0, expires - triggeredAtTick)
    }
}

// MARK: - Event Effects

struct EventEffect: Codable {
    var sourceMultiplier: Double = 1.0      // Multiply source output
    var bandwidthMultiplier: Double = 1.0   // Multiply link bandwidth
    var creditMultiplier: Double = 1.0      // Multiply credits earned
    var instantCredits: Double = 0          // One-time credit bonus
    var dataLoss: Double = 0                // Lose buffered data
    var loreFragmentId: String? = nil       // Unlock lore fragment
    var teamMemberId: String? = nil         // Team member event

    static let none = EventEffect()

    static func sourceBoost(_ multiplier: Double) -> EventEffect {
        var effect = EventEffect()
        effect.sourceMultiplier = multiplier
        return effect
    }

    static func bandwidthBoost(_ multiplier: Double) -> EventEffect {
        var effect = EventEffect()
        effect.bandwidthMultiplier = multiplier
        return effect
    }

    static func creditBoost(_ multiplier: Double) -> EventEffect {
        var effect = EventEffect()
        effect.creditMultiplier = multiplier
        return effect
    }

    static func instantBonus(_ amount: Double) -> EventEffect {
        var effect = EventEffect()
        effect.instantCredits = amount
        return effect
    }

    static func loreUnlock(_ fragmentId: String) -> EventEffect {
        var effect = EventEffect()
        effect.loreFragmentId = fragmentId
        return effect
    }
}

// MARK: - Event Generator

enum EventGenerator {
    // Base chance per tick (modified by threat level)
    private static let baseEventChance: Double = 0.02 // 2% per tick

    static func tryGenerateEvent(
        threatLevel: ThreatLevel,
        currentTick: Int,
        totalCredits: Double,
        random: inout some RandomNumberGenerator
    ) -> RandomEvent? {
        // Chance increases slightly with threat level
        let chanceMultiplier = 1.0 + (Double(threatLevel.rawValue) * 0.1)
        let chance = baseEventChance * chanceMultiplier

        guard Double.random(in: 0...1, using: &random) < chance else {
            return nil
        }

        // Weight event types based on threat level
        let eventType = selectEventType(threatLevel: threatLevel, random: &random)
        return createEvent(type: eventType, tick: currentTick, credits: totalCredits, random: &random)
    }

    private static func selectEventType(
        threatLevel: ThreatLevel,
        random: inout some RandomNumberGenerator
    ) -> RandomEventType {
        // Higher threat = more negative events, more story events
        // storyWeight is implicitly (1 - positiveWeight - negativeWeight) and is documented here for clarity
        let positiveWeight: Double
        let negativeWeight: Double

        switch threatLevel {
        case .ghost, .blip:
            positiveWeight = 0.6
            negativeWeight = 0.2
            // storyWeight = 0.2
        case .signal, .target:
            positiveWeight = 0.4
            negativeWeight = 0.35
            // storyWeight = 0.25
        case .priority, .hunted:
            positiveWeight = 0.3
            negativeWeight = 0.4
            // storyWeight = 0.3
        case .marked, .targeted, .hammered, .critical:
            positiveWeight = 0.2
            negativeWeight = 0.45
            // storyWeight = 0.35
        // Endgame threat levels (T7+) - more story events, very challenging
        case .ascended, .symbiont, .transcendent:
            positiveWeight = 0.15
            negativeWeight = 0.5
            // storyWeight = 0.35
        case .unknown, .dimensional, .cosmic:
            positiveWeight = 0.1
            negativeWeight = 0.55
            // storyWeight = 0.35
        case .paradox, .primordial, .infinite, .omega:
            positiveWeight = 0.05
            negativeWeight = 0.6
            // storyWeight = 0.35
        }

        let roll = Double.random(in: 0...1, using: &random)

        if roll < positiveWeight {
            let positiveTypes: [RandomEventType] = [.dataSurge, .clearChannel, .marketSpike, .luckyFind, .shadowContact]
            return positiveTypes.randomElement(using: &random)!
        } else if roll < positiveWeight + negativeWeight {
            let negativeTypes: [RandomEventType] = [.networkGlitch, .congestion, .marketCrash, .dataCorruption]
            return negativeTypes.randomElement(using: &random)!
        } else {
            let storyTypes: [RandomEventType] = [.cityWhisper, .malusMovement, .teamComms, .helixSignal]
            return storyTypes.randomElement(using: &random)!
        }
    }

    private static func createEvent(
        type: RandomEventType,
        tick: Int,
        credits: Double,
        random: inout some RandomNumberGenerator
    ) -> RandomEvent {
        switch type {
        // Positive events
        case .dataSurge:
            return RandomEvent(
                type: type,
                title: "DATA SURGE",
                message: dataSurgeMessages.randomElement(using: &random)!,
                effect: .sourceBoost(1.5),
                triggeredAtTick: tick,
                duration: 30
            )

        case .clearChannel:
            return RandomEvent(
                type: type,
                title: "CLEAR CHANNEL",
                message: clearChannelMessages.randomElement(using: &random)!,
                effect: .bandwidthBoost(1.75),
                triggeredAtTick: tick,
                duration: 25
            )

        case .marketSpike:
            return RandomEvent(
                type: type,
                title: "MARKET SPIKE",
                message: marketSpikeMessages.randomElement(using: &random)!,
                effect: .creditBoost(2.0),
                triggeredAtTick: tick,
                duration: 20
            )

        case .luckyFind:
            let bonus = max(50, credits * 0.1) // 10% of current credits or 50 minimum
            return RandomEvent(
                type: type,
                title: "LUCKY FIND",
                message: luckyFindMessages.randomElement(using: &random)!,
                effect: .instantBonus(bonus),
                triggeredAtTick: tick
            )

        case .shadowContact:
            return RandomEvent(
                type: type,
                title: "SHADOW CONTACT",
                message: shadowContactMessages.randomElement(using: &random)!,
                effect: .loreUnlock("contact_\(Int.random(in: 1...5, using: &random))"),
                triggeredAtTick: tick
            )

        // Negative events
        case .networkGlitch:
            return RandomEvent(
                type: type,
                title: "NETWORK GLITCH",
                message: networkGlitchMessages.randomElement(using: &random)!,
                effect: .sourceBoost(0.5),
                triggeredAtTick: tick,
                duration: 15
            )

        case .congestion:
            return RandomEvent(
                type: type,
                title: "CONGESTION",
                message: congestionMessages.randomElement(using: &random)!,
                effect: .bandwidthBoost(0.5),
                triggeredAtTick: tick,
                duration: 20
            )

        case .marketCrash:
            return RandomEvent(
                type: type,
                title: "MARKET CRASH",
                message: marketCrashMessages.randomElement(using: &random)!,
                effect: .creditBoost(0.5),
                triggeredAtTick: tick,
                duration: 15
            )

        case .dataCorruption:
            var effect = EventEffect()
            effect.dataLoss = 0.25 // Lose 25% of buffer
            return RandomEvent(
                type: type,
                title: "DATA CORRUPTION",
                message: dataCorruptionMessages.randomElement(using: &random)!,
                effect: effect,
                triggeredAtTick: tick
            )

        // Story events
        case .cityWhisper:
            return RandomEvent(
                type: type,
                title: "CITY WHISPER",
                message: cityWhisperMessages.randomElement(using: &random)!,
                effect: .loreUnlock("whisper_\(Int.random(in: 1...10, using: &random))"),
                triggeredAtTick: tick
            )

        case .malusMovement:
            return RandomEvent(
                type: type,
                title: "MALUS MOVEMENT",
                message: malusMovementMessages.randomElement(using: &random)!,
                effect: .loreUnlock("malus_\(Int.random(in: 1...8, using: &random))"),
                triggeredAtTick: tick
            )

        case .teamComms:
            let teamMembers = ["ronin", "tish", "flex", "tee", "rusty"]
            let member = teamMembers.randomElement(using: &random)!
            return RandomEvent(
                type: type,
                title: "TEAM COMMS",
                message: teamCommsMessages[member]?.randomElement(using: &random) ?? "> Signal lost.",
                effect: .loreUnlock("team_\(member)_\(Int.random(in: 1...3, using: &random))"),
                triggeredAtTick: tick
            )

        case .helixSignal:
            return RandomEvent(
                type: type,
                title: "HELIX SIGNAL",
                message: helixSignalMessages.randomElement(using: &random)!,
                effect: .loreUnlock("helix_\(Int.random(in: 1...6, using: &random))"),
                triggeredAtTick: tick
            )
        }
    }

    // MARK: - Message Banks

    private static let dataSurgeMessages = [
        "> Corporate firewall breach detected. Data flooding in.",
        "> Public mesh overloaded. Harvesting excess packets.",
        "> Traffic spike from downtown sector. Capitalizing.",
        "> Someone's moving big data tonight. Skimming the overflow.",
        "> Mega-system backup routine. Easy pickings."
    ]

    private static let clearChannelMessages = [
        "> Patrol drones offline for maintenance. Clear sailing.",
        "> Night shift skeleton crew. Bandwidth opening up.",
        "> Corporate node rerouting. Borrowed their tunnel.",
        "> Storm knocked out competing traffic. Lane's open.",
        "> Tee found a back door. Riding it while we can."
    ]

    private static let marketSpikeMessages = [
        "> Black market demand surge. Premium rates.",
        "> Corp bidding war for fresh data. Cash in.",
        "> Shadow Market contact paying double. Don't ask why.",
        "> Competing broker went dark. We're the only game.",
        "> Rare data type detected. Buyers are hungry."
    ]

    private static let luckyFindMessages = [
        "> Found a dead drop. Someone's loss, our gain.",
        "> Encrypted wallet cracked. Credits transferred.",
        "> Anonymous tip paid out. No questions.",
        "> Bounty cleared on old job. Forgot about that one.",
        "> Data cache sold. Didn't even remember having it."
    ]

    private static let shadowContactMessages = [
        "> Rusty's contact came through. Intel incoming.",
        "> Street-level source pinged us. New lead.",
        "> Anonymous informant. Could be useful, could be a trap.",
        "> Tee's network picked up chatter. Decrypting.",
        "> Old debt being repaid. Information as currency."
    ]

    private static let networkGlitchMessages = [
        "> Source node flickering. Interference detected.",
        "> Packet loss spiking. Something's wrong.",
        "> Hardware degradation. Running at half capacity.",
        "> Signal contamination. Filtering noise.",
        "> Power fluctuation. Riding it out."
    ]

    private static let congestionMessages = [
        "> Traffic jam in the mesh. Everyone's online tonight.",
        "> Bandwidth throttled. Someone's watching.",
        "> Competing signals flooding the channel.",
        "> Patrol activity increased. Laying low.",
        "> Mega-system running diagnostics. Bottleneck."
    ]

    private static let marketCrashMessages = [
        "> Buyer went dark. Rates plummeting.",
        "> Market flooded with cheap data. Prices crashed.",
        "> Shadow Market raid. Everyone's spooked.",
        "> Trust network compromised. Deals on hold.",
        "> Economic lockdown. Credits frozen briefly."
    ]

    private static let dataCorruptionMessages = [
        "> Buffer overflow. Some data didn't make it.",
        "> Malicious packet slipped through. Purging.",
        "> Encryption mismatch. Data lost in translation.",
        "> Hardware fault. Sector wiped.",
        "> Cascade failure. Salvaging what we can."
    ]

    private static let cityWhisperMessages = [
        "> They say something's moving in the white tower...",
        "> Street rats talking about a 'pure one'. Helix?",
        "> Rumors of a corp asset. Valuable. Protected.",
        "> The slums know things. They're scared of something new.",
        "> Whispers about Project Helix. It's not just code.",
        "> Old hackers going quiet. Something's coming.",
        "> The neon district's buzzing. New player in town.",
        "> Underground's talking about 'The Light'. Mean anything?",
        "> Someone's been asking questions. About us.",
        "> The city remembers. And it's starting to talk."
    ]

    private static let malusMovementMessages = [
        "> Malus spotted in Sector 7. He's hunting.",
        "> Cybernetic signature detected. It's him.",
        "> Hunter protocols active. Malus is close.",
        "> Surveillance footage scrubbed. Malus was here.",
        "> His drones are everywhere tonight. Stay sharp.",
        "> Malus interrogated a contact. They didn't survive.",
        "> He's not just hunting. He's building something.",
        "> Network intrusion matches his pattern. He knows we're here."
    ]

    private static let teamCommsMessages: [String: [String]] = [
        "ronin": [
            "> [RONIN] Movement in the perimeter. Eyes open.",
            "> [RONIN] Honor isn't dead. It's just expensive.",
            "> [RONIN] The blade remembers what the mind forgets."
        ],
        "tish": [
            "> [TISH] I see everything. Trust me.",
            "> [TISH] Three targets. Two exits. One solution.",
            "> [TISH] Overwatch established. You're clear."
        ],
        "flex": [
            "> [FL3X] Some problems need a direct approach.",
            "> [FL3X] They stopped running. Their mistake.",
            "> [FL3X] I don't forget. I can't."
        ],
        "tee": [
            "> [TEE] Found a backdoor. Also found their secrets.",
            "> [TEE] City's a circuit board. I know every path.",
            "> [TEE] Faster than their firewalls. Always."
        ],
        "rusty": [
            "> [RUSTY] Already mapped three escape routes.",
            "> [RUSTY] Hardware's holding. Barely.",
            "> [RUSTY] I see the battlefield before it exists."
        ]
    ]

    private static let helixSignalMessages = [
        "> Anomalous signal detected. Pure. Uncontaminated.",
        "> She's not just code. She's something else.",
        "> The white room can't hold her forever.",
        "> Helix fragment detected in the data stream.",
        "> Her signal is... beautiful. And terrifying.",
        "> She doesn't know what she is. Not yet."
    ]
}
