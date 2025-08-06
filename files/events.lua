customEvents["NemesisEnemy"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local cx, cy = GameGetCameraPos()
    local target_x = cx - 100
    local target_y = cy - 120
	
	--以下、死んだプレイヤーの画面に敵が現れるのを阻止する処理
	if NEMESIS.alive ~= false then
	--以上、死んだプレイヤーの画面に敵が現れるのを阻止する処理
	
	--以下、teams用
	local team = data.team
	PlayerList[tostring(userId)].team = team
	local nemesisPoint = data.nemesisPoint
	PlayerList[tostring(userId)].nemesisPoint = nemesisPoint
	
	if (team ~= nil) then 
		GamePrint("(" .. team .. ") " .. playername .. " sends an enemy")
		--stats
		local team_stats = json.decode(NEMESIS.team_stats or "[]")
		team_stats = team_stats or {}
		team_stats[team] = team_stats[team] or {}
		team_stats[team].enemies_sent = (team_stats[team].enemies_sent or 0) + 1
		NEMESIS.team_stats = json.encode(team_stats)
	else
		GamePrint(playername .. " sends an enemy")
	end
	
	if (NEMESIS.nt_nemesis_team ~= nil and team == NEMESIS.nt_nemesis_team) then 
		-- GamePrint("avoid enemy, we are same team!")
		return
	end
	--以上、teams用
    
    spawn_entity_in_view_random_angle("mods/noita-nemesis/files/entities/enemy_spawner/entity.xml", 96, 269, 20, function(spawner)
        local dx, dy = EntityGetTransform(spawner)
        EntityAddComponent2(spawner, "VariableStorageComponent", {
            name="dest_x",
            value_float=dx
        })
        EntityAddComponent2(spawner, "VariableStorageComponent", {
            name="dest_y",
            value_float=dy
        })
        EntityAddComponent2(spawner, "VariableStorageComponent", {
            name="enemy_file",
            value_string=data.file or ""
        })
        EntitySetTransform(spawner, target_x, target_y)
        local sprite = EntityGetFirstComponent(spawner, "SpriteComponent")
        ComponentSetValue2(sprite, "image_file", data.icon or "")
    end)
	
	--以下、死んだプレイヤーの画面に敵が現れるのを阻止する処理
    end
	--以上、死んだプレイヤーの画面に敵が現れるのを阻止する処理
	
    GamePrint(playername .. " sends and enemy")
end

local _timed_ability = timed_ability
function timed_ability(name, frames, entity_file, reduction)
    local player = get_player()
    local rrate = reduction or 0.5
    if (player == nil) then return end
    local thing = EntityGetWithName("nemesis_" .. name)
    if (thing ~= 0) then
        local lifetime = EntityGetFirstComponentIncludingDisabled(thing, "LifetimeComponent")
        local creation_frame = ComponentGetValue2(lifetime, "creation_frame")
        local kill_frame = ComponentGetValue2(lifetime, "kill_frame")
        local framesleft = kill_frame-creation_frame
        ComponentSetValue2(lifetime, "kill_frame", creation_frame + math.floor(framesleft*rrate) + frames )
        return
    end
    local x, y = get_player_pos()
    local efile = entity_file or "mods/noita-nemesis/files/effects/".. name .."/effect.xml"
    local thingy = EntityLoad(efile, x, y)
    local effectcomp = EntityGetFirstComponent(thingy, "GameEffectComponent")
    if (effectcomp) then
        ComponentSetValue2(effectcomp, "frames", frames)
    end
    EntityAddComponent2(thingy, "LifetimeComponent", {
        lifetime=frames
    })
    EntityAddChild(player, thingy)
end

--以下、コルミシルマを倒したプレイヤーの通知用

customEvents["NemesisKolmisilmaDefeated"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
	local playername = playerlist[tostring(data.userId)]
	local counts = data.number
	local player = get_player()
	local pos_x, pos_y = get_player_pos()
	
	local pluscounts = "NG"
	
	if ((counts > 0) and (counts <= 3)) then
		for i=1, counts do
			pluscounts = pluscounts .. "+"
		end
	elseif (counts > 3) then
		pluscounts = "NG+" .. counts
    end
	
    GamePrintImportant(playername .. " entered " .. pluscounts)
	
	if ((counts == 0) or (counts % 2 == 0)) then
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/kantele/a/create", pos_x, pos_y )
		--wait(10)
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/kantele/dis/create", pos_x, pos_y )
		--wait(10)
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/kantele/e/create", pos_x, pos_y )
		--wait(10)
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/kantele/g/create", pos_x, pos_y )
	else
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/ocarina/a/create", pos_x, pos_y )
		--wait(10)
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/ocarina/f/create", pos_x, pos_y )
		--wait(10)
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/ocarina/d/create", pos_x, pos_y )
		--wait(10)
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/ocarina/e/create", pos_x, pos_y )
		--wait(10)
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/ocarina/a2/create", pos_x, pos_y )
	end
	
	--以下、サンポフラグをNG+に入ったサインとして立てる処理
	if not PlayerList[tostring(userId)].sampo then
		PlayerList[tostring(userId)].sampo = true
	end
	--以上、サンポフラグをNG+に入ったサインとして立てる処理
end

--以上、コルミシルマを倒したプレイヤーの通知用
--以下、旧Fix、Teamsの再現
ABILITIES["trip"] = {
    id="trip", name="Trip", weigths={0.80, 0.80, 0.80, 0.80, 0.80, 0.80},
    fn=function ()
        local player = get_player()
        local fungi = CellFactory_GetType("fungi")
        GlobalsSetValue("fungal_shift_last_frame", "-1000000")
        EntityIngestMaterial( player, fungi, 600 )
    end
}
ABILITIES["sanic"] = {
    id="sanic", name="Sanic", weigths={0.20, 0.10, 0.50, 0.50, 0.50, 0.50},
    fn=function()
        timed_ability("sanic", 60*45)
    end
}
--[[
ABILITIES["fizzled"] = {
    id="fizzled", name="Fizzled", weigths={0.80, 0.80, 0.80, 0.80, 0.80, 0.80},
    fn=function()
        timed_ability("fizzled", 60*30)
		--要検討
    end
}]]
ABILITIES["removerandomPerk"] = {
    id="removerandomPerk", name="Remove RandomPerk", weigths={0, 0, 0, 0, 0, 0},
    fn=function()
        remove_random_perk()
    end
}
ABILITIES["loosechunks"] = {
    id="loosechunks", name="Loose Chunks", weigths={0.40, 0.40, 0.40, 0.40, 0.40, 0.40},
    fn=function()
        timed_ability("loosechunks", 60*15, "mods/Nemesis-Ability-Plus/files/effects/loosechunks/effect.xml")
    end
}
--以上、旧Fix、Teamsの再現

--以下、既存のアビリティの改変
ABILITIES["tanks"] = {
    id="tanks", name="Tanks", weigths={0.60, 0.60, 0.60, 0.60, 0.60, 0.60},
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local r = Random(4, 5)
        for i=1, r do 
		    if i == 1 then
                if r == 4 then
					spawn_entity_in_view_random_angle("data/entities/animals/tank_super.xml", 40, 200, 0, function(eid)
                	    EntityAddTag(eid, "NEMESIS_ENEMY")
                	    entity_attack_timer(eid, 20000)
                	end)
				else
                	spawn_entity_in_view_random_angle("data/entities/animals/tank_rocket.xml", 40, 200, 0, function(eid)
                	    EntityAddTag(eid, "NEMESIS_ENEMY")
                	    entity_attack_timer(eid, 20000)
                	end)
				end
			else
                spawn_entity_in_view_random_angle("data/entities/animals/tank.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
			end
        end
    end
}

ABILITIES["acid"] = {
    id="acid", name="Acid", weigths={0.1, 0.1, 0.1, 0.1, 0.1, 0.1},
    fn=function()
        timed_ability("acid", 60*5,"mods/Nemesis-Ability-Plus/files/effects/acid/effect.xml")
        for i=1, 6 do 
            spawn_entity_in_view_random_angle("data/entities/projectiles/deck/acidshot.xml", 20, 180)
        end
    end
}
ABILITIES["steve"] = {
    id="steve", name="Steve", weigths={0.001, 0.001, 0.01, 0.02, 0.1, 0.1},
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		spawn_entity_in_view_random_angle("data/entities/animals/necromancer_shop.xml", 60, 200, 0, function(eid)
            EntityAddTag(eid, "NEMESIS_ENEMY")
            EntityAddTag(eid, "NEMESIS_ABILITY_STEVE_ON")
			ComponentSetValue( GetGameEffectLoadTo( eid, "BERSERK", true ), "frames", -1 )
            entity_attack_timer(eid, 20000)
        end)
        timed_ability("steve", 60*1,"mods/Nemesis-Ability-Plus/files/effects/steve/effect.xml")
    end
}
ABILITIES["spikedrinks"] = {
    id="spikedrinks", name="Spike Drinks", weigths={0.80, 0.80, 0.80, 0.80, 0.80, 0.80},
    fn=function()
        local drinks = {
            --"lava",
            "alcohol",
            --"acid",
            --"radioactive_liquid",
            "magic_liquid_polymorph",
            "magic_liquid_random_polymorph",
            --"blood_cold",
            "poison",
            "magic_liquid_weakness",
            "material_confusion",
            "material_darkness"
        }
        local inventory = GetInven()
        local items = EntityGetAllChildren(inventory)
        if items ~= nil then
            for _, item_id in ipairs(items) do
                local flask_comp = EntityGetFirstComponentIncludingDisabled(item_id, "MaterialInventoryComponent")
                if flask_comp ~= nil then
                    local potion_material = random_from_array(drinks)
                    AddMaterialInventoryMaterial(item_id, potion_material, 150)
                end
            end
        end
    end
}
--以上、既存のアビリティの改変

--以下、追加アビリティ
ABILITIES["nap-al-blindness"] = {
    id="nap-al-blindness", name="nap-Blindness", weigths={0.85, 0.40, 0.60, 0.85, 0.30, 0.50},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-blindness.png",
    fn=function()
        timed_ability("nap-blindness", 60*10,"mods/Nemesis-Ability-Plus/files/effects/nap-blindness/effect.xml")
    end
}
ABILITIES["nap-al-explosive-projectile"] = {
    id="nap-al-explosive-projectile", name="nap-Explosive Projectile", weigths={0.40, 0.30, 0.40, 0.20, 0.30, 0.20},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-explosive-projectile.png",
    fn=function()
        timed_ability("nap-explosive-projectile", 60*30,"mods/Nemesis-Ability-Plus/files/effects/nap-explosive-projectile/effect.xml")
    end
}
ABILITIES["nap-youwantthis"] = {
    id="nap-youwantthis", name="nap-You want This", weigths={0.60, 0.60, 0.60, 0.70, 0.85, 0.70},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-youwantthis.png",
    fn=function()
        timed_ability("nap-youwantthis", 60*30,"mods/Nemesis-Ability-Plus/files/effects/nap-Youwantthis/effect.xml")
    end
}
ABILITIES["nap-al-pinwheels"] = {
    id="nap-al-pinwheels", name="nap-Pinwheels", weigths={0.05, 0.1, 0.7, 0.3, 0.4, 0.4},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-pinwheels.png",
    fn=function()
        local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local how_many = 12
        local angle_inc = ( 2 * 3.14159 ) / how_many
        local theta = rot
        local length = 130

        for i=1,how_many do
            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/glitter_bomb.xml", pos_x + math.cos( theta ) * 8, pos_y - math.sin( theta ) * 8, vel_x, vel_y )
            
            theta = theta + angle_inc
        end
    end
}
ABILITIES["nap-al-patsas"] = {
    id="nap-al-patsas", name="nap-Patsas", weigths={0.01, 0.05, 0.1, 0.2, 0.2, 0.6},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-patsas.png",
    fn=function () --
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local r = Random(1, 3)
        for i=1, r do 
            spawn_entity_in_view_random_angle("data/entities/animals/statue.xml", 40, 200, 0, function(eid)
                EntityAddTag(eid, "NEMESIS_ENEMY")
				ComponentSetValue( GetGameEffectLoadTo( eid, "MOVEMENT_FASTER_2X", true ), "frames", -1 )
                entity_attack_timer(eid, 20000)
            end)
		end
    end
}
ABILITIES["nap-turvalennokki"] = {
    id="nap-turvalennokki", name="nap-Turvalennokki", weigths={0.01, 0.05, 0.1, 0.2, 0.2, 0.6},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-turvalennokki.png",
    fn=function () --
        for i=1, 2 do
            spawn_entity_in_view_random_angle("data/entities/animals/drone_shield.xml", 40, 200, 0, function(eid)
                EntityAddTag(eid, "NEMESIS_ENEMY")
                entity_attack_timer(eid, 20000)
            end)
		end
    end
}
ABILITIES["nap-al-ultimatekiller"] = {
    id="nap-al-ultimatekiller", name="nap-Ultimate Killer", weigths={0.01, 0.05, 0.2, 0.3, 0.4, 0.5},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-ultimatekiller.png",
    fn=function () --
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local r = Random(2, 3)
        for i=1, r do 
			spawn_entity_in_view_random_angle("data/entities/animals/ultimate_killer.xml", 40, 200, 0, function(eid)
        	    EntityAddTag(eid, "NEMESIS_ENEMY")
        	    EntityAddTag(eid, "prey")
				ComponentSetValue( GetGameEffectLoadTo( eid, "CHARM", true ), "frames", -1 )
        	    entity_attack_timer(eid, 20000)
        	end)
		end
    end
}
ABILITIES["nap-bigukko"] = {
    id="nap-bigukko", name="nap-Big Ukko", weigths={0.0, 0.0, 0.01, 0.01, 0.05, 0.80},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-bigukko.png",
    fn=function () --
        spawn_entity_in_view_random_angle("data/entities/animals/thundermage_big.xml", 40, 200, 0, function(eid)
            EntityAddTag(eid, "NEMESIS_ENEMY")
			ComponentSetValue( GetGameEffectLoadTo( eid, "MOVEMENT_FASTER_2X", true ), "frames", -1 )
			ComponentSetValue( GetGameEffectLoadTo( eid, "FASTER_LEVITATION", true ), "frames", -1 )
            entity_attack_timer(eid, 20000)
        end)
    end
}
ABILITIES["nap-al-satellitecannon"] = {
    id="nap-al-satellitecannon", name="nap-Satellite Cannon", weigths={0.10, 0.20, 0.40, 0.30, 0.50, 0.30},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-satellitecannon.png",
    fn=function()
        local x,y = get_player_pos()
        EntityLoad("mods/Nemesis-Ability-Plus/files/entities/nap-satellitecannon/entity.xml", x, y + 120)
    end
}

ABILITIES["nap-al-deeryou"] = {
    id="nap-al-deeryou", name="nap-Deer You", weigths={0.00, 0.10, 0.20, 0.40, 0.30, 0.40},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-deeryou.png",
    fn=function () --
		SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local player = get_player()
		if (player == nil) then return end
			local pos_x, pos_y, rot = EntityGetTransform( player )
			local how_many = 10
			local angle_inc = ( 2 * 3.14159 ) / how_many
			local theta = rot
			local length = 900
			for i=1,how_many do
                local vel_x = math.cos( theta ) * length
                local vel_y = 0 - math.sin( theta ) * length
				
				if i <= 5 then
					local r = Random(15, 30)
					local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/exploding_deer_you.xml", pos_x + math.cos( theta ) * r * ((-1)^i), pos_y - math.sin( theta ), vel_x, vel_y )
				else
					spawn_entity_in_view_random_angle("data/entities/animals/deer.xml", 40, 200, 0, function(eid)
        	    	    EntityAddTag(eid, "NEMESIS_ENEMY")
        	     	   entity_attack_timer(eid, 20000)
        	    	end)
        	    end
			end
		
    end
}
ABILITIES["nap-al-drinkingparty"] = {
    id="nap-al-drinkingparty", name="nap-Drinking Party", weigths={0.85, 0.40, 0.85, 0.40, 0.50, 0.40},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-drinkingparty.png",
    fn=function()
        timed_ability("nap-drinkingparty", 60*20,"mods/Nemesis-Ability-Plus/files/effects/nap-drinkingparty/effect.xml")
    end
}
ABILITIES["nap-enemyinvisible"] = {
    id="nap-enemyinvisible", name="nap-Enemy Invisible", weigths={0.50, 0.60, 0.85, 0.60, 0.50, 0.60},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-enemyinvisible.png",
    fn=function()
		timed_ability("nap-enemyinvisible", 60*45,"mods/Nemesis-Ability-Plus/files/effects/nap-enemyinvisible/effect.xml")
    end
}
ABILITIES["nap-al-morerecoil"] = {
    id="nap-al-morerecoil", name="nap-More Recoil", weigths={0.30, 0.85, 0.40, 0.30, 0.50, 0.40},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-morerecoil.png",
    fn=function()
        timed_ability("nap-morerecoil", 60*42,"mods/Nemesis-Ability-Plus/files/effects/nap-morerecoil/effect.xml")
    end
}
ABILITIES["nap-powerrangers"] = {
    id="nap-powerrangers", name="nap-Power Rangers", weigths={0.25, 0.30, 0.25, 0.40, 0.25, 0.30},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-powerrangers.png",
    fn=function () --
        timed_ability("nap-powerrangers", 60*42,"mods/Nemesis-Ability-Plus/files/effects/nap-powerrangers/effect.xml")
    end
}
ABILITIES["nap-al-theilluminati"] = {
    id="nap-al-theilluminati", name="nap-The Illuminati", weigths={0.10, 0.20, 0.30, 0.10, 0.85, 0.20},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-theilluminati.png",
    fn=function()
        timed_ability("nap-theilluminati", 60*45,"mods/Nemesis-Ability-Plus/files/effects/nap-theilluminati/effect.xml")
    end
}
ABILITIES["nap-lavasea"] = {
    id="nap-lavasea", name="nap-Lava Sea", weigths={0.05, 0.2, 0.4, 0.1, 0.4, 0.3},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-lavasea.png",
    fn=function()
        local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local how_many = 2
        local angle_inc = ( 2 * 3.14159 ) / how_many
        local theta = rot
        local length = 100

        for i=1,how_many do
            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length
			
			if i == 1 then
                local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/sea_lava.xml", pos_x + math.cos( theta ) * 12, pos_y - math.sin( theta ) * 12, vel_x, vel_y )
				theta = theta + angle_inc
			else
			    local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/circle_fire_nap.xml", pos_x + math.cos( theta ) * 12, pos_y - math.sin( theta ) * 12, vel_x, vel_y )
				theta = theta + angle_inc
            end
        end
    end
}
ABILITIES["nap-youarecyclops"] = {
    id="nap-youarecyclops", name="nap-You are Cyclops", weigths={0.005, 0.0, 0.001, 0.0, 0.002, 0.01},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-youarecyclops.png",
    fn=function()
        local x,y = get_player_pos()
        EntityLoad("mods/Nemesis-Ability-Plus/files/entities/nap-youarecyclops/entity.xml", x, y)
    end
}
ABILITIES["nap-sluggishwand"] = {
    id="nap-sluggishwand", name="nap-Sluggish Wand", weigths={0.10, 0.10, 0.40, 0.20, 0.40, 0.40},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-sluggishwand.png",
    fn=function()
        timed_ability("nap-sluggishwand", 60*25,"mods/Nemesis-Ability-Plus/files/effects/nap-sluggishwand/effect.xml")
    end
}
ABILITIES["nap-al-konna"] = {
	id="nap-al-konna", name="nap-Konna", weigths={0.50, 0.85, 0.50, 0.40, 0.40, 0.40},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-konna.png",
    fn=function ()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local r = Random(9, 12)
        for i=1, r do 
            if i <= 3 then
			    spawn_entity_in_view_random_angle("data/entities/animals/frog_big.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
			else
			    spawn_entity_in_view_random_angle("data/entities/animals/frog.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
			end
        end
    end
}
ABILITIES["nap-perkenemy"] = {
    id="nap-perkenemy", name="nap-Perk Enemy", weigths={0.0, 0.1, 0.3, 0.4, 0.1, 0.2},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-perkenemy.png",
    fn=function()
		timed_ability("nap-perkenemy", 60*10,"mods/Nemesis-Ability-Plus/files/effects/nap-perkenemy/effect.xml")
    end
}

ABILITIES["nap-al-jigokudisc"] = {
    id="nap-al-jigokudisc", name="nap-Jigoku Disc", weigths={0.0, 0.2, 0.05, 0.3, 0.2, 0.3},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-jigokudisc.png",
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        local length = 1
		local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/disc_bullet_jigoku.xml", pos_x + math.cos( theta ) * 30 * (( -1 )^ j ), pos_y - math.sin( theta ) * 30, vel_x * (( -1 )^ j ), vel_y )
    end
}

ABILITIES["nap-al-cockroachtrap"] = {
    id="nap-al-cockroachtrap", name="nap-Cockroach Trap", weigths={0.0, 0.1, 0.3, 0.1, 0.2, 0.1},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-cockroachtrap.png",
    fn=function()
        local player = get_player()
        local pos_x, pos_y = EntityGetTransform( player )

        -- spawn safe haven
        GamePlaySound( "data/audio/Desktop/projectiles.bank", "projectiles/bullet_launcher", pos_x, pos_y )
        EntityLoad("data/entities/buildings/safe_haven_building.xml", pos_x, pos_y)
	
        for i=1,20 do
        	local x = pos_x + ProceduralRandom(pos_x, pos_y - i, -10, 10)
        	local y = pos_y + ProceduralRandom(pos_x + i, pos_y * 0.63, -8, 8) - 10
        	EntityLoad("data/entities/projectiles/glue.xml", x, y)
        end

        -- props
        EntityLoad("data/entities/projectiles/glue.xml", pos_x - 1, pos_y - 32)
        EntityLoad("data/entities/props/physics_barrel_radioactive.xml", pos_x - 36, pos_y - 12)
        EntityLoad("data/entities/projectiles/deck/mist_slime.xml", pos_x + 1, pos_y - 8)
        EntityLoad("data/entities/props/physics_barrel_radioactive.xml", pos_x + 46, pos_y - 12)
    end
}

ABILITIES["nap-fizzledonesgrudge"] = {
    id="nap-fizzledonesgrudge", name="nap-Fizzled One's Grudge", weigths={0.0, 0.05, 0.30, 0.85, 0.30, 0.35},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-fizzledonesgrudge.png",
    fn=function()
        if (NEMESIS.fizzled_count == nil) then
            NEMESIS.fizzled_count = 0
        end
		SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local counter_time = 0.4 + (NEMESIS.fizzled_count * 0.8)
		local counter_list = counter_list_full
		local fc_amount = math.min(NEMESIS.fizzled_count + 1, #counter_list)
		for i = 1,fc_amount do
			local j = Random(1, #counter_list)
			counter_list[j](counter_time)
			table.remove(counter_list, j)
            if (#counter_list == 0) then
                break
            end
		end
		NEMESIS.fizzled_count = 0
    end
}
ABILITIES["nap-poisonbomb"] = {
    id="nap-poisonbomb", name="nap-Poison Bomb", weigths={0.1, 0.8, 0.3, 0.4, 0.7, 0.2},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-poisonbomb.png",
    fn=function()
        local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        local length = 100
		local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/poisonbomb.xml", pos_x + math.cos( theta ) * 12 * (( -1 )^ j ), pos_y - math.sin( theta ) * 12, vel_x * (( -1 )^ j ), vel_y )
            
    end
}

ABILITIES["nap-thethreemusucketeers"] = {
    id="nap-thethreemusucketeers", name="nap-The Three Musucketeers", weigths={0.0, 0.0, 0.01, 0.05, 0.2, 0.3},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-thethreemusucketeers.png",
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
        for i=1, 4 do 
		    if i == 4 then
                spawn_entity_in_view_random_angle("data/entities/animals/spearbot.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
		    elseif i == 3 then
                spawn_entity_in_view_random_angle("data/entities/animals/assassin.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
		    elseif i == 2 then
                spawn_entity_in_view_random_angle("data/entities/animals/roboguard.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
			else
                spawn_entity_in_view_random_angle("data/entities/animals/missilecrab.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
			end
        end
    end
}

ABILITIES["nap-al-bubblybounce"] = {
    id="nap-al-bubblybounce", name="nap-Bubbly Bounce", weigths={0.6, 0.1, 0.85, 0.1, 0.0, 0.2},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-bubblybounce.png",
    fn=function()
		timed_ability("nap-bubblybounce", 60*30,"mods/Nemesis-Ability-Plus/files/effects/nap-bubblybounce/effect.xml")
    end
}

ABILITIES["nap-powerplantmen"] = {
    id="nap-powerplantmen", name="nap-Powerplant Men", weigths={0.0, 0.0, 0.0, 0.01, 0.05, 0.15},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-powerplantmen.png",
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
        for i=1, 5 do 
		    if i == 5 then
                spawn_entity_in_view_random_angle("data/entities/animals/basebot_hidden.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
		    elseif i == 4 then
                spawn_entity_in_view_random_angle("data/entities/animals/basebot_neutralizer.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
		    elseif i == 3 then
                spawn_entity_in_view_random_angle("data/entities/animals/basebot_sentry.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
		    elseif i == 2 then
                spawn_entity_in_view_random_angle("data/entities/animals/basebot_soldier.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
			else
                spawn_entity_in_view_random_angle("data/entities/animals/roboguard_big.xml", 40, 200, 0, function(eid)
                    EntityAddTag(eid, "NEMESIS_ENEMY")
                    entity_attack_timer(eid, 20000)
                end)
			end
        end
    end
}
ABILITIES["nap-al-moreknockback"] = {
    id="nap-al-moreknockback", name="nap-More Knockback", weigths={0.20, 0.50, 0.20, 0.80, 0.40, 0.30},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-moreknockback.png",
    fn=function()
        timed_ability("nap-moreknockback", 60*45,"mods/Nemesis-Ability-Plus/files/effects/nap-moreknockback/effect.xml")
    end
}
ABILITIES["nap-glassparty"] = {
    id="nap-glassparty", name="nap-Glass Party", weigths={0.00, 0.001, 0.03, 0.001, 0.02, 0.001},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-glassparty.png",
    fn=function()
        timed_ability("nap-glassparty", 60*1,"mods/Nemesis-Ability-Plus/files/effects/nap-glassparty/effect.xml")
    end
}

ABILITIES["nap-partsofomega1"] = {
    id="nap-partsofomega1", name="nap-Parts of Omega1", weigths={0.2, 0.6, 0.0, 0.0, 0.01, 0.03},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-partsofomega1.png",
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
        if (NEMESIS.omega_count == nil) then
            NEMESIS.omega_count = {0,0,0}
        end
		
		if (NEMESIS.omega_count[2] == 1 and NEMESIS.omega_count[3] == 1) then
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole_giga.xml", pos_x + math.cos( theta ) * 30 * (( -1 )^ j ), pos_y - math.sin( theta ) * 30, vel_x * (( -1 )^ j ), vel_y )
			NEMESIS.omega_count = {0,0,0}
			
		elseif (NEMESIS.omega_count[2] == 1 or NEMESIS.omega_count[3] == 1) then
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local distance = 100
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole_big.xml", pos_x + math.cos( theta ) * distance * (( -1 )^ j ), pos_y - math.sin( theta ) * distance, vel_x * (( -1 )^ j ), vel_y )

			NEMESIS.omega_count[1] = 1
		else
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole.xml", pos_x + math.cos( theta ) * 30 * (( -1 )^ j ), pos_y - math.sin( theta ) * 30, vel_x * (( -1 )^ j ), vel_y )
		
			NEMESIS.omega_count[1] = 1
		end
	end
}

ABILITIES["nap-partsofomega2"] = {
    id="nap-partsofomega2", name="nap-Parts of Omega2", weigths={0.2, 0.0, 0.6, 0.0, 0.01, 0.03},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-partsofomega2.png",
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
        if (NEMESIS.omega_count == nil) then
            NEMESIS.omega_count = {0,0,0}
        end
		
		if (NEMESIS.omega_count[1] == 1 and NEMESIS.omega_count[3] == 1) then
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole_giga.xml", pos_x + math.cos( theta ) * 30 * (( -1 )^ j ), pos_y - math.sin( theta ) * 30, vel_x * (( -1 )^ j ), vel_y )
			NEMESIS.omega_count = {0,0,0}
			
		elseif (NEMESIS.omega_count[1] == 1 or NEMESIS.omega_count[3] == 1) then
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local distance = 100
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole_big.xml", pos_x + math.cos( theta ) * distance * (( -1 )^ j ), pos_y - math.sin( theta ) * distance, vel_x * (( -1 )^ j ), vel_y )

			NEMESIS.omega_count[2] = 1
		else
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole.xml", pos_x + math.cos( theta ) * 30 * (( -1 )^ j ), pos_y - math.sin( theta ) * 30, vel_x * (( -1 )^ j ), vel_y )
		
			NEMESIS.omega_count[2] = 1
		end
	end
}

ABILITIES["nap-partsofomega3"] = {
    id="nap-partsofomega3", name="nap-Parts of Omega3", weigths={0.2, 0.0, 0.0, 0.6, 0.01, 0.03},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-partsofomega3.png",
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
        if (NEMESIS.omega_count == nil) then
            NEMESIS.omega_count = {0,0,0}
        end
		
		if (NEMESIS.omega_count[1] == 1 and NEMESIS.omega_count[2] == 1) then
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole_giga.xml", pos_x + math.cos( theta ) * 30 * (( -1 )^ j ), pos_y - math.sin( theta ) * 30, vel_x * (( -1 )^ j ), vel_y )
			NEMESIS.omega_count = {0,0,0}
			
		elseif (NEMESIS.omega_count[1] == 1 or NEMESIS.omega_count[2] == 1) then
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local distance = 100
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole_big.xml", pos_x + math.cos( theta ) * distance * (( -1 )^ j ), pos_y - math.sin( theta ) * distance, vel_x * (( -1 )^ j ), vel_y )

			NEMESIS.omega_count[3] = 1
		else
			local player = get_player()
        	if (player == nil) then return end  
        	local pos_x, pos_y, rot = EntityGetTransform( player )
        	local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
        	local length = 1
			local j = Random( 1 , 2)

            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length

            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/black_hole.xml", pos_x + math.cos( theta ) * 30 * (( -1 )^ j ), pos_y - math.sin( theta ) * 30, vel_x * (( -1 )^ j ), vel_y )
		
			NEMESIS.omega_count[3] = 1
		end
	end
}

ABILITIES["nap-al-incendiarycloud"] = {
    id="nap-al-incendiarycloud", name="nap-Incendiary Cloud", weigths={0.10, 0.40, 0.20, 0.85, 0.30, 0.10},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-incendiarycloud.png",
    fn=function()
        local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local theta = rot + (( 2 * 3.14159 ) /Random(1, 12))
		local j = Random( 1 , 2)
            local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/incendiary_cloud.xml", pos_x + math.cos( theta ) * 12 * (( -1 )^ j ), pos_y - math.sin( theta ) * 12, 0, 0 )
            
    end
}

ABILITIES["nap-propaneboy"] = {
    id="nap-propaneboy", name="nap-Propane Boy", weigths={0.0, 0.0, 0.1, 0.3, 0.4, 0.5},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-propaneboy.png",
    fn=function()
        SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local player = get_player()
		if (player == nil) then return end 
		local pos_x, pos_y, rot = EntityGetTransform( player )
		local how_many = 4
		local angle_inc = (2 * 3.14159) / how_many
		local theta = rot + (( 2 * 3.14159 ) /Random(1, 72))
		local j = Random( 1 , how_many)
		local r = Random( 30 , 45)
		for i = 1, how_many do
			if i == j then
				local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/propane_boy/static_propane_boy.xml", pos_x + math.cos( theta ) * r / 1.2 , math.min( pos_y - math.sin( theta ) * r, pos_y + math.sin( theta ) * r ) , 0, 0 )
			else
				local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/propane_boy/physics_propane_tank_weak.xml", pos_x + math.cos( theta ) * r / 1.2 , math.min( pos_y - math.sin( theta ) * r, pos_y + math.sin( theta ) * r ), 0, 0 )
			end
			theta = theta + angle_inc
		end
		local lod_x = 0
		local lod_y = 0
		local how_many_pb = 30
		local r1 = 256
		local r2 = 960
		for k = 1, how_many_pb do
			SetRandomSeed( GameGetFrameNum() + (k^2), GameGetFrameNum() + (k^2) )
			lod_y = Random( r1 , r2)
			local n = Random( 1 , 2)
			lod_x = Random( r1 * 2 , r2) * ((-1)^n)
			local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/propane_boy/static_propane_boy.xml", pos_x + lod_x , pos_y + lod_y , 0, 0 )
		end
    end
}

ABILITIES["nap-al-fakeitems"] = {
    id="nap-al-fakeitems", name="nap-Fake Items", weigths={0.5, 0.1, 0.8, 0.1, 0.4, 0.5},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-fakeitems.png",
    fn=function()
		local lod_x = 0
		local lod_y = 0
        local fake_items_list={}
		for i = 1 , 30 do
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_chest.xml")
		end
		for i = 1 , 20 do
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_heart.xml")
		end
		for i = 1 , 5 do
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spell_refresh.xml")
		end
		for i = 1 , 4 do
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_luminous_drill.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_chainsaw.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_teleport_projectile.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_teleport_projectile_short.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_light_bullet.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_light_bullet_trigger.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_laser_emitter.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_laser_emitter_cutter.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_black_hole.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_black_hole_death_trigger.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_worm_shot.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_chain_bolt.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_buckshot.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_bubbleshot.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_laser.xml")
		end
		for i = 1 , 3 do
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_mana_reduce.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_damage.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_heavy_shot.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_critical_hit.xml")
		end
		for i = 1 , 2 do
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_freeze.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_orbit_fireballs.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_homing.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_homing_short.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_matter_eater.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_static_to_sand.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_pingpong_path.xml")
			table.insert(fake_items_list, "mods/Nemesis-Ability-Plus/files/entities/items/fake_items/fake_spells_electric_charge.xml")
		end
		local player = get_player()
		if (player == nil) then return end 
		local pos_x, pos_y = EntityGetTransform( player )
        SetRandomSeed( GameGetFrameNum() + pos_x, GameGetFrameNum() + pos_y )
		local how_many = 100
		local r1 = 36
		local r2 = 1024
		for i = 1, how_many do
			SetRandomSeed( GameGetFrameNum() + (i^2), GameGetFrameNum() + (i^2) )
			lod_y = Random( r1 , r2)
			local n = Random( 1 , 2)
			lod_x = Random( r1 * 2 , r2) * ((-1)^n)
			local j = Random(1, #fake_items_list)
			EntityLoad(fake_items_list[j], pos_x + lod_x, pos_y + lod_y)
			table.remove(fake_items_list, j)
            if (#fake_items_list == 0) then
                break
            end
		end
    end
}
ABILITIES["nap-al-bloodlust"] = {
    id="nap-al-bloodlust", name="nap-Bloodlust", weigths={0.20, 0.10, 0.10, 0.85, 0.20, 0.30},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-bloodlust.png",
    fn=function()
        timed_ability("nap-bloodlust", 60*24,"mods/Nemesis-Ability-Plus/files/effects/nap-bloodlust/effect.xml")
    end
}
ABILITIES["nap-poobomber"] = {
    id="nap-poobomber", name="nap-Poo Bomber", weigths={0.80, 0.05, 0.05, 0.05, 0.30, 0.1},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-poobomber.png",
    fn=function()
        timed_ability("nap-poobomber", 60*45,"mods/Nemesis-Ability-Plus/files/effects/nap-poobomber/effect.xml")
    end
}
ABILITIES["nap-al-invisprojectiles"] = {
    id="nap-al-invisprojectiles", name="nap-Invis Projectiles", weigths={0.90, 0.10, 0.40, 0.30, 0.20, 0.10},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-invisprojectiles.png",
    fn=function()
        timed_ability("nap-invisprojectiles", 60*90,"mods/Nemesis-Ability-Plus/files/effects/nap-invisprojectiles/effect.xml")
    end
}
ABILITIES["nap-effectingswapper"] = {
    id="nap-effectingswapper", name="nap-Effecting Swapper", weigths={0.10, 0.20, 0.30, 0.30, 0.40, 0.30},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-effectingswapper.png",
    fn=function()
        timed_ability("nap-effectingswapper", 60*30,"mods/Nemesis-Ability-Plus/files/effects/nap-effectingswapper/effect.xml")
    end
}
ABILITIES["nap-fireballray"] = {
    id="nap-fireballray", name="nap-Fireball Ray", weigths={0.10, 0.20, 0.50, 0.40, 0.30, 0.20},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-fireballray.png",
    fn=function()
        timed_ability("nap-fireballray", 60*20,"mods/Nemesis-Ability-Plus/files/effects/nap-fireballray/effect.xml")
    end
}

ABILITIES["nap-al-circleslime"] = {
    id="nap-al-circleslime", name="nap-Circle Slime", weigths={0.2, 0.1, 0.8, 0.5, 0.2, 0.1},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-circleslime.png",
    fn=function()
        local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local how_many = 1
        local angle_inc = ( 2 * 3.14159 ) / how_many
        local theta = rot
        local length = 100

        for i=1,how_many do
            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length
			
			local bid = shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/circle_slime.xml", pos_x + math.cos( theta ) * 12, pos_y - math.sin( theta ) * 12, vel_x, vel_y )
			theta = theta + angle_inc
            
        end
    end
}

ABILITIES["nap-bundles"] = {
    id="nap-bundles", name="nap-Bundles", weigths={0.20, 0.10, 0.20, 0.10, 0.70, 0.50},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-bundles.png",
    fn=function()
        timed_ability("nap-bundles", 60*12,"mods/Nemesis-Ability-Plus/files/effects/nap-bundles/effect.xml")
    end
}

ABILITIES["nap-d-noteleport"] = {
    id="nap-d-noteleport", name="nap-No Teleport", weigths={0.20, 0.15, 0.30, 0.20, 0.30, 0.10},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-noteleport.png",
    fn=function()
        timed_ability("nap-noteleport", 60*80,"mods/Nemesis-Ability-Plus/files/effects/nap-noteleport/effect.xml")
    end
}

ABILITIES["nap-d-triplepenalties"] = {
    id="nap-d-triplepenalties", name="nap-Triple Penalties", weigths={0.00, 0.00, 0.05, 0.10, 0.10, 0.20},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-triplepenalties.png",
    fn=function()
        timed_ability("twitchy", 60 * 40)
		timed_ability("hearty", 60 * 40)
		timed_ability("weakened", 60 * 40)
    end
}

ABILITIES["nap-d-neo-fizzledonesgrudge"] = {
    id="nap-d-neo-fizzledonesgrudge", name="nap-neo-Fizzled One's Grudge", weigths={0.00, 0.00, 0.05, 0.10, 0.20, 0.10},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-neo-fizzledonesgrudge.png",
    fn=function()
        if (NEMESIS.fizzled_count == nil) then
            NEMESIS.fizzled_count = 0
        end
		SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local counter_time = ((NEMESIS.fizzled_count + 1) * 0.9 ) - 0.2
		local counter_list = counter_list_full
		local fc_amount = math.min(NEMESIS.fizzled_count + 2, #counter_list)
		for i = 1,fc_amount do
			local j = Random(1, #counter_list)
			counter_list[j](counter_time)
			table.remove(counter_list, j)
            if (#counter_list == 0) then
                break
            end
		end
		NEMESIS.fizzled_count = 0
    end
}

ABILITIES["nap-al-mixingrubbish"] = {
    id="nap-al-mixingrubbish", name="nap-Mixing Rubbish", weigths={0.70, 0.90, 0.20, 0.30, 0.90, 0.40},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-mixingrubbish.png",
    fn=function()
        local rubbishes = {
            "mud",
            "snow",
            "purifying_powder",
            "fungi",
            "soil",
            "gunpowder_unstable",
            "poo"
        }
        local inventory = GetInven()
        local items = EntityGetAllChildren(inventory)
        if items ~= nil then
            for _, item_id in ipairs(items) do
                local flask_comp = EntityGetFirstComponentIncludingDisabled(item_id, "MaterialInventoryComponent")
                if flask_comp ~= nil then
                    local potion_material = random_from_array(rubbishes)
                    AddMaterialInventoryMaterial(item_id, potion_material, 120)
                end
            end
        end
    end
}

ABILITIES["nap-d-sealedmattereater"] = {
    id="nap-d-sealedmattereater", name="nap-Sealed Matter Eater", weigths={0.00, 0.00, 0.20, 0.10, 0.25, 0.15},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-sealedmattereater.png",
    fn=function()
        timed_ability("nap-sealedmattereater", 60*96,"mods/Nemesis-Ability-Plus/files/effects/nap-sealedmattereater/effect.xml")
    end
}

ABILITIES["nap-linearc"] = {
    id="nap-linearc", name="nap-Line Arc", weigths={0.80, 0.80, 0.80, 0.70, 0.60, 0.40},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-linearc.png",
    fn=function()
        timed_ability("nap-linearc", 60*45,"mods/Nemesis-Ability-Plus/files/effects/nap-linearc/effect.xml")
    end
}

ABILITIES["nap-al-mimicsea"] = {
    id="nap-al-mimicsea", name="nap-Mimic Sea", weigths={0.1, 0.4, 0.5, 0.3, 0.5, 0.2},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-mimicsea.png",
    fn=function()
        local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local how_many = 1
        local angle_inc = ( 2 * 3.14159 ) / how_many
        local theta = rot
        local length = 5

        for i=1,how_many do
            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length
            local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/sea_mimic.xml", pos_x + math.cos( theta ) * 12, pos_y - math.sin( theta ) * 12, vel_x, vel_y )
			theta = theta + angle_inc
        end
    end
}

ABILITIES["nap-hookray"] = {
    id="nap-hookray", name="nap-Hook Ray", weigths={0.30, 0.10, 0.40, 0.60, 0.20, 0.20},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-hookray.png",
    fn=function()
        timed_ability("nap-hookray", 60*18,"mods/Nemesis-Ability-Plus/files/effects/nap-hookray/effect.xml")
    end
}

ABILITIES["nap-al-mist_radioactive"] = {
    id="nap-al-mist_radioactive", name="nap-Mist Radioactive", weigths={0.60, 0.70, 0.80, 0.70, 0.60, 0.50},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-mist_radioactive.png",
    fn=function()
        local player = get_player()
        if (player == nil) then return end 
        local pos_x, pos_y, rot = EntityGetTransform( player )
        local how_many = 1
        local angle_inc = ( 2 * 3.14159 ) / how_many
        local theta = rot
        local length = 1

        for i=1,how_many do
            local vel_x = math.cos( theta ) * length
            local vel_y = 0 - math.sin( theta ) * length
			
			local bid = shoot_projectile( entity_id, "data/entities/projectiles/deck/mist_radioactive.xml", pos_x + math.cos( theta ) * 12, pos_y - math.sin( theta ) * 12, vel_x, vel_y )
			theta = theta + angle_inc
            
        end
        for i = 1, 5 do
            spawn_entity_in_view_random_angle("data/entities/projectiles/deck/mist_radioactive.xml", 30, 140)
        end
    end
}

ABILITIES["nap-ninja_ghost"] = {
    id="nap-ninja_ghost", name="nap-Ninja Ghost", weigths={0.60, 0.30, 0.70, 0.30, 0.40, 0.20},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-ninja_ghost.png",
    fn=function()
        local x,y = get_player_pos()
        EntityLoad("mods/Nemesis-Ability-Plus/files/entities/nap-ninja_ghost/entity.xml", x, y)
    end
}

ABILITIES["nap-titres"] = {
    id="nap-titres", name="nap-Titres", weigths={0.10, 0.10, 0.70, 0.90, 0.50, 0.50},
	sprite="mods/Nemesis-Ability-Plus/files/badges/nap-titres.png",
    fn=function()
        timed_ability("nap-titres", 60*60,"mods/Nemesis-Ability-Plus/files/effects/nap-titres/effect.xml")
    end
}

counter_list_full={
    function (counter_time) timed_ability("grounded", 60*math.floor(6*counter_time)) end,
    function (counter_time) timed_ability("confusion", 60*math.floor(15*counter_time)) end,
    function (counter_time) timed_ability("enemyrandomizer", 60*math.max(1,math.floor(1*counter_time))) end,
    function (counter_time) timed_ability("matryoshka", 60*math.floor(45*counter_time)) end,
    function (counter_time) timed_ability("twitchy", 60*math.floor(30*counter_time)) end,
    function (counter_time) timed_ability("hearty", 60*math.floor(30*counter_time)) end,
    function (counter_time) timed_ability("weakened", 60*math.floor(30*counter_time)) end,
    function (counter_time) timed_ability("slowpoke", 60*math.floor(45*counter_time)) end,
    function (counter_time) timed_ability("gravityfield", 60*math.floor(30*counter_time)) end,
    function (counter_time) timed_ability("heavyspread", 60*math.floor(30*counter_time)) end,
    function (counter_time) timed_ability("nap-blindness", 60*math.floor(8*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-blindness/effect.xml") end,
    function (counter_time) timed_ability("nap-explosive-projectile", 60*math.floor(30*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-explosive-projectile/effect.xml") end,
    function (counter_time) timed_ability("nap-youwantthis", 60*math.floor(30*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-Youwantthis/effect.xml") end,
    function (counter_time) timed_ability("nap-drinkingparty", 60*math.floor(20*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-drinkingparty/effect.xml") end,
    function (counter_time) timed_ability("nap-enemyinvisible", 60*math.floor(45*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-enemyinvisible/effect.xml") end,
    function (counter_time) timed_ability("nap-morerecoil", 60*math.floor(42*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-morerecoil/effect.xml") end,
    function (counter_time) timed_ability("nap-powerrangers", 60*math.floor(42*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-powerrangers/effect.xml") end,
    function (counter_time) timed_ability("nap-sluggishwand", 60*math.floor(25*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-sluggishwand/effect.xml") end,
    function (counter_time) timed_ability("nap-perkenemy", 60*math.floor(10*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-perkenemy/effect.xml") end,
    function (counter_time) timed_ability("nap-bubblybounce", 60*math.floor(30*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-bubblybounce/effect.xml") end,
    function (counter_time) timed_ability("nap-moreknockback", 60*math.floor(45*counter_time),"mods/Nemesis-Ability-Plus/files/effects/nap-moreknockback/effect.xml")end,
    function (counter_time) timed_ability("nap-glassparty", 60*math.max(1,math.floor(1*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-glassparty/effect.xml")end,
    function (counter_time) timed_ability("nap-bloodlust", 60*math.max(1,math.floor(24*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-bloodlust/effect.xml")end,
    function (counter_time) timed_ability("nap-poobomber", 60*math.max(1,math.floor(45*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-poobomber/effect.xml")end,
    function (counter_time) timed_ability("nap-invisprojectiles", 60*math.max(1,math.floor(90*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-invisprojectiles/effect.xml")end,
    function (counter_time) timed_ability("nap-effectingswapper", 60*math.max(1,math.floor(30*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-effectingswapper/effect.xml")end,
    function (counter_time) timed_ability("nap-fireballray", 60*math.max(1,math.floor(20*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-fireballray/effect.xml")end,
    function (counter_time) timed_ability("nap-bundles", 60*math.max(1,math.floor(12*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-bundles/effect.xml")end,
    function (counter_time) timed_ability("nap-linearc", 60*math.max(1,math.floor(45*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-linearc/effect.xml")end,
    function (counter_time) timed_ability("nap-hookray", 60*math.max(1,math.floor(18*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-hookray/effect.xml")end,
    function (counter_time) timed_ability("nap-titres", 60*math.max(1,math.floor(60*counter_time)),"mods/Nemesis-Ability-Plus/files/effects/nap-titres/effect.xml")end
}