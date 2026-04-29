-- Biter Buddies v2 — Runtime control

------------------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------------------

local BUDDY_NAMES = {
  "small-biter-buddy", "medium-biter-buddy", "big-biter-buddy", "behemoth-biter-buddy",
  "small-spitter-buddy", "medium-spitter-buddy", "big-spitter-buddy", "behemoth-spitter-buddy",
}

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
-- STORAGE
------------------------------------------------------------------------

local function init_storage()
  storage.buddies = storage.buddies or {}       -- [player_index] = { [unit_number] = true }
  storage.buddy_owners = storage.buddy_owners or {}  -- [unit_number] = player_index
  storage.groups = storage.groups or {}         -- [group_id] = LuaCommandable
  -- Remove legacy storage
  storage.selected = nil
end

script.on_init(function()
  init_storage()
end)

script.on_configuration_changed(function()
  init_storage()
  -- Rebuild reverse map if upgrading
  if not next(storage.buddy_owners) then
    for player_index, buddies in pairs(storage.buddies) do
      for unit_number, _ in pairs(buddies) do
        storage.buddy_owners[unit_number] = player_index
      end
    end
  end
  -- Groups don't survive save/load — clear stale references
  storage.groups = {}
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
-- PERSISTENT GROUP MANAGEMENT
------------------------------------------------------------------------

-- Get the persistent group for a whistle item, or create one
local function get_or_create_group(player, whistle_stack)
  local group_id = whistle_stack:get_tag("group_id")

  -- Check if existing group is still valid
  if group_id then
    local group = storage.groups[group_id]
    if group and group.valid then
      return group
    end
    -- Stale reference — clean up
    storage.groups[group_id] = nil
  end

  -- Create a new group for this whistle
  local group = player.surface.create_unit_group{
    position = player.position,
    force = player.force,
  }
  local id = group.unique_id
  storage.groups[id] = group
  whistle_stack:set_tag("group_id", id)
  return group
end

-- Get the group for the whistle currently in the player's cursor
local function get_cursor_whistle_group(player)
  local cursor = player.cursor_stack
  if not cursor or not cursor.valid_for_read or cursor.name ~= "buddy-whistle" then
    return nil, nil
  end
  return get_or_create_group(player, cursor), cursor
end

-- Get valid members of a group
local function get_group_members(group)
  if not group or not group.valid then return {} end
  local members = group.commandable_members
  local result = {}
  for _, member in ipairs(members) do
    if member.valid then
      result[#result + 1] = member
    end
  end
  return result
end

-- Release all members from a group (give them wander command to detach)
local function clear_group(group)
  if not group or not group.valid then return end
  local members = group.commandable_members
  for _, member in ipairs(members) do
    if member.valid then
      member.set_command({
        type = defines.command.wander,
        distraction = defines.distraction.by_enemy,
      })
    end
  end
end

------------------------------------------------------------------------
-- EGG HATCHING
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

script.on_event(defines.events.on_entity_died, function(event)
  if event.entity and event.entity.valid then
    untrack_buddy(event.entity.unit_number)
    -- Engine automatically removes dead unit from its group
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
-- WHISTLE COMMANDS (persistent groups)
------------------------------------------------------------------------

local function area_center(area)
  return {
    x = (area.left_top.x + area.right_bottom.x) / 2,
    y = (area.left_top.y + area.right_bottom.y) / 2,
  }
end

local function find_target_entity(player, position)
  local center_entities = player.surface.find_entities_filtered{
    position = position,
    radius = 2,
    force = {"enemy", "neutral"},
  }
  if #center_entities > 0 then
    return center_entities[1]
  end
  return nil
end

local function make_go_command(target_pos, target_entity)
  if target_entity and target_entity.valid then
    return {
      type = defines.command.go_to_location,
      destination_entity = target_entity,
      distraction = defines.distraction.by_enemy,
      radius = WHISTLE_DESTINATION_RADIUS,
    }
  else
    return {
      type = defines.command.go_to_location,
      destination = target_pos,
      distraction = defines.distraction.by_enemy,
      radius = WHISTLE_DESTINATION_RADIUS,
    }
  end
end

-- Left-click: select buddies (replace group membership)
script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "buddy-whistle" then return end

  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local group, whistle = get_cursor_whistle_group(player)
  if not group then return end

  local my_buddies = filter_player_buddies(player, event.entities)

  -- Clear existing members
  clear_group(group)

  -- Add new selection
  for _, buddy in ipairs(my_buddies) do
    if buddy.valid then
      group.add_member(buddy)
    end
  end

  if #my_buddies > 0 then
    player.print("Selected " .. #my_buddies .. " buddies.")
  else
    player.print("Selection cleared — right-click will command all buddies.")
  end
end)

-- Shift+Left-click: add to group
script.on_event(defines.events.on_player_alt_selected_area, function(event)
  if event.item ~= "buddy-whistle" then return end

  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local group = get_cursor_whistle_group(player)
  if not group then return end

  local my_buddies = filter_player_buddies(player, event.entities)
  if #my_buddies == 0 then return end

  for _, buddy in ipairs(my_buddies) do
    if buddy.valid then
      group.add_member(buddy)
    end
  end

  local count = #get_group_members(group)
  player.print("Selected " .. count .. " buddies.")
end)

-- Right-click: send group to target
script.on_event(defines.events.on_player_reverse_selected_area, function(event)
  if event.item ~= "buddy-whistle" then return end

  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local target_pos = area_center(event.area)
  local target_entity = find_target_entity(player, target_pos)

  local group = get_cursor_whistle_group(player)
  if not group then return end

  local members = get_group_members(group)

  if #members > 0 then
    -- Send the persistent group
    group.set_command(make_go_command(target_pos, target_entity))
  else
    -- No selection — send all buddies via a temporary group
    local all_buddies = get_all_player_buddies(player)
    if #all_buddies == 0 then
      player.print("No buddies to command!")
      return
    end
    local temp_group = player.surface.create_unit_group{
      position = all_buddies[1].position,
      force = player.force,
    }
    for _, buddy in ipairs(all_buddies) do
      if buddy.valid then
        temp_group.add_member(buddy)
      end
    end
    temp_group.set_command(make_go_command(target_pos, target_entity))
  end
end)

-- Shift+Right-click: queue waypoint on persistent group
script.on_event(defines.events.on_player_alt_reverse_selected_area, function(event)
  if event.item ~= "buddy-whistle" then return end

  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local group = get_cursor_whistle_group(player)
  if not group then return end

  local members = get_group_members(group)
  if #members == 0 then
    player.print("No buddies selected to queue command for!")
    return
  end

  local target_pos = area_center(event.area)
  local target_entity = find_target_entity(player, target_pos)
  local waypoint = make_go_command(target_pos, target_entity)

  -- Queue: compound command chains current position → new waypoint
  group.set_command({
    type = defines.command.compound,
    structure_type = defines.compound_command.return_last,
    commands = {
      make_go_command(members[1].position, nil),
      waypoint,
    },
  })
end)

-- Ctrl+click: remove buddy under cursor from group
script.on_event("buddy_whistle_deselect", function(event)
  local player = game.players[event.player_index]
  if not player or not player.valid then return end

  local group = get_cursor_whistle_group(player)
  if not group then return end

  local target = player.selected
  if not target or not target.valid then return end
  if not BUDDY_NAME_SET[target.name] then return end

  -- Remove by giving the unit a wander command (detaches from group)
  target.set_command({
    type = defines.command.wander,
    distraction = defines.distraction.by_enemy,
  })

  local count = #get_group_members(group)
  player.print("Removed from selection. " .. count .. " buddies selected.")
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
