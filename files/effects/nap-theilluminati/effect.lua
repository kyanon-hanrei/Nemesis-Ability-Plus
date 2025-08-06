dofile_once( "data/scripts/lib/coroutines.lua" )
dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "data/scripts/game_helpers.lua" )

	local entity_id = GetUpdatedEntityID()
	local comp = EntityGetFirstComponent( entity_id,"UIIconComponent")
	if ( comp ~= nil ) then
		EntitySetTransform( entity_id, "-1", "-1")
	end