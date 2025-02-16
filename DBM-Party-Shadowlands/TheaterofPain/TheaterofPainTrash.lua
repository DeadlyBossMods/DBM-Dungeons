local mod	= DBM:NewMod("TheaterofPainTrash", "DBM-Party-Shadowlands", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2293)
mod:RegisterZoneCombat(2293)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 341902 341969 330614 342139 333861 330562 333294 331237 333231 317605 342135 330716 1215850 331316",
	"SPELL_CAST_SUCCESS 330810",
	"SPELL_AURA_APPLIED 341902 333241",
	"UNIT_DIED"
)

--TODO, verify https://shadowlands.wowhead.com/spell=333861/ricocheting-blade target scanning
--[[
(ability.id = 331237) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 331237
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 162763) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 162763)
--]]
local warnSoulstorm							= mod:NewSpellAnnounce(330716, 2)
local warnSavageFlurry						= mod:NewSpellAnnounce(331316, 3, nil, "Tank|Healer")
local warnRicochetingBlade					= mod:NewTargetNoFilterAnnounce(333861, 4)

--General
local specWarnGTFO							= mod:NewSpecialWarningGTFO(333241, nil, nil, nil, 1, 8)

local specWarnVileEruption					= mod:NewSpecialWarningDodge(330614, nil, nil, nil, 2, 2)
local specWarnDeathWinds					= mod:NewSpecialWarningDodge(333294, nil, nil, nil, 2, 15)
local specWarnBoneSpikes					= mod:NewSpecialWarningDodge(331237, nil, nil, nil, 2, 2)
local specWarnEarthcrusher					= mod:NewSpecialWarningDodge(1215850, nil, nil, nil, 2, 2)
local specWarnRicochetingBlade				= mod:NewSpecialWarningMoveAway(333861, nil, nil, nil, 1, 12)
local yellRicochetingBlade					= mod:NewYell(333861)
local specWarnWhirlwind						= mod:NewSpecialWarningRun(317605, "Melee", nil, nil, 4, 2)--LEFT OFF HERE
local specWarnInterruptingRoar				= mod:NewSpecialWarningCast(342135, "SpellCaster", nil, nil, 1, 2)--RESUME HERE
local specWarnUnholyFervorDispel			= mod:NewSpecialWarningDispel(341902, "MagicDispeller", nil, nil, 1, 2)
local specWarnRagingTantrumDispel			= mod:NewSpecialWarningDispel(333241, "RemoveEnrage", nil, nil, 1, 2)
local specWarnUnholyFervor					= mod:NewSpecialWarningInterrupt(341902, "HasInterrupt", nil, nil, 1, 2)
local specWarnWitheringDischarge			= mod:NewSpecialWarningInterrupt(341969, "HasInterrupt", nil, nil, 1, 2)
local specWarnBattleTrance					= mod:NewSpecialWarningInterrupt(342139, "HasInterrupt", nil, nil, 1, 2)
local specWarnDemoralizingShout				= mod:NewSpecialWarningInterrupt(330562, "HasInterrupt", nil, nil, 1, 2)
local specWarnBindSoul						= mod:NewSpecialWarningInterrupt(330810, "HasInterrupt", nil, nil, 1, 2)
local specWarnSearingDeath					= mod:NewSpecialWarningInterrupt(333231, "HasInterrupt", nil, nil, 1, 2)

local timerSoulstormCD						= mod:NewCDNPTimer(26.7, 323043, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerVileEruptionCD					= mod:NewCDNPTimer(15.4, 330614, nil, nil, nil, 3)--15.4-16.2
local timerDeathwindsCD						= mod:NewCDNPTimer(10.9, 333294, nil, nil, nil, 3)
local timerBoneSpikesCD						= mod:NewCDNPTimer(33.6, 331237, nil, nil, nil, 3)
local timerRicochetingBladeCD				= mod:NewCDNPTimer(12.1, 333861, nil, nil, nil, 3)--12.1 for Harugia the Bloodthirsty,
local timerWhirlwindCD						= mod:NewCDNPTimer(26.7, 317605, nil, nil, nil, 3)
local timerSavageFlurryCD					= mod:NewCDNPTimer(13.4, 331316, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEarthcrusherCD					= mod:NewCDNPTimer(13.4, 1215850, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

function mod:RicochetingTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnRicochetingBlade:Show()
		specWarnRicochetingBlade:Play("breaklos")
		yellRicochetingBlade:Yell()
	else
		warnRicochetingBlade:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end--Filter all casts done by mobs in combat with npcs/other mobs.
	local spellId = args.spellId
	if spellId == 341902 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnUnholyFervor:Show(args.sourceName)
		specWarnUnholyFervor:Play("kickcast")
	elseif spellId == 341969 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnWitheringDischarge:Show(args.sourceName)
		specWarnWitheringDischarge:Play("kickcast")
	elseif spellId == 342139 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBattleTrance:Show(args.sourceName)
		specWarnBattleTrance:Play("kickcast")
	elseif spellId == 330562 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDemoralizingShout:Show(args.sourceName)
		specWarnDemoralizingShout:Play("kickcast")
	elseif spellId == 333231 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSearingDeath:Show(args.sourceName)
		specWarnSearingDeath:Play("kickcast")
	elseif spellId == 330614 then
		timerVileEruptionCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnVileEruption:Show()
			specWarnVileEruption:Play("watchstep")
		end
	elseif spellId == 333294 then
		timerDeathwindsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDeathWinds:Show()
			specWarnDeathWinds:Play("frontal")
		end
	elseif spellId == 331237 then
		timerBoneSpikesCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBoneSpikes:Show()
			specWarnBoneSpikes:Play("watchstep")
		end
	elseif spellId == 317605 then
		timerWhirlwindCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnWhirlwind:Show()
			specWarnWhirlwind:Play("justrun")
		end
	elseif spellId == 342135 and self:AntiSpam(3, 1) then
		specWarnInterruptingRoar:Show()
		specWarnInterruptingRoar:Play("stopcast")
	elseif spellId == 333861 then
		local cid = self:GetCIDFromGUID(args.sourceGUID)
		local timer = cid == 167536 and 12.1 or 15.8
		timerRicochetingBladeCD:Start(timer, args.sourceGUID)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "RicochetingTarget", 0.1, 4)
	elseif spellId == 330716 then
		warnSoulstorm:Show()
		timerSoulstormCD:Start(nil, args.sourceGUID)
	elseif spellId == 1215850 then
		timerEarthcrusherCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnEarthcrusher:Show()
			specWarnEarthcrusher:Play("watchstep")
		end
	elseif spellId == 331316 then
		timerSavageFlurryCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnSavageFlurry:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 330810 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBindSoul:Show(args.sourceName)
		specWarnBindSoul:Play("kickcast")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 341902 and self:AntiSpam(3, 5) then
		specWarnUnholyFervorDispel:Show(args.destName)
		specWarnUnholyFervorDispel:Play("helpdispel")
	elseif spellId == 333241 and self:AntiSpam(3, 5) then
		specWarnRagingTantrumDispel:Show(args.destName)
		specWarnRagingTantrumDispel:Play("enrage")
	elseif spellId == 333241 and args:IsPlayer() and self:AntiSpam(3, 7) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 167998 then--Portal Guardian
		timerSoulstormCD:Stop(args.destGUID)
	elseif cid == 163086 then--Rancid Gasbag
		timerVileEruptionCD:Stop(args.destGUID)
	elseif cid == 169893 then--Nefarious Darkspeaker
		timerDeathwindsCD:Stop(args.destGUID)
	elseif cid == 162763 then--Soulforged Bonereaver
		timerBoneSpikesCD:Stop(args.destGUID)
	elseif cid == 167536 then--Harugia the Bloodthirsty
		timerRicochetingBladeCD:Stop(args.destGUID)
	elseif cid == 167533 then--Advent Nevermore
		timerRicochetingBladeCD:Stop(args.destGUID)
	elseif cid == 167538 then--Dokigg the Brutalizer
		timerWhirlwindCD:Stop(args.destGUID)
		timerSavageFlurryCD:Stop(args.destGUID)
		timerEarthcrusherCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 167998 then--Portal Guardian
		timerSoulstormCD:Start(8.2, guid)
	elseif cid == 163086 then--Rancid Gasbag
		timerVileEruptionCD:Start(6.3, guid)
	elseif cid == 169893 then--Nefarious Darkspeaker
		timerDeathwindsCD:Start(3.6, guid)
	elseif cid == 162763 then--Soulforged Bonereaver
		timerBoneSpikesCD:Start(6.1, guid)--Could be 5.7
	elseif cid == 167536 then--Harugia the Bloodthirsty
		timerRicochetingBladeCD:Start(3.6, guid)
	elseif cid == 167538 then--Dokigg the Brutalizer
		timerWhirlwindCD:Start(6.6, guid)
		timerSavageFlurryCD:Start(38.1, guid)--IFFY, could happen sooner maybe?
		timerEarthcrusherCD:Start(47.8, guid)--IFFY, could happen sooner maybe?
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
