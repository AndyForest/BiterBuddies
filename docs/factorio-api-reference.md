# Factorio 2.0 API Reference — Biter Buddies

Key API findings for this mod. Version 2.0.76. Verify links when Factorio updates.

## Unit Groups & Commands

### LuaCommandable (units and unit groups)
- [LuaCommandable docs](https://lua-api.factorio.com/latest/classes/LuaCommandable.html)
- `set_command(command)` — issue a command to a unit or group
- `add_member(member)` — add a unit to a group. Same effect as `defines.command.group`
- `commandable_members` — get direct members (non-recursive)
- `parent_group` — read-only, the group this unit belongs to (implies **single group membership**)
- `unique_id` — uint32, persistent identifier for a commandable
- `set_autonomous(autonomous)` — whether the unit acts on its own
- **A unit can only be in one group at a time.** Adding to a new group auto-removes from the old one.
- **Unit groups do NOT survive save/load.** Commands and group membership are lost on reload.

### Command types
- [Command docs](https://lua-api.factorio.com/latest/concepts/Command.html)
- `go_to_location` — move to position or entity. Fields: `destination` OR `destination_entity`, `distraction`, `radius`, `pathfind_flags`
- `compound` — chain commands. Fields: `structure_type` (sequential/return_last), `commands` (array)
- `attack`, `attack_area`, `wander`, `group` — other command types
- `distraction` defaults to `defines.distraction.by_enemy`

### LuaSurface.create_unit_group
- [LuaSurface docs](https://lua-api.factorio.com/latest/classes/LuaSurface.html)
- Params: `position` (required), `force` (optional, defaults to "enemy")
- Returns: `LuaCommandable`

## Selection Tool

### SelectionToolPrototype
- [SelectionToolPrototype docs](https://lua-api.factorio.com/latest/prototypes/SelectionToolPrototype.html)
- Required: `select`, `alt_select` (both are `SelectionModeData`)
- Optional: `reverse_select`, `alt_reverse_select`, `super_forced_select`

### Input mapping (confusing names — "alt" means "shift", not the Alt key)
| API field | Actual input | Event |
|---|---|---|
| `select` | Left-click drag | `on_player_selected_area` |
| `alt_select` | **Shift**+Left-click drag | `on_player_alt_selected_area` |
| `reverse_select` | Right-click drag | `on_player_reverse_selected_area` |
| `alt_reverse_select` | **Shift**+Right-click drag | `on_player_alt_reverse_selected_area` |
| `super_forced_select` | Unknown (no event exists) | N/A |

### SelectionModeData
- [SelectionModeData docs](https://lua-api.factorio.com/latest/types/SelectionModeData.html)
- Required: `border_color`, `cursor_box_type`, `mode`
- Optional: `entity_filters`, `entity_type_filters`, `entity_filter_mode`

### Selection events — all share these fields:
- `player_index`, `surface`, `area` (BoundingBox), `item` (string), `entities` (array), `tiles`

## Items & Shortcuts

### Item flags
- [ItemPrototypeFlags docs](https://lua-api.factorio.com/latest/types/ItemPrototypeFlags.html)
- `"spawnable"` — required for `ShortcutPrototype` with `action = "spawn-item"`
- `"only-in-cursor"` — item can't be placed in normal inventory slots
- `"not-stackable"` — stack size 1

### ShortcutPrototype
- [ShortcutPrototype docs](https://lua-api.factorio.com/latest/prototypes/ShortcutPrototype.html)
- `action = "spawn-item"` requires `item_to_spawn` and item must have `"spawnable"` flag

## Capsules & Projectiles

### CapsulePrototype
- [CapsulePrototype docs](https://lua-api.factorio.com/latest/prototypes/CapsulePrototype.html)
- `capsule_action.type = "throw"` — `attack_parameters` required
- Projectile action can include `type = "script"` with `effect_id` for `on_script_trigger_effect`

### on_script_trigger_effect
- [Events docs](https://lua-api.factorio.com/latest/events.html)
- Fields: `effect_id`, `surface_index` (non-optional), `target_position` (optional), `source_entity` (optional)
- `source_entity` is the player's character entity, not a LuaPlayer

## Entity & Force

### Getting player from character entity
- `entity.type == "character"` then `entity.player` — returns `LuaPlayer` or nil
- Do NOT use `is_player()` — that's on `LuaControl`, not `LuaEntity`

### Unit prototypes (1.1 → 2.0 changes)
- `pollution_to_join_attack` → `absorptions_to_join_attack = {pollution = N}`
- `global` → `storage` for mod persistent data

### Event filters
- `on_entity_died` supports name filters: `{filter = "name", name = "entity-name"}`
- Filters let the engine skip the Lua callback entirely for non-matching entities

## Custom Inputs
- [CustomInputPrototype docs](https://lua-api.factorio.com/latest/prototypes/CustomInputPrototype.html)
- Mouse buttons: `mouse-button-1` through `mouse-button-9`
- Modifiers: `"CONTROL"`, `"SHIFT"`, `"ALT"`, `"COMMAND"`
- Example: `"CONTROL + mouse-button-1"`
