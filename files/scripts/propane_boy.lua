dofile_once("data/scripts/lib/utilities.lua")

function spawn_propane_boy(entity_id)
	local x, y = EntityGetTransform( entity_id )
	local players = EntityGetInRadiusWithTag( x, y, 192, "player_unit" )
	if ( #players > 0 ) then
		EntityLoad("data/entities/buildings/statue_hand_fx.xml", x, y)
		EntityLoad( "mods/Nemesis-Ability-Plus/files/entities/propane_boy/propane_boy.xml", x, y )
		local abs = EntityGetInRadiusWithTag(x, y, 768, "static_propane_boy")
		for _, eid in ipairs(abs) do
			local tx, ty = EntityGetTransform(eid)
			EntityKill(eid)
		end
	end
end

function physics_body_modified( is_destroyed )
	local entity_id = GetUpdatedEntityID()
	spawn_propane_boy(entity_id)
end

function collision_trigger( colliding_entity_id )
	local entity_id = GetUpdatedEntityID()
	spawn_propane_boy(entity_id)
end

function kick()
	local entity_id = GetUpdatedEntityID()
	spawn_propane_boy(entity_id)
end

function damage_received( damage, desc, entity_who_caused, is_fatal )
	local entity_id = GetUpdatedEntityID()
	spawn_propane_boy(entity_id)
end