if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

------------------------
-- White Tiger Temple --
------------------------
L = DBM:GetModLocalization("d640")

L:SetMiscLocalization({
	Endless			= "Interminable",
	ReplyWhisper	= "<Deadly Boss Mods> %s está ocupado en el Terreno de Pruebas (%s, oleada %d)."
})

------------------------
-- Mage Tower: TANK --
------------------------
L = DBM:GetModLocalization("Kruul")

L:SetGeneralLocalization({
	name	= "El retorno del Alto Señor"
})

------------------------
-- Mage Tower: Healer --
------------------------
L = DBM:GetModLocalization("ArtifactHealer")

L:SetGeneralLocalization({
	name	= "Fin a la amenaza resucitada"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactFelTotem")

L:SetGeneralLocalization({
	name	= "La caída de los Tótem Vil"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactImpossibleFoe")

L:SetGeneralLocalization({
	name	= "Rival imposible"
})

L:SetMiscLocalization({
	impServants	= "¡Mata a los Sirvientes diablillo antes de que energicen a Agatha!"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactQueen")

L:SetGeneralLocalization({
	name	= "La furia de la Reina diosa"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactTwins")

L:SetGeneralLocalization({
	name	= "Fiasco de los gemelos"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactXylem")

L:SetGeneralLocalization({
	name	= "Cerrar el ojo"
})

------------------------
-- N'Zoth Visions: Stormwind --
------------------------
--L= DBM:GetModLocalization("d1993")

------------------------
-- N'Zoth Visions: Orgrimmar --
------------------------
--L= DBM:GetModLocalization("d1995")
