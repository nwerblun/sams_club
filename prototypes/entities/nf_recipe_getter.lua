--copy the assembling machine 3 entity
local recipe_getter = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
recipe_getter.name = "nf-recipe-getter-assembler"
recipe_getter.flags =  {
	"placeable-off-grid",
	"not-rotatable",
	"placeable-player",
	"not-blueprintable",
	"hidden",
	"hide-alt-info",
	"not-upgradable",
	"no-automated-item-insertion",
	"no-automated-item-removal"
}
recipe_getter.crafting_categories = {
	"advanced-crafting",
	"basic-crafting",
	"crafting",
	"crafting-with-fluid",
	"rocket-building"
}
recipe_getter.minable = nil
recipe_getter.energy_usage = "1W" --I wanted to do VOID but I CANNOT ESCAPE EARENDELS TYRANNY
--recipe_getter.selection_box = {{0,0}, {0,0}}
recipe_getter.selection_priority = 40
data:extend({recipe_getter})
