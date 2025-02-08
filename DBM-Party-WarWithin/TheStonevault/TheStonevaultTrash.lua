local mod	= DBM:NewMod("TheStonevaultTrash", "DBM-Party-WarWithin", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2652)
mod:RegisterZoneCombat(2652)

mod:RegisterEvents(
	"SPELL_CAST_START 425027 426283 447141 449455 429109 449130 449154 429545 426345 426771 445207 448640 429427 428879 428703 459210 425974",
	"SPELL_CAST_SUCCESS 429427 425027 447141 449455 426308 445207 429545 429109 449130 426345",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 426308",
	"SPELL_AURA_APPLIED_DOSE 427361",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--TODO, verify The reworked mechanic of Molten Mortar can still be target scanned (or even should be)
--TODO, maybe auto mark Totems for earthburst totem?
--TODO, Defiling Outburst deleted from game? no eff
--[[
 (ability.id = 425027 or ability.id = 447141 or ability.id = 426283 or ability.id = 425974 or ability.id = 449455 or ability.id = 429109 or ability.id = 445207 or ability.id = 429545 or ability.id = 448852 or ability.id = 426345 or ability.id = 426771 or ability.id = 448640 or ability.id = 429427 or ability.id = 428879 or ability.id = 428703) and (type = "begincast" or type = "cast")
 or (ability.id = 426308) and type = "cast"
 or stoppedAbility.id = 449455 or stoppedAbility.id = 445207 or stoppedAbility.id = 429545 or stoppedAbility.id = 429109 or stoppedAbility.id = 448852
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 210109) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 210109)
--]]
local warnHowlingFear						= mod:NewCastAnnounce(449455, 4)--High Prio interrupt
local warnRestoringMetals					= mod:NewCastAnnounce(429109, 4)--High Prio interrupt
local warnPiercingWail						= mod:NewCastAnnounce(445207, 4)--High Prio interrupt
local warnCensoringGear						= mod:NewCastAnnounce(429545, 4)--High Prio interrupt
local warnEarthBurstTotem					= mod:NewCastAnnounce(429427, 2, nil, nil, false, nil, nil, 3)--Optional CC warning
local warnFracture							= mod:NewStackAnnounce(427361, 2)
local warnMoltenMortar						= mod:NewSpellAnnounce(449154, 2)
local warnGroundPound						= mod:NewSpellAnnounce(425974, 3)

local specWarnShadowClaw					= mod:NewSpecialWarningDefensive(459210, nil, nil, nil, 1, 2)
local specWarnSeismicWave					= mod:NewSpecialWarningDodge(425027, nil, nil, nil, 2, 15)
local specWarnPulverizingPounce				= mod:NewSpecialWarningDodge(447141, nil, nil, nil, 2, 2)
local specWarnLavaCannon					= mod:NewSpecialWarningDodge(449130, nil, nil, nil, 2, 2)
local specWarnCrystalSalvo					= mod:NewSpecialWarningDodge(426345, nil, nil, nil, 2, 2)
local specWarnShieldStampede				= mod:NewSpecialWarningDodge(448640, nil, nil, nil, 2, 15)
local specWarnSmashRock						= mod:NewSpecialWarningSpell(428879, nil, nil, nil, 2, 15)
local specWarnGraniteEruption				= mod:NewSpecialWarningDodge(428703, nil, nil, nil, 2, 2)
local specWarnVoidStorm						= mod:NewSpecialWarningSpell(426771, nil, nil, nil, 2, 2)
local specWarnEarthBurstTotem				= mod:NewSpecialWarningSwitch(429427, nil, nil, nil, 1, 2)
local specWarnVoidInfection					= mod:NewSpecialWarningDispel(426308, "RemoveCurse", nil, nil, 1, 2)
local specWarnFracture						= mod:NewSpecialWarningDispel(427361, "RemoveMagic", nil, nil, 1, 2)
local specWarnArcingVoid					= mod:NewSpecialWarningInterrupt(426283, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt (that has no cooldown)
local specWarnHowlingFear					= mod:NewSpecialWarningInterrupt(449455, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt
local specWarnRestoringMetals				= mod:NewSpecialWarningInterrupt(429109, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt
local specWarnCensoringGear					= mod:NewSpecialWarningInterrupt(429545, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt
local specWarnPiercingWail					= mod:NewSpecialWarningInterrupt(445207, "HasInterrupt", nil, nil, 1, 2)--High Prio interrupt

local timerSeismicWaveCD					= mod:NewCDPNPTimer(15.1, 425027, nil, nil, nil, 3)--was 17 but now 18.1?
local timerPulverizingPounceCD				= mod:NewCDNPTimer(15.1, 447141, nil, nil, nil, 3)--was 15.2 but now 18.1?
local timerVoidInfectionCD					= mod:NewCDNPTimer(18.2, 426308, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerLavaCannonCD						= mod:NewCDPNPTimer(9.1, 449130, nil, nil, nil, 3)
local timerMoltenMortarCD					= mod:NewCDNPTimer(20.6, 449154, nil, nil, nil, 3)--15.3-19
local timerCrystalSalvoCD					= mod:NewCDNPTimer(15.3, 426345, nil, nil, nil, 3)
local timerShadowClawsCD					= mod:NewCDNPTimer(22.7, 459210, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerVoidOutburstCD					= mod:NewCDNPTimer(27.9, 426771, nil, nil, nil, 2)--Cast to cast for now, but if it gets stutter cast reports it'll be moved to success
local timerShieldStampedeCD					= mod:NewCDPNPTimer(17, 448640, nil, nil, nil, 3)
local timerSmashRockCD						= mod:NewCDNPTimer(28.3, 428879, nil, nil, nil, 3)
local timerGraniteEruptionCD				= mod:NewCDNPTimer(24.2, 428703, nil, nil, nil, 3)
local timerEarthBurstTotemCD				= mod:NewCDPNPTimer(30, 429427, nil, nil, nil, 1)
local timerGroundPoundCD					= mod:NewCDNPTimer(21.8, 425974, nil, nil, nil, 2)
local timerHowlingFearCD					= mod:NewCDPNPTimer(22.7, 449455, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Poor sample size, these mobs rarely live long enough
local timerRestoringMetalsCD				= mod:NewCDPNPTimer(16.3, 429109, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerCensoringGearCD					= mod:NewCDPNPTimer(18.2, 429545, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerPiercingWailCD					= mod:NewCDPNPTimer(20.1, 445207, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 425027 then
		if self:AntiSpam(3, 2) then
			specWarnSeismicWave:Show()
			specWarnSeismicWave:Play("frontal")
		end
	elseif spellId == 447141 then
		if self:AntiSpam(3, 2) then
			specWarnPulverizingPounce:Show()
			specWarnPulverizingPounce:Play("watchstep")
		end
	elseif spellId == 426283 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnArcingVoid:Show(args.sourceName)
			specWarnArcingVoid:Play("kickcast")
		end
	elseif spellId == 449455 then
		if self.Options.SpecWarn449455interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHowlingFear:Show(args.sourceName)
			specWarnHowlingFear:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHowlingFear:Show()
		end
	elseif spellId == 429109 then
		if self.Options.SpecWarn429109interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRestoringMetals:Show(args.sourceName)
			specWarnRestoringMetals:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnRestoringMetals:Show()
		end
	elseif spellId == 445207 then
		if self.Options.SpecWarn445207interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPiercingWail:Show(args.sourceName)
			specWarnPiercingWail:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnPiercingWail:Show()
		end
	elseif spellId == 449130 then
		if self:AntiSpam(3, 2) then
			specWarnLavaCannon:Show()
			specWarnLavaCannon:Play("watchorb")
		end
	elseif spellId == 449154 then
		if self:AntiSpam(3, 4) then
			warnMoltenMortar:Show()
		end
		timerMoltenMortarCD:Start(nil, args.sourceGUID)
	elseif spellId == 429545 then
		if self.Options.SpecWarn429545interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCensoringGear:Show(args.sourceName)
			specWarnCensoringGear:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnCensoringGear:Show()
		end
	elseif spellId == 426345 then
		if self:AntiSpam(3, 2) then
			specWarnCrystalSalvo:Show()
			specWarnCrystalSalvo:Play("watchstep")
		end
	elseif spellId == 426771 then
		timerVoidOutburstCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnVoidStorm:Show()
			specWarnVoidStorm:Play("aesoon")
		end
	elseif spellId == 448640 then
		timerShieldStampedeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(2, 2) then
			specWarnShieldStampede:Show()
			specWarnShieldStampede:Play("chargemove")
		end
	elseif spellId == 429427 then
		if self:AntiSpam(3, 6) then
			warnEarthBurstTotem:Show()
			warnEarthBurstTotem:Play("crowdcontrol")
		end
	elseif spellId == 428879 then
		timerSmashRockCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnSmashRock:Show()
			specWarnSmashRock:Play("carefly")
		end
	elseif spellId == 428703 then
		timerGraniteEruptionCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnGraniteEruption:Show()
			specWarnGraniteEruption:Play("watchstep")
		end
	elseif spellId == 459210 then
		timerShadowClawsCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnShadowClaw:Show()
			specWarnShadowClaw:Play("defensive")
		end
	elseif spellId == 425974 then
		timerGroundPoundCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnGroundPound:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 429427 then
		timerEarthBurstTotemCD:Start(30, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnEarthBurstTotem:Show()
			specWarnEarthBurstTotem:Play("attacktotem")
		end
	elseif spellId == 425027 then
		timerSeismicWaveCD:Start(15.1, args.sourceGUID)
	elseif spellId == 447141 then
		timerPulverizingPounceCD:Start(15.1, args.sourceGUID)
	elseif spellId == 449455 then
		timerHowlingFearCD:Start(22.7, args.sourceGUID)
	elseif spellId == 426308 then
		timerVoidInfectionCD:Start(18.2, args.sourceGUID)
	elseif spellId == 445207 then
		timerPiercingWailCD:Start(20.1, args.sourceGUID)
	elseif spellId == 429545 then
		timerCensoringGearCD:Start(18.2, args.sourceGUID)
	elseif spellId == 429109 then
		timerRestoringMetalsCD:Start(16.3, args.sourceGUID)
	elseif spellId == 449130 then
		timerLavaCannonCD:Start(9.1, args.sourceGUID)
	elseif spellId == 426345 then
		timerCrystalSalvoCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 449455 then
		timerHowlingFearCD:Start(22.7, args.destGUID)
	elseif spellId == 445207 then
		timerPiercingWailCD:Start(20.1, args.destGUID)
	elseif spellId == 429545 then
		timerCensoringGearCD:Start(18.2, args.destGUID)
	elseif spellId == 429109 then
		timerRestoringMetalsCD:Start(16.3, args.destGUID)
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
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 210109 then--Earth Infused Golem
		timerSeismicWaveCD:Stop(args.destGUID)
		timerGroundPoundCD:Stop(args.destGUID)
	elseif cid == 212389 or cid == 212403 then--Cursedheart Invader
		timerVoidInfectionCD:Stop(args.destGUID)
	elseif cid == 222923 then--Repurposed Loaderbox
		timerPulverizingPounceCD:Stop(args.destGUID)
	elseif cid == 212453 then--Ghastlyy Voidsoul
		timerHowlingFearCD:Stop(args.destGUID)
	elseif cid == 213338 or cid == 224962 then--Forgebound Mender / Cursedforge Mender
		timerRestoringMetalsCD:Stop(args.destGUID)
	elseif cid == 213343 then--Forge Loader
		timerLavaCannonCD:Stop(args.destGUID)
		timerMoltenMortarCD:Stop(args.destGUID)
	elseif cid == 214350 then--Turned Speaker
		timerCensoringGearCD:Stop(args.destGUID)
	elseif cid == 212400 then--Void Touched Elemental
		timerCrystalSalvoCD:Stop(args.destGUID)
	elseif cid == 212765 then--Void Bound Despoiler
		timerShadowClawsCD:Stop(args.destGUID)
		timerVoidOutburstCD:Stop(args.destGUID)
	elseif cid == 221979 then--Void Bound Howler
		timerPiercingWailCD:Stop(args.destGUID)
	elseif cid == 214264 then--Cursedforge Honor Guard
		timerShieldStampedeCD:Stop(args.destGUID)
	elseif cid == 214066 then--Cursedforge StoneShaper
		timerEarthBurstTotemCD:Stop(args.destGUID)
	elseif cid == 213954 then--Rock Smasher
		timerSmashRockCD:Stop(args.destGUID)
		timerGraniteEruptionCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 210109 then--Earth Infused Golem
		timerSeismicWaveCD:Start(4.6-delay, guid)--4.6-9.4
		timerGroundPoundCD:Start(13.2-delay, guid)--13.2-18.2
	elseif cid == 212389 or cid == 212403 then--Cursedheart Invader
		timerVoidInfectionCD:Start(8.2-delay, guid)--8.2-10
	elseif cid == 222923 then--Repurposed Loaderbox
		timerPulverizingPounceCD:Start(6.4-delay, guid)--6.4-11.4
	elseif cid == 212453 then--Ghastlyy Voidsoul
		timerHowlingFearCD:Start(4.2-delay, guid)--4.2-9.5
	elseif cid == 213338 or cid == 224962 then--Forgebound Mender
		timerRestoringMetalsCD:Start(10.8-delay, guid)--10.8-16.1
	elseif cid == 213343 then--Forge Loader
		timerLavaCannonCD:Start(9.4-delay, guid)--9.4-10.1
		timerMoltenMortarCD:Start(11.8-delay, guid)--11.8-13.4
	--elseif cid == 214350 then--Turned Speaker
	--	timerCensoringGearCD:Start(18.2-delay, guid)--Used immediately on pull
	elseif cid == 212400 then--Void Touched Elemental
		timerCrystalSalvoCD:Start(3.6-delay, guid)--3.6-5.5
	elseif cid == 212765 then--Void Bound Despoiler
		timerShadowClawsCD:Start(3-delay, guid)--3-6.7
		timerVoidOutburstCD:Start(7.1-delay, guid)--5.3-8.8?
	elseif cid == 221979 then--Void Bound Howler
		timerPiercingWailCD:Start(5.1-delay, guid)--Test thoroughly in folloewr dungeon
	elseif cid == 214264 then--Cursedforge Honor Guard
		timerShieldStampedeCD:Start(4.6-delay, guid)
	elseif cid == 214066 then--Cursedforge StoneShaper
		timerEarthBurstTotemCD:Start(1.9-delay, guid)--1.9-4.9
	elseif cid == 213954 then--Rock Smasher
		timerSmashRockCD:Start(8.5-delay, guid)--8.5
		timerGraniteEruptionCD:Start(14.5-delay, guid)--14.5-16.2
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
