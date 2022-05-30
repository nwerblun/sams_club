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
--Make it faster to justify the extra power
nanoFactoryEntity.crafting_speed = 2.5
--remove the fast replace option
nanoFactoryEntity.fast_replaceable_group = nil
--change it so mining it gives back the expected item
nanoFactoryEntity.minable = {mining_time = 2, result = "nano-factory"}
--more module slots
nanoFactoryEntity.module_specification = {module_slots = 16}
--add power setting. The setting is an int, but the value must be in terms of Watts with the 
--unit included as a string.
nanoFactoryEntity.energy_usage = tostring(settings.startup["nf:power-usage"].value) .. "W"
--increase scale to be 4x. Need to change regular and HR version for people playing with hi-res sprites.
for _, l in pairs(nanoFactoryEntity.animation["layers"]) do
	l["scale"] = 4
	l["hr_version"]["scale"] = 4
end
--increase drawing box along with scale
nanoFactoryEntity.drawing_box = {
	{-10.0,-10},
	{10.0,10.0}
}
nanoFactoryEntity.collision_box = {
	{-10.0,-10.0},
	{10.0,10.0}
}
nanoFactoryEntity.selection_box = {
	{-10.0,-10.0},
	{10.0,10.0}
}
--adjust pipe locations to match new bounding boxes
for _,b in pairs(nanoFactoryEntity.fluid_boxes) do
	if type(b) ~= "boolean" then
		b["base_area"] = 100
		local shft = 1; if b["production_type"] == "input" then shft = -1 end
		for _,c in pairs(b["pipe_connections"]) do
			--for some reason it's off aligned if x = 0, so shift it by 0.5 (the pipe size)
			c["position"] = {0.5, shft*10.5}
		end
	end

end
--add to data.raw
data:extend({nanoFactoryEntity, nanoFactoryItem})
--create crafting recipe
data:extend({
	{
		--TODO: Fix recipe and make enabled false
		type = "recipe",
		name = "nano-factory",
		enabled = "true",
		--TODO: Determine a better recipe
		ingredients = {}, --{{"iron-plate", 3}},
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


local nf_combinator = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
nf_combinator.name = "nf-combinator"
nf_combinator.flags = {
	"hidden",
	"placeable-off-grid",
	"not-rotatable",
	"player-creation",
	"placeable-neutral",
	"not-deconstructable",
	"hide-alt-info",
	"not-flammable",
	"not-upgradable",
}
nf_combinator.remove_decoratives = "false"
nf_combinator.collision_mask = {}
nf_combinator.item_slot_count = 20
nf_combinator.selection_priority = 51
nf_combinator.placeable_by = {item = "nano-factory", count = 0}
data:extend({nf_combinator})
