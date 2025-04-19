local mod	= DBM:NewMod("TheaterofPainTrash", "DBM-Party-Shadowlands", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2293)
mod:RegisterZoneCombat(2293)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 341902 341969 330614 342139 333861 330562 333294 331237 317605 342135 330716 1215850 331316 331288 332708 333241 330868 342675 341977 330586 334023 333845 333827",
	"SPELL_CAST_SUCCESS 330810 341969 330868 342675 341977 330562 330586 333845",
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
local warnUnbalancingBlow					= mod:NewSpellAnnounce(333845, 4, nil, "Tank|Healer")
local warnSeismicStomp						= mod:NewSpellAnnounce(333827, 3)
local warnRicochetingBlade					= mod:NewTargetNoFilterAnnounce(333861, 4)

--General
local specWarnGTFO							= mod:NewSpecialWarningGTFO(333241, nil, nil, nil, 1, 8)
local specWarnVileEruption					= mod:NewSpecialWarningDodge(330614, nil, nil, nil, 2, 2)
local specWarnDeathWinds					= mod:NewSpecialWarningDodge(333294, nil, nil, nil, 2, 15)
local specWarnBoneSpikes					= mod:NewSpecialWarningDodge(331237, nil, nil, nil, 2, 2)
local specWarnEarthcrusher					= mod:NewSpecialWarningDodge(1215850, nil, nil, nil, 2, 2)
local specWarnGroundSmash					= mod:NewSpecialWarningDodge(332708, nil, nil, nil, 2, 2)
local specWarnWhirlingBlade					= mod:NewSpecialWarningDodge(336996, nil, nil, nil, 2, 2)
local specWarnBloodthirstyCharge			= mod:NewSpecialWarningDodge(334023, nil, nil, nil, 2, 2)
local specWarnRicochetingBlade				= mod:NewSpecialWarningMoveAway(333861, nil, nil, nil, 1, 12)
local specWarnDevourFlesh					= mod:NewSpecialWarningDefensive(330586, nil, nil, nil, 1, 2)
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
local specWarnBoneSpear						= mod:NewSpecialWarningInterrupt(342675, "HasInterrupt", nil, nil, 1, 2)--cast every 3.6 seconds (it's 3.5 second cast, so basically spam cast)
local specWarnMeatShield					= mod:NewSpecialWarningInterrupt(341977, "HasInterrupt", nil, nil, 1, 2)

local timerSoulstormCD						= mod:NewCDNPTimer(26.7, 330716, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerVileEruptionCD					= mod:NewCDNPTimer(15.4, 330614, nil, nil, nil, 3)--15.4-16.2
local timerDeathwindsCD						= mod:NewCDNPTimer(8.4, 333294, nil, nil, nil, 3)
local timerBoneSpikesCD						= mod:NewCDNPTimer(33.6, 331237, nil, nil, nil, 3)
local timerRicochetingBladeCD				= mod:NewCDNPTimer(12.1, 333861, nil, nil, nil, 3)--12.1 for Harugia the Bloodthirsty,
local timerWhirlwindCD						= mod:NewCDNPTimer(26.7, 317605, nil, nil, nil, 3)
local timerSavageFlurryCD					= mod:NewCDNPTimer(13.3, 331316, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEarthcrusherCD					= mod:NewCDNPTimer(13.3, 1215850, nil, nil, nil, 3)
local timerInterruptingRoarCD				= mod:NewCDNPTimer(17.8, 342135, nil, nil, nil, 5)--Can spell queue up to 21.8 due to other abilities
local timerColossalSmashCD					= mod:NewCDNPTimer(9.7, 331288, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--9.7 but can spell queue up to 23 seconds due to other 2 abilities
--local timerGroundSmashCD					= mod:NewCDNPTimer(12.2, 332708, nil, nil, nil, 3)
local timerWhirlingBladeCD					= mod:NewCDNPTimer(12.2, 336996, nil, nil, nil, 3)--12.2-16.6
local timerRagingTantrumCD					= mod:NewCDNPTimer(18.2, 333241, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerWitheringDischargeCD				= mod:NewCDNPTimer(24.1, 341969, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerNecroticBoltVolleyCD				= mod:NewCDNPTimer(22.5, 330868, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerBoneSpearCD						= mod:NewCDNPTimer(23.1, 342675, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--CD deleted in Feb 28th hotfixes
local timerMeatShieldCD						= mod:NewCDNPTimer(20.6, 341977, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--20.6-25
local timerDemoralizingShoutCD				= mod:NewCDNPTimer(17, 330562, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBindSoulCD						= mod:NewCDNPTimer(14.4, 330810, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--14.4-20.6
local timerDevourFleshCD					= mod:NewCDNPTimer(27.4, 330586, nil, nil, nil, 5)
local timerBloodthirstyChargeCD				= mod:NewCDNPTimer(18.2, 334023, nil, nil, nil, 3)
local timerUnbalancingBlowCD				= mod:NewCDNPTimer(8.2, 333845, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSeismicStompCD					= mod:NewCDNPTimer(16.9, 333827, nil, nil, nil, 2)

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
	elseif spellId == 341977 then
		timerMeatShieldCD:Start(nil, args.sourceGUID)--rare exception that triggers on cast start
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMeatShield:Show(args.sourceName)
			specWarnMeatShield:Play("kickcast")
		end
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
		local timer = self:GetCIDFromGUID(args.sourceGUID) == 167538 and 26.7 or 20.6--26.7 for Dokigg the Brutalizer, shorter for others
		timerWhirlwindCD:Start(timer, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnWhirlwind:Show()
			specWarnWhirlwind:Play("justrun")
		end
	elseif spellId == 342135 then
		timerInterruptingRoarCD:Start(nil, args.sourceGUID)--17.8 seconds unless delayed by other spell queuing
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
--		timerGroundSmashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnGroundSmash:Show()
			specWarnGroundSmash:Play("watchstep")
		end
	elseif spellId == 333241 then
		timerRagingTantrumCD:Start(nil, args.sourceGUID)
	elseif spellId == 330586 then
		if self:IsTanking("player", nil, nil, nil, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnDevourFlesh:Show()
			specWarnDevourFlesh:Play("defensive")
		end
	elseif spellId == 334023 then
		timerBloodthirstyChargeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBloodthirstyCharge:Show()
			specWarnBloodthirstyCharge:Play("chargemove")
		end
	elseif spellId == 333845 then
		if self:AntiSpam(3, 5) then
			warnUnbalancingBlow:Show()
		end
	elseif spellId == 333827 then
		timerSeismicStompCD:Start(nil, args.sourceGUID)
		warnSeismicStomp:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end--Filter all casts done by mobs in combat with npcs/other mobs.
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
--	elseif spellId == 342675 then
--		timerBoneSpearCD:Start(23.1, args.sourceGUID)
--	elseif spellId == 341977 then
--		timerMeatShieldCD:Start(20.6, args.sourceGUID)
	elseif spellId == 330562 then
		timerDemoralizingShoutCD:Start(17, args.sourceGUID)
	elseif spellId == 330586 then
		timerDevourFleshCD:Start(24.9, args.sourceGUID)--27.4-2.5
	elseif spellId == 333845 then
		local timer = self:GetCIDFromGUID(args.sourceGUID) == 167534 and 9.2 or 15.3--15.3 for Rek the Hardened, 9.2 for Harugia the Bloodthirsty
		timerUnbalancingBlowCD:Start(timer, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 341969 then
		timerWitheringDischargeCD:Start(24.1, args.destGUID)
	elseif args.extraSpellId == 330868 then
		timerNecroticBoltVolleyCD:Start(22.5, args.destGUID)
--	elseif args.extraSpellId == 342675 then
--		timerBoneSpearCD:Start(23.1, args.destGUID)
--	elseif args.extraSpellId == 341977 then
--		timerMeatShieldCD:Start(20.6, args.destGUID)
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
	--Begin Mini Bosses
	elseif cid == 167536 then--Harugia the Bloodthirsty
		timerRicochetingBladeCD:Stop(args.destGUID)
		timerUnbalancingBlowCD:Stop(args.destGUID)
		timerBloodthirstyChargeCD:Stop(args.destGUID)
	elseif cid == 167533 then--Advent Nevermore
		timerSeismicStompCD:Stop(args.destGUID)
		timerWhirlingBladeCD:Stop(args.destGUID)
		timerColossalSmashCD:Stop(args.destGUID)
	elseif cid == 167538 then--Dokigg the Brutalizer
		timerWhirlwindCD:Stop(args.destGUID)
		timerSavageFlurryCD:Stop(args.destGUID)
		timerEarthcrusherCD:Stop(args.destGUID)
	elseif cid == 167532 then--Heavin the Breaker
		timerWhirlwindCD:Stop(args.destGUID)
		timerInterruptingRoarCD:Stop(args.destGUID)
		timerColossalSmashCD:Stop(args.destGUID)
	elseif cid == 162744 then--Nekthara the Mangler
		timerInterruptingRoarCD:Stop(args.destGUID)
		timerWhirlingBladeCD:Stop(args.destGUID)
		timerColossalSmashCD:Stop(args.destGUID)
	elseif cid == 167534 then--Rek the Hardened
		timerWhirlwindCD:Stop(args.destGUID)
		timerUnbalancingBlowCD:Stop(args.destGUID)
		--Swift Strikes
	--End Minibosses
	elseif cid == 170850 then--Raging Bloodhorn
		timerRagingTantrumCD:Stop(args.destGUID)
	elseif cid == 174210 then--Blighted Sludge-Spewer
		timerWitheringDischargeCD:Stop(args.destGUID)
	elseif cid == 160495 then--Maniacal Soulbinder
		timerNecroticBoltVolleyCD:Stop(args.destGUID)
--	elseif cid == 170882 then--Bone Magus
--		timerBoneSpearCD:Stop(args.destGUID)
	elseif cid == 170690 then--Diseased Horror
		timerMeatShieldCD:Stop(args.destGUID)
	elseif cid == 164506 then--Ancient Captain
		timerDemoralizingShoutCD:Stop(args.destGUID)
	elseif cid == 169875 then--Shackled Soul
		timerBindSoulCD:Stop(args.destGUID)
	elseif cid == 169927 then--Putrid Butcher
		timerDevourFleshCD:Stop(args.destGUID)
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
	--Begin Minibosses
	elseif cid == 167536 then--Harugia the Bloodthirsty
		timerRicochetingBladeCD:Start(2.4-delay, guid)
		timerUnbalancingBlowCD:Start(6-delay, guid)
		timerBloodthirstyChargeCD:Start(9.3-delay, guid)
	elseif cid == 167533 then--Advent Nevermore
		--Initial timers unknown. this mob is usually skipped
		--timerSeismicStompCD:Start(8.2-delay, guid)
		--timerWhirlingBladeCD:Start(38.1-delay, guid)
		--timerColossalSmashCD:Start(38.1-delay, guid)
	elseif cid == 167538 then--Dokigg the Brutalizer
		timerSavageFlurryCD:Start(2.8-delay, guid)--2.8 but wild swing
		timerWhirlwindCD:Start(6.6-delay, guid)
		timerEarthcrusherCD:Start(12.6-delay, guid)
	elseif cid == 167532 then--Heavin the Breaker
		timerInterruptingRoarCD:Start(3.5-delay, guid)
		timerColossalSmashCD:Start(8.4-delay, guid)
		timerWhirlwindCD:Start(12-delay, guid)
	elseif cid == 162744 then--Nekthara the Mangler
		timerWhirlingBladeCD:Start(4-delay, guid)
		timerInterruptingRoarCD:Start(6.8-delay, guid)
		timerColossalSmashCD:Start(12.4-delay, guid)
	elseif cid == 167534 then--Rek the Hardened
		--Swift Strikes (2.4)
		timerWhirlwindCD:Start(6.1-delay, guid)
		timerUnbalancingBlowCD:Start(11-delay, guid)
	--End Minibosses
	elseif cid == 170850 then--Raging Bloodhorn
		timerRagingTantrumCD:Start(8.5-delay, guid)
	elseif cid == 174210 then--Blighted Sludge-Spewer
		timerWitheringDischargeCD:Start(9-delay, guid)
	elseif cid == 160495 then--Maniacal Soulbinder
		timerNecroticBoltVolleyCD:Start(12-delay, guid)
--	elseif cid == 170882 then--Bone Magus
--		timerBoneSpearCD:Start(11-delay, guid)
--	elseif cid == 170690 then--Diseased Horror
--		timerMeatShieldCD:Start(21-delay, guid)--Initial is likely health based
	elseif cid == 164506 then--Ancient Captain
		timerDemoralizingShoutCD:Start(4.6-delay, guid)
	elseif cid == 169875 then--Shackled Soul
		timerBindSoulCD:Start(9.7-delay, guid)
--	elseif cid == 169927 then--Putrid Butcher
--		timerDevourFleshCD:Start(20.1-delay, guid)
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
