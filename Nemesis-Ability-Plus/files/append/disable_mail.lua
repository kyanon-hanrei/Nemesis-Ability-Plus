dofile_once("mods/noita-together/files/ws/events.lua")
dofile_once("data/scripts/lib/utilities.lua")

dofile_once("mods/noita-together/files/scripts/json.lua") --TESTIN

--以下、Teams式バイオームコスト計算、faintsnovさんに怒られたら修正します。
biomes ={
	[2] = 1,
	[5] = 2,
	[9] = 3,
	[12] = 4,
	[16] = 5,
	[20] = 5,
    [25] = 5 
}
--以上、Teams式バイオームコスト計算、faintsnovさんに怒られたら修正します。

abilities = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
	[7] = {}
}

--以下、Teams式お邪魔リロード、faintsnovさんに怒られたら修正します。
local function reload_abilities(tier)
    abilities[tier]={}
    for _, value in pairs(ABILITIES) do
        table.insert(abilities[tier], {
            probability = value.weigths[tier],
            id = value.id,
            name = value.name
        })
    end
end
--以上、Teams式お邪魔リロード、faintsnovさんに怒られたら修正します。

for _, value in pairs(ABILITIES) do
    for i, weight in ipairs(value.weigths) do
        table.insert(abilities[i], {
            probability = weight,
            id = value.id,
            name = value.name
        })
    end
end

function spawn_spell_eater(x,y)
	SetRandomSeed(69420+x,42069+y)
	local rnd = random_create(x, y)
	y = y - 3
	--Teams式NG+お邪魔出現再現、faintsnovさんに怒られたら修正します。
	local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
	--if ngcount == "0" then
	if ngcount ~= "0" then
		reload_abilities(6)
		for i=1, 3 do
			SpawnNemesisAbility(x+6, y - (i-1)*25, rnd)
			SpawnNemesisAbility(x+25, y - (i-1)*25, rnd)
		end
	else
		for i=1, 3 do
			SpawnNemesisAbility(x+4, y - (i-1)*25, rnd)
		end
	end
end

function spawn_spell_spitter(x,y)
	SetRandomSeed(42069+x,69420+y)
    local rnd = random_create(x, y)
    y = y - 3
	--Teams式NG+お邪魔出現再現、faintsnovさんに怒られたら修正します。
	local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
	--if ngcount == "0" then
	if ngcount ~= "0" then
		reload_abilities(6)
		for i=1, 3 do
			SpawnNemesisAbility(x-6, y - (i-1)*25, rnd)
			SpawnNemesisAbility(x-25, y - (i-1)*25, rnd)
		end
	else
		for i=1, 3 do
			SpawnNemesisAbility(x-4, y - (i-1)*25, rnd)
		end
	end
    --以下、値札表示用
	local costflag = EntityGetClosestWithTag(x-100,y-50, "SHOW_NP_COST")
	local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
	local shownnp_path = "mods/Nemesis-Ability-Plus/files/entities/shownp/shownp.xml"
	if ngcount ~= "0" then
		shownnp_path = "mods/Nemesis-Ability-Plus/files/entities/shownp/shownp_ng.xml"
	end
	if costflag == 0 then
		--EntityLoad( shownnp_path, x-75 , y-50 )
		EntityLoad( shownnp_path, x-100 , y-50 )
	end
	--以上、値札表示用
	--以下、RiskyAbility用
	local risky_ability_on = ModSettingGet("Nemesis-Ability-Plus.NAP_APPEARING_RISKY_ABILITY")
	if risky_ability_on == true then
		local riskyng = EntityGetClosestWithTag(x+37,y-50, "NEMESIS_RISKY_ABILITY")
		if (riskyng == 0) then
			dofile_once("mods/noita-nemesis/files/scripts/utils.lua")
			dofile_once("mods/noita-nemesis/files/store.lua")
			if (NEMESIS.deaths > 0) then
				SpawnRiskyNemesisAbility(x+37,y-50, rnd)
			end
		end
	end
	--以上、RiskyAbility用
end

function SpawnNemesisAbility(x,y, rnd)
	if (not GameHasFlagRun("NT_NEMESIS_nemesis_abilities")) then return end
        local level = math.floor(y/512) -- 2, 5, 9, 12, 16, 20
        local tier = biomes[level]
		--Teams式のNPコスト計算法、faintsnovさんに怒られたら修正します。
		local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
		if ngcount ~= "0" then
			level = 25 + math.floor(y/512)
			tier = 6
		end
        local ability = pick_random_from_table_weighted(rnd, abilities[tier])
        for i, v in ipairs(abilities[tier]) do
            if (v.id == ability.id) then
                table.remove(abilities[tier], i)
            end
        end
        local price = 10*math.floor(math.pow(level, 1.5)) + 15
		--以下、AL,DAbility用
		local entity_path = "mods/noita-nemesis/files/entities/ability/entity.xml"
	    if (string.sub (ability.id,1,7)=="nap-al-") then
			entity_path = "mods/Nemesis-Ability-Plus/files/entities/ability/entity.xml"
		elseif (string.sub (ability.id,1,6)=="nap-d-") then
			entity_path = "mods/Nemesis-Ability-Plus/files/entities/ability-d/entity.xml"
		end
		--以上、AL,DAbility用
		local ability_eid = EntityLoad(entity_path, x, y)
		EntityAddComponent2(ability_eid, "VariableStorageComponent", {
			name="nemesis_ability",
			value_string=ability.id
		})
		EntityAddComponent2(ability_eid, "VariableStorageComponent", {
		name="ability_price",
		value_int=price
		})
		
		local interact = EntityGetFirstComponent(ability_eid, "InteractableComponent")
		ComponentSetValue2(interact, "ui_text", "Press $0 to buy "..ability.name.." ("..price..")")
		local uiinfo = EntityGetFirstComponent(ability_eid, "UIInfoComponent")
		ComponentSetValue2(uiinfo, "name", ability.name)
		
		badge = EntityGetFirstComponent( ability_eid, "SpriteComponent", "badge" )
		if (ABILITIES[ability.id].sprite==nil) then
			ComponentSetValue2(badge, "image_file", "mods/noita-nemesis/files/badges/" .. ability.id .. ".png")
		else
			ComponentSetValue2(badge, "image_file", ABILITIES[ability.id].sprite)
		end
end

--以下、RiskyAbility用


function SpawnRiskyNemesisAbility(x,y, rnd)
	if (not GameHasFlagRun("NT_NEMESIS_nemesis_abilities")) then return end
        local level = math.floor(y/512) -- 2, 5, 9, 12, 16, 20
        local tier = biomes[level]
		--Teams式のNPコスト計算法、faintsnovさんに怒られたら修正します。
		local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
		if ngcount ~= "0" then
			level = 25 + math.floor(y/512)
			tier = 6
		end
        local ability = pick_random_from_table_weighted(rnd, abilities[tier])
        for i, v in ipairs(abilities[tier]) do
            if (v.id == ability.id) then
                table.remove(abilities[tier], i)
            end
        end
		
        if (NEMESIS.risky_ability_count == nil) then
            NEMESIS.risky_ability_count = 0
		end

		local player_id = get_player()
		local dcomps = EntityGetComponent( player_id, "DamageModelComponent" )
		local hp = 0
		local max_hp = 0

		if ( dcomps ~= nil ) then
			for j,comp in ipairs( dcomps ) do
				hp = ComponentGetValue2( comp, "hp" )
				max_hp = ComponentGetValue2( comp, "max_hp" )
			end
		end
		
        local price = math.min(math.floor((0.4 + (0.4 * (NEMESIS.risky_ability_count + 1)) + (max_hp * 0.1))*25 ),((max_hp - 0.04)* 25 ))
		
		local entity_path = "mods/Nemesis-Ability-Plus/files/entities/ability-risky/entity.xml"
		if (string.sub (ability.id,1,6)=="nap-d-") then
			entity_path = "mods/Nemesis-Ability-Plus/files/entities/ability-risky-d/entity.xml"
		end
	    local ability_eid = EntityLoad(entity_path, x, y)
        EntityAddComponent2(ability_eid, "VariableStorageComponent", {
            name="nemesis_ability",
            value_string=ability.id
        })
        EntityAddComponent2(ability_eid, "VariableStorageComponent", {
            name="ability_price",
            value_int=price
        })
    
        local interact = EntityGetFirstComponent(ability_eid, "InteractableComponent")
        ComponentSetValue2(interact, "ui_text", "Thee needeth to sacrifice " .. price .. " max hp to picketh this " .. ability.name)
        local uiinfo = EntityGetFirstComponent(ability_eid, "UIInfoComponent")
        ComponentSetValue2(uiinfo, "name", ability.name)
    
        badge = EntityGetFirstComponent( ability_eid, "SpriteComponent", "badge" )
		
        if (ABILITIES[ability.id].sprite==nil) then
            ComponentSetValue2(badge, "image_file", "mods/noita-nemesis/files/badges/" .. ability.id .. ".png")
        else
            ComponentSetValue2(badge, "image_file", ABILITIES[ability.id].sprite)
        end
end
