local mod	= DBM:NewMod("TheBlindingValeTrash", "DBM-Party-Midnight", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2859)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1242135, true, 1242135, 1, 1, "bleedyou", 19, 0)--Grievous
mod:AddAuraSoundOption(1237858, true, 1237858, 1, 2, "watchfeet", 8, 0)--Ruptured earth
mod:AddAuraSoundOption(1251345, true, 1251345, 1, 2, "watchfeet", 8, 0)--Blight Resin
mod:AddAuraSoundOption(1238294, true, 1238294, 1, 3, "stunyou", 19, 0)--Disorienting Screech (missed interrupt)
mod:AddAuraSoundOption(1238368, true, 1238368, 1, 1, "scatter", 2, 0)--Lightmaw beams
mod:AddAuraSoundOption(1250937, "RemovePoison", 1250937, 1, 1, "helpdispel", 2, 0)--Toxic Spew
