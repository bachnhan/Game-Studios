# Story-002: Inventory Slots

*   **Epic**: [Foundation Layer](file:///Users/cation/Game-Studios/production/epics/foundation/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a developer, I want to create the `ItemData` resource and the `Inventory` resource manager to track gathered items, manage stack sizes, and prevent item pickups when the player's 20-slot backpack is full.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-001: Resource Management](file:///Users/cation/Game-Studios/docs/architecture/adr-001-resource-management.md)
*   **Pattern**: Custom `ItemData` resources. `Inventory` stores `InventorySlot` instances (which contain an `ItemData` reference and an integer quantity count) to keep save data clean and lightweight.

---

## 3. GDD Requirements Addressed
*   **TR-inventory-001**: Pre-allocated slot capacity boundaries (20 slots) and stack size limits (max 99 per slot).

---

## 4. Acceptance Criteria
*   **GIVEN** an active inventory, **WHEN** `add_item()` is called with an item matching an existing slot below max stack size, **THEN** the item is added to the stack.
*   **GIVEN** an inventory containing 20 distinct item slots, **WHEN** attempting to add a 21st unique item type, **THEN** the transaction is blocked, the inventory returns the full amount, and the bag does not open new slots.
