function SetupEffectingSwapper(entity)
	EntityAddComponent2( entity, "LuaComponent", 
	{ 
    	execute_times = -1, 
    	remove_after_executed = false,
		script_damage_received="data/scripts/animals/wizard_swapper_damage.lua",
	} )
end

local frame = GameGetFrameNum()
local x, y = GameGetCameraPos()
local enemies = EntityGetInRadiusWithTag( x, y, 1024, "enemy" )

for i = 1, #enemies do
	local enemy = enemies[i]
	if (EntityGetName(enemy) ~= "$animal_boss_limbs" and EntityGetName(enemy) ~= "$animal_boss_centipede") then
		if (not EntityHasTag(enemy, "nap-effectingswapper")) then
			local e_x, e_y = EntityGetTransform( enemy )
			SetRandomSeed( GameGetFrameNum() + e_x + i, GameGetFrameNum() + e_y + i )
			if (Random(1,10) <= 3) then
				SetupEffectingSwapper( enemy )
				local elte = EntityLoad("mods/Nemesis-Ability-Plus/files/effects/nap-effectingswapper/enemy-icon.xml", e_x, e_y)
				EntityAddChild(enemy, elte)
			end
			EntityAddTag(enemy, "nap-effectingswapper")
		end
	end
end