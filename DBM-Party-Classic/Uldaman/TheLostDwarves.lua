if UnitFactionGroup("player") == "Alliance" then return end
local mod	= DBM:NewMod(468, "DBM-Party-Classic", 12, 239)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(6906, 6907, 6908)
mod:SetEncounterID(548)
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")
