local Event = require('__stdlib__/stdlib/event/event')
local buddies = {"small-biter-buddy", "medium-biter-buddy", "big-biter-buddy", "behemoth-biter-buddy", "small-spitter-buddy", "medium-spitter-buddy", "big-spitter-buddy", "behemoth-spitter-buddy"}

local function spawn_buddy(event)
    
    local s = game.surfaces['nauvis'] 
    local player = game.players[event.player_index]
    local p = player.position
    local x_offset
    local y_offset
    
    --player.print("spawn_buddy")

    local buddyGroup = s.create_unit_group{position = p, force = game.forces['player'], name = "biter-buddy-group"}
    
    for i, name in ipairs(buddies) do
        -- local p = {0,0} 
        y_offset = math.random(-10, 10)
        if math.abs(y_offset) < 3 then y_offset = 3 end
        x_offset = math.random(-10, 10)
        if math.abs(x_offset) < 3 then x_offset = 3 end
        local bp = {p.x + x_offset, p.y + y_offset}
        -- s.create_entity{name = buddies[i], position = bp, force = game.forces['player']}
        buddyGroup.add_member(s.create_entity{name = buddies[i], position = bp, force = game.forces['player']})
    end
end

Event.register("spawn_biter_buddy_hotkey", function(event) spawn_buddy(event) end)

local function spawn_enemy(event)
    local s = game.surfaces['nauvis'] 
    local player = game.players[event.player_index]
    local p = player.position
    local x_offset
    local y_offset
    for i = 1, 1, 1 do
        -- local p = {0,0} 
        y_offset = math.random(-100, 100)
        if math.abs(y_offset) < 10 then y_offset = 10 end
        x_offset = math.random(-100, 100)
        if math.abs(x_offset) < 10 then x_offset = 10 end
        local bp = {p.x + x_offset, p.y + y_offset}
        s.create_entity{name = "behemoth-biter-buddy", position = bp, force = game.forces['enemy']}
    end
end

Event.register("spawn_biter_enemy_buddy_hotkey", function(event) spawn_enemy(event) end)

local function targetBiterBuddies(event)
    
    local mySurface = game.surfaces['nauvis'] 
    local s = game.surfaces['nauvis'] 
    local player = game.players[event.player_index]
    local p = player.position
    local myForce = game.forces['player']

    --player.print("targetBiterBuddies")

    local chunkposition =  {p.x /32, p.y /32}
    --local myGroups = mySurface.get_entities_with_force(chunkposition, myForce)
    local myGroups = mySurface.find_entities_filtered{position = p, radius = 500, name = buddies}
    -- force = myForce}
    -- name = "biter-buddy-group"}

    for i, thisEntity in ipairs(myGroups) do
        --player.print(thisEntity.name)

        thisEntity.set_command({type = defines.command.go_to_location, 
         destination = p,
         distraction = defines.distraction.none,
         --pathfind_flags = {
         --   allow_destroy_friendly_entities  = false,
         --   allow_paths_through_own_entities =false,
         --   cache = false,
         --   prefer_straight_paths = true,
         --   low_priority =false,
         --   no_break  = true
         --},
         radius = 10
         })

    end

    
end

Event.register("summon_biter_buddies_hotkey", function(event) targetBiterBuddies(event) end)

--[[
script.on_event(defines.events.on_put_item, function(event)
	local current_tick = event.tick
	if global.tick and global.tick > current_tick then
		return
	end
	global.tick = current_tick + 10
	local player = game.players[event.player_index]
	if isHolding({name = "biter-buddy-remote", count = 1}, player) and player.force.is_chunk_charted(player.surface, Chunk.from_position(event.position)) then
		targetBiterBuddies(player.force, event.position, player.surface, player)
		player.cursor_stack.clear()
		global.holding_targeter[event.player_index] = true
		player.cursor_stack.set_stack({name = "biter-buddy-remote", count = 1})
	end
end)
--]]