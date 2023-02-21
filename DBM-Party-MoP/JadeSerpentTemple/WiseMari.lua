local mod	= DBM:NewMod(672, "DBM-Party-MoP", 1, 313)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56448)
mod:SetEncounterID(1418)
mod:SetUsedIcons(8)
mod:SetHotfixNoticeRev(20230116000000)
mod:SetMinSyncRevision(20221108000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 397783 397801",
	"SPELL_AURA_APPLIED 397797 397799",
	"SPELL_AURA_REMOVED 397797"
--	"SPELL_DAMAGE 115167",
--	"SPELL_MISSED 115167"
)

--This verion of mod is for the retail redesign
--[[
ability.id = 397783 and type = "begincast"
 or ability.id = 397797 and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnCorruptedVortex			= mod:NewTargetAnnounce(397797, 3)
local warnCorruptedGeyser			= mod:NewCountAnnounce(397793, 3)

local specWarnWashAway				= mod:NewSpecialWarningDodge(397783, nil, nil, nil, 2, 2)
local specWarnCorruptedVortex		= mod:NewSpecialWarningMoveAway(397797, nil, nil, nil, 1, 2)
local yellCorruptedVortex			= mod:NewYell(397797)
local yellCorruptedVortexFades		= mod:NewShortFadesYell(397797)
--local specWarnCorruptedGeyser		= mod:NewSpecialWarningDodge(397793, nil, nil, nil, 2, 2)
local specWarnHydrolance			= mod:NewSpecialWarningInterrupt(397801, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(397799, nil, nil, nil, 1, 8)

local timerWashAwayCD				= mod:NewCDTimer(41.3, 397783, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)--41-44
local timerCorruptedVortexCD		= mod:NewCDTimer(13, 397797, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
local timerCorruptedGeyserCD		= mod:NewCDCountTimer("d5", 397793, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	timerCorruptedVortexCD:Start(8.5-delay)
	timerWashAwayCD:Start(20.6-delay)
	--timerCorruptedGeyserCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 397783 then
		specWarnWashAway:Show()
		specWarnWashAway:Play("watchstep")
		timerWashAwayCD:Start()
		timerCorruptedVortexCD:Restart(17.2)
		--"<432.19 20:50:33> [CLEU] SPELL_CAST_START#Creature-0-3772-960-3510-56448-000045A960#Der weise Mari(56.1%-100.0%)##nil#397783#Wegspülen#nil#nil", -- [3320]
		--"<435.47 20:50:36> [CLEU] SPELL_DAMAGE[CONDENSED]#Creature-0-3772-960-3510-56448-000045A960#Der weise Mari#2 Targets#397793#Verderbter Geysir", -- [3338]
		--"<440.60 20:50:41> [CLEU] SPELL_DAMAGE#Creature-0-3772-960-3510-56448-000045A960#Der weise Mari#Player-1401-04216D3A#Valî-Shattrath#397793#Verderbter Geysir", -- [3373]
		--"<445.52 20:50:46> [CLEU] SPELL_DAMAGE#Creature-0-3772-960-3510-56448-000045A960#Der weise Mari#Player-1401-04216D3A#Valî-Shattrath#397793#Verderbter Geysir", -- [3382]
		warnCorruptedGeyser:Schedule(3.2, 1)
		timerCorruptedGeyserCD:Start(3.2, 1)
		warnCorruptedGeyser:Schedule(8.3, 2)
		timerCorruptedGeyserCD:Start(8.3, 2)
		warnCorruptedGeyser:Schedule(13.3, 3)
		timerCorruptedGeyserCD:Start(13.3, 3)
	elseif spellId == 397801 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnHydrolance:Show(args.sourceName)
		specWarnHydrolance:Play("kickcast")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 397797 then
		if self:AntiSpam(5, 1) then
			timerCorruptedVortexCD:Start()
		end
		if args:IsPlayer() then
			specWarnCorruptedVortex:Show()
			specWarnCorruptedVortex:Play("runout")
			yellCorruptedVortex:Yell()
			yellCorruptedVortexFades:Countdown(spellId)
		end
	elseif spellId == 397799 and args:IsPlayer() and self:AntiSpam(4, 2) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 397797 then
		if args:IsPlayer() then
			yellCorruptedVortexFades:Cancel()
		end
	end
end

--[[
function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 115167 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
--]]
