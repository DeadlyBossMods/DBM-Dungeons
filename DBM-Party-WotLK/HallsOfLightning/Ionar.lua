local mod	= DBM:NewMod(599, "DBM-Party-WotLK", 6, 275)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(28546)
mod:SetEncounterID(1984)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 52658 59795",
	"SPELL_AURA_REMOVED 52658 59795",
	"SPELL_CAST_START 52770"
)

local warningDisperseSoon	= mod:NewSoonAnnounce(52770, 2)
local warningDisperse		= mod:NewSpellAnnounce(52770, 3)
local warningOverload		= mod:NewTargetAnnounce(52658, 2)

local specWarnOverload		= mod:NewSpecialWarningMoveAway(52658, nil, nil, nil, 1, 2)

local timerOverload			= mod:NewTargetTimer(10, 52658, nil, nil, nil, 3)

mod:AddSetIconOption("SetIconOnOverloadTarget", 52658, true, 0, {8})

local warnedDisperse = false

function mod:OnCombatStart()
	warnedDisperse = false
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

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(52658, 59795) then
		if args:IsPlayer() then
			specWarnOverload:Show()
			specWarnOverload:Play("runout")
		else
			warningOverload:Show(args.destName)
		end
		timerOverload:Start(args.destName)
		if self.Options.SetIconOnOverloadTarget then
			self:SetIcon(args.destName, 8)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(52658, 59795) then
		if self.Options.SetIconOnOverloadTarget then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 52770 then
		warningDisperse:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if not warnedDisperse and self:GetUnitCreatureId(uId) == 28546 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.54 then
		warnedDisperse = true
		warningDisperseSoon:Show()
		self:UnregisterShortTermEvents()
	end
end
