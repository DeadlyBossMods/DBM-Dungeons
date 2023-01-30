local mod	= DBM:NewMod("JadeTempleTrash", "DBM-Party-MoP", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 398300 395859 397899 397881 397889 396001 395872 396073 396018 397931 114646",
	"SPELL_AURA_APPLIED 396020 396018"
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED"
)

--TODO, maybe add https://www.wowhead.com/spell=397914/defiling-mist interrupt warning?
local warnSurgingDeluge						= mod:NewSpellAnnounce(397881, 2)
local warnTidalburst						= mod:NewCastAnnounce(397889, 3)
local warnHauntingScream					= mod:NewCastAnnounce(395859, 4)
local warnSleepySililoquy					= mod:NewCastAnnounce(395872, 3)
local warnCatNap							= mod:NewCastAnnounce(396073, 3)
local warnFitofRage							= mod:NewCastAnnounce(396018, 3)
local warnHauntingGaze						= mod:NewCastAnnounce(114646, 3, nil, nil, "Tank|Healer")
local warnDarkClaw							= mod:NewCastAnnounce(397931, 4, nil, nil, "Tank|Healer")
local warnGoldenBarrier						= mod:NewTargetNoFilterAnnounce(396020, 2)

local specWarnFlamesofDoubt					= mod:NewSpecialWarningDodge(398300, nil, nil, nil, 2, 2)
local specWarnLegSweep						= mod:NewSpecialWarningDodge(397899, nil, nil, nil, 2, 2)
local specWarnTerritorialDisplay			= mod:NewSpecialWarningDodge(396001, nil, nil, nil, 2, 2)
--local yellConcentrateAnima					= mod:NewYell(339525)
--local yellConcentrateAnimaFades				= mod:NewShortFadesYell(339525)
local specWarnFitOfRage						= mod:NewSpecialWarningDispel(396018, "RemoveEnrage", nil, nil, 1, 2)
local specWarnHauntingScream				= mod:NewSpecialWarningInterrupt(395859, "HasInterrupt", nil, nil, 1, 2)
local specWarnSleepySililoquy				= mod:NewSpecialWarningInterrupt(395872, "HasInterrupt", nil, nil, 1, 2)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 398300 and self:AntiSpam(3, 2) then
		specWarnFlamesofDoubt:Show()
		specWarnFlamesofDoubt:Play("shockwave")
	elseif spellId == 397899 and self:AntiSpam(3, 2) then
		specWarnLegSweep:Show()
		specWarnLegSweep:Play("watchstep")
	elseif spellId == 396001 and self:AntiSpam(3, 2) then
		specWarnTerritorialDisplay:Show()
		specWarnTerritorialDisplay:Play("watchstep")
	elseif spellId == 395859 then
		if self.Options.SpecWarn395859interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHauntingScream:Show(args.sourceName)
			specWarnHauntingScream:Play("kickcast")
		elseif self:AntiSpam(3, 5) then
			warnHauntingScream:Show()
		end
	elseif spellId == 395872 then
		if self.Options.SpecWarn395872interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSleepySililoquy:Show(args.sourceName)
			specWarnSleepySililoquy:Play("kickcast")
		elseif self:AntiSpam(3, 5) then
			warnSleepySililoquy:Show()
		end
	elseif spellId == 397881 and self:AntiSpam(3, 6) then--Basically de-emphasized dodge warnings but using diff antispam so they don't squelch emphasized dodge warnings
		warnSurgingDeluge:Show()
	elseif spellId == 397889 and self:AntiSpam(3, 6) then--Basically de-emphasized dodge warnings but using diff antispam so they don't squelch emphasized dodge warnings
		warnTidalburst:Show()
	elseif spellId == 396073 and self:AntiSpam(3, 5) then
		warnCatNap:Show()
	elseif spellId == 396018 and self:AntiSpam(3, 5) then
		warnFitofRage:Show()
	elseif spellId == 397931 and self:AntiSpam(3, 5) then
		warnDarkClaw:Show()
	elseif spellId == 114646 and self:AntiSpam(3, 5) then
		warnHauntingGaze:Show()
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 396020 then
		warnGoldenBarrier:Show(args.destName)
	elseif spellId == 396018 then
		specWarnFitOfRage:Show(args.destName)
		specWarnFitOfRage:Play("enrage")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 339525 and args:IsPlayer() then

	end
end
--]]
