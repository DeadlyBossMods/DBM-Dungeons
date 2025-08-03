local mod	= DBM:NewMod(2677, "DBM-Party-WarWithin", 10, 1303)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234935)
mod:SetEncounterID(3109)
mod:SetHotfixNoticeRev(20250728000000)
--mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2830)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1224793 1236703 1225218 1225174",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 1224865 1226444",
	"SPELL_AURA_APPLIED_DOSE 1224865"
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[

 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, how does dread of the unknown work, it's poorly writen in journal. do you dodge stuff on ground, or do players get debuffs and have to scatter to not hit each other
local warnWhispersofFate				= mod:NewCountAnnounce(1224793, 3)
local warnFatebound						= mod:NewCountAnnounce(1224865, 3, nil, nil, DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.stack:format(1224865))

local specWarnWoundedFate				= mod:NewSpecialWarningYou(1226444, nil, nil, nil, 1, 2)
local specWarnEternalWeave				= mod:NewSpecialWarningCount(1236703, nil, nil, nil, 2, 2)
local specWarnDreadoftheUnknown			= mod:NewSpecialWarningCount(1225218, nil, nil, nil, 2, 2)--Redo audio when mechanic clear
local specWarnCeremonialDaggers			= mod:NewSpecialWarningSoakCount(1225174, nil, nil, nil, 2, 2)

local timerWhispersofFateCD				= mod:NewCDCountTimer(30, 1224793, nil, nil, nil, 5)
local timerEternalWeaveCD				= mod:NewCDCountTimer(87.5, 1236703, nil, nil, nil, 6)
local timerDreadoftheUnknownCD			= mod:NewCDCountTimer(87.5, 1225218, nil, nil, nil, 2)
local timerCeremonialDaggersCD			= mod:NewCDCountTimer(87.5, 1225174, nil, nil, nil, 3)

mod.vb.fateCount = 0
mod.vb.weaveCount = 0
mod.vb.dreadCount = 0
mod.vb.daggerCount = 0

function mod:OnCombatStart(delay)
	self.vb.fateCount = 0
	self.vb.weaveCount = 0
	self.vb.dreadCount = 0
	self.vb.daggerCount = 0
	timerWhispersofFateCD:Start(6.4-delay, 1)
	timerCeremonialDaggersCD:Start(10-delay, 1)
	timerDreadoftheUnknownCD:Start(28.2-delay, 1)
	timerEternalWeaveCD:Start(56.2-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 1224793 then
		self.vb.fateCount = self.vb.fateCount + 1
		warnWhispersofFate:Show(self.vb.fateCount)
		if self.vb.fateCount % 3 == 0 then
			timerWhispersofFateCD:Start(51, self.vb.fateCount+1)
		else
			timerWhispersofFateCD:Start(18.2, self.vb.fateCount+1)
		end
	elseif spellId == 1236703 then
		self.vb.weaveCount = self.vb.weaveCount + 1
		specWarnEternalWeave:Show(self.vb.weaveCount)
		specWarnEternalWeave:Play("phasechange")
		timerEternalWeaveCD:Start(nil, self.vb.weaveCount+1)
	elseif spellId == 1225218 then
		self.vb.dreadCount = self.vb.dreadCount + 1
		specWarnDreadoftheUnknown:Show(self.vb.dreadCount)
		specWarnDreadoftheUnknown:Play("aesoon")
		timerDreadoftheUnknownCD:Start(nil, self.vb.dreadCount+1)
	elseif spellId == 1225174 then
		self.vb.daggerCount = self.vb.daggerCount + 1
		specWarnCeremonialDaggers:Show(self.vb.daggerCount)
		specWarnCeremonialDaggers:Play("helpsoak")
		if self.vb.daggerCount % 2 == 0 then
			timerCeremonialDaggersCD:Start(51, self.vb.daggerCount+1)
		else
			timerCeremonialDaggersCD:Start(36.4, self.vb.daggerCount+1)
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 458082 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 1224865 and args:IsPlayer() then
		warnFatebound:Show(args.amount or 1)
	elseif spellId == 1226444 and args:IsPlayer() then
		specWarnWoundedFate:Show()
		specWarnWoundedFate:Play("targetyou")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 445262 then

	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 433067 and destGUID == UnitGUID("player") and self:AntiSpam(3, 3) then
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
