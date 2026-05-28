# Godot 4.4, 4.5, 4.6 — Breaking Changes

*Last verified: May 28, 2026*

This document tracks breaking changes in Godot Engine versions released after the LLM knowledge cutoff (May 2025).

---

## Godot 4.4 (March 2025)

### .NET 8.0 Upgrade
* **Change**: C# support now requires the .NET 8.0 SDK. Older .NET SDKs (like .NET 6.0 or 7.0) are no longer supported.
* **Mitigation**: Ensure you have the .NET 8.0+ SDK installed on your system if compilation errors occur.

### 3D Physics Interpolation
* **Change**: 3D physics interpolation is now on by default to match 2D. 
* **Mitigation**: If your game uses custom physics integration that jitters, verify if `physics_interpolation_mode` is configured correctly on the nodes.

---

## Godot 4.5 (September 2025)

### Shader Baking
* **Change**: Shader compiling now happens during export rather than in real-time. This eliminates startup stutters.
* **Mitigation**: Hand-crafted shader shaders must be properly linked to materials in the scene tree to ensure they bake during export.

---

## Godot 4.6 (January 2026)

### Default 3D Physics
* **Change**: Godot Jolt is now the default 3D physics engine for new projects.
* **Mitigation**: For 2D projects (like Hearth & Horn), this change does not impact anything. Godot Physics 2D is still the default.
