if IsTestBuild() or IsBetaBuild() then
	--Test mod for the boss at entrance of motherload on test/beta servers
	local mod	= DBM:NewMod("TestDummyBoss", "DBM-Party-BfA", 7)

	mod:SetEncounterID(3463)
	mod:SetZone(1594)

	mod:RegisterCombat("combat")

	mod:AddCustomAlertSoundOption(1280960, true, 1)
	mod:AddCustomAlertSoundOption(1280958, true, 1)
	mod:AddCustomAlertSoundOption(1280946, true, 2)
	mod:AddCustomTimerOptions(1280960, true, 4, 0)
	mod:AddCustomTimerOptions(1280958, true, 5, 0)
	mod:AddCustomTimerOptions(1280946, true, 3, 1)

	function mod:OnLimitedCombatStart()
		self:EnableTimelineOptions(1280946, 421)
		self:EnableTimelineOptions(1280958, 422)
		self:EnableTimelineOptions(1280960, 423)
		self:EnableAlertOptions(1280946, 421, "kickcast", 2)
		self:EnableAlertOptions(1280958, 422, "kickcast", 2)
		self:EnableAlertOptions(1280960, 423, "watchstep", 2)
	end
end

if DBM:IsPostMidnight() then return end
local mod	= DBM:NewMod("MotherloadTrash", "DBM-Party-BfA", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(1594)
mod:RegisterZoneCombat(1594)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 268865 268797 262092 263202 267354 280604 268702 263215 269302 263628 473168 473304 269429 1214754 1217279",--262554, 263275, 268709 268129 263103 263066 262540 267433
	"SPELL_CAST_SUCCESS 280604 268702 263215 268797 269090 269302 1213893 473168 1214751 1213139 1217279",--262515
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 262092 263215 262377",--262540 262947
	"UNIT_DIED"
)

--TODO, add more spells that are less important from https://docs.google.com/spreadsheets/d/1TnrQeJbxvwhqsy_YEVYOMaTxvFg1QP2nwi4BLhJvkOE/edit?gid=2081207633#gid=2081207633
--[[
(ability.id = 263202) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 263202
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 130661) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 130661)
--]]
local warnActivateMech						= mod:NewSpellAnnounce(1213893, 4, nil, nil, nil, nil, nil, 3)--267433 old
local warnFanOfKnives						= mod:NewCastAnnounce(267354, 4, nil, nil, nil, nil, nil, 3)
local warnChargedShield						= mod:NewCastAnnounce(263628, 3, nil, nil, "Tank|Healer")
local warnRapidExtraction					= mod:NewCastAnnounce(473168, 2)--, nil, nil, nil, nil, nil, 3
local warnChargedShot						= mod:NewCastAnnounce(269429, 2)
local warnBrutalCharge						= mod:NewTargetNoFilterAnnounce(1214751, 2)
local warnOvertime							= mod:NewSpellAnnounce(1213139, 2, nil, "Tank|Healer|RemoveEnrage")
local warnInhaleVapors						= mod:NewTargetNoFilterAnnounce(262092, 2, nil, "Tank|RemoveEnrage")

local specWarnForceCannon					= mod:NewSpecialWarningDodge(268865, nil, nil, nil, 2, 2)
local specWarnArtilleryBarrage				= mod:NewSpecialWarningDodge(269090, nil, nil, nil, 2, 2)
local specWarnBrainstorm					= mod:NewSpecialWarningDodge(473304, nil, nil, nil, 2, 2)
local specWarnMassiveSlam					= mod:NewSpecialWarningDodge(1214754, nil, nil, nil, 2, 2)
local specWarnSeekandDestroy				= mod:NewSpecialWarningRun(262377, nil, nil, nil, 4, 2)
local specWarnUppercut						= mod:NewSpecialWarningYou(1217280, nil, nil, nil, 1, 2)
local yellUppercut							= mod:NewShortYell(1217280)
local specWarnRockLance						= mod:NewSpecialWarningInterrupt(263202, false, nil, nil, 1, 2)--No cooldown, just spell lock. spammed ability
local specWarnIcedSpritzer					= mod:NewSpecialWarningInterrupt(280604, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnFuriousQuake					= mod:NewSpecialWarningInterrupt(268702, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnTectonicBarrier				= mod:NewSpecialWarningInterrupt(263215, false, nil, nil, 1, 2)--Off by default since furious quake is prio interrupt
local specWarnToxicBlades					= mod:NewSpecialWarningInterrupt(269302, "HasInterrupt", nil, nil, 1, 2)
local specWarnTectonicBarrierDispel			= mod:NewSpecialWarningDispel(263215, "MagicDispeller", nil, nil, 1, 2)
local specWarnEnemyToGoo					= mod:NewSpecialWarningInterrupt(268797, "HasInterrupt", nil, nil, 1, 2)--High Prio

local timerFanOfKnivesCD					= mod:NewCDNPTimer(20.6, 267354, nil, nil, nil, 3)
local timerIcedSpritzerCD					= mod:NewCDPNPTimer(24.0, 280604, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerFuriousQuakeCD					= mod:NewCDNPTimer(24.6, 268702, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Small sample, need more data
local timerTectonicBarrierCD				= mod:NewCDNPTimer(20.9, 263215, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--19.3-21.3?
local timerEnemyToGoosCD					= mod:NewCDPNPTimer(24.2, 268797, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerArtilleryBarrageCD				= mod:NewCDNPTimer(12.1, 269090, nil, nil, nil, 3)
local timerInhaleVaporsCD					= mod:NewCDNPTimer(21.9, 262092, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerToxicBladesCD					= mod:NewCDNPTimer(25.6, 269302, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerChargedShieldCD					= mod:NewCDNPTimer(20.9, 263628, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerRapidExtractionCD				= mod:NewCDNPTimer(24.2, 473168, nil, nil, nil, 3)
local timerBrainstormCD						= mod:NewCDNPTimer(17, 473304, nil, nil, nil, 3)--17-18.2
local timerChargedShotCD					= mod:NewCDNPTimer(17, 269429, nil, nil, nil, 3)
local timerBrutalChargeCD					= mod:NewCDNPTimer(12.2, 1214751, nil, nil, nil, 3)--Massive SLam used immediate after, so no need for slam NP timer
local timerOvertimeCD						= mod:NewCDNPTimer(10.4, 1213139, nil, "Tank|Healer|RemoveEnrage", nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerUppercutCD						= mod:NewCDNPTimer(20.3, 1217280, nil, nil, nil, 3)

--Abilities removed in 11.1
--local warnRepair							= mod:NewCastAnnounce(262554, 4)--Removed in 11.1?
--local warnAzeriteHeartseeker				= mod:NewTargetNoFilterAnnounce(262515, 3)

--local specWarnCover						= mod:NewSpecialWarningMove(263275, "Tank", nil, nil, 1, 2)
--local specWarnEarthShield					= mod:NewSpecialWarningInterrupt(268709, "HasInterrupt", nil, nil, 1, 2)
--local specWarnCola						= mod:NewSpecialWarningInterrupt(268129, "HasInterrupt", nil, nil, 1, 2)
--local specWarnBlowtorch					= mod:NewSpecialWarningInterrupt(263103, "HasInterrupt", nil, nil, 1, 2)
--local specWarnTransSyrum					= mod:NewSpecialWarningInterrupt(263066, "HasInterrupt", nil, nil, 1, 2)
--local specWarnOvercharge					= mod:NewSpecialWarningInterrupt(262540, "HasInterrupt", nil, nil, 1, 2)
--local specWarnAzeriteInjection			= mod:NewSpecialWarningDispel(262947, "MagicDispeller", nil, nil, 1, 2)
--local specWarnOverchargeDispel			= mod:NewSpecialWarningDispel(262540, "MagicDispeller", nil, nil, 1, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

local annoyingCasts = {}

function mod:UppercutTarget(targetname)
	if not targetname then return end
	if self:AntiSpam(3, targetname) then
		if targetname == UnitName("player") then
			specWarnUppercut:Show()
			specWarnUppercut:Play("carefly")
			yellUppercut:Yell()
		end
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 268797 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnEnemyToGoo:Show(args.sourceName)
		specWarnEnemyToGoo:Play("kickcast")
	elseif spellId == 262092 then
		timerInhaleVaporsCD:Start(nil, args.sourceGUID)--TODO, move if mob is stunable
	elseif spellId == 263202 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnRockLance:Show(args.sourceName)
		specWarnRockLance:Play("kickcast")
	elseif spellId == 280604 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnIcedSpritzer:Show(args.sourceName)
		specWarnIcedSpritzer:Play("kickcast")
	elseif spellId == 268702 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnFuriousQuake:Show(args.sourceName)
		specWarnFuriousQuake:Play("kickcast")
	elseif spellId == 263215 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnTectonicBarrier:Show(args.sourceName)
		specWarnTectonicBarrier:Play("kickcast")
	elseif spellId == 269302 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnToxicBlades:Show(args.sourceName)
		specWarnToxicBlades:Play("kickcast")
	elseif spellId == 268865 and self:AntiSpam(3, 2) then
		specWarnForceCannon:Show()
		specWarnForceCannon:Play("shockwave")
	elseif spellId == 267354 then
		timerFanOfKnivesCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(4, 5) then
			warnFanOfKnives:Show()
			warnFanOfKnives:Play("crowdcontrol")
		end
	elseif spellId == 473168 then
		if self:AntiSpam(3, 5) then
			warnRapidExtraction:Show()
			--warnRapidExtraction:Play("crowdcontrol")
		end
	elseif spellId == 263628 then
		timerChargedShieldCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnChargedShield:Show()
		end
	elseif spellId == 473304 then
		timerBrainstormCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBrainstorm:Show()
			specWarnBrainstorm:Play("watchstep")
		end
	elseif spellId == 269429 then
		timerChargedShotCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnChargedShot:Show()
		end
	elseif spellId == 1214754 then
		if self:AntiSpam(3, 2) then
			specWarnMassiveSlam:Show()
			specWarnMassiveSlam:Play("watchstep")
		end
	elseif spellId == 1217279 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "UppercutTarget", 0.1, 6)
	--elseif spellId == 267433 and self:AntiSpam(4, 1) then--IsValidWarning removed because it caused most activate mechs not to announce. re-add if it becomes problem
	--	warnActivateMech:Show()
	--elseif spellId == 263275 and self:IsValidWarning(args.sourceGUID) then
	--	specWarnCover:Show()
	--	specWarnCover:Play("moveboss")
	--elseif spellId == 262554 and self:IsValidWarning(args.sourceGUID) and self:AntiSpam(4, 2) then
	--	warnRepair:Show()
	--elseif spellId == 268129 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--	specWarnCola:Show(args.sourceName)
	--	specWarnCola:Play("kickcast")
	--elseif spellId == 268709 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--	specWarnEarthShield:Show(args.sourceName)
	--	specWarnEarthShield:Play("kickcast")
	--elseif spellId == 263103 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--	specWarnBlowtorch:Show(args.sourceName)
	--	specWarnBlowtorch:Play("kickcast")
	--elseif spellId == 263066 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--	specWarnTransSyrum:Show(args.sourceName)
	--	specWarnTransSyrum:Play("kickcast")
	--elseif spellId == 262540 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--	specWarnOvercharge:Show(args.sourceName)
	--	specWarnOvercharge:Play("kickcast")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 280604 then
		if not annoyingCasts[args.sourceGUID] then
			annoyingCasts[args.sourceGUID] = true
			timerIcedSpritzerCD:Start(21.5, args.sourceGUID)
		end
	elseif spellId == 268702 then
		timerFuriousQuakeCD:Start(22.7, args.sourceGUID)
	elseif spellId == 263215 then
		timerTectonicBarrierCD:Start(20.9, args.sourceGUID)
	elseif spellId == 268797 then
		timerEnemyToGoosCD:Start(24.2, args.sourceGUID)
	elseif spellId == 269090 then
		timerArtilleryBarrageCD:Start(12.1, args.sourceGUID)
		if self:AntiSpam(2, 3) then
			specWarnArtilleryBarrage:Show()
			specWarnArtilleryBarrage:Play("watchstep")
		end
	elseif spellId == 269302 then
		timerToxicBladesCD:Start(25.7, args.sourceGUID)
	elseif spellId == 1213893 then
		warnActivateMech:Show()
	elseif spellId == 473168 then
		timerRapidExtractionCD:Start(24.2, args.sourceGUID)
	elseif spellId == 1214751 then
		timerBrutalChargeCD:Start(12.2, args.sourceGUID)
		warnBrutalCharge:Show(args.destName)
	elseif spellId == 1213139 then
		timerOvertimeCD:Start(10.9, args.sourceGUID)
		warnOvertime:Show()
	--elseif spellId == 262515 and self:AntiSpam(2.5, args.destName) then
	--	warnAzeriteHeartseeker:CombinedShow(0.5, args.destName)
	elseif spellId == 1217279 then
		timerUppercutCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 280604 then
		if not annoyingCasts[args.destGUID] then
			annoyingCasts[args.destGUID] = true
			timerIcedSpritzerCD:Start(21.5, args.destGUID)
		end
	elseif args.extraSpellId == 268702 then
		timerFuriousQuakeCD:Start(22.7, args.destGUID)
	elseif args.extraSpellId == 263215 then
		timerTectonicBarrierCD:Start(20.9, args.destGUID)
	elseif args.extraSpellId == 268797 then
		timerEnemyToGoosCD:Start(24.2, args.destGUID)
	elseif args.extraSpellId == 269302 then
		timerToxicBladesCD:Start(25.7, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 262092 and args:IsDestTypeHostile() and self:IsValidWarning(args.destGUID) and self:AntiSpam(3, 3) then
		warnInhaleVapors:Show(args.destName)
	elseif spellId == 263215 and args:IsDestTypeHostile() and self:IsValidWarning(args.destGUID) and self:AntiSpam(3, 3) then
		specWarnTectonicBarrierDispel:Show(args.destName)
		specWarnTectonicBarrierDispel:Play("helpdispel")
	elseif spellId == 262377 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnSeekandDestroy:Show()
		specWarnSeekandDestroy:Play("justrun")
	--elseif spellId == 262947 and args:IsDestTypeHostile() and self:AntiSpam(3, 3) then
	--	specWarnAzeriteInjection:Show(args.destName)
	--	specWarnAzeriteInjection:Play("helpdispel")
	--elseif spellId == 262540 and args:IsDestTypeHostile() and self:AntiSpam(3, 3) then
	--	specWarnOverchargeDispel:Show(args.destName)
	--	specWarnOverchargeDispel:Play("helpdispel")
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 134232 then--Hired Assassin
		timerFanOfKnivesCD:Stop(args.destGUID)
		timerToxicBladesCD:Stop(args.destGUID)
	elseif cid == 136470 then--Refreshment Vendor
		timerIcedSpritzerCD:Stop(args.destGUID)
		annoyingCasts[args.destGUID] = nil
	elseif cid == 130635 then--Stonefury
		timerFuriousQuakeCD:Stop(args.destGUID)
		timerTectonicBarrierCD:Stop(args.destGUID)
	elseif cid == 133432 then--Venture Co. Alchemist
		timerEnemyToGoosCD:Stop(args.destGUID)
	elseif cid == 137029 then--Ordnance Specialist
		timerArtilleryBarrageCD:Stop(args.destGUID)
	elseif cid == 130435 then--Addled Thug
		timerInhaleVaporsCD:Stop(args.destGUID)
		timerUppercutCD:Stop(args.destGUID)
	elseif cid == 136139 then--Mechanized Peacekeeper
		timerChargedShieldCD:Stop(args.destGUID)
	elseif cid == 136643 then--Azerite Extractor
		timerRapidExtractionCD:Stop(args.destGUID)
	elseif cid == 133430 then--Venture Co. Mastermind
		timerBrainstormCD:Stop(args.destGUID)
	elseif cid == 133463 then--Venture Co. War Machine
		timerChargedShotCD:Stop(args.destGUID)
	elseif cid == 134012 then--Taskmaster Askari
		timerBrutalChargeCD:Stop(args.destGUID)
		timerOvertimeCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 134232 then--Hired Assassin
		timerToxicBladesCD:Start(9.6-delay, guid)
		timerFanOfKnivesCD:Start(13.3-delay, guid)
	elseif cid == 136470 then--Refreshment Vendor
		timerIcedSpritzerCD:Start(10.9-delay, guid)
	elseif cid == 130635 then--Stonefury
		timerTectonicBarrierCD:Start(5-delay, guid)
		timerFuriousQuakeCD:Start(11.3-delay, guid)
	elseif cid == 133432 then--Venture Co. Alchemist
		timerEnemyToGoosCD:Start(7.9-delay, guid)--7.9-15
--	elseif cid == 137029 then--Ordnance Specialist
--		timerArtilleryBarrageCD:Start(1.5-delay, guid)--Used pretty much instantly on pull
	elseif cid == 130435 then--Addled Thug
		timerInhaleVaporsCD:Start(9.9-delay, guid)--3.6 (sus, it might have been caused by late detection)
		timerUppercutCD:Start(16.5-delay, guid)--Iffy 9.5, these mobs fire affecting combat before they're actually affecting combat so initial timers can be glitchy
	elseif cid == 136139 then--Mechanized Peacekeeper
		timerChargedShieldCD:Start(16.7-delay, guid)
	elseif cid == 136643 then--Azerite Extractor
		timerRapidExtractionCD:Start(15.7-delay, guid)
	elseif cid == 133430 then--Venture Co. Mastermind
		timerBrainstormCD:Start(5.4-delay, guid)
	elseif cid == 133463 then--Venture Co. War Machine
		timerChargedShotCD:Start(6.9-delay, guid)
	elseif cid == 134012 then--Taskmaster Askari
		timerOvertimeCD:Start(6.9-delay, guid)
		timerBrutalChargeCD:Start(10-delay, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
