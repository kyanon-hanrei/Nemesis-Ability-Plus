dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)
local owner = get_player()

if (owner ~= nil) then
	EntityAddComponent( owner, "LuaComponent", {
		execute_every_n_frame = "-1",
		script_damage_received = "mods/noita-nemesis/files/effects/sanic/damage.lua"
	})
end