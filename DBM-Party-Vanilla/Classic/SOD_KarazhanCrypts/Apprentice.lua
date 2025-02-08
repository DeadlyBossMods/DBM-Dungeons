if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("Apprentice", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3170, 3171, 3172)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1222943 1220882",
	"SPELL_CAST_SUCCESS 1220882 1220862",
	"SPELL_AURA_APPLIED 1220862",
	"SPELL_PERIODIC_DAMAGE 1220862",
	"SPELL_PERIODIC_MISSED 1220862"
)

mod:RegisterEvents("ENCOUNTER_START")

-- Kaigy
--"Incendiary Boulder-1222943-npc:238233-00001A42B7 = pull:13.5, 17.8, 19.4, 17.8, 19.4, 17.8, 19.4",
local warnBoulder = mod:NewSpellAnnounce(1222943, 2)
local timerBoulder = mod:NewNextTimer(17.8, 1222943)

-- Sairuh
-- Blizzard (1220862) -> GTFO
-- 11.3, 33.58, 58.25

-- Freezing Field
-- Dodge or something, I don't seem anything relevant in the log for a GTFO
-- 21.03, 71.17

local warnFreezingField		= mod:NewCastAnnounce(1220882)
local timerFreezingField	= mod:NewCDTimer(50, 1220882)
local timerBlizzard			= mod:NewCDTimer(22.2, 1220862)

local specWarnGTFO	= mod:NewSpecialWarningGTFO(1220862, nil, nil, nil, 1, 8)


mod.vb.boulderCount = 0

function mod:PullKaigy()
	-- TODO: not sure if this is accurate
	timerBoulder:Start(13.52)
	self.vb.boulderCount = 0
end

function mod:PullSairuh()
	-- TODO: not sure if this is accurate
	timerFreezingField:Start(23)
	timerBlizzard:Start(11.3)
end

function mod:PullBarian()
	-- TODO
end

function mod:ENCOUNTER_START(encounterId)
	-- FIXME: Core should provide some way to detect which boss we actually pulled (they have different encounter IDs)
	if encounterId == 3170 then
		self:PullKaigy()
	elseif encounterId == 3171 then
		self:PullSairuh()
	elseif encounterId == 3172 then
		self:PullBarian()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(1222943) then
		warnBoulder:Show()
		-- TODO: can we guess the target? doesn't look like it from my log, but let's try run with boss target as debug or something
		self.vb.boulderCount = self.vb.boulderCount + 1
		-- This doesn't have a SPELL_CAST_SUCCESS event, just UCS, so schedule it here
		timerBoulder:Schedule(2.2, self.vb.boulderCount % 2 == 1 and 17.8 or 19.4)
	elseif args:IsSpell(1220882) then
		warnFreezingField:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(1220882) then
		timerFreezingField:Start()
	elseif args:IsSpell(1220862) then
		timerBlizzard:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(1220862) and args:IsPlayer() and self:AntiSpam(3.5, "gtfo") then
		specWarnGTFO:Show()
		specWarnGTFO:Play("watchfeet")
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 1220862 and destGUID == UnitGUID("player") and self:AntiSpam(3.5, "gtfo") then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
