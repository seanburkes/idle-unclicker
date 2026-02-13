# Flutter Architecture Refactoring Plan

## Overview

This document outlines a comprehensive refactoring plan to address architectural antipatterns identified in the codebase analysis. The refactoring follows a phased approach to minimize risk and maintain functionality throughout.

**Current State:**
- GameProvider: 2,659 lines (monolithic state management)
- 15 God widgets (330-1,200 lines each)
- Dual architecture confusion (DDD layer exists but unused)
- Layer violations throughout

**Target State:**
- Focused providers (<300 lines each)
- Decomposed widgets (<150 lines each)
- Clean layer separation
- Proper dependency injection

---

## Phase 1: Split GameProvider into Focused Providers

**Priority:** 🔴 Critical  
**Effort:** High  
**Risk:** Medium (core functionality)  
**Estimated Time:** 2-3 days

### 1.1 Provider Decomposition Strategy

Split `GameProvider` (2,659 lines) into focused, single-responsibility providers:

#### New Provider Structure
```
lib/providers/
├── core/
│   ├── game_timer_provider.dart      # Timer lifecycle management
│   ├── game_state_provider.dart      # Game state persistence
│   └── character_provider.dart       # Character state & progression
├── combat/
│   └── combat_provider.dart          # Combat state & logic
├── inventory/
│   └── inventory_provider.dart       # Equipment & items
├── progression/
│   ├── skill_tree_provider.dart      # Skill tree state
│   ├── profession_provider.dart      # Professions & crafting
│   └── bestiary_provider.dart        # Monster knowledge
├── features/
│   ├── guild_hall_provider.dart      # Guild hall management
│   ├── boss_rush_provider.dart       # Boss rush state
│   ├── enchanting_provider.dart      # Enchanting system
│   ├── equipment_sets_provider.dart  # Equipment sets
│   ├── companions_provider.dart      # Companion system
│   ├── transmutation_provider.dart   # Transmutation
│   ├── alchemy_provider.dart         # Alchemy system
│   ├── legendary_items_provider.dart # Legendary items
│   └── spiral_provider.dart          # Infinite spiral
└── providers.dart                    # Barrel export file
```

### 1.2 Provider Responsibilities

| Provider | Responsibilities | Lines (est.) |
|----------|------------------|--------------|
| GameTimerProvider | Timer lifecycle, tick orchestration | ~150 |
| GameStateProvider | App state, persistence coordination | ~200 |
| CharacterProvider | Character stats, XP, leveling | ~250 |
| CombatProvider | Combat state, turn management | ~200 |
| InventoryProvider | Equipment, inventory management | ~180 |
| SkillTreeProvider | Skill unlocks, bonuses | ~150 |
| ProfessionProvider | Gathering, crafting | ~200 |
| BestiaryProvider | Monster knowledge | ~100 |
| GuildHallProvider | Rooms, NPCs, upgrades | ~180 |
| BossRushProvider | Essence, bosses, rifts | ~150 |
| EnchantingProvider | Gems, enchantments | ~200 |
| EquipmentSetsProvider | Sets, bonuses, synergies | ~180 |
| CompanionsProvider | Roster, party management | ~120 |
| TransmutationProvider | Recipes, transmutation | ~150 |
| AlchemyProvider | Brewing, potions | ~180 |
| LegendaryItemsProvider | Legendary drops, effects | ~200 |
| SpiralProvider | Loop progression, tales | ~150 |

### 1.3 Refactoring Steps

#### Step 1: Create Provider Template
```dart
// Template for each new provider
import 'package:flutter/foundation.dart';
import '../models/xxx.dart';
import '../services/xxx_service.dart';

class XxxProvider extends ChangeNotifier {
  final XxxService _service;
  Xxx? _state;
  
  XxxProvider(this._service);
  
  Xxx? get state => _state;
  
  // Public methods only
  void initialize(Xxx initialState) {
    _state = initialState;
    notifyListeners();
  }
  
  Future<void> doAction() async {
    // Delegate to service
    _state = await _service.doAction(_state);
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Cleanup if needed
    super.dispose();
  }
}
```

#### Step 2: Extract Provider (One at a Time)

For each provider:

1. **Create new provider file**
   - Copy relevant fields from GameProvider
   - Copy relevant methods
   - Add constructor with service injection

2. **Update GameProvider**
   - Remove extracted fields and methods
   - Add getter for new provider
   - Keep backward compatibility during transition

3. **Update screens**
   - Replace `context.read<GameProvider>().xxx` with `context.read<XxxProvider>().xxx`
   - Update Consumer/Selector widgets

4. **Test**
   - Run the app
   - Verify functionality
   - Check for errors

5. **Commit**
   - Single provider per commit
   - Clear commit message

#### Step 3: Extract in Order

1. **GameTimerProvider** (foundation, no dependencies)
2. **CharacterProvider** (core entity, many depend on it)
3. **CombatProvider** (isolated domain)
4. **InventoryProvider** (equipment/items)
5. **SkillTreeProvider** (self-contained)
6. **BestiaryProvider** (simple, low risk)
7. **ProfessionProvider** (professions & crafting)
8. **GuildHallProvider** (feature)
9. **BossRushProvider** (feature)
10. **EnchantingProvider** (feature)
11. **EquipmentSetsProvider** (feature)
12. **CompanionsProvider** (feature)
13. **TransmutationProvider** (feature)
14. **AlchemyProvider** (feature)
15. **LegendaryItemsProvider** (feature)
16. **SpiralProvider** (feature, depends on others)

### 1.4 Cross-Provider Communication

Use a simple event bus or direct method calls for coordination:

```dart
// Option 1: Direct injection
class CombatProvider extends ChangeNotifier {
  final CharacterProvider _characterProvider;
  
  CombatProvider(this._characterProvider);
  
  void winCombat() {
    _characterProvider.gainExperience(xp);
  }
}

// Option 2: Event bus (for loose coupling)
class GameEventBus extends ChangeNotifier {
  void emit(GameEvent event) {
    notifyListeners();
  }
}
```

### 1.5 Testing Strategy

- Unit test each provider independently
- Mock service dependencies
- Test state transitions
- Verify notifyListeners() calls

---

## Phase 2: Extract God Widgets

**Priority:** 🔴 Critical  
**Effort:** High  
**Risk:** Low (UI only)  
**Estimated Time:** 3-4 days

### 2.1 Widget Decomposition Strategy

Break down each God screen into:
- **Screen** (coordination only, ~100 lines)
- **Tab widgets** (one per tab)
- **Feature widgets** (complex UI sections)
- **Reusable components** (shared across screens)

### 2.2 DashboardScreen Extraction

Current: 1,202 lines → Target: <150 lines

```
lib/screens/dashboard/
├── dashboard_screen.dart           # Main screen (tabs, navigation)
├── tabs/
│   ├── combat_tab.dart             # Combat interface
│   ├── equipment_tab.dart          # Equipment display
│   ├── inventory_tab.dart          # Inventory grid
│   ├── dungeon_tab.dart            # Dungeon/map view
│   └── log_tab.dart                # Message log
└── widgets/
    ├── dungeon_renderer_widget.dart
    ├── health_bar.dart
    ├── stat_display.dart
    ├── equipment_slot.dart
    └── inventory_grid.dart
```

### 2.3 Common Reusable Widgets

Create shared components:

```
lib/presentation/widgets/
├── common/
│   ├── game_card.dart              # Styled card container
│   ├── stat_row.dart               # Label + value display
│   ├── progress_bar.dart           # Custom progress indicator
│   ├── cooldown_indicator.dart     # Timer/cooldown display
│   └── rarity_indicator.dart       # Item rarity colors
├── buttons/
│   ├── game_button.dart            # Styled action button
│   ├── icon_action_button.dart     # Icon + label button
│   └── toggle_button.dart          # On/off toggle
└── lists/
    ├── item_list.dart              # Generic item list
    ├── grid_list.dart              # Grid layout
    └── log_list.dart               # Scrollable log
```

### 2.4 Extraction Pattern

```dart
// Before (in dashboard_screen.dart):
Widget _buildCombatSection() {
  return Column(
    children: [
      // 50+ lines of nested widgets
    ],
  );
}

// After (combat_tab.dart):
class CombatTab extends StatelessWidget {
  const CombatTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CombatProvider>(
      builder: (context, combat, child) {
        return Column(
          children: [
            EnemyWidget(enemy: combat.currentEnemy),
            CombatControls(onAttack: combat.attack),
          ],
        );
      },
    );
  }
}
```

### 2.5 Add Keys to Lists

Add keys to all dynamic lists:

```dart
// Before:
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)

// After:
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(
    key: ValueKey(items[index].id),  // Unique key
    item: items[index],
  ),
)
```

---

## Phase 3: Fix Layer Violations

**Priority:** 🟡 High  
**Effort:** Medium  
**Risk:** Medium  
**Estimated Time:** 2-3 days

### 3.1 Architecture Decision

**Option A: Commit to DDD** (Recommended)
- Use existing domain/ layer
- Convert models/ to DTOs only
- Implement repository pattern
- Move business logic to domain services

**Option B: Simplify to Simple Provider Pattern**
- Remove unused domain/ folder
- Keep models/ but extract business logic
- Use providers as orchestrators
- Simpler, less ceremony

**Decision: Option A** - The DDD layer is well-designed, let's use it.

### 3.2 Implementation Steps

1. **Move business logic from models to domain services**
   ```dart
   // models/character.dart (current)
   void takeDamage(int damage) { ... }
   
   // Move to:
   // domain/services/character_domain_service.dart
   Character takeDamage(Character character, int damage) { ... }
   ```

2. **Create repository implementations**
   ```dart
   // infrastructure/repositories/
   // - hive_character_repository.dart (exists)
   // - hive_game_state_repository.dart (exists)
   // Add remaining repositories
   ```

3. **Update screens to use domain entities**
   ```dart
   // Before:
   import '../models/character.dart';
   
   // After:
   import '../domain/entities/character.dart';
   ```

4. **Create mappers between domain and data models**
   ```dart
   // infrastructure/mappers/character_mapper.dart
   class CharacterMapper {
     static CharacterEntity toDomain(models.Character model) { ... }
     static models.Character toModel(CharacterEntity entity) { ... }
   }
   ```

### 3.3 Service Layer Alignment

Move services into proper layers:

```
lib/
├── domain/services/           # Pure business logic (stateless)
│   ├── combat_service.dart
│   ├── character_service.dart
│   └── ...
├── application/services/      # Orchestration, transactions
│   ├── combat_application_service.dart (exists)
│   ├── equipment_application_service.dart (exists)
│   └── ...
└── infrastructure/services/   # External concerns (moved from lib/services/)
    ├── enchanting_service.dart
    └── ...
```

---

## Phase 4: Implement Proper DI

**Priority:** 🟡 Medium  
**Effort:** Medium  
**Risk:** Low  
**Estimated Time:** 1-2 days

### 4.1 ServiceLocator Activation

Update `main.dart` to use ServiceLocator:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ServiceLocator
  await ServiceLocator.initialize();
  
  // Get repositories from locator
  final characterRepo = ServiceLocator.get<CharacterRepository>();
  final gameStateRepo = ServiceLocator.get<GameStateRepository>();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CharacterProvider(
            ServiceLocator.get<CharacterService>(),
          ),
        ),
        // ... other providers
      ],
      child: const MainApp(),
    ),
  );
}
```

### 4.2 Provider Constructor Injection

Update all providers to accept dependencies:

```dart
class CombatProvider extends ChangeNotifier {
  final CombatService _combatService;
  final CharacterProvider _characterProvider;
  
  CombatProvider({
    required CombatService combatService,
    required CharacterProvider characterProvider,
  })  : _combatService = combatService,
        _characterProvider = characterProvider;
}
```

---

## Phase 5: Performance Optimizations

**Priority:** 🟢 Medium  
**Effort:** Low  
**Risk:** Low  
**Estimated Time:** 1 day

### 5.1 Add const Constructors

Add `const` to all immutable widgets:

```dart
// Before:
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(8),
    child: Text('Hello'),
  );
}

// After:
Widget build(BuildContext context) {
  return const Container(
    padding: EdgeInsets.all(8),
    child: Text('Hello'),
  );
}
```

### 5.2 Add RepaintBoundary

Wrap complex widgets to prevent unnecessary repaints:

```dart
RepaintBoundary(
  child: DungeonRendererWidget(...),
)
```

### 5.3 Selector Optimization

Use Selector instead of Consumer where possible:

```dart
// Before: Rebuilds on any character change
Consumer<CharacterProvider>(
  builder: (context, character, child) => Text('${character.health}'),
)

// After: Only rebuilds when health changes
Selector<CharacterProvider, int>(
  selector: (context, provider) => provider.character.health,
  builder: (context, health, child) => Text('$health'),
)
```

---

## Commit Strategy

### Commit Message Format
```
refactor(provider): extract CombatProvider from GameProvider

- Create CombatProvider with combat-specific state
- Move combat timers and logic from GameProvider
- Update DashboardScreen to use CombatProvider
- Maintain backward compatibility during transition

Relates to Phase 1 of REFACTOR.md
```

### Commit Frequency
- One provider per commit
- One widget extraction per commit
- One screen refactoring per commit
- Run tests before each commit

---

## Verification Checklist

### Before Each Phase
- [ ] All tests pass
- [ ] No lint errors
- [ ] App builds successfully
- [ ] Feature flags work correctly

### After Each Phase
- [ ] All tests pass
- [ ] No new lint errors
- [ ] App runs without crashes
- [ ] All features functional
- [ ] Performance metrics maintained or improved

---

## Rollback Plan

If issues arise:

1. **Immediate**: Revert last commit: `git revert HEAD`
2. **Phase-level**: Revert to phase start: `git reset --hard <phase-start-commit>`
3. **Full**: Restore from backup branch: `git checkout backup/main-refactor`

---

## Timeline Summary

| Phase | Duration | Risk | Deliverable |
|-------|----------|------|-------------|
| Phase 1 | 2-3 days | Medium | 17 focused providers |
| Phase 2 | 3-4 days | Low | Decomposed widgets |
| Phase 3 | 2-3 days | Medium | Clean architecture |
| Phase 4 | 1-2 days | Low | Proper DI |
| Phase 5 | 1 day | Low | Performance optimized |
| **Total** | **9-13 days** | | |

---

## Success Criteria

- [ ] GameProvider < 300 lines (from 2,659)
- [ ] All screen widgets < 200 lines
- [ ] No business logic in build methods
- [ ] All list items have keys
- [ ] All providers use constructor injection
- [ ] Domain layer actively used
- [ ] Unit test coverage > 70%
- [ ] No lint warnings
- [ ] App performance maintained or improved

---

## Notes

- Work on one phase at a time
- Complete all steps in a phase before moving to next
- Keep main branch stable - use feature branches
- Document any deviations from this plan
- Update this document as we learn

**Start with Phase 1: Split GameProvider into focused providers**
