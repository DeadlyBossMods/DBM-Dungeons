local mod	= DBM:NewMod(2510, "DBM-Party-Dragonflight", 8, 1204)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(189727)
mod:SetEncounterID(2617)
mod:SetHotfixNoticeRev(20240429000000)
mod:SetMinSyncRevision(20230507000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 386757 386559 390111",
	"SPELL_CAST_SUCCESS 385963",
	"SPELL_AURA_APPLIED 385963"
)

--[[
(ability.id = 386757 or ability.id = 386559 or ability.id = 390111) and type = "begincast"
 or ability.id = 385963 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, review heroic logs in 10.1 to see if timer changes affect that mode
local warnFrostCyclone							= mod:NewTargetNoFilterAnnounce(390111, 3)

local specWarnHailstorm							= mod:NewSpecialWarningMoveTo(386757, nil, nil, nil, 2, 2)
local specWarnGlacialSurge						= mod:NewSpecialWarningDodgeCount(386559, nil, nil, nil, 2, 2)
local specWarnFrostCyclone						= mod:NewSpecialWarningMoveAway(390111, nil, nil, nil, 1, 2, 4)
local yellFrostCyclone							= mod:NewYell(390111)
local specWarnFrostShock						= mod:NewSpecialWarningDispel(385963, "RemoveMagic", nil, nil, 1, 2)

local timerHailstormCD							= mod:NewCDCountTimer(22, 386757, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerGlacialSurgeCD						= mod:NewCDCountTimer(22, 386559, nil, nil, nil, 3)
local timerFrostCycloneCD						= mod:NewCDCountTimer(29.9, 390111, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerFrostShockCD							= mod:NewCDCountTimer(11, 385963, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)

local boulder = DBM:GetSpellName(386222)

mod.vb.hailCount = 0
mod.vb.surgeCount = 0
mod.vb.cycloneCount = 0
mod.vb.shockCount = 0

function mod:FrostCycloneTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnFrostCyclone:Show()
		specWarnFrostCyclone:Play("runout")
		yellFrostCyclone:Yell()
	else
		warnFrostCyclone:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	self.vb.hailCount = 0
	self.vb.surgeCount = 0
	self.vb.cycloneCount = 0
	self.vb.shockCount = 0
	timerFrostShockCD:Start(6-delay, 1)
	if self:IsMythic() then
		timerFrostCycloneCD:Start(10-delay, 1)
		timerHailstormCD:Start(20-delay, 1)
		timerGlacialSurgeCD:Start(self:IsMythicPlus() and 32 or 27-delay, 1)
	else--TODO, verify heroic still does this
		timerHailstormCD:Start(10-delay, 1)
		timerGlacialSurgeCD:Start(22-delay, 1)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 386757 then
		self.vb.hailCount = self.vb.hailCount + 1
		specWarnHailstorm:Show(boulder)
		specWarnHailstorm:Play("findshelter")
		if self:IsMythicPlus() then
			--20.0, 30.0, 42.0, 30.0
			if self.vb.hailCount % 2 == 0 then
				timerHailstormCD:Start(42, self.vb.hailCount+1)
			else
				timerHailstormCD:Start(30, self.vb.hailCount+1)
			end
		else
			timerHailstormCD:Start(22, self.vb.hailCount+1)
		end
	elseif spellId == 386559 then
		self.vb.surgeCount = self.vb.surgeCount + 1
		specWarnGlacialSurge:Show(self.vb.surgeCount)
		specWarnGlacialSurge:Play("watchstep")--or watchring maybe?
		if self:IsMythicPlus() then
			--32.0, 30.0, 42.0, 30.0
			if self.vb.surgeCount % 2 == 0 then
				timerGlacialSurgeCD:Start(42, self.vb.surgeCount+1)
			else
				timerGlacialSurgeCD:Start(30, self.vb.surgeCount+1)
			end
		else
			timerGlacialSurgeCD:Start(22, self.vb.surgeCount+1)
		end
	elseif spellId == 390111 then
		self.vb.cycloneCount = self.vb.cycloneCount + 1
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "FrostCycloneTarget", 0.1, 6, true)
		if self:IsMythicPlus() then
			--10.0, 35.0, 37.0, 35.0
			if self.vb.cycloneCount % 2 == 0 then
				timerFrostCycloneCD:Start(37, self.vb.cycloneCount+1)
			else
				timerFrostCycloneCD:Start(35, self.vb.cycloneCount+1)
			end
		else
			timerFrostCycloneCD:Start(30, self.vb.cycloneCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 385963 then
		self.vb.shockCount = self.vb.shockCount + 1
		if self:IsMythicPlus() then
			--pull:6.0, 12.0, 30.0, 30.0, 12.0, 30.0
			if self.vb.shockCount % 3 == 1 then
				timerFrostShockCD:Start(12, self.vb.shockCount+1)
			else
				timerFrostShockCD:Start(30, self.vb.shockCount+1)
			end
		else
			timerFrostShockCD:Start(11, self.vb.shockCount+1)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 385963 and self:CheckDispelFilter("magic") then
		specWarnFrostShock:Show(args.destName)
		specWarnFrostShock:Play("helpdispel")
	end
end
