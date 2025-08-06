dofile_once("data/scripts/lib/utilities.lua")

local entity_id    = GetUpdatedEntityID()

local comp_cd = EntityGetFirstComponent( entity_id, "VariableStorageComponent", "ninja_ghost_cooldown" )
if ( comp_cd ~= nil ) then
	local cd = ComponentGetValue2( comp_cd, "value_int" )

	if ( cd > 0 ) then
		cd = cd - 1
		
		ComponentSetValue2( comp_cd, "value_int", cd )
	end
end