local mod	= DBM:NewMod(2473, "DBM-Party-Dragonflight", 1, 1196)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186120)
mod:SetEncounterID(2568)
mod:SetUsedIcons(8, 7, 6, 5)
mod:SetHotfixNoticeRev(20230516000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 376811 381770 377559 376934",
	"SPELL_SUMMON 376797",
	"SPELL_AURA_APPLIED 377222 378022",--377864
	"SPELL_AURA_REMOVED 377222 378022",
	"SPELL_PERIODIC_DAMAGE 378054",
	"SPELL_PERIODIC_MISSED 378054"
)

--TODO, proper phasing and timer updates
--TODO, better stack alert handling, maybe dispel special warning for RemoveDisease?
--[[
(ability.id = 376811 or ability.id = 377559 or ability.id = 376934) and type = "begincast"
 or ability.id = 377859 and type = "cast"
 or ability.id = 378022 and (type = "removebuff" or type = "applybuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 381770 and type = "begincast"
--]]
local warnGraspingVines							= mod:NewSpellAnnounce(376933, 2)
local warnConsume								= mod:NewTargetNoFilterAnnounce(377222, 4)
local warnDecaySpray							= mod:NewSpellAnnounce(376811, 2)
--local warnInfectiousSpit						= mod:NewStackAnnounce(377864, 2, nil, "Healer|RemoveDisease")

--local yellInfusedStrikes						= mod:NewShortFadesYell(361966)
local specWarnGraspingVines						= mod:NewSpecialWarningRun(376933, nil, nil, nil, 4, 2)
local specWarnGushingOoze						= mod:NewSpecialWarningInterrupt(381770, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(378054, nil, nil, nil, 1, 8)
local specWarnVineWhip							= mod:NewSpecialWarningDefensive(377559, nil, nil, nil, 1, 2)

local timerGraspingVinesCD						= mod:NewCDTimer(47.3, 376933, nil, nil, nil, 6)
local timerConsume								= mod:NewTargetTimer(10, 377222, nil, false, 2, 3, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerDecaySprayCD							= mod:NewCDTimer(42.4, 376811, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
--local timerInfectiousSpitCD					= mod:NewCDTimer(20.1, 377864, nil, nil, nil, 3, nil, DBM_COMMON_L.DISEASE_ICON)
local timerVineWhipCD							= mod:NewCDTimer(16.9, 377559, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddInfoFrameOption(378022, true)
mod:AddSetIconOption("SetIconOnDecaySpray", 376811, true, 5, {8, 7, 6, 5})

--mod:GroupSpells(377222, 378022)--Consume with Consuming

mod.vb.addIcon = 8

function mod:OnCombatStart(delay)
	timerVineWhipCD:Start(6-delay)
	timerDecaySprayCD:Start(15.7-delay)
	timerGraspingVinesCD:Start(23.2-delay)
--	timerInfectiousSpitCD:Start(25.9-delay)--Restarted by vines anyways
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 376811 then
		self.vb.addIcon = 8
		timerDecaySprayCD:Start()--42-46
	elseif spellId == 381770 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnGushingOoze:Show(args.sourceName)
		specWarnGushingOoze:Play("kickcast")
	elseif spellId == 377559 then
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnVineWhip:Show()
			specWarnVineWhip:Play("defensive")
		end
		timerVineWhipCD:Start()--16-24 now thanks to worse spell queue than before
	elseif spellId == 376934 then
		if DBM:UnitDebuff("player", 383875) then--Partially Digested
			specWarnGraspingVines:Show()
			specWarnGraspingVines:Play("justrun")
		else
			warnGraspingVines:Show()
		end
		timerGraspingVinesCD:Start(54.6)
		--Timer restarts
--		timerInfectiousSpitCD:Restart(10.2)--No longer exists at all?
		timerVineWhipCD:Restart(9)--9 second timer is started here, but will queue up if consume happens and be used near immediately when consume fades
--		timerDecaySprayCD:Restart(33.2)--No longer restarts here
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 376797 then
		if self.Options.SetIconOnDecaySpray then
			self:ScanForMobs(args.destGUID, 2, self.vb.addIcon, 1, nil, 12, "SetIconOnDecaySpray")
		end
		self.vb.addIcon = self.vb.addIcon - 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 377222 then--On Player
		warnConsume:CombinedShow(0.3, args.destName)
		timerConsume:Start(args.destName)
	elseif spellId == 378022 then--On Boss
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
--	elseif spellId == 377864 then
--		local amount = args.amount or 1
--		if amount % 2 == 0 then
--			warnInfectiousSpit:Show(args.destName, amount)
--		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 377222 then
		timerConsume:Stop(args.destName)
	elseif spellId == 378022 then--On Boss
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 378054 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
