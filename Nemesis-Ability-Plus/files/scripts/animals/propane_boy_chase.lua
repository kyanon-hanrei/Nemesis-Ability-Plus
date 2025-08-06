dofile_once("data/scripts/lib/utilities.lua")

local spd = 36
local speed1 = 0
local speed2 = 1.4
local speed3 = 0.4

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)
local player = EntityGetClosestWithTag(pos_x, pos_y, "player_unit")

if not (player == 0 or player == nil) then
	local p_x, p_y = EntityGetTransform( player )
	
	local spritecomp = EntityGetFirstComponent( entity_id, "SpriteComponent" )
	local current = ComponentGetValue2( spritecomp, "rect_animation" )
	
	p_x, p_y = vec_sub(p_x, p_y, pos_x, pos_y)
	component_write( EntityGetFirstComponent( entity_id, "CharacterPlatformingComponent" ), { fly_speed_mult = spd, fly_velocity_x = spd * 2 } )
	
	p_x, p_y = vec_normalize(p_x, p_y)
	
	if ((current == "stand") or (current == "fly_idle") or (current == "attack_ranged")) then
		speed1 = speed2 + speed3
	else
		speed1 = speed2
	end
	
	if EntityHasTag(entity_id, "mach_propane_boy") then
		speed1 = speed1 * 3
	end
	
	p_x, p_y = vec_mult(p_x, p_y, speed1)
	pos_x, pos_y = vec_add(pos_x, pos_y, p_x, p_y)
	
	EntitySetTransform(entity_id, pos_x, pos_y)
end