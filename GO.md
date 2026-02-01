# GO.md - Grid Watch Zero

## Quick Start

```bash
# Open the Xcode project
open "/Users/russmeadows/Dev/Games/GridWatchZero/GridWatchZero.xcodeproj"
```

Then press **Cmd+R** to build and run.

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| [CLAUDE.md](./CLAUDE.md) | AI assistant context - project structure, patterns, commands |
| [CONTEXT.md](./CONTEXT.md) | Game concept, narrative, design philosophy |
| [PROJECT_STATUS.md](./PROJECT_STATUS.md) | Implementation progress, current version, next tasks |
| [ISSUES.md](./ISSUES.md) | Bug tracking, enhancement requests |
| [DESIGN.md](./DESIGN.md) | Full game design document with mechanics |

---

## Current Sprint: Phase 9 - Character System & Polish ✅ COMPLETE

### ✅ Completed: App Store Preparation (2026-02-01)
- Privacy Policy and Support URLs hosted on GitHub Pages
- App Store screenshots captured and resized (iPhone 6.5", iPad 12.9")
- Build 1.0(1) uploaded to App Store Connect
- TestFlight internal testing configured
- Export compliance completed
- iCloud Diagnostic View added for troubleshooting

### ✅ Completed: Character Dossier System (2026-01-31)
Unlockable character profiles with detailed BIOs:
- 11 character dossiers (GridWatch Team + Prometheus AI)
- Profiles unlock as players progress through campaign
- Dossier Collection view accessible from Campaign Hub
- Each profile has: Visual description, multi-paragraph BIO, combat style, weakness, secret intel
- Faction filtering (GridWatch Team, Prometheus AI, Unknown)
- "NEW" badges for unread dossiers

### ✅ Completed: UI Fixes (2026-01-31)
- Campaign hub now shows correct 20 missions (was 7)
- Alert banner no longer pushes screen down (uses fixed height overlay)
- Fixed large number precision warnings in UnitFactory (scientific notation)
- Fixed Theme.swift number formatting for large values

### Completed in Phase 8 (2026-01-27)
- ✅ iPad Layout - Side-by-side panels, horizontal card layout
- ✅ Accessibility - Reduce Motion support, VoiceOver labels
- ✅ Game Balance - Level pacing (30-60 min), unit cost reductions
- ✅ Center Panel Visibility - Brighter colors, thicker borders, larger fonts
- ✅ iPhone Layout - Responsive card layouts for narrow screens
- ✅ Helix Awakening - Cinematic sequence for Level 7 completion

### Completed in Phase 7: Security Systems
- Defense Application System (6 categories with progression chains)
- Network Topology visualization
- Critical Alarm full-screen overlay
- Malus Intelligence tracking
- Title changed to "GRID WATCH ZERO"

### Remaining Tasks
1. **TestFlight Testing** - Verify app on device via TestFlight
2. **App Store Submission** - Submit for Apple review when testing complete

### New Files Added (Phase 9)
- `Models/CharacterDossier.swift` - Dossier data model with all character BIOs
- `Models/DossierManager.swift` - Unlock tracking and persistence
- `Views/DossierView.swift` - Collection and detail views for dossiers

### New Files Added (Phase 8)
- `Models/DefenseApplication.swift` - Security app model
- `Views/Components/DefenseApplicationView.swift` - Security app cards, topology
- `Views/Components/CriticalAlarmView.swift` - Full-screen alarm
- `Views/HelixAwakeningView.swift` - Level 7 completion cinematic

### Files to Modify
- `Views/DashboardView.swift` - iPad layout with NavigationSplitView
- All Views - Accessibility labels and modifiers
- `Info.plist` - App Store metadata
- `Assets.xcassets` - App icons and screenshots

---

## Development Workflow

### Adding New Files
1. Create file in correct folder via code
2. In Xcode: Right-click folder → "Add Files to 'GridWatchZero'..."
3. Select file, ensure "Copy items if needed" is **unchecked**
4. Build to verify (Cmd+B)

### Testing Threat System
Add debug credits to quickly reach higher threat levels:
```swift
// In GameEngine, call:
engine.addDebugCredits(100000)
```

### Testing Prestige
To test the prestige (Network Wipe) system:
```swift
// Accumulate enough credits, then:
engine.performPrestige()
```

### Save Data Location
UserDefaults key: `GridWatchZero.GameState.v6`

To reset: Delete app from simulator or call `engine.resetGame()`

---

## Architecture Quick Reference

```
┌─────────────────────────────────────────────────┐
│                  DashboardView                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │  Header  │ │  Threat  │ │   Alert Banner   │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
│  ┌──────────────────────────────────────────┐   │
│  │              Network Map                  │   │
│  │   [Source] → [Link] → [Sink]             │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │              Stats Panel                  │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                  GameEngine                      │
│  - processTick() runs every 1 second            │
│  - Manages: resources, nodes, threats           │
│  - @Published for SwiftUI reactivity            │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                    Models                        │
│  - SourceNode, TransportLink, SinkNode          │
│  - FirewallNode, DefenseStack (6 categories)    │
│  - ThreatState, Attack, ThreatLevel             │
│  - EventSystem, LoreSystem, MilestoneSystem     │
│  - PlayerResources, PrestigeState, MalusIntel   │
└─────────────────────────────────────────────────┘
```

---

## Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Terminal Black | #0D0D14 | Background |
| Terminal Dark Gray | #1A1A1F | Card backgrounds |
| Neon Green | #33FF66 | Data, success, source |
| Neon Cyan | #4DE6FF | Links, info |
| Neon Amber | #FFBF33 | Credits, warnings |
| Neon Red | #FF4D4D | Threats, damage |
| Terminal Gray | #333338 | Borders, disabled |

---

## Key Contacts

**Project**: Personal/Solo
**Repository**: Local at `/Users/russmeadows/Dev/Games/GridWatchZero`

---

## Session Checklist

Before ending a session:
- [ ] Update PROJECT_STATUS.md with progress
- [ ] Log any new issues in ISSUES.md
- [ ] Commit changes (if using git)
- [ ] Note next tasks in PROJECT_STATUS.md
