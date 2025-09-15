local mod	= DBM:NewMod(664, "DBM-Party-MoP", 1, 313)
local L		= mod:GetLocalizedStrings()

if DBM:IsRetail() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(59051, 59726, 58826)--59051 (Strife), 59726 (Anger), 58826 (Zao Sunseeker). This event has a random chance to be Zao (solo) or Anger and Strife (together)
mod:SetEncounterID(1417)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 113309",
	"SPELL_AURA_REMOVED 113309",
	"SPELL_AURA_APPLIED_DOSE 113315",
	"SPELL_CAST_SUCCESS 122714",
	"UNIT_DIED"
)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

--Stuff that might be used with more data--
--4/6 12:57:22.825  UNIT_DISSIPATES,0x0000000000000000,nil,0x80000000,0x80000000,0xF130DEF800005B63,"Corrupted Scroll",0xa48,0x0
-------------------------------------------
local warnIntensity			= mod:NewStackAnnounce(113315, 3)

local specWarnIntensity		= mod:NewSpecialWarning("SpecWarnIntensity", "-Healer", nil, 2, 1, 2)
local specWarnUltimatePower	= mod:NewSpecialWarningTarget(113309, nil, nil, nil, 2, 2)

local timerRP				= mod:NewCombatTimer(17.4)
local timerUltimatePower	= mod:NewTargetTimer(15, 113309, nil, nil, nil, 5)

mod.vb.bossesDead = 0

function mod:OnCombatStart(delay)
	self.vb.bossesDead = 0
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 113309 then
		specWarnUltimatePower:Show(args.destName)
		specWarnUltimatePower:Play("aesoon")
		timerUltimatePower:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 113309 then
		timerUltimatePower:Stop(args.destName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 122714 then
		DBM:EndCombat(self)--Alternte win detection, UNIT_DIED not fire for 59051 (Strife), 59726 (Anger)
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args.spellId == 113315 then
		if args.amount == 7 then--Start point of special warnings subject to adjustment based on live tuning.
			specWarnIntensity:Show(args.spellName, args.destName or "", args.amount)
			specWarnIntensity:Play("targetchange")
		elseif args.amount % 2 == 0 then
			warnIntensity:Show(args.destName or "", args.amount)
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 59051 or cid == 59726 then--These 2 both have to die for fight to end
		self.vb.bossesDead = self.vb.bossesDead + 1
		if self.vb.bossesDead == 2 then
			DBM:EndCombat(self)
		end
	elseif cid == 58826 then--This one is by himself so we don't need special rules
		DBM:EndCombat(self)
	end
end

--"<19.62 23:24:18> [CHAT_MSG_MONSTER_YELL] Ah, it is not yet over. From what I see, we face the trial of the yaungol. Let me shed some light...#Lorewalker Stonestep#####0#0##0#4721#nil#0#false#false#false#false", -- [23]
--"<28.33 23:24:27> [CHAT_MSG_MONSTER_YELL] As the tale goes, the yaungol was traveling across the Kun'lai plains when suddenly he was ambushed by two strange creatures!#Lorewalker Stonestep#####0#0##0#4722#nil#0#false#false#false#false", -- [29]
--"<37.08 23:24:35> [ENCOUNTER_START] 1417#Lorewalker Stonestep#1#5", -- [32]
--
--"<21.88 20:20:20> [CHAT_MSG_MONSTER_YELL] Oh, my. If I am not mistaken, it appears that the tale of Zao Sunseeker has come to life before us.#Lorewalker Stonestep#####0#0##0#1161#nil#0#false#false#false#false", -- [17]
--"<53.36 20:20:52> [ENCOUNTER_START] 1417#Lorewalker Stonestep#2#5", -- [22]
function mod:CHAT_MSG_MONSTER_YELL(msg, npc, _, _, target)
	if (msg == L.Event1 or msg:find(L.Event1)) then
		self:SendSync("LibraryRP1")
	elseif (msg == L.Event2 or msg:find(L.Event2)) then
		self:SendSync("LibraryRP2")
	end
end

function mod:OnSync(msg, targetname)
	if msg == "LibraryRP1" then
		timerRP:Start(17.4)
	elseif msg == "LibraryRP2" then
		timerRP:Start(31.4)
	end
end

