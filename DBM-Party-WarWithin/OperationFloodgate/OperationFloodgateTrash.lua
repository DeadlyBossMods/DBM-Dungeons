if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod("OperationFloodgateTrash", "DBM-Party-WarWithin", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2773)
mod:RegisterZoneCombat(2773)

mod:RegisterEvents(
	"SPELL_CAST_START 465754 474337 1216039 465682 462771 469818 1217496 469721 465827 463058 1214468 465666 465408 471733 461796",
	"SPELL_CAST_SUCCESS 462771 463058 1214468 469799 471733 471736",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 462771 463061 469799",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"RAID_BOSS_WHISPER",
	"UNIT_SPELLCAST_INTERRUPTED_UNFILTERED"
)

--TODO, FINISH bubbles timers
--TODO, review ALL timers much closer to live
--TODO, Darkfuse Soldier Black Blood Wound stack counter?
--TODO, EZ-Thro Dynamite III general announce? (Venture Co Surveyor)
--[[
ability.id = 469818 and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 469818
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 231197) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 231197)
--]]
--local warnHorrifyingshrill					= mod:NewCastAnnounce(434802, 4)--High Prio Off interrupt
local warnWarpBlood							= mod:NewSpellAnnounce(465827, 3)
local warnRapidReconstruction				= mod:NewSpellAnnounce(465408, 2)--Cast by Venture Co Architect when construction platform is destoryed
local warnJettisonkelp						= mod:NewSpellAnnounce(471736, 4, nil, nil, nil, nil, nil, 2)

local specWarnZepBarrage					= mod:NewSpecialWarningDodge(1213704, nil, nil, nil, 2, 2)
local specWarnFlamethrower					= mod:NewSpecialWarningDodge(465754, nil, nil, nil, 2, 15)
local specWarnShreddation					= mod:NewSpecialWarningDodge(474337, nil, nil, nil, 2, 2)
local specWarnRPGG							= mod:NewSpecialWarningDodge(1216039, nil, nil, nil, 2, 2)
local specWarnSurpriseInspection			= mod:NewSpecialWarningDodge(465682, nil, nil, nil, 2, 15)
local specWarnBubbleBurp					= mod:NewSpecialWarningDodge(469818, nil, nil, nil, 2, 2)
local specWarnSplishSplash					= mod:NewSpecialWarningDodge(1217496, nil, nil, nil, 2, 15)
local specWarnSparkslam						= mod:NewSpecialWarningDefensive(465666, nil, nil, nil, 1, 2)
local specWarnBackwash						= mod:NewSpecialWarningSpell(469721, nil, nil, nil, 2, 2)
local specWarnSurveyingBeamFailure			= mod:NewSpecialWarningRun(462771, nil, nil, nil, 4, 2)
--local yellChainLightning					= mod:NewYell(387127)
local specWarnOverchargeDispel				= mod:NewSpecialWarningDispel(469799, "RemoveMagic", nil, nil, 1, 2)
local specWarnBloodthirstyCackle			= mod:NewSpecialWarningDispel(463058, "RemoveEnrage", nil, nil, 1, 2)
local specWarnBloodthirstyCackleKick		= mod:NewSpecialWarningInterrupt(463058, "HasInterrupt", nil, nil, 1, 2)
local specWarnSurveyingBeam					= mod:NewSpecialWarningInterrupt(462771, "HasInterrupt", nil, nil, 1, 2)
local specWarnTrickShot						= mod:NewSpecialWarningInterrupt(1214468, "HasInterrupt", nil, nil, 1, 2)
local specWarnRestorativeAlgae				= mod:NewSpecialWarningInterrupt(471733, "HasInterrupt", nil, nil, 1, 2)

local timerFlamethrowerCD					= mod:NewCDNPTimer(25.5, 465754, nil, nil, nil, 3)
local timerShreddationCD					= mod:NewCDNPTimer(9.7, 474337, nil, nil, nil, 3)--9.7-15 (delayed by flamethrower most likely
local timerRPGGCD							= mod:NewCDNPTimer(14.5, 1216039, nil, nil, nil, 3)
local timerSurpriseInspectionCD				= mod:NewCDNPTimer(7.1, 465682, nil, nil, nil, 3)--7.1-9.7
local timerBubbleBurpCD						= mod:NewCDNPTimer(21.5, 469818, nil, nil, nil, 3)
local timerSplishSplashCD					= mod:NewCDNPTimer(21.8, 1217496, nil, nil, nil, 3)
local timerBackwashCD						= mod:NewCDNPTimer(21.8, 469721, nil, nil, nil, 2)
local timerWarpBloodCD						= mod:NewCDNPTimer(20.6, 465827, nil, nil, nil, 2)
local timerSparkslamCD						= mod:NewCDNPTimer(10.9, 465666, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerJettisonkelpCD					= mod:NewCDNPTimer(15.8, 471736, nil, nil, nil, 5)
local timerOverchargeCD						= mod:NewCDNPTimer(9.3, 469799, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--10-15
local timerSurveyingBeamCD					= mod:NewCDNPTimer(20.6, 462771, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBloodthirstyCackleCD				= mod:NewCDNPTimer(18, 463058, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--18-22
local timerTrickShotCD						= mod:NewCDNPTimer(10.9, 1214468, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--10.9-14 (seems to be buggy/random in some cases, inconsistent behaviors)
local timerRestorativeAlgaeCD				= mod:NewCDNPTimer(18.1, 471733, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

local allowInterruptOnBeam = false

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
	if spellId == 465754 then
		timerFlamethrowerCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnFlamethrower:Show()
			specWarnFlamethrower:Play("frontal")
		end
	elseif spellId == 474337 then
		timerShreddationCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnShreddation:Show()
			specWarnShreddation:Play("watchstep")
		end
	elseif spellId == 1216039 then
		if self:AntiSpam(3, 2) then
			specWarnRPGG:Show()
			specWarnRPGG:Play("watchstep")
		end
	elseif spellId == 465682 then
		timerSurpriseInspectionCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnSurpriseInspection:Show()
			specWarnSurpriseInspection:Play("frontal")
		end
	elseif spellId == 462771 then
		allowInterruptOnBeam = true
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSurveyingBeam:Show(args.sourceName)
			specWarnSurveyingBeam:Play("kickcast")
		end
	elseif spellId == 463058 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBloodthirstyCackleKick:Show(args.sourceName)
			specWarnBloodthirstyCackleKick:Play("kickcast")
		end
	elseif spellId == 1214468 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTrickShot:Show(args.sourceName)
			specWarnTrickShot:Play("kickcast")
		end
	elseif spellId == 471733 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRestorativeAlgae:Show(args.sourceName)
			specWarnRestorativeAlgae:Play("kickcast")
		end
	elseif spellId == 469818 then
		timerBubbleBurpCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBubbleBurp:Show()
			specWarnBubbleBurp:Play("watchstep")
		end
	elseif spellId == 1217496 then
		timerSplishSplashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnSplishSplash:Show()
			specWarnSplishSplash:Play("frontal")
		end
	elseif spellId == 469721 then
		timerBackwashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnBackwash:Show()
			specWarnBackwash:Play("aesoon")
		end
	elseif spellId == 465827 then
		timerWarpBloodCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnWarpBlood:Show()
		end
	elseif spellId == 465666 then
		timerSparkslamCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnSparkslam:Show()
			specWarnSparkslam:Play("defensive")
		end
	elseif spellId == 465408 then
		if self:AntiSpam(3, 6) then
			warnRapidReconstruction:Show()
		end
	elseif spellId == 461796 then--Reload (required to fire RPGG)
		timerRPGGCD:Start(9, args.sourceGUID)--Reload cast time + 2
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 462771 then
		allowInterruptOnBeam = false
		timerSurveyingBeamCD:Start(19.1, args.sourceGUID)--20.6-1.5
	elseif spellId == 463058 then
		timerBloodthirstyCackleCD:Start(18.9, args.sourceGUID)
	elseif spellId == 1214468 then
		timerTrickShotCD:Start(7.4, args.sourceGUID)--10.9-3.5
	elseif spellId == 469799 then
		timerOverchargeCD:Start(nil, args.sourceGUID)
	elseif spellId == 471733 then
		timerRestorativeAlgaeCD:Start(16.1, args.sourceGUID)--18.1-2
	elseif spellId == 471736 then
		timerJettisonkelpCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(5, 6) then
			warnJettisonkelp:Show()
		end
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if args.extraSpellId == 462771 and allowInterruptOnBeam then
		timerSurveyingBeamCD:Start(19.1, args.destGUID)--20.6-1.5
	elseif args.extraSpellId == 463058 then
		timerBloodthirstyCackleCD:Start(18.9, args.destGUID)
	elseif args.extraSpellId == 1214468 then
		timerTrickShotCD:Start(7.4, args.destGUID)--10.9-3.5
	elseif args.extraSpellId == 471733 then
		timerRestorativeAlgaeCD:Start(16.1, args.destGUID)--18.1-2
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 462771 then
		if args:IsPlayer() then
			specWarnSurveyingBeamFailure:Show()
			specWarnSurveyingBeamFailure:Play("laserrun")
		end
	elseif spellId == 463061 and self:AntiSpam(3, 5) then
		specWarnBloodthirstyCackle:Show(args.destName)
		specWarnBloodthirstyCackle:Play("enrage")
	elseif spellId == 469799 and self:CheckDispelFilter("magic") then
		specWarnOverchargeDispel:Show(args.destName)
		specWarnOverchargeDispel:Play("helpdispel")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 230740 then--Shredinator 3000
		timerFlamethrowerCD:Stop(args.destGUID)
		timerShreddationCD:Stop(args.destGUID)
	elseif cid == 229212 then--Darkfuse Demolitionist
		timerRPGGCD:Stop(args.destGUID)
	elseif cid == 231385 then--Darkfuse Inspector
		timerSurpriseInspectionCD:Stop(args.destGUID)
	elseif cid == 229686 then--Venture Co. Surveyor
		timerSurveyingBeamCD:Stop(args.destGUID)
	elseif cid == 231197 then--Bubbles
		timerBubbleBurpCD:Stop(args.destGUID)
		timerSplishSplashCD:Stop(args.destGUID)
		timerBackwashCD:Stop(args.destGUID)
	elseif cid == 230748 then--Darkfuse Bloodwarper
		timerWarpBloodCD:Stop(args.destGUID)
	elseif cid == 229252 then--Darkfuse Hyena
		timerBloodthirstyCackleCD:Stop(args.destGUID)
	elseif cid == 229069 then--Mechadrone Sniper
		timerTrickShotCD:Stop(args.destGUID)
	elseif cid == 231325 then--darkfuse jumpstarter
		timerSparkslamCD:Stop(args.destGUID)
	elseif cid == 231312 then--Venture Co. Electrician
		timerOverchargeCD:Stop(args.destGUID)
	elseif cid == 231223 then--Disturbed Kelp
		timerRestorativeAlgaeCD:Stop(args.destGUID)
		timerJettisonkelpCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.1-1 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 230740 then--Shredinator 3000
		timerShreddationCD:Start(3.5-delay, guid)
		timerFlamethrowerCD:Start(7-delay, guid)
	elseif cid == 229212 then--Darkfuse Demolitionist
		timerRPGGCD:Start(2-delay, guid)
	elseif cid == 231385 then--Darkfuse Inspector
		timerSurpriseInspectionCD:Start(6.1-delay, guid)
	elseif cid == 229686 then--Venture Co. Surveyor
		timerSurveyingBeamCD:Start(7-delay, guid)
	elseif cid == 231197 then--Bubbles
		timerBubbleBurpCD:Start(4.3-delay, guid)
		timerSplishSplashCD:Start(9-delay, guid)
		timerBackwashCD:Start(15-delay, guid)
	elseif cid == 230748 then--Darkfuse Bloodwarper
		timerWarpBloodCD:Start(6-delay, guid)
	elseif cid == 229252 then--Darkfuse Hyena
		timerBloodthirstyCackleCD:Start(5-delay, guid)
	elseif cid == 229069 then--Mechadrone Sniper
		timerTrickShotCD:Start(5.5-delay, guid)
	elseif cid == 231325 then--darkfuse jumpstarter
		timerSparkslamCD:Start(6-delay, guid)
	elseif cid == 231312 then--Venture Co. Electrician
		timerOverchargeCD:Start(3.9-delay, guid)
	elseif cid == 231223 then--Disturbed Kelp
		timerJettisonkelpCD:Start(7-delay, guid)
--		timerRestorativeAlgaeCD:Start(13-delay, guid)--Probably health based for first cast
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end

function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("spell:1213704") then
		specWarnZepBarrage:Show()
		specWarnZepBarrage:Play("watchstep")
	end
end

function mod:UNIT_SPELLCAST_INTERRUPTED_UNFILTERED(uId, _, spellId)
	if spellId == 461796 then--Reload
		local guid = UnitGUID(uId)
		timerRPGGCD:Stop(guid)
	end
end
