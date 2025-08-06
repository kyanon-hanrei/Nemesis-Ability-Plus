function SetupPowerRangers(entity, val)
	EntityAddComponent2(entity, "VariableStorageComponent", {
		name="nap-powerrangers",
		value_float=val
	})
	EntityAddComponent2( entity, "LuaComponent", 
	{ 
		script_death = "mods/Nemesis-Ability-Plus/files/effects/nap-powerrangers/death.lua",
		execute_every_n_frame = -1,
	} )
	EntityAddTag(entity, "nap-powerrangers")
end

local frame = GameGetFrameNum()
local x, y = GameGetCameraPos()
local enemies = EntityGetInRadiusWithTag( x, y, 896, "enemy" )

for i = 1, #enemies do
		local enemy = enemies[i]
		if (EntityGetName(enemy) ~= "$animal_boss_limbs" and EntityGetName(enemy) ~= "$animal_boss_centipede") then
				if (not EntityHasTag(enemy, "nap-powerrangers")) then
					SetupPowerRangers(enemy, 2.50)
				end
		end
end