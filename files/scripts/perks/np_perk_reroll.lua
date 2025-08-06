dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once( "data/scripts/perks/perk.lua" )

function item_pickup( entity_item, entity_who_picked, item_name )
	local pos_x, pos_y = EntityGetTransform( entity_item )
	np_perk_reroll_perks( entity_item )
	
	-- spawn a new one
	EntityKill( entity_item )
	EntityLoad( "mods/Nemesis-Ability-Plus/files/entities/items/pickup/np_perk_reroll.xml", pos_x, pos_y )
end
