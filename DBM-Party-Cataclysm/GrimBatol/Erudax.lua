local mod	= DBM:NewMod(134, "DBM-Party-Cataclysm", 3, 71)
local L		= mod:GetLocalizedStrings()

if not mod:IsCata() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else--TODO, refine for cata classic since no timewalker there
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40484)
mod:SetEncounterID(1049)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 75861 75792",
	"SPELL_CAST_START 75763 79467",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnBinding		= mod:NewTargetNoFilterAnnounce(75861, 3)
local warnFeeble		= mod:NewTargetNoFilterAnnounce(75792, 3, nil, "Tank|Healer", 2)
local warnUmbralMending	= mod:NewSpellAnnounce(75763, 4)

local specWarnMending	= mod:NewSpecialWarningInterrupt(75763, nil, nil, nil, 1, 2)
local specWarnGale		= mod:NewSpecialWarningCount(75664, nil, nil, nil, 2, 2)
local specWarnAdds		= mod:NewSpecialWarningAddsCount(75704, "Dps", nil, nil, 3, 2)

local timerFeebleCD		= mod:NewCDCountTimer(26, 75792, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFeeble		= mod:NewTargetTimer(3, 75792, nil, "Tank|Healer", 2, 5)
local timerGale			= mod:NewCastTimer(5, 75664, nil, nil, nil, 2)
local timerGaleCD		= mod:NewCDCountTimer(55, 75664, nil, nil, nil, 2)
local timerAddsCD		= mod:NewCDCountTimer(54.5, 75704, nil, nil, nil, 1)

mod.vb.feebleCount = 0
mod.vb.galeCount = 0
mod.vb.addsCount = 0

function mod:OnCombatStart(delay)
	self.vb.feebleCount = 0
	self.vb.galeCount = 0
	self.vb.addsCount = 0
	timerFeebleCD:Start(16-delay, 1)
	timerGaleCD:Start(23-delay, 1)
--	timerAddsCD:Start(95-delay, 1)--First ones don't start until boss reaches % health of some sort?
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 75861 then
		warnBinding:CombinedShow(0.3, args.destName)
	elseif spellId == 75792 then
		self.vb.feebleCount = self.vb.feebleCount + 1
		warnFeeble:Show(args.destName)
		timerFeebleCD:Start(nil, self.vb.feebleCount+1)
		if self:IsDifficulty("normal") then
			timerFeeble:Start(args.destName)
		else
			timerFeeble:Start(5, args.destName)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(75763, 79467) and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnMending:Show()
		specWarnMending:Play("kickcast")
	end
end

--Sometimes boss fails to cast gale so no SPELL_CAST_START event. This ensures we still detect cast and start timers
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 75656 then
		self.vb.galeCount = self.vb.galeCount + 1
		specWarnGale:Show(self.vb.galeCount)
		specWarnGale:Play("findshelter")
		timerGale:Start()
		timerGaleCD:Start(nil, self.vb.galeCount+1)
	elseif spellId == 75704 then
		self.vb.addsCount = self.vb.addsCount + 1
		specWarnAdds:Show(self.vb.addsCount)
		specWarnAdds:Play("killmob")
		timerAddsCD:Start(nil, self.vb.addsCount+1)
	end
end
