local mod	= DBM:NewMod(690, "DBM-Party-MoP", 5, 321)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61243, 61337, 61338, 61339, 61340)--61243 (Gekkan), 61337 (Glintrok Ironhide), 61338 (Glintrok Skulker), 61339 (Glintrok Oracle), 61340 (Glintrok Hexxer)
mod:SetEncounterID(1509, 1510)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 118988 129262 118958 118903",
	"SPELL_AURA_APPLIED_DOSE 129262",
	"SPELL_AURA_REMOVED 118988 129262 118903 118958",
	"SPELL_CAST_START 118903 118963 118940"
--	"UNIT_DIED"
)

local warnRecklessInspiration	= mod:NewStackAnnounce(118988, 3)
local warnIronProtector			= mod:NewTargetNoFilterAnnounce(118958, 2)

local specWarnShank				= mod:NewSpecialWarningInterrupt(118963, false, nil, nil, 1, 2)--specWarns can be spam. Default value is off. Use this manually.
local specWarnCleansingFlame	= mod:NewSpecialWarningInterrupt(118940, "HasInterrupt", nil, nil, 1, 2)
local specWarnHexInterrupt		= mod:NewSpecialWarningInterrupt(118903, "HasInterrupt", nil, nil, 1, 2)
local specWarnHexDispel			= mod:NewSpecialWarningDispel(118903, "RemoveMagic", nil, nil, 1, 2)

local timerInspiriation			= mod:NewTargetTimer(20, 118988, nil, nil, nil, 5)
local timerIronProtector		= mod:NewTargetTimer(15, 118958, nil, nil, nil, 5)
local timerHex					= mod:NewTargetTimer(20, 118903, nil, "Healer", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)

--function mod:OnCombatStart(delay)
--end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(118988, 129262) then
		warnRecklessInspiration:Show(args.destName, 1)
		timerInspiriation:Start(20, args.destName)
	elseif args.spellId == 118958 then
		warnIronProtector:Show(args.destName)
		timerIronProtector:Start(args.destName)
	elseif args.spellId == 118903 then
		if self:CheckDispelFilter("magic") then
			specWarnHexDispel:Show(args.destName)
			specWarnHexDispel:Play("helpdispel")
		end
		timerHex:Start(args.destName)
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args.spellId == 129262 then
		warnRecklessInspiration:Show(args.destName, args.amount or 1)
		timerInspiriation:Start(21, args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(118988, 129262) then
		timerInspiriation:Cancel(args.destName)
	elseif args.spellId == 118903 then
		timerHex:Cancel(args.destName)
	elseif args.spellId == 118958 then
		timerIronProtector:Cancel(args.destName)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 118903 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnHexInterrupt:Show(args.sourceName)
		specWarnHexInterrupt:Play("kickcast")
	elseif args.spellId == 118963 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnShank:Show(args.sourceName)
		specWarnShank:Play("kickcast")
	elseif args.spellId == 118940 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnCleansingFlame:Show(args.sourceName)
		specWarnCleansingFlame:Play("kickcast")
	end
end

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 61340 and self:IsInCombat() then--Seperate statement for Glintrok Hexxer since we actually need to cancel a cd bar.
--		timerHexCD:Cancel()
	end
end
--]]
