if GetLocale() ~= "koKR" then
	return
end
local L

------------------------
-- White Tiger Temple --
------------------------
L = DBM:GetModLocalization("d640")

L:SetMiscLocalization({
	Endless			= "무한",
	ReplyWhisper	= "<Deadly Boss Mods> %s님은 수련의 장을 플레이하느라 바쁩니다. (모드: %s, 단계: %d)"
})

------------------------
-- Mage Tower: TANK --
------------------------
L = DBM:GetModLocalization("Kruul")

L:SetGeneralLocalization({
	name	= "대군주의 귀환"
})

------------------------
-- Mage Tower: Healer --
------------------------
L = DBM:GetModLocalization("ArtifactHealer")

L:SetGeneralLocalization({
	name	= "되살아난 위협의 끝"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactFelTotem")

L:SetGeneralLocalization({
	name	= "지옥토템의 몰락"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactImpossibleFoe")

L:SetGeneralLocalization({
	name	= "말도 안 되게 강력한 적"
})

L:SetMiscLocalization({
	impServants	= "임프 하수인들이 아가타에게 힘을 불어넣기 전에 처치하세요!"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactQueen")

L:SetGeneralLocalization({
	name	= "여신왕의 분노"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactTwins")

L:SetGeneralLocalization({
	name	= "쌍둥이의 싸움 막기"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactXylem")

L:SetGeneralLocalization({
	name	= "눈동자가 어둠에 물들기 전에"
})

------------------------
-- N'Zoth Visions: Stormwind --
------------------------
--L= DBM:GetModLocalization("d1993")

------------------------
-- N'Zoth Visions: Orgrimmar --
------------------------
--L= DBM:GetModLocalization("d1995")
