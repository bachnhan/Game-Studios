# Hearth & Horn — Art Bible

*Status: Under Review (Lean Mode)*
*Last Updated: May 28, 2026*

---

## 1. Visual Identity Statement

**One-line Visual Rule**:  
> A vibrant GBA-style grid world where every asset conveys warmth, safety, and the active partnership between the traveler and their monsters.

### Supporting Principles

*   **Cozy Comfort Cues**: Visuals must prioritize feelings of safety, comfort, and warmth over harsh survival realism.
    *   *Design Test*: When choosing color temperatures or particle effects for campfires, we prioritize warm, glowing oranges and soft, natural greens over stark blues or cold shadows.
*   **Active Partnership**: Monsters are never passive objects or tools; they are active companions who contribute to the journey.
    *   *Design Test*: When designing idle animations or camp sprites, monsters must be shown helping with chores (e.g., blowing fire on the cooking pot, holding a lantern, or carrying supplies) rather than just standing still.
*   **Playful Stance Clarity**: Battle sprites and UI must clearly telegraph the current combat stance (Block, Counter-Block, or Brute) so that children can easily read the opponent's intentions.
    *   *Design Test*: When designing a battle stance sprite, a monster using "Block" must look visibly guarded (e.g., hunkered down, hiding behind its tail/shell), while a "Brute" stance must look heavy and energetic.

---

## 2. Mood & Atmosphere

This section defines the emotional targets and visual styles for each major game state.

| Game State | Primary Emotion | Lighting Character | Atmospheric Descriptors | Energy Level |
| :--- | :--- | :--- | :--- | :--- |
| **Town (Safe Zone)** | Relief, safety, community | Bright mid-day sun, soft shadows, high saturation | Cozy, bustling, welcoming, peaceful | Calm, relaxed |
| **Wildzone (Exploration)** | Curiosity, adventure, wonder | Golden-hour daylight, dappled forest light, moderate contrast | Adventurous, fresh, mysterious, vibrant | Measured, exploratory |
| **Campsite (Resting)** | Intimacy, bonding, physical comfort | Evening dusk to starry night; warm campfire glow | Crackling, comforting, starlit, warm | Contemplative, serene |
| **Combat (Battles)** | Playful excitement, tactical focus | Clear, high-readability lighting; high saturation | Energetic, focused, colorful, rhythmic | Focused, tactical |
| **Defeat (Exhausted)** | Gentle fatigue, sleepiness | Soft sunset or twilight glow; low saturation | Sleepy, quiet, safe, winding-down | Very low, restful |

---

## 3. Shape Language

This section establishes the geometric vocabulary that makes the game world visually coherent, readable, and child-friendly.

### Character & Monster Silhouettes
*   **Player Character (Traveler)**: Circular and rounded shapes representing friendliness and vulnerability. Main distinguishing features: a prominent backpack and a wide-brimmed traveler hat.
*   **Monster Archetypes (Combat Stance Indicators)**:
    *   *Block Stance (Defenders)*: Dome-like, semi-spherical silhouettes. Features thick, rounded protective elements (like turtle shells or padded hide) to suggest safe cover.
    *   *Brute Stance (Attackers)*: Triangle and wedge-shaped silhouettes with soft-angled corners. Points forward/upward to show dynamic energy without appearing sharp or menacing.
    *   *Counter-Block Stance (Agi-Bypassers)*: Crescent and curved oval shapes, conveying flowing movement, light weight, and the ability to slip past a block.

### Environment Geometry
*   **Organic Curves**: Round organic shapes dominate the wilderness (e.g., bulbous tree canopies, pillowy clouds, rounded rocks). Sharp jagged lines are explicitly avoided to make the wild feel adventurous rather than hostile.
*   **Rounded Grid-Alignment**: Buildings, signs, and pathways align to the 2D grid but feature hand-drawn curves and rounded corners rather than harsh right angles.

### UI & HUD Shape Grammar
*   **Cozy Dialogues**: Dialogue boxes, text banners, and menus use squircle shapes (rounded rectangles) with thick outlines, mimicking classic GBA-era game interfaces.
*   **Visual Stance Buttons**: Stance selection buttons are shaped to match their combat stance (e.g., Block is a dome/shield button, Brute is an upward wedge, Counter is a crescent arrow) so players don't rely on text alone.

### Visual Hierarchy (Hero vs. Supporting Shapes)
*   **Bold Outlines**: Characters and monsters use distinct, dark-brown outlines (black is avoided to keep the palette soft) that make them pop from the background.
*   **Receding Environments**: Trees, bushes, and terrains use thin, semi-transparent outlines or soft color boundaries so they sit comfortably in the background.
*   **Shadow Anchors**: Simple, soft circular shadows are drawn beneath active characters and monsters on the grid to ground them.

---

## 4. Color System

This section establishes a warm, producible 2D GBA-style palette system serving both aesthetic and semantic needs.

### Primary Palette (Warm GBA Tones)
*   **Hearth Red** (`#E06D53`): Warm primary red. Represents campfires, cooking heat, high-energy actions, and the Brute Attack stance.
*   **Grass Green** (`#66B032`): Lush, soft green. Represents safety, wildzone gathering spots, herbs, and Grass-type monsters.
*   **Water Blue** (`#4B8EC4`): Soft sky/lake blue. Represents river obstacles, clean water sources, resting states, and the Block stance.
*   **Sun Gold** (`#EBB847`): Soft bright yellow. Represents selection indicators, rare ingredients, player talent nodes, and the Counter-Block stance.
*   **Earth Brown** (`#8B5A2B`): Rich soil brown. Used for player/monster outlines, dirt paths, and campfire logs.
*   **Sky Cream** (`#FAF5E8`): Warm off-white. The base background color for dialogue text boxes and menu boxes to prevent eye strain.

### Semantic Color Vocabulary
*   **Red/Orange**: Active cooking, fire hazards, and attack power.
*   **Blue**: Water purification, defense status, and restorative sleep.
*   **Gold**: Successful counters, selection focus, and unlocked talents.
*   **Deep Purple**: High fatigue (monsters need to rest at camp).

### Biome & State Color Profiles
*   **Towns (Safe Zone)**: High-brightness warm-yellow filter to establish a cozy, sunny, and welcoming feeling.
*   **Forest Routes (Wildzone)**: Rich green mid-tones offset by soft yellow sun patches.
*   **Campfire (Dusk/Night)**: Moody blue-grey ambient lighting overlaid with a strong, circular warm-orange radial glow centered around the campfire.

### UI Palette
*   **Text/Outline**: Dark Brown (`#3C2010`) instead of pure black, making the UI feel warmer and softer.
*   **Frame/Background**: Light Cream (`#FAF5E8`) backgrounds with a double-layered frame of Earth Brown and Sun Gold.

### Accessibility (Colorblind Safety)
*   **Multi-Channel Cues**: Move categories (Block, Counter, Brute) are never distinguished by color alone:
    *   *Block* is always Blue + Dome Icon.
    *   *Brute* is always Red + Upward Triangle Icon.
    *   *Counter* is always Gold + Crescent Arrow Icon.
*   **Cooking States**: Progression changes color from Purple (raw) to Red (cooking) to Gold (perfectly cooked), and is accompanied by distinct bubbling/sizzling particles and sound cues.

---

## 5. Character Design Direction

This section establishes character and monster design rules optimized for GBA-style 2D pixel art.

### Player Character (The Traveler)
*   **Visual Archetype**: A cozy, grid-aligned kid adventurer. Outfitted with an oversized yellow floppy sun hat, a large canvas backpack filled with cooking utensils (pans clanking on the side) and a rolled-up sleeping mat, and sturdy red hiking boots.
*   **Animations**: 
    *   *Grid Movement*: A clean 4-directional walking cycle (up, down, left, right) matching a standard GBA pacing.
    *   *Camp Actions*: Custom mini-sprites for sitting on logs, stirring the cooking pot with a ladle, sleeping in a sleeping bag, and a warm "thumbs up" animation.

### Monster Art Direction (The Companions)
*   **Design Philosophy**: Chibi-style, chunky, and rounded creatures. All sharp edges, fangs, aggressive spikes, or scary claws are forbidden to maintain the kid-friendly vibe. 
*   **Stance/Utility Visual Indicators**:
    *   *Defenders (Block Stance)*: Thick, dome-shaped elements (e.g., shell backs, massive leaf-shields, or hunkered postures).
    *   *Attackers (Brute Stance)*: Triangular forms, heavy front paws, or minor rounded horns.
    *   *Helpers (Utility/Farming)*: Evocative gathering design (e.g., bulbous flower sacks, water-purifying cheek pouches, or fan-like tails for lighting cooking fires).

### Expression & Posing
*   **Micro-Animations**: Exaggerated 2D squash-and-stretch when a monster jumps, runs, or uses a move.
*   **Charming Eyes**: Simple dot or round white eyes. Petted monsters show happy arch eyes (`^^`), and tired monsters display spiral eyes (`@@`) or sweat-drop emojis floating above them.

### Camera Scale & Resolution
*   **Sprite Canvas**: Character and active monster sprites must fit within a **32x32 pixel** grid. Small support creatures (like wild squirrels or birds) fit within a **16x16 pixel** grid.
*   **Simplified Details**: Detail density must match the GBA resolution. Do not draw individual clothing folds, shoe laces, or fingers/toes. Keep features chunky and readable at a distance.

---

## 6. Environment Design Language

This section defines the architectural and tilemap rules to create a cozy, readable 2D environment.

### Architectural Style
*   **Towns (Safe Zones)**: Small wooden and stone cabins with rounded roofs, flower boxes under windows, and rustic wooden fences. The buildings should look soft, handcrafted, and welcoming.
*   **Campsites (Rest Zones)**: A single canvas pop-up tent, flat log stools, a stone fire ring, and string lights or paper lanterns hanging from nearby trees to define the safe campsite perimeter.

### Tile & Texture Philosophy (2D Tilemaps)
*   **Classic 16x16 Tiles**: The world is built using standard 16x16 pixel tiles, following a clean grid structure.
*   **Minimal Noise (No Dithering)**: We avoid noisy, high-contrast pixels in background textures (like grass, dirt, and water) to ensure that monsters and characters remain clearly visible. Color blending is soft and smooth.
*   **Grid Boundaries**: Natural obstacles like tree borders, cliffs, and water edges must clearly define which tiles are passable and which are blocked, preventing children from getting stuck or confused.

### Prop Density Rules
*   **Towns**: Medium density. Details like flower pots, barrels, clotheslines, and wooden signposts make towns feel lived-in but keep path navigation clear.
*   **Wildzones (Routes)**: Very low density on active walkways. Props are pushed to the borders (dense foliage, rock walls) to clearly frame the playable paths.
*   **Campsites**: Low density. Only essential camp items (tent, fire, logs, storage crate) exist to focus attention on the monster interactions.

### Environmental Storytelling (Visual Cues)
*   **Resource Indicators**: Sparkly particle overlays appear on bushes and plants that contain harvestable cooking ingredients (berries, mushrooms).
*   **Visual Safety Guides**: Warm, vertical light shafts filter through trees to highlight safe walking paths.
*   **Signage**: Route signs use clean icons (e.g., a tent icon for campsites, a house icon for towns) instead of text to guide young players.

---

## 7. UI/HUD Visual Direction

This section defines the interface visual standards to ensure readability and accessibility for young players.

### Overworld HUD Style
*   **Minimalist Overlay**: Screen-space HUD is kept small to avoid cluttering. 
    *   *Top-Left*: The active monster's portrait next to a curved, chunky **stamina bar** (color shifts from Green $\rightarrow$ Yellow $\rightarrow$ Red).
    *   *Top-Right*: Current route name in a small wooden frame.
*   **Diegetic Character Cues**: Rather than watching a health bar, players can see their monster's condition directly:
    *   Tired monsters drop their shoulders, walk slower, and emit small sweat drop particles.
    *   Hungry monsters display a small stomach-rumbling emoji bubble.

### Battle UI
*   **Split Layout**: Matches the GBA style. The battle scene takes up the top 70% of the screen, and the commands occupy the bottom 30%.
*   **Cream Commands Panel**: Text and buttons are hosted inside a light cream panel (`#FAF5E8`) with a double Earth Brown border.
*   **Chunky Touch-Friendly Buttons**: Selection buttons are large, square boxes with rounded corners—ideal for tablets and mouse clicks.
*   **Stance Button Designs**:
    *   *Block button*: Shield/Dome icon (Blue theme).
    *   *Brute button*: Sword/Upward wedge icon (Red theme).
    *   *Counter button*: Crescent arrow icon (Gold theme).

### Typography
*   **Primary Font**: A highly readable, retro pixel font with thick weights (e.g., *Press Start 2P* for titles, *m5x7* or *Silkscreen* for body text).
*   **Drop Shadow**: All text has a dark brown (`#3C2010`) drop shadow or thin outline to ensure high contrast against background panels.
*   **Font Scaling**: No text size should fall below 12px equivalent in GBA screen space.

### UI Animation & Transitions
*   **Cozy Spring Bounce**: Menus and dialogue windows slide into view with a gentle spring animation (slight bounce on settle).
*   **Selection Feedback**: Selected buttons scale up by 10% and pulse with a gold outline. Clicked buttons depress downward by 2 pixels.

---

## 8. Asset Standards

This section defines the file format, naming, and technical specifications for assets to ensure seamless integration and web performance in Godot 4.6.

### File Format Requirements
*   **Sprites & Tilesets**: `.png` format. Transparent backgrounds must have clean edges with no alpha bleeding or halo effects.
*   **Audio (Music)**: `.ogg` format (for clean loop points and low compressed sizes on web builds).
*   **Audio (Sound Effects)**: `.wav` format (8-bit or 16-bit, uncompressed, for low-latency triggers in-game).
*   **Fonts**: `.ttf` or `.otf` dynamic pixel fonts.

### Naming Conventions
To keep assets clean and match naming rules in `technical-preferences.md`, use these prefixes:
*   **Sprites**: `spr_[entity]_[action].png` (e.g. `spr_player_walk.png`, `spr_mon_sprout_sleep.png`).
*   **Tilesets**: `tiles_[biome].png` (e.g. `tiles_forest.png`, `tiles_camp.png`).
*   **UI Components**: `ui_[element]_[purpose].png` (e.g. `ui_btn_block.png`, `ui_frame_dialog.png`).
*   **Audio**: `bgm_[theme].ogg` (music), `sfx_[trigger].wav` (sound effect).

### Resolution & Texture Budgets
*   **Grid Base**: 16x16 pixels per tile.
*   **Characters/Monsters**: 32x32 pixels (or 16x16 for small props/creatures).
*   **Viewport Resolution**: Target base canvas is **320x180** (a standard 16:9 pixel aspect ratio that scales cleanly to modern screens).
*   **Stretching**: In Godot Project Settings, use `stretch_mode = viewport` and `stretch_aspect = keep` to prevent sub-pixel rendering.

### Godot 4.6 Import Standards (Guardrails)
*   **Filter: Disabled**: Ensure the import setting `Texture2D -> Filter` is set to **Nearest** (or disabled) to keep pixel art crisp.
*   **Mipmaps: Disabled**: Save texture memory and file size for the web target.
*   **Compression: Lossless**: Never use VRAM compression (like etc2) for 2D pixel art; it introduces blurry artifacts. Use Lossless compression to keep pixels sharp.

---

## 9. Reference Direction & Style Prohibitions

This section compiles visual inspirations, specific elements to draw or avoid from them, and strict rules on what is forbidden in the game's style.

### Reference Sources

| Reference Source | What to Draw From It | What to Explicitly Avoid |
| :--- | :--- | :--- |
| **Pokémon FireRed / LeafGreen (GBA)** | Clean 16x16 grid structure; warm saturation of tilesets; split-screen battle view camera angle; classic GBA font layouts. | Static, unmoving battle sprites (we want active, breathing idle animations); dark, confusing maze-like cave layouts. |
| **The Legend of Zelda: The Minish Cap (GBA)** | Highly expressive character movements (squash and stretch, visual "juice"); vibrant, detailed environment details (trees, flowers). | Real-time action sword combat; complex dungeon puzzle designs. |
| **Cozy Caravan (PC/Web)** | The slow-paced, relaxing road trip feeling; pitching a tent under stars; cooking meals together with monster helpers. | Fully 3D assets and 3D camera controls (Hearth & Horn is strictly flat 2D pixel art). |

### Style Prohibitions (Strict Visual Rules)
*   **No Gritty Realism**: No blood, fangs, raw bone details, aggressive claws, or dark mud. The world must always feel friendly and safe.
*   **No Pure Black Outlines**: Outlines for characters, UI elements, and active monsters must use Dark Earth Brown (`#3C2010`) to keep the visual tone soft and warm. Pure black outlines (`#000000`) are forbidden.
*   **No Blurry Pixel Stretching**: Anti-aliasing, linear filtering, or texture scaling that blurs pixel boundaries is strictly forbidden. Pixels must be sharp and mapped directly to the viewport grid.
*   **No 3D Effects**: Standard 3D lighting, complex normal mapping, or high-fidelity shadows are forbidden. Use simple 2D hand-drawn light overlays for fire glow and soft circles for shadows.

---
