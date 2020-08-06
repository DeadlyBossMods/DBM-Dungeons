local mod	= DBM:NewMod(178, "DBM-Party-Cataclysm", 11, 76, 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(52271)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_AURA_APPLIED"
)
mod.onlyHeroic = true

