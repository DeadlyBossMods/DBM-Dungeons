local mod	= DBM:NewMod("z2831", "DBM-Delves-WarWithin", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"--Best way to really call it
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234168)--Non hard placeholder on load. Real one set in OnCombatStart
mod:SetEncounterID(3126, 3138)--Normal, Hard
--mod:SetHotfixNoticeRev(20240914000000)
--mod:SetMinSyncRevision(20240914000000)
mod:SetZone(2831)--Demolition Dome

--mod:RegisterCombat("scenario", 2682)
mod:RegisterCombat("combat")

function mod:OnLimitedCombatStart()
	if self:IsMythic() then
		--self:SetStage(1)
		self:SetCreatureID(236626)
	else
		self:SetCreatureID(234168)
	end
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1214052 1213852 1217371 1215521 1214043 1214053 1217667 1217661",
	"SPELL_CAST_SUCCESS 1214147",
	"SPELL_AURA_REMOVED 1214052 1217667"
)
--]]

--[[
(ability.id = 1214052 or ability.id = 1213852 or ability.id = 1217371 or ability.id = 1215521 or ability.id = 1214053 or ability.id = 1217667 or ability.id = 1217661) and type = "begincast"
or ability.id = 1214147 and type = "cast"
or (ability.id = 1217667 or ability.id = 1214052) and type = "removebuff"
--]]
--[[
local warnBombs							= mod:NewCountAnnounce(1214147, 2, nil, nil, nil, nil, nil, 2)
local warnMoltenCannon					= mod:NewSpellAnnounce(1214043, 2, nil, false, nil, nil, nil, 2)--Utterly spammed, so warning off by default

local specWarnShield					= mod:NewSpecialWarningCount(1214052, nil, nil, nil, 1, 2)
local specWarnCrush						= mod:NewSpecialWarningDodgeCount(1213852, nil, nil, nil, 2, 2)
local specWarnFlamethrower				= mod:NewSpecialWarningDodgeCount(1217371, nil, nil, nil, 2, 15)
local specWarnCronies					= mod:NewSpecialWarningSwitchCount(1215521, nil, nil, nil, 1, 2)

local timerShieldCD						= mod:NewVarCountTimer("v45-58.5", 1214052, nil, nil, nil, 5)--45 seconds til full power, but boss is a dicksucker and doesn't cast it right away
local timerRechargeCast					= mod:NewCastTimer(15, 1214053, nil, nil, nil, 5)
local timerCrushCD						= mod:NewVarCountTimer("v20.2-45.4", 1213852, nil, nil, nil, 3)
local timerFlamethrowerCD				= mod:NewVarCountTimer("v20.2-42.5", 1217371, nil, nil, nil, 3)
local timerBombsCD						= mod:NewVarCountTimer("v25.5-41.3", 1214147, nil, nil, nil, 5)
local timerCroniesCD					= mod:NewVarCountTimer("v72.6-89.4", 1215521, nil, nil, nil, 1)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

mod.vb.shieldCount = 0
mod.vb.crushCount = 0
mod.vb.bombCount = 0
mod.vb.addsCount = 0

function mod:OnCombatStart(delay)
	self.vb.shieldCount = 0
	self.vb.crushCount = 0
	self.vb.bombCount = 0
	self.vb.addsCount = 0
	--Don't have mythic logs yet so using same timers for all right now
	timerCrushCD:Start(4.8-delay, 1)
	timerFlamethrowerCD:Start(9.6-delay, 1)
	timerBombsCD:Start(13.3-delay, 1)
	timerCroniesCD:Start(17.3-delay, 1)
	timerShieldCD:Start(46.1-delay, 1)
	if self:IsMythic() then
		--self:SetStage(1)
		self:SetCreatureID(236626)
	else
		self:SetCreatureID(234168)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 1214052 or args.spellId == 1217667 then
		self.vb.shieldCount = self.vb.shieldCount + 1
		specWarnShield:Show(self.vb.shieldCount)
		specWarnShield:Play("attackshield")
	elseif args.spellId == 1213852 then
		self.vb.crushCount = self.vb.crushCount + 1
		specWarnCrush:Show(self.vb.crushCount)
		specWarnCrush:Play("shockwave")
		timerCrushCD:Start(self:IsMythic() and "v15.1-34.6" or "v20.2-45.4", self.vb.crushCount+1)
	elseif args.spellId == 1217371 then
		specWarnFlamethrower:Show(self.vb.crushCount)
		specWarnFlamethrower:Play("frontal")
		timerFlamethrowerCD:Start(self:IsMythic() and "v15.1-32.7" or "v20.2-42.5", self.vb.crushCount+1)
	elseif args.spellId == 1215521 or args.spellId == 1217661 then
		self.vb.addsCount = self.vb.addsCount + 1
		specWarnCronies:Show(self.vb.addsCount)
		specWarnCronies:Play("killmob")
		timerCroniesCD:Start(self:IsMythic() and "v47.7-65.5" or "v67.9-89.4", self.vb.addsCount+1)
	elseif args.spellId == 1214043 and self:AntiSpam(4, 1) then
		warnMoltenCannon:Show()
		warnMoltenCannon:Play("watchorb")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 1214147 then
		self.vb.bombCount = self.vb.bombCount + 1
		warnBombs:Show(self.vb.bombCount)
		warnBombs:Play("bombsoon")
		timerBombsCD:Start(self:IsMythic() and "v20.5-40.1" or "v25.5-41.3", self.vb.bombCount+1)
	end
end
--]]

--[[
function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 1214052 or args.spellId == 1217667 then
		timerShieldCD:Start(nil, self.vb.shieldCount+1)
		timerRechargeCast:Stop()
	end
end
--]]
