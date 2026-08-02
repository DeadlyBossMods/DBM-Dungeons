if GetLocale() ~= "ruRU" then return end
local L

-----------------------
--Murder Row Trash
-----------------------
L = DBM:GetModLocalization("MurderRowTrash")

L:SetGeneralLocalization({
	name =	"Трэш: Закоулок душегубов"
})

-----------------------
--The Blinding Vale Trash
-----------------------
L = DBM:GetModLocalization("TheBlindingValeTrash")

L:SetGeneralLocalization({
	name =	"Трэш: Слепящая долина"
})

-----------------------
--Voidscar Arena Trash
-----------------------
L = DBM:GetModLocalization("VoidscarArenaTrash")

L:SetGeneralLocalization({
	name =	"Трэш: Арена Шрама Бездны"
})

-----------------------
--Altar of Fangs Trash
-----------------------
L = DBM:GetModLocalization("AltarofFangsTrash")

L:SetGeneralLocalization({
	name =	"Трэш: Алтарь Клыков"
})

-----------------------
--Den of Nalorakk Trash
-----------------------
L = DBM:GetModLocalization("DenofNalorakkTrash")

L:SetGeneralLocalization({
	name =	"Трэш: Берлога Налоракка"
})
