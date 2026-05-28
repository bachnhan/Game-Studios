# Epic: Core Layer

*   **Priority**: MVP (Core Layer)
*   **Layer**: Core
*   **Status**: Scoped
*   **Description**: Implements GBA-style cardinal grid movement, collision obstacle checks, one-way ledges, tall grass wild encounter step tracking, active 2v2 combat round loops, Speed-based AP budgeting, and the predictive move stance triangle.

## Systems Covered
*   [GridMovement](file:///Users/cation/Game-Studios/design/gdd/grid-movement.md)
*   [BattleEngine](file:///Users/cation/Game-Studios/design/gdd/battle-engine.md)

## Requirements Traceability
*   **TR-movement-001**: Grid sliding translations and in-place turning.
*   **TR-movement-002**: Wall/Obstacle blocking layers.
*   **TR-movement-003**: Grass steps accumulator and encounter roll.
*   **TR-movement-004**: One-way ledge leaping.
*   **TR-battle-001**: Active 2v2 deployment and Speed-AP round budgets.
*   **TR-battle-002**: Move stance execution and damage calculations.

## Dependencies
*   **ADR Referenced**: [ADR-002: TileMapLayer Grid](file:///Users/cation/Game-Studios/docs/architecture/adr-002-tilemap-layer.md)
*   **Upstream**: Foundation Layer (requires resource definitions for monsters).

## Sprint / Milestone Roadmap
1.  `story-004`: Implement Grid Movement on Stacked TileMapLayers.
2.  `story-005`: Implement Tall Grass Step Encounter System.
3.  `story-006`: Implement Battle AP Turn Loop.
4.  `story-007`: Implement Combat Stance Damage Resolution.
