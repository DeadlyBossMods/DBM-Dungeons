local mod	= DBM:NewMod(618, "DBM-Party-WotLK", 8, 281)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(26731)
mod:SetEncounterID(2010)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"CHAT_MSG_MONSTER_YELL"
)

local warningSplitSoon, warningSplitNow
if mod:IsClassic() then
	warningSplitSoon	= mod:NewSoonAnnounce(19570, 2)
	warningSplitNow		= mod:NewSpellAnnounce(19570, 3)
else
	warningSplitSoon	= mod:NewSoonAnnounce(-7395, 2)
	warningSplitNow		= mod:NewSpellAnnounce(-7395, 3)
end

mod.vb.warnedSplit1		= false
mod.vb.warnedSplit2		= false

function mod:OnCombatStart()
	self.vb.warnedSplit1 = false
	self.vb.warnedSplit2 = false
	if self:IsClassic() then
		self:RegisterShortTermEvents(
			"UNIT_HEALTH"
		)
	else
		self:RegisterShortTermEvents(
			"UNIT_HEALTH boss1"
		)
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedSplit1 and self:GetUnitCreatureId(uId) == 26731 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.58 then
		self.vb.warnedSplit1 = true
		warningSplitSoon:Show()
		if self:IsDifficulty("normal5") then
			self:UnregisterShortTermEvents()
		end
	elseif not self.vb.warnedSplit2 and not self:IsDifficulty("normal5") and self:GetUnitCreatureId(uId) == 26731 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.19 then
		self.vb.warnedSplit2 = true
		warningSplitSoon:Show()
		self:UnregisterShortTermEvents()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.SplitTrigger1 or msg == L.SplitTrigger2 then
		warningSplitNow:Show()
	end
end
