local khahana = dovah.get_form_by_id(0x02000D62)
if not khahana then
   error("actor ref missing!")
end

local cell = khahana.parent_cell
if not cell then
   error("actor ref parent cell is unknown!")
end

local chest_base = dovah.get_form_by_id(0x02000803)
if not chest_base then
   error("chest base missing!")
end

local chest_ref = dovah.create_form(form_types.reference, {
   editor_id = "WeirdArtifactsMerchantKhahanaChestREF",
   parent    = cell,
})
if not chest_ref then
   error("failed to create ref")
end

print(chest_ref:form_id_to_string())
chest_ref.base_form = chest_base
chest_ref.position.x = khahana.position.x
chest_ref.position.y = khahana.position.y
chest_ref.position.z = khahana.position.z - 256
print(string.format("coords: (%f, %f, %f)", chest_ref.position.x, chest_ref.position.y, chest_ref.position.z))

-- note: render window is unfinished and won't react to the chest being spawned or edited 
--       if you're already viewing that cell
--
--       run this script first; then navigate render window to the containing cell; then 
--       the chest will be visible and you'll be able to pick it for the faction