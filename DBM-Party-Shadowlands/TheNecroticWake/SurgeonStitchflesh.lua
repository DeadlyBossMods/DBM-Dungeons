local mod	= DBM:NewMod(2392, "DBM-Party-Shadowlands", 1, 1182)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(162689)
mod:SetEncounterID(2389)
mod:SetHotfixNoticeRev(20240817000000)
--mod:SetMinSyncRevision(20211203000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 320358 320376 327664 334488 343556",
	"SPELL_CAST_SUCCESS 320359 322681 320376 334488",
	"SPELL_AURA_APPLIED 320200 322681 322548 334321 343556",
	"SPELL_AURA_REMOVED 322681",
	"SPELL_PERIODIC_DAMAGE 320366",
	"SPELL_PERIODIC_MISSED 320366",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, need longer pulls where boss is NOT hooked for a while to see if he goes through cast sequences of spawning more adds or more Ichor
--[[
(ability.id = 320358 or ability.id = 327664 or ability.id = 334488 or ability.id = 343556) and type = "begincast"
 or (ability.id = 320359 or ability.id = 326574 or ability.id = 322681) and type = "cast"
 or ability.id = 327041 or ability.id = 322548
 or ability.id = 320376 and type = "begincast"
 or ability.id = 334321 and type = "applybuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnSummonCreation			= mod:NewCountAnnounce(320358, 2)
local warnMutilate					= mod:NewCastAnnounce(320376, 4, nil, nil, "Tank|Healer")--Spammy if lots of adds up, which is why not special warning
local warnSeverFlesh				= mod:NewCountAnnounce(334488, 3, nil, "Tank|Healer")
local warnEscape					= mod:NewCastAnnounce(320359, 3)
local warnEmbalmingIchor			= mod:NewTargetNoFilterAnnounce(327664, 3)
local warnMeatHook					= mod:NewTargetNoFilterAnnounce(322681, 3)
local warnStichNeedle				= mod:NewTargetNoFilterAnnounce(320200, 3, nil, false, 2)--Kind of spammy
local warnMorbidFixation			= mod:NewTargetAnnounce(343556, 3)

local specWarnEmbalmingIchor		= mod:NewSpecialWarningMoveAway(327664, nil, nil, nil, 1, 2)
local yellEmbalmingIchor			= mod:NewShortYell(327664)
local specWarnMeatHook				= mod:NewSpecialWarningMoveTo(322681, nil, nil, nil, 3, 2)
local yellMeatHook					= mod:NewShortYell(322681)
local yellMeatHookFades				= mod:NewShortFadesYell(322681)
local specWarnMorbidFixation		= mod:NewSpecialWarningDodge(343556, nil, nil, nil, 2, 2)
local yellMorbidFixation			= mod:NewShortYell(343556)
--local specWarnHealingBalm			= mod:NewSpecialWarningInterrupt(257397, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(320366, nil, nil, nil, 1, 8)

local timerSummonCreationCD			= mod:NewCDCountTimer(35.1, 320358, nil, nil, nil, 1)
local timerEmbalmingIchorCD			= mod:NewCDCountTimer(18, 327664, nil, nil, nil, 3)
local timerMorbidFixationCD			= mod:NewCDCountTimer(15.9, 343556, nil, nil, nil, 3)
local timerSeverFleshCD				= mod:NewCDCountTimer(8.7, 334488, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEscape					= mod:NewCastTimer(30, 320359, nil, nil, nil, 6)
--Add
local timerMutilateCD				= mod:NewCDNPTimer(11, 320376, nil, "Tank|Healer", nil, 5)
local timerMeatHookCD				= mod:NewCDTimer(18.2, 322681, nil, nil, nil, 3)
--local timerStichNeedleCD			= mod:NewCDTimer(15.8, 320200, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)--Basically spammed

mod.vb.bossDown = false
mod.vb.creationCount = 0
mod.vb.ichorCount = 0
mod.vb.severCount = 0

function mod:IchorTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnEmbalmingIchor:Show()
		specWarnEmbalmingIchor:Play("runout")
		yellEmbalmingIchor:Yell()
	else
		warnEmbalmingIchor:Show(targetname)
	end
end

function mod:MorbidFixation(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(5, 1) then
			specWarnMorbidFixation:Show()
			specWarnMorbidFixation:Play("targetyou")
			yellMorbidFixation:Yell()
		end
	else
		warnMorbidFixation:Show(targetname)
	end
end

---@param self DBMMod
local function findCreation(self, delay)
	for i = 1, 2 do
		local id = self:GetUnitCreatureId("boss"..i)
		if id == 164578 then--Creation
			local guid = UnitGUID("boss"..i)
			timerMutilateCD:Start(6-delay, guid)
			timerMeatHookCD:Start(9.6-delay, guid)
			break
		end
	end
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.bossDown = false
	self.vb.creationCount = 1--One already exists on pull
	self.vb.ichorCount = 0
	self.vb.severCount = 0
--	timerSummonCreationCD:Start(1-delay, 2)--START (unknown, nobody in public logs is this bad)
	timerEmbalmingIchorCD:Start(9.4-delay)
--	timerStichNeedleCD:Start(1-delay)--SUCCESS
	--Makes ure IEEU has fired before scanning for creations GUID
	self:Schedule(1, findCreation, self, delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 320358 then
		self.vb.creationCount = self.vb.creationCount + 1
		warnSummonCreation:Show(self.vb.creationCount)
		timerSummonCreationCD:Start(nil, self.vb.creationCount+1)
	elseif spellId == 320376 then
		warnMutilate:Show()
	elseif spellId == 327664 then
		self.vb.ichorCount = self.vb.ichorCount + 1
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "IchorTarget", 0.1, 6)
		timerEmbalmingIchorCD:Start(nil, self.vb.ichorCount+1)
	elseif spellId == 334488 then
		warnSeverFlesh:Show(self.vb.severCount+1)
	elseif spellId == 343556 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "MorbidFixation", 0.1, 6)
		--timerMorbidFixationCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 320359 then
		self:SetStage(1)
		warnEscape:Show()
		timerEscape:Stop()--Escaped early?
		timerSeverFleshCD:Stop()
		timerEmbalmingIchorCD:Start(10.9, self.vb.ichorCount+1)--8-11
	elseif spellId == 322681 then
		timerMeatHookCD:Start(15, args.sourceGUID)
	elseif spellId == 320376 then--Doesn't go on CD unless cast finishes
		timerMutilateCD:Start(10, args.sourceGUID)
	elseif spellId == 334488 then
		self.vb.severCount = self.vb.severCount + 1
		timerSeverFleshCD:Start(nil, self.vb.severCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 320200 then
		warnStichNeedle:CombinedShow(0.3, args.destName)
	elseif spellId == 322681 then
		if args:IsPlayer() then
			specWarnMeatHook:Show(DBM_COMMON_L.BOSS)
			specWarnMeatHook:Play("targetyou")
			yellMeatHook:Yell()
			yellMeatHookFades:Countdown(spellId)
		else
			warnMeatHook:Show(args.destName)
		end
	elseif spellId == 343556 then
		if args:IsPlayer() and self:AntiSpam(5, 1) then--Backup if target scan fails
			specWarnMorbidFixation:Show()
			specWarnMorbidFixation:Play("targetyou")
			yellMorbidFixation:Yell()
		end
	elseif spellId == 322548 and not self:GetStage(2) then--Boss getting meat hooked
		self:SetStage(2)
		timerSummonCreationCD:Stop()
		timerEmbalmingIchorCD:Stop()
		timerMorbidFixationCD:Stop()
		warnMeatHook:Show(args.destName)
		timerSeverFleshCD:Start(6, self.vb.severCount+1)
		timerMorbidFixationCD:Start(14.9)
		timerEscape:Start(30)
		timerSummonCreationCD:Start(31, self.vb.creationCount+1)--Give or take 1-2~
	elseif spellId == 334321 then--Festering Rot
		timerMutilateCD:Start(7.4, args.destGUID)
		timerMeatHookCD:Start(11.4, args.destGUID)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 322681 then
		if args:IsPlayer() then
			yellMeatHookFades:Cancel()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 320366 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 164578 then--Creation
		timerMeatHookCD:Stop(args.destGUID)
		timerMutilateCD:Stop(args.destGUID)
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
