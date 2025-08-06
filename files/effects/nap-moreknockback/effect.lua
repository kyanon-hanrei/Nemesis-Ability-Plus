dofile_once("data/scripts/lib/utilities.lua")
local entity_id = GetUpdatedEntityID()
local x, y = GameGetCameraPos()
local projectiles = EntityGetInRadiusWithTag( x, y, 512, "projectile" )

if ( #projectiles > 0 ) then
	for i = 1, #projectiles do
		local projectile = projectiles[i]
		if (not EntityHasTag(projectile, "nap-more_knockback")) then
			local comp = EntityGetFirstComponent( projectile, "ProjectileComponent")
			
			if (comp ~= nil) then
				local knockback = ComponentGetValue2(comp, "knockback_force" )
				--GamePrintImportant(knockback)
				knockback = knockback + 50
				ComponentSetValue2(comp, "knockback_force", knockback )
				
				local impulse = ComponentGetValue2(comp, "physics_impulse_coeff" )
				--GamePrintImportant(impulse)
				impulse = impulse + 50000
				ComponentSetValue2(comp, "physics_impulse_coeff", impulse )
				
				--[[
				local expower = tonumber( ComponentObjectGetValue( comp, "config_explosion", "physics_explosion_power.max" ) )
				expower = expower * 5
				GamePrintImportant(expower)
				ComponentObjectSetValue( comp, "config_explosion", "physics_explosion_power.max", tostring(expower))
				]]
			end
			
			EntityAddTag(projectile, "nap-more_knockback" )
		end
	end
end