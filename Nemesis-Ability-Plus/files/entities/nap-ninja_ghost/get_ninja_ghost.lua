dofile( "data/scripts/game_helpers.lua" )
dofile_once("data/scripts/lib/utilities.lua")
dofile( "data/scripts/perks/perk.lua" )
dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/streaming_integration/event_utilities.lua")
dofile_once("data/scripts/perks/perk_utilities.lua")



local players = get_players()

for i,entity_id in ipairs( players ) do
	local x,y = EntityGetTransform( entity_id )
	local child_id = EntityLoad( "mods/Nemesis-Ability-Plus/files/entities/misc/ninja_ghost.xml", x, y )
	EntityAddChild( entity_id, child_id )

	local comp_ng = EntityGetFirstComponent( entity_id, "LuaComponent", "ninja_ghost" )
	if (comp_ng == nil) then
		EntityAddComponent( entity_id, "LuaComponent", 
			{
				_tags = "ninja_ghost",
				script_wand_fired = "mods/Nemesis-Ability-Plus/files/scripts/animals/ninja_ghost_shoot_wand.lua",
				execute_every_n_frame = "1",
			} )
	end
end