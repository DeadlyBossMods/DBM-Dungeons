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

--NOTE, because these files aren't cleared on combat end, or updated when a user changes sound, user sound settings will actually be ignored until reloadui
--Note, bouncer and entertainer do not have encounter events on live, so they never used that api. in 12.1 they will use aura api though
--If game version 12.1 use only auras, else, use existing encounter apis for 2 of them
if DBM:GetTOC() >= 120100 then
	mod:AddAuraSoundOption(1218468, true, 1218468, 1, 1, "bouncer", 19)--Bouncer
	mod:AddAuraSoundOption(1218467, true, 1218467, 1, 1, "entertainer", 19)--Entertainer
	mod:AddAuraSoundOption(1218466, true, 1218466, 1, 1, "cleaner", 19)--Cleaner
	mod:AddAuraSoundOption(1218465, true, 1218465, 1, 1, "server", 19)--Server
else
	mod:AddCustomAlertSoundOption(1218465, true, 1)--Server
	mod:EnableAlertOptions(1218465, 615, "server", 19, 2, 0)
	mod:AddCustomAlertSoundOption(1218466, true, 1)--Cleaner
	mod:EnableAlertOptions(1218466, 616, "cleaner", 19, 2, 0)
end

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
