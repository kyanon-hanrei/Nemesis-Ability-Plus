dofile_once("data/scripts/lib/utilities.lua")

function shot( projectile_id )
	local px, py = EntityGetTransform( projectile_id )
	local comp_celleater = EntityGetFirstComponent( projectile_id, "CellEaterComponent" )

	if comp_celleater ~= nil then
		EntityLoad("data/entities/particles/neutralized.xml", px, py)
		EntityKill( projectile_id )
	end
end