local mod	= DBM:NewMod("VoidscarArenaTrash", "DBM-Party-Midnight", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2923)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
