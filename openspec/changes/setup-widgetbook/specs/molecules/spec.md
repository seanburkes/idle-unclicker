## ADDED Requirements

### Requirement: Game Card Container
The system SHALL provide a reusable bordered container with consistent styling for game UI sections.

#### Scenario: Bordered card
- **WHEN** a game card container is rendered
- **THEN** it displays with a border, border radius, and optional background color

### Requirement: Stat Row
The system SHALL provide a reusable row layout for displaying stat name, value, and modifier.

#### Scenario: Single stat row
- **WHEN** a stat row is rendered
- **THEN** it displays the stat label, current value, and any modifier with appropriate colors

#### Scenario: Multiple stat row
- **WHEN** multiple stats are rendered in a row
- **THEN** they display horizontally with consistent spacing

### Requirement: Section Header
The system SHALL provide a reusable section title component.

#### Scenario: Standard section
- **WHEN** a section header is rendered
- **THEN** it displays with uppercase text, color, and appropriate margin

### Requirement: Item Row
The system SHALL provide a reusable row for displaying inventory items or list entries.

#### Scenario: Inventory item row
- **WHEN** an item row is rendered
- **THEN** it displays the icon, name/description, and optional count badge

### Requirement: Toggle Switch
The system SHALL provide a styled toggle for auto-features and settings.

#### Scenario: Auto-feature toggle
- **WHEN** a toggle switch is rendered for an auto-feature
- **THEN** it displays with appropriate color and label
