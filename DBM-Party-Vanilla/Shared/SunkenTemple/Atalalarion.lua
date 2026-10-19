local mod	= DBM:NewMod("Atalalarion", "DBM-Party-Vanilla", DBM:IsPostCata() and 12 or 17)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(8580)
mod:SetEncounterID(3582)--TODO: Verify 3582; may belong to a Forever version of the Season of Discovery Sunken Temple raid, not the dungeon.
mod:SetZone(109)

mod:RegisterCombat("combat")
