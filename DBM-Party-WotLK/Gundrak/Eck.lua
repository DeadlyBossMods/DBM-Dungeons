local mod	= DBM:NewMod(595, "DBM-Party-WotLK", 5, 274)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "heroic,timewalker"
else
	mod.statTypes = "heroic"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(29932)
mod:SetEncounterID(1988)
--
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)

local enrageTimer	= mod:NewBerserkTimer(120)

function mod:OnCombatStart(delay)
	enrageTimer:Start(120 - delay)
end
