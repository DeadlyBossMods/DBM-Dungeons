local mod	= DBM:NewMod(132, "DBM-Party-Cataclysm", 3, 71)
local L		= mod:GetLocalizedStrings()

if not mod:IsCata() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else
	mod.statTypes = "normal,heroic"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40177)
mod:SetEncounterID(1050)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 75000",
	"SPELL_AURA_APPLIED 74981 75007 74908 74976 74987",
	"SPELL_DAMAGE 90754",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnPickWeapon		= mod:NewCountAnnounce(75000, 3)
local warnDualBlades		= mod:NewSpellAnnounce(74981, 3)
local warnEncumbered		= mod:NewSpellAnnounce(75007, 3)
local warnPhalanx			= mod:NewSpellAnnounce(74908, 3)
local warnDisorientingRoar	= mod:NewSpellAnnounce(74976, 3)

local specWarnGTFO			= mod:NewSpecialWarningGTFO(74987, nil, nil, nil, 1, 8)
local specWarnEncumbered	= mod:NewSpecialWarningRun(75007, "Tank", nil, nil, 4, 2)
local specWarnFlamingShield	= mod:NewSpecialWarningDodge(90819, nil, nil, nil, 2, 12)

local timerDualBlades		= mod:NewBuffActiveTimer(30, 74981, nil, nil, nil, 6)
local timerEncumbered		= mod:NewBuffActiveTimer(30, 75007, nil, nil, nil, 6)
local timerPhalanx			= mod:NewBuffActiveTimer(30, 74908, nil, nil, nil, 6)

mod.vb.weaponCount = 0

function mod:OnCombatStart(delay)
	self.vb.weaponCount = 0
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 75000 then
		self.vb.weaponCount = self.vb.weaponCount + 1
		warnPickWeapon:Show(self.vb.weaponCount)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 74981 then
		warnDualBlades:Show()
		timerDualBlades:Start()
	elseif spellId == 75007 then
		if self.Options.SpecWarn75007run then
			specWarnEncumbered:Show()
			specWarnEncumbered:Play("justrun")
		else
			warnEncumbered:Show()
		end
		timerEncumbered:Start()
	elseif spellId == 74908 then
		warnPhalanx:Show()
		timerPhalanx:Start()
	elseif spellId == 74976 and self:AntiSpam(10, 1) then
		warnDisorientingRoar:Show()
	elseif spellId == 74987 and args:IsPlayer() then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 90754 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
--mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 75071 then--Fixate effect (cast twice during phalanx phase, when boss prepares fire breath
		specWarnFlamingShield:Show()
		specWarnFlamingShield:Play("flamejet")
	end
end
