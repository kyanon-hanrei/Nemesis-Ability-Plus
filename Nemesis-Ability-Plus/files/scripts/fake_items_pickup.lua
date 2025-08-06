dofile_once("data/scripts/lib/utilities.lua")

function shoot_fakeshot( entity_item, player_entity )
	local message_list={
		"It's a Fake.  :-P",
		"It's a Fake.  :D",
		"It's a Fake.  ;)",
		"It's a Fake.  :O",
		"It's a Fake.  XD",
		"It's a Fake.  :-C",
		"It's a Fake.  :(",
		"It's a Fake.  :-)"
	}
	--local player_entity = EntityGetClosestWithTag( 0, 0, "player_unit")
	local x, y = EntityGetTransform( player_entity )
	SetRandomSeed( GameGetFrameNum() + x, GameGetFrameNum() + y)
	local j = Random(1, #message_list)	
	GamePrintImportant(message_list[j])
	GamePlaySound( "data/audio/Desktop/explosion.bank", "explosions/liquid", x, y )
	local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/fake_shot.xml", x , y - 1 , 0, 2000 )
	EntityKill( entity_item )
end

function item_pickup( entity_item, entity_who_picked, name )
	local player_entity = entity_who_picked
	shoot_fakeshot( entity_item, player_entity )
end

function physics_body_modified( is_destroyed )
	local player_entity = EntityGetClosestWithTag( 0, 0, "player_unit")
	local entity_item = GetUpdatedEntityID()
	if not EntityGetIsAlive( entity_who_caused ) then
	else
		local entity_caused = entity_who_caused
		if player_entity == entity_caused then
			shoot_fakeshot( entity_item, player_entity )
		end
	end
end

function damage_received( damage, desc, entity_who_caused, is_fatal )
	local player_entity = EntityGetClosestWithTag( 0, 0, "player_unit")
	local entity_item = GetUpdatedEntityID()
	if not EntityGetIsAlive( entity_who_caused ) then
	else
		local entity_caused = entity_who_caused
		if player_entity == entity_caused then
			shoot_fakeshot( entity_item, player_entity )
		end
	end
end