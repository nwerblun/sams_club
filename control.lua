--TODO: Clear all log statements
--TODO: Add death statements and robot build statements and other event statements
local function on_built(entity, player_index) 
	--create global flags. One for crafting, one for goal recipe
	global["nf_info"] = {
		crafting = false,
		goal_recipe = nil,
		current_recipe_goal = {},
		main_assembler = entity,
		banned_categories = {
			"centrifuging",
			"chemistry",
			"oil-processing",
			"smelting",
			"big-smelting",
			"growing"
		},
		banned_items = {
			"wood"
		}
	}

	local recipe_getter = entity.surface.create_entity({
		name = "nf-recipe-getter-assembler",
		position = entity.position,
		force = entity.force
	})
	recipe_getter.operable = false
	local in_comb_loc = {entity.position.x - 10, entity.position.y - 8}
	local in_comb = entity.surface.create_entity({
		name = "nf-input-combinator",
		position = in_comb_loc,
		force = entity.force,
	})
	in_comb.operable = false

	local rec_comb_loc = {entity.position.x - 10, entity.position.y - 5}
	local rec_comb = entity.surface.create_entity({
		name = "nf-recipe-combinator",
		position = rec_comb_loc,
		force = entity.force,
	})

	local out_comb_loc = {entity.position.x + 10, entity.position.y - 8}
	local out_comb = entity.surface.create_entity({
		name = "nf-output-combinator",
		position = out_comb_loc,
		force = entity.force,
	})
	out_comb.operable = false

	local chest_loc = {entity.position.x - 0.5, entity.position.y + 9.8}
	local refund_loader_loc = {entity.position.x - 0.5, entity.position.y + 8.8}
	local loader_loc = {entity.position.x - 0.5 , entity.position.y + 10}
	local belt_loc = {entity.position.x - 0.25, entity.position.y + 11}


	local refund_loader = entity.surface.create_entity({
		name="nf-filter-inserter",
		position = refund_loader_loc,
		force = entity.force,
		raise_built = true,
		direction = defines.direction.south
	})
	refund_loader.operable = false
	refund_loader.rotatable = false
	refund_loader.inserter_filter_mode = "whitelist"

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
	
	rec_comb.connect_neighbour({
		wire = defines.wire_type.red,
		target_entity = loader,
		source_circuit_id = defines.constant_combinator
	})
	
	chest.connect_neighbour({
		wire = defines.wire_type.red,
		target_entity = in_comb,
		source_circuit_id = defines.circuit_connector_id.container,
		target_circuit_id = defines.circuit_connector_id.combinator_output
	})
	

	--if you don't specify second signal or constant then it just assumes the second signal is a constant of 0.
	loader.get_or_create_control_behavior().circuit_condition = {
		condition = {
			comparator = "=",
			first_signal = {
				type = "virtual",
				name = "signal-everything"
			}
		}
	}

	--same as above regarding second signal.
	in_comb.get_or_create_control_behavior().parameters = {
		first_signal = {
			type = "virtual",
			name = "signal-each"
		},
		operation = "+",
		output_signal = {
			type = "virtual",
			name = "signal-each"
		}	
	}
	global["nf_info"]["recipe_getter"] = recipe_getter
	global["nf_info"]["rec_comb"] = rec_comb
	global["nf_info"]["in_comb"] = in_comb
	global["nf_info"]["output_chest"] = chest
	global["nf_info"]["output_loader"] = loader
	global["nf_info"]["internal_loader"] = refund_loader
	global["nf_info"]["out_comb"] = out_comb
end

function deepcopy(orig)
	--shamelessly stolen from lua documentation
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
	setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
        	copy = orig
	end
	return copy
end

local function get_all_inputs(comb) 
	if comb == nil then 
		return
	end

	ccb = comb.get_or_create_control_behavior()
	cn_red = ccb.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_output)
	cn_green = ccb.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_output)
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


local function contains(t, element)
	for _, value in pairs(t) do
		if value == element then
			return true
		end
	end
	return false
end

function concat_tables(t1,t2)
	for i=1, #t2 do
		t1[#t1+1] = t2[i]
	end
	return t1
end

local function get_recipe_tree(root_item_name, count)
	local recipe_tree_table = {}
	if contains(global["nf_info"]["banned_items"], root_item_name) then return {} end
	--this is necessary to get the sub components. Creating a recipe object is tough, so use a crafter to do it for us. Setting a recipe only requires a name.
	global["nf_info"]["recipe_getter"].set_recipe(root_item_name)
	local recipe = global["nf_info"]["recipe_getter"].get_recipe()
	if recipe ~= nil and recipe.category ~= nil and not contains(global["nf_info"]["banned_categories"], recipe.category) then
		table.insert(recipe_tree_table, {
			name = root_item_name,
			count = count
		})
		--TODO: enable this later. See if it breaks anything.
		--global["nf_info"]["recipe_getter"].set_recipe(nil)
		for _, ingr in pairs(recipe.ingredients) do
			recipe_tree_table = concat_tables(recipe_tree_table, get_recipe_tree(ingr.name, count * ingr.amount))
		end
		return recipe_tree_table
	else
		return {}
	end
	
end

local function every_n_ticks()
	if global["nf_info"] == nil or global["nf_info"]["main_assembler"] == nil then
		return
	end
	local recipe_tree = {}
	local recp = global["nf_info"]["rec_comb"].get_or_create_control_behavior().get_signal(1)
	if recp["signal"] ~= nil and recp["signal"]["type"] == "item" then
		global["nf_info"]["goal_recipe"] = {name = recp["signal"]["name"], count = recp["count"]}
	else
		global["nf_info"]["goal_recipe"] = nil
	end

	if global["nf_info"]["goal_recipe"] == nil then
		local spilled_items = global["nf_info"]["main_assembler"].set_recipe(nil)
		for item_name, item_count in pairs(spilled_items) do
			global["nf_info"]["output_chest"].get_output_inventory().insert({name = item_name, count = item_count})
		end
		global["nf_info"]["crafting"] = false
	elseif global["nf_info"]["goal_recipe"] ~= nil and global["nf_info"]["crafting"] == false then
		global["nf_info"]["crafting"] = true
		global["nf_info"]["recipe_tree"] = get_recipe_tree(global["nf_info"]["goal_recipe"].name, global["nf_info"]["goal_recipe"].count)
		local next_recipe = table.remove(global["nf_info"]["recipe_tree"])
		global["nf_info"]["main_assembler"].set_recipe(next_recipe.name)
		global["nf_info"]["current_recipe_goal"] = deepcopy(next_recipe)
		log("crafting is now true. Current recipe goal is "..next_recipe.name)
	elseif global["nf_info"]["goal_recipe"] ~= nil and global["nf_info"]["crafting"] == true then
		log("crafting is true")
		local curr_recipe = global["nf_info"]["main_assembler"].get_recipe()
		log("current goal step is "..global["nf_info"]["current_recipe_goal"].name)
		--we don't already have enough of the current goal item, need to craft more. If we have enough, we already removed it so next tick we will move on.
		if global["nf_info"]["in_comb"].get_or_create_control_behavior().get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_output).get_signal({type = "item", name = global["nf_info"]["current_recipe_goal"].name}) - global["nf_info"]["current_recipe_goal"].count < 0 then
			log("we don't have enough of the item, let's see if it's banned.")
			if not contains(global["nf_info"]["banned_categories"], curr_recipe.category) then
				log("item is not a banned item")
				for ind, ingr in pairs(curr_recipe.ingredients) do
					--set filter inserters to on, internal first
					global["nf_info"]["internal_loader"].set_filter(ind, ingr.name)
					--set output_comb to output what is currently needed
					global["nf_info"]["out_comb"].get_or_create_control_behavior().set_signal(ind, {signal = {type="item", name=ingr.name}, count = ingr.amount})
				end
			end
		end
		log("crafting progress "..tostring(global["nf_info"]["main_assembler"].crafting_progress))
		--crafting progress is unreliable since every time one finishes it goes back to 0. If you don't catch it on the right tick you will make too many. Instead check if we've made one yet.
		if global["nf_info"]["main_assembler"].get_output_inventory().get_item_count(global["nf_info"]["current_recipe_goal"].name) >= global["nf_info"]["current_recipe_goal"].count then
			log("crafting is done. Moving on")
			local next_goal = table.remove(global["nf_info"]["recipe_tree"])
			if next_goal ~= nil then
				global["nf_info"]["current_recipe_goal"] = deepcopy(next_goal)
				log("next goal is "..next_goal.name)
				local spilled_items = global["nf_info"]["main_assembler"].set_recipe(next_goal.name)
				for item_name, item_count in pairs(spilled_items) do
					global["nf_info"]["output_chest"].get_output_inventory().insert({name = item_name, count = item_count})
				end
			end
		end

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
