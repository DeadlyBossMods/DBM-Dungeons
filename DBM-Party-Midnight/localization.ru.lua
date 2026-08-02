if GetLocale() ~= "ruRU" then return end
local L

-----------------------
--Murder Row Trash
-----------------------
L = DBM:GetModLocalization("MurderRowTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Закоулок душегубов"
})

-----------------------
--The Blinding Vale Trash
-----------------------
L = DBM:GetModLocalization("TheBlindingValeTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Слепой долины"
})

-----------------------
--Voidscar Arena Trash
-----------------------
L = DBM:GetModLocalization("VoidscarArenaTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Арены шрамов Бездны"
})

-----------------------
--Altar of Fangs Trash
-----------------------
L = DBM:GetModLocalization("AltarofFangsTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Алтаря Клыков"
})

-----------------------
--Den of Nalorakk Trash
-----------------------
L = DBM:GetModLocalization("DenofNalorakkTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Логова Налоракка"
})
