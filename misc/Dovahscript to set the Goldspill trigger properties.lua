local ref   = dovah.get_form_by_id(0x02000845)
local layer = dovah.get_form_by_id(0x02000841)

local CELL_SIZE <const> = 4096

local uGridsToLoad_WorldUnits = CELL_SIZE * 5

ref.extra_data.collision_layer_uid = 0x00C0BB01
ref.extra_data.primitive = {
   bounds = { uGridsToLoad_WorldUnits, uGridsToLoad_WorldUnits, uGridsToLoad_WorldUnits * 2 },
   shape  = "box",
}