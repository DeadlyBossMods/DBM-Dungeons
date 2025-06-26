local mod	= DBM:NewMod(2094, "DBM-Party-BfA", 2, 1001)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(126969)
mod:SetEncounterID(2095)
mod:SetHotfixNoticeRev(20230505000000)
mod:SetZone(1754)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 256405 256489 256494",
	"SPELL_CAST_SUCCESS 256358",
	"SPELL_DAMAGE 256477 256552",
	"SPELL_MISSED 256477 256552"
)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_AURA_REMOVED_DOSE 257829",
	"SPELL_AURA_REMOVED 257829",
	"UNIT_DIED"
)

--[[
(ability.id = 256405 or ability.id = 256489 or ability.id = 256494 or ability.id = 257904) and type = "begincast"
 or (ability.id = 256358 or ability.id = 256477 or ability.id = 256363) and type = "cast"
 or type = "death" and target.id = 129699
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --]]
 --Note, most ability timers not consistent enough for decent timers, so disabled on purpose. They'd be misleading and non constructive
local warnSharkToss					= mod:NewTargetNoFilterAnnounce(256358, 4)
local warnGreasy					= mod:NewCountAnnounce(257829, 2)
local warnRearm						= mod:NewSpellAnnounce(256489, 4)

local specWarnSharkToss				= mod:NewSpecialWarningYou(256358, nil, nil, nil, 1, 2)
local yellSharkToss					= mod:NewYell(256358)
local specWarnSharknado				= mod:NewSpecialWarningRun(256405, nil, nil, nil, 4, 2)
--local specWarnRearm					= mod:NewSpecialWarningDodge(256489, nil, nil, nil, 2, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(256552, nil, nil, nil, 1, 8)

local timerRP						= mod:NewRPTimer(68)
--local timerSharkTossCD			= mod:NewCDTimer(31.5, 194956, nil, nil, nil, 3)--Disabled until more data, seems highly variable, even pull to pull
local timerSharknadoCD				= mod:NewCDTimer(26.7, 256405, nil, nil, nil, 3)--Only timer that's really accurate
local timerRearmCD					= mod:NewCDCountTimer("d19", 256489, nil, nil, nil, 3)--heavily affected by spell queues and may be disabled again if it leads to confusion/complaints

mod:AddRangeFrameOption(8, 256358)

function mod:OnCombatStart(delay)
	timerSharknadoCD:Start(20.4-delay)
	timerRearmCD:Start(31.3-delay, 1)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(8)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 256405 then
		specWarnSharknado:Show()
		specWarnSharknado:Play("justrun")
		timerSharknadoCD:Start()
	elseif spellId == 256489 or spellId == 256494 then
		if self:AntiSpam(3, 3) then
			warnRearm:Show()
		end
		if spellId == 256494 then
			timerRearmCD:Start(8, 2)--8-12
			timerRearmCD:Start(19.3, 1)--19-33.9
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 256358 then--Shark toss from boss, gives target of Sawtooth Shark
		if args:IsPlayer() then
			specWarnSharkToss:Show()
			specWarnSharkToss:Play("runaway")
			yellSharkToss:Yell()
		else
			warnSharkToss:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	local spellId = args.spellId
	if spellId == 257829 then
		local amount = args.amount or 0
		warnGreasy:Show(amount)
		--"<78.80 02:52:31> [CLEU] SPELL_AURA_REMOVED#Creature-0-2084-1754-9152-130099-00007D20E9#Lightning#Creature-0-2084-1754-9152-130099-00007D20E9#Lightning#257829#Greasy#BUFF#nil", -- [62]
		--"<104.47 02:52:56> [IsEncounterInProgress()] true", -- [69]
		if amount == 0 then
			timerRP:Start(25)
		end
	end
end
mod.SPELL_AURA_REMOVED = mod.SPELL_AURA_REMOVED_DOSE

function mod:SPELL_DAMAGE(sourceGUID, _, _, _, destGUID, destName, _, _, spellId, spellName)
	if spellId == 256477 and self:AntiSpam(3, 1) then--Aggregate, we only want first person to take damage in combat log, they're the original target
		local cid = self:GetCIDFromGUID(sourceGUID)
		if cid == 129448 then--Hammer Shark hitting a player on spawn
			if destGUID == UnitGUID("player") then
				specWarnSharkToss:Show()
				specWarnSharkToss:Play("runaway")
				yellSharkToss:Yell()
			else
				warnSharkToss:Show(destName)
			end
		end
	elseif spellId == 256552 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

--"<146.61 02:53:38> [CLEU] UNIT_DIED##nil#Creature-0-2084-1754-9152-129699-00007D20E9#Ludwig Von Tortollen#-1#false#nil#nil", -- [334]
--"<182.54 02:54:14> [ENCOUNTER_START] ENCOUNTER_START#2095#Ring of Booty#1#5", -- [366]
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 129699 then--Ludwig Von Tortollen
		timerRP:Start(35)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	--"<0.92 02:51:13> [CHAT_MSG_MONSTER_YELL] Gather 'round and place yer bets! We got a new set of vict-- uh... competitors! Take it away, Gurthok and Wodin!#Davey \"Two Eyes\"###Hunyadi##0#0##0#1165#nil#0#false#false#false#false",
	--"<63.07 02:52:15> [CLEU] SPELL_AURA_APPLIED#Creature-0-2084-1754-9152-130099-00007D20E9#Lightning#Creature-0-2084-1754-9152-130099-00007D20E9#Lightning#257829#Greasy#BUFF#nil", -- [23]
	if (msg == L.openingRP or msg:find(L.openingRP)) and self:LatencyCheck(1000) then
		self:SendSync("openingRP")
	end
end

function mod:OnSync(msg)
	if msg == "openingRP" and self:AntiSpam(10, 6) then
		timerRP:Start(62)
	end
end
