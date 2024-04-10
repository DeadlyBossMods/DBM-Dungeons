if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

-------------------------
-- Cavernas Roca Negra --
-------------------------
--------------------------
-- MachacahuesosRom'ogg --
--------------------------
L= DBM:GetModLocalization(105)

-----------------------------------
-- Corla, Heraldo del Crepúsculo --
-----------------------------------
L= DBM:GetModLocalization(106)

L:SetWarningLocalization({
	WarnAdd		= "Zelote evolucionado"
})

L:SetOptionLocalization({
	WarnAdd		= "Mostrar aviso cuando un zelote pierda el beneficio de $spell:75608"
})

---------------------
-- Karsh Doblacero --
---------------------
L= DBM:GetModLocalization(107)

L:SetTimerLocalization({
	TimerSuperheated 	= "Armadura sobrecalentada (%d)"
})

L:SetOptionLocalization({
	TimerSuperheated	= "Mostrar temporizador para la duración de $spell:75846"
})

-----------
-- Bella --
-----------
L= DBM:GetModLocalization(108)

--------------------------------
-- Señor ascendiente Obsidius --
--------------------------------
L= DBM:GetModLocalization(109)

L:SetOptionLocalization({
	SetIconOnBoss	= "Poner icono en el jefe tras $spell:76200 "
})

------------------------
-- Minas de la Muerte --
------------------------
-------------
-- Glubtok --
-------------
L= DBM:GetModLocalization(89)

--------------------------
-- Helix Rompengranajes --
--------------------------
L= DBM:GetModLocalization(90)

------------------------
-- Siegaenemigos 5000 --
------------------------
L= DBM:GetModLocalization(91)

L:SetOptionLocalization{
	HarvestIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88495)
}

----------------------------
-- Almirante Rasgagruñido --
----------------------------
L= DBM:GetModLocalization(92)

-------------------------
-- "Capitán" Cocinitas --
-------------------------
L= DBM:GetModLocalization(93)

----------------------
-- Vanessa VanCleef --
----------------------
L= DBM:GetModLocalization(95)

L:SetTimerLocalization({
	achievementGauntlet	= "Logro: Vigorosa venganza VanCleef"
})

----------------
-- Grim Batol --
----------------
---------------------
-- General Umbriss --
---------------------
L= DBM:GetModLocalization(131)

-------------------------------
-- Maestro de forja Throngus --
-------------------------------
L= DBM:GetModLocalization(132)

-------------------------
-- Drahga Quemasombras --
-------------------------
L= DBM:GetModLocalization(133)

-------------------------------------------
-- Erudax, el Duque de las profundidades --
-------------------------------------------
L= DBM:GetModLocalization(134)

-------------------------------
--  Cámaras de los Orígenes  --
--------------------------------
-- Guardián del templo Anhuur --
--------------------------------
L= DBM:GetModLocalization(124)

---------------------
-- Terracundo Ptah --
---------------------
L= DBM:GetModLocalization(125)

L:SetMiscLocalization{
	Kill		= "Se... acabaó... Ptah..."
}

--------------
-- Anraphet --
--------------
L= DBM:GetModLocalization(126)

L:SetTimerLocalization({
	achievementGauntlet	= "Logro: Más rápido que la velocidad de la luz"
})

L:SetMiscLocalization({
	Brann				= "¡Bien, vamos! Tan solo me falta introducir la secuencia final en el mecanismo de la puerta... y..."
})

---------------------------------
-- Isiset, Ensamblaje de magia --
---------------------------------
L= DBM:GetModLocalization(127)

L:SetWarningLocalization({
	WarnSplitSoon	= "Reflejos en breve"
})

L:SetOptionLocalization({
	WarnSplitSoon	= "Mostrar aviso previo para Reflejos"
})

---------------------------------
-- Ammunae, Ensamblaje de vida --
---------------------------------
L= DBM:GetModLocalization(128)

----------------------------------------
-- Setesh, Ensamblaje de destrucción  --
----------------------------------------
L= DBM:GetModLocalization(129)

------------------------------
-- Rajh, Ensamblaje del Sol --
------------------------------
L= DBM:GetModLocalization(130)

-----------------------------------
-- Ciudad Perdida de los Tol'vir --
-----------------------------------
-------------------
-- General Husam --
-------------------
L= DBM:GetModLocalization(117)

-----------------
-- Cierrafauce --
-----------------
L= DBM:GetModLocalization(118)

L:SetOptionLocalization{
	RangeFrame	= "Mostrar marco de distancia (5 m)"
}

----------
-- Augh --
----------
L = DBM:GetModLocalization("Augh")

L:SetGeneralLocalization({
	name = "Augh"		-- he is fightable after Lockmaw :o
})

------------------------
-- Sumo profeta Barim --
------------------------
L= DBM:GetModLocalization(119)

------------
-- Siamat --
------------
L= DBM:GetModLocalization(122)

L:SetWarningLocalization{
	specWarnPhase2Soon	= "Fase 2 en 5 s"
}

L:SetOptionLocalization{
	specWarnPhase2Soon	= "Mostrar aviso especial 5 s antes de la fase 2"
}

---------------------------------
-- Castillo de Colmillo Oscuro --
---------------------------------
-------------------
-- Barón Ashbury --
-------------------
L= DBM:GetModLocalization(96)

----------------------
-- Barón Filargenta --
----------------------
L= DBM:GetModLocalization(97)

--------------------------
-- Comandante Vallefont --
--------------------------
L= DBM:GetModLocalization(98)

L:SetTimerLocalization({
	TimerAdds		= "Siguientes esbirros"
})

L:SetOptionLocalization{
	TimerAdds		= "Mostrar temporizador para los siguientes esbirros"
}

L:SetMiscLocalization{
	YellAdds		= "¡Repeled a los instrusos!"
}

-----------------
-- Lord Walden --
-----------------
L= DBM:GetModLocalization(99)

L:SetWarningLocalization{
	specWarnCoagulant	= "Mezcla verde - ¡no te quedes quieto!",	-- Green light
	specWarnRedMix		= "Mezcla roja - ¡quédate quieto!"		-- Red light
}

L:SetOptionLocalization{
	RedLightGreenLight	= "Mostrar aviso especial para los requisitos de movimiento de las mezclas"
}

------------------
-- Lord Godfrey --
------------------
L= DBM:GetModLocalization(100)

----------------------
-- El Núcleo Pétreo --
----------------------
--------------
-- Corborus --
--------------
L= DBM:GetModLocalization(110)

L:SetWarningLocalization({
	WarnEmerge		= "Corborus ha regresado",
	WarnSubmerge	= "Corborus se sumerge"
})

L:SetTimerLocalization({
	TimerEmerge		= "Emersión",
	TimerSubmerge	= "Sumersión"
})

L:SetOptionLocalization({
	WarnEmerge		= "Mostrar aviso cuando Corborus regrese a la superficie",
	WarnSubmerge	= "Mostrar aviso cuando Corborus se sumerja en la tierra",
	TimerEmerge		= "Mostrar temporizador para cuando Corborus regrese a la superficie",
	TimerSubmerge	= "Mostrar temporizador para cuando Corborus se sumerja en la tierra",
	RangeFrame		= "Mostrar marco de distancia (5 m)"
})

----------------
-- Pielpétrea --
----------------
L= DBM:GetModLocalization(111)

L:SetWarningLocalization({
	WarnAirphase			= "Fase aérea",
	WarnGroundphase			= "Fase en tierra",
	specWarnCrystalStorm	= "Tormenta de cristales - ¡ponte a cubierto!"
})

L:SetTimerLocalization({
	TimerAirphase			= "Siguiente fase aérea",
	TimerGroundphase		= "Siguiente fase en tierra"
})

L:SetOptionLocalization({
	WarnAirphase			= "Mostrar aviso cuando Pielpétrea se eleve",
	WarnGroundphase			= "Mostrar aviso cuando Pielpétrea aterrice",
	TimerAirphase			= "Mostrar temporizador para la siguiente fase aérea",
	TimerGroundphase		= "Mostrar temporizador para la siguiente fase en tierra",
	specWarnCrystalStorm	= "Mostrar aviso especial para $spell:92265"
})

-----------
-- Ozruk --
-----------
L= DBM:GetModLocalization(112)

-------------------------
-- Suma sacerdotisa Azil --
------------------------
L= DBM:GetModLocalization(113)

---------------------------
-- La Cumbre del Vórtice --
---------------------------
----------------------
-- Gran visir Ertan --
----------------------
L= DBM:GetModLocalization(114)

L:SetMiscLocalization{
	Retract		= "¡%s retira su Escudo de ciclón!"
}

--------------
-- Altairus --
--------------
L= DBM:GetModLocalization(115)

----------------------------------
-- Asaad, califa de los Céfiros --
----------------------------------
L= DBM:GetModLocalization(116)

---------------------------
--  Trono de las Mareas  --
---------------------------
-- Lady Naz'jar --
------------------
L= DBM:GetModLocalization(101)

-----------------------
-- Comandante Ulthok --
-----------------------
L= DBM:GetModLocalization(102)

---------------------------
-- Dominamentes Ghur'sha --
---------------------------
L= DBM:GetModLocalization(103)

------------
-- Ozumat --
------------
L= DBM:GetModLocalization(104)

L:SetTimerLocalization{
	TimerPhase		= "Fase 2"
}

L:SetOptionLocalization{
	TimerPhase		= "Mostrar temporizador para fase 2"
}

--------------
-- Zul'Aman --
--------------
--------------
-- Akil'zon --
--------------
L= DBM:GetModLocalization(186)

L:SetOptionLocalization{
	RangeFrame	= "Mostrar marco de distancia (10 m)"
}

--------------
-- Nalorakk --
--------------
L= DBM:GetModLocalization(187)

L:SetWarningLocalization{
	WarnBear		= "Forma de oso",
	WarnBearSoon	= "Forma de oso en 5 s",
	WarnNormal		= "Forma normal",
	WarnNormalSoon	= "Forma normal en 5 s"
}

L:SetTimerLocalization{
	TimerBear		= "Forma de oso",
	TimerNormal		= "Forma normal"
}

L:SetOptionLocalization{
	WarnBear		= "Mostrar aviso para forma de oso",
	WarnBearSoon	= "Mostrar aviso previo para forma de oso",
	WarnNormal		= "Mostrar aviso para forma normal",
	WarnNormalSoon	= "Mostrar aviso previo para forma normal",
	TimerBear		= "Mostrar temporizador para forma de oso",
	TimerNormal		= "Mostrar temporizador para forma normal",
	InfoFrame		= "Mostrar marco de información de jugadores afectados por $spell:42402"
}

L:SetMiscLocalization{
	YellBear 		= "¡Si llamáis a la beh'tia, vais a recibir más de lo que eh'peráis!",
	YellNormal		= "¡Dejad paso al Nalorakk!",
	PlayerDebuffs	= "Perjuicio de Oleada"
}

--------------
-- Jan'alai --
--------------
L= DBM:GetModLocalization(188)

L:SetOptionLocalization{
	FlameIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(43140)
}

L:SetMiscLocalization{
	YellBomb	= "¡Ahora os quemaré!",
	YellHatchAll= "Os mostraré la fuerza... con números.",
	YellAdds	= "¿Dónde está mi criador? ¡A por los huevos!"
}

-------------
-- Halazzi --
-------------
L= DBM:GetModLocalization(189)

L:SetWarningLocalization{
	WarnSpirit	= "Fase de espíritu",
	WarnNormal	= "Fase normal"
}

L:SetOptionLocalization{
	WarnSpirit	= "Mostrar aviso para fase de espíritu",
	WarnNormal	= "Mostrar aviso para fase normal"
}

L:SetMiscLocalization{
	YellSpirit	= "Lucho con libertad de eh'píritu...",
	YellNormal	= "¡Eh'píritu, vuelve a mí!"
}

-----------------------------
-- Señor aojador Malacrass --
-----------------------------
L= DBM:GetModLocalization(190)

L:SetTimerLocalization{
	TimerSiphon	= "%s: %s"
}

L:SetOptionLocalization{
	TimerSiphon	= "Mostrar temporizador para $spell:43501"
}

L:SetMiscLocalization{
	YellPull	= "Las sombras caerán sobre vosotros..."
}

-------------
-- Daakara --
-------------
L= DBM:GetModLocalization(191)

L:SetTimerLocalization{
	timerNextForm	= "Siguiente cambio de forma"
}

L:SetOptionLocalization{
	timerNextForm	= "Mostrar temporizador para cambio de forma",
	InfoFrame		= "Mostrar marco de información de jugadores afectados por $spell:42402",
	ThrowIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(43093),
	ClawRageIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(43150)
}

L:SetMiscLocalization{
	PlayerDebuffs	= "Perjuicio de Oleada"
}

---------------
-- Zul'Gurub --
---------------
----------------------------
-- Sumo sacerdote Venoxis --
----------------------------
L= DBM:GetModLocalization(175)

L:SetOptionLocalization{
	SetIconOnToxicLink	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(96477)
}

-------------------------------
-- Señor sangriento Mandokir --
-------------------------------
L= DBM:GetModLocalization(176)

L:SetWarningLocalization{
	WarnRevive		= "Espíritus restantes: %d",
	SpecWarnOhgan	= "¡Ohgan ha resucitado! ¡Atacad ahora!" -- check this, i'm not good at English
}

L:SetOptionLocalization{
	WarnRevive		= "Anunciar el número de espíritus restantes",
	SpecWarnOhgan	= "Mostrar aviso cuando Ohgan resucite" -- check this, i'm not good at English
}

--------------------------
-- Extremo de la Locura --
--------------------------
-------------
-- Gri'lek --
-------------
L= DBM:GetModLocalization(177)

---------------
-- Hazza'rah --
---------------
L= DBM:GetModLocalization(178)

--------------
-- Renataki --
--------------
L= DBM:GetModLocalization(179)

---------------
-- Wushoolay --
---------------
L= DBM:GetModLocalization(180)

------------------------------
-- Suma sacerdotisa Kilnara --
------------------------------
L= DBM:GetModLocalization(181)

------------
-- Zanzil --
------------
L= DBM:GetModLocalization(184)

L:SetWarningLocalization{
	SpecWarnToxic	= "Bebe Tormento tóxico"
}

L:SetOptionLocalization{
	SpecWarnToxic	= "Mostrar aviso especial cuando no te afecte el perjuicio de $spell:96328",
	InfoFrame		= "Mostrar marco de información de jugadores no afectados por $spell:96328",
	SetIconOnGaze	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(96342)
}

L:SetMiscLocalization{
	PlayerDebuffs	= "Sin Tormento tóxico"
}

-----------------------------
-- Jin'do el Sojuzgadioses --
-----------------------------
L= DBM:GetModLocalization(185)

L:SetWarningLocalization{
	WarnBarrierDown	= "Cadenas de Hakkar restantes: %d"
}

L:SetOptionLocalization{
	WarnBarrierDown	= "Anunciar el número de cadenas de Hakkar restantes",
	BodySlamIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(97198)
}

L:SetMiscLocalization{
	Kill			= "Te has pasado de la raya, Jin'do. Juegas con poderes que van más allá de ti. ¿Acaso has olvidado quién soy? ¡¿Es que has olvidado lo que puedo hacer?!"
}

---------------------
-- Fin de los Días --
---------------------
------------------
-- Eco de Baine --
------------------
L= DBM:GetModLocalization(340)

------------------
-- Eco de Jaina --
------------------
L= DBM:GetModLocalization(285)

L:SetTimerLocalization{
	TimerFlarecoreDetonate	= "Bengala del Núcleo explota"
}

L:SetOptionLocalization{
	TimerFlarecoreDetonate	= "Mostrar temporizador para cuando explote $spell:101927"
}

---------------------
-- Eco de Sylvanas --
---------------------
L= DBM:GetModLocalization(323)

--------------------
-- Eco de Tyrande --
--------------------
L= DBM:GetModLocalization(283)

--------------
-- Murozond --
--------------
L= DBM:GetModLocalization(289)

L:SetMiscLocalization{
	Kill		= "No tenéis ni idea de lo que habéis hecho. Aman'Thul... Lo que... he... visto..."
}

--------------------------
-- Pozo de la Eternidad --
--------------------------
----------------
-- Peroth'arn --
----------------
L= DBM:GetModLocalization(290)

L:SetMiscLocalization{
	Pull		= "¡Ningún mortal que se enfrente a mí saldrá con vida!"
}

-------------------
-- Reina Azshara --
-------------------
L= DBM:GetModLocalization(291)

L:SetWarningLocalization{
	WarnAdds	= "Siguientes magos en breve"
}

L:SetTimerLocalization{
	TimerAdds	= "Siguientes magos"
}

L:SetOptionLocalization{
	WarnAdds	= "Anunciar cuando los siguientes magos se unan al combate",
	TimerAdds	= "Mostrar temporizador para los siguientes magos"
}

L:SetMiscLocalization{
	Kill		= "Ya basta. Por mucho que me guste hacer de anfitriona, debo atender asuntos más urgentes."
}

---------------------------
-- Mannoroth y Varo'then --
---------------------------
L= DBM:GetModLocalization(292)

L:SetTimerLocalization{
	TimerTyrandeHelp	= "Tyrande necesita ayuda"
}

L:SetOptionLocalization{
	TimerTyrandeHelp	= "Mostrar temporizador para cuando Tyrande necesite ayude"
}

L:SetMiscLocalization{
	Kill		= "¡Malfurion... lo ha logrado! ¡El portal se desmorona!"
}

-------------------------
-- Hora del Crepúsculo --
-------------------------
--------------
-- Arcurion --
--------------
L= DBM:GetModLocalization(322)

L:SetMiscLocalization{
	Event		= "¡Muéstrate!",
	Pull		= "Las fuerzas Crepusculares comienzan a aparecer en los bordes de los cañones."
}

--------------------------
-- Asira Puñal del Alba --
--------------------------
L= DBM:GetModLocalization(342)

L:SetMiscLocalization{
	Pull		= "... una vez liquidado eso, tú y ese rebaño de torpes amigos tuyos sois los siguientes en mi lista. ¡Mmm, creí que nunca llegarías!"
}

--------------------------
-- Arzobispo Benedictus --
--------------------------
L= DBM:GetModLocalization(341)

L:SetMiscLocalization{
	Event		= "Y ahora, chamán, me entregarás el Alma de dragón."
}
