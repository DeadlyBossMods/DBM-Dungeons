local mod	= DBM:NewMod("VarroxBleakhoof", "DBM-Party-Forever", 8)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3334)
mod:SetModelID(130447)
mod:SetZone(2974)

mod:RegisterCombat("combat")

mod:AddAuraSoundOption(1246362, true, 1246362, 1, 1, "bombyou", 12, 0)
mod:AddAuraSoundOption(1246456, true, 1246456, 1, 2, "pullin", 12, 0)
