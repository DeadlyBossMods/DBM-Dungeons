local mod	= DBM:NewMod(2572, "DBM-Party-WarWithin", 4, 1269)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(210108)
mod:SetEncounterID(2854)
mod:SetHotfixNoticeRev(20240428000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 424879 424888 424903",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 424795 424889 424893"
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 24879 or ability.id = 424888 or ability.id = 424903) and type = "begincast"
or ability.id = 424795 and type = "applydebuff"
or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnRefractingBeam					= mod:NewTargetNoFilterAnnounce(424795, 3)
local warnSeismicReverberation				= mod:NewTargetNoFilterAnnounce(424889, 3, nil, "RemoveMagic|Tank")
local warnEarthShield						= mod:NewTargetNoFilterAnnounce(424893, 3, nil, false)

local specWarnRefractingBeam				= mod:NewSpecialWarningYou(424795, nil, nil, nil, 1, 2)
local yellRefractingBeam					= mod:NewYell(424795)
local specWarnEarthShatterer				= mod:NewSpecialWarningCount(424879, nil, nil, nil, 2, 2)
local specWarnSeismicSmash					= mod:NewSpecialWarningDefensive(424888, nil, nil, nil, 1, 2)
local specWarnVolatileSpike					= mod:NewSpecialWarningCount(424903, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerRefractingBeamCD					= mod:NewCDCountTimer(10.9, 424795, nil, nil, nil, 3)
local timerEarthShattererCD					= mod:NewAITimer(33.9, 424879, nil, nil, nil, 2, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerSeismicSmashCD					= mod:NewCDCountTimer(23, 424888, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.HEALER_ICON)
local timerVolatileSpikeCD					= mod:NewCDCountTimer(14.5, 424903, nil, nil, nil, 3)

--local castsPerGUID = {}

mod.vb.laserCount = 0
mod.vb.shatterCount = 0
mod.vb.smashCount = 0
mod.vb.spikeCount = 0

function mod:OnCombatStart(delay)
	self.vb.laserCount = 0
	self.vb.shatterCount = 0
	self.vb.smashCount = 0
	self.vb.spikeCount = 0
	timerVolatileSpikeCD:Start(8.4-delay, 1)
	timerRefractingBeamCD:Start(10.9-delay, 1)
	timerSeismicSmashCD:Start(15.7-delay, 1)
	if self:IsMythic() then
		timerEarthShattererCD:Start(1-delay)
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 424879 then
		self.vb.shatterCount = self.vb.shatterCount + 1
		specWarnEarthShatterer:Show(self.vb.shatterCount)
		specWarnEarthShatterer:Play("aesoon")
		timerEarthShattererCD:Start()
	elseif spellId == 424888 then
		self.vb.smashCount = self.vb.smashCount + 1
		timerSeismicSmashCD:Start(nil, self.vb.smashCount+1)
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSeismicSmash:Show()
			specWarnSeismicSmash:Play("defensive")
		end
	elseif spellId == 424903 then
		self.vb.spikeCount = self.vb.spikeCount + 1
		specWarnVolatileSpike:Show(self.vb.spikeCount)
		specWarnVolatileSpike:Play("watchstep")
		timerVolatileSpikeCD:Start(nil, self.vb.spikeCount+1)
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
	if spellId == 424795 then
		self.vb.laserCount = self.vb.laserCount + 1
		if self:AntiSpam(3, 1) then
			timerRefractingBeamCD:Start(nil, self.vb.laserCount+1)--No cast event
		end
		warnRefractingBeam:PreciseShow(2, args.destName)
		if args:IsPlayer() then
			specWarnRefractingBeam:Show()
			specWarnRefractingBeam:Play("laserrun")
			yellRefractingBeam:Yell()
		end
	elseif spellId == 424889 then
		warnSeismicReverberation:Show(args.destName)
	elseif spellId == 424893 then
		warnEarthShield:Show(args.destName)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

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
