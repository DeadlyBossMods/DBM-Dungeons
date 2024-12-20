if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod("OperationFloodgateTrash", "DBM-Party-WarWithin", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2773)
mod:RegisterZoneCombat(2773)

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

 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 217531) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 217531)
--]]
--local warnHorrifyingshrill					= mod:NewCastAnnounce(434802, 4)--High Prio Off interrupt
--local warnPoisonousCloud					= mod:NewSpellAnnounce(438826, 3)

--local specWarnMassiveSlam					= mod:NewSpecialWarningSpell(434252, nil, nil, nil, 2, 2)
--local specWarnWebSpray						= mod:NewSpecialWarningDodge(434824, nil, nil, nil, 2, 15)
--local yellChainLightning					= mod:NewYell(387127)
--local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
--local specWarnHorrifyingShrill				= mod:NewSpecialWarningInterrupt(434802, "HasInterrupt", nil, nil, 1, 2)

--local timerMassiveSlamCD					= mod:NewCDNPTimer(15.4, 434252, nil, nil, nil, 2)
--local timerWebSprayCD						= mod:NewCDPNPTimer(7, 434824, nil, nil, nil, 3)

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
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 434824 then

	end
end
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 434802 then

	--elseif spellId == 434793 then
	--	if self.Options.SpecWarn434793interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--		specWarnRadiantBarrage:Show(args.sourceName)
	--		specWarnRadiantBarrage:Play("kickcast")
	--	elseif self:AntiSpam(3, 7) then
	--		warnRadiantBarrage:Show()
	--	end
	--	timerRadiantBarrageCD:Start(16.8, args.sourceGUID)
	end
end
--]]

--[[
function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if args.extraSpellId == 434802 then
		timerHorrifyingShrillCD:Start(13.3, args.destGUID)
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
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 217531 then

	end
end
--]]

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid)
	if cid == 217531 then

	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
