local mod	= DBM:NewMod("d286", "DBM-WorldEvents", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(25740)--25740 Ahune, 25755, 25756 the two types of adds
mod:SetEncounterID(3317)
mod:SetModelID(23447)--Frozen Core, ahunes looks pretty bad.
mod:SetZone(547)

mod:SetReCombatTime(10)
mod:RegisterCombat("combat")
mod:SetMinCombatTime(15)

if mod:IsRetail() then
	mod:RegisterSafeEventsInCombat(
		"UNIT_TARGETABLE_CHANGED"
	)
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 45954",
		"SPELL_AURA_REMOVED 45954"
	)
end

mod:RegisterEvents(
	"GOSSIP_SHOW"
)

local warnSubmerged				= mod:NewSpellAnnounce(37751, 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerged				= mod:NewAnnounce("Emerged", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")

local specWarnAttack 			= mod:NewSpecialWarning("specWarnAttack", nil, nil, nil, 1, 2, nil, nil, nil, nil, "changetarget")

local timerEmerge				= mod:NewTimer(33.5, "EmergeTimer", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)
local timerSubmerge				= mod:NewTimer(92, "SubmergeTimer", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6)--Variable, 92-96

mod:AddGossipOption(true, "Encounter")

function mod:OnLimitedCombatStart(delay)
	if self:AntiSpam(4, 1) then
		timerSubmerge:Start(95-delay)--first is 95, rest are 92
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 45954 and self:AntiSpam(4, 1) then -- Ahunes Shield
		warnEmerged:Show()
		timerSubmerge:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 45954 and self:IsInCombat() then -- Ahunes Shield
		warnSubmerged:Show()
		timerEmerge:Start()
		specWarnAttack:Show()
		specWarnAttack:Play("changetarget")
	end
end

--"<127.36 13:31:29> [UNIT_TARGETABLE_CHANGED] -boss1- [CanAttack:false#Exists:false#IsVisible:true#Name:<secret>#GUID:<secret>#Classification:elite#Health:<secret>]",
--"<127.54 13:31:29> [CHAT_MSG_RAID_BOSS_EMOTE] <secret>#<secret>###<secret>##0#0##0#99#nil#<secret>#false#false#false#false",
--"<127.54 13:31:29> [RAID_BOSS_EMOTE] Ahune Retreats.  His defenses diminish.#Memory of a Flamecaller#0#true",
function mod:UNIT_TARGETABLE_CHANGED(uId)
	if not self:IsInCombat() then return end
	if UnitIsUnit(uId, "boss1") then
		if not UnitCanAttack("player", uId) then
			warnSubmerged:Show()
			timerEmerge:Start()
			specWarnAttack:Show()
			specWarnAttack:Play("changetarget")
		else
			if self:AntiSpam(4, 1) then
				warnEmerged:Show()
				timerSubmerge:Start()
			end
		end
	end
end

function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if self.Options.AutoGossipEncounter and (gossipOptionID == 135555 or gossipOptionID == 36888) then
		self:SelectGossip(gossipOptionID)
	end
end
