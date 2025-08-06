local entity_id = GetUpdatedEntityID()
local costsprite_comp = EntityGetComponent( entity_id, "SpriteComponent" )
local x, y = EntityGetTransform( entity_id )

local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
local level = math.floor(y/512)
if (ngcount ~= "0") then
	level = 25 + math.floor(y/512)
end
local cost = 10*math.floor(math.pow(level, 1.5)) + 15

	local comp = costsprite_comp[1]
	local offsetx = 6
	
	local text = "CostNP: " .. tostring(cost)
	
	if ( text ~= nil ) then
		local textwidth = 0
	
		for i=1,#text do
			local l = string.sub( text, i, i )
			
			if ( l ~= "1" ) then
				textwidth = textwidth + 6
			else
				textwidth = textwidth + 3
			end
		end
		
		offsetx = textwidth * 0.5 - 0.5
		
		ComponentSetValue2( comp, "offset_x", offsetx )
		ComponentSetValue2( comp, "text", text )
	end
