local mod	= DBM:NewMod("TheRookeryTrash", "DBM-Party-WarWithin", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2648)

mod:RegisterEvents(
	"SPELL_CAST_START 426893 450628 427323 427404 430013 427616 430754 423979 430805 430812 432959",
	"SPELL_CAST_SUCCESS 427260 430805 432959 426893 450628 427323 427404 430013 427616 430754 430179 423979 430812",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 430179 427260",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--TODO, more spells probably
--[[
(ability.id = 426893 or ability.id = 450628 or ability.id = 427323 or ability.id = 427404 or ability.id = 430013 or ability.id = 427616 or ability.id = 430754 or ability.id = 423979 or ability.id = 430179 or ability.id = 430805 or ability.id = 430812 or ability.id = 432959) and (type = "begincast" or type = "cast")
 or ability.id = 427260 and type = "cast"
 or stoppedAbility.id = 430805 or stoppedAbility.id = 432959
--]]
--TODO, add Oblivion Wave frontal on tank
local warnEntropyShield						= mod:NewCastAnnounce(450628, 3)
local warnEnergizedBarrage 					= mod:NewCastAnnounce(427616, 3, nil, nil, "Tank")--Only warn tank by default since tank should aim it away from anyone else
local warnVoidShell							= mod:NewCastAnnounce(430754, 3, nil, nil, nil, nil, nil, 3)
local warnAttractingShadows					= mod:NewCastAnnounce(430812, 3, nil, nil, nil, nil, nil, 12)

local specWarnBoundingVoid					= mod:NewSpecialWarningDodge(426893, nil, nil, nil, 1, 2)
local specWarnChargedBombardment			= mod:NewSpecialWarningDodge(427323, nil, nil, nil, 1, 2)
local specWarnLocalizedStorm				= mod:NewSpecialWarningSpell(427404, nil, nil, nil, 1, 2)--Maybe change to Break LOS alert, needs more testing
local specWarnThunderstrike					= mod:NewSpecialWarningDodge(430013, nil, nil, nil, 1, 2)
local specWarnImplosion						= mod:NewSpecialWarningMoveAway(423979, nil, nil, nil, 1, 2)
local yellImplosion							= mod:NewShortYell(423979)
local specWarnSeepingCorruption				= mod:NewSpecialWarningMoveAway(430179, nil, nil, nil, 1, 2)
local yellSeepingCorruption					= mod:NewShortYell(430179)
local specWarnSeepingCorruptionDispel		= mod:NewSpecialWarningDispel(430179, "RemoveCurse", nil, nil, 1, 2)
local specWarnEnrageRook					= mod:NewSpecialWarningDispel(427260, "RemoveEnrage", nil, nil, 1, 2)
local specWarnArcingVoid					= mod:NewSpecialWarningInterrupt(430805, "HasInterrupt", nil, nil, 1, 2)
local specWarnVoidVolley					= mod:NewSpecialWarningInterrupt(432959, "HasInterrupt", nil, nil, 1, 2)

--Almost all timers probably wrong now, but can't use public WCL to fix this since all logs short
--Also, all of them were moved to success preemtively but if stops actually DO put any of these on CD, then the preemtive move actually broke timer
local timerBoundingVoidCD					= mod:NewCDPNPTimer(10.1, 426893, nil, nil, nil, 3)
local timerEntropyShieldCD					= mod:NewCDNPTimer(25.2, 450628, nil, nil, nil, 5)--Single cast instance, poor sample
local timerChargedBombardmentCD				= mod:NewCDPNPTimer(17.6, 427323, nil, nil, nil, 3)
local timerLocalizedStormCD					= mod:NewCDNPTimer(25.9, 427404, nil, nil, nil, 2)
local timerThunderstrikeCD					= mod:NewCDNPTimer(15.1, 430013, nil, nil, nil, 3)
local timerEnergizedBarrageCD				= mod:NewCDPNPTimer(20, 427616, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEnrageRookCD						= mod:NewCDNPTimer(15, 427260, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)--17-2 due to waiting for success
local timerVoidShellCD						= mod:NewCDNPTimer(18.7, 430754, nil, nil, nil, 5)
local timerSeepingCorruptionCD				= mod:NewCDNPTimer(25.2, 430179, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerImplosionCD						= mod:NewCDNPTimer(15.5, 423979, nil, nil, nil, 3)
local timerArcingVoidCD						= mod:NewCDPNPTimer(13.5, 430805, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerVoidVolleyCD						= mod:NewCDPNPTimer(15.6, 432959, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerAttractingShadowsCD				= mod:NewCDNPTimer(20.2, 430812, nil, nil, nil, 2)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
function mod:CLTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnChainLightning:Show()
			specWarnChainLightning:Play("runout")
		end
		yellChainLightning:Yell()
	end
end
--]]

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 426893 then
		if self:AntiSpam(3, 2) then
			specWarnBoundingVoid:Show()
			specWarnBoundingVoid:Play("watchorb")
		end
	elseif spellId == 427323 then
		if self:AntiSpam(3, 2) then
			specWarnChargedBombardment:Show()
			specWarnChargedBombardment:Play("chargemove")
		end
	elseif spellId == 450628 then
		warnEntropyShield:Show()
	elseif spellId == 427404 then
		if self:AntiSpam(3, 4) then
			specWarnLocalizedStorm:Show()
			specWarnLocalizedStorm:Play("aesoon")
		end
	elseif spellId == 430013 then
		if self:AntiSpam(3, 2) then
			specWarnThunderstrike:Show()
			specWarnThunderstrike:Play("chargemove")
		end
	elseif spellId == 427616 then
		if self:AntiSpam(3, 5) then
			warnEnergizedBarrage:Show()
		end
	elseif spellId == 430754 then
		if self:AntiSpam(4, 6) then
			warnVoidShell:Show()
			warnVoidShell:Play("crowdcontrol")
		end
	elseif spellId == 423979 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnImplosion:Show()
			specWarnImplosion:Play("range5")
			yellImplosion:Yell()
		end
	elseif spellId == 430805 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnArcingVoid:Show(args.sourceName)
			specWarnArcingVoid:Play("kickcast")
		end
	elseif spellId == 432959 then
		--if self.Options.SpecWarn430805interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnVoidVolley:Show(args.sourceName)
			specWarnVoidVolley:Play("kickcast")
		--elseif self:AntiSpam(3, 7) then
		--	warnTempest:Show()
		--end
	elseif spellId == 430812 then
		warnAttractingShadows:Show()
		warnAttractingShadows:Play("pullin")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 427260 then--Doesn't go on CD until cast, so using stuns to stop it causes recast
		timerEnrageRookCD:Start(nil, args.sourceGUID)
	elseif spellId == 430805 then
		timerArcingVoidCD:Start(13.5, args.sourceGUID)
	elseif spellId == 432959 then
		timerVoidVolleyCD:Start(15.6, args.sourceGUID)
	elseif spellId == 426893 then
		timerBoundingVoidCD:Start(10.1, args.sourceGUID)
	elseif spellId == 450628 then
		timerEntropyShieldCD:Start(25.2, args.sourceGUID)
	elseif spellId == 427323 then
		timerChargedBombardmentCD:Start(17.6, args.sourceGUID)
	elseif spellId == 427404 then
		timerLocalizedStormCD:Start(25.9, args.sourceGUID)
	elseif spellId == 430013 then
		timerThunderstrikeCD:Start(15.1, args.sourceGUID)
	elseif spellId == 427616 then
		timerEnergizedBarrageCD:Start(20, args.sourceGUID)
	elseif spellId == 430754 then
		timerVoidShellCD:Start(18.7, args.sourceGUID)
	elseif spellId == 430179 then
		timerSeepingCorruptionCD:Start(25.2, args.sourceGUID)
	elseif spellId == 423979 then
		timerImplosionCD:Start(nil, args.sourceGUID)
	elseif spellId == 430812 then
		timerAttractingShadowsCD:Start(20.2, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 430805 then
		timerArcingVoidCD:Start(13.5, args.destGUID)
	elseif spellId == 432959 then
		timerVoidVolleyCD:Start(15.6, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 430179 then
		--Always prio dispel over runout, even if on self cause can just dispel self
		if self.Options.SpecWarn430179dispel and self:CheckDispelFilter("curse") then
			specWarnSeepingCorruptionDispel:Show(args.destName)
			specWarnSeepingCorruptionDispel:Play("helpdispel")
			--Still do yell
			if args:IsPlayer() then
				yellSeepingCorruption:Yell()
			end
		elseif args:IsPlayer() then
			specWarnSeepingCorruption:Show()
			specWarnSeepingCorruption:Play("runout")
			yellSeepingCorruption:Yell()
		end
	elseif spellId == 427260 then
		specWarnEnrageRook:Show(args.destName)
		specWarnEnrageRook:Play("enrage")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 209801 then--Quartermaster Koratite
		timerBoundingVoidCD:Stop(args.destGUID)
		timerEntropyShieldCD:Stop(args.destGUID)
	elseif cid == 212786 then--Cursed Stormrider
		timerChargedBombardmentCD:Stop(args.destGUID)
		timerLocalizedStormCD:Stop(args.destGUID)
	elseif cid == 207186 then--Unruly Stormrook
		timerThunderstrikeCD:Stop(args.destGUID)
		timerEnergizedBarrageCD:Stop(args.destGUID)
	elseif cid == 214439 then--Corrupted Oracle
		timerVoidShellCD:Stop(args.destGUID)
		timerSeepingCorruptionCD:Stop(args.destGUID)
	elseif cid == 214419 then--Corrupted Rookguard
		timerImplosionCD:Stop(args.destGUID)
	elseif cid == 207199 then--Cursed Rook Tender
		timerEnrageRookCD:Stop(args.destGUID)
	elseif cid == 214421 then--Corrupted Thunderer
		timerArcingVoidCD:Stop(args.destGUID)
		timerAttractingShadowsCD:Stop(args.destGUID)
	elseif cid == 212793 then--Void Asscendant
		timerVoidVolleyCD:Stop()
	end
end
