local creatureID
local addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId
if UnitFactionGroup("player") == "Alliance" then--TODO, might have to change this to check party leader not player, due to cross faction groups.
	creatureID = 203679--Anduin Lothar
	addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId = 417018, 417030, 418059, 418056, 418047, 418062
else--Horde
	creatureID = 203678--Grommash Hellscream
	addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId = 407122, 407121, 410254, 408228, 418046, 410496
end
local mod	= DBM:NewMod(2533, "DBM-Party-Dragonflight", 9, 1209)--Alliance ID used, horde is 2534
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(creatureID)
mod:SetEncounterID(2672)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20230709000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 417018 407122 410234 418059 410254 418056 408228 418047 418046",
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
(ability.id = 417018 or ability.id = 407122 or ability.id = 410234 or ability.id = 418059 or ability.id = 410254 or ability.id = 418056 or ability.id = 408228 or ability.id = 418047 or ability.id = 418046) and type = "begincast"
 or (ability.id = 418062 or ability.id = 410496) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (ability.id = 417030 or ability.id = 407121 or ability.id = 407122 or ability.id = 410234) and type = "begincast"
--]]
--NOTE: Serrated and fireball abilities are spammed, so no timer or alert
--TODO, Mortal Strikes/Decapitate was bugged and only cast once then never again. Need to see if this is fixed on live to enable more timers
--TODO, GTFO for add aoe? Logs I had nobody took damage from it so couldn't do yet
--TODO, targetscan/detect bladestorm target?
--TODO, corrective spellId swaps on engage to all objects if group lead is passed to other faction? seems SUPER annoying, might only do it for CID and nothing else, depends on what BWs does since we have to match it for WAs
--The Infinite Battlefield
mod:AddTimerLine(DBM:EJ_GetSectionInfo(26514))
local warnAddAoE									= mod:NewSpellAnnounce(addAOESpellId, 3)
local warnAddDebuff									= mod:NewTargetNoFilterAnnounce(addDebuffSpellId, 3, nil, false)

--local specWarnManaBomb							= mod:NewSpecialWarningMoveAway(386181, nil, nil, nil, 1, 2)
--local yellManaBomb								= mod:NewYell(386181)
--local yellManaBombFades							= mod:NewShortFadesYell(386181)
--local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

local timerAddAoECD									= mod:NewCDTimer(12.1, addAOESpellId, nil, nil, nil, 3)

--mod:AddInfoFrameOption(391977, true)
--Boss (Anduin Lothar / Grommash Hellscream
mod:AddTimerLine(DBM_COMMON_L.BOSS)
local warnBladestorm								= mod:NewCountAnnounce(410234, 3)
local warnRally										= mod:NewCountAnnounce(rallySpellId, 2)
local warnCry										= mod:NewCountAnnounce(crySpellId, 2)
local warnShockwave									= mod:NewCountAnnounce(shockwaveSpellId, 3)--2nd and 3rd cast

local specWarnTankBuster							= mod:NewSpecialWarningDefensive(tankSpellId, nil, nil, nil, 1, 2)
local specWarnShockwave								= mod:NewSpecialWarningDodge(shockwaveSpellId, nil, nil, nil, 2, 2)--First cast in set

local timerBladestormCD								= mod:NewCDCountTimer(24.2, 410234, nil, nil, nil, 3)
local timerTankBusterCD								= mod:NewCDCountTimer(100, tankSpellId, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerShockwaveCD								= mod:NewCDCountTimer(19.1, shockwaveSpellId, nil, nil, nil, 3)
local timerRallyCD									= mod:NewCDCountTimer(24.2, rallySpellId, nil, nil, nil, 5)
local timerCryCD									= mod:NewCDCountTimer(19.4, crySpellId, nil, nil, nil, 2)

mod.vb.bladestormCount = 0
mod.vb.shockwaveSet = 0
mod.vb.shockwaveCount = 0
mod.vb.tankBusterCount = 0
mod.vb.rallyCount = 0
mod.vb.cryCount = 0

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
	self.vb.bladestormCount = 0
	self.vb.shockwaveSet = 0
	self.vb.shockwaveCount = 0
	self.vb.tankBusterCount = 0
	self.vb.rallyCount = 0
	self.vb.cryCount = 0
	timerTankBusterCD:Start(7.2-delay, 1)--Mortal Strikes/Decapitate
	timerShockwaveCD:Start(12-delay, 1)--Shockwave
	timerCryCD:Start(21.5-delay)--Battle Cry/War Cry
	timerRallyCD:Start(21.7-delay, 1)--For the alliance/horde
	timerBladestormCD:Start(24.1-delay, 1)
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
	if spellId == 417018 or spellId == 407122 then--Blizzard / Rain of Fire
		warnAddAoE:Show()
		timerAddAoECD:Start(nil, args.sourceGUID)
	elseif spellId == 410234 then--Same spell in both
		self.vb.bladestormCount = self.vb.bladestormCount + 1
		warnBladestorm:Show(self.vb.bladestormCount)
		timerBladestormCD:Start(nil, self.vb.bladestormCount+1)
	elseif spellId == 418059 or spellId == 410254 then--Mortal Strikes / Decapitate
		self.vb.tankBusterCount = self.vb.tankBusterCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTankBuster:Show()
			specWarnTankBuster:Play("defensive")
		end
--		timerTankBusterCD:Start(nil, self.vb.tankBusterCount+1)
	elseif spellId == 418056 or spellId == 408228 then--Shockwave / Shockwave (formerly Death Wish)
		self.vb.shockwaveCount = self.vb.shockwaveCount + 1
		if self.vb.shockwaveCount == 1 then
			self.vb.shockwaveSet = self.vb.shockwaveSet + 1
			specWarnShockwave:Show(self.vb.shockwaveSet)
			specWarnShockwave:Play("shockwave")
		else
			warnShockwave:Show(self.vb.shockwaveSet)
			if self.vb.shockwaveCount == 3 then
				timerShockwaveCD:Start(19.1, self.vb.shockwaveSet+1)--19.1-24.3
				self.vb.shockwaveCount = 0
			end
		end
	elseif spellId == 418047 or spellId == 418046 then--For the alliance, for the horde
		self.vb.rallyCount = self.vb.rallyCount + 1
		warnRally:Show(self.vb.rallyCount)
		--is 11.99 and 12.33 alternating. kinda interesting considering .34 doesn't make such a huge difference
		--A pattern is a pattern though so might as well support it
		if self.vb.rallyCount % 2 == 0 then
			timerRallyCD:Start(12, self.vb.rallyCount+1)
		else
			timerRallyCD:Start(12.3, self.vb.rallyCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 418062 or spellId == 410496 then--Battle Cry, War Cry
		self.vb.cryCount = self.vb.cryCount + 1
		warnCry:Show(self.vb.cryCount)
		timerCryCD:Start(nil, self.vb.cryCount+1)
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
	if cid == 206351 or cid == 203857 then--Alliance Conjuror / Horde Warlock
		timerAddAoECD:Stop(args.destGUID)
--	elseif cid == 206352 or cid == 203799 then--Alliance Archer/Horde Axe Thrower

	end
	if args:IsDestTypePlayer() then--Trigger Cd reset on tank buster
		timerTankBusterCD:Stop()
	end
end
