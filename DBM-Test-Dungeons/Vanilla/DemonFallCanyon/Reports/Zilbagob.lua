DBM.Test:Report[[
Test: SoD/Party/DemonFall/Zilbagob
Mod:  DBM-Party-Vanilla/Zilbagob

Findings:
	Unused event registration: SPELL_AURA_APPLIED 462272 (Pool of Fire)

Unused objects:
	[Special Warning] %s damage - move away, type=gtfo, spellId=462272

Timers:
	None

Announces:
	None

Special warnings:
	None

Yells:
	None

Voice pack sounds:
	None

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 3029, Zilbagob, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_AURA_APPLIED 462272
	[99.39] UNIT_DIED: [->Zilbagob] "", nil, 0x0, Creature-0-5252-2784-26746-226922-000012DCFD, Zilbagob, 0xa48, -1, false, 0, 0
		EndCombat: Main CID Down
]]
