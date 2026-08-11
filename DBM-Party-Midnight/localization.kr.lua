if GetLocale() ~= "koKR" then return end
local L

-----------------------
--Murder Row Trash
-----------------------
L = DBM:GetModLocalization("MurderRowTrash")

L:SetGeneralLocalization({
	name =	"죽음의 골목 일반몹"
})

-----------------------
--The Blinding Vale Trash
-----------------------
L = DBM:GetModLocalization("TheBlindingValeTrash")

L:SetGeneralLocalization({
	name =	"눈부신 골짜기 일반몹"
})

-----------------------
--Voidscar Arena Trash
-----------------------
L = DBM:GetModLocalization("VoidscarArenaTrash")

L:SetGeneralLocalization({
	name =	"공허흉터 투기장 일반몹"
})

-----------------------
--Altar of Fangs Trash
-----------------------
L = DBM:GetModLocalization("AltarofFangsTrash")

L:SetGeneralLocalization({
	name =	"송곳니의 제단 일반몹"
})

-----------------------
--Den of Nalorakk Trash
-----------------------
L = DBM:GetModLocalization("DenofNalorakkTrash")

L:SetGeneralLocalization({
	name =	"날로라크의 소굴 일반몹"
})
