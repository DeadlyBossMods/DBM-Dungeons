-- 泰坦重铸时光服-时光2-法师-旺仔芒果/椰奶冻-2026.11.13--
if GetLocale() ~= "zhCN" then
	return
end
local L

------------------------
-- White Tiger Temple --
------------------------
L = DBM:GetModLocalization("d640")

L:SetGeneralLocalization({
	name	= "试炼场"
})

L:SetMiscLocalization({
	Bronze			= "青铜",--Blizzard deleted global localization for it from game, has to be done manually now
	Silver			= "白银",--Blizzard deleted global localization for it from game, has to be done manually now
	Gold			= "黄金",--Blizzard deleted global localization for it from game, has to be done manually now
	Endless			= "无尽",--Could not find a global for this one.
	ReplyWhisper	= "<Deadly Boss Mods> %s正在试炼场试炼中(模式:%s 波数:%d)"
})
------------------------
-- Mage Tower: TANK --
------------------------
L = DBM:GetModLocalization("Kruul")

L:SetGeneralLocalization({
	name	= "魔王归来"
})

------------------------
-- Mage Tower: Healer --
------------------------
L = DBM:GetModLocalization("ArtifactHealer")

L:SetGeneralLocalization({
	name	= "终结威胁"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactFelTotem")

L:SetGeneralLocalization({
	name	= "邪能图腾之陨"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactImpossibleFoe")

L:SetGeneralLocalization({
	name	= "出乎意料的敌人"
})

L:SetMiscLocalization({
	impServants	= "击杀小鬼仆从，别让他们为阿加莎补充能量！"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactQueen")

L:SetGeneralLocalization({
	name	= "神后之怒"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactTwins")

L:SetGeneralLocalization({
	name	= "挫败双子"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactXylem")

L:SetGeneralLocalization({
	name	= "闭上眼睛"
})

------------------------
-- N'Zoth Visions: Stormwind --
------------------------
--L= DBM:GetModLocalization("d1993")

------------------------
-- N'Zoth Visions: Orgrimmar --
------------------------
--L= DBM:GetModLocalization("d1995")

------------------------
-- Torghast (Shadowlands) --
------------------------
--L= DBM:GetModLocalization("d1963")

------------------------
-- Path of Ascension (Shadowlands)
------------------------
L = DBM:GetModLocalization("Echthra")

L:SetGeneralLocalization{
	name = "晋升之路：艾克兹拉"
}

L = DBM:GetModLocalization("Nuuminuuru")

L:SetGeneralLocalization{
	name = "晋升之路：努米努鲁"
}

L = DBM:GetModLocalization("Splinterbark")

L:SetGeneralLocalization{
	name = "晋升之路：裂皮梦魇"
}

L = DBM:GetModLocalization("CravenCorinth")

L:SetGeneralLocalization{
	name = "晋升之路：克雷文·科林斯"
}

L = DBM:GetModLocalization("Kalisthene")

L:SetGeneralLocalization{
	name = "晋升之路：卡莉丝塞茵"
}

L = DBM:GetModLocalization("AlderynandMynir")

L:SetGeneralLocalization{
	name = "晋升之路：艾尔德林和敏伊尔"
}

L = DBM:GetModLocalization("MadMortimer")

L:SetGeneralLocalization{
	name = "晋升之路：疯狂的莫塔米尔"
}

L = DBM:GetModLocalization("Thrantiok")

L:SetGeneralLocalization{
	name = "晋升之路：兹兰提奥克"
}

L = DBM:GetModLocalization("Athanos")

L:SetGeneralLocalization{
	name = "晋升之路：阿萨诺斯"
}

L = DBM:GetModLocalization("Azaruux")

L:SetGeneralLocalization{
	name = "晋升之路：阿扎鲁克斯"
}
