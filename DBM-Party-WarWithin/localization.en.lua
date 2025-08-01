local L

-------------------------
--  Darkflame Cleft (1210/2651)  --
-----------------------------
--  Ol' Waxbeard  --
-----------------------------
--L = DBM:GetModLocalization(2569)

-----------------------------
--  Blazikon  --
-----------------------------
--L = DBM:GetModLocalization(2559)

-----------------------------
--  The Candle King  --
-----------------------------
--L = DBM:GetModLocalization(2560)

-----------------------------
--  The Darkness  --
-----------------------------
--L = DBM:GetModLocalization(2561)

---------
--Trash--
---------
L = DBM:GetModLocalization("DarkflameCleftTrash")

L:SetGeneralLocalization({
	name =	"Darkflame Cleft Trash"
})

-------------------------
--  Priory of the Sacred Flame (1267/2649)  --
-----------------------------
--  Captain Dailcry  --
-----------------------------
--L = DBM:GetModLocalization(2571)

-----------------------------
--  Baron Braunpyke  --
-----------------------------
--L = DBM:GetModLocalization(2570)

-----------------------------
--  Prioress Murrpray  --
-----------------------------
--L = DBM:GetModLocalization(2573)

---------
--Trash--
---------
L = DBM:GetModLocalization("SacredFlameTrash")

L:SetGeneralLocalization({
	name =	"PotSF Trash"--or PSF?, whatever players end up calling it
})

-------------------------
--  The Rookery (1268/2648)  --
-----------------------------
--  Kyrioss  --
-----------------------------
--L = DBM:GetModLocalization(2566)

-----------------------------
--  Stormguard Gorren  --
-----------------------------
--L = DBM:GetModLocalization(2567)

-----------------------------
--  Voidstone Monstrosity  --
-----------------------------
--L = DBM:GetModLocalization(2568)

---------
--Trash--
---------
L = DBM:GetModLocalization("TheRookeryTrash")

L:SetGeneralLocalization({
	name =	"The Rookery Trash"
})

-------------------------
--  The Stonevault (1269/2652)  --
-----------------------------
--  E.D.N.A.  --
-----------------------------
--L = DBM:GetModLocalization(2572)

-----------------------------
--  Skarmorak  --
-----------------------------
--L = DBM:GetModLocalization(2579)

-----------------------------
--  Forge Speakers  --
-----------------------------
L = DBM:GetModLocalization(2590)

L:SetMiscLocalization{
	SafeVent		= "Safe Vent"
}

-----------------------------
--  High Speaker Eirich  --
-----------------------------
L = DBM:GetModLocalization(2582)

L:SetWarningLocalization({
	specWarnVoidCorruption	= "Void Corruption - Move NEAR (not into) Rift"
})

L:SetOptionLocalization({
	specWarnVoidCorruption	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.moveto:format(427329)
})

---------
--Trash--
---------
L = DBM:GetModLocalization("TheStonevaultTrash")

L:SetGeneralLocalization({
	name =	"The Stonevault Trash"
})

-------------------------
--  The Dawnbreaker (1270/2662)  --
-----------------------------
--  Speaker Shadowcrown  --
-----------------------------
--L = DBM:GetModLocalization(2580)

-----------------------------
--  Anub'ikkaj  --
-----------------------------
--L = DBM:GetModLocalization(2581)

-----------------------------
--  Rasha'nan  --
-----------------------------
--L = DBM:GetModLocalization(2593)

---------
--Trash--
---------
L = DBM:GetModLocalization("TheDawnbreakerTrash")

L:SetGeneralLocalization({
	name =	"The Dawnbreaker Trash"
})

-------------------------
--  Ara-Kara, City of Echoes (1271/2660)  --
-----------------------------
--  Avanoxx  --
-----------------------------
--L = DBM:GetModLocalization(2583)

-----------------------------
--  Anub'zekt  --
-----------------------------
--L = DBM:GetModLocalization(2584)

-----------------------------
--  Ki'katal the Harvester  --
-----------------------------
--L = DBM:GetModLocalization(2585)

---------
--Trash--
---------
L = DBM:GetModLocalization("AraKaraTrash")

L:SetGeneralLocalization({
	name =	"Ara-Kara Trash"
})

-------------------------
--  Cinderbrew Meadery (1272/2661)  --
-----------------------------
--  Brew Master Aldryr  --
-----------------------------
--L = DBM:GetModLocalization(2586)

-----------------------------
--  I'pa  --
-----------------------------
--L = DBM:GetModLocalization(2587)

-----------------------------
--  Benk Buzzbee  --
-----------------------------
--L = DBM:GetModLocalization(2588)

-----------------------------
--  Goldie Baronbottom  --
-----------------------------
L = DBM:GetModLocalization(2589)

L:SetMiscLocalization{
	RolePlay		= "Alright. You may have gotten my employees."
}

---------
--Trash--
---------
L = DBM:GetModLocalization("CinderbrewMeaderyTrash")

L:SetGeneralLocalization({
	name =	"Cinderbrew Meadery Trash"
})

L:SetOptionLocalization({
	AGBuffs		= "Auto select gossip to activate buffs when interacting with profession objects"
})

-------------------------
--  City of Threads (1274/2669)  --
-----------------------------
--  Orator Krix'vizk  --
-----------------------------
--L = DBM:GetModLocalization(2594)

-----------------------------
--  Fangs of the Queen  --
-----------------------------
L = DBM:GetModLocalization(2595)

L:SetMiscLocalization{
	RolePlay		= "The Transformatory was once the home of our sacred evolution."
}

-----------------------------
--  The Coaglamation  --
-----------------------------
--L = DBM:GetModLocalization(2600)

-----------------------------
--  Izo, the Grand Splicer  --
-----------------------------
--L = DBM:GetModLocalization(2596)

---------
--Trash--
---------
L = DBM:GetModLocalization("CityofThreadsTrash")

L:SetGeneralLocalization({
	name =	"City of Threads Trash"
})

-----------------------------
--  Big M.O.M.M.A.  --
-----------------------------
--L = DBM:GetModLocalization(2648)

-----------------------------
--  Demolition Duo  --
-----------------------------
--L = DBM:GetModLocalization(2649)

-----------------------------
--  Swampface  --
-----------------------------
--L = DBM:GetModLocalization(2650)

-----------------------------
--  Geezle Gigazap (aka Geez nuts)  --
-----------------------------
--L = DBM:GetModLocalization(2651)

---------
--Trash--
---------
L = DBM:GetModLocalization("OperationFloodgateTrash")

L:SetGeneralLocalization({
	name =	"Operation: Floodgate Trash"
})

-----------------------------
--  Azhiccar  --
-----------------------------
--L = DBM:GetModLocalization(2675)

-----------------------------
--  Taah'bat and A'wazj  --
-----------------------------
--L = DBM:GetModLocalization(2676)

-----------------------------
--  Soul-Scribe  --
-----------------------------
--L = DBM:GetModLocalization(2677)

---------
--Trash--
---------
L = DBM:GetModLocalization("EcoDomeAldaniTrash")

L:SetGeneralLocalization({
	name =	"Eco-Dome Al'dani Trash"
})
