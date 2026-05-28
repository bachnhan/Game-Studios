# UX Spec: Main Menu

> **Status**: Approved (Lean Mode)
> **Author**: Antigravity
> **Last Updated**: May 28, 2026

## 1. Overview

The `MainMenu` is the landing screen of *Hearth & Horn*. It displays a cozy, animated title scene and presents simple navigation choices to start or resume a trip. Designed to run cleanly in web browsers, it queries the `SaveManager` on startup to enable or disable the load game option.

---

## 2. Layout & Wireframe

```
+-------------------------------------------------------------+
|                                                             |
|                    HEARTH & HORN                            |
|                 (Large Cozy Pixel Logo)                     |
|                                                             |
|                 [Animated Campfire Graphic]                 |
|                                                             |
|                    > Start Journey <                        |
|                      Resume Trip                            |
|                        Options                              |
|                                                             |
|                                                             |
|  v1.0.0                                    Press Z to Select|
+-------------------------------------------------------------+
```

*   **Logo Zone**: Placed at top center. Uses warm orange gradient text with `#3C2010` outlines.
*   **Art Center**: Animated campfire sprite loops sitting below the title logo.
*   **Menu Options Panel**: Vertically centered in the lower half of the screen.
*   **Version Tag**: Renders at bottom-left corner in small grey text.

---

## 3. Menu Options & States

*   **Start Journey**:
    *   *Action*: Starts a new game.
    *   *Behavior*: Triggers a transition fade-out (black screen, 0.5s), wipes active cache, and loads the initial town scene.
*   **Resume Trip**:
    *   *Action*: Loads existing progress.
    *   *Behavior*: Queries `SaveManager.has_save()`. If `false`, the text is rendered in light grey (`#8F8F8F`) and cannot be focused. If `true`, the text is active. Selecting it loads player coordinate data, party state, and inventory from `user://savegame.cfg`.
*   **Options**:
    *   *Action*: Opens sound configuration.
    *   *Behavior*: Displays slider bars for Music and Sound Effects volumes.

---

## 4. UI Transitions & Audio

*   **Startup**: Screen starts black and fades in the campfire graphics over 1.0 second. A soft chiptune introduction track begins looping.
*   **Navigation**: Arrow Up/Down moves the cursor. Plays a short wooden click sound.
*   **Selection**: Pressing **Z** on `Start Journey` or `Resume Trip` plays a rising chiptune chime, pauses the music, and initiates a 0.5-second black screen fade before loading the map.
