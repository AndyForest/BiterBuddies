Here are the **new insight logs** I’d add to Soup.net before handing this to Claude Code.

[Log: no buddy cap](https://mcp.soup.net/check?key=cn_s_YYuYKT30Poix4hNaiSMKOGFwOij86xnF&group=factorio-mods&recipe=As%20the%20co-creator%20of%20Biter%20Buddies%2C%20I%20do%20not%20want%20an%20artificial%20cap%20on%20the%20number%20of%20buddies%2C%20because%20the%20joy%20comes%20from%20commanding%20a%20goofy%20little%20squad%20without%20extra%20bookkeeping.&evidence=Interpretation%3A%20Andy%20and%20Rory%20explicitly%20rejected%20caps%20on%20the%20number%20of%20buddies.%0A%3E%20%22No%20need%20for%20any%20caps%20to%20the%20number%20of%20buddies.%22%0A--%20Andy%2C%202026-04-03)

[Log: exact landing matters](https://mcp.soup.net/check?key=cn_s_YYuYKT30Poix4hNaiSMKOGFwOij86xnF&group=factorio-mods&recipe=As%20the%20co-creator%20of%20Biter%20Buddies%2C%20I%20want%20eggs%20to%20spawn%20buddies%20exactly%20where%20they%20land%2C%20because%20throwing%20them%20should%20feel%20tactile%2C%20playful%2C%20and%20slightly%20skillful.&evidence=Interpretation%3A%20Andy%20and%20Rory%20chose%20exact%20impact-location%20spawning.%0A%3E%20%22Yes%2C%20instant%20hatch%20when%20they%20hit%20the%20ground%20after%20being%20thrown.%22%0A--%20Andy%2C%202026-04-03%0A%0AInterpretation%3A%20This%20goes%20with%20the%20throwable-egg%20interaction%20model.%0A%3E%20%22You%20can%20throw%20it%20like%20a%20grenade%20%2F%20defender%20drone%2C%20and%20then%20it%20spawns%20that%20kind%20of%20biter.%22%0A--%20Andy%2C%202026-04-03)

[Log: one whistle command, contextual target](https://mcp.soup.net/check?key=cn_s_YYuYKT30Poix4hNaiSMKOGFwOij86xnF&group=factorio-mods&recipe=As%20the%20co-creator%20of%20Biter%20Buddies%2C%20I%20want%20one%20simple%20whistle%20command%20that%20sends%20buddies%20to%20a%20ground%20location%20or%20to%20follow%20the%20entity%20under%20the%20cursor%2C%20because%20that%20keeps%20controls%20simple%20while%20making%20them%20feel%20smart%20and%20responsive.&evidence=Interpretation%3A%20Andy%20described%20the%20desired%20whistle%20behavior%20as%20a%20single%20%E2%80%9Cgo%20here%E2%80%9D%20command%20with%20special%20handling%20when%20pointing%20at%20an%20entity.%0A%3E%20%22Right%20now%2C%20there%20is%20only%20one%20whistle%20command%2C%20and%20it%20just%20means%20%27go%20here%27.%20Like%20an%20%27attack-move%27%20in%20a%20RTS.%22%0A%3E%20%22If%20your%20mouse%20is%20over%20an%20entity%20when%20you%20trigger%20the%20whistle%2C%20they%20follow%20that%20entity...%20then%20go%20back%20to%20follow.%22%0A--%20Andy%2C%202026-04-03)

[Log: range-limited whistle](https://mcp.soup.net/check?key=cn_s_YYuYKT30Poix4hNaiSMKOGFwOij86xnF&group=factorio-mods&recipe=As%20the%20co-creator%20of%20Biter%20Buddies%2C%20I%20want%20the%20whistle%20command%20to%20affect%20only%20buddies%20within%20a%20radius%2C%20because%20that%20preserves%20the%20current%20feel%20and%20makes%20group%20control%20more%20readable.&evidence=Interpretation%3A%20Andy%20wants%20to%20preserve%20the%20current%20range-based%20whistle%20behavior.%0A%3E%20%22In%20the%20current%20mod%2C%20the%20whistle%20has%20a%20range.%20Any%20biter%20buddies%20in%20that%20range%20obey%20the%20command.%20Keep%20that.%22%0A--%20Andy%2C%202026-04-03)

[Log: lean on built-in unit behavior](https://mcp.soup.net/check?key=cn_s_YYuYKT30Poix4hNaiSMKOGFwOij86xnF&group=factorio-mods&recipe=As%20the%20co-creator%20of%20Biter%20Buddies%2C%20I%20want%20the%20mod%20to%20lean%20heavily%20on%20Factorio%E2%80%99s%20built-in%20unit%20behavior%20and%20commands%20instead%20of%20inventing%20lots%20of%20custom%20AI%2C%20because%20that%20should%20keep%20the%20mod%20simpler%2C%20more%20stable%2C%20and%20more%20naturally%20%E2%80%9CFactorio.%E2%80%9D&evidence=Interpretation%3A%20Andy%20explicitly%20wants%20to%20keep%20the%20mod%20close%20to%20normal%20biter%20behavior%20and%20use%20built-in%20commands%20wherever%20possible.%0A%3E%20%22We%27re%20really%20just%20mostly%20leveraging%20the%20built%20in%20behavior%20of%20normal%20biters%2C%20and%20just%20setting%20their%20%27faction%27%20to%20the%20player%2C%20and%20giving%20them%20built%20in%20commands.%22%0A--%20Andy%2C%202026-04-03)

Here’s the brief for Claude Code.

---

# Biter Buddies 2.0 — implementation brief

## What this mod is

Biter Buddies 2.0 is a playful companion-combat mod for Factorio. The core fantasy is not “optimize an enemy-conversion system.” It is:

* raise and throw **buddy eggs**
* hatch them instantly into **friendly biter/spitter companions**
* command a **goofy little squad**
* keep the controls **simple and whistle-like**
* let the buddies persist and feel like real companions

This should feel closer to a delightful mashup of:

* capsules / grenades / defender bots
* RTS attack-move
* weird little monster pets

It should **not** become a complex biotech pipeline, worker-unit mod, or tactical micromanagement mod.

## First principles

Build toward these constraints:

* **No nest or spawner building** in the main loop.
* **Each egg type is an inventory item.**
* **Small eggs** are hand-craftable.
* **Medium and larger eggs** are assembler-crafted.
* Eggs are **thrown** like a grenade/capsule.
* Eggs **hatch instantly on impact** and spawn the buddy exactly where they land.
* Buddies **persist until killed**.
* **No artificial cap** on buddy count.
* Buddies are primarily **combat companions / protectors**, not labor units.
* Keep a **single main whistle command**.
* Whistle only affects buddies **within range**.
* Whistle behavior:

  * if pointed at terrain: buddies go there, attack-move style
  * if pointed at an entity: buddies follow that entity
  * if aggroed, they can react and attack, then resume following
  * once they reach the target location, they revert to normal roaming behavior
* Preserve the feeling that groups can move in a loose **column / pack**, like wild biters on the move when not actively aggroed.

## Progression ladder

Use this unlock structure unless implementation pressure forces a good reason to deviate:

* **Red / Automation science**: Small Biter Egg
* **Green / Logistic science**: Small Spitter Egg
* **Military science**: Medium Biter Egg, Medium Spitter Egg
* **White / Space science**: Large Biter Egg, Large Spitter Egg
* **Metallurgic science (Vulcanus)**: Behemoth Biter Egg
* **Agricultural science (Gleba)**: Behemoth Spitter Egg

This keeps late-game planet flavor as **science-gate flavor only**, not recipe bloat. The official wiki identifies Metallurgic science as the Vulcanus science pack, Agricultural science as the Gleba science pack, and Space science as the late-game space-tier pack. ([Official Factorio Wiki][1])

## Preferred implementation posture

Lean on built-in Factorio unit behavior as much as possible.

The current official API docs are version **2.0.76**. Runtime control for units and unit groups lives on `LuaCommandable`, which exposes `set_command`, `set_distraction_command`, `add_member`, `set_autonomous`, and `start_moving`. ([Lua API][2])

The command system already supports most of the behaviors we want:

* `go_to_location`
* `attack`
* `attack_area`
* `wander`
* `group`
* `compound`

`go_to_location` supports either a raw `destination` or a `destination_entity`, which maps very well to “go here” versus “follow this entity.” Commands also support `distraction`, and for groups, `wander_in_group=false` makes them move together in the same direction instead of milling individually. ([Lua API][3])

That means the mod should, where practical:

* issue native commands rather than simulating movement manually
* use `destination_entity` for follow-target behavior
* allow default enemy distraction / attack response unless there is a good reason to override it
* consider unit groups for the “pack / column” feel

If grouping helps, `LuaSurface.create_unit_group()` exists, units can be added to a group, and the runtime exposes events around unit-group creation and membership. ([Lua API][4])

## Spawn / throw model

Strong candidate implementation path:

* represent eggs as capsule-like throwable items
* on use / impact, spawn the correct buddy unit at the landing point
* attach ownership / buddy metadata so later whistle commands can find the right units for the right player

Factorio exposes `on_trigger_created_entity` for trigger prototypes such as capsules that create entities, which may be useful if you want to hook the throw-result flow instead of faking everything from scratch. ([Lua API][5])

You should inspect both paths:

1. a true capsule/prototype route
2. a simpler scripted route using the existing mod’s code paths plus runtime spawning

Then choose the one that is simpler and more robust.

## Force / faction handling

The design intent is “friendly to the player, hostile to enemies,” but do not assume the best implementation is literally “put all buddies on player force” without checking side effects.

The runtime exposes `LuaForce`, and Factorio’s default forces are `player`, `enemy`, and `neutral`; mods can also create additional forces. ([Lua API][6])

Please inspect the least-bad implementation for:

* buddies on `player` force
* a custom allied force
* other diplomacy/relationship approaches

I want you to **recipe check** this before locking it, because it is an implementation choice with gameplay consequences.

## Whistle behavior to implement

Implement one main whistle command.

Desired behavior:

* only buddies **within whistle radius** respond
* terrain target: move to target point in attack-move style
* entity target: follow that entity
* units can still react to aggro and attack
* after combat, they resume their last intended follow/move behavior if practical
* when they reach a location target, they go back to normal roaming behavior
* preserve the feeling of a pack moving together rather than scattered nonsense if you can do so without overengineering

For v1, optimize for:

* fun
* clarity
* robustness

Not for perfect tactical control.

## Buddy count

There is **no cap** right now. Do not add one unless a real technical or balance issue forces it.

If performance or control becomes a problem, recipe check before introducing caps or soft limits.

## What to inspect in the existing code

Please audit the existing mod first for anything already useful, especially:

* current whistle targeting and range logic
* current buddy ownership tracking
* current spawn logic
* any existing AI command helpers
* any methods already being used on units/groups that we can preserve
* any simple tricks already working well that should remain

Bias toward **reusing existing working behavior** over rewriting it just because a more abstract architecture is possible.

## What is already in Soup.net and worth reading first

Before implementing, recipe check / inspect existing Biter Buddies recipes around:

* preserve the companion fantasy rather than turning it into a generic combat cheat
* buddies come when called
* keep playful cheat-mod energy
* sparring / on-demand battles are fun
* Rory’s delight outranks strict optimization
* buddies are combat protectors, not labor units
* simple early-game access matters more than planet-hopping realism
* small biters red, small spitters green, mediums military, larges white
* behemoth biters Vulcanus science, behemoth spitters Gleba science
* small items hand-craftable; medium+ assembler-crafted
* eggs as inventory items
* eggs thrown like capsules / grenades
* instant hatch on impact
* persist until killed
* exact landing matters
* no cap
* whistle is range-limited and simple

Those should give you the taste and design boundaries without needing to reconstruct the whole conversation.

## Implementation status (v2.0.0 — 2026-04-04)

### Decisions made (recipe-checked on Soup.net)

* **Force model**: Player force. Simple, minimap-visible, turret-friendly. No custom force.
* **Spawn method**: Capsule items with projectile → `on_script_trigger_effect`. Factorio handles the throw arc.
* **Grouping model**: Temporary unit groups for pack movement on whistle.
* **Sparring mechanic**: Kept as F9 debug hotkey. Fun and free.
* **Spawner building**: Deferred. Eggs only for v2 launch.
* **Save/load**: `storage.buddies[player_index]` tracks unit numbers. Unit group commands are lost on reload (matches vanilla behavior).
* **No stdlib dependency**: Dropped in favor of native Factorio 2.0 `script.on_event`.

* **Multiplayer whistle ownership**: Per-player. Each player commands only their own hatched buddies.
* **Global recall**: Alt-click with whistle recalls ALL player's buddies from anywhere on the surface.
* **Whistle tool**: Selection tool item (Buddy Whistle) with toolbar shortcut button. Replaces F8 hotkey. Left-click = command buddies to area. Alt-click = global recall. Unlocked with first tech.

### Open decisions (need Andy/Rory input via Soup.net recipe checks)

* **Whistle radius UI**: Should the selection area have any maximum range, or is unlimited fine?
* **Performance strategy**: No cap, no throttling. Fine until someone has 500 buddies.

### What recipe checks are still needed

Before next iteration, recipe check:

* **Egg art / projectile visuals** — currently using acid-projectile placeholder sprites
* **Recipe balance** — ingredient costs may need tuning after playtesting

### File structure

```
data.lua        — Prototypes: buddy entities, egg capsules, projectiles, recipes, technologies, hotkeys
control.lua     — Runtime: egg hatching, buddy tracking, whistle commands, sparring, remote test interface
info.json       — Mod metadata (v2.0.0, Factorio 2.0)
locale/en/      — English locale strings for all items, entities, recipes, technologies
build.sh        — Packages mod into distributable zip
docs/           — This design brief
```

### Testing interface

In-game console commands via remote interface:
```
/c remote.call(“biter_buddies”, “give_eggs”)     -- 10 of each egg type
/c remote.call(“biter_buddies”, “unlock_all”)     -- unlock all technologies
/c remote.call(“biter_buddies”, “status”)         -- show buddy tracking state
/c remote.call(“biter_buddies”, “count_all”)      -- count all buddies on surface
```

### Creative coaching note

Protect the mod’s weird joy.

If a technically elegant choice makes the mod feel less like:

* throwing monster eggs
* hatching instant friends
* commanding a chaotic buddy squad

then it is probably the wrong choice unless it solves a truly serious problem.

The best version of this mod will feel like “of course this is silly,” not “of course this is architecturally pure.”

[1]: https://wiki.factorio.com/Metallurgic_science_pack?utm_source=chatgpt.com “Metallurgic science pack - Factorio Wiki”
[2]: https://lua-api.factorio.com/?utm_source=chatgpt.com “API Docs | Factorio”
[3]: https://lua-api.factorio.com/latest/concepts/Command.html “Command - Runtime Docs | Factorio”
[4]: https://lua-api.factorio.com/latest/classes/LuaSurface.html?utm_source=chatgpt.com “LuaSurface - Runtime Docs”
[5]: https://lua-api.factorio.com/latest/events.html “Events - Runtime Docs | Factorio”
[6]: https://lua-api.factorio.com/latest/classes/LuaForce.html?utm_source=chatgpt.com “LuaForce - Runtime Docs”
