if GetLocale() ~= "deDE" then
	return
end
local L

------------------------
-- White Tiger Temple --
------------------------
L = DBM:GetModLocalization("d640")

L:SetMiscLocalization({
	Endless			= "Endlos",
	ReplyWhisper	= "<Deadly Boss Mods> %s ist in der Feuerprobe beschäftigt (Modus: %s Welle: %d)"
})

------------------------
-- Mage Tower: TANK --
------------------------
L = DBM:GetModLocalization("Kruul")

L:SetGeneralLocalization({
	name	= "Rückkehr des Hochlords"
})

------------------------
-- Mage Tower: Healer --
------------------------
L = DBM:GetModLocalization("ArtifactHealer")

L:SetGeneralLocalization({
	name	= "Das Ende der erwachten Bedrohung"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactFelTotem")

L:SetGeneralLocalization({
	name	= "Sturz der Teufelstotems"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactImpossibleFoe")

L:SetGeneralLocalization({
	name	= "Ein unmöglicher Feind"
})

L:SetMiscLocalization({
	impServants	= "Tötet die Wichteldiener, bevor sie Agatha Energie gewähren!"--needs to be verified (video-captured translation)
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactQueen")

L:SetGeneralLocalization({
	name =	"Zorn der Gottkönigin"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactTwins")

L:SetGeneralLocalization({
	name	= "Zwillinge bezwingen"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactXylem")

L:SetGeneralLocalization({
	name	= "Ein Auge zudrücken"
})