local mod	= DBM:NewMod("AltarofFangsTrash", "DBM-Party-Midnight", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2993)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1306232, true, 1306232, 1, 2, "watchfeet", 2, 0)--Septic Spatter
mod:AddAuraSoundOption(1308518, false, 1308518, 1, 1, "teleyou", 2, 0)--Laced Edge
