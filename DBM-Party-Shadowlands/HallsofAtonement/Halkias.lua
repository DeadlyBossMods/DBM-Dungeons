local mod	= DBM:NewMod(2406, "DBM-Party-Shadowlands", 4, 1185)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(165408)
mod:SetEncounterID(2401)
mod:SetHotfixNoticeRev(20250808000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2287)

mod:RegisterCombat("combat")

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(323001, true, 323001, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(323001, "watchfeet", 8)
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 322936 322711",
	"SPELL_CAST_SUCCESS 322943",
	"SPELL_AURA_APPLIED 322977",
	"SPELL_PERIODIC_DAMAGE 323001",
	"SPELL_PERIODIC_MISSED 323001"
)
--]]

--TODO, Target scan Heave Debris? it's instant cast, maybe it has an emote?
--Sinlight visions deleted?
--Not entirely convinced refracted sinlight is a timer (and not health based)
--[[
(ability.id = 322936 or ability.id = 322711 or ability.id = 322977) and type = "begincast"
 or (ability.id = 322943) and type = "cast"
 or ability.id = 322977 and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--[[
local warnHeaveDebris				= mod:NewCountAnnounce(322943, 3)

local specWarnCrumblingSlam			= mod:NewSpecialWarningMove(322936, "Tank", nil, nil, 1, 2)
local specWarnRefractedSinlight		= mod:NewSpecialWarningDodgeCount(322711, nil, nil, nil, 3, 2)
local specWarnSinlightVisions		= mod:NewSpecialWarningDispel(322977, "RemoveMagic", nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(323001, nil, nil, nil, 1, 8)

local timerCrumblingSlamCD			= mod:NewCDCountTimer(12.1, 322936, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--12.1 except after refracted sinlight
local timerHeaveDebrisCD			= mod:NewCDCountTimer(12.1, 322943, nil, nil, nil, 3)--12.1 except after refracted sinlight
local timerRefractedSinlightCD		= mod:NewCDCountTimer(49.7, 322711, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--45--51
--local timerSinlightVisionsCD		= mod:NewCDTimer(23, 322977, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)--23-27

--"Sinlight Visions-339237-npc:165408 = pull:5.0, 5.0, 20.0, 5.0, 15.0, 20.0

mod.vb.slamCount = 0
mod.vb.debrisCount = 0
mod.vb.refractedCount = 0

function mod:OnCombatStart(delay)
	self.vb.slamCount = 0
	self.vb.debrisCount = 0
	self.vb.refractedCount = 0
	timerCrumblingSlamCD:Start(4-delay, 1)
--	timerSinlightVisionsCD:Start(5-delay)--SUCCESS
	timerHeaveDebrisCD:Start(15.1-delay, 1)--SUCCESS
	timerRefractedSinlightCD:Start(32.8-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 322936 then
		self.vb.slamCount = self.vb.slamCount + 1
		specWarnCrumblingSlam:Show()
		specWarnCrumblingSlam:Play("moveboss")
	elseif spellId == 322711 then
		self.vb.refractedCount = self.vb.refractedCount + 1
		specWarnRefractedSinlight:Show(self.vb.refractedCount)
		specWarnRefractedSinlight:Play("watchstep")
		timerRefractedSinlightCD:Start()
		timerCrumblingSlamCD:Stop()
		timerHeaveDebrisCD:Stop()
		timerHeaveDebrisCD:Start(18, self.vb.debrisCount+1)
		timerCrumblingSlamCD:Start(21.8, self.vb.slamCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 322943 then
		self.vb.debrisCount = self.vb.debrisCount + 1
		warnHeaveDebris:Show(self.vb.debrisCount)
		timerHeaveDebrisCD:Start(nil, self.vb.debrisCount+1)
--	elseif spellId == 322977 then
		--timerSinlightVisionsCD:Start()--Unknown, pull too short
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 322977 then
		specWarnSinlightVisions:Show(args.destName)
		specWarnSinlightVisions:Play("helpdispel")
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 323001 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
