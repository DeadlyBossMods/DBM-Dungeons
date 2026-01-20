local mod	= DBM:NewMod(2650, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226396)
mod:SetEncounterID(3053)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(470038, true, 470038, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(470038, "linegather", 2)
end

--[[
mod:RegisterEvents(
	"SPELL_CAST_SUCCESS 1214337"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 473070 473114 469478",
	"SPELL_AURA_APPLIED 470038 472819",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)
--]]

--[[
(ability.id = 473070 or ability.id = 473114 or ability.id = 469478) and type = "begincast"
 or ability.id = 472819 and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--[[
local specWarnRazorchokeVines				= mod:NewSpecialWarningYouCount(470038, nil, nil, nil, 1, 2)--Pre target debuff
local specWarnVinePartner					= mod:NewSpecialWarningLink(470039, nil, nil, nil, 1, 2)
local yellRazorchokeVines					= mod:NewIconTargetYell(470039)
--local yellInfestationFades				= mod:NewShortFadesYell(433740)
local specWarnAwakenSwamp					= mod:NewSpecialWarningDodgeCount(473070, nil, nil, nil, 2, 2)
local specWarnMudslide						= mod:NewSpecialWarningDodgeCount(473114, nil, nil, nil, 2, 2)
local specWarnSludgeClaws					= mod:NewSpecialWarningDefensive(469478, nil, nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerRP								= mod:NewRPTimer(19)
local timerRazorchokeVinesCD				= mod:NewNextCountTimer(30, 470039, nil, nil, nil, 3)
local timerAwakenSwampCD					= mod:NewNextCountTimer(30, 473070, nil, nil, nil, 3)
local timerMudslideCD						= mod:NewNextCountTimer(30, 473114, nil, nil, nil, 3)
local timerSludgeClawsCD					= mod:NewNextCountTimer(30, 469478, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod.vb.vinesCount = 0
mod.vb.swampCount = 0
mod.vb.mudslideCount = 0
mod.vb.clawsCount = 0
local vineTargets = {}

function mod:OnCombatStart(delay)
	self.vb.vinesCount = 0
	self.vb.swampCount = 0
	self.vb.mudslideCount = 0
	self.vb.clawsCount = 0
	timerSludgeClawsCD:Start(2-delay, 1)
--	timerRazorchokeVinesCD:Start(1-delay, 1)--Now cast instantly on pull
	timerMudslideCD:Start(9-delay, 1)
	timerAwakenSwampCD:Start(19-delay, 1)
end

function mod:OnCombatEnd()
	table.wipe(vineTargets)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 473070 then
		self.vb.swampCount = self.vb.swampCount + 1
		specWarnAwakenSwamp:Show(self.vb.swampCount)
		specWarnAwakenSwamp:Play("watchstep")
		timerAwakenSwampCD:Start(nil, self.vb.swampCount+1)
	elseif spellId == 473114 then
		self.vb.mudslideCount = self.vb.mudslideCount + 1
		specWarnMudslide:Show(self.vb.mudslideCount)
		specWarnMudslide:Play("watchstep")
		timerMudslideCD:Start(nil, self.vb.mudslideCount+1)
	elseif spellId == 469478 then
		self.vb.clawsCount = self.vb.clawsCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSludgeClaws:Show()
			specWarnSludgeClaws:Play("defensive")
		end
		timerSludgeClawsCD:Start(nil, self.vb.clawsCount+1)
	end
end

--"<147.34 22:50:30> [CLEU] SPELL_CAST_SUCCESS#Player-77-0F82F3AB#Possecutor-Thunderlord(100.0%-65.0%)#Creature-0-4212-2773-29843-234373-000014141A#Bomb Pile#1214337#Plant Bombs#nil#nil#nil#nil#nil#nil",
--"<161.44 22:50:44> [PLAYER_TARGET_CHANGED] 82 Hostile (elite Elemental) - Swampface # Vehicle-0-4212-2773-29843-226396-000014147D",
--"<166.37 22:50:49> [NAME_PLATE_UNIT_ADDED] Swampface#Vehicle-0-4212-2773-29843-226396-000014147D",
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 1214337 and self:AntiSpam(5, 1) then
		timerRP:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 470038 then--Pre target debuff everyone gets at once
		if args:IsPlayer() then
			specWarnRazorchokeVines:Show(self.vb.vinesCount)
			specWarnRazorchokeVines:Play("gathershare")
		end
	elseif spellId == 472819 then--Pairing debuff that links players in sets of 2
		vineTargets[#vineTargets + 1] = args.destName
		if #vineTargets % 2 == 0 then
			local icon = #vineTargets / 2
			local playerIsInPair = false
			if vineTargets[#vineTargets-1] == UnitName("player") then
				specWarnVinePartner:Show(vineTargets[#vineTargets])
				specWarnVinePartner:Play("linegather")
				playerIsInPair = true
			elseif vineTargets[#vineTargets] == UnitName("player") then
				specWarnVinePartner:Show(vineTargets[#vineTargets-1])
				specWarnVinePartner:Play("linegather")
				playerIsInPair = true
			end
			if playerIsInPair then
				yellRazorchokeVines:Yell(icon)
			end
		end
	end
end

--Vines Cast not in combat log (only debuffs, but this is more efficent timer start)
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 470039 then
		table.wipe(vineTargets)
		self.vb.vinesCount = self.vb.vinesCount + 1
		timerRazorchokeVinesCD:Start(nil, self.vb.vinesCount+1)
	end
end
--]]
