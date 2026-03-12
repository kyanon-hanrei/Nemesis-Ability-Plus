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

	local dcomps = EntityGetComponent( player_entity, "DamageModelComponent" )
	local hp = 0
	local max_hp = 0
	
	if ( dcomps ~= nil ) then
		for i,comp in ipairs( dcomps ) do
			max_hp = ComponentGetValue2( comp, "max_hp" )
			hp = ComponentGetValue2( comp, "hp" )
			
			if((max_hp * 25) > 5)then
				max_hp = max_hp - (5 / 25)
			end

			if ( hp > max_hp )then
				hp = max_hp
			end
			
			ComponentSetValue2( comp, "max_hp", max_hp )
			ComponentSetValue2( comp, "hp", hp )
		end
	end

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