local mod	= DBM:NewMod(2585, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(215407)
mod:SetEncounterID(2901)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 432117 432227 432130",
	"SPELL_CAST_SUCCESS 431985"
--	"SPELL_AURA_APPLIED"
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, grasping spammy
--TODO, at least two really really really really long pulls to see what's going on with timers
--[[
(ability.id = 432117 or ability.id = 432227 or ability.id = 432130) and type = "begincast"
 or ability.id = 431985 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnVenomVolley						= mod:NewCountAnnounce(432227, 3)

local specWarnCosmicSingularity				= mod:NewSpecialWarningMoveTo(432117, nil, nil, nil, 3, 15)
local specWarnVenomVolley					= mod:NewSpecialWarningDispel(432227, "RemovePoison", nil, nil, 1, 2)
local specWarnEruptingWebs					= mod:NewSpecialWarningDodgeCount(432130, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerAddsCD							= mod:NewCDTimer(3, -28411, nil, nil, nil, 1, 431985)
local timerCosmicSingularityCD				= mod:NewAITimer(3, 432117, nil, nil, nil, 2, nil, DBM_COMMON_L.TANK_ICON)
local timerVenomVolleyCD					= mod:NewAITimer(22.6, 432227, nil, nil, nil, 2, nil, DBM_COMMON_L.POISON_ICON)
local timerEruptingWebsCD					= mod:NewAITimer(19.4, 432130, nil, nil, nil, 3)

--local castsPerGUID = {}

mod.vb.cosmicCount = 0
mod.vb.venomCount = 0
mod.vb.eruptingCount = 0

function mod:OnCombatStart(delay)
	self.vb.cosmicCount = 0
	self.vb.venomCount = 0
	self.vb.eruptingCount = 0
	timerAddsCD:Start()--3
	timerEruptingWebsCD:Start(1-delay)--7
	timerVenomVolleyCD:Start(1-delay)--16.8
	timerCosmicSingularityCD:Start(1-delay)--26.5
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 432117 then
		self.vb.cosmicCount = self.vb.cosmicCount + 1
		specWarnCosmicSingularity:Show(DBM_COMMON_L.POOL)
		specWarnCosmicSingularity:Play("movetopool")
		timerCosmicSingularityCD:Start()
		timerAddsCD:Restart(3.5)
	elseif spellId == 432227 then
		self.vb.venomCount = self.vb.venomCount + 1
		if self.Options.SpecWarn432227dispel and self:CheckDispelFilter("poison") then
			specWarnVenomVolley:Show(DBM_COMMON_L.ALLIES)
			specWarnVenomVolley:Play("helpdispel")
		else
			warnVenomVolley:Show(self.vb.venomCount)
		end
		timerVenomVolleyCD:Start()
	elseif spellId == 432130 then
		self.vb.eruptingCount = self.vb.eruptingCount + 1
		specWarnEruptingWebs:Show(self.vb.eruptingCount)
		specWarnEruptingWebs:Play("watchstep")
		timerEruptingWebsCD:Start()
		timerAddsCD:Restart(2.1)--2.1-5
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 431985 then
		timerAddsCD:Start()
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 432031 then
		if args:IsPlayer() then

		end
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
