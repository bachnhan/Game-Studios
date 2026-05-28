# CampManager

> **Status**: In Design
> **Author**: Antigravity
> **Last Updated**: May 28, 2026
> **Implements Pillar**: Cozy Road-Trip Adventure, Campfire Connection (Food & Safety)

## Overview

The `CampManager` governs campsite safety, monster recovery, and cooking activities in *Hearth & Horn*. Campsites are special, safe grid tiles placed along wild routes where players can set up temporary camps. Inside the camp, players stoke the fire with wood to keep monsters warm, assign team members to non-combat chores based on their elemental camp roles (Fire-Starter, Water-Purifier, Gatherer, Warder), and combine gathered ingredients to cook fatigue-restoring meals through a timing-based minigame. 

## Player Fantasy

The camp manager delivers the core cozy heart of the game:
*   **Pitching the Tent**: Stepping off the dangerous trail into a quiet clearing and setting up a warm, safe campfire.
*   **Cooking Comfort Food**: Stirring a bubbling cooking pot over the fire, timing the heat perfectly, and serving hot, cozy stews that make your tired monster companions sigh with relief.
*   **Monsters as Helpers**: Watching your monsters help out around the camp—a Fire-type puffing sparks to boil water, or a Grass-type gathering wild herbs from the clearing edges.

## Detailed Design

### Camp Setup and States

1.  **Entering Camp**: The player can only trigger camp setup when standing on a designated Campsite tile on the route. Pressing the interact button locks map movement and transitions the screen to the Camp screen layout.
2.  **The Campfire (Fuel and Safety)**:
    *   The campfire starts with a default fuel gauge.
    *   The player can consume `item_wood` from the `Inventory` to stoke the fire, resetting the fuel gauge.
    *   If the fire runs out of fuel, the camp becomes cold. Fatigue recovers at a reduced rate, and complex cooking recipes fail.
3.  **Chore Board (Monster Utility Assignments)**:
    *   The player can assign their 4 party monsters to active camp chores:
        *   **Fire-Starter** (requires Fire-type or custom role): Decreases recipe cooking time and increases fire burn duration by 20%.
        *   **Water-Purifier** (requires Water-type or custom role): Accelerates HP recovery for resting team members.
        *   **Gatherer** (requires Normal/Grass-type): Slowly generates random raw ingredients (like berries) while camp is active.
        *   **Warder** (requires Warder role): Sets up a protective ward that prevents wild noises from interrupting sleep, maximizing fatigue recovery.
    *   Monsters assigned to chores do not recover fatigue during that time segment, but they gain small amounts of Bond XP.
4.  **Cooking Loop**:
    *   The player selects a recipe from their learned recipe book (e.g., "Cozy Berry Stew").
    *   If the player has the required ingredients, they are deducted from the inventory, and the cooking minigame begins.
    *   *Cooking Minigame*: A simple visual slider sweeps back and forth across a target "sweet spot" zone. The player must press the confirmation key when the slider aligns with the green zone to stir or stoke the pot.
    *   Based on player timing accuracy and monster help, the meal resolves to one of three qualities: Bland Meal, Good Meal, or Cozy Masterpiece.

## Formulas

### Formula 1: Cooking Quality Score
Determines the outcome of a cooking attempt:

`quality_score = base_efficiency * minigame_accuracy`

**Variables:**
| Variable | Symbol | Type | Default Range | Description |
|----------|--------|------|---------------|-------------|
| `base_efficiency` | $E_b$ | float | 0.8–1.2 | Modifier from the assigned helper monster's `work_efficiency`. If no monster is assigned, defaults to 0.8. |
| `minigame_accuracy` | $A_m$ | float | 0.5–1.5 | Score based on player slider timing (0.5 for misses, 1.0 for yellow zone, 1.5 for perfect green zone). |

*   **Quality Tiers**:
    *   `quality_score < 1.0`: **Bland Meal** - Restores 20 fatigue, 10% HP, +2 Bond XP.
    *   `1.0 <= quality_score < 1.4`: **Good Meal** - Restores 50 fatigue, 30% HP, +5 Bond XP.
    *   `quality_score >= 1.4`: **Cozy Masterpiece** - Restores 100 fatigue, 50% HP, +15 Bond XP. Instantly cures the Fainted state.

### Formula 2: Camp Fatigue Recovery
Calculates the fatigue points restored to a monster resting in the tent per time segment:

`fatigue_restored = base_rate * fire_multiplier * ward_multiplier`

**Variables:**
| Variable | Symbol | Type | Default Value | Description |
|----------|--------|------|---------------|-------------|
| `base_rate` | $R_b$ | int | 25 | Base fatigue recovery points per rested segment. |
| `fire_multiplier` | $M_f$ | float | 1.0 or 1.5 | 1.5 if the campfire is active and stoked; 1.0 if the fire has died out. |
| `ward_multiplier` | $M_w$ | float | 1.0 or 1.2 | 1.2 if a monster is assigned to the Warder chore. |

*   **Output Range**: `25` (no fire, no warder) to `45` fatigue restored per segment (fire active + warder present).

## Edge Cases

*   **Cooking with Fainted Monsters**: Fainted monsters (HP == 0) cannot be assigned to camp chores. They must rest in the tent or be fed a *Cozy Masterpiece* to revive them.
*   **Leaving Camp mid-chore**: If the player packs up camp while a Gatherer monster has a partially completed collection timer, the progress is saved. It resumes when the player next pitches camp.
*   **Inventory Full during Gathering**: If the Gatherer monster finds an ingredient but the player's inventory is full, the item is held on a temporary camp shelf. The player is prompted to clear bag space or consume a meal before they can claim it.
*   **Campfire burning out during sleep**: If the player chooses to "Sleep until Morning", the campfire fuel is consumed. If fuel drops to 0 mid-sleep, the recovery rate for the remaining hours is halved.

## Dependencies

### Upstream Dependencies (What this system requires)
*   **`InventorySystem` (Hard Dependency)**:
    *   *Interface*: Queries items (`has_item`), consumes ingredients/wood (`remove_item`), and adds gathered items.
    *   *Purpose*: Restricting cooking and stoking to available resources.
*   **`MonsterData` (Hard Dependency)**:
    *   *Interface*: Reads `camp_role`, `work_efficiency`, and modifies mutable runtime stats (`fatigue`, `current_hp`).
    *   *Purpose*: Allocating chores and writing rested values back to monster instances.

### Downstream Dependents (What requires this system to function)
*   **`BondManager` (Hard Dependency)**:
    *   *Interface*: Adds `bond_xp` to monster instances when they eat or gain chore experience.
    *   *Purpose*: Progression mechanics.
*   **`CampUI` (Hard Dependency)**:
    *   *Interface*: Visual panels, slider meters, and recipe book menus.
    *   *Purpose*: Player interaction layer.
*   **`SaveManager` (Hard Dependency)**:
    *   *Interface*: Persists camp shelf storage and current campfire fuel levels.

## Tuning Knobs

| Knob Name | Default Value | Safe Range | Affected System | Risk / Extreme Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `BASE_RECOVERY_RATE` | `25` | `10 - 50` | `CampManager` | Base fatigue restored. Setting to `50` makes rest too quick, making cooking optional. |
| `CAMP_FIRE_MAX_FUEL` | `120.0` | `30.0 - 300.0` | `CampManager` | Duration of 1 stoke (seconds). Too low forces players to stoke the fire constantly, disrupting gameplay. |

## Visual/Audio Requirements

*   **Visual Assets**:
    *   Campsite screen layout: Top-down or side-profile view of the camp clearing.
    *   Animated campfire with three flame states: Strong (bright orange/red, sparks rising), Weak (low embers), and Dead (cold grey ash pile).
    *   Monsters sitting on cozy sleeping bags, occasionally playing cute idle animations (yawning, sleeping with "Z" bubbles, or looking happy).
    *   Bubble particle effect for the boiling cooking pot.
*   **Audio Assets**:
    *   Comforting acoustic camping background theme.
    *   Campfire crackling and popping sounds (scale in volume with fire fuel levels).
    *   Bubbling liquid loop for the cooking pot.
    *   Chime sound when a meal is cooked successfully.

## UI Requirements

*   **Camp Dashboard Overlay**:
    *   Displays current Campfire Fuel slider bar at the top of the screen.
    *   Chore board panel with drag-and-drop slots for monsters.
    *   "Enter Tent" (rest) and "Cook Pot" buttons.
*   **Cooking Menu**:
    *   Displays a list of recipes. Icons display ingredient availability (e.g. Green checkmark if player has enough Cozy Berries, red X if missing).
*   **Minigame Overlay**:
    *   A slider bar that appears when cooking starts. A sweeping line moves left-to-right, with a green marker representing the perfect timing window.

## Acceptance Criteria

*   **Transition to Camp**: GIVEN a player on a campsite tile, WHEN pressing the interaction key, THEN the exploration scene fades out and the Camp layout renders with player controls locked.
*   **Stoking the Fire**: GIVEN a stoked campfire fuel level of 40%, WHEN the player consumes 1 wood, THEN the wood is deducted from the inventory, and the campfire fuel level resets to exactly 100%.
*   **Meal Quality Evaluation**: GIVEN a cooking minigame, WHEN the player hits the sweet spot for a total `minigame_accuracy = 1.5` with a helper monster of efficiency `base_efficiency = 1.0`, THEN the cooked item resolves to a `"Cozy Masterpiece"`.
*   **Recovery Calculation**: GIVEN a resting monster with fatigue 100, WHEN resting for 2 segments with a stoked campfire and no warder, THEN the monster recovers $2 \times (25 \times 1.5) = 75$ fatigue points, lowering fatigue to 25.

## Open Questions

*   **Camp Attacks**: Can wild monsters attack the camp?
    *   *Answer for MVP*: No. To maintain the anti-pillar of "No Stressful Survival," campsites are absolute safe zones. Wards simply speed up sleep recovery rather than protecting against physical damage.
*   **Cooking Failures**: Can cooking burn the food entirely?
    *   *Answer for MVP*: No. The worst result is a "Bland Meal," which still restores minor fatigue. There is no complete waste of ingredients to keep the loop rewarding.
