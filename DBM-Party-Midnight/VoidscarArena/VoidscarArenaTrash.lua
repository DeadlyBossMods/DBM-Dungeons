local mod	= DBM:NewMod("VoidscarArenaTrash", "DBM-Party-Midnight", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2923)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1233535, true, 1233535, 1, 1, "defensive", 19, 1)--Shred Defense (starts warning at 2+ stacks)
mod:AddAuraSoundOption(1267894, "RemoveBleed", 1267894, 1, 3, "bleedyou", 19, 0)--Savage Leap
mod:AddAuraSoundOption(1233398, true, 1233398, 1, 3, "fearyou", 19, 0)--Mad Shriek
