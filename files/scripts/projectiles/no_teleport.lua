dofile_once("data/scripts/lib/utilities.lua")

function shot( projectile_id )
	local px, py = EntityGetTransform( projectile_id )
	local comp_teleport = EntityGetFirstComponent( projectile_id, "TeleportProjectileComponent" )
	local comp_storages = EntityGetComponent( projectile_id, "VariableStorageComponent" )
	local comp_sprite = EntityGetComponent( projectile_id, "SpriteComponent" )
	local teleport_flag = false

	local storages_value_string = ""
	
	if ( comp_storages ~= nil ) then
		for i,comp in ipairs( comp_storages ) do
			local name = ComponentGetValue2( comp, "name" )
			if ( name == "projectile_file" ) then
				storages_value_string = ComponentGetValue2( comp, "value_string" )
				break
			end
		end
	end

	local spell_list = delete_spell_list

	for i = 1,#spell_list do
		if storages_value_string == spell_list[i] then
			teleport_flag = true
			break
		end
	end

	if comp_teleport ~= nil then
		teleport_flag = true
	end

	if ( comp_sprite ~= nil ) then
		for i,comp in ipairs( comp_sprite ) do
			local image_file = ComponentGetValue2( comp, "image_file" )
			if ( image_file == "data/projectiles_gfx/blast_teleportation.xml" ) then
				teleport_flag = true
				break
			end
		end
	end

	if teleport_flag == true then
		EntityLoad("data/entities/particles/neutralized.xml", px, py)
		EntityKill( projectile_id )
	end
end

delete_spell_list={
	"data/entities/projectiles/deck/teleport_projectile.xml",
	"data/entities/projectiles/deck/teleport_projectile_short.xml",
	"data/entities/projectiles/deck/swapper.xml",
	"data/entities/projectiles/deck/teleport_projectile_closer.xml"
}