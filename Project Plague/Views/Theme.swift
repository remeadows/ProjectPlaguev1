// Theme.swift
// GridWatchZero
// Cyberpunk terminal aesthetic

import SwiftUI

// MARK: - Color Theme

extension Color {
    // Primary colors
    static let terminalBlack = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let terminalDarkGray = Color(red: 0.12, green: 0.12, blue: 0.15)  // Lighter for better card contrast
    static let terminalGray = Color(red: 0.55, green: 0.55, blue: 0.6)  // Slightly brighter for readability

    // Accent colors
    static let neonGreen = Color(red: 0.2, green: 1.0, blue: 0.4)
    static let neonAmber = Color(red: 1.0, green: 0.75, blue: 0.2)
    static let neonRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let neonCyan = Color(red: 0.3, green: 0.9, blue: 1.0)

    // Dimmed variants
    static let dimGreen = Color(red: 0.1, green: 0.4, blue: 0.2)
    static let dimAmber = Color(red: 0.4, green: 0.3, blue: 0.1)
    static let dimRed = Color(red: 0.4, green: 0.15, blue: 0.15)

    // MARK: - Tier Colors (T7-25)

    // Transcendence colors (T7-10) - Purple shades
    static let transcendencePurple = Color(red: 0.6, green: 0.2, blue: 0.9)
    static let voidBlue = Color(red: 0.15, green: 0.1, blue: 0.4)

    // Dimensional colors (T11-15) - Purple/Gold
    static let dimensionalGold = Color(red: 1.0, green: 0.85, blue: 0.3)
    static let multiversePink = Color(red: 0.9, green: 0.3, blue: 0.6)
    static let akashicGold = Color(red: 1.0, green: 0.9, blue: 0.4)

    // Cosmic colors (T16-20) - White/Silver
    static let cosmicSilver = Color(red: 0.85, green: 0.85, blue: 0.92)
    static let darkMatterPurple = Color(red: 0.3, green: 0.1, blue: 0.4)
    static let singularityWhite = Color(red: 0.95, green: 0.95, blue: 1.0)

    // Infinite colors (T21-25) - Gold/Black
    static let infiniteGold = Color(red: 1.0, green: 0.9, blue: 0.5)
    static let omegaBlack = Color(red: 0.08, green: 0.02, blue: 0.12)

    /// Returns the appropriate SwiftUI Color for a tier color string
    static func tierColor(named colorName: String) -> Color {
        switch colorName {
        // Existing colors
        case "terminalGray": return .terminalGray
        case "neonGreen": return .neonGreen
        case "neonCyan": return .neonCyan
        case "neonAmber": return .neonAmber
        case "neonRed": return .neonRed
        // Transcendence (T7-10)
        case "transcendencePurple": return .transcendencePurple
        case "voidBlue": return .voidBlue
        // Dimensional (T11-15)
        case "dimensionalGold": return .dimensionalGold
        case "multiversePink": return .multiversePink
        case "akashicGold": return .akashicGold
        // Cosmic (T16-20)
        case "cosmicSilver": return .cosmicSilver
        case "darkMatterPurple": return .darkMatterPurple
        case "singularityWhite": return .singularityWhite
        // Infinite (T21-25)
        case "infiniteGold": return .infiniteGold
        case "omegaBlack": return .omegaBlack
        default: return .terminalGray
        }
    }
}

// MARK: - Font Theme
// Using relative text styles for Dynamic Type support while maintaining monospace design

extension Font {
    // Maps to .title2 (22pt base)
    static let terminalLarge = Font.system(.title2, design: .monospaced).weight(.bold)
    // Maps to .subheadline (15pt base)
    static let terminalTitle = Font.system(.subheadline, design: .monospaced).weight(.semibold)
    // Maps to .footnote (13pt base)
    static let terminalBody = Font.system(.footnote, design: .monospaced)
    // Maps to .footnote with medium weight (13pt base)
    static let terminalReadable = Font.system(.footnote, design: .monospaced).weight(.medium)
    // Maps to .caption2 (11pt base)
    static let terminalSmall = Font.system(.caption2, design: .monospaced)
    // Maps to .caption2 (11pt base) - smallest accessible size
    static let terminalMicro = Font.system(.caption2, design: .monospaced)
}

// MARK: - View Modifiers

struct TerminalCardModifier: ViewModifier {
    var borderColor: Color = .neonGreen

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor.opacity(0.7), lineWidth: 1.5)  // Brighter, thicker border
            )
            .shadow(color: borderColor.opacity(0.15), radius: 4, x: 0, y: 2)  // Subtle glow
    }
}

struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius)
    }
}

struct TerminalButtonModifier: ViewModifier {
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        content
            .font(.terminalSmall)
            .foregroundColor(isEnabled ? .terminalBlack : .terminalGray)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isEnabled ? Color.neonGreen : Color.terminalGray)
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isEnabled ? Color.neonGreen : Color.terminalGray, lineWidth: 1)
            )
    }
}

// MARK: - View Extensions

extension View {
    func terminalCard(borderColor: Color = .neonGreen) -> some View {
        modifier(TerminalCardModifier(borderColor: borderColor))
    }

    func glow(_ color: Color, radius: CGFloat = 8) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }

    func terminalButton(isEnabled: Bool = true) -> some View {
        modifier(TerminalButtonModifier(isEnabled: isEnabled))
    }
}

// MARK: - Number Formatting

extension Double {
    /// Formats large numbers with appropriate suffixes for T1-25 scale
    /// K = Thousand, M = Million, B = Billion, T = Trillion
    /// Q = Quadrillion, Qi = Quintillion, Sx = Sextillion, Sp = Septillion
    var formatted: String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""

        switch absValue {
        case 1_000_000_000_000_000_000_000_000...:  // Septillion+
            return sign + String(format: "%.1fSp", absValue / 1_000_000_000_000_000_000_000_000)
        case 1_000_000_000_000_000_000_000..<1_000_000_000_000_000_000_000_000:  // Sextillion
            return sign + String(format: "%.1fSx", absValue / 1_000_000_000_000_000_000_000)
        case 1_000_000_000_000_000_000..<1_000_000_000_000_000_000_000:  // Quintillion
            return sign + String(format: "%.1fQi", absValue / 1_000_000_000_000_000_000)
        case 1_000_000_000_000_000..<1_000_000_000_000_000_000:  // Quadrillion
            return sign + String(format: "%.1fQ", absValue / 1_000_000_000_000_000)
        case 1_000_000_000_000..<1_000_000_000_000_000:  // Trillion
            return sign + String(format: "%.1fT", absValue / 1_000_000_000_000)
        case 1_000_000_000..<1_000_000_000_000:  // Billion
            return sign + String(format: "%.1fB", absValue / 1_000_000_000)
        case 1_000_000..<1_000_000_000:  // Million
            return sign + String(format: "%.1fM", absValue / 1_000_000)
        case 1_000..<1_000_000:  // Thousand
            return sign + String(format: "%.1fK", absValue / 1_000)
        case _ where absValue == floor(absValue):
            return sign + String(format: "%.0f", absValue)
        default:
            return sign + String(format: "%.1f", absValue)
        }
    }

    var percentFormatted: String {
        String(format: "%.0f%%", self * 100)
    }
}
