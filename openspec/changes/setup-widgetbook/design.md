## Context

This design covers setting up Widgetbook for Flutter component documentation and development. The goal is to create a reusable widget library organized using Atomic Design principles (atoms, molecules, organisms, screens).

## Goals / Non-Goals

### Goals
- Add Widgetbook as a development tool for building widgets in isolation
- Create reusable widget components following Atomic Design
- Document all UI components with stories for development and QA
- Establish consistent UI patterns across the codebase

### Non-Goals
- Refactoring existing screen implementations (atoms/molecules will wrap existing patterns, not replace)
- Adding widgetbook_annotation code generation (manual registration is simpler for initial setup)
- Creating a full design system with design tokens (future work)
- Widgetbook Cloud integration (future work)

## Decisions

### Decision: Use widgetbook without code generation
- **Rationale**: Simpler setup, fewer build_runner dependencies, faster iteration
- **Alternative**: Use widgetbook_annotation with build_runner for automatic story registration

### Decision: Mirror folder structure in Widgetbook
- **Rationale**: Easy to locate widgets in both code and documentation
- **Structure**: atoms/, molecules/, organisms/, screens/ matching lib/presentation/widgets/

### Decision: Manual story registration
- **Rationale**: More explicit, easier to understand, less magic
- **Alternative**: Use WidgetbookGenerator for automatic discovery

### Decision: Create widgets that can coexist with inline implementations
- **Rationale**: Allows incremental adoption without massive refactoring
- **Strategy**: New components use the widget library; existing screens can migrate gradually

## Folder Structure

```
lib/presentation/widgets/
├── atoms/
│   ├── game_button.dart
│   ├── game_text_styles.dart
│   ├── stat_chip.dart
│   ├── count_badge.dart
│   ├── game_progress_bar.dart
│   └── game_icon.dart
├── molecules/
│   ├── game_card.dart
│   ├── stat_row.dart
│   ├── section_header.dart
│   ├── item_row.dart
│   └── game_toggle.dart
├── organisms/
│   ├── inventory_panel.dart
│   ├── item_grid.dart
│   ├── combat_stats_panel.dart
│   ├── character_header.dart
│   ├── resource_bar_group.dart
│   └── action_panel.dart
└── screens/
    ├── dashboard_shell.dart
    ├── alchemy_shell.dart
    └── skill_tree_shell.dart
```

## Widgetbook Entry Point

Create `lib/widgetbook.dart` with WidgetbookApp configuration:
- Theme addon for dark mode toggle
- Device frame addon for mobile preview
- Categorized widget directories

## Migration Strategy

1. **Phase 1**: Add Widgetbook dependency, create entry point, add atoms
2. **Phase 2**: Add molecules that use atoms
3. **Phase 3**: Add organisms that use molecules
4. **Phase 4**: Document screens in Widgetbook

Each phase builds on previous - no large bang refactoring.

## Risks / Trade-offs

- **Risk**: Widget library diverges from existing inline implementations
  - **Mitigation**: Extract from existing patterns, maintain visual parity

- **Risk**: Maintenance burden of keeping stories in sync
  - **Mitigation**: Start with essential components only, expand as needed

- **Trade-off**: Manual story registration vs automatic
  - **Decision**: Manual is simpler and more explicit for initial setup

## Open Questions

- Should we use widgetbook_annotation for code generation in future?
- Should we create a shared theme file for the game colors?
- Should Widgetbook stories live alongside widgets or in a separate directory?
