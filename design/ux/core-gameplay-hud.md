# UX Spec: Core Gameplay HUD

> **Status**: Approved (Lean Mode)
> **Author**: Antigravity
> **Last Updated**: May 28, 2026

## 1. Overview

The `CoreGameplayHUD` manages the overlay screens, widgets, and modal panels shown while the player is exploring routes and towns on the 2D grid. It contains the primary exploration layout (stamina/fatigue indicators, interaction prompts) and handles the pop-up backpack grid panel (20 items slot display, tooltips, and sorting actions).

---

## 2. Exploration Layout (Route HUD)

```
+-------------------------------------------------------------+
| [Mon Portrait] Sprout                                       |
| HP: [====] 50/50  Fatigue: [===] 12%                        |
|                                                             |
|                                                             |
|                           [Player]                          |
|                                                             |
|                         (Campsite Tile)                     |
|                           [A: Camp]                         |
|                                                             |
|                                                             |
|                                             [Shift] Backpack|
+-------------------------------------------------------------+
```

*   **Leader Status Widget (Top-Left)**:
    *   Displays the lead active monster's name and portrait.
    *   Health bar: Green color, transitions to yellow (< 50%) then red (< 20%).
    *   Fatigue bar: Green color, turns orange (>= 50%), red (>= 80%).
*   **Interaction Prompt (Center-Above Player)**:
    *   A small speech bubble pointing down to the character.
    *   Appears when the player coordinates are on a Campsite tile (renders `[A] Camp`) or facing a chest/NPC (renders `[A] Talk`).
*   **Shortcut Tag (Bottom-Right)**:
    *   Faded prompt showing button reminder: `[Shift] Backpack`.

---

## 3. Backpack Inventory Modal

Triggered by pressing **Shift** (or selecting Backpack in the pause menu). Exploration movement freezes, and the grid backpack overlay slides down from the top.

```
+-------------------------------------------------------------+
|  BACKPACK                    [Sort: Shift]                  |
|  +----+ +----+ +----+ +----+                                |
|  | O1 | | O2 | | O3 | |    |     Selected Item Details      |
|  | x12| | x1 | | x5 | |    |     +-----------------------+  |
|  +----+ +----+ +----+ +----+     | [Item Sprite]         |  |
|  +----+ +----+ +----+ +----+     | Cozy Berry (Ingredient)|  |
|  |    | |    | |    | |    |     | Weight: 0.1 kg        |  |
|  +----+ +----+ +----+ +----+     | "A warm, sweet berry."|  |
|  +----+ +----+ +----+ +----+     |                       |  |
|  |    | |    | |    | |    |     |   [Use]  [Discard]    |  |
|  +----+ +----+ +----+ +----+     +-----------------------+  |
|  (20 Slots Grid: 4 x 5)                                     |
+-------------------------------------------------------------+
```

### Grid Panel (Left Side)
*   Pre-allocated 4x5 grid of round-cornered slots.
*   Occupied slots display item icons and a text count (e.g., `x12`) in the bottom-right.
*   Focus selector moves from cell to cell using arrow keys, playing a snappy cursor tick.

### Item Details Panel (Right Side)
*   Populates details of the focused cell:
    *   Large sprite icon.
    *   Display Name.
    *   Category badge (color coded: Green for Ingredient, Orange for Fuel, Purple for Utility).
    *   Weight value (e.g. `0.1 kg`).
    *   Description.
*   **Context Actions**:
    *   `Use` (Consumables): consumes 1 item, restores HP/Fatigue, updates count.
    *   `Discard`: opens a confirmation prompt `"Discard this item?"` to permanently delete it.

---

## 4. UI Transitions & Audio

*   **Open Bag**: Slides down from the top over 0.25 seconds. Plays a canvas bag rustle sound.
*   **Close Bag**: Slides back up. Plays a soft snap zipper sound.
*   **Sorting**: Pressing **Shift** (or clicking Sort button) triggers stack consolidation. Slot items flash white briefly, and a satisfying click/rustle sound plays.
