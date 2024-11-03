local mod	= DBM:NewMod("PyroguardEmberseer", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(9816)
mod:SetZone(229)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_EMOTE"
)

-- Log from SoD:
-- <224.24 13:39:27> [CHAT_MSG_MONSTER_EMOTE] %s begins to regain its strength!#Pyroguard Emberseer
-- <255.00 13:39:57> [CHAT_MSG_MONSTER_EMOTE] %s is nearly at full strength!#Pyroguard Emberseer
-- <285.77 13:40:28> [CHAT_MSG_MONSTER_EMOTE] %s regains its power and breaks free of its bonds!#Pyroguard Emberseer
-- <287.41 13:40:30> [CHAT_MSG_MONSTER_YELL] Ha! Ha! Ha! Thank you for freeing me, fools. Now let me repay you by charring the flesh from your bones.#Pyroguard Emberseer
-- <290.44 13:40:33> [CLEU] SWING_DAMAGE#Creature-0-5210-229-17836-9816-000015056F#Pyroguard Emberseer
-- <290.45 13:40:33> [NAME_PLATE_UNIT_ADDED] Pyroguard Emberseer
local timerCombatStart	= mod:NewCombatTimer(DBM:IsRetail() and 64 or 66.2)

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L.Pull or msg:find(L.Pull) then
		timerCombatStart:Start()
	end
end
