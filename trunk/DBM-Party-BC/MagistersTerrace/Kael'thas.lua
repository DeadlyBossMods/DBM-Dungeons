local mod = DBM:NewMod(533, "DBM-Party-BC", 16, 249)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 645 $"):sub(12, -3))
mod:SetCreatureID(24664)
mod:SetEncounterID(1894)
mod:SetModelID(22906)--Here for a reason?

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 36819",
	"SPELL_CAST_SUCCESS 44194",
	"SPELL_AURA_APPLIED 46165",
	"SPELL_AURA_REMOVED 46165",
	"CHAT_MSG_MONSTER_YELL"
)

--TODO, switch to these events if blizzard enables boss1
--	"<231.31 20:53:15> [UNIT_SPELLCAST_SUCCEEDED] Kael'thas Sunstrider(Omegal) [[target:Clear Flight::0:44232]]", -- [530]
--	"<231.31 20:53:15> [UNIT_SPELLCAST_SUCCEEDED] Kael'thas Sunstrider(Omegal) [[target:Power Feedback::0:47109]]", -- [531]

local WarnShockBarrior		= mod:NewSpellAnnounce(46165, 3)
local WarnGravityLapse		= mod:NewSpellAnnounce(44224, 2)

local specwarnPyroblast		= mod:NewSpecialWarningInterrupt(36819, "HasInterrupt", nil, 2, 1, 2)
local specwarnPhoenix		= mod:NewSpecialWarningSwitch(44194, "-Healer", nil, nil, 1, 2)

local timerPyroblast		= mod:NewCastTimer(4, 36819, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerShockBarrior		= mod:NewNextTimer(60, 46165, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerPhoenix			= mod:NewCDTimer(45, 44194, nil, nil, nil, 1)--45-70?
local timerGravityLapse		= mod:NewBuffActiveTimer(35, 44194, nil, nil, nil, 6)
local timerGravityLapseCD	= mod:NewNextTimer(13.5, 44194, nil, nil, nil, 6)

local interruptable = false
local phase2Started = false

local function clearInterrupt()
	interruptable = false
end

function mod:OnCombatStart(delay)
	interruptable = false
	phase2Started = false
	if not self:IsDifficulty("normal5") then
        timerShockBarrior:Start(-delay)
    end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 36819 then
		interruptable = true
        timerPyroblast:Start()
        self:Schedule(4, clearInterrupt)
    elseif spellId == 44224 then
    	WarnGravityLapse:Show()
    	timerGravityLapse:Start()
    	timerGravityLapseCD:Schedule(35)--Show after current lapse has ended
    	if not phase2Started then
    		phase2Started = true
			timerShockBarrior:Stop()
			timerPhoenix:Stop()
    	end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 44194 then
		specwarnPhoenix:Show()
		specwarnPhoenix:Play("killmob")
		timerPhoenix:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 46165 then
		WarnShockBarrior:Show(args.destName)
        timerShockBarrior:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 46165 and interruptable then
        specwarnPyroblast:Show(args.destName)
        specwarnPyroblast:Play("kickcast")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.KaelP2 then
		phase2Started = true
		timerShockBarrior:Stop()
		timerPhoenix:Stop()
	end
end