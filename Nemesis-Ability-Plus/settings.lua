dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "Nemesis-Ability-Plus"
mod_settings_version = 1
mod_settings = 
{
	{
		id = "NAP_START_RUN_HINTS",
		ui_name = "Show hints for mod configuration at start",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NAP_START_SOUND",
		ui_name = "Sound effect at start",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NAP_HELPFUL_BOOSTER",
		ui_name = "Appearing helpful booster item at respawn",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NAP_APPEARING_RISKY_ABILITY",
		ui_name = "Appearing RiskyAbility",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NAP_AUTO_OPEN_PLAYER_LIST",
		ui_name = "Automatically opens the player list",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NAP_EXPAND_SEND_GOLD_AREA",
		ui_name = "Expand the area of remittances that can be sent to teams",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NAP_SHOW_NP_COST",
		ui_name = "Display the cost of nemesis abilities next to NP",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NAP_NO_TELEPORT_RULE",
		ui_name = "You start with teleportation spells and others sealed",
		value_default = false,
        scope=MOD_SETTING_SCOPE_RUNTIME
	}
}

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id )
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
