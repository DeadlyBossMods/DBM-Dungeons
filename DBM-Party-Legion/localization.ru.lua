if GetLocale() ~= "ruRU" then return end
local L

-----------------------
-- <<<Black Rook Hold>>> --
-----------------------
-----------------------
-- The Amalgam of Souls --
-----------------------
L= DBM:GetModLocalization(1518)

-----------------------
-- Illysanna Ravencrest --
-----------------------
L= DBM:GetModLocalization(1653)

-----------------------
-- Smashspite the Hateful --
-----------------------
L= DBM:GetModLocalization(1664)

-----------------------
-- Lord Kur'talos Ravencrest --
-----------------------
L= DBM:GetModLocalization(1672)

-----------------------
--Black Rook Hold Trash
-----------------------
L = DBM:GetModLocalization("BRHTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Крепость Чёрной Ладьи"
})

-----------------------
-- <<<Darkheart Thicket>>> --
-----------------------
-----------------------
-- Arch-Druid Glaidalis --
-----------------------
L= DBM:GetModLocalization(1654)

-----------------------
-- Oakheart --
-----------------------
L= DBM:GetModLocalization(1655)

-----------------------
-- Dresaron --
-----------------------
L= DBM:GetModLocalization(1656)

-----------------------
-- Shade of Xavius --
-----------------------
L= DBM:GetModLocalization(1657)

-----------------------
--Darkheart Thicket Trash
-----------------------
L = DBM:GetModLocalization("DHTTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Чаща Тёмного Сердца"
})

L:SetMiscLocalization({
	GlaidalisRP	= "Осквернители... Я чую Кошмар в вашей крови. Сгиньте из леса или познаете гнев природы!"
})


-----------------------
-- <<<Eye of Azshara>>> --
-----------------------
-----------------------
-- Warlord Parjesh --
-----------------------
L= DBM:GetModLocalization(1480)

-----------------------
-- Lady Hatecoil --
-----------------------
L= DBM:GetModLocalization(1490)

L:SetWarningLocalization({
	specWarnStaticNova			= "Кольцо молний - встаньте на песок",
	specWarnFocusedLightning	= "Средоточие молний - встаньте в воду"
})

-----------------------
-- King Deepbeard --
-----------------------
L= DBM:GetModLocalization(1491)

-----------------------
-- Serpentrix --
-----------------------
L= DBM:GetModLocalization(1479)

-----------------------
-- Wrath of Azshara --
-----------------------
L= DBM:GetModLocalization(1492)

-----------------------
--Eye of Azshara Trash
-----------------------
L = DBM:GetModLocalization("EoATrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Око Азшары"
})

-----------------------
-- <<<Halls of Valor>>> --
-----------------------
-----------------------
-- Hymdall --
-----------------------
L= DBM:GetModLocalization(1485)

-----------------------
-- Hyrja --
-----------------------
L= DBM:GetModLocalization(1486)

-----------------------
-- Fenryr --
-----------------------
L= DBM:GetModLocalization(1487)

-----------------------
-- God-King Skovald --
-----------------------
L= DBM:GetModLocalization(1488)

L:SetMiscLocalization({
	SkovaldRP		= "Нет! Я, Король-бог Сковальд, тоже доказал, что достоин. Эти смертные не посмеют оспорить мое право владеть Эгидой!",
	SkovaldRPTwo	= "Или эти псевдогерои сами отдадут Эгиду... Или я вырву ее из их мертвых рук!"
})

-----------------------
-- Odyn --
-----------------------
L= DBM:GetModLocalization(1489)

L:SetOptionLocalization({
	RuneBehavior	= "Установить режим мода для 'Рунического клейма'",
	Icon			= "Голосовые оповещения на основе назначений значков, соответствующих цветам рун (например, использование сигнальных ракет)",
	Entrance		= "Голосовые оповещения на основе кардинальных направлений, например, если вход находится на юге, а трон - на севере",
	Minimap			= "Голосовые оповещения на основе кардинальных направлений, основанных на миникарте, где трон находится на юге, а вход - на севере",
	Generic			= "Дает общее голосовое оповещение, которое просто говорит, что вы стали целью. Никаких указаний направления не дается"--По умолчанию
})

L:SetMiscLocalization({
	tempestModeMessage		=	"Нет последовательности бури: %s. Перепроверка через 8 секунд.",
	OdynRP					= 	"Удивительно! Я не верил, что кто-то может сравниться с валарьярами... Но вы доказали, что это возможно."
})

-----------------------
--Halls of Valor Trash
-----------------------
L = DBM:GetModLocalization("HoVTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Чертоги Доблести"
})

-----------------------
-- <<<Neltharion's Lair>>> --
-----------------------
-----------------------
-- Rokmora --
-----------------------
L= DBM:GetModLocalization(1662)

-----------------------
-- Ularogg Cragshaper --
-----------------------
L= DBM:GetModLocalization(1665)

-----------------------
-- Naraxas --
-----------------------
L= DBM:GetModLocalization(1673)

-----------------------
-- Dargrul the Underking --
-----------------------
L= DBM:GetModLocalization(1687)

-----------------------
--Neltharion's Lair Trash
-----------------------
L = DBM:GetModLocalization("NLTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Логово Нелтариона"
})

-----------------------
-- <<<The Arcway>>> --
-----------------------
-----------------------
-- Ivanyr --
-----------------------
L= DBM:GetModLocalization(1497)

-----------------------
-- Nightwell Sentry --
-----------------------
L= DBM:GetModLocalization(1498)

-----------------------
-- General Xakal --
-----------------------
L= DBM:GetModLocalization(1499)

L:SetMiscLocalization({
	batSpawn		=	"Подкрепления ко мне! СЕЙЧАС!"
})

-----------------------
-- Nal'tira --
-----------------------
L= DBM:GetModLocalization(1500)

-----------------------
-- Advisor Vandros --
-----------------------
L= DBM:GetModLocalization(1501)

-----------------------
--The Arcway Trash
-----------------------
L = DBM:GetModLocalization("ArcwayTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Катакомбы Сурамара"
})

-----------------------
-- <<<Court of Stars>>> --
-----------------------
-----------------------
-- Patrol Captain Gerdo --
-----------------------
L= DBM:GetModLocalization(1718)

-----------------------
-- Talixae Flamewreath --
-----------------------
L= DBM:GetModLocalization(1719)

-----------------------
-- Advisor Melandrus --
-----------------------
L= DBM:GetModLocalization(1720)

L:SetMiscLocalization({
	MelRP		= "Великий магистр, не слишком ли рано?"--Seems right
})

-----------------------
--Court of Stars Trash
-----------------------
L = DBM:GetModLocalization("CoSTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Квартал Звёзд"
})

L:SetWarningLocalization({
	warnAvailableItems	= "%s"
})

L:SetOptionLocalization({
	warnAvailableItems	= "Объявлять о доступных взаимодействиях в зоне на основе группы",
	SpyHelper		= "Помочь идентифицировать шпиона, автоматически сканируя диалоги при взаимодействии с Болтливым сплетником и отображая их на инфофрейме (также синхронизируется с другими игроками, использующими DBM/BigWigs)",
	SpyHelperClose2	= "Автоматическое закрытие диалогового окна через 0.3 секунды (задержка позволяет другим модам или WA успевать сканировать диалоги)",
	SendToChat2		= "Также отправлять подсказки в чат (требуется включенная выше опция)"
})

L:SetMiscLocalization({
	Found			= "Теперь, давайте не будем торопиться",
	CluesFound	= "Найдено подсказок: %d/5",
	ClueShort	= "Подсказка %d/5: %s",
	Gloves		= "Носит перчатки / Wears gloves",
	NoGloves	= "Без перчаток / No gloves",
	Cape		= "Носит плащ / Wearing a cape",
	Nocape		= "Без плаща / No cape",
	LightVest	= "Светлый жилет / Light vest",
	DarkVest	= "Темный жилет / Dark vest",
	Female		= "Женщина / Female",
	Male		= "Мужчина / Male",
	ShortSleeve = "Короткие рукава / Short sleeves",
	LongSleeve	= "Длинные рукава / Long sleeves",
	Potions		= "Зелья / Potions",
	NoPotions	= "Нет зелий / No potions",
	Book		= "Книга / Book",
	Pouch		= "Кошель / Pouch",

	SpyFoundP 	= "Я нашел шпиона",
	SpyFound 	= "Шпион был обнаружен %s",

	Nightshade					= "Закуски ночной тени",
	UmbralBloom					= "Теневой цветок",
	InfernalTome				= "Инфернальный фолиант",
	MagicalLantern				= "Магический светильник",
	StarlightRoseBrew			= "Отвар из звездной розы",
	WaterloggedScroll			= "Промокший свиток",
	DiscardedJunk				= "Выброшенный хлам",
	BazaarGoods					= "Рыночные товары",
	WoundedNightborneCivilian	= "Раненый ночнорожденный",
	LifesizedNightborneStatue	= "Статуя ночнорожденного в натуральную величину",
	--
	Available					= "%s|cffffffff%s|r доступно",
	UsableBy					= "может использоваться %s"
})

-----------------------
-- <<<The Maw of Souls>>> --
-----------------------
-----------------------
-- Ymiron, the Fallen King --
-----------------------
L= DBM:GetModLocalization(1502)

-----------------------
-- Harbaron --
-----------------------
L= DBM:GetModLocalization(1512)

-----------------------
-- Helya --
-----------------------
L= DBM:GetModLocalization(1663)

-----------------------
--Maw of Souls Trash
-----------------------
L = DBM:GetModLocalization("MawTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Утроба Душ"
})

-----------------------
-- <<<Assault Violet Hold>>> --
-----------------------
-----------------------
-- Mindflayer Kaahrj --
-----------------------
L= DBM:GetModLocalization(1686)

-----------------------
-- Millificent Manastorm --
-----------------------
L= DBM:GetModLocalization(1688)

-----------------------
-- Festerface --
-----------------------
L= DBM:GetModLocalization(1693)

-----------------------
-- Shivermaw --
-----------------------
L= DBM:GetModLocalization(1694)

-----------------------
-- Blood-Princess Thal'ena --
-----------------------
L= DBM:GetModLocalization(1702)

-----------------------
-- Anub'esset --
-----------------------
L= DBM:GetModLocalization(1696)

-----------------------
-- Sael'orn --
-----------------------
L= DBM:GetModLocalization(1697)

-----------------------
-- Fel Lord Betrug --
-----------------------
L= DBM:GetModLocalization(1711)

-----------------------
--Assault Violet Hold Trash
-----------------------
L = DBM:GetModLocalization("AVHTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Аметистовая Крепость"
})

L:SetWarningLocalization({
	WarningPortalSoon	= "Скоро новый портал",
	WarningPortalNow	= "Портал #%d",
	WarningBossNow		= "Прибытие босса"
})

L:SetTimerLocalization({
	TimerPortal			= "Восст. Портал"
})

L:SetOptionLocalization({
	WarningPortalNow		= "Предупреждение о новом портале",
	WarningPortalSoon		= "Предупреждать заранее о новом портале",
	WarningBossNow			= "Предупреждать о прибытии босса",
	TimerPortal				= "Отсчет вермени до след. портала (после босса)"
})

L:SetMiscLocalization({
	Malgath		=	"Лорд Малгат"
})

-----------------------
-- <<<Vault of the Wardens>>> --
-----------------------
-----------------------
-- Tirathon Saltheril --
-----------------------
L= DBM:GetModLocalization(1467)

-----------------------
-- Inquisitor Tormentorum --
-----------------------
L= DBM:GetModLocalization(1695)

-----------------------
-- Ash'golm --
-----------------------
L= DBM:GetModLocalization(1468)

-----------------------
-- Glazer --
-----------------------
L= DBM:GetModLocalization(1469)

-----------------------
-- Cordana --
-----------------------
L= DBM:GetModLocalization(1470)

-----------------------
--Vault of Wardens Trash
-----------------------
L = DBM:GetModLocalization("VoWTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Казематы Стражей"
})

-----------------------
-- <<<Return To Karazhan>>> --
-----------------------
-----------------------
-- Maiden of Virtue --
-----------------------
L= DBM:GetModLocalization(1825)

-----------------------
-- Opera Hall: Wikket  --
-----------------------
L= DBM:GetModLocalization(1820)

-----------------------
-- Opera Hall: Westfall Story --
-----------------------
L= DBM:GetModLocalization(1826)

-----------------------
-- Opera Hall: Beautiful Beast  --
-----------------------
L= DBM:GetModLocalization(1827)

-----------------------
-- Attumen the Huntsman --
-----------------------
L= DBM:GetModLocalization(1835)

-----------------------
-- Moroes --
-----------------------
L= DBM:GetModLocalization(1837)

-----------------------
-- The Curator --
-----------------------
L= DBM:GetModLocalization(1836)

-----------------------
-- Shade of Medivh --
-----------------------
L= DBM:GetModLocalization(1817)

-----------------------
-- Mana Devourer --
-----------------------
L= DBM:GetModLocalization(1818)

-----------------------
-- Viz'aduum the Watcher --
-----------------------
L= DBM:GetModLocalization(1838)

-----------------------
--Nightbane
-----------------------
L = DBM:GetModLocalization("Nightbane")

L:SetGeneralLocalization({
	name =	"Ночная погибель"
})

-----------------------
--Return To Karazhan Trash
-----------------------
L = DBM:GetModLocalization("RTKTrash")

L:SetGeneralLocalization({
	name =	"Трэш: Возвращение в Каражан"
})

L:SetMiscLocalization({
	speedRun		=	"Странный холод возвещает о темном присутствии..."
})

-----------------------
-- <<<Cathedral of Eternal Night >>> --
-----------------------
-----------------------
-- Agronox --
-----------------------
L= DBM:GetModLocalization(1905)

-----------------------
-- Trashbite the Scornful  --
-----------------------
L= DBM:GetModLocalization(1906)

L:SetMiscLocalization({
	bookCase	=	"За книжным шкафом"
})

-----------------------
-- Domatrax --
-----------------------
L= DBM:GetModLocalization(1904)

-----------------------
-- Mephistroth  --
-----------------------
L= DBM:GetModLocalization(1878)

-----------------------
--Cathedral of Eternal Night Trash
-----------------------
L = DBM:GetModLocalization("CoENTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Собор Вечной Ночи"
})

-----------------------
-- <<<Seat of Triumvirate >>> --
-----------------------
-----------------------
-- Zuraal --
-----------------------
L= DBM:GetModLocalization(1979)

-----------------------
-- Saprish  --
-----------------------
L= DBM:GetModLocalization(1980)

-----------------------
-- Viceroy Nezhar --
-----------------------
L= DBM:GetModLocalization(1981)

-----------------------
-- L'ura  --
-----------------------
L= DBM:GetModLocalization(1982)

-----------------------
--Seat of Triumvirate Trash
-----------------------
L = DBM:GetModLocalization("SoTTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Престол Триумвирата"
})
