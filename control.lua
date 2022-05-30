--TODO: Clear all log statements
--TODO: Add death statements and robot build statements and other event statements
local function on_built(entity) 
	local in_comb_loc = {entity.position.x - 10, entity.position.y - 9}
	entity.surface.create_entity({
		name = "nf-combinator",
		position = in_comb_loc,
		force = entity.force,
		type = "constant-combinator"
	})
	local in_comb = entity.surface.find_entity("nf-combinator", in_comb_loc)
	in_comb.operable = false

	local out_curr_rec_comb_loc = {entity.position.x + 10, entity.position.y - 9}
	local out_total_comb_loc = {entity.position.x + 10, entity.position.y - 8}

	entity.surface.create_entity({
		name = "nf-combinator",
		position = out_curr_rec_comb_loc,
		force = entity.force,
		type = "constant-combinator"
	})
	
	entity.surface.create_entity({
		name = "nf-combinator",
		position = out_total_comb_loc,
		force = entity.force,
		type = "constant-combinator"
	})

	local out_curr_rec_comb = entity.surface.find_entity("nf-combinator", out_curr_rec_comb_loc)
	local out_total_comb_loc = entity.surface.find_entity("nf-combinator", out_total_comb_loc)
	out_curr_rec_comb.operable = false
	out_total_comb_loc.operable = false

end

local function get_combs(nf)
	local in_comb = nf.surface.find_entity("nf-combinator", {nf.position.x-10, nf.position.y-9}) 
	local out_curr_rec_comb = nf.surface.find_entity("nf-combinator", {nf.position.x + 10, nf.position.y - 9})
	local out_total_comb = nf.surface.find_entity("nf-combinator", {nf.position.x + 10, nf.position.y - 8})
	return {in_comb = in_comb, out_curr_rec_comb = out_curr_rec_comb, out_total_comb = out_total_comb}
end


local function on_gui_closed(entity)
	if entity.name == "nf-entity" then
		rec = entity.get_recipe()
		if rec ~= nil then
			local combs = get_combs(entity)
			out_rec_ccb = combs["out_curr_rec_comb"].get_or_create_control_behavior()
			out_rec_ccb.enabled = false
			local ind = 1
			for _, ingredient in pairs(rec.ingredients) do
				out_rec_ccb.set_signal(
					ind,
					{
						signal = {type = "item", name = ingredient.name},
						count = ingredient.amount
					}
				)
				ind = ind + 1
			end
			out_rec_ccb.enabled = true

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
