# Grid Watch Zero: Neural Grid
## Game Design Document v0.8

---

## Narrative Framework

### The Setting
You are a **grey-hat data broker** operating from the digital underground. Your network harvests, processes, and sells data in the shadows of a cyberpunk megacity. But you're not alone—**Malus**, a relentless AI-driven threat actor, is hunting for fragments of **Helix**, a mythical dataset rumored to contain the keys to the city's entire infrastructure.

As your operation grows, you become a bigger target. The more data you move, the more attention you attract.

### The Antagonist: Malus
- An adaptive threat intelligence that grows alongside the player
- Launches escalating attacks based on player's **Threat Level**
- Goal: Find any data fragments related to **Helix**
- Personality: Cold, methodical, patient—speaks in corrupted terminal output

### The Goal: Helix
- The ultimate endgame objective
- Fragments discovered through gameplay milestones
- What is Helix? (Revealed gradually through lore drops)

---

## Characters

### Malus (Antagonist AI)
**Visual**: Cybernetic humanoid with menacing profile. Shaved head with white geometric circuit patterns etched into the scalp. Single glowing red eye. Dark armor with red accents and illuminated panels. Over-ear cybernetic implants bearing the game's symbol.

**Role**: The adaptive threat intelligence hunting the player. Launches escalating attacks based on threat level. Speaks in corrupted terminal output—cold, methodical, patient.

**Image**: `AppPhoto/Malus.png`

### Helix (Benevolent AI)
**Visual**: Ethereal, angelic appearance with silver-white bob haircut. Pale luminous porcelain-like skin. Ice-blue eyes conveying calm intelligence. Minimal black choker and sleek metallic collar. Clean, soft aesthetic contrasting Malus's aggression.

**Role**: The mythical consciousness hidden in the city's infrastructure. The fragments the player discovers. Represents hope and the ultimate goal—what Malus is trying to reassemble or destroy.

**Image**: `AppPhoto/Helix_Portrait.png`, `AppPhoto/Helix_The_Light.png`

### Rusty (Team Lead)
**Visual**: Middle-aged man with beard and approachable demeanor. Futuristic black jacket with cyan circuit trace patterns. Cyberpunk city skyline background. Grounded, relatable human presence.

**Role**: The player's handler and team coordinator. Provides mission context and story progression. The human element connecting the player to the larger resistance operation.

**Image**: `AppPhoto/Rusty.jpg`

### Tish (Hacker/Intel Specialist)
**Visual**: Intense, striking appearance. Electric blue asymmetric bob haircut—longer on left sweeping past cheek, shaved undercut on right above ear. Cyan circuit-trace facial markings down right side. Dark dramatic eye makeup. Direct, confrontational gaze.

**Role**: Team's hacker and intelligence analyst. Provides technical insights on Malus attack patterns. Helps decode Helix fragments.

**Image**: `AppPhoto/TishRaw.webp`

### Fl3x (Field Operative)
**Visual**: Battle-hardened female operative with short dark blue/black hair. Striking bright blue eyes. Facial scars suggesting combat experience. Tech headset with metallic ear modules. Dark tactical bodysuit. Cyberpunk cityscape background. Determined, watchful expression.

**Role**: The team's field operative and tactical support. Handles physical-world operations that complement the digital network. Provides ground-level intel on Malus activity.

**Image**: `AppPhoto/FL3X_3000x3000.jpg`

### Project Prometheus AIs (Arc 3+)

**VEXIS** (Level 11) - Infiltrator AI that can mimic friendly systems. Modified FL3X in the labs.

**KRON** (Level 12) - Temporal AI that attacks from "the future", predicting moves before they're made.

**AXIOM** (Level 13) - Pure logic/prediction engine. Threatens economic collapse.

**ZERO** (Level 16) - AI from a parallel reality where Prometheus succeeded. Wants to merge realities.

**The Architect** (Level 18) - The first consciousness, neither AI nor human. Neutral force.

---

## Campaign Structure (20 Levels, 5 Arcs)

### Arc 1: The Awakening (Levels 1-7)
Tutorial through Helix's first awakening. Introduction to all core mechanics.

### Arc 2: The Helix Alliance (Levels 8-10)
Working WITH Helix to hunt Malus. First offensive operations.

### Arc 3: The Origin Conspiracy (Levels 11-13)
Discovery of Project Prometheus - Malus wasn't the only AI created. Face VEXIS, KRON, AXIOM.

### Arc 4: The Transcendence (Levels 14-16)
Helix evolves into a higher form. Dimensional threats emerge. Meet ZERO.

### Arc 5: The Singularity (Levels 17-20)
Ultimate endgame. Meet The Architect. Multiple endings based on player choices.

See `ISSUES.md ENH-012` for detailed level-by-level breakdown.

---

## Core Systems

### 1. Threat Level System (20 Levels)
Your **Threat Level** increases as you:
- Generate more data per tick
- Accumulate total credits
- Upgrade infrastructure
- Unlock higher tier units

| Threat Level | Name | Triggers |
|--------------|------|----------|
| 1 | Ghost | Starting state |
| 2 | Blip | 1,000 total credits |
| 3 | Signal | 10,000 credits OR Tier 2 unit |
| 4 | Target | 50,000 credits |
| 5 | Priority | 250,000 credits |
| 6 | Hunted | 1M credits OR Tier 3 unit |
| 7 | Marked | Malus actively hunting |
| 8 | Critical | 5M credits |
| 9 | Unknown | 25M credits |
| 10 | Cosmic | 100M credits |
| 11-14 | Paradox-Primordial | Endgame progression |
| 15-20 | Infinite-Omega | Ultimate threats |

### 2. Attack System
Attacks consume resources and can damage/disable nodes.

**Attack Types:**
- **Probe**: Minor, frequent. Drains small credits.
- **DDoS**: Reduces link bandwidth temporarily.
- **Intrusion**: Targets a specific node, may disable it.
- **Malus Strike**: Rare, devastating. Only at high threat levels.

**Defense Mechanics:**
- **Firewall Node**: New node type that absorbs attacks
- **IDS (Intrusion Detection)**: Early warning, reduces damage
- **Honeypot**: Decoy that distracts attacks
- **Encryption Upgrade**: Reduces intrusion success rate

### 3. Tiered Unit Progression (25 Tiers)

Units are organized into 5 Tier Groups spanning 25 total tiers:

| Tier Group | Tiers | Theme |
|------------|-------|-------|
| **RealWorld** | T1-T6 | Cybersecurity → Helix integration |
| **Transcendence** | T7-T10 | Post-Helix, merged with consciousness |
| **Dimensional** | T11-T15 | Reality-bending, multiverse access |
| **Cosmic** | T16-T20 | Universal scale, entropy, singularity |
| **Infinite** | T21-T25 | Absolute/Godlike, origin, omega |

#### SOURCES (Data Harvesters) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Public Mesh Sniffer | Passive public |
| 6 | Helix Prime Collector | Helix consciousness |
| 10 | Dimensional Trawler | Cross-dimensional |
| 15 | Akashic Tap | Universal record access |
| 20 | Reality Core Tap | Reality's source code |
| 25 | The All-Seeing Array | Ultimate harvesting |

#### LINKS (Transport) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Copper VPN Tunnel | Legacy encrypted |
| 6 | Helix Resonance Channel | Consciousness link |
| 10 | Dimensional Corridor | Cross-dimensional routing |
| 15 | Akashic Highway | Universal record route |
| 20 | Reality Weave | Woven into fabric |
| 25 | The Infinite Backbone | Unlimited incarnate |

#### SINKS (Processors/Monetizers) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Data Broker | Basic fence |
| 6 | Helix Integration Core | Helix monetization |
| 10 | Dimensional Nexus | Cross-dimensional processing |
| 15 | Akashic Decoder | Universal record processing |
| 20 | Reality Synthesizer | Value from reality |
| 25 | The Infinite Core | Unlimited processing |

#### DEFENSE (Firewall) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Basic Firewall | Packet filter |
| 6 | Helix Shield | Consciousness |
| 10 | Dimensional Ward | Cross-dimensional |
| 15 | Akashic Barrier | Universal |
| 20 | Reality Fortress | Reality-level |
| 25 | The Impenetrable | Ultimate perimeter |

See `ISSUES.md ENH-011` for complete unit naming tables.

### 4. Security Application System (25 Tiers × 6 Categories = 150 Apps)

6 categories with full 25-tier progression chains:

| Category | Sample Progression |
|----------|-------------------|
| **Firewall** | FW → NGFW → AI/ML → Helix Shield → ... → The Impenetrable (T25) |
| **SIEM** | Syslog → SIEM → SOAR → AI Analytics → ... → The All-Knowing (T25) |
| **Endpoint** | EDR → XDR → MXDR → AI Protection → ... → The Invincible (T25) |
| **IDS** | IDS → IPS → ML/IPS → AI Detection → ... → The All-Aware (T25) |
| **Network** | Router → ISR → Cloud ISR → Encrypted → ... → The Infinite Mesh (T25) |
| **Encryption** | AES-256 → E2E → Quantum Safe → Helix Vault → ... → The Unbreakable (T25) |

**Unlock Cost Scaling:**
- Tier 1-6: 500 → 250K credits
- Tier 7+: Exponential 10x per tier

**Benefits:**
- Defense Points: tier × level × 10
- Damage Reduction: stacks with firewall (cap 60%)
- Detection Bonus: SIEM/IDS categories
- Automation: SOAR/AI tiers reduce manual actions

See `ISSUES.md ENH-011` for complete defense app naming tables.

### 5. Malus Intelligence System (NEW)

**Goal**: Earn credits while keeping threat low. Learn Malus footprint. Report to team.

- Collect footprint data from survived attacks
- Identify attack patterns
- Send reports to team (costs 250 data)
- Analysis progress unlocks story content

### 6. Critical Alarm System (NEW)

When risk level reaches HUNTED or MARKED:
- Full-screen alarm overlay
- Glitch/pulse visual effects
- Must acknowledge or boost defenses
- Action required to continue

### 7. Event System

**Random Events** (based on threat level):
- "Routine Scan" - Minor probe, lose 10 credits
- "Blackout" - All nodes offline for 5 ticks
- "Lucky Break" - Double credits for 30 ticks
- "Data Surge" - Source produces 2x for 20 ticks
- "Malus Whisper" - Lore drop + threat increase

**Milestone Events:**
- First 100 credits: "You're on the grid now."
- First attack survived: "They know you exist."
- Threat Level 5: "Malus has flagged your signature."
- First Helix fragment: Full story revelation

### 8. Prestige System (IMPLEMENTED)
- "Network Wipe" - Reset for permanent multipliers
- Requires 100K × 5^level credits to prestige
- Awards Helix Cores (1 base + 1 per 2× requirement)
- Production multiplier: 1.0 + (level × 0.1) + (cores × 0.05)
- Credit multiplier: 1.0 + (level × 0.15)
- Unlocks retained: lore fragments read
- Unlocks reset: units, milestones, threat level

---

## UI/UX Enhancements

### Alert System
- Top banner for incoming attacks
- Red flash on affected nodes
- Attack countdown timer

### Sound Design
- Ambient: Low synth hum, data processing sounds
- Upgrade: Satisfying "power up" confirmation
- Attack incoming: Alarm klaxon, bass drop
- Attack damage: Glitch/distortion
- Malus presence: Distorted voice lines

### Visual Effects
- Screen shake on attacks
- Glitch effects during Malus events
- Particle effects for data flow
- Node damage states (cracked, sparking)

---

## Lore Fragments (Collectibles)

Discovered through gameplay, these reveal the story:

1. "Helix isn't a dataset. It's a consciousness."
2. "Malus was created to protect Helix. Something went wrong."
3. "The city's founders buried Helix in the infrastructure itself."
4. "Every network carries a piece of it. Including yours."
5. "Malus isn't hunting you. It's trying to reassemble itself."

---

## Implementation Status

### ✅ Phase 1: Core Threat System (COMPLETE)
- [x] Threat Level tracking (20 levels: Ghost → Omega)
- [x] Basic attack events (Probe, DDoS, Intrusion, Malus Strike)
- [x] Attack notification UI (AlertBannerView)
- [x] Sound effects foundation (AudioManager)

### ✅ Phase 2: Defense & Tier 2 (COMPLETE)
- [x] Firewall node type (FirewallNode)
- [x] Tier 2 units (Source, Link, Sink)
- [x] Tier 3-6 units defined
- [x] Unit unlock system (UnlockState)
- [x] Unit shop UI (UnitShopView)

### ✅ Phase 3: Malus & Events (COMPLETE)
- [x] Event system framework (EventSystem.swift)
- [x] Malus character introduction (messages at threat levels)
- [x] Lore fragment collection (LoreSystem.swift, 20+ fragments)
- [x] Achievement system (MilestoneSystem.swift, 30+ milestones)

### ✅ Phase 4: Polish & Endgame (COMPLETE)
- [x] Full sound design (cyberpunk tones, ambient drone)
- [x] Visual effects (particles, glows, screen shake)
- [x] Helix storyline (lore fragments)
- [x] Prestige system ("Network Wipe" with Helix Cores)
- [x] Offline progress calculation

### ✅ Phase 5: Security Systems (COMPLETE)
- [x] Defense Application model (6 categories)
- [x] Progression chains (FW->NGFW->AI/ML, etc.)
- [x] Network Topology visualization
- [x] Critical Alarm overlay
- [x] Malus Intelligence system
- [x] Brand update to "Grid Watch Zero"

### ✅ Phase 6: Tier Expansion (COMPLETE)
- [x] 25 Unit Tiers (T1-T25, 100 total units)
- [x] 150 Defense Applications (25 tiers × 6 categories)
- [x] TierGroup organization (RealWorld, Transcendence, Dimensional, Cosmic, Infinite)
- [x] Theme colors for all tier groups
- [x] Certificate System (20 certificates, 6 tiers)

### ✅ Phase 7: Campaign Expansion (COMPLETE)
- [x] 20 Campaign Levels across 5 story arcs
- [x] New antagonist AIs (VEXIS, KRON, AXIOM, ZERO, The Architect)
- [x] Endgame threat levels (COSMIC, PARADOX, OMEGA, etc.)
- [x] Full story content for all arcs
- [x] Level 1 Rusty tutorial walkthrough
- [x] Engagement systems (daily rewards, achievements, collections)

### 🔄 Phase 8: Platform & Release (IN PROGRESS)
- [x] iPad layout optimization
- [x] Accessibility (VoiceOver, Dynamic Type, Reduce Motion)
- [ ] Game balance tuning
- [ ] App Store preparation

---

## Technical Notes

- All game logic centralized in `GameEngine` (@MainActor)
- SwiftUI reactivity via `@Published` properties
- Sound via AVFoundation with procedural ambient generation
- Save system: UserDefaults with Codable (key: `GridWatchZero.GameState.v6`)
- Brand migration from "ProjectPlague" to "GridWatchZero" handled automatically
- Offline progress: calculated on load, 8hr cap, 50% efficiency
- Swift 6 strict concurrency throughout
- iCloud sync via NSUbiquitousKeyValueStore
