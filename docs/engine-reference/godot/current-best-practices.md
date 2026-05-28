# Godot 4.x — Current Best Practices

*Last verified: May 28, 2026*

This document tracks modern best practices for Godot 4.4, 4.5, and 4.6 development, specifically focusing on 2D games like Hearth & Horn.

---

## 1. GDScript Static Typing
Godot 4 heavily rewards static typing with better editor autocomplete, script performance, and code safety.

* **Best Practice**: Enable "Safe Casts" and static typing warnings in your Godot Project Settings.
* **Example**:
  ```gdscript
  # Define static variables
  var monster_name: String = "Sprout"
  var current_ap: int = 2
  var base_speed: float = 45.5

  # Define typed functions
  func calculate_damage(attack_power: int, defender_defense: int) -> int:
      var raw_damage: int = attack_power - (defender_defense / 2)
      return max(1, raw_damage) as int
  ```

---

## 2. Data-Driven Design with Custom Resources
For games with collectible monsters, items, and recipes, use Godot's `Resource` class to store stats and metadata.

* **Best Practice**: Create custom `Resource` scripts to represent data structures. This allows you to edit monster templates and recipes directly in the inspector.
* **Example**:
  ```gdscript
  # monster_data.gd
  class_name MonsterData
  extends Resource

  @export var name: String = "Mon"
  @export var icon: Texture2D
  @export var base_speed: int = 2
  @export var elemental_type: String = "Grass"
  @export var max_hp: int = 50
  ```

---

## 3. UI Node Management
Godot 4.5 introduced AccessKit integration, making accessibility much easier.

* **Best Practice**: Use `Control` nodes properly (`MarginContainer`, `VBoxContainer`, `HBoxContainer`) instead of manually placing UI. This guarantees scaling on web browsers and mobile screens.
* **Accessibility**: Give focusable buttons descriptive names and tooltip text so screen readers can interpret them natively.

---

## 4. Web Export Optimization (HTML5)
* **Rendering Engine**: Use the **Compatibility** renderer (Vulkan Mobile is viable, but Compatibility is standard and stable for WebGL2 browsers).
* **Shader baking**: Allow Godot 4.5+ to pre-bake shaders on export to prevent web player stutters.
