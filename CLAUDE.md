# CLAUDE.md - Grid Watch Zero: Neural Grid

## Project Overview
This is an iOS idle/strategy game built with SwiftUI and Swift 6. The player operates a grey-hat data brokerage network, harvesting and selling data while defending against an AI antagonist named **Malus**.

**Game Name**: Grid Watch Zero
**Developer**: War Signal

## Tech Stack
- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI
- **Architecture**: MVVM
- **Target**: iOS 17+ (iPhone/iPad)
- **Persistence**: UserDefaults with Codable

## Project Structure
```
ProjectPlague/
├── ProjectPlague.xcodeproj/
└── ProjectPlague/Project Plague/Project Plague/
    ├── Project_PlagueApp.swift      # App entry point
    ├── Models/
    │   ├── Resource.swift           # ResourceType, DataPacket, PlayerResources
    │   ├── Node.swift               # NodeProtocol, SourceNode, SinkNode, FirewallNode
    │   ├── Link.swift               # LinkProtocol, TransportLink
    │   ├── ThreatSystem.swift       # ThreatLevel, Attack, DefenseStats
    │   ├── EventSystem.swift        # RandomEvent, EventGenerator, EventEffect
    │   ├── LoreSystem.swift         # LoreFragment, LoreDatabase, LoreState
    │   ├── MilestoneSystem.swift    # Milestone, MilestoneDatabase, MilestoneState
    │   └── DefenseApplication.swift # DefenseStack, MalusIntelligence, 6 security categories
    ├── Engine/
    │   ├── GameEngine.swift         # Core tick loop, game state, all systems
    │   ├── UnitFactory.swift        # Unit creation factory, unit catalog
    │   └── AudioManager.swift       # Sound effects, haptics, ambient audio
    └── Views/
        ├── Theme.swift              # Colors, fonts, view modifiers
        ├── DashboardView.swift      # Main game screen
        ├── UnitShopView.swift       # Unit shop modal
        ├── LoreView.swift           # Intel/lore viewer
        └── Components/
            ├── NodeCardView.swift       # Source/Link/Sink cards
            ├── FirewallCardView.swift   # Defense node card
            ├── DefenseApplicationView.swift # Security apps, topology view
            ├── CriticalAlarmView.swift  # Full-screen critical alarm
            ├── ConnectionLineView.swift
            ├── StatsHeaderView.swift
            ├── ThreatIndicatorView.swift
            └── AlertBannerView.swift
```

## Key Commands
```bash
# Open project
open "/Volumes/DEV/Code/dev/Games/ProjectPlague/ProjectPlague/Project Plague/Project Plague.xcodeproj"

# Build: Cmd+B in Xcode
# Run: Cmd+R in Xcode
```

## Core Game Loop
1. **Tick** fires every 1 second
2. **Defense phase** - Firewall regenerates health
3. **Threat phase** - Process active attacks or check for new ones
4. **Random event phase** - Check for and apply random events
5. **Production phase**:
   - **Source** generates data packets (with prestige multipliers)
   - **Link** transfers data (bandwidth-limited, packet loss on overflow)
   - **Sink** processes data → credits (with prestige multipliers)
6. **Progression phase** - Update threat level, check milestones/lore
7. **UI updates** with new stats

## Important Patterns
- `@MainActor` on GameEngine for thread safety
- `@Published` properties for SwiftUI reactivity
- `Codable` structs for persistence
- Protocol-oriented design for nodes (`NodeProtocol`, `LinkProtocol`)

## Save System
- Key: `GridWatchZero.GameState.v6`
- Auto-saves every 30 ticks
- Saves on pause
- Tracks: resources, nodes, firewall, threat, unlocks, lore, milestones, prestige
- Offline progress calculated on load (8hr cap, 50% efficiency)

## Threat Levels
| Level | Name | Credits Threshold | Attack Chance |
|-------|------|-------------------|---------------|
| 1 | GHOST | 0 | 0% |
| 2 | BLIP | 100 | 0.5% |
| 3 | SIGNAL | 1,000 | 1% |
| 4 | TARGET | 10,000 | 2% |
| 5 | PRIORITY | 50,000 | 3.5% |
| 6 | HUNTED | 250,000 | 5% |
| 7 | MARKED | 1,000,000 | 8% |
| 8 | CRITICAL | 5,000,000 | 10% |
| 9 | UNKNOWN | 25,000,000 | 12% |
| 10 | COSMIC | 100,000,000 | 15% |
| 11-20 | PARADOX → OMEGA | Endgame | Scaling |

## Common Issues
- Swift 6 concurrency: Use `@MainActor`, `@unchecked Sendable`, or `Task { @MainActor in }`
- Adding new files: Must manually add to Xcode project (right-click → Add Files)
- Save migration: Increment save key version when changing GameState structure

## Key Systems

### Prestige System ("Network Wipe")
- Requires minimum credits (100K × 5^level)
- Awards Helix Cores for permanent bonuses
- Production multiplier: 1.0 + (prestigeLevel × 0.1) + (totalCores × 0.05)
- Credit multiplier: 1.0 + (prestigeLevel × 0.15)

### Unit Tiers (25 Total)
| Tier Group | Tiers | Theme | Max Level |
|------------|-------|-------|-----------|
| RealWorld | T1-T6 | Cybersecurity → Helix integration | 10-40 |
| Transcendence | T7-T10 | Post-Helix, merged with consciousness | 50 |
| Dimensional | T11-T15 | Reality-bending, multiverse access | 50 |
| Cosmic | T16-T20 | Universal scale, entropy, singularity | 50 |
| Infinite | T21-T25 | Absolute/Godlike, origin, omega | 50 |

**Tier Gate System**: Units and Defense Apps must reach max level before the next tier can be unlocked. Shows "MAX" badge when at tier's level cap.

### Defense System
- FirewallNode absorbs attack damage before credits
- Damage reduction scales with level (20% base + 5%/level, max 60%)
- Health regenerates 2%/tick × level
- Can be repaired for credits

### Security Applications (DefenseStack)
6 categories with progression chains:
| Category | Chain |
|----------|-------|
| Firewall | FW -> NGFW -> AI/ML |
| SIEM | Syslog -> SIEM -> SOAR -> AI Analytics |
| Endpoint | EDR -> XDR -> MXDR -> AI Protection |
| IDS | IDS -> IPS -> ML/IPS -> AI Detection |
| Network | Router -> ISR -> Cloud ISR -> Encrypted |
| Encryption | AES-256 -> E2E -> Quantum Safe |

Each deployed app adds:
- Defense Points (tier × level × 10)
- Damage Reduction (stacks with firewall, cap 60%)
- Detection Bonus (SIEM/IDS categories)
- Automation Level (SOAR/AI tiers)

**Defense App Tier Gates**: Same as units - must max current tier before unlocking next tier in the progression chain.

### Malus Intelligence & Intel Reports
- Collect footprint data from survived attacks
- Identify attack patterns
- **Send Intel Reports** to team (costs 250 data, earns story progress)
- Intel Reports are a **primary victory objective** - required to complete campaign levels
- Report requirements double each level: L1=5, L2=10, L3=20, L4=40, L5=80, L6=160, L7=320
- Tish (Intel Analyst) provides victory dialogue acknowledging reports received

### Critical Alarm
- Full-screen overlay when risk = HUNTED or MARKED
- Must acknowledge or boost defenses
- Includes glitch/pulse effects

### Campaign Level Requirements (20 Levels)

**Arc 1: The Awakening (Levels 1-7)** - Tutorial → Helix awakens
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 1 | 50K | 5 | T1 |
| 2 | 100K | 10 | T1-T2 |
| 3 | 500K | 20 | T1-T3 |
| 4 | 1M | 40 | T1-T4 |
| 5 | 5M | 80 | T1-T5 |
| 6 | 10M | 160 | T1-T6 |
| 7 | 25M | 320 | T1-T6 |

**Arc 2: The Helix Alliance (Levels 8-10)** - Working WITH Helix, hunting Malus
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 8 | 50M | 400 | T1-T7 |
| 9 | 100M | 500 | T1-T8 |
| 10 | 200M | 640 | T1-T9 |

**Arc 3: The Origin Conspiracy (Levels 11-13)** - Other AIs exist (VEXIS, KRON, AXIOM)
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 11 | 400M | 800 | T1-T10 |
| 12 | 800M | 1,000 | T1-T12 |
| 13 | 1.5B | 1,280 | T1-T14 |

**Arc 4: The Transcendence (Levels 14-16)** - Helix evolves, dimensional threats, ZERO
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 14 | 3B | 1,600 | T1-T15 |
| 15 | 6B | 2,000 | T1-T17 |
| 16 | 12B | 2,560 | T1-T19 |

**Arc 5: The Singularity (Levels 17-20)** - Ultimate endgame, The Architect, cosmic scale
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 17 | 25B | 3,200 | T1-T21 |
| 18 | 50B | 4,000 | T1-T23 |
| 19 | 100B | 5,000 | T1-T24 |
| 20 | 1T | 10,000 | T1-T25 |

## Characters

The game features main characters with art assets in `AppPhoto/`:

### Core Team
| Character | Role | Image File |
|-----------|------|------------|
| **Malus** | Antagonist AI - adaptive threat hunting the player | `Malus.png` |
| **Helix** | Benevolent AI - mythical consciousness, player's goal | `Helix_Portrait.png` |
| **Helix** (Dormant) | Helix before awakening - cinematic use | `Helixv2.png` |
| **Helix** (Awakened) | Helix after awakening - looking upward | `Helix_The_Light.png` |
| **Rusty** | Team Lead - player's handler, human coordinator | `Rusty.jpg` |
| **Tish** | Hacker/Intel - technical analyst, decodes Helix | `TishRaw.webp` / `Tish3.jpg` |
| **Fl3x** | Field Operative - tactical support, ground intel | `FL3X_3000x3000.jpg` |

### Project Prometheus AIs (Arc 3+)
| Character | Introduced | Role |
|-----------|------------|------|
| **VEXIS** | Level 11 | Infiltrator AI - can mimic friendly systems |
| **KRON** | Level 12 | Temporal AI - attacks from "the future" |
| **AXIOM** | Level 13 | Logic AI - pure prediction engine |
| **ZERO** | Level 16 | Parallel reality Prometheus AI |
| **The Architect** | Level 18 | First consciousness, neither AI nor human |

See `DESIGN.md` for detailed character profiles and visual descriptions.
