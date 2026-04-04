-- Biter Buddies v2 — Runtime control

------------------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------------------

local BUDDY_NAMES = {
  "small-biter-buddy", "medium-biter-buddy", "big-biter-buddy", "behemoth-biter-buddy",
  "small-spitter-buddy", "medium-spitter-buddy", "big-spitter-buddy", "behemoth-spitter-buddy",
}

-- Derived from BUDDY_NAMES: trigger effect_id -> buddy entity name
local TRIGGER_TO_BUDDY = {}
local BUDDY_NAME_SET = {}
local ENTITY_DIED_FILTERS = {}
for _, name in ipairs(BUDDY_NAMES) do
  TRIGGER_TO_BUDDY["spawn-" .. name] = name
  BUDDY_NAME_SET[name] = true
  ENTITY_DIED_FILTERS[#ENTITY_DIED_FILTERS + 1] = {filter = "name", name = name}
end

local WHISTLE_DESTINATION_RADIUS = 5

------------------------------------------------------------------------
-- STORAGE INITIALIZATION
------------------------------------------------------------------------

local function init_storage()
  storage.buddies = storage.buddies or {}       -- [player_index] = { [unit_number] = true }
  storage.buddy_owners = storage.buddy_owners or {}  -- [unit_number] = player_index (reverse lookup)
end

script.on_init(function()
  init_storage()
end)

script.on_configuration_changed(function()
  init_storage()
  -- Rebuild reverse map if upgrading from a version that didn't have it
  if not next(storage.buddy_owners) then
    for player_index, buddies in pairs(storage.buddies) do
      for unit_number, _ in pairs(buddies) do
        storage.buddy_owners[unit_number] = player_index
      end
    end
  end
end)

------------------------------------------------------------------------
-- BUDDY TRACKING
------------------------------------------------------------------------

local function track_buddy(player_index, unit)
  if not storage.buddies[player_index] then
    storage.buddies[player_index] = {}
  end
  storage.buddies[player_index][unit.unit_number] = true
  storage.buddy_owners[unit.unit_number] = player_index
end

local function untrack_buddy(unit_number)
  local player_index = storage.buddy_owners[unit_number]
  if player_index and storage.buddies[player_index] then
    storage.buddies[player_index][unit_number] = nil
  end
  storage.buddy_owners[unit_number] = nil
end

local function get_all_player_buddies(player)
  local player_buddies = storage.buddies[player.index]
  if not player_buddies then return {} end

  local entities = player.surface.find_entities_filtered{
    name = BUDDY_NAMES,
    force = player.force,
  }

  local result = {}
  for _, entity in ipairs(entities) do
    if entity.valid and player_buddies[entity.unit_number] then
      result[#result + 1] = entity
    end
  end
  return result
end

local function filter_player_buddies(player, entities)
  local player_buddies = storage.buddies[player.index]
  if not player_buddies then return {} end

  local result = {}
  for _, entity in ipairs(entities) do
    if entity.valid and player_buddies[entity.unit_number] then
      result[#result + 1] = entity
    end
  end
  return result
end

------------------------------------------------------------------------
-- EGG HATCHING (capsule impact -> buddy spawn)
------------------------------------------------------------------------

script.on_event(defines.events.on_script_trigger_effect, function(event)
  local buddy_name = TRIGGER_TO_BUDDY[event.effect_id]
  if not buddy_name then return end

  local surface = event.surface_index and game.surfaces[event.surface_index]
  if not surface then return end

  local position = event.target_position
  if not position then return end

  local player_index = nil
  if event.source_entity and event.source_entity.type == "character" then
    local p = event.source_entity.player
    if p then player_index = p.index end
  end

  local force = game.forces.player
  if player_index then
    force = game.players[player_index].force
  end

  local buddy = surface.create_entity{
    name = buddy_name,
    position = position,
    force = force,
  }

  if buddy and player_index then
    track_buddy(player_index, buddy)
  end
end)

------------------------------------------------------------------------
-- BUDDY CLEANUP
------------------------------------------------------------------------

-- Engine-filtered: only fires for buddy entity deaths
script.on_event(defines.events.on_entity_died, function(event)
  if event.entity and event.entity.valid then
    untrack_buddy(event.entity.unit_number)
  end
end, ENTITY_DIED_FILTERS)

script.on_event(defines.events.on_player_removed, function(event)
  local player_buddies = storage.buddies[event.player_index]
  if player_buddies then
    for unit_number, _ in pairs(player_buddies) do
      storage.buddy_owners[unit_number] = nil
    end
  end
  storage.buddies[event.player_index] = nil
end)

------------------------------------------------------------------------
-- WHISTLE COMMAND (selection tool)
------------------------------------------------------------------------

local function command_buddies(player, buddies, target_pos, target_entity)
  if #buddies == 0 then return end

  local group = player.surface.create_unit_group{
    position = buddies[1].position,
    force = player.force,
  }
  for _, buddy in ipairs(buddies) do
    if buddy.valid then
      group.add_member(buddy)
    end
  end

  if target_entity and target_entity.valid then
    group.set_command({
      type = defines.command.go_to_location,
      destination_entity = target_entity,
      distraction = defines.distraction.by_enemy,
      radius = WHISTLE_DESTINATION_RADIUS,
    })
  elseif target_pos then
    group.set_command({
      type = defines.command.go_to_location,
      destination = target_pos,
      distraction = defines.distraction.by_enemy,
      radius = WHISTLE_DESTINATION_RADIUS,
    })
  end
end

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "buddy-whistle" then return end

  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local area = event.area
  local target_pos = {
    x = (area.left_top.x + area.right_bottom.x) / 2,
    y = (area.left_top.y + area.right_bottom.y) / 2,
  }

  -- Check for enemy/neutral entity near center for follow behavior
  local target_entity = nil
  local center_entities = player.surface.find_entities_filtered{
    position = target_pos,
    radius = 2,
    force = {"enemy", "neutral"},
  }
  if #center_entities > 0 then
    target_entity = center_entities[1]
  end

  local selected_buddies = filter_player_buddies(player, event.entities)

  if #selected_buddies > 0 then
    command_buddies(player, selected_buddies, target_pos, target_entity)
  else
    local all_buddies = get_all_player_buddies(player)
    if #all_buddies == 0 then
      player.print("No buddies to command!")
      return
    end
    command_buddies(player, all_buddies, target_pos, target_entity)
  end
end)

-- Alt-click: global recall
script.on_event(defines.events.on_player_alt_selected_area, function(event)
  if event.item ~= "buddy-whistle" then return end

  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local all_buddies = get_all_player_buddies(player)
  if #all_buddies == 0 then
    player.print("No buddies to recall!")
    return
  end

  command_buddies(player, all_buddies, player.position, nil)
  player.print("Recalled " .. #all_buddies .. " buddies!")
end)

------------------------------------------------------------------------
-- REMOTE INTERFACE (testing)
------------------------------------------------------------------------

remote.add_interface("biter_buddies", {
  status = function()
    local player = game.player
    if not player then return end
    local tracked = 0
    local player_buddies = storage.buddies[player.index] or {}
    for _ in pairs(player_buddies) do
      tracked = tracked + 1
    end
    local alive = #get_all_player_buddies(player)
    player.print("Buddy tracking: " .. tracked .. " tracked, " .. alive .. " alive on surface")
  end,

  give_eggs = function()
    local player = game.player
    if not player then return end
    for _, name in ipairs(BUDDY_NAMES) do
      player.insert{name = name:gsub("-buddy", "-egg"), count = 10}
    end
    player.insert{name = "buddy-whistle", count = 1}
    player.print("Gave 10 of each egg type + a buddy whistle!")
  end,

  unlock_all = function()
    local player = game.player
    if not player then return end
    for name, tech in pairs(player.force.technologies) do
      if name:find("^biter%-buddies%-") then
        tech.researched = true
      end
    end
    player.print("All buddy technologies unlocked!")
  end,

  count_all = function()
    local player = game.player
    if not player then return end
    local entities = player.surface.find_entities_filtered{
      name = BUDDY_NAMES,
      force = player.force,
    }
    local counts = {}
    for _, e in ipairs(entities) do
      counts[e.name] = (counts[e.name] or 0) + 1
    end
    player.print("All buddies on surface:")
    for name, c in pairs(counts) do
      player.print("  " .. name .. ": " .. c)
    end
    if next(counts) == nil then
      player.print("  (none)")
    end
  end,
})

------------------------------------------------------------------------
-- SPARRING (F9)
------------------------------------------------------------------------

script.on_event("spawn_biter_enemy_buddy_hotkey", function(event)
  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local p = player.position
  local x_offset = math.random(-50, 50)
  local y_offset = math.random(-50, 50)
  if math.abs(x_offset) < 10 then x_offset = (x_offset >= 0 and 10 or -10) end
  if math.abs(y_offset) < 10 then y_offset = (y_offset >= 0 and 10 or -10) end

  player.surface.create_entity{
    name = "behemoth-biter-buddy",
    position = {p.x + x_offset, p.y + y_offset},
    force = "enemy",
  }
end)
