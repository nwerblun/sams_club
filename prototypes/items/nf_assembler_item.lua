--copy the assembling machine 3 item
local nano_factory_item = table.deepcopy(data.raw["item"]["assembling-machine-3"])
nano_factory_item.name = "nano-factory"

--change the item to place our entity rather than the default assembler
nano_factory_item.place_result = "nf-assembler"
data:extend({nano_factory_item})
