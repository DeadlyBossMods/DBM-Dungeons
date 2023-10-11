local mod	= DBM:NewMod("EverBloomTrash", "DBM-Party-WoD", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(1279)

mod.isTrashMod = true

mod:RegisterEvents(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

--TODO, everything
--TODO, nameplate timer for Bounding Whirl mandatory for Melded Berserker
--TODO, Choking Vines interrupt
--[[

--]]
--local warnCyclone								= mod:NewTargetNoFilterAnnounce(88010, 4)

--local specWarnTurbulence						= mod:NewSpecialWarningSpell(411002, nil, nil, nil, 2, 2)
--local yellnViciousAmbush						= mod:NewYell(388984)
--local specWarnCyclone							= mod:NewSpecialWarningInterrupt(88010, "HasInterrupt", nil, nil, 1, 2)
--local specWarnVaporForm							= mod:NewSpecialWarningDispel(88186, "MagicDispeller", nil, nil, 1, 2)
--local specWarnGTFO								= mod:NewSpecialWarningGTFO(88171, nil, nil, nil, 1, 8)

--local timerStormSurgeCD							= mod:NewCDTimer(16.1, 88055, nil, nil, nil, 2)
--local timerGaleStrikeCD							= mod:NewCDTimer(17, 88061, nil, "MagicDispeller", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)


--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 88061 then

	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 88055 then

	end
end
--]]

--[[
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

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 45928 then

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
