
extra_modifiers["high_recoil"] = 
	function()
		SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		shot_effects.recoil_knockback = 0
		shot_effects.recoil_knockback = shot_effects.recoil_knockback + Random(80, 200)*((-1)^Random(0, 1))
		c.spread_degrees = c.spread_degrees + 4.0
	end

extra_modifiers["sluggish_shot"] =
	function()
		c.damage_critical_chance = c.damage_critical_chance - 50
		c.spread_degrees = c.spread_degrees + 1.0
		c.extra_entities = c.extra_entities .. "data/entities/misc/decelerating_shot.xml,"
		c.fire_rate_wait   = c.fire_rate_wait + 6
		current_reload_time = current_reload_time + 7
		c.bounces = c.bounces + 10
		c.lifetime_add = c.lifetime_add + 100
		c.gravity = c.gravity + 80
		c.knockback_force = c.knockback_force - 1
		c.speed_multiplier = c.speed_multiplier * 1.2
	end
	
extra_modifiers["bubbly_shot"] =
	function()
		c.extra_entities = c.extra_entities .. "data/entities/misc/bounce_spark.xml,"
		c.fire_rate_wait   = c.fire_rate_wait + 1
		c.bounces = c.bounces + 1
		shot_effects.recoil_knockback = shot_effects.recoil_knockback + 2.0
	end

extra_modifiers["more_knockback"] =
	function()
		SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		c.knockback_force = c.knockback_force + Random(60, 90)
	end

extra_modifiers["projectile_acid_trail_small"] = 
	function()
		c.trail_material = c.trail_material .. "acid,"
		c.trail_material_amount = c.trail_material_amount + 1
	end

extra_modifiers["bloodlust_shot"] = 
	function()
		c.damage_projectile_add = c.damage_projectile_add + 0.4
		c.gore_particles    = c.gore_particles + 4
		c.fire_rate_wait    = c.fire_rate_wait + 2
		c.friendly_fire		= true
		shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0
		c.spread_degrees = c.spread_degrees + 3
		c.extra_entities    = c.extra_entities .. "data/entities/particles/tinyspark_red.xml,"
	end

extra_modifiers["poo_shot"] = 
	function()
		c.trail_material = c.trail_material .. "poo_gas,poo,"
		c.trail_material_amount = c.trail_material_amount + 1
		c.material = "poo_gas"
		c.material_amount = c.material_amount + 15
	end

extra_modifiers["bundles"] = 
	function()
		SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
		local trigger_num = Random( 0, 3 ) 
		if trigger_num == 1 then
			c.extra_entities    = c.extra_entities .. "data/entities/misc/rocket_downwards.xml,"
		elseif trigger_num == 3 then
			c.extra_entities    = c.extra_entities .. "data/entities/misc/rocket_octagon.xml,"
		end
	end
		
extra_modifiers["sealed_matter_eater"] =
	function()
		c.extra_entities = c.extra_entities .. "mods/Nemesis-Ability-Plus/files/entities/misc/sealed_matter_eater.xml,"
	end
		
extra_modifiers["line_arc"] =
	function()
		c.extra_entities = c.extra_entities .. "data/entities/misc/line_arc.xml,"
	end