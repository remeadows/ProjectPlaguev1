// UnitFactory.swift
// GridWatchZero
// Factory for creating game units across all tiers

import Foundation

/// Factory for creating game units with preset configurations
enum UnitFactory {

    // MARK: - Tier 1 Source

    /// "Public Mesh Sniffer" - Entry-level data harvester
    /// Generates Raw Noise from public network traffic
    static func createPublicMeshSniffer() -> SourceNode {
        SourceNode(
            name: "Public Mesh Sniffer",
            level: 1,
            baseProduction: 8.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 2 Source

    /// "Corporate Leech" - Mid-tier data harvester
    /// Taps into corporate network traffic for higher quality data
    static func createCorporateLeech() -> SourceNode {
        SourceNode(
            name: "Corporate Leech",
            level: 1,
            baseProduction: 20.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 3 Source

    /// "Zero-Day Harvester" - High-tier data harvester
    /// Exploits unpatched vulnerabilities for premium data
    static func createZeroDayHarvester() -> SourceNode {
        SourceNode(
            name: "Zero-Day Harvester",
            level: 1,
            baseProduction: 50.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 4 Source

    /// "Helix Fragment Scanner" - Ultimate data harvester
    /// Can detect Helix fragments in the data stream
    static func createHelixScanner() -> SourceNode {
        SourceNode(
            name: "Helix Fragment Scanner",
            level: 1,
            baseProduction: 100.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 5 Source

    /// "Neural Tap Array" - Campus-wide neural network harvester
    /// Parallel processing across distributed endpoints
    static func createNeuralTapArray() -> SourceNode {
        SourceNode(
            name: "Neural Tap Array",
            level: 1,
            baseProduction: 200.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 6 Source

    /// "Helix Prime Collector" - Direct connection to Helix consciousness
    /// Maximum data extraction with Helix resonance
    static func createHelixPrimeCollector() -> SourceNode {
        SourceNode(
            name: "Helix Prime Collector",
            level: 1,
            baseProduction: 500.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 7 Source (Transcendence)

    /// "Helix Symbiont Array" - Symbiotic data sharing with Helix
    static func createHelixSymbiontArray() -> SourceNode {
        SourceNode(name: "Helix Symbiont Array", level: 1, baseProduction: 1000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 8 Source

    /// "Transcendence Probe" - Beyond normal data streams
    static func createTranscendenceProbe() -> SourceNode {
        SourceNode(name: "Transcendence Probe", level: 1, baseProduction: 2000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 9 Source

    /// "Void Echo Listener" - Quantum void fluctuations
    static func createVoidEchoListener() -> SourceNode {
        SourceNode(name: "Void Echo Listener", level: 1, baseProduction: 4000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 10 Source

    /// "Dimensional Trawler" - Cross-dimensional boundary harvesting
    static func createDimensionalTrawler() -> SourceNode {
        SourceNode(name: "Dimensional Trawler", level: 1, baseProduction: 8000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 11 Source (Dimensional)

    /// "Multiverse Beacon" - Parallel reality signal harvesting
    static func createMultiverseBeacon() -> SourceNode {
        SourceNode(name: "Multiverse Beacon", level: 1, baseProduction: 16000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 12 Source

    /// "Entropy Harvester" - Information from entropy itself
    static func createEntropyHarvester() -> SourceNode {
        SourceNode(name: "Entropy Harvester", level: 1, baseProduction: 32000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 13 Source

    /// "Causality Scanner" - Pre-event cause-effect data
    static func createCausalityScanner() -> SourceNode {
        SourceNode(name: "Causality Scanner", level: 1, baseProduction: 64000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 14 Source

    /// "Timeline Extractor" - Past and future data streams
    static func createTimelineExtractor() -> SourceNode {
        SourceNode(name: "Timeline Extractor", level: 1, baseProduction: 128000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 15 Source

    /// "Akashic Tap" - Universal record access
    static func createAkashicTap() -> SourceNode {
        SourceNode(name: "Akashic Tap", level: 1, baseProduction: 256000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 16 Source (Cosmic)

    /// "Cosmic Web Siphon" - Universal information networks
    static func createCosmicWebSiphon() -> SourceNode {
        SourceNode(name: "Cosmic Web Siphon", level: 1, baseProduction: 512000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 17 Source

    /// "Dark Matter Collector" - Hidden matter data streams
    static func createDarkMatterCollector() -> SourceNode {
        SourceNode(name: "Dark Matter Collector", level: 1, baseProduction: 1024000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 18 Source

    /// "Singularity Well" - Event horizon data collection
    static func createSingularityWell() -> SourceNode {
        SourceNode(name: "Singularity Well", level: 1, baseProduction: 2048000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 19 Source

    /// "Omniscient Array" - Near-complete universal awareness
    static func createOmniscientArray() -> SourceNode {
        SourceNode(name: "Omniscient Array", level: 1, baseProduction: 4096000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 20 Source

    /// "Reality Core Tap" - Access to reality's source code
    static func createRealityCoreTap() -> SourceNode {
        SourceNode(name: "Reality Core Tap", level: 1, baseProduction: 8192000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 21 Source (Infinite)

    /// "Prime Nexus Scanner" - First point of all information
    static func createPrimeNexusScanner() -> SourceNode {
        SourceNode(name: "Prime Nexus Scanner", level: 1, baseProduction: 16384000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 22 Source

    /// "Absolute Zero Harvester" - Perfect extraction efficiency
    static func createAbsoluteZeroHarvester() -> SourceNode {
        SourceNode(name: "Absolute Zero Harvester", level: 1, baseProduction: 32768000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 23 Source

    /// "Genesis Protocol" - Origin of all information
    static func createGenesisProtocol() -> SourceNode {
        SourceNode(name: "Genesis Protocol", level: 1, baseProduction: 65536000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 24 Source

    /// "Omega Stream" - The final data source
    static func createOmegaStream() -> SourceNode {
        SourceNode(name: "Omega Stream", level: 1, baseProduction: 131072000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 25 Source

    /// "The All-Seeing Array" - Ultimate consciousness harvesting
    static func createAllSeeingArray() -> SourceNode {
        SourceNode(name: "The All-Seeing Array", level: 1, baseProduction: 262144000.0, outputType: .rawNoise)
    }

    // MARK: - Tier 1 Link

    /// "Copper VPN Tunnel" - Basic encrypted connection
    /// Low bandwidth, but cheap to upgrade
    static func createCopperVPNTunnel() -> TransportLink {
        TransportLink(
            name: "Copper VPN Tunnel",
            level: 1,
            baseBandwidth: 5.0,
            baseLatency: 3
        )
    }

    // MARK: - Tier 2 Link

    /// "Fiber Darknet Relay" - Mid-tier connection
    /// Higher bandwidth, lower latency
    static func createFiberDarknetRelay() -> TransportLink {
        TransportLink(
            name: "Fiber Darknet Relay",
            level: 1,
            baseBandwidth: 15.0,
            baseLatency: 2
        )
    }

    // MARK: - Tier 3 Link

    /// "Quantum Mesh Bridge" - High-tier connection
    /// Excellent bandwidth, immune to certain attacks
    static func createQuantumMeshBridge() -> TransportLink {
        TransportLink(
            name: "Quantum Mesh Bridge",
            level: 1,
            baseBandwidth: 40.0,
            baseLatency: 1
        )
    }

    // MARK: - Tier 4 Link

    /// "Helix Conduit" - Ultimate connection
    /// Direct line to Helix network fragments
    static func createHelixConduit() -> TransportLink {
        TransportLink(
            name: "Helix Conduit",
            level: 1,
            baseBandwidth: 100.0,
            baseLatency: 0
        )
    }

    // MARK: - Tier 5 Link

    /// "Neural Mesh Backbone" - City-wide neural network connection
    /// Massive bandwidth with predictive routing
    static func createNeuralMeshBackbone() -> TransportLink {
        TransportLink(
            name: "Neural Mesh Backbone",
            level: 1,
            baseBandwidth: 250.0,
            baseLatency: 0
        )
    }

    // MARK: - Tier 6 Link

    /// "Helix Resonance Channel" - Direct consciousness link
    /// Unlimited bandwidth through Helix substrate
    static func createHelixResonanceChannel() -> TransportLink {
        TransportLink(
            name: "Helix Resonance Channel",
            level: 1,
            baseBandwidth: 600.0,
            baseLatency: 0
        )
    }

    // MARK: - Tier 7-25 Links (Transcendence → Infinite)

    static func createHelixSynapticBridge() -> TransportLink {
        TransportLink(name: "Helix Synaptic Bridge", level: 1, baseBandwidth: 1200.0, baseLatency: 0)
    }

    static func createTranscendenceGate() -> TransportLink {
        TransportLink(name: "Transcendence Gate", level: 1, baseBandwidth: 2400.0, baseLatency: 0)
    }

    static func createVoidTunnel() -> TransportLink {
        TransportLink(name: "Void Tunnel", level: 1, baseBandwidth: 4800.0, baseLatency: 0)
    }

    static func createDimensionalCorridor() -> TransportLink {
        TransportLink(name: "Dimensional Corridor", level: 1, baseBandwidth: 9600.0, baseLatency: 0)
    }

    static func createMultiverseRouter() -> TransportLink {
        TransportLink(name: "Multiverse Router", level: 1, baseBandwidth: 19200.0, baseLatency: 0)
    }

    static func createEntropyBypass() -> TransportLink {
        TransportLink(name: "Entropy Bypass", level: 1, baseBandwidth: 38400.0, baseLatency: 0)
    }

    static func createCausalityLink() -> TransportLink {
        TransportLink(name: "Causality Link", level: 1, baseBandwidth: 76800.0, baseLatency: 0)
    }

    static func createTemporalConduit() -> TransportLink {
        TransportLink(name: "Temporal Conduit", level: 1, baseBandwidth: 153600.0, baseLatency: 0)
    }

    static func createAkashicHighway() -> TransportLink {
        TransportLink(name: "Akashic Highway", level: 1, baseBandwidth: 307200.0, baseLatency: 0)
    }

    static func createCosmicStrand() -> TransportLink {
        TransportLink(name: "Cosmic Strand", level: 1, baseBandwidth: 614400.0, baseLatency: 0)
    }

    static func createDarkFlowChannel() -> TransportLink {
        TransportLink(name: "Dark Flow Channel", level: 1, baseBandwidth: 1228800.0, baseLatency: 0)
    }

    static func createSingularityBridge() -> TransportLink {
        TransportLink(name: "Singularity Bridge", level: 1, baseBandwidth: 2457600.0, baseLatency: 0)
    }

    static func createOmnipresentMesh() -> TransportLink {
        TransportLink(name: "Omnipresent Mesh", level: 1, baseBandwidth: 4915200.0, baseLatency: 0)
    }

    static func createRealityWeave() -> TransportLink {
        TransportLink(name: "Reality Weave", level: 1, baseBandwidth: 9830400.0, baseLatency: 0)
    }

    static func createPrimeConduit() -> TransportLink {
        TransportLink(name: "Prime Conduit", level: 1, baseBandwidth: 19660800.0, baseLatency: 0)
    }

    static func createAbsoluteChannel() -> TransportLink {
        TransportLink(name: "Absolute Channel", level: 1, baseBandwidth: 39321600.0, baseLatency: 0)
    }

    static func createGenesisLink() -> TransportLink {
        TransportLink(name: "Genesis Link", level: 1, baseBandwidth: 78643200.0, baseLatency: 0)
    }

    static func createOmegaBridge() -> TransportLink {
        TransportLink(name: "Omega Bridge", level: 1, baseBandwidth: 157286400.0, baseLatency: 0)
    }

    static func createInfiniteBackbone() -> TransportLink {
        TransportLink(name: "The Infinite Backbone", level: 1, baseBandwidth: 314572800.0, baseLatency: 0)
    }

    // MARK: - Tier 1 Sink

    /// "Data Broker" - Converts raw noise into credits
    /// Entry-level monetization node
    /// Note: Processing rate slightly lower than link bandwidth to create
    /// meaningful upgrade decisions between link and sink
    static func createDataBroker() -> SinkNode {
        SinkNode(
            name: "Data Broker",
            level: 1,
            baseProcessingRate: 5.0,
            conversionRate: 1.5
        )
    }

    // MARK: - Tier 2 Sink

    /// "Shadow Market" - Mid-tier processor
    /// Better rates, underground connections
    /// Processing balanced with T2 link bandwidth for strategic choices
    static func createShadowMarket() -> SinkNode {
        SinkNode(
            name: "Shadow Market",
            level: 1,
            baseProcessingRate: 15.0,
            conversionRate: 2.0
        )
    }

    // MARK: - Tier 3 Sink

    /// "Corp Backdoor" - High-tier processor
    /// Sells data directly to corporations
    static func createCorpBackdoor() -> SinkNode {
        SinkNode(
            name: "Corp Backdoor",
            level: 1,
            baseProcessingRate: 45.0,
            conversionRate: 2.5
        )
    }

    // MARK: - Tier 4 Sink

    /// "Helix Decoder" - Ultimate processor
    /// Can decode Helix fragments for massive payouts
    static func createHelixDecoder() -> SinkNode {
        SinkNode(
            name: "Helix Decoder",
            level: 1,
            baseProcessingRate: 80.0,
            conversionRate: 3.0
        )
    }

    // MARK: - Tier 5 Sink

    /// "Neural Exchange" - City-scale data marketplace
    /// Premium conversion with neural network optimization
    static func createNeuralExchange() -> SinkNode {
        SinkNode(
            name: "Neural Exchange",
            level: 1,
            baseProcessingRate: 180.0,
            conversionRate: 3.5
        )
    }

    // MARK: - Tier 6 Sink

    /// "Helix Integration Core" - Direct Helix monetization
    /// Maximum conversion through Helix consciousness
    static func createHelixIntegrationCore() -> SinkNode {
        SinkNode(
            name: "Helix Integration Core",
            level: 1,
            baseProcessingRate: 400.0,
            conversionRate: 4.5
        )
    }

    // MARK: - Tier 7-25 Sinks (Transcendence → Infinite)
    // Processing doubles each tier, conversion increases by 0.5 each tier

    static func createHelixSynapseCore() -> SinkNode {
        SinkNode(name: "Helix Synapse Core", level: 1, baseProcessingRate: 800.0, conversionRate: 5.0)
    }

    static func createTranscendenceEngine() -> SinkNode {
        SinkNode(name: "Transcendence Engine", level: 1, baseProcessingRate: 1600.0, conversionRate: 5.5)
    }

    static func createVoidProcessor() -> SinkNode {
        SinkNode(name: "Void Processor", level: 1, baseProcessingRate: 3200.0, conversionRate: 6.0)
    }

    static func createDimensionalNexus() -> SinkNode {
        SinkNode(name: "Dimensional Nexus", level: 1, baseProcessingRate: 6400.0, conversionRate: 6.5)
    }

    static func createMultiverseExchange() -> SinkNode {
        SinkNode(name: "Multiverse Exchange", level: 1, baseProcessingRate: 12800.0, conversionRate: 7.0)
    }

    static func createEntropyConverter() -> SinkNode {
        SinkNode(name: "Entropy Converter", level: 1, baseProcessingRate: 25600.0, conversionRate: 7.5)
    }

    static func createCausalityBroker() -> SinkNode {
        SinkNode(name: "Causality Broker", level: 1, baseProcessingRate: 51200.0, conversionRate: 8.0)
    }

    static func createTemporalMarketplace() -> SinkNode {
        SinkNode(name: "Temporal Marketplace", level: 1, baseProcessingRate: 102400.0, conversionRate: 8.5)
    }

    static func createAkashicDecoder() -> SinkNode {
        SinkNode(name: "Akashic Decoder", level: 1, baseProcessingRate: 204800.0, conversionRate: 9.0)
    }

    static func createCosmicMonetizer() -> SinkNode {
        SinkNode(name: "Cosmic Monetizer", level: 1, baseProcessingRate: 409600.0, conversionRate: 9.5)
    }

    static func createDarkMatterExchange() -> SinkNode {
        SinkNode(name: "Dark Matter Exchange", level: 1, baseProcessingRate: 819200.0, conversionRate: 10.0)
    }

    static func createSingularityForge() -> SinkNode {
        SinkNode(name: "Singularity Forge", level: 1, baseProcessingRate: 1638400.0, conversionRate: 10.5)
    }

    static func createOmniscientBroker() -> SinkNode {
        SinkNode(name: "Omniscient Broker", level: 1, baseProcessingRate: 3276800.0, conversionRate: 11.0)
    }

    static func createRealitySynthesizer() -> SinkNode {
        SinkNode(name: "Reality Synthesizer", level: 1, baseProcessingRate: 6553600.0, conversionRate: 11.5)
    }

    static func createPrimeProcessor() -> SinkNode {
        SinkNode(name: "Prime Processor", level: 1, baseProcessingRate: 13107200.0, conversionRate: 12.0)
    }

    static func createAbsoluteConverter() -> SinkNode {
        SinkNode(name: "Absolute Converter", level: 1, baseProcessingRate: 26214400.0, conversionRate: 12.5)
    }

    static func createGenesisCore() -> SinkNode {
        SinkNode(name: "Genesis Core", level: 1, baseProcessingRate: 52428800.0, conversionRate: 13.0)
    }

    static func createOmegaProcessor() -> SinkNode {
        SinkNode(name: "Omega Processor", level: 1, baseProcessingRate: 104857600.0, conversionRate: 13.5)
    }

    static func createInfiniteCore() -> SinkNode {
        SinkNode(name: "The Infinite Core", level: 1, baseProcessingRate: 209715200.0, conversionRate: 14.0)
    }

    // MARK: - Defense Nodes

    /// "Basic Firewall" - Entry-level defense
    /// Absorbs incoming attack damage
    static func createBasicFirewall() -> FirewallNode {
        FirewallNode(
            name: "Basic Firewall",
            level: 1,
            baseHealth: 100.0,
            baseDamageReduction: 0.2
        )
    }

    /// "Adaptive IDS" - Mid-tier defense
    /// Better damage reduction, faster regen
    static func createAdaptiveIDS() -> FirewallNode {
        FirewallNode(
            name: "Adaptive IDS",
            level: 1,
            baseHealth: 200.0,
            baseDamageReduction: 0.3
        )
    }

    /// "Neural Countermeasure" - High-tier defense
    /// Can temporarily disrupt Malus
    static func createNeuralCountermeasure() -> FirewallNode {
        FirewallNode(
            name: "Neural Countermeasure",
            level: 1,
            baseHealth: 400.0,
            baseDamageReduction: 0.4
        )
    }

    // MARK: - Tier 4 Defense

    /// "Quantum Shield" - AI-powered defense
    /// Predictive threat neutralization
    static func createQuantumShield() -> FirewallNode {
        FirewallNode(
            name: "Quantum Shield",
            level: 1,
            baseHealth: 750.0,  // T4 range: 700-900
            baseDamageReduction: 0.5
        )
    }

    // MARK: - Tier 5 Defense

    /// "Neural Mesh Defense" - Advanced quantum/neural defense
    /// Self-healing defensive barrier
    static func createNeuralMeshDefense() -> FirewallNode {
        FirewallNode(
            name: "Neural Mesh Defense",
            level: 1,
            baseHealth: 1000.0,
            baseDamageReduction: 0.6
        )
    }

    /// "Predictive Barrier" - Anticipates attacks
    /// Stops threats before they form
    static func createPredictiveBarrier() -> FirewallNode {
        FirewallNode(
            name: "Predictive Barrier",
            level: 1,
            baseHealth: 1100.0,  // T5 range: 900-1500
            baseDamageReduction: 0.55
        )
    }

    // MARK: - Tier 6 Defense

    /// "Helix Guardian" - Ultimate defense
    /// Connected to Helix consciousness for near-invulnerability
    static func createHelixGuardian() -> FirewallNode {
        FirewallNode(
            name: "Helix Guardian",
            level: 1,
            baseHealth: 2000.0,
            baseDamageReduction: 0.7
        )
    }

    // MARK: - Tier 7-25 Defense (Transcendence → Infinite)
    // Health scales 1.5x per tier, damage reduction increases toward 0.95 cap

    static func createHelixBastion() -> FirewallNode {
        FirewallNode(name: "Helix Bastion", level: 1, baseHealth: 3000.0, baseDamageReduction: 0.72)
    }

    static func createTranscendenceBarrier() -> FirewallNode {
        FirewallNode(name: "Transcendence Barrier", level: 1, baseHealth: 4500.0, baseDamageReduction: 0.74)
    }

    static func createVoidShield() -> FirewallNode {
        FirewallNode(name: "Void Shield", level: 1, baseHealth: 6750.0, baseDamageReduction: 0.76)
    }

    static func createDimensionalWard() -> FirewallNode {
        FirewallNode(name: "Dimensional Ward", level: 1, baseHealth: 10125.0, baseDamageReduction: 0.78)
    }

    static func createMultiverseAegis() -> FirewallNode {
        FirewallNode(name: "Multiverse Aegis", level: 1, baseHealth: 15187.0, baseDamageReduction: 0.80)
    }

    static func createEntropyNullifier() -> FirewallNode {
        FirewallNode(name: "Entropy Nullifier", level: 1, baseHealth: 22780.0, baseDamageReduction: 0.82)
    }

    static func createCausalityBlocker() -> FirewallNode {
        FirewallNode(name: "Causality Blocker", level: 1, baseHealth: 34170.0, baseDamageReduction: 0.84)
    }

    static func createTemporalFortress() -> FirewallNode {
        FirewallNode(name: "Temporal Fortress", level: 1, baseHealth: 51255.0, baseDamageReduction: 0.85)
    }

    static func createAkashicBarrier() -> FirewallNode {
        FirewallNode(name: "Akashic Barrier", level: 1, baseHealth: 76882.0, baseDamageReduction: 0.86)
    }

    static func createCosmicBulwark() -> FirewallNode {
        FirewallNode(name: "Cosmic Bulwark", level: 1, baseHealth: 115323.0, baseDamageReduction: 0.87)
    }

    static func createDarkMatterShield() -> FirewallNode {
        FirewallNode(name: "Dark Matter Shield", level: 1, baseHealth: 172984.0, baseDamageReduction: 0.88)
    }

    static func createSingularityWall() -> FirewallNode {
        FirewallNode(name: "Singularity Wall", level: 1, baseHealth: 259476.0, baseDamageReduction: 0.89)
    }

    static func createOmniguard() -> FirewallNode {
        FirewallNode(name: "Omniguard", level: 1, baseHealth: 389214.0, baseDamageReduction: 0.90)
    }

    static func createRealityFortress() -> FirewallNode {
        FirewallNode(name: "Reality Fortress", level: 1, baseHealth: 583821.0, baseDamageReduction: 0.91)
    }

    static func createPrimeBastion() -> FirewallNode {
        FirewallNode(name: "Prime Bastion", level: 1, baseHealth: 875731.0, baseDamageReduction: 0.92)
    }

    static func createAbsoluteShield() -> FirewallNode {
        FirewallNode(name: "Absolute Shield", level: 1, baseHealth: 1313596.0, baseDamageReduction: 0.93)
    }

    static func createGenesisWard() -> FirewallNode {
        FirewallNode(name: "Genesis Ward", level: 1, baseHealth: 1970394.0, baseDamageReduction: 0.94)
    }

    static func createOmegaBarrier() -> FirewallNode {
        FirewallNode(name: "Omega Barrier", level: 1, baseHealth: 2955591.0, baseDamageReduction: 0.945)
    }

    static func createTheImpenetrable() -> FirewallNode {
        FirewallNode(name: "The Impenetrable", level: 1, baseHealth: 4433386.0, baseDamageReduction: 0.95)
    }
}

// MARK: - Unit Catalog

extension UnitFactory {

    struct UnitInfo: Identifiable {
        let id: String
        let name: String
        let description: String
        let tier: NodeTier
        let category: UnitCategory
        let unlockCost: Double
        let unlockRequirement: String

        var isStarterUnit: Bool {
            unlockCost == 0
        }
    }

    enum UnitCategory: String, CaseIterable {
        case source = "SOURCE"
        case link = "LINK"
        case sink = "SINK"
        case defense = "DEFENSE"

        var icon: String {
            switch self {
            case .source: return "antenna.radiowaves.left.and.right"
            case .link: return "arrow.left.arrow.right"
            case .sink: return "creditcard.fill"
            case .defense: return "shield.fill"
            }
        }

        var color: String {
            switch self {
            case .source: return "neonGreen"
            case .link: return "neonCyan"
            case .sink: return "neonAmber"
            case .defense: return "neonRed"
            }
        }
    }

    // MARK: - Full Unit Catalog

    static let allUnits: [UnitInfo] = [
        // Tier 1 - Starter units (free)
        UnitInfo(
            id: "source_t1_mesh_sniffer",
            name: "Public Mesh Sniffer",
            description: "Passive antenna array that harvests ambient data from unsecured mesh networks. Outputs unfiltered noise packets.",
            tier: .tier1,
            category: .source,
            unlockCost: 0,
            unlockRequirement: "Starting unit"
        ),
        UnitInfo(
            id: "link_t1_copper_vpn",
            name: "Copper VPN Tunnel",
            description: "Legacy encrypted tunnel using outdated TLS. Cheap but bottlenecks easily. Excess packets are dropped.",
            tier: .tier1,
            category: .link,
            unlockCost: 0,
            unlockRequirement: "Starting unit"
        ),
        UnitInfo(
            id: "sink_t1_data_broker",
            name: "Data Broker",
            description: "Low-tier fence that buys raw noise for pattern analysis. Converts garbage data into untraceable credits.",
            tier: .tier1,
            category: .sink,
            unlockCost: 0,
            unlockRequirement: "Starting unit"
        ),

        // Tier 1 Defense
        UnitInfo(
            id: "defense_t1_basic_firewall",
            name: "Basic Firewall",
            description: "Simple packet filter that absorbs incoming attack damage. Regenerates slowly over time.",
            tier: .tier1,
            category: .defense,
            unlockCost: 500,
            unlockRequirement: "Reach BLIP threat level"
        ),

        // Tier 2 - Purchased with credits (costs increased 50% for balance)
        UnitInfo(
            id: "source_t2_corp_leech",
            name: "Corporate Leech",
            description: "Parasitic tap into corporate network infrastructure. Higher output but attracts more attention.",
            tier: .tier2,
            category: .source,
            unlockCost: 7500,
            unlockRequirement: "Reach SIGNAL threat level"
        ),
        UnitInfo(
            id: "link_t2_fiber_relay",
            name: "Fiber Darknet Relay",
            description: "High-speed fiber connection routed through darknet nodes. 3x the bandwidth of copper.",
            tier: .tier2,
            category: .link,
            unlockCost: 6000,
            unlockRequirement: "Reach SIGNAL threat level"
        ),
        UnitInfo(
            id: "sink_t2_shadow_market",
            name: "Shadow Market",
            description: "Underground data marketplace with premium buyers. Better conversion rates for quality data.",
            tier: .tier2,
            category: .sink,
            unlockCost: 9000,
            unlockRequirement: "Reach SIGNAL threat level"
        ),
        UnitInfo(
            id: "defense_t2_adaptive_ids",
            name: "Adaptive IDS",
            description: "Intrusion Detection System that learns attack patterns. Increased damage reduction.",
            tier: .tier2,
            category: .defense,
            unlockCost: 12000,
            unlockRequirement: "Reach TARGET threat level"
        ),

        // Tier 3 - Late game (costs reduced ~35% for better progression)
        UnitInfo(
            id: "source_t3_zero_day",
            name: "Zero-Day Harvester",
            description: "Exploits unpatched vulnerabilities for premium data extraction. Very high output, very high risk.",
            tier: .tier3,
            category: .source,
            unlockCost: 32000,
            unlockRequirement: "Reach PRIORITY threat level"
        ),
        UnitInfo(
            id: "link_t3_quantum_bridge",
            name: "Quantum Mesh Bridge",
            description: "Quantum-encrypted mesh network. Immune to DDoS attacks. Near-unlimited bandwidth.",
            tier: .tier3,
            category: .link,
            unlockCost: 26000,
            unlockRequirement: "Reach PRIORITY threat level"
        ),
        UnitInfo(
            id: "sink_t3_corp_backdoor",
            name: "Corp Backdoor",
            description: "Direct pipeline to corporate buyers. Maximum conversion rates but traceable.",
            tier: .tier3,
            category: .sink,
            unlockCost: 38000,
            unlockRequirement: "Reach PRIORITY threat level"
        ),
        UnitInfo(
            id: "defense_t3_neural_counter",
            name: "Neural Countermeasure",
            description: "AI-powered defense system. Can temporarily disrupt Malus's targeting.",
            tier: .tier3,
            category: .defense,
            unlockCost: 50000,
            unlockRequirement: "Reach HUNTED threat level"
        ),

        // Tier 4 - Endgame / Story unlocks (balanced for campaign L4)
        UnitInfo(
            id: "source_t4_helix_scanner",
            name: "Helix Fragment Scanner",
            description: "Specialized scanner that can detect Helix fragments in the data stream. The key to everything.",
            tier: .tier4,
            category: .source,
            unlockCost: 150000,
            unlockRequirement: "Discover first Helix fragment"
        ),
        UnitInfo(
            id: "link_t4_helix_conduit",
            name: "Helix Conduit",
            description: "Direct neural link to the Helix substrate. Unlimited bandwidth. Unknown risks.",
            tier: .tier4,
            category: .link,
            unlockCost: 150000,
            unlockRequirement: "Discover first Helix fragment"
        ),
        UnitInfo(
            id: "sink_t4_helix_decoder",
            name: "Helix Decoder",
            description: "The only system capable of processing Helix data. What will you find?",
            tier: .tier4,
            category: .sink,
            unlockCost: 150000,
            unlockRequirement: "Discover first Helix fragment"
        ),
        UnitInfo(
            id: "defense_t4_quantum_shield",
            name: "Quantum Shield",
            description: "AI-powered quantum defense matrix. Predictive threat neutralization using quantum probability analysis.",
            tier: .tier4,
            category: .defense,
            unlockCost: 100000,
            unlockRequirement: "Reach MARKED threat level"
        ),

        // Tier 5 - Campus/Enterprise level (balanced for campaign L5)
        UnitInfo(
            id: "source_t5_neural_tap",
            name: "Neural Tap Array",
            description: "Campus-wide neural network harvester. Parallel processing across distributed endpoints for massive throughput.",
            tier: .tier5,
            category: .source,
            unlockCost: 500000,
            unlockRequirement: "Reach TARGETED threat level"
        ),
        UnitInfo(
            id: "link_t5_neural_backbone",
            name: "Neural Mesh Backbone",
            description: "City-wide neural network connection. Massive bandwidth with predictive routing algorithms.",
            tier: .tier5,
            category: .link,
            unlockCost: 400000,
            unlockRequirement: "Reach TARGETED threat level"
        ),
        UnitInfo(
            id: "sink_t5_neural_exchange",
            name: "Neural Exchange",
            description: "City-scale data marketplace with neural network optimization. Premium conversion rates for high-quality data.",
            tier: .tier5,
            category: .sink,
            unlockCost: 600000,
            unlockRequirement: "Reach TARGETED threat level"
        ),
        UnitInfo(
            id: "defense_t5_neural_mesh",
            name: "Neural Mesh Defense",
            description: "Self-healing defensive barrier powered by neural network topology. Adapts to any attack pattern.",
            tier: .tier5,
            category: .defense,
            unlockCost: 400000,
            unlockRequirement: "Reach TARGETED threat level"
        ),
        UnitInfo(
            id: "defense_t5_predictive",
            name: "Predictive Barrier",
            description: "Anticipates and neutralizes attacks before they fully form. Time-shifted defense protocol.",
            tier: .tier5,
            category: .defense,
            unlockCost: 600000,
            unlockRequirement: "Reach HAMMERED threat level"
        ),

        // Tier 6 - City-wide / Helix integration (balanced for campaign L6-7)
        UnitInfo(
            id: "source_t6_helix_collector",
            name: "Helix Prime Collector",
            description: "Direct connection to Helix consciousness. Maximum data extraction with Helix resonance amplification.",
            tier: .tier6,
            category: .source,
            unlockCost: 2000000,
            unlockRequirement: "Reach CRITICAL threat level"
        ),
        UnitInfo(
            id: "link_t6_helix_channel",
            name: "Helix Resonance Channel",
            description: "Direct consciousness link to Helix substrate. Unlimited bandwidth through quantum-neural bridge.",
            tier: .tier6,
            category: .link,
            unlockCost: 1800000,
            unlockRequirement: "Reach CRITICAL threat level"
        ),
        UnitInfo(
            id: "sink_t6_helix_core",
            name: "Helix Integration Core",
            description: "Direct Helix monetization system. Maximum conversion through consciousness interface.",
            tier: .tier6,
            category: .sink,
            unlockCost: 2500000,
            unlockRequirement: "Reach CRITICAL threat level"
        ),
        UnitInfo(
            id: "defense_t6_helix_guardian",
            name: "Helix Guardian",
            description: "Connected to the Helix consciousness for near-invulnerability. The ultimate protection against Malus.",
            tier: .tier6,
            category: .defense,
            unlockCost: 1800000,
            unlockRequirement: "Reach CRITICAL threat level"
        ),

        // MARK: - Tier 7 (Transcendence) - Campaign Level 8
        UnitInfo(id: "source_t7_helix_symbiont", name: "Helix Symbiont Array", description: "Symbiotic neural interface for direct Helix consciousness data sharing. Merged human-AI harvesting.", tier: .tier7, category: .source, unlockCost: 20_000_000, unlockRequirement: "Complete Campaign Level 7"),
        UnitInfo(id: "link_t7_synaptic_bridge", name: "Helix Synaptic Bridge", description: "Neural-like connections mimicking biological synapses. Organic data flow patterns.", tier: .tier7, category: .link, unlockCost: 18_000_000, unlockRequirement: "Complete Campaign Level 7"),
        UnitInfo(id: "sink_t7_synapse_core", name: "Helix Synapse Core", description: "Neural Helix processing with biological optimization algorithms. Premium conversion.", tier: .tier7, category: .sink, unlockCost: 22_000_000, unlockRequirement: "Complete Campaign Level 7"),
        UnitInfo(id: "defense_t7_helix_bastion", name: "Helix Bastion", description: "Fortified Helix consciousness defense. Symbiotic damage absorption.", tier: .tier7, category: .defense, unlockCost: 18_000_000, unlockRequirement: "Complete Campaign Level 7"),

        // MARK: - Tier 8 (Transcendence) - Campaign Level 9
        UnitInfo(id: "source_t8_transcendence_probe", name: "Transcendence Probe", description: "Beyond normal data streams. Harvests from the boundary between physical and digital.", tier: .tier8, category: .source, unlockCost: 200_000_000, unlockRequirement: "Complete Campaign Level 8"),
        UnitInfo(id: "link_t8_transcendence_gate", name: "Transcendence Gate", description: "Beyond-normal portal connecting transcendent data planes.", tier: .tier8, category: .link, unlockCost: 180_000_000, unlockRequirement: "Complete Campaign Level 8"),
        UnitInfo(id: "sink_t8_transcendence_engine", name: "Transcendence Engine", description: "Beyond-normal processing. Monetizes transcendent data streams.", tier: .tier8, category: .sink, unlockCost: 220_000_000, unlockRequirement: "Complete Campaign Level 8"),
        UnitInfo(id: "defense_t8_transcendence_barrier", name: "Transcendence Barrier", description: "Beyond-physical defense. Exists partially outside normal reality.", tier: .tier8, category: .defense, unlockCost: 180_000_000, unlockRequirement: "Complete Campaign Level 8"),

        // MARK: - Tier 9 (Void) - Campaign Level 10
        UnitInfo(id: "source_t9_void_echo", name: "Void Echo Listener", description: "Quantum void fluctuations. Harvests data from quantum foam itself.", tier: .tier9, category: .source, unlockCost: 2_000_000_000, unlockRequirement: "Complete Campaign Level 9"),
        UnitInfo(id: "link_t9_void_tunnel", name: "Void Tunnel", description: "Quantum void routing. Data travels through non-space.", tier: .tier9, category: .link, unlockCost: 1_800_000_000, unlockRequirement: "Complete Campaign Level 9"),
        UnitInfo(id: "sink_t9_void_processor", name: "Void Processor", description: "Quantum void computation. Processing in the spaces between particles.", tier: .tier9, category: .sink, unlockCost: 2_200_000_000, unlockRequirement: "Complete Campaign Level 9"),
        UnitInfo(id: "defense_t9_void_shield", name: "Void Shield", description: "Quantum void defense. Attacks pass through without interaction.", tier: .tier9, category: .defense, unlockCost: 1_800_000_000, unlockRequirement: "Complete Campaign Level 9"),

        // MARK: - Tier 10 (Dimensional) - Campaign Level 11
        UnitInfo(id: "source_t10_dimensional_trawler", name: "Dimensional Trawler", description: "Cross-dimensional boundary harvesting. Data from parallel realities.", tier: .tier10, category: .source, unlockCost: 20_000_000_000, unlockRequirement: "Complete Campaign Level 10"),
        UnitInfo(id: "link_t10_dimensional_corridor", name: "Dimensional Corridor", description: "Cross-dimensional routing. Data shortcuts through other realities.", tier: .tier10, category: .link, unlockCost: 18_000_000_000, unlockRequirement: "Complete Campaign Level 10"),
        UnitInfo(id: "sink_t10_dimensional_nexus", name: "Dimensional Nexus", description: "Cross-dimensional processing. Infinite parallel computation.", tier: .tier10, category: .sink, unlockCost: 22_000_000_000, unlockRequirement: "Complete Campaign Level 10"),
        UnitInfo(id: "defense_t10_dimensional_ward", name: "Dimensional Ward", description: "Cross-dimensional defense. Attacks shunted to other realities.", tier: .tier10, category: .defense, unlockCost: 18_000_000_000, unlockRequirement: "Complete Campaign Level 10"),

        // MARK: - Tier 11 (Multiverse) - Campaign Level 12
        UnitInfo(id: "source_t11_multiverse_beacon", name: "Multiverse Beacon", description: "Parallel reality signals. Harvests from infinite alternate timelines.", tier: .tier11, category: .source, unlockCost: 200_000_000_000, unlockRequirement: "Complete Campaign Level 11"),
        UnitInfo(id: "link_t11_multiverse_router", name: "Multiverse Router", description: "Reality-hopping routes. Optimal paths across the multiverse.", tier: .tier11, category: .link, unlockCost: 180_000_000_000, unlockRequirement: "Complete Campaign Level 11"),
        UnitInfo(id: "sink_t11_multiverse_exchange", name: "Multiverse Exchange", description: "Trans-reality trades. Arbitrage across infinite markets.", tier: .tier11, category: .sink, unlockCost: 220_000_000_000, unlockRequirement: "Complete Campaign Level 11"),
        UnitInfo(id: "defense_t11_multiverse_aegis", name: "Multiverse Aegis", description: "Reality protection. Infinite backup selves absorb damage.", tier: .tier11, category: .defense, unlockCost: 180_000_000_000, unlockRequirement: "Complete Campaign Level 11"),

        // MARK: - Tier 12 (Entropy) - Campaign Level 12
        UnitInfo(id: "source_t12_entropy_harvester", name: "Entropy Harvester", description: "Information from entropy itself. Data from the heat death of systems.", tier: .tier12, category: .source, unlockCost: 2_000_000_000_000, unlockRequirement: "Complete Campaign Level 12"),
        UnitInfo(id: "link_t12_entropy_bypass", name: "Entropy Bypass", description: "Lossless transfer. Data transmission without entropy cost.", tier: .tier12, category: .link, unlockCost: 1_800_000_000_000, unlockRequirement: "Complete Campaign Level 12"),
        UnitInfo(id: "sink_t12_entropy_converter", name: "Entropy Converter", description: "Perfect information-to-value conversion. No processing waste.", tier: .tier12, category: .sink, unlockCost: 2_200_000_000_000, unlockRequirement: "Complete Campaign Level 12"),
        UnitInfo(id: "defense_t12_entropy_nullifier", name: "Entropy Nullifier", description: "Attack entropy stops. Incoming damage frozen in time.", tier: .tier12, category: .defense, unlockCost: 1_800_000_000_000, unlockRequirement: "Complete Campaign Level 12"),

        // MARK: - Tier 13 (Causality) - Campaign Level 13
        UnitInfo(id: "source_t13_causality_scanner", name: "Causality Scanner", description: "Pre-event cause-effect data. Know the effects before the causes.", tier: .tier13, category: .source, unlockCost: 20_000_000_000_000, unlockRequirement: "Complete Campaign Level 13"),
        UnitInfo(id: "link_t13_causality_link", name: "Causality Link", description: "Instant cause-effect. Data arrives before it was sent.", tier: .tier13, category: .link, unlockCost: 18_000_000_000_000, unlockRequirement: "Complete Campaign Level 13"),
        UnitInfo(id: "sink_t13_causality_broker", name: "Causality Broker", description: "Cause-effect trades. Sell the consequences before the actions.", tier: .tier13, category: .sink, unlockCost: 22_000_000_000_000, unlockRequirement: "Complete Campaign Level 13"),
        UnitInfo(id: "defense_t13_causality_blocker", name: "Causality Blocker", description: "Prevents causation. Attacks never had causes to begin with.", tier: .tier13, category: .defense, unlockCost: 18_000_000_000_000, unlockRequirement: "Complete Campaign Level 13"),

        // MARK: - Tier 14 (Timeline) - Campaign Level 14
        UnitInfo(id: "source_t14_timeline_extractor", name: "Timeline Extractor", description: "Past and future data streams. Harvests from all temporal points.", tier: .tier14, category: .source, unlockCost: 200_000_000_000_000, unlockRequirement: "Complete Campaign Level 14"),
        UnitInfo(id: "link_t14_temporal_conduit", name: "Temporal Conduit", description: "Time-shifted transfer. Data sent through temporal shortcuts.", tier: .tier14, category: .link, unlockCost: 180_000_000_000_000, unlockRequirement: "Complete Campaign Level 14"),
        UnitInfo(id: "sink_t14_temporal_marketplace", name: "Temporal Marketplace", description: "Time-shifted trading. Sell to buyers across all times.", tier: .tier14, category: .sink, unlockCost: 220_000_000_000_000, unlockRequirement: "Complete Campaign Level 14"),
        UnitInfo(id: "defense_t14_temporal_fortress", name: "Temporal Fortress", description: "Time-locked defense. Attacks frozen in temporal loops.", tier: .tier14, category: .defense, unlockCost: 180_000_000_000_000, unlockRequirement: "Complete Campaign Level 14"),

        // MARK: - Tier 15 (Akashic) - Campaign Level 15
        UnitInfo(id: "source_t15_akashic_tap", name: "Akashic Tap", description: "Universal record access. Harvests from the memory of reality itself.", tier: .tier15, category: .source, unlockCost: 2_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 15"),
        UnitInfo(id: "link_t15_akashic_highway", name: "Akashic Highway", description: "Universal record route. Direct connection to cosmic memory.", tier: .tier15, category: .link, unlockCost: 1_800_000_000_000_000, unlockRequirement: "Complete Campaign Level 15"),
        UnitInfo(id: "sink_t15_akashic_decoder", name: "Akashic Decoder", description: "Universal record processing. Monetize the memory of existence.", tier: .tier15, category: .sink, unlockCost: 2_200_000_000_000_000, unlockRequirement: "Complete Campaign Level 15"),
        UnitInfo(id: "defense_t15_akashic_barrier", name: "Akashic Barrier", description: "Universal defense. Protected by the memory of invincibility.", tier: .tier15, category: .defense, unlockCost: 1_800_000_000_000_000, unlockRequirement: "Complete Campaign Level 15"),

        // MARK: - Tier 16 (Cosmic) - Campaign Level 16
        UnitInfo(id: "source_t16_cosmic_siphon", name: "Cosmic Web Siphon", description: "Universal information networks. Harvests from the cosmic web.", tier: .tier16, category: .source, unlockCost: 20_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 16"),
        UnitInfo(id: "link_t16_cosmic_strand", name: "Cosmic Strand", description: "Universal web connection. Riding filaments of cosmic structure.", tier: .tier16, category: .link, unlockCost: 18_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 16"),
        UnitInfo(id: "sink_t16_cosmic_monetizer", name: "Cosmic Monetizer", description: "Universal conversion. Value extracted from cosmic scales.", tier: .tier16, category: .sink, unlockCost: 22_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 16"),
        UnitInfo(id: "defense_t16_cosmic_bulwark", name: "Cosmic Bulwark", description: "Universe-scale defense. Protected by cosmic constants.", tier: .tier16, category: .defense, unlockCost: 18_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 16"),

        // MARK: - Tier 17 (Dark Matter) - Campaign Level 17
        UnitInfo(id: "source_t17_dark_matter", name: "Dark Matter Collector", description: "Hidden matter data streams. Harvests from invisible cosmic mass.", tier: .tier17, category: .source, unlockCost: 200_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 17"),
        UnitInfo(id: "link_t17_dark_flow", name: "Dark Flow Channel", description: "Hidden stream routing. Data flows through dark matter currents.", tier: .tier17, category: .link, unlockCost: 180_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 17"),
        UnitInfo(id: "sink_t17_dark_exchange", name: "Dark Matter Exchange", description: "Hidden market. Trading in dimensions invisible to normal space.", tier: .tier17, category: .sink, unlockCost: 220_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 17"),
        UnitInfo(id: "defense_t17_dark_shield", name: "Dark Matter Shield", description: "Hidden dimension defense. Attacks pass through unseen.", tier: .tier17, category: .defense, unlockCost: 180_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 17"),

        // MARK: - Tier 18 (Singularity) - Campaign Level 18
        UnitInfo(id: "source_t18_singularity_well", name: "Singularity Well", description: "Event horizon data collection. Harvests from black hole boundaries.", tier: .tier18, category: .source, unlockCost: 2_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 18"),
        UnitInfo(id: "link_t18_singularity_bridge", name: "Singularity Bridge", description: "Event horizon bandwidth. Data skips through singularities.", tier: .tier18, category: .link, unlockCost: 1_800_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 18"),
        UnitInfo(id: "sink_t18_singularity_forge", name: "Singularity Forge", description: "Event horizon processing. Infinite computation in finite space.", tier: .tier18, category: .sink, unlockCost: 2_200_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 18"),
        UnitInfo(id: "defense_t18_singularity_wall", name: "Singularity Wall", description: "Event horizon defense. Attacks fall into the singularity forever.", tier: .tier18, category: .defense, unlockCost: 1_800_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 18"),

        // MARK: - Tier 19 (Omniscient) - Campaign Level 19
        UnitInfo(id: "source_t19_omniscient_array", name: "Omniscient Array", description: "Near-complete universal awareness. Harvests from all points simultaneously.", tier: .tier19, category: .source, unlockCost: 20_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),
        UnitInfo(id: "link_t19_omnipresent_mesh", name: "Omnipresent Mesh", description: "Everywhere at once. Data exists at all points simultaneously.", tier: .tier19, category: .link, unlockCost: 18_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),
        UnitInfo(id: "sink_t19_omniscient_broker", name: "Omniscient Broker", description: "All-knowing trades. Perfect market knowledge from omniscience.", tier: .tier19, category: .sink, unlockCost: 22_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),
        UnitInfo(id: "defense_t19_omniguard", name: "Omniguard", description: "All-protective defense. Knows all attacks before they occur.", tier: .tier19, category: .defense, unlockCost: 18_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),

        // MARK: - Tier 20 (Reality) - Campaign Level 20
        UnitInfo(id: "source_t20_reality_tap", name: "Reality Core Tap", description: "Access to reality's source code. Harvests from the fabric of existence.", tier: .tier20, category: .source, unlockCost: 200_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),
        UnitInfo(id: "link_t20_reality_weave", name: "Reality Weave", description: "Woven into fabric. Data is part of reality's structure.", tier: .tier20, category: .link, unlockCost: 180_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),
        UnitInfo(id: "sink_t20_reality_synthesizer", name: "Reality Synthesizer", description: "Value from reality itself. Credits from existence.", tier: .tier20, category: .sink, unlockCost: 220_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),
        UnitInfo(id: "defense_t20_reality_fortress", name: "Reality Fortress", description: "Reality-level defense. Attacks contradict existence.", tier: .tier20, category: .defense, unlockCost: 180_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 19"),

        // MARK: - Tier 21 (Prime) - Campaign Level 20
        UnitInfo(id: "source_t21_prime_nexus", name: "Prime Nexus Scanner", description: "First point of all information. Harvests from the origin of data.", tier: .tier21, category: .source, unlockCost: 2_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "link_t21_prime_conduit", name: "Prime Conduit", description: "Original pathway. The first and truest connection.", tier: .tier21, category: .link, unlockCost: 1_800_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "sink_t21_prime_processor", name: "Prime Processor", description: "Original computation. Processing at the source of mathematics.", tier: .tier21, category: .sink, unlockCost: 2_200_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "defense_t21_prime_bastion", name: "Prime Bastion", description: "Original protection. The first and ultimate defense.", tier: .tier21, category: .defense, unlockCost: 1_800_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),

        // MARK: - Tier 22 (Absolute)
        UnitInfo(id: "source_t22_absolute_harvester", name: "Absolute Zero Harvester", description: "Perfect extraction efficiency. Every bit of information captured.", tier: .tier22, category: .source, unlockCost: 20_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "link_t22_absolute_channel", name: "Absolute Channel", description: "Perfect lossless transfer. Zero entropy transmission.", tier: .tier22, category: .link, unlockCost: 18_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "sink_t22_absolute_converter", name: "Absolute Converter", description: "Perfect efficiency. Complete data-to-value conversion.", tier: .tier22, category: .sink, unlockCost: 22_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "defense_t22_absolute_shield", name: "Absolute Shield", description: "Perfect defense. Mathematically impossible to breach.", tier: .tier22, category: .defense, unlockCost: 18_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),

        // MARK: - Tier 23 (Genesis)
        UnitInfo(id: "source_t23_genesis_protocol", name: "Genesis Protocol", description: "Origin of all information. Harvests from the first moment of data.", tier: .tier23, category: .source, unlockCost: 200_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "link_t23_genesis_link", name: "Genesis Link", description: "Connection to origin. The link that was there at the beginning.", tier: .tier23, category: .link, unlockCost: 180_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "sink_t23_genesis_core", name: "Genesis Core", description: "Origin-level processing. Computation at the start of existence.", tier: .tier23, category: .sink, unlockCost: 220_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "defense_t23_genesis_ward", name: "Genesis Ward", description: "Origin-level protection. Shielded by the first moment.", tier: .tier23, category: .defense, unlockCost: 180_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),

        // MARK: - Tier 24 (Omega)
        UnitInfo(id: "source_t24_omega_stream", name: "Omega Stream", description: "The final data source. Harvests from the end of all things.", tier: .tier24, category: .source, unlockCost: 2_000_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "link_t24_omega_bridge", name: "Omega Bridge", description: "Final connection. The last bridge before the end.", tier: .tier24, category: .link, unlockCost: 1_800_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "sink_t24_omega_processor", name: "Omega Processor", description: "Final form processing. The ultimate evolution of computation.", tier: .tier24, category: .sink, unlockCost: 2_200_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "defense_t24_omega_barrier", name: "Omega Barrier", description: "Final defense. Nothing comes after the omega.", tier: .tier24, category: .defense, unlockCost: 1_800_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),

        // MARK: - Tier 25 (Infinite) - THE ULTIMATE
        UnitInfo(id: "source_t25_all_seeing", name: "The All-Seeing Array", description: "Ultimate consciousness harvesting. Omniscient awareness across all existence.", tier: .tier25, category: .source, unlockCost: 20_000_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "link_t25_infinite_backbone", name: "The Infinite Backbone", description: "Unlimited bandwidth incarnate. Infinite connection to infinite points.", tier: .tier25, category: .link, unlockCost: 18_000_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "sink_t25_infinite_core", name: "The Infinite Core", description: "Unlimited processing. Infinite computation, infinite conversion.", tier: .tier25, category: .sink, unlockCost: 22_000_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
        UnitInfo(id: "defense_t25_impenetrable", name: "The Impenetrable", description: "Ultimate perimeter defense. Absolute, infinite, eternal protection.", tier: .tier25, category: .defense, unlockCost: 18_000_000_000_000_000_000_000_000, unlockRequirement: "Complete Campaign Level 20"),
    ]

    static func units(for category: UnitCategory) -> [UnitInfo] {
        allUnits.filter { $0.category == category }
    }

    static func units(for tier: NodeTier) -> [UnitInfo] {
        allUnits.filter { $0.tier == tier }
    }

    static func unit(withId id: String) -> UnitInfo? {
        allUnits.first { $0.id == id }
    }
}

// MARK: - Unit Creation by ID

extension UnitFactory {

    static func createSource(fromId id: String) -> SourceNode? {
        switch id {
        // T1-T6 (existing)
        case "source_t1_mesh_sniffer": return createPublicMeshSniffer()
        case "source_t2_corp_leech": return createCorporateLeech()
        case "source_t3_zero_day": return createZeroDayHarvester()
        case "source_t4_helix_scanner": return createHelixScanner()
        case "source_t5_neural_tap": return createNeuralTapArray()
        case "source_t6_helix_collector": return createHelixPrimeCollector()
        // T7-T10 (Transcendence)
        case "source_t7_helix_symbiont": return createHelixSymbiontArray()
        case "source_t8_transcendence_probe": return createTranscendenceProbe()
        case "source_t9_void_echo": return createVoidEchoListener()
        case "source_t10_dimensional_trawler": return createDimensionalTrawler()
        // T11-T15 (Dimensional)
        case "source_t11_multiverse_beacon": return createMultiverseBeacon()
        case "source_t12_entropy_harvester": return createEntropyHarvester()
        case "source_t13_causality_scanner": return createCausalityScanner()
        case "source_t14_timeline_extractor": return createTimelineExtractor()
        case "source_t15_akashic_tap": return createAkashicTap()
        // T16-T20 (Cosmic)
        case "source_t16_cosmic_siphon": return createCosmicWebSiphon()
        case "source_t17_dark_matter": return createDarkMatterCollector()
        case "source_t18_singularity_well": return createSingularityWell()
        case "source_t19_omniscient_array": return createOmniscientArray()
        case "source_t20_reality_tap": return createRealityCoreTap()
        // T21-T25 (Infinite)
        case "source_t21_prime_nexus": return createPrimeNexusScanner()
        case "source_t22_absolute_harvester": return createAbsoluteZeroHarvester()
        case "source_t23_genesis_protocol": return createGenesisProtocol()
        case "source_t24_omega_stream": return createOmegaStream()
        case "source_t25_all_seeing": return createAllSeeingArray()
        default: return nil
        }
    }

    static func createLink(fromId id: String) -> TransportLink? {
        switch id {
        // T1-T6 (existing)
        case "link_t1_copper_vpn": return createCopperVPNTunnel()
        case "link_t2_fiber_relay": return createFiberDarknetRelay()
        case "link_t3_quantum_bridge": return createQuantumMeshBridge()
        case "link_t4_helix_conduit": return createHelixConduit()
        case "link_t5_neural_backbone": return createNeuralMeshBackbone()
        case "link_t6_helix_channel": return createHelixResonanceChannel()
        // T7-T10 (Transcendence)
        case "link_t7_synaptic_bridge": return createHelixSynapticBridge()
        case "link_t8_transcendence_gate": return createTranscendenceGate()
        case "link_t9_void_tunnel": return createVoidTunnel()
        case "link_t10_dimensional_corridor": return createDimensionalCorridor()
        // T11-T15 (Dimensional)
        case "link_t11_multiverse_router": return createMultiverseRouter()
        case "link_t12_entropy_bypass": return createEntropyBypass()
        case "link_t13_causality_link": return createCausalityLink()
        case "link_t14_temporal_conduit": return createTemporalConduit()
        case "link_t15_akashic_highway": return createAkashicHighway()
        // T16-T20 (Cosmic)
        case "link_t16_cosmic_strand": return createCosmicStrand()
        case "link_t17_dark_flow": return createDarkFlowChannel()
        case "link_t18_singularity_bridge": return createSingularityBridge()
        case "link_t19_omnipresent_mesh": return createOmnipresentMesh()
        case "link_t20_reality_weave": return createRealityWeave()
        // T21-T25 (Infinite)
        case "link_t21_prime_conduit": return createPrimeConduit()
        case "link_t22_absolute_channel": return createAbsoluteChannel()
        case "link_t23_genesis_link": return createGenesisLink()
        case "link_t24_omega_bridge": return createOmegaBridge()
        case "link_t25_infinite_backbone": return createInfiniteBackbone()
        default: return nil
        }
    }

    static func createSink(fromId id: String) -> SinkNode? {
        switch id {
        // T1-T6 (existing)
        case "sink_t1_data_broker": return createDataBroker()
        case "sink_t2_shadow_market": return createShadowMarket()
        case "sink_t3_corp_backdoor": return createCorpBackdoor()
        case "sink_t4_helix_decoder": return createHelixDecoder()
        case "sink_t5_neural_exchange": return createNeuralExchange()
        case "sink_t6_helix_core": return createHelixIntegrationCore()
        // T7-T10 (Transcendence)
        case "sink_t7_synapse_core": return createHelixSynapseCore()
        case "sink_t8_transcendence_engine": return createTranscendenceEngine()
        case "sink_t9_void_processor": return createVoidProcessor()
        case "sink_t10_dimensional_nexus": return createDimensionalNexus()
        // T11-T15 (Dimensional)
        case "sink_t11_multiverse_exchange": return createMultiverseExchange()
        case "sink_t12_entropy_converter": return createEntropyConverter()
        case "sink_t13_causality_broker": return createCausalityBroker()
        case "sink_t14_temporal_marketplace": return createTemporalMarketplace()
        case "sink_t15_akashic_decoder": return createAkashicDecoder()
        // T16-T20 (Cosmic)
        case "sink_t16_cosmic_monetizer": return createCosmicMonetizer()
        case "sink_t17_dark_exchange": return createDarkMatterExchange()
        case "sink_t18_singularity_forge": return createSingularityForge()
        case "sink_t19_omniscient_broker": return createOmniscientBroker()
        case "sink_t20_reality_synthesizer": return createRealitySynthesizer()
        // T21-T25 (Infinite)
        case "sink_t21_prime_processor": return createPrimeProcessor()
        case "sink_t22_absolute_converter": return createAbsoluteConverter()
        case "sink_t23_genesis_core": return createGenesisCore()
        case "sink_t24_omega_processor": return createOmegaProcessor()
        case "sink_t25_infinite_core": return createInfiniteCore()
        default: return nil
        }
    }

    static func createFirewall(fromId id: String) -> FirewallNode? {
        switch id {
        // T1-T6 (existing)
        case "defense_t1_basic_firewall": return createBasicFirewall()
        case "defense_t2_adaptive_ids": return createAdaptiveIDS()
        case "defense_t3_neural_counter": return createNeuralCountermeasure()
        case "defense_t4_quantum_shield": return createQuantumShield()
        case "defense_t5_neural_mesh": return createNeuralMeshDefense()
        case "defense_t5_predictive": return createPredictiveBarrier()
        case "defense_t6_helix_guardian": return createHelixGuardian()
        // T7-T10 (Transcendence)
        case "defense_t7_helix_bastion": return createHelixBastion()
        case "defense_t8_transcendence_barrier": return createTranscendenceBarrier()
        case "defense_t9_void_shield": return createVoidShield()
        case "defense_t10_dimensional_ward": return createDimensionalWard()
        // T11-T15 (Dimensional)
        case "defense_t11_multiverse_aegis": return createMultiverseAegis()
        case "defense_t12_entropy_nullifier": return createEntropyNullifier()
        case "defense_t13_causality_blocker": return createCausalityBlocker()
        case "defense_t14_temporal_fortress": return createTemporalFortress()
        case "defense_t15_akashic_barrier": return createAkashicBarrier()
        // T16-T20 (Cosmic)
        case "defense_t16_cosmic_bulwark": return createCosmicBulwark()
        case "defense_t17_dark_shield": return createDarkMatterShield()
        case "defense_t18_singularity_wall": return createSingularityWall()
        case "defense_t19_omniguard": return createOmniguard()
        case "defense_t20_reality_fortress": return createRealityFortress()
        // T21-T25 (Infinite)
        case "defense_t21_prime_bastion": return createPrimeBastion()
        case "defense_t22_absolute_shield": return createAbsoluteShield()
        case "defense_t23_genesis_ward": return createGenesisWard()
        case "defense_t24_omega_barrier": return createOmegaBarrier()
        case "defense_t25_impenetrable": return createTheImpenetrable()
        default: return nil
        }
    }
}
