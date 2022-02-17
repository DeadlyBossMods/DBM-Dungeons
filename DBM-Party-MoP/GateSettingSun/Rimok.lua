local mod	= DBM:NewMod(676, "DBM-Party-MoP", 4, 303)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56636)
mod:SetEncounterID(1406)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 107122 107120",
	"SPELL_AURA_APPLIED_DOSE 107122 107120",
	"SPELL_CAST_START 107120"
)

--This mod needs more stuff involving adds later.
local specWarnFrenziedAssault	= mod:NewSpecialWarningDodge(107120, "Tank", nil, nil, 1, 2)
local specWarnViscousFluid		= mod:NewSpecialWarningGTFO(107122, nil, nil, nil, 1, 8)

local timerFrenziedAssault		= mod:NewBuffActiveTimer(6, 107120)
local timerFrenziedAssaultCD	= mod:NewNextTimer(17, 107120, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerFrenziedAssaultCD:Start(6-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 107122 and args:IsPlayer() and self:AntiSpam(3) then
		specWarnViscousFluid:Show()
		specWarnViscousFluid:Play("watchfeet")
	elseif args.spellId == 107120 then
		timerFrenziedAssault:Start()
		timerFrenziedAssaultCD:Start()
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_START(args)
	if args.spellId == 107120 then
		specWarnFrenziedAssault:Show()
		specWarnFrenziedAssault:Play("shockwave")
	end
end
