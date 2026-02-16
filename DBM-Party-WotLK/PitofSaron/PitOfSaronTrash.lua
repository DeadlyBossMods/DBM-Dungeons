local mod	= DBM:NewMod("PitOfSaronTrash", "DBM-Party-WotLK", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(658)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"GOSSIP_SHOW"
)

mod:AddGossipOption(true, "Action")

function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		--All 6 slave camps
		if self.Options.AutoGossipBuff and (gossipOptionID == 136624 or gossipOptionID == 136271 or gossipOptionID == 136316 or gossipOptionID == 136280 or gossipOptionID == 136301 or gossipOptionID == 138618) then -- Buffs
			self:SelectGossip(gossipOptionID)
		end
	end
end
