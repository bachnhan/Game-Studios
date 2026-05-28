# Smoke Test: Critical Paths

**Purpose**: Run these checks before any QA hand-off or release milestone.
**Run via**: `/smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Game launches to main menu without crash.
2. New game / session can be started from the main menu.
3. Main menu responds to all inputs without freezing.

## Core Mechanic (Sprint 01 Focus)

4. Monster resource data can be generated dynamically from templates at runtime without mutating base values (`MonsterData` duplication check).
5. Inventory containers successfully stack and split item resources (`InventorySystem`).
6. Grid movement handles cardinal tile transitions and detects collisions correctly (`GridMovement`).

## Data Integrity

7. Save game completes without error (ConfigFile saved to disk).
8. Load game restores player position, inventory, and companion health.

## Performance

9. No visible frame rate drops on target hardware (60fps target).
10. No memory leaks or growth over 5 minutes of active movement/combat.
