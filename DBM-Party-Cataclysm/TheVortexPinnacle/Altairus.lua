local mod	= DBM:NewMod(115, "DBM-Party-Cataclysm", 8, 68)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"
mod.upgradedMPlus = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(43873)
mod:SetEncounterID(1041)
mod:SetUsedIcons(8)
mod:SetHotfixNoticeRev(20230427000000)
--mod:SetMinSyncRevision(20230226000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 88308",
	"SPELL_CAST_SUCCESS 413295 181089",
	"SPELL_AURA_APPLIED 88282 88286 413275"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, verify changes on non mythic+ in 10.1
--NOTE, breath target no longer available in 10.1, this code may still be used in classic cataclysm
--NOTE, Biting Cold doesn't seem worth adding anything for. it's a passive healing requirement
--[[
ability.id = 88308 and type = "begincast"
 or (ability.id = 413295 or ability.id = 181089) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--local warnBreath			= mod:NewTargetNoFilterAnnounce(88308, 2)
local warnCalltheWind		= mod:NewCountAnnounce(88276, 2)
local warnUpwind			= mod:NewSpellAnnounce(88282, 1)

--local specWarnBreath		= mod:NewSpecialWarningYou(88308, "-Tank", nil, 2, 1, 2)
--local specWarnBreathNear	= mod:NewSpecialWarningClose(88308, nil, nil, nil, 1, 2)
local specWarnBreath		= mod:NewSpecialWarningDodgeCount(88308, nil, nil, nil, 2, 2)
local specWarnDownburst		= mod:NewSpecialWarningCount(413295, nil, nil, nil, 2, 2, 4)
local specWarnDownwind		= mod:NewSpecialWarningSpell(88286, nil, nil, nil, 1, 14)
local specWarnGTFO			= mod:NewSpecialWarningGTFO(413275, nil, nil, nil, 1, 8)

local timerCalltheWindCD	= mod:NewCDCountTimer(20.6, 88276, nil, nil, nil, 6)
local timerBreathCD			= mod:NewCDCountTimer(13.4, 88308, nil, nil, nil, 3)--May be 10.5 pre nerf for cata classic
local timerDownburstCD		= mod:NewCDCountTimer(43.7, 413295, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)

--mod:AddSetIconOption("BreathIcon", 88308, true, false, {8})

mod.vb.activeWind = "none"
mod.vb.windCount = 0
mod.vb.burstCount = 0
mod.vb.breathCount = 0

--[[
function mod:BreathTarget()
	local targetname = self:GetBossTarget(43873)
	if not targetname then return end
	if self.Options.BreathIcon then
		self:SetIcon(targetname, 8, 4)
	end
	if targetname == UnitName("player") then--Tank doesn't care about this so if your current spec is tank ignore this warning.
		specWarnBreath:Show()
		specWarnBreath:Play("targetyou")
	elseif self:CheckNearby(10, targetname) then
		specWarnBreathNear:Show(targetname)
		specWarnBreathNear:Play("runaway")
	else
		warnBreath:Show(targetname)
	end
end
--]]

function mod:OnCombatStart(delay)
	self.vb.activeWind = "none"
	self.vb.windCount = 0
	self.vb.burstCount = 0
	self.vb.breathCount = 0
	timerCalltheWindCD:Start(5-delay, 1)
	if self:IsMythicPlus() then
		timerBreathCD:Start(self:IsMythicPlus() and 13.1-delay, 1)
		timerDownburstCD:Start(21.6-delay, 1)
	else
		--TODO, recheck on non mythic plus
		timerBreathCD:Start(10.7-delay, 1)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 88308 then
--		self:ScheduleMethod(0.2, "BreathTarget")
		self.vb.breathCount = self.vb.breathCount + 1
		specWarnBreath:Show(self.vb.breathCount)
		specWarnBreath:Play("breathsoon")
		timerBreathCD:Start(self:IsMythicPlus() and 21.8 or 13.4, self.vb.breathCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 413295 then
		self.vb.burstCount = self.vb.burstCount + 1
		specWarnDownburst:Show(self.vb.burstCount)
		specWarnDownburst:Play("specialsoon")
		timerDownburstCD:Start()
	elseif args.spellId == 181089 then--Encounter Event
		self.vb.windCount = self.vb.windCount + 1
		warnCalltheWind:Show(self.vb.windCount)
		if self:IsMythicPlus() then
			if self.vb.windCount % 4 == 2 then--2, 6, 10, etc
				timerCalltheWindCD:Start(19.4, self.vb.windCount+1)
			else
				timerCalltheWindCD:Start(15.4, self.vb.windCount+1)
			end
		else
			timerCalltheWindCD:Start(20.6, self.vb.windCount+1)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 88282 and args:IsPlayer() and self.vb.activeWindactiveWind ~= "up" then
		warnUpwind:Show()
		self.vb.activeWindactiveWind = "up"
	elseif args.spellId == 88286 and args:IsPlayer() and self.vb.activeWindactiveWind ~= "down" then
		specWarnDownwind:Show()
		specWarnDownwind:Play("getupwind")
		self.vb.activeWindactiveWind = "down"
	elseif args.spellId == 413275 and args:IsPlayer() and self:AntiSpam(2.5, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 88276 then
		warnCalltheWind:Show()
		timerCalltheWindCD:Start()
	end
end
--]]
