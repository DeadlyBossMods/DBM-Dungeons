if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

-------------
-- Augurio --
-------------
L = DBM:GetModLocalization("Omen")

L:SetGeneralLocalization({
	name = "Augurio"
})

------------------------------
-- Químicos La Corona, S.L. --
------------------------------
L = DBM:GetModLocalization("d288")

L:SetTimerLocalization{
	HummelActive		= "Hummel entra en combate",
	BaxterActive		= "Baxter entra en combate",
	FryeActive			= "Frye entra en combate"
}

L:SetOptionLocalization({
	TrioActiveTimer		= "Mostrar temporizadores para cuando los apotecarios entren en combate"
})

L:SetMiscLocalization({
	SayCombatStart		= "¿Se han molestado en decirte quién soy y por qué estoy haciendo esto?"
})

-----------
-- Ahune --
-----------
L = DBM:GetModLocalization("d286")

L:SetWarningLocalization({
	Emerged			= "Ahune vuelve a la superficie",
	specWarnAttack	= "Ahune es vulnerable - ¡Ataca ahora!"
})

L:SetTimerLocalization{
	SubmergeTimer = "Sumergir",
	EmergeTimer	 = "Volver a la superficie"
}

L:SetOptionLocalization({
	Emerged			= "Mostrar aviso cuando Ahune vuelva a la superficie",
	specWarnAttack	= "Mostrar aviso especial cuando Ahune se vuelva vulnerable",
	SubmergeTimer	= "Mostrar temporizador para cuando Ahune se sumerja",
	EmergeTimer		= "Mostrar temporizador para cuando Ahune vuelva a la superficie"
})

L:SetMiscLocalization({
	Pull			= "¡La piedra de hielo se ha derretido!"
})

---------------------------
-- Coren Cerveza Temible --
---------------------------
L = DBM:GetModLocalization("d287")

L:SetWarningLocalization({
	specWarnBrew		= "¡Bebe la cerveza antes de que te lance otra!",
	specWarnBrewStun	= "SUGERENCIA: ¡Te han dado! ¡No te olvides de beber la cerveza!"
})

L:SetOptionLocalization({
	specWarnBrew		= "Mostrar aviso especial para $spell:47376",
	specWarnBrewStun	= "Mostrar aviso especial para $spell:47340"
})

L:SetMiscLocalization({
	YellBarrel			= "¡Tengo el barril!"
})

--------------------------
-- Fiesta de la Cerveza --
--------------------------
L = DBM:GetModLocalization("Brew")

L:SetGeneralLocalization({
	name = "Fiesta de la Cerveza"
})

L:SetOptionLocalization({
	NormalizeVolume		 = "Normalizar automáticamente el volumen del canal de sonido de diálogo con el de música cuando estés en una zona de la Fiesta de la Cerveza para que el sonido no sea demasiado molesto"
})

--------------------------
-- El Jinete decapitado --
--------------------------
L = DBM:GetModLocalization("d285")

L:SetWarningLocalization({
	WarnPhase			 	= "Fase %d",
	warnHorsemanSoldiers	= "Calabazas con pulso",
	warnHorsemanHead		= "Cabeza de El jinete decapitado"
})

L:SetOptionLocalization({
	WarnPhase			 	= "Mostrar aviso para cambios de fase",
	warnHorsemanSoldiers	= "Mostrar aviso cuando aparezcan Cabalazas con pulso",
	warnHorsemanHead		= "Mostrar aviso cuando aparezca la Cabeza de El jinete decapitado"
})

L:SetMiscLocalization({
	HorsemanSummon			= "Jinete álzate...",
	HorsemanSoldiers		= "Soldados, alzaos y luchad, tomad vuestro acero. Dad la victoria a este deshonrado caballero."
})

--------------------------
-- Grinch el Abominable --
--------------------------
L = DBM:GetModLocalization("Greench")

L:SetGeneralLocalization({
	name = "Grinch el Abominable"
})

-------------------------------------
-- Flores de paz contra necrófagos --
-------------------------------------
L = DBM:GetModLocalization("PlantsVsZombies")

L:SetGeneralLocalization({
	name = "Flores de paz contra necrófagos"
})

L:SetWarningLocalization({
	warnTotalAdds	= "Total de zombis desde la última oleada gigantesca: %d",
	specWarnWave	= "¡Oleada gigantesca!"
})

L:SetTimerLocalization{
	timerWave	 	= "Siguiente oleada gigantesca"
}

L:SetOptionLocalization({
	warnTotalAdds	= "Anunciar total de zombis entre oleadas gigantescas",
	specWarnWave	= "Mostrar aviso especial cuando comience una oleada gigantesca",
	timerWave		= "Mostrar temporizador para las siguientes oleadas gigantescas"
})

L:SetMiscLocalization({
	MassiveWave	 = "¡Se acerca una gigantesca oleada de zombis!"
})

---------------------------
-- Invasiones demoníacas --
---------------------------
L = DBM:GetModLocalization("DemonInvasions")

L:SetGeneralLocalization({
	name = "Invasiones demoníacas"
})

--------------------------
--	Memories of Azeroth: Burning Crusade	--
--------------------------
L = DBM:GetModLocalization("BCEvent")

L:SetGeneralLocalization({
	name = "MoA: Burning Crusade"
})

--------------------------
--	Memories of Azeroth: Wrath of the Lich King	--
--------------------------
L = DBM:GetModLocalization("WrathEvent")

L:SetGeneralLocalization({
	name = "MoA: WotLK"
})

L:SetMiscLocalization{
	Emerge				= "emerge de la tierra!",
	Burrow				= "se entierra en el suelo!"
}

L:SetOptionLocalization{
	WarnEmerge				= "Mostrar aviso al emerger",
	WarnEmergeSoon			= "Mostrar preaviso antes de emerger",
	WarnSubmerge			= "Mostrar aviso al enterrarse",
	WarnSubmergeSoon		= "Mostrar preaviso antes de enterrarse",
	TimerEmerge				= "Mostrar temporizador para emerger",
	TimerSubmerge		 	= "Mostrar temporizador para enterrarse",
	WarningTeleportNow		= "Mostrar aviso para teletransporte",
	WarningTeleportSoon		= "Mostrar preaviso antes de teletransporte",
	TimerTeleport			= "Mostrar temporizador para teletransporte"
}

--------------------------
--	Memories of Azeroth: Cataclysm	--
--------------------------
L = DBM:GetModLocalization("CataEvent")

L:SetGeneralLocalization({
	name = "MoA: Cataclysm"
})

L:SetWarningLocalization({
	warnSplittingBlow		= "%s en %s",--Nombre de hechizo en ubicación
	warnEngulfingFlame		= "%s en %s"--Nombre de hechizo en ubicación
})

L:SetOptionLocalization({
	warnSplittingBlow		= "Mostrar avisos de ubicación para $spell:98951",
	warnEngulfingFlame		= "Mostrar avisos de ubicación para $spell:99171"
})

--------------------------------------------
--	Jefes de mundo de eventos de Azeroth	--
--------------------------------------------

-- Lord Kazzak (Las Tierras Devastadas)
L = DBM:GetModLocalization("KazzakClassic")

L:SetGeneralLocalization{
	name = "Lord Kazzak"
}

L:SetMiscLocalization({
	Pull = "¡Por la Legión! ¡Por Kil'Jaeden!"
})

-- Azuregos (Azshara)
L = DBM:GetModLocalization("Azuregos")

L:SetGeneralLocalization{
	name = "Azuregos"
}

-- Taerar (Vallefresno)
L = DBM:GetModLocalization("Taerar")

L:SetGeneralLocalization{
	name = "Taerar"
}

-- Ysondre (Feralas)
L = DBM:GetModLocalization("Ysondre")

L:SetGeneralLocalization{
	name = "Ysondre"
}

-- Lethon (Tierras del Interior)
L = DBM:GetModLocalization("Lethon")

L:SetGeneralLocalization{
	name = "Lethon"
}

-- Emeriss (Bosque del Ocaso)
L = DBM:GetModLocalization("Emeriss")

L:SetGeneralLocalization{
	name = "Emeriss"
}

-- Caminante del Destino (Tanaris)
L = DBM:GetModLocalization("DoomwalkerEvent")

L:SetGeneralLocalization{
	name = "Caminante del Destino (Evento)"
}

---------------------------------
--  Ultracañón Pimpampum 5000  --
---------------------------------
L = DBM:GetModLocalization("Cannon")

L:SetGeneralLocalization({
	name = "Ultracañón Pimpampum 5000"
})

-----------------------
--  Golpea al gnoll  --
-----------------------
L = DBM:GetModLocalization("Gnoll")

L:SetGeneralLocalization({
	name = "Golpea al gnoll"
})

L:SetWarningLocalization({
	warnGameOverQuest	= "Has ganado %d de %d puntos posibles",
	warnGameOverNoQuest	= "La partida ha terminado con un total de %d puntos posibles",
	warnGnoll			= "Sale un gnoll",
	warnHogger			= "Sale Hogger",
	specWarnHogger		= "¡Sale Hogger!"
})

L:SetOptionLocalization({
	warnGameOver	= "Anunciar máximo de puntos posibles cuando termine la partida",
	warnGnoll		= "Anunciar cuándo sale un gnoll",
	warnHogger		= "Anunciar cuándo sale Hogger",
	specWarnHogger	= "Mostrar aviso especial cuando salga Hogger"
})

---------------------------------
--  Galería de tiro al blanco  --
---------------------------------
L = DBM:GetModLocalization("Shot")

L:SetGeneralLocalization({
	name = "Galería de tiro al blanco"
})

L:SetOptionLocalization({
	SetBubbles			= "Desactivar automáticamente los bocadillos de chat durante $spell:101871 (se restaurarán al terminar la partida)"
})

--------------------------
--  Batalla de tonques  --
--------------------------
L = DBM:GetModLocalization("Tonks")

L:SetGeneralLocalization({
	name = "Batalla de tonques"
})

-----------------------------------
--  Desafío del pájaro de fuego  --
-----------------------------------
L = DBM:GetModLocalization("Rings")

L:SetGeneralLocalization({
	name = "Desafío del pájaro de fuego"
})

-------------------------------
--  Conejo de la Luna Negra  --
-------------------------------
L = DBM:GetModLocalization("Rabbit")

L:SetGeneralLocalization({
	name = "Conejo de la Luna Negra"
})

------------------
--  Dienteluna  --
------------------
L = DBM:GetModLocalization("Moonfang")

L:SetGeneralLocalization({
	name = "Dienteluna"
})

L:SetWarningLocalization({
	specWarnCallPack		= "Llamar a la manada - ¡Aléjate a más de 40 m de Dienteluna!",
	specWarnMoonfangCurse	= "Maldición de Dienteluna - ¡Aléjate a más de 10 m de Dienteluna!"
})
