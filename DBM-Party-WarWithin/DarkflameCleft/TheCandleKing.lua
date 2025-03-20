local mod	= DBM:NewMod(2560, "DBM-Party-WarWithin", 1, 1210)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(208745)
mod:SetEncounterID(2787)
mod:SetUsedIcons(8, 7, 6, 5, 4)
mod:SetHotfixNoticeRev(20250222000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2651)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 420659 426145",
	"SPELL_CAST_SUCCESS 422648",
	"SPELL_SUMMON 420665 420949",
	"SPELL_AURA_APPLIED 421653",
	"SPELL_AURA_REMOVED 422648",
	"SPELL_PERIODIC_DAMAGE 421067",
	"SPELL_PERIODIC_MISSED 421067",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, verify auto marking
--TODO, are both private aura spellids used? what's the primary (for showing in GUI)
--TODO, timers only veted on S2 M+, not lower difficulties
--[[
(ability.id = 420659 or ability.id = 426145) and type = "begincast"
 or ability.id = 422648 and type = "cast"
 or (ability.id = 453278 or ability.id = 420696) and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnEarieMolds						= mod:NewCountAnnounce(420659, 3)
local warnCursedWax							= mod:NewTargetNoFilterAnnounce(421653, 4)
local warnDarkflamePickaxe					= mod:NewTargetNoFilterAnnounce(420659, 3)
--local warnThrowDarkflame					= mod:NewTargetNoFilterAnnounce(420696, 3)--Private Aura

local specWarnDarkflamePickaxe				= mod:NewSpecialWarningMoveTo(420659, nil, nil, nil, 1, 17)
local yellDarkflamePickaxe					= mod:NewShortYell(422648)
local yellDarkflamePickaxeFades				= mod:NewShortFadesYell(422648)
--local specWarnThrowDarkflame				= mod:NewSpecialWarningMoveTo(420696, nil, nil, nil, 1, 2)--Private Aura
--local yellThrowDarkflame					= mod:NewShortYell(420696)--Private Aura
--local yellThrowDarkflameFades				= mod:NewShortFadesYell(420696)--Private Aura
local specWarnParanoidMind					= mod:NewSpecialWarningInterruptCount(426145, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(421067, nil, nil, nil, 1, 8)

local timerEarieMoldsCD						= mod:NewVarCountTimer("v21.8-27.9", 420659, nil, nil, nil, 1)
local timerDarkflamePickaxeCD				= mod:NewVarCountTimer("v23.1-27.9", 422648, nil, nil, nil, 3)
local timerParanoidMindCD					= mod:NewVarCountTimer("v10.9-15.8", 426145, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Usually 12.1, probably need more timer correction
local timerThrowDarkflameCD					= mod:NewVarCountTimer("v21.9-37.6", 420696, nil, nil, nil, 3)--TODO, refine it with timer correction

mod:AddSetIconOption("SetIconOnAdds", 420659, true, 5, {8, 7, 6, 5, 4})
mod:AddPrivateAuraSoundOption(420696, true, 420696, 1)--Throw Darkflame

mod.vb.addIcon = 8
mod.vb.statueCount = 0
mod.vb.pickaxeCount = 0
mod.vb.mindCount = 0
mod.vb.throwCount = 0
local statueName = DBM:GetSpellName(431179)

function mod:OnCombatStart(delay)
	self.vb.statueCount = 0
	self.vb.pickaxeCount = 0
	self.vb.mindCount = 0
	self.vb.throwCount = 0
	timerEarieMoldsCD:Start(6-delay, 1)
	timerDarkflamePickaxeCD:Start(15.4-delay, 1)
	timerParanoidMindCD:Start(9.4-delay, 1)
	if self:IsMythic() then
		timerThrowDarkflameCD:Start(21.4-delay, 1)
		self:EnablePrivateAuraSound(420696, "movetostatue", 17)--Throw Darkflame
		self:EnablePrivateAuraSound(453278, "movetostatue", 17, 420696)--Register Additional Throw Darkflame ID
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 420659 then
		self.vb.addIcon = 8
		self.vb.statueCount = self.vb.statueCount + 1
		warnEarieMolds:Show(self.vb.statueCount)
		--6.9, 23.1, 23.1, 24.3, 21.8, 21.9, 25.5, 26.8, 26.7
		timerEarieMoldsCD:Start(nil, self.vb.statueCount+1)
	elseif spellId == 426145 then
		self.vb.mindCount = self.vb.mindCount + 1
		specWarnParanoidMind:Show(args.sourceName, self.vb.mindCount)
		specWarnParanoidMind:Play("kickcast")
		timerParanoidMindCD:Start(nil, self.vb.mindCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 422648 then
		self.vb.pickaxeCount = self.vb.pickaxeCount + 1
		--15.4, 23.1, 24.3, 27.9, 24.3, 25.5, 26.8, 26.7
		timerDarkflamePickaxeCD:Start(nil, self.vb.pickaxeCount+1)
		if args:IsPlayer() then
			specWarnDarkflamePickaxe:Show(statueName)
			specWarnDarkflamePickaxe:Play("movetostatue")
			yellDarkflamePickaxe:Yell()
			yellDarkflamePickaxeFades:Countdown(spellId)
		else
			warnDarkflamePickaxe:Show(args.destName)
		end
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 420665 or spellId == 420949 then
		if self.Options.SetIconOnAdds then
			self:ScanForMobs(args.destGUID, 2, self.vb.addIcon, 1, nil, 12, "SetIconOnAdds")
		end
		self.vb.addIcon = self.vb.addIcon - 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 421653 then
		warnCursedWax:Show(args.destName)
	--elseif spellId == 420696 then
	--	if self:AntiSpam(3, 1) then
	--		self.vb.throwCount = self.vb.throwCount + 1
	--		timerThrowDarkflameCD:Start()--Not in combat log, so has to be in applied event
	--	end
	--	warnThrowDarkflame:CombinedShow(0.5, args.destName)
	--	if args:IsPlayer() then
	--		specWarnThrowDarkflame:Show(statueName)
	--		specWarnThrowDarkflame:Play("behindmob")
	--		yellThrowDarkflame:Yell()
	--		yellThrowDarkflameFades:Countdown(spellId)
	--	end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 422648 then
		if args:IsPlayer() then
			yellDarkflamePickaxeFades:Cancel()
		end
	--elseif spellId == 420696 then
	--	if args:IsPlayer() then
	--		yellThrowDarkflameFades:Cancel()
	--	end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 421067 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
--https://www.wowhead.com/beta/npc=209603/wax-statue
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 420696 then
		self.vb.throwCount = self.vb.throwCount + 1
		timerThrowDarkflameCD:Start(nil, self.vb.throwCount+1)
	end
end
