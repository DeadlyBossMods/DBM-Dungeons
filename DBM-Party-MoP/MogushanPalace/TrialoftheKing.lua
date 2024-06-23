local mod	= DBM:NewMod(708, "DBM-Party-MoP", 5, 321)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61442, 61444, 61445)--61442 (Kuai the Brute), 61444 (Ming the Cunning), 61445 (Haiyan the Unstoppable)
mod:SetEncounterID(1442)

--http://www.wowpedia.org/Clan_Leaders_of_the_Mogu
mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.Defeat)--Defeat off first line said after all are defeated.
mod:SetWipeTime(30)--Based on data, phase transitions are 10-16 seconds, 20 should be enough, but can raise if needed.

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 119946 123655 120201",
	"SPELL_CAST_START 119922 119981 123654",
	"INSTANCE_ENCOUNTER_ENGAGE_UNIT",
	"UNIT_DIED"
)
mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

local warnRavage			= mod:NewTargetNoFilterAnnounce(119946, 3)--Mu'Shiba's Fixate attack
local warnWhirlingDervish	= mod:NewSpellAnnounce(119981, 3)--Ming's Attack
local warnTraumaticBlow		= mod:NewTargetNoFilterAnnounce(123655, 3, nil, "Healer")--Haiyan's Attack
local warnConflag			= mod:NewTargetNoFilterAnnounce(120201, 3, nil, "Healer")--Haiyan's Attack

local specWarnShockwave		= mod:NewSpecialWarningDodge(119922, nil, nil, nil, 1, 2)--Not sure if he always faced it toward tank, or did it blackhorn style, if it's blackhorn style this needs to be changed to a targetscan if possible
local specWarnLightningBolt	= mod:NewSpecialWarningInterrupt(123654, false, nil, nil, 1, 2)

local timerRP				= mod:NewCombatTimer(60)
local timerRavageCD			= mod:NewCDTimer(20, 119946, nil, nil, nil, 3)
local timerShockwaveCD		= mod:NewCDTimer(10.9, 119922, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerWhirlingDervishCD= mod:NewCDTimer(22, 119981, nil, nil, nil, 3)
local timerTraumaticBlowCD	= mod:NewCDTimer(17, 123655, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--17-21sec variation
local timerConflagCD		= mod:NewCDTimer(10, 120201, nil, nil, nil, 3)--10-22?
local timerMeteorCD			= mod:NewNextTimer(55, 120195, nil, nil, nil, 3)--Assumed based on limited data

local shockwaveCD = 15
local seenAdds = {}
--local kuai = DBM:EJ_GetSectionInfo(6015)
--local ming = DBM:EJ_GetSectionInfo(6019)
--local haiyan = DBM:EJ_GetSectionInfo(6023)

function mod:OnCombatStart()
	table.wipe(seenAdds)
	--Initial timers started by INSTANCE_ENCOUNTER_ENGAGE_UNIT
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 119922 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnShockwave:Show()
			specWarnShockwave:Play("shockwave")
		end
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

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i = 1, 5 do
		local unitID = "boss"..i
		local GUID = UnitGUID(unitID)
		if GUID and not seenAdds[GUID] then
			seenAdds[GUID] = true
			local cid = self:GetCIDFromGUID(GUID)
			if cid == 61442 then--Kuai
				shockwaveCD = 15
				timerWhirlingDervishCD:Cancel()
				timerConflagCD:Cancel()
				timerMeteorCD:Cancel()
				timerTraumaticBlowCD:Cancel()
				timerShockwaveCD:Start(17.2)
				timerRavageCD:Start(21.6)
			elseif cid == 61444 then--Ming
				timerShockwaveCD:Cancel()
				timerRavageCD:Cancel()
				timerConflagCD:Cancel()
				timerMeteorCD:Cancel()
				timerTraumaticBlowCD:Cancel()
				timerWhirlingDervishCD:Start(22)--Not confirmed through multiple pulls, just one
			elseif cid == 61445 then--Haiyan
				timerWhirlingDervishCD:Cancel()
				timerShockwaveCD:Cancel()
				timerRavageCD:Cancel()
				timerConflagCD:Start()--Not confirmed through multiple pulls, just one
				timerMeteorCD:Start(42)
			end
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 61453 then--Mu'Shiba, Kuai's Add
		timerRavageCD:Cancel()
		shockwaveCD = 10--Need more data to confirm this but appears to be case.
	end
end

--"<2.94 18:23:24> [CHAT_MSG_MONSTER_YELL] Useless, all of you! Even the guards you give me in tribute can't keep these lesser beings from my palace.#Xin the Weaponmaster###Xin the Weaponmaster##0#0##0#946#nil#0#false#false#false#fals
--"<24.62 18:23:45> [ENCOUNTER_START] 1442#Trial of the King#2#5",
--"<24.66 18:23:45> [PLAYER_REGEN_DISABLED] +Entering combat!",
--"<27.17 18:23:48> [INSTANCE_ENCOUNTER_ENGAGE_UNIT] Fake Args:#boss1#true#true#true#Kuai the Brute#
function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Pull then
		self:SendSync("firstPull")
	end
end

function mod:OnSync(msg)
	if msg == "firstPull" then
		timerRP:Start(21.7)--24.2 until an actually attackable mob, but we'll use it as a combat timer for now
	end
end
