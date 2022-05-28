--TODO: Clear all log statements
--TODO: Add death statements and robot build statements
local function on_built(entity)
	local chest_loc = {entity.position.x - 2, entity.position.y}
	log(tostring(chest_loc))
	log("creating chest")
	entity.surface.create_entity({
		name = "steel-chest",
		position = chest_loc,
		force = entity.force,
		type = "container"
	})
end

local function get_chest(nf)
	local chst = nf.surface.find_entity("steel-chest", {nf.position.x-2, nf.position.y})
	return chst 
end

local function on_gui_closed(entity)
	if entity.name == "nf-entity" then
		rec = entity.get_recipe()
		if rec ~= nil then
			local chst = get_chest(entity)
			for _, ingredient in pairs(rec.ingredients) do
				log("checking ingredients")
				log(ingredient)
				log(ingredient.name)
				log(ingredient.amount)
				log(ingredient.name)
				chst.get_output_inventory().insert({
					name = ingredient.name,
					count = ingredient.amount
				})		
			end

		end
	end

end


script.on_event(defines.events.on_built_entity, 
	function(event)
		if event.created_entity.name == "nf-entity" then
			log("Nano Factory Built")
			on_built(event.created_entity)
		end
	end
)


script.on_event(defines.events.on_gui_closed, 
	function(event)
		if event.entity ~= nil and event.entity.name == "nf-entity" then
			log("nf gui closed")
			on_gui_closed(event.entity)
		end

	end
)
