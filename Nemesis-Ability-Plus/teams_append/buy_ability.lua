dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/ws/events.lua")
dofile_once("data/scripts/game_helpers.lua")
dofile_once("data/scripts/streaming_integration/event_utilities.lua")

local _send_ability = send_ability
send_ability = function (ability,x,y)
    if (sendToSelf) then
      --GamePrint(ability)
      -- doesn't work with coroutines
      local fn = ABILITIES[ability].fn
      if (fn ~= nil) then fn() end
    else
      local queue = json.decode(NT.wsQueue)
      if (NEMESIS.nt_nemesis_team ~= nil) then
        local team = NEMESIS.nt_nemesis_team
        local nemesisPoint = NEMESIS.points
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisAbility", ability=ability, x=x, y=y, team=team, nemesisPoint=nemesisPoint}})
        --stats
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        team_stats = team_stats or {}
        team_stats[team] = team_stats[team] or {}
        team_stats[team].abilities_gained = (team_stats[team].abilities_gained or 0) + 1
        team_stats[team].abilities_gained_mina = (team_stats[team].abilities_gained_mina or 0) + 1
        NEMESIS.team_stats = json.encode(team_stats)
      else
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisAbility", ability=ability, x=x, y=y}})
      end
      NEMESIS.ability_used_count = (NEMESIS.ability_used_count or 0) + 1
      NT.wsQueue = json.encode(queue)
    end
end

interacting = function ( entity_who_interacted, entity_interacted, interactable_name )
    local x, y = EntityGetTransform(entity_interacted)
    local ability_comp = get_variable_storage_component(entity_interacted, "nemesis_ability")
    local price_comp = get_variable_storage_component(entity_interacted, "ability_price")

    local ability = ComponentGetValue2(ability_comp, "value_string")
    local price = ComponentGetValue2(price_comp, "value_int")

    local points = NEMESIS.points
	SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
	
	--以下、RiskyAbility用と死んだプレイヤーのお邪魔取得を止める処理

	dofile_once("mods/noita-nemesis/files/scripts/utils.lua")
	
	local player_id = get_player()
	local dcomps = EntityGetComponent( player_id, "DamageModelComponent" )
	local hp = 0
	local max_hp = 0
	local no_teleport_rule = ModSettingGet("Nemesis-Ability-Plus.NAP_NO_TELEPORT_RULE")
	
	if NEMESIS.alive ~= false then 
		if (EntityHasTag( entity_interacted, "NEMESIS_RISKY_ABILITY")) then
			if ( dcomps ~= nil ) then
				for j,comp in ipairs( dcomps ) do
					local hp = ComponentGetValue2( comp, "hp" )
					local max_hp = ComponentGetValue2( comp, "max_hp" )
			
					max_hp = max_hp - ( price / 25 )
					hp = math.min( max_hp , hp )
				
					ComponentSetValue2( comp, "max_hp", max_hp )
					ComponentSetValue2( comp, "hp", hp )
				end
			end

			SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
	
			send_ability(ability, math.floor(x), math.floor(y))

				--以下、Dアビリティ用の処理
			if (EntityHasTag( entity_interacted, "NEMESIS_DANGEROUS_ABILITY")) then
				ABILITIES[ability].fn()
				--以下、テレポ禁止ルール時のテレポ禁止のボーナス
				if (no_teleport_rule == true and ability == "nap-d-noteleport") then
					noteleport_ability_bonus(x,y,dcomps)
				end
				--以上、テレポ禁止ルール時のテレポ禁止のボーナス
			end
				--以上、Dアビリティ用の処理
				
			EntityKill(entity_interacted)
			EntityLoad("data/entities/particles/poof_red_sparse.xml", x, y)
		
			if (ability == "fizzled") then
				NEMESIS.fizzled_count = NEMESIS.fizzled_count + 1
			end
	
			NEMESIS.risky_ability_count = NEMESIS.risky_ability_count + 1
	
				--以上、RiskyAbility用と死んだプレイヤーのお邪魔取得を止める処理
	
		elseif (points >= price) then
			NEMESIS.points = NEMESIS.points - price
			send_ability(ability, math.floor(x), math.floor(y))
				--以下、Dアビリティ用の処理
			if (EntityHasTag( entity_interacted, "NEMESIS_DANGEROUS_ABILITY")) then
				ABILITIES[ability].fn()
				--以下、テレポ禁止ルール時のテレポ禁止のボーナス
				if (no_teleport_rule == true and ability == "nap-d-noteleport") then
					noteleport_ability_bonus(x,y,dcomps)
				end
				--以上、テレポ禁止ルール時のテレポ禁止のボーナス
			end
				--以上、Dアビリティ用の処理

			EntityKill(entity_interacted)
		
				--以下、HelpfulBooster用のポイント加算処理
			if NEMESIS.helpful_booster_count ~= nil then
				NEMESIS.helpful_booster_count = NEMESIS.helpful_booster_count + 10
			end
				--以上、HelpfulBooster用のポイント加算処理
				--以下、短絡カウンター用のポイント加算処理
			if ((ability == "fizzled") and (NEMESIS.fizzled_count ~= nil))then
				NEMESIS.fizzled_count = NEMESIS.fizzled_count + 1
			end
				--以上、短絡カウンター用のポイント加算処理
			if (string.sub (ability,1,7)~="nap-al-") then
				--以下、NG+用のお邪魔消去範囲調整
				local erase_radius = 1000
				local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
				--if ngcount == "0" then
				if ngcount ~= "0" then
					erase_radius = 80
				end
				local abs = EntityGetInRadiusWithTag(x, y - 25, erase_radius, "NEMESIS_ABILITY")
				--以上、NG+用のお邪魔消去範囲調整
				for _, eid in ipairs(abs) do
					local tx, ty = EntityGetTransform(eid)
					EntityLoad("data/entities/particles/poof_pink.xml", tx, ty)
					EntityKill(eid)
				end
			elseif (Random(1, 4)==1) then
				NEMESIS.points = NEMESIS.points + math.floor(price / 2)
				EntityLoad("data/entities/particles/poof_pink.xml", x, y)
				GamePrintImportant("Lucky! You got half of your payment back!")
			else
				EntityLoad("data/entities/particles/poof_pink.xml", x, y)
			end
		end
		--以下、RiskyAbility用と死んだプレイヤーのお邪魔取得を止める処理
	end
	--以上、RiskyAbility用と死んだプレイヤーのお邪魔取得を止める処理
end

function noteleport_ability_bonus(x,y,dcomps)
	if ( dcomps ~= nil ) then
		for i,comp in ipairs( dcomps ) do
			max_hp = ComponentGetValue2( comp, "max_hp" )
			max_hp = max_hp + 1
			ComponentSetValue2( comp, "max_hp", max_hp )
		end
	end
	local remove_timer = false
	for i = 1,3 do
		load_gold_entity( "data/entities/items/pickup/goldnugget_50.xml", x + Random(-10,10), y - 4 + Random(-10,5), remove_timer )
	end
end