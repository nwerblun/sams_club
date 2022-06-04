--TODO: Replace with invisible sprite
--TODO: don't display grab locations
--TODO: Make the box not selectable
local NOTHING_PICTURE = "__nano-factory__/graphics/nf_nothing.png"
local nf_inserter = table.deepcopy(data.raw["inserter"]["filter-inserter"])
nf_inserter.name = "nf-filter-inserter"
nf_inserter.rotation_speed = 1.0
nf_inserter.flags =  {
	"placeable-off-grid",
	"placeable-player",
	"not-blueprintable",
	"hidden",
	"hide-alt-info",
	"not-upgradable",
}
nf_inserter.draw_circuit_wires = false
nf_inserter.circuit_wire_max_distance = 50
nf_inserter.selection_priority = 51
nf_inserter.energy_per_movement = "0KJ"
nf_inserter.energy_per_rotation = "0KJ"
nf_inserter.energy_source = {type = "void"}
nf_inserter.working_sound = nil
--nf_inserter.selection_box = {{0,0}, {0,0}}
nf_inserter.next_upgrade = nil
nf_inserter.minable = nil
nf_inserter.collision_mask = {}

nf_inserter.hand_base_picture = {
	filename = NOTHING_PICTURE,
	height = 32,
	width = 32,
	priority = "medium",
	scale = 0.25,
	hr_version = {
		filename = NOTHING_PICTURE,
		height = 32,
		width = 32,
		priority = "medium",
		scale = 0.25,
	}
}

nf_inserter.hand_base_shadow = {
	filename = NOTHING_PICTURE,
	height = 32,
	width = 32,
	priority = "medium",
	scale = 0.25,
	hr_version = {
		filename = NOTHING_PICTURE,
		height = 32,
		width = 32,
		priority = "medium",
		scale = 0.25,
	}
}

nf_inserter.hand_closed_picture = {
	filename = NOTHING_PICTURE,
	height = 32,
	width = 32,
	priority = "medium",
	scale = 0.25,
	hr_version = {
		filename = NOTHING_PICTURE,
		height = 32,
		width = 32,
		priority = "medium",
		scale = 0.25,
	}
}

nf_inserter.hand_closed_shadow = {
	filename = NOTHING_PICTURE,
	height = 32,
	width = 32,
	priority = "medium",
	scale = 0.25,
	hr_version = {
		filename = NOTHING_PICTURE,
		height = 32,
		width = 32,
		priority = "medium",
		scale = 0.25,
	}
}

nf_inserter.hand_open_picture = {
	filename = NOTHING_PICTURE,
	height = 32,
	width = 32,
	priority = "medium",
	scale = 0.25,
	hr_version = {
		filename = NOTHING_PICTURE,
		height = 32,
		width = 32,
		priority = "medium",
		scale = 0.25,
	}
}

nf_inserter.hand_open_shadow = {
	filename = NOTHING_PICTURE,
	height = 32,
	width = 32,
	priority = "medium",
	scale = 0.25,
	hr_version = {
		filename = NOTHING_PICTURE,
		height = 32,
		width = 32,
		priority = "medium",
		scale = 0.25,
	}
}

nf_inserter.platform_picture = {
	filename = NOTHING_PICTURE,
	height = 32,
	width = 32,
	priority = "medium",
	scale = 0.25,
	hr_version = {
		filename = NOTHING_PICTURE,
		height = 32,
		width = 32,
		priority = "medium",
		scale = 0.25,
	}
}
nf_inserter.draw_held_item = false
nf_inserter.use_easter_egg = false
--nf_inserter.draw_inserter_arrow = false
data:extend({nf_inserter})
