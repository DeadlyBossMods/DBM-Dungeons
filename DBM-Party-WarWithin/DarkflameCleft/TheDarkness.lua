local mod	= DBM:NewMod(2561, "DBM-Party-WarWithin", 1, 1210)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(208747)
mod:SetEncounterID(2788)
mod:SetHotfixNoticeRev(20250222000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2651)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 426943 428266 427025 427011 427176",
	"SPELL_CAST_SUCCESS 427157",
	"SPELL_AURA_APPLIED 420307 427015",
	"SPELL_AURA_REMOVED 427015"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, more data to confirm Rising Gloom is cast every 10 seconds once candles are gone
--TODO, candle tracking?
--TODO, tracking Candlebearers?
--[[
(ability.id = 426943 or ability.id = 428266 or ability.id = 427025 or ability.id = 427011) and type = "begincast"
 or ability.id = 427157 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnRisingGloom						= mod:NewSpellAnnounce(426943, 4)
local warnCandlelight						= mod:NewTargetNoFilterAnnounce(420307, 1)
local warnShadowblast						= mod:NewTargetNoFilterAnnounce(427011, 3)

local specWarnEternalDarkness				= mod:NewSpecialWarningCount(428266, nil, nil, nil, 2, 2)
local yellCandlelight						= mod:NewShortYell(420307, nil, nil, nil, "YELL")
local specWarnCallDarkspawn					= mod:NewSpecialWarningInterruptCount(427157, "HasInterrupt", nil, nil, 1, 2)
local specWarnUmbralSlash					= mod:NewSpecialWarningDodgeCount(427025, nil, nil, nil, 2, 15)
local specWarnShadowblast					= mod:NewSpecialWarningMoveAway(427011, nil, nil, nil, 2, 2)
local yellShadowblast						= mod:NewShortYell(427011)
local yellShadowblastFades					= mod:NewShortFadesYell(427011)
local specWarnDrainLight					= mod:NewSpecialWarningInterrupt(427176, "HasInterrupt", nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerEternalDarknessCD				= mod:NewCDCountTimer(63.1, 428266, nil, nil, nil, 2, nil, DBM_COMMON_L.MAGIC_ICON)
local timerCallDarkspawnCD					= mod:NewVarCountTimer("v46.2-51.8", 427157, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerUmbralSlashCD					= mod:NewVarCountTimer("v30.3-34", 427025, nil, nil, nil, 3)
local timerShadowblastCD					= mod:NewVarCountTimer("v30.3-34", 427011, nil, nil, nil, 3)

mod.vb.eternalCount = 0
mod.vb.callCount = 0
mod.vb.umbralCount = 0
mod.vb.blastCount = 0

mod:AddInfoFrameOption(422806, false)

function mod:OnCombatStart(delay)
	self.vb.eternalCount = 0
	self.vb.callCount = 0
	self.vb.umbralCount = 0
	self.vb.blastCount = 0
	timerShadowblastCD:Start(10.1-delay, 1)
	timerUmbralSlashCD:Start(20.3-delay, 1)
	timerCallDarkspawnCD:Start(26.4-delay, 1)
	if self:IsMythic() then
		timerEternalDarknessCD:Start(30.5-delay, 1)
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM:GetSpellName(422806))
		DBM.InfoFrame:Show(5, "playerbaddebuff", 422806)
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 426943 then
		warnRisingGloom:Show()
	elseif spellId == 428266 then
		self.vb.eternalCount = self.vb.eternalCount + 1
		specWarnEternalDarkness:Show(self.vb.eternalCount)
		specWarnEternalDarkness:Play("aesoon")
		--30.5, 63.1, 63.9
		timerEternalDarknessCD:Start(nil, self.vb.eternalCount+1)
	elseif spellId == 427025 then
		self.vb.umbralCount = self.vb.umbralCount + 1
		specWarnUmbralSlash:Show(self.vb.umbralCount)
		specWarnUmbralSlash:Play("frontal")
		--20.3, 30.8, 30.3, 31.1, 30.3, 31.5
		timerUmbralSlashCD:Start(nil, self.vb.umbralCount+1)
	elseif spellId == 427011 then
		self.vb.blastCount = self.vb.blastCount + 1
		--10.6, 30.8, 30.3, 32.3, 30.3, 31.5
		timerShadowblastCD:Start(nil, self.vb.blastCount+1)
	elseif spellId == 427176 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDrainLight:Show(args.sourceName)
		specWarnDrainLight:Play("kickcast")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 427157 then
		self.vb.callCount = self.vb.callCount + 1
		specWarnCallDarkspawn:Show(args.sourceName, self.vb.callCount)
		specWarnCallDarkspawn:Play("kickcast")
		--26.4, 51.4, 46.9, 47.3
		timerCallDarkspawnCD:Start(nil, self.vb.callCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 420307 then
		warnCandlelight:Show(args.destName)
		if args:IsPlayer() then
			yellCandlelight:Yell()
		end
	elseif spellId == 427015 then
		if args:IsPlayer() then
			specWarnShadowblast:Show()
			specWarnShadowblast:Play("runout")
			yellShadowblast:Yell()
			yellShadowblastFades:Countdown(spellId)
		else
			warnShadowblast:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 427015 then
		if args:IsPlayer() then
			yellShadowblastFades:Cancel()
		end
	end
end

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
