local mod	= DBM:NewMod(133, "DBM-Party-Cataclysm", 3, 71)
local L		= mod:GetLocalizedStrings()

if not mod:IsCata() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else--TODO, refine for cata classic since no timewalker there
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40319)
mod:SetEncounterID(1048)
mod:SetHotfixNoticeRev(20240614000000)
--mod:SetMinSyncRevision(20230929000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 75328 75317",
	"SPELL_CAST_START 90950 448013 456751 450095",
--	"SPELL_SUMMON",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_AURA_UNFILTERED"
)

--shredding? Disabled since it seemed utterly useless in my limited testing
--local warnShredding			= mod:NewSpellAnnounce(75271, 3)
local warnFlamingFixate	 		= mod:NewTargetNoFilterAnnounce(82850, 4)

local specWarnAdds				= mod:NewSpecialWarningSwitch(90949, "Dps", nil, nil, 1, 2)
local specWarnFlamingFixate		= mod:NewSpecialWarningRun(82850, nil, nil, nil, 4, 2)
local specWarnDevouring 		= mod:NewSpecialWarningDodgeCount(90950, nil, nil, nil, 2, 2)
local specWarnSeepingTwilight	= mod:NewSpecialWarningGTFO(75317, nil, nil, nil, 2, 8)

local timerAddCD				= mod:NewCDCountTimer(20.6, 90949, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--20.6-27. 24 is the average
local timerDevouringCD			= mod:NewCDCountTimer(40, 90950, nil, nil, nil, 3)
local timerDevouring			= mod:NewBuffActiveTimer(5, 90950, nil, nil, nil, 3)
--local timerShredding			= mod:NewBuffActiveTimer(20, 75271)
--Add TWW unique stuff
local warnTwilightBuffet, timerTwilightBuffetCD, warnCurseofEntropy, timerCurseofEntropyCD
if not mod:IsCata() then
	warnTwilightBuffet			= mod:NewCountAnnounce(456751, 3)
	warnCurseofEntropy			= mod:NewCountAnnounce(450095, 3)
	timerTwilightBuffetCD		= mod:NewCDCountTimer(30, 456751, nil, nil, nil, 2)
	timerCurseofEntropyCD		= mod:NewCDCountTimer(30, 450095, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
end

local fixateWarned = {}
local Valiona = DBM:EJ_GetSectionInfo(3369)
mod.vb.addCount = 0
mod.vb.devourCount = 0
mod.vb.buffetCount = 0
mod.vb.curseCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	table.wipe(fixateWarned)
	self.vb.addCount = 0
	self.vb.devourCount = 0
	self.vb.buffetCount = 0
	self.vb.curseCount = 0
	if not self:IsCata() then
		timerCurseofEntropyCD:Stop()
		timerAddCD:Start(8, 1)--Maybe also true in cata?
		timerCurseofEntropyCD:Start(17, 1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 75328 then--Twilight Shift (Valiona running away)
		timerDevouringCD:Cancel()
		timerDevouring:Cancel()
		if self:IsCata() then
			timerTwilightBuffetCD:Stop()
		end
	elseif args.spellId == 75317 and args:IsPlayer() then
		specWarnSeepingTwilight:Show(args.spellName)
		specWarnSeepingTwilight:Play("watchfeet")
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 90950 then
		self.vb.devourCount = self.vb.devourCount + 1
		specWarnDevouring:Show(self.vb.devourCount)
		specWarnDevouring:Play("breathsoon")
		timerDevouring:Start()
		timerDevouringCD:Start(self:IsCata() and 40 or 37.5, self.vb.devourCount+1)
	elseif args.spellId == 448013 then--Invocation of Shadowflame (New add summon spell trigger in TWW)
		self.vb.addCount = self.vb.addCount + 1
		specWarnAdds:Show(self.vb.addCount)
		timerAddCD:Start(self:GetStage(2) and 30 or 26, self.vb.addCount+1)
	elseif args.spellId == 456751 then
		self.vb.buffetCount = self.vb.buffetCount + 1
		warnTwilightBuffet:Show(self.vb.buffetCount)
		timerTwilightBuffetCD:Start(nil, self.vb.buffetCount+1)
	elseif args.spellId == 450095 then
		self.vb.curseCount = self.vb.curseCount + 1
		warnCurseofEntropy:Show(self.vb.curseCount)
		timerCurseofEntropyCD:Start(self:GetStage(2) and 30 or 26, self.vb.curseCount+1)
	end
end

--[[
function mod:SPELL_SUMMON(args)
	if args.spellId == 75271 then
		warnShredding:Show()
		timerShredding:Start()
	end
end--]]

--"<78.70 00:51:47> [CHAT_MSG_MONSTER_YELL] If they do not kill you, I will do it myself!#Valiona###Drahga Shadowburner##0#0##0#2916#nil#0#f
--"<93.66 00:52:02> [CLEU] SPELL_CAST_START#Creature-0-2085-670-19236-40319-00006A7386#Drahga Shadowburner(0.0%-100.0%)##nil#448013#Invocation of Shadowflame#nil#nil",
--"<101.62 00:52:10> [CLEU] SPELL_CAST_START#Vehicle-0-2085-670-19236-40320-00006A7386#Valiona(87.8%-0.0%)##nil#456751#Twilight Buffet#nil#nil",
--"<103.60 00:52:12> [CLEU] SPELL_CAST_START#Creature-0-2085-670-19236-40319-00006A7386#Drahga Shadowburner(0.0%-100.0%)##nil#450095#Curse of Entropy#nil#nil",
--"<107.30 00:52:16> [CLEU] SPELL_CAST_START#Vehicle-0-2085-670-19236-40320-00006A7386#Valiona(83.1%-0.0%)##nil#90950#Devouring Flames#nil#nil",
function mod:CHAT_MSG_MONSTER_YELL(msg, npc)
	if npc == Valiona and self:GetStage(1) then
		self:SetStage(2)
		timerDevouringCD:Start(29, 1)
		if not self:IsCata() then
			timerAddCD:Stop()
			timerCurseofEntropyCD:Stop()
			timerAddCD:Start(14.9, self.vb.addCount+1)--Maybe also restarts in cata?
			timerTwilightBuffetCD:Start(22.9, 1)
			timerCurseofEntropyCD:Start(24.9, self.vb.curseCount+1)
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg:find("spell:75218") then--Add spawning
		self.vb.addCount = self.vb.addCount + 1
		specWarnAdds:Show(self.vb.addCount)
		timerAddCD:Start(nil, self.vb.addCount+1)
	end
end

do
	--Still not in the combat log in TWW
	local flamingFixate = DBM:GetSpellName(82850)
	function mod:UNIT_AURA_UNFILTERED(uId)
		local isFixate = DBM:UnitDebuff(uId, flamingFixate)
		local name = DBM:GetUnitFullName(uId) or "UNKNOWN"
		if not isFixate and fixateWarned[name] then
			fixateWarned[name] = nil
		elseif isFixate and not fixateWarned[name] then
			fixateWarned[name] = true
			if UnitIsUnit(uId, "player") then
				specWarnFlamingFixate:Show()
				specWarnFlamingFixate:Play("justrun")
			else
				warnFlamingFixate:Show(name)
			end
		end
	end
end
