if GetLocale() ~= "deDE" then return end
local L

------------
--  Omen  --
------------
L = DBM:GetModLocalization("Omen")

L:SetGeneralLocalization({
	name = "Omen"
})

------------------------------
--  The Crown Chemical Co.  --
------------------------------
L = DBM:GetModLocalization("d288")

L:SetTimerLocalization{
	HummelActive		= "Hummel wird aktiv",
	BaxterActive		= "Baxter wird aktiv",
	FryeActive			= "Frye wird aktiv"
}

L:SetOptionLocalization({
	TrioActiveTimer		= "Zeige Zeit bis Apotheker aktiv werden"
})

L:SetMiscLocalization({
	SayCombatStart		= "Haben sie sich die Mühe gemacht und Euch gesagt, wer ich bin und warum ich das hier tue?"
})

----------------------------
--  The Frost Lord Ahune  --
----------------------------
L = DBM:GetModLocalization("d286")

L:SetWarningLocalization({
	Emerged			= "Aufgetaucht",
	specWarnAttack	= "Ahune ist verwundbar - Angriff!"
})

L:SetTimerLocalization{
	SubmergeTimer	= "Abtauchen",
	EmergeTimer		= "Auftauchen"
}

L:SetOptionLocalization({
	Emerged			= "Zeige Warnung, wenn Ahune auftaucht",
	specWarnAttack	= "Spezialwarnung, wenn Ahune verwundbar wird",
	SubmergeTimer	= "Zeige Zeit bis Abtauchen",
	EmergeTimer		= "Zeige Zeit bis Auftauchen"
})

L:SetMiscLocalization({
	Pull			= "Der Eisbrocken ist geschmolzen!"
})

----------------------
--  Coren Direbrew  --
----------------------
L = DBM:GetModLocalization("d287")

L:SetWarningLocalization({
	specWarnBrew		= "Werde das Bier los, bevor sie dir noch eins zuwirft!",
	specWarnBrewStun	= "TIPP: Du hast eine Kopfnuss kassiert, trink das Bier beim nächsten Mal!"
})

L:SetOptionLocalization({
	specWarnBrew		= "Spezialwarnung für $spell:47376",
	specWarnBrewStun	= "Spezialwarnung für $spell:47340"
})

L:SetMiscLocalization({
	YellBarrel			= "Stecke im Fass!"
})

----------------
--  Brewfest  --
----------------
L = DBM:GetModLocalization("Brew")

L:SetGeneralLocalization({
	name = "Braufest"
})

L:SetOptionLocalization({
	NormalizeVolume			= "Setze im Braufestgebiet die Lautstärke des DIALOG-Audiokanals automatisch auf die Lautstärke des Musik-Audiokanals, damit es nicht so ärgerlich laut ist. (falls keine Musiklautstärke gesetzt ist, wird der Dialog-Audiokanal stummgeschaltet)"
})

-----------------------------
--  The Headless Horseman  --
-----------------------------
L = DBM:GetModLocalization("d285")

L:SetWarningLocalization({
	WarnPhase				= "Phase %d",
	warnHorsemanSoldiers	= "Pulsierende Kürbisse erscheinen",
	warnHorsemanHead		= "Kopf des Reiters aktiv"
})

L:SetOptionLocalization({
	WarnPhase				= "Zeige Warnung für jeden Phasenwechsel",
	warnHorsemanSoldiers	= "Zeige Warnung, wenn Pulsierende Kürbnisse erscheinen",
	warnHorsemanHead		= "Zeige Warnung, wenn Kopf des Reiters erscheint"
})

L:SetMiscLocalization({
	HorsemanSummon			= "Erhebe dich, Reiter,...",
	HorsemanSoldiers		= "Soldaten, erhebt Euch und kämpft immer weiter. Bringt endlich den Sieg zum gefallenen Reiter!"
})

------------------------------
--  The Abominable Greench  --
------------------------------
L = DBM:GetModLocalization("Greench")

L:SetGeneralLocalization({
	name = "Der monströse Griesgram"
})

--------------------------
--  Plants Vs. Zombies  --
--------------------------
L = DBM:GetModLocalization("PlantsVsZombies")

L:SetGeneralLocalization({
	name = "Pflanzen gegen Zombies"
})

L:SetWarningLocalization({
	warnTotalAdds	= "Anzahl erschienener Zombies seit letzter Riesiger Welle: %d",
	specWarnWave	= "Riesige Welle!"
})

L:SetTimerLocalization{
	timerWave		= "Nächste Riesige Welle"
}

L:SetOptionLocalization({
	warnTotalAdds	= "Verkünde die Anzahl der erschienenen Zombies zwischen jeder Riesigen Welle",
	specWarnWave	= "Spezialwarnung, wenn eine Riesige Welle beginnt",
	timerWave		= "Zeige Zeit bis nächste Riesige Welle"
})

L:SetMiscLocalization({
	MassiveWave		= "Eine riesige Zombiewelle nähert sich!" --needs to be verified (video-captured translation)
})

--------------------------
--  Demonic Invasions  --
--------------------------
L = DBM:GetModLocalization("DemonInvasions")

L:SetGeneralLocalization({
	name = "Dämoneninvasionen"
})

--------------------------
--  Memories of Azeroth: Burning Crusade  --
--------------------------
L = DBM:GetModLocalization("BCEvent")

L:SetGeneralLocalization({
	name = "MoA: Burning Crusade"
})

--------------------------
--  Memories of Azeroth: Wrath of the Lich King  --
--------------------------
L = DBM:GetModLocalization("WrathEvent")

L:SetGeneralLocalization({
	name = "MoA: WotLK"
})

L:SetMiscLocalization{
	Emerge				= "entsteigt dem Boden!",
	Burrow				= "gräbt sich in den Boden!"
}

--------------------------
--  Memories of Azeroth: Cataclysm  --
--------------------------
L = DBM:GetModLocalization("CataEvent")

L:SetGeneralLocalization({
	name = "MoA: Cataclysm"
})

-- Lord Kazzak (Badlands)
L = DBM:GetModLocalization("KazzakClassic")

----------------------------------
--  Azeroth Event World Bosses  --
----------------------------------

L:SetGeneralLocalization{
	name = "Lord Kazzak"
}

L:SetMiscLocalization({
	Pull		= "Für die Legion! Für Kil'jaeden!"
})

-- Azuregos (Azshara)
L = DBM:GetModLocalization("Azuregos")

L:SetGeneralLocalization{
	name = "Azuregos"
}

L:SetMiscLocalization({
	Pull		= "Dieser Ort steht unter meinem Schutz. Die Mysterien des Arkanen werden unberührt bleiben."
})

-- Taerar (Ashenvale)
L = DBM:GetModLocalization("Taerar")

L:SetGeneralLocalization{
	name = "Taerar"
}

L:SetMiscLocalization({
	Pull		= "Frieden ist nur ein flüchtiger Traum! Möge der Alptraum herrschen!"
})

-- Ysondre (Feralas)
L = DBM:GetModLocalization("Ysondre")

L:SetGeneralLocalization{
	name = "Ysondre"
}

L:SetMiscLocalization({
	Pull		= "Die Fäden des Lebens wurden durchtrennt! Die Träumer müssen gerächt werden."
})

-- Lethon (Hinterlands)
L = DBM:GetModLocalization("Lethon")

L:SetGeneralLocalization{
	name = "Lethon"
}

L:SetMiscLocalization({
--	Pull		= "Ich spüre die Schatten in Euren Herzen. Die Verdammten werden niemals ruhen!"
})

-- Emeriss (Duskwood)
L = DBM:GetModLocalization("Emeriss")

L:SetGeneralLocalization{
	name = "Smariss"
}

L:SetMiscLocalization({
	Pull		= "Hoffnung ist ein Gebrechen der Seele! Dieses Land wird verdorren und vergehen!"
})

--------------------------
--  Blastenheimer 5000  --
--------------------------
L = DBM:GetModLocalization("Cannon")

L:SetGeneralLocalization({
	name = "Kanonendonner"
})

-------------
--  Gnoll  --
-------------
L = DBM:GetModLocalization("Gnoll")

L:SetGeneralLocalization({
	name = "Hau-den-Gnoll"
})

L:SetWarningLocalization({
	warnGameOverQuest	= "Es wurden %d von insgesamt %d erreichbaren Punkten erzielt.",
	warnGameOverNoQuest	= "Spielende. Es waren insgesamt %d Punkte erreichbar.",
	warnGnoll			= "Gnoll erschienen",
	warnHogger			= "Hogger erschienen",
	specWarnHogger		= "Hogger erschienen!"
})

L:SetOptionLocalization({
	warnGameOver	= "Verkünde nach dem Spielende die insgesamt erreichbaren Punkte",
	warnGnoll		= "Zeige Warnung, wenn ein Gnoll erscheint",
	warnHogger		= "Zeige Warnung, wenn ein Hogger erscheint",
	specWarnHogger	= "Spezialwarnung, wenn ein Hogger erscheint"
})

------------------------
--  Shooting Gallery  --
------------------------
L = DBM:GetModLocalization("Shot")

L:SetGeneralLocalization({
	name = "Schießbude"
})

L:SetOptionLocalization({
	SetBubbles			= "Automatische Deaktivierung der 'Sprechblasen' während $spell:101871<br/>(wird nach dem Spielende auf die vorherige Einstellung zurückgesetzt)"
})

----------------------
--  Tonk Challenge  --
----------------------
L = DBM:GetModLocalization("Tonks")

L:SetGeneralLocalization({
	name = "Panzergeneral"
})

---------------------------
--  Fire Ring Challenge  --
---------------------------
L = DBM:GetModLocalization("Rings")

L:SetGeneralLocalization({
	name = "Herausforderung des Feuervogels"
})

-----------------------
--  Darkmoon Rabbit  --
-----------------------
L = DBM:GetModLocalization("Rabbit")

L:SetGeneralLocalization({
	name = "Dunkelmond-Kaninchen"
})

-------------------------
--  Darkmoon Moonfang  --
-------------------------
L = DBM:GetModLocalization("Moonfang")

L:SetGeneralLocalization({
	name = "Mondfang"
})

L:SetWarningLocalization({
	specWarnCallPack		= "Rudelruf - Lauf mehr als 40 Meter von Mondfang weg!",
	specWarnMoonfangCurse	= "Mondfangs Fluch - Lauf mehr als 10 Meter von Mondfang weg!"
})
