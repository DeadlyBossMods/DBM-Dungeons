local mod	= DBM:NewMod("AraKaraTrash", "DBM-Party-WarWithin", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2660)
mod:RegisterZoneCombat(2660)

mod:RegisterEvents(
	"SPELL_CAST_START 434824 434802 438877 436322 438826 448248 453161 432967 433841 433845 434252 1241693 433002",
	"SPELL_CAST_SUCCESS 434802 434793 438622 448248 433841 433002",
	"SPELL_INTERRUPT",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--[[
ability.id = 434802 and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 434802
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 217531) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 217531)
--]]
local warnHorrifyingshrill					= mod:NewCastAnnounce(434802, 4)--High Prio Off interrupt
local warnRadiantBarrage					= mod:NewSpellAnnounce(434793, 4)--High Prio Off interrupt
local warnVenomVolley						= mod:NewCastAnnounce(433841, 4)--High Prio Off interrupt
local warnAlarmShill						= mod:NewCastAnnounce(432967, 4, nil, nil, nil, nil, nil, 2)
local warnToxicRupture						= mod:NewSpellAnnounce(438622, 4, nil, "Melee")
local warnCalloftheBrood					= mod:NewSpellAnnounce(438877, 3)
local warnPoisonousCloud					= mod:NewSpellAnnounce(438826, 3)

local specWarnMassiveSlam					= mod:NewSpecialWarningSpell(434252, nil, nil, nil, 2, 2)
local specWarnLocusSwarm					= mod:NewSpecialWarningSpell(1241693, nil, nil, nil, 2, 2)
local specWarnWebSpray						= mod:NewSpecialWarningDodge(434824, nil, nil, nil, 2, 15)
local specWarnImpale						= mod:NewSpecialWarningDodge(453161, nil, nil, nil, 2, 15)
local specWarnEruptingWebs					= mod:NewSpecialWarningDodge(433845, nil, nil, nil, 2, 2)
--local yellChainLightning					= mod:NewYell(387127)
local specWarnExtractionStrike				= mod:NewSpecialWarningDefensive(433002, nil, nil, nil, 1, 2)
--local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
local specWarnHorrifyingShrill				= mod:NewSpecialWarningInterrupt(434802, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnRadiantBarrage				= mod:NewSpecialWarningInterrupt(434793, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnPoisonBolt					= mod:NewSpecialWarningInterrupt(436322, "HasInterrupt", nil, nil, 1, 2)--High Prio (no CD timer, it's recast out of spell lockout regardless
local specWarnRevoltingVolley				= mod:NewSpecialWarningInterrupt(448248, "HasInterrupt", nil, nil, 1, 2)
local specWarnVenomVolley					= mod:NewSpecialWarningInterrupt(433841, "HasInterrupt", nil, nil, 1, 2)--High Prio

local timerMassiveSlamCD					= mod:NewCDNPTimer(15.4, 434252, nil, nil, nil, 2)--Removed in 11.2? keeping object for now but not starting on engage
local timerWebSprayCD						= mod:NewCDPNPTimer(7, 434824, nil, nil, nil, 3)--7-8.2 from last cast finish/kick
local timerHorrifyingShrillCD				= mod:NewCDPNPTimer(20.9, 434802, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--13.3-15.5 from last cast finish/kick
local timerRadiantBarrageCD					= mod:NewCDNPTimer(16.8, 434793, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerCalloftheBroodCD					= mod:NewCDNPTimer(21.8, 438877, nil, nil, nil, 1)
local timerPoisonousCloudCD					= mod:NewCDNPTimer(15.3, 438826, nil, nil, nil, 3)--15.3-24.7
local timerRevoltingVolleyCD				= mod:NewCDNPTimer(22.2, 448248, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerImpaleCD							= mod:NewCDPNPTimer(10.9, 453161, nil, nil, nil, 3)
local timerVenomVolleyCD					= mod:NewCDPNPTimer(18.2, 433841, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerEruptingWebsCD					= mod:NewCDNPTimer(18.1, 433845, nil, nil, nil, 3)
local timerLocusSwarmCD						= mod:NewCDNPTimer(30.3, 1241693, nil, nil, nil, 2)
local timerExtractionStrikeCD				= mod:NewCDNPTimer(13.8, 433002, nil, "Tank|Healer", nil, 5)--15.8-2

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
function mod:CLTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnChainLightning:Show()
			specWarnChainLightning:Play("runout")
		end
		yellChainLightning:Yell()
	end
end
--]]

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 434824 then
		timerWebSprayCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnWebSpray:Show()
			specWarnWebSpray:Play("frontal")
		end
	elseif spellId == 434802 then
		if self.Options.SpecWarn434802interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHorrifyingShrill:Show(args.sourceName)
			specWarnHorrifyingShrill:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHorrifyingshrill:Show()
		end
	elseif spellId == 438877 then
		warnCalloftheBrood:Show()
		timerCalloftheBroodCD:Start(nil, args.sourceGUID)--Ok to start here, Nakt can't be interrupted or CCed
	elseif spellId == 436322 then
		--Even though high priorty, no off interrupt announce due to fact it'll be recast every 3-6 (based on spell lockout)
		--We do not want to spam users in this way. By Quazii's SS, it's high prio but only if you can spare an interrupt CD for it.
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPoisonBolt:Show(args.sourceName)
			specWarnPoisonBolt:Play("kickcast")
		end
	elseif spellId == 438826 then
		warnPoisonousCloud:Show()
		timerPoisonousCloudCD:Start(15.3, args.sourceGUID)
	elseif spellId == 448248 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRevoltingVolley:Show(args.sourceName)
			specWarnRevoltingVolley:Play("kickcast")
		end
	elseif spellId == 453161 then
		timerImpaleCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnImpale:Show()
			specWarnImpale:Play("frontal")
		end
	elseif spellId == 432967 and self:AntiSpam(5, 6) then
		warnAlarmShill:Show()
		warnAlarmShill:Play("crowdcontrol")
	elseif spellId == 433841 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnVenomVolley:Show(args.sourceName)
			specWarnVenomVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnVenomVolley:Show()
		end
	elseif spellId == 433845 then
		timerEruptingWebsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnEruptingWebs:Show()
			specWarnEruptingWebs:Play("watchstep")
		end
	elseif spellId == 434252 then
		timerMassiveSlamCD:Start(15.4, args.sourceGUID)
		specWarnMassiveSlam:Show()
		specWarnMassiveSlam:Play("stunsoon")
	elseif spellId == 1241693 then
		timerLocusSwarmCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnLocusSwarm:Show()
			specWarnLocusSwarm:Play("aesoon")
		end
	elseif spellId == 433002 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnExtractionStrike:Show()
			specWarnExtractionStrike:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 434802 then
		timerHorrifyingShrillCD:Start(nil, args.sourceGUID)
	elseif spellId == 434793 then
		if self.Options.SpecWarn434793interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRadiantBarrage:Show(args.sourceName)
			specWarnRadiantBarrage:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnRadiantBarrage:Show()
		end
		timerRadiantBarrageCD:Start(16.8, args.sourceGUID)
	elseif spellId == 438622 and self:AntiSpam(3, 6) then
		warnToxicRupture:Show()
	elseif spellId == 448248 then
		timerRevoltingVolleyCD:Start(nil, args.sourceGUID)
	elseif spellId == 433841 then
		timerVenomVolleyCD:Start(18.2, args.sourceGUID)
	elseif spellId == 433002 then
		timerExtractionStrikeCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if args.extraSpellId == 434802 then
		timerHorrifyingShrillCD:Start(nil, args.destGUID)
	elseif args.extraSpellId == 448248 then
		timerRevoltingVolleyCD:Start(nil, args.destGUID)
	elseif args.extraSpellId == 433841 then
		timerVenomVolleyCD:Start(18.2, args.destGUID)
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 395035 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 217531 then--Ixin
		timerWebSprayCD:Stop(args.destGUID)
		timerHorrifyingShrillCD:Stop(args.destGUID)
	elseif cid == 218324 then--Nakt
		timerWebSprayCD:Stop(args.destGUID)
		timerCalloftheBroodCD:Stop(args.destGUID)
	elseif cid == 217533 then--Atik
		timerWebSprayCD:Stop(args.destGUID)
		timerPoisonousCloudCD:Stop(args.destGUID)
	elseif cid == 216293 then--Trilling Attendant
		timerRadiantBarrageCD:Stop(args.destGUID)
	elseif cid == 223253 then--Bloodstained Webmage
		timerRevoltingVolleyCD:Stop(args.destGUID)
	elseif cid == 216338 then--Hulking Bodyguard
		timerImpaleCD:Stop(args.destGUID)
		timerLocusSwarmCD:Stop(args.destGUID)
	elseif cid == 216364 then--Blood Overseer
		timerVenomVolleyCD:Stop(args.destGUID)
		timerEruptingWebsCD:Stop(args.destGUID)
	elseif cid == 217039 then--Nerubian Hauler
		timerMassiveSlamCD:Stop(args.destGUID)
	elseif cid == 216333 then--Bloodstained Assistant
		timerExtractionStrikeCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 217531 then--Ixin
		timerWebSprayCD:Start(3.3-delay, guid)--3.3-7
		timerHorrifyingShrillCD:Start(12.7-delay, guid)
	elseif cid == 218324 then--Nakt
		timerCalloftheBroodCD:Start(9.7-delay, guid)
		timerWebSprayCD:Start(14.3-delay, guid)
	elseif cid == 217533 then--Atik
		timerWebSprayCD:Start(3.6-delay, guid)--3.6-6
		timerPoisonousCloudCD:Start(7.9-delay, guid)--7.9-14.4
	elseif cid == 216293 then--Trilling Attendant
		timerRadiantBarrageCD:Start(2.1-delay, guid)--2.1-3.8
	elseif cid == 223253 then--Bloodstained Webmage
		timerRevoltingVolleyCD:Start(6.4-delay, guid)
	elseif cid == 216338 then--Hulking Bodyguard
--		timerLocusSwarmCD:Start(5.6-delay, guid)--can be used instantly on pull
		timerImpaleCD:Start(16.4-delay, guid)--Delayed in S3 because of new locus swarm cast
	elseif cid == 216364 then--Blood Overseer
		timerVenomVolleyCD:Start(5.2-delay, guid)--5.2-7.4
		timerEruptingWebsCD:Start(11.3-delay, guid)--11.3-13.9
--	elseif cid == 217039 then--Nerubian Hauler
--		timerMassiveSlamCD:Start(3-delay, guid)--3-4 (removed in 11.2?)
	elseif cid == 216333 then--Bloodstained Assistant
		timerExtractionStrikeCD:Start(3.5-delay, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
