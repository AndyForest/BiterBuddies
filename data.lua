-- Biter Buddies v2
-- Buddy entity prototypes, egg capsule items, recipes, and technologies

------------------------------------------------------------------------
-- BUDDY ENTITY PROTOTYPES
------------------------------------------------------------------------

local buddy_types = {
  { name = "small-biter-buddy",     base = "small-biter" },
  { name = "medium-biter-buddy",    base = "medium-biter" },
  { name = "big-biter-buddy",       base = "big-biter" },
  { name = "behemoth-biter-buddy",  base = "behemoth-biter" },
  { name = "small-spitter-buddy",   base = "small-spitter" },
  { name = "medium-spitter-buddy",  base = "medium-spitter" },
  { name = "big-spitter-buddy",     base = "big-spitter" },
  { name = "behemoth-spitter-buddy",base = "behemoth-spitter" },
}

for _, bt in ipairs(buddy_types) do
  local unit = table.deepcopy(data.raw.unit[bt.base])
  unit.name = bt.name
  unit.absorptions_to_join_attack = {pollution = 1000}
  data:extend{unit}
end

------------------------------------------------------------------------
-- EGG CAPSULE ITEMS
------------------------------------------------------------------------

-- Map from egg item name to the buddy entity it spawns
local egg_definitions = {
  { egg = "small-biter-egg",      buddy = "small-biter-buddy",      order = "a[small-biter]" },
  { egg = "small-spitter-egg",    buddy = "small-spitter-buddy",    order = "b[small-spitter]" },
  { egg = "medium-biter-egg",     buddy = "medium-biter-buddy",     order = "c[medium-biter]" },
  { egg = "medium-spitter-egg",   buddy = "medium-spitter-buddy",   order = "d[medium-spitter]" },
  { egg = "big-biter-egg",        buddy = "big-biter-buddy",        order = "e[big-biter]" },
  { egg = "big-spitter-egg",      buddy = "big-spitter-buddy",      order = "f[big-spitter]" },
  { egg = "behemoth-biter-egg",   buddy = "behemoth-biter-buddy",   order = "g[behemoth-biter]" },
  { egg = "behemoth-spitter-egg", buddy = "behemoth-spitter-buddy", order = "h[behemoth-spitter]" },
}

for _, def in ipairs(egg_definitions) do
  -- Capsule item
  data:extend{{
    type = "capsule",
    name = def.egg,
    icon = "__base__/graphics/icons/" .. def.buddy:gsub("-buddy", "") .. ".png",
    icon_size = 64,
    subgroup = "capsule",
    order = "e[biter-buddy]-" .. def.order,
    stack_size = 100,
    capsule_action = {
      type = "throw",
      attack_parameters = {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = 30,
        range = 25,
        ammo_type = {
          category = "capsule",
          target_type = "position",
          action = {
            type = "direct",
            action_delivery = {
              type = "projectile",
              projectile = def.egg .. "-projectile",
              starting_speed = 0.3,
            },
          },
        },
      },
    },
  }}

  -- Projectile that triggers the spawn on landing
  data:extend{{
    type = "projectile",
    name = def.egg .. "-projectile",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "script",
            effect_id = "spawn-" .. def.buddy,
          },
          {
            type = "create-trivial-smoke",
            smoke_name = "smoke-fast",
            offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
            starting_frame_deviation = 5,
          },
        },
      },
    },
    light = {intensity = 0.5, size = 4},
    animation = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
      frame_count = 15,
      width = 42,
      height = 164,
      priority = "high",
      shift = {0, 0},
      line_length = 5,
      scale = 0.33,
    },
    shadow = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
      frame_count = 15,
      width = 42,
      height = 164,
      priority = "high",
      shift = {0, 0},
      line_length = 15,
      scale = 0.33,
    },
  }}
end

------------------------------------------------------------------------
-- RECIPES (table-driven)
------------------------------------------------------------------------

local recipe_definitions = {
  { egg = "small-biter-egg",      time = 2,  ingredients = {{"iron-plate", 5}, {"coal", 3}} },
  { egg = "small-spitter-egg",    time = 2,  ingredients = {{"copper-plate", 5}, {"coal", 3}} },
  { egg = "medium-biter-egg",     time = 5,  ingredients = {{"iron-plate", 10}, {"steel-plate", 5}, {"small-biter-egg", 1}} },
  { egg = "medium-spitter-egg",   time = 5,  ingredients = {{"copper-plate", 10}, {"steel-plate", 5}, {"small-spitter-egg", 1}} },
  { egg = "big-biter-egg",        time = 10, ingredients = {{"steel-plate", 10}, {"processing-unit", 2}, {"medium-biter-egg", 1}} },
  { egg = "big-spitter-egg",      time = 10, ingredients = {{"steel-plate", 10}, {"processing-unit", 2}, {"medium-spitter-egg", 1}} },
  { egg = "behemoth-biter-egg",   time = 15, ingredients = {{"medium-biter-egg", 2}, {"low-density-structure", 5}} },
  { egg = "behemoth-spitter-egg", time = 15, ingredients = {{"medium-spitter-egg", 2}, {"low-density-structure", 5}} },
}

for _, def in ipairs(recipe_definitions) do
  local ingredients = {}
  for _, ing in ipairs(def.ingredients) do
    ingredients[#ingredients + 1] = {type = "item", name = ing[1], amount = ing[2]}
  end
  data:extend{{
    type = "recipe",
    name = def.egg,
    enabled = false,
    energy_required = def.time,
    ingredients = ingredients,
    results = {{type = "item", name = def.egg, amount = 1}},
    category = "crafting",
  }}
end

------------------------------------------------------------------------
-- TECHNOLOGIES
------------------------------------------------------------------------

data:extend{
  -- Red science: Small Biter Egg
  {
    type = "technology",
    name = "biter-buddies-1",
    icon = "__base__/graphics/icons/small-biter.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "small-biter-egg"},
    },
    prerequisites = {"automation"},
    unit = {
      count = 30,
      ingredients = {{"automation-science-pack", 1}},
      time = 15,
    },
    order = "e-j-a",
  },
  -- Green science: Small Spitter Egg
  {
    type = "technology",
    name = "biter-buddies-2",
    icon = "__base__/graphics/icons/small-spitter.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "small-spitter-egg"},
    },
    prerequisites = {"biter-buddies-1", "logistic-science-pack"},
    unit = {
      count = 50,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 15,
    },
    order = "e-j-b",
  },
  -- Military science: Medium Biter + Medium Spitter Eggs
  {
    type = "technology",
    name = "biter-buddies-3",
    icon = "__base__/graphics/icons/medium-biter.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "medium-biter-egg"},
      {type = "unlock-recipe", recipe = "medium-spitter-egg"},
    },
    prerequisites = {"biter-buddies-2", "military-science-pack"},
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 30,
    },
    order = "e-j-c",
  },
  -- Space science: Big Biter + Big Spitter Eggs
  {
    type = "technology",
    name = "biter-buddies-4",
    icon = "__base__/graphics/icons/big-biter.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "big-biter-egg"},
      {type = "unlock-recipe", recipe = "big-spitter-egg"},
    },
    prerequisites = {"biter-buddies-3", "space-science-pack"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 45,
    },
    order = "e-j-d",
  },
  -- Metallurgic science (Vulcanus): Behemoth Biter Egg
  {
    type = "technology",
    name = "biter-buddies-5",
    icon = "__base__/graphics/icons/behemoth-biter.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "behemoth-biter-egg"},
    },
    prerequisites = {"biter-buddies-4", "metallurgic-science-pack"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
      },
      time = 60,
    },
    order = "e-j-e",
  },
  -- Agricultural science (Gleba): Behemoth Spitter Egg
  {
    type = "technology",
    name = "biter-buddies-6",
    icon = "__base__/graphics/icons/behemoth-spitter.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "behemoth-spitter-egg"},
    },
    prerequisites = {"biter-buddies-4", "agricultural-science-pack"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1},
        {"agricultural-science-pack", 1},
      },
      time = 60,
    },
    order = "e-j-f",
  },
}

------------------------------------------------------------------------
-- BUDDY WHISTLE (selection tool + toolbar shortcut)
------------------------------------------------------------------------

-- Build the list of buddy entity names for selection tool filters
local buddy_entity_names = {}
for _, bt in ipairs(buddy_types) do
  buddy_entity_names[#buddy_entity_names + 1] = bt.name
end

data:extend{
  -- Selection tool item: the Buddy Whistle
  {
    type = "selection-tool",
    name = "buddy-whistle",
    icon = "__base__/graphics/icons/spidertron-remote.png",
    icon_size = 64,
    subgroup = "tool",
    order = "c[automated-construction]-d[buddy-whistle]",
    stack_size = 1,
    flags = {"spawnable", "only-in-cursor", "not-stackable"},
    select = {
      border_color = {r = 0.2, g = 0.8, b = 0.2},
      cursor_box_type = "entity",
      mode = {"any-entity", "same-force"},
      entity_filters = buddy_entity_names,
    },
    alt_select = {
      border_color = {r = 0.2, g = 0.4, b = 1.0},
      cursor_box_type = "entity",
      mode = {"nothing"},
    },
  },

  -- Toolbar shortcut button to equip the whistle
  {
    type = "shortcut",
    name = "buddy-whistle-shortcut",
    localised_name = {"item-name.buddy-whistle"},
    action = "spawn-item",
    item_to_spawn = "buddy-whistle",
    icon = "__base__/graphics/icons/spidertron-remote.png",
    icon_size = 64,
    small_icon = "__base__/graphics/icons/spidertron-remote.png",
    small_icon_size = 64,
  },

}

------------------------------------------------------------------------
-- HOTKEYS (sparring only)
------------------------------------------------------------------------

data:extend{
  {
    type = "custom-input",
    name = "spawn_biter_enemy_buddy_hotkey",
    key_sequence = "F9",
    consuming = "none",
  },
}
