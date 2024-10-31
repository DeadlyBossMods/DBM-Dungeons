local dungeonID, creatureID
if UnitFactionGroup("player") == "Alliance" then
	dungeonID, creatureID = 2132, 128650--Redhook
else
	dungeonID, creatureID = 2133, 130834--Bainbridge
end
local mod	= DBM:NewMod(dungeonID, "DBM-Party-BfA", 5, 1023)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(creatureID)
mod:SetEncounterID(2098, 2097)--Redhook, Bainbridge
mod:SetHotfixNoticeRev(20240613000000)
mod:SetMinSyncRevision(20240613000000)
mod:DisableESCombatDetection()--Fires during trash in current TWW build, causing false engage.

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 257459 275107 257326 261428 260924 272662",
	"SPELL_AURA_APPLIED 257459 260954 261428 256709",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, verify some other spellIds
--In M+, both factions fight Lockwood, but what about non M+? Do they fight different bosses?
--TODO, Keep eye on timers. For now only cannon barrage is consistent. Everything else is a bit chaotic since boss can be kited around and prevented from casting long periods of time
--NOTE, Iron Hook will be handled by trash mod so it also includes trash in front of boss
--[[
(ability.id = 257459 or ability.id = 275107 or ability.id = 257326 or ability.id = 261428 or ability.id = 260924 or ability.id = 257288 or ability.id = 257348 or ability.id = 272662) and type = "begincast"
 or (ability.id = 257288) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 257585 and (target.id = 128650 or target.id = 130834)
 or ability.id = 273721 and (target.id = 128650 or target.id = 130834)
--]]
--Chopper Redhook
local warnOntheHook					= mod:NewTargetNoFilterAnnounce(257459, 2)
local warnMeatHook					= mod:NewCastAnnounce(275107, 2)
local warnIronHook					= mod:NewSpellAnnounce(272662, 4, nil, nil, nil, nil, nil, 12)
--Sergeant Bainbridge
local warnIronGaze					= mod:NewTargetNoFilterAnnounce(260954, 2)

--Chopper Redhook
local specWarnOntheHook				= mod:NewSpecialWarningRun(257459, nil, nil, nil, 4, 2)
local yellOntheHook					= mod:NewYell(257459)
local specWarnGoreCrash				= mod:NewSpecialWarningDodge(257326, nil, nil, nil, 2, 2)
--Sergeant Bainbridge
local specWarnIronGaze				= mod:NewSpecialWarningRun(260954, nil, nil, nil, 4, 2)
local yellIronGaze					= mod:NewYell(260954)
local specWarnHangmansNoose			= mod:NewSpecialWarningRun(261428, nil, nil, nil, 4, 2)
local specWarnSteelTempest			= mod:NewSpecialWarningDodge(260924, nil, nil, nil, 2, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)
--BOTH
local specWarnCannonBarrage			= mod:NewSpecialWarningDodgeCount(257540, nil, nil, nil, 2, 2)
--local specWarnAdds					= mod:NewSpecialWarningAdds(257649, "-Healer", nil, nil, 1, 2)

--Chopper Redhook
--local timerOntheHookCD			= mod:NewCDTimer(13, 257459, nil, nil, nil, 3)
--local timerGoreCrashCD			= mod:NewCDTimer(13, 257326, nil, nil, nil, 3)--24.9, 43.3
local timerIronHookCD				= mod:NewCDTimer(17.7, 272662, nil, nil, nil, 3)
--Sergeant Bainbridge
--local timerIronGazeCD				= mod:NewCDTimer(13, 260954, nil, nil, nil, 3)
--local timerSteelTempestCD			= mod:NewCDTimer(13, 260924, nil, nil, nil, 3)
--local timerHangmansNooseCD			= mod:NewCDTimer(13, 261428, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
--BOTH
local timerCannonBarrageCD			= mod:NewCDCountTimer(60, 257540, nil, nil, nil, 6)

mod.vb.cannonCount = 0

local function checkWhichBoss(self)
	local cid = self:GetUnitCreatureId("boss1")
	if cid then
		--Only do swaps if they differ from last check or load
		if cid ~= creatureID then--cid mismatch, correct it on engage
			creatureID = cid
			self:SetCreatureID(cid)
			--Our callbacks fire the first ID in table, so we purposely set first ID to the currently engaged boss
			if cid == 128650 then--Redhook
				self:SetEncounterID(2098, 2097)--Redhook, Bainbridge
			else
				self:SetEncounterID(2097, 2098)--Bainbridge, Redhook
			end
		end
	end
end

function mod:OnCombatStart(delay)
	self.vb.cannonCount = 0
	--if dungeonID == 2132 then--Redhook
		--timerOntheHookCD:Start(1-delay)
		--timerGoreCrashCD:Start(1-delay)
	--else--Bainbridge
		--timerIronGazeCD:Start(1-delay)
		--timerSteelTempestCD:Start(1-delay)
	--end
	timerCannonBarrageCD:Start(10.1-delay, 1)
	self:Schedule(1.5, checkWhichBoss, self)
end

function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 257459 then
		--timerOntheHookCD:Start()
	elseif spellId == 275107 then
		warnMeatHook:Show()
	elseif spellId == 257326 then
		specWarnGoreCrash:Show()
		specWarnGoreCrash:Play("watchstep")
		--timerGoreCrashCD:Start()
	elseif spellId == 260924 then
		specWarnSteelTempest:Show()
		specWarnSteelTempest:Play("watchstep")
		--timerSteelTempestCD:Start()
	elseif spellId == 261428 then
		--timerHangmansNooseCD:Start()
--	elseif spellId == 260954 then
		--timerIronGazeCD:Start()
	elseif spellId == 272662 and args:GetSrcCreatureID() == 128650 then
		warnIronHook:Show()
		warnIronHook:Play("pullin")
		timerIronHookCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 260954 then
		if args:IsPlayer() then
			specWarnIronGaze:Show()
			specWarnIronGaze:Play("justrun")
			specWarnIronGaze:ScheduleVoice(1.5, "keepmove")
			yellIronGaze:Yell()
		else
			warnIronGaze:Show(args.destName)
		end
	elseif spellId == 257459 then
		if args:IsPlayer() then
			specWarnOntheHook:Show()
			specWarnOntheHook:Play("justrun")
			specWarnOntheHook:ScheduleVoice(1.5, "keepmove")
			yellOntheHook:Yell()
		else
			warnOntheHook:Show(args.destName)
		end
	elseif spellId == 261428 then
		if args:IsPlayer() then
			specWarnHangmansNoose:Show()
			specWarnHangmansNoose:Play("justrun")
			specWarnHangmansNoose:ScheduleVoice(1.5, "keepmove")
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 228007 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show()
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--STILL not in combat log
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257540 then--Cannon Barrage
		--18.1, 60.2, 61.0
		self.vb.cannonCount = self.vb.cannonCount + 1
		specWarnCannonBarrage:Show(self.vb.cannonCount)
		specWarnCannonBarrage:Play("watchstep")
		timerCannonBarrageCD:Start(nil, self.vb.cannonCount+1)
	--19.7, 18.2, 14.6
--	elseif spellId == 274002 then--Call Adds (works fine alliance side, horde side it spams non stop)
		--specWarnAdds:Show()
		--specWarnAdds:Play("mobsoon")
	--	end
	end
end
