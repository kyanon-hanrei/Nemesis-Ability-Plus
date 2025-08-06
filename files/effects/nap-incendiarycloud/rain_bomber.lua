dofile_once("data/scripts/lib/utilities.lua")

local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )

SetRandomSeed( GameGetFrameNum(), pos_x + pos_y + entity_id )

local rnd = 1

if (rnd == 1) then
	local offset_x = Random( -16, 16 )

	shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/grenade_cloud.xml", pos_x + offset_x, pos_y - 37, 0, -120 )
end
