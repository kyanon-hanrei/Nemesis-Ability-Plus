-- Please give me death
dofile_once("data/scripts/lib/utilities.lua")

function SetupPowerRangers(entity, val)
	EntityAddComponent2(entity, "VariableStorageComponent", {
		name="nap-powerrangers",
		value_float=val
	})
	EntityAddComponent2( entity, "LuaComponent", 
	{ 
		script_death = "mods/Nemesis-Ability-Plus/files/effects/nap-powerrangers/death.lua",
		execute_every_n_frame = -1,
	} )
	EntityAddTag(entity, "nap-powerrangers")
    EntityAddTag(entity, "NEMESIS_ENEMY")
end

function MakeLarg(entity, val)
    local chardata = EntityGetFirstComponentIncludingDisabled(entity, "CharacterDataComponent")
    local damage = EntityGetFirstComponentIncludingDisabled(entity, "DamageModelComponent")
    local hitbox = EntityGetFirstComponentIncludingDisabled(entity, "HitboxComponent")
    local sprites = EntityGetComponent(entity, "SpriteComponent")
	local damagemodel_comp = EntityGetFirstComponent( entity, "DamageModelComponent" )
    
	ComponentSetValue2(damage, "max_hp", ComponentGetValue2(damage, "max_hp") * 2.00 )
    ComponentSetValue2(damage, "hp", ComponentGetValue2(damage, "hp") * 2.00 )
    ComponentSetValue2(damage, "invincibility_frames", 5)
    ComponentSetValue2(damage, "ragdoll_filenames_file", "")
	
	ComponentObjectSetValue2(damagemodel_comp, "damage_multipliers", "melee", 0)
	ComponentObjectSetValue2(damagemodel_comp, "damage_multipliers", "fire", 0)
	ComponentObjectSetValue2(damagemodel_comp, "damage_multipliers", "projectile", 0.5)
	ComponentObjectSetValue2(damagemodel_comp, "damage_multipliers", "explosion", 0.8)
	ComponentObjectSetValue2(damagemodel_comp, "damage_multipliers", "slice", 0.7)

	ComponentSetValue2(damage,"create_ragdoll", false)
	
    ComponentSetValue2(chardata, "buoyancy_check_offset_y", ComponentGetValue2(chardata, "buoyancy_check_offset_y") * val)
    ComponentSetValue2(chardata, "collision_aabb_min_x", ComponentGetValue2(chardata, "collision_aabb_min_x") * val)
    ComponentSetValue2(chardata, "collision_aabb_max_x", ComponentGetValue2(chardata, "collision_aabb_max_x") * val)
    ComponentSetValue2(chardata, "collision_aabb_min_y", ComponentGetValue2(chardata, "collision_aabb_min_y") * val)
    ComponentSetValue2(chardata, "collision_aabb_max_y", ComponentGetValue2(chardata, "collision_aabb_max_y") * val)

    ComponentSetValue2(hitbox, "aabb_min_x", ComponentGetValue2(hitbox ,"aabb_min_x") * val )
    ComponentSetValue2(hitbox, "aabb_max_x", ComponentGetValue2(hitbox ,"aabb_max_x") * val )
    ComponentSetValue2(hitbox, "aabb_min_y", ComponentGetValue2(hitbox ,"aabb_min_y") * val )
    ComponentSetValue2(hitbox, "aabb_max_y", ComponentGetValue2(hitbox ,"aabb_max_y") * val )

    for _, sprite in ipairs(sprites) do
        ComponentSetValue2(sprite, "has_special_scale", true)
        ComponentSetValue2(sprite, "special_scale_x", val)
        ComponentSetValue2(sprite, "special_scale_y", val)
        ComponentSetValue2(sprite, "update_transform", true)
        ComponentSetValue2(sprite, "update_transform_rotation", true)
    end
	
	--以下、敵の左右の向きを変えさせる処理
	if (not EntityHasTag( entity, "ssx_rev")) then
		EntityAddComponent2( entity, "LuaComponent", 
		{ 
			script_source_file = "mods/Nemesis-Ability-Plus/files/effects/reverse_ss_x.lua",
			execute_every_n_frame = 10,
		} )
		EntityAddTag( entity, "ssx_rev")
	end
	--以上、敵の左右の向きを変えさせる処理
end

function death( dmg_type, dmg_msg, entity_thats_responsible, drop_items )
    local entity_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform( entity_id )
    local comp = get_variable_storage_component(entity_id, "nap-powerrangers")
    if (comp == nil) then
        return
    end
    local val = ComponentGetValue2(comp, "value_float")
    local entity_file = EntityGetFilename( entity_id )
    val = val + 0.50

    if (val < 3.10) then
    	local entity_new = EntityLoad(entity_file, x, y)
        SetupPowerRangers(entity_new, val)
		if (EntityHasTag(entity_id, "matryoshka") and (not EntityHasTag(entity_id, "power-matryoshka"))) then
			EntityAddTag(entity_new, "power-matryoshka")
		end
        MakeLarg(entity_new, val)
	else
	    shoot_projectile( entity_id, "mods/Nemesis-Ability-Plus/files/entities/projectiles/explosion_power_rangers.xml", x, y, 0, 0 )
	end
end