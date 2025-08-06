dofile_once("data/scripts/streaming_integration/event_utilities.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/lib/coroutines.lua")
dofile( "data/scripts/perks/perk.lua" )
dofile( "data/scripts/game_helpers.lua" )
dofile_once("data/scripts/perks/perk_utilities.lua")

for i,entity_id in pairs( get_enemies_in_radius(256) ) do
	if ((not EntityHasTag( entity_id, "nap-glassparty")) and EntityGetName(entity_id) ~= "$animal_boss_limbs" and EntityGetName(entity_id) ~= "$animal_boss_centipede") then
		local x, y = EntityGetTransform( entity_id )
		
		local perk_data = get_perk_with_id( perk_list, "GLASS_CANNON" )
		give_perk_to_enemy( perk_data, entity_id, 0 )
		
		EntityAddTag( entity_id, "nap-glassparty")
	end
end