local mod	= DBM:NewMod(1235, "DBM-Party-WoD", 4, 558)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"
mod.upgradedMPlus = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(81297, 81305)
mod:SetEncounterID(1749)
mod:SetBossHPInfoToHighest(false)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 164426",
	"SPELL_CAST_SUCCESS 164835",
	"SPELL_AURA_APPLIED 164426 164632",
	"SPELL_AURA_REMOVED 164426",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2",
	"UNIT_TARGETABLE_CHANGED"
)

--TODO, see if boss is missing UnitID in stage 1 in M+ version
--[[
ability.id = 164835 and type = "cast"
 or ability.id = 164426 and type = "begincast"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnBloodLettingHowl				= mod:NewSpellAnnounce(164835, 3)
local warnNokgar						= mod:NewSpellAnnounce("ej10433", 3, "134170")

local specWarnBurningArrows				= mod:NewSpecialWarningSpell(164635, nil, nil, nil, 2, 2)
local specWarnBurningArrowsMove			= mod:NewSpecialWarningMove(164635, nil, nil, nil, 1, 8)
local specWarnRecklessProvocation		= mod:NewSpecialWarningReflect(164426, nil, nil, nil, 1, 2)
local specWarnRecklessProvocationEnd	= mod:NewSpecialWarningEnd(164426, nil, nil, nil, 1, 2)

local timerRecklessProvocationCD		= mod:NewCDTimer(42.5, 164426, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerRecklessProvocation			= mod:NewBuffActiveTimer(5, 164426, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerBurningArrowsCD				= mod:NewCDTimer(25, 164635, nil, nil, nil, 3)--25~42 variable
local timerBloodlettingHowlCD			= mod:NewCDTimer(25, 164835, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)

function mod:OnCombatStart(delay)
	self:SetStage(1)
	--timerBurningArrowsCD:Start()--Unknown, stupid non logged event
	--timerBloodlettingHowlCD:Start(33.9-delay)--Iffy
	--timerRecklessProvocationCD:Start(43.7-delay)--Iffy
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 164426 then
		timerRecklessProvocationCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 164835 then
		warnBloodLettingHowl:Show()
		timerBloodlettingHowlCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 164426 then
		specWarnRecklessProvocation:Show(args.destName)
		specWarnRecklessProvocation:Play("stopattack")
		timerRecklessProvocation:Start()
	elseif args.spellId == 164632 and args:IsPlayer() and self:AntiSpam(2, 2) then
		specWarnBurningArrowsMove:Show()
		specWarnBurningArrowsMove:Play("watchfeet")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 164426 then
		specWarnRecklessProvocationEnd:Show()
		specWarnRecklessProvocationEnd:Play("safenow")
	end
end

--Not detectable in phase 1. Seems only cleanly detectable in phase 2, in phase 1 boss has no "boss" unitid so cast hidden.
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 164635 then
		specWarnBurningArrows:Show()
		specWarnBurningArrows:Play("watchfeet")
		timerBurningArrowsCD:Start(self.vb.phase == 1 and 25 or 40)
	end
end

function mod:UNIT_TARGETABLE_CHANGED()
	self:SetStage(2)
	warnNokgar:Show()
	timerRecklessProvocationCD:Stop()
	timerBurningArrowsCD:Stop()
	timerBloodlettingHowlCD:Stop()
--	timerBurningArrowsCD:Start()
end
