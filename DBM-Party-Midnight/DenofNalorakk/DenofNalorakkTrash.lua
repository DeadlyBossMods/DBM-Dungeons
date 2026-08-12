local mod	= DBM:NewMod("DenofNalorakkTrash", "DBM-Party-Midnight", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2825)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1252825, true, 1252825, 1, 1, "findshelter", 2, 0)--Harsh Winds
mod:AddAuraSoundOption(1233904, true, 1233904, 1, 1, "safenow", 2, 0)--Sheltered
mod:AddAuraSoundOption(1297701, true, 1297701, 1, 2, "watchfeet", 8, 0)--Rotten Ground
mod:AddAuraSoundOption(1247367, true, 1247367, 1, 2, "watchfeet", 8, 0)--Earthquake
mod:AddAuraSoundOption(1238801, true, 1238801, 1, 3, "attacktotem", 2, 0)--Insatiable Hunger (HP Reduction) (secondary effect of Starvation Effigy Totem)
mod:AddAuraSoundOption(1238439, false, 1238439, 1, 3, "bleedyou", 19, 0)--Razor Dive
mod:AddAuraSoundOption(1238687, true, 1238687, 1, 3, "aesoon", 2, 0)--Feast of Misery
mod:AddAuraSoundOption(1309919, true, 1309919, 1, 3, "debuffyou", 17, 0)--Frigid Roar
mod:AddAuraSoundOption(1241464, true, 1241464, 1, 3, "dpshard", 16, 0)--Glacial Tomb
