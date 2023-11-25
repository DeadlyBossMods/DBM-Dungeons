local mod	= DBM:NewMod(2128, "DBM-Party-BfA", 10, 1001)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(131527, 131545)
mod:SetMainBossID(131545)
mod:SetEncounterID(2116)
mod:SetHotfixNoticeRev(20231025000000)
mod:SetMinSyncRevision(20231025000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 268306 261440 268278",
	"SPELL_CAST_SUCCESS 261438 261446 268306",
	"SPELL_AURA_APPLIED 261440",
	"SPELL_AURA_REMOVED 261440",
	"UNIT_DIED"
)

--TODO, more/better timer data, because Lady Waycrest will interrupt Cadenza casts to cast vitaly transfer, so on normal mode her health drops too fast for meaningful Cd data
--TODO, Contanous Remnants doesn't seem to have a valid debuff spellID that has a duration in tooltip data, so figure out what to use for it on heroic
--[[
(ability.id = 268306 or ability.id = 261440 or ability.id = 268278) and type = "begincast"
 or (ability.id = 261438 or ability.id = 261446 or ability.id = 268306) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (target.id = 131527 or target.id = 131545) and type = "death"
--]]
local warnVirulentPathogen			= mod:NewTargetAnnounce(261440, 2)
local warnVitalityTransfer			= mod:NewCountAnnounce(261446, 2)

local specWarnDiscordantCadenza		= mod:NewSpecialWarningDodge(268306, nil, nil, nil, 2, 2)
local specWarnVirulentPathogen		= mod:NewSpecialWarningMoveAway(261440, nil, nil, nil, 1, 2)
local yellVirulentPathogen			= mod:NewShortYell(261440)
local yellVirulentPathogenFades		= mod:NewShortFadesYell(261440)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerWastingStrikeCD			= mod:NewCDCountTimer(16, 261438, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON, nil, 2, 3)--16.5-17.1
local timerVirulentPathogenCD		= mod:NewCDCountTimer(15.4, 261440, nil, nil, nil, 3, nil, DBM_COMMON_L.DISEASE_ICON)--15.4-17
local timerDiscordantCadenzaCD		= mod:NewCDCountTimer(23.5, 268306, nil, nil, nil, 3)--Casting transfer can delay it further since that triggers a 3 second spell lockout+cast time
local timerWrackingChordCD			= mod:NewCDCountTimer(7.3, 268278, nil, nil, nil, 4, nil, DBM_COMMON_L.DISEASE_ICON)

mod:AddRangeFrameOption(6, 261440)

mod.vb.wastingCount = 0
mod.vb.virulentCount = 0
mod.vb.discordCount = 0--Reused for wracking in stage 2
mod.vb.transferCount = 0

local function scanBosses(self, delay)
	for i = 1, 2 do
		local unitID = "boss"..i
		if UnitExists(unitID) then
			local cid = self:GetUnitCreatureId(unitID)
			local bossGUID = UnitGUID(unitID)
			if cid == 131527 then--Lord waycrest
				timerWastingStrikeCD:Start(5-delay, 1, bossGUID)
				timerVirulentPathogenCD:Start(9.5-delay, 1, bossGUID)
			else
				timerDiscordantCadenzaCD:Start(14.5-delay, 1, bossGUID)
			end
		end
	end
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.wastingCount = 0
	self.vb.virulentCount = 0
	self.vb.discordCount = 0
	self.vb.transferCount = 0
	self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss unitIDs
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(6)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 268306 and self:AntiSpam(6, 1) then--Antispam in case she interrupts cast to cast transfer, then casts it a second time
		specWarnDiscordantCadenza:Show(self.vb.discordCount+1)
		specWarnDiscordantCadenza:Play("watchstep")
	elseif spellId == 261440 then
		self.vb.virulentCount = self.vb.virulentCount + 1
		timerVirulentPathogenCD:Start(15.7, self.vb.virulentCount+1, args.sourceGUID)
	elseif spellId == 268278 and self:GetStage(2) then
		self.vb.discordCount = self.vb.discordCount + 1--Reused since not needed anymore otherwise
		timerWrackingChordCD:Start(nil, self.vb.discordCount+1, args.sourceGUID)--8
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 261438 then
		self.vb.wastingCount = self.vb.wastingCount + 1
		timerWastingStrikeCD:Start(nil, self.vb.wastingCount+1, args.sourceGUID)
	elseif spellId == 261446 then
		self.vb.transferCount = self.vb.transferCount + 1
		warnVitalityTransfer:Show(self.vb.transferCount)
		if self.vb.transferCount == 3 then
			self:SetStage(2)
			self.vb.discordCount = 0
			timerDiscordantCadenzaCD:HardStop(args.sourceGUID)
			timerWrackingChordCD:Start(11, 1, args.sourceGUID)
		end
	elseif spellId == 268306 then
		--only increment count and start timer on an actually successful cast since she'll abort casts for Transfer
		self.vb.discordCount = self.vb.discordCount + 1
		timerDiscordantCadenzaCD:Start(20.6, self.vb.discordCount+1, args.sourceGUID)--23.5 - 2
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 261440 then
		warnVirulentPathogen:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnVirulentPathogen:Show()
			specWarnVirulentPathogen:Play("scatter")
			yellVirulentPathogen:Yell()
			yellVirulentPathogenFades:Countdown(spellId)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 261440 then
		if args:IsPlayer() then
			yellVirulentPathogenFades:Cancel()
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 131527 then--Lord Waycrest
		timerWastingStrikeCD:HardStop(args.destGUID)
		timerVirulentPathogenCD:HardStop(args.destGUID)
	elseif cid == 131545 then--Lady Waycrest
		timerDiscordantCadenzaCD:HardStop(args.destGUID)
		timerWrackingChordCD:HardStop(args.destGUID)
	end
end
