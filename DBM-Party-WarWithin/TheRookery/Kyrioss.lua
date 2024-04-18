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
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 420739",
	"SPELL_AURA_REMOVED 420739"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE, Lightning torrent shows dispel icon, but isnt dispelable
--TODO, verify Dash target scanning
--TODO, what to do with stormheart
local warnChainLightning					= mod:NewCountAnnounce(424148, 3)--Might be spammy, uncertain cast frequency
local warnLightningDash						= mod:NewTargetNoFilterAnnounce(419870, 3)
local warnStormheart						= mod:NewCountAnnounce(444324, 3)

local specWarnUnstableCharge				= mod:NewSpecialWarningYou(420739, nil, nil, nil, 1, 2)
local yellSUnstableCharge					= mod:NewYell(420739)
local yellSUnstableChargeFades				= mod:NewShortFadesYell(420739)
local specWarnLightningTorrent				= mod:NewSpecialWarningDodgeCount(444123, nil, nil, nil, 1, 2)
local specWarnLightningDash					= mod:NewSpecialWarningYou(419870, nil, nil, nil, 1, 2)
local yellSLightningDash					= mod:NewYell(419870)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerChainLightningCD					= mod:NewAITimer(33.9, 424148, nil, nil, nil, 3)
local timerUnstableChargeCD					= mod:NewAITimer(33.9, 424148, nil, nil, nil, 3)
local timerLightningTorrentCD				= mod:NewAITimer(33.9, 444123, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerLightningDashCD					= mod:NewAITimer(33.9, 419870, nil, nil, nil, 3)
local timerStormheartCD						= mod:NewAITimer(33.9, 444324, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)

--local castsPerGUID = {}

mod.vb.chainCount = 0
mod.vb.chargeCount = 0
mod.vb.torrentCount = 0
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

function mod:OnCombatStart(delay)
	self.vb.chainCount = 0
	self.vb.chargeCount = 0
	self.vb.torrentCount = 0
	self.vb.stormheartCount = 0
	timerChainLightningCD:Start(1)
	timerUnstableChargeCD:Start(1)
	timerLightningTorrentCD:Start(1)
	timerLightningDashCD:Start(1)
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
		warnChainLightning:Show()
		timerChainLightningCD:Start()
	elseif spellId == 420739 then
		self.vb.chargeCount = self.vb.chargeCount + 1
		timerUnstableChargeCD:Start()
	elseif spellId == 444123 then
		self.vb.torrentCount = self.vb.torrentCount + 1
		specWarnLightningTorrent:Show(self.vb.torrentCount)
		specWarnLightningTorrent:Play("watchstep")
		timerLightningTorrentCD:Start()
	elseif spellId == 419870 then
		timerLightningDashCD:Start()
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "DashTarget", 0.1, 7, true)
	elseif spellId == 444324 then
		self.vb.stormheartCount = self.vb.stormheartCount + 1
		warnStormheart:Show(self.vb.stormheartCount)
		timerStormheartCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 372858 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 420739 then
		if args:IsPlayer() then
			specWarnUnstableCharge:Show()
			specWarnUnstableCharge:Play("bombyou")--Change to jumpinpit?
			yellSUnstableCharge:Yell()
			yellSUnstableChargeFades:Countdown(spellId)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 420739 then
		if args:IsPlayer() then
			yellSUnstableChargeFades:Cancel()
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
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
