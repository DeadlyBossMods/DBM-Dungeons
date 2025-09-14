local mod	= DBM:NewMod("z2951", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(244752)--Non hard one placeholder on load. Real one set in OnCombatStart
mod:SetEncounterID(3326, 3325)
mod:SetHotfixNoticeRev(20250908000000)
mod:SetMinSyncRevision(20250908000000)
mod:SetZone(2951)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1245203 1244462 1245582 1245240 1244600"
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED"
)

local warnInvokeTheShadows				= mod:NewCountAnnounce(1244462, 3)

local specWarnDarkMassacre				= mod:NewSpecialWarningCount(1245203, nil, nil, nil, 2, 2)
local specWarnNetherRift				= mod:NewSpecialWarningCount(1245582, nil, nil, nil, 2, 12)
local specWarnNexusDaggers				= mod:NewSpecialWarningDodgeCount(1245240, nil, nil, nil, 2, 2)
local specWarnShadowEruption			= mod:NewSpecialWarningSpell(1244600, nil, nil, nil, 2, 2)

local timerDarkMassacreCD				= mod:NewCDCountTimer(27.9, 1245203, nil, nil, nil, 5)
local timerInvokeTheShadowsCD			= mod:NewCDCountTimer(20.0, 1244462, nil, nil, nil, 1)
local timerNetherRiftCD					= mod:NewCDCountTimer(30.0, 1245582, nil, nil, nil, 2)
local timerNexusDaggersCD				= mod:NewCDCountTimer(30.0, 1245240, nil, nil, nil, 2)

mod.vb.darkMassacreCount = 0
mod.vb.invokeTheShadowsCount = 0
mod.vb.netherRiftCount = 0
mod.vb.daggersCount = 0

--Scheduled checks for skipped casts due to using the healing curio that stuns boss for 5 seconds.
--These checks will run 10 seconds after expected cast, but be unscheduled on cast.
local function checkForSkippedMassacre(self)
	self.vb.darkMassacreCount = self.vb.darkMassacreCount + 1
	local cd = 30
	if self.vb.darkMassacreCount % 2 == 0 then
		cd = 59.9
	end
	timerDarkMassacreCD:Start(cd-10, self.vb.darkMassacreCount+1)
	self:Schedule(cd, checkForSkippedMassacre, self)
end

local function checkForSkippedRift(self)
	self.vb.netherRiftCount = self.vb.netherRiftCount + 1
	local cd = 30
	if self.vb.netherRiftCount % 2 == 0 then
		cd = 59.9
	end
	timerNetherRiftCD:Start(cd-10, self.vb.netherRiftCount+1)
	self:Schedule(cd, checkForSkippedRift, self)
end

local function checkForSkippedDaggers(self)
	self.vb.daggersCount = self.vb.daggersCount + 1
	timerNexusDaggersCD:Start(19.9, self.vb.daggersCount+1)
	self:Schedule(29.9, checkForSkippedDaggers, self)
end

function mod:OnCombatStart(delay)
	if self:IsMythic() then
		self:SetCreatureID(244753)
	else
		self:SetCreatureID(244752)
	end
	self.vb.darkMassacreCount = 0
	self.vb.invokeTheShadowsCount = 0
	self.vb.netherRiftCount = 0
	self.vb.daggersCount = 0
	--Nexus daggers used on pull
	timerNetherRiftCD:Start(5.2-delay)
	self:Schedule(15.2, checkForSkippedRift, self)
	timerDarkMassacreCD:Start(20-delay, 1)
	self:Schedule(30, checkForSkippedMassacre, self)
	timerInvokeTheShadowsCD:Start(64.1-delay, 1)
end

function mod:SPELL_CAST_START(args)
	--"Dark Massacre-1245203-npc:244752-00003DD595 = pull:20.1, 30.0, 60.0, 30.0, 60.1, 30.0, 59.9",
	if args.spellId == 1245203 then
		self.vb.darkMassacreCount = self.vb.darkMassacreCount + 1
		specWarnDarkMassacre:Show(self.vb.darkMassacreCount)
		specWarnDarkMassacre:Play("ghostsoon")
		local cd = 30
		if self.vb.darkMassacreCount % 2 == 0 then
			cd = 59.9
		end
		timerDarkMassacreCD:Start(cd, self.vb.darkMassacreCount+1)
		self:Unschedule(checkForSkippedMassacre)
		self:Schedule(10, checkForSkippedMassacre, self)
	--"Invoke the Shadows-1244462-npc:244752-00003DD595 = pull:64.1, 89.9",
	elseif args.spellId == 1244462 then
		self.vb.invokeTheShadowsCount = self.vb.invokeTheShadowsCount + 1
		warnInvokeTheShadows:Show(self.vb.invokeTheShadowsCount)
		timerInvokeTheShadowsCD:Start(89.9, self.vb.invokeTheShadowsCount+1)
	--"Nether Rift-1245582-npc:244752-00003DD595 = pull:5.2, 30.0, 59.9, 30.0, 60.1, 30.0, 59.9",
	elseif args.spellId == 1245582 then
		self.vb.netherRiftCount = self.vb.netherRiftCount + 1
		specWarnNetherRift:Show(self.vb.netherRiftCount)
		specWarnNetherRift:Play("pullin")
		local cd = 30
		if self.vb.netherRiftCount % 2 == 0 then
			cd = 59.9
		end
		timerNetherRiftCD:Start(cd, self.vb.netherRiftCount+1)
		self:Unschedule(checkForSkippedRift)
		self:Schedule(10, checkForSkippedRift, self)
	--"Nexus Daggers-1245240-npc:244752-00003DD595 = pull:0.2, 29.9, 30.0, 30.1, 29.9, 30.0, 30.1, 29.9, 60.1, 29.9",
	elseif args.spellId == 1245240 and (args:GetSrcCreatureID() == 244752 or args:GetSrcCreatureID() == 244753) then
		self.vb.daggersCount = self.vb.daggersCount + 1
		specWarnNexusDaggers:Show(self.vb.daggersCount)
		specWarnNexusDaggers:Play("farfromline")
		timerNexusDaggersCD:Start(29.9, self.vb.daggersCount+1)
		self:Unschedule(checkForSkippedDaggers)
		self:Schedule(10, checkForSkippedDaggers, self)
	elseif args.spellId == 1244600 and self:AntiSpam(5, 1) then
		specWarnShadowEruption:Show()
		specWarnShadowEruption:Play("aesoon")
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 138561 and destGUID == UnitGUID("player") and self:AntiSpam() then

	end
end
--]]
