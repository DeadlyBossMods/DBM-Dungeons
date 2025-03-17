local mod	= DBM:NewMod("TheRookeryTrash", "DBM-Party-WarWithin", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2648)
mod:RegisterZoneCombat(2648)

mod:RegisterEvents(
	"SPELL_CAST_START 426893 450628 427404 427616 430805 430812 474018 427260 474031 1214546 472764",--430754
	"SPELL_CAST_SUCCESS 430805 450628 430179 427260 474031 443854 1214523 1214628",--430754
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 430179 427260 1214523",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--TODO, more spells probably
--[[
(ability.id = 450628) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 450628
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 209801) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 209801)
--]]
--TODO, add Oblivion Wave frontal on tank
--TODO, void shell gone?
local warnInstability						= mod:NewSpellAnnounce(443854, 2)
local warnEntropyShield						= mod:NewCastAnnounce(450628, 3)
local warnEnergizedBarrage 					= mod:NewCastAnnounce(427616, 3, nil, nil, "Tank")--Only warn tank by default since tank should aim it away from anyone else
--local warnVoidShell						= mod:NewCastAnnounce(430754, 3, nil, nil, nil, nil, nil, 3)
local warnAttractingShadows					= mod:NewCastAnnounce(430812, 3, nil, nil, nil, nil, nil, 12)
local warnVoidExtraction					= mod:NewCastAnnounce(472764, 3)

local specWarnLocalizedStorm				= mod:NewSpecialWarningSpell(427404, nil, nil, nil, 2, 2)--Maybe change to Break LOS alert, needs more testing
local specWarnBoundingVoid					= mod:NewSpecialWarningDodge(426893, nil, nil, nil, 2, 2)
--local specWarnThunderstrike					= mod:NewSpecialWarningDodge(430013, nil, nil, nil, 2, 2)
local specWarnWildLightning					= mod:NewSpecialWarningDodge(474018, nil, nil, nil, 2, 15)
local specWarnUmbralWave					= mod:NewSpecialWarningDodge(1214546, nil, nil, nil, 2, 2)
local specWarnUnleashedDarkness				= mod:NewSpecialWarningDodge(1214628, nil, nil, nil, 2, 2)
local specWarnSeepingCorruption				= mod:NewSpecialWarningMoveAway(430179, nil, nil, nil, 1, 2)
local yellSeepingCorruption					= mod:NewShortYell(430179)
local specWarnVoidCrush						= mod:NewSpecialWarningMoveAway(474031, nil, nil, nil, 1, 2)
local yellVoidCrush							= mod:NewShortYell(474031)
local specWarnSeepingCorruptionDispel		= mod:NewSpecialWarningDispel(430179, "RemoveCurse", nil, nil, 1, 2)
local specWarnLightingSurgeDispel			= mod:NewSpecialWarningDispel(427260, "RemoveEnrage", nil, nil, 1, 2)
local specWarnFeastingVoid					= mod:NewSpecialWarningDispel(1214523, "MagicDispeller", nil, nil, 1, 2)
local specWarnLightingSurge					= mod:NewSpecialWarningInterrupt(427260, "HasInterrupt", nil, nil, 1, 2)
local specWarnArcingVoid					= mod:NewSpecialWarningInterrupt(430805, "HasInterrupt", nil, nil, 1, 2)

--Almost all timers probably wrong now, but can't use public WCL to fix this since all logs short
--Also, all of them were moved to success preemtively but if stops actually DO put any of these on CD, then the preemtive move actually broke timer
local timerBoundingVoidCD					= mod:NewCDPNPTimer(18.2, 426893, nil, nil, nil, 3)--S2 Confirmed
local timerEntropyShieldCD					= mod:NewCDNPTimer(27.1, 450628, nil, nil, nil, 5)--S2 Confirmed
local timerLocalizedStormCD					= mod:NewCDNPTimer(23.1, 427404, nil, nil, nil, 2)
local timerWildLightningCD					= mod:NewCDNPTimer(20.6, 474018, nil, nil, nil, 3)
--local timerThunderstrikeCD				= mod:NewCDNPTimer(15.1, 430013, nil, nil, nil, 3)
--local timerEnergizedBarrageCD				= mod:NewCDPNPTimer(5, 427616, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--MUCH lower CD in 11.1
local timerLightningSurgeCD					= mod:NewCDNPTimer(18.3, 427260, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)--17-2 due to waiting for success
--local timerVoidShellCD					= mod:NewCDNPTimer(18.7, 430754, nil, nil, nil, 5)
local timerSeepingCorruptionCD				= mod:NewCDNPTimer(20.3, 430179, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerArcingVoidCD						= mod:NewCDPNPTimer(18.1, 430805, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerAttractingShadowsCD				= mod:NewCDNPTimer(21.9, 430812, nil, nil, nil, 2)--21.9-24.2
local timerVoidCrushCD						= mod:NewCDNPTimer(20.7, 474031, nil, nil, nil, 3)--Can stutter cast
local timerFeastingVoidCD					= mod:NewCDNPTimer(21, 1214523, nil, nil, nil, 5)
local timerUmbralWaveCD						= mod:NewCDNPTimer(23, 1214546, nil, nil, nil, 3)--23-29
local timerVoidExtractionCD					= mod:NewCDNPTimer(18.2, 472764, nil, nil, nil, 3)
local timerUnleashedDarknessCD				= mod:NewCDNPTimer(18.2, 1214628, nil, nil, nil, 3)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:VoidCrushtarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnVoidCrush:Show()
			specWarnVoidCrush:Play("runout")
		end
		yellVoidCrush:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 426893 then
		timerBoundingVoidCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBoundingVoid:Show()
			specWarnBoundingVoid:Play("watchorb")
		end
	elseif spellId == 450628 then
		warnEntropyShield:Show()
	elseif spellId == 427404 then
		timerLocalizedStormCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnLocalizedStorm:Show()
			specWarnLocalizedStorm:Play("aesoon")
		end
	--elseif spellId == 430013 then
	--	if self:AntiSpam(3, 2) then
	--		specWarnThunderstrike:Show()
	--		specWarnThunderstrike:Play("chargemove")
	--	end
	elseif spellId == 427616 then
		if self:AntiSpam(3, 5) then
			warnEnergizedBarrage:Show()
		end
	--elseif spellId == 430754 then
	--	if self:AntiSpam(4, 6) then
	--		warnVoidShell:Show()
	--		warnVoidShell:Play("crowdcontrol")
	--	end
	elseif spellId == 430805 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnArcingVoid:Show(args.sourceName)
			specWarnArcingVoid:Play("kickcast")
		end
	elseif spellId == 427260 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnLightingSurge:Show(args.sourceName)
			specWarnLightingSurge:Play("kickcast")
		end
	elseif spellId == 430812 then
		timerAttractingShadowsCD:Start(nil, args.sourceGUID)
		warnAttractingShadows:Show()
		warnAttractingShadows:Play("pullin")
	elseif spellId == 474018 and args:GetSrcCreatureID() == 212786 then--Trash version
		timerWildLightningCD:Start(20.6, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnWildLightning:Show()
			specWarnWildLightning:Play("frontal")
		end
	elseif spellId == 474031 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "VoidCrushtarget", 0.1, 8)
	elseif spellId == 1214546 then
		timerUmbralWaveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnUmbralWave:Show()
			specWarnUmbralWave:Play("watchorb")
		end
	elseif spellId == 472764 then
		timerVoidExtractionCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnVoidExtraction:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 427260 then--Doesn't go on CD until cast, so using stuns to stop it causes recast
		timerLightningSurgeCD:Start(nil, args.sourceGUID)
	elseif spellId == 430805 then
		timerArcingVoidCD:Start(15.1, args.sourceGUID)
	elseif spellId == 450628 then
		timerEntropyShieldCD:Start(25.2, args.sourceGUID)
	--elseif spellId == 430013 then
	--	timerThunderstrikeCD:Start(15.1, args.sourceGUID)
--	elseif spellId == 427616 then
--		timerEnergizedBarrageCD:Start(5, args.sourceGUID)
	--elseif spellId == 430754 then
	--	timerVoidShellCD:Start(18.7, args.sourceGUID)
	elseif spellId == 430179 then
		timerSeepingCorruptionCD:Start(20.3, args.sourceGUID)
	elseif spellId == 474031 then
		timerVoidCrushCD:Start(18.7, args.sourceGUID)
	elseif spellId == 443854 and self:AntiSpam(4, 6) then
		warnInstability:Show()
	elseif spellId == 1214523 then
		timerFeastingVoidCD:Start(21, args.sourceGUID)
	elseif spellId == 1214628 then
		if self:AntiSpam(4, 2) then
			specWarnUnleashedDarkness:Show()
			specWarnUnleashedDarkness:Play("aesoon")
			specWarnUnleashedDarkness:ScheduleVoice(1.5, "watchstep")
		end
		timerUnleashedDarknessCD:Start(18.2, args.sourceGUID)
		timerUnleashedDarknessCD:Stop(args.sourceGUID)--It's not actually recast, above line is just to trigger debug
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 430805 then
		timerArcingVoidCD:Start(15.1, args.destGUID)
	elseif spellId == 427260 then
		timerLightningSurgeCD:Start(18.3, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 430179 then
		--Always prio dispel over runout, even if on self cause can just dispel self
		if self.Options.SpecWarn430179dispel and self:CheckDispelFilter("curse") then
			specWarnSeepingCorruptionDispel:Show(args.destName)
			specWarnSeepingCorruptionDispel:Play("helpdispel")
			--Still do yell
			if args:IsPlayer() then
				yellSeepingCorruption:Yell()
			end
		elseif args:IsPlayer() then
			specWarnSeepingCorruption:Show()
			specWarnSeepingCorruption:Play("runout")
			yellSeepingCorruption:Yell()
		end
	elseif spellId == 427260 and self:AntiSpam(3, 3) then
		specWarnLightingSurgeDispel:Show(args.destName)
		specWarnLightingSurgeDispel:Play("enrage")
	elseif spellId == 1214523 and self:AntiSpam(3, 3) then
		specWarnFeastingVoid:Show(args.destName)
		specWarnFeastingVoid:Play("dispelnow")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 209801 then--Quartermaster Koratite
		timerBoundingVoidCD:Stop(args.destGUID)
		timerEntropyShieldCD:Stop(args.destGUID)
	elseif cid == 212786 then--Cursed Stormrider
		timerLocalizedStormCD:Stop(args.destGUID)
		timerWildLightningCD:Stop(args.destGUID)
	--elseif cid == 207186 then--Unruly Stormrook
	--	timerThunderstrikeCD:Stop(args.destGUID)
		--timerEnergizedBarrageCD:Stop(args.destGUID)
	elseif cid == 214439 then--Corrupted Oracle
		--timerVoidShellCD:Stop(args.destGUID)
		timerSeepingCorruptionCD:Stop(args.destGUID)
	elseif cid == 214419 then--Corrupted Rookguard
		timerVoidCrushCD:Stop(args.destGUID)
	elseif cid == 207199 then--Cursed Rook Tender
		timerLightningSurgeCD:Stop(args.destGUID)
	elseif cid == 214421 then--Corrupted Thunderer
		timerArcingVoidCD:Stop(args.destGUID)
		timerAttractingShadowsCD:Stop(args.destGUID)
	elseif cid == 212793 then--Void Asscendant
		timerFeastingVoidCD:Stop(args.destGUID)
		timerUmbralWaveCD:Stop(args.destGUID)
	elseif cid == 212739 then--Consuming Voidstone
		timerVoidExtractionCD:Stop(args.destGUID)
		timerUnleashedDarknessCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 209801 then--Quartermaster Koratite
		timerBoundingVoidCD:Start(6-delay, guid)
		timerEntropyShieldCD:Start(9-delay, guid)
	elseif cid == 212786 then--Cursed Stormrider
		timerWildLightningCD:Start(11-delay, guid)
		timerLocalizedStormCD:Start(16.7-delay, guid)
--	elseif cid == 207186 then--Unruly Stormrook
--		timerThunderstrikeCD:Start(0.5-delay, guid)
--		timerEnergizedBarrageCD:Start(0.5-delay, guid)
	elseif cid == 214439 then--Corrupted Oracle
--		timerVoidShellCD:Start(0.5-delay, guid)
		timerSeepingCorruptionCD:Start(16.7-delay, guid)
	elseif cid == 214419 then--Corrupted Rookguard
		timerVoidCrushCD:Start(8.4-delay, guid)
	elseif cid == 207199 then--Cursed Rook Tender
		timerLightningSurgeCD:Start(10-delay, guid)
	elseif cid == 214421 then--Corrupted Thunderer
		timerAttractingShadowsCD:Start(5.6-delay, guid)
		timerArcingVoidCD:Start(8-delay, guid)
	elseif cid == 212793 then--Void Asscendant
		timerFeastingVoidCD:Start(12.1-delay, guid)
		timerUmbralWaveCD:Start(15.5-delay, guid)
	elseif cid == 212739 then--Consuming Voidstone
		timerVoidExtractionCD:Start(14-delay, guid)--100% wrong
		timerUnleashedDarknessCD:Start(29.1-delay, guid)--100% wrong
	end
end

function mod:LeavingZoneCombat()
	self:Stop(true)
end
