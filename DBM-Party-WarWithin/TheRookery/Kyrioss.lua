local mod	= DBM:NewMod(2566, "DBM-Party-WarWithin", 3, 1268)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(209230)
mod:SetEncounterID(2816)
mod:SetHotfixNoticeRev(20250303000000)
mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2648)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 424148 419870 1214325 1214315 474018",
	"SPELL_CAST_SUCCESS 444034",
	"SPELL_AURA_REMOVED 1214315"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE: Boss lists 3 abilities in journal that are never cast. stormheart, chain lightning, and unstable charge
--[[
(ability.id = 424148 or ability.id = 420739 or ability.id = 419870 or ability.id = 444324) and type = "begincast"
 or ability.id = 444034 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--local warnLightningDash					= mod:NewTargetNoFilterAnnounce(419870, 3)
--local warnStormheart						= mod:NewCountAnnounce(444324, 3)

local specWarnLightningTorrent				= mod:NewSpecialWarningDodgeCount(444123, nil, nil, nil, 1, 2)
local specWarnLightningDash					= mod:NewSpecialWarningDodgeCount(419870, nil, nil, nil, 1, 2)
local specWarnCrashingThunder				= mod:NewSpecialWarningDodgeCount(1214325, nil, nil, nil, 2, 2)
local specWarnWildLightning					= mod:NewSpecialWarningDodgeCount(474018, nil, nil, nil, 2, 2)
--local yellSLightningDash					= mod:NewYell(419870)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerLightningTorrentCD				= mod:NewNextCountTimer(55.9, 444123, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerLightningTorrent					= mod:NewCastTimer(19, 444034, nil, nil, nil, 5, nil, DBM_COMMON_L.DEADLY_ICON)
local timerLightningDashCD					= mod:NewNextCountTimer(55.9, 419870, nil, nil, nil, 3)--Timer confirmed by bugging out torrent to disable delays
--local timerStormheartCD					= mod:NewCDCountTimer(33.9, 444324, nil, nil, nil, 3)
local timerCrashingThunderCD				= mod:NewCDCountTimer(15.3, 1214325, nil, nil, nil, 3)
local timerWildLightningCD					= mod:NewCDCountTimer(15.3, 474018, nil, nil, nil, 3)

--local castsPerGUID = {}

mod.vb.wildCount = 0
mod.vb.torrentCount = 0
mod.vb.dashCount = 0
--mod.vb.stormheartCount = 0
mod.vb.crashingThunderCount = 0

function mod:OnCombatStart(delay)
	self.vb.wildCount = 0
	self.vb.torrentCount = 0
	self.vb.dashCount = 0
--	self.vb.stormheartCount = 0
	self.vb.crashingThunderCount = 0
--	timerStormheartCD:Start(1, 1)
	timerCrashingThunderCD:Start(5.0, 1)
	timerWildLightningCD:Start(9.4, 1)
	timerLightningTorrentCD:Start(16.1, 1)
	--Dash timer started in torrent
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 419870 then
		self.vb.dashCount = self.vb.dashCount + 1
		specWarnLightningDash:Show(self.vb.dashCount)
		specWarnLightningDash:Play("watchstep")
	--elseif spellId == 444324 then
	--	self.vb.stormheartCount = self.vb.stormheartCount + 1
	--	warnStormheart:Show(self.vb.stormheartCount)
	--	timerStormheartCD:Start()
	elseif spellId == 1214325 then
		self.vb.crashingThunderCount = self.vb.crashingThunderCount + 1
		specWarnCrashingThunder:Show(self.vb.crashingThunderCount)
		specWarnCrashingThunder:Play("watchstep")
		--"Crashing Thunder-1214325-npc:209230-000034D362 = pull:5.8, 42.5, 15.8, 40.1, 15.8",
		if self.vb.crashingThunderCount == 1 then
			timerCrashingThunderCD:Start(41.3, 2)
		elseif self.vb.crashingThunderCount % 2 == 0 then
			timerCrashingThunderCD:Start(15.8, self.vb.crashingThunderCount+1)
		else
			timerCrashingThunderCD:Start(40.1, self.vb.crashingThunderCount+1)
		end
	elseif spellId == 1214315 then
		timerLightningTorrent:Start()
	elseif spellId == 474018 then
		self.vb.wildCount = self.vb.wildCount + 1
		specWarnWildLightning:Show(self.vb.wildCount)
		specWarnWildLightning:Play("watchstep")
		--"Wild Lightning-474018-npc:209230-000034D362 = pull:9.4, 42.1, 15.8, 40.1, 15.8",
		if self.vb.wildCount == 1 then
			timerWildLightningCD:Start(42.1, 2)
		elseif self.vb.wildCount % 2 == 0 then
			timerWildLightningCD:Start(15.8, self.vb.wildCount+1)
		else
			timerWildLightningCD:Start(40.1, self.vb.wildCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 444034 then--Faster than SPELL_CAST_START but may be hidden later so SCS backup remains
		self.vb.torrentCount = self.vb.torrentCount + 1
		specWarnLightningTorrent:Show(self.vb.torrentCount)
		specWarnLightningTorrent:Play("watchstep")
		timerLightningTorrentCD:Start(nil, self.vb.torrentCount+1)
		--Better to start this here, since boss always comes out of torrent with a lightning dash
		timerLightningDashCD:Start(22.5, self.vb.dashCount+1)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 1214315 then--Torrent Ending
		timerLightningTorrent:Stop()
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
