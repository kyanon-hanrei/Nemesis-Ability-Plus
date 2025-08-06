dofile_once("data/scripts/lib/utilities.lua")

local dis_l = 370
local dis_s = 145
local dis_d = 15

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)
local player = EntityGetClosestWithTag(pos_x, pos_y, "player_unit")

if not (player == 0 or player == nil) then
	local p_x, p_y = EntityGetTransform( player )
	p_x, p_y = vec_sub(p_x, p_y, pos_x, pos_y)
	
	if ((p_x ^ 2 ) > ( (dis_l + dis_d) ^ 2 ) or (p_y ^ 2 ) > ( (dis_l - dis_d) ^ 2 )) and (not EntityHasTag(entity_id, "mach_propane_boy")) then
		EntityAddTag(entity_id, "mach_propane_boy")
		--GamePrintImportant("test_L")
	elseif ((p_x ^ 2 ) < ( (dis_s + dis_d) ^ 2 ) and (p_y ^ 2 ) < ( (dis_s - dis_d) ^ 2 )) and (EntityHasTag(entity_id, "mach_propane_boy"))  then
		EntityRemoveTag(entity_id, "mach_propane_boy")
		--GamePrintImportant("test_S")
	end
end