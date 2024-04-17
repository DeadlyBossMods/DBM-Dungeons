local mod	= DBM:NewMod("CityofThreadsTrash", "DBM-Party-WarWithin", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

--mod:RegisterEvents(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
--)

--local warnTotemicOverload					= mod:NewCastAnnounce(387145, 3)

--local specWarnChainLightning				= mod:NewSpecialWarningMoveAway(387127, nil, nil, nil, 1, 2)
--local yellChainLightning					= mod:NewYell(387127)
--local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
--local specWarnTempest						= mod:NewSpecialWarningInterrupt(386024, "HasInterrupt", nil, nil, 1, 2)

--local timerRainofArrowsCD					= mod:NewCDNPTimer(15.7, 384476, nil, nil, nil, 3)
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

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 387145 and self:AntiSpam(5, 4) then

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
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 384476 then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 395035 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 192796 then
	end
end
--]]
