local mod	= DBM:NewMod(2391, "DBM-Party-Shadowlands", 1, 1182)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(163157)--162692?
mod:SetEncounterID(2388)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 320012",
	"SPELL_CAST_START 322493 321247 320170 333488",
	"SPELL_CAST_SUCCESS 321226 320012",
	"SPELL_SUMMON 333627",
	"UNIT_DIED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, which interrupt is priority?
--[[
(ability.id = 321247 or ability.id = 333488) and type = "begincast"
 or (ability.id = 321226 or ability.id = 320012) and type = "cast"
 or (ability.id = 322493 or ability.id = 320170) and type = "begincast"
--]]
--TODO, analyze more data and use corrective timers that account for shadow school lockout from interupts
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

--All bosses timers are 41.2-48.4 but often spell queued behind other spells. You'll often see them be in median of that range (so 45)
--Even updating timers for spell queuing is iffy cause the problem is Mostly necrotic bolt (which may even incur spell lockouts and push timers back even more)
local timerLandoftheDeadCD			= mod:NewCDCountTimer(41.2, 321226, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--41.2-48.4
local timerFinalHarvestCD			= mod:NewCDCountTimer(41.2, 321247, nil, nil, nil, 2)--41.2-48.4
local timerNecroticBreathCD			= mod:NewCDCountTimer(41.2, 333493, nil, nil, nil, 3)--41.2-48.4
local timerUnholyFrenzyCD			= mod:NewCDCountTimer(41.2, 320012, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON..DBM_COMMON_L.TANK_ICON)--41.2-48.4

mod:AddSetIconOption("SetIconOnAdds", 321226, true, 5, {1, 2, 3, 4, 5, 6, 7, 8})

mod.vb.deadCount = 0
mod.vb.harvestCount = 0
mod.vb.breathCount = 0
mod.vb.frenzyCount = 0
mod.vb.volleyCount = 0
local addUsedMarks = {}

function mod:OnCombatStart(delay)
	--TODO, fine tune start times, started from first melee swing not ENCOUNTER_START
	self.vb.deadCount = 0
	self.vb.harvestCount = 0
	self.vb.breathCount = 0
	self.vb.frenzyCount = 0
	self.vb.volleyCount = 0
	table.wipe(addUsedMarks)
	timerUnholyFrenzyCD:Start(6-delay, 1)--SUCCESS
	timerLandoftheDeadCD:Start(8.6-delay, 1)--SUCCESS
	timerNecroticBreathCD:Start(29.4-delay, 1)
	timerFinalHarvestCD:Start(38.6-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 322493 then
		self.vb.volleyCount = self.vb.volleyCount + 1
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFrostboltVolley:Show(args.sourceName, self.vb.volleyCount)
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
	elseif spellId == 333488 then
		self.vb.breathCount = self.vb.breathCount + 1
		specWarnNecroticBreath:Show(self.vb.breathCount)
		specWarnNecroticBreath:Play("breathsoon")
		timerNecroticBreathCD:Start(nil, self.vb.breathCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 321226 then
		self.vb.deadCount = self.vb.deadCount + 1
		specWarnLandoftheDead:Show(self.vb.deadCount)
		specWarnLandoftheDead:Play("killmob")
		timerLandoftheDeadCD:Start(nil, self.vb.deadCount+1)
	elseif spellId == 320012 then
		self.vb.frenzyCount = self.vb.frenzyCount + 1
		timerUnholyFrenzyCD:Start(nil, self.vb.frenzyCount+1)
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
