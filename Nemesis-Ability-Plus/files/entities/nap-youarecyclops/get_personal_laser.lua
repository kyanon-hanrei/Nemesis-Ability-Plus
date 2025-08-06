dofile( "data/scripts/game_helpers.lua" )
dofile_once("data/scripts/lib/utilities.lua")
dofile( "data/scripts/perks/perk.lua" )
dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/streaming_integration/event_utilities.lua")
dofile_once("data/scripts/perks/perk_utilities.lua")



local players = get_players()

for i,entity_id in ipairs( players ) do
	local x,y = EntityGetTransform( entity_id )
	local pid = perk_spawn( x, y, "PERSONAL_LASER" )
	perk_pickup( pid, entity_id, pid, true, false )
end