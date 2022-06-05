--TODO: Clear all log statements
--TODO: Add death statements and robot build statements and other event statements
local function on_built(entity, player_index) 
	--create global flags. One for crafting, one for goal recipe
	global["nf_info"] = {
		crafting = false,
		goal_recipe = nil,
		current_recipe_goal = {},
		main_assembler = entity,
		allowed_categories = {
			"advanced-crafting",
			"basic-crafting",
			"crafting",
			"crafting-with-fluid",
			"rocket-building"
		},
		banned_items = {
			"wood"
		}
	}
	--[[
	local recipe_getter = entity.surface.create_entity({
		name = "nf-recipe-getter-assembler",
		position = entity.position,
		force = entity.force
	})
	recipe_getter.operable = false
	--]]
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
	refund_loader.operable = true
	refund_loader.rotatable = true
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
	--global["nf_info"]["recipe_getter"] = recipe_getter
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
	for i=1, ccb.signals_count do
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
	log("adding "..tostring(root_item_name).."x"..tostring(count).." to tree")
	
	--special case because it can't be made in an assembler. 
	if game.item_prototypes[root_item_name].subgroup.name == "raw-resource" then
		table.insert(recipe_tree_table, {
		name = root_item_name,
		count = count
		})
		return recipe_tree_table
	end
	
	local recipe = game.recipe_prototypes[root_item_name]
	if recipe ~= nil and recipe.category ~= nil and contains(global["nf_info"]["allowed_categories"], recipe.category) then
		table.insert(recipe_tree_table, {
			name = root_item_name,
			count = count
		})
		for _, ingr in pairs(recipe.ingredients) do
		
			local diff = count - global["nf_info"]["in_comb"].get_or_create_control_behavior().get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_output).get_signal({type = "item", name = ingr.name})
			if diff > 0 then
				recipe_tree_table = concat_tables(recipe_tree_table, get_recipe_tree(ingr.name, diff * ingr.amount))
			end
		
		
		end
		return recipe_tree_table
	else
		return {}
	end
	
end

local function prune_tree(tree)
	local copy = deepcopy(tree)
	for ind, item in pairs(copy) do
		log("pruning "..tostring(ind)..": "..tostring(item.name))
		if game.item_prototypes[item.name].subgroup.name == "raw-resource" then
			table.remove(copy, ind)
		end
	end
	return copy
end

local function clean_up()
	global["nf_info"]["goal_recipe"] = nil
	global["nf_info"]["current_recipe_goal"] = nil
	global["nf_info"]["crafting"] = false
	clear_signals(global["nf_info"]["rec_comb"].get_or_create_control_behavior())
	clear_signals(global["nf_info"]["out_comb"].get_or_create_control_behavior())
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
		clean_up()
		local spilled_items = global["nf_info"]["main_assembler"].set_recipe(nil)
		for item_name, item_count in pairs(spilled_items) do
			global["nf_info"]["output_chest"].get_output_inventory().insert({name = item_name, count = item_count})
		end
		global["nf_info"]["crafting"] = false
	elseif global["nf_info"]["goal_recipe"] ~= nil and global["nf_info"]["crafting"] == false then
		global["nf_info"]["crafting"] = true
		local recipe_tree = get_recipe_tree(global["nf_info"]["goal_recipe"].name, global["nf_info"]["goal_recipe"].count)
		global["nf_info"]["recipe_tree"] = prune_tree(recipe_tree)
		local next_recipe = table.remove(global["nf_info"]["recipe_tree"])
		global["nf_info"]["main_assembler"].set_recipe(next_recipe.name)
		global["nf_info"]["current_recipe_goal"] = deepcopy(next_recipe)
	elseif global["nf_info"]["goal_recipe"] ~= nil and global["nf_info"]["crafting"] == true then
		local curr_recipe = global["nf_info"]["main_assembler"].get_recipe()
		log("current goal step is "..global["nf_info"]["current_recipe_goal"].name)
		--we don't already have enough of the current goal item, need to craft more. If we have enough, we already removed it so next tick we will move on. If the current step is the final goal, make it true
		if global["nf_info"]["in_comb"].get_or_create_control_behavior().get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_output).get_signal({type = "item", name = global["nf_info"]["current_recipe_goal"].name}) - global["nf_info"]["current_recipe_goal"].count < 0 or global["nf_info"]["current_recipe_goal"].name == global["nf_info"]["goal_recipe"].name then
			if contains(global["nf_info"]["allowed_categories"], curr_recipe.category) then
				for ind, ingr in pairs(curr_recipe.ingredients) do
					--set filter inserters to on, internal first
					global["nf_info"]["internal_loader"].set_filter(ind, ingr.name)
					--set output_comb to output what is currently needed
					global["nf_info"]["out_comb"].get_or_create_control_behavior().set_signal(ind, {signal = {type="item", name=ingr.name}, count = ingr.amount})
				end
			end
		end
		--crafting progress is unreliable since every time one finishes it goes back to 0. If you don't catch it on the right tick you will make too many. Instead check if we've made one yet.
		if global["nf_info"]["main_assembler"].get_output_inventory().get_item_count(global["nf_info"]["current_recipe_goal"].name) >= global["nf_info"]["current_recipe_goal"].count then
			if global["nf_info"]["current_recipe_goal"].name == global["nf_info"]["goal_recipe"].name then
				clean_up()
				return
			end
			local next_goal = table.remove(global["nf_info"]["recipe_tree"])
			log("next goal is "..tostring(next_goal))
			if next_goal ~= nil then
				global["nf_info"]["current_recipe_goal"] = deepcopy(next_goal)
				log("next goal is "..next_goal.name)
				local inserter_items = global["nf_info"]["internal_loader"].held_stack
				if inserter_items ~= nil and inserter_items.valid_for_read then
					log(inserter_items)
					log(inserter_items.name)
					global["nf_info"]["output_chest"].get_output_inventory().insert({name = inserter_items.name, count = inserter_items.count})
					inserter_items.clear()
				end
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
