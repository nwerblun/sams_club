--TODO: Replace sprite with invisible or some kind of antenna
local nf_output_combinator = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
nf_output_combinator.name = "nf-output-combinator"
nf_output_combinator.flags = {
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
nf_output_combinator.minable = nil
nf_output_combinator.circuit_wire_max_distance = 50
nf_output_combinator.remove_decoratives = "false"
nf_output_combinator.collision_mask = {}
nf_output_combinator.item_slot_count = 15
nf_output_combinator.selection_priority = 51
nf_output_combinator.placeable_by = {item = "nano-factory", count = 0}
nf_output_combinator.energy_source = {type = "void"}
data:extend({nf_output_combinator})

