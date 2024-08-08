local mod	= DBM:NewMod("TheStonevaultTrash", "DBM-Party-WarWithin", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 425027 426283 447141 449455 426308 429109 449130 449154 429545 426345 448852 426771 445207",
	"SPELL_CAST_SUCCESS 429427",
	"SPELL_AURA_APPLIED 426308",
	"SPELL_AURA_APPLIED_DOSE 427361",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--TODO, monitor https://www.wowhead.com/beta/spell=429545/censoring-gear . right now it's always cast on tank and is inconsiquential and there are more important spells to kick. Nameplate timer only for now
local warnHowlingFear						= mod:NewCastAnnounce(449455, 4)
local warnRestoringMetals					= mod:NewCastAnnounce(429109, 4)
local warnPiercingWail						= mod:NewCastAnnounce(445207, 4)
local warnFracture							= mod:NewStackAnnounce(427361, 2)

local specWarnSeismicWave					= mod:NewSpecialWarningDodge(425027, nil, nil, nil, 2, 2)
local specWarnPulverizingPounce				= mod:NewSpecialWarningDodge(447141, nil, nil, nil, 2, 2)
local specWarnLavaCannon					= mod:NewSpecialWarningDodge(449130, nil, nil, nil, 2, 2)
local specWarnCrystalSalvo					= mod:NewSpecialWarningDodge(426345, nil, nil, nil, 2, 2)
local specWarnVoidStorm						= mod:NewSpecialWarningSpell(426771, nil, nil, nil, 2, 2)
local specWarnTerminationProtocol			= mod:NewSpecialWarningMoveAway(449154, nil, nil, nil, 1, 2)
local yellTerminationProtocol				= mod:NewShortYell(449154)
local specWarnEarthBurstTotem				= mod:NewSpecialWarningSwitch(429427, nil, nil, nil, 1, 2)
local specWarnVoidInfection					= mod:NewSpecialWarningDispel(426308, "RemoveCurse", nil, nil, 1, 2)
local specWarnFracture						= mod:NewSpecialWarningDispel(427361, "RemoveMagic", nil, nil, 1, 2)
local specWarnArcingVoid					= mod:NewSpecialWarningInterrupt(426283, "HasInterrupt", nil, nil, 1, 2)
local specWarnHowlingFear					= mod:NewSpecialWarningInterrupt(449455, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt
local specWarnRestoringMetals				= mod:NewSpecialWarningInterrupt(429109, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt
local specWarnCensoringGear					= mod:NewSpecialWarningInterrupt(429545, false, nil, nil, 1, 2)
local specWarnDefilingOutburst				= mod:NewSpecialWarningInterrupt(448852, "HasInterrupt", nil, nil, 1, 2)
local specWarnPiercingWail					= mod:NewSpecialWarningInterrupt(445207, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt

local timerSeismicWaveCD					= mod:NewCDNPTimer(17, 425027, nil, nil, nil, 3)
local timerPulverizingPounceCD				= mod:NewCDNPTimer(15.8, 447141, nil, nil, nil, 3)--15.8-19
local timerVoidInfectionCD					= mod:NewCDNPTimer(15, 426308, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerLavaCannonCD						= mod:NewCDNPTimer(14.9, 449130, nil, nil, nil, 3)--15.3-19
local timerTerminationProtocolCD			= mod:NewCDNPTimer(15.3, 449154, nil, nil, nil, 3)--15.3-19
local timerCrystalSalvoCD					= mod:NewCDNPTimer(24.2, 426345, nil, nil, nil, 3)--Insufficient data to be sure of this one yet
local timerVoidStormCD						= mod:NewCDNPTimer(15.7, 426771, nil, nil, nil, 2)
local timerArcingVoidCD						= mod:NewCDNPTimer(7.2, 426283, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Note, if a stun is used to stop cast, it's recast immediately
local timerHowlingFearCD					= mod:NewCDNPTimer(20.6, 449455, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRestoringMetalsCD				= mod:NewCDNPTimer(10.9, 429109, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerCensoringGearCD					= mod:NewCDNPTimer(13.3, 429545, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDefilingOutburstCD				= mod:NewCDNPTimer(18.2, 448852, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Insufficient data to be sure of this one yet
local timerPiercingWailCD					= mod:NewCDNPTimer(15.7, 445207, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:ProtocolTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(3, 5) then
			specWarnTerminationProtocol:Show()
			specWarnTerminationProtocol:Play("runout")
			specWarnTerminationProtocol:ScheduleVoice(2, "keepmove")
			yellTerminationProtocol:Yell()
		end
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 425027 then
		timerSeismicWaveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnSeismicWave:Show()
			specWarnSeismicWave:Play("shockwave")
		end
	elseif spellId == 447141 then
		timerPulverizingPounceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnPulverizingPounce:Show()
			specWarnPulverizingPounce:Play("watchstep")
		end
	elseif spellId == 426283 then
		timerArcingVoidCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnArcingVoid:Show(args.sourceName)
			specWarnArcingVoid:Play("kickcast")
		end
	elseif spellId == 449455 then
		timerHowlingFearCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn449455interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHowlingFear:Show(args.sourceName)
			specWarnHowlingFear:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHowlingFear:Show()
		end
	elseif spellId == 429109 then
		timerRestoringMetalsCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn429109interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRestoringMetals:Show(args.sourceName)
			specWarnRestoringMetals:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnRestoringMetals:Show()
		end
	elseif spellId == 445207 then
		timerPiercingWailCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn445207interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPiercingWail:Show(args.sourceName)
			specWarnPiercingWail:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnPiercingWail:Show()
		end
	elseif spellId == 426308 then
		timerVoidInfectionCD:Start(nil, args.sourceGUID)
	elseif spellId == 449130 then
		timerLavaCannonCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnLavaCannon:Show()
			specWarnLavaCannon:Play("watchorb")
		end
	elseif spellId == 449154 then
		timerTerminationProtocolCD:Start(nil, args.sourceGUID)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ProtocolTarget", 0.1, 8)
	elseif spellId == 429545 then
		timerCensoringGearCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCensoringGear:Show(args.sourceName)
			specWarnCensoringGear:Play("kickcast")
		end
	elseif spellId == 448852 then
		timerDefilingOutburstCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, nil, true) then
			specWarnDefilingOutburst:Show(args.sourceName)
			specWarnDefilingOutburst:Play("kickcast")
		end
	elseif spellId == 426345 then
		timerCrystalSalvoCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnCrystalSalvo:Show()
			specWarnCrystalSalvo:Play("watchstep")
		end
	elseif spellId == 426771 then
		timerVoidStormCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnVoidStorm:Show()
			specWarnVoidStorm:Play("aesoon")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 429427 then
		if self:AntiSpam(3, 5) then
			specWarnEarthBurstTotem:Show()
			specWarnEarthBurstTotem:Play("attacktotem")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 426308 and args:IsDestTypePlayer() and self:CheckDispelFilter("curse") then
		specWarnVoidInfection:Show(args.destName)
		specWarnVoidInfection:Play("helpdispel")
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 427361 and args:IsDestTypePlayer() then
		if args.amount % 5 == 0 then
			if self:CheckDispelFilter("magic") then
				specWarnFracture:Show(args.destName)
				specWarnFracture:Play("helpdispel")
			elseif args:IsPlayer() or self:IsHealer() then
				warnFracture:Show(args.destName, args.amount)
			end
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 210109 then--Earth Infused Golem
		timerSeismicWaveCD:Stop(args.destGUID)
	elseif cid == 212389 or cid == 212403 then--Cursedheart Invader
		timerArcingVoidCD:Stop(args.destGUID)
		timerVoidInfectionCD:Stop(args.destGUID)
	elseif cid == 222923 then--Repurposed Loaderbox
		timerPulverizingPounceCD:Stop(args.destGUID)
	elseif cid == 212453 then--Ghastlyy Voidsoul
		timerHowlingFearCD:Stop(args.destGUID)
	elseif cid == 213338 then--Forgebound Mender
		timerRestoringMetalsCD:Stop(args.destGUID)
	elseif cid == 213343 then--Forge Loader
		timerLavaCannonCD:Stop(args.destGUID)
		timerTerminationProtocolCD:Stop(args.destGUID)
	elseif cid == 214350 then--Turned Speaker
		timerCensoringGearCD:Stop(args.destGUID)
	elseif cid == 212400 then--Void Touched Elemental
		timerCrystalSalvoCD:Stop(args.destGUID)
	elseif cid == 212765 then--Void Bound Despoiler
		timerDefilingOutburstCD:Stop(args.destGUID)
		timerVoidStormCD:Stop(args.destGUID)
	elseif cid == 221979 then
		timerPiercingWailCD:Stop(args.destGUID)
	end
end
