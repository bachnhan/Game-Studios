# GBA UI Interaction Patterns

> **Status**: Approved (Lean Mode)
> **Author**: Antigravity
> **Last Updated**: May 28, 2026

## Overview

This document defines common user interface standards and interaction behaviors for *Hearth & Horn*. Designed to match the GBA-era pixel-art aesthetic while maintaining high accessibility for younger players, it details input mappings, window aesthetics, menu lists, text reveals, and slider behaviors.

---

## 1. Input Controls & Mappings

To support web browser testing and simple keyboard play, controls are mapped to a standard emulator layout:

| Keyboard Key | GBA Button | Gameplay Action | Menu / UI Action |
| :--- | :--- | :--- | :--- |
| **Arrow Keys** | D-Pad | Move player grid-by-grid | Navigate selection focus |
| **Z** | Button A | Interact with object / talk | Accept / Confirm |
| **X** | Button B | Hold to view quick info | Cancel / Back |
| **Space** | Start | Open Pause / Party Menu | Confirm action queue |
| **Shift** | Select | Open Backpack directly | Sort active list |
| **1, 2, 3, 4** | Hotkeys | N/A | Quick select Move in combat slots |

---

## 2. Window Framing & Aesthetics

Following our art bible guidelines, UI windows must feel organic and cozy:
*   **Border outline**: Must enforce Dark Earth Brown `#3C2010` outlines. Pure black `#000000` is forbidden.
*   **Borders**: Retro double-line frame styling with rounded corners (corner radius 4px).
*   **Background panels**: Semi-transparent warm cream (`#FAF0E6` at 90% opacity) or dark wood (`#2F1B10` at 90% opacity) for high readability.
*   **Text color**: Dark brown `#1C0F08` for light panels, warm white `#FFF8DC` for dark panels.

---

## 3. Dialogue Box Pattern

Dialogue boxes appear at the bottom of the screen during interactions:
*   **Layout**: Renders exactly 2 lines of text.
*   **Text Reveal**: Typewriter character reveal at a speed of 30 characters per second (approx. 33ms per character).
*   **Typewriter Skip**: Pressing **Z** (Button A) while text is revealing instantly completes the current line reveal.
*   **Bouncing Arrow**: A small flashing red arrow indicator appears at the bottom-right corner of the dialogue frame when text halts, indicating the player must press **Z** to advance.
*   **Audio**: A low-pitched chiptune letter click sound plays during character reveals.

---

## 4. Grid Selector & Focus Indicators

Grid selectors appear in the backpack slot view and move selection wheel:
*   **Focus Frame**: The currently focused slot is surrounded by a solid yellow border (`#FFD700`) that pulses in width (from 1px to 2px) at a rate of 2 Hz.
*   **Hover Scaling**: Focused icons scale up by 10% (from $1.0$ to $1.1$ scale) to create satisfying visual depth.
*   **Cursor Movement**: Pressing a directional arrow key shifts the focus box immediately to the adjacent cell and triggers a short "tick" audio feedback.

---

## 5. Sweet-Spot Slider (QTE) Pattern

Used during cooking chores:
*   **Bar Layout**: A horizontal slider bar containing:
    *   Grey backing representing the total range (100%).
    *   Yellow region representing a "Good" hit (outer 30%).
    *   Green region representing a "Perfect" hit (inner 15%).
*   **Sweeper Line**: A thin white vertical cursor sweeps left-to-right at a constant rate of 1.5 cycles per second.
*   **Interaction**: Pressing **Z** halts the sweeper cursor. The position is mapped to the minigame score:
    *   Halts in green: `1.5` score (Perfect!)
    *   Halts in yellow: `1.0` score (Good)
    *   Halts in grey: `0.5` score (Bland)
