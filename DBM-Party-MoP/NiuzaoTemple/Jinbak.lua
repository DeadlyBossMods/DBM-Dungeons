local mod	= DBM:NewMod(693, "DBM-Party-MoP", 6, 324)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61567)
mod:SetEncounterID(1465)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 119941",
	"SPELL_AURA_APPLIED_DOSE 119941",
	"SPELL_CAST_SUCCESS 120001",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local specWarnSapResidue	= mod:NewSpecialWarningStack(119941, nil, 6, nil, nil, 1, 8)
local specWarnDetonate		= mod:NewSpecialWarningSpell(120001, nil, nil, nil, 2, 2)
local specWarnGlob			= mod:NewSpecialWarningSwitch(-6494, "-Healer", nil, nil, 2, 2)

local timerDetonateCD		= mod:NewNextTimer(45.5, 120001, nil, nil, nil, 2)
local timerDetonate			= mod:NewCastTimer(5, 120001, nil, nil, nil, 5)
local timerSapResidue		= mod:NewBuffFadesTimer(10, 119941, nil, nil, nil, 5)
--local timerGlobCD			= mod:NewNextTimer(45.5, 119990, nil, nil, nil, 1)--Need more logs

function mod:OnCombatStart(delay)
	timerDetonateCD:Start(30-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 119941 and args:IsPlayer() then
		timerSapResidue:Start()
		if (args.amount or 1) >= 6 and self:AntiSpam(3, 1) then
			specWarnSapResidue:Show(args.amount)
			specWarnSapResidue:Play("stackhigh")
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 120001 then
		specWarnDetonate:Show()
		specWarnDetonate:Play("aesoon")
		timerDetonate:Start()
		timerDetonateCD:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 119990 then
		specWarnGlob:Show()
		specWarnGlob:Play("killmob")
	end
end
