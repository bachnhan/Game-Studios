# ADR-001: Data-Driven Resource Management

*   **Status**: Accepted
*   **Date**: 2026-05-28
*   **Author**: Antigravity
*   **Engine Version**: Godot 4.6.3

---

## Context & Decision Drivers

Hearth & Horn relies on static template databases for monsters (`MonsterData`) and items (`ItemData`). Game designers need to easily create and balance these databases using Godot's visual inspector. At the same time, when a player collects a monster or buys an item, the game must track runtime instance changes (such as current health, fatigue, and stack counts) without altering the static default databases.

In Godot, files extending `Resource` are shared in memory by default when loaded. If two instances of the same monster race are active, any modification to a resource property (like health) on one would immediately mutate the other and overwrite the static file resource, causing critical bugs.

## Options Considered

### Option A: Custom Godot Resources with Runtime Duplication (Recommended)
This approach defines databases as custom resources inheriting `extends Resource` (e.g., `class_name MonsterData`). When an active monster or item is instantiated, the system duplicates the base template using `template.duplicate()`.

*   **Pros**:
    *   100% integrated with the Godot Inspector; designers can easily create templates as `.tres` files.
    *   Preserves static type safety.
    *   Godot's built-in duplication handles nested properties cleanly.
*   **Cons**:
    *   Requires strict developer discipline to always duplicate templates before editing.

### Option B: JSON Data Tables and RefCounted Translators
This approach stores static data in raw JSON config files. At runtime, these files are read, parsed, and mapped to mutable instances of `RefCounted` data-holding scripts.

*   **Pros**:
    *   Complete isolation of data; no risk of mutating shared resource templates.
*   **Cons**:
    *   No Godot inspector support; designers must edit raw text JSON configurations.
    *   No native support for dragging and dropping visual assets (like textures/icons) directly in the editor.

## Chosen Option

**Option A (Custom Godot Resources with Runtime Duplication)** is selected. It provides the best cozy visual editor workflow, which is critical for rapid balancing.

To mitigate the risk of developers forgetting to call `.duplicate()`, we enforce a Factory Pattern: active instances must be loaded through explicit helper functions:

```gdscript
# Inside MonsterFactory.gd or similar helper
static func spawn_active(template: MonsterData) -> MonsterData:
    var instance: MonsterData = template.duplicate() as MonsterData
    instance.initialize_runtime_state()
    return instance
```

## Consequences

*   **Positive**: Designers can create new monsters and items in seconds by clicking "New Resource" in the Godot inspector.
*   **Negative**: Calling `.duplicate()` creates a new object in memory. However, for a cozy prototype containing fewer than 100 active entities on screen, the memory impact is negligible.

## Dependencies
*   **Enables**: [ADR-003: Save/Load State with ConfigFile](file:///Users/cation/Game-Studios/docs/architecture/adr-003-save-load-configfile.md) (requires serialized items/monsters).

## GDD Requirements Addressed
*   **TR-monster-data-001**: Inspector-editable templates for monster attributes.
*   **TR-monster-data-002**: Runtime isolation of mutable variables (health, fatigue).
