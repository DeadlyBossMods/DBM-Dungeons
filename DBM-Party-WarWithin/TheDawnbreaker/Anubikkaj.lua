local mod	= DBM:NewMod(2581, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(211089)
mod:SetEncounterID(2838)
mod:SetHotfixNoticeRev(20240706000000)
mod:SetZone(2662)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:AddPrivateAuraSoundOption(426865, true, 426860, 1)--Dark Orb target

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(426865, "targetyou", 2)--Dark Orb
	self:EnablePrivateAuraSound(450855, "targetyou", 2, 426865)--Register Additional ID
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 427001 426860 426787 452127 452099"
)
--]]

--[[
(target.name = "Anub'ikkaj" or target.name = "Ascendant Vis'coxria" or target.name = "Deathscreamer Iken'tak" or target.name = "Ixkreten the Unbreakable") and (type = "applybuff" or type = "removebuff" or type = "death" or type = "removebuffstack" or type = "applybuffstack")
 or (source.name = "Anub'ikkaj" or source.name = "Ascendant Vis'coxria" or source.name = "Deathscreamer Iken'tak" or source.name = "Ixkreten the Unbreakable") and (type = "cast" or type = "begincast" or type = "applybuff" or type = "removebuff" or type = "removebuffstack" or type = "applybuffstack") and not ability.id = 1
--]]
--[[
(ability.id = 427001 or ability.id = 426860 or ability.id = 426787 or ability.id = 452127) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 452145 and type = "summon"
 or ability.id = 452099 and type = "begincast"
--]]
--[[
local warnAnimatedShadows					= mod:NewCountAnnounce(452127, 3)--Change to switch alert if they have to die asap

local specWarnTerrifyingSlam				= mod:NewSpecialWarningRunCount(427001, nil, nil, nil, 4, 2)
local specWarnDarkOrb						= mod:NewSpecialWarningDodgeCount(426860, nil, nil, nil, 2, 2)
local specWarnShadowDecay					= mod:NewSpecialWarningCount(426787, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)
local specWarnCongealedDarkness				= mod:NewSpecialWarningInterruptCount(452099, nil, nil, nil, 1, 2, 4)

--All timers are 16 (or even lower) but are often extended to 23, 26, 33, or even in extreme cases 42.5
local timerTerrifyingSlamCD					= mod:NewCDCountTimer(16, 427001, nil, nil, nil, 2)
local timerDarkOrbCD						= mod:NewCDCountTimer(16, 426860, nil, nil, nil, 3)
local timerShadowDecayCD					= mod:NewCDCountTimer(16, 426787, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerAnimateShadowsCD					= mod:NewCDCountTimer(34.6, 452127, nil, nil, nil, 1, nil, DBM_COMMON_L.MYTHIC_ICON)

mod:AddPrivateAuraSoundOption(426865, true, 426860, 1)--Dark Orb target

mod.vb.slamCount = 0
mod.vb.orbCount = 0
mod.vb.shadowCount = 0
mod.vb.addsCount = 0
local castsPerGUID = {}

--Animate Shadows triggers 7.5 second ICD
--Dark Orb triggers 9 second ICD
--Terrifying Slam triggers 7 second ICD
--Shadowy Decay triggers 11 second ICD
--No spells have spell priority. It truly is wild west despite how consistent it looks in some logs, look hard enough you find others
--Nerzhul code NOT usable here, upon further log review, there is no consistency because all spells (meaning no spell priority is in place)
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
--	local nextCast = 0
	if timerAnimateShadowsCD:GetRemaining(self.vb.addsCount+1) < ICD then
		local elapsed, total = timerAnimateShadowsCD:GetTime(self.vb.addsCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerAnimateShadowsCD extended by: "..extend, 2)
		timerAnimateShadowsCD:Update(elapsed, total+extend, self.vb.addsCount+1)
--		nextCast = 1
	end
	if timerDarkOrbCD:GetRemaining(self.vb.orbCount+1) < ICD then
		local elapsed, total = timerDarkOrbCD:GetTime(self.vb.orbCount+1)
		local extend = ICD - (total-elapsed)
		--if nextCast == 1 then--Previous spells in queue priority are head of it in line, auto adjust
		--	extend = extend + 7.5
		--	DBM:Debug("timerDarkOrbCD extended by: "..extend.." plus 7.5 for Animate Shadows", 2)
		--else
			DBM:Debug("timerDarkOrbCD extended by: "..extend, 2)
		--	nextCast = 2
		--end
		timerDarkOrbCD:Update(elapsed, total+extend, self.vb.orbCount+1)
	end
	if timerTerrifyingSlamCD:GetRemaining(self.vb.slamCount+1) < ICD then
		local elapsed, total = timerTerrifyingSlamCD:GetTime(self.vb.slamCount+1)
		local extend = ICD - (total-elapsed)
		--if nextCast == 1 then--Previous spells in queue priority are head of it in line, auto adjust
		--	extend = extend + 7.5
		--	DBM:Debug("timerTerrifyingSlamCD extended by: "..extend.." plus 7.5 for Animate Shadows", 2)
		--elseif nextCast == 2 then
		--	extend = extend + 9
		--	DBM:Debug("timerTerrifyingSlamCD extended by: "..extend.." plus 9 for Dark Orb", 2)
		--else
			DBM:Debug("timerTerrifyingSlamCD extended by: "..extend, 2)
		--	nextCast = 3
		--end
		timerTerrifyingSlamCD:Update(elapsed, total+extend, self.vb.slamCount+1)
	end
	if timerShadowDecayCD:GetRemaining(self.vb.shadowCount+1) < ICD then
		local elapsed, total = timerShadowDecayCD:GetTime(self.vb.shadowCount+1)
		local extend = ICD - (total-elapsed)
		--if nextCast == 1 then--Previous spells in queue priority are head of it in line, auto adjust
		--	extend = extend + 7.5
		--	DBM:Debug("timerShadowDecayCD extended by: "..extend.." plus 7.5 for Animate Shadows", 2)
		--elseif nextCast == 2 then
		--	extend = extend + 9
		--	DBM:Debug("timerShadowDecayCD extended by: "..extend.." plus 9 for Dark Orb", 2)
		--elseif nextCast == 3 then
		--	extend = extend + 7
		--	DBM:Debug("timerShadowDecayCD extended by: "..extend.." plus 7 for Terrifying Slam", 2)
		--else
			DBM:Debug("timerShadowDecayCD extended by: "..extend, 2)
		--end
		timerShadowDecayCD:Update(elapsed, total+extend, self.vb.shadowCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.slamCount = 0
	self.vb.orbCount = 0
	self.vb.shadowCount = 0
	self.vb.addsCount = 0
	table.wipe(castsPerGUID)
	timerDarkOrbCD:Start(6-delay, 1)
	timerTerrifyingSlamCD:Start(13-delay, 1)
	timerShadowDecayCD:Start(20-delay, 1)
	if self:IsMythic() then
		timerAnimateShadowsCD:Start(32-delay, 1)
	end
	self:EnablePrivateAuraSound(426865, "targetyou", 2)--Dark Orb
	self:EnablePrivateAuraSound(450855, "targetyou", 2, 426865)--Register Additional ID
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 427001 then
		self.vb.slamCount = self.vb.slamCount + 1
		specWarnTerrifyingSlam:Show(self.vb.slamCount)
		if DBM:UnitBuff("boss1", 427153, 427154) then--Terrifying Empowerment
			specWarnTerrifyingSlam:Play("carefly")
			specWarnTerrifyingSlam:ScheduleVoice(1.2, "fearsoon")
		else
			specWarnTerrifyingSlam:Play("justrun")
		end
		timerTerrifyingSlamCD:Start(nil, self.vb.slamCount+1)
		updateAllTimers(self, 7)
	elseif spellId == 426860 then
		self.vb.orbCount = self.vb.orbCount + 1
		specWarnDarkOrb:Show(self.vb.orbCount)
		specWarnDarkOrb:Play("watchorb")
		timerDarkOrbCD:Start(nil, self.vb.orbCount+1)
		updateAllTimers(self, 9)
	elseif spellId == 426787 then
		self.vb.shadowCount = self.vb.shadowCount + 1
		specWarnShadowDecay:Show(self.vb.shadowCount)
		specWarnShadowDecay:Play("aesoon")
		timerShadowDecayCD:Start(nil, self.vb.shadowCount+1)
		updateAllTimers(self, 11)
	elseif spellId == 452127 then
		self.vb.addsCount = self.vb.addsCount + 1
		warnAnimatedShadows:Show(self.vb.addsCount)
		timerAnimateShadowsCD:Start(nil, self.vb.addsCount+1)
		updateAllTimers(self, 7.5)
	elseif spellId == 452099 then
		if not castsPerGUID[args.sourceGUID] then
			castsPerGUID[args.sourceGUID] = 0
		end
		castsPerGUID[args.sourceGUID] = castsPerGUID[args.sourceGUID] + 1
		local count = castsPerGUID[args.sourceGUID]
		if self:CheckInterruptFilter(args.sourceGUID, false, false) then--Count interrupt, so cooldown is not checked
			specWarnCongealedDarkness:Show(args.sourceName, count)
			if count < 6 then
				specWarnCongealedDarkness:Play("kick"..count.."r")
			else
				specWarnCongealedDarkness:Play("kickcast")
			end
		end
	end
end
--]]
