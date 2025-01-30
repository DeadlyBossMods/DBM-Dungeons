if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("Apprentice", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3170, 3171, 3172)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1222943"
)

--"Incendiary Boulder-1222943-npc:238233-00001A42B7 = pull:13.5, 17.8, 19.4, 17.8, 19.4, 17.8, 19.4",
local warnBoulder = mod:NewSpellAnnounce(1222943, 2)
local timerBoulder = mod:NewNextTimer(17.8, 1222943)

mod.vb.boulderCount = 0
function mod:OnCombatStart(delay)
	timerBoulder:Start(13.5 - delay) -- TODO: not sure if this is accurate in general
	self.vb.boulderCount = 0
end


function mod:SPELL_CAST_START(args)
	if args:IsSpell(1222943) then
		warnBoulder:Show()
		-- TODO: can we guess the target? doesn't look like it from my log, but let's try run with boss target as debug or something
		self.vb.boulderCount = self.vb.boulderCount + 1
		timerBoulder:Start(self.vb.boulderCount % 2 == 1 and 17.8 or 19.4)
	end
end
