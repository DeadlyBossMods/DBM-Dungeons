local mod	= DBM:NewMod("TheDawnbreakerTrash", "DBM-Party-WarWithin", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 451102 451119 450854 451117 451097 431364 431494 432565 432520 431333 431637",
	"SPELL_CAST_SUCCESS 451112",
	"SPELL_AURA_APPLIED 451097 432520 451112",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--Abilities for the mini bosses for Anub are also mixed in here
--TODO, more high priority interrupt CDs and alerts?
local warnSilkenShell						= mod:NewCastAnnounce(451097, 3)--High prio interrupt
local warnUmbrelRush						= mod:NewCastAnnounce(431637, 2)

local specWarnRadiantDecay					= mod:NewSpecialWarningSpell(451102, nil, nil, nil, 2, 2)
local specWarnDarkOrb						= mod:NewSpecialWarningSpell(450854, nil, nil, nil, 2, 2)
local specWarnBlackEdge						= mod:NewSpecialWarningDodge(431494, nil, nil, nil, 2, 2)
local specWarnBlackHail						= mod:NewSpecialWarningDodge(432565, nil, nil, nil, 2, 2)
local specWarnTerrifyingSlam				= mod:NewSpecialWarningRun(451117, nil, nil, nil, 4, 2)
--local yellChainLightning					= mod:NewYell(387127)
local specWarnSilkenShell					= mod:NewSpecialWarningInterrupt(451097, "HasInterrupt", nil, nil, 1, 2)--High prio interrupt
local specWarnTormentingRay					= mod:NewSpecialWarningInterrupt(431364, "HasInterrupt", nil, nil, 1, 2)--High prio?
local specWarnTormentingBeam				= mod:NewSpecialWarningInterrupt(431333, "HasInterrupt", nil, nil, 1, 2)--High prio?
local specWarnSilkenShellDispel				= mod:NewSpecialWarningDispel(451097, "MagicDispeller", nil, nil, 1, 2)
local specWarnUmbrelBarrierDispel			= mod:NewSpecialWarningDispel(432520, "MagicDispeller", nil, nil, 1, 2)
local specWarnTacticiansRageDispel			= mod:NewSpecialWarningDispel(451112, "RemoveEnrage", nil, nil, 1, 2)

local timerAbyssalBlastCD					= mod:NewCDNPTimer(10.6, 451119, nil, "Tank|Healer", nil, 5)
local timerRadiantDecayCD					= mod:NewCDNPTimer(15.7, 451102, nil, nil, nil, 2)
local timerDarkOrbCD						= mod:NewCDNPTimer(19.4, 450854, nil, nil, nil, 3)--Small sample, needs more data
local timerTerrifyingSlamCD					= mod:NewCDNPTimer(23, 451117, nil, nil, nil, 2)
local timerBlackEdgeCD						= mod:NewCDNPTimer(13.2, 431494, nil, nil, nil, 3)
local timerBlackHailCD						= mod:NewCDNPTimer(14.6, 432565, nil, nil, nil, 3)
local timerUmbrelRushCD						= mod:NewCDNPTimer(10.9, 431637, nil, nil, nil, 3)--Stuns do NOT put this on CD, but it's rarely stunned so for most part should be fine. IGNORE timer refreshed errors that are rare
local timerUmbrelBarrierCD					= mod:NewCDNPTimer(20.6, 432520, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerTacticiansRageCD					= mod:NewCDNPTimer(18.2, 451112, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSilkenShellCD					= mod:NewCDNPTimer(21.4, 451097, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerTormentingRayCD					= mod:NewCDNPTimer(10.9, 431364, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerTormentingBeamCD				= mod:NewCDNPTimer(8.1, 431333, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Wildly varient due to not going on CD if stunned

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
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 451102 then
		timerRadiantDecayCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnRadiantDecay:Show()
			specWarnRadiantDecay:Play("aesoon")
		end
	elseif spellId == 451119 then
		timerAbyssalBlastCD:Start(nil, args.sourceGUID)
	elseif spellId == 450854 then
		timerDarkOrbCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDarkOrb:Show()
			specWarnDarkOrb:Play("watchorb")
		end
	elseif spellId == 451117 then
		timerTerrifyingSlamCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			specWarnTerrifyingSlam:Show()
			specWarnTerrifyingSlam:Play("justrun")
		end
	elseif spellId == 451097 then
		timerSilkenShellCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn451097interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSilkenShell:Show(args.sourceName)
			specWarnSilkenShell:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSilkenShell:Show()
		end
	elseif spellId == 431364 then
		timerTormentingRayCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTormentingRay:Show(args.sourceName)
			specWarnTormentingRay:Play("kickcast")
		end
	elseif spellId == 431494 then
		timerBlackEdgeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBlackEdge:Show()
			specWarnBlackEdge:Play("shockwave")
		end
	elseif spellId == 432565 then
		timerBlackHailCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBlackHail:Show()
			specWarnBlackHail:Play("watchstep")
		end
	elseif spellId == 432520 then
		timerUmbrelBarrierCD:Start(nil, args.sourceGUID)
	elseif spellId == 431333 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTormentingBeam:Show(args.sourceName)
			specWarnTormentingBeam:Play("kickcast")
		end
	elseif spellId == 431637 then
		timerUmbrelRushCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnUmbrelRush:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 451112 then
		timerTacticiansRageCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 451097 and self:AntiSpam(4, 3) then
		specWarnSilkenShellDispel:Show(args.destName)
		specWarnSilkenShellDispel:Play("helpdispel")
	elseif spellId == 432520 and self:AntiSpam(4, 3) then
		specWarnUmbrelBarrierDispel:Show(args.destName)
		specWarnUmbrelBarrierDispel:Play("helpdispel")
	elseif spellId == 451112 and self:AntiSpam(4, 3) then
		specWarnTacticiansRageDispel:Show(args.destName)
		specWarnTacticiansRageDispel:Play("enrage")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 211261 then--Ascendant Vis'coxria
		timerAbyssalBlastCD:Stop(args.destGUID)--They all cast this
		timerRadiantDecayCD:Stop(args.destGUID)
	elseif cid == 211263 then--Deathscreamer Iken'tak
		timerAbyssalBlastCD:Stop(args.destGUID)--They all cast this
		timerDarkOrbCD:Stop(args.destGUID)
	elseif cid == 211262 then--Ixkreten the Unbreakable
		timerAbyssalBlastCD:Stop(args.destGUID)--They all cast this
		timerTerrifyingSlamCD:Stop(args.destGUID)
	elseif cid == 213932 then--Sureki Militant
		timerSilkenShellCD:Stop(args.destGUID)
	elseif cid == 214761 then--Nightfall Ritualist
		timerTormentingRayCD:Stop(args.destGUID)
	elseif cid == 213934 then--Nightfall Tactician
		timerBlackEdgeCD:Stop(args.destGUID)
		timerTacticiansRageCD:Stop(args.destGUID)
	elseif cid == 211341 then--Manifested Shadow
		timerBlackHailCD:Stop(args.destGUID)
	elseif cid == 213893 then--Nightfall Darkcaster
		timerUmbrelBarrierCD:Stop(args.destGUID)
		timerUmbrelRushCD:Stop(args.destGUID)
	end
end
