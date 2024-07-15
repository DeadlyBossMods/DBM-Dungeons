DBM.Test:Report[[
Test: SoD/Party/DemonFall/HellscreamsPhantom
Mod:  DBM-Party-Vanilla/HellscreamsPhantom

Findings:
	None

Unused objects:
	None

Timers:
	None

Announces:
	None

Special warnings:
	%s damage - move away, type=gtfo, spellId=460249, triggerDeltas = 51.66, 35.01, 5.99, 32.91
		[ 51.66] SPELL_DAMAGE: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E666, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0
			 Triggered 3x, delta times: 51.66, 41.00, 32.91
		[ 86.67] SPELL_MISSED: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E666, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0

Yells:
	None

Voice pack sounds:
	VoicePack/watchfeet
		[ 51.66] SPELL_DAMAGE: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E666, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0
			 Triggered 3x, delta times: 51.66, 41.00, 32.91
		[ 86.67] SPELL_MISSED: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E666, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0

Icons:
	None

Event trace:
	[  0.00] ENCOUNTER_START: 3031, Hellscream's Phantom, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_DAMAGE 460249, SPELL_MISSED 460249
	[ 51.66] SPELL_DAMAGE: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E666, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0
		AntiSpam: 1
			Filtered: 3x SPELL_DAMAGE at 52.16, 52.66, 53.16
		ShowSpecialWarning: Spiritstorm damage - move away
		PlaySound: VoicePack/watchfeet
	[ 86.67] SPELL_MISSED: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E666, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0
		AntiSpam: 1
			Filtered: 2x SPELL_DAMAGE at 87.16, 87.66
		ShowSpecialWarning: Spiritstorm damage - move away
		PlaySound: VoicePack/watchfeet
	[ 92.66] SPELL_DAMAGE: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E666, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0
		AntiSpam: 1
			Filtered: 4x SPELL_DAMAGE at 93.16, 93.66, 94.16, 94.66
		ShowSpecialWarning: Spiritstorm damage - move away
		PlaySound: VoicePack/watchfeet
	[125.57] SPELL_DAMAGE: [Spiritstorm->Tandanu: Spiritstorm] Creature-0-5252-2784-26746-228551-000012E695, Spiritstorm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460249, Spiritstorm, 0, 0
		AntiSpam: 1
			Filtered: 2x SPELL_DAMAGE at 126.07, 126.57
		ShowSpecialWarning: Spiritstorm damage - move away
		PlaySound: VoicePack/watchfeet
	[146.16] UNIT_DIED: [->Hellscream's Phantom] "", nil, 0x0, Vehicle-0-5252-2784-26746-227028-000012E50E, Hellscream's Phantom, 0xa48, -1, false, 0, 0
		EndCombat: Main CID Down
]]
