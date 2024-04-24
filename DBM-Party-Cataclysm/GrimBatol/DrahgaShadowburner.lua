local mod	= DBM:NewMod(133, "DBM-Party-Cataclysm", 3, 71)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40319)
mod:SetEncounterID(1048)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 75328 75317",
	"SPELL_CAST_START 90950",
--	"SPELL_SUMMON",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_AURA_UNFILTERED"
)

--shredding? Disabled since it seemed utterly useless in my limited testing
--local warnShredding			= mod:NewSpellAnnounce(75271, 3)
local warnFlamingFixate	 		= mod:NewTargetNoFilterAnnounce(82850, 4)

local specWarnFlamingFixate		= mod:NewSpecialWarningRun(82850, nil, nil, nil, 4, 2)
local specWarnDevouring 		= mod:NewSpecialWarningDodgeCount(90950, nil, nil, nil, 2, 2)
local specWarnSeepingTwilight	= mod:NewSpecialWarningMove(75317, nil, nil, nil, 2, 2)

local timerAddCD				= mod:NewCDCountTimer(20.6, 90949, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--20.6-27. 24 is the average
local timerDevouringCD			= mod:NewCDCountTimer(40, 90950, nil, nil, nil, 3)
local timerDevouring			= mod:NewBuffActiveTimer(5, 90950, nil, nil, nil, 3)
--local timerShredding			= mod:NewBuffActiveTimer(20, 75271)

local fixateWarned = {}
local Valiona = DBM:EJ_GetSectionInfo(3369)
mod.vb.valionaLanded = false
mod.vb.addCount = 0
mod.vb.devourCount = 0

function mod:OnCombatStart(delay)
	table.wipe(fixateWarned)
	self.vb.valionaLanded = false
	self.vb.addCount = 0
	self.vb.devourCount = 0
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 75328 then
		timerDevouringCD:Cancel()
		timerDevouring:Cancel()
	elseif args.spellId == 75317 and args:IsPlayer() then
		specWarnSeepingTwilight:Show()
		specWarnSeepingTwilight:Play("runaway")
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 90950 then
		self.vb.devourCount = self.vb.devourCount + 1
		specWarnDevouring:Show(self.vb.devourCount)
		specWarnDevouring:Play("breathsoon")
		timerDevouring:Start()
		timerDevouringCD:Start(nil, self.vb.devourCount+1)
	end
end

--[[
function mod:SPELL_SUMMON(args)
	if args.spellId == 75271 then
		warnShredding:Show()
		timerShredding:Start()
	end
end--]]

function mod:CHAT_MSG_MONSTER_YELL(msg, npc)
	if npc == Valiona and not self.vb.valionaLanded then
		self.vb.valionaLanded = true
		timerDevouringCD:Start(29, 1)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg:find("spell:75218") then--Add spawning
		self.vb.addCount = self.vb.addCount + 1
		timerAddCD:Start(nil, self.vb.addCount+1)
	end
end

do
	local flamingFixate = DBM:GetSpellInfo(82850)
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
