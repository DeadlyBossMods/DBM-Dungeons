local mod = DBM:NewMod(549, "DBM-Party-BC", 15, 254)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 645 $"):sub(12, -3))

mod:SetCreatureID(20885)
mod:SetEncounterID(1913)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 39013 36144 36175 36142",
	"SPELL_AURA_APPLIED 39009 36173",
	"SPELL_AURA_REMOVED 39009 36173"
)

--LOG THIS, needs whirlwind CD timer
local warnGift			= mod:NewTargetAnnounce(39009, 3)

local specwarnWhirlwind	= mod:NewSpecialWarningRun(36175, "Melee", nil, nil, 4, 6)
local specwarnHeal		= mod:NewSpecialWarningInterrupt(39013, "-Healer", nil, nil, 1, 2)

local timerGift			= mod:NewTargetTimer(10, 39009, nil, false, 2, 3)

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(39013, 36144) then
		specwarnHeal:Show()
		specwarnHeal:Play("kickcast")
	elseif args:IsSpellID(36175, 36142) then
		specwarnWhirlwind:Show()
		specwarnWhirlwind:Play("whirlwind")--Probably get this sound file renamed to "whirlwind" in 7.0
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(39009, 36173) then
		warnGift:Show(args.destName)
		timerGift:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(39009, 36173) then
		timerGift:Stop(args.destName)
	end
end