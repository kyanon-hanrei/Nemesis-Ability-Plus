function IsPlayerDead()
  local player = GetPlayer()
  local damage_models = nil
  if (player ~= nil) then
      damage_models = EntityGetFirstComponent(player, "DamageModelComponent")
  end

  if (damage_models ~= nil) then
      local curHp = ComponentGetValue2(damage_models, "hp")
      if (curHp < 0.0) then
          if (GameHasFlagRun("ending_game_completed")) then
			  ComponentSetValue2(damage_models, "kill_now", true)
              EndRun()
              return
          end

          if (NEMESIS.deaths > 0) then
              --以下、脱落プレイヤーを短絡状態にする処理
			  local x, y = EntityGetTransform( player )
			  local thingy = EntityLoad("mods/Nemesis-Ability-Plus/files/effects/death_fizzled/effect.xml", x, y)
			  EntityAddChild(player, thingy)
			  --以上、脱落プレイヤーを短絡状態にする処理
			  --以下、脱落プレイヤーの友好値を上昇させる処理
			  local world_entity_id = GameGetWorldStateEntity()
			  if( world_entity_id ~= nil ) then
				local comp_worldstate = EntityGetFirstComponent( world_entity_id, "WorldStateComponent" )
				if( comp_worldstate ~= nil ) then
					local global_genome_relations_modifier = tonumber( ComponentGetValue( comp_worldstate, "global_genome_relations_modifier" ) )
					global_genome_relations_modifier = global_genome_relations_modifier + 300
					ComponentSetValue( comp_worldstate, "global_genome_relations_modifier", tostring( global_genome_relations_modifier ) )
				end
			  end
			  --以上、脱落プレイヤーの友好値を上昇させる処理
              EndRun()
              EntityRemoveComponent(player, damage_models)
              local sprites = EntityGetComponent(player, "SpriteComponent")
              for _, sprite in ipairs(sprites) do
                ComponentSetValue2(sprite, "alpha", 0)
              end
              GameDestroyInventoryItems( player )
              local controls_component = EntityGetFirstComponent(player, "ControlsComponent")
                if (controls_component ~= nil) then
                    ComponentSetValue2(controls_component, "enabled", false)
                end
                EntityAddTag( player, "polymorphable_NOT")
                NEMESIS.alive = false
              --ComponentSetValue2(damage_models, "kill_now", true)
          else
              NEMESIS.deaths = NEMESIS.deaths + 1
              PlayerRespawn(player, false, true) -- TODO: get penalty?
          end
      end
  end
  damage_models = nil
  local polymorphed, entity_id = IsPlayerPolymorphed()
  if (not polymorphed) then return end

  damage_models = EntityGetFirstComponent(entity_id, "DamageModelComponent")
    if (damage_models ~= nil) then
        ComponentSetValue2(damage_models, "wait_for_kill_flag_on_death", true)
        local curHp = ComponentGetValue2(damage_models, "hp")
        if (curHp < 0.0) then
            if (GameHasFlagRun("ending_game_completed")) then
                ComponentSetValue2(damage_models, "kill_now", true)
                return
            end

            if (NEMESIS.deaths > 0) then
                --以下、脱落プレイヤーの友好値を上昇させる処理
                local world_entity_id = GameGetWorldStateEntity()
                if( world_entity_id ~= nil ) then
                    local comp_worldstate = EntityGetFirstComponent( world_entity_id, "WorldStateComponent" )
                    if( comp_worldstate ~= nil ) then
                        local global_genome_relations_modifier = tonumber( ComponentGetValue( comp_worldstate, "global_genome_relations_modifier" ) )
                        global_genome_relations_modifier = global_genome_relations_modifier + 300
                        ComponentSetValue( comp_worldstate, "global_genome_relations_modifier", tostring( global_genome_relations_modifier ) )
                    end
                end
                --以上、脱落プレイヤーの友好値を上昇させる処理
                EndRun()
                --ComponentSetValue2(damage_models, "kill_now", true)
                --以下、多形で脱落したプレイヤーにも死亡判定を付与する処理
                NEMESIS.alive = false
                --以上、多形で脱落したプレイヤーにも死亡判定を付与する処理
                ComponentSetValue2(damage_models, "kill_now", true)
			    --以下、死亡したプレイヤーのコントロールを無くす
			    --[[
			    local controls_component = EntityGetFirstComponent(player_entity, "ControlsComponent")
				    if (controls_component ~= nil) then
				    	ComponentSetValue2(controls_component, "enabled", false)
				    end
			    ]]
			    --以上、死亡したプレイヤーのコントロールを無くす
            else
                NEMESIS.deaths = NEMESIS.deaths + 1
                PlayerRespawn(entity_id, true, true) -- TODO: get penalty?
            end
        end
    end
end

function PlayerRespawn(entity_id, poly, weak)
  if (Respawning == true) then return end
  async(function()
      Respawning = true
      if (poly) then
          local children = EntityGetAllChildren(entity_id)
          for _, child in ipairs(children) do
              local effects = EntityGetComponent(child, "GameEffectComponent")
              if (effects ~= nil and #effects > 0) then
                  for _, effect_comp in ipairs(effects) do
                      if (effect_comp ~= nil and effect_comp > 0) then
                          ComponentSetValue2(effect_comp, "frames", 1)
                      end
                  end
              end
          end
          wait(2)
      end
      local player = GetPlayer()
      local damage_models = nil
      if (player ~= nil) then
          damage_models = EntityGetFirstComponent(player, "DamageModelComponent")
      end
      if (damage_models ~= nil) then
          local max_hp = ComponentGetValue2(damage_models, "max_hp")
          if (weak) then
              --send custom message for weakening
              if (GameGetFrameNum() > LastRespawn + 30) then
                  LastRespawn = GameGetFrameNum()
                  SendWsEvent({event="CustomModEvent", payload={name="NemesisRespawn"}})
              end
          end
          ComponentSetValue2(damage_models, "hp", max_hp)
      end
      local effect_entity = LoadGameEffectEntityTo(player, "data/entities/misc/effect_protection_all.xml")
      local effect_comp = EntityGetFirstComponent(effect_entity, "GameEffectComponent")
      ComponentSetValue2(effect_comp, "frames", 60*30)
      EntityAddComponent2(effect_entity, "UIIconComponent", {
          icon_sprite_file = "data/ui_gfx/status_indicators/protection_all.png",
          name = "Respawn Protection",
          description = "You are being protected against campers.",
          display_above_head = true,
          display_in_hud = true,
          is_perk = false
      })
      EntitySetTransform(player, GetLastCheckPoint())
      Respawning = false
	  --以下、HelpfulBooster用の出現処理
	  local Booster_item = ModSettingGet("Nemesis-Ability-Plus.NAP_HELPFUL_BOOSTER")
	  if Booster_item == true then
		if NEMESIS.helpful_booster_count <= 30 then
			local hb_x,hb_y = GetLastCheckPoint()
			EntityLoad("mods/Nemesis-Ability-Plus/files/entities/helpfulbooster/helpfulbooster.xml", hb_x + 100, hb_y - 30)
		end
	  end
	  --以上、HelpfulBooster用の出現処理
	  --以下、NP_Perk_Rerollの半額処理
	  if NEMESIS.np_reroll_count >= 1 then
		  NEMESIS.np_reroll_count = NEMESIS.np_reroll_count - 1
	  end
	  --以上、NP_Perk_Rerollの半額処理
  end)
end

function StartRun()
    local player = GetPlayer()
    if (player ~= nil and player > 0) then
        local controls_component = EntityGetFirstComponent(player, "ControlsComponent")
        if (controls_component ~= nil) then
            if (NT ~= nil and NT.run_started == false) then
                GamePrintImportant("$noitatogether_run_started_title", "$noitatogether_run_started_subtitle")
                NT.run_started = true
				--以下、スタート時に効果音を鳴らす処理
				local start_sound = ModSettingGet("Nemesis-Ability-Plus.NAP_START_SOUND")
				if start_sound == true then
					local pos_x, pos_y = EntityGetTransform( player )
					GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", pos_x, pos_y )
				end
                --以上、スタート時に効果音を鳴らす処理
				--以下、プレイヤーリストを開始時に自動で開く処理
				local auto_open_list = ModSettingGet("Nemesis-Ability-Plus.NAP_AUTO_OPEN_PLAYER_LIST")
				if (auto_open_list == true) then
					GlobalsSetValue("AUTO_SHOW_PLAYER_LIST","1")
				end
				--以上、プレイヤーリストを開始時に自動で開く処理
			end
            ComponentSetValue2(controls_component, "enabled", true)
        end

        --Remove polymorph immunity if we granted it pre-run-start
        --So players cant polymorph and move around before run start
        if (GameHasFlagRun("NT_added_poly_immune_prerun")) then
            if(EntityHasTag(player, "polymorphable_NOT")) then
                EntityRemoveTag(player, "polymorphable_NOT")
            end
            GameRemoveFlagRun("NT_added_poly_immune_prerun")

            --Re-enable the starter potion now, too
            SetStarterPotionDrinkable(true)
        end

        local cosmetics = CosmeticFlags()
        SendWsEvent({event="CustomModEvent", payload={name="PlayerCosmeticFlags", flags=cosmetics}})
        GameAddFlagRun("NT_unlocked_controls")
        _start_run = false
        _started = true
    end
end