// GameEngine.swift
// GridWatchZero
// Core game loop and tick processing

import Foundation
import Combine

// MARK: - Tick Statistics

/// Stats from a single tick for UI display
struct TickStats {
    var dataGenerated: Double = 0
    var dataTransferred: Double = 0
    var dataDropped: Double = 0
    var creditsEarned: Double = 0
    var creditsDrained: Double = 0
    var damageAbsorbed: Double = 0
    var bufferUtilization: Double = 0

    var dropRate: Double {
        guard dataGenerated > 0 else { return 0 }
        return dataDropped / dataGenerated
    }

    var netCredits: Double {
        creditsEarned - creditsDrained
    }
}

// MARK: - Game Event

enum GameEvent: Equatable {
    case attackStarted(AttackType)
    case attackEnded(AttackType, survived: Bool)
    case threatLevelIncreased(ThreatLevel)
    case nodeDisabled(String)
    case malusMessage(String)
    case milestone(String)
    case unitUnlocked(String)
    case firewallDamaged(Double)
    case firewallDestroyed
    case randomEvent(String, String)  // title, message
    case loreUnlocked(String)  // fragment title
    case milestoneCompleted(String)  // milestone title

    var isAlert: Bool {
        switch self {
        case .attackStarted, .nodeDisabled, .malusMessage, .firewallDestroyed:
            return true
        default:
            return false
        }
    }

    var isPositive: Bool {
        switch self {
        case .milestone, .unitUnlocked, .loreUnlocked, .milestoneCompleted:
            return true
        case .randomEvent(let title, _):
            return !title.contains("GLITCH") && !title.contains("CRASH") && !title.contains("CORRUPTION") && !title.contains("CONGESTION")
        default:
            return false
        }
    }
}

// MARK: - Offline Progress

/// Represents earnings calculated while the player was away
struct OfflineProgress: Equatable {
    let secondsAway: Int
    let ticksSimulated: Int
    let creditsEarned: Double
    let dataProcessed: Double

    var formattedTimeAway: String {
        if secondsAway < 60 {
            return "\(secondsAway) seconds"
        } else if secondsAway < 3600 {
            let minutes = secondsAway / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else if secondsAway < 86400 {
            let hours = secondsAway / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            let days = secondsAway / 86400
            return "\(days) day\(days == 1 ? "" : "s")"
        }
    }
}

// MARK: - Unlock State

struct UnlockState: Codable {
    var unlockedUnitIds: Set<String> = [
        "source_t1_mesh_sniffer",
        "link_t1_copper_vpn",
        "sink_t1_data_broker"
    ]

    func isUnlocked(_ unitId: String) -> Bool {
        unlockedUnitIds.contains(unitId)
    }

    mutating func unlock(_ unitId: String) {
        unlockedUnitIds.insert(unitId)
    }
}

// MARK: - Prestige State

/// Tracks prestige ("Network Wipe") progress and bonuses
struct PrestigeState: Codable {
    /// Number of times the player has prestiged
    var prestigeLevel: Int = 0

    /// Total helix cores earned across all runs
    var totalHelixCores: Int = 0

    /// Currently available helix cores to spend
    var availableHelixCores: Int = 0

    /// Permanent production multiplier from prestige
    var productionMultiplier: Double {
        1.0 + (Double(prestigeLevel) * 0.1) + (Double(totalHelixCores) * 0.05)
    }

    /// Permanent credit multiplier from prestige
    var creditMultiplier: Double {
        1.0 + (Double(prestigeLevel) * 0.15)
    }

    /// Credits required for next prestige
    static func creditsRequiredForPrestige(level: Int) -> Double {
        // Exponential scaling: 150K, 750K, 3.75M, 18.75M...
        // Increased base from 100K to 150K to encourage T3 exploration
        return 150_000 * pow(5.0, Double(level))
    }

    /// Helix cores earned from a prestige with given total credits
    static func helixCoresEarned(fromCredits credits: Double, atLevel level: Int) -> Int {
        let required = creditsRequiredForPrestige(level: level)
        let ratio = credits / required
        // Base 1 core + 1 per 2x the requirement
        return max(1, Int(ratio / 2) + 1)
    }
}

// MARK: - Game State

/// Complete game state for saving/loading
struct GameState: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?
    var defenseStack: DefenseStack
    var malusIntel: MalusIntelligence
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
    var loreState: LoreState
    var milestoneState: MilestoneState
    var prestigeState: PrestigeState
    var lastSaveTimestamp: Date?  // For offline progress calculation
    var criticalAlarmAcknowledged: Bool  // Whether user dismissed critical alarm

    static func newGame(prestigeState: PrestigeState = PrestigeState()) -> GameState {
        var loreState = LoreState()
        // Unlock starter lore fragments
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: PlayerResources(),
            source: UnitFactory.createPublicMeshSniffer(),
            link: UnitFactory.createCopperVPNTunnel(),
            sink: UnitFactory.createDataBroker(),
            firewall: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: 0,
            totalPlayTime: 0,
            threatState: ThreatState(),
            unlockState: UnlockState(),
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: prestigeState,
            criticalAlarmAcknowledged: false
        )
    }
}

// MARK: - Game Engine

@MainActor
final class GameEngine: ObservableObject {
    // MARK: - Published State

    @Published private(set) var resources: PlayerResources
    @Published private(set) var source: SourceNode
    @Published private(set) var link: TransportLink
    @Published private(set) var sink: SinkNode
    @Published private(set) var firewall: FirewallNode?

    @Published private(set) var currentTick: Int = 0
    @Published private(set) var lastTickStats: TickStats = TickStats()
    @Published private(set) var isRunning: Bool = false

    // MARK: - Threat System

    @Published private(set) var threatState: ThreatState = ThreatState()
    @Published private(set) var activeAttack: Attack? = nil
    @Published private(set) var lastEvent: GameEvent? = nil

    // MARK: - Unlock System

    @Published private(set) var unlockState: UnlockState = UnlockState()

    // MARK: - Event & Story Systems

    @Published private(set) var loreState: LoreState = LoreState()
    @Published private(set) var milestoneState: MilestoneState = MilestoneState()
    @Published private(set) var activeRandomEvent: RandomEvent? = nil
    @Published private(set) var offlineProgress: OfflineProgress? = nil

    // MARK: - Prestige System

    @Published private(set) var prestigeState: PrestigeState = PrestigeState()

    // MARK: - Defense Stack & Malus Intel

    @Published private(set) var defenseStack: DefenseStack = DefenseStack()
    @Published private(set) var malusIntel: MalusIntelligence = MalusIntelligence()
    @Published private(set) var showCriticalAlarm: Bool = false
    @Published private(set) var criticalAlarmAcknowledged: Bool = false

    // MARK: - Event Multipliers (from random events)

    private var sourceMultiplier: Double = 1.0
    private var bandwidthMultiplier: Double = 1.0
    private var creditMultiplier: Double = 1.0

    // MARK: - Temporary Debuffs (from attacks)

    private var bandwidthDebuff: Double = 0  // 0.0 - 1.0 reduction

    // MARK: - Cumulative Stats

    @Published private(set) var totalDataGenerated: Double = 0
    @Published private(set) var totalDataTransferred: Double = 0
    @Published private(set) var totalDataDropped: Double = 0

    // MARK: - Campaign Mode

    @Published private(set) var levelConfiguration: LevelConfiguration?
    @Published private(set) var levelStartTick: Int = 0
    @Published private(set) var levelCreditsEarned: Double = 0
    @Published private(set) var levelAttacksSurvived: Int = 0
    @Published private(set) var levelDamageBlocked: Double = 0

    /// Callback when level is completed
    var onLevelComplete: ((LevelCompletionStats) -> Void)?

    /// Callback when level is failed
    var onLevelFailed: ((FailureReason) -> Void)?

    /// Callback when a unit is unlocked (for campaign persistence)
    var onUnitUnlocked: ((String) -> Void)?

    /// Whether we're in campaign mode
    var isInCampaignMode: Bool { levelConfiguration != nil }

    /// Maximum tier available in current level (6 if sandbox/endless mode)
    var maxTierAvailable: Int {
        levelConfiguration?.level.availableTiers.max() ?? 6
    }

    // MARK: - Private

    private var tickTimer: AnyCancellable?
    private let tickInterval: TimeInterval = 1.0
    private var totalPlayTime: TimeInterval = 0
    private var rng: RandomNumberGenerator = SystemRandomNumberGenerator()

    // MARK: - Persistence

    private var saveKey: String { SaveVersion.current.saveKey }

    // MARK: - Init

    init() {
        // Start with default new game state
        let state = GameState.newGame()
        self.resources = state.resources
        self.source = state.source
        self.link = state.link
        self.sink = state.sink
        self.firewall = state.firewall
        self.defenseStack = state.defenseStack
        self.malusIntel = state.malusIntel
        self.currentTick = state.currentTick
        self.totalPlayTime = state.totalPlayTime
        self.threatState = state.threatState
        self.unlockState = state.unlockState
        self.loreState = state.loreState
        self.milestoneState = state.milestoneState
        self.prestigeState = state.prestigeState
        self.criticalAlarmAcknowledged = state.criticalAlarmAcknowledged

        // Load saved game (with migration support)
        loadGame()
    }

    // MARK: - Game Loop Control

    func start() {
        guard !isRunning else { return }
        isRunning = true

        tickTimer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.processTick()
            }
    }

    func pause() {
        isRunning = false
        tickTimer?.cancel()
        tickTimer = nil
        saveGame()
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    // MARK: - Core Tick Processing (NetOps Math)

    private func processTick() {
        currentTick += 1
        totalPlayTime += tickInterval

        var stats = TickStats()

        // === DEFENSE PHASE ===
        firewall?.regenerate()

        // === THREAT PHASE ===
        processThreats(&stats)

        // === RANDOM EVENT PHASE ===
        processRandomEvents()

        // === PRODUCTION PHASE ===

        // Step 1: Source generates data (apply event + prestige multipliers)
        var packet = source.produce(atTick: currentTick)
        packet.amount *= sourceMultiplier * prestigeState.productionMultiplier
        stats.dataGenerated = packet.amount
        totalDataGenerated += packet.amount

        // Step 2: Check how much the sink can accept
        let sinkCanAccept = sink.bufferRemaining

        // Step 3: Apply bandwidth debuff from attacks AND event multiplier
        let effectiveBandwidth = link.bandwidth * (1.0 - bandwidthDebuff) * bandwidthMultiplier

        // Step 4: Link transfers data (applies bandwidth cap + packet loss)
        var modifiedLink = link
        let (transferred, dropped) = modifiedLink.transfer(
            packet,
            maxAcceptable: min(sinkCanAccept, effectiveBandwidth)
        )
        link.lastTickTransferred = transferred
        link.lastTickDropped = dropped

        stats.dataTransferred = transferred
        stats.dataDropped = dropped
        totalDataTransferred += transferred
        totalDataDropped += dropped
        resources.totalPacketsLost += dropped

        // Step 5: Sink receives the transferred data
        _ = sink.receiveData(transferred)

        // Step 6: Sink processes its buffer and generates credits (apply event + prestige + engagement multipliers)
        let baseCredits = sink.process()
        let engagementBonus = EngagementManager.shared.activeMultiplier
        let credits = baseCredits * creditMultiplier * prestigeState.creditMultiplier * engagementBonus
        stats.creditsEarned = credits
        resources.addCredits(credits)
        resources.totalDataProcessed += transferred

        // Step 7: Track total for threat calculation
        threatState.totalCreditsEarned += credits

        // Step 7b: Track credits for campaign mode
        if isInCampaignMode {
            levelCreditsEarned += credits
        }

        // Step 8: Calculate buffer utilization
        stats.bufferUtilization = sink.loadPercentage

        lastTickStats = stats

        // === UPDATE THREAT LEVEL ===
        let previousLevel = threatState.currentLevel
        threatState.updateThreatLevel()
        if threatState.currentLevel != previousLevel {
            emitEvent(.threatLevelIncreased(threatState.currentLevel))
            triggerMalusMessage(for: threatState.currentLevel)
        }

        // === UPDATE NET DEFENSE ===
        if let fw = firewall {
            threatState.updateNetDefense(
                firewallTier: fw.tier,
                firewallLevel: fw.level,
                firewallHealthPercent: fw.healthPercentage
            )
        } else {
            threatState.updateNetDefense(firewallTier: 0, firewallLevel: 0, firewallHealthPercent: 0)
        }

        // === MILESTONE & LORE CHECK ===
        updateMilestoneProgress()
        checkMilestones()
        checkLoreUnlocks()

        // === CAMPAIGN VICTORY CHECK ===
        if isInCampaignMode {
            checkLevelVictoryConditions()
        }

        // Auto-save every 30 ticks
        if currentTick % 30 == 0 {
            if isInCampaignMode {
                // Save campaign checkpoint for resume capability
                saveCampaignCheckpoint()
            } else {
                saveGame()
            }

            // Update engagement stats periodically
            updateEngagementStats()

            // Update playtime challenge progress (convert ticks to minutes)
            EngagementManager.shared.updateProgress(type: .playMinutes, amount: 0.5)  // 30 ticks = 0.5 min
        }

        // Tick engagement bonus multiplier
        EngagementManager.shared.tickBonus()
    }

    // MARK: - Threat Processing

    private func processThreats(_ stats: inout TickStats) {
        // Check critical alarm state
        checkCriticalAlarmReset()

        // === AUTOMATION: Auto-repair firewall ===
        if defenseStack.totalAutomation >= 0.25 {
            autoRepairFirewall()
        }

        // === AUTOMATION: Passive intel generation ===
        // Only generates intel if defense apps are deployed (automation comes from apps anyway)
        if defenseStack.totalAutomation >= 0.75 && defenseStack.deployedCount >= 1 {
            let passiveIntel = 1.0 * defenseStack.totalAutomation
            malusIntel.addFootprintData(passiveIntel, detectionMultiplier: defenseStack.totalDetectionBonus)
        }

        // Process active attack
        if var attack = activeAttack, attack.isActive {
            // Calculate player's current income for attack scaling
            let playerIncome = lastTickStats.creditsEarned
            var damage = attack.damagePerTick(playerIncomePerTick: playerIncome)

            // Apply damage multiplier from campaign mode (e.g., 1.5x for Insane)
            let damageMultiplier = levelConfiguration?.damageMultiplier ?? 1.0
            damage.creditDrain *= damageMultiplier
            damage.bandwidthReduction = min(1.0, damage.bandwidthReduction * damageMultiplier)
            damage.nodeDisableChance = min(1.0, damage.nodeDisableChance * damageMultiplier)

            // Defense reduces DAMAGE (not attack frequency)
            // 1. NetDefenseLevel provides base damage reduction (8% per level, up to 72%)
            let netDefenseReduction = threatState.riskCalculation.damageReduction
            // 2. Defense stack and intel add additional reduction
            let stackReduction = defenseStack.totalDamageReduction + malusIntel.damageReductionBonus
            // Combine reductions: apply NetDefense first, then stack reduction on remaining
            // This creates diminishing returns rather than simple addition
            let afterNetDefense = 1.0 - netDefenseReduction
            let totalReduction = netDefenseReduction + (afterNetDefense * min(0.65, stackReduction))
            // Cap total reduction at 85% to prevent complete immunity
            let cappedReduction = min(0.85, totalReduction)
            damage.creditDrain *= (1.0 - cappedReduction)
            damage.bandwidthReduction *= (1.0 - cappedReduction)

            // Firewall absorbs remaining damage
            if var fw = firewall, !fw.isDestroyed {
                let creditDamage = damage.creditDrain
                let remainingDamage = fw.absorbDamage(creditDamage)
                stats.damageAbsorbed = creditDamage - remainingDamage
                damage.creditDrain = remainingDamage

                // Check if firewall was destroyed
                if fw.isDestroyed && firewall?.isDestroyed != true {
                    emitEvent(.firewallDestroyed)
                }

                firewall = fw
            }

            // Apply remaining credit drain
            if damage.creditDrain > 0 {
                let actualDrain = min(resources.credits, damage.creditDrain)
                resources.credits -= actualDrain
                stats.creditsDrained = actualDrain
                attack.damageDealt += actualDrain
                threatState.totalDamageReceived += actualDrain
            }

            // Apply bandwidth reduction
            bandwidthDebuff = damage.bandwidthReduction

            // Check for node disable
            if damage.nodeDisableChance > 0 {
                let roll = Double.random(in: 0...1, using: &rng)
                if roll < damage.nodeDisableChance {
                    emitEvent(.nodeDisabled("System temporarily disrupted"))
                }
            }

            // === AUTOMATION: Reduced attack duration ===
            var ticksToProcess = 1
            if defenseStack.totalAutomation >= 0.50 {
                // Chance to process extra tick (faster attack resolution)
                let extraTickChance = (defenseStack.totalAutomation - 0.50) * 2.0  // 0-100% at 0.5-1.0
                if Double.random(in: 0...1, using: &rng) < extraTickChance {
                    ticksToProcess = 2
                }
            }

            for _ in 0..<ticksToProcess {
                attack.tick()
            }
            activeAttack = attack

            // Check if attack ended
            if !attack.isActive {
                threatState.attacksSurvived += 1
                emitEvent(.attackEnded(attack.type, survived: true))

                // Unlock Malus dossier on first survived attack
                if threatState.attacksSurvived == 1 {
                    DossierManager.shared.unlockMalusDossier()
                }

                // Track for campaign mode
                if isInCampaignMode {
                    levelAttacksSurvived += 1
                    levelDamageBlocked += attack.blocked
                }

                // Track for engagement system (damage taken = damageDealt - blocked)
                let damageTaken = attack.damageDealt - attack.blocked
                recordAttackSurvived(damageTaken: damageTaken)

                // Collect Malus footprint data from the attack (with detection bonus)
                collectMalusFootprint(attack)
                activeAttack = nil
                bandwidthDebuff = 0
            }
        } else {
            // No active attack - check for new attack
            bandwidthDebuff = 0

            // Check for early warning (from intel milestone)
            let warningChance = malusIntel.attackWarningChance
            var attackBlocked = false
            if warningChance > 0 && Double.random(in: 0...1, using: &rng) < warningChance {
                // Early warning - chance to prevent attack entirely
                attackBlocked = true
            }

            if !attackBlocked {
                // Get frequency multiplier from campaign mode (e.g., 2x for Insane)
                let frequencyMultiplier = levelConfiguration?.threatMultiplier ?? 1.0

                // Get minimum attack chance floor from level config
                let minimumAttackChance = levelConfiguration?.minimumAttackChance ?? 0.0

                // Use RAW threat level for attack generation (defense reduces DAMAGE, not frequency)
                // This ensures attacks keep happening even with high defense
                if let newAttack = AttackGenerator.tryGenerateAttack(
                    threatLevel: threatState.currentLevel,  // Raw threat, not effectiveRiskLevel
                    currentTick: currentTick,
                    random: &rng,
                    frequencyReduction: 0.0,  // No longer reduce frequency - defense reduces damage instead
                    frequencyMultiplier: frequencyMultiplier,
                    minimumChance: minimumAttackChance
                ) {
                    activeAttack = newAttack
                    emitEvent(.attackStarted(newAttack.type))
                    AudioManager.shared.playSound(.attackIncoming)
                }
            }
        }
    }

    /// Auto-repair firewall when automation is high enough
    private func autoRepairFirewall() {
        guard var fw = firewall, fw.currentHealth < fw.maxHealth else { return }

        // Auto-repair rate: 1% of max health per tick at 0.25 automation, up to 3% at 1.0
        let repairRate = 0.01 + (defenseStack.totalAutomation - 0.25) * 0.027
        let repairAmount = fw.maxHealth * repairRate
        fw.currentHealth = min(fw.maxHealth, fw.currentHealth + repairAmount)
        firewall = fw
    }

    // MARK: - Malus Messages

    private func triggerMalusMessage(for level: ThreatLevel) {
        let messages: [ThreatLevel: String] = [
            .blip: "> anomaly detected...",
            .signal: "> tracing signal origin...",
            .target: "> target acquired. monitoring.",
            .priority: "> escalating priority. resources allocated.",
            .hunted: "> MALUS ONLINE. HUNTING PROTOCOL ACTIVE.",
            .marked: ">> I SEE YOU. HELIX WILL BE MINE. <<"
        ]

        if let message = messages[level] {
            emitEvent(.malusMessage(message))
            threatState.malusEncounters += 1
            threatState.lastMalusMessageTick = currentTick
        }
    }

    private func emitEvent(_ event: GameEvent) {
        lastEvent = event
    }

    // MARK: - Random Event Processing

    private func processRandomEvents() {
        // Check if active event expired
        if let event = activeRandomEvent {
            if let expires = event.expiresAtTick, currentTick >= expires {
                // Event expired, reset multipliers
                sourceMultiplier = 1.0
                bandwidthMultiplier = 1.0
                creditMultiplier = 1.0
                activeRandomEvent = nil
            }
        }

        // Only try to generate new event if none active
        guard activeRandomEvent == nil else { return }

        if let newEvent = EventGenerator.tryGenerateEvent(
            threatLevel: threatState.currentLevel,
            currentTick: currentTick,
            totalCredits: threatState.totalCreditsEarned,
            random: &rng
        ) {
            activeRandomEvent = newEvent
            applyEventEffect(newEvent.effect)
            emitEvent(.randomEvent(newEvent.title, newEvent.message))

            // Play sound based on event type
            if newEvent.type.isPositive {
                AudioManager.shared.playSound(.milestone)
            } else {
                AudioManager.shared.playSound(.warning)
            }
        }
    }

    private func applyEventEffect(_ effect: EventEffect) {
        // Apply multipliers
        sourceMultiplier = effect.sourceMultiplier
        bandwidthMultiplier = effect.bandwidthMultiplier
        creditMultiplier = effect.creditMultiplier

        // Instant credits
        if effect.instantCredits > 0 {
            resources.addCredits(effect.instantCredits)
        }

        // Data loss (affects sink buffer)
        if effect.dataLoss > 0 {
            let loss = sink.inputBuffer * effect.dataLoss
            sink.inputBuffer -= loss
        }

        // Lore unlock
        if let fragmentId = effect.loreFragmentId {
            unlockLoreFragment(fragmentId)
        }
    }

    // MARK: - Milestone Processing

    private func updateMilestoneProgress() {
        milestoneState.totalCreditsEarned = threatState.totalCreditsEarned
        milestoneState.totalDataProcessed = resources.totalDataProcessed
        milestoneState.attacksSurvived = threatState.attacksSurvived
        milestoneState.highestThreatLevel = max(milestoneState.highestThreatLevel, threatState.currentLevel)
        milestoneState.unitsUnlocked = unlockState.unlockedUnitIds.count
        milestoneState.totalPlayTimeSeconds = Int(totalPlayTime)
        milestoneState.loreFragmentsCollected = loreState.unlockedFragmentIds.count
    }

    /// Update campaign completion counts for milestone tracking
    func updateCampaignMilestones(campaignCompleted: Int, insaneCompleted: Int) {
        milestoneState.campaignLevelsCompleted = campaignCompleted
        milestoneState.insaneLevelsCompleted = insaneCompleted
        checkMilestones()
        saveGame()
    }

    private func checkMilestones() {
        let completable = MilestoneDatabase.checkProgress(state: milestoneState)

        for milestone in completable {
            milestoneState.complete(milestone.id)
            emitEvent(.milestoneCompleted(milestone.title))
            AudioManager.shared.playSound(.milestone)

            // Apply reward
            applyMilestoneReward(milestone.reward)
        }
    }

    private func applyMilestoneReward(_ reward: MilestoneReward) {
        switch reward {
        case .credits(let amount):
            resources.addCredits(amount)

        case .loreUnlock(let fragmentId):
            unlockLoreFragment(fragmentId)

        case .unitUnlock(let unitId):
            unlockState.unlock(unitId)
            if let unit = UnitFactory.unit(withId: unitId) {
                emitEvent(.unitUnlocked(unit.name))
            }

        case .multiplier(_, _):
            // TODO: Implement temporary multiplier from milestone
            break
        }
    }

    // MARK: - Lore Processing

    private func checkLoreUnlocks() {
        // Check credit-based lore unlocks
        let creditUnlocks = LoreDatabase.fragmentsUnlockedByCredits(upTo: threatState.totalCreditsEarned)
        for fragment in creditUnlocks {
            if !loreState.isUnlocked(fragment.id) {
                // Check prerequisite
                if let prereq = fragment.prerequisiteFragmentId {
                    guard loreState.isUnlocked(prereq) else { continue }
                }
                unlockLoreFragment(fragment.id)
            }
        }
    }

    private func unlockLoreFragment(_ fragmentId: String) {
        guard !loreState.isUnlocked(fragmentId) else { return }

        loreState.unlock(fragmentId)

        if let fragment = LoreDatabase.fragment(withId: fragmentId) {
            emitEvent(.loreUnlocked(fragment.title))
        }
    }

    func markLoreRead(_ fragmentId: String) {
        loreState.markRead(fragmentId)
        saveGame()
    }

    // MARK: - Upgrades

    func upgradeSource() -> Bool {
        // Check if at max level for this tier
        guard source.canUpgrade else { return false }
        let cost = source.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        source.upgrade()
        AudioManager.shared.playSound(.upgrade)
        TutorialManager.shared.recordAction(.upgradedSource)
        recordUnitUpgrade()
        saveGame()
        return true
    }

    func upgradeLink() -> Bool {
        // Check if at max level for this tier
        guard link.canUpgrade else { return false }
        let cost = link.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        link.upgrade()
        AudioManager.shared.playSound(.upgrade)
        TutorialManager.shared.recordAction(.upgradedLink)
        recordUnitUpgrade()
        saveGame()
        return true
    }

    func upgradeSink() -> Bool {
        // Check if at max level for this tier
        guard sink.canUpgrade else { return false }
        let cost = sink.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        sink.upgrade()
        AudioManager.shared.playSound(.upgrade)
        TutorialManager.shared.recordAction(.upgradedSink)
        recordUnitUpgrade()
        saveGame()
        return true
    }

    func upgradeFirewall() -> Bool {
        guard var fw = firewall else { return false }
        // Check if at max level for this tier
        guard fw.canUpgrade else { return false }
        let cost = fw.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        fw.upgrade()
        firewall = fw
        AudioManager.shared.playSound(.upgrade)
        recordUnitUpgrade()
        saveGame()
        return true
    }

    // MARK: - Unit Unlock/Purchase

    /// Check if a unit can be unlocked (credits + tier gate)
    func canUnlock(_ unitInfo: UnitFactory.UnitInfo) -> Bool {
        guard !unlockState.isUnlocked(unitInfo.id) else { return false }
        guard resources.credits >= unitInfo.unlockCost else { return false }

        // Tier gate: must have previous tier at max level
        guard isTierGateSatisfied(for: unitInfo) else { return false }

        return true
    }

    /// Check if the tier gate requirement is satisfied
    /// To unlock a T(N) unit, the player must have a T(N-1) unit at max level
    func isTierGateSatisfied(for unitInfo: UnitFactory.UnitInfo) -> Bool {
        let targetTier = unitInfo.tier.rawValue

        // T1 units have no tier gate
        guard targetTier > 1 else { return true }

        // Check if we have the previous tier at max level for the same category
        let previousTier = NodeTier(rawValue: targetTier - 1) ?? .tier1

        switch unitInfo.category {
        case .source:
            // Check if current source is at max level AND is the previous tier
            return source.tier.rawValue >= previousTier.rawValue && source.isAtMaxLevel
        case .link:
            return link.tier.rawValue >= previousTier.rawValue && link.isAtMaxLevel
        case .sink:
            return sink.tier.rawValue >= previousTier.rawValue && sink.isAtMaxLevel
        case .defense:
            if let fw = firewall {
                return fw.nodeTier.rawValue >= previousTier.rawValue && fw.isAtMaxLevel
            }
            // If no firewall, T1 defense has no gate
            return targetTier == 1
        }
    }

    /// Get the tier gate reason for UI display
    func tierGateReason(for unitInfo: UnitFactory.UnitInfo) -> String? {
        guard !isTierGateSatisfied(for: unitInfo) else { return nil }

        let targetTier = unitInfo.tier.rawValue
        guard targetTier > 1 else { return nil }

        let previousTier = NodeTier(rawValue: targetTier - 1) ?? .tier1

        switch unitInfo.category {
        case .source:
            if source.tier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Source"
            }
            return "T\(previousTier.rawValue) Source must be at max level (\(previousTier.maxLevel))"
        case .link:
            if link.tier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Link"
            }
            return "T\(previousTier.rawValue) Link must be at max level (\(previousTier.maxLevel))"
        case .sink:
            if sink.tier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Sink"
            }
            return "T\(previousTier.rawValue) Sink must be at max level (\(previousTier.maxLevel))"
        case .defense:
            guard let fw = firewall else { return "Requires T\(previousTier.rawValue) Defense" }
            if fw.nodeTier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Defense"
            }
            return "T\(previousTier.rawValue) Defense must be at max level (\(previousTier.maxLevel))"
        }
    }

    func unlockUnit(_ unitInfo: UnitFactory.UnitInfo) -> Bool {
        guard canUnlock(unitInfo) else { return false }
        guard resources.spendCredits(unitInfo.unlockCost) else { return false }

        unlockState.unlock(unitInfo.id)
        emitEvent(.unitUnlocked(unitInfo.name))
        AudioManager.shared.playSound(.milestone)

        // Notify campaign system of unlock (for persistence across levels)
        onUnitUnlocked?(unitInfo.id)

        saveGame()
        return true
    }

    // MARK: - Unit Swapping

    func setSource(_ unitId: String) -> Bool {
        guard unlockState.isUnlocked(unitId),
              let newSource = UnitFactory.createSource(fromId: unitId) else {
            return false
        }
        source = newSource
        saveGame()
        return true
    }

    func setLink(_ unitId: String) -> Bool {
        guard unlockState.isUnlocked(unitId),
              let newLink = UnitFactory.createLink(fromId: unitId) else {
            return false
        }
        link = newLink
        saveGame()
        return true
    }

    func setSink(_ unitId: String) -> Bool {
        guard unlockState.isUnlocked(unitId),
              let newSink = UnitFactory.createSink(fromId: unitId) else {
            return false
        }
        sink = newSink
        saveGame()
        return true
    }

    func setFirewall(_ unitId: String?) -> Bool {
        if let unitId = unitId {
            guard unlockState.isUnlocked(unitId),
                  let newFirewall = UnitFactory.createFirewall(fromId: unitId) else {
                return false
            }
            firewall = newFirewall
        } else {
            firewall = nil
        }
        saveGame()
        return true
    }

    // MARK: - Firewall Actions

    func purchaseFirewall() -> Bool {
        guard firewall == nil else { return false }

        let firewallInfo = UnitFactory.unit(withId: "defense_t1_basic_firewall")
        guard let info = firewallInfo else { return false }

        // Unlock if needed
        if !unlockState.isUnlocked(info.id) {
            guard unlockUnit(info) else { return false }
        }

        firewall = UnitFactory.createBasicFirewall()
        TutorialManager.shared.recordAction(.purchasedFirewall)
        saveGame()
        return true
    }

    func repairFirewall() -> Bool {
        guard var fw = firewall, fw.currentHealth < fw.maxHealth else {
            return false
        }

        let repairCost = fw.repair()
        guard resources.spendCredits(repairCost) else { return false }

        firewall = fw
        saveGame()
        return true
    }

    // MARK: - Persistence

    private func saveGame() {
        let state = GameState(
            resources: resources,
            source: source,
            link: link,
            sink: sink,
            firewall: firewall,
            defenseStack: defenseStack,
            malusIntel: malusIntel,
            currentTick: currentTick,
            totalPlayTime: totalPlayTime,
            threatState: threatState,
            unlockState: unlockState,
            loreState: loreState,
            milestoneState: milestoneState,
            prestigeState: prestigeState,
            lastSaveTimestamp: Date(),
            criticalAlarmAcknowledged: criticalAlarmAcknowledged
        )

        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func loadGame() {
        // Use migration manager to load (handles old versions automatically)
        guard let state = SaveMigrationManager.loadAndMigrate() else {
            return
        }

        resources = state.resources
        source = state.source
        link = state.link
        sink = state.sink
        firewall = state.firewall
        defenseStack = state.defenseStack
        malusIntel = state.malusIntel
        currentTick = state.currentTick
        totalPlayTime = state.totalPlayTime
        threatState = state.threatState
        unlockState = state.unlockState
        loreState = state.loreState
        milestoneState = state.milestoneState
        prestigeState = state.prestigeState
        criticalAlarmAcknowledged = state.criticalAlarmAcknowledged

        // Calculate offline progress
        if let lastSave = state.lastSaveTimestamp {
            calculateOfflineProgress(since: lastSave)
        }
    }

    /// Calculate and apply credits earned while player was away
    private func calculateOfflineProgress(since lastSave: Date) {
        let now = Date()
        let secondsAway = Int(now.timeIntervalSince(lastSave))

        // Only count offline progress if away for at least 60 seconds
        guard secondsAway >= 60 else { return }

        // Cap offline time at 8 hours (28800 seconds) for balance
        let maxOfflineSeconds = 28800
        let effectiveSeconds = min(secondsAway, maxOfflineSeconds)

        // Calculate ticks (1 tick per second)
        let ticksToSimulate = effectiveSeconds

        // Calculate earnings at reduced rate (50% of normal)
        // This prevents offline from being better than active play
        let offlineEfficiency = 0.5

        // Estimate production per tick based on current setup
        let estimatedProduction = source.productionPerTick
        let effectiveBandwidth = link.bandwidth
        let estimatedTransfer = min(estimatedProduction, effectiveBandwidth)
        let estimatedProcessing = min(estimatedTransfer, sink.processingPerTick)
        let creditsPerTick = estimatedProcessing * sink.conversionRate * offlineEfficiency

        // Calculate totals
        let totalCredits = creditsPerTick * Double(ticksToSimulate)
        let totalData = estimatedProcessing * Double(ticksToSimulate)

        // Apply earnings
        resources.addCredits(totalCredits)
        resources.totalDataProcessed += totalData
        threatState.totalCreditsEarned += totalCredits
        currentTick += ticksToSimulate
        totalPlayTime += TimeInterval(effectiveSeconds)

        // Create offline progress report
        offlineProgress = OfflineProgress(
            secondsAway: secondsAway,
            ticksSimulated: ticksToSimulate,
            creditsEarned: totalCredits,
            dataProcessed: totalData
        )
    }

    /// Calculate offline progress for a campaign level checkpoint
    /// Returns the bonus credits earned while away (to be added to checkpoint credits)
    func calculateCampaignOfflineProgress(checkpoint: LevelCheckpoint) -> OfflineProgress? {
        let now = Date()
        let secondsAway = Int(now.timeIntervalSince(checkpoint.savedAt))

        // Only count offline progress if away for at least 60 seconds
        guard secondsAway >= 60 else { return nil }

        // Cap offline time at 4 hours for campaign (shorter than endless)
        let maxOfflineSeconds = 14400
        let effectiveSeconds = min(secondsAway, maxOfflineSeconds)

        // Calculate ticks (1 tick per second)
        let ticksToSimulate = effectiveSeconds

        // Calculate earnings at reduced rate (30% for campaign - lower than endless)
        let offlineEfficiency = 0.3

        // Use checkpoint's node levels to estimate production
        // Base T1 values scaled by level
        let estimatedProduction = 10.0 * Double(checkpoint.sourceLevel)  // ~10/tick at T1
        let effectiveBandwidth = 15.0 * Double(checkpoint.linkLevel)     // ~15/tick at T1
        let estimatedTransfer = min(estimatedProduction, effectiveBandwidth)
        let estimatedProcessing = min(estimatedTransfer, 12.0 * Double(checkpoint.sinkLevel))
        let creditsPerTick = estimatedProcessing * 1.0 * offlineEfficiency  // 1.0 conversion rate

        // Calculate totals
        let totalCredits = creditsPerTick * Double(ticksToSimulate)
        let totalData = estimatedProcessing * Double(ticksToSimulate)

        return OfflineProgress(
            secondsAway: secondsAway,
            ticksSimulated: ticksToSimulate,
            creditsEarned: totalCredits,
            dataProcessed: totalData
        )
    }

    /// Dismiss offline progress notification
    func dismissOfflineProgress() {
        offlineProgress = nil
    }

    func resetGame() {
        pause()
        let state = GameState.newGame()
        resources = state.resources
        source = state.source
        link = state.link
        sink = state.sink
        firewall = nil
        defenseStack = DefenseStack()
        malusIntel = MalusIntelligence()
        currentTick = 0
        totalPlayTime = 0
        totalDataGenerated = 0
        totalDataTransferred = 0
        totalDataDropped = 0
        lastTickStats = TickStats()
        threatState = ThreatState()
        unlockState = UnlockState()
        loreState = state.loreState
        milestoneState = MilestoneState()
        prestigeState = PrestigeState()  // Reset prestige on full reset
        activeAttack = nil
        activeRandomEvent = nil
        lastEvent = nil
        bandwidthDebuff = 0
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = 1.0
        showCriticalAlarm = false
        criticalAlarmAcknowledged = false
        UserDefaults.standard.removeObject(forKey: saveKey)
    }

    // MARK: - Prestige System

    /// Check if player can prestige at current level
    var canPrestige: Bool {
        let required = PrestigeState.creditsRequiredForPrestige(level: prestigeState.prestigeLevel)
        return threatState.totalCreditsEarned >= required
    }

    /// Credits required for next prestige
    var creditsRequiredForPrestige: Double {
        PrestigeState.creditsRequiredForPrestige(level: prestigeState.prestigeLevel)
    }

    /// Helix cores that would be earned from prestiging now
    var helixCoresFromPrestige: Int {
        PrestigeState.helixCoresEarned(
            fromCredits: threatState.totalCreditsEarned,
            atLevel: prestigeState.prestigeLevel
        )
    }

    /// Perform a prestige (Network Wipe) - resets progress but grants permanent bonuses
    func performPrestige() -> Bool {
        guard canPrestige else { return false }

        // Calculate rewards before resetting
        let coresEarned = helixCoresFromPrestige

        // Update prestige state
        var newPrestigeState = prestigeState
        newPrestigeState.prestigeLevel += 1
        newPrestigeState.totalHelixCores += coresEarned
        newPrestigeState.availableHelixCores += coresEarned

        // Reset game but keep prestige
        pause()
        let state = GameState.newGame(prestigeState: newPrestigeState)
        resources = state.resources
        source = state.source
        link = state.link
        sink = state.sink
        firewall = nil
        currentTick = 0
        totalPlayTime = 0
        totalDataGenerated = 0
        totalDataTransferred = 0
        totalDataDropped = 0
        lastTickStats = TickStats()
        threatState = ThreatState()
        unlockState = UnlockState()
        loreState = state.loreState
        milestoneState = MilestoneState()
        prestigeState = newPrestigeState
        activeAttack = nil
        activeRandomEvent = nil
        lastEvent = nil
        bandwidthDebuff = 0
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = 1.0

        // Emit event
        emitEvent(.milestone("NETWORK WIPE COMPLETE - Helix Core +\(coresEarned)"))
        AudioManager.shared.playSound(.milestone)

        saveGame()
        return true
    }

    // MARK: - Defense Stack Management

    /// Unlock a defense application tier
    func unlockDefenseTier(_ tier: DefenseAppTier) -> Bool {
        guard defenseStack.canUnlock(tier) else { return false }
        guard resources.spendCredits(tier.unlockCost) else { return false }

        defenseStack.unlock(tier)
        emitEvent(.unitUnlocked(tier.displayName))
        AudioManager.shared.playSound(.upgrade)
        saveGame()
        return true
    }

    /// Deploy a defense application
    func deployDefenseApp(_ tier: DefenseAppTier) -> Bool {
        guard defenseStack.isUnlocked(tier) else { return false }

        defenseStack.deploy(tier)
        emitEvent(.milestone("Deployed: \(tier.displayName)"))
        AudioManager.shared.playSound(.upgrade)
        TutorialManager.shared.recordAction(.deployedDefenseApp)
        recordDefenseDeployed()
        saveGame()
        return true
    }

    /// Upgrade a deployed defense application
    func upgradeDefenseApp(_ category: DefenseCategory) -> Bool {
        guard let app = defenseStack.application(for: category) else { return false }
        guard resources.spendCredits(app.upgradeCost) else { return false }

        _ = defenseStack.upgrade(category)
        AudioManager.shared.playSound(.upgrade)
        saveGame()
        return true
    }

    // MARK: - Critical Alarm

    /// Check if critical alarm should show
    var shouldShowCriticalAlarm: Bool {
        // Show if risk is HUNTED or MARKED and not acknowledged
        let riskLevel = threatState.effectiveRiskLevel
        return (riskLevel == .hunted || riskLevel == .marked) && !criticalAlarmAcknowledged
    }

    /// Acknowledge critical alarm
    func acknowledgeCriticalAlarm() {
        criticalAlarmAcknowledged = true
        showCriticalAlarm = false
        saveGame()
    }

    /// Reset alarm acknowledgement (called when risk drops)
    private func checkCriticalAlarmReset() {
        let riskLevel = threatState.effectiveRiskLevel
        if riskLevel.rawValue < ThreatLevel.hunted.rawValue {
            criticalAlarmAcknowledged = false
        } else if !criticalAlarmAcknowledged {
            showCriticalAlarm = true
        }
    }

    // MARK: - Malus Intelligence

    /// Send report to team - now with meaningful rewards!
    func sendMalusReport() -> Bool {
        // Get intel multiplier from SIEM/IDS systems
        let intelMultiplier = defenseStack.totalIntelMultiplier

        guard let result = malusIntel.sendReport(intelMultiplier: intelMultiplier) else {
            return false
        }

        // Award credits
        resources.addCredits(result.creditsEarned)

        // Check for milestone unlock
        if let milestone = result.milestone {
            // Emit milestone event
            emitEvent(.milestone("INTEL MILESTONE: \(milestone.title) - +₵\(Int(result.milestoneCredits).formatted())"))

            // Unlock lore fragment if available
            if let loreId = milestone.loreFragmentId {
                unlockLoreFragment(loreId)
            }

            AudioManager.shared.playSound(.milestone)
        } else {
            // Regular report
            emitEvent(.milestone("Intel Report #\(result.reportNumber) - +₵\(Int(result.creditsEarned).formatted())"))
            AudioManager.shared.playSound(.upgrade)
        }

        // Track for engagement system
        recordIntelReportSent()

        TutorialManager.shared.recordAction(.sentReport)
        saveGame()
        return true
    }

    /// Get info about next intel milestone
    var nextIntelMilestone: IntelMilestone? {
        malusIntel.nextMilestone
    }

    /// Reports needed for next milestone
    var reportsToNextMilestone: Int {
        malusIntel.reportsToNextMilestone
    }

    /// Collect footprint data from survived attack
    private func collectMalusFootprint(_ attack: Attack) {
        // GATE: Must have at least one defense app deployed to collect intel
        // This makes defense apps essential for campaign progress (intel reports are required)
        guard defenseStack.deployedCount >= 1 else { return }

        // Base intel from attack: damage blocked + duration + severity bonus
        let damageBlocked = attack.blocked
        let durationBonus = Double(attack.type.baseDuration) * 15.0
        let severityBonus = attack.severity * 25.0
        let baseData = damageBlocked * 0.5 + durationBonus + severityBonus

        // Apply detection bonus from SIEM/IDS systems
        let detectionMultiplier = defenseStack.totalDetectionBonus
        malusIntel.addFootprintData(baseData, detectionMultiplier: detectionMultiplier)

        // Identify pattern based on attack type (with speed bonus from milestones)
        let pattern = "\(attack.type.rawValue)_v\(Int(attack.severity * 10))"
        malusIntel.identifyPattern(pattern, patternSpeedBonus: malusIntel.patternIdSpeedBonus)

        // Bonus pattern from high-tier attacks
        if attack.type == .malusStrike {
            let malusPattern = "MALUS_SIGNATURE_\(currentTick % 100)"
            malusIntel.identifyPattern(malusPattern, patternSpeedBonus: malusIntel.patternIdSpeedBonus)
        }
    }

    // MARK: - Campaign Mode

    /// Start a campaign level with specific configuration
    /// - Parameters:
    ///   - config: Level configuration
    ///   - persistedUnlocks: Unit IDs unlocked in previous campaign levels (persisted across levels)
    func startCampaignLevel(_ config: LevelConfiguration, persistedUnlocks: Set<String> = []) {
        // Pause any existing game
        pause()

        // IMPORTANT: Clear any offline progress from endless mode
        // Campaign levels start fresh - offline progress doesn't apply to new levels
        offlineProgress = nil

        // Store configuration
        levelConfiguration = config

        // Reset to level's starting state
        let level = config.level
        resources = PlayerResources()
        resources.credits = level.startingCredits
        source = UnitFactory.createPublicMeshSniffer()
        link = UnitFactory.createCopperVPNTunnel()
        sink = UnitFactory.createDataBroker()
        firewall = nil
        defenseStack = DefenseStack()
        malusIntel = MalusIntelligence()

        // Restore unlocked units from campaign progress
        // Start with base T1 units, then add persisted unlocks
        unlockState = UnlockState()
        for unitId in persistedUnlocks {
            unlockState.unlock(unitId)
        }

        // Set threat level
        threatState = ThreatState()
        threatState.currentLevel = level.startingThreatLevel

        // Reset level tracking
        levelStartTick = 0
        levelCreditsEarned = 0
        levelAttacksSurvived = 0
        levelDamageBlocked = 0
        currentTick = 0

        // Reset event multipliers
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = config.incomeMultiplier  // Apply insane mode income penalty
        bandwidthDebuff = 0

        // Clear any active states
        activeAttack = nil
        activeRandomEvent = nil
        showCriticalAlarm = false
        criticalAlarmAcknowledged = false

        // Start the level
        start()
    }

    /// End campaign mode and return to endless
    func exitCampaignMode() {
        levelConfiguration = nil
        onLevelComplete = nil
        onLevelFailed = nil

        // Reset multipliers
        creditMultiplier = 1.0
    }

    // MARK: - Campaign Checkpoint Save

    /// Save a checkpoint of the current campaign level progress
    func saveCampaignCheckpoint() {
        guard let config = levelConfiguration else { return }

        let checkpoint = LevelCheckpoint(
            levelId: config.level.id,
            isInsane: config.isInsane,
            savedAt: Date(),
            credits: resources.credits,
            data: resources.totalDataProcessed,
            ticksElapsed: currentTick - levelStartTick,
            attacksSurvived: levelAttacksSurvived,
            damageBlocked: levelDamageBlocked,
            creditsEarned: levelCreditsEarned,
            sourceUnitId: source.unitTypeId,
            sourceLevel: source.level,
            linkUnitId: link.unitTypeId,
            linkLevel: link.level,
            sinkUnitId: sink.unitTypeId,
            sinkLevel: sink.level,
            firewallUnitId: firewall?.unitTypeId,
            firewallHealth: firewall?.currentHealth,
            firewallMaxHealth: firewall?.maxHealth,
            firewallLevel: firewall?.level,
            defenseStack: defenseStack,
            malusIntel: malusIntel,
            unlockedUnits: unlockState.unlockedUnitIds
        )

        // Save checkpoint to campaign progress
        var progress = CampaignSaveManager.shared.load()
        progress.activeCheckpoint = checkpoint
        CampaignSaveManager.shared.save(progress)
    }

    /// Clear the active campaign checkpoint (called on level complete/fail/abandon)
    func clearCampaignCheckpoint() {
        var progress = CampaignSaveManager.shared.load()
        progress.activeCheckpoint = nil
        CampaignSaveManager.shared.save(progress)
    }

    /// Check if there's a valid checkpoint for a specific level
    func hasValidCheckpoint(for levelId: Int, isInsane: Bool) -> Bool {
        let progress = CampaignSaveManager.shared.load()
        guard let checkpoint = progress.activeCheckpoint else { return false }
        return checkpoint.levelId == levelId &&
               checkpoint.isInsane == isInsane &&
               checkpoint.isValid
    }

    /// Resume from a saved checkpoint
    /// - Parameters:
    ///   - checkpoint: The saved checkpoint to resume from
    ///   - config: Level configuration
    ///   - persistedUnlocks: Unused (kept for API compatibility) - unlocks are restored from checkpoint
    func resumeFromCheckpoint(_ checkpoint: LevelCheckpoint, config: LevelConfiguration, persistedUnlocks: Set<String> = []) {
        // Set up the level first
        levelConfiguration = config

        // Calculate offline progress earned while away from this checkpoint
        let campaignOffline = calculateCampaignOfflineProgress(checkpoint: checkpoint)
        let bonusCredits = campaignOffline?.creditsEarned ?? 0

        // Restore level tracking
        levelStartTick = 0  // We'll offset tick calculations
        levelCreditsEarned = checkpoint.creditsEarned + bonusCredits  // Use saved credits earned + offline bonus
        levelAttacksSurvived = checkpoint.attacksSurvived
        levelDamageBlocked = checkpoint.damageBlocked
        currentTick = checkpoint.ticksElapsed

        // Restore resources (including offline bonus)
        resources = PlayerResources()
        resources.credits = checkpoint.credits + bonusCredits
        resources.totalDataProcessed = checkpoint.data + (campaignOffline?.dataProcessed ?? 0)

        // Restore unlocked units from checkpoint (includes units unlocked during this level)
        // Note: Unit unlocks do NOT persist across campaign levels
        unlockState = UnlockState()
        for unitId in checkpoint.unlockedUnits {
            unlockState.unlock(unitId)
        }

        // Restore nodes by their actual unit ID (not just T1 default)
        if let restoredSource = UnitFactory.createSource(fromId: checkpoint.sourceUnitId) {
            source = restoredSource
        } else {
            source = UnitFactory.createPublicMeshSniffer()
        }
        for _ in 1..<checkpoint.sourceLevel {
            source.upgrade()
        }

        if let restoredLink = UnitFactory.createLink(fromId: checkpoint.linkUnitId) {
            link = restoredLink
        } else {
            link = UnitFactory.createCopperVPNTunnel()
        }
        for _ in 1..<checkpoint.linkLevel {
            link.upgrade()
        }

        if let restoredSink = UnitFactory.createSink(fromId: checkpoint.sinkUnitId) {
            sink = restoredSink
        } else {
            sink = UnitFactory.createDataBroker()
        }
        for _ in 1..<checkpoint.sinkLevel {
            sink.upgrade()
        }

        // Restore firewall if it was present (by unit ID)
        if let fwUnitId = checkpoint.firewallUnitId,
           let fwHealth = checkpoint.firewallHealth {
            if let restoredFirewall = UnitFactory.createFirewall(fromId: fwUnitId) {
                firewall = restoredFirewall
            } else {
                firewall = UnitFactory.createBasicFirewall()
            }
            // Restore firewall level (maxHealth is computed from level, so upgrading restores it)
            if let fwLevel = checkpoint.firewallLevel {
                for _ in 1..<fwLevel {
                    firewall?.upgrade()
                }
            }
            firewall?.currentHealth = fwHealth
        } else {
            firewall = nil
        }

        // Restore defense stack and malus intel (FULL STATE)
        defenseStack = checkpoint.defenseStack
        malusIntel = checkpoint.malusIntel

        // Set threat state
        threatState = ThreatState()
        threatState.currentLevel = config.level.startingThreatLevel

        // Reset event multipliers
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = config.incomeMultiplier
        bandwidthDebuff = 0

        // Clear active states
        activeAttack = nil
        activeRandomEvent = nil
        showCriticalAlarm = false
        criticalAlarmAcknowledged = false

        // Set offline progress to show the dialog (if there was progress)
        offlineProgress = campaignOffline

        // Start the level
        start()
    }

    /// Check victory conditions (called each tick in campaign mode)
    private func checkLevelVictoryConditions() {
        guard let config = levelConfiguration else { return }

        let conditions = config.level.victoryConditions

        // Check for time limit failure first
        if conditions.isTimeLimitExceeded(currentTick: currentTick - levelStartTick) {
            handleLevelFailed(.timeLimitExceeded)
            return
        }

        // Check for bankruptcy
        if resources.credits <= 0 && currentTick > levelStartTick + 60 {
            // Give 60 ticks grace period at start
            handleLevelFailed(.creditsZero)
            return
        }

        // Check victory conditions
        if conditions.isSatisfied(
            defenseStack: defenseStack,
            riskLevel: threatState.effectiveRiskLevel,
            totalCredits: levelCreditsEarned,
            attacksSurvived: levelAttacksSurvived,
            reportsSent: malusIntel.reportsSent,
            currentTick: currentTick - levelStartTick
        ) {
            handleLevelComplete()
        }
    }

    /// Handle successful level completion
    private func handleLevelComplete() {
        guard let config = levelConfiguration else { return }

        pause()

        // Clear checkpoint on completion
        clearCampaignCheckpoint()

        let stats = LevelCompletionStats(
            levelId: config.level.id,
            isInsane: config.isInsane,
            ticksToComplete: currentTick - levelStartTick,
            creditsEarned: levelCreditsEarned,
            attacksSurvived: levelAttacksSurvived,
            damageBlocked: levelDamageBlocked,
            finalDefensePoints: Int(defenseStack.totalDefensePoints),
            intelReportsSent: malusIntel.reportsSent,
            completionDate: Date()
        )

        onLevelComplete?(stats)
    }

    /// Handle level failure
    private func handleLevelFailed(_ reason: FailureReason) {
        pause()

        // Clear checkpoint on failure
        clearCampaignCheckpoint()

        onLevelFailed?(reason)
    }

    /// Get current victory progress for UI display
    var victoryProgress: VictoryProgress? {
        guard let config = levelConfiguration else { return nil }

        let conditions = config.level.victoryConditions
        let highestTier = defenseStack.applications.values.map { $0.tier.tierNumber }.max() ?? 0

        return VictoryProgress(
            defenseTierRequired: conditions.requiredDefenseTier,
            defenseTierCurrent: highestTier,
            defensePointsRequired: conditions.requiredDefensePoints,
            defensePointsCurrent: Int(defenseStack.totalDefensePoints),
            riskLevelRequired: conditions.requiredRiskLevel,
            riskLevelCurrent: threatState.effectiveRiskLevel,
            creditsRequired: conditions.requiredCredits,
            creditsCurrent: levelCreditsEarned,
            attacksRequired: conditions.requiredAttacksSurvived,
            attacksCurrent: levelAttacksSurvived,
            reportsRequired: conditions.requiredReportsSent,
            reportsCurrent: malusIntel.reportsSent
        )
    }

    // MARK: - Debug

    func addDebugCredits(_ amount: Double) {
        resources.addCredits(amount)
        threatState.totalCreditsEarned += amount
    }

    // MARK: - Engagement System Support

    /// Add credits from engagement rewards (daily login, achievements, etc.)
    func addCredits(_ amount: Double) {
        resources.addCredits(amount)
        threatState.totalCreditsEarned += amount

        // Update engagement challenge progress
        EngagementManager.shared.updateProgress(type: .earnCredits, amount: amount)
    }

    /// Update engagement system with current game stats
    func updateEngagementStats() {
        // Update achievement stats
        AchievementManager.shared.updateStats { stats in
            stats.totalCreditsEarned = threatState.totalCreditsEarned
            stats.highestSingleRunCredits = max(stats.highestSingleRunCredits, resources.credits)
            stats.totalAttacksSurvived = threatState.attacksSurvived
            stats.highestDefensePoints = max(stats.highestDefensePoints, Int(defenseStack.totalDefensePoints))
            stats.prestigeLevel = prestigeState.prestigeLevel
            stats.loreFragmentsCollected = loreState.unlockedFragmentIds.count
            stats.dataChipsCollected = CollectionManager.shared.ownedCount
            stats.intelReportsSent = malusIntel.reportsSent

            // Login streak from engagement manager
            stats.longestLoginStreak = max(stats.longestLoginStreak, EngagementManager.shared.longestStreak)
        }
    }

    /// Called when an attack is survived - updates engagement systems
    func recordAttackSurvived(damageTaken: Double) {
        // Update engagement challenge progress
        EngagementManager.shared.updateProgress(type: .surviveAttacks, amount: 1)

        // Update achievement stats
        AchievementManager.shared.updateStats { stats in
            stats.totalAttacksSurvived += 1
            if damageTaken <= 0 {
                stats.consecutiveNoDamageAttacks += 1
                stats.perfectDefenseStreak += 1
            } else {
                stats.consecutiveNoDamageAttacks = 0
                stats.perfectDefenseStreak = 0
            }
        }
    }

    /// Called when intel report is sent
    func recordIntelReportSent() {
        EngagementManager.shared.updateProgress(type: .sendReports, amount: 1)

        AchievementManager.shared.updateStats { stats in
            stats.intelReportsSent += 1
        }
    }

    /// Called when a unit is upgraded
    func recordUnitUpgrade() {
        EngagementManager.shared.updateProgress(type: .upgradeUnits, amount: 1)
    }

    /// Called when a defense app is deployed
    func recordDefenseDeployed() {
        EngagementManager.shared.updateProgress(type: .deployDefense, amount: 1)
    }

    /// Called when level is completed - updates achievement stats
    func recordLevelCompletion(level: Int, damageTaken: Bool, timeInTicks: Int) {
        AchievementManager.shared.updateStats { stats in
            stats.highestLevelCompleted = max(stats.highestLevelCompleted, level)

            // Track best completion time
            if let existingTime = stats.levelCompletionTimes[level] {
                stats.levelCompletionTimes[level] = min(existingTime, timeInTicks)
            } else {
                stats.levelCompletionTimes[level] = timeInTicks
            }

            // Check for perfect level 1 completion
            if level == 1 && !damageTaken {
                stats.easterEggsFound.insert("perfect_level1")
            }
        }

        // Chance to award a data chip on level completion
        let _ = CollectionManager.shared.awardRandomChip(
            levelCompleted: level,
            threat: threatState.currentLevel.rawValue,
            attacks: threatState.attacksSurvived,
            reports: malusIntel.reportsSent,
            prestige: prestigeState.prestigeLevel
        )
    }

    /// Check for time-based easter eggs
    func checkTimeBasedEasterEggs() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour == 3 {
            AchievementManager.shared.triggerEasterEgg("night_3am")
        }
    }
}

// MARK: - Victory Progress (For UI)

struct VictoryProgress {
    let defenseTierRequired: Int
    let defenseTierCurrent: Int
    let defensePointsRequired: Int
    let defensePointsCurrent: Int
    let riskLevelRequired: ThreatLevel
    let riskLevelCurrent: ThreatLevel
    let creditsRequired: Double?
    let creditsCurrent: Double
    let attacksRequired: Int?
    let attacksCurrent: Int
    let reportsRequired: Int?
    let reportsCurrent: Int

    var defenseTierMet: Bool { defenseTierCurrent >= defenseTierRequired }
    var defensePointsMet: Bool { defensePointsCurrent >= defensePointsRequired }
    var riskLevelMet: Bool { riskLevelCurrent.rawValue <= riskLevelRequired.rawValue }

    var creditsMet: Bool {
        guard let required = creditsRequired else { return true }
        return creditsCurrent >= required
    }

    var attacksMet: Bool {
        guard let required = attacksRequired else { return true }
        return attacksCurrent >= required
    }

    var reportsMet: Bool {
        guard let required = reportsRequired else { return true }
        return reportsCurrent >= required
    }

    var allConditionsMet: Bool {
        defenseTierMet && defensePointsMet && riskLevelMet && creditsMet && attacksMet && reportsMet
    }

    var overallProgress: Double {
        var progress = 0.0
        var count = 0.0

        // Defense tier (weighted heavily)
        progress += min(1.0, Double(defenseTierCurrent) / Double(defenseTierRequired)) * 2
        count += 2

        // Defense points
        progress += min(1.0, Double(defensePointsCurrent) / Double(defensePointsRequired))
        count += 1

        // Risk level (1.0 if met, partial otherwise)
        let riskProgress = riskLevelMet ? 1.0 : max(0, 1.0 - Double(riskLevelCurrent.rawValue - riskLevelRequired.rawValue) * 0.2)
        progress += riskProgress
        count += 1

        // Credits
        if let required = creditsRequired {
            progress += min(1.0, creditsCurrent / required)
            count += 1
        }

        // Attacks
        if let required = attacksRequired {
            progress += min(1.0, Double(attacksCurrent) / Double(required))
            count += 1
        }

        // Intel Reports (weighted heavily - main objective)
        if let required = reportsRequired {
            progress += min(1.0, Double(reportsCurrent) / Double(required)) * 2
            count += 2
        }

        return progress / count
    }
}
