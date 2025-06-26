local mod	= DBM:NewMod("EcoDomeAldaniTrash", "DBM-Party-WarWithin", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2830)
mod:RegisterZoneCombat(2830)

mod:RegisterEvents(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_INTERRUPT",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

--[[
(ability.id = 450628) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 450628
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 209801) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 209801)
--]]
--local warnInstability						= mod:NewSpellAnnounce(443854, 2)

--local specWarnLocalizedStorm				= mod:NewSpecialWarningSpell(427404, nil, nil, nil, 2, 2)
--local yellSeepingCorruption				= mod:NewShortYell(430179)
--local specWarnLightingSurge				= mod:NewSpecialWarningInterrupt(427260, "HasInterrupt", nil, nil, 1, 2)

--local timerBoundingVoidCD					= mod:NewCDPNPTimer(18.2, 426893, nil, nil, nil, 3)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
function mod:VoidCrushtarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnVoidCrush:Show()
			specWarnVoidCrush:Play("scatter")
		end
		yellVoidCrush:Yell()
	end
end
--]]

--[[
function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 426893 then

	end
end
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 427260 then

	end
end
--]]

--[[
function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 430805 then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 430179 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

--[[
function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 0 then

	end
end
--]]

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 0 then

	end
end

function mod:LeavingZoneCombat()
	self:Stop(true)
end
