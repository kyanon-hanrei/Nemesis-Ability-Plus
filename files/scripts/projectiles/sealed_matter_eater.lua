dofile_once("data/scripts/lib/utilities.lua")

local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )

local comp_celleater = EntityGetFirstComponent( entity_id, "CellEaterComponent" )

if comp_celleater ~= nil then
	EntityLoad("data/entities/particles/neutralized.xml", pos_x, pos_y)
	EntityKill( entity_id )
end