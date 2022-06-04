--copy the assembling machine 3 entity
local nano_factory_entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
nano_factory_entity.name = "nf-assembler"
table.insert(nano_factory_entity.flags, "no-automated-item-removal")
--add extra crafting categories
nano_factory_entity.crafting_categories = {
	"advanced-crafting",
	"basic-crafting",
	"crafting",
	"crafting-with-fluid",
	"rocket-building"
}
--Make it faster to justify the extra power
nano_factory_entity.crafting_speed = 2.5
--remove the fast replace option
nano_factory_entity.fast_replaceable_group = nil
--change it so mining it gives back the expected item
nano_factory_entity.minable = {mining_time = 2, result = "nano-factory"}
--more module slots
nano_factory_entity.module_specification = {module_slots = 16}
--add power setting. The setting is an int, but the value must be in terms of Watts with the 
--unit included as a string.
nano_factory_entity.energy_usage = tostring(settings.startup["nf-power-usage"].value) .. "W"
--increase scale to be 4x. Need to change regular and HR version for people playing with hi-res sprites.
for _, l in pairs(nano_factory_entity.animation["layers"]) do
	l["scale"] = 4
	l["hr_version"]["scale"] = 4
	l["shift"] = {-0.5, l["shift"][2]*4}
	l["hr_version"]["shift"] = {-0.5, l["shift"][2]*4}
	if l["draw_as_shadow"] == nil or l["draw_as_shadow"] == false then
		l["hr_version"]["filename"] = "__nano-factory__/graphics/nf_assembler/hr-assembling-machine-3.png"
		l["filename"] = "__nano-factory__/graphics/nf_assembler/assembling-machine-3.png"
	end
end
--increase drawing box along with scale
nano_factory_entity.drawing_box = {
	{-10,-11},
	{10,9}
}
nano_factory_entity.collision_box = {
	{-10,-11},
	{10, 9}
}
nano_factory_entity.selection_box = {
	{-10,-11},
	{10,9}
}
--adjust pipe locations to match new bounding boxes
for _,b in pairs(nano_factory_entity.fluid_boxes) do
	if type(b) ~= "boolean" then
		b["base_area"] = 100
		local shft = 9.5; if b["production_type"] == "input" then shft = -11.5 end
		for _,c in pairs(b["pipe_connections"]) do
			--for some reason it's off aligned if x = 0, so shift it by 0.5 (the pipe size)
			c["position"] = {0.5, shft}
		end
	end

end
nano_factory_entity.selection_priority = 40
nano_factory_entity.energy_source = {type = "void"}
table.insert(nano_factory_entity.flags, "not-rotatable")
data:extend({nano_factory_entity})
