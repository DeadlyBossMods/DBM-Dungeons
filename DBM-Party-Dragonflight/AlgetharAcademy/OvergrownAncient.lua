local mod	= DBM:NewMod(2512, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186951)
mod:SetEncounterID(2563)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 388923 388623 371453 388544",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 388796 389033 371453",
	"SPELL_AURA_APPLIED_DOSE 389033",
	"SPELL_AURA_REMOVED 389033",
	"SPELL_AURA_REMOVED_DOSE 389033",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, Fix Germinate event.
--TODO, Branch Out target scan? it says "at a location" not "at a player"
--TODO, review interupt timer for add, if it's spam cast, scrap.
local warnEntanglingRoots						= mod:NewTargetNoFilterAnnounce(371453, 3, nil, "RemoveMagic")

local specWarnGerminate							= mod:NewSpecialWarningDodge(388796, nil, nil, nil, 2, 2)
local specWarnLasherToxin						= mod:NewSpecialWarningStack(389033, nil, 12, nil, nil, 1, 6)
local specWarnBurstForth						= mod:NewSpecialWarningSpell(388923, nil, nil, nil, 2, 2)
local specWarnBranchOut							= mod:NewSpecialWarningDodge(388623, nil, nil, nil, 2, 2)
local specWarnEntanglingRoots					= mod:NewSpecialWarningInterrupt(371453, "HasInterrupt", nil, nil, 1, 2)
local specWarnBarkbreaker						= mod:NewSpecialWarningDefensive(388544, nil, nil, nil, 1, 2)
--local specWarnGTFO							= mod:NewSpecialWarningGTFO(340324, nil, nil, nil, 1, 8)

local timerGerminateCD							= mod:NewAITimer(35, 388796, nil, nil, nil, 3)
local timerBurstForthCD							= mod:NewAITimer(35, 388923, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerBranchOutCD							= mod:NewAITimer(35, 388623, nil, nil, nil, 3)
local timerEntanglingRootsCD					= mod:NewAITimer(35, 371453, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBarkbreakerCD						= mod:NewAITimer(35, 388544, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.HEALER_ICON)

--local berserkTimer							= mod:NewBerserkTimer(600)

--mod:AddRangeFrameOption("8")
mod:AddInfoFrameOption(389033, "RemovePoison")
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

local toxinStacks = {}

function mod:OnCombatStart(delay)
	table.wipe(toxinStacks)
	timerGerminateCD(1-delay)
	timerBurstForthCD:Start(1-delay)
	timerBranchOutCD:Start(1-delay)
	timerBarkbreakerCD:Start(1-delay)
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM:GetSpellInfo(389033))
		DBM.InfoFrame:Show(5, "table", toxinStacks, 1)
	end
end

function mod:OnCombatEnd()
	table.wipe(toxinStacks)
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 388923 then
		specWarnBurstForth:Show()
		specWarnBurstForth:Play("aesoon")
		timerBurstForthCD:Start()
	elseif spellId == 388623 then
		specWarnBranchOut:Show()
		specWarnBranchOut:Play("watchstep")
		timerBranchOutCD:Start()
	elseif spellId == 371453 then
		timerEntanglingRootsCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnEntanglingRoots:Show(args.sourceName)
			specWarnEntanglingRoots:Play("kickcast")
		end
	elseif spellId == 388544 then
		timerBarkbreakerCD:Start()
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnBarkbreaker:Show()
			specWarnBarkbreaker:Play("defensive")
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 362805 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 388796 then
		specWarnGerminate:Show()
		specWarnGerminate:Play("watchstep")
		timerGerminateCD:Start()
	elseif spellId == 389033 then
		local amount = args.amount or 1
		toxinStacks[args.destName] = amount
		if self.Options.InfoFrame then
			DBM.InfoFrame:UpdateTable(toxinStacks, 0.2)
		end
		if args:IsPlayer() and amount >= 12 then
			specWarnLasherToxin:Cancel()--Possible to get multiple applications at once so we throttle by scheduling
			specWarnLasherToxin:Schedule(0.2, amount)
			specWarnLasherToxin:ScheduleVoice(0.2, "stackhigh")
		end
	elseif spellId == 371453 then
		warnEntanglingRoots:Show(args.destName)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 389033 then
		toxinStacks[args.destName] = nil
		if self.Options.InfoFrame then
			DBM.InfoFrame:UpdateTable(toxinStacks, 0.2)
		end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	local spellId = args.spellId
	if spellId == 389033 then
		toxinStacks[args.destName] = args.amount or 1
		if self.Options.InfoFrame then
			DBM.InfoFrame:UpdateTable(toxinStacks, 0.2)
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 196548 then--Ancient Branch
		timerEntanglingRootsCD:Stop(args.destGUID)
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
