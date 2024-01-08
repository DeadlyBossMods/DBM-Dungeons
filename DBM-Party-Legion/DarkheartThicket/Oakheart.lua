local mod	= DBM:NewMod(1655, "DBM-Party-Legion", 2, 762)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(103344)
mod:SetEncounterID(1837)
mod:SetHotfixNoticeRev(20231029000000)
mod:SetMinSyncRevision(20231029000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 204666 204646 204574 204667 204611 212786"
)

--[[
(ability.id = 204666 or ability.id = 204574 or ability.id = 204667 or ability.id = 204611 or ability.id = 212786) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 204646 and type = "begincast"
--]]
--NOTE: this boss has some serious spell queuing issues that causes wild variation in timers and ability orders
--As such, it will use aggressive on the fly timer correction that may feel jarring to users that don't recognize it's happening til they realize it is and why
local warnShatteredEarth			= mod:NewSpellAnnounce(204666, 2)
local warnThrowTarget				= mod:NewTargetNoFilterAnnounce(204658, 2)--This is target the tank is THROWN at.
local warnUproot					= mod:NewSpellAnnounce(212786, 2)

local specWarnRoots					= mod:NewSpecialWarningDodge(204574, nil, nil, nil, 2, 2)
local yellThrow						= mod:NewYell(204658, 2764)--yell so others can avoid splash damage. I don't think target can avoid
local specWarnBreath				= mod:NewSpecialWarningDefensive(204667, nil, nil, nil, 1, 2)

local timerShatteredEarthCD			= mod:NewCDCountTimer(31.6, 204666, nil, nil, nil, 2)--34-60 (basically same as OG)
local timerCrushingGripCD			= mod:NewCDCountTimer(27.9, 204611, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON, nil, mod:IsTank() and 2, 4)--27.9-36 (basically same as OG)
local timerRootsCD					= mod:NewCDCountTimer(18.2, 204574, nil, nil, nil, 3)--18.2-35.1 (basically same as OG)
local timerBreathCD					= mod:NewCDCountTimer(26.5, 204667, nil, nil, nil, 5)--26-35 (basically same as OG)
local timerUprootCD					= mod:NewCDCountTimer(32.4, 212786, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--32.7-37.6 (Probably also OG timer, but didn't have it in OG mod)

mod.vb.shatteredCount = 0
mod.vb.crushingCount = 0
mod.vb.rootsCount = 0
mod.vb.breathCount = 0
mod.vb.uprootCount = 0

--Nightmare Breath triggers 7.2 (formerly 9.7) ICD
--Crushing Grip triggers 6 ICD (well technically it triggers 1, and second Id triggers 5 more)
--Uproot triggers 3.6 ICD
--Strangling Roots triggers 2.4 ICD
--Shattering Earth triggers 7.2 ICD
--Shattering Roots itself is unaffected by ICDs of other spells
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerShatteredEarthCD:GetRemaining(self.vb.shatteredCount+1) < ICD then
		local elapsed, total = timerShatteredEarthCD:GetTime(self.vb.shatteredCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerShatteredEarthCD extended by: "..extend, 2)
		timerShatteredEarthCD:Update(elapsed, total+extend, self.vb.shatteredCount+1)
	end
	if timerCrushingGripCD:GetRemaining(self.vb.crushingCount+1) < ICD then
		local elapsed, total = timerCrushingGripCD:GetTime(self.vb.crushingCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerCrushingGripCD extended by: "..extend, 2)
		timerCrushingGripCD:Update(elapsed, total+extend, self.vb.crushingCount+1)
	end
	--Roots only affected by crushing grip ICD now (and with reduced ICD, 4.8)
	if ICD == 6 and (timerRootsCD:GetRemaining(self.vb.rootsCount+1) < 4.8) then
		local elapsed, total = timerRootsCD:GetTime(self.vb.rootsCount+1)
		local extend = 4.8 - (total-elapsed)
		DBM:Debug("timerRootsCD extended by: "..extend, 2)
		timerRootsCD:Update(elapsed, total+extend, self.vb.rootsCount+1)
	end
	if timerBreathCD:GetRemaining(self.vb.breathCount+1) < ICD then
		local elapsed, total = timerBreathCD:GetTime(self.vb.breathCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerBreathCD extended by: "..extend, 2)
		timerBreathCD:Update(elapsed, total+extend, self.vb.breathCount+1)
	end
	if timerUprootCD:GetRemaining(self.vb.uprootCount+1) < (ICD == 7.1 and 3 or ICD) then
		local elapsed, total = timerUprootCD:GetTime(self.vb.uprootCount+1)
		local extend = (ICD == 7.1 and 3 or ICD) - (total-elapsed)
		DBM:Debug("timerUprootCD extended by: "..extend, 2)
		timerUprootCD:Update(elapsed, total+extend, self.vb.uprootCount+1)
	end
end

--AKA Crushing Grip secondary mechanic
function mod:ThrowTarget(targetname, uId)
	if not targetname then
		return
	end
	warnThrowTarget:Show(targetname)
	if targetname == UnitName("player") then
		--Can this be dodged? personal warning?
		yellThrow:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.shatteredCount = 0
	self.vb.crushingCount = 0
	self.vb.rootsCount = 0
	self.vb.breathCount = 0
	self.vb.uprootCount = 0
	timerShatteredEarthCD:Start(7.2-delay, 1)--7.3, 8.1, 8.5
	timerRootsCD:Start(10.2-delay, 1)--12.2, 15.8, 12.2, 12.9
	timerBreathCD:Start(18.2-delay, 1)--21.4, 21.5, 18.2
	--Uproot and Crushing can swap places pull to pull then stay that way rest of fight
	timerCrushingGripCD:Start(27.9-delay, 1)--27.9, 34, 34.8 (34 if it's after uproot)
	timerUprootCD:Start(30.4-delay, 1)--31.1, 30.4, 34 (30-31 if it's first)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 204646 then--Secondary cast of Crushing Grip
		self:BossTargetScanner(103344, "ThrowTarget", 0.1, 12, true, nil, nil, nil, true)--Filters tank,
	elseif spellId == 204666 then
		self.vb.shatteredCount = self.vb.shatteredCount + 1
		warnShatteredEarth:Show(self.vb.shatteredCount)
		--35.2, 44.9 / 51.8, 36.3 / 52.2, 60.7
		timerShatteredEarthCD:Start(nil, self.vb.shatteredCount+1)
		updateAllTimers(self, 7.2)
	elseif spellId == 204574 then
		self.vb.rootsCount = self.vb.rootsCount + 1
		specWarnRoots:Show(self.vb.rootsCount)
		specWarnRoots:Play("watchstep")
		--25.5, 29.1, 35.1 / 28.7, 32.7, 27.9, 23 / 27.9, 32.7, 31.6, 27.9
		timerRootsCD:Start(nil, self.vb.rootsCount+1)
		updateAllTimers(self, 2.4)
	elseif spellId == 204667 then
		self.vb.breathCount = self.vb.breathCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnBreath:Show(self.vb.breathCount)
			specWarnBreath:Play("defensive")
		end
		--32.7, 27.9 / 29.1, 32.7, 36.4 / 29.1, 32.8, 27.9
		timerBreathCD:Start(nil, self.vb.breathCount+1)
		updateAllTimers(self, 7.2)
	elseif spellId == 204611 then--Primary Crushnig Grip Cast
		self.vb.crushingCount = self.vb.crushingCount + 1
		--32.7, 35.1 / 33.5, 36.4 / 32.7, 27.9, 32.7
		timerCrushingGripCD:Start(nil, self.vb.crushingCount+1)
		updateAllTimers(self, 6)
	elseif spellId == 212786 then
		self.vb.uprootCount = self.vb.uprootCount + 1
		warnUproot:Show(self.vb.uprootCount)
		--32.7, 35.1 / 33.5, 34.5 / 32.7, 37.6, 33.9
		timerUprootCD:Start(nil, self.vb.uprootCount+1)
		updateAllTimers(self, 3.6)
	end
end
