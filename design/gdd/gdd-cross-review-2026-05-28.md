## Cross-GDD Review Report
Date: 2026-05-28
GDDs Reviewed: 6
Systems Covered: MonsterData, InventorySystem, GridMovement, BattleEngine, CampManager, BattleUI

---

### Consistency Issues

#### Blocking (must resolve before architecture begins)
None.

#### Warnings (should resolve, but won't block)
None. All systems are fully aligned on stats, AP costs, fatigue parameters, and item categories.

---

### Game Design Issues

#### Blocking
None.

#### Warnings
⚠️ **Player Attention Budget / UI Selectors**  
With 2 active monsters in battle and moves mapped to keys `1`–`4`, younger players might occasionally get confused about which monster they are currently selecting actions for.  
*Recommendation*: The `BattleUI` must visually highlight the currently selected monster (e.g., using a glowing nameplate, selection arrow, or active border) to ensure input clarity.

---

### Cross-System Scenario Issues

Scenarios walked: 3
1.  **Tall Grass Exploration into Battle**: Player walks through tall grass, triggers a wild combat encounter, enters battle scene, and AP budget is computed.
2.  **Post-Battle Fatigue and Camping**: Player concludes battle, fatigue accumulates, player navigates to campsite, pitches camp, stokes fire, cooks food, and rests monsters.
3.  **Hazard Traversal and Resource Cost**: Player encounters a route obstacle, checks inventory for tool item, consumes fatigue to clear it, and continues.

#### Blockers
None.

#### Warnings
None.

#### Info
ℹ️ **Battle Transition Alignment**: The transition from exploration to combat must wait for the player character's movement tween to complete its slide to the target tile before fading/wiping the screen, preventing coordinate alignment desync. (Already explicitly documented in GDD edge cases).

---

### GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| None | All GDDs are consistent | None | None |

---

### Verdict: PASS

PASS: No blocking issues. Warnings present but don't prevent architecture.
