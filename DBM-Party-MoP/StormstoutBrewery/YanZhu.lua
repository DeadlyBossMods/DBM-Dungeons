local mod	= DBM:NewMod(670, "DBM-Party-MoP", 2, 302)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(59479)
mod:SetEncounterID(1414)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 106546 106851",
	"SPELL_AURA_APPLIED_DOSE 106851",
	"SPELL_AURA_REMOVED 106546",
	"SPELL_CAST_START 106546 106851 106563 115003",
	"SPELL_CAST_SUCCESS 114459",
	"SPELL_DAMAGE 114386",
	"SPELL_MISSED 114386"
)


local warnBloat				= mod:NewTargetAnnounce(106546, 2)
local warnBlackoutBrew		= mod:NewSpellAnnounce(106851, 2)--Applies 3 stacks of debuff to everyone, these 3 stacks will add to current stacks if you still have them (if you do, you're doing it wrong)
local warnBubbleShield		= mod:NewSpellAnnounce(106563, 3)
local warnCarbonation		= mod:NewSpellAnnounce(115003, 4)

local specWarnBloat			= mod:NewSpecialWarningYou(106546, nil, nil, nil, 1, 2)
local specWarnBlackoutBrew	= mod:NewSpecialWarningKeepMove(106851, nil, nil, nil, 1, 2)--Moving clears this debuff, it should never increase unless you're doing fight wrong (think Hodir)
local specWarnFizzyBubbles	= mod:NewSpecialWarning("SpecWarnFizzyBubbles", nil, nil, nil, 1, 2)

local timerBloatCD			= mod:NewCDTimer(13.3, 106546, nil, nil, nil, 3)
local timerBloat			= mod:NewBuffFadesTimer(30, 106546, nil, nil, nil, 5)
local timerBlackoutBrewCD	= mod:NewNextTimer(10.5, 106851, nil, nil, nil, 3)
local timerBubbleShieldCD	= mod:NewNextTimer(42, 106563)
local timerCarbonationCD	= mod:NewNextTimer(64, 115003, nil, nil, nil, 6)
local timerCarbonation		= mod:NewBuffActiveTimer(23, 115003, nil, nil, nil, 6)
local timerFizzyBubbles		= mod:NewBuffFadesTimer(20, 114459, nil, nil, nil, 5)

mod:AddBoolOption("RangeFrame")

function mod:OnCombatStart(delay)
--	timerBlackoutBrewCD:Start(7-delay)-- cannot determine what spells will be used.
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 106546 then
		if args:IsPlayer() then
			specWarnBloat:Show()
			specWarnBloat:Play("targetyou")
			timerBloat:Start()
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(10)
			end
		else
			warnBloat:Show(args.destName)
		end
	elseif args.spellId == 106851 and args:IsPlayer() and (args.amount or 3) >= 3 and self:AntiSpam() then
		specWarnBlackoutBrew:Show()--Basically special warn any time you gain a stack over 3, if stack is nil, then it's initial application and stack count is 3.
		specWarnBlackoutBrew:Play("keepmove")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 106546 and args:IsPlayer() then
		timerBloat:Cancel()
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 106546 then
		timerBloatCD:Start()
	elseif args.spellId == 106851 then
		warnBlackoutBrew:Show()
		timerBlackoutBrewCD:Start()
	elseif args.spellId == 106563 then
		warnBubbleShield:Show()
		timerBubbleShieldCD:Start()
	elseif args.spellId == 115003 then
		warnCarbonation:Show()
		timerCarbonation:Start()
		timerCarbonationCD:Start()
		specWarnFizzyBubbles:Show()
		specWarnFizzyBubbles:Play("gatheritem")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 114459 then
		timerFizzyBubbles:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 114386 and destGUID == UnitGUID("player") and self:AntiSpam(4, 1) then
		specWarnFizzyBubbles:Show()
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
