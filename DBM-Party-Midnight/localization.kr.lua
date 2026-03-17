if GetLocale() ~= "koKR" then return end
local L

-----------------------
--Murder Row Trash
-----------------------
L = DBM:GetModLocalization("MurderRowTrash")

L:SetGeneralLocalization({
	name =	"죽음의 골목 일반몹"
})
