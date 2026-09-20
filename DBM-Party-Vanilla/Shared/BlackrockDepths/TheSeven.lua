local mod	= DBM:NewMod(385, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9035, 9039, 9040, 9037, 9034, 9038, 9036)--9035 Anger'rel, 9039/doomrel, 9040/doperel, 9037/gloomrel, 9034/haterel, 9038/seethrel, 9036/vilerel
mod:SetEncounterID(243)
mod:SetModelID(8690)
mod:SetZone(230)

mod:RegisterCombat("combat")

