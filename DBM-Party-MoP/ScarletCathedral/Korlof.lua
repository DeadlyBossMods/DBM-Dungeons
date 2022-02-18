local mod	= DBM:NewMod(671, "DBM-Party-MoP", 9, 316)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(59223)
mod:SetEncounterID(1424)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 113764 114807",
	"SPELL_AURA_APPLIED 114460"
)

--local warnScorchedEarth		= mod:NewCountAnnounce(114460, 3)--only aoe warn will be enough.

local specWarnFlyingKick	= mod:NewSpecialWarningDodge(113764, nil, nil, nil, 2, 2)--This is always followed instantly by Firestorm kick, so no reason to warn both.
local specWarnScorchedEarth	= mod:NewSpecialWarningGTFO(114460, nil, nil, nil, 1, 8)
local specWarnBlazingFists	= mod:NewSpecialWarningDodge(114807, "Tank", nil, nil, 1, 2) -- Everything is dangerous in challenge mode, entry level heriocs will also be dangerous when they aren't overtuning your gear with an ilvl buff.if its avoidable, you should avoid it, in good practice, to create good habit for challenge modes.

local timerFlyingKickCD		= mod:NewCDTimer(25, 113764, nil, nil, nil, 3)--25-30 second variation
local timerFirestormKick	= mod:NewBuffActiveTimer(6, 113764, nil, nil, nil, 2)
local timerBlazingFistsCD	= mod:NewNextTimer(30, 114807, nil, "Tank", 2, 5)

function mod:OnCombatStart(delay)
	timerFlyingKickCD:Start(10-delay)
	timerBlazingFistsCD:Start(20.5-delay)
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 113764 then
		specWarnFlyingKick:Show()
		specWarnFlyingKick:Play("watchstep")
		timerFirestormKick:Start()
		timerFlyingKickCD:Start()
	elseif args.spellId == 114807 then
		specWarnBlazingFists:Show()
		specWarnBlazingFists:Play("shockwave")
		timerBlazingFistsCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 114460 then
		self:RegisterShortTermEvents(
			"SPELL_DAMAGE 114465",
			"SPELL_MISSED 114465"
		)
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 114465 and destGUID == UnitGUID("player") and self:AntiSpam(3) then
		specWarnScorchedEarth:Show(spellName)
		specWarnScorchedEarth:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
