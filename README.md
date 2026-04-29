# Biter Buddies

### Command Your Loyal Posse

Hatch your own biter and spitter buddies from throwable eggs, then lead a loyal posse that follows you on patrol, defends the base, and charges in on your whistle.

> **A Family Project:** A Factorio 2.0 mod by Andy and son. When I started playing Factorio with my son, he came up with the idea for this mod. We programmed it together and released it for everyone!

## How it Works

Biter Buddies turns the locals from a threat into a posse. Hatch them, name them in your head, and bring them along — they're weird little monster friends who happen to be very good at biting things you point at.

- **Throwable eggs** — Craft biter and spitter eggs, then throw them like grenades. Buddies hatch instantly on impact.
- **Command your posse** — Use the **Buddy Whistle** (like a spidertron remote) to select buddies and send them where you need them — to scout, to defend, or to bite the wild ones who didn't get tamed.
- **Persistent companions** — Your buddies stick around until killed. There's no artificial cap on posse size.
- **Science-gated progression** — Unlock bigger, stronger buddies as you advance through the tech tree, all the way up to Behemoth bugs on Vulcanus and Gleba.
- **Multiplayer ready** — Each player commands their own posse, so per-player ownership is fully supported.

## Playing with Biter Buddies

1. Research **Biter Buddies** (requires red science) to unlock small biter eggs.
2. Craft your eggs and throw them to hatch your buddies.
3. Equip the **Buddy Whistle** (or click the toolbar shortcut) to issue commands:
   - **Left-click/drag** to select which buddies to command.
   - **Shift+Left-click/drag** to add to your selection.
   - **Ctrl+click** a buddy to remove it from your selection.
   - **Right-click** to send selected buddies to that location (if none selected, sends the whole posse).
   - **Shift+Right-click** to queue a move command.
4. **Practice sparring:** Press **F9** to spawn a sparring partner so your posse can stretch its legs.

## Installation

### From the Mod Portal (recommended)
1. In Factorio, click **Mods** from the main menu.
2. Search for **Biter Buddies**.
3. Click **Install**.

### Manual install
1. Download or build the zip file (`Biter_Buddies_2.0.0.zip`).
2. Copy it to your Factorio mods folder:
   - **Windows:** `%APPDATA%\Factorio\mods\`
   - **Linux:** `~/.factorio/mods/`
   - **macOS:** `~/Library/Application Support/factorio/mods/`
3. Restart Factorio and enable the mod in the Mods menu.

## Development & Console Commands

### Building from source
```bash
bash build.sh
```
This packages only the required mod files into `dist/Biter_Buddies_<version>.zip`, ready to install or upload.

### Console commands for testing
The console display can be toggled with the GRAVE key ( ` )
```lua
/c remote.call("biter_buddies", "unlock_all")   -- unlock all technologies
/c remote.call("biter_buddies", "give_eggs")     -- give 10 of each egg + whistle
/c remote.call("biter_buddies", "status")        -- show buddy tracking info
/c remote.call("biter_buddies", "count_all")     -- count all buddies on surface
```

## Requirements
- Factorio 2.0+
- Space Age DLC (for behemoth egg technologies only)
