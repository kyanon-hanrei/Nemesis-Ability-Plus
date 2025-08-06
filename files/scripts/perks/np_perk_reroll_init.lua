dofile_once("mods/noita-nemesis/files/store.lua")

local entity_id = GetUpdatedEntityID()
local costsprite_comp = EntityGetComponent( entity_id, "SpriteComponent", "shop_cost" )

local reroll_count = 0
if NEMESIS.np_reroll_count ~= nil then
	reroll_count = NEMESIS.np_reroll_count
end

local cost = 25 * math.pow( 2, reroll_count )


	local comp = costsprite_comp[1]
	local offsetx = 6
	
	local text = "NP:" .. tostring(cost)
	
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
		
		offsetx = textwidth * 0.5 - 5.0
		
		ComponentSetValue2( comp, "offset_x", offsetx )
		ComponentSetValue2( comp, "text", text )
	end

