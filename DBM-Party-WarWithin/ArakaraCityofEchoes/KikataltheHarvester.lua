local mod	= DBM:NewMod(2585, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(215407)
mod:SetEncounterID(2901)
mod:SetHotfixNoticeRev(20240630000000)
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
local timerCosmicSingularityCD				= mod:NewCDCountTimer(46.1, 432117, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)--54.6 old
local timerVenomVolleyCD					= mod:NewCDCountTimer(27.9, 432227, nil, nil, nil, 2, nil, DBM_COMMON_L.POISON_ICON)--22.6-23 old
local timerEruptingWebsCD					= mod:NewCDCountTimer(18.1, 432130, nil, nil, nil, 3)--18.1-19.3

--local castsPerGUID = {}

mod.vb.cosmicCount = 0
mod.vb.venomCount = 0
mod.vb.eruptingCount = 0

function mod:OnCombatStart(delay)
	self.vb.cosmicCount = 0
	self.vb.venomCount = 0
	self.vb.eruptingCount = 0
	timerAddsCD:Start()--3
	timerEruptingWebsCD:Start(7-delay, 1)
	timerVenomVolleyCD:Start(12-delay, 1)--16.8 on normal still?
	timerCosmicSingularityCD:Start(35.1-delay, 1)--26.5 on normal still?
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 432117 then
		self.vb.cosmicCount = self.vb.cosmicCount + 1
		specWarnCosmicSingularity:Show(DBM_COMMON_L.POOL)
		specWarnCosmicSingularity:Play("movetopool")
		timerCosmicSingularityCD:Start(nil, self.vb.cosmicCount+1)
		timerAddsCD:Stop()
		timerAddsCD:Start(3.4)
		timerVenomVolleyCD:Stop()
		timerEruptingWebsCD:Stop()
		timerVenomVolleyCD:Start(7.2, self.vb.venomCount+1)--23 old
		timerEruptingWebsCD:Start(13.3, self.vb.eruptingCount+1)
	elseif spellId == 432227 then
		self.vb.venomCount = self.vb.venomCount + 1
		if self.Options.SpecWarn432227dispel and self:CheckDispelFilter("poison") then
			specWarnVenomVolley:Show(DBM_COMMON_L.ALLIES)
			specWarnVenomVolley:Play("helpdispel")
		else
			warnVenomVolley:Show(self.vb.venomCount)
		end
		--Start next timer if cosmic is far enough away, else wait for cosmic to restart timer
		if timerCosmicSingularityCD:GetRemaining(self.vb.cosmicCount+1) >= 27.9 then
			timerVenomVolleyCD:Start(nil, self.vb.venomCount+1)
		end
	elseif spellId == 432130 then
		self.vb.eruptingCount = self.vb.eruptingCount + 1
		specWarnEruptingWebs:Show(self.vb.eruptingCount)
		specWarnEruptingWebs:Play("watchstep")
		--Start next timer if cosmic is far enough away, else wait for cosmic to restart timer
		if timerCosmicSingularityCD:GetRemaining(self.vb.cosmicCount+1) >= 18.1 then
			timerEruptingWebsCD:Start(nil, self.vb.eruptingCount+1)
		end
		timerAddsCD:Stop()
		timerAddsCD:Start(2.1)--2.1-5
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
