if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("Kharon", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3143)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1217694",
	"SPELL_AURA_APPLIED 1218038",
	"SPELL_AURA_REMOVED 1218038",
	"SPELL_AURA_APPLIED_DOSE 1217844"
)

mod:SetUsedIcons(5)

-- Mind Control
-- I didn't understand that mechanic, it's a 2 min debuff that can't be purged, but it somehow disappears earlier, not sure what triggers that.
-- "Illimitable Dominion-1218089-npc:237439-00001A5C02 = pull:42.5, 86.2, 80.5, 80.9",

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


local warnWrap			= mod:NewSpecialWarningTargetChange(1218038, nil, nil, nil, 1, 2)
local warnPlayerStacks	= mod:NewStackAnnounce(1217844, 2)

local timerRedDeath		= mod:NewNextTimer(30.7, 1217694)
local timerWrap			= mod:NewVarTimer("v64.8-73.3", 1218038, nil, nil, nil, 3)
local timerNextStack	= mod:NewTargetCountTimer(5, 1217844)

-- Enabled even for ranged because everyone is stacking near to the torch bearer
local specWarnRedDeath	= mod:NewSpecialWarningMove(1217694, nil, nil, nil, 1, 2)
local specWarnDropTorch	= mod:NewSpecialWarning("SpecWarnDropTorch", nil, nil, nil, 1, 6)

local yellWrap = mod:NewIconTargetYell(1218038)

function mod:OnCombatStart(delay)
	timerRedDeath:Start(21.1 - delay) -- Consistent across 5 logs
	timerWrap:Start(35.8 - delay) -- Also consistent
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(1217694) then
		timerRedDeath:Start()
		specWarnRedDeath:Show()
		specWarnRedDeath:Play("runout")
	end
end

function mod:YellLoop(maxCount)
	maxCount = maxCount - 1
	yellWrap:Show(5)
	if maxCount > 0 then
		self:ScheduleMethod(2, "YellLoop", maxCount)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(1218038) then
		if args:IsPlayer() then
			self:YellLoop(8)
		else
			warnWrap:Show(args.destName)
			warnWrap:Play("targetchange")
		end
		timerWrap:Start()
		self:SetIcon(args.destName, 5)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpell(1218038) then
		self:RemoveIcon(args.destName)
		if args:IsPlayer() then
			self:UnscheduleMethod("YellLoop")
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
				specWarnDropTorch:Play("stackhigh") -- TODO: replace with "droptorch" once new Core is out
			end
		else
			if amount % 5 == 0 then
				warnPlayerStacks:Show(args.destName, amount)
			end
		end
	end
end
