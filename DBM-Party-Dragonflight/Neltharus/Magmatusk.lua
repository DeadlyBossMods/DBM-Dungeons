local mod	= DBM:NewMod(2494, "DBM-Party-Dragonflight", 4, 1199)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(181861)
mod:SetEncounterID(2610)
mod:SetHotfixNoticeRev(20230507000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 374365 375068 375251",
	"SPELL_CAST_SUCCESS 375436",
	"SPELL_PERIODIC_DAMAGE 375204",
	"SPELL_PERIODIC_MISSED 375204"
)

--[[
(ability.id = 374365 or ability.id = 375068 or ability.id = 375251 or ability.id = 375439) and type = "begincast"
 or (ability.id = 376169 or ability.id = 375436) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--NOTE, target scan for lava spray is veru slow, so only used for yell and target announce, everyone will get shockwave warning right away.
--NOTE: Magma Lob is cast by EACH tentacle, it's downgraded to normal warning by default and timer disabled because it gets spammy later fight

local warnMagmaLob								= mod:NewSpellAnnounce(375068, 3)
local warnVolatileMutation						= mod:NewCountAnnounce(374365, 3)
local warnLavaSpray								= mod:NewTargetNoFilterAnnounce(375251, 3)

local specWarnMagmaLob							= mod:NewSpecialWarningDodge(375068, false, nil, 2, 2, 2)
local specWarnLavaSpray							= mod:NewSpecialWarningDodge(375251, nil, nil, nil, 2, 2)
local yellLavaSpray								= mod:NewYell(375251)
local specWarnBlazingCharge						= mod:NewSpecialWarningDodge(375436, nil, nil, nil, 2, 2)
local yellBlazingCharge							= mod:NewYell(375436)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(375204, nil, nil, nil, 1, 8)

local timerRP									= mod:NewRPTimer(9.9)
local timerVolatileMutationCD					= mod:NewCDCountTimer(27.9, 374365, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)--Can get spell queued behind other abilities
--local timerMagmaLobCD							= mod:NewCDTimer(6.5, 375068, nil, nil, nil, 3)--8 unless delayed by other casts
local timerLavaSrayCD							= mod:NewCDTimer(19.4, 375251, nil, nil, nil, 3)
local timerBlazingChargeCD						= mod:NewCDTimer(23, 375436, nil, nil, nil, 3)

mod.vb.mutationCount = 0

function mod:LavaSprayTarget(targetname)
	if not targetname then return end
	warnLavaSpray:Show(targetname)
	if targetname == UnitName("player") then
		yellLavaSpray:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.mutationCount = 0
	timerLavaSrayCD:Start(7.2-delay)
--	timerMagmaLobCD:Start(8-delay)
	timerBlazingChargeCD:Start(19.3-delay)
	timerVolatileMutationCD:Start(25-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 374365 then
		self.vb.mutationCount = self.vb.mutationCount + 1
		warnVolatileMutation:Show(self.vb.mutationCount)
		timerVolatileMutationCD:Start(nil, self.vb.mutationCount+1)
	elseif spellId == 375068 then
		if self.Options.SpecWarn375068dodge then
			specWarnMagmaLob:Show()
			specWarnMagmaLob:Play("watchstep")
		else
			warnMagmaLob:Show()
		end
--		timerMagmaLobCD:Start()
	elseif spellId == 375251 then
		self:BossUnitTargetScanner("boss1", "LavaSprayTarget", 2.4, true)--Allow tank true
--		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "LavaSprayTarget", 0.2, 12, true)
		specWarnLavaSpray:Show()
		specWarnLavaSpray:Play("shockwave")
		timerLavaSrayCD:Start()
--	elseif spellId == 375439 then--Backup Trigger for Blazing Charge

	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 375436 then--Blazing Charge trigger with target information (Although pretty sure it's always on the tank)
		specWarnBlazingCharge:Show()
		specWarnBlazingCharge:Play("chargemove")
		timerBlazingChargeCD:Start()
		if args:IsPlayer() then
			yellBlazingCharge:Yell()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 375204 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:OnSync(msg)
	---@diagnostic disable-next-line: dbm-sync-checker
	if msg == "TuskRP" and self:AntiSpam(10, 9) then--Sync sent from trash mod since trash mod is already monitoring out of combat CLEU events
		timerRP:Start(9.9)
	end
end
