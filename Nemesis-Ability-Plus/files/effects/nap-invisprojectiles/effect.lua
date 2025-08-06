dofile_once("data/scripts/lib/utilities.lua")
local entity_id = GetUpdatedEntityID()
local x, y = GameGetCameraPos()
local projectiles = EntityGetInRadiusWithTag( x, y, 512, "projectile" )

if ( #projectiles > 0 ) then
	for i = 1, #projectiles do
		local projectile = projectiles[i]
		if (not EntityHasTag(projectile, "nap-invis_projectiles")) then
			EntityAddComponent2( projectile, "LuaComponent",
			{
				script_source_file = "data/scripts/projectiles/colour_spell.lua",
				execute_every_n_frame = 1,
				remove_after_executed = true,
			})
			
			EntityAddComponent2( projectile, "LuaComponent",
			{
				script_source_file = "data/scripts/projectiles/colour_spell.lua",
				execute_on_added = true,
				remove_after_executed = true,
			})
			
			EntityAddComponent2( projectile, "VariableStorageComponent",
			{
				name = "colour_name",
				value_string = "invis",
			})
			
			EntityAddTag(projectile, "nap-invis_projectiles" )
		end
	end
end