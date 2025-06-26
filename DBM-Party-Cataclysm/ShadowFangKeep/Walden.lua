local mod	= DBM:NewMod(99, "DBM-Party-Cataclysm", 6, 64)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,duos"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(46963)
mod:SetEncounterID(1073)
mod:SetZone(33, 2849)--SFK, Duos

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 93505 93697",
	"SPELL_AURA_APPLIED 93527 93689 93617",
	"SPELL_AURA_APPLIED_DOSE 93527 93689 93617"
)

local warnFrostMix		= mod:NewSpellAnnounce(93505, 3)
local warnIceShards		= mod:NewSpellAnnounce(93527, 3)
local warnPoisonMix		= mod:NewSpellAnnounce(93697, 3)

local specWarnGreenMix	= mod:NewSpecialWarning("specWarnCoagulant", nil, false, nil, 1, 2)
local specWarnRedMix	= mod:NewSpecialWarning("specWarnRedMix", nil, false, nil, 1, 2)
mod:AddBoolOption("RedLightGreenLight", true, "announce")

local timerIceShards	= mod:NewBuffActiveTimer(5, 93527)
local timerRedMix		= mod:NewBuffActiveTimer(10, 93689, nil, nil, nil, 6)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 93527 and not self:IsDuo() then--Inconsiquential in duos
		warnIceShards:Show()
		timerIceShards:Start()
	elseif args.spellId == 93689 and self:AntiSpam(4, 1) then--Red Light
		timerRedMix:Start()
		if self.Options.RedLightGreenLight then
			specWarnRedMix:Show()
			specWarnRedMix:Play("stopmove")
		end
	elseif args.spellId == 93617 and self:AntiSpam(10, 2) then--Green Light
		if self.Options.RedLightGreenLight then
			specWarnGreenMix:Show()
			specWarnGreenMix:Play("keepmove")
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_START(args)
	if args.spellId == 93505 and not self:IsDuo() then
		warnFrostMix:Show()
	elseif args.spellId == 93697 and not self:IsDuo() then
		warnPoisonMix:Show()
	end
end
