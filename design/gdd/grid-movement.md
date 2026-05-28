# GridMovement

> **Status**: In Design
> **Author**: Antigravity
> **Last Updated**: May 28, 2026
> **Implements Pillar**: Cozy Road-Trip Adventure

## Overview

The `GridMovement` system handles player navigation across route and town maps. Designed to evoke the classic nostalgic feel of GBA top-down adventure games, it forces the player character to align strictly to a 2D tile grid. Moving the directional controls slides the player smoothly from tile to tile, checking cell collision layer data to prevent walking through obstacles. It also coordinates transition triggers such as entering tall grass (encounter checks), stepping onto campsites (camp pitching), jumping down ledges (one-way barriers), and colliding with field obstructions.

## Player Fantasy

The grid movement system supports the relaxed, deliberate pacing of a walking tour:
*   **Tactile GBA Movement**: Bumping into trees, hopping down ledges, and walking along dirt paths with responsive, clean grid-aligned steps.
*   **Careful Exploration**: Walking cautiously through rustling tall grass, knowing that every step counts, and searching for the perfect cozy clearing to set up a campfire.
*   **Nostalgic Interaction**: Simply stepping up to signposts, item pouches, or fellow travelers and clicking to interact, feeling like a classic adventure game protagonist.

## Detailed Design

### Core Rules & Properties

Movement in the game world is managed by a character scene containing a `Sprite2D`, `AnimationPlayer`, and a custom controller script (`class_name GridPlayer extends CharacterBody2D` or simple `Node2D` — because we use grid-based path translation, a direct `Node2D` using tweens or custom physics step integration is preferred over complex CharacterBody2D physics vectors).

Map coordinates are defined on a grid index using `Vector2i`. The maps themselves are constructed using Godot 4.6’s `TileMapLayer` nodes.

#### Grid Positioning Variables
*   `grid_position`: Vector2i - The current tile coordinates on the map (e.g., `Vector2i(10, 15)`).
*   `target_position`: Vector2i - The destination coordinate while moving.
*   `facing_direction`: Vector2i - One of the cardinal unit vectors representing the player's look direction:
    *   `Vector2i(0, 1)` (DOWN)
    *   `Vector2i(0, -1)` (UP)
    *   `Vector2i(-1, 0)` (LEFT)
    *   `Vector2i(1, 0)` (RIGHT)
*   `is_moving`: bool - Tracks if the character is currently sliding between tiles.
*   `move_percent`: float - Transition progress range `0.0` to `1.0`.

#### Grid Movement State Machine

The player's movement operates in five distinct states:

| State | Description | Transitions To |
| :--- | :--- | :--- |
| **Idle** | Standing still. Awaiting input. | `Turning`, `Moving`, `Interacting` |
| **Turning** | Player tapped a direction briefly. They rotate in place without changing cells. | `Idle`, `Moving` |
| **Moving** | Player is sliding smoothly between `grid_position` and `target_position`. | `Idle` (if input is released), `Moving` (if input is held) |
| **Blocked** | Player attempted to walk into an obstacle. Plays bump visual/sound. | `Idle` |
| **Interacting** | Movement input is disabled during dialogs, battles, or cooking. | `Idle` (once interaction concludes) |

#### Input Buffering and In-Place Turning
To replicate the responsive movement of GBA-era games:
1.  **Tap to Turn**: If the player taps a direction key for less than `TURN_TAP_THRESHOLD` (e.g., 0.1 seconds), the character shifts their `facing_direction` and updates their animation sprite, but remains on the same grid cell.
2.  **Hold to Run/Walk**: If the input is held past the threshold, the player moves into the adjacent tile.
3.  **Input Buffering**: If the player presses a new directional key during the final 20% of a tile transition (`move_percent >= 0.8`), that input is queued. When the player reaches the destination tile, they immediately transition into the next movement cycle without stopping, avoiding stutter.

#### Collision and Tile Checks
Before entering a tile, the movement controller queries the `TileMapLayer` at the `target_position`:
1.  **Custom Data Layers**:
    *   `walkable` (Boolean): If `false`, the move is cancelled, transitioning the player to the `Blocked` state.
    *   `terrain_type` (String): Values include `"Grass"`, `"Dirt"`, `"Campsite"`, `"Ledge"`.
2.  **Ledge Rules**: If the tile contains a Ledge in the matching direction, the player executes a "Ledge Hop" animation:
    *   Forces the player 2 tiles forward in the direction of the ledge.
    *   Plays a parabolic height bounce animation.
    *   Bypasses normal collision for that 2-tile leap.
    *   This is a one-way path; the player cannot walk back up the ledge.

## Formulas

### Formula 1: Walk Slide Interpolation
The screen coordinates of the player during movement are calculated as:

`pixel_position = (grid_position * TILE_SIZE) + (direction * TILE_SIZE * move_percent)`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `TILE_SIZE` | $S$ | int | 16 or 32 | The pixel size of a grid tile (default: 16). |
| `move_percent` | $P$ | float | 0.0–1.0 | Progress of the current tile transition. |
| `direction` | $D$ | Vector2 | Unit Vector | Direction of travel. |

*   **Slide Time**: The duration of one step is:  
    `step_duration = TILE_SIZE / MOVE_SPEED` (e.g., $16 \text{ px} / 64 \text{ px/sec} = 0.25 \text{ seconds}$).

### Formula 2: Cozy Tall Grass Encounter Rate
To prevent frustrating back-to-back encounters, the combat spawn system uses a progressive step protection curve:

If `steps_in_grass < MIN_SAFE_STEPS`:  
`encounter_chance = 0.0`

If `steps_in_grass >= MIN_SAFE_STEPS`:  
`encounter_chance = clamp((steps_in_grass - MIN_SAFE_STEPS) * ENCOUNTER_ACCUMULATOR, 0.0, MAX_ENCOUNTER_CHANCE)`

**Variables:**
| Variable | Symbol | Type | Default Value | Description |
|----------|--------|------|---------------|-------------|
| `steps_in_grass` | $N_g$ | int | Variable | The number of consecutive steps taken in grass tiles. |
| `MIN_SAFE_STEPS` | $S_s$ | int | 5 | Safe buffer before encounters can trigger. |
| `ENCOUNTER_ACCUMULATOR`| $A_e$ | float | 0.05 | Rate at which probability increases per step. |
| `MAX_ENCOUNTER_CHANCE` | $C_m$ | float | 0.35 | The capped maximum encounter rate (35%). |

*   **Example**: After 8 steps in grass ($N_g = 8$, $S_s = 5$):  
    `encounter_chance = (8 - 5) * 0.05 = 3 * 0.05 = 15%` chance.  
    A random float `randf()` is rolled against `0.15`. If the roll triggers, a battle begins. The counter resets to `0` upon battle start or when leaving the grass.

## Edge Cases

*   **Triggering battle mid-step**: If a wild encounter triggers on a grass tile, the player character must complete their slide to the target tile (`move_percent = 1.0`, updating `grid_position` to `target_position`) before the screen transitions to the battle layout, preventing the character from getting stuck between tiles.
*   **Menu opening while moving**: If the player opens a pause menu while sliding, the input is locked, but the slide completes to the target tile, and then the character stands idle.
*   **Collision with moving NPCs**: If an NPC moves into the target tile at the exact moment the player initiates movement, the collision check resolves at step start. If they overlap due to simultaneous moves, the player’s slide takes precedence and the NPC is pushed back or pauses.
*   **Boundaries of the Map**: If the player attempts to walk off the edge of the tilemap grid boundary, the cell is read as null and defaults to `walkable = false`, causing a Blocked bump.

## Dependencies

### Upstream Dependencies (What this system requires)
*   **None**: As a core navigation system, this is self-contained.

### Downstream Dependents (What requires this system to function)
*   **`BattleEngine` (Hard Dependency)**:
    *   *Interface*: Receives trigger events (`trigger_wild_encounter`).
    *   *Purpose*: Initiates stance combat when an encounter check succeeds.
*   **`CampManager` (Hard Dependency)**:
    *   *Interface*: Read access to player position and cell type.
    *   *Purpose*: Unlocks the "Pitch Tent" menu interaction when `grid_position` sits on a tile tagged as a `"Campsite"`.
*   **`SaveManager` (Hard Dependency)**:
    *   *Interface*: Read and write access.
    *   *Purpose*: Saves/loads the player's coordinate `grid_position` and direction vector on route maps.
*   **`FieldHazards` (Hard Dependency)**:
    *   *Interface*: Intercepts movement input checks.
    *   *Purpose*: Prevents grid transitions if the target tile contains an uncleared road obstacle, prompting interaction.

## Tuning Knobs

| Knob Name | Default Value | Safe Range | Affected System | Risk / Extreme Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `TILE_SIZE` | `16` | `8 - 64` | `GridMovement`, `ArtAssets` | Adjusting this requires changing all tile graphic layouts. Must match sprite art grid. |
| `MOVE_SPEED` | `64.0` | `32.0 - 128.0` | `GridMovement`, `Animations` | Setting it too fast makes movement look glitchy/teleporty; too slow makes exploration feel tedious. |
| `MIN_SAFE_STEPS` | `5` | `0 - 15` | `GridMovement` | Safe padding in grass. Too high makes wild battles rare, making route traversal boring. |
| `ENCOUNTER_ACCUMULATOR`| `0.05` | `0.01 - 0.20` | `GridMovement` | The speed at which encounter chance grows. Set to `0.20` causes almost instant battles after safety steps. |
| `MAX_ENCOUNTER_CHANCE` | `0.35` | `0.10 - 0.80` | `GridMovement` | Maximum roll cap. Setting to `0.80` makes traversing grass highly disruptive. |
| `TURN_TAP_THRESHOLD` | `0.10` | `0.05 - 0.20` | `GridMovement` | Duration window to recognize a tap turn vs. a step. Too high causes delay when starting to walk. |

## Visual/Audio Requirements

*   **Visual Assets**:
    *   Character sprite sheet: 4 directions (Up, Down, Left, Right), 3 frames of walking animation per direction (Left foot, Idle, Right foot).
    *   Character sprite outlines must use cozy dark brown `#3C2010` outlines.
    *   Dust cloud particle effect (puffing at feet when starting a walk, running, or landing a ledge jump).
    *   Ledge jump animation curve: scales the sprite up and offsets its Y-position upwards in a quadratic arc before landing.
*   **Audio Assets**:
    *   Cardinally varied footstep sounds (soft "rustle" on tall grass, clicky "crunch" on dirt, solid "thump" on wood).
    *   "Bump" sound effect: quiet wooden knock sound when hitting blocking tiles.
    *   "Ledge jump" sound effect: short, cartoonish "boing" or wind swoosh.

## UI Requirements

*   **Interaction Prompts**:
    *   Displays a small pixel-art speech bubble or button indicator (e.g., a green bubble showing `[A]`) above the player's head when facing an interactable entity or campsite tile.
*   **Encounter Transition Effect**:
    *   A nostalgic, retro diagonal screen wipe, screen block spiral, or screen flash before launching the battle layout.

## Acceptance Criteria

*   **Cardinal Translation**: GIVEN a player character idle at `grid_position = Vector2i(0, 0)`, WHEN the player holds `Right` past `TURN_TAP_THRESHOLD`, THEN the sprite plays the walking animation and slides to `Vector2i(1, 0)` over exactly $0.25$ seconds, updating the final grid coordinates.
*   **In-Place Turning**: GIVEN a player character facing `Down` at `grid_position = Vector2i(0, 0)`, WHEN the player taps `Left` for $0.05$ seconds, THEN the player updates their `facing_direction` to `Vector2i(-1, 0)` and plays the turning frame, but remains at `grid_position = Vector2i(0, 0)`.
*   **Collision Block**: GIVEN a player facing a tile with property `walkable = false`, WHEN the player holds the directional input, THEN the character plays a brief bumping squish, plays the bump audio effect, and coordinates remain unchanged.
*   **Tall Grass Safe Steps**: GIVEN a player walking into tall grass, WHEN the player has taken less than 5 steps (`MIN_SAFE_STEPS`) in grass, THEN no wild encounter is ever rolled.
*   **Ledge Hop**: GIVEN a player standing above a ledge facing `Down`, WHEN the player presses `Down`, THEN the player plays a jumping arc animation, ignores collision on the ledge cells, lands at `grid_position + Vector2i(0, 2)`, and cannot walk `Up` back through the ledge.

## Open Questions

*   **Running Shoe Toggle**: Do we want a button to sprint/run faster like in Pokémon?
    *   *Answer for MVP*: No, to maintain a relaxed, cozy atmosphere, the player moves at a single constant cozy speed.
*   **Grid Diagonal Movement**: Should diagonal inputs be allowed?
    *   *Answer for MVP*: No, movement is strictly 4-directional cardinal to keep tile alignment clean and simple.
