# PROJECT_STATUS.md - Grid Watch Zero

## Current Version: 1.0.0

## Last Updated: 2026-02-01

---

## Implementation Status

### ✅ Phase 1: Core MVP (COMPLETE)
- [x] Project setup with SwiftUI + Swift 6
- [x] MVVM architecture with GameEngine
- [x] Tick-based game loop (1 tick/second)
- [x] Resource flow: Source → Link → Sink
- [x] Bottleneck math (bandwidth caps, packet loss)
- [x] Upgrade system for all nodes
- [x] Cyberpunk terminal UI theme
- [x] Persistence with UserDefaults
- [x] Basic stats display

### ✅ Phase 2: Threat System (COMPLETE)
- [x] ThreatLevel enum (7 levels: Ghost → Marked)
- [x] Threat progression based on credits earned
- [x] Attack types: Probe, DDoS, Intrusion, Malus Strike
- [x] Attack processing in game loop
- [x] Attack damage: credit drain, bandwidth reduction
- [x] AlertBanner UI for attacks
- [x] ThreatIndicator showing current level
- [x] Screen shake on attack
- [x] Malus messages at threat level changes
- [x] Sound effects (system sounds) + haptic feedback
- [x] DDoS visual overlay on Link node

### ✅ Phase 3: Defense & Tier System (COMPLETE)
- [x] FirewallNode defense type
- [x] Firewall absorbs attack damage
- [x] Firewall health regeneration
- [x] Firewall repair system
- [x] FirewallCardView UI component
- [x] NodeTier enum (Tier 1-4)
- [x] Tier 2 Source: Corporate Leech (20 base output)
- [x] Tier 2 Link: Fiber Darknet Relay (15 bandwidth)
- [x] Tier 2 Sink: Shadow Market (2.0x conversion)
- [x] Tier 3 units defined
- [x] Tier 4 (Helix) units defined
- [x] UnlockState for tracking purchased units
- [x] Unit catalog with 15 units across 4 tiers
- [x] Defense nodes: Basic Firewall, Adaptive IDS, Neural Countermeasure
- [x] Save system updated to v3 with firewall + unlocks

### ✅ Phase 4: Unit Shop & Selection (COMPLETE)
- [x] Unit shop modal/sheet (UnitShopView.swift)
- [x] Unit purchase flow with credit deduction
- [x] Unit swap UI (change active source/link/sink/defense)
- [x] Category tabs (Source/Link/Sink/Defense)
- [x] Unit row with tier badge, stats preview
- [x] Lock/unlock state display
- [x] Shop button in header (amber cart icon)
- [x] Equip button for unlocked units

### ✅ Phase 5: Events & Narrative (COMPLETE)
- [x] Random event system (EventSystem.swift)
- [x] Positive events: Data Surge, Clear Channel, Market Spike, Lucky Find, Shadow Contact
- [x] Negative events: Network Glitch, Congestion, Market Crash, Data Corruption
- [x] Story events: City Whisper, Malus Movement, Team Comms, Helix Signal
- [x] Event multipliers affect production/bandwidth/credits
- [x] Milestone system with 30+ achievements (MilestoneSystem.swift)
- [x] Lore fragment collection with 20+ entries (LoreSystem.swift)
- [x] Categories: World, Helix, Malus, Team, Intel
- [x] Lore unlocks via credits and milestones
- [x] LoreView and MilestonesView UIs
- [x] Header buttons for Intel (book) and Trophies
- [x] Unread badge on lore button
- [x] Alert banners for events, lore unlocks, milestone completions

### ✅ Phase 6: Polish & Endgame (COMPLETE)
- [x] Custom sound effects (cyberpunk-themed system sounds)
- [x] Ambient background audio (procedural synth drone)
- [x] Advanced visual effects (particles, glows on node cards)
- [x] Offline progress calculation (up to 8 hours, 50% efficiency)
- [x] Prestige system ("Network Wipe" with Helix Cores)

### ✅ Phase 7: Security Systems (COMPLETE)
- [x] Defense Application model with 6 categories
- [x] Progression chains: FW->NGFW->AI/ML, Syslog->SIEM->SOAR->AI, etc.
- [x] Network Topology visualization
- [x] Critical Alarm full-screen overlay
- [x] Malus Intelligence tracking system
- [x] Title update to "GRID WATCH ZERO"
- [x] Scrollable defense section in dashboard

### ✅ Phase 8: Platform & Release (COMPLETE)
- [x] iPad layout optimization (side-by-side panels with HStack)
- [x] Accessibility improvements (VoiceOver labels, Dynamic Type, reduce motion)
- [x] Game balance tuning (T2 costs +50%, attack scaling, prestige 150K, bottleneck variety)

### ✅ Phase 9: Character System & Polish (COMPLETE)
- [x] Character Dossier System - Unlockable profiles with detailed BIOs
- [x] Dossier Collection View - Gallery view in Campaign Hub
- [x] UI Fixes - Alert banner overlay, level count corrections
- [x] Large number precision fixes (scientific notation for T18+)
- [x] Added Ronin and T33 to StoryCharacter enum
- [x] App Store preparation (screenshots, metadata, TestFlight)
- [x] iCloud Diagnostic View for troubleshooting cloud sync
- [x] Privacy Policy and Support URLs (GitHub Pages)
- [x] App Store screenshots resized (iPhone 6.5", iPad 12.9")
- [x] Build 1.0(1) uploaded to App Store Connect
- [x] TestFlight internal testing configured
- [x] Export compliance completed

---

## Current Game Balance

### Balance Pass v2 (Sprint 9)
- Income scaling capped at 10x (was 50x) - prevents brutal damage spikes
- T3/T4 unit costs reduced 35-40% - smoother progression
- Levels 4-7 starting credits increased 30-60%
- Levels 4-7 credit requirements reduced 30-40%
- Attacks survived requirements reduced 50%
- Insane Level 7 modifiers softened (2x/1.5x/0.7x from 2.5x/1.75x/0.6x)

### Unit Catalog

#### Sources
| Tier | Name | Base Output | Unlock Cost |
|------|------|-------------|-------------|
| 1 | Public Mesh Sniffer | 8/tick | Free |
| 2 | Corporate Leech | 20/tick | ¢7,500 |
| 3 | Zero-Day Harvester | 50/tick | ¢32,000 |
| 4 | Helix Fragment Scanner | 100/tick | ¢300,000 |
| 5 | Neural Tap Array | 200/tick | ¢750,000 |
| 6 | Helix Prime Collector | 500/tick | ¢3,500,000 |

#### Links
| Tier | Name | Bandwidth | Unlock Cost |
|------|------|-----------|-------------|
| 1 | Copper VPN Tunnel | 5/tick | Free |
| 2 | Fiber Darknet Relay | 15/tick | ¢6,000 |
| 3 | Quantum Mesh Bridge | 40/tick | ¢26,000 |
| 4 | Helix Conduit | 100/tick | ¢300,000 |
| 5 | Neural Mesh Backbone | 250/tick | ¢600,000 |
| 6 | Helix Resonance Channel | 600/tick | ¢3,000,000 |

#### Sinks
| Tier | Name | Processing | Conversion | Unlock Cost |
|------|------|------------|------------|-------------|
| 1 | Data Broker | 5/tick | 1.5x | Free |
| 2 | Shadow Market | 15/tick | 2.0x | ¢9,000 |
| 3 | Corp Backdoor | 45/tick | 2.5x | ¢38,000 |
| 4 | Helix Decoder | 80/tick | 3.0x | ¢300,000 |
| 5 | Neural Exchange | 180/tick | 3.5x | ¢900,000 |
| 6 | Helix Integration Core | 400/tick | 4.5x | ¢4,000,000 |

#### Defense
| Tier | Name | Base Health | Damage Reduction | Unlock Cost |
|------|------|-------------|------------------|-------------|
| 1 | Basic Firewall | 100 | 20% | ¢500 |
| 2 | Adaptive IDS | 200 | 30% | ¢12,000 |
| 3 | Neural Countermeasure | 400 | 40% | ¢50,000 |
| 4 | Quantum Shield | 600 | 50% | ¢150,000 |
| 5 | Neural Mesh / Predictive | 800-1000 | 55-60% | ¢600K-900K |
| 6 | Helix Guardian | 2000 | 70% | ¢3,000,000 |

### Threat Thresholds
| Level | Credits | Attack %/tick |
|-------|---------|---------------|
| GHOST | 0 | 0.2% |
| BLIP | 100 | 0.5% |
| SIGNAL | 1,000 | 1% |
| TARGET | 10,000 | 2% |
| PRIORITY | 50,000 | 3.5% |
| HUNTED | 250,000 | 5% |
| MARKED | 1,000,000 | 8% |

---

## Known Issues

See [ISSUES.md](./ISSUES.md) for detailed tracking.

**Critical**: None (all closed)
**Major**: None (all closed)
**Minor**: None (all closed)

---

## Session Log: 2026-02-01

### Summary
Completed App Store preparation - build uploaded to TestFlight, all metadata configured.

### App Store Preparation

#### Privacy Policy & Support URLs
- Created `docs/privacy-policy.html` - Cyberpunk-styled privacy policy
- Created `docs/support.html` - FAQ and support page
- Created `docs/index.html` - Landing page
- Pushed to GitHub repo: remeadows/ProjectPlaguev1
- Enabled GitHub Pages for hosting

#### Screenshots
- Captured iPhone screenshots (iPhone 17 Pro)
- Captured iPad screenshots (iPad Pro 13-inch M5)
- Resized iPhone screenshots to 1284×2778 (6.5" display)
- Resized iPad screenshots to 2732×2048 (12.9" landscape)
- Location: `AppStoreAssets/Screenshots/iPhone_6.5/` and `iPad_Resized/`

#### iCloud Diagnostic Tools
- Created `CloudDiagnosticView.swift` - Comprehensive diagnostic UI
- Added iCloud section to SettingsView
- Enhanced CloudSaveManager with verbose logging

#### App Store Connect Configuration
- App name: Grid Watch Zero
- Bundle ID: WarSignal.GridWatchZero
- SKU: GRIDWATCHZERO001
- Version: 1.0 (Build 1)
- Category: Games > Strategy
- Price: Free
- Privacy Policy URL: https://remeadows.github.io/ProjectPlaguev1/privacy-policy.html
- Support URL: https://remeadows.github.io/ProjectPlaguev1/support.html

#### Build & TestFlight
- Archived build 1.0(1) from Xcode
- Uploaded to App Store Connect
- Completed export compliance (uses Apple's encryption via iCloud)
- Configured internal TestFlight testing
- TestFlight invitation sent and received

### New Files Created
- `docs/privacy-policy.html`
- `docs/support.html`
- `docs/index.html`
- `Views/CloudDiagnosticView.swift`
- `AppStoreAssets/Screenshots/iPhone_6.5/*.png` (7 screenshots)
- `AppStoreAssets/Screenshots/iPad_Resized/*.png` (4 screenshots)

### Modified Files
- `Views/SettingsView.swift` - Added iCloud Sync section with diagnostics
- `Engine/CloudSaveManager.swift` - Added verbose os.log logging
- `Engine/NavigationCoordinator.swift` - Updated environment object passing
- `ISSUES.md` - Added ISSUE-017 for iCloud investigation

---

## Session Log: 2026-01-31

### Summary
Implemented Character Dossier System with unlockable profiles and detailed BIOs for all characters.

### Character Dossier System

#### New Files Created
- `Models/CharacterDossier.swift` - Dossier data model containing:
  - 11 character profiles (Rusty, Tish, FL3X, Malus, Helix, Ronin, T33, VEXIS, KRON, AXIOM, ZERO, The Architect)
  - Visual descriptions, multi-paragraph BIOs, combat style, weakness, secret intel
  - CharacterFaction enum (GridWatch Team, Prometheus AI, Unknown)
  - DossierDatabase with all dossier entries

- `Models/DossierManager.swift` - Unlock tracking and persistence:
  - DossierState with unlocked/viewed tracking
  - Level-based unlock triggers
  - Unread count for "NEW" badges
  - UserDefaults persistence

- `Views/DossierView.swift` - UI for viewing dossiers:
  - DossierCollectionView with faction filter tabs
  - DossierCardView with locked/unlocked states
  - DossierDetailView with BIO/COMBAT/SECRET tabs
  - Responsive iPad/iPhone layouts

### UI Fixes
- **Campaign Level Count**: Updated from 7 to 20 in HomeView, CampaignProgress, CloudSaveManager, MilestoneSystem, AchievementSystem
- **Alert Banner**: Fixed screen movement by using fixed height overlay approach in AlertBannerView
- **Large Number Precision**: Converted T18-T25 unlock costs to scientific notation in UnitFactory
- **Theme.swift**: Updated number formatting to use scientific notation

### Modified Files
- `Models/StorySystem.swift` - Added `ronin` and `tee` to StoryCharacter enum with display names, roles, image names, and theme colors
- `Views/HomeView.swift` - Added Character Dossiers button in Intelligence section
- `Engine/NavigationCoordinator.swift` - Added dossier unlock triggers on level completion
- `Engine/GameEngine.swift` - Added Malus dossier unlock on first survived attack
- `Views/Components/AlertBannerView.swift` - Fixed overlay approach to prevent screen movement

### Dossier Unlock Schedule
| Level | Character |
|-------|-----------|
| 1 | Rusty |
| 2 | Tish |
| 3 | FL3X |
| First Attack | Malus |
| 5 | Helix |
| 8 | Ronin |
| 10 | T33 |
| 12 | VEXIS |
| 14 | KRON |
| 16 | AXIOM |
| 18 | ZERO |
| 20 | The Architect |

---

## Session Log: 2026-01-29 (ENH-014)

### Summary
Implemented ENH-014: Game Engagement Improvements - comprehensive daily rewards, achievement, and collection systems.

### Engagement System Implementation

#### Daily Rewards & Streaks (`Models/EngagementSystem.swift`)
- 7-day reward cycle: Day 1=₵500, Day 7=₵5,000 + 2x multiplier
- Streak tracking with bonus multipliers:
  - 1 week streak: 1.25x production bonus
  - 2 weeks: 1.5x bonus
  - 4+ weeks: 2x bonus
- Weekly challenges generated based on player level
- Streak persistence with proper day boundary handling

#### Achievement System (`Models/AchievementSystem.swift`)
- 40+ achievements across 7 categories:
  - Combat, Economy, Progression, Collection, Mastery, Social, Secret
- 5 rarity tiers: Common, Uncommon, Rare, Epic, Legendary
- Progress tracking via `AchievementStats` struct
- Credit rewards based on rarity (100-10,000 credits)

#### Collection System (`Models/CollectionSystem.swift`)
- 25+ collectible Data Chips across 6 categories:
  - Network, Malware, Encryption, AI Research, Helix, Personnel
- 4 rarity tiers: Common (60% drop), Uncommon (25%), Rare (12%), Legendary (3%)
- Unlock requirements tied to gameplay progression
- Sellable duplicates for credits

#### Engagement UI (`Views/Components/EngagementView.swift`)
- `DailyRewardPopupView` - Full-screen modal with weekly progress
- `AchievementUnlockPopupView` - Shows rarity, rewards, descriptions
- `DataChipUnlockPopupView` - Shows chip details and flavor text
- `StreakBadgeView`, `BonusMultiplierView`, `WeeklyChallengeCardView`

### New Files
- `Models/EngagementSystem.swift` (~350 lines)
- `Models/AchievementSystem.swift` (~500 lines)
- `Models/CollectionSystem.swift` (~400 lines)
- `Views/Components/EngagementView.swift` (~350 lines)

### Modified Files
- `Engine/GameEngine.swift` - Added engagement tracking methods and bonus multiplier
- `Views/DashboardView.swift` - Added popup overlays at zIndex 400-402
- `ISSUES.md` - Marked ENH-014 as complete
- `Grid Watch Zero.entitlements` - Restored iCloud Key-Value Storage

### iCloud Configuration
- Confirmed paid Apple Developer account (Team ID: B2U8T6A2Y3)
- Restored iCloud Key-Value Storage entitlement for cloud saves

---

## Session Log: 2026-01-29 (ENH-013)

### Summary
Implemented ENH-013: Level 1 Rusty Tutorial Walkthrough - comprehensive guided tutorial system.

### Tutorial System Implementation
Created 12-step guided tutorial for Level 1 with:
- Welcome and data flow explanation
- Interactive steps for upgrading Source, Link, Sink
- Firewall purchase and defense app deployment
- Intel reports explanation and first report
- Victory goals summary

### Features
- Character dialogue overlay with Rusty portrait
- UI highlighting with animated pulse effects on target elements
- Hint banner showing current required action
- Skip button for returning players
- Tutorial state persistence (won't repeat after completion)
- Automatic step progression triggered by player actions

### New Files
- `Models/TutorialSystem.swift` - Tutorial steps, state, TutorialManager
- `Views/Components/TutorialOverlayView.swift` - Dialogue UI, highlight modifier, hint banner

### Modified Files
- `Engine/GameEngine.swift` - Added TutorialManager action triggers
- `Views/DashboardView.swift` - Tutorial overlay + card highlights
- `Models/StorySystem.swift` - Shortened Level 1 intro story
- `ISSUES.md` - Marked ENH-013 as complete

---

## Session Log: 2026-01-29

### Summary
Complete audio system overhaul - replaced procedural synth and system sounds with custom audio files.

### Audio Changes
- Added background music loop (background_music.m4a from user's custom track)
- Created 8 sound effect files: button_tap, upgrade, attack_incoming, attack_end, milestone, warning, error, malus_message
- Replaced AudioServicesPlaySystemSound with AVAudioPlayer for reliable playback
- Changed audio session to .playback category with mixWithOthers for layering
- Added music pause/resume on app background/foreground

### Files Changed
- `Engine/AudioManager.swift` - Complete rewrite using AVAudioPlayer
- `Engine/NavigationCoordinator.swift` - Added AmbientAudioManager pause/resume on scenePhase
- `Grid Watch Zero/Resources/` - New folder with 9 audio files

---

## Session Log: 2026-01-28 (Continued)

### Summary
Fixed all Minor issues: dialog accuracy, playtime tracking, proactive tier gates, and lifetime stats.

### Modified Files (5 additional)

#### Models
- `StorySystem.swift` - Updated all level intro dialogs with correct credit requirements
- `CampaignProgress.swift` - Added playtime tracking, intel reports, highest defense points
- `CampaignLevel.swift` - Added intelReportsSent to LevelCompletionStats

#### Views
- `UnitShopView.swift` - Proactive tier gate reason display

#### Engine
- `GameEngine.swift` - Capture intel reports in completion stats
- `NavigationCoordinator.swift` - Updated preview with new stat field

### Bug Fixes
- **ISSUE-012 FIXED**: Story dialogs now match actual level requirements (L1: ₵50K not ₵2K, etc.)
- **ISSUE-014 FIXED**: Playtime now tracked via totalPlaytimeTicks
- **ISSUE-015 FIXED**: Tier gate requirements shown proactively in unit shop
- **ISSUE-016 FIXED**: Added totalIntelReportsSent and highestDefensePoints to LifetimeStats

---

## Session Log: 2026-01-28

### Summary
Fixed all Critical and Major issues: cloud save entitlements, sound respecting volume, zero starting credits, auto-save on background, and defense app gating for intel collection.

### Modified Files (5 total)

#### Project Configuration
- `Grid Watch Zero.xcodeproj/project.pbxproj` - Removed CODE_SIGN_ENTITLEMENTS (awaiting developer account approval)

#### Engine
- `AudioManager.swift` - Check device volume before playing system sounds
- `NavigationCoordinator.swift` - Added scenePhase observer for auto-save on background
- `GameEngine.swift` - Gated intel collection behind defense app deployment

#### Models
- `LevelDatabase.swift` - Set all 7 levels to startingCredits: 0
- `DefenseApplication.swift` - Increased upgrade cost formula (10x base, steeper scaling)

### Bug Fixes
- **ISSUE-007 FIXED**: Cloud save code ready - awaiting paid developer account approval (~48hrs)
- **ISSUE-008 FIXED**: Sound respects device volume - added outputVolume check
- **ISSUE-009 FIXED**: All campaign levels start with 0 credits
- **ISSUE-010 FIXED**: Auto-save on app background/inactive via scenePhase observer
- **ISSUE-011 FIXED**: Intel collection requires deployed defense apps; upgrade costs 10x higher

### Balance Changes
- Defense app upgrade costs increased from `25*tier*1.18^level` to `250*tier*1.25^level`
- Intel collection now gated behind having at least 1 defense app deployed
- All campaign levels start with 0 credits (was 500 to 400K)

---

## Session Log: 2026-01-27

### Summary
Phase 8 Platform & Polish sprint - iPad layout improvements, game balance tuning, center panel visibility enhancements.

### Completed This Session
1. **iPad Layout Fixes**
   - Reduced sidebar widths (compact 300, regular 320, expanded 340)
   - Added `useVerticalCardLayout` for compact mode
   - Created `iPadNodeCards` function with horizontal/vertical layouts
   - Fixed truncated node card names with lineLimit(2) + minimumScaleFactor(0.8)

2. **Game Balance Tuning**
   - Increased level credit requirements for 30-60 min completion times:
     - L1: 50K→100K, L2: 100K→250K, L3: 500K→750K
     - L4: 1M→2M, L5: 3M→6M, L6: 8M→15M, L7: 25M→40M
   - Reduced T4-T6 unit costs 30-40%
   - Reduced attack frequencies at high threat levels
   - Reduced defense app unlock costs for T3-T6

3. **Center Panel Visibility (Partial)**
   - Increased `terminalDarkGray` and `terminalGray` brightness
   - Added thicker borders (1.5px, 0.7 opacity) and subtle glow to cards
   - Added background to iPad center panel
   - Improved NetworkTopologyView contrast (larger fonts, brighter borders)
   - Simplified node card stat layouts to horizontal inline format

4. **Accessibility**
   - Added Reduce Motion support to AlertBannerView components
   - Added accessibility labels to all banner types

### iPhone Layout Fix (COMPLETED)
**iPhone Layout Cramped**: The simplified node card layouts looked cramped on iPhone. The horizontal stat layout didn't fit well in narrow widths.

**Fix Applied**:
- Added `@Environment(\.horizontalSizeClass)` to SourceCardView, LinkCardView, SinkCardView
- Created responsive layouts using `isCompact` boolean:
  - iPhone (compact): Vertical stat layout with full-width upgrade buttons
  - iPad (regular): Horizontal inline stat layout (preserved existing design)
- Improved button tap targets on iPhone (larger padding, full-width)
- Added buffer percentage display to SinkCardView compact layout

### Helix Awakening Cinematic (COMPLETED)
15-second cinematic sequence triggered after Level 7 completion:

**Animation Phases:**
1. **Dormant (0-3s)** - Dark background, minimal glow
2. **Power Build (3-8s)** - Cyan aura intensifies, pulse animation, text appears
3. **Awakening (8-12s)** - Eye glow effect, environment shifts to blue
4. **Revealed (12-15s)** - Crossfade from Helixv2 to Helix_Awakened image

**Features:**
- Procedural cyberpunk audio (bass drone + harmonics that build intensity)
- Skip button (appears after 2s)
- Reduce motion support (simplified 5s sequence)
- Particle field effects
- Haptic feedback on awakening moment

**New Assets:**
- `Helixv2.imageset` - Dormant Helix portrait (706KB)
- `Helix_Awakened.imageset` - Awakened Helix looking upward

### Modified Files
- `Views/Theme.swift` - Brighter colors, thicker card borders, card shadows
- `Views/DashboardView.swift` - iPad layout improvements, center panel background
- `Views/Components/NodeCardView.swift` - Responsive layouts for iPhone/iPad
- `Views/Components/AlertBannerView.swift` - Reduce Motion support, accessibility
- `Views/Components/DefenseApplicationView.swift` - Larger topology fonts/icons
- `Models/LevelDatabase.swift` - Increased credit requirements for pacing
- `Engine/NavigationCoordinator.swift` - Added helixAwakening screen and flow

### New Files
- `Views/HelixAwakeningView.swift` - Level 7 completion cinematic with CinematicAudioManager
- `Models/ThreatSystem.swift` - Reduced attack frequencies (documented earlier)
- `Engine/UnitFactory.swift` - Reduced T4-T6 costs (documented earlier)
- `Models/DefenseApplication.swift` - Reduced defense unlock costs (documented earlier)

---

## Session Log: 2026-01-24

### Summary
Fixed critical ISSUE-006 (campaign progress loss), added checkpoint system, expanded T5/T6 unit catalog, and improved campaign UX.

### New Files
- `TEST_REPORT.md` - Comprehensive test and code review documentation

### Modified Files (14 total, +951/-320 lines)

#### Engine
- `GameEngine.swift` - Campaign offline progress, full checkpoint state persistence
- `NavigationCoordinator.swift` - Save-and-exit flow, redesigned VictoryProgressBar
- `UnitFactory.swift` - Added T5/T6 sources, links, and sinks

#### Models
- `CampaignProgress.swift` - Full state checkpoint (defenseStack, malusIntel), forced sync
- `DefenseApplication.swift` - IntelMilestone display names and bonus descriptions
- `LevelDatabase.swift` - Removed conflicting attack requirement from Level 2
- `StorySystem.swift` - Condensed all story dialogues (~50% shorter)
- `ThreatSystem.swift` - GHOST now has 0.2% attack chance (light probing)

#### Views
- `CriticalAlarmView.swift` - Redesigned MalusIntelPanel with mission context
- `DefenseApplicationView.swift` - Tier badges, inline tier upgrade buttons
- `StatsHeaderView.swift` - Campaign level info display, exit button
- `DashboardView.swift` - Campaign exit callback, tier restriction
- `HomeView.swift` - Checkpoint resume/restart buttons
- `UnitShopView.swift` - "OWNED" status, T5/T6 stat strings

### Bug Fixes
- **ISSUE-006 RESOLVED**: Campaign level completion no longer lost on hub return
  - Root cause: Race condition between async cloud sync and level completion
  - Fix: Multiple defensive measures (forced sync, reload verification, proper @Published triggering)

### New Content
| Tier | Source | Link | Sink |
|------|--------|------|------|
| T5 | Neural Tap Array (200/tick) | Neural Mesh Backbone (250 BW) | Neural Exchange (180 proc, 3.5x) |
| T6 | Helix Prime Collector (500/tick) | Helix Resonance Channel (600 BW) | Helix Integration Core (400 proc, 4.5x) |

### Balance Changes
- GHOST threat level now has light attacks (0.2% chance, 0.3x severity)
- Level 2: Removed "survive 8 attacks" requirement (conflicted with low-risk goal)

---

## Previous Session: 2026-01-20

### Files Changed (Playtesting & Bug Fixes)

#### New Files
- `Engine/CloudSaveManager.swift` - iCloud sync for campaign progress
- `Models/CosmeticSystem.swift` - UI themes and node skins
- `Views/PlayerProfileView.swift` - Player profile UI
- `PrivacyInfo.xcprivacy` - Privacy manifest for App Store
- `APP_STORE_METADATA.md` - App Store submission guide

#### Modified Files
- `Models/LevelDatabase.swift` - Removed attack requirement from Level 1 tutorial
- `Models/CampaignProgress.swift` - Added LevelCheckpoint for mid-level saves
- `Engine/GameEngine.swift` - Campaign checkpoint save/load system
- `Engine/NavigationCoordinator.swift` - Cloud sync on launch

#### Bug Found
**ISSUE-006**: Campaign level completion lost on return to hub (fixed 2026-01-24)

---

## Next Session Tasks

### CURRENT: Continue Campaign Sprint Plan

**Completed Sprints (1-8):**
- Sprint 1: Foundation & Navigation ✅
- Sprint 2: Campaign Data Model ✅
- Sprint 3: Level Flow & Victory ✅
- Sprint 4: Story Integration ✅
- Sprint 5: Cloud Save & Account ✅
- Sprint 6: Expanded Tiers & Threats ✅
- Sprint 7: Insane Mode & Polish ✅
- Sprint 8: Release Preparation ✅

**Completed: Sprint 8 - Release Preparation** ✅

**Remaining Manual Tasks:**
- [x] Create app icon (1024x1024 PNG) - COMPLETE
- [x] Capture screenshots for App Store - COMPLETE (resized to 1284×2778 iPhone, 2732×2048 iPad)
- [x] Set up TestFlight internal testing - COMPLETE
- [x] Final playtesting via TestFlight - IN PROGRESS
- [ ] Submit to App Store - Ready when testing complete

See APP_STORE_METADATA.md for full submission checklist.

### Quick Reference - Key Files
- `Engine/NavigationCoordinator.swift` - App navigation, story triggers
- `Models/CampaignLevel.swift` - Level definitions, victory conditions
- `Models/CampaignProgress.swift` - Progression tracking, CampaignState
- `Models/LevelDatabase.swift` - All 7 levels defined
- `Models/StorySystem.swift` - Character dialogues, story moments
- `Views/StoryDialogueView.swift` - Dialogue presentation UI

### Future Considerations
- Localization support
- watchOS companion (stats only)

---

## ROADMAP: Story Mode & Campaign System

### Version Target: 1.0.0

### Overview
Transform Grid Watch Zero from endless idle into a structured **campaign with 7 levels**, featuring Rusty as the main character, a progression system through increasingly difficult network protection scenarios, and culminating in joining the fight against Malus.

### Core Requirements

1. **Title Screen** - "Grid Watch Zero v1.0.0"
2. **Developer Credit** - "REMeadows"
3. **Main Menu** - "New Game", "Continue Game"
4. **Home Page** - Level select, stats, topology, Team info
5. **Cloud Save** - Apple ID / iCloud sync
6. **Player Account** - Stats tracking across campaigns
7. **Story Integration** - Character images from `AppPhoto/`
8. **Level-based Progression** - 7 campaign levels + "Insane" variants

### Campaign Architecture

**Main Character**: Rusty (the engineer)
**Mentor/Guide**: Neon Ronin (notices skills, offers challenges)
**Endgame**: Join the fight against Malus

| Level | Name | Threat Level | Defense Tier | Network Size | Victory Condition |
|-------|------|--------------|--------------|--------------|-------------------|
| 1 | Home Protection | GHOST/BLIP | Tier 1 | Small Home | Max T1 defense + Risk=GHOST |
| 2 | Small Office | SIGNAL | Tier 2 | Small Office | Max T2 defense + Risk=GHOST |
| 3 | Office Network | HUNTED | Tier 3 | Office | Max T3 defense + Risk=GHOST |
| 4 | Large Office | MARKED | Tier 4 | Large Office | Max T4 defense + Risk=GHOST |
| 5 | Campus Network | TARGETED* | Tier 5* | Campus | Max T5 defense + Risk=GHOST |
| 6 | Enterprise Network | HAMMERED* | Tier 6* | Enterprise | Max T6 defense + Risk=GHOST |
| 7 | City Network | CRITICAL* | Tier 6+ | City-wide | Max defense + Join team vs Malus |

*Note: Levels 5-7 require new threat levels and defense tiers beyond current implementation.

### Insane Mode
Each level has an "Insane" variant:
- 2x threat frequency
- 1.5x attack damage
- 0.75x credit income
- Special cosmetic reward on completion

---

## Sprint Plan

### Sprint 1: Foundation & Navigation (UI Shell) ✅ COMPLETE
**Goal**: Title screen, main menu, navigation structure

- [x] Create `TitleScreenView.swift` with logo, version, developer credit
- [x] Create `MainMenuView.swift` with New Game / Continue Game
- [x] Create `HomeView.swift` (level select, stats overview, team roster)
- [x] Add `NavigationCoordinator` for flow
- [x] Integrate existing `DashboardView` as the "in-level" gameplay screen
- [x] Preserve existing cyber defense interface (minimal changes to DashboardView)

**Key Constraint**: Keep `DashboardView` and all defense UI as-is. Navigation wraps around it.

**New Files Created**:
- `Views/TitleScreenView.swift` - Animated title with glitch effects, version, credits
- `Views/MainMenuView.swift` - New Game / Continue buttons with save detection
- `Views/HomeView.swift` - Campaign hub with level select, endless mode, team roster
- `Engine/NavigationCoordinator.swift` - App navigation state machine, GameplayContainerView, LevelCompleteView, LevelFailedView

**Modified Files**:
- `Project_PlagueApp.swift` - Entry point now uses RootNavigationView
- `Views/DashboardView.swift` - Changed from @StateObject to @EnvironmentObject for GameEngine injection

---

### Sprint 2: Campaign Data Model ✅ COMPLETE
**Goal**: Level definitions, progression tracking, save structure

- [x] Create `CampaignLevel.swift` model with:
  - Level ID, name, description
  - Starting resources, threat level, available tiers
  - Victory conditions (defense score, risk level)
  - Unlock requirements (previous level complete)
  - Insane mode flag
- [x] Create `CampaignProgress.swift` model with:
  - Current level
  - Completed levels (normal + insane)
  - Total stats across all runs
  - Unlocked tiers/units
- [x] Create `LevelDatabase.swift` with all 7 levels defined
- [x] Update `GameEngine` to accept level configuration
- [x] Add level completion detection logic

**New Files Created**:
- `Models/CampaignLevel.swift` - Level model, VictoryConditions, UnlockRequirement, NetworkSize, InsaneModifiers, LevelState, LevelCompletionStats, LevelGrade, LevelConfiguration
- `Models/CampaignProgress.swift` - Progress tracking, LifetimeStats, CampaignSaveManager, CampaignState (ObservableObject)
- `Models/LevelDatabase.swift` - All 7 levels with victory conditions, LevelSummary, progression path

**Modified Files**:
- `Engine/GameEngine.swift` - Added campaign mode properties, startCampaignLevel(), checkLevelVictoryConditions(), victoryProgress, level stat tracking
- `Views/HomeView.swift` - Updated to use real CampaignLevel and LevelDatabase, added CampaignState, PlayerStatsSheet

**Victory Condition System**:
- Defense tier requirement (must deploy apps of required tier)
- Defense points requirement (minimum DP threshold)
- Risk level requirement (must reduce risk to target level)
- Optional: credits earned, attacks survived, time limit

---

### Sprint 3: Level Flow & Victory ✅ COMPLETE
**Goal**: Start level, play, win/lose, return to menu

- [x] Add `startLevel(level: CampaignLevel)` to GameEngine (done in Sprint 2)
- [x] Configure starting state based on level (credits, nodes, threat) (done in Sprint 2)
- [x] Implement victory condition checking each tick (done in Sprint 2)
- [x] Create `LevelCompleteView` (stats, rewards, grade, next level button)
- [x] Create `LevelFailedView` (failure reason, tips, retry, return to menu)
- [x] Add level transition animations (spring-based fade/scale)
- [x] Preserve current gameplay loop entirely

**Enhanced Components in NavigationCoordinator.swift**:
- `LevelCompleteView` - Grade display (S/A/B/C), stat cards (time, credits, attacks, damage, DP), next mission button
- `LevelFailedView` - Failure reason icon, contextual tips per failure type, retry/return buttons
- `VictoryProgressBar` - Real-time progress toward victory conditions
- `ConditionPill` - Individual condition status indicators (T1, 50DP, GHOST, etc.)
- `StatDisplayRow` - Reusable stat display component
- `GameplayContainerView` - Proper level setup with GameEngine callbacks, campaign top bar, endless mode support

**AppScreen Enum Updates**:
- Added `FailureReason` to `levelFailed` case for proper routing
- Custom `Hashable` implementation for enum with associated values

---

### Sprint 4: Story Integration ✅ COMPLETE
**Goal**: Narrative beats, character appearances, dialogue

- [x] Create `StorySystem.swift` model (StoryCharacter, StoryMoment, StoryTrigger, StoryState, StoryDatabase)
- [x] Add story moments to each level:
  - Level intro (Rusty's mission briefings)
  - Mid-level events (Tish, FL3X, Malus, Helix appearances)
  - Victory celebration (character reactions)
  - Failure encouragement (retry motivation)
- [x] Create `StoryDialogueView.swift` (character portrait + typewriter text)
- [x] Integrate character images from AppPhoto folder to Assets.xcassets
- [x] Add story moments to level transitions via NavigationCoordinator
- [x] Final level: Helix awakening and team welcome

**New Files Created**:
- `Models/StorySystem.swift` - Complete story system with:
  - 5 characters (Rusty, Tish, FL3X, Malus, Helix, System)
  - 6 story triggers (levelIntro, levelComplete, levelFailed, midLevel, campaignStart, campaignComplete)
  - 20+ story moments across all 7 campaign levels
  - StoryState persistence for tracking seen stories
  - StoryDatabase singleton with query methods

- `Views/StoryDialogueView.swift` - Dialogue presentation with:
  - Character portrait with themed glow
  - Typewriter text effect (respects reduce motion)
  - Visual effects (glitch, static, pulse, scanlines)
  - Line-by-line progression with tap to skip/continue
  - Mood-based styling (neutral, urgent, warning, threatening, mysterious, celebration)

**Asset Catalog Updates**:
- Added Rusty.imageset, Tish.imageset, FL3X.imageset, Malus.imageset, Helix_Portrait.imageset
- Converted TishRaw.webp to Tish.png for compatibility

**NavigationCoordinator Updates**:
- Added storyState tracking and persistence
- Added showStoryThenNavigate() for story-then-action flow
- Story overlays on level complete/failed screens
- Level intro stories before gameplay starts
- Campaign start story on New Game

---

### Sprint 5: Cloud Save & Account ✅ COMPLETE
**Goal**: iCloud sync, player profile

- [x] Create `CloudSaveManager.swift` using NSUbiquitousKeyValueStore
- [x] Sync campaign progress across devices
- [x] Handle merge conflicts (latest timestamp wins)
- [x] Create `PlayerProfileView.swift` showing:
  - Total playtime
  - Levels completed (normal/insane)
  - Total credits earned lifetime
  - Attacks survived
  - Favorite defense setup
  - Best grades achieved
  - First connection date
- [x] Add sign-in prompt for iCloud features
- [x] Graceful offline fallback
- [x] Cloud sync status indicator in HomeView header
- [x] Sync conflict resolution UI

**New Files Created**:
- `Engine/CloudSaveManager.swift` - iCloud sync using NSUbiquitousKeyValueStore with:
  - CloudSaveStatus enum (available, syncing, synced, conflict, error, unavailable)
  - SyncableProgress for serializing progress + story state + timestamp + deviceId
  - Automatic sync on progress save
  - Conflict detection based on timestamp proximity
  - SyncConflict struct for presenting merge conflicts to user
  - External change notification handling

- `Views/PlayerProfileView.swift` - Comprehensive player profile with:
  - Cloud sync status section with manual sync button
  - Campaign progress section (progress bar, level/insane/star counts, grade badges)
  - Lifetime stats section (playtime, credits, attacks, damage, deaths)
  - Achievements summary (favorite tier, average clear time, best grade, first play date)
  - Account actions (reset progress)
  - Sync conflict resolution alert

**Modified Files**:
- `Engine/NavigationCoordinator.swift` - Added playerProfile screen, cloud sync integration, initial sync on app launch
- `Views/HomeView.swift` - Changed to use @EnvironmentObject for campaignState/cloudManager, added cloud sync indicator, profile button
- `Models/CampaignProgress.swift` - Added automatic cloud upload on save

---

### Sprint 6: Expanded Tiers & Threats ✅ COMPLETE
**Goal**: New defense tiers and threat levels for late-game

- [x] Add Tier 5 defense applications (6 categories × 2 apps each):
  - Quantum Firewall, Neural Barrier
  - Predictive SIEM
  - Autonomous Response
  - Quantum IDS
  - Neural Mesh Network
  - Neural Cipher
- [x] Add Tier 6 defense applications (Helix Integration for all categories):
  - Helix Shield, Helix Insight, Helix Sentinel, Helix Watcher, Helix Conduit, Helix Vault
- [x] Add new threat levels:
  - TARGETED (after MARKED) - 12% attack chance, 7x severity
  - HAMMERED (extreme pressure) - 18% attack chance, 10x severity
  - CRITICAL (city-level threats) - 25% attack chance, 15x severity
- [x] Add new attack types:
  - Coordinated Assault (multi-vector, T8+ threat)
  - Neural Hijack (AI override, T9+ threat)
  - Quantum Breach (ultimate attack, T10 threat)
- [x] Update NetDefenseLevel with quantum/neural/helix tiers
- [x] Balance new tiers for campaign progression
- [x] Update LevelDatabase levels 5-7 with new threat levels
- [x] Add T4-T6 firewall units to UnitFactory

**New Files**: None

**Modified Files**:
- `Models/ThreatSystem.swift` - Added TARGETED/HAMMERED/CRITICAL, new attack types, expanded NetDefenseLevel
- `Models/DefenseApplication.swift` - Added 30 new defense app tiers (T5/T6 for all 6 categories)
- `Models/Node.swift` - Added tier5/tier6 to NodeTier enum
- `Models/LevelDatabase.swift` - Updated levels 5-7 with new threat levels
- `Engine/UnitFactory.swift` - Added Quantum Shield, Neural Mesh Defense, Predictive Barrier, Helix Guardian

---

### Sprint 7: Insane Mode & Polish ✅ COMPLETE
**Goal**: Challenge variants, achievements, final polish

- [x] Implement Insane mode modifiers per level (2x threat frequency, 1.5x damage, 0.75x income)
- [x] Add Insane mode unlock (complete normal first)
- [x] Create Insane-specific achievements (8 new milestones for campaign/insane completion)
- [x] Add cosmetic rewards (5 UI themes, 5 node skins unlocked via Insane)
- [x] Add insane mode indicator in gameplay UI
- [x] Wire up Insane mode button in LevelDetailSheet

**New Files Created**:
- `Models/CosmeticSystem.swift` - Complete cosmetic reward system with:
  - 5 UI Themes: Classic, Crimson Protocol, Arctic Frost, Helix Purity, Malus Shadow
  - 5 Node Skins: Standard, Hardened, Quantum, Neural, Helix Core
  - InsaneUnlockRequirement enum for progressive unlocks
  - CosmeticState singleton for persistence
  - CosmeticUnlockBanner view for unlock notifications

**Modified Files**:
- `Engine/NavigationCoordinator.swift` - Major updates:
  - AppScreen enum now includes isInsane parameter
  - GameplayContainerView accepts and uses isInsane config
  - LevelCompleteView shows Insane-specific styling
  - Level retry preserves insane mode setting
  - Cosmetic unlock integration on level complete

- `Engine/GameEngine.swift` - Campaign modifiers:
  - Threat frequency multiplier from LevelConfiguration
  - Damage multiplier applied to all attack damage
  - updateCampaignMilestones() for milestone tracking

- `Models/ThreatSystem.swift` - Attack generation:
  - Added frequencyMultiplier parameter to tryGenerateAttack()

- `Models/MilestoneSystem.swift` - New milestone types:
  - Added campaign and insane MilestoneType cases
  - Added campaignLevelsCompleted and insaneLevelsCompleted tracking
  - 8 new milestones: campaign_1/3/5/7, insane_1/3/5/7

- `Views/HomeView.swift` - Insane mode UI:
  - LevelDetailSheet now has onStartNormal/onStartInsane callbacks
  - Added Insane mode button (unlocked after normal completion)
  - Added insaneModifiersInfo view showing 2x/150%/75% stats
  - Added insaneStats display for best Insane run
  - Fixed threat level color cases for new levels

---

### Sprint 8: Release Preparation ✅ COMPLETE
**Goal**: App Store ready

- [x] Privacy Manifest (PrivacyInfo.xcprivacy) - UserDefaults API declaration
- [x] App Store metadata documentation (APP_STORE_METADATA.md)
- [x] Code review for release blockers - passed
- [x] Build verification - successful, no warnings

**Manual Tasks Remaining:**
- [ ] Create app icon (1024x1024 PNG)
- [ ] Capture screenshots for iPhone 15 Pro Max (6.7")
- [ ] Capture screenshots for iPad Pro 12.9"
- [ ] TestFlight internal testing
- [ ] TestFlight external beta
- [ ] Submit to App Store

**New Files Created:**
- `PrivacyInfo.xcprivacy` - Privacy manifest declaring UserDefaults usage (CA92.1)
- `APP_STORE_METADATA.md` - Complete submission guide with:
  - App name and bundle ID
  - Short description (30 chars)
  - Promotional text (170 chars)
  - Full description (4000 chars)
  - Keywords (100 chars)
  - Screenshot requirements
  - Age rating guidance
  - Review notes for Apple
  - Pre-submission checklist

---

## Design Principles

1. **Preserve the Core**: The cyber defense interface (DashboardView, DefenseApplicationView, NetworkTopologyView) stays intact. Navigation wraps around it.

2. **Progressive Disclosure**: Each level introduces new mechanics gradually. Level 1 is tutorial-simple.

3. **Narrative Purpose**: Every level has story context. Rusty grows from home defender to city protector.

4. **Replayability**: Insane modes + endless mode after campaign completion.

5. **Respect Player Time**: Clear victory conditions, no grinding walls.

---

## Character Assets

Located in `AppPhoto/`:

| Character | Role | File | Resolution |
|-----------|------|------|------------|
| Malus | Antagonist AI | `Malus.png` | 2.7MB |
| Helix | Benevolent AI | `Helix_Portrait.png` | 91KB |
| Helix (alt) | Light version | `Helix_The_Light.png` | 15KB |
| Rusty | Team Lead | `Rusty.jpg` | 1.5MB |
| Tish | Hacker/Intel | `TishRaw.webp` | 57KB |
| Fl3x | Field Operative | `FL3X_3000x3000.jpg` | 1.1MB |

See `DESIGN.md` for detailed character profiles and visual descriptions.
