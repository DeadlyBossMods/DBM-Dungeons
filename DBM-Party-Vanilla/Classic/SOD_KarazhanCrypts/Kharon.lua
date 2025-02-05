if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("Kharon", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3143)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1217694 1217952",
	"SPELL_AURA_APPLIED 1218038 1218089",
	"SPELL_AURA_REMOVED 1218038 1218089",
	"SPELL_AURA_APPLIED_DOSE 1217844"
)

mod:SetUsedIcons(7, 8)

-- Mind Control
-- Kill mind controlled player, 2 sec cast, but just triggering on aura applied because the cast isn't actionable
-- "Illimitable Dominion-1218089-npc:237439-00001A5C02 = pull:42.5, 86.2, 80.5, 80.9",
-- "Illimitable Dominion-1218089-npc:237439-00001BDBFD = pull:40.1, 82.5, 77.7",

-- Red Death
-- Move away from boss
-- SPELL_CAST_START "The Red Death-1217694-npc:237439-00001A5E01 = pull:21.1, 30.8, 30.7, 30.8, 30.7, 30.8, 30.8",

-- Inhumane
-- Player gets frozen in a block of ice that others need to break
-- TODO: can we predict the target early? it has 3 sec casting time
-- "<41.47 18:00:47> [CLEU] SPELL_AURA_APPLIED#Creature-0-5209-2875-4757-237439-00001A5E01#Kharon#Player-5827-02484403#Ðjs#1218038#Inhume#DEBUFF#nil#nil#nil#nil#nil",
-- "Inhume-1218038-npc:237439-00001A5C02 = pull:35.8, 72.9, 73.3, 69.5",

-- Charred Skin
-- Torch bearer gets debuff stacks that do fire damage over time. Drop torch when stacks are too high, not yet sure what a good threshold is.
-- This was buggy and completely missing in at least one of my attempts!
-- I wonder if you can also cheese this by dropping the torch right before the debuff triggers as it's consistent every 5 sec, but probably too annoying to do.
-- 	"<187.32 17:48:52> [CLEU] SPELL_AURA_APPLIED_DOSE#Player-5827-02484403#Ðjs#Player-5827-02484403#Ðjs#1217844#Charred Skin#DEBUFF#10#nil#nil#nil#nil",

-- Fear
-- CAST_START times, 2 sec cast
-- "Dreadful Visage-1217952-npc:237439-00001D2BCC = pull:30.7, 72.8, 76.0, 69.6",
-- "Dreadful Visage-1217952-npc:237439-00001D2AAA = pull:30.7, 63.6, 67.6",
-- "Dreadful Visage-1217952-npc:237439-00001E153E = pull:30.7, 64.7, 72.9",


local enrageTimer		= mod:NewBerserkTimer(300)

local warnWrap			= mod:NewSpecialWarningTargetChange(1218038, nil, nil, nil, 1, 2)
local warnPlayerStacks	= mod:NewStackAnnounce(1217844, 2)
local warnFearCast		= mod:NewCastAnnounce(1217952)

local timerRedDeath		= mod:NewNextTimer(30.7, 1217694)
local timerWrap			= mod:NewVarTimer("v64.8-73.3", 1218038, nil, nil, nil, 3)
local timerNextStack	= mod:NewTargetCountTimer(5, 1217844)
local timerMc			= mod:NewVarTimer("v77.5-86.2", 1218089)
local timerFear			= mod:NewVarTimer("v63.6-76.0", 1217952, 5782)

-- Enabled even for ranged because everyone is stacking near to the torch bearer
local specWarnRedDeath	= mod:NewSpecialWarningMove(1217694, nil, nil, nil, 1, 2)
local specWarnDropTorch	= mod:NewSpecialWarning("SpecWarnDropTorch", nil, nil, nil, 1, 18)
local specWarnMc		= mod:NewSpecialWarningTargetChange(1218089, nil, nil, nil, 1, 2)


local yellWrap	= mod:NewIconTargetYell(1218038)
local yellMc	= mod:NewIconTargetYell(1218089)

mod:AddSetIconOption("SetIconOnWrapTarget", 1218038, true, 0, {8})
mod:AddSetIconOption("SetIconOnMindControlTarget", 1218089, true, 0, {7})

function mod:OnCombatStart(delay)
	timerRedDeath:Start(21.1 - delay) -- Consistent across 5 logs
	timerWrap:Start(35.8 - delay) -- Also consistent
	timerMc:Start("v42-45")
	enrageTimer:Start(-delay)
	timerFear:Start(32.7)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(1217694) then
		timerRedDeath:Start()
		specWarnRedDeath:Show()
		specWarnRedDeath:Play("watchstep")
	elseif args:IsSpell(1217952) then
		warnFearCast:Show()
		-- update timer to exactly 2 sec remaining, a bit ugly with var timers?
		local _, fearTimerTotal = timerFear:GetTime()
		if not fearTimerTotal or fearTimerTotal == 0 then
			fearTimerTotal = 70
		end
		timerFear:Cancel()
		timerFear:Update(fearTimerTotal - 2, fearTimerTotal)
		timerFear:DelayedStart(2)
	end
end

function mod:YellLoop(yell, icon, maxCount)
	maxCount = maxCount - 1
	yell:Show(icon)
	if maxCount > 0 then
		self:ScheduleMethod(3, "YellLoop", yell, icon, maxCount)
	end
end

-- Something about SetIcon in dungeons seems fishy, at least on SoD, using this instead
local function setIcon(name, icon)
	local uId = DBM:GetRaidUnitId(name)
	if not uId or not UnitExists(uId) then
		return
	end
	local currentIcon = GetRaidTargetIndex(uId)
	if currentIcon ~= icon then
		SetRaidTarget(uId, icon)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(1218038) then
		if args:IsPlayer() then
			self:YellLoop(yellWrap, 7, 6)
		else
			warnWrap:Show(args.destName)
			warnWrap:Play("targetchange")
		end
		timerWrap:Start()
		if self.Options.SetIconOnWrapTarget then
			setIcon(args.destName, 5)
		end
	elseif args:IsSpell(1218089) then
		-- args:IsPlayer() works as expected in tests, but I've seen people in my group where this yell didn't get canceled when we broke MC.
		-- Unfortunately I didn't get MC'd myself, so no good data, but I suspect the flags may work out in a way that IsPlayer() is false during mind control.
		-- Needs more data/I need to get mind controlled myself with a full combat log, until then let's explicitly check the GUID.
		if args:IsPlayer() or args.destGUID == UnitGUID("player") then
			self:YellLoop(yellMc, 8, 6)
		else
			specWarnMc:Show(args.destName)
			specWarnMc:Play("targetchange")
		end
		timerMc:Start()
		if self.Options.SetIconOnMindControlTarget then
			setIcon(args.destName, 8)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpell(1218038) then
		if self.Options.SetIconOnWrapTarget then
			setIcon(args.destName, 0)
		end
		if args:IsPlayer() then
			self:UnscheduleMethod("YellLoop", yellWrap)
		end
	elseif args:IsSpell(1218089) then
		if self.Options.SetIconOnMindControlTarget then
			setIcon(args.destName, 0)
		end
		if args:IsPlayer() then
			self:UnscheduleMethod("YellLoop", yellMc)
		end
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpell(1217844) then
		local amount = args.amount or 1
		timerNextStack:Stop()
		timerNextStack:Start(5, amount + 1, args.destName)
		if args:IsPlayer() then
			if amount == 10 or amount == 15 or amount == 20 then -- If you have more than 20 then you better have some strategy for that, like fire res, dunno.
				specWarnDropTorch:Show(amount)
				specWarnDropTorch:Play("droptorch")
			end
		else
			if amount % 5 == 0 then
				warnPlayerStacks:Show(args.destName, amount)
			end
		end
	end
end
