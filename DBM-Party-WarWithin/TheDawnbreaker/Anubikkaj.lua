local mod	= DBM:NewMod(2581, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(211089)
mod:SetEncounterID(2838)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 427001 426860 426787 452127 452099"
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(target.name = "Anub'ikkaj" or target.name = "Ascendant Vis'coxria" or target.name = "Deathscreamer Iken'tak" or target.name = "Ixkreten the Unbreakable") and (type = "applybuff" or type = "removebuff" or type = "death" or type = "removebuffstack" or type = "applybuffstack")
 or (source.name = "Anub'ikkaj" or source.name = "Ascendant Vis'coxria" or source.name = "Deathscreamer Iken'tak" or source.name = "Ixkreten the Unbreakable") and (type = "cast" or type = "begincast" or type = "applybuff" or type = "removebuff" or type = "removebuffstack" or type = "applybuffstack") and not ability.id = 1
--]]
--TODO, auto marking Animate Shadows? need to see if has spell summon event or if they instantly cast congealed for GUID target scanner, else use CID based single scan
local warnAnimatedShadows					= mod:NewCountAnnounce(452127, 3)--Change to switch alert if they have to die asap

local specWarnTerrifyingSlam				= mod:NewSpecialWarningRunCount(427001, nil, nil, nil, 4, 2)
local specWarnDarkOrb						= mod:NewSpecialWarningDodgeCount(426860, nil, nil, nil, 2, 2)
local specWarnRadiantDecay					= mod:NewSpecialWarningDodgeCount(426787, nil, nil, nil, 2, 2)
--local yellSomeAbility						= mod:NewYell(372107)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)
local specWarnCongealedDarkness				= mod:NewSpecialWarningInterruptCount(452099, nil, nil, nil, 1, 2, 4)

local timerTerrifyingSlamCD					= mod:NewCDCountTimer(24, 427001, nil, nil, nil, 2)
local timerDarkOrbCD						= mod:NewCDCountTimer(24, 426860, nil, nil, nil, 3)
local timerRadiantDecayCD					= mod:NewCDCountTimer(24, 426787, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerAnimateShadowsCD					= mod:NewAITimer(24, 452127, nil, nil, nil, 1, nil, DBM_COMMON_L.MYTHIC_ICON)

mod:AddPrivateAuraSoundOption(426865, true, 426860, 1)--Dark Orb target

mod.vb.slamCount = 0
mod.vb.orbCount = 0
mod.vb.radiantCount = 0
mod.vb.addsCount = 0
local castsPerGUID = {}

function mod:OnCombatStart(delay)
	self.vb.slamCount = 0
	self.vb.orbCount = 0
	self.vb.radiantCount = 0
	self.vb.addsCount = 0
	table.wipe(castsPerGUID)
	timerDarkOrbCD:Start(6-delay, 1)
	timerTerrifyingSlamCD:Start(13-delay, 1)
	timerRadiantDecayCD:Start(20-delay, 1)
	if self:IsMythic() then
		timerAnimateShadowsCD:Start(1-delay)
	end
	self:EnablePrivateAuraSound(426865, "targetyou", 2)--Dark Orb
	self:EnablePrivateAuraSound(450855, "targetyou", 2, 426865)--Register Additional ID
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 427001 then
		self.vb.slamCount = self.vb.slamCount + 1
		specWarnTerrifyingSlam:Show(self.vb.slamCount)
		if DBM:UnitBuff("boss1", 427153, 427154) then--Terrifying Empowerment
			specWarnTerrifyingSlam:Play("carefly")
			specWarnTerrifyingSlam:ScheduleVoice(1.2, "fearsoon")
		else
			specWarnTerrifyingSlam:Play("justrun")
		end
		timerTerrifyingSlamCD:Start(nil, self.vb.slamCount+1)
	elseif spellId == 426860 then
		self.vb.orbCount = self.vb.orbCount + 1
		specWarnDarkOrb:Show()
		specWarnDarkOrb:Play("watchorb")
		timerDarkOrbCD:Start(nil, self.vb.orbCount+1)
	elseif spellId == 426787 then
		self.vb.radiantCount = self.vb.radiantCount + 1
		specWarnRadiantDecay:Show(self.vb.radiantCount)
		specWarnRadiantDecay:Play("aesoon")
		timerRadiantDecayCD:Start(nil, self.vb.radiantCount+1)
	elseif spellId == 452127 then
		self.vb.addsCount = self.vb.addsCount + 1
		warnAnimatedShadows:Show(self.vb.addsCount)
		timerAnimateShadowsCD:Start()--nil, self.vb.addsCount+1
	elseif spellId == 452099 then
		if not castsPerGUID[args.sourceGUID] then
			castsPerGUID[args.sourceGUID] = 0
		end
		castsPerGUID[args.sourceGUID] = castsPerGUID[args.sourceGUID] + 1
		local count = castsPerGUID[args.sourceGUID]
		if self:CheckInterruptFilter(args.sourceGUID, false, false) then--Count interrupt, so cooldown is not checked
			specWarnCongealedDarkness:Show(args.sourceName, count)
			if count < 6 then
				specWarnCongealedDarkness:Play("kick"..count.."r")
			else
				specWarnCongealedDarkness:Play("kickcast")
			end
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 372858 then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 372858 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
