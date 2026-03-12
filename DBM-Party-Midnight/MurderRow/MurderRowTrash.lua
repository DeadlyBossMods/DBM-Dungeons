local mod	= DBM:NewMod("MurderRowTrash", "DBM-Party-Midnight", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(2813)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true


mod:RegisterEvents(
	"GOSSIP_SHOW"
)

--NOTE, bounce appears to be missing or misflagged in EncounterEvent but we know it exists so it's one of misflagged abilities (maybe the wierd escape one?
--NOTE, Entertainer is also missing from EncounterEvent, but we know it exists, so also one of misflagged abilities
--NOTE, because these files aren't cleared on combat end, or updated when a user changes sound, user sound settings will actually be ignored until reloadui
mod:AddCustomAlertSoundOption(1218465, true, 1)--Server
mod:EnableAlertOptions(1218465, 615, "server", 19, 2, 0)
mod:AddCustomAlertSoundOption(1218466, true, 1)--Cleaner
mod:EnableAlertOptions(1218466, 616, "cleaner", 19, 2, 0)

mod:AddGossipOption(true, "Action")

function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		--Balath Dawnblade NPC before server event
		if self.Options.AutoGossipAction and gossipOptionID == 131567 then
			self:SelectGossip(gossipOptionID)
		end
	end
end
