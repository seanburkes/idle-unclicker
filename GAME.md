# Idle Unclicker - Game Design Document

**Status**: Pre-Production  
**Platform**: Android (Flutter)  
**Genre**: Anti-Clicker / Passive Idle RPG  
**Monetization**: Completely Free (No ads, no IAP)  
**Tone**: Satirical, Absurdist, Anti-Capitalist

---

## 1. Core Concept

An idle RPG that rewards genuine absence. The less you interact with the game, the faster you progress. Open the app to watch your character automatically battle absurd monsters, accumulate loot, and progress through an infinitely recursive leveling system inspired by Tower of Hanoi mathematics.

**The Twist**: Every tap, swipe, or interaction reduces your "Focus" multiplier. The game explicitly discourages play.

**Inspirations**:
- **ProgressQuest** (2002): Automated RPG progression with absurdist flavor text
- **IRC IdleRPG**: Time-based XP accumulation with penalties for talking
- **Tower of Hanoi**: Exponential 2^n - 1 scaling creating plateau-breakthrough loops
- **Cow Clicker**: Satire of exploitation mechanics becoming the thing they critique

---

## 2. Core Mechanics

### 2.1 The Anti-Click System

**Focus Meter** (0-100%):
- Builds at 1% per minute of app inactivity (screen on but no interaction)
- Builds at 2% per minute of app being backgrounded/closed
- Resets to 0% on any tap, swipe, or interaction
- Maximum offline accumulation: 8 hours (anti-cheat protection)

**XP Multiplier**:
- Base: 1x
- With Focus: 1x + (Focus% × 2)
  - 100% Focus = 3x XP
  - 50% Focus = 2x XP
  - 0% Focus = 1x XP

**Zen Streaks**:
- Track consecutive days with >80% average Focus
- Zen Streak bonuses unlock cosmetic options and rare titles

### 2.2 Time-Based Progression (IRC IdleRPG Style)

**Time To Level (TTL)** Formula:
```
TTL = 600 × (1.16 ^ current_level) seconds

Examples:
- Level 1: ~10 minutes
- Level 10: ~44 minutes
- Level 25: ~6.5 hours
- Level 50: ~3.2 days
- Level 99: ~23 days
```

**After Level 60**: Linear scaling (+1 day per level) to prevent exponential absurdity.

### 2.3 Tower of Hanoi Progression Architecture

Each "Disk" represents a major progression system. To advance Disk N, you must first complete Disk N-1 in all prerequisite systems.

**The Recursive Structure**:
```
Meta-Tower (Player Level)
├── Disk 1: Physical Combat (STR)
│   └── Requires: Nothing
├── Disk 2: Magical Energy (INT)
│   └── Requires: Combat Disk 1 complete
├── Disk 3: Equipment Crafting (DEX)
│   └── Requires: Energy Disk 2 complete
├── Disk 4: Guild Influence (CHA)
│   └── Requires: Crafting Disk 3 complete
└── ... (continues infinitely)
```

**Mathematical Scaling**:
- Each disk level requires (2^N - 1) sub-completions
- Disk 5 requires 31 completions of its prerequisite
- Disk 10 requires 1,023 completions
- Creates natural "plateau then breakthrough" rhythm

**Visual Representation**:
- Display current disk positions as stacked rings
- Each system shows: `[Current Disks] / [Next Disk Requirement]`
- When complete, animation shows disk moving to next peg

### 2.4 Automated Combat (ProgressQuest Style)

**Combat Loop** (Runs automatically when app is open):
1. Generate random monster based on player level
2. Display absurdist combat text
3. Calculate damage and loot
4. Update stats and inventory
5. Repeat every 3-5 seconds

**Combat Text Generation**:
```
[Action] [Number] [Adjective] [Monster Type]

Action Pool:
- "Executing"
- "Slaying"
- "Vanquishing"
- "Dismantling"
- "Politely asking to leave"

Adjective Modifiers (based on level difference):
- (-10 levels): "imaginary"
- (-5 to -1): "sick", "crippled", "undernourished"
- (0 to +5): (none)
- (+6 to +10): "greater", "massive", "veteran"
- (+11+): "titanic", "demon", "undead"

Monster Examples:
- "Beef Elemental"
- "Humidity Giant"
- "Plaid Dragon"
- "Enraged Toaster"
- "Existential Dread"
- "Tax Accountant"
```

### 2.5 The Penalty System

**Interaction Penalties** (IRC IdleRPG style):

| Action | Focus Penalty | XP Penalty |
|--------|--------------|------------|
| Tap anywhere | Reset to 0% | Lose 1 minute of accumulated XP |
| Open settings | -25% | None |
| Change equipment | -10% | None |
| Check inventory | -5% | None |
| Level up (necessary tap) | -50% | None |

**Messages displayed when tapping**:
- "The Hero prefers to work alone."
- "Your interference has been noted and logged."
- "Please stop helping."
- "Focus disrupted. Shame applied."
- "The monsters appreciate your assistance."

---

## 3. Character System

### 3.1 Character Creation

**Race Options** (Purely cosmetic):
- Half Orc
- Dung Elf
- Double Hobbit
- Enchanted Motorcycle
- Land Squid
- Sentient Sandwich
- Corporate Middle Manager
- Abstract Concept

**Class Options** (Purely cosmetic):
- Ur-Paladin
- Voodoo Princess
- Robot Monk
- Shiv-Knight
- Tickle-Mimic
- Excel Spreadsheet
- Meeting That Could Have Been an Email

**Stat System** (Mostly meaningless):
- STR: Only affects inventory capacity (STR + 10 slots)
- CON, DEX, INT, WIS, CHA: Display only, no gameplay effect

### 3.2 Equipment System

**11 Equipment Slots**:
Weapon, Shield, Helm, Hauberk, Brassairts, Vambraces, Gauntlets, Gambeson, Cuisses, Greaves, Sollerets

**Naming Formula**:
```
[Prefix] [Material] [Item] of [Suffix]

Examples:
- "Rusty Macrame Helmet of Indifference"
- "Polished Plasma Vambraces of Mild Annoyance"
- "Vicious Mithril Whinyard of Tax Evasion"
```

**Auto-Upgrade System**:
- Equipment automatically upgrades when gold threshold reached
- No player input required
- Old equipment sold automatically

### 3.3 Alignment System (IdleRPG Style)

**Choose at character creation**:

**Good**:
- +10% item effectiveness
- 1/12 daily chance of "Divine Intervention" (5-12% TTL reduction)
- 1/50 critical hit chance
- Philosophy: "Patience is rewarded"

**Neutral**:
- Baseline stats
- No special events
- Philosophy: "Just let it happen"

**Evil**:
- -10% item effectiveness
- 1/8 daily chance to steal items OR be forsaken (1-5% TTL penalty)
- 1/20 critical hit chance
- Philosophy: "The ends justify the memes"

---

## 4. UI/UX Design

### 4.1 Dashboard Layout

```
┌─────────────────────────────────────┐
│  Idle Unclicker          [Zen: 5d]  │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Executing 3 greater war   │   │
│  │        Bacon Elementals     │   │
│  └─────────────────────────────┘   │
│                                     │
│  HP: 47/50          MP: 12/20       │
│  ┌──────────────────┐              │
│  │ [==========>    ]│  XP to Lvl   │
│  └──────────────────┘  2d 4h 12m    │
│                                     │
│  Focus: ████████░░  82% (2.6x XP)   │
│                                     │
│  Gold: 4,291                        │
│  Level: 23 Bureaucrat               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Disk Progress:              │   │
│  │ Combat:  [███░░░] 3/7      │   │
│  │ Magic:   [██░░░░] 2/5      │   │
│  │ Craft:   [█░░░░░] 1/3      │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Level Up - Tapping penalizes]    │
│                                     │
│  Direction: [Idle Forward ▼]       │
│                                     │
└─────────────────────────────────────┘
```

### 4.2 Combat Log

Scrolling text area showing recent actions:
```
08:42 - Executing 2 greater war Tax Accountants
08:42 - Loot: Rusty Macrame Helmet of Indifference
08:43 - Found: 1 bit (Currency)
08:43 - Executing a sick dying Humidity Giant
08:43 - Quest Updated: Deliver 5 bits to the void
08:44 - Executing a passing Sentient Sandwich Excel Spreadsheet
```

### 4.3 Minimal Interaction Controls

**Level Up Button**:
- Only active when XP threshold reached
- Displays warning: "Leveling up will disrupt Focus (-50%)"
- Single tap executes, then button disables

**Direction Dropdown**:
- Options: "Idle Forward", "Idle Backward", "Sideways Idle", "Existential Drift"
- All options function identically (cosmetic only)
- Changing direction: -10% Focus penalty

**Settings (Hidden)**:
- Accessed via triple-tap on title
- Sound toggle, notification settings
- No gameplay-relevant options

### 4.4 Notification Strategy

**When to Notify**:
- Level up achieved (optional, default off)
- Zen streak milestone (7d, 30d, 100d)
- Daily "Reminder to NOT play" (satirical)

**Notification Text Examples**:
- "You have NOT been playing for 7 days straight. Impressive."
- "Your character misses you. Please continue ignoring them."
- "Achievement unlocked: Successfully avoided interaction!"

---

## 5. Progression Systems

### 5.1 Individual Progress (Towers)

Each tower represents a character aspect. All progress simultaneously when app is open.

**Physical Tower (STR)**:
- Base generation: 1 XP/second
- Benefits: Inventory capacity
- Disk scaling: 2^n - 1 per level

**Mental Tower (INT/WIS)**:
- Base generation: 0.8 XP/second
- Benefits: Spell unlocks (cosmetic)
- Disk scaling: 2^n - 1 per level

**Social Tower (CHA)**:
- Base generation: 0.5 XP/second
- Benefits: Guild rank titles
- Disk scaling: 2^n - 1 per level

### 5.2 Meta-Progress (Player Level)

Player level determined by lowest tower level (bottleneck design).

**Example**:
```
Physical: Level 10 (requires 1023 XP)
Mental:   Level 8  (requires 255 XP)
Social:   Level 12 (requires 4095 XP)
Player Level: 8 (bottlenecked by Mental)
```

This encourages balanced progression across all systems.

### 5.3 Quest System (ProgressQuest Style)

**Automated Quests**:
- Quests assigned automatically
- Progress tracked automatically
- Rewards granted automatically
- Player has no control over quest selection

**Quest Types**:
1. **Kill Quests**: "Execute 5 Corporate Middle Managers"
2. **Fetch Quests**: "Deliver 3 existential crises to the void"
3. **Escort Quests**: "Accompany a Passive-Aggressive Note to safety"
4. **Narrative Quests**: Random story events with no choice

**Quest Progression**:
- Displayed in combat log
- No "accept" or "complete" buttons
- Just happens while you watch

---

## 6. Anti-Cheat & Technical Considerations

### 6.1 Time Manipulation Protection

**Strategy**: Hybrid NTP + Monotonic Clock

```dart
// Pseudocode
class TimeManager {
  Future<Duration> calculateOfflineProgress() async {
    // Get trusted NTP time
    final trustedNow = await FlutterKronos.getCurrentTimeMs();
    final lastTrusted = await getLastTrustedTime();
    
    // Detect device time changes
    final localNow = DateTime.now().millisecondsSinceEpoch;
    final localDiff = localNow - lastLocal;
    final trustedDiff = trustedNow - lastTrusted;
    
    if ((localDiff - trustedDiff).abs() > 30 seconds) {
      // Time manipulation detected - cap progress
      return min(Duration(hours: 1), calculateMinProgress());
    }
    
    // Cap at 8 hours regardless
    return min(Duration(hours: 8), Duration(milliseconds: trustedDiff));
  }
}
```

### 6.2 State Persistence

**Storage Strategy**:
- **Primary**: Hive (fast, type-safe object storage)
- **Backup**: SharedPreferences (timestamp verification)
- **Save triggers**: App pause, every 30 seconds while open

**Critical State to Persist**:
- Last update timestamp (trusted and local)
- All resource values (gold, XP per tower)
- Current Focus percentage
- Zen streak counter and last check date

### 6.3 Background Processing

**Android**:
- WorkManager for periodic updates (every 15 min minimum)
- Foreground service optional for persistent notification

**iOS** (if expanding):
- Background fetch for state updates
- Push notifications for level-ups

---

## 7. Satirical Elements

### 7.1 Anti-Capitalist Themes

**The Core Satire**:
The game explicitly mocks:
- Energy systems ("You have infinite energy because you shouldn't be playing")
- Pay-to-win ("All upgrades are free because you shouldn't want them")
- Daily rewards ("Log in to be disappointed")
- Loot boxes ("Your reward is the friends we made along the way: none")

**Flavor Text Examples**:
- Equipment: "This sword has been nerfed 47 times by corporate"
- Monsters: "Corporate Middle Manager - attacks with meetings"
- Spells: "Summon Middle Management (0 damage, 2 hour meeting)"

### 7.2 Breaking the Fourth Wall

**Game Acknowledges It's a Game**:
- "You have been NOT playing for 3 hours. Your dopamine receptors thank you."
- "Achievement unlocked: Touched grass (metaphorically)"
- "Your character has unionized and demands less screen time."

### 7.3 The Meta-Joke

The ultimate satire: the game itself becomes a commentary on:
- How idle games exploit psychological triggers
- The absurdity of "progress" without agency
- The gamification of existence
- The value of doing nothing

---

## 8. Technical Implementation

### 8.1 Required Flutter Packages

```yaml
dependencies:
  # State persistence
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Background processing
  workmanager: ^0.9.0+3
  
  # Anti-cheat time
  flutter_kronos: ^0.1.1+2
  
  # Notifications
  flutter_local_notifications: ^16.1.0
  
  # App lifecycle
  # (Built-in WidgetsBindingObserver)
```

### 8.2 Architecture Overview

```
lib/
├── main.dart                    # App entry, lifecycle wrapper
├── models/
│   ├── game_state.dart          # Hive model for persistence
│   ├── character.dart           # Character data
│   └── tower.dart               # Individual tower progress
├── providers/
│   ├── game_provider.dart       # Main game state management
│   ├── time_manager.dart        # Anti-cheat time tracking
│   └── combat_generator.dart    # Absurdist text generation
├── screens/
│   └── dashboard_screen.dart    # Main UI
├── services/
│   ├── background_service.dart  # WorkManager callbacks
│   └── notification_service.dart
└── utils/
    ├── combat_text.dart         # Text generation pools
    └── constants.dart           # Formulas, multipliers
```

### 8.3 Key Implementation Notes

1. **Combat Text Generation**: Use formulaic generation (Prefix + Material + Item) rather than hardcoded lists for infinite variety

2. **Time Calculation**: Always use NTP-verified time for progression calculations, local time only for display

3. **Focus Tracking**: Track time between interactions, not just total idle time

4. **Offline Progress**: Calculate on app resume using saved timestamp, not background processing

5. **State Sync**: Save immediately on app pause (didChangeAppLifecycleState), not just periodic saves

---

## 9. Open Questions & Decisions Needed

### 9.1 Clarification Required

1. **Monetization**: Confirm completely free / open source? Any future plans?

2. **Offline Time**: Does progress count when app is completely closed, or only backgrounded?

3. **Social Features**: Local-only, or online leaderboards for longest Zen streaks?

4. **Prestige System**: Should there be ascension/prestige mechanics (reset for bonuses)?

5. **Character Permanence**: Can characters die/be deleted, or is progress permanent?

6. **Multi-Character**: Single character per device, or multiple save slots?

### 9.2 Design Decisions Pending

1. **Visual Style**: 
   - ASCII/text-based (ProgressQuest style)?
   - Minimalist vector graphics?
   - Retro pixel art?

2. **Sound Design**:
   - Silent (true idle experience)?
   - Ambient background sounds?
   - Absurdist voice lines?

3. **Accessibility**:
   - Colorblind-friendly indicators?
   - Screen reader support?
   - Text size options?

4. **Localization**:
   - English only initially?
   - i18n framework from start?

---

## 10. Success Metrics

**For a Satirical Anti-Clicker**:

1. **Average Session Length**: Target < 30 seconds (players open, check progress, close)

2. **Retention**: Track 7-day and 30-day "non-interaction" retention

3. **Zen Streaks**: Measure how many players achieve 7+ day streaks

4. **Player Comments**: Best success = players who "get the joke" and share the satire

5. **Organic Sharing**: Players sharing screenshots of absurdist loot/equipment names

---

## 11. Development Phases

### Phase 1: Core Loop (MVP)
- [ ] Basic Flutter setup with Hive persistence
- [ ] Time-based progression system
- [ ] Automated combat with text generation
- [ ] Simple dashboard UI
- [ ] Anti-cheat time tracking

### Phase 2: Progression Systems
- [ ] Tower of Hanoi disk progression
- [ ] Equipment system with formulaic naming
- [ ] Quest system (automated)
- [ ] Alignment system (Good/Neutral/Evil)

### Phase 3: Anti-Click Mechanics
- [ ] Focus meter implementation
- [ ] Tap penalty system
- [ ] Zen streak tracking
- [ ] Satirical messaging system

### Phase 4: Polish & Satire
- [ ] Extensive combat text pools
- [ ] Absurdist flavor text
- [ ] Notification system
- [ ] Settings/hidden options

### Phase 5: Social (Optional)
- [ ] Online leaderboards
- [ ] Guild system
- [ ] Team quests

---

**Document Version**: 0.1  
**Last Updated**: 2026-02-08  
**Next Review**: After clarification on open questions
