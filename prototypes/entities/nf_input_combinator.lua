--TODO: Replace sprite with invisible or some kind of antenna
local nf_input_combinator = table.deepcopy(data.raw["arithmetic-combinator"]["arithmetic-combinator"])
nf_input_combinator.name = "nf-input-combinator"
nf_input_combinator.flags = {
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
--nf_input_combinator.draw_circuit_wires = false
nf_input_combinator.minable = nil
nf_input_combinator.circuit_wire_max_distance = 50
nf_input_combinator.remove_decoratives = "false"
nf_input_combinator.collision_mask = {}
nf_input_combinator.selection_priority = 51
nf_input_combinator.placeable_by = {item = "nano-factory", count = 0}
nf_input_combinator.energy_source = {type = "void"}
data:extend({nf_input_combinator})

