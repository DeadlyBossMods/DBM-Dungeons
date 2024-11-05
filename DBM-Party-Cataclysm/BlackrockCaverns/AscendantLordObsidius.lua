local mod	= DBM:NewMod(109, "DBM-Party-Cataclysm", 1, 66)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(39705)
mod:SetEncounterID(1036)
mod:SetZone(645)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 76200 76188 76189",
	"SPELL_AURA_REFRESH 76188 76189",
	"SPELL_AURA_REMOVED 76242 76188"
)

local warnTransformation	= mod:NewSpellAnnounce(76200, 3)
local warnCorrupion			= mod:NewTargetNoFilterAnnounce(76188, 2, nil, "Healer", 2)

local timerCorruption		= mod:NewTargetTimer(12, 76188, nil, "Healer", nil, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.MAGIC_ICON)
local timerVeil				= mod:NewTargetTimer(4, 76189, nil, "Healer", nil, 5, nil, DBM_COMMON_L.HEALER_ICON)

mod:AddSetIconOption("SetIconOnBoss", 76242, true, 0, {8})

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 76200 then
		warnTransformation:Show()
	elseif args.spellId == 76188 then
		warnCorrupion:Show(args.destName)
		timerCorruption:Start(args.destName)
	elseif args.spellId == 76189 then
		timerVeil:Start(args.destName)
	end
end
mod.SPELL_AURA_REFRESH = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 76242 and self.Options.SetIconOnBoss then
		self:SetIcon(L.name, 8)
	elseif args.spellId == 76188 then
		timerCorruption:Cancel(args.destName)
	end
end
