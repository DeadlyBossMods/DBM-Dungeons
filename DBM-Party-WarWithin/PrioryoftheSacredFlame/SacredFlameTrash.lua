local mod	= DBM:NewMod("SacredFlameTrash", "DBM-Party-WarWithin", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2649)
mod:RegisterZoneCombat(2649)

mod:RegisterEvents(
	"SPELL_CAST_START 424621 424423 424431 448515 424462 424420 427484 427356 427601 444296 427609 462859 446776 448787 448485 448492 427897 427357 464240 448791 435156 444743 435165",
	"SPELL_CAST_SUCCESS 453458 427484 427342 462859 427356 446776 424420 444728 424429 444743 448787",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 426964 424430 427621 444728 424419",
	"SPELL_AURA_APPLIED_DOSE 426964 424419",
	"SPELL_AURA_REMOVED 428150",
	"UNIT_DIED"
)
--TODO, target scan lunging strike?
--TODO, longer pulls for Trusted Guard timers
--TODO, nameplate timer for https://www.wowhead.com/beta/spell=424421/fireball on Taener Duelmal?
--TODO, Add Holy Smite? It's cast every 6 seconds give or take
--TODO, add https://www.wowhead.com/ptr-2/spell=427950/seal-of-flame ? it has 17 second cd and lats 15 seconds.
--TODO, add https://www.wowhead.com/spell=427596/seal-of-lights-fury ? 12 second cd and 8 second duration, so once again it's mostly active
--TODO, reflective shield upgrade to special warning?
--[[
(ability.id = 444743) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 444743
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 221760) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 221760)

ability.id = 427342 and (type = "removebuff" or type = "cast")
--]]
--All normal Trash
local warnThunderclap						= mod:NewSpellAnnounce(448492, 2)
local warnPotShot							= mod:NewYouAnnounce(462859, 3)
local warnMortalStrike						= mod:NewStackAnnounce(426964, 2, nil, "Tank|Healer")
local warnBurstofLight						= mod:NewCastAnnounce(427601, 4)--SUPER obvious so doesn't need a special warning for now i think
local warnGreaterHeal						= mod:NewCastAnnounce(427356, 3)--High Prio Interrupt
local warnDefend							= mod:NewCastAnnounce(427342, 4, nil, nil, nil, nil, nil, 3)
local warnPounce							= mod:NewCastAnnounce(446776, 3, nil, nil, false, nil, nil, 3)
local warnHeatWave							= mod:NewCastAnnounce(427897, 3)
local warnSacredToll						= mod:NewCastAnnounce(448791, 3)
local warnLightExpulsion					= mod:NewCastAnnounce(435156, 3)--On death spell, no CD
local warnBlazingStrike						= mod:NewCastAnnounce(435165, 3, nil, nil, "Tank|Healer")
local warnImpale							= mod:NewTargetNoFilterAnnounce(444296, 3, nil, "Healer|RemoveBleed")
local warnPurification						= mod:NewTargetNoFilterAnnounce(448787, 4, nil, "Healer")
local warnReflectiveShield					= mod:NewTargetNoFilterAnnounce(464240, 3)

local specWarnDisruptingShout				= mod:NewSpecialWarningCast(427609, "SpellCaster", nil, nil, 1, 2)
local specWarnCaltrops						= mod:NewSpecialWarningDodge(453458, nil, nil, nil, 2, 2)
local specWarnFlamestrike					= mod:NewSpecialWarningDodge(427484, nil, nil, nil, 2, 2)
local specWarnPurification					= mod:NewSpecialWarningYou(448787, nil, nil, nil, 1, 2)
local specWarnShieldSlam					= mod:NewSpecialWarningDefensive(448485, nil, nil, nil, 1, 2)
--local yellChainLightning					= mod:NewYell(387127)
local specWarnGreaterHeal					= mod:NewSpecialWarningInterrupt(427356, nil, nil, nil, 1, 2)
local specWarnHolySmite						= mod:NewSpecialWarningInterrupt(427357, false, nil, 2, 1, 2)--Off by default so as not to interfere with greater heal
local specWarnFireballVolley				= mod:NewSpecialWarningInterrupt(444743, nil, nil, nil, 1, 2)
local specWarnTemplarsWrath					= mod:NewSpecialWarningDispel(444728, "MagicDispeller", nil, nil, 1, 2)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(424430, nil, nil, nil, 1, 8)

local timerCaltropsCD						= mod:NewCDNPTimer(24.2, 453458, nil, nil, nil, 3)--S2 updated
local timerFlamestrikeCD					= mod:NewCDNPTimer(23, 427484, nil, nil, nil, 3)
local timerGreaterHealCD					= mod:NewCDPNPTimer(21.8, 427356, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--S2 Updated (21.8-25.8)
local timerDefendCD							= mod:NewCDNPTimer(30.3, 427342, nil, nil, nil, 5)
local timerImpaleCD							= mod:NewCDNPTimer(17, 444296, nil, nil, nil, 3)--17 unless delayed by disrupting shout
local timerDisruptingShoutCD				= mod:NewCDNPTimer(23, 427609, nil, nil, nil, 2)
local timerPotShotCD						= mod:NewCDNPTimer(12.1, 462859, nil, nil, nil, 3)--8.9
local timerPounceCD							= mod:NewCDNPTimer(17, 446776, nil, nil, nil, 3)
local timerPurificationCD					= mod:NewCDNPTimer(17, 448787, nil, nil, nil, 5)
local timerShieldSlamCD						= mod:NewCDNPTimer(9.7, 448485, nil, nil, nil, 5)--9.7-13.8
local timerThunderclapCD					= mod:NewCDNPTimer(15.8, 448492, nil, nil, nil, 2)
local timerHeatWaveCD						= mod:NewCDNPTimer(18.2, 427897, nil, nil, nil, 2)
local timerReflectiveShieldCD				= mod:NewCDNPTimer(20.7, 464240, nil, nil, nil, 5)
local timerTemplarsWrathCD					= mod:NewCDNPTimer(23.1, 444728, nil, nil, nil, 5)
local timerConsecrationCD					= mod:NewCDNPTimer(23, 424429, nil, nil, nil, 3)
local timerSacredtollCD						= mod:NewCDNPTimer(17.2, 448791, nil, nil, nil, 5)--17.2-25.5
local timerFireballVolleyCD					= mod:NewCDNPTimer(26.7, 444743, nil, nil, nil, 4)
local timerBlazingStrikeCD					= mod:NewCDNPTimer(13.4, 435165, nil, nil, nil, 5)

----Everything below here are the adds from Captain Dailcry. treated as trash since they are pulled as trash, just like Court of Stars
--The Trusted Guard
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27840))
--Sergeant Shaynemail
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27825))
local specWarnBrutalSmash					= mod:NewSpecialWarningDodge(424621, nil, nil, nil, 2, 2)
local specWarnLungingStrike					= mod:NewSpecialWarningMoveAway(424423, nil, nil, nil, 1, 2)

local timerBrutalSmashCD					= mod:NewCDTimer(29.2, 424621, nil, nil, nil, 3)--Using full timer instead of nameplate only so we can cleaner update it
local timerLungingStrikeCD					= mod:NewCDTimer(14.5, 424423, nil, nil, nil, 3)
--Elaena Emberlanz
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27828))
local specWarnHolyRadiance					= mod:NewSpecialWarningSpell(424431, nil, nil, nil, 2, 2)
local specWarnDivineJudgement				= mod:NewSpecialWarningDefensive(448515, nil, nil, nil, 2, 2)

local timerHolyRadianceCD					= mod:NewCDTimer(25.5, 424431, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerDivineJudgementCD				= mod:NewCDTimer(14.6, 448515, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--Taener Duelmal
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27831))
local specWarnEmberStorm					= mod:NewSpecialWarningDodge(424462, nil, nil, nil, 2, 2)
local specWarnCinderblast					= mod:NewSpecialWarningInterrupt(424420, "HasInterrupt", nil, nil, 1, 2)

local timerEmberStormCD						= mod:NewCDTimer(24.3, 424462, nil, nil, nil, 3)--24.3-40
local timerCinderblastCD					= mod:NewCDTimer(15.6, 424420, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Can be MASSIVE delayed by cinderstorm or just rng

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

function mod:Pottarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 6) then
			warnPotShot:Show()
		end
	end
end

function mod:Purtarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnPurification:Show()
		specWarnPurification:Play("targetyou")
	else
		warnPurification:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 424621 then
		timerBrutalSmashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBrutalSmash:Show()
			specWarnBrutalSmash:Play("watchstep")
		end
	elseif spellId == 427356 then
		if self.Options.SpecWarn427356interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGreaterHeal:Show(args.sourceName)
			specWarnGreaterHeal:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnGreaterHeal:Show()
		end
	elseif spellId == 427357 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnHolySmite:Show(args.sourceName)
		specWarnHolySmite:Play("kickcast")
	elseif spellId == 424462 then
		timerEmberStormCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnEmberStorm:Show()
			specWarnEmberStorm:Play("watchstep")
		end
	elseif spellId == 424423 then
		timerLungingStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnLungingStrike:Show()
			specWarnLungingStrike:Play("scatter")
		end
	elseif spellId == 424431 then
		timerHolyRadianceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnHolyRadiance:Show()
			specWarnHolyRadiance:Play("aesoon")
		end
	elseif spellId == 448515 then
		timerDivineJudgementCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnDivineJudgement:Show()
			specWarnDivineJudgement:Play("defensive")
		end
	elseif spellId == 424420 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCinderblast:Show(args.sourceName)
			specWarnCinderblast:Play("kickcast")
		end
	elseif spellId == 427484 then
		if self:AntiSpam(3, 2) then
			specWarnFlamestrike:Show()
			specWarnFlamestrike:Play("watchstep")
		end
	elseif spellId == 427601 then
		if self:AntiSpam(3, 6) then
			warnBurstofLight:Show()
		end
	elseif spellId == 444296 then
		timerImpaleCD:Start(nil, args.sourceGUID)
	elseif spellId == 427609 then
		timerDisruptingShoutCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnDisruptingShout:Show()
			specWarnDisruptingShout:Play("stopcast")
		end
	elseif spellId == 462859 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "Pottarget", 0.1, 8)
	elseif spellId == 446776 then
		if self:AntiSpam(3, 6) then
			warnPounce:Show()
			warnPounce:Play("crowdcontrol")
		end
	elseif spellId == 448787 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "Purtarget", 0.1, 4)
	elseif spellId == 448485 then
		timerShieldSlamCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnShieldSlam:Show()
			specWarnShieldSlam:Play("carefly")
		end
	elseif spellId == 448492 then
		timerThunderclapCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnThunderclap:Show()
		end
	elseif spellId == 427897 then
		timerHeatWaveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnHeatWave:Show()
		end
	elseif spellId == 464240 then
		timerReflectiveShieldCD:Start(nil, args.sourceGUID)--Purely for debug purposes
		timerReflectiveShieldCD:Stop(args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnReflectiveShield:Show(args.sourceName)
		end
	elseif spellId == 448791 then
		timerSacredtollCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnSacredToll:Show()
		end
	elseif spellId == 435156 then
		if self:AntiSpam(3, 4) then
			warnLightExpulsion:Show()
		end
	elseif spellId == 444743 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFireballVolley:Show(args.sourceName)
			specWarnFireballVolley:Play("kickcast")
		end
	elseif spellId == 435165 then
		timerBlazingStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnBlazingStrike:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 453458 then
		timerCaltropsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnCaltrops:Show()
			specWarnCaltrops:Play("watchstep")
		end
	elseif spellId == 427484 then
		timerFlamestrikeCD:Start(18.5, args.sourceGUID)--23-4.5
	elseif spellId == 427342 then
		timerDefendCD:Start(30.3, args.sourceGUID)
		if self:AntiSpam(3.5, 6) then
			warnDefend:Show()
			warnDefend:Play("crowdcontrol")
		end
	elseif spellId == 462859 then
		timerPotShotCD:Start(8.9, args.sourceGUID)--10.9-2
	elseif spellId == 427356 then
		timerGreaterHealCD:Start(21.8, args.sourceGUID)
	elseif spellId == 446776 then
		timerPounceCD:Start(15.5, args.sourceGUID)--17-1.5
	elseif spellId == 424420 then
		timerCinderblastCD:Start(15.6, args.sourceGUID)
	elseif spellId == 444728 then
		timerTemplarsWrathCD:Start(23.1, args.sourceGUID)
	elseif spellId == 424429 then
		timerConsecrationCD:Start(23, args.sourceGUID)
	elseif spellId == 444743 then
		timerFireballVolleyCD:Start(22.4, args.sourceGUID)
	elseif spellId == 448787 then
		timerPurificationCD:Start(15, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 427356 then
		timerGreaterHealCD:Start(21.8, args.destGUID)
	elseif spellId == 424420 then
		timerCinderblastCD:Start(15.6, args.destGUID)
	elseif spellId == 444743 then
		timerFireballVolleyCD:Start(22.4, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 426964 then
		local amount = args.amount or 1
		if self:AntiSpam(3, 5) then
			warnMortalStrike:Show(args.destName, amount)
		end
	elseif spellId == 424430 and args:IsPlayer() and self:AntiSpam(3, 8) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 427621 then
		warnImpale:CombinedShow(0.5, args.destName)
	elseif spellId == 444728 and args:IsDestTypeHostile() and self:AntiSpam(3, 3) then
		specWarnTemplarsWrath:Show(args.destName)
		specWarnTemplarsWrath:Play("dispelboss")
	elseif spellId == 424419 then--Warcry from Captain Dailcry
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 211291 or cid == 239836 then--sergeant-shaynemail (boss/trash)
			timerBrutalSmashCD:RemoveTime(12.5, args.destGUID)
		elseif cid == 211290 or cid == 239833 then--elaena-emberlanz (boss/trash)
			timerDivineJudgementCD:RemoveTime(12.5, args.destGUID)
		elseif cid == 211289 or cid == 239834 then--taener-duelmal (boss/trash)
			timerEmberStormCD:RemoveTime(12.5, args.destGUID)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 428150 then
		timerReflectiveShieldCD:Start(20.7, args.destGUID)
	end
end

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 211291 or cid == 239836 then--sergeant-shaynemail (boss/trash)
		timerBrutalSmashCD:Stop(args.destGUID)
		timerLungingStrikeCD:Stop(args.destGUID)
	elseif cid == 211289 or cid == 239834 then--taener-duelmal (boss/trash)
		timerEmberStormCD:Stop(args.destGUID)
		timerCinderblastCD:Stop(args.destGUID)
	elseif cid == 211290 or cid == 239833 then--elaena-emberlanz (boss/trash)
		timerHolyRadianceCD:Stop(args.destGUID)
		timerDivineJudgementCD:Stop(args.destGUID)
	elseif cid == 206694 then--Fervent Sharpshooter
		timerCaltropsCD:Stop(args.destGUID)
		timerPotShotCD:Stop(args.destGUID)
	elseif cid == 206698 then--Fanatical Mage
		timerFlamestrikeCD:Stop(args.destGUID)
	elseif cid == 206705 then--Arathi Footman
		timerDefendCD:Stop(args.destGUID)
	elseif cid == 206696 then--Arathi Knight
		timerImpaleCD:Stop(args.destGUID)
		timerDisruptingShoutCD:Stop(args.destGUID)
	elseif cid == 206697 then--Devout Priest
		timerGreaterHealCD:Stop(args.destGUID)
	elseif cid == 206699 then--War Lynx
		timerPounceCD:Stop(args.destGUID)
	elseif cid == 206710 then--Lightspawn
		timerPurificationCD:Stop(args.destGUID)
	elseif cid == 212826 then--Guard Captain Suleyman
		timerShieldSlamCD:Stop(args.destGUID)
		timerThunderclapCD:Stop(args.destGUID)
	elseif cid == 212831 then--Forge Master Damian
		timerHeatWaveCD:Stop(args.destGUID)
	elseif cid == 212827 then--High Priest Aemya
		timerReflectiveShieldCD:Stop(args.destGUID)
	elseif cid == 207949 then--Zealous Templar
		timerTemplarsWrathCD:Stop(args.destGUID)
	elseif cid == 206704 then--Ardent Paladin
		timerConsecrationCD:Stop(args.destGUID)
		timerSacredtollCD:Stop(args.destGUID)
	elseif cid == 221760 then--Risen Mage
		timerFireballVolleyCD:Stop(args.destGUID)
	elseif cid == 217658 then--Sir Braunpyke
		timerBlazingStrikeCD:Stop(args.destGUID)
	end
end

--ALL initial timers here will need 1-2 second correction with transcriptor debug
--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay, uID)
	if cid == 211291 then--sergeant-shaynemail (boss)
		timerLungingStrikeCD:Start(20.8-delay, guid)
		timerBrutalSmashCD:Start(41.9, guid)--41.9-49.6???
	elseif cid == 239836 then--sergeant-shaynemail (trash)
--		timerLungingStrikeCD:Start(20.8-delay, guid)
--		timerBrutalSmashCD:Start(41.9, guid)--41.9-49.6???
	elseif cid == 211289 then--taener-duelmal (boss1)
		timerCinderblastCD:Start(8.4-delay, guid)--8.4-11.8
		timerEmberStormCD:Start(24.9, guid)
	elseif cid == 239834 then--taener-duelmal (trash)
		timerCinderblastCD:Start(14-delay, guid)
		timerEmberStormCD:Start(24.9, guid)
	elseif cid == 239833 then--elaena-emberlanz trash
		timerDivineJudgementCD:Start(19-delay, guid)
		timerHolyRadianceCD:Start(38.5, guid)
	elseif cid == 211290 then--elaena-emberlanz Boss
		timerDivineJudgementCD:Start(8.1-delay, guid)
		timerHolyRadianceCD:Start(16.9, guid)--16.9-26.6
	elseif cid == 206694 then--Fervent Sharpshooter
		timerPotShotCD:Start(4.8-delay, guid)
		timerCaltropsCD:Start(12.1-delay, guid)
	elseif cid == 206698 then--Fanatical Conjurer
		timerFlamestrikeCD:Start(10.4-delay, guid)
--	elseif cid == 206705 then--Arathi Footman
--		timerDefendCD:Start(0.5-delay, guid)--Likely has no initial timer, seems quite random. Could be health threshold check
	elseif cid == 206696 then--Arathi Knight
		timerImpaleCD:Start(3.6-delay, guid)
		timerDisruptingShoutCD:Start(19.5-delay, guid)
	--elseif cid == 206697 then--Devout Priest
	--	timerGreaterHealCD:Start(0.5-delay, guid)--Initila has health trigger
	elseif cid == 206699 then--War Lynx
		timerPounceCD:Start(6.4-delay, guid)
	elseif cid == 206710 then--Lightspawn
		timerPurificationCD:Start(6.6-delay, guid)
	elseif cid == 212826 then--Guard Captain Suleyman
		timerShieldSlamCD:Start(3.6-delay, guid)
		timerThunderclapCD:Start(15.8-delay, guid)
	elseif cid == 212831 then--Forge Master Damian
		timerHeatWaveCD:Start(12-delay, guid)
	elseif cid == 212827 then--High Priest Aemya
		timerReflectiveShieldCD:Start(4.6-delay, guid)
	elseif cid == 207949 then--Zealous Templar
		timerTemplarsWrathCD:Start(7.6-delay, guid)
	elseif cid == 206704 then
		timerConsecrationCD:Start(10-delay, guid)
		timerSacredtollCD:Start(15.5-delay, guid)
	elseif cid == 221760 then--Risen Mage
		timerFireballVolleyCD:Start(8.3-delay, guid)
	elseif cid == 217658 then--Sir Braunpyke
		timerBlazingStrikeCD:Start(8.2-delay, guid)
	end
end

function mod:LeavingZoneCombat()
	self:Stop(true)
end
