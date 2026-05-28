# Godot 4.x — Deprecated APIs

*Last verified: May 28, 2026*

This document tracks APIs that have been deprecated or renamed in Godot 4.4, 4.5, and 4.6. Always use the recommended replacements.

| Deprecated / Old API | Replacement API | Notes |
|----------------------|-----------------|-------|
| `get_node("Node").set_name(...)` | `get_node("Node").name = ...` | Property access is preferred over setter methods. |
| `OS.get_system_time_secs()` | `Time.get_time_dict_from_system()` or `Time.get_unix_time_from_system()` | Legacy OS time methods are deprecated. |
| `String.to_ascii()` | `String.to_ascii_buffer()` | Ascii buffer is safer for byte transfers. |
| `File.new()` | `FileAccess.open()` | Static FileAccess API replaced the old instantiated File. |
| `Directory.new()` | `DirAccess.open()` | DirAccess static API replaced Directory. |
| `get_tree().is_network_server()` | `multiplayer.is_server()` | Multiplayer API is decoupled from SceneTree. |
| `get_tree().get_network_unique_id()` | `multiplayer.get_unique_id()` | Decoupled multiplayer API. |
| `Control.set_anchors_preset()` | `Control.set_anchors_and_offsets_preset()` | More descriptive preset control. |
