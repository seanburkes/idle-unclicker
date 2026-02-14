# Change: Setup Widgetbook with Atomic Design Phases

## Why

The codebase lacks a component documentation system and has no reusable widget library. All UI patterns are duplicated inline across 15 screens. This makes it difficult to:
- Develop new UI in isolation
- Document existing components
- Maintain visual consistency
- Test edge cases

Widgetbook provides a sandbox for building and documenting widgets in isolation, inspired by Storybook.js.

## What Changes

### Phase 1: Atoms
- Add `widgetbook` dependency to pubspec.yaml
- Create `lib/presentation/widgets/atoms/` directory
- Implement basic UI primitives: buttons, text styles, icons, badges, progress bars, stat chips

### Phase 2: Molecules
- Create `lib/presentation/widgets/molecules/` directory
- Extract reusable composables: card containers, stat rows, section headers, item rows, toggle switches

### Phase 3: Organisms
- Create `lib/presentation/widgets/organisms/` directory
- Assemble feature sections: inventory panel, combat stats, character header, resource bars

### Phase 4: Screens
- Create `lib/presentation/widgets/screens/` directory
- Document full screen shells in Widgetbook

## Impact

- Affected specs: UI component library
- Affected code: New directories under `lib/presentation/widgets/`
- Dependencies added: `widgetbook` (dev)
