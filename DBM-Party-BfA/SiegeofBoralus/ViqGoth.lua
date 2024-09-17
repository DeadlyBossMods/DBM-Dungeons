local mod	= DBM:NewMod(2140, "DBM-Party-BfA", 5, 1023)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(120553)
mod:SetEncounterID(2100)
--mod:SetHotfixNoticeRev(20230516000000)
--mod:SetMinSyncRevision(20211203000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 270185 269266 269456 269366 270590",
	"SPELL_CAST_SUCCESS 274991 269984",
	"SPELL_AURA_APPLIED 270624 275014",
	"UNIT_DIED",
--	"INSTANCE_ENCOUNTER_ENGAGE_UNIT",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, just show initial terror timer and nothing more
--[[
(ability.id = 270185 or ability.id = 269266 or ability.id = 269456 or ability.id = 269366 or ability.id = 270590) and type = "begincast"
 or (ability.id = 274991 or ability.id = 269984) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnPutridWaters				= mod:NewTargetAnnounce(275014, 2)
local warnRepair					= mod:NewCastAnnounce(269366, 1)
local warnEradication				= mod:NewCastAnnounce(269456, 4)

local specWarnCalloftheDeep			= mod:NewSpecialWarningDodge(270185, nil, nil, nil, 2, 2)
local yellCrushingEmbrace			= mod:NewYell(270624)
local specWarnPutridWaters			= mod:NewSpecialWarningMoveAway(275014, nil, nil, nil, 1, 2)
local yellPutridWaters				= mod:NewYell(275014)
local specWarnSlam					= mod:NewSpecialWarningSpell(269266, nil, nil, 2, 2, 2)

local timerCalloftheDeepCD			= mod:NewCDTimer(13, 270185, nil, nil, nil, 3)--6.4, 15.1, 19.0, 11.9, 12.1, 12.3, 15.6, 12.1, 12.9, 7.0, 8.6, 7.5, 7.2, 7.4, 7.0, 7.0, 7.3, 7.2
local timerPutridWatersCD			= mod:NewCDCountTimer(19.9, 275014, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSlamCD					= mod:NewCDTimer(6, 269266, nil, nil, 2, 2)
--local timerDemolisherTerrorCD		= mod:NewCDCountTimer(20, 270605, nil, nil, nil, 1, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DAMAGE_ICON)

mod:AddRangeFrameOption(5, 275014)

local seenAdds = {}
mod.vb.watersCount = 0

function mod:OnCombatStart(delay)
	table.wipe(seenAdds)
	self:SetStage(1)
	self.vb.watersCount = 0
	timerPutridWatersCD:Start(3.4-delay, 1)
	timerCalloftheDeepCD:Start(6.3-delay)
	--timerDemolisherTerrorCD:Start(19.9-delay, 1)--Should be started by IEEU event
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(5)
	end
end

function mod:OnCombatEnd()
	table.wipe(seenAdds)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 270185 then
		specWarnCalloftheDeep:Show()
		specWarnCalloftheDeep:Play("watchstep")
		--timerCalloftheDeepCD:Start()
	elseif spellId == 269266 then
		if self:AntiSpam(2.5, 1) then
			specWarnSlam:Show()
			specWarnSlam:Play("aesoon")
		end
		local timer = self:GetStage(1) and 18.2 or self:GetStage(2) and 13.3 or 10.1
		timerSlamCD:Start(timer, args.sourceGUID)
	elseif spellId == 269366 then
		warnRepair:Show()
	elseif spellId == 269456 then
		warnEradication:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 274991 then
		self.vb.watersCount = self.vb.watersCount + 1
		timerPutridWatersCD:Start(nil, self.vb.watersCount+1)
	elseif spellId == 269984 then--Damage Boss 35% (can use SPELL_CAST_START of 269456 alternatively)
		--Might actually be at Repair event instead (269366)
		if self:GetStage(3, 1) then
			self:SetStage(0)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 270624 and args:IsPlayer() then
		yellCrushingEmbrace:Yell()
	elseif spellId == 275014 then
		if args:IsPlayer() then
			specWarnPutridWaters:Show()
			specWarnPutridWaters:Play("range5")
			yellPutridWaters:Yell()
		else
			warnPutridWaters:CombinedShow(0.3, args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 137614 or cid == 137625 or cid == 137626 or cid == 140447 then--Demolishing Terror
		timerSlamCD:Stop(args.destGUID)
--	elseif cid == 137405 then--Gripping Terror
--		timerDemolisherTerrorCD:Stop()
	end
end

--[[
function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i = 1, 5 do
		local unitID = "boss"..i
		local GUID = UnitGUID(unitID)
		if GUID and not seenAdds[GUID] then
			seenAdds[GUID] = true
			local cid = self:GetCIDFromGUID(GUID)
			if cid == 137405 then--Gripping Terror
				self.vb.terrorCount = 1--Set to 1 because first spawn comes with the terror spawn
				timerDemolisherTerrorCD:Start(19.2, 2)
			end
		end
	end
end
--]]

--Readd 270605 if Bfa Classic ever happens (i hope the hell not)
function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 270183 then
		--6.3, 15.1, 16.2, 17.0, 13.9, 12.0, 12.0, 12.1, 12.0, 15.0, 7.3, 7.0, 7.1, 7.2, 7.3, 7.2, 7.0, 7.0, 7.1, 7.0, 7.1, 7.4
		--(ie stage one 15, stage 2 12, stage 3 7)
		local timer = self:GetStage(1) and 15 or self:GetStage(2) and 12 or 7
		timerCalloftheDeepCD:Start(timer)
	end
end
