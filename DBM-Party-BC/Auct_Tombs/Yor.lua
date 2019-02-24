local mod	= DBM:NewMod(536, "DBM-Party-BC", 8, 250)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 598 $"):sub(12, -3))
mod:SetCreatureID(22930)
--mod:SetEncounterID(250)--Verify before enable

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
mod.onlyHeroic = true