local mod	= DBM:NewMod(685, "DBM-Party-MoP", 3, 312)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56719)
mod:SetEncounterID(1305)

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.Kill)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 38166",
	"SPELL_CAST_START 106877",
	"SPELL_CAST_SUCCESS 106872"
)

local warnDisorientingSmash		= mod:NewTargetAnnounce(106872, 2)
local warnShaSpike				= mod:NewTargetAnnounce(106877, 3)
local warnEnrage				= mod:NewSpellAnnounce(38166, 4)

local specWarnShaSpike			= mod:NewSpecialWarningMoveAway(106877, nil, nil, nil, 1, 2)
local specWarnShaSpikeNear		= mod:NewSpecialWarningClose(106877, nil, nil, nil, 1, 2)

local timerDisorientingSmashCD	= mod:NewCDTimer(13, 106872, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON..DBM_COMMON_L.HEALER_ICON)
local timerShaSpikeCD			= mod:NewNextTimer(9, 106877, nil, nil, nil, 3)

function mod:ShaSpikeTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnShaSpike:Show()
		specWarnShaSpike:Play("runout")
	else
		if uId then
			local inRange = DBM.RangeCheck:GetDistance("player", uId)
			if inRange and inRange < 6 then
				specWarnShaSpikeNear:Show(targetname)
				specWarnShaSpikeNear:Play("runaway")
			else
				warnShaSpike:Show(targetname)
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 38166 then
		warnEnrage:Show()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 106877 then
		self:BossTargetScanner(56719, "ShaSpikeTarget", 0.02, 20)
		timerShaSpikeCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 106872 then
		warnDisorientingSmash:Show(args.destName)
		timerDisorientingSmashCD:Start()
	end
end
