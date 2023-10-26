local mod	= DBM:NewMod("StonecoreTrash", "DBM-Party-Cataclysm", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(725)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 81459"
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

--[[

--]]
--TODO, Quake you have to jump for
--TODO, portal you have to interrupt/stun that spawns imps
--[[
(ability.id = 81459) and type = "begincast"
--]]
--local warnCyclone								= mod:NewTargetNoFilterAnnounce(88010, 4)
local warnForceofEarth							= mod:NewCastAnnounce(81459, 4)

local specWarnForceofEarth						= mod:NewSpecialWarningInterrupt(81459, "HasInterrupt", nil, nil, 1, 2)

--local timerForceofEarthCD						= mod:NewCDNPTimer(14.1, 81459, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)


--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 81459 then
--		timerForceofEarthCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn372223interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnForceofEarth:Show(args.sourceName)
			specWarnForceofEarth:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnForceofEarth:Show()
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 88055 then

	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 88010 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 87726 then

	end
end
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 43537 then--Stonecore Earthshaper
--		timerForceofEarthCD:Stop(args.destGUID)
	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
