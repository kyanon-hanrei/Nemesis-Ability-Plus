
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-together/files/scripts/utils.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

function sendGold( destination, amount )
    if (NEMESIS==nil) then return end
    local team = NEMESIS.nt_nemesis_team
    if (team==nil) then return end
    local player = GetPlayer()
    local damagemodels = EntityGetComponent( player, "DamageModelComponent" )
    if (damagemodels==nil) then 
        GamePrint("Life is sweet.")
        return
    end
    local currentFrameNum = GameGetFrameNum()
    local lastFrameNum = tonumber(GlobalsGetValue("NOITA_NEMESIS_LAST_SEND_GOLD_FRAME_NUM")) or 0
    local interval = 10  --1 secound
    if (currentFrameNum - lastFrameNum < interval) then
        GamePrint("Remittance is in progress, plan well before using")
        return
    end
    local x,y = GetPlayerPos()
    --以下、範囲を広げる処理
    local send_area = 20
    local expand_area = ModSettingGet("Nemesis-Ability-Plus.NAP_EXPAND_SEND_GOLD_AREA")
    if expand_area == true then
        send_area = 150
    end
    --以上、範囲を広げる処理
    local targets = EntityGetInRadiusWithTag( x, y, send_area, "perk_reroll_machine" )
    if (#targets < 1) then
        GamePrint("The perk reroll machine is too far")
        return
    end

    local wallet, gold = nil, 0
    wallet, gold = PlayerWalletInfo()
    if (amount <= gold and wallet ~= nil) then
        ComponentSetValue2(wallet, "money", gold - amount)
        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamSendGold", team=team, destination=destination, amount=amount}})
        NT.wsQueue = json.encode(queue)

        GlobalsSetValue("NOITA_NEMESIS_LAST_SEND_GOLD_FRAME_NUM", GameGetFrameNum())
        GamePrint("Sending gold.")
        --以下、送金時に効果音を鳴らす処理
        GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/goldnugget/create", x, y)
        --以上、送金時に効果音を鳴らす処理
        --stats
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        team_stats = team_stats or {}
        team_stats[team] = team_stats[team] or {}
        team_stats[team].gold_sent = (team_stats[team].gold_sent or 0) + 1
        team_stats[team].gold_sent_mina = (team_stats[team].gold_sent_mina or 0) + 1
        NEMESIS.team_stats = json.encode(team_stats)
    else
        GamePrint("I'm broke.")
    end

end
