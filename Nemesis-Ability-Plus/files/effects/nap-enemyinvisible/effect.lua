dofile_once("data/scripts/streaming_integration/event_utilities.lua")
dofile_once("data/scripts/lib/utilities.lua")

for i,entity_id in pairs( get_enemies_in_radius(500) ) do
	if (not EntityHasTag( entity_id, "nap-invisibility") and EntityGetName(entity_id) ~= "$animal_boss_limbs" and EntityGetName(entity_id) ~= "$animal_boss_centipede") then
		local x, y = EntityGetTransform( entity_id )
					
		local effect_id = EntityLoad( "data/scripts/streaming_integration/entities/effect_invisibility.xml", x, y )
		set_lifetime( effect_id, 0.75 )
		EntityAddChild( entity_id, effect_id )
		EntityAddTag( entity_id, "nap-invisibility")
	end
end