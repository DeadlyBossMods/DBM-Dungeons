std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc"
}
ignore = {
	"211", -- Unused local variable
	"211/L", -- Unused local variable "L"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"213", -- Unused loop variable
	"231/_.*", -- unused variables starting with _
	"311", -- Value assigned to a local variable is unused
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
	"542", -- An empty if branch
}
globals = {
	-- DBM
	"DBM",
	"DBM_CORE_L",
	"DBM_COMMON_L",
	"DBT",

	-- Lua
	"table.wipe",

	-- Utility functions
	"C_Timer",
	"tContains",
	"strlower",

	-- WoW
	"ALTERNATE_POWER_INDEX",
	"BOSS",
	"LE_PARTY_CATEGORY_HOME",
	"LE_PARTY_CATEGORY_INSTANCE",
	"SHIELDSLOT",
	"SPELL_TARGET_TYPE13_DESC",
	"TANK",
	"WOW_PROJECT_ID",
	"WOW_PROJECT_CLASSIC",
	"WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
	"WOW_PROJECT_MAINLINE",

	"ExtraActionBarFrame",

	"C_GossipInfo.CloseGossip",
	"C_GossipInfo.GetOptions",
	"C_GossipInfo.GetText",
	"C_GossipInfo.SelectOption",
	"C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo",
	"Ambiguate",
	"CheckInteractDistance",
	"EJ_GetEncounterInfo",
	"GetAchievementInfo",
	"GetFramesRegisteredForEvent",
	"GetLocale",
	"GetRaidTargetIndex",
	"GetTime",
	"IsInGroup",
	"SendChatMessage",
	"SetRaidTarget",
	"UnitCanAttack",
	"UnitCastingInfo",
	"UnitClass",
	"UnitExists",
	"UnitRace",
	"UnitGroupRolesAssigned",
	"UnitInParty",
	"GetProfessions",
	"GetProfessionInfo",
	"UnitFactionGroup",
	"UnitGetTotalAbsorbs",
	"UnitGUID",
	"UnitHealth",
	"UnitHealthMax",
	"UnitIsDeadOrGhost",
	"UnitIsEnemy",
	"UnitIsFriend",
	"UnitIsUnit",
	"UnitName",
	"UnitPower",
}
