local mod	= DBM:NewMod(2348, "DBM-Party-BfA", 11, 1178)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(144248)--Head Mechinist Sparkflux
mod:SetEncounterID(2259)
mod:SetZone(2097)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 285440",
	"SPELL_CAST_SUCCESS 285454 294853 292332",
	"SPELL_AURA_APPLIED 285460"
)

--TODO, can bomb be target scanned?
--TODO, do more with plants and oil and stuff?
--TODO, if plant warning works, localize it to something more friendly
--TODO, add Blossom Blast if it's not spammy
--[[
ability.id = 285440 and type = "begincast"
 or (ability.id = 285454 or ability.id = 294855 or ability.id = 294853 or ability.id = 292332) and type = "cast"
--]]
local warnDiscomBomb				= mod:NewCountAnnounce(285454, 2)
local warnSelfTrimmingHedge			= mod:NewCountAnnounce(294954, 2)
local warnPlant						= mod:NewCountAnnounce(294853, 2)

local specWarnFlameCannon			= mod:NewSpecialWarningCount(285440, nil, nil, nil, 2, 2)
local specWarnDiscomBomb			= mod:NewSpecialWarningDispel(285454, "RemoveMagic", nil, nil, 2, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerDiscomBombCD				= mod:NewNextCountTimer(20.6, 285454, nil, nil, nil, 3)
local timerFlameCannonCD			= mod:NewCDCountTimer(47.4, 285440, nil, nil, nil, 2)
local timerSelfTrimmingHedgeCD		= mod:NewCDCountTimer(25.5, 294954, nil, nil, nil, 3)
local timerPlantCD					= mod:NewVarCountTimer("v46.1-48.7", 294853, nil, nil, nil, 1)

mod.vb.bombCount = 0
mod.vb.cannonCount = 0
mod.vb.hedgeCount = 0
mod.vb.plantCount = 0

function mod:OnCombatStart(delay)
	self.vb.bombCount = 0
	self.vb.cannonCount = 0
	self.vb.hedgeCount = 0
	self.vb.plantCount = 0
	timerSelfTrimmingHedgeCD:Start(3.4-delay, 1)
	timerPlantCD:Start(5.9-delay, 1)
	timerDiscomBombCD:Start(8.3-delay, 1)
	timerFlameCannonCD:Start(11.9-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 285440 then
		self.vb.cannonCount = self.vb.cannonCount + 1
		specWarnFlameCannon:Show(self.vb.cannonCount)
		specWarnFlameCannon:Play("aesoon")
		timerFlameCannonCD:Start(nil, self.vb.cannonCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 285454 then
		self.vb.bombCount = self.vb.bombCount + 1
		warnDiscomBomb:Show(self.vb.bombCount)
		timerDiscomBombCD:Start(nil, self.vb.bombCount+1)
	elseif spellId == 294853 then--Activate Plant
		self.vb.plantCount = self.vb.plantCount + 1
		warnPlant:Show(self.vb.plantCount)
		timerPlantCD:Start(nil, self.vb.plantCount+1)
	elseif spellId == 292332 then--Self-Trimming Hedge
		self.vb.hedgeCount = self.vb.hedgeCount + 1
		warnSelfTrimmingHedge:Show(self.vb.hedgeCount)
		--"Self-Trimming Hedge-292332-npc:144248-0000322FAF = pull:3.7, 25.5, 25.5, 25.5, 25.5, 25.5",
		timerSelfTrimmingHedgeCD:Start(nil, self.vb.hedgeCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 285460 and self:CheckDispelFilter("magic") then
		specWarnDiscomBomb:Show(args.destName)
		specWarnDiscomBomb:Play("helpdispel")
	end
end
