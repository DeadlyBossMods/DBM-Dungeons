local mod	= DBM:NewMod(2585, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(215407)
mod:SetEncounterID(2901)
mod:SetHotfixNoticeRev(20240818000000)
mod:SetMinSyncRevision(20240818000000)
mod:SetZone(2660)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 432117 432227 432130 461487",
	"SPELL_AURA_APPLIED 432031"
)
--]]

--[[
(ability.id = 432117 or ability.id = 432227 or ability.id = 432130 or ability.id = 461487) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"

 or ability.id = 431985 and type = "cast"
--]]
--[[
local warnVenomVolley						= mod:NewCountAnnounce(432227, 3)
local warnCultivatedPoisons					= mod:NewCountAnnounce(461487, 3)
local warnSingularity						= mod:NewCastAnnounce(432117, 4)

local specWarnCosmicSingularity				= mod:NewSpecialWarningMoveTo(432117, nil, nil, nil, 3, 15)
local specWarnVenomVolley					= mod:NewSpecialWarningDispel(432227, "RemovePoison", nil, nil, 1, 2)
local specWarnCultivatedPoisons				= mod:NewSpecialWarningDispel(461487, "RemovePoison", nil, nil, 1, 2, 4)
local specWarnEruptingWebs					= mod:NewSpecialWarningDodgeCount(432130, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

--local timerAddsCD							= mod:NewCDTimer(3, -28411, nil, nil, nil, 1, 431985)
local timerCosmicSingularityCD				= mod:NewCDCountTimer(46.1, 432117, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)--54.6 old
local timerVenomVolleyCD					= mod:NewCDCountTimer(22.6, 432227, nil, nil, nil, 2, nil, DBM_COMMON_L.POISON_ICON)
local timerCulturePoisonsCD					= mod:NewCDCountTimer(21.0, 461487, nil, nil, nil, 2, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerEruptingWebsCD					= mod:NewCDCountTimer(18.1, 432130, nil, nil, nil, 3)--18.1-19.3

mod.vb.cosmicCount = 0
mod.vb.venomCount = 0
mod.vb.eruptingCount = 0

function mod:OnCombatStart(delay)
	self.vb.cosmicCount = 0
	self.vb.venomCount = 0
	self.vb.eruptingCount = 0
--	timerAddsCD:Start()--3
	timerEruptingWebsCD:Start(6.2-delay, 1)
	if self:IsMythic() then
		timerCulturePoisonsCD:Start(12-delay, 1)
	else
		timerVenomVolleyCD:Start(12-delay, 1)--16.8 on normal still?
	end
	timerCosmicSingularityCD:Start(26.5-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 432117 then
		self.vb.cosmicCount = self.vb.cosmicCount + 1
		warnSingularity:Show()
		specWarnCosmicSingularity:Schedule(3.5, DBM_COMMON_L.POOL)
		specWarnCosmicSingularity:ScheduleVoice(3.5, "movetopool")
		timerCosmicSingularityCD:Start(46.1, self.vb.cosmicCount+1)

		--Do some timer adjustments if needed
		if self:IsMythic() then
			--if time remaining on Venom is < 7.3, it's extended by this every time
			if timerCulturePoisonsCD:GetRemaining(self.vb.venomCount+1) < 7.2 then
				local elapsed, total = timerCulturePoisonsCD:GetTime(self.vb.venomCount+1)
				local extend = 7.2 - (total-elapsed)
				DBM:Debug("timerCulturePoisonsCD extended by: "..extend, 2)
				timerCulturePoisonsCD:Update(elapsed, total+extend, self.vb.venomCount+1)
			end
		else
			--if time remaining on Venom is < 7.3, it's extended by this every time
			if timerVenomVolleyCD:GetRemaining(self.vb.venomCount+1) < 7.2 then
				local elapsed, total = timerVenomVolleyCD:GetTime(self.vb.venomCount+1)
				local extend = 7.2 - (total-elapsed)
				DBM:Debug("timerVenomVolleyCD extended by: "..extend, 2)
				timerVenomVolleyCD:Update(elapsed, total+extend, self.vb.venomCount+1)
			end
		end
		--if time remaining on Erupting Webs is < 7.3, it's extended by this every time (well not every time anymore?)
		if timerEruptingWebsCD:GetRemaining(self.vb.eruptingCount+1) < 7.3 then
			local elapsed, total = timerEruptingWebsCD:GetTime(self.vb.eruptingCount+1)
			local extend = 7.3 - (total-elapsed)
			DBM:Debug("timerEruptingWebsCD extended by: "..extend, 2)
			timerEruptingWebsCD:Update(elapsed, total+extend, self.vb.eruptingCount+1)
		end
	elseif spellId == 432227 then--Non Mythic
		self.vb.venomCount = self.vb.venomCount + 1
		if self.Options.SpecWarn432227dispel and self:CheckDispelFilter("poison") then
			specWarnVenomVolley:Show(DBM_COMMON_L.ALLIES)
			specWarnVenomVolley:Play("helpdispel")
		else
			warnVenomVolley:Show(self.vb.venomCount)
		end
		--Start next timer if cosmic is far enough away, else wait for cosmic to restart timer
		if timerCosmicSingularityCD:GetRemaining(self.vb.cosmicCount+1) >= 27.9 then
			timerVenomVolleyCD:Start(nil, self.vb.venomCount+1)
		end
	elseif spellId == 461487 then--Mythic
		self.vb.venomCount = self.vb.venomCount + 1
		if self.Options.SpecWarn461487dispel and self:CheckDispelFilter("poison") then
			specWarnCultivatedPoisons:Show(DBM_COMMON_L.ALLIES)
			specWarnCultivatedPoisons:Play("helpdispel")
		else
			warnCultivatedPoisons:Show(self.vb.venomCount)
		end
		--Start next timer if cosmic is far enough away, else wait for cosmic to restart timer
		if timerCosmicSingularityCD:GetRemaining(self.vb.cosmicCount+1) >= 27.9 then
			timerCulturePoisonsCD:Start(nil, self.vb.venomCount+1)
		end
	elseif spellId == 432130 then
		self.vb.eruptingCount = self.vb.eruptingCount + 1
		specWarnEruptingWebs:Show(self.vb.eruptingCount)
		specWarnEruptingWebs:Play("watchstep")
		--Start next timer if cosmic is far enough away, else wait for cosmic to restart timer
		if timerCosmicSingularityCD:GetRemaining(self.vb.cosmicCount+1) >= 18.1 then
			timerEruptingWebsCD:Start(nil, self.vb.eruptingCount+1)
		end
		--timerAddsCD:Stop()
		--timerAddsCD:Start(2.1)--2.1-5
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 432031 then
		if args:IsPlayer() then
			specWarnCosmicSingularity:Cancel()
			specWarnCosmicSingularity:CancelVoice()
		end
	end
end
--]]
