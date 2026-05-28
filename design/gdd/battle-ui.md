# BattleUI

> **Status**: In Design
> **Author**: Antigravity
> **Last Updated**: May 28, 2026
> **Implements Pillar**: Playful Stance Battles

## Overview

The `BattleUI` manages the visual overlay, controls, menus, and feedback indicators during turn-based combat in *Hearth & Horn*. Designed to fit the GBA pixel-art aesthetic while maintaining modern usability standards, the interface presents the 2v2 battlefield, tracks health, renders shared Action Point (AP) gauges, and displays stance selection wheels. It also handles predictive alerts (hints about enemy stances) and floating impact typography (`"BLOCKED!"`, `"COUNTERED!"`) to guide the player's prediction choices.

## Player Fantasy

The battle interface supports the cozy tactical aesthetic of the combat system:
*   **Tactile Retro Menus**: Snappy, clicky GBA-style menus with rounded frames, wooden/earthy color borders, and clear icons.
*   **Predictive Clarity**: Seeing clear indicators on enemy cards that suggest their active stances, making it satisfying to select the counter-move.
*   **Exciting Impact Feedback**: Retro-styled text bouncing off monsters when they block attacks or execute high-damage stance counters.

## Detailed Design

### Layout Zones (2v2 Arena Grid)

To support web browser scalability across different screens, the interface is built using Godot's control container hierarchy (`Control` > `MarginContainer` > `VBoxContainer`/`HBoxContainer` with proper anchor settings).

```
+-------------------------------------------------------------+
|  [Enemy Mon B Status]                 [Enemy Mon A Status]  |
|  (HP Bar / Stance Icon)               (HP Bar / Stance Icon)  |
|                                                             |
|           [Enemy B Sprite]      [Enemy A Sprite]            |
|                                                             |
|     [Player A Sprite]       [Player B Sprite]               |
|                                                             |
|  [Player A Status]                    [Player B Status]     |
|  (HP Bar / Stance Icon)               (HP Bar / Stance Icon)  |
+-------------------------------------------------------------+
|  [AP Crystal Gauge:  o  o  o  x  x ]                         |
|  +-------------------------------------------------------+  |
|  | Dialogue Log: "Sprout is planning..."                 |  |
|  | [Fight] [Party] [Run]                                 |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

1.  **Arena Viewport (Upper 70%)**: Renders the 2D pixel-art monster sprites and battle backdrop.
2.  **Status Plates (Floating)**:
    *   Placed near the feet or heads of the active monsters.
    *   Displays: Name, level, health bar, and active stance badge.
3.  **Shared Action Panel (Lower 30%)**:
    *   **AP Crystal Bar**: Displays shared round Action Points as a row of glowing crystals.
    *   **Dialogue & Option Box**: Shows textual combat log descriptions (e.g. `"Choose Sprout's action..."`) and provides control buttons: `Fight`, `Party` (Swap), and `Run` (Escape).

### Action Phase Selection Flow

During the Planning Phase, the player configures actions:
1.  **Select Monster**: Player clicks Active Mon 1 (or it auto-selects if it is the first turn).
2.  **Stance Selection Wheel**: Renders a pop-up wheel around the monster or a grid in the action panel displaying up to 4 moves:
    *   Each move displays its Name, AP Cost (1 or 2 icons), and Stance type badge:
        *   **Brute**: Crossed swords icon.
        *   **Block**: Wooden shield icon.
        *   **Counter-Block**: Target eye/crosshair icon.
3.  **Target Selection**: Reticle indicators appear over eligible targets.
4.  **Confirm Phase**: Once all AP is allocated (or player confirms early), the player clicks the confirmation button, initiating the action resolution.

### Feedback Popups and Screen Shake

To make combat feel impact-driven and satisfying:
*   **Stance Popups**: Floating, bouncy pixel-art text displays over the target sprite:
    *   `"BLOCKED!"`: Bounces down in blue text, squishing the text slightly.
    *   `"COUNTERED!"`: Expansion/pulse animation in neon yellow.
    *   `"MISS!"`: Slides slowly upwards in grey text.
*   **Health Bar Tweens**: Damage does not instantly cut the health bar. The green/yellow bar drains smoothly using a Godot `Tween`, while a red "damage backing" bar slowly catches up to emphasize the hit weight.
*   **Low Health Alert**: When a monster's HP drops below 20%, its health bar shifts to flashing red, and the status plate border glows.

## Formulas

### Formula 1: HP Bar Width Interpolation
Calculates the UI health bar fill value:

`bar_fill = current_hp / base_hp`

*   **UI Tween**: `create_tween().tween_property(hp_bar, "value", bar_fill, HP_BAR_TWEEN_DURATION)`
*   **Variables**:
    *   `HP_BAR_TWEEN_DURATION`: Default 0.5 seconds.

### Formula 2: AP Cost Preview Flash
When the player hovers over a move costing $C_{move}$ Action Points, the UI flashes the crystals to show estimated consumption:

`preview_index_start = current_ap - C_move`

*   **UI Effect**: Crystals from index `preview_index_start` to `current_ap - 1` flash in red, while the remaining crystals (from `0` to `preview_index_start - 1`) remain glowing green.

## Edge Cases

*   **Browser Scaling**: On extremely wide or tall browser screens, the battle screen preserves its 4:3 or 16:9 pixel aspect ratio using a Godot `SubViewportContainer` set to `Stretch` mode, avoiding stretched/blurred pixels.
*   **Targeting Fainted Opponents**: If a player selects a target that faints due to a faster monster's strike earlier in the Action Phase, the target reticle redirects to the remaining active opponent. The UI updates the target nameplate dynamically.
*   **Chosing Moves under status effects**: If a monster is put to sleep mid-turn, its status plate immediately overlays a grey `"Sleeping"` tag, and its action icons in the wheel lock out.

## Dependencies

### Upstream Dependencies (What this system requires)
*   **`BattleEngine` (Hard Dependency)**:
    *   *Interface*: Receives move confirmations, queries active AP budgets, and reads HP values.
    *   *Purpose*: Feeding player input actions into the math engine and displaying engine states.
*   **`MonsterData` (Hard Dependency)**:
    *   *Interface*: Reads monster sprite sheets, move lists, and names.
    *   *Purpose*: Populating nameplates and move wheels.

### Downstream Dependents (What requires this system to function)
*   **None**: Presentational layer.

## Tuning Knobs

| Knob Name | Default Value | Safe Range | Affected System | Risk / Extreme Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `HP_BAR_TWEEN_DURATION` | `0.5` | `0.1 - 1.5` | `BattleUI` | Duration of health bar drain animation. Too high makes multi-hit resolutions look lagged. |
| `LOW_HP_THRESHOLD` | `0.20` | `0.10 - 0.35` | `BattleUI` | HP ratio to trigger low-health warning styles. |

## Visual/Audio Requirements

*   **Visual Assets**:
    *   Pixel-art UI borders: Cozy wood grain texture with dark brown `#3C2010` borders.
    *   AP crystals: Red glowing diamonds.
    *   Stance badges: 16x16 pixel icons (Shield, Swords, Eye).
    *   Impact texts: `"BLOCKED!"`, `"COUNTERED!"`, `"MISS!"`, `"CRITICAL!"` custom pixel font sheets.
*   **Audio Assets**:
    *   Click sound: A snappy wooden button click.
    *   Select Move: Short chiptune chime.
    *   Error/No AP: Low wooden knock sound.
    *   Confirm Turn: Short, energetic retro drum roll.

## UI Requirements

*   **Move Wheel / Panel**:
    *   A grid of 4 buttons mapped to hotkeys `1`, `2`, `3`, `4` (matching GBA emulator standard buttons).
    *   Each slot displays: Move Name, Stance Icon, AP cost (represented as small cost diamonds).
*   **Stance Cues**:
    *   Enemy status plates contain a small, glowing question mark icon.
    *   Hovering over an enemy showing a defensive physical pose updates the status plate to show a fading shield icon (fading opacity based on `STANCE_ALERT_OPACITY` knob), hinting at their Block choice.

## Acceptance Criteria

*   **Container Scaling**: GIVEN a browser window resize from 800x600 to 1920x1080, WHEN rendering the battle interface, THEN the UI scales proportionally using Godot's aspect ratio containers without stretching pixel ratios.
*   **AP Crystal Cost Preview**: GIVEN the player has 4 AP, WHEN hovering over a 2-AP Move, THEN the last 2 AP crystals in the bar flash red.
*   **Smooth HP Bar Drain**: GIVEN a monster with 100 HP, WHEN hit by a move dealing 50 damage, THEN the health bar value drains from 1.0 to 0.5 smoothly over exactly $0.5$ seconds.
*   **Feedback Popup**: GIVEN a Blocked event, WHEN the action executes, THEN the text label `"BLOCKED!"` is spawned above the target, animating upwards before fading out.
*   **Stance Icon Update**: GIVEN Active Mon 1 selects a Block move and Active Mon 2 selects a Brute move, WHEN targets are confirmed, THEN the status plates for Mon 1 and Mon 2 update to show the Shield and Sword icons respectively.

## Open Questions

*   **Move Hotkeys**: Should we support keyboard mappings for quick selections?
    *   *Answer for MVP*: Yes, moves 1–4 are mapped to numbers `1`–`4` to facilitate quick testing in emulator setups.
*   **Move Animations**: Do monsters play complex spell animations?
    *   *Answer for MVP*: No, monsters play basic physical translation shifts (sliding forward to strike, jumping up for ledges) accompanied by screen flash or simple particle effects to keep the scope clean.
