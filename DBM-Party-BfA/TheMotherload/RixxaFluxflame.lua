local mod	= DBM:NewMod(2115, "DBM-Party-BfA", 7, 1012)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(129231)
mod:SetEncounterID(2107)
mod:SetHotfixNoticeRev(20250302000000)
mod:SetZone(1594)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 260669 259940 259022 270042",
	"SPELL_CAST_SUCCESS 259856 275992",
	"SPELL_AURA_APPLIED 259853"
)

--TODO, video fight to figure out whats going on with azerite and gushing and what makes them diff.
--TODO, more work on timers. Need longer pulls
local warnAxeriteCatalyst			= mod:NewCountAnnounce(259022, 2)--Cast often, so general warning not special
local warnPoropellantBlast			= mod:NewTargetNoFilterAnnounce(259940, 2)

local specWarnChemBurn				= mod:NewSpecialWarningDispel(259853, "RemoveMagic", nil, 2, 1, 2)
local specWarnPoropellantBlast		= mod:NewSpecialWarningYou(259940, nil, nil, nil, 1, 2)
local yellPoropellantBlast			= mod:NewYell(259940)

local timerAxeriteCatalystCD		= mod:NewCDCountTimer(53, 259022, nil, nil, nil, 3)
local timerChemBurnCD				= mod:NewCDCountTimer(13, 259853, nil, nil, 2, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.MAGIC_ICON)
local timerPropellantBlastCD		= mod:NewCDCountTimer(11, 259940, nil, nil, nil, 3)
local timerGushingCatalystCD		= mod:NewCDCountTimer(53, 275992, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON)

mod.vb.azeriteCataCast = 0
mod.vb.chemBurnCast = 0
mod.vb.gushingCatalystCast = 0
mod.vb.propellantBlastCast = 0

function mod:BlastTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnPoropellantBlast:Show()
		specWarnPoropellantBlast:Play("targetyou")
		yellPoropellantBlast:Yell()
	else
		warnPoropellantBlast:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	self.vb.chemBurnCast = 0
	self.vb.azeriteCataCast = 0
	self.vb.gushingCatalystCast = 0
	self.vb.propellantBlastCast = 0
	if self:IsMythic() then
		timerGushingCatalystCD:Start(3-delay, 1)
		timerAxeriteCatalystCD:Start(10-delay, 1)
		timerPropellantBlastCD:Start(22-delay)
		--Chem burn not seen on mythic
--	else--No timer data yet
--		timerGushingCatalystCD:Start(53-delay, 1)
--		timerAxeriteCatalystCD:Start(10-delay, 1)
--		timerPropellantBlastCD:Start(22-delay, 1)
--		timerChemBurnCD:Start(12-delay, 1)--SUCCESS
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 260669 or spellId == 259940 then
		self.vb.propellantBlastCast = self.vb.propellantBlastCast + 1
		self:BossTargetScanner(args.sourceGUID, "BlastTarget", 0.1, 8)
		--"Propellant Blast-259940-npc:129231-000034EF63 = pull:22.0, 11.0, 11.0, 31.0, 11.0, 11.0",
		if self.vb.propellantBlastCast % 3 == 0 then--assumed, need to see 7th cast
			timerPropellantBlastCD:Start(31, self.vb.propellantBlastCast+1)
		else
			timerPropellantBlastCD:Start(11, self.vb.propellantBlastCast+1)
		end
	elseif (spellId == 259022 or spellId == 270042) and self:AntiSpam(5, 1) then
		self.vb.azeriteCataCast = self.vb.azeriteCataCast + 1
		warnAxeriteCatalyst:Show(self.vb.azeriteCataCast)
		--"Azerite Catalyst-270042-npc:129231-000034EF63 = pull:10.0, 53.0, 53.1",
		timerAxeriteCatalystCD:Start(nil, self.vb.azeriteCataCast+1)
		--if self.vb.azeriteCataCast % 2 == 0 then
		--	timerAxeriteCatalystCD:Start(27, self.vb.azeriteCataCast+1)
		--else
		--	timerAxeriteCatalystCD:Start(15, self.vb.azeriteCataCast+1)
		--end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 259856 and self:AntiSpam(5, 1) then
		self.vb.chemBurnCast = self.vb.chemBurnCast + 1
		if self.vb.chemBurnCast % 2 == 0 then
			timerChemBurnCD:Start(27, self.vb.chemBurnCast+1)
		else
			timerChemBurnCD:Start(15, self.vb.chemBurnCast+1)
		end
	elseif spellId == 275992 then
		self.vb.gushingCatalystCast = self.vb.gushingCatalystCast + 1
		--"Gushing Catalyst-275992-npc:129231-000034EF63 = pull:3.0, 53.0, 53.1",
		timerGushingCatalystCD:Start(nil, self.vb.gushingCatalystCast+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 259853 and self:CheckDispelFilter("magic") then
		specWarnChemBurn:CombinedShow(1, args.destName)
		specWarnChemBurn:ScheduleVoice(1, "dispelnow")
	end
end
