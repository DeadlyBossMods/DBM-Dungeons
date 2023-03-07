local mod	= DBM:NewMod(708, "DBM-Party-MoP", 5, 321)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61442, 61444, 61445)--61442 (Kuai the Brute), 61453 (Mu'Shiba, Kuai's Add), 61444 (Ming the Cunning), 61445 (Haiyan the Unstoppable)
mod:SetEncounterID(1442)

--http://www.wowpedia.org/Clan_Leaders_of_the_Mogu
mod:RegisterCombat("yell", L.Pull, L.Kuai, L.Ming, L.Haiyan) -- Common pull not fires if you've wiped. Other trigger is backup.
mod:RegisterKill("yell", L.Defeat)--Defeat off first line said after all are defeated.
mod:SetWipeTime(30)--Based on data, phase transitions are 10-16 seconds, 20 should be enough, but can raise if needed.

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 119946 123655 120201",
	"SPELL_CAST_START 119922 119981 123654",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_DIED"
)

--TODO, rework phase changes with UNIT events?
--TODO, rework combat detection to use ES/EE?
local warnRavage			= mod:NewTargetNoFilterAnnounce(119946, 3)--Mu'Shiba's Fixate attack
local warnShockwave			= mod:NewSpellAnnounce(119922, 4)--Kuai's Attack
local warnWhirlingDervish	= mod:NewSpellAnnounce(119981, 3)--Ming's Attack
local warnTraumaticBlow		= mod:NewTargetNoFilterAnnounce(123655, 3, nil, "Healer")--Haiyan's Attack
local warnConflag			= mod:NewTargetNoFilterAnnounce(120201, 3, nil, "Healer")--Haiyan's Attack

local specWarnShockwave		= mod:NewSpecialWarningDodge(119922, "Tank", nil, nil, 1, 2)--Not sure if he always faced it toward tank, or did it blackhorn style, if it's blackhorn style this needs to be changed to a targetscan if possible
local specWarnLightningBolt	= mod:NewSpecialWarningInterrupt(123654, false, nil, nil, 1, 2)

local timerRavageCD			= mod:NewCDTimer(20, 119946, nil, nil, nil, 3)
local timerShockwaveCD		= mod:NewCDTimer(10.9, 119922, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerWhirlingDervishCD= mod:NewCDTimer(22, 119981, nil, nil, nil, 3)
local timerTraumaticBlowCD	= mod:NewCDTimer(17, 123655, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--17-21sec variation
local timerConflagCD		= mod:NewCDTimer(22, 120201, nil, nil, nil, 3)--Limited data, may not be completely accurate
local timerMeteorCD			= mod:NewNextTimer(55, 120195, nil, nil, nil, 3)--Assumed based on limited data

local shockwaveCD = 15
local kuai = DBM:EJ_GetSectionInfo(6015)
local ming = DBM:EJ_GetSectionInfo(6019)
local haiyan = DBM:EJ_GetSectionInfo(6023)

--function mod:OnCombatStart(delay)

--end

function mod:SPELL_CAST_START(args)
	if args.spellId == 119922 then
		specWarnShockwave:Show()
		specWarnShockwave:Play("shockwave")
		timerShockwaveCD:Start(shockwaveCD)
	elseif args.spellId == 119981 then
		warnWhirlingDervish:Show()
		timerWhirlingDervishCD:Start()
	elseif args.spellId == 123654 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnLightningBolt:Show(args.sourceName)
		specWarnLightningBolt:Play("kickcast")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 119946 then
		warnRavage:Show(args.destName)
		timerRavageCD:Start()
	elseif args.spellId == 123655 then
		warnTraumaticBlow:Show(args.destName)
		timerTraumaticBlowCD:Start()
	elseif args.spellId == 120201 then
		warnConflag:Show(args.destName)
		timerConflagCD:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Kuai or msg:find(L.Kuai) then
		shockwaveCD = 15
		timerWhirlingDervishCD:Cancel()
		timerConflagCD:Cancel()
		timerMeteorCD:Cancel()
		timerTraumaticBlowCD:Cancel()
		timerShockwaveCD:Start(19)--Not confirmed through multiple pulls, just one
		timerRavageCD:Start(26)
	elseif msg == L.Ming or msg:find(L.Ming) then
		timerShockwaveCD:Cancel()
		timerRavageCD:Cancel()
		timerConflagCD:Cancel()
		timerMeteorCD:Cancel()
		timerTraumaticBlowCD:Cancel()
		timerWhirlingDervishCD:Start(22)--Not confirmed through multiple pulls, just one
	elseif msg == L.Haiyan or msg:find(L.Haiyan) then
		timerWhirlingDervishCD:Cancel()
		timerShockwaveCD:Cancel()
		timerRavageCD:Cancel()
		timerConflagCD:Start()--Not confirmed through multiple pulls, just one
		timerMeteorCD:Start(42)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 61453 then
		timerRavageCD:Cancel()
		shockwaveCD = 10--Need more data to confirm this but appears to be case.
	end
end
