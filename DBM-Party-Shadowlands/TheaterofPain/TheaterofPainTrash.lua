local mod	= DBM:NewMod("TheaterofPainTrash", "DBM-Party-Shadowlands", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2293)
mod:RegisterZoneCombat(2293)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 341902 341969 330614 342139 333861 330562 333294 331237 317605 342135 330716 1215850 331316 331288 332708 333241 330868 342675 341977",
	"SPELL_CAST_SUCCESS 330810 341969 330868 342675 341977 330562",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 341902 333241",
	"UNIT_SPELLCAST_SUCCEEDED_UNFILTERED",
	"UNIT_DIED"
)

--TODO, verify https://shadowlands.wowhead.com/spell=333861/ricocheting-blade target scanning
--NOTE, some of interrupt CDs may be wrong cause they don't properly account for cast time (some do some don't)
--[[
(ability.id = 341902) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 341902
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 174197) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 174197)
--]]
local warnSoulstorm							= mod:NewSpellAnnounce(330716, 2)
local warnSavageFlurry						= mod:NewSpellAnnounce(331316, 3, nil, "Tank|Healer")
local warnColossalSmash						= mod:NewSpellAnnounce(331288, 3, nil, "Tank|Healer")
local warnRicochetingBlade					= mod:NewTargetNoFilterAnnounce(333861, 4)

--General
local specWarnGTFO							= mod:NewSpecialWarningGTFO(333241, nil, nil, nil, 1, 8)
local specWarnVileEruption					= mod:NewSpecialWarningDodge(330614, nil, nil, nil, 2, 2)
local specWarnDeathWinds					= mod:NewSpecialWarningDodge(333294, nil, nil, nil, 2, 15)
local specWarnBoneSpikes					= mod:NewSpecialWarningDodge(331237, nil, nil, nil, 2, 2)
local specWarnEarthcrusher					= mod:NewSpecialWarningDodge(1215850, nil, nil, nil, 2, 2)
local specWarnGroundSmash					= mod:NewSpecialWarningDodge(332708, nil, nil, nil, 2, 2)
local specWarnWhirlingBlade					= mod:NewSpecialWarningDodge(336996, nil, nil, nil, 2, 2)
local specWarnRicochetingBlade				= mod:NewSpecialWarningMoveAway(333861, nil, nil, nil, 1, 12)
local yellRicochetingBlade					= mod:NewYell(333861)
local specWarnWhirlwind						= mod:NewSpecialWarningRun(317605, "Melee", nil, nil, 4, 2)
local specWarnInterruptingRoar				= mod:NewSpecialWarningCast(342135, "SpellCaster", nil, nil, 1, 2)
local specWarnRagingTantrumDispel			= mod:NewSpecialWarningDispel(333241, "RemoveEnrage", nil, nil, 1, 2)
local specWarnUnholyFervorDispel			= mod:NewSpecialWarningDispel(341902, "MagicDispeller", nil, nil, 1, 2)--No Cd timer cause initial cast is health based, recast is unknown
local specWarnUnholyFervor					= mod:NewSpecialWarningInterrupt(341902, "HasInterrupt", nil, nil, 1, 2)--No Cd timer cause initial cast is health based, recast is unknown
local specWarnWitheringDischarge			= mod:NewSpecialWarningInterrupt(341969, "HasInterrupt", nil, nil, 1, 2)
local specWarnBattleTrance					= mod:NewSpecialWarningInterrupt(342139, "HasInterrupt", nil, nil, 1, 2)--Missing timer
local specWarnDemoralizingShout				= mod:NewSpecialWarningInterrupt(330562, "HasInterrupt", nil, nil, 1, 2)
local specWarnBindSoul						= mod:NewSpecialWarningInterrupt(330810, "HasInterrupt", nil, nil, 1, 2)
local specWarnNecroticBoltVolley			= mod:NewSpecialWarningInterrupt(330868, "HasInterrupt", nil, nil, 1, 2)
local specWarnBoneSpear						= mod:NewSpecialWarningInterrupt(342675, "HasInterrupt", nil, nil, 1, 2)
local specWarnMeatShield					= mod:NewSpecialWarningInterrupt(341977, "HasInterrupt", nil, nil, 1, 2)

local timerSoulstormCD						= mod:NewCDNPTimer(26.7, 323043, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerVileEruptionCD					= mod:NewCDNPTimer(15.4, 330614, nil, nil, nil, 3)--15.4-16.2
local timerDeathwindsCD						= mod:NewCDNPTimer(10.9, 333294, nil, nil, nil, 3)
local timerBoneSpikesCD						= mod:NewCDNPTimer(33.6, 331237, nil, nil, nil, 3)
local timerRicochetingBladeCD				= mod:NewCDNPTimer(12.1, 333861, nil, nil, nil, 3)--12.1 for Harugia the Bloodthirsty,
local timerWhirlwindCD						= mod:NewCDNPTimer(26.7, 317605, nil, nil, nil, 3)
local timerSavageFlurryCD					= mod:NewCDNPTimer(13.4, 331316, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEarthcrusherCD					= mod:NewCDNPTimer(13.4, 1215850, nil, nil, nil, 3)
local timerInterruptingRoarCD				= mod:NewCDNPTimer(18.1, 342135, nil, nil, nil, 5)--Can spell queue up to 21.8 due to other abilities
local timerColossalSmashCD					= mod:NewCDNPTimer(9.7, 331288, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--9.7 but can spell queue up to 23 seconds due to other 2 abilities
local timerGroundSmashCD					= mod:NewCDNPTimer(12.2, 332708, nil, nil, nil, 3)
local timerWhirlingBladeCD					= mod:NewCDNPTimer(16.6, 336996, nil, nil, nil, 3)
local timerRagingTantrumCD					= mod:NewCDNPTimer(18.2, 333241, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerWitheringDischargeCD				= mod:NewCDNPTimer(24.1, 341969, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerNecroticBoltVolleyCD				= mod:NewCDNPTimer(22.5, 330868, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBoneSpearCD						= mod:NewCDNPTimer(23.1, 342675, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerMeatShieldCD						= mod:NewCDNPTimer(20.6, 341977, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--20.6-25
local timerDemoralizingShoutCD				= mod:NewCDNPTimer(17, 330562, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBindSoulCD						= mod:NewCDNPTimer(20.6, 330810, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

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
	elseif spellId == 330868 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnNecroticBoltVolley:Show(args.sourceName)
		specWarnNecroticBoltVolley:Play("kickcast")
	elseif spellId == 342675 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBoneSpear:Show(args.sourceName)
		specWarnBoneSpear:Play("kickcast")
	elseif spellId == 341977 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnMeatShield:Show(args.sourceName)
		specWarnMeatShield:Play("kickcast")
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
	elseif spellId == 342135 then
		timerInterruptingRoarCD:Start(nil, args.sourceGUID)--18.1 seconds unless delayed by other spell queuing
		if self:AntiSpam(3, 1) then
			specWarnInterruptingRoar:Show()
			specWarnInterruptingRoar:Play("stopcast")
		end
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
	elseif spellId == 331288 then
		timerColossalSmashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnColossalSmash:Show()
		end
	elseif spellId == 332708 then
		timerGroundSmashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnGroundSmash:Show()
			specWarnGroundSmash:Play("watchstep")
		end
	elseif spellId == 333241 then
		timerRagingTantrumCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 330810  then
		timerBindSoulCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBindSoul:Show(args.sourceName)
			specWarnBindSoul:Play("kickcast")
		end
	elseif spellId == 341969 then
		timerWitheringDischargeCD:Start(24.1, args.sourceGUID)
	elseif spellId == 330868 then
		timerNecroticBoltVolleyCD:Start(22.5, args.sourceGUID)
	elseif spellId == 342675 then
		timerBoneSpearCD:Start(23.1, args.sourceGUID)
	elseif spellId == 341977 then
		timerMeatShieldCD:Start(20.6, args.sourceGUID)
	elseif spellId == 330562 then
		timerDemoralizingShoutCD:Start(17, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 341969 then
		timerWitheringDischargeCD:Start(24.1, args.destGUID)
	elseif args.extraSpellId == 330868 then
		timerNecroticBoltVolleyCD:Start(22.5, args.destGUID)
	elseif args.extraSpellId == 342675 then
		timerBoneSpearCD:Start(23.1, args.destGUID)
	elseif args.extraSpellId == 341977 then
		timerMeatShieldCD:Start(20.6, args.destGUID)
	elseif args.extraSpellId == 330562 then
		timerDemoralizingShoutCD:Start(17, args.destGUID)
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

function mod:UNIT_SPELLCAST_SUCCEEDED_UNFILTERED(uId, _, spellId)
	if spellId == 336995 then
		local guid = UnitGUID(uId)
		if guid and self:IsValidWarning(guid) then
			self:SendSync("BlizzardHatesCombatLog", guid)
		end
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
	elseif cid == 167532 then--Heavin the Breaker
		timerInterruptingRoarCD:Stop(args.destGUID)
		timerColossalSmashCD:Stop(args.destGUID)
		timerGroundSmashCD:Stop(args.destGUID)
	elseif cid == 162744 then--Nekthara the Mangler
		timerInterruptingRoarCD:Stop(args.destGUID)
		timerWhirlwindCD:Stop(args.destGUID)
		timerWhirlingBladeCD:Stop(args.destGUID)
	elseif cid == 170850 then--Raging Bloodhorn
		timerRagingTantrumCD:Stop(args.destGUID)
	elseif cid == 174210 then--Blighted Sludge-Spewer
		timerWitheringDischargeCD:Stop(args.destGUID)
	elseif cid == 160495 then--Maniacal Soulbinder
		timerNecroticBoltVolleyCD:Stop(args.destGUID)
	elseif cid == 170882 then--Bone Magus
		timerBoneSpearCD:Stop(args.destGUID)
	elseif cid == 170690 then--Diseased Horror
		timerMeatShieldCD:Stop(args.destGUID)
	elseif cid == 164506 then--Ancient Captain
		timerDemoralizingShoutCD:Stop(args.destGUID)
	elseif cid == 169875 then--Shackled Soul
		timerBindSoulCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 167998 then--Portal Guardian
		timerSoulstormCD:Start(8.2-delay, guid)
	elseif cid == 163086 then--Rancid Gasbag
		timerVileEruptionCD:Start(6.3-delay, guid)
	elseif cid == 169893 then--Nefarious Darkspeaker
		timerDeathwindsCD:Start(3.6-delay, guid)
	elseif cid == 162763 then--Soulforged Bonereaver
		timerBoneSpikesCD:Start(6.1-delay, guid)--Could be 5.7
	elseif cid == 167536 then--Harugia the Bloodthirsty
		timerRicochetingBladeCD:Start(3.6-delay, guid)
	elseif cid == 167538 then--Dokigg the Brutalizer
		timerWhirlwindCD:Start(6.6-delay, guid)
		timerSavageFlurryCD:Start(38.1-delay, guid)--IFFY, could happen sooner maybe?
		timerEarthcrusherCD:Start(47.8-delay, guid)--IFFY, could happen sooner maybe?
	elseif cid == 167532 then--Heavin the Breaker
		timerInterruptingRoarCD:Start(6-delay, guid)
		timerGroundSmashCD:Start(10.5-delay, guid)
		timerColossalSmashCD:Start(15.5-delay, guid)
	elseif cid == 162744 then--Nekthara the Mangler
		timerWhirlwindCD:Start(4-delay, guid)
		timerWhirlingBladeCD:Start(9-delay, guid)
		timerInterruptingRoarCD:Start(11-delay, guid)
	elseif cid == 170850 then--Raging Bloodhorn
		timerRagingTantrumCD:Start(8.5-delay, guid)
	elseif cid == 174210 then--Blighted Sludge-Spewer
		timerWitheringDischargeCD:Start(13-delay, guid)
	elseif cid == 160495 then--Maniacal Soulbinder
		timerNecroticBoltVolleyCD:Start(12-delay, guid)
	elseif cid == 170882 then--Bone Magus
		timerBoneSpearCD:Start(11-delay, guid)
--	elseif cid == 170690 then--Diseased Horror
--		timerMeatShieldCD:Start(21-delay, guid)--Initial is likely health based
	elseif cid == 164506 then--Ancient Captain
		timerDemoralizingShoutCD:Start(4.6-delay, guid)
	elseif cid == 169875 then--Shackled Soul
		timerBindSoulCD:Start(12.5-delay, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end

function mod:OnSync(msg, guid)
	if msg == "BlizzardHatesCombatLog" then
		specWarnWhirlingBlade:Show()
		specWarnWhirlingBlade:Play("watchstep")
		timerWhirlingBladeCD:Start(nil, guid)
	end
end
