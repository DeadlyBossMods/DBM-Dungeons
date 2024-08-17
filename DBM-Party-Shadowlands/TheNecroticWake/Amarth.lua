local mod	= DBM:NewMod(2391, "DBM-Party-Shadowlands", 1, 1182)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(163157)--162692?
mod:SetEncounterID(2388)
mod:SetHotfixNoticeRev(20240817000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 320012",
	"SPELL_CAST_START 322493 321247 320170 333488 328667",
	"SPELL_CAST_SUCCESS 321226 320012",
	"SPELL_SUMMON 333627",
	"UNIT_DIED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 321247 or ability.id = 333488) and type = "begincast"
 or (ability.id = 321226 or ability.id = 320012) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (ability.id = 322493 or ability.id = 320170 or ability.id = 328667) and type = "begincast"
--]]
--TODO, analyze more data and use corrective timers that account for shadow school lockout from interupts?
local specWarnLandoftheDead			= mod:NewSpecialWarningSwitchCount(321226, "-Healer", nil, nil, 1, 2)
local specWarnFinalHarvest			= mod:NewSpecialWarningDodgeCount(321247, nil, nil, nil, 2, 2)
local specWarnNecroticBreath		= mod:NewSpecialWarningDodgeCount(333493, nil, nil, nil, 2, 2)
--local yellNecroticBreath			= mod:NewYell(333493)
local specWarnNecroticBolt			= mod:NewSpecialWarningInterrupt(320170, false, nil, 2, 1, 2)--Every 5 seconds, so off by default
local specWarnUnholyFrenzy			= mod:NewSpecialWarningDispel(320012, "RemoveEnrage", nil, nil, 1, 2)
local specWarnUnholyFrenzyTank		= mod:NewSpecialWarningDefensive(320012, nil, nil, nil, 1, 2)
--Reanimated Mage
local specWarnFrostboltVolley		= mod:NewSpecialWarningInterruptCount(322493, "HasInterrupt", nil, nil, 1, 2)--Mythic and above, normal/heroic uses regular frostbolts
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

--All bosses timers are 40 but often spell queued behind other spells. You'll often see them be in median of 40-48.4 range (so 44)
--Even updating timers for spell queuing is not 100% cause the problem is Mostly necrotic bolt (which may even incur spell lockouts and push timers back even more)
local timerLandoftheDeadCD			= mod:NewCDCountTimer(40, 321226, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--40-48.4
local timerFinalHarvestCD			= mod:NewCDCountTimer(40, 321247, nil, nil, nil, 2)--40-48.4
local timerNecroticBreathCD			= mod:NewCDCountTimer(40, 333493, nil, nil, nil, 3)--40-48.4
local timerUnholyFrenzyCD			= mod:NewCDCountTimer(40, 320012, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON..DBM_COMMON_L.TANK_ICON)--40-48.4
local timerFrostboltVolleyCD		= mod:NewCDNPTimer(18.1, 322493, nil, nil, nil, 4, nil, DBM_CORE_L.INTERRUPT_ICON)--40-48.4

mod:AddSetIconOption("SetIconOnAdds", 321226, true, 5, {1, 2, 3, 4, 5, 6, 7, 8})

mod.vb.deadCount = 0
mod.vb.harvestCount = 0
mod.vb.breathCount = 0
mod.vb.frenzyCount = 0
mod.vb.volleyCount = 0
local addUsedMarks = {}
local castsPerGUID = {}

function mod:OnCombatStart(delay)
	self.vb.deadCount = 0
	self.vb.harvestCount = 0
	self.vb.breathCount = 0
	self.vb.frenzyCount = 0
	self.vb.volleyCount = 0
	table.wipe(addUsedMarks)
	table.wipe(castsPerGUID)
	--Even initial timers can variate due to spell lockouts on necrotic bolt, which then in turn can set pacing of spell queuing rest of fight
	--Fortunately mods corrective code should mostly handle it within a ~2.5 second margin of error instead of full 8-9 seconds
	timerUnholyFrenzyCD:Start(6-delay, 1)--SUCCESS
	timerLandoftheDeadCD:Start(8.6-delay, 1)--SUCCESS
	timerNecroticBreathCD:Start(29.3-delay, 1)
	timerFinalHarvestCD:Start(38.6-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 322493 or spellId == 328667 then
		self.vb.volleyCount = self.vb.volleyCount + 1
		if spellId == 328667 then--Adds casting it
			castsPerGUID[args.sourceGUID] = (castsPerGUID[args.sourceGUID] or 0) + 1
			timerFrostboltVolleyCD:Start(18.1, args.sourceGUID)
		end
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFrostboltVolley:Show(args.sourceName, castsPerGUID[args.sourceGUID] or self.vb.volleyCount)
			specWarnFrostboltVolley:Play("kickcast")
		end
	elseif spellId == 320170 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnNecroticBolt:Show(args.sourceName)
		specWarnNecroticBolt:Play("kickcast")
	elseif spellId == 321247 then
		self.vb.harvestCount = self.vb.harvestCount + 1
		specWarnFinalHarvest:Show(self.vb.harvestCount)
		specWarnFinalHarvest:Play("watchstep")
		timerFinalHarvestCD:Start(nil, self.vb.harvestCount+1)
		--if time remaining on unholy is < 10.9, it's extended by this every time
		if timerUnholyFrenzyCD:GetRemaining(self.vb.frenzyCount+1) < 10.9 then
			local elapsed, total = timerUnholyFrenzyCD:GetTime(self.vb.frenzyCount+1)
			local extend = 10.9 - (total-elapsed)
			DBM:Debug("timerUnholyFrenzyCD extended by: "..extend, 2)
			timerUnholyFrenzyCD:Update(elapsed, total+extend, self.vb.frenzyCount+1)
		end
	elseif spellId == 333488 then
		self.vb.breathCount = self.vb.breathCount + 1
		specWarnNecroticBreath:Show(self.vb.breathCount)
		specWarnNecroticBreath:Play("breathsoon")
		timerNecroticBreathCD:Start(nil, self.vb.breathCount+1)
		--if time remaining on final harvest is < 9.2, it's extended by this every time (this one variates more, 9.2 to 11.7 likely to a necrotic bolt spell lockout)
		if timerFinalHarvestCD:GetRemaining(self.vb.harvestCount+1) < 9.2 then
			local elapsed, total = timerFinalHarvestCD:GetTime(self.vb.harvestCount+1)
			local extend = 9.2 - (total-elapsed)
			DBM:Debug("timerFinalHarvestCD extended by: "..extend, 2)
			timerFinalHarvestCD:Update(elapsed, total+extend, self.vb.harvestCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 321226 then
		self.vb.deadCount = self.vb.deadCount + 1
		specWarnLandoftheDead:Show(self.vb.deadCount)
		specWarnLandoftheDead:Play("killmob")
		timerLandoftheDeadCD:Start(nil, self.vb.deadCount+1)
		--if remaining time on necrotic breath is < 17.5, it's extended by this every time (this one variates more, 17.5 to 20.9 likely to a necrotic bolt spell lockout)
		if timerNecroticBreathCD:GetRemaining(self.vb.breathCount+1) < 17.5 then
			local elapsed, total = timerNecroticBreathCD:GetTime(self.vb.breathCount+1)
			local extend = 17.5 - (total-elapsed)
			DBM:Debug("timerNecroticBreathCD extended by: "..extend, 2)
			timerNecroticBreathCD:Update(elapsed, total+extend, self.vb.breathCount+1)
		end
	elseif spellId == 320012 then
		self.vb.frenzyCount = self.vb.frenzyCount + 1
		timerUnholyFrenzyCD:Start(nil, self.vb.frenzyCount+1)
		--if remainig time on land of the dead is < 2.4, it's extended by this every time (this one variates more, 2.4 to 5 likely to a necrotic bolt spell lockout)
		if timerLandoftheDeadCD:GetRemaining(self.vb.deadCount+1) < 2.4 then
			local elapsed, total = timerLandoftheDeadCD:GetTime(self.vb.deadCount+1)
			local extend = 2.4 - (total-elapsed)
			DBM:Debug("timerLandoftheDeadCD extended by: "..extend, 2)
			timerLandoftheDeadCD:Update(elapsed, total+extend, self.vb.deadCount+1)
		end
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 333627 then
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 164414 then--Auto mark mages
			if self.Options.SetIconOnAdds then
				for i = 8, 1, -1 do--8-7 confirmed, rest are just in case
					if not addUsedMarks[i] then
						addUsedMarks[i] = args.destGUID
						self:ScanForMobs(args.destGUID, 2, i, 1, nil, 12, "SetIconOnAdds")
						break
					end
				end
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 320012 then
		if self.Options.SpecWarn320012dispel then
			specWarnUnholyFrenzy:Show(args.destName)
			specWarnUnholyFrenzy:Play("enrage")
		else
			if self:IsTanking("player", nil, nil, true, args.destGUID) then
				specWarnUnholyFrenzyTank:Show()
				specWarnUnholyFrenzyTank:Play("defensive")
			end
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 164414 then
		timerFrostboltVolleyCD:Stop(args.destGUID)
		for i = 8, 1, -1 do
			if addUsedMarks[i] == args.destGUID then
				addUsedMarks[i] = nil
				return
			end
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
