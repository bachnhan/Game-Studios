# MonsterData

> **Status**: In Design
> **Author**: Antigravity
> **Last Updated**: May 28, 2026
> **Implements Pillar**: Cozy Road-Trip Adventure, Playful Stance Battles

## Overview

The `MonsterData` system is the foundational data infrastructure that defines all monster attributes, including base stats (HP, Attack, Defense, Special Attack, Special Defense, Speed), elements, movesets, and campsite utility behaviors. Built using Godot 4.6’s `Resource` class, it acts as a static template database. The player experiences this system indirectly through its integration with the `BattleEngine` (which reads stats for 2v2 combat rounds) and the `CampManager` (which reads utility traits for camping chores). Without this system, there would be no unified structure for monster capabilities, progression, or campsite roles. For implementation details regarding Godot Resource instantiation and memory safety, see [ADR-001: Godot Resource Data-Driven Architecture](file:///Users/cation/Game-Studios/docs/architecture/adr-001.md).

## Player Fantasy

Although the player never manipulates the raw `MonsterData` directly, they feel its effects through the unique individuality and helpful presence of their monster companions. The system delivers the fantasy of a close, co-dependent road trip:
*   **Individuality in Battle**: Your monster isn't just a list of moves; their physical build and Speed stat dictate their pacing. A heavy turtle-like defender feels slow but incredibly safe, while a swift avian partner feels light and active.
*   **Living Companions at Camp**: Monsters are active partners in your journey. Because their elemental data is tied to camp utilities, a Fire-type companion is visually and mechanically the cozy center of your camp—helping you cook meals and keeping the campsite warm and safe.

## Detailed Design

### Core Rules & Properties (Godot Resource Structure)
A monster's static data is defined in a custom Godot Resource class (`class_name MonsterData extends Resource`). 

#### Static Data Fields (Resource Templates)
*   **Identity**:
    *   `monster_id`: String (Unique internal ID, e.g., `"mon_leafy"`)
    *   `display_name`: String (The monster's individual name, e.g., `"Sprout"`)
    *   `monster_race`: String (The monster's species, e.g., `"Leafy"`)
    *   `elemental_type`: Enum (`Grass`, `Fire`, `Water`, `Normal`)
    *   `signature_talent`: MonsterTalent (A static, unchangeable resource reference defining the race's unique ability. E.g., a Fire-race monster has `Kindle` to speed up cooking or heat up battle attacks; a Grass-race has `Photosynthesis` to heal outside towns).
*   **Base Stats**:
    *   `base_hp`: int (Range: 20–200) - Maximum Health points.
    *   `base_attack`: int (Range: 10–100) - Physical strike power.
    *   `base_defense`: int (Range: 10–100) - Physical mitigation.
    *   `base_sp_attack`: int (Range: 10–100) - Elemental spell power.
    *   `base_sp_defense`: int (Range: 10–100) - Elemental mitigation.
    *   `base_speed`: int (Range: 1–3) - Directly represents the **Action Points (AP)** this monster contributes to the round budget in combat.
*   **Stance Moveset**:
    *   `available_moves`: Array[MonsterMove] - Reference to custom Move resources. A monster can carry up to 4 moves. Each move defines:
        *   `move_name`: String
        *   `ap_cost`: int (1 or 2 AP points)
        *   `stance_type`: Enum (`Block`, `Counter-Block`, `Brute`, `None`)
        *   `base_power`: int
*   **Campsite Utility**:
    *   `camp_role`: Enum (`Fire-Starter`, `Water-Purifier`, `Gatherer`, `Warder`)
    *   `work_efficiency`: float (Default: 1.0) - Modifier for campsite chores.

#### Runtime Instance Properties (Mutable Player Data)
To prevent shared memory mutation, every active monster must duplicate the static template resource (`var active_mon = template.duplicate()`). The active instance tracks:
*   `current_hp`: int (0 to `base_hp`)
*   `fatigue`: int (0 to 100) - Increases by +10 per combat round or +5 per route hazard cleared; resets to 0 at camps or safe zones.
*   `bond_level`: int (0 to 5) - Enhances combat AP budget and efficiency.
*   `bond_xp`: int - Acquired by eating camp food and petting.
*   `plus_talent`: MonsterTalent (A mutable, trainable secondary ability resource. Can be changed or leveled up through training mini-games, special items, or camp events. E.g., `Iron Guard` which increases defense when in Block stance, or `AP Saver` which reduces the cost of a Brute move once per battle).

### States and Transitions
Active monster instances cycle through five distinct states based on their HP and Fatigue stats:

| Source State | Target State | Trigger Condition | Gameplay Effect |
| :--- | :--- | :--- | :--- |
| **Healthy** | **Tired** | `fatigue >= 80` | Sprite shows sweat drops; minor speed debuff. |
| **Healthy / Tired** | **Exhausted** | `fatigue == 100` | Monster falls asleep; cannot be deployed in battle or assigned camp chores. |
| **Any State** | **Fainted** | `current_hp == 0` | Cannot battle or help. Must be revived using specific camp meals or at town. |
| **Tired / Exhausted** | **Healthy** | Resting at Campsite or Town | Fatigue drops to 0; HP restores. |
| **Fainted** | **Healthy** | Eating a Revive Recipe at camp | HP set to 50%, fatigue set to 50. |

### Interactions with Other Systems
*   **2v2 Active Deployment**: The player brings a party of up to 4 monsters on their journey. By default, **2 monsters are deployed actively** in battles.
*   **Speed-AP Budget**: At the start of a combat round, the player's total Action Point (AP) budget is calculated as the sum of the Speed stats of the 2 active monsters.
    *   *Example*: A fast monster (Speed 3) paired with a slow defender (Speed 1) provides a total of 4 AP for the round.

## Formulas

This section defines the calculations governing monster stats and fatigue modifiers.

### Formula 1: Monster Active Combat Stats Modifier
The `combat_stat_modifier` formula is defined as:

`combat_stat_modifier = 1.0 + (bond_level * 0.05)`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `bond_level` | `bond_level` | int | 0–5 | The current relationship tier of the monster. |

*   **Output Range**: `1.0` (no buff at Bond Level 0) to `1.25` (+25% buff at max Bond Level 5).
*   **Example**: If a monster has `base_attack = 50` and its `bond_level = 4`, its modified attack stat in battle is:  
    $50 \times (1.0 + 4 \times 0.05) = 50 \times 1.20 = 60$ Attack.

### Formula 2: Fatigue Accumulation Rate
The `fatigue_accum` formula is defined as:

`fatigue_accum = base_cost * (1.0 - (bond_level * 0.05))`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `base_cost` | `base_cost` | int | 5–20 | The default fatigue cost of the action (e.g., 10 per combat round, 5 per hazard cleared). |
| `bond_level` | `bond_level` | int | 0–5 | The current relationship tier of the monster. |

*   **Output Range**: `base_cost` (at Bond Level 0) to `0.75 * base_cost` (25% reduction in fatigue rate at max Bond Level 5).
*   **Example**: A monster with `bond_level = 4` completes a combat round (base cost 10). The accumulated fatigue is:  
    $10 \times (1.0 - 4 \times 0.05) = 10 \times 0.80 = 8$ fatigue points.

## Edge Cases

This section outlines visual and structural edge cases and their exact mechanical resolution:

*   **If a monster is Exhausted (`fatigue == 100`) at the start of combat**: It cannot be actively deployed. The player must choose a healthy party member to deploy. If the player's entire party is Exhausted or Fainted, the player cannot trigger wild battles and will automatically retreat to the nearest campsite or safe town.
*   **If a monster Faints (`current_hp == 0`) while carrying high fatigue**: Its fatigue level is immediately set to 50, and its HP is set to 0. Upon revival, the monster will wake up with 50% HP and 50 Fatigue, preventing players from letting monsters faint simply to wipe their fatigue clean.
*   **If a monster is petted or fed while already at max Bond Level 5**: The action succeeds, showing happy visual indicators (`^^`), but its `bond_xp` remains capped at max and does not overflow or increase further.
*   **If a monster's speed or stats would be reduced below 0 by status effects or fatigue**: Stats (excluding Speed) are capped at a minimum value of 1. Speed is capped at a minimum value of 1 (guaranteeing at least 1 combat Action Point per round).

## Dependencies

This section outlines how the `MonsterData` system connects to other parts of the codebase.

### Upstream Dependencies (What this system requires)
*   **None**: As a foundational data resource, this system is self-contained.

### Downstream Dependents (What requires this system to function)
*   **`BattleEngine` (Hard Dependency)**: 
    *   *Interface*: Read-only access to stats, `monster_race`, `signature_talent`, `plus_talent`, and `available_moves`.
    *   *Purpose*: The battle system requires this data to calculate damage, execute stance mechanics, determine the player's round-start Action Points (AP) in 2v2 combat, and apply talent buffs.
*   **`CampManager` (Hard Dependency)**:
    *   *Interface*: Read-only access to `camp_role`, `work_efficiency`, `signature_talent`, and `plus_talent`.
    *   *Purpose*: The camp system requires this to allocate chores and apply speed modifiers to tasks.
*   **`BondManager` (Hard Dependency)**:
    *   *Interface*: Read-write access to instance stats (`current_hp`, `fatigue`, `bond_level`, and `bond_xp`) and mutable `plus_talent`.
    *   *Purpose*: Tracks relationship growth, lets the player train or swap their `plus_talent`, and manages resting states at campsites.
*   **`FieldHazards` (Hard Dependency)**:
    *   *Interface*: Read-only access to `elemental_type`.
    *   *Purpose*: Restricts route traversal unless a monster with a compatible element is in the player's active party to clear the hazard.

## Tuning Knobs

This section lists values that game designers can modify in the code configuration without rewriting systems.

| Knob Name | Default Value | Safe Range | Affected System | Risk / Extreme Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `MAX_BOND_LEVEL` | `5` | `3 - 10` | `BondManager`, `TalentTree` | Setting it too high makes progression feel grindy and stretches the stat scaling too wide. |
| `BOND_STAT_MULTIPLIER` | `0.05` | `0.01 - 0.10` | `BattleEngine` | The stat multiplier applied per bond level. If set to `0.10`, a max-bond monster gets a massive +50% stat buff, trivializing battles. |
| `BOND_FATIGUE_REDUCTION` | `0.05` | `0.02 - 0.10` | `BondManager` | Fatigue accumulation reduction multiplier per bond level. If set to `0.10` at bond level 5, monsters lose 50% less fatigue, making campsites optional. |
| `MAX_FATIGUE` | `100` | `50 - 200` | `BondManager` | Maximum fatigue cap. Too high makes wildroutes trivial; too low forces players to camp on every grid step. |
| `COMBAT_ROUND_FATIGUE_COST`| `10` | `2 - 25` | `BattleEngine` | Base fatigue cost gained by each deployed monster per round. |
| `FIELD_HAZARD_FATIGUE_COST` | `5` | `1 - 20` | `FieldHazards` | Base fatigue cost gained by a monster when using its element to clear a path blockade. |

## Visual/Audio Requirements

*   **Pixel Art Style**: GBA-era 2D pixel art. Warm, nostalgic, cozy aesthetic.
*   **Outline Rule**: NO pure black `#000000` outlines on character or monster sprites. Use `#3C2010` (Dark Earth Brown) for outline safety to maintain a softer, organic, cozy look.
*   **State Indicators**:
    *   *Tired state (`fatigue >= 80`)*: Playful floating sweat-drop particle/emoticon above the sprite.
    *   *Exhausted state (`fatigue == 100`)*: Character sprite transitions to a sleeping pose with floating 'Z' particles.
    *   *Fainted state (`current_hp == 0`)*: Sprite is knocked down, greyed out, or lying down.
*   **Audio Style**: Soft, nostalgic 16-bit chiptune sound design. Playful chirp for bonding, comforting crackling fire sound at campsites, and low-stress battle themes.

## UI Requirements

*   **Party Panel**:
    *   Displays up to 4 monster portrait slots.
    *   Shows current HP and Max HP with a clear green/yellow/red health bar.
    *   Shows a Fatigue bar with color shifts: Green (0–49), Orange (50–79), Dark Red (80–99), and a Sleep icon (100).
*   **Stat/Profile Screen**:
    *   Displays static data (`monster_id`, `monster_race`, `elemental_type`, `base_speed` as action points).
    *   Displays current mutable stats: Bond Level (0–5) with an XP progress bar, current Fatigue, and current HP.
    *   Tooltips/Descriptions for both `signature_talent` and the currently trained `plus_talent`.
*   **Battle Interface**:
    *   Displays both active monsters with their floating nameplates.
    *   Clearly displays the combined speed-based AP budget at the start of each round.

## Acceptance Criteria

*   **Racial Properties**: GIVEN a new `MonsterData` resource template is created, WHEN the inspector is opened in the Godot Editor, THEN `monster_race`, `elemental_type`, and `signature_talent` are editable properties.
*   **Duplication**: GIVEN a static template resource, WHEN instantiated via `template.duplicate()`, THEN changes to the copy's mutable attributes (`current_hp`, `fatigue`, `bond_level`) do NOT affect the base template.
*   **Stat Buff**: GIVEN a monster with a base stat of 50 (e.g., `base_attack`), WHEN it reaches `bond_level = 4`, THEN its calculated combat stat is exactly 60 ($50 \times 1.20$).
*   **Fatigue Accumulation**: GIVEN a monster at `bond_level = 4` performing a base-10 fatigue cost action, WHEN the fatigue is applied, THEN its fatigue increases by exactly 8 points.
*   **Exhaustion Block**: GIVEN a monster with `fatigue = 100`, WHEN the player attempts to deploy them in battle or assign them a camp chore, THEN the system blocks the action and displays a notification.

## Open Questions

*   **Saving Custom Nicknames**: Should players be able to rename their monsters? 
    *   *Answer for MVP*: No, display names default to the monster race/base display name to keep save serialization lightweight.
*   **Plus Talent Serialization**: How should mutable trained `plus_talent` resources be saved?
    *   *Answer for MVP*: The SaveManager will store the resource path or a unique ID string representing the talent along with its tier, rather than serializing the entire Resource object.
