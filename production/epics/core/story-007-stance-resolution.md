# Story-007: Stance Resolution

*   **Epic**: [Core Layer](file:///Users/cation/Game-Studios/production/epics/core/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want moves to resolve based on the stance triangle (Block, Counter-Block, Brute) and apply stance modifiers to the damage calculations so that predictive strategy determines battle victory.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-001: Resource Management](file:///Users/cation/Game-Studios/docs/architecture/adr-001-resource-management.md)
*   **Pattern**: Implements stance resolution checkers comparing the attacker's chosen move stance with the defender's active stance, returning a matchup multiplier (0.0x, 1.0x, 2.0x) fed into the battle damage formula.

---

## 3. GDD Requirements Addressed
*   **TR-battle-002**: Stance triangle matchups (Block counters Brute; Counter-Block counters Block; Brute counters Counter-Block) and damage calculations.

---

## 4. Acceptance Criteria
*   **GIVEN** an active companion uses a Block stance move, **WHEN** hit by an opponent's Brute Attack move, **THEN** the damage resolves to exactly 0.
*   **GIVEN** an active companion uses a Counter-Block move, **WHEN** targeted at a defender in Block stance, **THEN** the damage is calculated using `stance_multiplier = 2.0`.
*   **GIVEN** an active companion uses a Counter-Block move, **WHEN** targeted at a defender in Brute or Idle stance, **THEN** the move fails, dealing exactly 0 damage.
