local Entity = require('__stdlib__/stdlib/entity/entity')
local Inventory = require('__stdlib__/stdlib/entity/inventory')

-- Initialize the pseudo random number generator
--global.generator = game.create_random_generator()

local smallbiterBuddy = table.deepcopy(data.raw.unit["small-biter"])
smallbiterBuddy.pollution_to_join_attack = 1000
smallbiterBuddy.name = "small-biter-buddy"
data:extend{smallbiterBuddy}

local tank_base = table.deepcopy(data.raw.car.tank)

local mediumbiterBuddy = table.deepcopy(data.raw.unit["medium-biter"])
mediumbiterBuddy.pollution_to_join_attack = 1000
mediumbiterBuddy.name = "medium-biter-buddy"
mediumbiterBuddy.selectable_in_game = true
inventory_size = 4
data:extend{mediumbiterBuddy}

local bigbiterBuddy = table.deepcopy(data.raw.unit["big-biter"])
bigbiterBuddy.pollution_to_join_attack = 1000
bigbiterBuddy.name = "big-biter-buddy"
data:extend{bigbiterBuddy}

local behemothbiterBuddy = table.deepcopy(data.raw.unit["behemoth-biter"])
behemothbiterBuddy.pollution_to_join_attack = 1000
behemothbiterBuddy.name = "behemoth-biter-buddy"
data:extend{behemothbiterBuddy}

local smallspitterBuddy = table.deepcopy(data.raw.unit["small-spitter"])
smallspitterBuddy.pollution_to_join_attack = 1000
smallspitterBuddy.name = "small-spitter-buddy"
data:extend{smallspitterBuddy}

local mediumspitterBuddy = table.deepcopy(data.raw.unit["medium-spitter"])
mediumspitterBuddy.pollution_to_join_attack = 1000
mediumspitterBuddy.name = "medium-spitter-buddy"
data:extend{mediumspitterBuddy}

local bigspitterBuddy = table.deepcopy(data.raw.unit["big-spitter"])
bigspitterBuddy.pollution_to_join_attack = 1000
bigspitterBuddy.name = "big-spitter-buddy"
data:extend{bigspitterBuddy}

local behemothspitterBuddy = table.deepcopy(data.raw.unit["behemoth-spitter"])
behemothspitterBuddy.pollution_to_join_attack = 1000
behemothspitterBuddy.name = "behemoth-spitter-buddy"
data:extend{behemothspitterBuddy}

local buddyRemote = table.deepcopy(data.raw.recipe["spidertron-remote"])
buddyRemote.name = "biter-buddy-remote"
data:extend{buddyRemote}


data:extend(
   {
      {
         type = "custom-input",
         name = "spawn_biter_buddy_hotkey",
         key_sequence = "F7",
         consuming = "none"
      },
   }
)

data:extend(
   {
      {
         type = "custom-input",
         name = "spawn_biter_enemy_buddy_hotkey",
         key_sequence = "F9",
         consuming = "none"
      },
   }
)

data:extend(
   {
      {
         type = "custom-input",
         name = "summon_biter_buddies_hotkey",
         key_sequence = "F8",
         consuming = "none"
      },
   }
)

-- local recipe = table.deepcopy(data.raw["recipe"]["stone-furnace"])
-- recipe.enabled = true
-- recipe.name = "biter-buddy"
-- recipe.result = "biter-buddy"
-- data:extend{biterBuddy,recipe}

local make_unit = function(k)

    local shift = {(math.random() - 0.5) / 1.5, (math.random() - 0.5) / 1.5}
    --local sprite_base = util.copy(sprite_base)
    --util.recursive_hack_make_hr(sprite_base)
    --util.recursive_hack_scale(sprite_base, 0.4 + (math.random()/ 20))
    --util.recursive_hack_shift(sprite_base, shift)
  
    local selection_box =
    {
      {
        -0.3 + shift[1],
        -0.3 + shift[2],
      },
      {
        0.3 + shift[1],
        0.3 + shift[2],
      }
    }
  
    local darkness = 0.3  + math.random() / 5
  
    local unit =
    {
      type = "unit",
      name = name.."-"..k,
      localised_name = {name},
      icon = util.path("data/entities/transport_drone/transport-drone-icon.png"),
      icon_size = 112,
      icon_mipmaps = 0,
      flags = transport_drone_flags,
      map_color = {b = 0.5, g = 1},
      enemy_map_color = {r = 1},
      max_health = 50,
      radar_range = 1,
      order="i-d",
      subgroup = "transport",
      resistances =
      {
        {
          type = "acid",
          decrease = 0,
          percent = 90
        }
      },
      healing_per_tick = 0.1,
      --minable = {result = name, mining_time = 2},
      collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
      selection_box = selection_box,
      sticker_box = {shift, shift},
      collision_mask = shared.drone_collision_mask,
      max_pursue_distance = 64,
      min_persue_time = (60 * 15),
      --sticker_box = {{-0.2, -0.2}, {0.2, 0.2}},
      distraction_cooldown = (15),
      move_while_shooting = true,
      can_open_gates = true,
      ai_settings =
      {
        do_separation = false
      },
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "bullet",
        warmup = 0,
        cooldown = 2 ^ 30,
        range = 0.5,
        ammo_type =
        {
          category = util.ammo_category("transport-drone"),
          target_type = "entity",
          action =
          {
            type = "direct",
            action_delivery =
            {
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 10 , type = util.damage_type("physical")}
                  }
                }
              }
            }
          }
        },
        animation = full_truck(shift)
      },
      vision_distance = 40,
      has_belt_immunity = true,
      not_controllable = true,
      movement_speed = 0.15,
      distance_per_frame = 0.15,
      pollution_to_join_attack = 1000,
      rotation_speed = 1 / (60 * 1 + (math.random() / 20)),
      --corpse = name.." Corpse",
      dying_explosion = "explosion",
      light =
      {
        {
          minimum_darkness = darkness,
          intensity = 0.4,
          size = 10,
          color = {r=1.0, g=1.0, b=1.0},
          shift = shift
        },
        {
          type = "oriented",
          minimum_darkness = darkness,
          picture =
          {
            filename = "__core__/graphics/light-cone.png",
            priority = "extra-high",
            flags = { "light" },
            scale = 2,
            width = 200,
            height = 200
          },
          shift = {shift[1], shift[2] -3.5},
          size = 0.5,
          intensity = 0.6,
          color = {r=1.0, g=1.0, b=1.0}
        }
      },
      vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
      working_sound =
      {
        sound = sprite_base.working_sound.sound,
        max_sounds_per_type = 5,
        audible_distance_modifier = 0.7
      },
      --run_animation = empty_truck(shift),
      run_animation = full_truck(shift),
      emissions_per_second = shared.drone_pollution_per_second
    }
    data:extend{unit}
  end
  
  -- for k = 1, shared.variation_count do
  --  make_unit(k)
  -- end