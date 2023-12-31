local mod	= DBM:NewMod(1656, "DBM-Party-Legion", 2, 762)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(99200)
mod:SetEncounterID(1838)
mod:SetHotfixNoticeRev(20231029000000)
mod:SetMinSyncRevision(20231029000000)
--mod.respawnTime = 29
mod:DisableESCombatDetection()--Remove if blizz fixes trash firing ENCOUNTER_START
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 199389 199345",
	"SPELL_PERIODIC_DAMAGE 199460",
	"SPELL_PERIODIC_MISSED 199460",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 199389 or ability.id = 199345 or ability.id = 191325) and type = "begincast"
 or ability.name = "Breath of Corruption" and type = "damage"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnRoar						= mod:NewCountAnnounce(199389, 2)

local specWarnDownDraft				= mod:NewSpecialWarningCount(199345, nil, nil, nil, 2, 2)
local specWarnBreath				= mod:NewSpecialWarningDodgeCount(191325, "Tank", nil, nil, 1, 2)
--local yellBreath					= mod:NewYell(199332)
local specWarnFallingRocks			= mod:NewSpecialWarningGTFO(199460, nil, nil, nil, 1, 8)

local timerBreathCD					= mod:NewCDCountTimer(22, 191325, nil, "Tank", nil, 5)--22/30 alternating? need more logs to confirm
local timerEarthShakerCD			= mod:NewCDCountTimer(30.3, 199389, nil, nil, nil, 3)--OLD: 21
local timerDownDraftCD				= mod:NewCDCountTimer(30.3, 199345, nil, nil, nil, 2)--OLD: 30-42 (health based or varaible?)

mod.vb.breathCount = 0
mod.vb.earthCount = 0
mod.vb.draftCount = 0

function mod:OnCombatStart(delay)
	self.vb.breathCount = 0
	self.vb.earthCount = 0
	self.vb.draftCount = 0
	timerBreathCD:Start(14.6-delay, 1)--14.6-15.4
	timerDownDraftCD:Start(20.6-delay, 1)--20.6-22.7
	timerEarthShakerCD:Start(32.9-delay, 1)--32.9-34.8
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 199389 then
		self.vb.earthCount = self.vb.earthCount + 1
		warnRoar:Show(self.vb.earthCount)
		timerEarthShakerCD:Start(nil, self.vb.earthCount+1)
	elseif spellId == 199345 then
		self.vb.draftCount = self.vb.draftCount + 1
		specWarnDownDraft:Show(self.vb.draftCount)
		specWarnDownDraft:Play("keepmove")
		timerDownDraftCD:Start(nil, self.vb.draftCount+1)
--	elseif spellId == 191325 then--If they ever enable it in combat log, it'll be this ID
--		self.vb.breathCount = self.vb.breathCount + 1
--		specWarnBreath:Show(self.vb.breathCount)
--		specWarnBreath:Play("breathsoon")
--		--"Breath of Corruption-199332-npc:99200-000021BD9C = pull:14.6, 22.0, 30.4", -- [8]
--		if self.vb.breathCount == 2 then--TODO, longer pulls to find out if it's 30 every other one
--			timerBreathCD:Start(30, self.vb.breathCount+1)
--		else
--			timerBreathCD:Start(22, self.vb.breathCount+1)
--		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 199460 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		specWarnFallingRocks:Show(spellName)
		specWarnFallingRocks:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--For time stamping purposes for WCL parsing, shows us time from cast til damage (~2 sec)
--NOTE spell damage not reliable, the tank actually can side step it, just right now not all tanks on PTR are (thankfully for timer purposes)
--"<1405.08 22:44:10> [UNIT_SPELLCAST_SUCCEEDED] Dresaron(75.6%-0.0%){Target:Fxa} -Breath of Corruption- [[boss1:Cast-3-5770-1466-11160-199332-001921C31C:199332]]", -- [17494]
--"<1405.09 22:44:10> [UNIT_SPELLCAST_START] Dresaron(75.6%-0.0%){Target:Fxa} -Breath of Corruption- 2s [[boss1:Cast-3-5770-1466-11160-191325-001AA1C31C:191325]]", -- [17498]
--"<1406.30 22:44:12> [UNIT_TARGET] boss1#Dresaron#Target: ??#TargetOfTarget: ??", -- [17511]
--"<1407.09 22:44:12> [UNIT_SPELLCAST_CHANNEL_START] Dresaron(71.2%-0.0%){Target:??} -Breath of Corruption- 2s [[boss1:nil:191325]]", -- [17524]
--"<1407.12 22:44:12> [CLEU] SPELL_DAMAGE#Creature-0-5770-1466-11160-99200-000021BD9C#Dresaron#Player-5764-000CFD06#Fxa#191326#Breath of Corruption", -- [17526]
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 199332 then--Target scanning not an option, boss wipes target as seen above
		self.vb.breathCount = self.vb.breathCount + 1
		specWarnBreath:Show(self.vb.breathCount)
		specWarnBreath:Play("breathsoon")
		--"Breath of Corruption-199332-npc:99200-000021BD9C = pull:14.6, 22.0, 30.4", -- [8]
		if self.vb.breathCount == 2 then--TODO, longer pulls to find out if it's 30 every other one
			timerBreathCD:Start(30, self.vb.breathCount+1)
		else
			timerBreathCD:Start(22, self.vb.breathCount+1)
		end
	end
end
