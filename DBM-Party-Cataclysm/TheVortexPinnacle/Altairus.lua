local mod	= DBM:NewMod(115, "DBM-Party-Cataclysm", 8, 68)
local L		= mod:GetLocalizedStrings()

if not mod:IsCata() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else
	mod.statTypes = "normal,heroic"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(43873)
mod:SetEncounterID(1041)
mod:SetUsedIcons(8)
mod:SetHotfixNoticeRev(20230527000000)
--mod:SetMinSyncRevision(20230226000000)
mod.sendMainBossGUID = true

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
local specWarnBreath		= mod:NewSpecialWarningDodgeCount(88308, nil, nil, nil, 2, 2)
local specWarnDownwind		= mod:NewSpecialWarningSpell(88286, nil, nil, nil, 1, 14)
local specWarnGTFO			= mod:NewSpecialWarningGTFO(413275, nil, nil, nil, 1, 8)

local timerCalltheWindCD	= mod:NewCDCountTimer(20.6, 88276, nil, nil, nil, 6)
local timerBreathCD			= mod:NewCDCountTimer(13.4, 88308, nil, nil, nil, 3)--May be 10.5 pre nerf for cata classic

local specWarnDownburst, timerDownburstCD
if mod:IsRetail() then
	specWarnDownburst		= mod:NewSpecialWarningMoveTo(413295, nil, nil, nil, 2, 14, 4)
	timerDownburstCD		= mod:NewCDCountTimer(35.1, 413295, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)--35.1-44
end

--mod:AddSetIconOption("BreathIcon", 88308, true, false, {8})

mod.vb.activeWind = "none"
mod.vb.windCount = 0
mod.vb.burstCount = 0
mod.vb.breathCount = 0
local tornado = DBM:GetSpellName(86133)

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
	else
		warnBreath:Show(targetname)
	end
end
--]]

local function updateAllTimers(self, ICD)
	if not self:IsRetail() then return end
	DBM:Debug("updateAllTimers running", 3)
	if timerBreathCD:GetRemaining(self.vb.breathCount+1) < ICD then
		local elapsed, total = timerBreathCD:GetTime(self.vb.breathCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerBreathCD extended by: "..extend, 2)
		timerBreathCD:Update(elapsed, total+extend, self.vb.breathCount+1)
	end
	if timerCalltheWindCD:GetRemaining(self.vb.windCount+1) < ICD then
		local elapsed, total = timerCalltheWindCD:GetTime(self.vb.windCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerCalltheWindCD extended by: "..extend, 2)
		timerCalltheWindCD:Update(elapsed, total+extend, self.vb.windCount+1)
	end
	if timerDownburstCD:GetRemaining(self.vb.burstCount+1) < ICD then
		local elapsed, total = timerDownburstCD:GetTime(self.vb.burstCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerDownburstCD extended by: "..extend, 2)
		timerDownburstCD:Update(elapsed, total+extend, self.vb.burstCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.activeWind = "none"
	self.vb.windCount = 0
	self.vb.burstCount = 0
	self.vb.breathCount = 0
	timerCalltheWindCD:Start(5-delay, 1)
	if self:IsMythicPlus() then
		timerBreathCD:Start(self:IsMythicPlus() and 12.1-delay, 1)
		timerDownburstCD:Start(20.5-delay, 1)
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
		updateAllTimers(self, 6)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 413295 then
		self.vb.burstCount = self.vb.burstCount + 1
		specWarnDownburst:Show(tornado)
		specWarnDownburst:Play("getknockedup")
		timerDownburstCD:Start(nil, self.vb.burstCount+1)
		--updateAllTimers(self, 1.2)--accurate, but not really worth triggering
	elseif args.spellId == 181089 then--Encounter Event
		self.vb.windCount = self.vb.windCount + 1
		warnCalltheWind:Show(self.vb.windCount)
		timerCalltheWindCD:Start(self:IsMythicPlus() and 15.4 or 20.6, self.vb.windCount+1)
		--updateAllTimers(self, 1.2)--accurate, but not really worth triggering
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
