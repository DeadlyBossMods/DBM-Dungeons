local mod	= DBM:NewMod(2509, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(194181)
mod:SetEncounterID(2562)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 385974 388537 386173 385958",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 386181",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 386181",
	"SPELL_PERIODIC_DAMAGE 386201",
	"SPELL_PERIODIC_MISSED 386201"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, arcane fissure is not timer based, it's energy. Boss passive energy gains plus orbs reaching boss. Maybe a base timer that's auto corrective?
local warnArcaneOrbs							= mod:NewCountAnnounce(385974, 3)--Professor Maxdormu
local warnManaBombs								= mod:NewTargetAnnounce(386173, 3)

local specWarnArcaneFissure						= mod:NewSpecialWarningDodge(388537, nil, nil, nil, 1, 2)
local specWarnManaBomb							= mod:NewSpecialWarningMoveAway(386181, nil, nil, nil, 1, 2)
local yellManaBomb								= mod:NewYell(386181)
local yellManaBombFades							= mod:NewShortFadesYell(386181)
local specWarnArcaneExpulsion					= mod:NewSpecialWarningDefensive(385958, nil, nil, nil, 1, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

local timerArcaneOrbsCD							= mod:NewAITimer(35, 385974, nil, nil, nil, 5)--Professor Maxdormu
--local timerArcaneFissureCD					= mod:NewAITimer(35, 388537, nil, nil, nil, 3)
local timerManaBombsCD							= mod:NewAITimer(35, 386173, nil, nil, nil, 3)
local timerArcaneExpulsionCD					= mod:NewAITimer(35, 385958, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--local berserkTimer							= mod:NewBerserkTimer(600)

--mod:AddRangeFrameOption("8")
--mod:AddInfoFrameOption(361651, true)
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

mod:GroupSpells(386173, 386181)--Group Mana Bombs with Mana Bomb

mod.vb.orbCount = 0

function mod:OnCombatStart(delay)
	self.vb.orbCount = 0
	timerArcaneOrbsCD:Start(1-delay)
	--timerArcaneFissureCD:Start(1-delay)
	timerManaBombsCD:Start(1-delay)
	timerArcaneExpulsionCD:Start(1-delay)
end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 385974 then
		self.vb.orbCount = self.vb.orbCount + 1
		warnArcaneOrbs:Show(self.vb.orbCount)
		timerArcaneOrbsCD:Start()
	elseif spellId == 388537 then
		specWarnArcaneFissure:Show()
		specWarnArcaneFissure:Play("watchstep")
	elseif spellId == 386173 then
		timerManaBombsCD:Start()
	elseif spellId == 385958 then
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnArcaneExpulsion:Show()
			specWarnArcaneExpulsion:Play("defensive")
		end
		timerArcaneExpulsionCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 362805 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 386181 then
		warnManaBombs:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnManaBomb:Show()
			specWarnManaBomb:Play("runout")
			yellManaBomb:Yell()
			yellManaBombFades:Countdown(spellId)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 386181 then
		if args:IsPlayer() then
			yellManaBombFades:Cancel()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 386201 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
