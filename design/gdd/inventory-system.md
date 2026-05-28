# InventorySystem

> **Status**: In Design
> **Author**: Antigravity
> **Last Updated**: May 28, 2026
> **Implements Pillar**: Cozy Road-Trip Adventure, Campfire Connection (Food & Safety)

## Overview

The `InventorySystem` manages the player's collection, storage, and consumption of resources gathered during their road trip. It tracks items like cooking ingredients (berries, herbs), campfire fuel (wood, tinder), and travel utility gear (ropes, axes). Using Godot 4.6’s `Resource` model, static item templates are defined as read-only configurations, while the player's bag is a mutable runtime container tracking item IDs and stack sizes. The system integrates closely with the `CampManager` (which consumes items for cooking and fuel) and `FieldHazards` (which checks for tool items to navigate blocks).

## Player Fantasy

The inventory supports the satisfying feeling of nomadic self-sufficiency and travel preparation:
*   **Packing the Backpack**: Opening a neat, visually organized grid bag and seeing it filled with gathered forest resources, delicious snacks, and sturdy travel gear.
*   **Foraging Along the Trail**: The delight of picking wild berries, harvesting fresh herbs, or gathering wood branches along routes to prepare for the next campfire camp.
*   **Resource Utility**: Seeing your gathered resources come alive—using the wood you picked to warm the camp, and cooking the berries to feed your tired monster friends.

## Detailed Design

### Core Rules & Properties (Godot Resource Structure)

Static item properties are configured using a custom Godot Resource class (`class_name ItemData extends Resource`). 

#### Static Data Fields (ItemData Resource Templates)
*   **Identity**:
    *   `item_id`: String (Unique internal ID, e.g., `"item_berry_cozy"`)
    *   `display_name`: String (The human-readable item name, e.g., `"Cozy Berry"`)
    *   `description`: String (Short description detailing flavor or utility)
    *   `category`: Enum (`Ingredient`, `Fuel`, `Consumable`, `Utility`)
*   **Attributes**:
    *   `max_stack`: int (Default: 99, Range: 10–99) - Maximum stack size.
    *   `weight`: float (Range: 0.1–5.0) - Weight of a single item unit in kilograms.
    *   `camp_value`: float (Default: 0.0) - Numerical utility value. For `Ingredient` and `Consumable`, this represents stamina/health recovery. For `Fuel`, this represents campfire burning duration.
    *   `icon`: Texture2D - 16x16 pixel icon for the item.

#### Mutable Data structures (Runtime Container)

To maintain memory safety and keep save file sizes minimal, the runtime inventory does not store raw duplicated `ItemData` objects. Instead, it tracks slot structures:

1.  **`InventorySlot` Class** (extends `RefCounted` or simple `Object` for UI bindings):
    *   `item_data`: ItemData - Reference to the read-only static item template.
    *   `quantity`: int - Current quantity in this slot (1 to `item_data.max_stack`).
2.  **`Inventory` Resource** (`class_name Inventory extends Resource`):
    *   `slots`: Array[InventorySlot] - Array of slots. Pre-allocated to match `max_slots`.
    *   `max_slots`: int - Total number of available item slots.

#### Inventory Operations API

The `Inventory` script exposes the following core functions:
*   `add_item(item_data: ItemData, amount: int) -> int`: Attempts to add items. Automatically fills existing incomplete stacks of the same ID first, then creates new stacks in empty slots. Returns any leftover amount that could not fit (returns `0` if all items were added).
*   `remove_item(item_id: String, amount: int) -> bool`: Consumes items across stacks. Returns `true` if successfully removed, `false` if inventory didn't contain enough of the item.
*   `has_item(item_id: String, amount: int) -> bool`: Checks if the sum of all stacks of the item ID is at least the requested amount.
*   `get_item_count(item_id: String) -> int`: Returns the total amount of the specified item across all slots.
*   `sort_inventory() -> void`: Consolidates partial stacks and groups items by category (`Utility` -> `Consumable` -> `Ingredient` -> `Fuel`), then alphabetically by name.

## Formulas

This section defines the calculations governing weight and slot management.

### Formula 1: Occupied Slot Count
The number of slots currently containing items:

`occupied_slots = count(slots where slot.quantity > 0)`

*   **Variables**:
    *   `slots`: Array of size `max_slots`.
*   **Output Range**: `0` to `max_slots`.

### Formula 2: Total Inventory Weight
Total weight of all items in the player's backpack:

`total_weight = sum(slot.item_data.weight * slot.quantity for slot in slots)`

*   **Variables**:
    *   `weight`: Weight of a single item unit.
    *   `quantity`: Number of items in the slot.
*   **Output Range**: `0.0` to maximum theoretically possible weight (e.g., $20 \text{ slots} \times 99 \text{ qty} \times 5.0 \text{ weight} = 9900.0 \text{ kg}$). Weight does not limit carry capacity in the MVP but is displayed in the UI.

## Edge Cases

*   **Picking up items when the inventory is full**: If the item cannot fit in any existing stacks and all slots are occupied, `add_item` returns the leftover amount. The game will show a floating text banner `"Bag is full!"` in the UI, and the item will drop back to the ground or remain as an interactive object on the route.
*   **Dropping items**: The player can discard items from their backpack. Discarded items are permanently removed from the game (they do not spawn as physical pickups on the ground) to prevent save file bloat and eliminate tracking complex item entities across map coordinates.
*   **Resource template protection**: Designers edit the base `ItemData` resources. At runtime, code must treat `item_data` references inside slots as strictly read-only. Any system seeking to modify item characteristics (e.g., crafting or using items) changes slot quantities, never the resource's properties directly.

## Dependencies

### Upstream Dependencies (What this system requires)
*   **None**: The inventory system is self-contained.

### Downstream Dependents (What requires this system to function)
*   **`CampManager` (Hard Dependency)**:
    *   *Interface*: Read and write access (`has_item`, `remove_item`).
    *   *Purpose*: Camp cooking checks if the backpack contains required recipe ingredients and consumes them. Stoke-campfire chores check for and consume `Fuel` items.
*   **`FieldHazards` (Hard Dependency)**:
    *   *Interface*: Read access (`has_item`).
    *   *Purpose*: Restricts progression unless the player has specific `Utility` items (e.g., an axe to clear logs or rope to cross a chasm).
*   **`SaveManager` (Hard Dependency)**:
    *   *Interface*: Read and write access.
    *   *Purpose*: SaveManager serializes the inventory state into a simple array of JSON dictionaries: `[{"item_id": "item_wood", "qty": 12}, ...]` and reconstructs the inventory slots upon loading.
*   **`InventoryUI` (Hard Dependency)**:
    *   *Interface*: Reads inventory slots data and triggers `sort_inventory` or `remove_item` (for direct consumption/discarding).

## Tuning Knobs

| Knob Name | Default Value | Safe Range | Affected System | Risk / Extreme Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `BASE_INVENTORY_SLOTS` | `20` | `10 - 50` | `InventorySystem`, `UI` | Setting it too high makes resource management trivial and creates UI grid overflow issues. Setting it too low forces players to discard items constantly. |
| `MAX_STACK_SIZE` | `99` | `10 - 999` | `InventorySystem` | Setting it too high makes slot limits meaningless as players can stack hundreds of ingredients in a single slot. |

## Visual/Audio Requirements

*   **Visual Assets**:
    *   16x16 pixel icons for all items. Following the cozy visual guidelines, outlines must use `#3C2010` (Dark Earth Brown) rather than pure black `#000000`.
    *   Visual category indicators (badges): soft green for `Ingredient`, soft orange for `Fuel`, soft purple for `Utility`, soft pink for `Consumable`.
*   **Audio Assets**:
    *   A soft, satisfying fabric rustling sound effect when opening the backpack.
    *   A clean click sound when selecting or sorting items.
    *   A low-pitched alert chime when attempting to add an item to a full inventory.

## UI Requirements

*   **Backpack Overlay Screen**:
    *   Renders a grid of slots matching the `max_slots` limit.
    *   Each filled slot displays the item's sprite icon and a small quantity text count in the bottom-right corner.
    *   Empty slots are rendered as clean, semi-transparent grey boxes with rounded borders.
*   **Detail Panel**:
    *   When a slot is clicked, the side panel populates with the item's details: Large sprite, display name, category badge, weight, description, and an action button context menu ("Use" for consumables, "Discard" to throw away).
*   **Sort Button**:
    *   A prominent icon button at the top of the grid to trigger inventory sorting.

## Acceptance Criteria

*   **Template Editing**: GIVEN a new `ItemData` resource template, WHEN opened in the Godot inspector, THEN `item_id`, `display_name`, `category`, `max_stack`, and `weight` are editable properties.
*   **Auto-Stacking**: GIVEN an inventory slot containing 50 units of `"item_berry_cozy"`, WHEN the player adds 10 more units of `"item_berry_cozy"`, THEN the quantity in that slot updates to exactly 60.
*   **Slot Limits**: GIVEN an inventory with all `max_slots` occupied by different item types, WHEN the player attempts to add a new item type, THEN the inventory rejects the addition, returns the full added quantity, and does not open a new slot.
*   **Stack Splitting**: GIVEN a slot with 10 items, WHEN `add_item` is called with 95 items (exceeding `max_stack = 99`), THEN the first slot is filled to 99, a new slot is opened to store the remaining 6 items, and the function returns `0`.
*   **Item Consumption**: GIVEN an inventory containing 5 items of `"item_wood"`, WHEN `remove_item("item_wood", 3)` is called, THEN the inventory successfully updates, returning `true`, and the wood count drops to 2.

## Open Questions

*   **Weight Carry Limits**: Do we want a maximum carry weight limit that slows down the player or prevents movement?
    *   *Answer for MVP*: No, weight limits are omitted to keep exploration stress-free. The weight attribute is only shown for flavor/immersion.
*   **Storage Box**: Is there a chest at campsite zones or safe towns to store excess items?
    *   *Answer for MVP*: No, the player's backpack is the only storage space available to keep the prototype scope small.
