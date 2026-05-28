# Game Concept: Hearth & Horn

*Created: May 28, 2026*
*Status: Approved*

---

## Elevator Pitch

> Hearth & Horn is a cozy, travel-themed 2D pixel art monster-collecting adventure for kids. Players journey through wild routes connecting safe towns, pitching camp to cook delicious snacks and protect their monster companions with safety skills, while commanding their team in tactical, speed-based turn battles using a playful predictive move triangle.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Cozy Monster-Taming Adventure |
| **Platform** | Web Browser (HTML5) & PC (Easiest for prototyping) |
| **Target Audience** | Kids (8-14) & Family-friendly casual gamers |
| **Player Count** | Single-player |
| **Session Length** | 15 - 45 minutes |
| **Monetization** | Premium / Free Web Demo |
| **Estimated Scope** | Small (3-6 months, solo developer) |
| **Comparable Titles** | *Pokémon FireRed*, *Cozy Caravan*, *Palworld* (concept of monster utility, but cozy and kid-friendly) |

---

## Core Fantasy

> You are a young monster traveler on a grand adventure across the wild routes of the world. With your small, trusted group of monster friends sleeping in your tent and sitting around your campfire, you journey from town to town. You rely on them to help you cook, navigate natural obstacles, and stay safe, while they rely on your support magic and delicious food to stay strong.

---

## Unique Hook

> It's like classic Pokémon, but there is no static home base and no massive box storage. Instead, you are a nomad: you travel through wildzones where you must set up temporary campsites, using your monsters' non-combat skills (like fire-starting or water purification) to cook food that boosts them. Battles are turn-based but use Speed-based Action Points and a simple, predictive move stance triangle (Block beats Brute, Counter-Block beats Block, Brute beats Counter-Block).

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Fantasy** (role-playing) | 1 | The feeling of being a supportive companion coach and chef, traveling with cute monsters who are active helpers rather than passive toolsets. |
| **Discovery** (exploration) | 2 | Finding hidden forest clearings, discovering new cooking ingredients, mapping routes, and encountering rare friendly monsters. |
| **Submission** (relaxation) | 3 | High comfort loops—pitching camp, watching the fire crackle, cooking food, and petting/grooming monsters in a safe space. |
| **Expression** (creativity) | 4 | Distributing points in the Elemental Talent Tree to specialize in specific skills, and choosing which moves to teach monsters. |
| **Sensation** (sensory pleasure) | 5 | Warm GBA-style pixel art, cozy acoustic soundtracks, satisfying clicky menus, and expressive animations for your monster companions. |
| **Challenge** (mastery) | 6 | Simple strategic battles. Fun and accessible, teaching basic prediction logic without punishing failure. |
| **Narrative** | 7 | A lighthearted journey storyline about traveling to the Grand Trainer Capital. |
| **Fellowship** | N/A | Single-player focus. |

### Key Dynamics (Emergent player behaviors)
* **Strategic Preparation**: Players will plan their trips at towns, buying ingredients and packing gear before venturing into wildzones.
* **Campfire Bonding**: Players will naturally pause to pitch camps, cooking specific meals to cater to their monsters' favorite tastes and boost their relationship tiers.
* **Tactical Prediction**: In combat, players will try to read the opponent monster's move cues (e.g., a defense stance suggests a Block move, meaning the player should order a Counter-Block).

### Core Mechanics (Systems we build)

1. **AP Turn-Based Combat**: Battles occur in turn-based rounds. Monsters receive Action Points (AP) based on their Speed (average 2 AP, fast monsters 3 AP, slow monsters 1 AP). Players budget these points for moves.
2. **The Stance Triangle**: Moves belong to three archetypes:
   * **Block**: Counters Brute Attacks, reducing damage to zero.
   * **Counter-Block**: Deals double damage to a blocking monster.
   * **Brute Attack**: Deals high raw damage, beating Counter-Block moves.
3. **Campsites & Cozy Cooking**: Safe spots in wildzones where players set up camps. Players combine gathered ingredients to cook meals. Monsters help based on elements (e.g., Fire monsters cook, Water monsters purify).
4. **Player Elemental Talent Tree**: Developed by bonding with monsters and exploring. Grants:
   * *Cooking Talents*: Unlocks tasty recipes that provide stat boosts.
   * *Safe Talents*: Utility spells like "Camp Ward" (prevents wild monsters from approaching camp) or "Scent Mask" (briefly avoids encounters on the route).
   * *Field Skills*: Environmental clearing (e.g., using fire talent to burn thorny vines).

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Relatedness** | High emphasis on pet care, feeding, campfire bonding, and mutual cooperation in travel. | **Core** |
| **Autonomy** | Deciding which route to take, which monsters to travel with (limit of 4 active), and how to build the talent tree. | **Supporting** |
| **Competence** | Learning recipe combinations and mastering the combat predictive move triangle. | **Supporting** |

### Player Type Appeal (Bartle Taxonomy)

* [x] **Explorers** (discovery, finding secrets) — How: Mapping wild routes, finding hidden ingredients, and finding safe campsite locations.
* [x] **Socializers** (relationships, bonding) — How: Building deep relationships with a small group of monsters, petting them, and watching them react happily.
* [x] **Achievers** (progression, collection) — How: Collecting recipe badges, unlocking all elemental talents, and leveling up monsters.
* [ ] **Killers/Competitors** — N/A: No PvP or high-stress combat.

### Flow State Design

* **Onboarding curve**: Starts in a safe hometown. The first route has a tutorial monster partner, walking the player through moving on a grid, pitching a tent, cooking a basic soup, and winning a simple 1v1 practice battle.
* **Difficulty scaling**: Wildzones get progressively larger with more environmental obstacles. Opponents budget their Action Points smarter, requiring the player to pay closer attention to their stances.
* **Feedback clarity**: Clear visual indicators during combat (e.g. "Countered!", "Blocked!") and star-ratings for cooked food.
* **Recovery from failure**: Extremely forgiving. If your monsters run out of energy, they fall asleep, and you wake up safely at your last campsite or the previous town. You lose no items or progress.

---

## Core Loop

### Moment-to-Moment (30 seconds)
> Moving top-down grid-by-grid along routes, gathering cooking ingredients (berries, herbs), and using player elemental talents to resolve paths (like watering a withered vine to climb it).

### Short-Term (5-15 minutes)
> Navigating a section of a wild route. Managing your monsters' energy levels. Finding a safe clearing, setting up a campsite, cooking a warm meal to restore your team, and bonding with them.

### Session-Level (30-120 minutes)
> Departing a safe town fully prepared $\rightarrow$ traveling through 1-2 wild routes $\rightarrow$ establishing campsites to rest $\rightarrow$ completing tactical battle challenges against wild monsters $\rightarrow$ reaching the safety of the next town to buy supplies and unlock new gear.

### Long-Term Progression
> Developing the player's Elemental Talent Tree (unlocking advanced cooking and safety skills), leveling up monsters to teach them stronger AP moves, and upgrading your mobile camping equipment.

---

## Game Pillars

### Pillar 1: Cozy Road-Trip Adventure
* Traveling is about the joy of the journey with friends. Exploring routes is a low-stress, beautiful experience filled with cute discoveries rather than hardcore survival threats.
* *Design test*: If debating between adding a fast-travel teleportation map or keeping focus on route travel, we keep the route travel but keep it short, interesting, and rewarding.

### Pillar 2: Playful Stance Battles
* Combat is strategic, clean, and kid-friendly, focusing on stance prediction (Block-Counter-Brute) and Action Point budgeting rather than complex math or typing charts.
* *Design test*: If debating between adding detailed type-effectiveness multipliers or prioritizing the AP action economy and move stances, we choose the AP and stances.

### Pillar 3: Campfire Connection (Food & Safety)
* The player is a caregiver and support coach. Resting at camp, preparing food, and utilizing safe skills are the primary ways you progress and care for your team.
* *Design test*: If choosing between let monsters heal automatically after battle or requiring the player to feed them at camp to restore energy, we require feeding at camp to keep the bonding loop active.

---

## Anti-Pillars (What This Game Is NOT)

* **NOT Stressful Survival**: No punishing mechanics like permadeath, starvation damage, or losing items when defeated.
* **NOT Permanent Base-Building**: No building static farms, houses, or factory lines. Your home is your campfire and your tent.
* **NOT Direct Player Combat**: The player never attacks. They act purely as a coach, using support items, cooking, and casting protective safety spells.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| *Pokémon FireRed* | 2D top-down grid movement, battle camera style, monster stats. | Supportive player role, AP/Stance combat, camping focus. | Establishes the classic GBA pixel aesthetic kids and retro fans love. |
| *Palworld* | Monster utility roles (monsters helping cook/gather). | Cozy, friendly, no weapons, no industrial exploitation. | Validates that monsters having utility outside combat is highly engaging. |
| *Cozy Caravan* | The feeling of a cozy nomadic travel adventure. | Added tactical turn-based battles and campsite cooking. | Validates that travel-based coziness is a very satisfying player fantasy. |

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 8 - 14 years old (plus cozy game enthusiasts) |
| **Gaming experience** | Casual / Beginner |
| **Time availability** | Short play sessions (15 - 30 minutes) after school or on weekends |
| **Platform preference** | Web Browsers (Chrome/Safari on tablets/Chromebooks) and PC |
| **Current games they play** | *Minecraft* (peaceful mode), *Animal Crossing*, *Pokémon* |
| **What they're looking for** | A cute, charming game where they can care for animal friends and go on an adventure without stressful timers or scary monsters. |
| **What would turn them away** | Punishing mechanics, dark/scary themes, complex text-heavy UI, or microtransactions. |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | **Godot Engine 4** (Outstanding 2D support, lightweight, extremely easy HTML5 web export, user-friendly GDScript). |
| **Key Technical Challenges** | Implementing turn-based UI states in Godot's control nodes, managing a simple JSON-based saving/loading system for web browser cookies. |
| **Art Style** | 2D Pixel Art (GBA-inspired top-down grid). |
| **Art Pipeline Complexity** | Low (Using simple 16x16 or 32x32 tilesets and sprites). |
| **Audio Needs** | Cozy, loopable 8-bit or acoustic background music, cute UI blips, campfire crackles. |
| **Networking** | None (Pure offline single-player). |
| **Content Volume** | Prototype: 1 town, 1 wild route, 1 campsite, 2 monsters, 2 recipes. |

---

## Risks and Open Questions

### Design Risks
* **Combat Over-simplicity**: The Block-Counter-Brute triangle might feel too simple over long sessions.
  * *Resolution*: Introduce status effects (like Sleep, Burn) and variable action point costs to keep battles tactical.

### Technical Risks
* **HTML5 Web Saves**: Web builds can lose local save data if browser cookies are cleared.
  * *Resolution*: Keep the game short or offer simple code-based save states (save passwords).

---

## MVP Definition

**Core hypothesis**: Players find the turn-based move-prediction combat and cozy camping/cooking loop fun in a GBA-style browser prototype.

**Required for MVP**:
1. **Explore**: 1 simple grid route connecting a starting village to a campsite.
2. **Battle**: 1 turn-based battle using the AP system (2 AP average) and the Block-Counter-Brute triangle.
3. **Camp**: 1 campsite pitching interaction, cooking 1 basic berry recipe that restores monster stamina.
4. **Partner**: 1 monster companion following the player.

**Explicitly NOT in MVP**:
* Multi-monster parties (restricted to 1 active partner for the sample).
* Multiple elemental talent branches (only basic camp ward and cooking unlocked).
* Advanced items, shopping, or wild monster capturing.

### Scope Tiers

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 1 small route, 1 battle | Basic movement, AP/Stance combat, 1 recipe | 2 - 3 weeks |
| **Vertical Slice** | 1 town, 1 full wildzone, 1 campsite | Full camp setup, 3 monsters, 3 recipes, basic talent tree | 6 - 8 weeks |
| **Alpha** | 2 towns, 2 routes, 3 campsites | 6 monsters, 8 recipes, inventory system | 12 weeks |
| **Full Vision** | 3 towns, 4 routes, multiple zones | 10+ monsters, full talent tree, polish and sound | 16 - 20 weeks |

## Visual Identity Anchor

**One-line Visual Rule**:  
> A vibrant GBA-style grid world where every asset conveys warmth, safety, and the active partnership between the traveler and their monsters.

### Supporting Principles
*   **Cozy Comfort Cues**: Visuals must prioritize feelings of safety, comfort, and warmth over harsh survival realism (e.g., warm, glowing oranges and soft greens).
*   **Active Partnership**: Monsters are never passive objects or tools; they must be shown actively participating in camp chores or idle tasks.
*   **Playful Stance Clarity**: Battle sprites and UI must clearly telegraph the current combat stance (Block, Counter-Block, or Brute) so that children can easily read the opponent's intentions.

---

## Next Steps

- [x] Write game concept document to `design/gdd/game-concept.md`
- [ ] Configure engine by running `/setup-engine` to select Godot 4
- [ ] Establish initial project rules and preferences in `CLAUDE.md` and `.claude/docs/technical-preferences.md`
- [ ] Create the visual identity specification (`/art-bible`)
- [ ] Decompose the concept into systems with `/map-systems`
- [ ] Begin prototyping the core battle loop
