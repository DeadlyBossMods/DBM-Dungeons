if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

local L
local isSpanishMX = GetLocale() == "esMX"

L = DBM:GetModLocalization("InfiltratorGulkat")
L:SetGeneralLocalization({
	name = "Infiltrado Gulkat"
})

L = DBM:GetModLocalization("BladeMasterDarza")
L:SetGeneralLocalization({
	name = "Maestra del acero Darza"
})

L = DBM:GetModLocalization("SpiritflayerJinma")
L:SetGeneralLocalization({
	name = isSpanishMX and "Rasgaespíritus Jin'Ma" or "Fustigaespíritus Jin'Ma"
})

L = DBM:GetModLocalization("Mycomight")
L:SetGeneralLocalization({
	name = isSpanishMX and "Micosupremo" or "Micominencia"
})

L = DBM:GetModLocalization("SpinshroomMid")
L:SetGeneralLocalization({
	name = isSpanishMX and "Champizote" or "Tejepiñón"
})

L = DBM:GetModLocalization("Brightthorn")
L:SetGeneralLocalization({
	name = isSpanishMX and "Cornobrillo" or "Espinabrillante"
})

L = DBM:GetModLocalization("MulthAul")
L:SetGeneralLocalization({
	name = "Mul'tha'ul"
})

L = DBM:GetModLocalization("Lumenia")
L:SetGeneralLocalization({
	name = "Lumenia"
})

L = DBM:GetModLocalization("GladiusSlaurna")
L:SetGeneralLocalization({
	name = "Gladius Slaurna"
})

L = DBM:GetModLocalization("EsuritusParhelion")
L:SetGeneralLocalization({
	name = "Esuritus"
})

L = DBM:GetModLocalization("Hydrangea")
L:SetGeneralLocalization({
	name = isSpanishMX and "Hydrangea" or "Hortensia"
})

L = DBM:GetModLocalization("VoidScornedVagrant")
L:SetGeneralLocalization({
	name = isSpanishMX and "Vagante desdeñado por el Vacío" or "Vagante rechazado por el Vacío"
})

L = DBM:GetModLocalization("InfiltratorGarand")
L:SetGeneralLocalization({
	name = "Infiltrado Garand"
})

L = DBM:GetModLocalization("Antenorian")
L:SetGeneralLocalization({
	name = "Antenorian"
})

L = DBM:GetModLocalization("ChiefArcanistPatram")
L:SetGeneralLocalization({
	name = isSpanishMX and "Jefe arcanista Patram" or "Arcanista jefe Patram"
})

L = DBM:GetModLocalization("EsuritusSunkiller")
L:SetGeneralLocalization({
	name = "Esuritus"
})

L = DBM:GetModLocalization("Nullaeus")
L:SetGeneralLocalization({
	name = isSpanishMX and "Nullaeus" or "Anulleus"
})

L = DBM:GetModLocalization("Aztarec")
L:SetGeneralLocalization({
	name = "Azta'rec"
})

L = DBM:GetModLocalization("Junala")
L:SetGeneralLocalization({
	name = "Jun'ala"
})

L = DBM:GetModLocalization("SulliedRevenant")
L:SetGeneralLocalization({
	name = "Aparecido mancillado"
})

L = DBM:GetModLocalization("ShaKuro")
L:SetGeneralLocalization({
	name = "Sha'Kuro"
})

L = DBM:GetModLocalization("Kindojan")
L:SetGeneralLocalization({
	name = isSpanishMX and "Kindo'Jan" or "Kindo'jan"
})

L = DBM:GetModLocalization("DenZara")
L:SetGeneralLocalization({
	name = "Den'Zara"
})

L = DBM:GetModLocalization("DrillSergeant")
L:SetGeneralLocalization({
	name = "Sargento de maniobras"
})

L = DBM:GetModLocalization("TheUndeadTrollbunal")
L:SetGeneralLocalization({
	name = "El trolbunal no-muerto"
})

L = DBM:GetModLocalization("Grukk")
L:SetGeneralLocalization({
	name = "Grukk"
})

L = DBM:GetModLocalization("TreasureHunterTaltrois")
L:SetGeneralLocalization({
	name = "Cazatesoros Taltrois"
})

L = DBM:GetModLocalization("ShadowhunterJodin")
L:SetGeneralLocalization({
	name = isSpanishMX and "Cazasombras Jo'din" or "Cazador de las Sombras Jo'zin"
})

L = DBM:GetModLocalization("KingofSouls")
L:SetGeneralLocalization({
	name = "Rey de almas"
})

L = DBM:GetModLocalization("CynthraButtonsmasher")
L:SetGeneralLocalization({
	name = isSpanishMX and "Cynthra Machacabotones" or "Machacabotones Cynthra"
})

L = DBM:GetModLocalization("ReplicatingVenomborne")
L:SetGeneralLocalization({
	name = isSpanishMX and "Portaveneno replicante" or "Venenonato replicante"
})

L = DBM:GetModLocalization("DiscipleofVashnik")
L:SetGeneralLocalization({
	name = "Discípulo de Vashnik"
})

L = DBM:GetModLocalization("RitualPillar")
L:SetGeneralLocalization({
	name = isSpanishMX and "Pilar de ritual" or "Pilar ritual"
})

L = DBM:GetModLocalization("AppallingPotadpolastrophy")
L:SetGeneralLocalization({
	name = isSpanishMX and "Papacuajostrofia horripilante" or "Renacuatatatrofia espantosa"
})

L = DBM:GetModLocalization("GralkaSnakeEater")
L:SetGeneralLocalization({
	name = isSpanishMX and "Gralka devoraserpientes" or "Gralka Comeserpientes"
})

L = DBM:GetModLocalization("OsseousAmalgamation")
L:SetGeneralLocalization({
	name = "Amalgama ósea"
})

L = DBM:GetModLocalization("Gnok")
L:SetGeneralLocalization({
	name = isSpanishMX and "Gtoc" or "Gnok"
})

L = DBM:GetModLocalization("Drakta")
L:SetGeneralLocalization({
	name = "Drakta, héroe de la arena"
})

L = DBM:GetModLocalization("Tarembe")
L:SetGeneralLocalization({
	name = "Tarem'be"
})
