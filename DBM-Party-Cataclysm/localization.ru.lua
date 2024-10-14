if GetLocale() ~= "ruRU" then return end
local L

-------------------------
--  Blackrock Caverns  --
--------------------------
-- Rom'ogg Bonecrusher --
--------------------------
L= DBM:GetModLocalization(105)

-------------------------------
-- Corla, Herald of Twilight --
-------------------------------
L= DBM:GetModLocalization(106)

L:SetWarningLocalization({
	WarnAdd		= "Помощник освобожден"
})

L:SetOptionLocalization({
	WarnAdd		= "Сообщать, когда на помощнике истекает эффект $spell:75608"
})

-----------------------
-- Karsh SteelBender --
-----------------------
L= DBM:GetModLocalization(107)

L:SetTimerLocalization({
	TimerSuperheated 	= "Перегретая броня (%d)"
})

L:SetOptionLocalization({
	TimerSuperheated	= "Показывать таймер длительности $spell:75846"
})

------------
-- Beauty --
------------
L= DBM:GetModLocalization(108)

-----------------------------
-- Ascendant Lord Obsidius --
-----------------------------
L= DBM:GetModLocalization(109)

---------
--Trash--
---------
L = DBM:GetModLocalization("BlackrockCavernsTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Пещеры Черной горы"
})

---------------------
--  The Deadmines  --
---------------------
-- Glubtok --
-------------
L= DBM:GetModLocalization(89)

-----------------------
-- Helix Gearbreaker --
-----------------------
L= DBM:GetModLocalization(90)

---------------------
-- Foe Reaper 5000 --
---------------------
L= DBM:GetModLocalization(91)

L:SetOptionLocalization{
	HarvestIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88495)
}

----------------------
-- Admiral Ripsnarl --
----------------------
L= DBM:GetModLocalization(92)

----------------------
-- "Captain" Cookie --
----------------------
L= DBM:GetModLocalization(93)

----------------------
-- Vanessa VanCleef --
----------------------
L= DBM:GetModLocalization(95)

L:SetTimerLocalization({
	achievementGauntlet	= "Великое воздаяние"
})

------------------
--  Grim Batol  --
---------------------
-- General Umbriss --
---------------------
L= DBM:GetModLocalization(131)

--------------------------
-- Forgemaster Throngus --
--------------------------
L= DBM:GetModLocalization(132)

-------------------------
-- Drahga Shadowburner --
-------------------------
L= DBM:GetModLocalization(133)

------------
-- Erudax --
------------
L= DBM:GetModLocalization(134)

L = DBM:GetModLocalization("GrimBatolTrash")
L:SetGeneralLocalization({
	name =	"Трэш мобы Грим Батол"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("BoralusTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Боралус"
})

----------------------------
--  Halls of Origination  --
----------------------------
-- Temple Guardian Anhuur --
----------------------------
L= DBM:GetModLocalization(124)

---------------------
-- Earthrager Ptah --
---------------------
L= DBM:GetModLocalization(125)

L:SetMiscLocalization{
	Kill		= "Пта... Больше... Нет..."
}

--------------
-- Anraphet --
--------------
L= DBM:GetModLocalization(126)

L:SetTimerLocalization({
	achievementGauntlet	= "Скорость Света"
})

L:SetMiscLocalization({
	Brann		= "Ага, ну поехали! Осталось ввести последний код для открывания двери...и..."
})

------------
-- Isiset --
------------
L= DBM:GetModLocalization(127)

L:SetWarningLocalization({
	WarnSplitSoon	= "Скоро разделение"
})

L:SetOptionLocalization({
	WarnSplitSoon	= "Предварительное предупреждение о разделении"
})

-------------
-- Ammunae --
-------------
L= DBM:GetModLocalization(128)

-------------
-- Setesh  --
-------------
L= DBM:GetModLocalization(129)

----------
-- Rajh --
----------
L= DBM:GetModLocalization(130)

--------------------------------
--  Lost City of the Tol'vir  --
--------------------------------
-- General Husam --
-------------------
L= DBM:GetModLocalization(117)

--------------
-- Lockmaw --
--------------
L= DBM:GetModLocalization(118)

L:SetOptionLocalization{
	RangeFrame	= "Окно проверки дистанции (5м)"
}

----------
-- Augh --
----------
L = DBM:GetModLocalization("Augh")

L:SetGeneralLocalization({
	name = "Ауг"
})

------------------------
-- High Prophet Barim --
------------------------
L= DBM:GetModLocalization(119)

------------------------------------
-- Siamat, Lord of the South Wind --
------------------------------------
L= DBM:GetModLocalization(122)

L:SetWarningLocalization{
	specWarnPhase2Soon	= "2-я фаза через 5 сек"
}

L:SetOptionLocalization{
	specWarnPhase2Soon	= "Спецпредупреждение перед началом 2-й фазы (5 сек)"
}

-----------------------
--  Shadowfang Keep  --
-----------------------
-- Baron Ashbury --
-------------------
L= DBM:GetModLocalization(96)

-----------------------
-- Baron Silverlaine --
-----------------------
L= DBM:GetModLocalization(97)

--------------------------
-- Commander Springvale --
--------------------------
L= DBM:GetModLocalization(98)

L:SetTimerLocalization({
	TimerAdds		= "След. помощники"
})

L:SetOptionLocalization{
	TimerAdds		= "Показывать таймер для помощников"
}

L:SetMiscLocalization{
	YellAdds		= "Repel the intruders!"
}

-----------------
-- Lord Walden --
-----------------
L= DBM:GetModLocalization(99)

L:SetWarningLocalization{
	specWarnCoagulant	= "Зеленая смесь - двигайтесь!",
	specWarnRedMix		= "Красная смесь - не двигайтесь!"
}

L:SetOptionLocalization{
	RedLightGreenLight	= "Сообщать о красной/зеленой очередности движений"
}

------------------
-- Lord Godfrey --
------------------
L= DBM:GetModLocalization(100)

---------------------
--  The Stonecore  --
---------------------
-- Corborus --
--------------
L= DBM:GetModLocalization(110)

L:SetWarningLocalization({
	WarnEmerge		= "Появление",
	WarnSubmerge	= "Погружение"
})

L:SetTimerLocalization({
	TimerEmerge		= "Появление",
	TimerSubmerge	= "Погружение"
})

L:SetOptionLocalization({
	WarnEmerge		= "Показывать предупреждения о появлении",
	WarnSubmerge	= "Показывать предупреждения о погружении",
	TimerEmerge		= "Показывать таймер до появления",
	TimerSubmerge	= "Показывать таймер до погружения",
	RangeFrame		= "Окно проверки дистанции (5м)"
})

--------------
-- Slabhide --
--------------
L= DBM:GetModLocalization(111)

L:SetWarningLocalization({
	WarnAirphase				= "Воздушная фаза",
	WarnGroundphase				= "Наземная фаза",
	specWarnCrystalStorm		= "Кристальная буря - в укрытие!"
})

L:SetTimerLocalization({
	TimerAirphase				= "След. воздушная фаза",
	TimerGroundphase			= "След. наземная фаза"
})

L:SetOptionLocalization({
	WarnAirphase				= "Предупреждать, когда Камнешкур взлетает",
	WarnGroundphase				= "Предупреждать, когда Камнешкур приземляется",
	TimerAirphase				= "Показывать таймер для следующей воздушной фазы",
	TimerGroundphase			= "Показывать таймер для следующей наземной фазы",
	specWarnCrystalStorm		= "Спецпредупреждение для $spell:92265"
})

-----------
-- Ozruk --
-----------
L= DBM:GetModLocalization(112)

-------------------------
-- High Priestess Azil --
------------------------
L= DBM:GetModLocalization(113)

---------
--Trash--
---------
L = DBM:GetModLocalization("StonecoreTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Каменные Недра"
})

---------------------------
--  The Vortex Pinnacle  --
---------------------------
-- Grand Vizier Ertan --
------------------------
L= DBM:GetModLocalization(114)

L:SetMiscLocalization{
	Retract		= "%s притягивает к себе охранный смерч!"
}

--------------
-- Altairus --
--------------
L= DBM:GetModLocalization(115)

-----------
-- Asaad --
-----------
L= DBM:GetModLocalization(116)

---------
--Trash--
---------
L = DBM:GetModLocalization("VortexPinnacleTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Вершина Смерча"
})

---------------------------
--  The Throne of Tides  --
---------------------------
-- Lady Naz'jar --
------------------
L= DBM:GetModLocalization(101)

-----======-----------
-- Commander Ulthok --
----------------------
L= DBM:GetModLocalization(102)

-------------------------
-- Erunak Stonespeaker --
-------------------------
L= DBM:GetModLocalization(103)

------------
-- Ozumat --
------------
L= DBM:GetModLocalization(104)

L:SetTimerLocalization{
	TimerPhase		= "2-я фаза"
}

L:SetOptionLocalization{
	TimerPhase		= "Показывать таймер для 2-й фазы"
}

---------
--Trash--
---------
L = DBM:GetModLocalization("ThroneofTidesTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Трон Приливов"
})

----------------
--  Zul'Aman  --
----------------
--  Akil'zon --
---------------
L= DBM:GetModLocalization(186)

L:SetOptionLocalization{
	RangeFrame	= "Окно проверки дистанции (10м)"
}

---------------
--  Nalorakk --
---------------
L= DBM:GetModLocalization(187)

L:SetWarningLocalization{
	WarnBear		= "Облик медведя",
	WarnBearSoon	= "Облик медведя через 5 секунд",
	WarnNormal		= "Обычный облик",
	WarnNormalSoon	= "Обычный облик через 5 секунд"
}

L:SetTimerLocalization{
	TimerBear		= "Облик медведя",
	TimerNormal		= "Обычный облик"
}

L:SetOptionLocalization{
	WarnBear		= "Показывать предупреждения для облика медведя",
	WarnBearSoon	= "Показывать предупреждение о скорой смене облика на медвежий",
	WarnNormal		= "Показывать предупреждения для обычного облика",
	WarnNormalSoon	= "Показывать предупреждение о скорой смене облика на обычный",
	TimerBear		= "Показывать таймер облика медведя",
	TimerNormal		= "Показывать таймер обычного облика",
	InfoFrame		= "Показывать игроков с $spell:42402"
}

L:SetMiscLocalization{
	YellBear 		= "Хотели разбудить во мне зверя? Вам это удалось.",
	YellNormal		= "C дороги!",
	PlayerDebuffs	= "С дебаффом"
}

---------------
--  Jan'alai --
---------------
L= DBM:GetModLocalization(188)

L:SetOptionLocalization{
	FlameIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(43140)
}

L:SetMiscLocalization{
	YellBomb	= "Щас я вас сожгу!",
	YellHatchAll= "Я покажу вам… что такое численное превосходство!",
	YellAdds	= "Эй, хранители! Займитесь яйцами!"
}

--------------
--  Halazzi --
--------------
L= DBM:GetModLocalization(189)

L:SetWarningLocalization{
	WarnSpirit	= "Призывает дух",
	WarnNormal	= "Дух исчезает"
}

L:SetOptionLocalization{
	WarnSpirit	= "Показывать предупреждения для фазы духа",
	WarnNormal	= "Показывать предупреждения для обычной фазы "
}

L:SetMiscLocalization{
	YellSpirit	= "Мы с моим духом уничтожим вас!",
	YellNormal	= "Дух мой, вернись ко мне!"
}

-----------------------
-- Hexlord Malacrass --
-----------------------
L= DBM:GetModLocalization(190)

L:SetTimerLocalization{
	TimerSiphon	= "%s: %s"
}

L:SetOptionLocalization{
	TimerSiphon	= "Показывать таймер для $spell:43501"
}

L:SetMiscLocalization{
	YellPull	= "Сегодня духи попируют на славу!"
}

-------------
-- Daakara --
-------------
L= DBM:GetModLocalization(191)

L:SetTimerLocalization{
	timerNextForm	= "Смена формы"
}

L:SetOptionLocalization{
	timerNextForm	= "Отсчет времени до следующей смены формы",
	InfoFrame		= "Показывать игроков, пораженных $spell:42402",
	ThrowIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(43093),
	ClawRageIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(43150)
}

L:SetMiscLocalization{
	PlayerDebuffs	= "Без дебаффа"
}

-----------------
--  Zul'Gurub  --
-----------------
-- High Priest Venoxis --
-------------------------
L= DBM:GetModLocalization(175)

------------------------
-- Bloodlord Mandokir --
------------------------
L= DBM:GetModLocalization(176)

L:SetWarningLocalization{
	WarnRevive		= "Осталось духов: %d",
	SpecWarnOhgan	= "Оган возродился! Убейте его!"
}

L:SetOptionLocalization{
	WarnRevive		= "Показывать количество оставшихся духов",
	SpecWarnOhgan	= "Предупреждение, когда Оган возрождается"
}

----------------------
-- Cache of Madness --
----------------------
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

----------------------------
-- High Priestess Kilnara --
----------------------------
L= DBM:GetModLocalization(181)

------------
-- Zanzil --
------------
L= DBM:GetModLocalization(184)

L:SetWarningLocalization{
	SpecWarnToxic	= "Воспользуйтесь зелёным котлом!"
}

L:SetOptionLocalization{
	SpecWarnToxic	= "Спецпредупреждение, когда на Вас нет $spell:96328",
	InfoFrame		= "Показывать игроков без $spell:96328"
}

L:SetMiscLocalization{
	PlayerDebuffs	= "Без зелёного дебаффа"
}

----------------------------
-- Jindo --
----------------------------
L= DBM:GetModLocalization(185)

L:SetWarningLocalization{
	WarnBarrierDown	= "Барьер над цепями Хаккара снят - осталось %d/3"
}

L:SetOptionLocalization{
	WarnBarrierDown	= "Предупреждение, кода спадает барьер над цепями Хаккара",
	BodySlamIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(97198)
}

L:SetMiscLocalization{
	Kill			= "Ты перешел все границы, Джин'до. Ты играешь с силами, которые тебе неподвластны. Ты забыл, кто я? Забыл, что я могу с тобой сделать?!" -- temporarily
}

----------------
--  End Time  --
-------------------
-- Echo of Baine --
-------------------
L= DBM:GetModLocalization(340)

-------------------
-- Echo of Jaina --
-------------------
L= DBM:GetModLocalization(285)

L:SetTimerLocalization{
	TimerFlarecoreDetonate	= "Взрыв пламенных недр"
}

L:SetOptionLocalization{
	TimerFlarecoreDetonate	= "Отсчет времени до взрыва $spell:101927"
}

----------------------
-- Echo of Sylvanas --
----------------------
L= DBM:GetModLocalization(323)

---------------------
-- Echo of Tyrande --
---------------------
L= DBM:GetModLocalization(283)

--------------
-- Murozond --
--------------
L= DBM:GetModLocalization(289)

L:SetMiscLocalization{
	Kill		= "Что... вы наделали... Аман'тул... Я...видел..."
}

------------------------
--  Well of Eternity  --
------------------------
-- Peroth'arn --
----------------
L= DBM:GetModLocalization(290)

L:SetMiscLocalization{
	Pull		= "Ни один смертный не сможет противостоять мне!"
}

-------------
-- Azshara --
-------------
L= DBM:GetModLocalization(291)

L:SetWarningLocalization{
	WarnAdds	= "Скоро новые помощники"
}

L:SetTimerLocalization{
	TimerAdds	= "Новые помощники"
}

L:SetOptionLocalization{
	WarnAdds	= "Предупреждать о скором появлении новых помощников",
	TimerAdds	= "Отсчет времени до появлении новых помощников"
}

L:SetMiscLocalization{
	Kill		= "Довольно. Хоть я и люблю быть радушной хозяйкой, у меня есть более срочные дела."
}

-----------------------------
-- Mannoroth and Varo'then --
-----------------------------
L= DBM:GetModLocalization(292)

L:SetTimerLocalization{
	TimerTyrandeHelp	= "Тиранде нужна помощь"
}

L:SetOptionLocalization{
	TimerTyrandeHelp	= "Отсчет времени, когда Тиранде нужна помощь"
}

L:SetMiscLocalization{
	Kill		= "Малфурион, у него получилось! Портал разрушается."
}

------------------------
--  Hour of Twilight  --
------------------------
-- Arcurion --
--------------
L= DBM:GetModLocalization(322)

L:SetMiscLocalization{
	Event		= "Покажи себя!",
	Pull		= "На обрывах каньона появляются войска Сумрака."
}

----------------------
-- Asira Dawnslayer --
----------------------
L= DBM:GetModLocalization(342)

L:SetMiscLocalization{
	Pull		= "...ну а теперь перейдем к тебе и стайке твоих неуклюжих друзей. Я уж думала, вы сюда никогда не доберетесь!"
}

---------------------------
-- Archbishop Benedictus --
---------------------------
L= DBM:GetModLocalization(341)

L:SetMiscLocalization{
	Event		= "А теперь, шаман, ты отдашь Душу Дракона МНЕ."
}
