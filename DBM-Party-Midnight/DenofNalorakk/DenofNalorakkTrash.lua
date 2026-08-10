local mod	= DBM:NewMod("DenofNalorakkTrash", "DBM-Party-Midnight", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2825)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1233904, true, 1233904, 1, 1, "safenow", 2, 0)--Sheltered
mod:AddAuraSoundOption(1297701, true, 1297701, 1, 1, "watchfeet", 8, 0)--Rotten Ground
