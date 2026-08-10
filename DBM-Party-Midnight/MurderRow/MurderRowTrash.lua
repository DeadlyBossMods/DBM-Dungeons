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
--TODO, add https://www.wowhead.com/ptr/spell=1302007/blade-dance as aoe warning?
mod:AddAuraSoundOption(1218468, true, 1218468, 1, 1, "bouncer", 19)--Bouncer
mod:AddAuraSoundOption(1218467, true, 1218467, 1, 1, "entertainer", 19)--Entertainer
mod:AddAuraSoundOption(1218466, true, 1218466, 1, 1, "cleaner", 19)--Cleaner
mod:AddAuraSoundOption(1218465, true, 1218465, 1, 1, "server", 19)--Server
mod:AddAuraSoundOption(1216590, "Tank", 1216590, 1, 1, "kite", 19)--Heartstop Poison
mod:AddAuraSoundOption(1217973, true, 1217973, 1, 1, "curseyou", 19)--Curse of Doom
mod:AddAuraSoundOption(1218187, true, 1218187, 1, 1, "laserrun", 2)--Fel Beam

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
