## ADDED Requirements

### Requirement: Game Button Variants
The system SHALL provide reusable button components matching the game's UI theme.

#### Scenario: Primary button
- **WHEN** a primary action button is rendered
- **THEN** it displays with black background, colored border, and appropriate text

#### Scenario: Secondary button
- **WHEN** a secondary action button is rendered
- **THEN** it displays as a text button with minimal styling

#### Scenario: Icon button
- **WHEN** an icon-only button is rendered
- **THEN** it displays as a tappable icon with hover/press feedback

### Requirement: Game Text Styles
The system SHALL provide consistent text styling for section headers, stat labels, and body text.

#### Scenario: Section header
- **WHEN** a section header is rendered
- **THEN** it displays with uppercase text, colored text (e.g., green), bold weight, and appropriate font size

#### Scenario: Stat label
- **WHEN** a stat label is rendered
- **THEN** it displays with smaller font, muted color, and consistent spacing

### Requirement: Stat Chips and Badges
The system SHALL provide visual indicators for stats, resources, and inventory counts.

#### Scenario: Stat chip with value
- **WHEN** a stat chip is rendered with a numeric value
- **THEN** it displays the stat name and value with appropriate color coding

#### Scenario: Count badge
- **WHEN** an inventory count badge is rendered
- **THEN** it displays as a small overlay showing the quantity

### Requirement: Progress Indicators
The system SHALL provide styled progress bars for health, mana, experience, and timers.

#### Scenario: Health bar
- **WHEN** a health bar is rendered
- **THEN** it displays with red fill and appropriate styling

#### Scenario: Experience bar
- **WHEN** an experience bar is rendered
- **THEN** it displays with blue/green gradient fill

### Requirement: Game Icons
The system SHALL provide consistent iconography for common game elements.

#### Scenario: Resource icon
- **WHEN** a resource icon (gold, gems, etc.) is rendered
- **THEN** it displays with the appropriate color and size
