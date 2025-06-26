local mod	= DBM:NewMod(2082, "DBM-Party-BfA", 1, 968)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(122967)
mod:SetEncounterID(2084)
mod:SetUsedIcons(8)
mod:SetHotfixNoticeRev(20231023000000)
--mod:SetMinSyncRevision(20231021000000)
mod:SetZone(1763)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 255577",
	"SPELL_CAST_SUCCESS 255579 255591",
	"SPELL_SUMMON 259209",
	"SPELL_AURA_APPLIED 255579"--277072
)

--[[
ability.id = 255577 and type = "begincast"
 or (ability.id = 255579 or ability.id = 255591) and type = "cast"
 or ability.id = 259209
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnTransfusion				= mod:NewCountAnnounce(255577, 1)
local warnMoltenGold				= mod:NewCountAnnounce(255582, 3)

local specWarnTransfusion			= mod:NewSpecialWarningMoveTo(255577, nil, nil, nil, 3, 2)
local specWarnClaws					= mod:NewSpecialWarningDefensive(255579, "Tank", nil, nil, 1, 2)
local specWarnClawsDispel			= mod:NewSpecialWarningDispel(255579, "MagicDispeller", nil, nil, 1, 2)
local specWarnSpiritofGold			= mod:NewSpecialWarningSwitchCount(259205, "Dps", nil, nil, 1, 2, 3)
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(277072, nil, nil, nil, 1, 8)--Unclear, it seems from logs once you step in it, you don't lose debuff moving out of it

local timerTransfusionCD			= mod:NewCDCountTimer(34, 255577, nil, nil, nil, 5)
local timerGildedClawsCD			= mod:NewCDCountTimer(34, 255579, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerMoltenGoldCD				= mod:NewCDCountTimer(8.1, 255582, nil, nil, nil, 3)--8.1, but reset by transfusion 99% of time
local timerSpiritofGoldCD			= mod:NewCDCountTimer(34, 259205, nil, nil, nil, 1, nil, DBM_COMMON_L.HEROIC_ICON)

mod:AddSetIconOption("SetIconOnSpirit", 259205, true, 5, {8})

local taintedBlood = DBM:GetSpellName(255558)

mod.vb.transCount = 0
mod.vb.clawsCount = 0
mod.vb.goldCount = 0
mod.vb.spiritCount = 0

function mod:OnCombatStart(delay)
	self.vb.transCount = 0
	self.vb.clawsCount = 0
	self.vb.goldCount = 0
	self.vb.spiritCount = 0
	timerGildedClawsCD:Start(10.5-delay, 1)
	timerMoltenGoldCD:Start(16.5-delay, 1)
	timerTransfusionCD:Start(25-delay, 1)
	if not self:IsNormal() then
		timerSpiritofGoldCD:Start(9.1-delay, 1)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 255577 then
		self.vb.transCount = self.vb.transCount + 1
		timerTransfusionCD:Start(nil, self.vb.transCount+1)
		local _, _, _, _, _, expireTime = DBM:UnitDebuff("player", taintedBlood)
		local remaining
		if expireTime then
			remaining = expireTime-GetTime()
		end
		--Not dead, and do not have tainted blood or do have it but it'll expire for transfusion does.
		if not UnitIsDeadOrGhost("player") and (not remaining or remaining and remaining < 9) then
			specWarnTransfusion:Show(taintedBlood)
			specWarnTransfusion:Play("takedamage")
		else--Already good to go, just a positive warning
			warnTransfusion:Show(self.vb.transCount)
		end
		--Handle timer resets
		timerMoltenGoldCD:Stop()
		timerMoltenGoldCD:Start(25.5, self.vb.goldCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 255579 then
		self.vb.clawsCount = self.vb.clawsCount + 1
		if not self.Options.SpecWarn255579dispel then
			specWarnClaws:Show()
			specWarnClaws:Play("defensive")
		end
		timerGildedClawsCD:Start(nil, self.vb.clawsCount+1)
	elseif spellId == 255591 then
		self.vb.goldCount = self.vb.goldCount + 1
		warnMoltenGold:Show(self.vb.goldCount)
		timerMoltenGoldCD:Start(nil, self.vb.goldCount+1)
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 259209 then
		self.vb.spiritCount = self.vb.spiritCount + 1
		specWarnSpiritofGold:Show(self.vb.spiritCount)
		specWarnSpiritofGold:Play("killmob")
		timerSpiritofGoldCD:Start(nil, self.vb.spiritCount+1)
		if self.Options.SetIconOnSpirit then
			self:ScanForMobs(args.destGUID, 2, 8, 1, nil, 12, "SetIconOnSpirit")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 255579 and not args:IsDestTypePlayer() then
		specWarnClawsDispel:Show(args.destName)
		specWarnClawsDispel:Play("dispelboss")
--	elseif spellId == 277072 and args:IsPlayer() and self:AntiSpam(3, 1) then
--		specWarnGTFO:Show(args.spellName)
--		specWarnGTFO:Play("watchfeet")
	end
end
