--バージョン表記
local _Nemesis_Ability_Plus_version = "3.03"
function OnPlayerSpawned( player_entity )
	GlobalsSetValue("Nemesis_Ability_Plus_version", _Nemesis_Ability_Plus_version)
	--テレポート無しルールの場合の処理
	local no_teleport_rule = ModSettingGet("Nemesis-Ability-Plus.NAP_NO_TELEPORT_RULE")
	if no_teleport_rule == true then
		--テレポ禁止の永続状態異常付与
		local x, y = EntityGetTransform( player_entity )
		local thingy = EntityLoad("mods/Nemesis-Ability-Plus/files/effects/rule_noteleport/effect.xml", x, y)
		EntityAddChild(player_entity, thingy)

		--テレポ液を不安定テレポ液に変換する処理
		--local water = CellFactory_GetType( "water" )
		local teleportatium = CellFactory_GetType( "magic_liquid_teleportation" )
		local u_teleportatium = CellFactory_GetType( "magic_liquid_unstable_teleportation" )
		--ConvertMaterialEverywhere( u_teleportatium, water )
		ConvertMaterialEverywhere( teleportatium, u_teleportatium )
	end
end

function OnWorldPreUpdate(player_entity)
	--しゃがみさんの復活地点修正記載
	GameAddFlagRun("NT_death_penalty_full_respawn")
	--This code is included with Mr. Syagami's permission. Thanks.
end

--追加お邪魔用のモディファイ追加
ModLuaFileAppend("data/scripts/gun/gun_extra_modifiers.lua", "mods/Nemesis-Ability-Plus/files/scripts/gun_extra_modifiers.lua")

--お邪魔追加、他（teams干渉対処）
ModLuaFileAppend("mods/noita-nemesis/files/events.lua", "mods/Nemesis-Ability-Plus/files/events.lua")
	--teams用
	ModTextFileSetContent("mods/noita-nemesis-teams/append/events.lua", "-- noop\n")
	ModLuaFileAppend("mods/noita-nemesis-teams/append/events.lua", "mods/Nemesis-Ability-Plus/files/events.lua")
	ModLuaFileAppend("mods/noita-nemesis-teams/append/events.lua", "mods/Nemesis-Ability-Plus/teams_append/events.lua")

--お邪魔出現上書き（teams干渉対処）
ModLuaFileAppend("mods/noita-nemesis/files/append/disable_mail.lua", "mods/Nemesis-Ability-Plus/files/append/disable_mail.lua")
ModLuaFileAppend("mods/noita-nemesis/files/scripts/buy_ability.lua", "mods/Nemesis-Ability-Plus/files/scripts/buy_ability.lua")
	--teams用
	ModTextFileSetContent("mods/noita-nemesis-teams/append/buy_ability.lua", "-- noop\n")
	ModLuaFileAppend("mods/noita-nemesis-teams/append/buy_ability.lua", "mods/Nemesis-Ability-Plus/teams_append/buy_ability.lua")

--store.luaを上書きして各種数値をセット
ModTextFileSetContent("mods/noita-nemesis/files/store.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/store.lua", "mods/Nemesis-Ability-Plus/files/store.lua")


--マトリョーシカの左右反転及びパワーレンジャーとの兼ね合いの修正
ModTextFileSetContent("mods/noita-nemesis/files/effects/matryoshka/death.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/effects/matryoshka/death.lua", "mods/Nemesis-Ability-Plus/files/effects/matryoshka/death.lua")

--ルッキ変異とレギー変異が敵に付与されないようにする
ModLuaFileAppend( "data/scripts/perks/perk_list.lua", "mods/Nemesis-Ability-Plus/files/scripts/perk_list.lua")

--プレイヤーリスト自動展開処理関係
ModTextFileSetContent("mods/noita-nemesis/files/append/ui.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/append/ui.lua", "mods/Nemesis-Ability-Plus/files/append/ui.lua")

--Teams用ログ、プレイヤーリスト自動展開処理、死亡したプレイヤーは全員の杖を見れる処理関係
ModTextFileSetContent("mods/noita-nemesis-teams/append/ui.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis-teams/append/ui.lua", "mods/Nemesis-Ability-Plus/teams_append/ui.lua")

--脱落プレイヤー関係、ブーストアイテム、NPリロール半額、スタートの効果音を鳴らす、プレイヤーリスト自動展開処理関係
ModTextFileSetContent("mods/noita-nemesis/files/append/utils.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-together/files/scripts/utils.lua", "mods/Nemesis-Ability-Plus/files/append/utils.lua" )

--NPリロール天秤関係の上書き
ModLuaFileAppend("data/scripts/perks/perk.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/perk.lua")
--同上バイオーム関係（teams干渉対処）
ModLuaFileAppend("data/scripts/biomes/boss_arena.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/spawn_perk_reroll.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/spawn_perk_reroll.lua")--teams
ModLuaFileAppend("data/scripts/biomes/temple_altar_empty.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/spawn_perk_reroll.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar_right.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/spawn_perk_reroll.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar_right_snowcastle.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/spawn_perk_reroll.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar_right_snowcave.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/spawn_perk_reroll.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar_right_snowcave_empty.lua", "mods/Nemesis-Ability-Plus/files/scripts/perks/spawn_perk_reroll.lua")

--スタート画面にバージョンを表示する関係の上書き
ModLuaFileAppend("mods/noita-together/files/scripts/start_run_hint.lua", "mods/Nemesis-Ability-Plus/files/scripts/start_run_hint.lua")

--聖なる山で杖が未編集の場合インベントリを開く処理を無効にする（teams干渉対処）
ModLuaFileAppend("data/scripts/biomes/boss_arena.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop.lua")
ModLuaFileAppend("data/scripts/biomes/shop_room.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop.lua")--teams
ModLuaFileAppend("data/scripts/biomes/temple_altar_left.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop.lua")--teams
ModLuaFileAppend("data/scripts/biomes/temple_altar_right.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop_show_hint.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar_right_snowcastle.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop_show_hint.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar_right_snowcave.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop_show_hint.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar_secret.lua", "mods/Nemesis-Ability-Plus/files/scripts/biomes/spawn_workshop.lua")

--NG+へ進んだプレイヤーの通知を出す処理関係の上書き
ModTextFileSetContent("mods/noita-nemesis/files/append/boss_death.lua", "-- noop\n")
ModLuaFileAppend("data/entities/animals/boss_centipede/death_check.lua", "mods/Nemesis-Ability-Plus/files/append/boss_death.lua")

--sanicをTeams式にする上書き
ModTextFileSetContent("mods/noita-nemesis/files/effects/sanic/start.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/effects/sanic/start.lua", "mods/Nemesis-Ability-Plus/files/effects/sanic/start.lua")
ModTextFileSetContent("mods/noita-nemesis/files/effects/sanic/end.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/effects/sanic/end.lua", "mods/Nemesis-Ability-Plus/files/effects/sanic/end.lua")

--カオス多形弾のエラー対処（teams干渉対処）
ModTextFileSetContent("mods/noita-nemesis/files/death.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/death.lua", "mods/Nemesis-Ability-Plus/files/death.lua")
	--teams用
	ModTextFileSetContent("mods/noita-nemesis-teams/append/death.lua", "-- noop\n")
	ModLuaFileAppend("mods/noita-nemesis-teams/append/death.lua", "mods/Nemesis-Ability-Plus/files/death.lua")

--NP表示に各山の消費ポイントを加える処理関係の上書き
ModTextFileSetContent("mods/noita-nemesis/files/scripts/ui.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/scripts/ui.lua", "mods/Nemesis-Ability-Plus/files/scripts/ui.lua")