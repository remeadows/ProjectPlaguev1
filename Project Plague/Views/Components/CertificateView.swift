// CertificateView.swift
// GridWatchZero
// UI components for displaying cyber defense certificates

import SwiftUI

// MARK: - Certificate Card View

struct CertificateCardView: View {
    let certificate: Certificate
    let isEarned: Bool
    let earnedDate: Date?
    var showFullDetails: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with tier badge and abbreviation
            HStack {
                // Tier icon
                Image(systemName: certificate.tier.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(tierColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(certificate.abbreviation)
                        .font(.terminalTitle)
                        .foregroundColor(isEarned ? tierColor : .terminalGray)

                    Text(certificate.tier.rawValue.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(tierColor.opacity(0.7))
                }

                Spacer()

                if isEarned {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(tierColor)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.terminalGray.opacity(0.5))
                }
            }

            // Certificate name
            Text(certificate.name)
                .font(.terminalBody)
                .foregroundColor(isEarned ? .white : .terminalGray.opacity(0.6))
                .lineLimit(2)

            if showFullDetails {
                // Full name
                Text(certificate.fullName)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.terminalGray)
                    .lineLimit(2)

                // Description
                Text(certificate.description)
                    .font(.terminalSmall)
                    .foregroundColor(isEarned ? .terminalGray : .terminalGray.opacity(0.5))
                    .lineLimit(3)

                // Metadata
                HStack {
                    Label("\(certificate.creditHours) hrs", systemImage: "clock.fill")
                        .font(.system(size: 10, design: .monospaced))

                    Spacer()

                    Text(certificate.issuingBody)
                        .font(.system(size: 9, design: .monospaced))
                        .lineLimit(1)
                }
                .foregroundColor(.terminalGray.opacity(0.7))

                // Earned date
                if isEarned, let date = earnedDate {
                    HStack {
                        Text("Earned:")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.terminalGray)

                        Text(date, style: .date)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(tierColor)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isEarned ? Color.terminalDarkGray : Color.terminalBlack)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isEarned ? tierColor.opacity(0.6) : Color.terminalGray.opacity(0.2),
                            lineWidth: isEarned ? 1.5 : 1
                        )
                )
        )
        .opacity(isEarned ? 1.0 : 0.6)
    }

    private var tierColor: Color {
        Color.tierColor(named: certificate.tier.color)
    }
}

// MARK: - Certificate Grid View

struct CertificateGridView: View {
    @ObservedObject var certificateManager: CertificateManager
    @State private var selectedCertificate: Certificate?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CERTIFICATIONS")
                        .font(.terminalTitle)
                        .foregroundColor(.neonCyan)

                    Text("\(certificateManager.state.totalCertificates)/\(CertificateDatabase.allCertificates.count) Earned")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }

                Spacer()

                // Total credit hours
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(certificateManager.state.totalCreditHours)")
                        .font(.terminalTitle)
                        .foregroundColor(.neonGreen)

                    Text("Credit Hours")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.terminalGray)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.terminalDarkGray)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.neonCyan)
                        .frame(width: geometry.size.width * certificateManager.progressPercentage / 100.0)
                }
            }
            .frame(height: 8)

            // Certificates by tier
            ForEach(CertificateTier.allCases, id: \.self) { tier in
                tierSection(tier)
            }
        }
        .sheet(item: $selectedCertificate) { cert in
            CertificateDetailView(
                certificate: cert,
                isEarned: certificateManager.state.hasEarned(cert.id),
                earnedDate: certificateManager.state.earnedDate(for: cert.id)
            )
        }
    }

    @ViewBuilder
    private func tierSection(_ tier: CertificateTier) -> some View {
        let tierCerts = certificateManager.certificatesForTier(tier)
        let earnedCount = tierCerts.filter { $0.earned }.count

        VStack(alignment: .leading, spacing: 8) {
            // Tier header
            HStack {
                Image(systemName: tier.icon)
                    .foregroundColor(Color.tierColor(named: tier.color))

                Text(tier.rawValue.uppercased())
                    .font(.terminalBody)
                    .foregroundColor(Color.tierColor(named: tier.color))

                Spacer()

                Text("\(earnedCount)/\(tierCerts.count)")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
            }
            .padding(.horizontal, 4)

            // Certificates grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(tierCerts, id: \.certificate.id) { item in
                    CertificateCardView(
                        certificate: item.certificate,
                        isEarned: item.earned,
                        earnedDate: certificateManager.state.earnedDate(for: item.certificate.id),
                        showFullDetails: false
                    )
                    .onTapGesture {
                        selectedCertificate = item.certificate
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Certificate Detail View

struct CertificateDetailView: View {
    let certificate: Certificate
    let isEarned: Bool
    let earnedDate: Date?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.terminalGray)
                    }
                }

                Spacer()

                // Certificate visual
                certificateVisual

                Spacer()

                // Details
                VStack(spacing: 12) {
                    // Issuing body
                    HStack {
                        Text("Issued by:")
                            .foregroundColor(.terminalGray)
                        Text(certificate.issuingBody)
                            .foregroundColor(tierColor)
                    }
                    .font(.terminalSmall)

                    // Credit hours
                    HStack {
                        Text("Continuing Education:")
                            .foregroundColor(.terminalGray)
                        Text("\(certificate.creditHours) hours")
                            .foregroundColor(.neonGreen)
                    }
                    .font(.terminalSmall)

                    // Level requirement
                    HStack {
                        Text("Required Level:")
                            .foregroundColor(.terminalGray)
                        Text("Campaign Level \(certificate.levelId)")
                            .foregroundColor(.neonAmber)
                    }
                    .font(.terminalSmall)

                    if isEarned, let date = earnedDate {
                        HStack {
                            Text("Earned:")
                                .foregroundColor(.terminalGray)
                            Text(date, style: .date)
                                .foregroundColor(tierColor)
                        }
                        .font(.terminalSmall)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }

    private var certificateVisual: some View {
        VStack(spacing: 16) {
            // Certificate frame
            ZStack {
                // Outer frame
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [tierColor, tierColor.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isEarned ? 3 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.terminalDarkGray)
                    )

                VStack(spacing: 12) {
                    // Seal/Badge
                    ZStack {
                        Circle()
                            .fill(isEarned ? tierColor.opacity(0.2) : Color.terminalGray.opacity(0.1))
                            .frame(width: 60, height: 60)

                        Image(systemName: isEarned ? "checkmark.seal.fill" : certificate.tier.icon)
                            .font(.system(size: 30))
                            .foregroundColor(isEarned ? tierColor : .terminalGray.opacity(0.5))
                    }

                    // Title
                    Text("CERTIFICATE OF ACHIEVEMENT")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminalGray)
                        .tracking(2)

                    // Certificate name
                    Text(certificate.abbreviation)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(isEarned ? tierColor : .terminalGray)

                    Text(certificate.name)
                        .font(.terminalTitle)
                        .foregroundColor(isEarned ? .white : .terminalGray.opacity(0.6))
                        .multilineTextAlignment(.center)

                    Divider()
                        .background(tierColor.opacity(0.3))
                        .padding(.horizontal, 40)

                    // Full name
                    Text(certificate.fullName)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.terminalGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Description
                    Text(certificate.description)
                        .font(.terminalSmall)
                        .foregroundColor(isEarned ? .terminalGray : .terminalGray.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .lineLimit(4)

                    // Tier badge
                    HStack {
                        Image(systemName: certificate.tier.icon)
                        Text(certificate.tier.rawValue.uppercased())
                    }
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(tierColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(tierColor.opacity(0.15))
                    )
                }
                .padding(24)
            }
            .frame(maxWidth: 340, maxHeight: 420)
            .opacity(isEarned ? 1.0 : 0.6)

            // Lock message for unearned
            if !isEarned {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Complete Campaign Level \(certificate.levelId) to earn this certificate")
                }
                .font(.terminalSmall)
                .foregroundColor(.neonAmber)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.dimAmber.opacity(0.3))
                )
            }
        }
    }

    private var tierColor: Color {
        Color.tierColor(named: certificate.tier.color)
    }
}

// MARK: - Certificate Unlock Popup

struct CertificateUnlockPopupView: View {
    let certificate: Certificate
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var sealRotation: Double = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 24) {
                // Animated seal
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(tierColor.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)

                    // Seal
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(tierColor)
                        .rotationEffect(.degrees(sealRotation))
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1.0 : 0.0)

                // Title
                VStack(spacing: 8) {
                    Text("CERTIFICATE EARNED!")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(tierColor)
                        .tracking(3)

                    Text(certificate.abbreviation)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text(certificate.name)
                        .font(.terminalTitle)
                        .foregroundColor(.terminalGray)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)

                // Tier badge
                HStack {
                    Image(systemName: certificate.tier.icon)
                    Text(certificate.tier.rawValue.uppercased())
                }
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(tierColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(tierColor, lineWidth: 1)
                )
                .opacity(showContent ? 1.0 : 0.0)

                // Credit hours
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.neonGreen)
                    Text("+\(certificate.creditHours) Credit Hours")
                        .foregroundColor(.neonGreen)
                }
                .font(.terminalBody)
                .opacity(showContent ? 1.0 : 0.0)

                // Dismiss button
                Button {
                    onDismiss()
                } label: {
                    Text("CONTINUE")
                        .font(.terminalBody)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(tierColor)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            withAnimation(.linear(duration: 0.5)) {
                sealRotation = 360
            }
        }
    }

    private var tierColor: Color {
        Color.tierColor(named: certificate.tier.color)
    }
}

// MARK: - Certificate Summary Badge (for profile)

struct CertificateSummaryBadge: View {
    @ObservedObject var certificateManager: CertificateManager

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(highestTierColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: highestTierIcon)
                    .font(.system(size: 18))
                    .foregroundColor(highestTierColor)
            }

            // Stats
            VStack(alignment: .leading, spacing: 2) {
                Text("\(certificateManager.state.totalCertificates) Certificates")
                    .font(.terminalBody)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("\(certificateManager.state.totalCreditHours) hrs")
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen)

                    if let tier = certificateManager.state.highestTier {
                        Text(tier.rawValue)
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.tierColor(named: tier.color))
                    }
                }
            }

            Spacer()

            // Progress
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f%%", certificateManager.progressPercentage))
                    .font(.terminalTitle)
                    .foregroundColor(.neonCyan)

                Text("Complete")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.terminalGray)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.terminalDarkGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(highestTierColor.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var highestTierColor: Color {
        if let tier = certificateManager.state.highestTier {
            return Color.tierColor(named: tier.color)
        }
        return .terminalGray
    }

    private var highestTierIcon: String {
        certificateManager.state.highestTier?.icon ?? "doc.text"
    }
}

// MARK: - Certificates Full View (Sheet)

struct CertificatesFullView: View {
    @ObservedObject var certificateManager: CertificateManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CERTIFICATIONS")
                            .font(.terminalLarge)
                            .foregroundColor(.neonCyan)

                        Text("Cyber Defense Credentials")
                            .font(.terminalSmall)
                            .foregroundColor(.terminalGray)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.terminalGray)
                            .padding(8)
                    }
                }
                .padding(20)

                ScrollView {
                    CertificateGridView(certificateManager: certificateManager)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.terminalBlack.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 20) {
                CertificateCardView(
                    certificate: CertificateDatabase.allCertificates[0],
                    isEarned: true,
                    earnedDate: Date(),
                    showFullDetails: true
                )

                CertificateCardView(
                    certificate: CertificateDatabase.allCertificates[5],
                    isEarned: false,
                    earnedDate: nil,
                    showFullDetails: true
                )

                CertificateSummaryBadge(certificateManager: CertificateManager.shared)
            }
            .padding()
        }
    }
}
