local mod	= DBM:NewMod(178, "DBM-Party-Cataclysm", 11, 76, 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(52271)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_AURA_APPLIED"
)

