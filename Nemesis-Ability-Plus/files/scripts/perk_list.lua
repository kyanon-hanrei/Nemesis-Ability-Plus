
--敵にレギー変異とルッキ変異を付かないようにする
function foot_modi( perk_name )
	local key_to_perk = nil
	for key,perk in pairs(perk_list) do
		if( perk.id == perk_name) then
			perk.usable_by_enemies = false
		end
	end
end

foot_modi( "LEGGY_FEET" )
foot_modi( "ATTACK_FOOT" )

--透明とギャンブルを出現させないようにする
function remove_perk( perk_name )
	local key_to_perk = nil
	for key,perk in pairs(perk_list) do
		if( perk.id == perk_name) then
			key_to_perk = key
		end
	end

	if( key_to_perk ~= nil ) then
		table.remove(perk_list, key_to_perk)
	end
end

remove_perk( "INVISIBILITY" )
remove_perk( "GAMBLE" )

--テレポート禁止ルールにしている場合、瞬間移動を消す処理
local no_teleport_rule = GlobalsGetValue("NAP_NO_TELEPORT_RULE")
if no_teleport_rule == "1" then
	remove_perk( "TELEPORTITIS" )
end