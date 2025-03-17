local mod	= DBM:NewMod(2339, "DBM-Party-BfA", 11, 1178)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(144246)
mod:SetEncounterID(2258)
mod:SetHotfixNoticeRev(20250303000000)
mod:SetZone(2097)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 291946 291973",
	"SPELL_CAST_SUCCESS 291922 294929",
	"SPELL_AURA_APPLIED 291972 294929",
	"SPELL_AURA_APPLIED_DOSE 294929"
)

--[[
(ability.id = 291946 or ability.id = 291973) and type = "begincast"
 or (ability.id = 291922 or ability.id = 294929) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, can't see a way to detect Robo waste drops, schedule a timer loop?
local warnAirDrop					= mod:NewCountAnnounce(291930, 2)
local warnExplosiveLeap				= mod:NewTargetNoFilterAnnounce(291972, 3)
local warnBlazingChomp				= mod:NewStackAnnounce(294929, 2, nil, "Tank|Healer")

local specWarnExplosiveLeap			= mod:NewSpecialWarningMoveAway(291972, nil, nil, nil, 1, 2)
local yellExplosiveLeap				= mod:NewYell(291972)
local specWarnVentingFlames			= mod:NewSpecialWarningMoveTo(291946, nil, nil, nil, 3, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerAurDropCD				= mod:NewNextCountTimer(32.7, 291930, nil, nil, nil, 3)
local timerExplosiveLeapCD			= mod:NewNextCountTimer(34, 291972, nil, nil, nil, 3)
local timerVentingFlamesCD			= mod:NewCDCountTimer(13.4, 291946, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerBlazingChompCD			= mod:NewVarCountTimer("v15.8-19.4", 294929, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod.vb.airDropCount = 0
mod.vb.leapCount = 0
mod.vb.flamesCount = 0
mod.vb.chompCount = 0

function mod:OnCombatStart(delay)
	self.vb.airDropCount = 0
	self.vb.leapCount = 0
	self.vb.flamesCount = 0
	self.vb.chompCount = 0
	timerAurDropCD:Start("v5.8-9.2", 1)--SUCCESS
	timerBlazingChompCD:Start(10.6-delay, 1)--SUCCESS
	timerVentingFlamesCD:Start(15.5-delay, 1)--START
	timerExplosiveLeapCD:Start(38.6-delay, 1)--START
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 291946 then
		self.vb.flamesCount = self.vb.flamesCount + 1
		specWarnVentingFlames:Show(DBM_COMMON_L.BREAK_LOS)
		specWarnVentingFlames:Play("findshelter")
		--15.5, 33.9, 34.0, 34.0"
		timerVentingFlamesCD:Start(nil, self.vb.flamesCount+1)
	elseif spellId == 291973 then
		self.vb.leapCount = self.vb.leapCount + 1
		--38.6, 33.9, 34.0, 33.4
		--"Explosive Leap-291973-npc:144246-0000322FAF = pull:38.6, 34.0, 34.0, 34.0",
		timerExplosiveLeapCD:Start(nil, self.vb.leapCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 291922 then
		self.vb.airDropCount = self.vb.airDropCount + 1
		warnAirDrop:Show(self.vb.airDropCount)
		--7.2, 26.3, 34.0, 34.0, 34.0
		--"Air Drop-291922-npc:144246-0000322FAF = pull:6.1, 26.4, 34.0, 34.0, 34.0",
		timerAurDropCD:Start(self.vb.airDropCount == 1 and 26.3 or 34)
	elseif spellId == 294929 then
		self.vb.chompCount = self.vb.chompCount + 1
		--10.7, 18.2, 18.2, 17.0, 17.0, 15.8
		--10.6, 15.8, 20.6, 15.8, 18.2, 15.8, 18.2, 15.8, 18.2, 15.8",
		timerBlazingChompCD:Start(nil, self.vb.chompCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 291972 then
		warnExplosiveLeap:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnExplosiveLeap:Show()
			specWarnExplosiveLeap:Play("runout")
			yellExplosiveLeap:Yell()
		end
	elseif spellId == 294929 then
		local amount = args.amount or 1
		warnBlazingChomp:Show(args.destName, amount)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
