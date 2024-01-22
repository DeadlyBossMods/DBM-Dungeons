local mod	= DBM:NewMod(1657, "DBM-Party-Legion", 2, 762)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(99192)
mod:SetEncounterID(1839)
mod:SetHotfixNoticeRev(20231030000000)
mod:SetMinSyncRevision(20231030000000)
--mod.respawnTime = 29
mod:SetUsedIcons(2, 1)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 212834 200185 200050 200289",
	"SPELL_CAST_SUCCESS 200182 200238",--199837 still used?
	"SPELL_AURA_APPLIED 200182 200243 200289 200238",
	"SPELL_AURA_REMOVED 200243 200289"
)

--TOOD, maybe play gathershare for ALL (except tank) for nightmare target.
--NOTE: Timers may look sequenceable because most of time they don't variate much (outside of when boss uses apocalyptic nightmare and shifts everyhing
--But truth is it's just very consistent spell queuing due to ability Cds that keep abilities in same order every pull. It results in fairly consistent ICD gaps
--But I'm still gonna code it same way as rest of instance, with live ICD correction instead of assumed tables that DO variate slightly (and get screwed up by Apoc Nightmare)
--[[
 (ability.id = 212834 or ability.id = 200185 or ability.id = 200050 or ability.id = 200289) and type = "begincast"
 or (ability.id = 200182 or ability.id = 200238) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnWakingNightmare			= mod:NewTargetAnnounce(200243, 3)
local warnParanoia					= mod:NewTargetAnnounce(200289, 3)
local warnApocNightmare				= mod:NewSpellAnnounce(200050, 4)
local warnFeedOnTheWeak				= mod:NewTargetNoFilterAnnounce(200238, 2)

local specWarnFesteringRip			= mod:NewSpecialWarningDispel(200182, "RemoveMagic", nil, 2, 1, 2)
local specWarnWakingNightmare		= mod:NewSpecialWarningMoveTo(200243, nil, nil, nil, 1, 2)
local yellWakingNightmare			= mod:NewYell(200243, nil, nil, nil, "YELL")--Yell is standard for grou up
local specWarnParanoia				= mod:NewSpecialWarningMoveAway(200289, nil, nil, nil, 1, 2)
local yellParanoia					= mod:NewYell(200289)--Say is standard for avoid

local timerFesteringRipCD			= mod:NewCDCountTimer(17, 200182, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--17-21
local timerNightmareBoltCD			= mod:NewCDCountTimer(22.7, 200185, nil, nil, nil, 3)--24.3-36.5
local timerParanoiaCD				= mod:NewCDCountTimer(22, 200289, nil, nil, nil, 3)--22-34 (200359 matches journal, but better to sync up with debuff for WA keys)
local timerFeedOnTheWeakCD			= mod:NewCDCountTimer(18.2, 200238, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)

mod:AddSetIconOption("SetIconOnNightmare", 200243, true, false, {1})
mod:AddSetIconOption("SetIconOnParanoia", 200289, true, false, {2})

mod.vb.festerCount = 0
mod.vb.nightmareCount = 0
mod.vb.feedCount = 0
mod.vb.paranoiaCount = 0

--Feed on the Weak triggers 4.8 ICD
--Festering Rip triggers 2.4 ICD
--Nightmare Bolt triggers 4.8 ICD
--Growing Paranoia triggers 6 ICD
--Festering Apoc triggers 5.2 ICD (technically cast + 1)
local function updateAllTimers(self, ICD, isWeak, isPara)
	DBM:Debug("updateAllTimers running", 3)
	if timerFesteringRipCD:GetRemaining(self.vb.festerCount+1) < ((isWeak or isPara) and 2.4 or ICD) then
		local elapsed, total = timerFesteringRipCD:GetTime(self.vb.festerCount+1)
		local extend = ((isWeak or isPara) and 2.4 or ICD) - (total-elapsed)
		DBM:Debug("timerFesteringRipCD extended by: "..extend, 2)
		timerFesteringRipCD:Update(elapsed, total+extend, self.vb.festerCount+1)
	end
	if timerNightmareBoltCD:GetRemaining(self.vb.nightmareCount+1) < (isWeak and 2.4 or ICD) then
		local elapsed, total = timerNightmareBoltCD:GetTime(self.vb.nightmareCount+1)
		local extend = (isWeak and 2.4 or ICD) - (total-elapsed)
		DBM:Debug("timerNightmareBoltCD extended by: "..extend, 2)
		timerNightmareBoltCD:Update(elapsed, total+extend, self.vb.nightmareCount+1)
	end
	if timerFeedOnTheWeakCD:GetRemaining(self.vb.feedCount+1) < ICD then
		local elapsed, total = timerFeedOnTheWeakCD:GetTime(self.vb.feedCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerFeedOnTheWeakCD extended by: "..extend, 2)
		timerFeedOnTheWeakCD:Update(elapsed, total+extend, self.vb.feedCount+1)
	end
	if timerParanoiaCD:GetRemaining(self.vb.paranoiaCount+1) < (isWeak and 3.6 or ICD) then
		local elapsed, total = timerParanoiaCD:GetTime(self.vb.paranoiaCount+1)
		local extend = (isWeak and 3.6 or ICD) - (total-elapsed)
		DBM:Debug("timerParanoiaCD extended by: "..extend, 2)
		timerParanoiaCD:Update(elapsed, total+extend, self.vb.paranoiaCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.festerCount = 0
	self.vb.nightmareCount = 0
	self.vb.feedCount = 0
	self.vb.paranoiaCount = 0
	timerFesteringRipCD:Start(3.2-delay, 1)
	timerNightmareBoltCD:Start(6-delay, 1)
	timerFeedOnTheWeakCD:Start(15.7-delay, 1)
	timerParanoiaCD:Start(20.4-delay, 1)
end

--<1631.04 22:47:56> [CLEU] SPELL_CAST_START#Creature-0-5770-1466-11160-99192-000021BD9C#Shade of Xavius(78.8%-100.0%)##nil#200289#Growing Paranoia#nil#nil", -- [20172]
--<1631.04 22:47:56> [CLEU] SPELL_CAST_SUCCESS#Creature-0-5770-1466-11160-99192-000021BD9C#Shade of Xavius(78.8%-100.0%)##nil#200359#Induced Paranoia#nil#nil", -- [20174]
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 212834 or spellId == 200185 then--212834 is easy mode non waking nightmare mechanic, 200185 is one with waking nightmare
		self.vb.nightmareCount = self.vb.nightmareCount + 1
		--7.2, 26.6, 36.5 (8.6 added), 24.3
		--6.8, 26.7, 27.9, 32.7 (8.4 added), 27.8
		--6.9, 26.7, 27.9
		timerNightmareBoltCD:Start(nil, self.vb.nightmareCount+1)
		updateAllTimers(self, 4.8)
	elseif spellId == 200050 then
		warnApocNightmare:Show()
		updateAllTimers(self, 5.2)
	elseif spellId == 200289 then--Slightly faster in CLEU than 200359
		self.vb.paranoiaCount = self.vb.paranoiaCount + 1
		--27.8, 34, 24.4, 32.8
		--27.5, 27.9, 32.7, 27.9, 32.7
		--27.5, 27.9, 32.7
		timerParanoiaCD:Start(nil, self.vb.paranoiaCount+1)
		updateAllTimers(self, 6, false, true)--Review, might be 2.4 now
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 200182 then
		self.vb.festerCount = self.vb.festerCount + 1
		--3.5, 21.8, 19.4, 23.1, 24.4, 24.3
		--3.2, 21.8, 19.4, 21.8, 19.4, 19.3, 21.8, 19.4
		--3.2, 21.9, 19.3, 21.8, 19.4
		timerFesteringRipCD:Start(nil, self.vb.festerCount+1)
		updateAllTimers(self, 2.4)
	elseif spellId == 200238 then
		self.vb.feedCount = self.vb.feedCount + 1
		--16.9, 30.3, 30.5, 30.3
		--16.6, 30.3, 30.3, 30.3, 30.3
		--16.6, 30.3, 30.3
		--17.0, 30.4, 44.9, 30.4, 30.4 (yes even feed can get spell queued depending on apocalytpic timing)
		timerFeedOnTheWeakCD:Start(nil, self.vb.feedCount+1)
		updateAllTimers(self, 6, true)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 200182 then
		specWarnFesteringRip:Show(args.destName)
		specWarnFesteringRip:Play("helpdispel")
	elseif spellId == 200243 then
		if args:IsPlayer() then
			specWarnWakingNightmare:Show(DBM_COMMON_L.ALLY)
			specWarnWakingNightmare:Play("gathershare")
			yellWakingNightmare:Yell()
		else
			warnWakingNightmare:Show(args.destName)
		end
		--CD increased in 10.2, no longer needs to use two icons
		if self.Options.SetIconOnNightmare then
			self:SetIcon(args.destName, 1)
		end
	elseif spellId == 200289 then
		if args:IsPlayer() then
			specWarnParanoia:Show()
			specWarnParanoia:Play("scatter")
			yellParanoia:Yell()
		else
			warnParanoia:Show(args.destName)
		end
		--CD increased in 10.2, no longer needs to use two icons
		if self.Options.SetIconOnParanoia then
			self:SetIcon(args.destName, 2)
		end
	elseif spellId == 200238 and (args:IsPlayer() or self:IsHealer()) then
		warnFeedOnTheWeak:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 200243 then
		if self.Options.SetIconOnNightmare then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 200289 then
		if self.Options.SetIconOnParanoia then
			self:SetIcon(args.destName, 0)
		end
	end
end
