local mod	= DBM:NewMod("SolakarFlamewreath", "DBM-Party-Vanilla", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10264)

mod:RegisterCombat("combat")
