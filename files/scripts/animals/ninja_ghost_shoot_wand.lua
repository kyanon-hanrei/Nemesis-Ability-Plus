dofile_once("data/scripts/lib/utilities.lua")

function wand_fired( wand_id )
	local projectile_velocity = 600

	local entity_id = GetUpdatedEntityID()
	local children = EntityGetAllChildren( entity_id )
	local ghost_ids = {}

	if ( children ~= nil ) then
		for i,v in ipairs( children ) do
			if EntityHasTag( v, "ninja_ghost" ) then
				table.insert( ghost_ids, v )
			end
		end
	end
	
	if ( wand_id ~= nil ) and ( wand_id ~= NULL_ENTITY ) then
		for a,ghost_id in ipairs( ghost_ids ) do
			local pos_x, pos_y = EntityGetTransform( ghost_id )
			local comp_cd = EntityGetFirstComponent( ghost_id, "VariableStorageComponent", "ninja_ghost_cooldown" )
			
			if ( comp_cd ~= nil ) then
				local cd = ComponentGetValue2( comp_cd, "value_int" )
				if ( cd == 0 ) then
					SetRandomSeed(pos_x + GameGetFrameNum(), pos_y)
					projectile_velocity = Random( 550, 750 )

					local x,y,dir = EntityGetTransform( wand_id )
					local projectile = "data/entities/projectiles/deck/disc_bullet.xml"

					local vel_x = math.cos( 0 - dir ) * projectile_velocity
					local vel_y = 0 - math.sin( 0 - dir ) * projectile_velocity

					local i = Random( 1 , 300 )
					local j = Random( 1 , 2 )
					local k = i * ( (-1) ^ j )
						
					shoot_projectile( entity_id, projectile, pos_x, pos_y, vel_x + k, vel_y + k )
						
					cd = 10
				end
				
				ComponentSetValue2( comp_cd, "value_int", cd )
			end
		end
	end
end

