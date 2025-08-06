dofile_once("data/scripts/lib/utilities.lua")

local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )

local vel_x,vel_y = 0,0

edit_component( entity_id, "VelocityComponent", function(comp,vars)
	vel_x,vel_y = ComponentGetValueVector2( comp, "mVelocity" )
end)

local speed = math.sqrt( vel_y ^ 2 + vel_x ^ 2 )

if ( speed < 2 ) then
	SetRandomSeed( GameGetFrameNum(), pos_x + pos_y + entity_id )

	edit_component( entity_id, "VelocityComponent", function(comp,vars)
		local vel_x,vel_y = ComponentGetValueVector2( comp, "mVelocity")
	
		--local scale = math.max( math.abs( vel_x ), math.abs( vel_y ) ) * 0.4
		--local random_adjustment = Random( 0 - scale, scale )
		local random_adjustment = Random( -2, 2 )

		vel_x = vel_x + random_adjustment
		vel_y = vel_y + random_adjustment

		ComponentSetValueVector2( comp, "mVelocity", vel_x, vel_y)
	end)
end