dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

function death( dmg_type, dmg_msg, entity_thats_responsible, drop_items )
    local player = get_player()
    if (entity_thats_responsible ~= player and EntityGetParent(entity_thats_responsible) ~= player) then
        return
    end
	--以下、teams用処理
	GlobalsSetValue("NOITA_NEMESIS_LAST_KILL_FRAME_NUM", GameGetFrameNum())
	--以上、teams用処理
    local entity_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform( entity_id )
    local px, py = get_player_pos()
    local entity_file = EntityGetFilename( entity_id )
    local entity_name = EntityGetName(entity_id)
    local damagecomp = EntityGetFirstComponentIncludingDisabled(entity_id, "DamageModelComponent")
    if (damagecomp ~= nil) then
        local max_hp = ComponentGetValue2(damagecomp, "max_hp")
        local points = math.floor(max_hp*10) --Y scaling TODO ???
        NEMESIS.points = NEMESIS.points + points
    end 
    if (EntityHasTag(entity_id, "NEMESIS_ENEMY")) then
		--以下、teams用処理
		if (NEMESIS.team_points ~= nil) then
			NEMESIS.team_points = (NEMESIS.team_points or 0) + points
		end
		--以上、teams用処理
        return
    end
    local playerlist = json.decode(NEMESIS.PlayerList)
    local count = #playerlist
    if (count < 5) then count = 5 end
    if (count > 30) then count = 30 end
    local spawn_chance = 1 - 0.03 * count
	SetRandomSeed( GameGetFrameNum(), entity_id )
    if Random(1, 100) >= spawn_chance * 100 then
        return
    end
    local cx, cy = GameGetCameraPos()
    local icon = string.gsub(entity_name, "$animal_", "")
    icon = "data/ui_gfx/animal_icons/" .. icon .. ".png"
	--以下、カオス多形弾他のエラー対処
	if (icon == nil or icon == "") then
		icon = "data/ui_gfx/gun_actions/chaos_polymorph_field.png"
	end
	if (entity_file == "data/entities/projectiles/polyorb.xml") then
		icon = "data/ui_gfx/gun_actions/chaos_polymorph_field.png"
	end
	--以上、カオス多形弾他のエラー対処
    local icon_entity = EntityLoad("mods/noita-nemesis/files/entities/kill_icon/entity.xml")
    local sprite = EntityGetFirstComponent(icon_entity, "SpriteComponent")
    ComponentSetValue2(sprite, "image_file", icon)
    EntitySetTransform(icon_entity, x, y)
    local queue = json.decode(NT.wsQueue)
	--以下、teams用処理
    --table.insert(queue, {event="CustomModEvent", payload={name="NemesisEnemy", icon=icon, file=entity_file}})
	if (NEMESIS.nt_nemesis_team ~= nil) then
		local team = NEMESIS.nt_nemesis_team
		local nemesisPoint = NEMESIS.points
		table.insert(queue, {event="CustomModEvent", payload={name="NemesisEnemy", icon=icon, file=entity_file, team=team, nemesisPoint=nemesisPoint}})
		--stats
		local team_stats = json.decode(NEMESIS.team_stats or "[]")
		team_stats = team_stats or {}
		team_stats[team] = team_stats[team] or {}
		team_stats[team].enemies_sent = (team_stats[team].enemies_sent or 0) + 1
		team_stats[team].enemies_sent_mina = (team_stats[team].enemies_sent_mina or 0) + 1
		NEMESIS.team_stats = json.encode(team_stats)
    else
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisEnemy", icon=icon, file=entity_file}})
    end
	--以上、teams用処理
    NT.wsQueue = json.encode(queue)
end