// LoreView.swift
// GridWatchZero
// View for reading collected lore fragments and intel

import SwiftUI

struct LoreView: View {
    @ObservedObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: LoreCategory = .intel
    @State private var selectedFragment: LoreFragment?

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                loreHeader

                // Category tabs
                categoryTabs

                // Content
                if let fragment = selectedFragment {
                    fragmentDetail(fragment)
                } else {
                    fragmentList
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var loreHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("INTEL DATABASE")
                    .font(.terminalLarge)
                    .foregroundColor(.neonCyan)
                    .glow(.neonCyan, radius: 4)

                Text("[ CLASSIFIED ARCHIVE ]")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            // Unread indicator
            if engine.loreState.unreadCount > 0 {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.neonAmber)
                        .frame(width: 8, height: 8)
                    Text("\(engine.loreState.unreadCount) NEW")
                        .font(.terminalMicro)
                        .foregroundColor(.neonAmber)
                }
            }

            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.terminalGray)
                    .frame(width: 32, height: 32)
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
            }
            .padding(.leading, 12)
        }
        .padding()
        .background(Color.terminalDarkGray)
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(LoreCategory.allCases, id: \.self) { category in
                    categoryTab(category)
                }
            }
        }
        .background(Color.terminalBlack)
    }

    private func categoryTab(_ category: LoreCategory) -> some View {
        let isSelected = selectedCategory == category
        let unlockedCount = fragmentsForCategory(category).count
        let color = categoryColor(category)

        return Button(action: {
            selectedCategory = category
            selectedFragment = nil
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))

                Text(category.rawValue)
                    .font(.terminalMicro)

                if unlockedCount > 0 {
                    Text("(\(unlockedCount))")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                }
            }
            .foregroundColor(isSelected ? color : .terminalGray)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? color.opacity(0.1) : Color.clear)
            .overlay(
                Rectangle()
                    .fill(isSelected ? color : Color.clear)
                    .frame(height: 2),
                alignment: .bottom
            )
        }
    }

    private func categoryColor(_ category: LoreCategory) -> Color {
        switch category {
        case .world: return .terminalGray
        case .helix: return .neonCyan
        case .malus: return .neonRed
        case .team: return .neonGreen
        case .intel: return .neonAmber
        }
    }

    // MARK: - Fragment List

    private var fragmentList: some View {
        let fragments = fragmentsForCategory(selectedCategory)

        return ScrollView {
            if fragments.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.terminalGray)

                    Text("NO INTEL AVAILABLE")
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    Text("Keep operating. Information will surface.")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(fragments) { fragment in
                        fragmentRow(fragment)
                    }
                }
                .padding()
            }
        }
    }

    private func fragmentsForCategory(_ category: LoreCategory) -> [LoreFragment] {
        LoreDatabase.fragments(for: category)
            .filter { engine.loreState.isUnlocked($0.id) }
            .sorted { $0.title < $1.title }
    }

    private func fragmentRow(_ fragment: LoreFragment) -> some View {
        let isRead = engine.loreState.isRead(fragment.id)
        let color = categoryColor(fragment.category)

        return Button(action: {
            selectedFragment = fragment
            if !isRead {
                engine.markLoreRead(fragment.id)
            }
        }) {
            HStack {
                // Unread indicator
                Circle()
                    .fill(isRead ? Color.clear : Color.neonAmber)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(fragment.title.uppercased())
                        .font(.terminalSmall)
                        .foregroundColor(color)

                    Text(fragment.content.prefix(60) + "...")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.terminalGray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.terminalDarkGray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isRead ? Color.terminalGray.opacity(0.3) : color.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Fragment Detail

    private func fragmentDetail(_ fragment: LoreFragment) -> some View {
        let color = categoryColor(fragment.category)

        return VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: { selectedFragment = nil }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("BACK")
                    }
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
                }

                Spacer()
            }
            .padding()
            .background(Color.terminalDarkGray.opacity(0.5))

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    HStack {
                        Image(systemName: fragment.category.icon)
                            .font(.system(size: 24))
                            .foregroundColor(color)

                        Text(fragment.title.uppercased())
                            .font(.terminalLarge)
                            .foregroundColor(color)
                    }

                    // Category badge
                    Text(fragment.category.rawValue)
                        .font(.terminalSmall)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(color)
                        .cornerRadius(2)

                    Divider()
                        .background(color.opacity(0.3))

                    // Content
                    Text(fragment.content)
                        .font(.terminalReadable)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(8)

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
    }
}

// MARK: - Milestones View

struct MilestonesView: View {
    @ObservedObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                milestonesHeader

                // Milestone list
                milestoneList
            }
        }
        .preferredColorScheme(.dark)
    }

    private var milestonesHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("MILESTONES")
                    .font(.terminalLarge)
                    .foregroundColor(.neonAmber)
                    .glow(.neonAmber, radius: 4)

                let completed = engine.milestoneState.completedMilestoneIds.count
                let total = MilestoneDatabase.visibleMilestones().count
                Text("[ \(completed)/\(total) COMPLETE ]")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.terminalGray)
                    .frame(width: 32, height: 32)
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.terminalDarkGray)
    }

    private var milestoneList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(MilestoneType.allCases, id: \.self) { type in
                    milestoneSection(type)
                }
            }
            .padding()
        }
    }

    private func milestoneSection(_ type: MilestoneType) -> some View {
        let milestones = MilestoneDatabase.milestones(for: type)
            .filter { !$0.isHidden || engine.milestoneState.isCompleted($0.id) }

        guard !milestones.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                // Section header
                HStack(spacing: 8) {
                    Image(systemName: type.icon)
                        .font(.system(size: 14))
                        .foregroundColor(.neonAmber)

                    Text(type.rawValue.uppercased())
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)

                    Rectangle()
                        .fill(Color.terminalGray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.top, 8)

                ForEach(milestones) { milestone in
                    milestoneRow(milestone)
                }
            }
        )
    }

    private func milestoneRow(_ milestone: Milestone) -> some View {
        let isCompleted = engine.milestoneState.isCompleted(milestone.id)
        let progress = engine.milestoneState.progress(for: milestone)

        return HStack {
            // Completion indicator
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .neonGreen : .terminalGray)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.terminalSmall)
                    .foregroundColor(isCompleted ? .neonGreen : .white)

                Text(milestone.description)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                // Progress bar (if not completed)
                if !isCompleted {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.terminalGray.opacity(0.3))

                            Rectangle()
                                .fill(Color.neonAmber)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 4)
                    .cornerRadius(2)
                }
            }

            Spacer()

            // Reward
            VStack(alignment: .trailing, spacing: 2) {
                Text("REWARD")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Text(milestone.reward.description)
                    .font(.terminalMicro)
                    .foregroundColor(isCompleted ? .neonGreen : .neonAmber)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isCompleted ? Color.dimGreen : Color.terminalDarkGray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isCompleted ? Color.neonGreen.opacity(0.3) : Color.terminalGray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview("Lore") {
    LoreView(engine: GameEngine())
}

#Preview("Milestones") {
    MilestonesView(engine: GameEngine())
}
