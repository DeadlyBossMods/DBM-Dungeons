local mod	= DBM:NewMod("EcoDomeAldaniTrash", "DBM-Party-WarWithin", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2830)
mod:RegisterZoneCombat(2830)

mod:RegisterEvents(
	"SPELL_CAST_START 1229474 426893 1221190 1226111 1235368 1222356 1229510 1222815 1221532 1226306 1222341 1223007 1237195 1237220 1215850",
	"SPELL_CAST_SUCCESS 426893 1221190 1226111 1235368 1222356 1221679 1229510 1223000 1222341 1221483",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 1221133 1221483 1231608 1223000 1239229",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--[[
(ability.id = 1221152) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 1221152
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 234883) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 234883)
--]]
--TODO, do anything protected/unstable cores?
--TODO, target scan some of these? WCL doesn't reveal that kind of info
--TODO, add Shatter Conduit?
--https://docs.google.com/spreadsheets/d/14lo7XeMrTRsIYXf9_TYfzCDvx53dL56hM1TR40NYRKs/edit?gid=269490265#gid=269490265
local warnFarstalkersLeap					= mod:NewSpellAnnounce(1221679, 2)--Non special because it's instant cast so it's not like you can really avoid it
local warnArcaneSlash						= mod:NewCastAnnounce(1235368, 3, nil, nil, "Tank|Healer")
local warnGloomBite							= mod:NewCastAnnounce(1222341, 2, nil, nil, "Tank|Healer")
local warnAlacrity							= mod:NewTargetNoFilterAnnounce(1231608, 2, nil, "Tank|MagicDispeller")
local warnKareshiSurge						= mod:NewYouAnnounce(1239229, 1)

local specWarnGorgingSmash					= mod:NewSpecialWarningSpell(426893, nil, nil, nil, 2, 2)
local specErraticRitual						= mod:NewSpecialWarningSpell(1221532, nil, nil, nil, 2, 2)
local specWarnStingingSandstorm				= mod:NewSpecialWarningSpell(1237220, nil, nil, nil, 2, 2)
local specWarnConsumeSpirit					= mod:NewSpecialWarningSwitch(1226306, "-Healer", nil, nil, 1, 2)
local specWarnGluttonousMiasma				= mod:NewSpecialWarningMoveAway(1221190, nil, nil, nil, 2, 2)
local specWarnVolatileEjection				= mod:NewSpecialWarningYou(1226111, nil, nil, nil, 1, 2)
local yellVolatileEjection					= mod:NewShortYell(1226111)
local specWarnVolatileEjectionOther			= mod:NewSpecialWarningTarget(1226111, nil, nil, nil, 2, 2)
local specWarnWarp							= mod:NewSpecialWarningDodge(1222356, nil, nil, nil, 2, 2)
local specWarnBurrowingEruption				= mod:NewSpecialWarningDodge(1223007, nil, nil, nil, 2, 2)
local specWarnBurrowCharge					= mod:NewSpecialWarningDodge(1237195, nil, nil, nil, 2, 2)
local specWarnEarthCrusher					= mod:NewSpecialWarningDodge(1215850, nil, nil, nil, 2, 2)
local specWarnArcingEnergy					= mod:NewSpecialWarningMoveAway(1221483, nil, nil, nil, 1, 2)
local yellArcingEnergy						= mod:NewShortYell(1221483)
local specWarnGorge							= mod:NewSpecialWarningInterrupt(1229474, "HasInterrupt", nil, nil, 1, 2)--More or less spammed so no timer
local specWarnArcingZap						= mod:NewSpecialWarningInterrupt(1229510, "HasInterrupt", nil, nil, 1, 2)--Important
local specWarnArcaneBolt					= mod:NewSpecialWarningInterrupt(1222815, "HasInterrupt", nil, nil, 1, 2)--More or less spammed so no timer
local specWarnHungeringRage					= mod:NewSpecialWarningDispel(1221133, "RemoveEnrage", nil, nil, 1, 2)--No clear CD, probably only cast once at a health threshold
local specWarnArcingEnergyDispel			= mod:NewSpecialWarningDispel(1221483, "RemoveMagic", nil, nil, 1, 2)
local specWarnEmbraceOfKaresh				= mod:NewSpecialWarningDispel(1223000, "MagicDispeller", nil, nil, 1, 2)

local timerGorgingSmashCD					= mod:NewCDNPTimer(16.4, 426893, nil, nil, nil, 3)--18.2 but cast time adjusted
local timerGluttonousMiasmaCD				= mod:NewCDNPTimer(15.2, 1221190, nil, nil, nil, 3)--18.2 but cast time adjusted
local timerVolatileEjectionCD				= mod:NewCDNPTimer(16.6, 1226111, nil, nil, nil, 3)--20.6 but cast time adjusted
local timerArcaneSlashCD					= mod:NewCDNPTimer(15.2, 1235368, nil, nil, nil, 3)--18.2 but cast time adjusted
local timerWarpCD							= mod:NewCDNPTimer(9.2, 1222356, nil, nil, nil, 3)--12.2 but cast time adjusted
local timerFarstalkersLeapCD				= mod:NewCDNPTimer(11.8, 1221679, nil, nil, nil, 3)--11.8-13.3
local timerArcingZapCD						= mod:NewCDPNPTimer(24.2, 1229510, nil, nil, nil, 4)
local timerArcingEnergyCD					= mod:NewCDNPTimer(9.4, 1221483, nil, nil, nil, 3)--actually alternates between 10.9 and 13.3 due to a spell queue
local timerErraticRitualCD					= mod:NewCDPNPTimer(19.8, 1221532, nil, nil, nil, 2)--19.8-31.6
local timerConsumeSpiritCD					= mod:NewCDPNPTimer(51.9, 1226306, nil, nil, nil, 1)--Iffy
local timerEmbraceOfKareshCD				= mod:NewCDNPTimer(17, 1223000, nil, nil, nil, 5)
local timerGloomBiteCD						= mod:NewCDNPTimer(12.1, 1222341, nil, nil, nil, 5)--Iffy 14.6-2.5
local timerBurrowingEruptionCD				= mod:NewCDNPTimer(18.3, 1223007, nil, nil, nil, 3)--Iffy
local timerBurrowChargeCD					= mod:NewCDNPTimer(19.5, 1237195, nil, nil, nil, 3)--Iffy 19.5-25
local timerStingingSandstormCD				= mod:NewCDPNPTimer(26.7, 1237220, nil, nil, nil, 2)--Iffy
local timerEarthCrusherCD					= mod:NewCDPNPTimer(31.7, 1215850, nil, nil, nil, 3)--Iffy 31.7-37

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:VolatileTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnVolatileEjection:Show()
			specWarnVolatileEjection:Play("targetyou")
		end
		yellVolatileEjection:Yell()
	else
		if self:AntiSpam(3, 2) then
			specWarnVolatileEjectionOther:Show(targetname)
			specWarnVolatileEjectionOther:Play("frontal")
		end
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 1229474 and self:CheckInterruptFilter(args.sourceGUID, nil, true) then
		specWarnGorge:Show(args.sourceName)
		specWarnGorge:Play("kickcast")
	elseif spellId == 426893 then
		if self:AntiSpam(3, 4) then
			specWarnGorgingSmash:Show()
			specWarnGorgingSmash:Play("aesoon")
		end
	elseif spellId == 1221190 then
		if self:AntiSpam(3, 6) then
			specWarnGluttonousMiasma:Show()
			specWarnGluttonousMiasma:Play("scatter")
		end
	elseif spellId == 1226111 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "VolatileTarget", 0.1, 4)
	elseif spellId == 1235368 then
		if self:AntiSpam(3, 5) then
			warnArcaneSlash:Show()
		end
	elseif spellId == 1222356 then
		if self:AntiSpam(3.5, 2) then
			specWarnWarp:Show()
			specWarnWarp:Play("farfromline")
		end
	elseif spellId == 1229510 then
		if self:CheckInterruptFilter(args.sourceGUID, nil, true) then
			specWarnArcingZap:Show(args.sourceName)
			specWarnArcingZap:Play("kickcast")
		end
	elseif spellId == 1222815 and self:CheckInterruptFilter(args.sourceGUID, nil, true) then
		specWarnArcaneBolt:Show(args.sourceName)
		specWarnArcaneBolt:Play("kickcast")
	elseif spellId == 1221532 then
		if self:AntiSpam(3, 2) then
			specErraticRitual:Show()
			specErraticRitual:Play("aesoon")
		end
		timerErraticRitualCD:Start(nil, args.sourceGUID)
	elseif spellId == 1226306 then
		if self:AntiSpam(3, 2) then
			specWarnConsumeSpirit:Show()
			specWarnConsumeSpirit:Play("killmob")
		end
		timerConsumeSpiritCD:Start(nil, args.sourceGUID)
	elseif spellId == 1222341 then
		if self:AntiSpam(3, 5) then
			warnGloomBite:Show()
		end
	elseif spellId == 1223007 then
		if self:AntiSpam(3, 2) then
			specWarnBurrowingEruption:Show()
			specWarnBurrowingEruption:Play("watchstep")
		end
		timerBurrowingEruptionCD:Start(nil, args.sourceGUID)
	elseif spellId == 1237195 then
		if self:AntiSpam(3, 2) then
			specWarnBurrowCharge:Show()
			specWarnBurrowCharge:Play("watchstep")
		end
		timerBurrowChargeCD:Start(nil, args.sourceGUID)
	elseif spellId == 1237220 then
		if self:AntiSpam(3, 2) then
			specWarnStingingSandstorm:Show()
			specWarnStingingSandstorm:Play("aesoon")
		end
		timerStingingSandstormCD:Start(nil, args.sourceGUID)
	elseif spellId == 1215850 then
		if self:AntiSpam(3, 2) then
			specWarnEarthCrusher:Show()
			specWarnEarthCrusher:Play("aesoon")
		end
		timerEarthCrusherCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 426893 then
		timerGorgingSmashCD:Start(nil, args.sourceGUID)
	elseif spellId == 1221190 then
		timerGluttonousMiasmaCD:Start(nil, args.sourceGUID)
	elseif spellId == 1226111 then
		timerVolatileEjectionCD:Start(nil, args.sourceGUID)
	elseif spellId == 1235368 then
		timerArcaneSlashCD:Start(nil, args.sourceGUID)
	elseif spellId == 1222356 then
		timerWarpCD:Start(nil, args.sourceGUID)
	elseif spellId == 1221679 then
		if self:AntiSpam(3, 6) then
			warnFarstalkersLeap:Show()
		end
		timerFarstalkersLeapCD:Start(nil, args.sourceGUID)
	elseif spellId == 1229510 then
		timerArcingZapCD:Start(nil, args.sourceGUID)
	elseif spellId == 1223000 then
		timerEmbraceOfKareshCD:Start(nil, args.sourceGUID)
	elseif spellId == 1222341 then
		timerGloomBiteCD:Start(nil, args.sourceGUID)
	elseif spellId == 1221483 then
		timerArcingEnergyCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 1229510 then
		timerArcingZapCD:Start(nil, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 1221133 then
		if self:AntiSpam(3, 3) then
			specWarnHungeringRage:Show(args.destName)
			specWarnHungeringRage:Play("enrage")
		end
	elseif spellId == 1221483 then
		if self.Options.SpecWarn1221483dispel and self:CheckDispelFilter("magic") then
			specWarnArcingEnergyDispel:Show(args.destName)
			specWarnArcingEnergyDispel:Play("dispelnow")
		elseif args:IsPlayer() then
			specWarnArcingEnergy:Show()
			specWarnArcingEnergy:Play("range5")
			yellArcingEnergy:Yell()
		end
	elseif spellId == 1231608 and self:AntiSpam(3, 3) then
		warnAlacrity:Show(args.destName)
	elseif spellId == 1223000 and self:AntiSpam(3, 3) then
		specWarnEmbraceOfKaresh:Show(args.destName)
		specWarnEmbraceOfKaresh:Play("dispelnow")
	elseif spellId == 1239229 and args:IsPlayer() then
		warnKareshiSurge:Show()
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 234883 then--Voracious Gorger
		timerGorgingSmashCD:Stop(args.destGUID)
	elseif cid == 236995 then--Ravenous Destroyer
		timerGluttonousMiasmaCD:Stop(args.destGUID)
		timerVolatileEjectionCD:Stop(args.destGUID)
	elseif cid == 242631 then--Overcharged Sentinel
		timerArcaneSlashCD:Stop(args.destGUID)
	elseif cid == 234960 then--Tamed Ruinstalker
		timerWarpCD:Stop(args.destGUID)
	elseif cid == 234962 then--Wastelander Farstalker
		timerFarstalkersLeapCD:Stop(args.destGUID)
		timerArcingZapCD:Stop(args.destGUID)
	elseif cid == 234957 then--Wastelander Ritualist
		timerArcingEnergyCD:Stop(args.destGUID)
	elseif cid == 234955 then--Wastelander Pactspeaker
		timerErraticRitualCD:Stop(args.destGUID)
		timerConsumeSpiritCD:Stop(args.destGUID)
	elseif cid == 235151 then--K'aresh Elemental
		timerEmbraceOfKareshCD:Stop(args.destGUID)
	elseif cid == 234918 then--Wastes Creeper
		timerGloomBiteCD:Stop(args.destGUID)
		timerBurrowingEruptionCD:Stop(args.destGUID)
	elseif cid == 245092 then--Burrowing Creeper
		timerBurrowChargeCD:Stop(args.destGUID)
		timerStingingSandstormCD:Stop(args.destGUID)
		timerEarthCrusherCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 234883 then--Voracious Gorger
		timerGorgingSmashCD:Start(24-delay, guid)
	elseif cid == 236995 then--Ravenous Destroyer
		timerGluttonousMiasmaCD:Start(7.7-delay, guid)
		timerVolatileEjectionCD:Start(14-delay, guid)--Iffy
--	elseif cid == 242631 then--Overcharged Sentinel
--		timerArcaneSlashCD:Start(8-delay, guid)--UNKNOWN, placeholder
	elseif cid == 234960 then--Tamed Ruinstalker
		timerWarpCD:Start(6-delay, guid)--Iffy
	elseif cid == 234962 then--Wastelander Farstalker
		timerFarstalkersLeapCD:Start(3.8-delay, guid)--3.8-7
		timerArcingZapCD:Start(9.9-delay, guid)
	elseif cid == 234957 then--Wastelander Ritualist
		timerArcingEnergyCD:Start(8.5-delay, guid)
	elseif cid == 234955 then--Wastelander Pactspeaker
		timerErraticRitualCD:Start(8.5-delay, guid)--Iffy
		timerConsumeSpiritCD:Start(25.8-delay, guid)--Iffy
	elseif cid == 235151 then--K'aresh Elemental
		timerEmbraceOfKareshCD:Start(7.1-delay, guid)
	elseif cid == 234918 then--Wastes Creeper
		timerGloomBiteCD:Start(5.3-delay, guid)--Iff
		timerBurrowingEruptionCD:Start(8.8-delay, guid)
	elseif cid == 245092 then--Burrowing Creeper
		timerBurrowChargeCD:Start(5.5-delay, guid)--Iffy
		timerStingingSandstormCD:Start(13.8-delay, guid)--Iffy
		timerEarthCrusherCD:Start(19.9-delay, guid)--Iffy
	end
end

function mod:LeavingZoneCombat()
	self:Stop(true)
end
