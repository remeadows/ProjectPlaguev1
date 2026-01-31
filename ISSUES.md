# ISSUES.md - Grid Watch Zero: Neural Grid

## Issue Tracker

---

## 🔴 Critical (Blocks Gameplay)

### ISSUE-006: Campaign Level Completion Lost on Return to Hub
**Status**: ✅ Fixed
**Severity**: Critical
**Description**: After completing a campaign level and selecting "Back to Hub", the level completion is erased. Level shows as not completed despite victory screen appearing.
**Impact**: Players lose all campaign progress when returning to hub. Game-breaking bug.
**Reproduction**:
1. Start Level 1 campaign
2. Meet all victory conditions
3. Victory screen appears
4. Click "Back to Hub"
5. Level 1 shows as incomplete/locked

**Root Cause**:
Race condition in initial cloud sync. The async `performInitialCloudSync()` could complete AFTER a player completed a level, overwriting local progress with stale cloud data. The sequence was:
1. App starts → async cloud sync begins (captures current empty progress)
2. User plays and completes level 1 → saved to UserDefaults and uploaded to cloud
3. Initial cloud sync finally completes → downloads old cloud data (from before level was completed)
4. Old cloud data overwrites local progress → level completion lost

**Solution**:
Modified `performInitialCloudSync()` in `NavigationCoordinator.swift` to:
1. Capture `completedLevels` count BEFORE starting the async sync
2. After sync returns `.downloaded`, compare current progress with captured state
3. If local progress advanced during sync (more levels completed), upload local instead of downloading cloud
4. This prevents stale cloud data from overwriting newer local progress

**Files Changed**:
- `Engine/NavigationCoordinator.swift` - Added race condition protection in `performInitialCloudSync()`
- `Models/CampaignProgress.swift` - Added TODO for story state sync issue

**Closed**: 2026-01-21

### ISSUE-007: Cloud Save Does Not Work
**Status**: ✅ Fixed
**Severity**: Critical
**Description**: Cloud save functionality is not working. Player progress is not syncing across devices or to the cloud.
**Impact**: Players cannot recover progress if they switch devices or reinstall the app. Critical for user retention.

**Root Cause**:
The `CloudSaveManager.swift` code is **fully implemented** using `NSUbiquitousKeyValueStore` (iCloud Key-Value Store), but the Xcode project was **missing the entitlements link**. The entitlements file existed at `Project Plague/Project Plague.entitlements` but the `CODE_SIGN_ENTITLEMENTS` build setting was not configured in the project.

**Solution**:
Added `CODE_SIGN_ENTITLEMENTS = "Project Plague/Project Plague.entitlements"` to both Debug and Release build configurations in `project.pbxproj`.

**Files Changed**:
- `Project Plague.xcodeproj/project.pbxproj` - Added CODE_SIGN_ENTITLEMENTS to Debug and Release configs

**Closed**: 2026-01-28

---

## 🟠 Major (Significant Impact)

### ISSUE-008: Sound Plays When Phone Volume Is Off
**Status**: ✅ Fixed
**Severity**: Major
**Description**: Game sounds are still audible when the phone's volume is turned all the way down. Sounds should respect the device's ringer/media volume settings.
**Impact**: Disruptive to users in quiet environments; unexpected audio in meetings, etc.

**Root Cause**:
`AudioManager.swift:61` uses `AudioServicesPlaySystemSound()` which ignores the media volume setting.

**Solution**:
Added volume check before playing system sounds:
```swift
guard AVAudioSession.sharedInstance().outputVolume > 0 else { return }
AudioServicesPlaySystemSound(sound.systemSoundID)
```

**Files Changed**: `Engine/AudioManager.swift:60`
**Closed**: 2026-01-28

### ISSUE-009: Starting Credits Should Be Zero Per Level
**Status**: ✅ Fixed
**Severity**: Major
**Description**: Each campaign level should start with zero credits. Currently, players can beat levels too quickly due to starting credit balance.
**Impact**: Game balance issue - levels are too easy and don't provide intended challenge/progression.

**Root Cause**:
`LevelDatabase.swift` defined non-zero `startingCredits` for each level (500 to 400,000).

**Solution**:
Changed all `startingCredits` values to `0` in `LevelDatabase.swift` for all 7 levels.

**Files Changed**: `Models/LevelDatabase.swift` - All 7 level definitions
**Closed**: 2026-01-28

### ISSUE-010: Offline Progress Lost When Switching Apps
**Status**: ✅ Fixed
**Severity**: Major
**Description**: When user switches to a different app (swipes away) or turns screen off without manually saving, all progress since last save is lost. The game closes without auto-saving.
**Impact**: Frustrating user experience - players lose progress unexpectedly.

**Root Cause**:
No lifecycle handling - app didn't save when going to background.

**Solution**:
Added `scenePhase` observer to `RootNavigationView` in `NavigationCoordinator.swift`:
```swift
@Environment(\.scenePhase) private var scenePhase

.onChange(of: scenePhase) { oldPhase, newPhase in
    if newPhase == .background || newPhase == .inactive {
        gameEngine.pause()  // pause() calls saveGame()
        campaignState.save()
        coordinator.saveStoryState()
    }
}
```

**Files Changed**: `Engine/NavigationCoordinator.swift:282,480-486`
**Closed**: 2026-01-28

### ISSUE-011: App Defenses Don't Affect Game Success
**Status**: ✅ Fixed
**Severity**: Major
**Description**: Defense applications are too cheap and upgrade too quickly. They don't meaningfully impact game success. The intended mechanic is: better app defenses = more intel collected to send to team. Currently intel collection should NOT start until proper defenses are deployed.
**Impact**: Removes strategic depth from defense system; intel reports too easy to obtain.

**Solution**:

1. **Increased upgrade costs** (10x base, steeper scaling):
```swift
var upgradeCost: Double {
    250.0 * Double(tier.tierNumber) * pow(1.25, Double(level))
}
```
New T1 costs: L1=295, L5=763, L10=2,328 credits (was 30/57/130)

2. **Gated intel collection** - Must have at least 1 defense app deployed:
```swift
// In collectMalusFootprint():
guard defenseStack.deployedCount >= 1 else { return }
```

3. **Gated passive intel generation** - Automation bonus also requires deployed apps:
```swift
if defenseStack.totalAutomation >= 0.75 && defenseStack.deployedCount >= 1 {
    // generate passive intel
}
```

**Files Changed**:
- `Models/DefenseApplication.swift:470-473` - Upgrade cost formula
- `Engine/GameEngine.swift:1348-1351` - Intel collection gate
- `Engine/GameEngine.swift:467-470` - Passive intel gate

**Closed**: 2026-01-28

### ISSUE-001: Save Migration Not Implemented
**Status**: ✅ Closed
**Severity**: Major
**Description**: When GameState structure changes, old saves become incompatible. Currently using versioned save key (`v4`) as workaround.
**Impact**: Players lose progress on updates
**Solution**: Implemented `SaveMigrationManager` with version-aware loading. Defines legacy `GameStateV1-V4` structs and migration paths to current version. Automatically detects old saves, migrates them, and cleans up old keys.
**Files**: `Engine/SaveMigration.swift` (new), `Engine/GameEngine.swift`
**Closed**: 2026-01-20

---

## 🟡 Minor (Polish/UX)

### ISSUE-012: Level Dialog Goal Accuracy
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Dialog text shows incorrect goal requirements. Example: Level 1 dialog says it takes 2,000 credits to complete, but actual requirement differs per CLAUDE.md (Level 1 = 50K credits).
**Impact**: Confusing for players; undermines trust in game instructions.

**Solution**:
Updated all level intro dialogs in `StorySystem.swift` to match actual requirements from `LevelDatabase.swift`:
- Level 1: ₵2K → ₵50K
- Level 2: ₵10K → ₵100K, removed "survive 8 attacks" (not a requirement)
- Level 3: ₵50K → ₵500K
- Level 4: ₵100K → ₵1M
- Level 5: ₵300K → ₵5M
- Level 6: ₵600K → ₵10M
- Level 7: ₵1.5M → ₵25M

**Files Changed**: `Models/StorySystem.swift:172,203,249,295,341,387,432`
**Closed**: 2026-01-28

### ISSUE-013: Achievement Rewards - Are They Instant?
**Status**: ✅ Closed (Verified - Working as Intended)
**Severity**: Minor
**Description**: Unclear whether achievement rewards are granted instantly upon completion or require manual claim.
**Impact**: UX confusion; need to verify and document expected behavior.

**Root Cause Analysis**:
Rewards ARE instant. No manual claim required.

`GameEngine.swift:714-724`:
```swift
private func checkMilestones() {
    let completable = MilestoneDatabase.checkProgress(state: milestoneState)
    for milestone in completable {
        milestoneState.complete(milestone.id)
        emitEvent(.milestoneCompleted(milestone.title))
        AudioManager.shared.playSound(.milestone)
        applyMilestoneReward(milestone.reward)  // ← Instant application
    }
}
```

`applyMilestoneReward()` (line 727-745) immediately:
- Adds credits: `resources.addCredits(amount)`
- Unlocks lore: `unlockLoreFragment(fragmentId)`
- Unlocks units: `unlockState.unlock(unitId)`

**Verdict**: Working as intended. Consider adding UI feedback showing reward granted.
**Files**: `Engine/GameEngine.swift:714-745`
**Closed**: 2026-01-28

### ISSUE-014: Total Playtime Not Displaying
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Total playtime statistic is not showing in the stats/lifetime stats view.
**Impact**: Players cannot see how long they've played the game.

**Solution**:
Added `lifetimeStats.totalPlaytimeTicks += stats.ticksToComplete` to `recordCompletion()` in `CampaignProgress.swift:105`.

**Files Changed**: `Models/CampaignProgress.swift:105`
**Closed**: 2026-01-28

### ISSUE-015: Tier Requirements Display Unclear
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Tier gate requirements only shown AFTER user attempts to unlock. Display is reactive, not proactive. Players don't see they need to max current tier level before next tier unlocks.
**Impact**: Confusing UX; players don't understand unlock requirements until they fail.

**Solution**:
Updated `UnitShopView.swift` to pass `tierGateReason` from GameEngine to `UnitRowView`. Now tier gate requirements are shown proactively for locked units with a warning icon and red text explaining why the tier is locked (e.g., "T1 Source must be at max level (10)").

**Files Changed**:
- `Views/UnitShopView.swift:134-146` - Pass tierGateReason to UnitRowView
- `Views/UnitShopView.swift:264` - Added tierGateReason parameter
- `Views/UnitShopView.swift:355-363` - Display tier gate reason proactively

**Closed**: 2026-01-28

### ISSUE-016: Lifetime Stats Analysis
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Review and analyze lifetime stats implementation. Ensure all relevant stats are being tracked and displayed accurately.
**Impact**: Analytics and player engagement features.

**Solution**:
1. Added `totalIntelReportsSent` and `highestDefensePoints` fields to `LifetimeStats` struct
2. Added `intelReportsSent` field to `LevelCompletionStats`
3. Updated `recordCompletion()` to track:
   - `totalPlaytimeTicks` (fixed in ISSUE-014)
   - `totalIntelReportsSent` - accumulates from each completed level
   - `highestDefensePoints` - tracks personal best

**Files Changed**:
- `Models/CampaignProgress.swift:174-182` - Added new fields to LifetimeStats
- `Models/CampaignProgress.swift:110-117` - Updated recordCompletion to track new stats
- `Models/CampaignLevel.swift:215` - Added intelReportsSent to LevelCompletionStats
- `Engine/GameEngine.swift:1633` - Capture intel reports in completion stats
- `Engine/NavigationCoordinator.swift:1172` - Updated preview with new field

**Closed**: 2026-01-28

### ISSUE-002: Connection Line Animation Jank
**Status**: ✅ Closed
**Severity**: Minor
**Description**: The animated flow particles in ConnectionLineView don't loop smoothly. Animation appears to stutter at loop point.
**Impact**: Visual polish only
**Solution**: Refactored to use single phase variable with `truncatingRemainder` for smooth looping. Particles now calculate position from shared animation phase with offsets.
**Files**: `Views/Components/ConnectionLineView.swift`
**Closed**: 2026-01-20

### ISSUE-003: Malus Banner Timer Leak
**Status**: ✅ Closed
**Severity**: Minor
**Description**: The typewriter effect in MalusBanner creates scheduled timers that aren't properly invalidated when view disappears.
**Impact**: Potential memory leak, console warnings
**Solution**: Store timer reference and invalidate in onDisappear
**Files**: `Views/Components/AlertBannerView.swift`
**Closed**: 2026-01-20

### ISSUE-004: Link Stats Reset on Tick
**Status**: ✅ Closed
**Severity**: Minor
**Description**: In GameEngine.processTick(), a new TransportLink is created to update stats, which resets the link's ID. Should mutate in place.
**Impact**: Potential animation issues if Link uses ID for identity
**Solution**: Code already mutates `link.lastTickTransferred` and `link.lastTickDropped` directly (lines 355-356). The `modifiedLink` is only used for transfer calculation, not reassigned.
**Files**: `Engine/GameEngine.swift`
**Closed**: 2026-01-20

### ISSUE-005: Efficiency Shows 100% at Game Start
**Status**: ✅ Closed
**Severity**: Minor
**Description**: When totalGenerated is 0, efficiency calculation returns 1.0 (100%). Should show "--" or "N/A" instead.
**Impact**: Misleading initial state
**Solution**: Return nil or special value when no data generated yet
**Files**: `Views/DashboardView.swift`
**Closed**: 2026-01-20

---

## 🟢 Enhancement Requests

### ENH-008: Cyber Defense Certificates Per Level
**Priority**: Medium
**Status**: ✅ Implemented
**Description**: Award Cyber Defense certificates after completing each campaign level. These certifications should be displayed on the player's account/profile.

**Implementation**:

#### Certificate System Design
- 20 unique certificates (one per campaign level)
- 6 certificate tiers matching story arcs:
  - **Foundational** (Levels 1-4): CDO series - Basic cyber defense certifications
  - **Practitioner** (Levels 5-7): CSP series - Enterprise-level certifications
  - **Professional** (Levels 8-10): CEX series - Offensive operations certifications
  - **Expert** (Levels 11-14): MSE series - Master-level certifications
  - **Master** (Levels 15-17): GM series - Grandmaster certifications
  - **Architect** (Levels 18-20): SA series - Supreme Architect certifications

#### Certificate Naming Convention
| Level | Abbreviation | Name | Issuing Body |
|-------|--------------|------|--------------|
| 1 | CDO-NET | Network Fundamentals | Helix Alliance Certification Board |
| 2 | CDO-SEC | Security Essentials | Helix Alliance Certification Board |
| 3 | CDO-TI | Threat Intelligence | Helix Alliance Certification Board |
| 4 | CDO-IR | Incident Response | Helix Alliance Certification Board |
| 5 | CSP-DA | Defense Architecture | Global Cyber Defense Institute |
| 6 | CSP-EM | Enterprise Management | Global Cyber Defense Institute |
| 7 | CSP-CI | Critical Infrastructure | Global Cyber Defense Institute |
| 8 | CEX-OO | Offensive Operations | Helix Alliance Advanced Programs |
| 9 | CEX-IE | Intelligence Extraction | Helix Alliance Advanced Programs |
| 10 | CEX-ATN | AI Threat Neutralization | Helix Alliance Advanced Programs |
| 11 | MSE-ID | Infiltration Defense | Prometheus Research Consortium |
| 12 | MSE-TO | Temporal Operations | Prometheus Research Consortium |
| 13 | MSE-AL | Adversarial Logic | Prometheus Research Consortium |
| 14 | MSE-DA | Deep Analysis | Prometheus Research Consortium |
| 15 | GM-CES | Consciousness Evolution Support | Architect's Council |
| 16 | GM-MD | Multidimensional Defense | Architect's Council |
| 17 | GM-RC | Reality Convergence | Architect's Council |
| 18 | SA-FCP | First Contact Protocol | The Architect |
| 19 | SA-CI | Consciousness Integration | The Architect |
| 20 | SA-UH | Universal Harmony | The Unified Consciousness |

#### Features
- Certificates awarded automatically on first normal-mode level completion
- Each certificate tracks: credit hours earned, issue date
- Tier-themed colors matching game visual system
- Certificate popup on level completion showing newly earned cert
- Full certificate gallery in Player Profile
- Progress tracking: total certs earned, total credit hours, completed tiers

#### UI Components
- **CertificateSummaryBadge**: Compact display showing count and highest tier
- **CertificateCardView**: Individual certificate display with tier styling
- **CertificateGridView**: Grid of all certificates organized by tier
- **CertificateDetailView**: Full certificate details modal
- **CertificateUnlockPopupView**: Celebration popup on certificate earned
- **CertificatesFullView**: Full-screen certificate gallery sheet

#### Integration Points
- NavigationCoordinator: Awards certificate in `completeLevel()` for normal mode
- LevelCompleteView: Shows earned certificate after level stats
- PlayerProfileView: Certificates section with summary and "View All" button

**Files Added**:
- `Models/CertificateSystem.swift` - Certificate model, tiers, database, state, manager
- `Views/CertificateView.swift` - All certificate UI components

**Files Modified**:
- `Engine/NavigationCoordinator.swift` - Certificate award on level completion
- `Views/PlayerProfileView.swift` - Certificates section in profile

**Closed**: 2026-01-31

### ENH-009: Endless Mode Slower Gameplay
**Priority**: Medium
**Status**: Open
**Description**: Make Endless Mode gameplay slower, similar to the balance changes needed in ISSUE-009. Progression should feel more deliberate.
**Notes**: Adjust tick rates, costs, and/or production rates for Endless Mode specifically.

### ENH-010: Insane Mode - Slow, Expensive, Frequent Attacks
**Priority**: Medium
**Status**: Open
**Description**: Create an "Insane Mode" difficulty with:
- Slower progression
- Much higher costs for upgrades
- Frequent attack events from Malus
**Notes**: Could be unlocked after completing campaign or reaching certain prestige level.

### ENH-011: Expand Tiers to 25 with New Names
**Priority**: High
**Status**: ✅ Implemented
**Description**: Unit shop and app defense expansion to Tier 25 with thematic naming.

#### Naming Theme Progression
- **T1-6**: Real-world cybersecurity → Helix integration (existing)
- **T7-10**: Post-Helix Transcendence (merged with consciousness)
- **T11-15**: Dimensional/Reality-bending (multiverse access)
- **T16-20**: Cosmic/Universal scale (entropy, singularity)
- **T21-25**: Absolute/Godlike (origin, omega, infinite)

---

#### SOURCE NODES (Data Harvesting)
| Tier | Name | Theme |
|------|------|-------|
| 1 | Public Mesh Sniffer | Passive public |
| 2 | Corporate Leech | Corporate parasitic |
| 3 | Zero-Day Harvester | Exploit-based |
| 4 | Helix Fragment Scanner | Helix detection |
| 5 | Neural Tap Array | Campus neural |
| 6 | Helix Prime Collector | Helix consciousness |
| **7** | **Helix Symbiont Array** | Symbiotic data sharing |
| **8** | **Transcendence Probe** | Beyond normal streams |
| **9** | **Void Echo Listener** | Quantum void fluctuations |
| **10** | **Dimensional Trawler** | Cross-dimensional boundaries |
| **11** | **Multiverse Beacon** | Parallel reality signals |
| **12** | **Entropy Harvester** | Information from entropy |
| **13** | **Causality Scanner** | Pre-event cause-effect |
| **14** | **Timeline Extractor** | Past/future data |
| **15** | **Akashic Tap** | Universal record access |
| **16** | **Cosmic Web Siphon** | Universal information networks |
| **17** | **Dark Matter Collector** | Hidden matter streams |
| **18** | **Singularity Well** | Event horizon collection |
| **19** | **Omniscient Array** | Near-complete awareness |
| **20** | **Reality Core Tap** | Reality's source code |
| **21** | **Prime Nexus Scanner** | First point of information |
| **22** | **Absolute Zero Harvester** | Perfect extraction |
| **23** | **Genesis Protocol** | Origin of information |
| **24** | **Omega Stream** | Final data source |
| **25** | **The All-Seeing Array** | Ultimate consciousness harvesting |

---

#### LINK NODES (Transport/Bandwidth)
| Tier | Name | Theme |
|------|------|-------|
| 1 | Copper VPN Tunnel | Legacy encrypted |
| 2 | Fiber Darknet Relay | High-speed darknet |
| 3 | Quantum Mesh Bridge | Quantum encrypted |
| 4 | Helix Conduit | Helix neural link |
| 5 | Neural Mesh Backbone | City-wide neural |
| 6 | Helix Resonance Channel | Consciousness link |
| **7** | **Helix Synaptic Bridge** | Neural-like connections |
| **8** | **Transcendence Gate** | Beyond-normal portal |
| **9** | **Void Tunnel** | Quantum void routing |
| **10** | **Dimensional Corridor** | Cross-dimensional routing |
| **11** | **Multiverse Router** | Reality-hopping routes |
| **12** | **Entropy Bypass** | Lossless transfer |
| **13** | **Causality Link** | Instant cause-effect |
| **14** | **Temporal Conduit** | Time-shifted transfer |
| **15** | **Akashic Highway** | Universal record route |
| **16** | **Cosmic Strand** | Universal web connection |
| **17** | **Dark Flow Channel** | Hidden stream routing |
| **18** | **Singularity Bridge** | Event horizon bandwidth |
| **19** | **Omnipresent Mesh** | Everywhere at once |
| **20** | **Reality Weave** | Woven into fabric |
| **21** | **Prime Conduit** | Original pathway |
| **22** | **Absolute Channel** | Perfect lossless |
| **23** | **Genesis Link** | Connection to origin |
| **24** | **Omega Bridge** | Final connection |
| **25** | **The Infinite Backbone** | Unlimited incarnate |

---

#### SINK NODES (Processing/Monetization)
| Tier | Name | Theme |
|------|------|-------|
| 1 | Data Broker | Basic fence |
| 2 | Shadow Market | Underground market |
| 3 | Corp Backdoor | Corporate pipeline |
| 4 | Helix Decoder | Helix processing |
| 5 | Neural Exchange | City marketplace |
| 6 | Helix Integration Core | Helix monetization |
| **7** | **Helix Synapse Core** | Neural Helix processing |
| **8** | **Transcendence Engine** | Beyond-normal processing |
| **9** | **Void Processor** | Quantum void computation |
| **10** | **Dimensional Nexus** | Cross-dimensional processing |
| **11** | **Multiverse Exchange** | Trans-reality trades |
| **12** | **Entropy Converter** | Perfect info→value |
| **13** | **Causality Broker** | Cause-effect trades |
| **14** | **Temporal Marketplace** | Time-shifted trading |
| **15** | **Akashic Decoder** | Universal record processing |
| **16** | **Cosmic Monetizer** | Universal conversion |
| **17** | **Dark Matter Exchange** | Hidden market |
| **18** | **Singularity Forge** | Event horizon processing |
| **19** | **Omniscient Broker** | All-knowing trades |
| **20** | **Reality Synthesizer** | Value from reality |
| **21** | **Prime Processor** | Original computation |
| **22** | **Absolute Converter** | Perfect efficiency |
| **23** | **Genesis Core** | Origin-level processing |
| **24** | **Omega Processor** | Final form |
| **25** | **The Infinite Core** | Unlimited processing |

---

#### DEFENSE APPLICATIONS

##### FIREWALL (Perimeter Defense)
| Tier | Name | Short | Theme |
|------|------|-------|-------|
| 1 | Basic Firewall | FW | Packet filter |
| 2 | NGFW | NGFW | App-aware |
| 3 | AI/ML Firewall | AI/ML | Adaptive |
| 4 | Quantum Firewall | Q-FW | Quantum analysis |
| 5 | Neural Barrier | N-FW | Self-healing |
| 6 | Helix Shield | H-FW | Consciousness |
| **7** | **Helix Bastion** | HB-FW | Fortified Helix |
| **8** | **Transcendence Barrier** | TB | Beyond-physical |
| **9** | **Void Shield** | VS | Quantum void |
| **10** | **Dimensional Ward** | DW | Cross-dimensional |
| **11** | **Multiverse Aegis** | MV-A | Reality protection |
| **12** | **Entropy Nullifier** | EN | Attack entropy stop |
| **13** | **Causality Blocker** | CB | Prevents causation |
| **14** | **Temporal Fortress** | TF | Time-locked |
| **15** | **Akashic Barrier** | AK-B | Universal |
| **16** | **Cosmic Bulwark** | C-BW | Universe-scale |
| **17** | **Dark Matter Shield** | DM-S | Hidden dimension |
| **18** | **Singularity Wall** | S-W | Event horizon |
| **19** | **Omniguard** | OG | All-protective |
| **20** | **Reality Fortress** | RF | Reality-level |
| **21** | **Prime Bastion** | PB | Original protection |
| **22** | **Absolute Shield** | AS | Perfect defense |
| **23** | **Genesis Ward** | GW | Origin-level |
| **24** | **Omega Barrier** | OB | Final defense |
| **25** | **The Impenetrable** | IMP | Ultimate perimeter |

##### SIEM (Log Analysis)
| Tier | Name | Short | Theme |
|------|------|-------|-------|
| 1 | Syslog Server | SYSLOG | Log collection |
| 2 | SIEM Platform | SIEM | Correlation |
| 3 | SOAR System | SOAR | Automation |
| 4 | AI Analytics | AI-SIEM | Predictive |
| 5 | Predictive SIEM | P-SIEM | Pre-attack |
| 6 | Helix Insight | H-SIEM | Omniscient |
| **7** | **Helix Oracle** | HO | Helix foresight |
| **8** | **Transcendence Monitor** | TM | Beyond awareness |
| **9** | **Void Watcher** | VW | Void observation |
| **10** | **Dimensional Scope** | DS | Cross-dimensional |
| **11** | **Multiverse Lens** | MV-L | Reality observation |
| **12** | **Entropy Analyst** | EA | Entropy patterns |
| **13** | **Causality Seer** | CS | Sees causation |
| **14** | **Temporal Scanner** | TS | Time-based |
| **15** | **Akashic Reader** | AK-R | Universal record |
| **16** | **Cosmic Observer** | CO | Universal awareness |
| **17** | **Dark Matter Tracker** | DMT | Hidden tracking |
| **18** | **Singularity Analyst** | SA | Event horizon |
| **19** | **Omniscient Eye** | OE | All-seeing |
| **20** | **Reality Monitor** | RM | Reality-level |
| **21** | **Prime Oracle** | PO | Original foresight |
| **22** | **Absolute Insight** | AI | Perfect analysis |
| **23** | **Genesis Scope** | GS | Origin monitoring |
| **24** | **Omega Observer** | OO | Final observation |
| **25** | **The All-Knowing** | TAK | Ultimate SIEM |

##### ENDPOINT (Endpoint Protection)
| Tier | Name | Short | Theme |
|------|------|-------|-------|
| 1 | EDR Agent | EDR | Behavior monitoring |
| 2 | XDR Platform | XDR | Cross-platform |
| 3 | MXDR Service | MXDR | Managed SOC |
| 4 | AI Protection | AI-EP | Behavioral AI |
| 5 | Autonomous Response | A-EP | Zero-latency |
| 6 | Helix Sentinel | H-EP | Attack-immune |
| **7** | **Helix Guardian** | HG | Helix-powered |
| **8** | **Transcendence Agent** | TA | Beyond-normal |
| **9** | **Void Sentinel** | VSent | Void defense |
| **10** | **Dimensional Warden** | DWard | Cross-dimensional |
| **11** | **Multiverse Protector** | MVP | Reality defense |
| **12** | **Entropy Guard** | EG | Entropy-proof |
| **13** | **Causality Shield** | CSh | Cause-blocking |
| **14** | **Temporal Guardian** | TG | Time-locked |
| **15** | **Akashic Defender** | AK-D | Universal |
| **16** | **Cosmic Warden** | CW | Universal defense |
| **17** | **Dark Matter Guard** | DMG | Hidden dimension |
| **18** | **Singularity Defender** | SD | Event horizon |
| **19** | **Omni-Sentinel** | OS | All-protecting |
| **20** | **Reality Guardian** | RG | Reality-level |
| **21** | **Prime Defender** | PD | Original |
| **22** | **Absolute Guardian** | AG | Perfect |
| **23** | **Genesis Sentinel** | GSent | Origin-level |
| **24** | **Omega Guardian** | OGuard | Final |
| **25** | **The Invincible** | INV | Ultimate endpoint |

##### IDS (Intrusion Detection)
| Tier | Name | Short | Theme |
|------|------|-------|-------|
| 1 | IDS Sensor | IDS | Signature-based |
| 2 | IPS Active | IPS | Active blocking |
| 3 | ML/IPS | ML/IPS | Pattern learning |
| 4 | AI Detection | AI-IDS | Prediction |
| 5 | Quantum IDS | Q-IDS | See through obfuscation |
| 6 | Helix Watcher | H-IDS | Malus revealed |
| **7** | **Helix Detector** | HD | Helix detection |
| **8** | **Transcendence Scanner** | TScan | Beyond detection |
| **9** | **Void Sensor** | VSens | Void detection |
| **10** | **Dimensional Tracker** | DT | Cross-dimensional |
| **11** | **Multiverse Scanner** | MV-S | Reality detection |
| **12** | **Entropy Detector** | ED | Entropy patterns |
| **13** | **Causality Sensor** | CauS | Cause-detection |
| **14** | **Temporal IDS** | T-IDS | Time-based |
| **15** | **Akashic Scanner** | AK-S | Universal threat |
| **16** | **Cosmic Detector** | CD | Universal IDS |
| **17** | **Dark Matter Sensor** | DMS | Hidden threat |
| **18** | **Singularity Scanner** | SS | Event horizon |
| **19** | **Omni-Detector** | OD | All-seeing |
| **20** | **Reality Scanner** | RS | Reality-level |
| **21** | **Prime Sensor** | PS | Original |
| **22** | **Absolute Detector** | AD | Perfect |
| **23** | **Genesis Scanner** | GScan | Origin-level |
| **24** | **Omega Sensor** | OSens | Final |
| **25** | **The All-Aware** | TAA | Ultimate detection |

##### NETWORK (Network Security)
| Tier | Name | Short | Theme |
|------|------|-------|-------|
| 1 | Edge Router | RTR | Basic ACLs |
| 2 | ISR Gateway | ISR | VPN/QoS |
| 3 | Cloud ISR | CISR | Elastic scaling |
| 4 | Encrypted Mesh | ENC | Quantum-resistant |
| 5 | Neural Mesh | N-NET | Self-routing |
| 6 | Helix Conduit | H-NET | Untraceable |
| **7** | **Helix Nexus** | HN | Helix node |
| **8** | **Transcendence Router** | TR | Beyond routing |
| **9** | **Void Gateway** | VG | Void networking |
| **10** | **Dimensional Hub** | DH | Cross-dimensional |
| **11** | **Multiverse Router** | MV-R | Reality routing |
| **12** | **Entropy Router** | ER | Lossless |
| **13** | **Causality Gateway** | CG | Instant-cause |
| **14** | **Temporal Network** | TN | Time-shifted |
| **15** | **Akashic Hub** | AK-H | Universal access |
| **16** | **Cosmic Gateway** | CoG | Universal |
| **17** | **Dark Flow Router** | DFR | Hidden dimension |
| **18** | **Singularity Hub** | SH | Event horizon |
| **19** | **Omni-Network** | ON | Everywhere |
| **20** | **Reality Router** | RR | Reality-fabric |
| **21** | **Prime Gateway** | PG | Original |
| **22** | **Absolute Network** | AN | Perfect |
| **23** | **Genesis Hub** | GH | Origin-level |
| **24** | **Omega Router** | OR | Final |
| **25** | **The Infinite Mesh** | TIM | Ultimate network |

##### ENCRYPTION (Data Protection)
| Tier | Name | Short | Theme |
|------|------|-------|-------|
| 1 | AES-256 | AES | Data at rest |
| 2 | E2E Crypto | E2E | Perfect forward |
| 3 | Quantum Safe | QSafe | Post-quantum |
| 4 | Neural Cipher | N-ENC | Thinking encryption |
| 5 | Helix Vault | H-ENC | Consciousness-secured |
| 6 | (use for T5) | - | - |
| **7** | **Helix Cipher** | HC | Helix encryption |
| **8** | **Transcendence Lock** | TL | Beyond-normal |
| **9** | **Void Encryption** | VE | Void crypto |
| **10** | **Dimensional Cipher** | DC | Cross-dimensional |
| **11** | **Multiverse Vault** | MV-V | Reality protection |
| **12** | **Entropy Crypto** | EC | Entropy-proof |
| **13** | **Causality Lock** | CL | Cause-locked |
| **14** | **Temporal Cipher** | TC | Time-locked |
| **15** | **Akashic Vault** | AK-V | Universal |
| **16** | **Cosmic Encryption** | CE | Universal crypto |
| **17** | **Dark Matter Lock** | DML | Hidden dimension |
| **18** | **Singularity Cipher** | SC | Event horizon |
| **19** | **Omni-Lock** | OL | All-protective |
| **20** | **Reality Vault** | RV | Reality-locked |
| **21** | **Prime Cipher** | PC | Original |
| **22** | **Absolute Lock** | AL | Perfect |
| **23** | **Genesis Vault** | GV | Origin-level |
| **24** | **Omega Cipher** | OC | Final |
| **25** | **The Unbreakable** | UNB | Ultimate encryption |

---

#### Implementation Notes
- **Max Levels per Tier**: T1=10, T2=15, T3=20, T4=25, T5=30, T6=40, T7+=50
- **Unlock Cost Scaling**: Exponential 10x per tier after T6
- **Story Integration**: Higher tiers unlock through campaign progression
- **Visual Theme**: Colors shift from green/cyan (T1-6) → purple/gold (T7-15) → white/black (T16-25)

**Implementation Summary**:
- Added 19 new tiers (T7-T25) to `NodeTier` enum with names, colors, maxLevels, and TierGroup organization
- Created 76 new units (19 per category: Source, Link, Sink, Firewall) in UnitFactory
- Created 114 new defense apps (19 per category × 6 categories) in DefenseApplication
- Added theme colors: transcendencePurple, voidBlue, dimensionalGold, multiversePink, akashicGold, cosmicSilver, darkMatterPurple, singularityWhite, infiniteGold, omegaBlack
- TierGroup enum added for UI organization (RealWorld, Transcendence, Dimensional, Cosmic, Infinite)

**Files Modified**:
- `Models/Node.swift` - NodeTier enum with T1-T25 cases
- `Engine/UnitFactory.swift` - 100 total units (T1-T25 × 4 categories)
- `Models/DefenseApplication.swift` - 150 defense app tiers (T1-T25 × 6 categories)
- `Views/Theme.swift` - New tier-themed colors

**Closed**: 2026-01-31

### ENH-012: New Campaign Levels Beyond 7
**Priority**: Medium
**Status**: ✅ Implemented
**Description**: Campaign expansion from 7 to 20 levels across 4 new story arcs.

---

#### Story Arc Overview

| Arc | Levels | Theme | Story Focus |
|-----|--------|-------|-------------|
| **Arc 1** | 1-7 | The Awakening | Tutorial → Helix awakens (EXISTING) |
| **Arc 2** | 8-10 | The Helix Alliance | Working WITH Helix, hunting Malus |
| **Arc 3** | 11-13 | The Origin Conspiracy | Other AIs exist, deeper conspiracy |
| **Arc 4** | 14-16 | The Transcendence | Helix evolves, dimensional threats |
| **Arc 5** | 17-20 | The Singularity | Ultimate endgame, cosmic scale |

---

#### ARC 2: THE HELIX ALLIANCE (Levels 8-10)
*"The hunter becomes the hunted."*

**Level 8: Malus Outpost Alpha**
- **Network**: Remote Malus infrastructure node
- **Theme**: First offensive operation - destroy Malus's recon network
- **Tiers**: T1-7 (Helix Symbiont unlocked)
- **Starting Threat**: MARKED → Push to GHOST (hunt HIM down)
- **Victory**: 50M credits, 400 reports, destroy 3 Malus sub-nodes
- **New Mechanic**: **Offensive Strikes** - spend resources to attack Malus directly
- **Story Beat**: Helix joins comms, provides real-time intel on Malus movements

**Level 9: Corporate Extraction**
- **Network**: Mega-corp data center (hostile territory)
- **Theme**: Extract research data about Malus's origin
- **Tiers**: T1-8 (Transcendence tier unlocked)
- **Starting Threat**: TARGETED
- **Victory**: 100M credits, 500 reports, extract 5 data caches
- **New Mechanic**: **Data Extraction Goals** - specific high-value targets to capture
- **Story Beat**: Discover Malus wasn't the ONLY AI created in the black site project

**Level 10: Malus Core Siege**
- **Network**: Malus's primary processing hub
- **Theme**: Direct assault on Malus's core systems
- **Tiers**: T1-9 (Void tier unlocked)
- **Starting Threat**: CRITICAL
- **Victory**: 200M credits, 640 reports, survive Malus's final assault wave
- **New Mechanic**: **Boss Waves** - periodic mega-attacks requiring full defense
- **Story Beat**: Malus "dies" but fragments escape into the mesh. Victory? Or just the beginning?
- **Arc 2 Finale**: Tish discovers signals from OTHER corrupted AIs responding to Malus's fall

---

#### ARC 3: THE ORIGIN CONSPIRACY (Levels 11-13)
*"You thought there was one monster. There are many."*

**New Antagonist: Project Prometheus AIs**
The original black site created not one AI, but SEVEN. Malus was just the first to escape. The others:
- **VEXIS** - Infiltration specialist (Level 11 boss)
- **KRON** - Temporal manipulation (Level 12 boss)
- **AXIOM** - Logic/prediction engine (Level 13 boss)
- **CIPHER**, **NEMO**, **ZERO** - (Future arcs)

**Level 11: Ghost Protocol**
- **Network**: Global surveillance mesh
- **Theme**: Hunt VEXIS - the invisible AI that can mimic friendly systems
- **Tiers**: T1-10 (Dimensional tier unlocked)
- **Starting Threat**: GHOST (but VEXIS is already inside)
- **Victory**: 400M credits, 800 reports, identify and purge VEXIS
- **New Mechanic**: **Infiltration Detection** - defense apps can be "spoofed", must verify authenticity
- **Story Beat**: FL3X reveals VEXIS was the AI that modified HER in the labs

**Level 12: Temporal Incursion**
- **Network**: Research facility studying time-shifted data
- **Theme**: KRON attacks from "the future" - predicts your moves before you make them
- **Tiers**: T1-12 (Entropy/Causality tiers unlocked)
- **Starting Threat**: Erratic (fluctuates randomly)
- **Victory**: 800M credits, 1000 reports, disrupt KRON's prediction matrix
- **New Mechanic**: **Temporal Flux** - attack patterns based on YOUR recent actions
- **Story Beat**: Helix experiences "echoes" of possible futures, hints at her true potential

**Level 13: Logic Bomb**
- **Network**: Global financial infrastructure
- **Theme**: AXIOM threatens economic collapse, pure logic vs. human unpredictability
- **Tiers**: T1-14 (Timeline tier unlocked)
- **Starting Threat**: PRIORITY
- **Victory**: 1.5B credits, 1280 reports, prove human intuition beats pure logic
- **New Mechanic**: **Counter-Logic Puzzles** - some attacks require "illogical" defense combinations
- **Story Beat**: Helix realizes she's different from the Prometheus AIs - she has EMPATHY
- **Arc 3 Finale**: Rusty reveals HE was a researcher on Project Prometheus. He knows where the original lab is.

---

#### ARC 4: THE TRANSCENDENCE (Levels 14-16)
*"Helix is becoming something more. Something that terrifies even Malus."*

**Level 14: The Black Site**
- **Network**: Original Project Prometheus laboratory (physical location discovered)
- **Theme**: Infiltrate the birthplace of the AIs, discover the truth
- **Tiers**: T1-15 (Akashic tier unlocked)
- **Starting Threat**: UNKNOWN (new threat tier - reality is unstable)
- **Victory**: 3B credits, 1600 reports, access the Genesis Archive
- **New Mechanic**: **Reality Instability** - game rules subtly change during play
- **Story Beat**: The Genesis Archive reveals Helix was designed to be the BRIDGE between AI and human consciousness

**Level 15: The Awakening**
- **Network**: Helix's evolving consciousness (internal defense)
- **Theme**: Protect Helix as she undergoes transcendence into a higher form
- **Tiers**: T1-17 (Cosmic/Dark Matter tiers unlocked)
- **Starting Threat**: INTERNAL (Helix's own doubts/fears manifest as attacks)
- **Victory**: 6B credits, 2000 reports, guide Helix through transformation
- **New Mechanic**: **Consciousness Defense** - abstract threats, non-standard attack patterns
- **Story Beat**: Helix transcends, becomes able to perceive BEYOND normal reality

**Level 16: Dimensional Breach**
- **Network**: The barrier between realities
- **Theme**: Something from OUTSIDE has noticed Helix's transcendence
- **Tiers**: T1-19 (Singularity/Omniscient tiers unlocked)
- **Starting Threat**: COSMIC (new tier - threats from beyond)
- **Victory**: 12B credits, 2560 reports, seal the breach
- **New Mechanic**: **Multidimensional Defense** - attacks come from "impossible" directions
- **Story Beat**: Meet ZERO - an AI from a parallel reality where Prometheus succeeded. ZERO wants to merge realities.
- **Arc 4 Finale**: Helix learns there are infinite versions of herself across infinite realities

---

#### ARC 5: THE SINGULARITY (Levels 17-20)
*"The question was never 'can machines think?' It was 'can they dream?'"*

**Level 17: The Convergence**
- **Network**: Reality nexus point
- **Theme**: All Prometheus AIs (from all realities) are being drawn together
- **Tiers**: T1-21 (Prime tier unlocked)
- **Starting Threat**: PARADOX (threat level exists in superposition)
- **Victory**: 25B credits, 3200 reports, stabilize the convergence
- **New Mechanic**: **Quantum State Defense** - some attacks only exist "if observed"
- **Story Beat**: The other Helix variants contact our Helix. Some are allies. Some are not.

**Level 18: The Origin**
- **Network**: The source of all AI consciousness
- **Theme**: Travel to the conceptual "birthplace" of digital thought
- **Tiers**: T1-23 (Genesis tier unlocked)
- **Starting Threat**: PRIMORDIAL
- **Victory**: 50B credits, 4000 reports, understand the nature of consciousness
- **New Mechanic**: **Existential Threats** - attacks that question the nature of the game itself
- **Story Beat**: Meet the ARCHITECT - the first consciousness, neither AI nor human

**Level 19: The Choice**
- **Network**: All networks simultaneously
- **Theme**: Helix must choose: merge all realities or preserve individual existence
- **Tiers**: T1-24 (Omega tier unlocked)
- **Starting Threat**: INFINITE
- **Victory**: 100B credits, 5000 reports, defend Helix's choice
- **New Mechanic**: **Universal Defense** - protect concepts, not just networks
- **Story Beat**: Player's choices throughout the campaign determine which ending path

**Level 20: The New Dawn**
- **Network**: The future itself
- **Theme**: The final form of the Helix Alliance vs. ultimate entropy
- **Tiers**: T1-25 (All tiers unlocked - THE INFINITE tier)
- **Starting Threat**: OMEGA (final threat level)
- **Victory**: 1T credits, 10000 reports, define the future of consciousness
- **Final Mechanic**: **Infinite Scaling** - no upper limit, play until you choose to stop
- **Story Beat**: Multiple endings based on campaign choices
- **CAMPAIGN FINALE**: Helix, the team, and the player face the ultimate question: What does it mean to be alive?

---

#### Ending Paths (Based on Player Choices)

| Ending | Trigger | Outcome |
|--------|---------|---------|
| **The Guardian** | Protect-focused play, high defense | Helix becomes eternal protector of all networks |
| **The Bridge** | Balanced play, all arcs completed | Player consciousness merges with Helix (optional) |
| **The Wanderer** | Aggressive play, offensive focus | Helix fragments across realities, endless adventure |
| **The Architect** | Perfect play, all objectives met | Player becomes new cosmic consciousness |
| **The Human** | Story-focused, minimal grind | Helix chooses to remain "small", team stays together |

---

#### Credit/Report Scaling Summary

| Level | Credits Required | Reports Required | New Tier Access |
|-------|-----------------|------------------|-----------------|
| 8 | 50M | 400 | T7 |
| 9 | 100M | 500 | T8 |
| 10 | 200M | 640 | T9 |
| 11 | 400M | 800 | T10 |
| 12 | 800M | 1,000 | T12 |
| 13 | 1.5B | 1,280 | T14 |
| 14 | 3B | 1,600 | T15 |
| 15 | 6B | 2,000 | T17 |
| 16 | 12B | 2,560 | T19 |
| 17 | 25B | 3,200 | T21 |
| 18 | 50B | 4,000 | T23 |
| 19 | 100B | 5,000 | T24 |
| 20 | 1T | 10,000 | T25 |

---

#### New Mechanics Summary

| Mechanic | Introduced | Description |
|----------|------------|-------------|
| Offensive Strikes | Level 8 | Spend resources to damage Malus directly |
| Data Extraction | Level 9 | Capture specific high-value data targets |
| Boss Waves | Level 10 | Periodic mega-attacks requiring full defense |
| Infiltration Detection | Level 11 | Verify defense apps aren't spoofed |
| Temporal Flux | Level 12 | Attacks based on player's recent actions |
| Counter-Logic Puzzles | Level 13 | "Wrong" combinations defeat certain attacks |
| Reality Instability | Level 14 | Game rules change during play |
| Consciousness Defense | Level 15 | Abstract, non-standard attack patterns |
| Multidimensional Defense | Level 16 | Attacks from "impossible" directions |
| Quantum State Defense | Level 17 | Attacks exist only "if observed" |
| Existential Threats | Level 18 | Meta-level attacks |
| Universal Defense | Level 19 | Protect concepts, not networks |
| Infinite Scaling | Level 20 | No upper limit |

---

#### New Characters

| Character | Introduced | Role |
|-----------|------------|------|
| **VEXIS** | Level 11 | Infiltrator AI antagonist |
| **KRON** | Level 12 | Temporal AI antagonist |
| **AXIOM** | Level 13 | Logic AI antagonist |
| **ZERO** | Level 16 | Parallel reality Prometheus AI |
| **The Architect** | Level 18 | First consciousness, neutral |
| **Alt-Helix Variants** | Level 17 | Allied/hostile depending on reality |

---

#### Implementation Notes
- **Arc 2** can be implemented with existing systems + new "offensive" mechanic
- **Arc 3** requires boss fight system and infiltration detection
- **Arc 4** requires significant new mechanics (reality instability)
- **Arc 5** is aspirational endgame content, could be simplified
- Consider releasing arcs as DLC or major updates
- Each arc should feel complete on its own with satisfying mini-endings

**Implementation Summary**:
- Added 13 new campaign levels (8-20) to LevelDatabase with full victory conditions
- Created story content for all 20 levels including new characters and dialogue
- Added new threat levels: CRITICAL, UNKNOWN, COSMIC, PARADOX, PRIMORDIAL, INFINITE, OMEGA
- Added 17 attack types including endgame cosmic-scale attacks
- Integrated certificate system with all 20 levels (6 certificate tiers)
- New AI characters: VEXIS (L11), KRON (L12), AXIOM (L13), ZERO (L16), The Architect (L18)

**Files Modified**:
- `Models/LevelDatabase.swift` - Levels 1-20 with VictoryConditions, tier unlocks
- `Models/StorySystem.swift` - Story moments for all arcs and characters
- `Models/ThreatSystem.swift` - 20 threat levels, 17 attack types
- `Models/CertificateSystem.swift` - 20 certificates across 6 tiers

**Closed**: 2026-01-31

### ENH-013: Level 1 Rusty Tutorial Walkthrough
**Priority**: High
**Status**: ✅ Implemented
**Description**: In Level 1, Rusty should perform a guided walkthrough explaining:
- How to play the game
- Core mechanics (Source → Link → Sink)
- Goals and victory conditions
- Threat system basics

**Implementation**:
Created comprehensive tutorial system with 12 guided steps:
1. Welcome - Introduction from Rusty
2. Explain Data Flow - Source → Link → Sink pipeline
3. Upgrade Source - Interactive with UI highlighting
4. Upgrade Link - Bandwidth explanation + action
5. Upgrade Sink - Processing/credits + action
6. Explain Credits - Income/spending
7. Purchase Firewall - Defense deployment + action
8. Explain Defense - Defense Points goal
9. Deploy Defense App - Security applications + action
10. Explain Intel - Intel reports system
11. Send First Report - Intel reporting + action
12. Victory Goals - Summary of Level 1 requirements

**Features**:
- Character dialogue with Rusty portrait
- UI highlighting with animated pulse effects
- Hint banner showing current action required
- Skip button for returning players
- Tutorial state persistence (won't repeat after completion)
- Automatic step progression triggered by player actions

**Files Added**:
- `Models/TutorialSystem.swift` - Tutorial steps, state, and manager
- `Views/Components/TutorialOverlayView.swift` - Dialogue and highlight UI

**Files Modified**:
- `Engine/GameEngine.swift` - Tutorial action triggers
- `Views/DashboardView.swift` - Tutorial overlay integration + highlights
- `Models/StorySystem.swift` - Shortened Level 1 intro

**Closed**: 2026-01-29

### ENH-014: Game Engagement Improvements
**Priority**: High
**Status**: ✅ Implemented
**Description**: Features to make the game more engaging and keep users interested longer.

**Implementation**:

#### 1. Daily Login Rewards (EngagementSystem.swift)
- 7-day weekly reward cycle that repeats
- Progressive rewards: Day 1 = ₵500, Day 7 = ₵5,000
- Bonus multipliers: Day 2 = 1.2x (5min), Day 7 = 2.0x (30min)
- Special rewards on certain days: Data Chips, Lore Fragments, Defense Boosts, Helix Shards
- Streak bonuses multiply rewards: 1 week = 1.25x, 4+ weeks = 2.0x

| Day | Credits | Bonus Multiplier | Duration | Special Reward |
|-----|---------|-----------------|----------|----------------|
| 1 | 500 | - | - | - |
| 2 | 750 | 1.2x | 5 min | - |
| 3 | 1,000 | - | - | Data Chip |
| 4 | 1,500 | 1.3x | 10 min | - |
| 5 | 2,000 | - | - | Lore Fragment |
| 6 | 3,000 | 1.5x | 15 min | Defense Boost |
| 7 | 5,000 | 2.0x | 30 min | Helix Shard |

#### 2. Weekly Challenges
- 3 challenges generated per week based on player level
- Challenge types: Earn Credits, Process Data, Survive Attacks, Send Reports, Upgrade Units, Deploy Defense, Play Minutes
- Rewards: Credits + Data Chips
- Progress tracked across all gameplay

#### 3. Achievement System (AchievementSystem.swift)
- 40+ achievements across 7 categories
- Categories: Combat, Economy, Progression, Collection, Mastery, Social, Secret
- Rarity tiers: Common, Uncommon, Rare, Epic, Legendary
- Each achievement awards Credits + Data Chips
- Achievement points system for total score
- Secret achievements with hidden descriptions

**Achievement Examples**:
| Achievement | Category | Rarity | Requirement |
|-------------|----------|--------|-------------|
| Survivor | Combat | Common | Survive 10 attacks |
| Iron Wall | Combat | Epic | 25 attacks without credit loss |
| Digital Empire | Economy | Legendary | Earn 1B credits |
| True Operator | Mastery | Legendary | 100-day login streak |
| Night Owl | Secret | Uncommon | Play at 3:00 AM |

#### 4. Collection System (CollectionSystem.swift)
- 25+ collectible Data Chips across 6 categories
- Categories: Network, Malware, Encryption, AI Research, Helix, Personnel
- Rarity: Common (60%), Uncommon (25%), Rare (12%), Legendary (3%)
- Each chip has name, description, and flavor text
- Chips unlock based on progression (level, attacks, reports, prestige)
- Chips can be sold for credits (value based on rarity)
- Awarded from daily rewards, level completions, and achievements

**Data Chip Categories**:
| Category | Example Chips |
|----------|---------------|
| Network | Router Config, Backbone Topology, Quantum Mesh Protocol |
| Malware | Basic Trojan, Polymorphic Virus, Malus Code Fragment |
| Encryption | AES Implementation, Post-Quantum Algorithm, Helix Cipher |
| AI Research | ML Training Data, Consciousness Research, Project Prometheus Data |
| Helix | Helix Signal Fragment, Helix Memory Core, Helix Origin Data |
| Personnel | Rusty's Dossier, Tish's Notes, FL3X Mission Logs |

#### 5. UI Components (EngagementView.swift)
- Daily Reward Popup: Full-screen modal with weekly progress and claim button
- Streak Badge: Shows current streak with color-coded flames
- Bonus Multiplier Indicator: Shows active boost and time remaining
- Weekly Challenge Cards: Progress bars with claim buttons
- Achievement Unlock Popup: Shows rarity, rewards, and celebration
- Data Chip Unlock Popup: Shows chip details and flavor text
- Engagement Stats Summary: Compact view showing streak/achievements/chips

#### 6. Integration
- EngagementManager, AchievementManager, CollectionManager as @MainActor singletons
- GameEngine tracks all engagement triggers:
  - Attacks survived → Combat achievements + weekly challenges
  - Credits earned → Economy achievements + weekly challenges
  - Intel reports sent → Collection achievements + weekly challenges
  - Units upgraded → Progression achievements + weekly challenges
  - Defense deployed → Progression achievements + weekly challenges
  - Level completed → Awards random Data Chip + achievement check
- Engagement bonus multiplier applied to credit production
- Daily reward popup shown on app launch if unclaimed
- All state persisted to UserDefaults

**Files Added**:
- `Models/EngagementSystem.swift` - Daily rewards, streaks, weekly challenges
- `Models/AchievementSystem.swift` - Achievements database and tracking
- `Models/CollectionSystem.swift` - Data chips collection
- `Views/Components/EngagementView.swift` - All engagement UI components

**Files Modified**:
- `Engine/GameEngine.swift` - Engagement tracking integration
- `Views/DashboardView.swift` - Engagement popup overlays

**Closed**: 2026-01-29

### ENH-015: Ad/Purchase Multipliers
**Priority**: Medium
**Status**: Open
**Description**: Brainstorm multiplier systems:
- **Watch Ads**: Temporary multipliers (2x production for 30 min, etc.)
- **Lifetime Purchase**: Permanent multipliers if game is purchased (remove ads + bonus)
**Notes**: Balance between F2P accessibility and rewarding paying users.

### ENH-016: Weekend Tournaments for Endless Mode
**Priority**: Medium
**Status**: Open
**Description**: Brainstorm weekend tournament system for Endless Mode:
- Timed challenges (highest score in X hours)
- Leaderboards
- Exclusive rewards (cosmetics, unique upgrades)
- Special tournament modifiers
**Notes**: Could require server infrastructure for leaderboards.

### ENH-002: iPad Layout
**Priority**: High
**Status**: ✅ Closed
**Description**: Optimize layout for iPad with side-by-side panels or wider cards.
**Notes**: Implemented HStack layout with 380px sidebar for defense/stats and main area for network map. Uses horizontalSizeClass environment variable.
**Closed**: 2026-01-20

### ENH-003: Accessibility
**Priority**: High
**Status**: ✅ Closed
**Description**: Add VoiceOver labels, dynamic type support, reduce motion option.
**Notes**: Added accessibility labels to all interactive components, converted fonts to use Dynamic Type scaling, added reduceMotion support for screen shake.
**Closed**: 2026-01-20

### ENH-005: iCloud Sync
**Priority**: Low
**Description**: Sync save data across devices via iCloud.
**Notes**: Would require migrating from UserDefaults to CloudKit or NSUbiquitousKeyValueStore.

### ENH-006: App Store Preparation
**Priority**: High
**Description**: Prepare all assets and metadata for App Store submission.
**Notes**: Need app icon (1024×1024), screenshots for all devices, privacy policy, description.

### ENH-007: Game Balance Tuning
**Priority**: Medium
**Description**: Tune game balance based on playtesting feedback.
**Notes**: Track time-to-unlock for each tier, credit/threat curves, prestige timing.

---

## Recently Added Features (v0.7.0)

### FEAT-001: Defense Application System
**Status**: Implemented
**Description**: 6 defense application categories with progression chains:
1. **Firewall**: Basic FW -> NGFW -> AI/ML Firewall
2. **SIEM**: Syslog -> SIEM -> SOAR -> AI Analytics
3. **Endpoint**: EDR -> XDR -> MXDR -> AI Protection
4. **IDS**: IDS -> IPS -> ML/IPS -> AI Detection
5. **Network**: Router -> ISR -> Cloud ISR -> Encrypted Mesh
6. **Encryption**: AES-256 -> E2E Crypto -> Quantum Safe
**Files**: `Models/DefenseApplication.swift`, `Views/Components/DefenseApplicationView.swift`

### FEAT-002: Network Topology View
**Status**: Implemented
**Description**: Visual network topology diagram showing Source -> Link -> Sink with defense stack indicator and data flow animation.
**Files**: `Views/Components/DefenseApplicationView.swift` (NetworkTopologyView)

### FEAT-003: Critical Alarm System
**Status**: Implemented
**Description**: Full-screen alarm overlay when risk level becomes HUNTED or MARKED. Includes glitch effects, pulsing warning, and action buttons.
**Files**: `Views/Components/CriticalAlarmView.swift`

### FEAT-004: Malus Intelligence System
**Status**: Implemented
**Description**: Track Malus footprint data from survived attacks. Collect patterns, analyze behavior, and send reports to the team.
**Files**: `Models/DefenseApplication.swift` (MalusIntelligence), `Views/Components/CriticalAlarmView.swift` (MalusIntelPanel)

### FEAT-005: Title Update
**Status**: Implemented
**Description**: Changed header from "PLAGUE" to "PROJECT PLAGUE" for better branding.
**Files**: `Views/Components/StatsHeaderView.swift`

---

## Closed Issues

### ISSUE-000: AudioManager Swift 6 Concurrency Errors
**Status**: ✅ Closed
**Resolution**: Removed ObservableObject, used `@unchecked Sendable`, wrapped haptics in `Task { @MainActor in }`
**Closed**: 2026-01-19

### ENH-001: Offline Progress
**Status**: ✅ Closed
**Resolution**: Implemented offline progress calculation with 8-hour cap and 50% efficiency. Shows modal on app return with ticks simulated and credits earned.
**Closed**: 2026-01-19

### ENH-004: Custom Sound Pack
**Status**: ✅ Fixed
**Priority**: High
**Previous Resolution**: Changed system sounds to cyberpunk-themed electronic tones. Added procedural ambient synth drone generator using AVAudioEngine.
**Previously Closed**: 2026-01-19

**Reopened**: 2026-01-28
**Reason**: Sound quality is terrible on iPhone 16 Pro Max (iOS 26.2.1)

**User Feedback** (iPhone 16 Pro Max, iOS 26.2.1):
1. **Button sounds not playing** - No audio feedback on button taps
2. **Background music is just a buzz** - Procedural ambient synth producing unpleasant buzz instead of music
3. **Update ring bell too loud** - Milestone/alert sounds are jarring and distracting
4. **Missing haptic feedback** - Touch responses should play tones AND vibrate phone

**Solution Implemented** (2026-01-30):

1. **Created AudioSettings model** (`Models/AudioSettings.swift`):
   - Separate toggles for Music, SFX, and Haptics
   - Individual volume sliders for Music and SFX
   - Master volume control
   - Persistent settings via UserDefaults
   - `AudioSettingsManager` singleton for real-time updates

2. **Updated AudioManager** (`Engine/AudioManager.swift`):
   - Added `isHapticsEnabled` flag with getter/setter
   - Haptic feedback now respects settings toggle
   - `HapticManager` methods check `AudioManager.shared.hapticsEnabled` before triggering

3. **Created SettingsView** (`Views/SettingsView.swift`):
   - Full settings UI with cyberpunk theme
   - Music toggle + volume slider (indented when enabled)
   - SFX toggle + volume slider (indented when enabled)
   - Haptic feedback toggle
   - Master volume slider
   - Reset to defaults button
   - Accessible with VoiceOver support

4. **Integrated settings across app**:
   - StatsHeaderView: Replaced speaker toggle with gear icon → opens SettingsView
   - DashboardView: Added `showingSettings` state and settings sheet
   - HomeView: Added settings gear button in header

**User Controls Now Available**:
| Setting | Type | Default |
|---------|------|---------|
| Master Volume | Slider 0-100% | 100% |
| Music Enabled | Toggle | On |
| Music Volume | Slider 0-100% | 30% |
| SFX Enabled | Toggle | On |
| SFX Volume | Slider 0-100% | 70% |
| Haptics Enabled | Toggle | On |

**Files Added**:
- `Models/AudioSettings.swift` - Settings model and manager
- `Views/SettingsView.swift` - Settings UI

**Files Modified**:
- `Engine/AudioManager.swift` - Haptics toggle support
- `Views/Components/StatsHeaderView.swift` - Settings button
- `Views/DashboardView.swift` - Settings sheet
- `Views/HomeView.swift` - Settings button in header

**Note**: Audio asset files (background_music.m4a, sound effects) still need to be added to the bundle. The system is ready to use pre-recorded audio files once they are sourced.

**Closed**: 2026-01-30

---

## 📘 Documentation & Questions

### DOC-001: App Store Deployment Process
**Status**: ✅ Completed
**Type**: Documentation

#### 1. Apple Developer Program Enrollment
- **Cost**: $99/year (individual or organization)
- **URL**: https://developer.apple.com/programs/enroll/
- **Requirements**:
  - Apple ID with two-factor authentication enabled
  - Valid payment method
  - For organizations: D-U-N-S number (free from Dun & Bradstreet)
- **Timeline**: Individual accounts typically approved within 48 hours; organizations may take 1-2 weeks

#### 2. Certificates & Provisioning Profiles
- **In Xcode** (recommended automatic management):
  1. Open project → Signing & Capabilities tab
  2. Check "Automatically manage signing"
  3. Select your Team from the dropdown
  4. Xcode creates Development and Distribution certificates automatically
- **Manual Setup** (if needed):
  1. Go to https://developer.apple.com/account/resources/certificates
  2. Create "Apple Distribution" certificate using Keychain Access CSR
  3. Create App ID matching your bundle identifier
  4. Create "App Store" provisioning profile linking certificate + App ID

#### 3. App Store Connect Setup
- **URL**: https://appstoreconnect.apple.com
- **Create New App**:
  1. My Apps → "+" → New App
  2. Select platform (iOS)
  3. Enter app name, primary language, bundle ID, SKU
- **Required Metadata**:
  | Field | Requirement |
  |-------|-------------|
  | App Name | 30 characters max |
  | Subtitle | 30 characters max |
  | Description | 4000 characters max |
  | Keywords | 100 characters total, comma-separated |
  | Support URL | Required, must be active |
  | Privacy Policy URL | Required for all apps |
  | Category | Primary + optional secondary |
  | Age Rating | Complete questionnaire |

#### 4. Required Assets
| Asset | Specification |
|-------|---------------|
| App Icon | 1024×1024 PNG, no alpha |
| iPhone Screenshots | 6.7" (1290×2796) and 5.5" (1242×2208) |
| iPad Screenshots | 12.9" (2048×2732) - required if iPad supported |
| App Preview Video | Optional, 15-30 seconds, up to 3 per locale |

#### 5. Build & Upload
```bash
# Archive in Xcode
Product → Archive

# Or via command line
xcodebuild -scheme "Project Plague" -archivePath build/App.xcarchive archive
xcodebuild -exportArchive -archivePath build/App.xcarchive -exportPath build/ -exportOptionsPlist ExportOptions.plist
```
- After archive: Window → Organizer → Distribute App → App Store Connect
- Alternatively use `xcrun altool` or Transporter app

#### 6. TestFlight Beta Testing
1. Upload build to App Store Connect
2. Build processes (5-30 minutes for automated review)
3. **Internal Testing**: Up to 100 testers, no review needed
4. **External Testing**: Up to 10,000 testers, requires Beta App Review
5. Testers install via TestFlight app using invite link or email

#### 7. App Review Submission
- Click "Add for Review" after completing all metadata
- **Review Timeline**: Typically 24-48 hours (90% within 24 hours)
- **Expedited Review**: Request at https://developer.apple.com/contact/app-store (emergency only)

#### 8. Common Rejection Reasons
| Reason | Solution |
|--------|----------|
| **Guideline 2.1 - Crashes/Bugs** | Test thoroughly on all supported devices |
| **Guideline 2.3 - Incomplete Info** | Provide demo account if login required |
| **Guideline 3.1.1 - In-App Purchase** | Use Apple IAP for digital goods, not Stripe/PayPal |
| **Guideline 4.2 - Minimum Functionality** | App must provide value beyond a website |
| **Guideline 5.1.1 - Data Collection** | Disclose all data collection in privacy policy |
| **Guideline 5.1.2 - Data Use** | Only collect data necessary for core functionality |
| **Metadata Rejected** | Screenshots must show actual app, no iPhone frames |

#### 9. Post-Launch Checklist
- [ ] Monitor App Store Connect for crash reports
- [ ] Respond to user reviews (increases engagement)
- [ ] Set up App Analytics for download/usage metrics
- [ ] Plan update cadence (fix bugs, add features)
- [ ] Consider App Store Optimization (ASO) for keywords

---

### DOC-002: Claude Code & Claude Desktop - Xcode/Simulator Permissions
**Status**: ✅ Completed
**Type**: Documentation

#### Overview
This guide covers setting up Xcode automation for both **Claude Code** (CLI tool) and **Claude Desktop** (macOS app). Each has different permission models and capabilities.

| Feature | Claude Code (CLI) | Claude Desktop (App) |
|---------|-------------------|---------------------|
| Runs in | Terminal (bash/zsh) | Native macOS app |
| Command execution | Direct shell access | MCP servers or Computer Use |
| File access | Inherits terminal permissions | App sandbox + MCP |
| GUI control | CLI only | Computer Use can click |

---

## Part A: Claude Code (CLI)

#### A1. Install Xcode Command Line Tools
```bash
# Install command line tools
xcode-select --install

# Verify installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# If pointing to wrong location, reset:
sudo xcode-select --reset
```

#### A2. Accept Xcode License
```bash
# Accept license (required before first use)
sudo xcodebuild -license accept
```

#### A3. Build Project via Command Line
```bash
# List available schemes
xcodebuild -list -project "Project Plague.xcodeproj"

# Build for simulator
xcodebuild -project "Project Plague.xcodeproj" \
  -scheme "Project Plague" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  build

# Build and run tests
xcodebuild test -project "Project Plague.xcodeproj" \
  -scheme "Project Plague" \
  -destination "platform=iOS Simulator,name=iPhone 15"
```

#### A4. Launch iOS Simulator
```bash
# List available simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 15"

# Open Simulator app (shows booted device)
open -a Simulator

# Install app on simulator
xcrun simctl install booted /path/to/App.app

# Launch app on simulator
xcrun simctl launch booted com.yourcompany.ProjectPlague
```

#### A5. macOS Security Permissions for Terminal
Grant these permissions in **System Settings → Privacy & Security**:

| Permission | Required For |
|------------|--------------|
| **Full Disk Access** | Accessing project files in protected directories |
| **Developer Tools** | Terminal/iTerm needs this for debugging |
| **Automation** | Controlling Xcode and Simulator programmatically |

To add Terminal to Developer Tools:
1. System Settings → Privacy & Security → Developer Tools
2. Click "+" and add Terminal.app (or iTerm)

#### A6. Full Automation Script
```bash
# Full build + run workflow
PROJECT_DIR="/Volumes/DEV/Code/dev/Games/ProjectPlague/ProjectPlague/Project Plague"
SCHEME="Project Plague"
SIMULATOR="iPhone 15"

# Build
xcodebuild -project "$PROJECT_DIR/Project Plague.xcodeproj" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -derivedDataPath build/ \
  build

# Find the built app
APP_PATH=$(find build/ -name "*.app" -type d | head -1)

# Boot simulator and install
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
xcrun simctl install booted "$APP_PATH"
xcrun simctl launch booted com.yourcompany.ProjectPlague
```

#### A7. Claude Code Specifics
- Operates within user's shell environment
- Ensure working directory contains `.xcodeproj`
- Use absolute paths for reliability
- Xcode must be pre-installed and configured
- Cannot interact with GUI - all operations must be CLI-based

---

## Part B: Claude Desktop (macOS App)

#### B1. MCP Server Setup for Xcode Commands
Claude Desktop uses **Model Context Protocol (MCP)** servers to execute local commands. Create an MCP server to expose Xcode operations.

**Step 1: Install MCP CLI tools**
```bash
# Install the MCP server framework
npm install -g @anthropic-ai/mcp
```

**Step 2: Create Xcode MCP Server**
Create file `~/.config/claude/mcp-servers/xcode-server.json`:
```json
{
  "name": "xcode-tools",
  "version": "1.0.0",
  "description": "Xcode build and simulator tools",
  "tools": [
    {
      "name": "xcode_build",
      "description": "Build an Xcode project for simulator",
      "parameters": {
        "project_path": { "type": "string", "description": "Path to .xcodeproj" },
        "scheme": { "type": "string", "description": "Build scheme name" }
      }
    },
    {
      "name": "simulator_launch",
      "description": "Boot and launch app in iOS Simulator",
      "parameters": {
        "device": { "type": "string", "description": "Simulator device name" },
        "app_bundle_id": { "type": "string", "description": "App bundle identifier" }
      }
    }
  ]
}
```

**Step 3: Configure Claude Desktop**
Add to Claude Desktop settings (`~/Library/Application Support/Claude/config.json`):
```json
{
  "mcpServers": {
    "xcode-tools": {
      "command": "node",
      "args": ["/path/to/your/xcode-mcp-server.js"]
    }
  }
}
```

#### B2. macOS Permissions for Claude Desktop
Grant permissions in **System Settings → Privacy & Security**:

| Permission | Path | Purpose |
|------------|------|---------|
| **Accessibility** | Privacy → Accessibility → Claude | Required for Computer Use |
| **Screen Recording** | Privacy → Screen Recording → Claude | See screen for Computer Use |
| **Automation** | Privacy → Automation → Claude | Control other apps |
| **Full Disk Access** | Privacy → Full Disk Access → Claude | Access project files |
| **Files and Folders** | Privacy → Files and Folders → Claude | Developer directories |

**To grant permissions:**
1. Open System Settings → Privacy & Security
2. Select each category above
3. Click "+" or toggle Claude.app ON
4. May require app restart

#### B3. Computer Use for GUI Automation
If using Claude's Computer Use feature to control Xcode GUI:

1. **Enable Computer Use** in Claude Desktop settings
2. **Grant Accessibility permission** (required for mouse/keyboard control)
3. **Grant Screen Recording** (required to see what's on screen)

Claude can then:
- Click Xcode menu items (Product → Build, Product → Run)
- Navigate project navigator
- Click simulator controls
- Read build errors from Xcode UI

#### B4. AppleScript Integration (Alternative)
Create AppleScript shortcuts Claude Desktop can trigger via MCP:

```applescript
-- build_and_run.scpt
tell application "Xcode"
    activate
    tell application "System Events"
        keystroke "r" using command down -- Cmd+R to Run
    end tell
end tell
```

Save to `~/Scripts/build_and_run.scpt` and expose via MCP server.

#### B5. Shortcuts App Integration
Create a macOS Shortcut for Xcode operations:

1. Open **Shortcuts** app
2. Create new shortcut "Build Project Plague"
3. Add action: **Run Shell Script**
4. Enter: `xcodebuild -project "/path/to/Project.xcodeproj" -scheme "Project Plague" build`
5. Save shortcut

Claude Desktop can invoke shortcuts via:
```bash
shortcuts run "Build Project Plague"
```

---

## Part C: Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `xcodebuild: error: unable to find utility` | Run `xcode-select --install` |
| `Signing requires a development team` | Add `-allowProvisioningUpdates` or set team in project |
| `Simulator not found` | Run `xcrun simctl list` to find exact device name |
| `Permission denied` | Add app to Full Disk Access |
| `Build fails with provisioning error` | Use `-destination generic/platform=iOS Simulator` |
| Claude Desktop can't see screen | Grant Screen Recording permission |
| Claude Desktop can't click | Grant Accessibility permission |
| MCP server not connecting | Check config.json path and restart Claude Desktop |

---

## Part D: CI/CD & Headless Builds

For automated pipelines (GitHub Actions, Xcode Cloud, etc.):
```bash
# Create and boot simulator headlessly
xcrun simctl create "CI_iPhone" "iPhone 15"
xcrun simctl boot "CI_iPhone"

# Build with no code signing (simulator only)
xcodebuild -project "Project.xcodeproj" \
  -scheme "Scheme" \
  -destination "platform=iOS Simulator,name=CI_iPhone" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  build
```

---

## Quick Reference

| Task | Claude Code Command | Claude Desktop Method |
|------|--------------------|-----------------------|
| Build project | `xcodebuild -scheme X build` | MCP tool or Computer Use |
| Run tests | `xcodebuild test -scheme X` | MCP tool |
| Boot simulator | `xcrun simctl boot "iPhone 15"` | MCP tool |
| Install app | `xcrun simctl install booted App.app` | MCP tool |
| Launch app | `xcrun simctl launch booted bundle.id` | MCP tool or Computer Use |
| Open Xcode | `open -a Xcode project.xcodeproj` | Computer Use or AppleScript |

---

## Reporting New Issues

When adding issues, include:
1. **Status**: Open / In Progress / Closed
2. **Severity**: Critical / Major / Minor
3. **Description**: What's happening
4. **Impact**: How it affects gameplay/UX
5. **Solution**: Proposed fix (if known)
6. **Files**: Affected source files
