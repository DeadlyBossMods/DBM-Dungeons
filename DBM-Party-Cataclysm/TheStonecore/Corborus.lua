local mod	= DBM:NewMod(110, "DBM-Party-Cataclysm", 7, 67)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(43438)
mod:SetEncounterID(1056)
mod:SetZone(725)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 86881",
	"SPELL_CAST_SUCCESS 82415",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnCrystalBarrage			= mod:NewTargetAnnounce(81634, 2, nil, false, 2)
local warnDampening					= mod:NewSpellAnnounce(82415, 2)
local warnSubmerge					= mod:NewAnnounce("WarnSubmerge", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerge					= mod:NewAnnounce("WarnEmerge", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")

local specWarnCrystalBarrage		= mod:NewSpecialWarningYou(81634, nil, nil, nil, 1, 2)

local timerDampening				= mod:NewCDTimer(10, 82415, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSubmerge					= mod:NewTimer(80, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6)
local timerEmerge					= mod:NewTimer(30, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)

local crystalTargets = {}

function mod:OnCombatStart(delay)
	timerSubmerge:Start(30-delay)
	table.wipe(crystalTargets)
end


function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 86881 and not self:IsTrivial() then
		warnCrystalBarrage:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnCrystalBarrage:Show()
			specWarnCrystalBarrage:Play("targetyou")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 82415 then
		warnDampening:Show()
		timerDampening:Start()
	end
end

--"<6.5> [INSTANCE_ENCOUNTER_ENGAGE_UNIT] Fake Args:#1#1#Corborus#0xF130A9AE00013D1D#elite#2904790#nil#nil#nil#nil#normal#0#nil#nil#nil#nil#normal#0#nil#nil#nil#nil#normal#0#Real Args:", -- [40]
--"<36.5> [UNIT_SPELLCAST_SUCCEEDED] Corborus:Possible Target<Omegal>:boss1:ClearAllDebuffs::0:34098", -- [1228]
--"<65.6> [UNIT_SPELLCAST_SUCCEEDED] Corborus:Possible Target<nil>:boss1:Emerge::0:81948", -- [1830]
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 34098 then--ClearAllDebuffs, He casts this before borrowing.
		warnSubmerge:Show()
		timerEmerge:Start()
		timerDampening:Cancel()
	elseif spellId == 81948 then--Emerge, He casts this before borrowing.
		warnEmerge:Show()
		timerSubmerge:Start()
	end
end
