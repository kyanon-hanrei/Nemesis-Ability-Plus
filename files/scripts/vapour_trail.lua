dofile_once("data/scripts/lib/utilities.lua")

local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )

local vel_x, vel_y = GameGetVelocityCompVelocity(entity_id)
vel_x = -vel_x * 25
vel_y = -vel_y * 100
shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/blood_coldburst.xml", pos_x, pos_y, vel_x, vel_y )

