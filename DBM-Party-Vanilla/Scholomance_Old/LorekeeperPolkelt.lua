local mod	= DBM:NewMod("LorekeeperPolkelt", "DBM-Party-Vanilla", 16)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10901)

mod:RegisterCombat("combat")
