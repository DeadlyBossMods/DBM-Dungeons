if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

-------------------------------
-- Templo del Dragón de Jade --
-------------------------------
----------------
-- Sabio Maro --
----------------
L= DBM:GetModLocalization(672)

L:SetOptionLocalization({
	SetIconOnAdds	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format("ej5616")
})

--------------------------
-- Eremita Senda Pétrea --
--------------------------
L= DBM:GetModLocalization(664)

L:SetWarningLocalization({
	SpecWarnIntensity	= "%s en %s (%d)"
})

L:SetOptionLocalization({
	SpecWarnIntensity	= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.stack:format(6, 113315)
})

---------------------------
-- Liu Corazón Llameante --
---------------------------
L= DBM:GetModLocalization(658)

--------------------
-- Sha de la duda --
--------------------
L= DBM:GetModLocalization(335)

---------------------------
-- Cervecería del Trueno --
---------------------------
-------------
-- Ook-Ook --
-------------
L= DBM:GetModLocalization(668)

---------------
-- Saltadizo --
---------------
L= DBM:GetModLocalization(669)

-----------------------
-- Yan-Zhu el Peleón --
-----------------------
L= DBM:GetModLocalization(670)

L:SetWarningLocalization({
	SpecWarnFizzyBubbles	= "Obtén Pompa burbujeante y vuela"
})

L:SetOptionLocalization({
	SpecWarnFizzyBubbles	= "Mostrar aviso especial cuando no estés afectado por el perjuicio de $spell:114459",
	RangeFrame				= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(10, 106546)
})

-----------------------------
-- Monasterio del Shadopan --
-----------------------------
----------------------
-- Gu Golpe Celeste --
----------------------
L= DBM:GetModLocalization(673)

L:SetWarningLocalization({
	warnStaticField	= "%s"
})

L:SetOptionLocalization({
	warnStaticField	= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(106923)
})

------------------------------
-- Maestro Ventisca Algente --
------------------------------
L= DBM:GetModLocalization(657)

L:SetWarningLocalization({
	warnRemainingNovice	= "Novicios restantes: %d"
})

L:SetOptionLocalization({
	warnRemainingNovice	= "Anunciar el número de novicios restantes"
})

L:SetMiscLocalization({
	NovicesPulled	= "¡Vosotros habéis permitido que los sha despierten, después de todos estos años!",
	NovicesDefeated = "Habéis superado a mis pupilos más inexpertos. Ahora os las veréis con dos de los más veteranos.",
--	Defeat			= "I am bested.  Give me a moment and we will venture forth together to face the Sha."
})

-------------------------
-- Sha de la violencia --
-------------------------
L= DBM:GetModLocalization(685)

L:SetMiscLocalization({
	Kill		= "Siempre que la violencia anide en vuestros corazones... volveré..."
})

---------------
-- Taran Zhu --
---------------
L= DBM:GetModLocalization(686)

L:SetOptionLocalization({
	InfoFrame			= "Mostrar marco de información para $journal:5827"
})

-----------------------------
-- Puerta del Sol Poniente --
-----------------------------
--------------------------
-- Saboteador Kip'tilak --
--------------------------
L= DBM:GetModLocalization(655)

L:SetOptionLocalization({
	IconOnSabotage	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(107268)
})

----------------------
-- Asediador Ga'dok --
----------------------
L= DBM:GetModLocalization(675)

L:SetMiscLocalization({
	StaffingRun		= "¡Asediador Ga'dok se prepara para un bombardeo!"
})

-----------------------
-- Comandante Ri'mok --
-----------------------
L= DBM:GetModLocalization(676)

-------------
-- Raigonn --
-------------
L= DBM:GetModLocalization(649)

-----------------------
-- Palacio Mogu'shan --
-----------------------
--------------------
-- Prueba del Rey --
--------------------
L= DBM:GetModLocalization(708)

L:SetMiscLocalization({
	Pull		= "¡Inútiles! ¡Todos! Ni los guardias que me ofrecéis como tributo pueden impedir que entren gusanos en mi palacio.",
	Kuai		= "¡El clan Gurthan demostrará al Rey y a los impostores sedientos de poder como vosotros por qué merecemos su confianza!",
	Ming		= "¡El clan Harthak os demostrará por qué somos los más puros de los mogu!",
	Haiyan		= "¡El clan Kargesh os demostrará por qué solo los más fuertes merecen servir al Rey!",
	Defeat		= "¿Quién ha dejado entrar a los forasteros? ¡Solo los clanes Harthak o Kargesh se rebajarían a cometer tal traición!"
})

------------
-- Gekkan --
------------
L= DBM:GetModLocalization(690)

------------------------------
-- Xin, el Maestro de armas --
------------------------------
L= DBM:GetModLocalization(698)

---------------------------------
-- Asedio del Templo de Niuzao --
---------------------------------
-------------------
-- Visir Jin'bak --
-------------------
L= DBM:GetModLocalization(693)

-----------------------
-- Comandante Vo'jak --
-----------------------
L= DBM:GetModLocalization(738)

L:SetTimerLocalization({
	TimerWave	= "Siguiente oleada: %s"
})

L:SetOptionLocalization({
	TimerWave	= "Mostrar temporizador para la siguiente oleada de esbirros"
})

L:SetMiscLocalization({
	WaveStart	= "¡Necios! ¿Atacáis frontalmente al ejército mántide? ¡Vuestras muertes serán rápidas!"
})

----------------------
-- General Pa'valak --
----------------------
L= DBM:GetModLocalization(692)

---------------------------------
-- Líder de escuadrón Ner'onok --
---------------------------------
L= DBM:GetModLocalization(727)

-----------------
-- Scholomance --
-----------------
--------------------------------
-- Instructora Corazón Álgido --
--------------------------------
L= DBM:GetModLocalization(659)

-------------------
-- Jandice Barov --
-------------------
L= DBM:GetModLocalization(663)

------------------
-- Traquesangre --
------------------
L= DBM:GetModLocalization(665)

L:SetWarningLocalization({
	SpecWarnGetBoned	= "Obtén Armadura ósea",
	SpecWarnDoctor		= "¡El doctor ha llegado!"
})

L:SetOptionLocalization({
	SpecWarnGetBoned	= "Mostrar aviso especial cuando no estés afectado por el perjuicio de $spell:113996",
	SpecWarnDoctor		= "Mostrar aviso especial si aparece el Doctor Theolen Krastinov",
	InfoFrame			= "Mostrar marco de información de jugadores no afectados por $spell:113996"
})

L:SetMiscLocalization({
	PlayerDebuffs	= "Sin Armadura ósea",
	TheolenSpawn	= "¡El doctor ha llegado!"
})

------------------
-- Lillian Voss --
------------------
L= DBM:GetModLocalization(666)

L:SetMiscLocalization({
	Kill	= "¡MUERE, NIGROMANTE!"
})

-----------------------------
-- Maestro oscuro Gandling --
-----------------------------
L= DBM:GetModLocalization(684)

-----------------------
-- Cámaras Escarlata --
-----------------------
----------------------------
-- Maestro de canes Braun --
----------------------------
L= DBM:GetModLocalization(660)

-----------------------------
-- Maestor de armas Harlan --
-----------------------------
L= DBM:GetModLocalization(654)

------------------------------
-- Tejedor de fuego Koegler --
------------------------------
L= DBM:GetModLocalization(656)

--------------------------
-- Monasterio Escarlata --
--------------------------
-------------
-- Thalnos --
-------------
L= DBM:GetModLocalization(688)

--------------------
-- Hermano Korlof --
--------------------
L= DBM:GetModLocalization(671)

L:SetOptionLocalization({
	KickArrow	= "Mostrar flecha cuando $spell:114487 ocurra cerca de ti"
})

------------------
-- Melenablanca --
------------------
L= DBM:GetModLocalization(674)
