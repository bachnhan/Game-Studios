# UX Spec: Pause / Party Menu

> **Status**: Approved (Lean Mode)
> **Author**: Antigravity
> **Last Updated**: May 28, 2026

## 1. Overview

The `PauseMenu` (triggered by pressing **Space**) freezes exploration gameplay and opens a multi-tab overlay panel. It allows the player to review their monster party details, inspect companion stats/talents, re-order deployment slots (shifting who battles first), and save progress using the `SaveManager`.

---

## 2. Layout & Tabs

The menu features a retro tabbed index at the top, navigated using the D-Pad/Arrow Keys or selection highlights:

```
+-------------------------------------------------------------+
|  [ PARTY ]          [ BAG ]          [ SAVE ]               |
|  +--------------------+   +-------------------------------+  |
|  | Slot 1: Sprout     |   | Companion Details             |  |
|  | HP: 50/50  Fatg: 0%|   | [Monster Sprite]              |  |
|  +--------------------+   | Element: Grass    Speed: 2 AP |  |
|  | Slot 2: Ember      |   | Attack: 40        Defense: 35 |  |
|  | HP: 45/45  Fatg: 10%|  |                               |  |
|  +--------------------+   | Signature: Kindle             |  |
|  | Slot 3: Empty      |   | Plus: Iron Guard              |  |
|  +--------------------+   +-------------------------------+  |
|  [Shift Position (Z)]                       Press X to Close|
+-------------------------------------------------------------+
```

---

## 3. Tab Interactions

### Tab 1: Party (Manage Companions)
*   **Active List (Left Side)**:
    *   Displays 4 vertical slots.
    *   Each filled slot shows: portrait, Name, HP bar, Fatigue value (%), and Bond Level (0-5).
*   **Companion Details Card (Right Side)**:
    *   Populates details of the selected slot: Large sprite, elemental badge, base speed (AP count), attack, defense, and signature/plus talent tooltips.
*   **Re-ordering (Shift Position)**:
    *   Pressing **Z** (Button A) on a monster slot marks it for swapping (border turns green).
    *   The player navigates to another slot and presses **Z** again to swap position.
    *   *Gameplay Impact*: The monsters in slots 1 and 2 are automatically deployed in combat; re-ordering shifts who fights first.

### Tab 2: Bag (Backpack Shortcut)
*   Instantly opens the modal backpack screen (see [Core Gameplay HUD](file:///Users/cation/Game-Studios/design/ux/core-gameplay-hud.md)).

### Tab 3: Save (Record Progress)
*   Displays a confirmation box: `"Record your trip?"`
*   Selecting **Save Game** calls `SaveManager.save_game()`. Renders a dialog bubble: `"Trip recorded successfully!"` accompanied by a cozy retro chime.
*   Selecting **Return to Title** prompts for verification before fading to black and loading the main menu.

---

## 4. UI Transitions & Audio

*   **Pause Screen**: Slides in from the left over 0.2 seconds. Exploration music drops in volume (muffled low-pass filter effect).
*   **Unpause Screen**: Slides back left. Exploration music returns to normal volume.
*   **Save Chime**: A light, cozy 16-bit harp arpeggio plays upon successful saves.
