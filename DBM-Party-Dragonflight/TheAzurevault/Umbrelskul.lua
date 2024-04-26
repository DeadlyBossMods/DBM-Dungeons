local mod	= DBM:NewMod(2508, "DBM-Party-Dragonflight", 6, 1203)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186738)
mod:SetEncounterID(2584)
mod:SetHotfixNoticeRev(20230110000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 384978 385399 385075 388804",
	"SPELL_CAST_SUCCESS 384696 385399 388804",
	"SPELL_AURA_APPLIED 384978"
)

--TODO, Current under-tuning makes the crystals and fracture completely inconsiquential. Until that changes, not much to do with those.
--TODO, target scan arcane eruption?
--TODO, Even on really long M+, Unleashed was never cast more than once, with upwards of 107 seconds between first cast and kill
--TODO, Brittle not in CLEU so can't be implemented yet
--[[
(ability.id = 384978 or ability.id = 384699 or ability.id = 385399 or ability.id = 385075 or ability.id = 388804)  and type = "begincast"
 or ability.id = 384696 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnArcaneEruption						= mod:NewCountAnnounce(385075, 3)

local specWarnDragonStrike						= mod:NewSpecialWarningDefensive(384978, nil, nil, nil, 1, 2)
local specWarnDragonStrikeDebuff				= mod:NewSpecialWarningDispel(384978, "RemoveMagic", nil, nil, 1, 2)
local specWarnCrystallineRoar					= mod:NewSpecialWarningDodgeCount(384699, nil, nil, nil, 3, 2)
local specWarnUnleashedDestruction				= mod:NewSpecialWarningCount(385399, nil, nil, nil, 2, 2)

local timerDragonStrikeCD						= mod:NewCDTimer(7.3, 384978, nil, "Tank|Healer|RemoveMagic", nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.MAGIC_ICON)--7.3-24, probably delayed by CLEU events I couldn't see
local timerCrystallineRoarCD					= mod:NewCDCountTimer(111.6, 384699, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerUnleashedDestructionCD				= mod:NewCDCountTimer(103.1, 385399, nil, nil, nil, 2)--103-115
local timerArcaneEruptionCD						= mod:NewCDCountTimer(54.6, 385075, nil, nil, nil, 3)

mod:AddInfoFrameOption(388777, false)

mod.vb.roarCount = 0
mod.vb.unleashedCast = 0
mod.vb.eruptionCount = 0

function mod:OnCombatStart(delay)
	self.vb.roarCount = 0
	self.vb.unleashedCast = 0
	self.vb.eruptionCount = 0
	timerDragonStrikeCD:Start(7.1-delay)
	timerCrystallineRoarCD:Start(12.3-delay, 1)
	timerArcaneEruptionCD:Start(28.9-delay, 1)--28.9-37, Highly variable if it gets spell queued behind more tank casts
	timerUnleashedDestructionCD:Start(48.2-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 384978 then
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnDragonStrike:Show()
			specWarnDragonStrike:Play("defensive")
		end
		timerDragonStrikeCD:Start()
	elseif spellId == 385399 or spellId == 388804 then--Easy, Hard
		specWarnUnleashedDestruction:Show(self.vb.unleashedCast+1)
		specWarnUnleashedDestruction:Play("carefly")
	elseif spellId == 385075 then
		self.vb.eruptionCount = self.vb.eruptionCount + 1
		warnArcaneEruption:Show(self.vb.eruptionCount)
		timerArcaneEruptionCD:Start(nil, self.vb.eruptionCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 384696 then
		self.vb.roarCount = self.vb.roarCount + 1
		specWarnCrystallineRoar:Show(self.vb.roarCount)
		specWarnCrystallineRoar:Play("shockwave")
		timerCrystallineRoarCD:Start(nil, self.vb.roarCount+1)
	elseif spellId == 385399 or spellId == 388804 then--Easy, Hard
		self.vb.unleashedCast = self.vb.unleashedCast + 1--Only increment cast count if it actually finishes
		timerUnleashedDestructionCD:Start(100.1, self.vb.unleashedCast+1)--Even this cast can be interrupted kited boss around so we have to move timer to success
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 384978 then
		local uId = DBM:GetRaidUnitId(args.destName)
		if self:IsTanking(uId) and self:CheckDispelFilter("magic") then
			specWarnDragonStrikeDebuff:Show(args.destName)
			specWarnDragonStrikeDebuff:Play("helpdispel")
		end
	end
end
