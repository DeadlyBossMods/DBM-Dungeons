if GetLocale() ~= "ruRU" then return end
local L

----------------------------------
--  Ahn'Kahet: The Old Kingdom  --
----------------------------------
--  Prince Taldaram  --
-----------------------
L = DBM:GetModLocalization(581)

L:SetGeneralLocalization{
	name 		= "Принц Талдарам"
}

-------------------
--  Elder Nadox  --
-------------------
L = DBM:GetModLocalization(580)

L:SetGeneralLocalization{
	name 		= "Старейшина Надокс"
}

---------------------------
--  Jedoga Shadowseeker  --
---------------------------
L = DBM:GetModLocalization(582)

L:SetGeneralLocalization{
	name 		= "Джедога Искательница Теней"
}

---------------------
--  Herald Volazj  --
---------------------
L = DBM:GetModLocalization(584)

L:SetGeneralLocalization{
	name 		= "Глашатай Волаж"
}

----------------
--  Amanitar  --
----------------
L = DBM:GetModLocalization(583)

L:SetGeneralLocalization{
	name 		= "Аманитар"
}

-------------------
--  Azjol-Nerub  --
---------------------------------
--  Krik'thir the Gatewatcher  --
---------------------------------
L = DBM:GetModLocalization(585)

L:SetGeneralLocalization{
	name 		= "Крик'тир Хранитель Врат"
}

----------------
--  Hadronox  --
----------------
L = DBM:GetModLocalization(586)

L:SetGeneralLocalization{
	name 		= "Хадронокс"
}

-------------------------
--  Anub'arak (Party)  --
-------------------------
L = DBM:GetModLocalization(587)

L:SetGeneralLocalization{
	name 		= "Ануб'арак (подземелье)"
}

---------------------------------------
--  Caverns of Time: Old Stratholme  --
---------------------------------------
--  Meathook  --
----------------
L = DBM:GetModLocalization(611)

L:SetGeneralLocalization{
	name 		= "Мясной Крюк"
}

--------------------------------
--  Salramm the Fleshcrafter  --
--------------------------------
L = DBM:GetModLocalization(612)

L:SetGeneralLocalization{
	name 		= "Салрамм Плоторез"
}

-------------------------
--  Chrono-Lord Epoch  --
-------------------------
L = DBM:GetModLocalization(613)

L:SetGeneralLocalization{
	name 		= "Хронолорд Эпох"
}

-----------------
--  Mal'Ganis  --
-----------------
L = DBM:GetModLocalization(614)

L:SetGeneralLocalization{
	name 		= "Мал'Ганис"
}

L:SetMiscLocalization({
	Outro	= "Твое путешествие начинается, юный принц. Собирай свои войска и отправляйся в царство вечных снегов, в Нордскол. Там мы и уладим все наши дела, там ты узнаешь свою судьбу."
})

-------------------
--  Wave Timers  --
-------------------
L = DBM:GetModLocalization("StratWaves")

L:SetGeneralLocalization({
	name = "Волны Стратхольма"
})

L:SetWarningLocalization({
	WarningWaveNow = "Волна %d: призыв %s"
})

L:SetTimerLocalization({
	TimerWaveIn		= "Следующая волна (6)",
	TimerRoleplay	= "Ролевая игра"
})

L:SetOptionLocalization({
	WarningWaveNow	= "Показывать предупреждение о новой волне",
	TimerWaveIn		= "Отсчет времени до cледующей волны (после 5-й волны босса)",
	TimerRoleplay	= "Отсчет времени до Ролевой игры"
})

L:SetMiscLocalization({
	Devouring	= "Всепожирающий вурдалак",
	Enraged		= "Разъярившийся вурдалак",
	Necro		= "Некромант",
	Fiend		= "Некрорахнид",
	Stalker		= "Кладбищенский ловец",
	Abom		= "Лоскутное создание",
	Acolyte		= "Послушник",
	Wave1		= "%d %s",
	Wave2		= "%d %s и %d %s",
	Wave3		= "%d %s, %d %s и %d %s",
	Wave4		= "%d %s, %d %s, %d %s и %d %s",
	WaveBoss	= "%s",
	Roleplay	= "Я рад, что ты пришел, Утер!",
	Roleplay2	= "Похоже, все готовы. Помните, эти люди заражены чумой и скоро умрут. Мы должны очистить Стратхольм и защитить Лордерон от Плети. Вперед."
})

------------------------
--  Drak'Tharon Keep  --
------------------------
--  Trollgore  --
-----------------
L = DBM:GetModLocalization(588)

L:SetGeneralLocalization{
	name 		= "Кровотролль"
}

--------------------------
--  Novos the Summoner  --
--------------------------
L = DBM:GetModLocalization(589)

L:SetGeneralLocalization{
	name 		= "Новос Призыватель"
}

L:SetMiscLocalization({
	YellPull		= "Вам холодно? Это дыхание скорой смерти.",
	HandlerYell		= "Защищайте меня! Быстрее, будьте вы прокляты!",
	Phase2			= "Неужели вы не понимаете всей бесполезности происходящего?",
	YellKill		= "Ваши усилия... напрасны."
})

-----------------
--  King Dred  --
-----------------
L = DBM:GetModLocalization(590)

L:SetGeneralLocalization{
	name 		= "Король Дред"
}

-----------------------------
--  The Prophet Tharon'ja  --
-----------------------------
L = DBM:GetModLocalization(591)

L:SetGeneralLocalization{
	name 		= "Пророк Тарон'джа"
}

---------------
--  Gundrak  --
----------------
--  Slad'ran  --
----------------
L = DBM:GetModLocalization(592)

L:SetGeneralLocalization{
	name 		= "Слад'ран"
}

---------------
--  Moorabi  --
---------------
L = DBM:GetModLocalization(594)

L:SetGeneralLocalization{
	name 		= "Мураби"
}

-------------------------
--  Drakkari Colossus  --
-------------------------
L = DBM:GetModLocalization(593)

L:SetGeneralLocalization{
	name 		= "Колосс Драккари"
}

-----------------
--  Gal'darah  --
-----------------
L = DBM:GetModLocalization(596)

L:SetGeneralLocalization{
	name 		= "Гал'дара"
}

-------------------------
--  Eck the Ferocious  --
-------------------------
L = DBM:GetModLocalization(595)

L:SetGeneralLocalization{
	name 		= "Эк Свирепый"
}

--------------------------
--  Halls of Lightning  --
--------------------------
--  General Bjarngrim  --
-------------------------
L = DBM:GetModLocalization(597)

L:SetGeneralLocalization{
	name 		= "Генерал Бьярнгрин"
}

-------------
--  Ionar  --
-------------
L = DBM:GetModLocalization(599)

L:SetGeneralLocalization{
	name 		= "Ионар"
}

---------------
--  Volkhan  --
---------------
L = DBM:GetModLocalization(598)

L:SetGeneralLocalization{
	name 		= "Волхан"
}

-------------
--  Loken  --
-------------
L = DBM:GetModLocalization(600)

L:SetGeneralLocalization{
	name 		= "Локен"
}

----------------------
--  Halls of Stone  --
-----------------------
--  Maiden of Grief  --
-----------------------
L = DBM:GetModLocalization(605)

L:SetGeneralLocalization{
	name 		= "Дева Скорби"
}

------------------
--  Krystallus  --
------------------
L = DBM:GetModLocalization(604)

L:SetGeneralLocalization{
	name 		= "Кристаллус"
}

------------------------------
--  Sjonnir the Ironshaper  --
------------------------------
L = DBM:GetModLocalization(607)

L:SetGeneralLocalization{
	name 		= "Сьоннир Литейщик"
}

--------------------------------------
--  Brann Bronzebeard Escort Event  --
--------------------------------------
L = DBM:GetModLocalization(606)

L:SetGeneralLocalization{
	name 		= "Событие Бранна"
}

L:SetWarningLocalization({
	WarningPhase	= "Фаза %d"
})

L:SetTimerLocalization({
	timerEvent	= "Оставшееся время"
})

L:SetOptionLocalization({
	WarningPhase	= "Показывать предупреждение о смене фазы",
	timerEvent		= "Показывать таймер длительности события"
})

L:SetMiscLocalization({
	Pull	= "Теперь будьте внимательны! Не успеете и глазом моргнуть, как...",
	Phase1	= "Обнаружено вторжение в систему. Приоритетность работ по анализу исторических архивов понижена. Ответные меры инициированы.",
	Phase2	= "Порог допустимой угрозы превышен. Астрономический архив отключен. Уровень безопасности повышен.",
	Phase3	= "Критическое значение уровня угрозы. Перенаправление анализа Бездны. Инициирование протокола очищения.",
	Kill	= "Внимание: меры предосторожности деактивированы. Начинаю стирание памяти и..."
})

-----------------
--  The Nexus  --
-----------------
--  Anomalus  --
----------------
L = DBM:GetModLocalization(619)

L:SetGeneralLocalization{
	name 		= "Аномалус"
}

-------------------------------
--  Ormorok the Tree-Shaper  --
-------------------------------
L = DBM:GetModLocalization(620)

L:SetGeneralLocalization{
	name 		= "Орморок Воспитатель Дерев"
}

----------------------------
--  Grand Magus Telestra  --
----------------------------
L = DBM:GetModLocalization(618)

L:SetGeneralLocalization{
	name 		= "Великая ведунья Телестра"
}

L:SetMiscLocalization({
	SplitTrigger1		= "Меня на вас хватит!",
	SplitTrigger2		= "Вы получите больше, чем заслуживаете!"
})

-------------------
--  Keristrasza  --
-------------------
L = DBM:GetModLocalization(621)

L:SetGeneralLocalization{
	name 		= "Керистраза"
}

-----------------------------------
--  Commander Kolurg/Stoutbeard  --
-----------------------------------
L = DBM:GetModLocalization("Commander")

local commander = "Неизвестный"
if UnitFactionGroup("player") == "Alliance" then
	commander = "Командир Колург"
elseif UnitFactionGroup("player") == "Horde" then
	commander = "Командир Пивобород"
end

L:SetGeneralLocalization({
	name = commander
})

------------------
--  The Oculus  --
-------------------------------
--  Drakos the Interrogator  --
-------------------------------
L = DBM:GetModLocalization(622)

L:SetGeneralLocalization{
	name 		= "Дракос Дознаватель"
}

L:SetOptionLocalization({
	MakeitCountTimer	= "Отсчет времени до \"Вам всем зачтется\" (достижение)"
})

L:SetMiscLocalization({
	MakeitCountTimer	= "Вам всем зачтется"
})

----------------------
--  Mage-Lord Urom  --
----------------------
L = DBM:GetModLocalization(624)

L:SetGeneralLocalization{
	name 		= "Маг-лорд Уром"
}

L:SetMiscLocalization({
	CombatStart		= "Несчастные слепые глупцы!"
})

--------------------------
--  Varos Cloudstrider  --
--------------------------
L = DBM:GetModLocalization(623)

L:SetGeneralLocalization{
	name 		= "Варос Заоблачный Странник"
}

---------------------------
--  Ley-Guardian Eregos  --
---------------------------
L = DBM:GetModLocalization(625)

L:SetGeneralLocalization{
	name 		= "Хранитель энергии Эрегос"
}

L:SetMiscLocalization({
	MakeitCountTimer	= "Вам всем зачтется"
})

--------------------
--  Utgarde Keep  --
-----------------------
--  Prince Keleseth  --
-----------------------
L = DBM:GetModLocalization(638)

L:SetGeneralLocalization{
	name 		= "Принц Келесет"
}

--------------------------------
--  Skarvald the Constructor  --
--  & Dalronn the Controller  --
--------------------------------
L = DBM:GetModLocalization(639)

L:SetGeneralLocalization{
	name 		= "Скарвальд и Далронн"
}

----------------------------
--  Ingvar the Plunderer  --
----------------------------
L = DBM:GetModLocalization(640)

L:SetGeneralLocalization{
	name 		= "Ингвар Расхититель"
}

L:SetMiscLocalization({
	YellCombatEnd	= "Нет! Я смогу это сделать... я смогу..."
})

------------------------
--  Utgarde Pinnacle  --
--------------------------
--  Skadi the Ruthless  --
--------------------------
L = DBM:GetModLocalization(643)

L:SetGeneralLocalization{
	name 		= "Скади Безжалостный"
}

L:SetMiscLocalization({
	CombatStart		= "Что за недоноски осмелились вторгнуться сюда? Поживее, братья мои! Угощение тому, кто принесет мне их головы!",
	Phase2			= "Ничтожные лакеи! Ваши трупы послужат хорошей закуской для моего нового дракона!"
})

-------------------
--  King Ymiron  --
-------------------
L = DBM:GetModLocalization(644)

L:SetGeneralLocalization{
	name 		= "Король Имирон"
}

-------------------------
--  Svala Sorrowgrave  --
-------------------------
L = DBM:GetModLocalization(641)

L:SetGeneralLocalization{
	name 		= "Свала Вечноскорбящая"
}

L:SetTimerLocalization({
	timerRoleplay		= "Свала Вечноскорбящая активируется"
})

L:SetOptionLocalization({
	timerRoleplay		= "Отсчет времени до ролевой игры перед активацией Свалы Вечноскорбящей"
})

L:SetMiscLocalization({
	SvalaRoleplayStart	= "Мой господин! Я сделала, как вы велели, и теперь молю вас о благословении!"
})

-----------------------
--  Gortok Palehoof  --
-----------------------
L = DBM:GetModLocalization(642)

L:SetGeneralLocalization{
	name 		= "Горток Бледное Копыто"
}

-----------------------
--  The Violet Hold  --
-----------------------
--  Cyanigosa  --
-----------------
L = DBM:GetModLocalization(632)

L:SetGeneralLocalization{
	name 		= "Синигоса"
}

L:SetMiscLocalization({
	CyanArrived	= "Вы доблестно обороняетесь, но этот город должен быть стерт с лица земли, и я лично исполню волю Малигоса!"
})

--------------
--  Erekem  --
--------------
L = DBM:GetModLocalization(626)

L:SetGeneralLocalization{
	name 		= "Эрекем"
}

---------------
--  Ichoron  --
---------------
L = DBM:GetModLocalization(628)

L:SetGeneralLocalization{
	name 		= "Гнойрон"
}

-----------------
--  Lavanthor  --
-----------------
L = DBM:GetModLocalization(630)

L:SetGeneralLocalization{
	name 		= "Лавантор"
}

--------------
--  Moragg  --
--------------
L = DBM:GetModLocalization(627)

L:SetGeneralLocalization{
	name 		= "Морагг"
}

--------------
--  Xevozz  --
--------------
L = DBM:GetModLocalization(629)

L:SetGeneralLocalization{
	name 		= "Ксевозз"
}

-------------------------------
--  Zuramat the Obliterator  --
-------------------------------
L = DBM:GetModLocalization(631)

L:SetGeneralLocalization{
	name 		= "Зурамат Уничтожитель"
}

---------------------
--  Portal Timers  --
---------------------
L = DBM:GetModLocalization("PortalTimers")

L:SetGeneralLocalization({
	name = "Таймеры порталов"
})

L:SetWarningLocalization({
	WarningPortalSoon	= "Скоро новый портал",
	WarningPortalNow	= "Портал #%d",
	WarningBossNow		= "Прибытие Босса"
})

L:SetTimerLocalization({
	TimerPortalIn	= "Портал #%d" ,
})

L:SetOptionLocalization({
	WarningPortalNow		= "Показывать предупреждение о новом портале",
	WarningPortalSoon		= "Заранее предупреждать о новом портале",
	WarningBossNow			= "Показывать предупреждение о появлении босса",
	TimerPortalIn			= "Отсчет времени до следующего портала (после босса)",
	ShowAllPortalTimers		= "Отсчет времени для всех порталов (неточно)"
})

L:SetMiscLocalization({
	Sealbroken	= "Мы прорвались через тюремные ворота! Дорога в Даларан открыта! Теперь мы, наконец, прекратим войну Нексуса!"
})

-----------------------------
--  Trial of the Champion  --
-----------------------------
--  The Black Knight  --
------------------------
L = DBM:GetModLocalization(637)

L:SetGeneralLocalization{
	name 		= "Черный рыцарь"
}

L:SetMiscLocalization({
	Pull				= "Великолепно. Сегодня вы в честной борьбе заслужили…",
	YellCombatEnd		= "Нет! Я не могу... снова... проиграть."
})

-----------------------
--  Grand Champions  --
-----------------------
L = DBM:GetModLocalization(634)

L:SetGeneralLocalization{
	name 		= "Испытание чемпиона"
}

L:SetMiscLocalization({
	YellCombatEnd	= "Вы отлично сражались! Следующим испытанием станет битва с одним из членов Авангарда. Вы проверите свои силы в схватке с достойным соперником."
})

----------------------------------
--  Argent Confessor Paletress  --
----------------------------------
L = DBM:GetModLocalization(636)

L:SetGeneralLocalization{
	name 		= "Исповедница Серебряного Авангарда Пейлтресс"
}

L:SetMiscLocalization({
	YellCombatEnd	= "Отличная работа!"
})

-----------------------
--  Eadric the Pure  --
-----------------------
L = DBM:GetModLocalization(635)

L:SetGeneralLocalization{
	name 		= "Эдрик Чистый"
}

L:SetMiscLocalization({
	YellCombatEnd	= "Я сдаюсь! Я побежден. Отличная работа. Можно теперь убегать?"
})

--------------------
--  Pit of Saron  --
---------------------
--  Ick and Krick  --
---------------------
L = DBM:GetModLocalization(609)

L:SetGeneralLocalization{
	name 		= "Ик и Крик"
}

L:SetMiscLocalization({
	Barrage	= "%s начинает быстро создавать взрывающиеся снаряды."
})

----------------------------
--  Forgemaster Garfrost  --
----------------------------
L = DBM:GetModLocalization(608)

L:SetGeneralLocalization{
	name 		= "Начальник кузни Гархлад"
}

L:SetMiscLocalization({
	SaroniteRockThrow	= "%s швыряет в вас глыбой саронита!"
})

----------------------------
--  Scourgelord Tyrannus  --
----------------------------
L = DBM:GetModLocalization(610)

L:SetGeneralLocalization{
	name 		= "Повелитель Плети Тираний"
}

L:SetMiscLocalization({
	CombatStart	= "Увы, бесстрашные герои, ваша навязчивость ускорила развязку. Вы слышите громыхание костей и скрежет стали за вашими спинами? Это предвестники скорой погибели.",
	HoarfrostTarget	= "Ледяной змей Иней смотрит на (%S+), готовя морозную атаку!",
	YellCombatEnd	= "Не может быть... Иней... Предупреди..."
})

----------------------
--  Forge of Souls  --
----------------------
--  Bronjahm  --
----------------
L = DBM:GetModLocalization(615)

L:SetGeneralLocalization{
	name 		= "Броньям"
}

-------------------------
--  Devourer of Souls  --
-------------------------
L = DBM:GetModLocalization(616)

L:SetGeneralLocalization{
	name 		= "Пожиратель Душ"
}

---------------------------
--  Halls of Reflection  --
---------------------------
--  Wave Timers  --
-------------------
L = DBM:GetModLocalization("HoRWaveTimer")

L:SetGeneralLocalization({
	name = "Таймеры волн"
})

L:SetWarningLocalization({
	WarnNewWaveSoon	= "Скоро новая волна",
	WarnNewWave		= "%s вступает в бой"
})

L:SetTimerLocalization({
	TimerNextWave	= "След. Волна"
})

L:SetOptionLocalization({
	WarnNewWave			= "Показывать предупреждение о вступлении босса в бой",
	WarnNewWaveSoon		= "Заранее предупреждать о новой волне (после 5-й волны босса)",
	ShowAllWaveWarnings	= "Показывать предупреждения для всех волн",
	TimerNextWave		= "Отсчет времени до следующей волны (после 5-й волны босса)",
	ShowAllWaveTimers	= "Заранее предупреждать и отсчитывать время для всех волн (неточно)"
})

--------------
--  Falric  --
--------------
L = DBM:GetModLocalization(601)

L:SetGeneralLocalization{
	name 		= "Фалрик"
}

--------------
--  Marwyn  --
--------------
L = DBM:GetModLocalization(602)

L:SetGeneralLocalization{
	name 		= "Марвин"
}

-----------------------
--  Lich King Event  --
-----------------------
L = DBM:GetModLocalization(603)

L:SetWarningLocalization({
	WarnWave		= "%s"
})

L:SetTimerLocalization({
	achievementEscape	= "Время для побега"
})

L:SetOptionLocalization({
	WarnWave	= "Показывать предупреждение для прибывающих волн"
})

L:SetMiscLocalization({
	ACombatStart	= "Он слишком силен. Мы должны выбраться отсюда как можно скорее. Моя магия задержит его, но не надолго. Быстрее, герои!",
	HCombatStart	= "Он... слишком силён. Герои, быстрее... идите ко мнe! Мы должны немедленно покинуть это место! Я сделаю все возможное, чтобы удержать его на месте, пока мы бежим.",
	Ghoul			= "Вурдалак",
	Doctor			= "Знахарь",
	Abom			= "Поганище"
})
