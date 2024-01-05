local mod	= DBM:NewMod(1488, "DBM-Party-Legion", 4, 721)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(95675)
mod:SetEncounterID(1808)
mod:SetHotfixNoticeRev(20221127000000)
--mod:SetMinSyncRevision(20221108000000)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 193659 193668 193826 194112",
	"SPELL_CAST_SUCCESS 193659",
	"SPELL_AURA_APPLIED 193783",
	"SPELL_PERIODIC_DAMAGE 193702",
	"SPELL_PERIODIC_MISSED 193702"
)
mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

--TODO, longer/more pulls, a timer sequence may be better than on fly timer correction.
--TODO, Fix Savage blade, which sometimes doesn't reset after ragnarok?
--[[
(ability.id = 193659 or ability.id = 193668 or ability.id = 193826 or ability.id = 194112) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnAegis						= mod:NewTargetNoFilterAnnounce(193783, 1)
local warnFelblazeRush				= mod:NewTargetNoFilterAnnounce(193659, 2)
local warnClaimAegis				= mod:NewSpellAnnounce(194112, 2)

local specWarnFelRush				= mod:NewSpecialWarningYou(193659, nil, nil, nil, 1, 2)
local yellFelblazeRush				= mod:NewYell(193659)
local specWarnSavageBlade			= mod:NewSpecialWarningDefensive(193668, "Tank", nil, nil, 1, 2)
local specWarnRagnarok				= mod:NewSpecialWarningMoveTo(193826, nil, nil, nil, 3, 2)
local specWarnFlames				= mod:NewSpecialWarningMove(193702, nil, nil, nil, 1, 2)

local timerRP						= mod:NewCombatTimer(34.4)
local timerRushCD					= mod:NewCDTimer(11, 193659, nil, nil, nil, 3)--11-13 unless delayed by claim aegis or ragnarok
local timerSavageBladeCD			= mod:NewCDTimer(19, 193668, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--23 unless delayed by claim aegis or ragnarok
local timerRagnarokCD				= mod:NewCDTimer(63.1, 193826, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)

function mod:FelblazeRushTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnFelRush:Show()
		specWarnFelRush:Play("targetyou")
		yellFelblazeRush:Yell()
	else
		warnFelblazeRush:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	timerRushCD:Start(7.1-delay)
	timerRagnarokCD:Start(11-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 193659 then
		--Because of boss delay (never looking at correct target immediately/before cast start
		--there is time to use this better method for fastest and most efficient method
		self:BossUnitTargetScanner("boss1", "FelblazeRushTarget")
--[[		local elapsed, total = timerRagnarokCD:GetTime()
		local remaining = total - elapsed
		if remaining < 11 then
			local extend = 11 - remaining
			DBM:Debug("timerRushCD Extend by: "..extend)
			timerRushCD:Start(11+extend)
		else--]]
			timerRushCD:Start()
		--end
	elseif spellId == 193668 then
		specWarnSavageBlade:Show()
		specWarnSavageBlade:Play("defensive")
--		local elapsed, total = timerRagnarokCD:GetTime()
--		local remaining = total - elapsed
--		if remaining >= 20 then
			timerSavageBladeCD:Start()
--		end
	elseif spellId == 193826 then
		specWarnRagnarok:Show(SHIELDSLOT)
		specWarnRagnarok:Play("findshield")
		timerRagnarokCD:Start()
		--Other timers can be extended but they aren't restarted, they just get spell queued behind ragnarok
	elseif spellId == 194112 then
		warnClaimAegis:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 193659 then
		self:BossUnitTargetScannerAbort()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 193783 and args:IsDestTypePlayer() then
		warnAegis:Show(args.destName)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 193702 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		specWarnFlames:Show()
		specWarnFlames:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:CHAT_MSG_MONSTER_YELL(msg, npc, _, _, target)
	if (msg == L.SkovaldRP or msg:find(L.SkovaldRP)) then--Pre hotfix original start point
		self:SendSync("SkovaldRP")--Syncing to help unlocalized clients
	elseif (msg == L.SkovaldRPTwo or msg:find(L.SkovaldRPTwo)) then--Post hotfix, this is only line he does
		self:SendSync("SkovaldRPTwo")--Syncing to help unlocalized clients
	end
end

--"<5.00 03:10:33> [CHAT_MSG_MONSTER_YELL] If these false champions will not yield the aegis by choice... then they will surrender it in death!#God-King Skovald###Omegal##0#0##
--"<15.54 03:10:43> [ENCOUNTER_START] 1808#God-King Skovald#8#5", -- [22]
function mod:OnSync(msg, targetname)
	if msg == "SkovaldRP" and self:AntiSpam(10, 2) then
		timerRP:Start()
	elseif msg == "SkovaldRPTwo" and self:AntiSpam(10, 2) then
		timerRP:Stop()
		timerRP:Start(10)
	end
end
