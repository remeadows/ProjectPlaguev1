// DefenseApplication.swift
// GridWatchZero
// Security application progression chains for network defense

import Foundation

// MARK: - Defense Application Category

enum DefenseCategory: String, Codable, CaseIterable {
    case firewall = "FIREWALL"
    case siem = "SIEM"
    case endpoint = "ENDPOINT"
    case ids = "IDS"
    case network = "NETWORK"
    case encryption = "ENCRYPTION"

    var displayName: String {
        switch self {
        case .firewall: return "Perimeter Defense"
        case .siem: return "Log Analysis"
        case .endpoint: return "Endpoint Protection"
        case .ids: return "Intrusion Detection"
        case .network: return "Network Security"
        case .encryption: return "Data Protection"
        }
    }

    var icon: String {
        switch self {
        case .firewall: return "flame.fill"
        case .siem: return "list.bullet.rectangle.fill"
        case .endpoint: return "desktopcomputer"
        case .ids: return "eye.trianglebadge.exclamationmark.fill"
        case .network: return "network"
        case .encryption: return "lock.shield.fill"
        }
    }

    var baseColor: String {
        switch self {
        case .firewall: return "neonRed"
        case .siem: return "neonCyan"
        case .endpoint: return "neonGreen"
        case .ids: return "neonAmber"
        case .network: return "neonCyan"
        case .encryption: return "neonGreen"
        }
    }

    /// Progression chain for this category (T1-T25)
    var progressionChain: [DefenseAppTier] {
        switch self {
        case .firewall:
            return [
                .firewallBasic, .firewallNGFW, .firewallAIML, .firewallQuantum, .firewallNeural, .firewallHelix,
                .firewallSymbiont, .firewallTranscendence, .firewallVoid, .firewallDimensional,
                .firewallMultiverse, .firewallEntropy, .firewallCausality, .firewallTimeline, .firewallAkashic,
                .firewallCosmic, .firewallDarkMatter, .firewallSingularity, .firewallOmniscient, .firewallReality,
                .firewallPrime, .firewallAbsolute, .firewallGenesis, .firewallOmega, .firewallInfinite
            ]
        case .siem:
            return [
                .siemSyslog, .siemSIEM, .siemSOAR, .siemAI, .siemPredictive, .siemHelix,
                .siemSymbiont, .siemTranscendence, .siemVoid, .siemDimensional,
                .siemMultiverse, .siemEntropy, .siemCausality, .siemTimeline, .siemAkashic,
                .siemCosmic, .siemDarkMatter, .siemSingularity, .siemOmniscient, .siemReality,
                .siemPrime, .siemAbsolute, .siemGenesis, .siemOmega, .siemInfinite
            ]
        case .endpoint:
            return [
                .endpointEDR, .endpointXDR, .endpointMXDR, .endpointAI, .endpointAutonomous, .endpointHelix,
                .endpointSymbiont, .endpointTranscendence, .endpointVoid, .endpointDimensional,
                .endpointMultiverse, .endpointEntropy, .endpointCausality, .endpointTimeline, .endpointAkashic,
                .endpointCosmic, .endpointDarkMatter, .endpointSingularity, .endpointOmniscient, .endpointReality,
                .endpointPrime, .endpointAbsolute, .endpointGenesis, .endpointOmega, .endpointInfinite
            ]
        case .ids:
            return [
                .idsBasic, .idsIPS, .idsMLIPS, .idsAI, .idsQuantum, .idsHelix,
                .idsSymbiont, .idsTranscendence, .idsVoid, .idsDimensional,
                .idsMultiverse, .idsEntropy, .idsCausality, .idsTimeline, .idsAkashic,
                .idsCosmic, .idsDarkMatter, .idsSingularity, .idsOmniscient, .idsReality,
                .idsPrime, .idsAbsolute, .idsGenesis, .idsOmega, .idsInfinite
            ]
        case .network:
            return [
                .networkRouter, .networkISR, .networkCloudISR, .networkEncrypted, .networkNeural, .networkHelix,
                .networkSymbiont, .networkTranscendence, .networkVoid, .networkDimensional,
                .networkMultiverse, .networkEntropy, .networkCausality, .networkTimeline, .networkAkashic,
                .networkCosmic, .networkDarkMatter, .networkSingularity, .networkOmniscient, .networkReality,
                .networkPrime, .networkAbsolute, .networkGenesis, .networkOmega, .networkInfinite
            ]
        case .encryption:
            return [
                .encryptionBasic, .encryptionAdvanced, .encryptionQuantum, .encryptionNeural, .encryptionHelix,
                .encryptionSymbiont, .encryptionTranscendence, .encryptionVoid, .encryptionDimensional, .encryptionMultiverse,
                .encryptionEntropy, .encryptionCausality, .encryptionTimeline, .encryptionAkashic, .encryptionCosmic,
                .encryptionDarkMatter, .encryptionSingularity, .encryptionOmniscient, .encryptionReality, .encryptionPrime,
                .encryptionAbsolute, .encryptionGenesis, .encryptionOmega, .encryptionInfinite, .encryptionUltimate
            ]
        }
    }
}

// MARK: - Defense Application Tier

enum DefenseAppTier: String, Codable, CaseIterable {
    // MARK: - Firewall Chain (T1-T25)
    // T1-T6: Real-world cybersecurity
    case firewallBasic = "firewall_basic"              // T1
    case firewallNGFW = "firewall_ngfw"                // T2
    case firewallAIML = "firewall_aiml"                // T3
    case firewallQuantum = "firewall_quantum"          // T4
    case firewallNeural = "firewall_neural"            // T5
    case firewallHelix = "firewall_helix"              // T6
    // T7-T10: Transcendence
    case firewallSymbiont = "firewall_symbiont"        // T7
    case firewallTranscendence = "firewall_transcendence" // T8
    case firewallVoid = "firewall_void"                // T9
    case firewallDimensional = "firewall_dimensional"  // T10
    // T11-T15: Dimensional
    case firewallMultiverse = "firewall_multiverse"    // T11
    case firewallEntropy = "firewall_entropy"          // T12
    case firewallCausality = "firewall_causality"      // T13
    case firewallTimeline = "firewall_timeline"        // T14
    case firewallAkashic = "firewall_akashic"          // T15
    // T16-T20: Cosmic
    case firewallCosmic = "firewall_cosmic"            // T16
    case firewallDarkMatter = "firewall_darkmatter"    // T17
    case firewallSingularity = "firewall_singularity"  // T18
    case firewallOmniscient = "firewall_omniscient"    // T19
    case firewallReality = "firewall_reality"          // T20
    // T21-T25: Infinite
    case firewallPrime = "firewall_prime"              // T21
    case firewallAbsolute = "firewall_absolute"        // T22
    case firewallGenesis = "firewall_genesis"          // T23
    case firewallOmega = "firewall_omega"              // T24
    case firewallInfinite = "firewall_infinite"        // T25

    // MARK: - SIEM Chain (T1-T25)
    case siemSyslog = "siem_syslog"                    // T1
    case siemSIEM = "siem_siem"                        // T2
    case siemSOAR = "siem_soar"                        // T3
    case siemAI = "siem_ai"                            // T4
    case siemPredictive = "siem_predictive"            // T5
    case siemHelix = "siem_helix"                      // T6
    // T7-T10: Transcendence
    case siemSymbiont = "siem_symbiont"                // T7
    case siemTranscendence = "siem_transcendence"      // T8
    case siemVoid = "siem_void"                        // T9
    case siemDimensional = "siem_dimensional"          // T10
    // T11-T15: Dimensional
    case siemMultiverse = "siem_multiverse"            // T11
    case siemEntropy = "siem_entropy"                  // T12
    case siemCausality = "siem_causality"              // T13
    case siemTimeline = "siem_timeline"                // T14
    case siemAkashic = "siem_akashic"                  // T15
    // T16-T20: Cosmic
    case siemCosmic = "siem_cosmic"                    // T16
    case siemDarkMatter = "siem_darkmatter"            // T17
    case siemSingularity = "siem_singularity"          // T18
    case siemOmniscient = "siem_omniscient"            // T19
    case siemReality = "siem_reality"                  // T20
    // T21-T25: Infinite
    case siemPrime = "siem_prime"                      // T21
    case siemAbsolute = "siem_absolute"                // T22
    case siemGenesis = "siem_genesis"                  // T23
    case siemOmega = "siem_omega"                      // T24
    case siemInfinite = "siem_infinite"                // T25

    // MARK: - Endpoint Chain (T1-T25)
    case endpointEDR = "endpoint_edr"                  // T1
    case endpointXDR = "endpoint_xdr"                  // T2
    case endpointMXDR = "endpoint_mxdr"                // T3
    case endpointAI = "endpoint_ai"                    // T4
    case endpointAutonomous = "endpoint_autonomous"    // T5
    case endpointHelix = "endpoint_helix"              // T6
    // T7-T10: Transcendence
    case endpointSymbiont = "endpoint_symbiont"        // T7
    case endpointTranscendence = "endpoint_transcendence" // T8
    case endpointVoid = "endpoint_void"                // T9
    case endpointDimensional = "endpoint_dimensional"  // T10
    // T11-T15: Dimensional
    case endpointMultiverse = "endpoint_multiverse"    // T11
    case endpointEntropy = "endpoint_entropy"          // T12
    case endpointCausality = "endpoint_causality"      // T13
    case endpointTimeline = "endpoint_timeline"        // T14
    case endpointAkashic = "endpoint_akashic"          // T15
    // T16-T20: Cosmic
    case endpointCosmic = "endpoint_cosmic"            // T16
    case endpointDarkMatter = "endpoint_darkmatter"    // T17
    case endpointSingularity = "endpoint_singularity"  // T18
    case endpointOmniscient = "endpoint_omniscient"    // T19
    case endpointReality = "endpoint_reality"          // T20
    // T21-T25: Infinite
    case endpointPrime = "endpoint_prime"              // T21
    case endpointAbsolute = "endpoint_absolute"        // T22
    case endpointGenesis = "endpoint_genesis"          // T23
    case endpointOmega = "endpoint_omega"              // T24
    case endpointInfinite = "endpoint_infinite"        // T25

    // MARK: - IDS Chain (T1-T25)
    case idsBasic = "ids_basic"                        // T1
    case idsIPS = "ids_ips"                            // T2
    case idsMLIPS = "ids_mlips"                        // T3
    case idsAI = "ids_ai"                              // T4
    case idsQuantum = "ids_quantum"                    // T5
    case idsHelix = "ids_helix"                        // T6
    // T7-T10: Transcendence
    case idsSymbiont = "ids_symbiont"                  // T7
    case idsTranscendence = "ids_transcendence"        // T8
    case idsVoid = "ids_void"                          // T9
    case idsDimensional = "ids_dimensional"            // T10
    // T11-T15: Dimensional
    case idsMultiverse = "ids_multiverse"              // T11
    case idsEntropy = "ids_entropy"                    // T12
    case idsCausality = "ids_causality"                // T13
    case idsTimeline = "ids_timeline"                  // T14
    case idsAkashic = "ids_akashic"                    // T15
    // T16-T20: Cosmic
    case idsCosmic = "ids_cosmic"                      // T16
    case idsDarkMatter = "ids_darkmatter"              // T17
    case idsSingularity = "ids_singularity"            // T18
    case idsOmniscient = "ids_omniscient"              // T19
    case idsReality = "ids_reality"                    // T20
    // T21-T25: Infinite
    case idsPrime = "ids_prime"                        // T21
    case idsAbsolute = "ids_absolute"                  // T22
    case idsGenesis = "ids_genesis"                    // T23
    case idsOmega = "ids_omega"                        // T24
    case idsInfinite = "ids_infinite"                  // T25

    // MARK: - Network Chain (T1-T25)
    case networkRouter = "network_router"              // T1
    case networkISR = "network_isr"                    // T2
    case networkCloudISR = "network_cloud"             // T3
    case networkEncrypted = "network_encrypted"        // T4
    case networkNeural = "network_neural"              // T5
    case networkHelix = "network_helix"                // T6
    // T7-T10: Transcendence
    case networkSymbiont = "network_symbiont"          // T7
    case networkTranscendence = "network_transcendence" // T8
    case networkVoid = "network_void"                  // T9
    case networkDimensional = "network_dimensional"    // T10
    // T11-T15: Dimensional
    case networkMultiverse = "network_multiverse"      // T11
    case networkEntropy = "network_entropy"            // T12
    case networkCausality = "network_causality"        // T13
    case networkTimeline = "network_timeline"          // T14
    case networkAkashic = "network_akashic"            // T15
    // T16-T20: Cosmic
    case networkCosmic = "network_cosmic"              // T16
    case networkDarkMatter = "network_darkmatter"      // T17
    case networkSingularity = "network_singularity"    // T18
    case networkOmniscient = "network_omniscient"      // T19
    case networkReality = "network_reality"            // T20
    // T21-T25: Infinite
    case networkPrime = "network_prime"                // T21
    case networkAbsolute = "network_absolute"          // T22
    case networkGenesis = "network_genesis"            // T23
    case networkOmega = "network_omega"                // T24
    case networkInfinite = "network_infinite"          // T25

    // MARK: - Encryption Chain (T1-T25)
    case encryptionBasic = "encryption_basic"          // T1
    case encryptionAdvanced = "encryption_advanced"    // T2
    case encryptionQuantum = "encryption_quantum"      // T3
    case encryptionNeural = "encryption_neural"        // T4
    case encryptionHelix = "encryption_helix"          // T5
    // Note: T6 added for consistency
    case encryptionSymbiont = "encryption_symbiont"    // T6
    // T7-T10: Transcendence
    case encryptionTranscendence = "encryption_transcendence" // T7
    case encryptionVoid = "encryption_void"            // T8
    case encryptionDimensional = "encryption_dimensional" // T9
    case encryptionMultiverse = "encryption_multiverse" // T10
    // T11-T15: Dimensional
    case encryptionEntropy = "encryption_entropy"      // T11
    case encryptionCausality = "encryption_causality"  // T12
    case encryptionTimeline = "encryption_timeline"    // T13
    case encryptionAkashic = "encryption_akashic"      // T14
    case encryptionCosmic = "encryption_cosmic"        // T15
    // T16-T20: Cosmic
    case encryptionDarkMatter = "encryption_darkmatter" // T16
    case encryptionSingularity = "encryption_singularity" // T17
    case encryptionOmniscient = "encryption_omniscient" // T18
    case encryptionReality = "encryption_reality"      // T19
    case encryptionPrime = "encryption_prime"          // T20
    // T21-T25: Infinite
    case encryptionAbsolute = "encryption_absolute"    // T21
    case encryptionGenesis = "encryption_genesis"      // T22
    case encryptionOmega = "encryption_omega"          // T23
    case encryptionInfinite = "encryption_infinite"    // T24
    case encryptionUltimate = "encryption_ultimate"    // T25

    var category: DefenseCategory {
        switch self {
        // Firewall (all 25 tiers)
        case .firewallBasic, .firewallNGFW, .firewallAIML, .firewallQuantum, .firewallNeural, .firewallHelix,
             .firewallSymbiont, .firewallTranscendence, .firewallVoid, .firewallDimensional,
             .firewallMultiverse, .firewallEntropy, .firewallCausality, .firewallTimeline, .firewallAkashic,
             .firewallCosmic, .firewallDarkMatter, .firewallSingularity, .firewallOmniscient, .firewallReality,
             .firewallPrime, .firewallAbsolute, .firewallGenesis, .firewallOmega, .firewallInfinite:
            return .firewall
        // SIEM (all 25 tiers)
        case .siemSyslog, .siemSIEM, .siemSOAR, .siemAI, .siemPredictive, .siemHelix,
             .siemSymbiont, .siemTranscendence, .siemVoid, .siemDimensional,
             .siemMultiverse, .siemEntropy, .siemCausality, .siemTimeline, .siemAkashic,
             .siemCosmic, .siemDarkMatter, .siemSingularity, .siemOmniscient, .siemReality,
             .siemPrime, .siemAbsolute, .siemGenesis, .siemOmega, .siemInfinite:
            return .siem
        // Endpoint (all 25 tiers)
        case .endpointEDR, .endpointXDR, .endpointMXDR, .endpointAI, .endpointAutonomous, .endpointHelix,
             .endpointSymbiont, .endpointTranscendence, .endpointVoid, .endpointDimensional,
             .endpointMultiverse, .endpointEntropy, .endpointCausality, .endpointTimeline, .endpointAkashic,
             .endpointCosmic, .endpointDarkMatter, .endpointSingularity, .endpointOmniscient, .endpointReality,
             .endpointPrime, .endpointAbsolute, .endpointGenesis, .endpointOmega, .endpointInfinite:
            return .endpoint
        // IDS (all 25 tiers)
        case .idsBasic, .idsIPS, .idsMLIPS, .idsAI, .idsQuantum, .idsHelix,
             .idsSymbiont, .idsTranscendence, .idsVoid, .idsDimensional,
             .idsMultiverse, .idsEntropy, .idsCausality, .idsTimeline, .idsAkashic,
             .idsCosmic, .idsDarkMatter, .idsSingularity, .idsOmniscient, .idsReality,
             .idsPrime, .idsAbsolute, .idsGenesis, .idsOmega, .idsInfinite:
            return .ids
        // Network (all 25 tiers)
        case .networkRouter, .networkISR, .networkCloudISR, .networkEncrypted, .networkNeural, .networkHelix,
             .networkSymbiont, .networkTranscendence, .networkVoid, .networkDimensional,
             .networkMultiverse, .networkEntropy, .networkCausality, .networkTimeline, .networkAkashic,
             .networkCosmic, .networkDarkMatter, .networkSingularity, .networkOmniscient, .networkReality,
             .networkPrime, .networkAbsolute, .networkGenesis, .networkOmega, .networkInfinite:
            return .network
        // Encryption (all 25 tiers)
        case .encryptionBasic, .encryptionAdvanced, .encryptionQuantum, .encryptionNeural, .encryptionHelix,
             .encryptionSymbiont, .encryptionTranscendence, .encryptionVoid, .encryptionDimensional, .encryptionMultiverse,
             .encryptionEntropy, .encryptionCausality, .encryptionTimeline, .encryptionAkashic, .encryptionCosmic,
             .encryptionDarkMatter, .encryptionSingularity, .encryptionOmniscient, .encryptionReality, .encryptionPrime,
             .encryptionAbsolute, .encryptionGenesis, .encryptionOmega, .encryptionInfinite, .encryptionUltimate:
            return .encryption
        }
    }

    var displayName: String {
        switch self {
        // Firewall T1-T6
        case .firewallBasic: return "Basic Firewall"
        case .firewallNGFW: return "NGFW"
        case .firewallAIML: return "AI/ML Firewall"
        case .firewallQuantum: return "Quantum Firewall"
        case .firewallNeural: return "Neural Barrier"
        case .firewallHelix: return "Helix Shield"
        // Firewall T7-T10
        case .firewallSymbiont: return "Symbiont Wall"
        case .firewallTranscendence: return "Transcendence Barrier"
        case .firewallVoid: return "Void Shield"
        case .firewallDimensional: return "Dimensional Barrier"
        // Firewall T11-T15
        case .firewallMultiverse: return "Multiverse Wall"
        case .firewallEntropy: return "Entropy Shield"
        case .firewallCausality: return "Causality Barrier"
        case .firewallTimeline: return "Timeline Shield"
        case .firewallAkashic: return "Akashic Wall"
        // Firewall T16-T20
        case .firewallCosmic: return "Cosmic Barrier"
        case .firewallDarkMatter: return "Dark Matter Shield"
        case .firewallSingularity: return "Singularity Wall"
        case .firewallOmniscient: return "Omniscient Barrier"
        case .firewallReality: return "Reality Shield"
        // Firewall T21-T25
        case .firewallPrime: return "Prime Barrier"
        case .firewallAbsolute: return "Absolute Shield"
        case .firewallGenesis: return "Genesis Wall"
        case .firewallOmega: return "Omega Barrier"
        case .firewallInfinite: return "Infinite Shield"

        // SIEM T1-T6
        case .siemSyslog: return "Syslog Server"
        case .siemSIEM: return "SIEM Platform"
        case .siemSOAR: return "SOAR System"
        case .siemAI: return "AI Analytics"
        case .siemPredictive: return "Predictive SIEM"
        case .siemHelix: return "Helix Insight"
        // SIEM T7-T10
        case .siemSymbiont: return "Symbiont Analytics"
        case .siemTranscendence: return "Transcendence SIEM"
        case .siemVoid: return "Void Insight"
        case .siemDimensional: return "Dimensional SIEM"
        // SIEM T11-T15
        case .siemMultiverse: return "Multiverse Analytics"
        case .siemEntropy: return "Entropy SIEM"
        case .siemCausality: return "Causality Insight"
        case .siemTimeline: return "Timeline SIEM"
        case .siemAkashic: return "Akashic Records"
        // SIEM T16-T20
        case .siemCosmic: return "Cosmic Analytics"
        case .siemDarkMatter: return "Dark Matter SIEM"
        case .siemSingularity: return "Singularity Insight"
        case .siemOmniscient: return "Omniscient SIEM"
        case .siemReality: return "Reality Analytics"
        // SIEM T21-T25
        case .siemPrime: return "Prime Insight"
        case .siemAbsolute: return "Absolute SIEM"
        case .siemGenesis: return "Genesis Analytics"
        case .siemOmega: return "Omega Insight"
        case .siemInfinite: return "Infinite SIEM"

        // Endpoint T1-T6
        case .endpointEDR: return "EDR Agent"
        case .endpointXDR: return "XDR Platform"
        case .endpointMXDR: return "MXDR Service"
        case .endpointAI: return "AI Protection"
        case .endpointAutonomous: return "Autonomous Response"
        case .endpointHelix: return "Helix Sentinel"
        // Endpoint T7-T10
        case .endpointSymbiont: return "Symbiont Agent"
        case .endpointTranscendence: return "Transcendence EDR"
        case .endpointVoid: return "Void Sentinel"
        case .endpointDimensional: return "Dimensional Agent"
        // Endpoint T11-T15
        case .endpointMultiverse: return "Multiverse Sentinel"
        case .endpointEntropy: return "Entropy Agent"
        case .endpointCausality: return "Causality Sentinel"
        case .endpointTimeline: return "Timeline Agent"
        case .endpointAkashic: return "Akashic Sentinel"
        // Endpoint T16-T20
        case .endpointCosmic: return "Cosmic Agent"
        case .endpointDarkMatter: return "Dark Matter Sentinel"
        case .endpointSingularity: return "Singularity Agent"
        case .endpointOmniscient: return "Omniscient Sentinel"
        case .endpointReality: return "Reality Agent"
        // Endpoint T21-T25
        case .endpointPrime: return "Prime Sentinel"
        case .endpointAbsolute: return "Absolute Agent"
        case .endpointGenesis: return "Genesis Sentinel"
        case .endpointOmega: return "Omega Agent"
        case .endpointInfinite: return "Infinite Sentinel"

        // IDS T1-T6
        case .idsBasic: return "IDS Sensor"
        case .idsIPS: return "IPS Active"
        case .idsMLIPS: return "ML/IPS"
        case .idsAI: return "AI Detection"
        case .idsQuantum: return "Quantum IDS"
        case .idsHelix: return "Helix Watcher"
        // IDS T7-T10
        case .idsSymbiont: return "Symbiont IDS"
        case .idsTranscendence: return "Transcendence Watcher"
        case .idsVoid: return "Void IDS"
        case .idsDimensional: return "Dimensional Watcher"
        // IDS T11-T15
        case .idsMultiverse: return "Multiverse IDS"
        case .idsEntropy: return "Entropy Watcher"
        case .idsCausality: return "Causality IDS"
        case .idsTimeline: return "Timeline Watcher"
        case .idsAkashic: return "Akashic IDS"
        // IDS T16-T20
        case .idsCosmic: return "Cosmic Watcher"
        case .idsDarkMatter: return "Dark Matter IDS"
        case .idsSingularity: return "Singularity Watcher"
        case .idsOmniscient: return "Omniscient IDS"
        case .idsReality: return "Reality Watcher"
        // IDS T21-T25
        case .idsPrime: return "Prime IDS"
        case .idsAbsolute: return "Absolute Watcher"
        case .idsGenesis: return "Genesis IDS"
        case .idsOmega: return "Omega Watcher"
        case .idsInfinite: return "Infinite IDS"

        // Network T1-T6
        case .networkRouter: return "Edge Router"
        case .networkISR: return "ISR Gateway"
        case .networkCloudISR: return "Cloud ISR"
        case .networkEncrypted: return "Encrypted Mesh"
        case .networkNeural: return "Neural Mesh"
        case .networkHelix: return "Helix Conduit"
        // Network T7-T10
        case .networkSymbiont: return "Symbiont Mesh"
        case .networkTranscendence: return "Transcendence Network"
        case .networkVoid: return "Void Conduit"
        case .networkDimensional: return "Dimensional Mesh"
        // Network T11-T15
        case .networkMultiverse: return "Multiverse Network"
        case .networkEntropy: return "Entropy Conduit"
        case .networkCausality: return "Causality Mesh"
        case .networkTimeline: return "Timeline Network"
        case .networkAkashic: return "Akashic Conduit"
        // Network T16-T20
        case .networkCosmic: return "Cosmic Mesh"
        case .networkDarkMatter: return "Dark Matter Network"
        case .networkSingularity: return "Singularity Conduit"
        case .networkOmniscient: return "Omniscient Mesh"
        case .networkReality: return "Reality Network"
        // Network T21-T25
        case .networkPrime: return "Prime Conduit"
        case .networkAbsolute: return "Absolute Mesh"
        case .networkGenesis: return "Genesis Network"
        case .networkOmega: return "Omega Conduit"
        case .networkInfinite: return "Infinite Mesh"

        // Encryption T1-T6
        case .encryptionBasic: return "AES-256"
        case .encryptionAdvanced: return "E2E Crypto"
        case .encryptionQuantum: return "Quantum Safe"
        case .encryptionNeural: return "Neural Cipher"
        case .encryptionHelix: return "Helix Vault"
        case .encryptionSymbiont: return "Symbiont Cipher"
        // Encryption T7-T10
        case .encryptionTranscendence: return "Transcendence Vault"
        case .encryptionVoid: return "Void Cipher"
        case .encryptionDimensional: return "Dimensional Vault"
        case .encryptionMultiverse: return "Multiverse Cipher"
        // Encryption T11-T15
        case .encryptionEntropy: return "Entropy Vault"
        case .encryptionCausality: return "Causality Cipher"
        case .encryptionTimeline: return "Timeline Vault"
        case .encryptionAkashic: return "Akashic Cipher"
        case .encryptionCosmic: return "Cosmic Vault"
        // Encryption T16-T20
        case .encryptionDarkMatter: return "Dark Matter Cipher"
        case .encryptionSingularity: return "Singularity Vault"
        case .encryptionOmniscient: return "Omniscient Cipher"
        case .encryptionReality: return "Reality Vault"
        case .encryptionPrime: return "Prime Cipher"
        // Encryption T21-T25
        case .encryptionAbsolute: return "Absolute Vault"
        case .encryptionGenesis: return "Genesis Cipher"
        case .encryptionOmega: return "Omega Vault"
        case .encryptionInfinite: return "Infinite Cipher"
        case .encryptionUltimate: return "Ultimate Vault"
        }
    }

    var shortName: String {
        // Use tier number and category prefix for compact display
        let tierNum = tierNumber
        switch category {
        case .firewall:
            let base = tierNum <= 6 ? ["FW", "NGFW", "AI/ML", "Q-FW", "N-FW", "H-FW"][tierNum - 1] :
                       "FW\(tierNum)"
            return base
        case .siem:
            let base = tierNum <= 6 ? ["SYSLOG", "SIEM", "SOAR", "AI-SI", "P-SI", "H-SI"][tierNum - 1] :
                       "SI\(tierNum)"
            return base
        case .endpoint:
            let base = tierNum <= 6 ? ["EDR", "XDR", "MXDR", "AI-EP", "A-EP", "H-EP"][tierNum - 1] :
                       "EP\(tierNum)"
            return base
        case .ids:
            let base = tierNum <= 6 ? ["IDS", "IPS", "ML/IP", "AI-ID", "Q-ID", "H-ID"][tierNum - 1] :
                       "ID\(tierNum)"
            return base
        case .network:
            let base = tierNum <= 6 ? ["RTR", "ISR", "CISR", "ENC", "N-NET", "H-NET"][tierNum - 1] :
                       "NET\(tierNum)"
            return base
        case .encryption:
            let base = tierNum <= 6 ? ["AES", "E2E", "QSafe", "N-EN", "H-EN", "S-EN"][tierNum - 1] :
                       "EN\(tierNum)"
            return base
        }
    }

    var description: String {
        // T1-T6 have unique descriptions, T7+ use tier-themed descriptions
        let tier = tierNumber
        switch self {
        // Firewall T1-T6
        case .firewallBasic: return "Stateful packet inspection. Blocks known threats."
        case .firewallNGFW: return "Next-gen firewall with application awareness and deep packet inspection."
        case .firewallAIML: return "AI-powered threat detection. Adapts to zero-day attacks in real-time."
        case .firewallQuantum: return "Quantum-encrypted packet analysis. Unbreakable at the network edge."
        case .firewallNeural: return "Neural network barrier. Self-healing defense perimeter."
        case .firewallHelix: return "Helix consciousness integration. Threat elimination before detection."
        // SIEM T1-T6
        case .siemSyslog: return "Centralized log collection. Basic event correlation."
        case .siemSIEM: return "Security Information and Event Management. Advanced correlation rules."
        case .siemSOAR: return "Security Orchestration, Automation and Response. Automated playbooks."
        case .siemAI: return "AI-enhanced analytics. Predictive threat modeling and automated reporting."
        case .siemPredictive: return "Predictive analysis engine. Sees attacks before they form."
        case .siemHelix: return "Helix insight stream. Omniscient security awareness."
        // Endpoint T1-T6
        case .endpointEDR: return "Endpoint Detection and Response. Monitors endpoint behavior."
        case .endpointXDR: return "Extended Detection. Cross-platform correlation and response."
        case .endpointMXDR: return "Managed XDR. 24/7 SOC monitoring and threat hunting."
        case .endpointAI: return "AI-driven protection. Behavioral analysis prevents unknown threats."
        case .endpointAutonomous: return "Autonomous response system. Zero-latency threat neutralization."
        case .endpointHelix: return "Helix sentinel presence. Endpoints become attack-immune."
        // IDS T1-T6
        case .idsBasic: return "Intrusion Detection. Signature-based threat identification."
        case .idsIPS: return "Intrusion Prevention. Active blocking of detected threats."
        case .idsMLIPS: return "ML-enhanced IPS. Learns network patterns, detects anomalies."
        case .idsAI: return "AI threat recognition. Offensive maneuver prediction and counter."
        case .idsQuantum: return "Quantum detection matrix. Sees through any obfuscation."
        case .idsHelix: return "Helix watcher protocol. Malus patterns revealed in real-time."
        // Network T1-T6
        case .networkRouter: return "Basic edge routing with ACLs."
        case .networkISR: return "Integrated Services Router. VPN, QoS, and security services."
        case .networkCloudISR: return "Cloud-native ISR. Elastic scaling and global reach."
        case .networkEncrypted: return "Fully encrypted mesh network. Quantum-resistant key exchange."
        case .networkNeural: return "Neural mesh topology. Self-routing, self-healing network."
        case .networkHelix: return "Helix conduit network. Traffic becomes untraceable, unhackable."
        // Encryption T1-T6
        case .encryptionBasic: return "AES-256 encryption for data at rest."
        case .encryptionAdvanced: return "End-to-end encryption with perfect forward secrecy."
        case .encryptionQuantum: return "Post-quantum cryptography. Future-proof against quantum attacks."
        case .encryptionNeural: return "Neural cipher system. Encryption that thinks."
        case .encryptionHelix: return "Helix vault protection. Data secured by consciousness itself."
        case .encryptionSymbiont: return "Symbiont encryption. Living cipher adapts to threats."
        // T7+ use tier-themed descriptions
        default:
            return tierDescription(tier: tier, category: category)
        }
    }

    private func tierDescription(tier: Int, category: DefenseCategory) -> String {
        let categoryName = category.displayName
        switch tier {
        case 7: return "Symbiont-enhanced \(categoryName). Biological integration with defense systems."
        case 8: return "Transcendent \(categoryName). Beyond conventional security paradigms."
        case 9: return "Void-powered \(categoryName). Threats absorbed into nothingness."
        case 10: return "Dimensional \(categoryName). Defense across parallel realities."
        case 11: return "Multiverse \(categoryName). Protection spans infinite realities."
        case 12: return "Entropy-harnessing \(categoryName). Chaos becomes order."
        case 13: return "Causality-aware \(categoryName). Prevents attacks before their cause."
        case 14: return "Timeline-spanning \(categoryName). Defense across all moments."
        case 15: return "Akashic \(categoryName). Connected to universal memory."
        case 16: return "Cosmic \(categoryName). Universal-scale protection."
        case 17: return "Dark matter \(categoryName). Invisible, intangible defense."
        case 18: return "Singularity-class \(categoryName). Infinite density protection."
        case 19: return "Omniscient \(categoryName). All-knowing defense awareness."
        case 20: return "Reality-bending \(categoryName). Rewrites existence for security."
        case 21: return "Prime \(categoryName). First and foremost protection."
        case 22: return "Absolute \(categoryName). Unconditional, total defense."
        case 23: return "Genesis \(categoryName). Creates protection from nothing."
        case 24: return "Omega \(categoryName). The final evolution of defense."
        case 25: return "Infinite \(categoryName). Limitless, eternal protection."
        default: return "Advanced \(categoryName) system."
        }
    }

    /// Tier number (1-25)
    var tierNumber: Int {
        switch self {
        // Tier 1 - Basic
        case .firewallBasic, .siemSyslog, .endpointEDR, .idsBasic, .networkRouter, .encryptionBasic:
            return 1
        // Tier 2 - Advanced
        case .firewallNGFW, .siemSIEM, .endpointXDR, .idsIPS, .networkISR, .encryptionAdvanced:
            return 2
        // Tier 3 - Elite
        case .firewallAIML, .siemSOAR, .endpointMXDR, .idsMLIPS, .networkCloudISR, .encryptionQuantum:
            return 3
        // Tier 4 - AI-Powered
        case .firewallQuantum, .siemAI, .endpointAI, .idsAI, .networkEncrypted, .encryptionNeural:
            return 4
        // Tier 5 - Quantum/Neural
        case .firewallNeural, .siemPredictive, .endpointAutonomous, .idsQuantum, .networkNeural, .encryptionHelix:
            return 5
        // Tier 6 - Helix Integration
        case .firewallHelix, .siemHelix, .endpointHelix, .idsHelix, .networkHelix, .encryptionSymbiont:
            return 6
        // Tier 7 - Symbiont
        case .firewallSymbiont, .siemSymbiont, .endpointSymbiont, .idsSymbiont, .networkSymbiont, .encryptionTranscendence:
            return 7
        // Tier 8 - Transcendence
        case .firewallTranscendence, .siemTranscendence, .endpointTranscendence, .idsTranscendence, .networkTranscendence, .encryptionVoid:
            return 8
        // Tier 9 - Void
        case .firewallVoid, .siemVoid, .endpointVoid, .idsVoid, .networkVoid, .encryptionDimensional:
            return 9
        // Tier 10 - Dimensional
        case .firewallDimensional, .siemDimensional, .endpointDimensional, .idsDimensional, .networkDimensional, .encryptionMultiverse:
            return 10
        // Tier 11 - Multiverse
        case .firewallMultiverse, .siemMultiverse, .endpointMultiverse, .idsMultiverse, .networkMultiverse, .encryptionEntropy:
            return 11
        // Tier 12 - Entropy
        case .firewallEntropy, .siemEntropy, .endpointEntropy, .idsEntropy, .networkEntropy, .encryptionCausality:
            return 12
        // Tier 13 - Causality
        case .firewallCausality, .siemCausality, .endpointCausality, .idsCausality, .networkCausality, .encryptionTimeline:
            return 13
        // Tier 14 - Timeline
        case .firewallTimeline, .siemTimeline, .endpointTimeline, .idsTimeline, .networkTimeline, .encryptionAkashic:
            return 14
        // Tier 15 - Akashic
        case .firewallAkashic, .siemAkashic, .endpointAkashic, .idsAkashic, .networkAkashic, .encryptionCosmic:
            return 15
        // Tier 16 - Cosmic
        case .firewallCosmic, .siemCosmic, .endpointCosmic, .idsCosmic, .networkCosmic, .encryptionDarkMatter:
            return 16
        // Tier 17 - Dark Matter
        case .firewallDarkMatter, .siemDarkMatter, .endpointDarkMatter, .idsDarkMatter, .networkDarkMatter, .encryptionSingularity:
            return 17
        // Tier 18 - Singularity
        case .firewallSingularity, .siemSingularity, .endpointSingularity, .idsSingularity, .networkSingularity, .encryptionOmniscient:
            return 18
        // Tier 19 - Omniscient
        case .firewallOmniscient, .siemOmniscient, .endpointOmniscient, .idsOmniscient, .networkOmniscient, .encryptionReality:
            return 19
        // Tier 20 - Reality
        case .firewallReality, .siemReality, .endpointReality, .idsReality, .networkReality, .encryptionPrime:
            return 20
        // Tier 21 - Prime
        case .firewallPrime, .siemPrime, .endpointPrime, .idsPrime, .networkPrime, .encryptionAbsolute:
            return 21
        // Tier 22 - Absolute
        case .firewallAbsolute, .siemAbsolute, .endpointAbsolute, .idsAbsolute, .networkAbsolute, .encryptionGenesis:
            return 22
        // Tier 23 - Genesis
        case .firewallGenesis, .siemGenesis, .endpointGenesis, .idsGenesis, .networkGenesis, .encryptionOmega:
            return 23
        // Tier 24 - Omega
        case .firewallOmega, .siemOmega, .endpointOmega, .idsOmega, .networkOmega, .encryptionInfinite:
            return 24
        // Tier 25 - Infinite
        case .firewallInfinite, .siemInfinite, .endpointInfinite, .idsInfinite, .networkInfinite, .encryptionUltimate:
            return 25
        }
    }

    /// Cost to unlock this tier (balanced with unit costs)
    var unlockCost: Double {
        switch tierNumber {
        case 1: return 500
        case 2: return 5_000
        case 3: return 40_000
        case 4: return 120_000
        case 5: return 500_000
        case 6: return 2_000_000
        // T7+ scale exponentially (similar to unit costs)
        case 7: return 10_000_000           // 10M
        case 8: return 50_000_000           // 50M
        case 9: return 200_000_000          // 200M
        case 10: return 1_000_000_000       // 1B
        case 11: return 5_000_000_000       // 5B
        case 12: return 20_000_000_000      // 20B
        case 13: return 100_000_000_000     // 100B
        case 14: return 500_000_000_000     // 500B
        case 15: return 2_000_000_000_000   // 2T
        case 16: return 10_000_000_000_000  // 10T
        case 17: return 50_000_000_000_000  // 50T
        case 18: return 200_000_000_000_000 // 200T
        case 19: return 1_000_000_000_000_000   // 1Q
        case 20: return 5_000_000_000_000_000   // 5Q
        case 21: return 20_000_000_000_000_000  // 20Q
        case 22: return 100_000_000_000_000_000 // 100Q
        case 23: return 500_000_000_000_000_000 // 500Q
        case 24: return 2_000_000_000_000_000_000   // 2Qi
        case 25: return 10_000_000_000_000_000_000  // 10Qi
        default: return 0
        }
    }

    /// Prerequisite tier (nil if this is the first in chain)
    var prerequisite: DefenseAppTier? {
        let chain = category.progressionChain
        guard let index = chain.firstIndex(of: self), index > 0 else { return nil }
        return chain[index - 1]
    }

    /// Next tier in the chain (nil if this is the last)
    var nextTier: DefenseAppTier? {
        let chain = category.progressionChain
        guard let index = chain.firstIndex(of: self), index < chain.count - 1 else { return nil }
        return chain[index + 1]
    }
}

// MARK: - Defense Application Instance

struct DefenseApplication: Identifiable, Codable {
    let id: UUID
    let tier: DefenseAppTier
    var level: Int
    var isOnline: Bool

    /// Current operational status
    var status: DefenseStatus

    init(tier: DefenseAppTier, level: Int = 1) {
        self.id = UUID()
        self.tier = tier
        self.level = level
        self.isOnline = true
        self.status = .nominal
    }

    var category: DefenseCategory { tier.category }
    var displayName: String { tier.displayName }
    var shortName: String { tier.shortName }

    // MARK: - Stats

    /// Defense points contributed - reduces attack frequency
    /// Higher tiers provide exponentially more points
    var defensePoints: Double {
        let tierMultiplier = pow(2.0, Double(tier.tierNumber - 1))  // T1=1x, T2=2x, T3=4x, T4=8x
        return Double(level) * 10.0 * tierMultiplier
    }

    /// Damage reduction percentage (0.0 - 1.0)
    /// BALANCED: Each tier has a different cap, making upgrades essential
    var damageReduction: Double {
        let tierNum = tier.tierNumber
        let tierCap: Double
        switch tierNum {
        case 1: tierCap = 0.05   // T1: max 5% per app (basic protection)
        case 2: tierCap = 0.10   // T2: max 10% per app (serious defense)
        case 3: tierCap = 0.15   // T3: max 15% per app (elite defense)
        case 4: tierCap = 0.20   // T4: max 20% per app (AI-powered)
        case 5: tierCap = 0.25   // T5: max 25% per app (quantum/neural)
        case 6: tierCap = 0.30   // T6: max 30% per app (Helix-integrated)
        // T7+ continues scaling
        case 7...10: tierCap = 0.30 + (0.02 * Double(tierNum - 6))  // T7=32%, T10=38%
        case 11...15: tierCap = 0.38 + (0.02 * Double(tierNum - 10)) // T11=40%, T15=48%
        case 16...20: tierCap = 0.48 + (0.02 * Double(tierNum - 15)) // T16=50%, T20=58%
        case 21...25: tierCap = 0.58 + (0.02 * Double(tierNum - 20)) // T21=60%, T25=68%
        default: tierCap = 0.05
        }
        // Level scaling: slower growth, tier matters more
        let levelBonus = 0.005 * Double(level)  // +0.5% per level
        let tierBase = min(0.50, 0.02 * Double(tierNum))  // T1=2%, capped at 50%
        return min(tierCap, tierBase + levelBonus)
    }

    /// Detection bonus - multiplies intel collection from attacks
    /// SIEM/IDS categories are specialists, but all apps contribute slightly
    var detectionBonus: Double {
        let baseBonus: Double
        switch tier.category {
        case .siem:
            // SIEM is THE intel collection system
            baseBonus = 0.15 * Double(tier.tierNumber)  // T1=15%, T2=30%, T3=45%, T4=60%
        case .ids:
            // IDS helps identify patterns
            baseBonus = 0.10 * Double(tier.tierNumber)  // T1=10%, T2=20%, T3=30%, T4=40%
        case .endpoint:
            // Endpoints see attack behavior
            baseBonus = 0.05 * Double(tier.tierNumber)
        default:
            baseBonus = 0.02 * Double(tier.tierNumber)
        }
        let levelBonus = 0.01 * Double(level)  // +1% per level
        return baseBonus + levelBonus
    }

    /// Automation level - enables auto-features
    /// SOAR/AI tiers unlock: auto-repair, attack duration reduction, passive intel
    var automationLevel: Double {
        let tierNum = tier.tierNumber

        // T7+ use tier-based scaling
        if tierNum >= 7 {
            // Automation scales with tier: T7=70%, T15=85%, T25=95%
            let baseAutomation = 0.65 + (0.015 * Double(tierNum - 6))
            let levelBonus = 0.005 * Double(level)
            return min(0.99, baseAutomation + levelBonus)
        }

        // T1-T6 use specific logic
        switch tier {
        case .siemSOAR:
            return 0.15 + (0.02 * Double(level))  // 15% base + 2%/level
        case .siemAI:
            return 0.30 + (0.03 * Double(level))  // 30% base + 3%/level
        case .endpointMXDR:
            return 0.20 + (0.02 * Double(level))  // Managed service
        case .endpointAI, .idsAI:
            return 0.25 + (0.025 * Double(level)) // AI-powered
        case .firewallAIML:
            return 0.10 + (0.015 * Double(level)) // Some automation
        // T5 - Advanced automation
        case .siemPredictive:
            return 0.40 + (0.035 * Double(level)) // Predictive = better automation
        case .endpointAutonomous:
            return 0.50 + (0.04 * Double(level))  // Autonomous = high automation
        case .firewallQuantum, .firewallNeural, .idsQuantum, .networkNeural, .encryptionNeural:
            return 0.35 + (0.03 * Double(level))  // Quantum/Neural systems
        // T6 - Helix automation (near-perfect)
        case .siemHelix:
            return 0.60 + (0.04 * Double(level))  // Helix insight
        case .endpointHelix:
            return 0.65 + (0.045 * Double(level)) // Helix sentinel
        case .firewallHelix, .idsHelix, .networkHelix:
            return 0.55 + (0.04 * Double(level))  // Helix integration
        default:
            return 0
        }
    }

    /// Intel multiplier - how much this app boosts intel from reports
    /// Makes sending reports more valuable with better apps
    var intelMultiplier: Double {
        switch tier.category {
        case .siem:
            return 1.0 + (0.25 * Double(tier.tierNumber)) + (0.05 * Double(level))
        case .ids:
            return 1.0 + (0.15 * Double(tier.tierNumber)) + (0.03 * Double(level))
        default:
            return 1.0
        }
    }

    // MARK: - Upgrade

    /// Upgrade cost uses exponential scaling like other units
    /// Costs are higher than units since apps provide permanent defense bonuses
    var upgradeCost: Double {
        250.0 * Double(tier.tierNumber) * pow(1.25, Double(level))
    }

    /// Maximum level for this tier (same as unit tiers)
    var maxLevel: Int {
        switch tier.tierNumber {
        case 1: return 10
        case 2: return 15
        case 3: return 20
        case 4: return 25
        case 5: return 30
        case 6: return 40
        case 7...25: return 50  // All T7+ have max level 50
        default: return 10
        }
    }

    /// Whether this app can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this app is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        level >= maxLevel
    }

    mutating func upgrade() {
        guard canUpgrade else { return }
        level += 1
    }
}

// MARK: - Defense Status

enum DefenseStatus: String, Codable {
    case nominal = "NOMINAL"
    case degraded = "DEGRADED"
    case alert = "ALERT"
    case critical = "CRITICAL"
    case offline = "OFFLINE"

    var color: String {
        switch self {
        case .nominal: return "neonGreen"
        case .degraded: return "neonAmber"
        case .alert: return "neonAmber"
        case .critical: return "neonRed"
        case .offline: return "terminalGray"
        }
    }

    var icon: String {
        switch self {
        case .nominal: return "checkmark.circle.fill"
        case .degraded: return "exclamationmark.circle.fill"
        case .alert: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        case .offline: return "minus.circle.fill"
        }
    }
}

// MARK: - Defense Stack

/// Represents all deployed defense applications
struct DefenseStack: Codable {
    /// Deployed applications by category
    var applications: [DefenseCategory: DefenseApplication] = [:]

    /// Unlocked tiers (can deploy these)
    var unlockedTiers: Set<DefenseAppTier> = []

    /// Get deployed app for category
    func application(for category: DefenseCategory) -> DefenseApplication? {
        applications[category]
    }

    /// Check if a tier is unlocked
    func isUnlocked(_ tier: DefenseAppTier) -> Bool {
        unlockedTiers.contains(tier)
    }

    /// Check if can unlock a tier (prereq met AND current tier at max level)
    func canUnlock(_ tier: DefenseAppTier) -> Bool {
        guard !isUnlocked(tier) else { return false }

        // Check if prerequisite tier is unlocked
        if let prereq = tier.prerequisite {
            guard isUnlocked(prereq) else { return false }

            // Must have current tier at max level before unlocking next
            if let currentApp = applications[tier.category] {
                guard currentApp.isAtMaxLevel else { return false }
            }
        }
        return true
    }

    /// Get the reason why a tier can't be unlocked (for UI display)
    func tierGateReason(for tier: DefenseAppTier) -> String? {
        guard !isUnlocked(tier) else { return nil }

        if let prereq = tier.prerequisite {
            if !isUnlocked(prereq) {
                return "Unlock T\(prereq.tierNumber) first"
            }

            if let currentApp = applications[tier.category] {
                if !currentApp.isAtMaxLevel {
                    return "Max level T\(currentApp.tier.tierNumber) first (\(currentApp.level)/\(currentApp.maxLevel))"
                }
            }
        }
        return nil
    }

    /// Unlock a tier
    mutating func unlock(_ tier: DefenseAppTier) {
        unlockedTiers.insert(tier)
    }

    /// Deploy an application
    mutating func deploy(_ tier: DefenseAppTier) {
        guard isUnlocked(tier) else { return }
        applications[tier.category] = DefenseApplication(tier: tier)
    }

    /// Upgrade deployed application (returns false if at max level)
    mutating func upgrade(_ category: DefenseCategory) -> Bool {
        guard var app = applications[category] else { return false }
        guard app.canUpgrade else { return false }
        app.upgrade()
        applications[category] = app
        return true
    }

    // MARK: - Aggregate Stats

    /// Total defense points - reduces attack frequency
    /// Formula: each 100 points = 1% reduced attack chance
    var totalDefensePoints: Double {
        applications.values.reduce(0) { $0 + $1.defensePoints }
    }

    /// Attack frequency reduction from defense points (0.0 - 0.5 cap)
    var attackFrequencyReduction: Double {
        min(0.5, totalDefensePoints / 10000.0)  // 10K points = 50% reduction cap
    }

    /// Total damage reduction (scales with highest tier)
    /// T1-T4: 60% cap
    /// T5: 70% cap
    /// T6: 80% cap
    /// T7-T10: 85% cap
    /// T11-T15: 90% cap
    /// T16-T20: 93% cap
    /// T21-T25: 95% cap
    var totalDamageReduction: Double {
        let maxTier = applications.values.map { $0.tier.tierNumber }.max() ?? 1
        let cap: Double
        switch maxTier {
        case 1...4: cap = 0.60
        case 5: cap = 0.70
        case 6: cap = 0.80
        case 7...10: cap = 0.85
        case 11...15: cap = 0.90
        case 16...20: cap = 0.93
        case 21...25: cap = 0.95
        default: cap = 0.60
        }
        return min(cap, applications.values.reduce(0) { $0 + $1.damageReduction })
    }

    /// Total detection bonus - multiplies intel collection
    var totalDetectionBonus: Double {
        applications.values.reduce(0) { $0 + $1.detectionBonus }
    }

    /// Total automation level - enables special features
    /// 0.25+ = auto-repair firewall
    /// 0.50+ = reduced attack duration
    /// 0.75+ = passive intel generation
    var totalAutomation: Double {
        min(1.0, applications.values.reduce(0) { $0 + $1.automationLevel })
    }

    /// Total intel multiplier for report rewards
    var totalIntelMultiplier: Double {
        let multiplier = applications.values.reduce(1.0) { result, app in
            result * app.intelMultiplier
        }
        return multiplier
    }

    /// Count of deployed applications
    var deployedCount: Int {
        applications.count
    }

    /// Overall stack health
    var overallStatus: DefenseStatus {
        let statuses = applications.values.map { $0.status }
        if statuses.contains(.critical) { return .critical }
        if statuses.contains(.alert) { return .alert }
        if statuses.contains(.degraded) { return .degraded }
        if statuses.isEmpty { return .offline }
        return .nominal
    }
}

// MARK: - Malus Intelligence

/// Intel report milestone rewards
enum IntelMilestone: Int, CaseIterable {
    case firstReport = 1       // First report sent
    case patternAnalyst = 3    // 3 reports - basic pattern recognition
    case signatureExpert = 5   // 5 reports - signature database
    case threatHunter = 10     // 10 reports - predictive analysis
    case malusTracker = 15     // 15 reports - tracking Malus movements
    case originDiscovery = 20  // 20 reports - discover Malus origin
    case counterIntel = 25     // 25 reports - counter-intelligence ops

    var title: String {
        switch self {
        case .firstReport: return "First Contact"
        case .patternAnalyst: return "Pattern Analyst"
        case .signatureExpert: return "Signature Expert"
        case .threatHunter: return "Threat Hunter"
        case .malusTracker: return "Malus Tracker"
        case .originDiscovery: return "Origin Discovery"
        case .counterIntel: return "Counter-Intelligence"
        }
    }

    var description: String {
        switch self {
        case .firstReport: return "Sent your first intel report to the team"
        case .patternAnalyst: return "Team can now predict basic attack patterns"
        case .signatureExpert: return "Signature database online - faster pattern ID"
        case .threatHunter: return "Predictive threat analysis active"
        case .malusTracker: return "Team is tracking Malus movements"
        case .originDiscovery: return "Discovered Malus's true origin"
        case .counterIntel: return "Counter-intelligence operations enabled"
        }
    }

    var loreFragmentId: String? {
        switch self {
        case .firstReport: return "intel_first_report"
        case .patternAnalyst: return "intel_patterns"
        case .signatureExpert: return "malus_signatures"
        case .threatHunter: return "intel_threat_hunting"
        case .malusTracker: return "malus_tracked"
        case .originDiscovery: return "malus_origin"
        case .counterIntel: return "intel_counter_ops"
        }
    }

    /// Credit reward for reaching this milestone
    var creditReward: Double {
        switch self {
        case .firstReport: return 1_000
        case .patternAnalyst: return 5_000
        case .signatureExpert: return 15_000
        case .threatHunter: return 50_000
        case .malusTracker: return 100_000
        case .originDiscovery: return 250_000
        case .counterIntel: return 500_000
        }
    }

    /// Permanent bonus unlocked
    var permanentBonus: IntelBonus {
        switch self {
        case .firstReport: return .intelCollectionRate(0.10)      // +10% intel collection
        case .patternAnalyst: return .patternIdSpeed(0.25)        // +25% faster pattern ID
        case .signatureExpert: return .intelCollectionRate(0.15)  // +15% more intel
        case .threatHunter: return .attackWarning(0.20)           // 20% chance early warning
        case .malusTracker: return .damageReduction(0.05)         // +5% damage reduction
        case .originDiscovery: return .intelCollectionRate(0.25)  // +25% more intel
        case .counterIntel: return .attackFrequencyReduction(0.10) // 10% fewer attacks
        }
    }

    /// Short name for UI display
    var name: String {
        switch self {
        case .firstReport: return "First Contact"
        case .patternAnalyst: return "Pattern Analyst"
        case .signatureExpert: return "Signature Expert"
        case .threatHunter: return "Threat Hunter"
        case .malusTracker: return "Malus Tracker"
        case .originDiscovery: return "Origin Found"
        case .counterIntel: return "Counter-Intel"
        }
    }

    /// Human-readable description of the bonus
    var bonusDescription: String {
        switch self {
        case .firstReport: return "+10% intel collection"
        case .patternAnalyst: return "+25% pattern ID speed"
        case .signatureExpert: return "+15% intel collection"
        case .threatHunter: return "20% attack early warning"
        case .malusTracker: return "+5% damage reduction"
        case .originDiscovery: return "+25% intel collection"
        case .counterIntel: return "10% fewer attacks"
        }
    }
}

enum IntelBonus {
    case intelCollectionRate(Double)
    case patternIdSpeed(Double)
    case attackWarning(Double)
    case damageReduction(Double)
    case attackFrequencyReduction(Double)
}

/// Tracks what we know about Malus
struct MalusIntelligence: Codable {
    /// Footprint data collected
    var footprintData: Double = 0

    /// Attack patterns identified
    var patternsIdentified: Int = 0

    /// Reports sent to team
    var reportsSent: Int = 0

    /// Current analysis progress (0-100)
    var analysisProgress: Double = 0

    /// Known Malus signatures
    var knownSignatures: [String] = []

    /// Whether Malus origin is discovered (unlocked at 20 reports)
    var originDiscovered: Bool = false

    /// Milestones already claimed (by rawValue)
    var claimedMilestones: Set<Int> = []

    /// Total credits earned from intel reports
    var totalIntelCredits: Double = 0

    /// Add footprint data from defended attack
    /// - Parameter detectionMultiplier: Bonus from SIEM/IDS systems
    mutating func addFootprintData(_ amount: Double, detectionMultiplier: Double = 1.0) {
        let bonusMultiplier = 1.0 + detectionMultiplier + intelCollectionBonus
        footprintData += amount * bonusMultiplier
        // Update analysis progress (scales with total footprint)
        analysisProgress = min(100, (footprintData / 500.0) * 100.0)
    }

    /// Identify a new pattern
    /// - Parameter patternSpeedBonus: Bonus from milestone unlocks
    mutating func identifyPattern(_ pattern: String, patternSpeedBonus: Double = 0) {
        if !knownSignatures.contains(pattern) {
            knownSignatures.append(pattern)
            patternsIdentified += 1
            // Bonus patterns from speed bonus (chance to identify variant)
            if patternSpeedBonus > 0 && Double.random(in: 0...1) < patternSpeedBonus {
                let variant = "\(pattern)_variant"
                if !knownSignatures.contains(variant) {
                    knownSignatures.append(variant)
                    patternsIdentified += 1
                }
            }
        }
    }

    /// Check if ready to send report
    var canSendReport: Bool {
        footprintData >= reportCost
    }

    /// Cost to send next report (scales slightly with reports sent)
    var reportCost: Double {
        let baseCost = 200.0
        let scaling = 1.0 + (Double(reportsSent) * 0.05)  // +5% per report sent
        return baseCost * scaling
    }

    /// Send report to team (costs footprint data, returns reward info)
    /// - Parameter intelMultiplier: Bonus from SIEM systems
    mutating func sendReport(intelMultiplier: Double = 1.0) -> IntelReportResult? {
        guard canSendReport else { return nil }

        let cost = reportCost
        footprintData -= cost
        reportsSent += 1

        // Base credit reward scales with patterns known
        let baseReward = 100.0 + (Double(patternsIdentified) * 10.0)
        let multipliedReward = baseReward * intelMultiplier

        // Check for milestone
        var unlockedMilestone: IntelMilestone?
        for milestone in IntelMilestone.allCases {
            if reportsSent >= milestone.rawValue && !claimedMilestones.contains(milestone.rawValue) {
                claimedMilestones.insert(milestone.rawValue)
                unlockedMilestone = milestone
                if milestone == .originDiscovery {
                    originDiscovered = true
                }
                break  // Only one milestone per report
            }
        }

        let milestoneReward = unlockedMilestone?.creditReward ?? 0
        let totalReward = multipliedReward + milestoneReward
        totalIntelCredits += totalReward

        return IntelReportResult(
            creditsEarned: totalReward,
            baseCredits: multipliedReward,
            milestoneCredits: milestoneReward,
            milestone: unlockedMilestone,
            reportNumber: reportsSent
        )
    }

    /// Get next unclaimed milestone
    var nextMilestone: IntelMilestone? {
        for milestone in IntelMilestone.allCases {
            if !claimedMilestones.contains(milestone.rawValue) {
                return milestone
            }
        }
        return nil
    }

    /// Reports needed for next milestone
    var reportsToNextMilestone: Int {
        guard let next = nextMilestone else { return 0 }
        return max(0, next.rawValue - reportsSent)
    }

    // MARK: - Cumulative Bonuses from Milestones

    /// Total intel collection rate bonus from milestones
    var intelCollectionBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .intelCollectionRate(let rate) = milestone.permanentBonus {
                bonus += rate
            }
        }
        return bonus
    }

    /// Pattern identification speed bonus
    var patternIdSpeedBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .patternIdSpeed(let speed) = milestone.permanentBonus {
                bonus += speed
            }
        }
        return bonus
    }

    /// Early attack warning chance
    var attackWarningChance: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .attackWarning(let chance) = milestone.permanentBonus {
                bonus += chance
            }
        }
        return bonus
    }

    /// Bonus damage reduction from intel
    var damageReductionBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .damageReduction(let reduction) = milestone.permanentBonus {
                bonus += reduction
            }
        }
        return bonus
    }

    /// Attack frequency reduction from counter-intel
    var attackFrequencyReductionBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .attackFrequencyReduction(let reduction) = milestone.permanentBonus {
                bonus += reduction
            }
        }
        return bonus
    }
}

/// Result of sending an intel report
struct IntelReportResult {
    let creditsEarned: Double
    let baseCredits: Double
    let milestoneCredits: Double
    let milestone: IntelMilestone?
    let reportNumber: Int

    var hasMilestone: Bool { milestone != nil }
}
