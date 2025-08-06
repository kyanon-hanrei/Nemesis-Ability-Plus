dofile_once("data/scripts/lib/utilities.lua")


local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )
local sprites = EntityGetComponent( entity_id , "SpriteComponent")

local val_x = 0
for _, sprite in ipairs(sprites) do
	val_x = ComponentGetValue2(sprite, "special_scale_x")
end

local velocitycomp = EntityGetFirstComponent( entity_id , "VelocityComponent")
local vel_x, vel_y = ComponentGetValue2(velocitycomp, "mVelocity")

local player_entitys = EntityGetWithTag("player_unit")
local player_id = 0
local p_x, p_y = 0
if #player_entitys ~= 0 then
	player_id = player_entitys[1]
	p_x, p_y = EntityGetTransform( player_id )
end

local animalaicomp = EntityGetFirstComponent( entity_id , "AnimalAIComponent")
local threat_id = ComponentGetValue2(animalaicomp , "mGreatestThreat")
local prey_id = ComponentGetValue2(animalaicomp , "mGreatestPrey")
local jump_x,jump_y = 0
jump_x,jump_y = ComponentGetValue2(animalaicomp , "mNextJumpTarget")

if ( val_x * jump_x < 0 ) and ( vel_x == 0 ) then
	val_x = val_x * -1
	for _, sprite in ipairs(sprites) do
		ComponentSetValue2(sprite, "special_scale_x", val_x)
	end
elseif ( val_x * vel_x < 0 ) then
	val_x = val_x * -1
	for _, sprite in ipairs(sprites) do
		ComponentSetValue2(sprite, "special_scale_x", val_x)
	end
elseif (( threat_id == player_id ) or ( prey_id == player_id )) and ((( p_x - pos_x) * val_x) < 0 ) and ( vel_x == 0 ) and ( jump_x == 0 ) then
	val_x = val_x * -1
	for _, sprite in ipairs(sprites) do
		ComponentSetValue2(sprite, "special_scale_x", val_x)
	end
end