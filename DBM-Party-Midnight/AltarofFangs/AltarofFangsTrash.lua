local mod	= DBM:NewMod("AltarofFangsTrash", "DBM-Party-Midnight", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID()
mod:SetZone(2993)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:AddAuraSoundOption(1306232, true, 1306232, 1, 2, "watchfeet", 2, 0)--Septic Spatter
mod:AddAuraSoundOption(1308518, false, 1308518, 1, 1, "teleyou", 2, 0)--Laced Edge
mod:AddAuraSoundOption(1308865, true, 1308865, 1, 1, "runout", 2, 0)--Infest
mod:AddAuraSoundOption(1294557, true, 1294557, 1, 1, "debuffyou", 17, 0)--Piercing Hiss (Missed interrupt)
mod:AddAuraSoundOption(1306550, true, 1306550, 1, 1, "absorbyou", 19, 0)--Blood Sacrifice
mod:AddAuraSoundOption(1307571, "RemovePoison", 1307571, 1, 3, "helpdispel", 2, 0)--Envenom (Debuff from Mass Envenom)
