# Idle Unclicker - Development Roadmap

## Game Philosophy
**Less interaction is better.** The player automaton makes all decisions - combat tactics, resource management, equipment, and survival. The player's role is to observe, occasionally guide focus, and witness the character's journey through an infinite dungeon.

## Current State (v0.1)
- [x] Core combat loop (DCSS-inspired)
- [x] Character progression (stats, skills, levels)
- [x] Dungeon/Town navigation with ASCII maps
- [x] Player automaton (auto-potions, auto-flee, auto-rest)
- [x] Equipment system (weapons/armor tiers)
- [x] Offline progression (8+ hour gate)
- [x] Hive persistence (character, game state, combat log)
- [x] TimeManager anti-cheat (NTP validation)
- [x] Tab-based UI with stats display
- [x] Roboto Mono font for ASCII art

---

## Phase 1: Core Progression Loop (v0.2)

### 1.1 Prestige/Ascension System ⭐ PRIORITY
**Goal**: Give meaning to death and long-term progression

**Implementation**:
- On permanent death, convert accumulated XP → "Echo Shards"
- Echo Shards persist across all characters
- Spend shards on permanent meta-upgrades:
  - +5% starting HP (max 100% bonus)
  - +1 starting potion (max 10)
  - +10% XP gain (max 200%)
  - +1 to starting dungeon depth (max 10)
  - Unlock new races/classes
- **Automation**: Auto-triggers ascension when death is inevitable (0 potions, <5% HP, 3+ deaths on current depth)

**Twist**: Each ascension adds a "Scar" - cosmetic but shows veteran status

### 1.2 Skill Tree (Passive Grid)
**Goal**: Build variety without micromanagement

**Implementation**:
- Hex-grid with 3 branches: Combat (red), Survival (green), Wealth (gold)
- ~30 nodes per branch, various paths
- Nodes unlock passively as you play (time-based, not point-based)
- **Automation**: Auto-selects path based on detected playstyle:
  - Aggressive (kills quickly) → Combat branch
  - Defensive (flees often) → Survival branch
  - Loot-focused → Wealth branch

**Twist**: Some nodes have tradeoffs (+10% damage, -10% HP) - automation weighs these

### 1.3 Bestiary Knowledge
**Goal**: Reward dungeon diving with permanent knowledge

**Implementation**:
- Track kills per monster type
- At 10/50/100/500 kills: unlock knowledge bonuses
- Bonuses: +2% damage, +5% evasion, +10% loot, learn weakness
- **Automation**: Uses knowledge to exploit weaknesses (auto-switches weapons for monster type)

**Twist**: Knowledge persists across ascensions - your "Echo" remembers

---

## Phase 2: Companions & Social (v0.3)

### 2.1 Mercenary Companions
**Goal**: Dungeon feels less lonely, adds tactical depth

**Implementation**:
- Hire up to 2 companions from town
- Roles: Tank (high HP, taunt), Healer (regen), DPS (damage), Scout (evasion)
- Companions have:
  - Equipment slots (automated)
  - Loyalty meter (flee too much = they leave)
  - Level independently
- **Automation**: Auto-hires based on gold reserves and current party gaps

**Twist**: Companions can sacrifice themselves to save you - automation decides when

### 2.2 Guild Hall (Echo Sanctuary)
**Goal**: Meta-progression hub

**Implementation**:
- Unlock after first ascension
- Build rooms that give permanent bonuses:
  - Training Hall: +1% skill XP
  - Treasury: +10% gold find
  - Library: Bestiary fills 2x faster
  - Smithy: Better equipment drops
- **Automation**: Auto-upgrades when gold available, prioritizes based on playstyle

**Twist**: Hall is populated by "Echoes" of previous characters - they wander as NPCs

---

## Phase 3: Advanced Systems (v0.4)

### 3.1 Equipment Enchanting & Gems
**Goal**: Item depth beyond tiers

**Implementation**:
- Gems drop from monsters (3 colors = 3 stat types)
- Socket into equipment for bonuses
- Enchanting adds random prefix/suffix
- **Automation**: Auto-enchants in town when safe, auto-swaps gems for bosses
- Risk: 5% chance to destroy item on enchant

**Twist**: "Cursed" enchantments exist - powerful but with drawbacks (automation evaluates)

### 3.2 Boss Rush & Rifts
**Goal**: Challenge modes, variety

**Implementation**:
- Every 5th floor: Boss with unique mechanic
- Bosses drop "Essences" for legendary crafting
- Daily Rifts: Special dungeons with modifiers (no potions, double speed, etc.)
- **Automation**: Decides whether to attempt based on power estimation

**Twist**: Rifts have leaderboards (local-only) - compete against your Echoes

### 3.3 Professions (Passive Gathering)
**Goal**: Secondary progression while fighting

**Implementation**:
- Mining: Auto-gathers ore during combat
- Herbalism: Auto-gathers herbs
- Skinning: Auto-gathers from beasts
- Crafting: Auto-crafts potions, scrolls
- **Automation**: Auto-crafts when mats available, auto-sells excess

**Twist**: Rare "Astral" materials only drop during focus mode (>80% focus)

---

## Phase 4: Polish & Depth (v0.5)

### 4.1 Equipment Sets & Synergies
**Goal**: Build-around mechanics

**Implementation**:
- Sets have 2/4/6 piece bonuses
- Mixing sets can create unexpected synergies
- **Automation**: Evaluates set bonuses vs raw stats, sometimes keeps weaker item for set

**Twist**: "Corrupted" sets - extremely powerful but slowly drain HP

### 4.2 Transmutation/Alchemy
**Goal**: Inventory management becomes progression

**Implementation**:
- 10 common → 1 uncommon → 1 rare → 1 epic → 1 legendary
- **Automation**: Auto-transmutes when inventory full, prioritizes needs
- Small chance (1%) of "Miracle" - epic becomes legendary

**Twist**: "Volatile" transmutation - 50% chance of nothing, 50% chance of +1 tier

### 4.3 Legendary Items
**Goal**: Chase items, long-term goals

**Implementation**:
- 20 unique legendaries with game-changing effects
- Drop from bosses only
- Can be "reforged" to change stats but keep effect
- **Automation**: Builds around legendary effects when acquired

**Twist**: Some legendaries have "sentience" - they want specific actions (kill dragons, etc.)

---

## Phase 5: Infinite Endgame (v1.0)

### 5.1 The Infinite Spiral
**Goal**: Truly endless progression

**Implementation**:
- After floor 100, dungeon "resets" but harder
- Each spiral: +10% monster HP/damage, better loot
- Keeps ascending until you stop
- **Automation**: Continuously pushes, only returns to town when absolutely necessary

### 5.2 Character Legacy
**Goal**: Your history matters

**Implementation**:
- Each character writes a "Tale" on death/ascension
- Tales unlock permanent account bonuses
- Tales can be re-read in Guild Hall
- **Automation**: None - this is purely for the player to read

---

## Technical Debt & Polish

- [ ] Add sound effects (retro 8-bit style)
- [ ] Add haptic feedback on mobile
- [ ] Improve ASCII art (more tile variety)
- [ ] Add color to ASCII (rare rooms, loot)
- [ ] Settings screen (font size, toggle features)
- [ ] Export/import save (for backup)
- [ ] Achievements (local)

---

## Design Principles (Checklist for New Features)

1. **Does it require player interaction?** (If yes, how can we automate it?)
2. **Does it respect the 8-hour offline gate?** (No constant checking needed)
3. **Does it persist across ascensions?** (Long-term value)
4. **Can the automaton make meaningful decisions about it?** (Not just random)
5. **Does it add visible progression?** (Player can see/feel the difference)

---

## Current Priority: Phase 1.1 (Prestige System)

**Why first?**
- Gives meaning to death (currently just annoying)
- Creates long-term retention loop
- Simple to implement (mostly data structures)
- Automation logic is straightforward

**Next Steps:**
1. Create `EchoShards` counter in GameState
2. Add `Ascension` screen (shown on death or from menu)
3. Implement 5-6 meta-upgrades
4. Modify death flow to offer ascension
5. Add "Scar" system (cosmetic only)

Ready to implement?
