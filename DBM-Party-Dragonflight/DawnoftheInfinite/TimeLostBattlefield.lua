local creatureID
local seratedSpellId, addAOESpellId, addDebuffSpellId, tankSpellId, frontalSpellId, rallySpellId, crySpellId
if UnitFactionGroup("player") == "Alliance" then--TODO, might have to change this to check party leader not player, due to cross faction groups.
	creatureID = 203679--Anduin Lothar
	seratedSpellId, addAOESpellId, addDebuffSpellId, tankSpellId, frontalSpellId, rallySpellId, crySpellId = 418009, 417018, 417030, 418059, 418056, 418047, 418062
else--Horde
	creatureID = 203678--Grommash Hellscream
	seratedSpellId, addAOESpellId, addDebuffSpellId, tankSpellId, frontalSpellId, rallySpellId, crySpellId = 407120, 407122, 407121, 410254, 408228, 418046, 410496
end
local mod	= DBM:NewMod(2533, "DBM-Party-Dragonflight", 9, 1209)--Alliance ID used, horde is 2534
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(creatureID)
mod:SetEncounterID(2672)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetHotfixNoticeRev(20221015000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 407120 418009 417018 407122 417030 407121 410234 418059 410254 418056 408228 418047 418046",
	"SPELL_CAST_SUCCESS 418062 410496",
	"SPELL_AURA_APPLIED 417030 407121",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[

--]]
--TODO, target scan serated axe/arrow? announce it?
--TODO, GTFO for add aoe?
--TODO, targetscan/detect bladestorm target?
--TODO, corrective spellId swaps on engage to all objects if group lead is passed to other faction? seems SUPER annoying, might only do it for CID and nothing else
--The Infinite Battlefield
mod:AddTimerLine(DBM:EJ_GetSectionInfo(26514))
local warnAddAoE									= mod:NewSpellAnnounce(addAOESpellId, 3)
local warnAddDebuff									= mod:NewTargetNoFilterAnnounce(addDebuffSpellId, 3, nil, "RemoveMagic")

--local specWarnManaBomb							= mod:NewSpecialWarningMoveAway(386181, nil, nil, nil, 1, 2)
--local yellManaBomb								= mod:NewYell(386181)
--local yellManaBombFades							= mod:NewShortFadesYell(386181)
--local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

local timerSeratedCD								= mod:NewAITimer(19.4, seratedSpellId, nil, nil, nil, 3)--Serated Axe/Serrated Arrows
local timerAddAoECD									= mod:NewAITimer(19.4, addAOESpellId, nil, nil, nil, 3)
local timerAddDebuffCD								= mod:NewAITimer(19.4, addDebuffSpellId, nil, nil, nil, 3)

--mod:AddInfoFrameOption(391977, true)
--Boss (Anduin Lothar / Grommash Hellscream
mod:AddTimerLine(DBM:EJ_GetSectionInfo(DBM_COMMON_L.BOSS))
local warnBladestorm								= mod:NewSpellAnnounce(410234, 3)
local warnRally										= mod:NewSpellAnnounce(rallySpellId, 2)
local warnCry										= mod:NewSpellAnnounce(crySpellId, 2)

local specWarnTankBuster							= mod:NewSpecialWarningDefensive(tankSpellId, nil, nil, nil, 1, 2)
local specWarnFrontal								= mod:NewSpecialWarningDodge(frontalSpellId, nil, nil, nil, 2, 2)

local timerBladestormCD								= mod:NewAITimer(19.4, 410234, nil, nil, nil, 3)
local timerTankBusterCD								= mod:NewAITimer(19.4, tankSpellId, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFrontalCD								= mod:NewAITimer(19.4, frontalSpellId, nil, nil, nil, 3)
local timerRallyCD									= mod:NewAITimer(19.4, rallySpellId, nil, nil, nil, 5)
local timerCryCD									= mod:NewAITimer(19.4, crySpellId, nil, nil, nil, 2)

local function checkWhichBoss(self)
	local cid = self:GetUnitCreatureId("boss1")
	if cid then
		if cid ~= creatureID then--cid mismatch, correct it on engage
			creatureID = cid
			self:SetCreatureID(cid)
		end
	end
end

function mod:OnCombatStart(delay)
	timerBladestormCD:Start(1-delay)
	timerTankBusterCD:Start(1-delay)
	timerFrontalCD:Start(1-delay)
	timerRallyCD:Start(1-delay)
	timerCryCD:Start(1-delay)
	self:Schedule(1.5, checkWhichBoss, self)
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
	if spellId == 407120 or spellId == 418009 then--Axe / Arrow
		timerSeratedCD:Start(nil, args.sourceGUID)
	elseif spellId == 417018 or spellId == 407122 then--Blizzard / Rain of Fire
		warnAddAoE:Show()
		timerAddAoECD:Start(nil, args.sourceGUID)
	elseif spellId == 417030 or spellId == 407121 then--Fireball / Immolate
		timerAddDebuffCD:Start(nil, args.sourceGUID)
	elseif spellId == 410234 then--Same spell in both
		warnBladestorm:Show()
		timerBladestormCD:Start()
	elseif spellId == 418059 or spellId == 410254 then--Mortal Strikes / Decapitate
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTankBuster:Show()
			specWarnTankBuster:Play("defensive")
		end
		timerTankBusterCD:Start()
	elseif spellId == 418056 or spellId == 408228 then--Shockwave / Death Wish
		specWarnFrontal:Show()
		specWarnFrontal:Play("shockwave")
		timerFrontalCD:Start()
	elseif spellId == 418047 or spellId == 418046 then--For the alliance, for the horde
		warnRally:Show()
		timerRallyCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 418062 or spellId == 410496 then--Battle Cry, War Cry
		warnCry:Show()
		timerCryCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 417030 or spellId == 407121 then--Fireball / Immolate
		warnAddDebuff:Show(args.destName)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 386181 then

	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 386201 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 206352 or cid == 203799 then--Alliance Archer/Horde Axe Thrower
		timerSeratedCD:Stop(args.destGUID)
	elseif cid == 206351 or cid == 203857 then--Alliance Conjuror / Horde Warlock
		timerAddAoECD:Stop(args.destGUID)
		timerAddDebuffCD:Stop(args.destGUID)
	end
	if args:IsDestTypePlayer() then--Trigger Cd reset on tank buster
		timerTankBusterCD:Stop()
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
