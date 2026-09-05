local mod	= DBM:NewMod("VoidscarArenaTrash", "DBM-Party-Midnight", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2923)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1233535, true, 1233535, 1, 1, "defensive", 19, 1)--Shred Defense (starts warning at 2+ stacks)
mod:AddAuraSoundOption(1267894, "RemoveBleed", 1267894, 1, 3, "bleedyou", 19, 0)--Savage Leap
mod:AddAuraSoundOption(1233398, true, 1233398, 1, 3, "fearyou", 19, 0)--Mad Shriek
mod:AddAuraSoundOption(1300138, true, 1300138, 1, 2, "beamyou", 19, 0)--Voidbeam
mod:AddAuraSoundOption(1239856, true, 1239856, 1, 1, "gathershare", 2, 0)--Sky Strike
