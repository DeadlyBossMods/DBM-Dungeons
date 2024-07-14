local mod	= DBM:NewMod(2396, "DBM-Party-Shadowlands", 1, 1182)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(162693)
mod:SetEncounterID(2390)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 321368 321754 320788 323730 323198",
	"SPELL_AURA_REMOVED 321368 321754 320788 323730 323198",
	"SPELL_CAST_START 320772",
	"SPELL_CAST_SUCCESS 320788 323730 321894"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, target scan dark exile to make it faster?
--[[
ability.id = 320772 and type = "begincast"
 or (ability.id = 320788 or ability.id = 323730 or ability.id = 321894) and type = "cast"
 or (ability.id = 321368 or ability.id = 321754) and type = "applybuff"
--]]
local warnIceboundAegis				= mod:NewTargetNoFilterAnnounce(321754, 4)
local warnFrozenBinds				= mod:NewTargetNoFilterAnnounce(323730, 3)
local warnDarkExile					= mod:NewTargetNoFilterAnnounce(321894, 3)

local specWarnCometStorm			= mod:NewSpecialWarningDodgeCount(320772, nil, nil, nil, 2, 2)
local specWarnFrozenBinds			= mod:NewSpecialWarningYou(323730, nil, nil, nil, 1, 2)
local yellFrozenBinds				= mod:NewYell(323730)
local yellFrozenBindsFades			= mod:NewShortYell(323730)
local specWarnDarkExile				= mod:NewSpecialWarningYou(321894, nil, nil, nil, 1, 5)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerCometStormCD				= mod:NewCDCountTimer(24.2, 320772, nil, nil, nil, 3)
local timerIceboundAegisCD			= mod:NewCDCountTimer(24.2, 321754, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerFrozenBindsCD			= mod:NewCDCountTimer(24.2, 323730, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerDarkExileCD				= mod:NewCDCountTimer(35.2, 321894, nil, nil, nil, 3)--35.2-40+
local timerDarkExile				= mod:NewTargetTimer(50, 321894, nil, nil, nil, 5)

mod:AddInfoFrameOption(321754, true)

mod.vb.cometCount = 0
mod.vb.aegisCount = 0
mod.vb.bindsCount = 0
mod.vb.exileCount = 0

function mod:OnCombatStart(delay)
	self.vb.cometCount = 0
	self.vb.aegisCount = 0
	self.vb.bindsCount = 0
	self.vb.exileCount = 0
	timerFrozenBindsCD:Start(8.9-delay, 1)--SUCCESS
	timerIceboundAegisCD:Start(11.7-delay, 1)--11.7-14
	timerCometStormCD:Start(16.5-delay, 1)--16.5-17.2
	timerDarkExileCD:Start(26.5-delay, 1)--SUCCESS--26-30
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 320772 then
		self.vb.cometCount = self.vb.cometCount + 1
		specWarnCometStorm:Show(self.vb.cometCount)
		specWarnCometStorm:Play("watchstep")
		timerCometStormCD:Start(nil, self.vb.cometCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 320788 or spellId == 323730 then
		self.vb.bindsCount = self.vb.bindsCount + 1
		timerFrozenBindsCD:Start(nil, self.vb.bindsCount+1)
	elseif spellId == 321894 then
		self.vb.exileCount = self.vb.exileCount + 1
		timerDarkExileCD:Start(nil, self.vb.exileCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 321368 or spellId == 321754 then
		self.vb.aegisCount = self.vb.aegisCount + 1
		warnIceboundAegis:Show(args.destName)
		timerIceboundAegisCD:Start(nil, self.vb.aegisCount+1)
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	elseif spellId == 320788 or spellId == 323730 then
		if args:IsPlayer() then
			specWarnFrozenBinds:Show()
			specWarnFrozenBinds:Play("targetyou")
			yellFrozenBinds:Yell()
			yellFrozenBindsFades:Countdown(spellId)
		else
			warnFrozenBinds:CombinedShow(0.5, args.destName)
		end
	elseif spellId == 323198 then
		timerDarkExile:Start(50, args.destName)
		if args:IsPlayer() then
			specWarnDarkExile:Show()
			specWarnDarkExile:Play("teleyou")
		else
			warnDarkExile:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 321368 or spellId == 321754 then
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	elseif spellId == 320788 or spellId == 323730 then
		if args:IsPlayer() then
			yellFrozenBindsFades:Cancel()
		end
	elseif spellId == 323198 then
		timerDarkExile:Stop(args.destName)
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
