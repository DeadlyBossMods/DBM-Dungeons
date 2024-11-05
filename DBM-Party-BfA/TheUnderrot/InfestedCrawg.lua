local mod	= DBM:NewMod(2131, "DBM-Party-BfA", 8, 1022)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(131817)
mod:SetEncounterID(2118)
mod:SetHotfixNoticeRev(20230528000000)
mod:SetZone(1841)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 260416 260333",
	"SPELL_AURA_REMOVED 260416",
	"SPELL_CAST_START 260793 260292",
	"SPELL_CAST_SUCCESS 260333"
)

--TODO, a really long normal pull to get timer interactions correct when there are no tantrums
--These don't exist on WCL, or at least not in a way they can be found easily :\
--M+ Off Log
--https://www.warcraftlogs.com/reports/cjPnRCWhkrvwd7zD#fight=last&pins=2%24Off%24%23244F4B%24expression%24ability.id%20%3D%20260333%20and%20type%20%3D%20%22cast%22%20%20or%20(ability.id%20%3D%20260793%20or%20ability.id%20%3D%20260292)%20and%20type%20%3D%20%22begincast%22%20%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events&translate=true
--M+ Frequent Log
--https://www.warcraftlogs.com/reports/GQa23ntY8pxJNhHB#fight=last&pins=2%24Off%24%23244F4B%24expression%24ability.id%20%3D%20260333%20and%20type%20%3D%20%22cast%22%20%20or%20(ability.id%20%3D%20260793%20or%20ability.id%20%3D%20260292)%20and%20type%20%3D%20%22begincast%22%20%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
--[[
ability.id = 260333 and type = "cast"
 or (ability.id = 260793 or ability.id = 260292) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local specWarnIndigestion			= mod:NewSpecialWarningSpell(260793, "Tank", nil, nil, 1, 2)
local specWarnCharge				= mod:NewSpecialWarningDodgeCount(260292, nil, nil, nil, 3, 2)
local specWarnTantrum				= mod:NewSpecialWarningCount(260333, nil, nil, nil, 2, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerIndigestionCD			= mod:NewCDTimer(49.7, 260793, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerChargeCD					= mod:NewCDTimer(20.7, 260292, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerTantrumCD				= mod:NewCDCountTimer(44.9, 260333, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

mod:AddNamePlateOption("NPAuraMetamorphosis", 260416)

mod.vb.chargeCast = 0
mod.vb.tantrumCast = 0

local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerTantrumCD:GetRemaining(self.vb.tantrumCast+1) < ICD then
		local elapsed, total = timerTantrumCD:GetTime(self.vb.tantrumCast+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerTantrumCD extended by: "..extend, 2)
		timerTantrumCD:Update(elapsed, total+extend, self.vb.tantrumCast+1)
	end
	if timerChargeCD:GetRemaining() < ICD then
		local elapsed, total = timerChargeCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerChargeCD extended by: "..extend, 2)
		timerChargeCD:Update(elapsed, total+extend)
	end
	if timerIndigestionCD:GetRemaining() < ICD then
		local elapsed, total = timerIndigestionCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerIndigestionCD extended by: "..extend, 2)
		timerIndigestionCD:Update(elapsed, total+extend)
	end
end

function mod:OnCombatStart(delay)
	self.vb.chargeCast = 0
	self.vb.tantrumCast = 0
	if self.Options.NPAuraMetamorphosis then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
	--he casts random ability first, it's charge like 95% of time though
	timerIndigestionCD:Start(8.3-delay)
	timerChargeCD:Start(8.3-delay)
	timerTantrumCD:Start(45, 1)
end

function mod:OnCombatEnd()
	if self.Options.NPAuraMetamorphosis then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 260416 then
		if self.Options.NPAuraMetamorphosis then
			DBM.Nameplate:Show(true, args.destGUID, spellId, nil, 8)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 260416 then
		if self.Options.NPAuraMetamorphosis then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 260793 then
		specWarnIndigestion:Show()
		specWarnIndigestion:Play("breathsoon")
		timerIndigestionCD:Start(49.7)
		updateAllTimers(self, 10.9)--10.9 for tantrum, 12 for charge
	elseif spellId == 260292 then
		self.vb.chargeCast = self.vb.chargeCast + 1
		specWarnCharge:Show(self.vb.chargeCast)
		specWarnCharge:Play("chargemove")
		timerChargeCD:Start(20)
		updateAllTimers(self, 5)--Never seen it delay indigestion but have seen it delay tantrum many times by at least 5 sec
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 260333 then--Tantrum
		self.vb.chargeCast = 0
		self.vb.tantrumCast = self.vb.tantrumCast + 1
		timerChargeCD:AddTime(6.1)--Seems to add 7 seconds static to charge timer, period. charge CD is either 20, or 27 if a tantrum was in between charges, (Unless spell queued but that is handled by auto correct)
		specWarnTantrum:Show(self.vb.tantrumCast)
		specWarnTantrum:Play("aesoon")
		timerTantrumCD:Start(nil, self.vb.tantrumCast+1)
--		updateAllTimers(self, 13.4)--Unknown but I imagine it's like 5 sec at most, some logs make it appear 6 13 or 18, but all are incorrect assumptions
	end
end
