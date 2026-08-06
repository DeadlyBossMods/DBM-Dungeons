local mod	= DBM:NewMod("TheBlindingValeTrash", "DBM-Party-Midnight", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2859)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1242135, true, 1242135, 1, 1, "bleedyou", 19, 0)--Grievous
mod:AddAuraSoundOption(1237858, true, 1237858, 1, 2, "watchfeet", 8, 0)--Ruptured earth
