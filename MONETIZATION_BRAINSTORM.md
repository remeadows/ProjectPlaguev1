# MONETIZATION_BRAINSTORM.md - Grid Watch Zero

## Session Date: 2026-02-01

---

## Overview

This document captures brainstorming discussion around monetization strategies for Grid Watch Zero. The game is currently configured as **Free** on the App Store with no monetization.

---

## Question 1: How to Insert Features That Require Payment

### iOS Payment Options

**1. In-App Purchases (IAP)**
Apple's StoreKit framework provides three IAP types:

| Type | Description | Use Case |
|------|-------------|----------|
| **Consumable** | One-time use, can repurchase | Credit packs, instant boosts |
| **Non-Consumable** | Permanent unlock, one-time purchase | Remove ads, unlock full game, cosmetics |
| **Subscription** | Recurring payment | VIP status, daily rewards multiplier |

**Implementation Requirements:**
- Add StoreKit framework to project
- Create `StoreManager.swift` to handle purchases
- Configure products in App Store Connect
- Implement receipt validation (local or server-side)
- Handle restore purchases (required by Apple)
- Test with Sandbox environment

**Apple's Cut:** 30% (15% for Small Business Program if <$1M/year)

**2. Ad Networks**
Popular options for iOS games:

| Network | Pros | Cons |
|---------|------|------|
| **AdMob (Google)** | Largest network, reliable fill rates | Google dependency |
| **Unity Ads** | Great for games, rewarded video focus | Requires Unity Ads SDK |
| **AppLovin** | High eCPMs, good mediation | Complex setup |
| **ironSource** | Strong rewarded video | Can be intrusive |

**Ad Types:**
- **Banner Ads**: Persistent, low revenue, can hurt UX
- **Interstitial**: Full-screen between levels, moderate revenue
- **Rewarded Video**: User-initiated for rewards, best UX, highest eCPM

---

## Question 2: Ads vs. Paid Unlock Model

### Option A: Free with Ads + Paid Unlock

**Model:** Free to play with occasional ads. One-time purchase ($2.99-$4.99) removes all ads permanently.

**Pros:**
- Low barrier to entry (free download)
- Revenue from both ad viewers and paying users
- "Remove Ads" is a well-understood value proposition
- Good for discoverability (free apps get more downloads)

**Cons:**
- Ads can hurt the immersive cyberpunk atmosphere
- Banner ads especially disruptive on a "dashboard" interface
- Need to balance ad frequency carefully
- Some users have ad blockers

**Recommended Ad Placement for Grid Watch Zero:**
- ❌ NO banner ads (would break NOC aesthetic)
- ⚠️ Interstitials only between campaign levels (not during gameplay)
- ✅ Rewarded video for optional bonuses (see Question 3)

### Option B: Freemium with IAP

**Model:** Free base game, pay for convenience/cosmetics/content.

**Pros:**
- Can generate more revenue from engaged players ("whales")
- No ads to break immersion
- Players pay for what they value

**Cons:**
- Risk of "pay to win" perception
- Requires careful balance design
- More complex to implement
- Can feel predatory if done poorly

### Option C: Premium (Paid Upfront)

**Model:** $2.99-$4.99 one-time purchase, no ads, no IAP.

**Pros:**
- Clean user experience
- No balance concerns
- Simple to implement
- Attracts quality-focused players

**Cons:**
- Fewer downloads (paid apps have 10-50x fewer installs)
- Hard to compete with free alternatives
- No ongoing revenue stream

### Recommendation for Grid Watch Zero

**Hybrid Model: Free + Rewarded Ads + Optional Premium Unlock**

1. Game is **free to download and play completely**
2. **Rewarded video ads** offer optional bonuses (2x credits, etc.)
3. **"Grid Watch Pro" IAP ($3.99)** unlocks:
   - Permanent 2x credit multiplier (no ads needed)
   - Exclusive cosmetic theme ("Pro Operator")
   - Remove all ad prompts
   - Support the developer badge

This respects the player while providing monetization options.

---

## Question 3: "2x Earned Credits" Feature

### Implementation Options

**Option A: Rewarded Video Ad**
- Player taps "Watch Ad for 2x Credits"
- 15-30 second video ad plays
- Credits doubled for next 5-10 minutes (or next X ticks)
- Can watch again after cooldown (30 min - 1 hour)

**UI Placement Ideas:**
```
┌─────────────────────────────────────┐
│  CREDITS: ₵125,430                  │
│  ┌─────────────────────────────┐    │
│  │ 🎬 Watch Ad for 2x Credits  │    │
│  │    (5 minutes)              │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

Or in the Stats Header:
```
┌─────────────────────────────────────┐
│  ₵125,430  │  📊 +2.5K/tick  │ [2x] │
└─────────────────────────────────────┘
                                  ↑
                          Tap for ad boost
```

**Option B: IAP "Permanent 2x Multiplier"**
- One-time purchase ($1.99 - $2.99)
- Credits permanently doubled
- Shows "PRO" badge next to credit display
- Could tier it: 1.5x for $0.99, 2x for $1.99, 3x for $2.99

**Option C: Hybrid (Both)**
- Free players: Watch ad for temporary 2x (5-10 min)
- Paid players: Permanent 2x with single purchase
- This is the **recommended approach**

### Other "Watch Ad" Feature Ideas

| Feature | Ad Reward | Duration/Amount |
|---------|-----------|-----------------|
| 2x Credits | Rewarded Video | 5-10 minutes |
| Instant Repair | Rewarded Video | Full firewall heal |
| Skip Cooldown | Rewarded Video | Reset prestige timer |
| Bonus Intel | Rewarded Video | +50 Intel points |
| Lucky Drop | Rewarded Video | Random data chip |
| Threat Reduction | Rewarded Video | -1 threat level (10 min) |
| Offline Boost | Rewarded Video | 2x offline earnings |

### Balance Considerations

**Without 2x Boost:**
- Level 1: ~15-20 minutes to complete
- Level 7: ~45-60 minutes to complete

**With 2x Boost:**
- Level 1: ~8-10 minutes
- Level 7: ~25-30 minutes

This is acceptable - it's a convenience, not a requirement. Players who don't want to watch ads can still complete all content.

---

## Technical Implementation Notes

### StoreKit 2 (Recommended for iOS 15+)

```swift
// Example structure (DO NOT IMPLEMENT YET)
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    private let productIDs = [
        "com.warsignal.gridwatchzero.removeads",
        "com.warsignal.gridwatchzero.pro",
        "com.warsignal.gridwatchzero.credits2x"
    ]

    func loadProducts() async {
        // Load from App Store
    }

    func purchase(_ product: Product) async throws {
        // Handle purchase
    }

    func restorePurchases() async {
        // Restore for new devices
    }
}
```

### Ad Integration (AdMob Example)

```swift
// Example structure (DO NOT IMPLEMENT YET)
import GoogleMobileAds

class AdManager: ObservableObject {
    @Published var isRewardedAdReady = false
    private var rewardedAd: GADRewardedAd?

    func loadRewardedAd() {
        // Load rewarded video
    }

    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        // Show ad, call completion with success/failure
    }
}
```

---

## Revenue Projections (Rough Estimates)

### Assumptions
- 10,000 downloads in first month (modest for free game)
- 5% watch rewarded ads regularly
- 2% convert to paid unlock

### Scenario A: Ads Only
- 500 daily ad views × $0.02 eCPM = $10/day = **$300/month**

### Scenario B: Ads + $3.99 Unlock
- 200 purchases × $3.99 × 0.70 (Apple cut) = **$559 one-time**
- Plus ongoing ad revenue from non-purchasers

### Scenario C: Premium $2.99
- 10,000 × 0.05 conversion × $2.99 × 0.70 = **$1,047 one-time**
- But likely only 500-1,000 downloads at paid tier

---

## Next Steps

1. **Decide on monetization model** (recommend Hybrid: Free + Rewarded Ads + Pro Unlock)
2. **Design ad placement UX** that fits cyberpunk aesthetic
3. **Configure App Store Connect** with IAP products
4. **Integrate ad SDK** (AdMob recommended for simplicity)
5. **Implement StoreManager** for purchases
6. **Test extensively** in Sandbox environment
7. **Update privacy policy** for ad tracking disclosure

---

## Open Questions

- [ ] What price point feels right for "Grid Watch Pro"? ($2.99? $3.99? $4.99?)
- [ ] Should cosmetics be separate purchases or bundled with Pro?
- [ ] How aggressive should ad prompts be? (Never interrupt gameplay)
- [ ] Should there be a "tip jar" for players who want to support more?
- [ ] Consider regional pricing for different markets?

---

## References

- [Apple StoreKit Documentation](https://developer.apple.com/storekit/)
- [AdMob iOS Quick Start](https://developers.google.com/admob/ios/quick-start)
- [App Store Review Guidelines - IAP](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase)
- [Apple Small Business Program](https://developer.apple.com/app-store/small-business-program/)

---

*This document is for planning purposes only. No code changes have been made.*
