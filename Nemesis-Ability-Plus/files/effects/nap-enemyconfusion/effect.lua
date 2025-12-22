dofile_once("data/scripts/streaming_integration/event_utilities.lua")
dofile_once("data/scripts/lib/utilities.lua")

for i,entity_id in pairs( get_enemies_in_radius(512) ) do
	if (not EntityHasTag( entity_id, "nap-enemyconfusion") and EntityGetName(entity_id) ~= "$animal_boss_limbs" and EntityGetName(entity_id) ~= "$animal_boss_centipede") then
		local x, y = EntityGetTransform( entity_id )
					
		local eid = EntityLoad( "mods/Nemesis-Ability-Plus/files/entities/misc/effect_confusion_enemy.xml", x, y )
		EntityAddChild( entity_id, eid )
		EntityAddTag( entity_id, "nap-enemyconfusion")
	end
end