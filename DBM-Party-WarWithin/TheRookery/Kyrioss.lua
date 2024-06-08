local mod	= DBM:NewMod(2566, "DBM-Party-WarWithin", 3, 1268)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(209230)
mod:SetEncounterID(2816)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 424148 420739 444123 419870 444324",
	"SPELL_CAST_SUCCESS 444034",
	"SPELL_AURA_APPLIED 420739",
	"SPELL_AURA_REMOVED 420739"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE, it's currently possible to detect direction of beam by checking target of spell due to stalker not yet being hidden. DBM puposely avoids this since I expect this to be fixed
--TODO, verify Dash target scanning
--TODO, what to do with stormheart
--[[
(ability.id = 424148 or ability.id = 420739 or ability.id = 444123 or ability.id = 419870 or ability.id = 444324) and type = "begincast"
 or ability.id = 444034 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnUnstableCharge					= mod:NewTargetNoFilterAnnounce(420739, 4)
local warnChainLightning					= mod:NewTargetCountAnnounce(424148, 3, nil, nil, nil, nil, nil, nil, true)--Might be spammy, uncertain cast frequency
local warnLightningDash						= mod:NewTargetNoFilterAnnounce(419870, 3)
local warnStormheart						= mod:NewCountAnnounce(444324, 3)

local specWarnUnstableCharge				= mod:NewSpecialWarningYou(420739, nil, nil, nil, 1, 7)
local yellUnstableCharge					= mod:NewYell(420739)
local yellUnstableChargeFades				= mod:NewShortFadesYell(420739)
local specWarnLightningTorrent				= mod:NewSpecialWarningDodgeCount(444123, nil, nil, nil, 1, 2)
local specWarnLightningDash					= mod:NewSpecialWarningYou(419870, nil, nil, nil, 1, 2)
local yellSLightningDash					= mod:NewYell(419870)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerChainLightningCD					= mod:NewCDCountTimer(15.7, 424148, nil, nil, nil, 3)--Lowest priority, 15-18, or longer if delayed by torrent
local timerUnstableChargeCD					= mod:NewCDCountTimer(31.6, 420739, nil, nil, nil, 3)--Timer confirmed by bugging out torrent to disable delays
local timerLightningTorrentCD				= mod:NewCDCountTimer(30.3, 444123, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)--always 30, unless boss is out of range of middle, then it'll be delayed til boss is back in range (i'm sure this will be fixed, cause you can keep boss out of range and disable ability entirely)
local timerLightningDashCD					= mod:NewCDCountTimer(31.6, 419870, nil, nil, nil, 3)--Timer confirmed by bugging out torrent to disable delays
local timerStormheartCD						= mod:NewAITimer(33.9, 444324, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)

--local castsPerGUID = {}

mod.vb.chainCount = 0
mod.vb.chargeCount = 0
mod.vb.torrentCount = 0
mod.vb.dashCount = 0
mod.vb.stormheartCount = 0

function mod:DashTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnLightningDash:Show()
		specWarnLightningDash:Play("targetyou")
		yellSLightningDash:Yell()
	else
		warnLightningDash:Show(targetname)
	end
end

function mod:ChargeTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(5, 1) then
			specWarnUnstableCharge:Show()
			specWarnUnstableCharge:Play("bombyou")
			yellUnstableCharge:Yell()
			--Other voice schedule and countdown yell still triggered by debuff application)
		end
	elseif self:AntiSpam(5, 3) then
		warnUnstableCharge:Show(targetname)
	end
end

function mod:ChainTarget(targetname)
	if not targetname then return end
	warnChainLightning:Show(self.vb.chainCount, targetname)
end

--Update all timers for the Lightning Torrent Delay
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerLightningDashCD:GetRemaining(self.vb.dashCount+1) < ICD then
		local elapsed, total = timerLightningDashCD:GetTime(self.vb.dashCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerLightningDashCD extended by: "..extend, 2)
		timerLightningDashCD:Update(elapsed, total+extend, self.vb.dashCount+1)
	end
	if timerChainLightningCD:GetRemaining(self.vb.chainCount+1) < ICD then
		local elapsed, total = timerChainLightningCD:GetTime(self.vb.chainCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerChainLightningCD extended by: "..extend, 2)
		timerChainLightningCD:Update(elapsed, total+extend, self.vb.chainCount+1)
	end
	if timerUnstableChargeCD:GetRemaining(self.vb.chargeCount+1) < ICD then
		local elapsed, total = timerUnstableChargeCD:GetTime(self.vb.chargeCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerUnstableChargeCD extended by: "..extend, 2)
		timerUnstableChargeCD:Update(elapsed, total+extend, self.vb.chargeCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.chainCount = 0
	self.vb.chargeCount = 0
	self.vb.torrentCount = 0
	self.vb.dashCount = 0
	self.vb.stormheartCount = 0
	timerLightningDashCD:Start(2.1, 1)
	timerChainLightningCD:Start(8.2, 1)
	timerUnstableChargeCD:Start(15.5, 1)
	timerLightningTorrentCD:Start(31.3, 1)
	if self:IsMythic() then
		timerStormheartCD:Start(1)
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 424148 then
		self.vb.chainCount = self.vb.chainCount + 1
		timerChainLightningCD:Start(nil, self.vb.chainCount+1)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ChainTarget", 0.1, 7, true)
	elseif spellId == 420739 then
		self.vb.chargeCount = self.vb.chargeCount + 1
		timerUnstableChargeCD:Start(nil, self.vb.chargeCount+1)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ChargeTarget", 0.1, 7, true, nil, nil, nil, true)--Pre warn for non tanks
	elseif spellId == 444123 and self:AntiSpam(5, 2) then
		self.vb.torrentCount = self.vb.torrentCount + 1
		specWarnLightningTorrent:Show(self.vb.torrentCount)
		specWarnLightningTorrent:Play("watchstep")
		timerLightningTorrentCD:Start(nil, self.vb.torrentCount+1)
		updateAllTimers(self, 8.5)
	elseif spellId == 419870 then
		self.vb.dashCount = self.vb.dashCount + 1
		timerLightningDashCD:Start(nil, self.vb.dashCount+1)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "DashTarget", 0.1, 7, true)
	elseif spellId == 444324 then
		self.vb.stormheartCount = self.vb.stormheartCount + 1
		warnStormheart:Show(self.vb.stormheartCount)
		timerStormheartCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 444034 and self:AntiSpam(5, 2) then--Faster than SPELL_CAST_START but may be hidden later so SCS backup remains
		self.vb.torrentCount = self.vb.torrentCount + 1
		specWarnLightningTorrent:Show(self.vb.torrentCount)
		specWarnLightningTorrent:Play("watchstep")
		timerLightningTorrentCD:Start(nil, self.vb.torrentCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 420739 then
		if args:IsPlayer() then
			if self:AntiSpam(5, 1) then--Already warned by pre scan
				specWarnUnstableCharge:Show()
				specWarnUnstableCharge:Play("bombyou")
				yellUnstableCharge:Yell()
			end
			specWarnUnstableCharge:ScheduleVoice(2.5, "jumpinpit")
			yellUnstableChargeFades:Countdown(spellId)
		elseif self:AntiSpam(5, 3) then
			warnUnstableCharge:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 420739 then
		if args:IsPlayer() then
			yellUnstableChargeFades:Cancel()
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
