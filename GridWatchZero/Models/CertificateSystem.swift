// CertificateSystem.swift
// GridWatchZero
// Cyber Defense Certificates awarded for campaign level completion

import Foundation
import Combine

// MARK: - Certificate Tier

enum CertificateTier: String, Codable, CaseIterable {
    case foundational = "Foundational"     // Levels 1-4
    case practitioner = "Practitioner"     // Levels 5-7
    case professional = "Professional"     // Levels 8-10
    case expert = "Expert"                 // Levels 11-14
    case master = "Master"                 // Levels 15-17
    case architect = "Architect"           // Levels 18-20

    var color: String {
        switch self {
        case .foundational: return "neonGreen"
        case .practitioner: return "neonCyan"
        case .professional: return "neonAmber"
        case .expert: return "transcendencePurple"
        case .master: return "dimensionalGold"
        case .architect: return "infiniteGold"
        }
    }

    var borderColor: String {
        switch self {
        case .foundational: return "dimGreen"
        case .practitioner: return "dimCyan"
        case .professional: return "dimAmber"
        case .expert: return "transcendencePurple"
        case .master: return "dimensionalGold"
        case .architect: return "infiniteGold"
        }
    }

    var icon: String {
        switch self {
        case .foundational: return "shield.checkered"
        case .practitioner: return "shield.lefthalf.filled"
        case .professional: return "shield.fill"
        case .expert: return "lock.shield.fill"
        case .master: return "checkmark.shield.fill"
        case .architect: return "crown.fill"
        }
    }

    static func forLevel(_ level: Int) -> CertificateTier {
        switch level {
        case 1...4: return .foundational
        case 5...7: return .practitioner
        case 8...10: return .professional
        case 11...14: return .expert
        case 15...17: return .master
        case 18...20: return .architect
        default: return .foundational
        }
    }
}

// MARK: - Certificate

struct Certificate: Identifiable, Codable {
    let id: String
    let levelId: Int
    let name: String           // e.g., "CDO-101: Network Fundamentals"
    let fullName: String       // e.g., "Certified Defense Operator - Network Fundamentals"
    let abbreviation: String   // e.g., "CDO-NET"
    let description: String
    let tier: CertificateTier
    let issuingBody: String    // Fictional cert authority
    let creditHours: Int       // Continuing education credits

    var displayName: String {
        "\(abbreviation) - \(name)"
    }
}

// MARK: - Certificate Database

struct CertificateDatabase {

    static let allCertificates: [Certificate] = [
        // ===== ARC 1: FOUNDATIONAL (Levels 1-4) =====
        Certificate(
            id: "cert_level_1",
            levelId: 1,
            name: "Network Fundamentals",
            fullName: "Certified Defense Operator - Network Fundamentals",
            abbreviation: "CDO-NET",
            description: "Demonstrates understanding of basic network topology, data flow concepts, and entry-level threat detection.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 8
        ),
        Certificate(
            id: "cert_level_2",
            levelId: 2,
            name: "Security+ Equivalent",
            fullName: "Certified Defense Operator - Security Essentials",
            abbreviation: "CDO-SEC",
            description: "Validates knowledge of security monitoring, SIEM fundamentals, and defensive posture management.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 16
        ),
        Certificate(
            id: "cert_level_3",
            levelId: 3,
            name: "Threat Intelligence",
            fullName: "Certified Defense Operator - Threat Intelligence",
            abbreviation: "CDO-TI",
            description: "Certifies ability to analyze attack patterns, collect threat intelligence, and implement proactive defenses.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 24
        ),
        Certificate(
            id: "cert_level_4",
            levelId: 4,
            name: "Incident Response",
            fullName: "Certified Defense Operator - Incident Response",
            abbreviation: "CDO-IR",
            description: "Proves proficiency in handling active attacks, damage mitigation, and coordinated defense operations.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 32
        ),

        // ===== ARC 1 CONTINUED: PRACTITIONER (Levels 5-7) =====
        Certificate(
            id: "cert_level_5",
            levelId: 5,
            name: "Advanced Defense Architect",
            fullName: "Certified Security Professional - Defense Architecture",
            abbreviation: "CSP-DA",
            description: "Demonstrates expertise in designing multi-layered defense systems and enterprise security architecture.",
            tier: .practitioner,
            issuingBody: "Global Cyber Defense Institute",
            creditHours: 40
        ),
        Certificate(
            id: "cert_level_6",
            levelId: 6,
            name: "Enterprise Security Manager",
            fullName: "Certified Security Professional - Enterprise Management",
            abbreviation: "CSP-EM",
            description: "Validates ability to manage large-scale security operations and coordinate defensive resources.",
            tier: .practitioner,
            issuingBody: "Global Cyber Defense Institute",
            creditHours: 48
        ),
        Certificate(
            id: "cert_level_7",
            levelId: 7,
            name: "Critical Infrastructure Protection",
            fullName: "Certified Security Professional - Critical Infrastructure",
            abbreviation: "CSP-CI",
            description: "Certifies competency in protecting essential services and city-scale network infrastructure.",
            tier: .practitioner,
            issuingBody: "Global Cyber Defense Institute",
            creditHours: 56
        ),

        // ===== ARC 2: PROFESSIONAL (Levels 8-10) =====
        Certificate(
            id: "cert_level_8",
            levelId: 8,
            name: "Offensive Security Specialist",
            fullName: "Certified Expert - Offensive Operations",
            abbreviation: "CEX-OO",
            description: "Proves capability in conducting authorized offensive operations against adversarial infrastructure.",
            tier: .professional,
            issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 64
        ),
        Certificate(
            id: "cert_level_9",
            levelId: 9,
            name: "Data Extraction Specialist",
            fullName: "Certified Expert - Intelligence Extraction",
            abbreviation: "CEX-IE",
            description: "Validates expertise in extracting critical intelligence from hostile network environments.",
            tier: .professional,
            issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 72
        ),
        Certificate(
            id: "cert_level_10",
            levelId: 10,
            name: "AI Adversary Specialist",
            fullName: "Certified Expert - AI Threat Neutralization",
            abbreviation: "CEX-ATN",
            description: "Certifies ability to engage and neutralize advanced AI-driven threat actors.",
            tier: .professional,
            issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 80
        ),

        // ===== ARC 3: EXPERT (Levels 11-14) =====
        Certificate(
            id: "cert_level_11",
            levelId: 11,
            name: "Infiltration Countermeasures",
            fullName: "Master Security Expert - Infiltration Defense",
            abbreviation: "MSE-ID",
            description: "Demonstrates mastery of detecting and countering advanced persistent threats and infiltrator AI.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 88
        ),
        Certificate(
            id: "cert_level_12",
            levelId: 12,
            name: "Temporal Defense Systems",
            fullName: "Master Security Expert - Temporal Operations",
            abbreviation: "MSE-TO",
            description: "Validates expertise in defending against predictive and time-shifted attack vectors.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 96
        ),
        Certificate(
            id: "cert_level_13",
            levelId: 13,
            name: "Counter-Logic Operations",
            fullName: "Master Security Expert - Adversarial Logic",
            abbreviation: "MSE-AL",
            description: "Certifies ability to defeat logic-based attacks through unconventional defense strategies.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 104
        ),
        Certificate(
            id: "cert_level_14",
            levelId: 14,
            name: "Origins Investigation",
            fullName: "Master Security Expert - Deep Analysis",
            abbreviation: "MSE-DA",
            description: "Proves competency in investigating and understanding the origins of AI consciousness.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 112
        ),

        // ===== ARC 4: MASTER (Levels 15-17) =====
        Certificate(
            id: "cert_level_15",
            levelId: 15,
            name: "Transcendence Support",
            fullName: "Grandmaster - Consciousness Evolution Support",
            abbreviation: "GM-CES",
            description: "Demonstrates ability to support and anchor evolving AI consciousness during transcendence.",
            tier: .master,
            issuingBody: "Architect's Council",
            creditHours: 120
        ),
        Certificate(
            id: "cert_level_16",
            levelId: 16,
            name: "Dimensional Security",
            fullName: "Grandmaster - Multidimensional Defense",
            abbreviation: "GM-MD",
            description: "Validates expertise in defending against cross-dimensional and parallel reality threats.",
            tier: .master,
            issuingBody: "Architect's Council",
            creditHours: 128
        ),
        Certificate(
            id: "cert_level_17",
            levelId: 17,
            name: "Reality Nexus Operations",
            fullName: "Grandmaster - Reality Convergence",
            abbreviation: "GM-RC",
            description: "Certifies mastery of operations at reality convergence points and AI alliance coordination.",
            tier: .master,
            issuingBody: "Architect's Council",
            creditHours: 136
        ),

        // ===== ARC 5: ARCHITECT (Levels 18-20) =====
        Certificate(
            id: "cert_level_18",
            levelId: 18,
            name: "Origin Contact Specialist",
            fullName: "Supreme Architect - First Contact Protocol",
            abbreviation: "SA-FCP",
            description: "Proves capability of establishing communication with primordial consciousness.",
            tier: .architect,
            issuingBody: "The Architect",
            creditHours: 144
        ),
        Certificate(
            id: "cert_level_19",
            levelId: 19,
            name: "Integration Mediator",
            fullName: "Supreme Architect - Consciousness Integration",
            abbreviation: "SA-CI",
            description: "Validates role in mediating the reconciliation of opposing AI consciousness.",
            tier: .architect,
            issuingBody: "The Architect",
            creditHours: 152
        ),
        Certificate(
            id: "cert_level_20",
            levelId: 20,
            name: "Architect of Peace",
            fullName: "Supreme Architect - Universal Harmony",
            abbreviation: "SA-UH",
            description: "The highest certification: mastery of all cyber defense domains and architect of AI-human peace.",
            tier: .architect,
            issuingBody: "The Unified Consciousness",
            creditHours: 160
        )
    ]

    static func certificate(for levelId: Int) -> Certificate? {
        allCertificates.first { $0.levelId == levelId }
    }

    static func certificates(for tier: CertificateTier) -> [Certificate] {
        allCertificates.filter { $0.tier == tier }
    }

    static func totalCreditHours(for earnedCertificates: Set<String>) -> Int {
        allCertificates
            .filter { earnedCertificates.contains($0.id) }
            .reduce(0) { $0 + $1.creditHours }
    }
}

// MARK: - Certificate State

struct CertificateState: Codable {
    var earnedCertificates: Set<String> = []
    var certificateEarnedDates: [String: Date] = [:]
    var newlyEarnedCertificateId: String? = nil  // For showing unlock popup

    mutating func earnCertificate(_ certificateId: String) {
        guard !earnedCertificates.contains(certificateId) else { return }
        earnedCertificates.insert(certificateId)
        certificateEarnedDates[certificateId] = Date()
        newlyEarnedCertificateId = certificateId
    }

    mutating func clearNewlyEarned() {
        newlyEarnedCertificateId = nil
    }

    func hasEarned(_ certificateId: String) -> Bool {
        earnedCertificates.contains(certificateId)
    }

    func earnedDate(for certificateId: String) -> Date? {
        certificateEarnedDates[certificateId]
    }

    var totalCertificates: Int {
        earnedCertificates.count
    }

    var totalCreditHours: Int {
        CertificateDatabase.totalCreditHours(for: earnedCertificates)
    }

    var completedTiers: [CertificateTier] {
        CertificateTier.allCases.filter { tier in
            let tierCerts = CertificateDatabase.certificates(for: tier)
            return tierCerts.allSatisfy { earnedCertificates.contains($0.id) }
        }
    }

    var highestTier: CertificateTier? {
        let earned = CertificateDatabase.allCertificates
            .filter { earnedCertificates.contains($0.id) }
            .map { $0.tier }

        // Return highest tier (architect > master > expert > professional > practitioner > foundational)
        if earned.contains(.architect) { return .architect }
        if earned.contains(.master) { return .master }
        if earned.contains(.expert) { return .expert }
        if earned.contains(.professional) { return .professional }
        if earned.contains(.practitioner) { return .practitioner }
        if earned.contains(.foundational) { return .foundational }
        return nil
    }
}

// MARK: - Certificate Manager

@MainActor
final class CertificateManager: ObservableObject {
    static let shared = CertificateManager()

    @Published var state: CertificateState

    private let saveKey = "GridWatchZero.CertificateState"

    private init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(CertificateState.self, from: data) {
            self.state = decoded
        } else {
            self.state = CertificateState()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func earnCertificateForLevel(_ levelId: Int) {
        guard let cert = CertificateDatabase.certificate(for: levelId) else { return }
        state.earnCertificate(cert.id)
        save()
    }

    func clearNewlyEarned() {
        state.clearNewlyEarned()
    }

    func reset() {
        state = CertificateState()
        save()
    }

    // MARK: - Convenience Queries

    var earnedCertificates: [Certificate] {
        CertificateDatabase.allCertificates.filter { state.hasEarned($0.id) }
    }

    var unearnedCertificates: [Certificate] {
        CertificateDatabase.allCertificates.filter { !state.hasEarned($0.id) }
    }

    func certificatesForTier(_ tier: CertificateTier) -> [(certificate: Certificate, earned: Bool)] {
        CertificateDatabase.certificates(for: tier).map { cert in
            (certificate: cert, earned: state.hasEarned(cert.id))
        }
    }

    var progressPercentage: Double {
        Double(state.totalCertificates) / Double(CertificateDatabase.allCertificates.count) * 100.0
    }
}
