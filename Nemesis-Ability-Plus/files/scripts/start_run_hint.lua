dofile_once("mods/noita-together/files/store.lua")
local entity_id = GetUpdatedEntityID()
local textsprite_comp = EntityGetComponent( entity_id, "SpriteComponent" )
local teams_ver = ""
local nap_ver = ""
local ver_text = ""
--[[
if GlobalsGetValue("NOITA_NEMESIS_TEAMS_VERSION") ~= nil then
	teams_ver = " noita-nemesis-teams Version : " .. tostring( GlobalsGetValue("NOITA_NEMESIS_TEAMS_VERSION") )
end

if GlobalsGetValue("Nemesis_Ability_Plus_version") ~= nil then
	nap_ver = " Nemesis-Ability-Plus Version : " .. tostring( GlobalsGetValue("Nemesis_Ability_Plus_version") )
end
]]
if GlobalsGetValue("Nemesis_Ability_Plus_version") ~= "" then
	local off_y_size = -9
	--1行目を上にずらす処理
	local comp = textsprite_comp[1]
	ComponentSetValue2( comp, "offset_y", 15 )
	
	--セッティングから表示するか否かを読み込む
	local DisplayHint = ModSettingGet("Nemesis-Ability-Plus.NAP_START_RUN_HINTS")
	if DisplayHint == true then
		--2行目を表示する処理
		EntityAddComponent2(entity_id, "SpriteComponent",
			{
			_enabled=true,
			_tags = "enabled_in_world",
			image_file = "data/fonts/font_pixel_white.xml",
			emissive=true,
			is_text_sprite=true,
			offset_x=0,
			offset_y=5,
			alpha=1,
			update_transform=true,
			update_transform_rotation=false,
			text="Please be sure to check that your mods are in the following order.",
			has_special_scale=true,
			special_scale_x=0.8,
			special_scale_y=0.8,
			z_index=-9000
			})
	
		--NAPとバージョンを表示する処理
		nap_ver = "[x]Nemesis-Ability-Plus (Version : " .. tostring( GlobalsGetValue("Nemesis_Ability_Plus_version") ) .. ")"
		EntityAddComponent2(entity_id, "SpriteComponent",
			{
			_enabled=true,
			_tags = "enabled_in_world",
			image_file = "data/fonts/font_pixel_white.xml",
			emissive=true,
			is_text_sprite=true,
			offset_x=0,
			offset_y = off_y_size,
			alpha=1,
			update_transform=true,
			update_transform_rotation=false,
			text=nap_ver,
			has_special_scale=true,
			special_scale_x=0.8,
			special_scale_y=0.8,
			z_index=-9000
			})
		off_y_size = off_y_size - 9
		
		--Teamsとバージョンを表示する処理
		if GlobalsGetValue("NOITA_NEMESIS_TEAMS_VERSION") ~= "" then
			teams_ver = "[x]Noita Nemesis Teams (Version : " .. tostring( GlobalsGetValue("NOITA_NEMESIS_TEAMS_VERSION") ) .. ")"
			EntityAddComponent2(entity_id, "SpriteComponent",
				{
				_enabled=true,
				_tags = "enabled_in_world",
				image_file = "data/fonts/font_pixel_white.xml",
				emissive=true,
				is_text_sprite=true,
				offset_x=0,
				offset_y = off_y_size,
				alpha=1,
				update_transform=true,
				update_transform_rotation=false,
				text=teams_ver,
				has_special_scale=true,
				special_scale_x=0.8,
				special_scale_y=0.8,
				z_index=-9000
				})
			off_y_size = off_y_size - 9
		end
		
		--Nemesisを表示する処理
		EntityAddComponent2(entity_id, "SpriteComponent",
			{
			_enabled=true,
			_tags = "enabled_in_world",
			image_file = "data/fonts/font_pixel_white.xml",
			emissive=true,
			is_text_sprite=true,
			offset_x=0,
			offset_y = off_y_size,
			alpha=1,
			update_transform=true,
			update_transform_rotation=false,
			text="[x]Nemesis prototype",
			has_special_scale=true,
			special_scale_x=0.8,
			special_scale_y=0.8,
			z_index=-9000
			})
		off_y_size = off_y_size - 9
		
		--Togetherを表示する処理
		EntityAddComponent2(entity_id, "SpriteComponent",
			{
			_enabled=true,
			_tags = "enabled_in_world",
			image_file = "data/fonts/font_pixel_white.xml",
			emissive=true,
			is_text_sprite=true,
			offset_x=0,
			offset_y = off_y_size,
			alpha=1,
			update_transform=true,
			update_transform_rotation=false,
			text="[x]Noita Together",
			has_special_scale=true,
			special_scale_x=0.8,
			special_scale_y=0.8,
			z_index=-9000
			})
	end
end
