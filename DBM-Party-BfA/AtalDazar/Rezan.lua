local mod	= DBM:NewMod(2083, "DBM-Party-BfA", 1, 968)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(122963)
mod:SetEncounterID(2086)
mod:SetHotfixNoticeRev(20231023000000)
mod:SetMinSyncRevision(20231023000000)
mod:SetZone(1763)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 255371 257407 260683",
	"SPELL_CAST_SUCCESS 255434",
	"SPELL_AURA_APPLIED 257407",
	"SPELL_AURA_REMOVED 257407 255421",
	"RAID_BOSS_WHISPER",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

--[[
(ability.id = 255371 or ability.id = 257407 or ability.id = 260683) and type = "begincast"
 or ability.id = 255434 and type = "cast"
 or ability.id = 257407 or ability.id = 255421
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, Bone Quake deleted in M+? It's in journal but never cast
--TODO, no two pulls are same timer wise. pursuit kinda fucks timers to hell. makes it hard to learn ACTUAL cds since spells get delayed by ICDs and spell queues
local warnPursuit				= mod:NewTargetAnnounce(257407, 2)

local specWarnTeeth				= mod:NewSpecialWarningDefensive(255434, nil, nil, nil, 1, 2)
local specWarnFear				= mod:NewSpecialWarningMoveTo(255371, nil, nil, nil, 3, 13)
local yellPursuit				= mod:NewYell(257407)
local specWarnPursuit			= mod:NewSpecialWarningRun(257407, nil, nil, nil, 4, 2)
local specWarnBoneQuake			= mod:NewSpecialWarningSpell(260683, nil, nil, nil, 2, 2)

local timerTeethCD				= mod:NewCDCountTimer(25, 255434, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--actual minimum timer not known
local timerFearCD				= mod:NewCDCountTimer(35.1, 255371, nil, nil, nil, 2)--actual minimum timer not known
local timerPursuitCD			= mod:NewCDCountTimer(35.1, 257407, nil, nil, nil, 3)--actual minimum timer not known

mod.vb.teethCount = 0--27.1, 49.7, 29.1, 47.5, 26.7 (some timer examples, min used, and timer correction used otherwise
mod.vb.fearCount = 0
mod.vb.pursuitCount = 0

--Pursuit/Devour ending triggers 9.1 ICD
--Terrifing Visage cast triggers 9.5 ICD
--Serrated teeth triggers 3.5 ICD
--Serated teeth has highest spell queue priority
--ICDs mess CDs all to hell since pursuit is a wild card
--it's likely we'll never learn any of these actual CDs are for true correctness
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerTeethCD:GetRemaining(self.vb.teethCount+1) < ICD then
		local elapsed, total = timerTeethCD:GetTime(self.vb.teethCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerTeethCD extended by: "..extend, 2)
		timerTeethCD:Update(elapsed, total+extend, self.vb.teethCount+1)
	end
	if timerFearCD:GetRemaining(self.vb.fearCount+1) < ICD then
		local elapsed, total = timerFearCD:GetTime(self.vb.fearCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerFearCD extended by: "..extend, 2)
		timerFearCD:Update(elapsed, total+extend, self.vb.fearCount+1)
	end
	if timerPursuitCD:GetRemaining(self.vb.pursuitCount+1) < ICD then
		local elapsed, total = timerPursuitCD:GetTime(self.vb.pursuitCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerPursuitCD extended by: "..extend, 2)
		timerPursuitCD:Update(elapsed, total+extend, self.vb.pursuitCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.teethCount = 0
	self.vb.fearCount = 0
	self.vb.pursuitCount = 0
	timerTeethCD:Start(6-delay, 1)--8.1
	timerFearCD:Start(11.7-delay, 1)
	timerPursuitCD:Start(21.7-delay, 1)
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 257407 and self:AntiSpam(5, args.destName) then--Backup if CHAT_MSG_RAID_BOSS_EMOTE/RAID_BOSS_WHISPER doesn't work
		if args:IsPlayer() then
			specWarnPursuit:Show()
			specWarnPursuit:Play("justrun")
			yellPursuit:Yell()
		else
			warnPursuit:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 257407 or (spellId == 255421 and args:IsDestTypeHostile()) then--Pursuit ending with no devour happening, or devour ending on Rezan
		updateAllTimers(self, 9.1)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 255371 then
		self.vb.fearCount = self.vb.fearCount + 1
		specWarnFear:Show(DBM_COMMON_L.BREAK_LOS)
		specWarnFear:Play("breaklos")
		timerFearCD:Start(nil, self.vb.fearCount+1)
		updateAllTimers(self, 9.5)
	elseif spellId == 257407 then
		self.vb.pursuitCount = self.vb.pursuitCount + 1
		timerPursuitCD:Start(nil, self.vb.pursuitCount+1)
	elseif spellId == 260683 then
		specWarnBoneQuake:Show()
		specWarnBoneQuake:Play("mobsoon")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 255434 then
		self.vb.teethCount = self.vb.teethCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTeeth:Show()
			specWarnTeeth:Play("defensive")
		end
		timerTeethCD:Start(nil, self.vb.teethCount+1)
		updateAllTimers(self, 3.5)
	end
end

--10.2 switched event to WHISPER
function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("spell:255421") then
		specWarnPursuit:Show()
		specWarnPursuit:Play("justrun")
		yellPursuit:Yell()
	end
end

function mod:OnTranscriptorSync(msg, targetName)
	if msg:find("255421") and targetName and self:AntiSpam(5, targetName) then
		targetName = Ambiguate(targetName, "none")
		warnPursuit:Show(targetName)
	end
end

--Same time as SPELL_CAST_START but has target information on normal
--Deprecated in 10.2
function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, targetName)
	if msg:find("spell:255421") then
		if targetName and self:AntiSpam(5, targetName) then
			if targetName == UnitName("player") then
				specWarnPursuit:Show()
				specWarnPursuit:Play("justrun")
				yellPursuit:Yell()
			else
				warnPursuit:Show(targetName)
			end
		end
	end
end
