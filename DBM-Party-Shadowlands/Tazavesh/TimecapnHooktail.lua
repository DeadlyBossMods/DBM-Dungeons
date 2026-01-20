local mod	= DBM:NewMod(2449, "DBM-Party-Shadowlands", 9, 1194)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(175546)
mod:SetEncounterID(2419)
mod:SetHotfixNoticeRev(20220405000000)
mod:SetZone(2441)

mod:RegisterCombat("combat")

--Midnight private aura replacements
--No private aura for https://www.wowhead.com/beta/spell=350134/infinite-breath yet. Check it if dungeon returns
mod:AddPrivateAuraSoundOption(1240097, true, 1240097, 1)
mod:AddPrivateAuraSoundOption(358947, true, 358947, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1240097, "debuffyou", 17)
	self:EnablePrivateAuraSound(358947, "watchfeet", 8)
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 350517 347151",
	"SPELL_CAST_SUCCESS 352345",
	"SPELL_AURA_APPLIED 354334 350134 1240097",
	"SPELL_AURA_REMOVED 350134",
	"SPELL_PERIODIC_DAMAGE 358947",
	"SPELL_PERIODIC_MISSED 358947"
)
--]]

--Notes: Cannon Barrage has no entries for cast, only damage, no clean timers/warnings for it so omitted
--TODO, Fix hook swipe when blizzard re-enables the ability they accidentally deleted.
--NOTE:, Double time is no longer in combat log and now uses https://www.wowhead.com/ptr-2/spell=1240213/double-time worth re-adding?
--[[
(ability.id = 347149 or ability.id = 350517 or ability.id = 347151) and type = "begincast"
 or ability.id = 352345 and type = "cast"
 or ability.id = 350134 and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--[[
--Boss
local warnInfiniteBreath			= mod:NewTargetCountAnnounce(347149, 4, nil, nil, nil, nil, nil, nil, true)
local warnHookd						= mod:NewTargetNoFilterAnnounce(354334, 2, nil, "Healer")
--local warnDoubleTime				= mod:NewCastAnnounce(350517, 3)

local specWarnInfiniteBreath		= mod:NewSpecialWarningCount(347149, nil, nil, nil, 1, 2)
local specWarnInfiniteBreathDodge	= mod:NewSpecialWarningDodgeCount(347149, nil, nil, nil, 3, 2)
local specWarnAnchorShot			= mod:NewSpecialWarningYou(352345, nil, nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(358947, nil, nil, nil, 1, 8)

local timerInfiniteBreathCD			= mod:NewCDTimer(15, 347149, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
--local timerHookSwipeCD				= mod:NewCDTimer(12, 347151, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
--local timerDoubleTimeCD				= mod:NewCDTimer(54.6, 350517, nil, nil, nil, 3)

--mod:GroupSpells(347151, 354334)--Group Hook'd debuff with Hook Swipe
--Corsair Cannoneers
--local warnCannonBarrage			= mod:NewSpellAnnounce(347370, 3)
local warnAnchorShot				= mod:NewTargetNoFilterAnnounce(352345, 3)

local timerAnchorShotCD				= mod:NewCDTimer(20, 352345, nil, nil, nil, 3)
--11.2
local warnTimeBomb 					= mod:NewTargetNoFilterAnnounce(1240097, 2, nil, "-Tank")--On by default for all but the tank
local specWarnTimeBombDispel		= mod:NewSpecialWarningDispel(1240097, false, nil, nil, 1, 2)--Off by default, because if it's on by default people will dispel it right away like on auto pilot, and it's a huge dps loss to not sit on it for a while

mod.vb.breathCount = 0
mod.vb.anchorCount = 0

--Maybe worth adding? (quest still valid years later)
--"Super Saison-356133-npc:180015-000048C7C5 = pull:28.5, 30.4, 30.4",
--"Sword Toss-368661-npc:179386-000048C7C6 = pull:12.7, 14.6, 14.6",
--These are handled different right now but might sequence if other handling faulters
--"Infinite Breath-347149-npc:175546-000048CB60 = pull:15.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 7.0, 12.0, 12.0, 12.0, 12.0, 7.0, 12.0, 12.0, 12.0", -- [9]
--"Anchor Shot-352345-npc:176178-000048C7C5 = pull:59.0, 21.0, 20.0, 14.0, 21.0, 20.0, 14.0, 21.0, 20.0", -- [1]--OLD
--"Anchor Shot-352345-npc:176178-00000FBFBE = pull:15.0, 20.0, 20.0, 20.0, 20.0, 20.1, 20.0",--NEW

function mod:OnCombatStart(delay)
	self.vb.breathCount = 0
	self.vb.anchorCount = 0
--	timerHookSwipeCD:Start(8.2-delay)--April 5th hotfixes broke it and he doesn't cast this anymore
	timerInfiniteBreathCD:Start(12-delay)
--	timerDoubleTimeCD:Start(55-delay)
	--Cannoneers
	timerAnchorShotCD:Start(15-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 347151 then
--		timerHookSwipeCD:Start()--Work Needed
--	elseif spellId == 350517 then
--		warnDoubleTime:Show()
--		timerDoubleTimeCD:Start()
		--When he casts double time it removes 5 seconds from current breath timer
--		timerInfiniteBreathCD:RemoveTime(5)
		--It also removes 6 seconds from current Anchor Shot timer
--		timerAnchorShotCD:RemoveTime(6)--Handled via counting for now, but counting may fail if pull is long enough
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 352345 then
		self.vb.anchorCount = self.vb.anchorCount + 1
		if args:IsPlayer() then
			specWarnAnchorShot:Show()
			specWarnAnchorShot:Play("targetyou")
		else
			warnAnchorShot:Show(args.destName)
		end
		if self.vb.anchorCount % 3 == 0 then
			timerAnchorShotCD:Start(14)
		else
			timerAnchorShotCD:Start(20)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 354334 then
		warnHookd:Show(args.destName)
	elseif spellId == 350134 then
		self.vb.breathCount = self.vb.breathCount + 1
		if args:IsPlayer() then
			specWarnInfiniteBreath:Show(self.vb.breathCount)
			specWarnInfiniteBreath:Play("bait")
		else
			warnInfiniteBreath:Show(self.vb.breathCount, args.destName)
		end
		timerInfiniteBreathCD:Start()
	elseif spellId == 1240097 then
		if self.Options.SpecWarn1240097dispel and self:CheckDispelFilter("magic") then
			specWarnTimeBombDispel:CombinedShow(0.5, args.destName)
			specWarnTimeBombDispel:ScheduleVoice(0.5, "helpdispel")
		else
			warnTimeBomb:CombinedShow(0.5, args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 350134 and args:IsPlayer() then
		specWarnInfiniteBreathDodge:Show(self.vb.breathCount)
		specWarnInfiniteBreathDodge:Play("breathsoon")
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 358947 and destGUID == UnitGUID("player") and self:AntiSpam(3, 1) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
