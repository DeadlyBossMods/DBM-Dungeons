local mod	= DBM:NewMod(2586, "DBM-Party-WarWithin", 7, 1272)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(210271)
mod:SetEncounterID(2900)
mod:SetHotfixNoticeRev(20240425000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2661)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 442525 432198 432179 432229",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 431896",
	"SPELL_AURA_REMOVED 442525 431896",
	"SPELL_PERIODIC_DAMAGE 432196",
	"SPELL_PERIODIC_MISSED 432196"
--	"UNIT_SPELLCAST_SUCCEEDED"--All units since we need to find adds casting it (unless boss does)
)

--TODO, or use 442611 removed (Disregard) if happy hour removed doesn't work
--TODO, upgrade brawl to higher prio warning?, assuming detection even valid
--[[
(ability.id = 442525 or ability.id = 432198 or ability.id = 432179 or ability.id = 432229) and type = "begincast"
 or ability.id = 442525
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnHappyHour							= mod:NewSpellAnnounce(442525, 3)
local warnHappyHourOver						= mod:NewEndAnnounce(442525, 2)
local warnThrowCinderbrew					= mod:NewCountAnnounce(432179, 2)

local specWarnBlazingBelch					= mod:NewSpecialWarningDodgeCount(432198, nil, nil, nil, 2, 2)
local specWarnKegSmash						= mod:NewSpecialWarningCount(432229, nil, nil, nil, 1, 2)
local specWarnBrawl							= mod:NewSpecialWarningDodge(445180, nil, nil, nil, 2, 2)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(432196, nil, nil, nil, 1, 8)

local timerBlazingBelchCD					= mod:NewCDCountTimer(23, 432198, nil, nil, nil, 3)
local timerThrowCinderbrewCD				= mod:NewCDCountTimer(17.8, 432179, nil, nil, nil, 3)
local timerKegSmashCD						= mod:NewVarCountTimer("v13.7-14.5", 432229, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddNamePlateOption("NPAuraOnThirsty", 431896)

mod.vb.happyHourCount = 0
mod.vb.belchCount = 0
mod.vb.cinderbrewCount = 0
mod.vb.kegCount = 0

function mod:OnCombatStart(delay)
	self.vb.happyHourCount = 0
	self.vb.belchCount = 0
	self.vb.cinderbrewCount = 0
	self.vb.kegCount = 0
	timerKegSmashCD:Start(5.2, 1)
	timerThrowCinderbrewCD:Start(10.1, 1)
	timerBlazingBelchCD:Start(14.3, 1)
	if self.Options.NPAuraOnThirsty then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	if self.Options.NPAuraOnThirsty then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 442525 then
		self.vb.happyHourCount = self.vb.happyHourCount + 1
		warnHappyHour:Show()
		timerBlazingBelchCD:Stop()
		timerThrowCinderbrewCD:Stop()
		timerKegSmashCD:Stop()
	elseif spellId == 432198 then
		self.vb.belchCount = self.vb.belchCount + 1
		specWarnBlazingBelch:Show(self.vb.belchCount)
		specWarnBlazingBelch:Play("breathsoon")
		timerBlazingBelchCD:Start(nil, self.vb.belchCount+1)
	elseif spellId == 432179 then
		self.vb.cinderbrewCount = self.vb.cinderbrewCount + 1
		warnThrowCinderbrew:Show(self.vb.cinderbrewCount)
		timerThrowCinderbrewCD:Start(nil, self.vb.cinderbrewCount+1)
	elseif spellId == 432229 then
		self.vb.kegCount  = self.vb.kegCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnKegSmash:Show(self.vb.kegCount)
			specWarnKegSmash:Play("carefly")
		end
		timerKegSmashCD:Start(nil, self.vb.kegCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 431896 then
		if self.Options.NPAuraOnThirsty then
			DBM.Nameplate:Show(true, args.destGUID, spellId)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 442525 then--Happy Hour
		self.vb.belchCount = 0
		self.vb.cinderbrewCount = 0
		self.vb.kegCount = 0
		warnHappyHourOver:Show()
		if self:IsMythic() then
			specWarnBrawl:Show()
			specWarnBrawl:Play("watchstep")
		end
		timerKegSmashCD:Start(8.4, 1)
		timerThrowCinderbrewCD:Start(13.2, 1)
		timerBlazingBelchCD:Start(16.7, 1)
	elseif spellId == 431896 then
		if self.Options.NPAuraOnThirsty then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 432196 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]
