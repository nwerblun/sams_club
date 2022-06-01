local belt = table.deepcopy(data.raw["transport-belt"]["ultimate-belt"])
belt.name = "nf-belt"
belt.minable = nil
table.insert(belt.flags, "hidden")
belt.resitances = {
	{
		type = "fire",
		percent = 100
	},

	{
		type = "acid",
		percent = 100
	},

	{
		type = "physical",
		percent = 100
	},
	
	{
		type = "impact",
		percent = 100
	},

	{
		type = "poison",
		percent = 100
	},

	{
		type = "explosion",
		percent = 100
	},

	{
		type = "laser",
		percent = 100
	},

	{
		type = "electric",
		percent = 100
	},
}
data:extend({belt})
