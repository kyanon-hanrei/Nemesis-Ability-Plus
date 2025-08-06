dofile_once( "data/scripts/lib/coroutines.lua" )
dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "data/scripts/game_helpers.lua" )

minos_list_full={
    "mods/Nemesis-Ability-Plus/files/entities/props/titres/physics_mino_o.xml",
    "mods/Nemesis-Ability-Plus/files/entities/props/titres/physics_mino_i.xml",
    "mods/Nemesis-Ability-Plus/files/entities/props/titres/physics_mino_t.xml",
    "mods/Nemesis-Ability-Plus/files/entities/props/titres/physics_mino_s.xml",
    "mods/Nemesis-Ability-Plus/files/entities/props/titres/physics_mino_z.xml",
    "mods/Nemesis-Ability-Plus/files/entities/props/titres/physics_mino_l.xml",
    "mods/Nemesis-Ability-Plus/files/entities/props/titres/physics_mino_j.xml"
}

SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
local players = EntityGetWithTag( "player_unit" )
local player_id = players[1]
local x,y = EntityGetTransform( player_id )

local minos_list = minos_list_full
local i = Random(1, #minos_list)
local j = Random(1, 2)
local k = Random(8, 64)
local l = Random(16, 64)
EntityLoad(minos_list[i], x + (k * ((-1) ^ j )), y - l)