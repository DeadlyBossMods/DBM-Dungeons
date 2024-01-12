local mod	= DBM:NewMod(2537, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge"--No Follower dungeon

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198933)
mod:SetEncounterID(2669)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20231102000000)
mod:SetMinSyncRevision(20231102000000)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 414535 409456 409635 414184 414652",
	"SPELL_AURA_APPLIED 409266 414376",
	"SPELL_AURA_REMOVED 409456 414177"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

--[[
(ability.id = 409261 or ability.id = 414535 or ability.id = 409456 or ability.id = 409635 or ability.id = 414184 or ability.id = 414652) and type = "begincast"
 or (ability.id = 409456 or ability.id = 414177) and type = "removebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--https://www.warcraftlogs.com/reports/q8cZgTfWkBRp3vFy#fight=last&pins=2%24Off%24%23244F4B%24expression%24(ability.id%20%3D%20409261%20or%20ability.id%20%3D%20414535%20or%20ability.id%20%3D%20409456%20or%20ability.id%20%3D%20409635%20or%20ability.id%20%3D%20414184%20or%20ability.id%20%3D%20414652)%20and%20type%20%3D%20%22begincast%22%0A%20or%20(ability.id%20%3D%20409456%20or%20ability.id%20%3D%20414177)%20and%20type%20%3D%20%22removebuff%22%0A%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
--NOTES: Crushing Onslaught seems utterly passive and not much point in warning for it really
local warnExtinctionBlast						= mod:NewTargetNoFilterAnnounce(409261, 4)
local warnEarthsurge							= mod:NewCountAnnounce(409456, 3)
local warnEarthsurgeOver						= mod:NewEndAnnounce(409456, 1)
local warnCataclysmicObliteration				= mod:NewSpellAnnounce(414184, 4)

local specWarnExtinctionBlast					= mod:NewSpecialWarningMoveTo(409261, nil, nil, nil, 2, 2)--Warn everyone
local yellExtinctionBlast						= mod:NewYell(409261)--But have target of it do yell
local specWarnStonecrackerBarrage				= mod:NewSpecialWarningSoakCount(414535, nil, nil, nil, 2, 2)
local specWarnPulvBreath						= mod:NewSpecialWarningDodgeCount(409635, nil, nil, nil, 2, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(414376, nil, nil, nil, 1, 8)

local timerRP									= mod:NewRPTimer(19.8)
local timerExtinctionBlastCD					= mod:NewCDCountTimer(19.4, 409261, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerStonecrackerBarrageCD				= mod:NewCDCountTimer(19.4, 414535, nil, nil, nil, 5, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerEarthSurgeCD							= mod:NewCDCountTimer(19.4, 409456, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON..DBM_COMMON_L.HEALER_ICON)
local timerPulverizingExhalationCD				= mod:NewCDCountTimer(19.4, 409635, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerCataclysmicObliteration				= mod:NewCastTimer(30, 414184, nil, nil, nil, 2)

mod.vb.surgeCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.surgeCount = 0
	timerExtinctionBlastCD:Start(8.5, 1)
	timerStonecrackerBarrageCD:Start(16.3, 1)
	timerEarthSurgeCD:Start(35.2, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 414535 then
		specWarnStonecrackerBarrage:Show(self.vb.surgeCount+1)
		specWarnStonecrackerBarrage:Play("helpsoak")
	elseif spellId == 409456 then
		self.vb.surgeCount = self.vb.surgeCount + 1
		warnEarthsurge:Show(self.vb.surgeCount)
	elseif spellId == 409635 then
		specWarnPulvBreath:Show(self.vb.surgeCount)
		specWarnPulvBreath:Play("breathsoon")
		if self:IsMythic() then
			specWarnPulvBreath:ScheduleVoice(2, "scatter")
		end
	elseif spellId == 414184 or spellId == 414652 then
		self:SetStage(2)
		timerExtinctionBlastCD:Stop()
		timerStonecrackerBarrageCD:Stop()
		timerEarthSurgeCD:Stop()
		timerPulverizingExhalationCD:Stop()
		warnCataclysmicObliteration:Show()
		timerCataclysmicObliteration:Start(spellId == 414652 and 6 or 30)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 409266 then
		if args:IsPlayer() then
			specWarnExtinctionBlast:Show(DBM_COMMON_L.SHIELD)
			specWarnExtinctionBlast:Play("findshelter")
			yellExtinctionBlast:Yell()
		else
			warnExtinctionBlast:Show(args.destName)
		end
	elseif spellId == 414376 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 409456 then--Earthsurge
		warnEarthsurgeOver:Show()
		timerPulverizingExhalationCD:Start(9, self.vb.surgeCount)
		timerExtinctionBlastCD:Start(41.8, self.vb.surgeCount+1)
		timerStonecrackerBarrageCD:Start(49.4, self.vb.surgeCount+1)
		timerEarthSurgeCD:Start(68.5, self.vb.surgeCount+1)
	elseif spellId == 414177 then
		timerCataclysmicObliteration:Stop()
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 386201 and destGUID == UnitGUID("player") and self:AntiSpam(2, 3) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--"<403.05 22:15:46> [CHAT_MSG_MONSTER_YELL] So the titans' puppets have come to face me.#Iridikron###Alphal##0#0##0#14598#nil#0#false#false#false#false", -- [2637]
--"<410.46 22:15:53> [CHAT_MSG_MONSTER_SAY] He's siphoning Galakrond's essence into a... vessel?#Chromie###Alphal##0#0##0#14599#nil#0#false#false#false#false", -- [2644]
--"<416.01 22:15:59> [CHAT_MSG_MONSTER_SAY] It looks kind of like the Dragon Soul, but even more ancient.#Chromie###Alphal##0#0##0#14600#nil#0#false#false#false#false", -- [2645]
--"<423.68 22:16:07> [CHAT_MSG_MONSTER_YELL] A hunger lost to the ages. One which I shall reclaim!#Iridikron###Alphal##0#0##0#14601#nil#0#false#false#false#false", -- [2646]
--"<437.69 22:16:21> [DBM_Debug] ENCOUNTER_START event fired: 2669 Iridikron 8 5#nil", -- [2655]
function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.PrePullRP or msg:find(L.PrePullRP)) then
		self:SendSync("IridikronRP")--Syncing to help unlocalized clients
	end
end

function mod:OnSync(msg)
	if msg == "IridikronRP" and self:AntiSpam(10, 2) then
		timerRP:Start(34.6)
	end
end
