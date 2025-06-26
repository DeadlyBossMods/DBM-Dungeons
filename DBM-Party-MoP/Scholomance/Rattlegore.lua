local mod	= DBM:NewMod(665, "DBM-Party-MoP", 7, 246)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker,duos"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(59153)
mod:SetEncounterID(1428)
mod:SetZone(1007, 2849)--Scholomance, Duos

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 113765",
	"SPELL_AURA_APPLIED_DOSE 113765",
	"SPELL_AURA_REMOVED 113996 113765",
	"SPELL_CAST_START 113999",
	"SPELL_DAMAGE 114009"
)


local warnBoneSpike		= mod:NewTargetNoFilterAnnounce(113999, 3)

local specWarnGetBoned	= mod:NewSpecialWarning("SpecWarnGetBoned", nil, nil, nil, 1, 2)
local specWarnSoulFlame	= mod:NewSpecialWarningGTFO(114009, nil, nil, nil, 1, 6)--Not really sure what the point of this is yet. It's stupid easy to avoid and seems to serve no fight purpose yet, besides maybe cover some of the bone's you need for buff.
local specWarnRusting	= mod:NewSpecialWarningStack(113765, "Tank", 5, nil, nil, 1, 6)
local SpecWarnDoctor	= mod:NewSpecialWarning("SpecWarnDoctor", nil, nil, nil, 1, 2)

local timerBoneSpikeCD	= mod:NewCDTimer(8, 113999)
local timerRusting		= mod:NewBuffActiveTimer(15, 113765, nil, "Tank")

mod:AddBoolOption("InfoFrame")

local boned = DBM:GetSpellName(113996)

function mod:BoneSpikeTarget()
	local targetname = self:GetBossTarget(59153)
	if not targetname then return end
	warnBoneSpike:Show(targetname)
end

function mod:OnCombatStart(delay)
	timerBoneSpikeCD:Start(6.5-delay)
	if not DBM:UnitDebuff("player", boned) then
		specWarnGetBoned:Show()
		specWarnGetBoned:Play("getboned")
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(L.PlayerDebuffs)
		DBM.InfoFrame:Show(5, "playergooddebuff", boned)
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 113765 then
		timerRusting:Start()
		if (args.amount or 0) >= 5 and self:AntiSpam(1, 3) then
			specWarnRusting:Show(args.amount)
			specWarnRusting:Play("stackhigh")
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 113996 and args:IsPlayer() then
		specWarnGetBoned:Show()
		specWarnGetBoned:Play("getboned")
	elseif args.spellId == 113765 then
		timerRusting:Cancel()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 113999 then
		self:ScheduleMethod(0.1, "BoneSpikeTarget")
		timerBoneSpikeCD:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 114009 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnSoulFlame:Show(spellName)
		specWarnSoulFlame:Play("watchfeet")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg, npc)
	if npc and not UnitIsFriend("player", npc) and (msg == L.TheolenSpawn or msg:find(L.TheolenSpawn)) then
		SpecWarnDoctor:Show()
		SpecWarnDoctor:Play("bigmob")
	end
end
