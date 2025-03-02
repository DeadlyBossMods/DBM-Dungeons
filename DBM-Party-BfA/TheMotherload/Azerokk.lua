local mod	= DBM:NewMod(2114, "DBM-Party-BfA", 7, 1012)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(129227)
mod:SetEncounterID(2106)
mod:SetHotfixNoticeRev(20250302000000)
mod:DisableESCombatDetection()--ES fires for nearby trash even if boss isn't pulled
mod:SetZone(1594)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 257593 258622 275907 258627 271698",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 257582",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnRagingGaze				= mod:NewTargetAnnounce(257582, 2)
local warnPulse						= mod:NewCastAnnounce(258622, 3)

local specWarnCallEarthRager		= mod:NewSpecialWarningCount(257593, nil, nil, nil, 1, 2)
local specWarnRagingGaze			= mod:NewSpecialWarningRun(257582, nil, nil, nil, 4, 2)
local yellRagingGaze				= mod:NewYell(257582)
local specWarnInfusion				= mod:NewSpecialWarningSwitchCount(271698, "-Healer", nil, nil, 1, 2)
--local specWarnResonantPulse		= mod:NewSpecialWarningDodge(258622, nil, nil, nil, 2, 2)
local specWarnTectonicSmash			= mod:NewSpecialWarningDodgeCount(275907, nil, nil, 2, 1, 15)
local specWarnQuake					= mod:NewSpecialWarningDodge(258627, nil, nil, nil, 2, 2)

local timerCallEarthragerCD			= mod:NewNextCountTimer(44.9, 257593, nil, nil, nil, 1)
local timerInfusionCD				= mod:NewVarCountTimer("v40.9-45", 271698, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)--Health based?
local timerResonantPulseCD			= mod:NewVarCountTimer("v40.1-44.9", 258622, nil, nil, nil, 2)
local timerTectonicSmashCD			= mod:NewVarCountTimer("v14.6-25.5", 275907, nil, nil, nil, 3)

mod:AddInfoFrameOption(257481, true)

mod.vb.addCount = 0
mod.vb.pulseCount = 0
mod.vb.smashCount = 0
mod.vb.infusionCount = 0

local updateInfoFrame
do
	local ccList = {--Likely TOTALLY out of date
		[1] = DBM:GetSpellName(257481),--Trap included with fight
		[2] = DBM:GetSpellName(6770),--Rogue Sap
		[3] = DBM:GetSpellName(9484),--Priest Shackle
		[4] = DBM:GetSpellName(20066),--Paladin Repentance
		[5] = DBM:GetSpellName(118),--Mage Polymorph
		[6] = DBM:GetSpellName(51514),--Shaman Hex
		[7] = DBM:GetSpellName(3355),--Hunter Freezing Trap
	}
	local lines = {}
	local floor = math.floor
	updateInfoFrame = function()
		table.wipe(lines)
		for i = 1, 5 do
			local uId = "boss"..i
			if UnitExists(uId) then
				for s = 1, #ccList do
					local spellName = ccList[s]
					local _, _, _, _, _, expires = DBM:UnitDebuff(uId, spellName)
					if expires then
						local debuffTime = expires - GetTime()
						lines[UnitName(uId)] = floor(debuffTime)
						break
					end
				end
			end
		end
		return lines
	end
end

function mod:OnCombatStart(delay)
	self.vb.addCount = 0
	self.vb.pulseCount = 0
	self.vb.smashCount = 0
	self.vb.infusionCount = 0

	timerInfusionCD:Start(5.2-delay, 1)
	timerResonantPulseCD:Start(8.6-delay, 1)
	if not self:IsNormal() then
		timerTectonicSmashCD:Start(12.2-delay, 1)
	end
	timerCallEarthragerCD:Start(40.1-delay, 1)
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM:GetSpellName(227909))
		DBM.InfoFrame:Show(5, "function", updateInfoFrame, false, true)
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 257593 then
		self.vb.addCount = self.vb.addCount + 1
		specWarnCallEarthRager:Show(self.vb.addCount)
		specWarnCallEarthRager:Play("bigmob")
		timerCallEarthragerCD:Start(60, self.vb.addCount+1)--add self.vb.addCount+1
	elseif spellId == 258622 then
		self.vb.pulseCount = self.vb.pulseCount + 1
		warnPulse:Show()
		timerResonantPulseCD:Start(nil, self.vb.pulseCount+1)
	elseif spellId == 275907 then
		self.vb.smashCount = self.vb.smashCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTectonicSmash:Show(self.vb.smashCount)
			specWarnTectonicSmash:Play("frontal")
		end
		timerTectonicSmashCD:Start(nil, self.vb.smashCount+1)
	elseif spellId == 258627 and self:AntiSpam(3.5, 1) then
		specWarnQuake:Show()
		specWarnQuake:Play("watchstep")
	elseif spellId == 271698 and self:AntiSpam(3.5, 2) then
		self.vb.infusionCount = self.vb.infusionCount + 1
		specWarnInfusion:Show(self.vb.infusionCount)
		specWarnInfusion:Play("targetchange")
		timerInfusionCD:Start(nil, self.vb.infusionCount+1)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 271698 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 257582 and self:AntiSpam(3.5, args.destName) then
		warnRagingGaze:CombinedShow(0.5, args.destName)--In case two adds are up
		if args:IsPlayer() and self:AntiSpam(3.5, 3) then
			specWarnRagingGaze:Show()
			specWarnRagingGaze:Play("justrun")
			specWarnRagingGaze:ScheduleVoice(1.5, "keepmove")
			yellRagingGaze:Yell()
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--"Azerite Infusion-257596-npc:129227-000034EF63 = pull:5.2, 40.9, 45.0, 45.0",
--"Azerite Infusion-271698-npc:129227-000034EF63 = pull:5.2, 40.9, 45.0, 45.0",
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257596 and self:AntiSpam(3.5, 2) then--Backup
		specWarnInfusion:Show(self.vb.infusionCount)
		specWarnInfusion:Play("killmob")
		timerInfusionCD:Start(nil, self.vb.infusionCount+1)
	end
end
