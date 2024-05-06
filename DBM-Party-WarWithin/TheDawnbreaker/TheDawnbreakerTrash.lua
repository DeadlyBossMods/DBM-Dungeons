local mod	= DBM:NewMod("TheDawnbreakerTrash", "DBM-Party-WarWithin", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 451102 451119 450854 451117 451097",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 451097",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

local warnSilkenShell						= mod:NewCastAnnounce(451097, 3)--High prio interrupt

local specWarnRadiantDecay					= mod:NewSpecialWarningSpell(451102, nil, nil, nil, 2, 2)
local specWarnDarkOrb						= mod:NewSpecialWarningSpell(450854, nil, nil, nil, 2, 2)
local specWarnTerrifyingSlam				= mod:NewSpecialWarningRun(451117, nil, nil, nil, 4, 2)
--local yellChainLightning					= mod:NewYell(387127)
local specWarnSilkenShell					= mod:NewSpecialWarningInterrupt(451097, "HasInterrupt", nil, nil, 1, 2)--High prio interrupt
local specWarnSilkenShellDispel				= mod:NewSpecialWarningDispel(451097, "MagicDispeller", nil, nil, 1, 2)

local timerAbyssalBlastCD					= mod:NewCDNPTimer(18.4, 451119, nil, "Tank|Healer", nil, 5)
local timerRadiantDecayCD					= mod:NewCDNPTimer(15.7, 451102, nil, nil, nil, 2)
local timerDarkOrbCD						= mod:NewCDNPTimer(19.4, 450854, nil, nil, nil, 3)--Small sample, needs more data
local timerTerrifyingSlamCD					= mod:NewCDNPTimer(14.5, 451117, nil, nil, nil, 2)
local timerSilkenShellCD					= mod:NewCDNPTimer(21.4, 451097, nil, nil, nil, 4)
--local timerBloodcurdlingShoutCD				= mod:NewCDNPTimer(19.1, 373395, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

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
	--elseif spellId == 386024 then
	--	timerTempestCD:Start(nil, args.sourceGUID)
	--	if self.Options.SpecWarn386024interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--		specWarnTempest:Show(args.sourceName)
	--		specWarnTempest:Play("kickcast")
	--	elseif self:AntiSpam(3, 7) then
	--		warnTempest:Show()
	--	end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 384476 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 451097 and self:AntiSpam(4, 3) then
		specWarnSilkenShellDispel:Show(args.destName)
		specWarnSilkenShellDispel:Play("helpdispel")
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
	end
end
