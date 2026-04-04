# Biter Buddies

Hatch your own biter and spitter buddies from throwable eggs! Craft eggs, throw them like grenades, and command your buddy squad with a whistle.

A Factorio 2.0 mod by Andy and Rory. When I started playing Factorio with my son, he came up with the idea for this mod. We programmed it together and released it for everyone!

## Features

- **Throwable eggs** — craft biter and spitter eggs, throw them like grenades. Buddies hatch instantly on impact.
- **Buddy Whistle** — a selection tool for commanding your squad. Left-click to send buddies to a location. Alt-click to recall ALL buddies from anywhere on the map.
- **Toolbar shortcut** — one-click access to equip your whistle.
- **Science-gated progression** — unlock bigger buddies as you advance:
  - Red science: Small Biter Egg
  - Green science: Small Spitter Egg
  - Military science: Medium Biter & Spitter Eggs
  - Space science: Big Biter & Spitter Eggs
  - Metallurgic science (Vulcanus): Behemoth Biter Egg
  - Agricultural science (Gleba): Behemoth Spitter Egg
- **Buddies persist** until killed. No artificial cap on buddy count.
- **Per-player ownership** — in multiplayer, each player commands their own squad.
- **Sparring mode** — press F9 to spawn an enemy biter for testing combat.

## Installation

### From the Mod Portal (recommended)

1. In Factorio, click **Mods** from the main menu
2. Search for **Biter Buddies**
3. Click **Install**

### Manual install

1. Download or build the zip file (`Biter_Buddies_2.0.0.zip`)
2. Copy it to your Factorio mods folder:
   - **Windows:** `%APPDATA%\Factorio\mods\`
   - **Linux:** `~/.factorio/mods/`
   - **macOS:** `~/Library/Application Support/factorio/mods/`
3. Restart Factorio and enable the mod in the Mods menu

### Building from source

```bash
bash build.sh
```

This packages only the required mod files into `dist/Biter_Buddies_<version>.zip`, ready to install or upload.

## Usage

1. Research **Biter Buddies** (red science) to unlock small biter eggs
2. Craft eggs
3. Throw eggs to hatch buddies at the landing spot
4. Equip the Buddy Whistle (or click the toolbar shortcut) and:
   - **Left-click/drag** on terrain to send nearby buddies there
   - **Alt-click/drag** anywhere to recall ALL your buddies to you
5. Press **F9** to spawn a sparring partner

### Console commands for testing

The console display can be toggled with the GRAVE key ( ` )

```
/c remote.call("biter_buddies", "unlock_all")   -- unlock all technologies
/c remote.call("biter_buddies", "give_eggs")     -- give 10 of each egg + whistle
/c remote.call("biter_buddies", "status")        -- show buddy tracking info
/c remote.call("biter_buddies", "count_all")     -- count all buddies on surface
```

## Requirements

- Factorio 2.0+
- Space Age DLC (for behemoth egg technologies only)

## Deployment to Mod Portal

1. Run `bash build.sh` to create the zip
2. Upload to https://mods.factorio.com/
3. The zip must be named `Biter_Buddies_<version>.zip` with the version matching `info.json`
