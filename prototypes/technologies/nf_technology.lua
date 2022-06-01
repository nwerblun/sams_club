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

