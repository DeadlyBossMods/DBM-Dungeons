local mod	= DBM:NewMod(727, "DBM-Party-MoP", 6, 324)
local L		= mod:GetLocalizedStrings()

if DBM:IsRetail() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(62205)
mod:SetEncounterID(1464)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 121447 121443 121282",
	"SPELL_INTERRUPT"
)

local warnResin				= mod:NewTargetNoFilterAnnounce(121447, 4)

local specWarnGustingWinds	= mod:NewSpecialWarningSpell(121282, nil, nil, nil, 2, 2)
local specWarnResin			= mod:NewSpecialWarningYou(121447, nil, nil, nil, 1, 2)
local specWarnCausticPitch	= mod:NewSpecialWarningMove(121443, nil, nil, nil, 1, 8)

local timerResinCD			= mod:NewCDTimer(20, 121447, nil, nil, nil, 3)--20-25 sec variation

mod.vb.windsActive = false

function mod:OnCombatStart(delay)
	self.vb.windsActive = false
	timerResinCD:Start(7-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 121447 then
		if args:IsPlayer() then
			specWarnResin:Show()
			specWarnResin:Play("targetyou")
		else
			warnResin:Show(args.destName)
		end
	elseif args.spellId == 121443 and args:IsPlayer() then
		specWarnCausticPitch:Show()
		specWarnCausticPitch:Play("watchfeet")
	elseif args.spellId == 121282 and not self.vb.windsActive then
		self.vb.windsActive = true
		timerResinCD:Cancel()
		specWarnGustingWinds:Show()
		specWarnGustingWinds:Play("phasechange")
	end
end

function mod:SPELL_INTERRUPT(args)
	if (type(args.extraSpellId) == "number" and args.extraSpellId == 121282) and self:AntiSpam() then
		self.vb.windsActive = false
		timerResinCD:Start(10)
	end
end
