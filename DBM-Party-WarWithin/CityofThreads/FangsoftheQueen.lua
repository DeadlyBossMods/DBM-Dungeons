local mod	= DBM:NewMod(2595, "DBM-Party-WarWithin", 8, 1274)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(216648, 216649)--Nx, Vx
mod:SetEncounterID(2908)
mod:SetHotfixNoticeRev(20240818000000)
mod:SetMinSyncRevision(20240818000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 441384 441381 439621 440468 439692 440218 440238",
--	"SPELL_CAST_SUCCESS 440419",
	"SPELL_AURA_APPLIED 441298 458741 440238",
--	"SPELL_AURA_REMOVED 439989"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"CHAT_MSG_MONSTER_SAY"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE: Knife Throw is just spammed, not practical alert or timer
--TODO: auto mark paranoia if it's not too many targets at once.
--TODO, Dark Paranoia doesn't seem used on even M+ 10
--[[
(ability.id = 441384 or ability.id = 441381 or ability.id = 439621 or ability.id = 440468 or ability.id = 440420 or ability.id = 439692 or ability.id = 440218) and type = "begincast"
 or ability.id = 440419 and type = "cast"
 or ability.id = 439989 and type = "removedebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--General
local warnSynergicStep						= mod:NewCountAnnounce(439989, 3)

local timerRP								= mod:NewRPTimer(8)
local timerNextSwapCD						= mod:NewCDCountTimer(44.9, 439989, nil, nil, nil, 6)
--Nx Active (Vx support)
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28876))
local warnIceSickles						= mod:NewTargetNoFilterAnnounce(440238, 3, nil, "RemoveMagic")

local specWarnShadeSlash					= mod:NewSpecialWarningDefensive(439621, nil, nil, nil, 1, 2)
local specWarnDuskbringer					= mod:NewSpecialWarningDodgeCount(439692, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerShadeSlashCD						= mod:NewCDCountTimer(7.8, 439621, nil, "Tank|Healer", nil, 5)
local timerDuskbringerCD					= mod:NewCDCountTimer(33.9, 439692, nil, nil, nil, 2)
local timerIceSicklesCD						= mod:NewCDCountTimer(33.9, 440218, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
--Vx Active (Nx support)
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28875))
local warnFrozenSolid						= mod:NewTargetNoFilterAnnounce(458741, 4)--Failing freezing blood

local specWarnRimeDagger					= mod:NewSpecialWarningDefensive(440468, nil, nil, nil, 1, 2)
local yellFreezingBlood						= mod:NewYell(441298, nil, nil, nil, "YELL")

local timerRimeDaggerCD						= mod:NewCDCountTimer(13.3, 440468, nil, nil, nil, 5)

mod.vb.swapCount = 0
mod.vb.tankCount = 0
mod.vb.duskCount = 0
mod.vb.paranoiaCount = 0
mod.vb.iceCount = 0

---@param self DBMMod2595
local function buggedIceSicklesCast(self)
	self.vb.iceCount = self.vb.iceCount + 1
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.swapCount = 0
	self.vb.tankCount = 0
	self.vb.duskCount = 0
	self.vb.shunpoCount = 0
	self.vb.paranoiaCount = 0
	self.vb.iceCount = 0
	--Nx starts active on pull
	timerShadeSlashCD:Start(4.4-delay, 1)
	timerDuskbringerCD:Start(18.5-delay, 1)
	timerIceSicklesCD:Start(20.4-delay, 1)
	self:Schedule(25.4, buggedIceSicklesCast, self)
	timerNextSwapCD:Start(28.1-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if (spellId == 441384 or spellId == 441381) and self:AntiSpam(5, 1) then--Synergic Step (Swapping)
		self:Unschedule(buggedIceSicklesCast)
		self.vb.swapCount = self.vb.swapCount + 1
		warnSynergicStep:Show(self.vb.swapCount)
		--Stop timers all timers
		timerShadeSlashCD:Stop()
		timerDuskbringerCD:Stop()
		timerRimeDaggerCD:Stop()
		timerIceSicklesCD:Stop()
		if self:GetStage(1) then
			self:SetStage(2)
			--Start Vx Active timers, Nx Inactive timers
			timerRimeDaggerCD:Start(24.9, self.vb.tankCount+1)--24.9-26.3 (phase change travel times)
			timerDuskbringerCD:Start(35.8, self.vb.duskCount+1)--35.8-37.8
		else
			self:SetStage(1)
			--Start Nx Active timers, Vx Inactive timers
			timerShadeSlashCD:Start(24.0, self.vb.tankCount+1)
			timerDuskbringerCD:Start(39.5, self.vb.duskCount+1)
			timerIceSicklesCD:Start(42.3, self.vb.iceCount+1)
			self:Schedule(47.3, buggedIceSicklesCast, self)
		end
		timerNextSwapCD:Start(44.9, self.vb.swapCount+1)
	elseif spellId == 439621 then
		self.vb.tankCount = self.vb.tankCount + 1
		--2 casts per set, only start first timer here, other cast started in phasing cast
		if self.vb.tankCount % 2 == 1 then
			timerShadeSlashCD:Start(9.4, self.vb.tankCount+1)
		end
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnShadeSlash:Show()
			specWarnShadeSlash:Play("defensive")
		end
	elseif spellId == 440468 then
		self.vb.tankCount = self.vb.tankCount + 1
		--2 casts per set, only start first timer here, other cast started in phasing cast
		if self.vb.tankCount % 2 == 1 then
			timerRimeDaggerCD:Start(9.4, self.vb.tankCount+1)
		end
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnRimeDagger:Show()
			specWarnRimeDagger:Play("defensive")
		end
	elseif spellId == 439692 then
		self.vb.duskCount = self.vb.duskCount + 1
		specWarnDuskbringer:Show(self.vb.duskCount)
		specWarnDuskbringer:Play("aesoon")
		specWarnDuskbringer:ScheduleVoice(1.5, "watchstep")
		--timerDuskbringerCD:Start(nil, self.vb.duskCount+1)--Not started here, one cast per phase
	elseif spellId == 440218 then
		self:Unschedule(buggedIceSicklesCast)
		self.vb.iceCount = self.vb.iceCount + 1
--		timerIceSicklesCD:Start(nil, self.vb.iceCount+1)--Not started here, one cast per phase
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 441298 then
		if args:IsPlayer() then
			yellFreezingBlood:Yell()
		end
	elseif spellId == 458741 then
		warnFrozenSolid:Show(args.destName)
	elseif spellId == 440238 then
		warnIceSickles:CombinedShow(0.5, args.destName)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--"<777.33 09:52:11> [CHAT_MSG_MONSTER_SAY] The Transformatory was once the home of our sacred evolution.#Executor Nizrek###Junghee##0#0##0#517#nil#0#false#false#false#false",
--"<803.71 09:52:37> [NAME_PLATE_UNIT_ADDED] Nx#Creature-0-3776-2669-3094-216648-00007B52C3",
--"<803.74 09:52:37> [NAME_PLATE_UNIT_ADDED] Vx#Creature-0-3776-2669-3094-216649-00007B52C3",
function mod:CHAT_MSG_MONSTER_SAY(msg)
	if (msg == L.RolePlay or msg:find(L.RolePlay)) and self:LatencyCheck() then
		self:SendSync("openingRP")
	end
end

function mod:OnSync(msg)
	if msg == "openingRP" and self:AntiSpam(10, 3) then
		timerRP:Start(26.3)
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
