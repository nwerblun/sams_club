local chest = table.deepcopy(data.raw["container"]["steel-chest"])
local NOTHING_PICTURE = "__nano-factory__/graphics/nf_nothing.png"
chest.name = "nf-chest"
chest.minable = nil
chest.inventory_size = 120
chest.flags = {
	"placeable-off-grid",
	"hide-alt-info",
	"not-rotatable",
	"placeable-player",
	"not-blueprintable",
	"hidden",
	"not-upgradable",
	"no-copy-paste",
	"no-automated-item-insertion",
}

chest.picture = {
	layers = {
		{
			filename = NOTHING_PICTURE,
			width = 32,
			height = 32,
			priority = "medium",
			hr_version = {
				filename = NOTHING_PICTURE,
				width = 32,
				height = 32,
				priority = "medium",

			}
		}
	}
}
chest.draw_circuit_wires = false
chest.circuit_wire_max_distance = 50
chest.selection_priority = 51
chest.selection_box = {{0,0}, {0,0}}
data:extend({chest})

