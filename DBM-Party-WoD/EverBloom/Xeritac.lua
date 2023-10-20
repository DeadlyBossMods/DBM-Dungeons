local mod	= DBM:NewMod(1209, "DBM-Party-WoD", 5, 556)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

if (wowToc >= 100200) then
	mod.upgradedMPlus = true
	mod.sendMainBossGUID = true
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(84550)
mod:SetEncounterID(1752)
mod:SetReCombatTime(120, 3)--this boss can quickly re-enter combat if boss reset occurs.

mod:RegisterCombat("combat_emotefind", L.Pull)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 169248 169233 169382",
	"SPELL_PERIODIC_DAMAGE 169223",
	"SPELL_PERIODIC_MISSED 169223",
	"UNIT_DIED",
	"UNIT_TARGETABLE_CHANGED"
)

--[[
(ability.id = 169248 or ability.id = 169233 or ability.id = 169382) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 181113 and type = "cast"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
--]]
--TODO, figure out why the hell emote pull doesn't work. Text is correct.
--TODO, rework it with 10.2 version and get some working add timers, if boss is even doable on M+ that is
--TODO, add other abilities too, but agai only if this is actually M+ mod, if it's not, not worth the time
local warnToxicSpiderling			= mod:NewAddsLeftAnnounce(-10492, 2, "136113")
--local warnVenomCrazedPaleOne		= mod:NewSpellAnnounce("ej10502", 3)--I can't find a way to detect these, at least not without flat out scanning all DAMAGE events but that's too much work.
local warnInhale					= mod:NewSpellAnnounce(169233, 3)
local warnPhase2					= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)

local specWarnVenomCrazedPaleOne	= mod:NewSpecialWarningSwitch(-10502, "-Healer", nil, nil, 1, 2)
local specWarnGaseousVolley			= mod:NewSpecialWarningSpell(169382, nil, nil, nil, 2, 2)
local specWarnToxicGas				= mod:NewSpecialWarningMove(169223, nil, nil, nil, 1, 8)

--local timerConsume					= mod:NewCastTimer(10, 169248, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)--Maye add if easy to cancel

mod.vb.spiderlingCount = 8--4 pre 10.2, 8 post 10.2

function mod:OnCombatStart(delay)
	self.vb.spiderlingCount = 8
	self:SetStage(1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 169233 then
		warnInhale:Show()
	elseif spellId == 169248 then
		specWarnVenomCrazedPaleOne:Show()
		specWarnVenomCrazedPaleOne:Play("killmob")
	elseif spellId == 169382 then
		specWarnGaseousVolley:Show()
		specWarnGaseousVolley:Play("watchstep")
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 169223 and destGUID == UnitGUID("player") and self:AntiSpam(2) then
		specWarnToxicGas:Show()
		specWarnToxicGas:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 84552 then
		self.vb.spiderlingCount = self.vb.spiderlingCount - 1
		if self.vb.spiderlingCount > 0 then--Don't need to warn 0, phase 2 kind of covers that 1.4 seconds later.
			warnToxicSpiderling:Show(self.vb.spiderlingCount)
		end
	end
end

function mod:UNIT_TARGETABLE_CHANGED()
	if self:GetStage(1) then
		self:SetStage(2)
		warnPhase2:Show()
		warnPhase2:Play("ptwo")
	end
end
