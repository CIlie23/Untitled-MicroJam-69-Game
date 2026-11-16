# Untitled-MicroJam-69-Game

Made for MicroJam 69 (nice).

A top-down survivor game about a skeleton with two souls fighting for control of one body.

---

## The Game

You are a **Worthless Skelly**: a skeleton with two souls crammed inside it. One is you. The other is a rival soul that wants the body for itself and will do anything to take it.

Survive waves of enemies, grow stronger, and keep fighting off the other soul for control. The stronger you get, the weaker the other soul becomes, and vice versa. Every kill pushes the balance one way or the other.

### Visual Style

- Vampire Survivors-style top-down gameplay
- Visual concepts from Don't Starve Together
- Pixel art

### Core Loop

1. Move with **WASD**. Your weapons attack automatically.
2. Kill enemies. They drop **Soul Shards**.
3. Collect shards to gain XP and level up.
4. On each level-up, pick one of three upgrades from the card screen.
5. Every few levels, choose an **Evolution** that changes how you play.
6. Survive the timer and defeat the boss.

### The Two-Soul Mechanic

Both souls share the same body, and a **versus bar** shows who is winning.

- **Your soul** is the one you control. Your kills make you stronger and push the bar in your favour.
- **The other soul** is aggressive. From time to time it takes over the body, walks around by itself, attacks anything nearby, and gets stronger from its own kills.
- **Taking control back:** while the other soul has the wheel, you must fight to regain control through a minigame. Two options are being considered:
  - **Type words or mash keys.** Type random words (Latin words would fit the theme) or press prompted keys.
  - **Catch the letters.** Drag letters into the correct slots with the mouse while the letters try to run away from the cursor.
- **Shared XP:** the other soul levels up as you do. When you grow stronger, so does your rival, since you share a body.
- **Winning the struggle:** push the versus bar all the way to the left to push the other soul out of the body for good.

### Progression and Evolutions

You start with one weak bone throw. Stats improve every level, and every 5 levels you pick an evolution. Each stage has 2-3 or more variations.

Evolution line: **Skelly → Bone Knight → Lich → Death Lord**

Early evolution options include **Bone Mage**, **Grave Knight** and **Plague Skelly**.

As a **Lich** you automatically raise a capped skeleton army from defeated enemies.

### Weapons and Items

- Two weapon types: **slash** (melee) and the **evolution weapon** (ranged or special)
- Melee items and ranged items, each showing its **cooldown** on screen
- Items and modifiers are tied to the **card system**: the screen where you pick your items on level-up
- Buffs and variations for items

### Enemies

- 3 or more enemy types to start, with more added over time
- Enemies gain strength as the run goes on
- Mini-bosses every 5 minutes grant a big XP boost

### Bosses and Ending

- Run length is roughly 8 to 15 minutes, with a 15 minute timer.
- Defeating the other soul triggers a cutscene. The other soul says it found something better and runs off.
- You then fight the **final boss** (the Inquisitor or the Crypt Warden). The boss uses items and abilities of its own.

### Audio and Presentation

- Sound effects and music
- Opening cutscene and tutorial
- Death screen
- Settings menu and credits

---

## Roadmap

### Planned

- [ ] Other soul AI: walks around on its own, attacks enemies, very aggressive
- [ ] Soul struggle minigame (type words / drag fleeing letters)
- [ ] Shared XP: the other soul levels up with the player
- [ ] More enemy types
- [ ] Items, modifiers and variations connected to the card system
- [ ] Ranged and melee items with cooldown display
- [ ] Evolutions and the Lich skeleton army
- [ ] Mini-bosses every 5 minutes
- [ ] Final boss with its own items, tied to the cutscene
- [ ] Death screen
- [ ] Finish settings menu and credits
- [ ] Sound effects and music
- [ ] Cutscenes and tutorial
- [ ] Sprites

### Open Questions

- Which minigame fits better for taking control back: typing words or catching fleeing letters?
- Which final boss: the Inquisitor or the Crypt Warden?
- Run length: 8-15 minutes, or the fixed 15 minute timer?

---

## Adding Content in the Editor

The project already has an item and enemy resource system in place.

To add a weapon or an enemy:

1. In the Inspector, create a new Resource and search for **Weapon** or **Enemy**.
2. Fill in its fields, then **save** it as a `.tres` file in `data/`.
3. To spawn a new enemy, open the **Spawner** node and find **Enemy Types**.
4. Set **Size** to the number of enemy types you are adding.
5. Drag and drop each enemy resource into the new slots.

---

## Project Structure Guide

This project follows a **feature-oriented (contextual)** organization. Related scenes, scripts, and entity-specific assets are kept together rather than split into disparate top-level folders.

## Directory Overview

```
res://
├── assets/                  # Shared raw assets
│   ├── audio/               # Background music and shared sound effects
│   ├── fonts/               # Typography files (.ttf, .otf, FontFile resources)
│   ├── shaders/             # Reusable visual and canvas shaders (.gdshader)
│   └── textures/            # Shared textures, environment sprites, icons
│
├── data/                    # Concrete custom Resource instances (.tres files)
│   ├── items/               # Equipment, consumable, and inventory data
│   └── stats/               # Unit stats, balancing numbers, attribute configs
│
└── src/                     # Game logic, scenes, and mechanics
    ├── autoload/            # Global singletons (Event bus, persistent state)
    ├── common/              # Shared base systems and utilities
    │   ├── components/      # Reusable sub-nodes (Hitbox, Hurtbox, Health)
    │   ├── resources/       # Custom Resource definitions (class_name ... extends Resource)
    │   └── utils/           # Pure functional helpers, math libs, constants
    ├── entities/            # In-game dynamic actors (player, NPCs, enemies)
    ├── levels/              # Playable maps, rooms, arenas, and level logic
    └── ui/                  # User interface scenes and menus

```

## What Goes Where?

### 1. `assets/` (Shared Media)

- **Rule:** Store only media used across multiple entities or systems.

- **Examples:** Default UI fonts, ambient music, environmental tilesets, footstep audio, global particle textures.

- **Note:** If an asset belongs strictly to one actor (e.g., a boss's bespoke sprite sheet), keep it inside that actor's folder in `src/entities/`.

### 2. `data/` (Concrete Resources)

- Stores `.tres` (Text Resource) data instances created in the inspector.

- Keeps tuning, balancing numbers, and database-style entries out of code and separated from scene graphs.

### 3. `src/autoload/` (Singletons)

- **Keep minimal.** Use primarily for:
  - **Event Bus** (`events.gd`) for broadcast signals between distant nodes.

  - **Global State** (`game_state.gd`) for session flags, settings, or scene transitions.

- Avoid dumping gameplay logic or actor references into autoloads.

### 4. `src/common/` (Shared Building Blocks)

- **`components/`**: Modular logic nodes attached to entities (e.g., `HealthComponent.tscn`, `Hitbox.tscn`, `InteractionArea.tscn`).

- **`resources/`**: Script definitions for resources (e.g., `item_data.gd`, `enemy_stats.gd`).

- **`utils/`**: Stateless helper classes with static functions (e.g., vector math, save-file serialization).

### 5. `src/entities/` (Actors)

- Co-locate an entity's `.tscn`, `.gd`, local assets, and sub-systems in the same folder:

  ```
  entities/player/
  ├── player.tscn
  ├── player.gd
  ├── player_sprite.png
  └── states/
      ├── idle_state.gd
      └── move_state.gd

  ```

### 6. `src/levels/` (Scenes & Environments)

- Playable spaces, scene composition, and level-specific scripting (e.g., `level_01.tscn`, `arena_boss.tscn`).

### 7. `src/ui/` (Interface)

- **`menus/`**: Fullscreen flows like `main_menu.tscn`, `options_menu.tscn`, `game_over.tscn`.

- **`hud/`**: In-game overlays like health bars, inventories, minimaps, and hotbars.

## Architecture Conventions

- **Co-location:** Always keep a scene and its primary script together in the same directory with matching names (`my_node.tscn` and `my_node.gd`).

- **Signal Up, Call Down:** A parent can call child methods directly (`$Hurtbox.take_damage()`), but children should notify parents via signals (`signal health_depleted`) to prevent tight coupling.
