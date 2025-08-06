dofile_once("data/scripts/streaming_integration/event_utilities.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/lib/coroutines.lua")
dofile( "data/scripts/perks/perk.lua" )
dofile( "data/scripts/game_helpers.lua" )

for i,entity_id in pairs( get_enemies_in_radius(512) ) do
	if ((not EntityHasTag( entity_id, "nap-enemyperk")) and EntityGetName(entity_id) ~= "$animal_boss_limbs" and EntityGetName(entity_id) ~= "$animal_boss_centipede") then
		local x, y = EntityGetTransform( entity_id )
		SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - entity_id )
		
		give_random_perk_to_enemy( entity_id )
		
		EntityAddTag( entity_id, "nap-enemyperk")
	end
end