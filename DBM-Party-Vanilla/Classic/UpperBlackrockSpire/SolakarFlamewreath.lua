local mod	= DBM:NewMod("SolakarFlamewreath", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10264)

mod:RegisterCombat("combat")
