local mod	= DBM:NewMod(2595, "DBM-Party-WarWithin", 8, 1274)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(216648, 216649)--Nx, Vx
mod:SetEncounterID(2908)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 441384 441381 439621 440468 440420",
	"SPELL_CAST_SUCCESS 440419",
	"SPELL_AURA_APPLIED 439692 440437 441286",
	"SPELL_AURA_REMOVED 439989"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE: Ice Sickles cast isn't in combat log, only players hit by it. needs transcriptor to fix
--NOTE: Knife Throw is just spammed, not practical alert or timer
--TODO: some way of tracking https://www.wowhead.com/beta/spell=441298/freezing-blood for stack management. maybe yell system like larodar?
--TODO: auto mark paranoia if it's not too many targets at once.
--[[
(ability.id = 441384 or ability.id = 441381) and type = "begincast"
 or ability.id = 439989 and type = "removedebuff"
--]]
--General
local warnSynergicStep						= mod:NewCountAnnounce(439989, 3)

local timerNextSwapCD						= mod:NewCDCountTimer(33.9, 439989, nil, nil, nil, 6)
--Nx Active (Vx support)
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28876))
--local warnSomeAbility						= mod:NewSpellAnnounce(373087, 3)

local specWarnShadeSlash					= mod:NewSpecialWarningDefensive(439621, nil, nil, nil, 1, 2)
local specWarnDuskbringer					= mod:NewSpecialWarningDodgeCount(439692, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerShadeSlashCD						= mod:NewCDCountTimer(7, 439621, nil, "Tank|Healer", nil, 5)--Needs bigger sample
local timerDuskbringerCD					= mod:NewCDCountTimer(33.9, 439692, nil, nil, nil, 2)
--local timerIceSicklesCD					= mod:NewCDCountTimer(33.9, 440238, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
--Vx Active (Nx support)
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28875))
local warnShadowShunpo						= mod:NewTargetNoFilterAnnounce(440419, 3, nil, false)
local warnDarkparanoia						= mod:NewTargetNoFilterAnnounce(440420, 4)

local specWarnRimeDagger					= mod:NewSpecialWarningDefensive(440468, nil, nil, nil, 1, 2)
local specWarnDarkParanoia					= mod:NewSpecialWarningMoveAway(440420, nil, nil, nil, 2, 2, 4)
local yellDarkParanoia						= mod:NewYell(440420)

local timerRimeDaggerCD						= mod:NewCDCountTimer(5, 440468, nil, nil, nil, 5)--5-7.9
local timerDarkparanoiaCD					= mod:NewAITimer(3, 440420, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerShadowShunpoCD					= mod:NewCDCountTimer(3, 440419, nil, nil, nil, 3)

mod.vb.swapCount = 0
mod.vb.tankCount = 0
mod.vb.duskCount = 0
mod.vb.shunpoCount = 0
mod.vb.paranoiaCount = 0

function mod:OnCombatStart(delay)
	self.vb.swapCount = 0
	self.vb.tankCount = 0
	self.vb.duskCount = 0
	self.vb.shunpoCount = 0
	self.vb.paranoiaCount = 0
	--Nx starts active on pull
	timerShadeSlashCD:Start(7-delay, 1)
	timerDuskbringerCD:Start(18.5-delay, 1)
	timerNextSwapCD:Start(26.1-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if (spellId == 441384 or spellId == 441381) then--Synergic Step (Swapping)
		self.vb.swapCount = self.vb.swapCount + 1
		warnSynergicStep:Show(self.vb.swapCount)
		--Stop timers all timers
		timerShadeSlashCD:Stop()
		timerDuskbringerCD:Stop()
		timerRimeDaggerCD:Stop()
		timerShadowShunpoCD:Stop()
		timerDarkparanoiaCD:Stop()
	elseif spellId == 439621 then
		self.vb.tankCount = self.vb.tankCount + 1
		timerShadeSlashCD:Start(nil, self.vb.tankCount+1)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnShadeSlash:Show()
			specWarnShadeSlash:Play("defensive")
		end
	elseif spellId == 440468 then
		self.vb.tankCount = self.vb.tankCount + 1
		timerRimeDaggerCD:Start(nil, self.vb.tankCount+1)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnRimeDagger:Show()
			specWarnRimeDagger:Play("defensive")
		end
	elseif spellId == 440420 then
		self.vb.paranoiaCount = self.vb.paranoiaCount + 1
		timerDarkparanoiaCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 440419 then
		self.vb.shunpoCount = self.vb.shunpoCount + 1
		timerShadowShunpoCD:Start(nil, self.vb.shunpoCount+1)
	end
end


function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 439692 then
		self.vb.duskCount = self.vb.duskCount + 1
		specWarnDuskbringer:Show(self.vb.duskCount)
		specWarnDuskbringer:Play("aesoon")
		specWarnDuskbringer:ScheduleVoice(1.5, "watchstep")
		--timerDuskbringerCD:Start(nil, self.vb.duskCount+1)
	elseif spellId == 440437 then
		warnShadowShunpo:Show(args.destName)
	elseif spellId == 441286 then
		if args:IsPlayer() then
			specWarnDarkParanoia:Show()
			specWarnDarkParanoia:Play("runout")
			yellDarkParanoia:Yell()
		else
			warnDarkparanoia:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 439989 then--Removed of this ID is the boss entering arena
		self.vb.tankCount = 0
		self.vb.duskCount = 0
		self.vb.shunpoCount = 0
		self.vb.paranoiaCount = 0
		--timerNextSwapCD:Start(nil, self.vb.swapCount+1)
		if args:GetDestCreatureID() == 216648 then--Nx is leaving
			--Start Vx Active timers, Nx Inactive timers
			timerShadowShunpoCD:Start(10, 1)
			timerRimeDaggerCD:Start(21.5, 1)
			if self:IsMythic() then
				timerDarkparanoiaCD:Start(2)
			end
		else--Vx is leaving
			--Start Nx Active timers, Vx Inactive timers
			--timerShadeSlashCD:Start(7, 1)
			--timerDuskbringerCD:Start(18.5, 1)
		end
	end
end


--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
