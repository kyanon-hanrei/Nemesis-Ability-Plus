dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once( "data/scripts/game_helpers.lua" )

interacting = function ( entity_who_interacted, entity_interacted, interactable_name )
	
	local player_entity = EntityGetClosestWithTag( 0, 0, "player_unit")
	local x, y = EntityGetTransform( player_entity )
	
	local frames = 60 * 60
	local life_up_points = 15 / 25
	
	local dcomps = EntityGetComponent( player_entity, "DamageModelComponent" )
	local hp = 0
	local max_hp = 0
	
	if ( dcomps ~= nil ) then
		for i,comp in ipairs( dcomps ) do
			max_hp = ComponentGetValue2( comp, "max_hp" )
			hp = ComponentGetValue2( comp, "hp" )
			
			max_hp = max_hp + life_up_points
			hp = hp + life_up_points
			
			ComponentSetValue2( comp, "max_hp", max_hp )
			ComponentSetValue2( comp, "hp", hp )
		end
	end
	
	GameRegenItemActionsInPlayer( player_entity )
	
	local game_effect_comp,game_effect_entity = GetGameEffectLoadTo( player_entity, "MANA_REGENERATION", false )
	if (game_effect_comp ~= nil) and (game_effect_entity ~= nil) then
		ComponentSetValue( game_effect_comp, "frames", frames )
	end
	
	local efile = "mods/Nemesis-Ability-Plus/files/entities/helpfulbooster/effect.xml"
	local thingy = EntityLoad(efile, x, y)
	local effectcomp = EntityGetFirstComponent(thingy, "GameEffectComponent")
	if (effectcomp) then
		ComponentSetValue2(effectcomp, "frames", frames)
	end
	
	EntityAddComponent2(thingy, "LifetimeComponent",
	{
	lifetime=frames
	})
	
	EntityAddChild(player_entity, thingy)
	
	local points = NEMESIS.points
	local helpful_booster_count = NEMESIS.helpful_booster_count
	--[[
	if helpful_booster_count <= 20 then
		if points ~= nil then
			NEMESIS.points = NEMESIS.points + 15
		end
	end
	
	if helpful_booster_count <= 10 then
		local wallet = EntityGetComponent( player_entity, "WalletComponent" )
		if( wallet ~= nil ) then
			for i,v in ipairs(wallet) do
				money = tonumber( ComponentGetValue( v, "money" ) )
				money = money + 100
				ComponentSetValue( v, "money", money)
			end
		end
	end
	]]
	SetRandomSeed( x + GameGetFrameNum(), y + GameGetFrameNum() )
	local remove_timer = false
	if helpful_booster_count == 0 then
		load_gold_entity( "data/entities/items/pickup/goldnugget_200.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
		load_gold_entity( "data/entities/items/pickup/goldnugget_50.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
		for i = 1,2 do
			load_gold_entity( "data/entities/items/pickup/goldnugget_10.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
		end
	elseif helpful_booster_count <= 10 then
		for i = 1,3 do
			load_gold_entity( "data/entities/items/pickup/goldnugget_50.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
		end
		for i = 1,3 do
			load_gold_entity( "data/entities/items/pickup/goldnugget_10.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
		end
	elseif helpful_booster_count <= 20 then
		for i = 1,2 do
			load_gold_entity( "data/entities/items/pickup/goldnugget_50.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
		end
		for i = 1,4 do
			load_gold_entity( "data/entities/items/pickup/goldnugget_10.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
		end
	end
	GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/heart_fullhp/create", x, y )
	EntityKill(entity_interacted)
end
