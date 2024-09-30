DBM.Test:Report[[
Test: SoD/Party/DemonFall/Azgaloth
Mod:  DBM-Party-Vanilla/Azgaloth

Findings:
	None

Unused objects:
	None

Timers:
	Umbral Slash, time=4.00, type=cast, spellId=470280, triggerDeltas = 21.03
		[21.03] SPELL_CAST_START: [Azgaloth: Umbral Slash] Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, "", nil, 0x0, 470280, Umbral Slash, 0, 0

Announces:
	Casting Bounding Shadow: 1.0 sec, type=cast, spellId=470457, triggerDeltas = 8.07, 30.76
		[ 8.07] SPELL_CAST_START: [Azgaloth: Bounding Shadow] Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, "", nil, 0x0, 470457, Bounding Shadow, 0, 0
			 Triggered 2x, delta times: 8.07, 30.76

Special warnings:
	Umbral Slash - soak it, type=soak, spellId=470280, triggerDeltas = 21.03
		[21.03] SPELL_CAST_START: [Azgaloth: Umbral Slash] Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, "", nil, 0x0, 470280, Umbral Slash, 0, 0

Yells:
	None

Voice pack sounds:
	VoicePack/frontal
		[21.03] SPELL_CAST_START: [Azgaloth: Umbral Slash] Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, "", nil, 0x0, 470280, Umbral Slash, 0, 0

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 3080, Azgaloth, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_CAST_START 470280 470457
	[ 8.07] SPELL_CAST_START: [Azgaloth: Bounding Shadow] Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, "", nil, 0x0, 470457, Bounding Shadow, 0, 0
		ShowAnnounce: Casting Bounding Shadow: 1.0 sec
	[21.03] SPELL_CAST_START: [Azgaloth: Umbral Slash] Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, "", nil, 0x0, 470280, Umbral Slash, 0, 0
		ShowSpecialWarning: Umbral Slash - soak it
		PlaySound: VoicePack/frontal
		StartTimer: 4.0, Umbral Slash
	[38.83] SPELL_CAST_START: [Azgaloth: Bounding Shadow] Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, "", nil, 0x0, 470457, Bounding Shadow, 0, 0
		ShowAnnounce: Casting Bounding Shadow: 1.0 sec
	[44.17] UNIT_DIED: [->Azgaloth] "", nil, 0x0, Creature-0-1-2784-1-232632-0000000003, Azgaloth, 0xa48, -1, false, 0, 0
		EndCombat: Main CID Down
]]
