local cell = dovah.get_form_by_id(0x02000844)
local base = dovah.get_form_by_id(0x02000842)

local ref = dovah.create_form(form_types.reference, {
   editor_id = "WeirdArtifactsGoldspillCounterREF",
   parent    = cell
})
print(ref:form_id_to_string())
ref.base_form = base