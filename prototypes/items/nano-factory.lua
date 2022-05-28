--copy the assembling machine 3 item and entity
local nanoFactoryEntity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
local nanoFactoryItem = table.deepcopy(data.raw["item"]["assembling-machine-3"])
nanoFactoryEntity.name = "nf-entity"
nanoFactoryItem.name = "nano-factory"

--change the item to place our entity rather than the default assembler
nanoFactoryItem.place_result = "nf-entity"
--add extra crafting categories
nanoFactoryEntity.crafting_categories = {
	"advanced-crafting",
	"basic-crafting",
	"crafting",
	"crafting-with-fluid",
	"rocket-building"
}
--remove the fast replace option
nanoFactoryEntity.fast_replaceable_group = nil
--change it so mining it gives back the expected item
nanoFactoryEntity.minable = {mining_time = 2, result = "nano-factory"}
--more module slots
nanoFactoryEntity.module_specification = {module_slots = 16}
--add power setting. The setting is an int, but the value must be in terms of Watts with the 
--unit included as a string.
nanoFactoryEntity.energy_usage = tostring(settings.startup["nf:power-usage"].value) .. "W"
--add to data.raw
data:extend({nanoFactoryEntity, nanoFactoryItem})
--create crafting recipe
data:extend({
	{
		type = "recipe",
		name = "nano-factory",
		enabled = "false",
		--TODO: Determine a better recipe
		ingredients = {{"iron-plate", 3}},
		result = "nano-factory"	
	}
})


local nanoFactoryTech = table.deepcopy(data.raw["technology"]["automation-3"])
nanoFactoryTech.name = "nano-factory-tech"
nanoFactoryTech.localised_description = {"nano-factory-tech"}
nanoFactoryTech.effects = {
	{
		type = "unlock-recipe",
		recipe = "nano-factory"
	}
}
nanoFactoryTech.prerequisites = {
	"automation-3",
	"utility-science-pack",
	"fcpu"
}
nanoFactoryTech.unit = {
	count = 250,
	ingredients = {
		{"automation-science-pack", 3},
		{"logistic-science-pack", 3},
		{"utility-science-pack", 1},
		{"production-science-pack", 1},
		{"se-energy-science-pack-2",1},
		{"se-material-science-pack-2", 1}
	},
	time = 45
}
data:extend({nanoFactoryTech})
