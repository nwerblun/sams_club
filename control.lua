--TODO: Clear all log statements
--TODO: Add death statements and robot build statements and other event statements
local function on_built(entity, player_index) 
	--create global flags. One for crafting, one for goal recipe
	global["nf_info"] = {
		crafting = false,
		goal_recipe = nil
	}

	local in_comb_loc = {entity.position.x - 10, entity.position.y - 8}
	local in_comb = entity.surface.create_entity({
		name = "nf-input-combinator",
		position = in_comb_loc,
		force = entity.force,
	})
	in_comb.operable = false

	local rec_comb_loc = {entity.position.x - 10, entity.position.y - 5}
	local rec_comb = entity.surface.create_entity({
		name = "nf-input-combinator",
		position = rec_comb_loc,
		force = entity.force,
	})

	local chest_loc = {entity.position.x - 0.5, entity.position.y + 9.8}
	local loader_loc = {entity.position.x - 0.5 , entity.position.y + 10}
	local belt_loc = {entity.position.x - 0.25, entity.position.y + 11}

	local loader = entity.surface.create_entity({
		name="nf-fast-inserter",
		position = loader_loc,
		force = entity.force,
		raise_built = true
	})

	local chest = entity.surface.create_entity({
		name = "nf-chest",
		force = entity.force,
		position = chest_loc
	})
	
	local belt = entity.surface.create_entity({
		name = "nf-belt",
		force = entity.force,
		position = belt_loc,
		direction = defines.direction.south
	
	})
	belt.rotatable = false
	belt.operable = false

	global["nf_info"]["rec_comb"] = rec_comb
	global["nf_info"]["in_comb"] = in_comb
	global["nf_info"]["output_chest"] = chest
	global["nf_info"]["output_loader"] = loader
end


local function get_all_inputs(comb) 
	if comb == nil then 
		return
	end

	ccb = comb.get_or_create_control_behavior()
	cn_red = ccb.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator)
	cn_green = ccb.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator)
	local everything = {}
	if cn_red ~= nil and cn_red.signals ~= nil then
		for _,sig in pairs(cn_red.signals) do
			if sig["signal"]["type"] == "item" then
				if everything[sig["signal"]["name"]] == nil then
					everything[sig["signal"]["name"]] = sig["count"]
				else
					everything[sig["signal"]["name"]] = sig["count"] + everything[sig["signal"]["name"]]
				end
			end
		end
	end
	if cn_green ~= nil and cn_green.signals ~= nil then
		for _,sig in pairs(cn_green.signals) do
			if sig["signal"]["type"] == "item" then
				if everything[sig["signal"]["name"]] == nil then
					everything[sig["signal"]["name"]] = sig["count"]
				else
					everything[sig["signal"]["name"]] = sig["count"] + everything[sig["signal"]["name"]]
				end
			end
		end
	end

	if everything ~= nil then
		return everything
	else
		return {}
	end
end


local function clear_signals(ccb)
	for i=1, table.getn(ccb.signals_count) do
		ccb.set_signal(i, nil)
	end
end

local function every_n_ticks()
--if goal recipe == nil and crafting = 1
----clear recipe on crafter
----push inventory into overflow chest
----activate overflow chest output
----disable output combs
----set global crafting flag to 0
--else if goal recipe ~= nil and crafting flag = 0
----global crafting flag -> 1
----calculate all needed recipes. Do not check if we have it or not. Store to global list.
----enable combs, disable loaders
----pop top off global list. Do we have it? if so don't set it as recipe.
----If not, set it as recipe
--else if crafting flag == 1 and goal recipe ~= nil and crafting progress == 1
----flush inventory to internal chests 
----pop top, do we have it? do same thing as previous section
	if global["nf_info"] == nil then
		return
	end

	local recp = global["nf_info"]["rec_comb"].get_or_create_control_behavior().get_signal(1)
	if recp["signal"] ~= nil and recp["signal"]["type"] == "item" then
		global["nf_info"]["goal_recipe"] = {recp["signal"]["name"], recp["count"]}
	end

	if global["nf_info"]["goal_recipe"] == nil then
		log("goal is nil")
	elseif global["nf_info"]["goal_recipe"] ~= nil and global["nf_info"]["crafting"] == false then
		log("goal not nil, crafting 0")
	else
		log("goal not nil, crafting 1")
	end
end

script.on_event(defines.events.on_built_entity, 
	function(event)
		if event.created_entity.name == "nf-assembler" then
			on_built(event.created_entity, event.player_index)
		end
	end
)

script.on_nth_tick(10, 
	function(nth_tick_event_data)
		every_n_ticks()
	end
)
