dofile_once("data/scripts/lib/utilities.lua")

function damage_received( damage, desc, entity_who_caused, is_fatal )
	local entity_id    = GetUpdatedEntityID()
	local x, y = EntityGetTransform( entity_id )

	if( entity_who_caused == entity_id ) then return end
	if script_wait_frames( entity_id, 20 ) then  return  end
	
	SetRandomSeed( GameGetFrameNum(), x + y + entity_id )
	
	local angle_inc = 0
	local angle_inc_set = false
	
	local length = 300
	local length_s = 15
	
	local player_id = EntityGetClosestWithTag(x, y, "player_unit")
	local p_x, p_y = EntityGetTransform( player_id )
	
	if ( entity_who_caused ~= nil ) and ( entity_who_caused ~= NULL_ENTITY ) then
		local ex, ey = EntityGetTransform( entity_who_caused )
		
		if ( ex ~= nil ) and ( ey ~= nil ) then
			angle_inc = 0 - math.atan2( ( ey - y ), ( ex - x ) )
			angle_inc_set = true
		elseif ( p_x ~= nil ) and ( p_y ~= nil ) then
			angle_inc = 0 - math.atan2( ( p_y - y ), ( p_x - x ) )
			angle_inc_set = true
		end
	end
	

	local angle = 0
	if angle_inc_set then
		angle = angle_inc + Random( -3, 3 ) * 0.01
	else
		angle = math.rad( Random( 1, 360 ) )
	end
		
	local vel_x = math.cos( angle ) * length
	local vel_y = 0- math.sin( angle ) * length
		
	local d_x = math.cos( angle ) * length_s
	local d_y = 0- math.sin( angle ) * length_s

	shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/small_ice_propane_tank.xml", x + d_x, y + d_y, vel_x, vel_y )
	GameEntityPlaySound( entity_id, "shoot" )

end
