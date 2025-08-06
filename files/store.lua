
if NEMESIS then
    return
end
dofile("mods/noita-together/files/stringstore/stringstore.lua")
dofile("mods/noita-together/files/stringstore/noitaglobalstore.lua")
NEMESIS = stringstore.open_store(stringstore.noita.global("NEMESIS_STORE"))

if (NEMESIS.initialized ~= true) then
    NEMESIS.points = 0
    NEMESIS.ngcount = 0
    NEMESIS.deaths = 0
    NEMESIS.PlayerList = "{}"
    NEMESIS.ngstats = "{}"
    NEMESIS.alive = true
	NEMESIS.fizzled_count = 0
	NEMESIS.risky_ability_count = 0
	NEMESIS.omega_count = {0,0,0}
	NEMESIS.np_reroll_count = 1
    NEMESIS.initialized = true
	NEMESIS.helpful_booster_count = 0
end