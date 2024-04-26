local mod	= DBM:NewMod(2125, "DBM-Party-BfA", 10, 1021)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(135358, 135359, 135360, 131823, 131824, 131825)--All versions so we can pull boss
mod:SetEncounterID(2113)
mod:DisableESCombatDetection()--ES fires For entryway trash pull sometimes, for some reason.
mod:SetUsedIcons(8)
mod:SetBossHPInfoToHighest()
--mod:SetHotfixNoticeRev(20231023000000)
mod:SetMinSyncRevision(20221021000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 260773 260741",
	"SPELL_CAST_SUCCESS 260741 260907 260703 268088",
	"SPELL_AURA_APPLIED 260805 260703 260741 260900",
	"SPELL_AURA_REMOVED 260805 268088"
)

--[[
(ability.id = 260741 or ability.id = 260907 or ability.id = 260703) and (type = "begincast" or type = "cast")
 or ability.id = 260805 and (type = "applybuff" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, outlier timer for killing solena last and actually seeing a second soul manipulation before iris ends
--Sister Briar
mod:AddTimerLine(DBM:EJ_GetSectionInfo(17738))
local specWarnJaggedNettles			= mod:NewSpecialWarningTarget(260741, nil, nil, 2, 1, 2)

local timerJaggedNettlesCD			= mod:NewCDTimer(12.5, 260741, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
--Sister Malady
mod:AddTimerLine(DBM:EJ_GetSectionInfo(17739))
local warnUnstableMark				= mod:NewTargetAnnounce(260703, 2)
local warnAuraofDreadOver			= mod:NewEndAnnounce(268086, 1)

local specWarnUnstableMark			= mod:NewSpecialWarningMoveAway(260703, nil, nil, nil, 1, 2)
local yellUnstableMark				= mod:NewYell(260703)
local specWarnAuraofDread			= mod:NewSpecialWarningKeepMove(268086, nil, nil, nil, 1, 2)

local timerUnstableRunicMarkCD		= mod:NewCDTimer(12.5, 260703, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)

mod:AddRangeFrameOption(6, 260703)
--Sister Solena
mod:AddTimerLine(DBM:EJ_GetSectionInfo(17740))
local specWarnSoulManipulation		= mod:NewSpecialWarningSwitch(260907, nil, nil, nil, 1, 2)

local timerSoulManipulationCD		= mod:NewCDTimer(12.5, 260907, nil, nil, nil, 3, nil, DBM_COMMON_L.TANK_ICON)--Always tank? if not, remove tank icon
--Focusing Iris
mod:AddTimerLine(DBM:GetSpellName(260805))
local warnActiveTriad				= mod:NewTargetNoFilterAnnounce(260805, 2)

local specWarnRitual				= mod:NewSpecialWarningSpell(260773, nil, nil, nil, 3, 2)

local timerRitualCD					= mod:NewCDTimer(12.5, 260773, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)

mod:AddSetIconOption("SetIconOnTriad", 260805, true, 5, {8})
mod:AddInfoFrameOption(260773, false)

local IrisBuff = DBM:GetSpellName(260805)

function mod:NettlesTargetQuestionMark(targetname)
	if not targetname then return end
	if self:AntiSpam(5, targetname) then
		specWarnJaggedNettles:Show(targetname)
		specWarnJaggedNettles:Play("healfull")
	end
end

function mod:OnCombatStart()
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM_CORE_L.INFOFRAME_POWER)
		DBM.InfoFrame:Show(3, "enemypower", 2)
	end
	--Hack so win detection and bosses remaining work with 6 CIDs
	self.vb.bossLeft = 3
	self.numBoss = 3
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 260773 then
		specWarnRitual:Show()
		specWarnRitual:Play("aesoon")
	elseif spellId == 260741 then
		--People say LW warns this faster, but is target scanning actually accurate?
		--My logs showed this spell was not a good candidate for target scanning, but maybe it merits more testing.
		--Below shows that sparty was target at start of cast, Omega was target at the end of cast, but the spell didn't go on EITHER ONE of them
		--"<48.98 23:48:04> [UNIT_SPELLCAST_START] Sister Briar(Sparty) - Jagged Nettles - 2s [[boss3:Cast-3-3882-1862-7607-260741-000A7796F4:260741]]", -- [651]
		--"<51.01 23:48:06> [UNIT_SPELLCAST_SUCCEEDED] Sister Briar(Omegall) -Jagged Nettles- [[boss3:Cast-3-3882-1862-7607-260741-000A7796F4]]", -- [678]
		--"<51.01 23:48:06> [CLEU] SPELL_CAST_SUCCESS#Creature-0-3882-1862-7607-131825-00007795D8#Sister Briar#Player-60-0BA0A53F#Lethorr#260741#Jagged Nettles#nil#nil", -- [681]
		--"<51.02 23:48:06> [CLEU] SPELL_DAMAGE#Creature-0-3882-1862-7607-131825-00007795D8#Sister Briar#Player-60-0BA0A53F#Lethorr#260741#Jagged Nettles", -- [682]
		--I guess if it starts spitting out random wrong targets, i'll hear about it, so here is to a drycode find out! Maybe the boss looks at a 3rd target mid cast that transcritor missed?
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "NettlesTargetQuestionMark", 0.1, 7, true)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 260741 then
		--Prevent timer from starting if Cast start started before transfer of power, but Iris sister changed by time fast finished
		local bossUnitID = self:GetUnitIdFromGUID(args.sourceGUID)
		if bossUnitID and not DBM:UnitBuff(bossUnitID, IrisBuff) and not DBM:UnitDebuff(bossUnitID, IrisBuff) then
			timerJaggedNettlesCD:Start(nil, args.sourceGUID)--12.5, Time until cast START
		end
	--[[elseif spellId == 260907 then
		--Prevent timer from starting if Cast start started before transfer of power, but Iris sister changed by time fast finished
		local bossUnitID = self:GetUnitIdFromGUID(args.sourceGUID)
		if bossUnitID and not DBM:UnitBuff(bossUnitID, IrisBuff) and not DBM:UnitDebuff(bossUnitID, IrisBuff) then
			timerSoulManipulationCD:Start(nil, args.sourceGUID)--Time until cast SUCCESS
		end--]]
	elseif spellId == 260703 then
		--Prevent timer from starting if Cast start started before transfer of power, but Iris sister changed by time fast finished
		local bossUnitID = self:GetUnitIdFromGUID(args.sourceGUID)
		if bossUnitID and not DBM:UnitBuff(bossUnitID, IrisBuff) and not DBM:UnitDebuff(bossUnitID, IrisBuff) then
			timerUnstableRunicMarkCD:Start(nil, args.sourceGUID)--Time until cast SUCCESS
		end
	elseif spellId == 268088 then
		specWarnAuraofDread:Show()
		specWarnAuraofDread:Play("keepmove")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 260805 then--Iris
		warnActiveTriad:Show(args.destName)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 135360 or cid == 131825 then--Sister Briar
			timerJaggedNettlesCD:Start(6.2, args.destGUID)--CAST START (6-9)
		elseif cid == 135358 or cid == 131823 then--Sister Malady
			timerUnstableRunicMarkCD:Start(8.6, args.destGUID)--CAST SUCCESS (8-10)
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(6)
			end
		elseif cid == 135359 or cid == 131824 then--Sister Solena
			timerSoulManipulationCD:Start(8, args.destGUID)--CAST START (8-11)
		end
		if self.Options.SetIconOnTriad then
			self:ScanForMobs(args.destGUID, 2, 8, 1, nil, 6, "SetIconOnTriad", nil, nil, nil, true)
		end
	elseif spellId == 260703 then
		warnUnstableMark:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnUnstableMark:Show()
			specWarnUnstableMark:Play("scatter")
			yellUnstableMark:Yell()
		end
	elseif spellId == 260741 and self:AntiSpam(5, args.destName) then
		specWarnJaggedNettles:Show(args.destName)
		specWarnJaggedNettles:Play("healfull")
	elseif spellId == 260900 then
		if not args:IsPlayer() then
			specWarnSoulManipulation:Show()
			specWarnSoulManipulation:Play("findmc")
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 260805 then--Iris
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 135360 or cid == 131825 then--Sister Briar
			timerJaggedNettlesCD:Stop(args.destGUID)
		elseif cid == 135358 or cid == 131823 then--Sister Malady
			timerUnstableRunicMarkCD:Stop(args.destGUID)
			if self.Options.RangeFrame then
				DBM.RangeCheck:Hide()
			end
		elseif cid == 135359 or cid == 131824 then--Sister Solena
			timerSoulManipulationCD:Stop(args.destGUID)
		end
	elseif spellId == 268088 then
		warnAuraofDreadOver:Show()
	end
end
