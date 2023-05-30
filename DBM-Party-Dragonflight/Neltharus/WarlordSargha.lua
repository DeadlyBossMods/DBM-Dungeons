local mod	= DBM:NewMod(2501, "DBM-Party-Dragonflight", 4, 1199)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(189901)
mod:SetEncounterID(2611)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20230508000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 376780 377017 377204 377473",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 376780 377018 377022 377522 377014",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 376780",
	"SPELL_PERIODIC_DAMAGE 377542",
	"SPELL_PERIODIC_MISSED 377542"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTES
	--Based on latest analysis. These timers pause on cast start of shield
	--They stay paused until shield is removed, then if stun happens, 10 seconds is added to all timers
	--(they basically pause again but easier to add 10 seconds)
	--Then there is the fact that abilities spell queue and trigger ICDs on one another, that's auto corrected as well
	--Kiln also can be queued so bad a cast gets entirely skipped. the auto correct code will restart the timer if it's missings
--[[
ability.id = 376780 and (type = "begincast" or type = "applybuff" or type = "removebuff")
 or (ability.id = 377017 or ability.id = 377204 or ability.id = 377473) and type = "begincast"
 or ability.id = 377014
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnMagmaShield							= mod:NewTargetNoFilterAnnounce(376780, 3)
local warnMagmaShieldOver						= mod:NewEndAnnounce(376780, 1)
local warnMoltenGold							= mod:NewTargetNoFilterAnnounce(377018, 2, nil, "Healer")
local warnHardenedGold							= mod:NewYouAnnounce(377022, 2)--So inconsiquential it doesn't even deserve a special announcement
local warnBurningPursuit						= mod:NewTargetNoFilterAnnounce(377522, 3)

local specWarnDragonsKiln						= mod:NewSpecialWarningDodge(377204, nil, nil, nil, 2, 2)
local specWarnBurningEmber						= mod:NewSpecialWarningDodge(377477, nil, nil, nil, 2, 2)
local specWarnBurningPursuit					= mod:NewSpecialWarningYou(377522, nil, nil, nil, 1, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(377542, nil, nil, nil, 1, 8)

local timerMagmaShieldCD						= mod:NewCDCountTimer(33.4, 376780, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerMoltenGoldCD							= mod:NewCDTimer(26.7, 377018, nil, nil, nil, 3)
local timerDragonsKilnCD						= mod:NewCDTimer(21, 377204, nil, nil, nil, 3)
local timerBurningEmberCD						= mod:NewCDTimer(28.2, 377477, nil, nil, nil, 1)--Timer extrapolated by reversing spell queues and pauses then vetting it multiple times as accurate within a less than ~1 deviation

--local berserkTimer							= mod:NewBerserkTimer(600)

--mod:AddRangeFrameOption("8")
mod:AddInfoFrameOption(376780, true)
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

mod.vb.shieldCount = 0

local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerMoltenGoldCD:GetRemaining() < ICD then
		local elapsed, total = timerMoltenGoldCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerMoltenGoldCD extended by: "..extend, 2)
		timerMoltenGoldCD:Update(elapsed, total+extend)
	end
	if timerDragonsKilnCD:GetRemaining() < ICD then
		local elapsed, total = timerDragonsKilnCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerDragonsKilnCD extended by: "..extend, 2)
		timerDragonsKilnCD:Update(elapsed, total+extend)
	end
	if timerBurningEmberCD:GetRemaining() < ICD then
		local elapsed, total = timerBurningEmberCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerBurningEmberCD extended by: "..extend, 2)
		timerBurningEmberCD:Update(elapsed, total+extend)
	end
end

function mod:OnCombatStart(delay)
	self.vb.shieldCount = 0
	timerDragonsKilnCD:Start(7-delay)
	timerMoltenGoldCD:Start(14.3-delay)
	timerBurningEmberCD:Start(21.6-delay)
	timerMagmaShieldCD:Start(34.1-delay, 1)
end

function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 376780 then
		timerDragonsKilnCD:Pause()
		timerMoltenGoldCD:Pause()
		timerBurningEmberCD:Pause()
	elseif spellId == 377017 then
		timerMoltenGoldCD:Start()
		updateAllTimers(self, 4.8)
	elseif spellId == 377204 then
		specWarnDragonsKiln:Show()
		specWarnDragonsKiln:Play("shockwave")
		timerDragonsKilnCD:Start()
		updateAllTimers(self, 6)
	elseif spellId == 377473 then
		specWarnBurningEmber:Show()
		specWarnBurningEmber:Play("watchstep")
		timerBurningEmberCD:Start()
		updateAllTimers(self, 4.6)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 362805 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 376780 then
		self.vb.shieldCount = self.vb.shieldCount + 1
		warnMagmaShield:Show(args.destName)
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	elseif spellId == 377018 then
		warnMoltenGold:Show(args.destName)
	elseif spellId == 377022 and args:IsPlayer() then
		warnHardenedGold:Show()
	elseif spellId == 377522 then
		if args:IsPlayer() then
			specWarnBurningPursuit:Show()
			specWarnBurningPursuit:Play("targetyou")
		else
			warnBurningPursuit:Show(args.destName)
		end
	elseif spellId == 377014 then--Backdraft
		timerDragonsKilnCD:AddTime(10)
		timerMoltenGoldCD:AddTime(10)
		timerBurningEmberCD:AddTime(10)
		timerMagmaShieldCD:AddTime(10, self.vb.shieldCount+1)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 376780 then
		warnMagmaShieldOver:Show()
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
		timerDragonsKilnCD:Resume()
		timerMoltenGoldCD:Resume()
		timerBurningEmberCD:Resume()
		timerMagmaShieldCD:Start(30.1, self.vb.shieldCount+1)--30-34, not even boss energy is worth a shit on this boss. bad encounter scripting is bad
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 377542 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) and not DBM:UnitDebuff("player", 377022) then--GTFO filtered if you have Hardened Gold
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
