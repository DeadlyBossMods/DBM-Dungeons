local mod	= DBM:NewMod("SacredFlameTrash", "DBM-Party-WarWithin", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 424621 424423 424431 448515 427583 424462 424420 427484 427356 427601",
	"SPELL_CAST_SUCCESS 453458 427484",
	"SPELL_AURA_APPLIED 426964 424430",
	"SPELL_AURA_APPLIED_DOSE 426964",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)
--TODO, target scan lunging strike?
--TODO, longer pulls for Trusted Guard timers
--TODO, nameplate timer for https://www.wowhead.com/beta/spell=424421/fireball on Taener Duelmal?
--All normal Trash
local warnMortalStrike						= mod:NewStackAnnounce(426964, 2, nil, "Tank|Healer")
local warnBurstofLight						= mod:NewCastAnnounce(427601, 4)--SUPER obvious so doesn't need a special warning for now i think
local warnGreaterHeal						= mod:NewCastAnnounce(427356, 3)--High Prio Interrupt

local specWarnCaltrops						= mod:NewSpecialWarningDodge(453458, nil, nil, nil, 2, 2)
local specWarnFlamestrike					= mod:NewSpecialWarningDodge(427484, nil, nil, nil, 2, 2)
--local yellChainLightning					= mod:NewYell(387127)
local specWarnGreaterHeal					= mod:NewSpecialWarningInterrupt(427356, nil, nil, nil, 1, 2)
--local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(424430, nil, nil, nil, 1, 8)

local timerCaltropsCD						= mod:NewCDNPTimer(16.9, 453458, nil, nil, nil, 3)
local timerFlamestrikeCD					= mod:NewCDNPTimer(17.4, 427484, nil, nil, nil, 3)
--local timerGreaterHealCD					= mod:NewCDNPTimer(20.4, 427356, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Currently too much of a PITA to add due to stuns not putting it on CD
----Everything below here are the adds from Captain Dailcry. treated as trash since they are pulled as trash, just like Court of Stars
--The Trusted Guard
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27840))
--Sergeant Shaynemail
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27825))
local specWarnBrutalSmash					= mod:NewSpecialWarningDodge(424621, nil, nil, nil, 2, 2)
local specWarnLungingStrike					= mod:NewSpecialWarningMoveAway(424423, nil, nil, nil, 1, 2)

--local timerBrutalSmashCD					= mod:NewCDNPTimer(15.7, 424621, nil, nil, nil, 3)
local timerLungingStrikeCD					= mod:NewCDNPTimer(14.5, 424423, nil, nil, nil, 3)--Not enough sample data
--Elaena Emberlanz
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27828))
local specWarnHolyRadiance					= mod:NewSpecialWarningMoveAway(424431, nil, nil, nil, 2, 2)
local specWarnDivineJudgement				= mod:NewSpecialWarningDefensive(448515, nil, nil, nil, 2, 2)
local specWarnRepentance					= mod:NewSpecialWarningInterrupt(427583, "HasInterrupt", nil, nil, 1, 2)

--local timerHolyRadianceCD					= mod:NewCDNPTimer(14.5, 424431, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerDivineJudgementCD				= mod:NewCDNPTimer(12.1, 448515, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerRepentanceCD						= mod:NewCDNPTimer(15.7, 427583, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--Taener Duelmal
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27831))
local specWarnEmberStorm					= mod:NewSpecialWarningDodge(424462, nil, nil, nil, 2, 2)
local specWarnCinderblast					= mod:NewSpecialWarningInterrupt(424420, "HasInterrupt", nil, nil, 1, 2)

--local timerEmberStormCD					= mod:NewCDNPTimer(12.1, 424462, nil, nil, nil, 3)
local timerCinderblastCD					= mod:NewCDNPTimer(15.7, 424420, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

--[[
function mod:CLTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnChainLightning:Show()
			specWarnChainLightning:Play("runout")
		end
		yellChainLightning:Yell()
	end
end
--]]

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 424621 then
		--timerBrutalSmashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBrutalSmash:Show()
			specWarnBrutalSmash:Play("shockwave")
		end
	elseif spellId == 427356 then
		if self.Options.SpecWarn427356interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGreaterHeal:Show(args.sourceName)
			specWarnGreaterHeal:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnGreaterHeal:Show()
		end
	elseif spellId == 424462 then
		--timerEmberStormCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnEmberStorm:Show()
			specWarnEmberStorm:Play("watchstep")
		end
	elseif spellId == 424423 then
		timerLungingStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnLungingStrike:Show()
			specWarnLungingStrike:Play("scatter")
		end
	elseif spellId == 424431 then
		--timerHolyRadianceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnHolyRadiance:Show()
			specWarnHolyRadiance:Play("aesoon")
		end
	elseif spellId == 448515 then
		timerDivineJudgementCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnDivineJudgement:Show()
			specWarnDivineJudgement:Play("defensive")
		end
	elseif spellId == 427583 then
		timerRepentanceCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRepentance:Show(args.sourceName)
			specWarnRepentance:Play("kickcast")
		end
	elseif spellId == 424420 then
		timerCinderblastCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCinderblast:Show(args.sourceName)
			specWarnCinderblast:Play("kickcast")
		end
	elseif spellId == 427484 then
		if self:AntiSpam(3, 2) then
			specWarnFlamestrike:Show()
			specWarnFlamestrike:Play("watchstep")
		end
	elseif spellId == 427601 then
		if self:AntiSpam(3, 6) then
			warnBurstofLight:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 453458 then
		timerCaltropsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnCaltrops:Show()
			specWarnCaltrops:Play("watchstep")
		end
	elseif spellId == 427484 then
		timerFlamestrikeCD:Start(17.4, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 426964 then
		local amount = args.amount or 1
		if self:AntiSpam(3, 5) then
			warnMortalStrike:Show(args.destName, amount)
		end
	elseif spellId == 424430 and args:IsPlayer() and self:AntiSpam(3, 8) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 211291 then--sergeant-shaynemail
		--timerBrutalSmashCD:Stop(args.destGUID)
		timerLungingStrikeCD:Stop(args.destGUID)
	elseif cid == 211289 then--taener-duelmal
		--timerEmberStormCD:Stop(args.destGUID)
		timerCinderblastCD:Stop(args.destGUID)
	elseif cid == 211290 then--elaena-emberlanz
		--timerHolyRadianceCD:Stop(args.destGUID)
		timerDivineJudgementCD:Stop(args.destGUID)
		timerRepentanceCD:Stop(args.destGUID)
	elseif cid == 206694 then--Fervent Sharpshooter
		timerCaltropsCD:Stop(args.destGUID)
	elseif cid == 206698 then--Fanatical Mage
		timerFlamestrikeCD:Stop(args.destGUID)
	end
end
