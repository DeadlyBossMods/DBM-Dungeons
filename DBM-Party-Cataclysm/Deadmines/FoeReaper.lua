local mod	= DBM:NewMod(91, "DBM-Party-Cataclysm", 2, 63)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,duos"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(43778)
mod:SetEncounterID(1063, 2975, 2980)
mod:SetUsedIcons(8)
mod:SetZone(36, 1688, 2769)--OG Deadmines, Cata Deadmines, Duos

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 88495",
	"SPELL_AURA_APPLIED 88481 88522",
	"SPELL_CAST_SUCCESS 59304"
)

local warnOverdrive			= mod:NewSpellAnnounce(88481, 3)
local warnHarvest			= mod:NewTargetAnnounce(88495, 4)
local warnEnrage			= mod:NewSpellAnnounce(88522, 4)
local warnSpiritStrike		= mod:NewSpellAnnounce(59304, 3)

local specWarnHarvest		= mod:NewSpecialWarningRun(88495, nil, nil, 2, 4, 2)
local specWarnHarvestNear	= mod:NewSpecialWarningClose(88495, nil, nil, nil, 1, 2)

local timerHarvest			= mod:NewCastTimer(5, 88495, nil, nil, nil, 3)
local timerOverdrive		= mod:NewBuffActiveTimer(10, 88481, nil, nil, nil, 2)

mod:AddSetIconOption("HarvestIcon", 88495, true, 0, {8})

function mod:HarvestTarget()
	local targetname = self:GetBossTarget(43778)
	if not targetname then return end
	if self.Options.HarvestIcon then
		self:SetIcon(targetname, 8, 5)
	end
	if targetname == UnitName("player") then
		specWarnHarvest:Show()
		specWarnHarvest:Play("justrun")
	elseif self:IsClassic() and self:CheckNearby(10, targetname) then
		specWarnHarvestNear:Show(targetname)
		specWarnHarvestNear:Play("runaway")
	else
		warnHarvest:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 88495 then
		self:ScheduleMethod(0.1, "HarvestTarget")
		timerHarvest:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 88481 then
		warnOverdrive:Show()
		timerOverdrive:Start()
	elseif args.spellId == 88522 then
		warnEnrage:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 59304 then
		warnSpiritStrike:Show()
	end
end
