local mod	= DBM:NewMod(692, "DBM-Party-MoP", 6, 324)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61485)
mod:SetEncounterID(1447)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 119476",
	"SPELL_AURA_REMOVED 119476",
	"SPELL_CAST_START 124283 119875"
)

local warnBladeRush			= mod:NewSpellAnnounce(124283, 3)

local specWarnTempest		= mod:NewSpecialWarningSpell(119875, "Healer", nil, nil, 2, 2)
local specWarnBulwark		= mod:NewSpecialWarningSpell(119476, nil, nil, nil, 2, 2)

local timerBladeRushCD		= mod:NewCDTimer(12, 124283, nil, nil, nil, 3)--12-20sec variation
local timerTempestCD		= mod:NewCDTimer(43, 119875, nil, nil, nil, 2)--Tempest has a higher cast priority than blade rush, if it's do, it'll delay blade rush.

mod:AddInfoFrameOption(119875, true)

function mod:OnCombatStart(delay)
	self:SetStage(1)
	timerBladeRushCD:Start(10.6-delay)
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 119476 then
		self:SetStage(2)
		specWarnBulwark:Show()
		specWarnBulwark:Play("attackshield")
		timerBladeRushCD:Cancel()
		timerTempestCD:Cancel()
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, UnitGetTotalAbsorbs("boss1"))
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 119476 then--When bullwark breaks, he will instantly cast either tempest or blade rush, need more logs to determine if it's random or set.
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 124283 then--he do not target anything. so can't use target scan.
		warnBladeRush:Show()
		timerBladeRushCD:Start()
	elseif args.spellId == 119875 then
		specWarnTempest:Show()
		specWarnTempest:Play("specialsoon")
		timerBladeRushCD:Start(7)--always 7-7.5 seconds after tempest.
		if self:GetStage(2) then
			timerTempestCD:Start(33)--seems to be cast more often between 66-33% health. (might be 100-33 but didn't get 2 casts before first bulwark)
		else
			timerTempestCD:Start()
		end
	end
end
