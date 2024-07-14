DBM.Test:Report[[
Test: SoD/Party/DemonFall/Diathorus
Mod:  DBM-Party-Vanilla/Diathorus

Findings:
	None

Unused objects:
	None

Timers:
	None

Announces:
	None

Special warnings:
	Veil of Shadow - interrupt >%s<!, type=interrupt, spellId=460755, triggerDeltas = 13.31, 24.32
		[ 13.31] SPELL_CAST_START: [Diathorus the Seeker: Veil of Shadow] Creature-0-5252-2784-26746-227019-000012D5C6, Diathorus the Seeker, 0xa48, "", nil, 0x0, 460755, Veil of Shadow, 0, 0
			 Triggered 2x, delta times: 13.31, 24.32
	%s damage - move away, type=gtfo, spellId=460759, triggerDeltas = 18.68
		[ 18.68] SPELL_AURA_APPLIED: [Carrion Swarm->Tandanu: Carrion Swarm] Creature-0-5252-2784-26746-228770-000012E18E, Carrion Swarm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460759, Carrion Swarm, 0, DEBUFF, 0

Yells:
	None

Voice pack sounds:
	VoicePack/kickcast
		[ 13.31] SPELL_CAST_START: [Diathorus the Seeker: Veil of Shadow] Creature-0-5252-2784-26746-227019-000012D5C6, Diathorus the Seeker, 0xa48, "", nil, 0x0, 460755, Veil of Shadow, 0, 0
			 Triggered 2x, delta times: 13.31, 24.32
	VoicePack/watchfeet
		[ 18.68] SPELL_AURA_APPLIED: [Carrion Swarm->Tandanu: Carrion Swarm] Creature-0-5252-2784-26746-228770-000012E18E, Carrion Swarm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460759, Carrion Swarm, 0, DEBUFF, 0

Icons:
	None

Event trace:
	[  0.00] ENCOUNTER_START: 3024, Diathorus the Seeker, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_CAST_START 460755, SPELL_AURA_APPLIED 460759
	[ 13.31] SPELL_CAST_START: [Diathorus the Seeker: Veil of Shadow] Creature-0-5252-2784-26746-227019-000012D5C6, Diathorus the Seeker, 0xa48, "", nil, 0x0, 460755, Veil of Shadow, 0, 0
		PlaySound: VoicePack/kickcast
		ShowSpecialWarning: Veil of Shadow - interrupt Diathorus the Seeker!
	[ 18.68] SPELL_AURA_APPLIED: [Carrion Swarm->Tandanu: Carrion Swarm] Creature-0-5252-2784-26746-228770-000012E18E, Carrion Swarm, 0xa48, Player-5826-020CBDBB, Tandanu, 0x511, 460759, Carrion Swarm, 0, DEBUFF, 0
		AntiSpam: 1
		PlaySound: VoicePack/watchfeet
		ShowSpecialWarning: Carrion Swarm damage - move away
	[ 37.63] SPELL_CAST_START: [Diathorus the Seeker: Veil of Shadow] Creature-0-5252-2784-26746-227019-000012D5C6, Diathorus the Seeker, 0xa48, "", nil, 0x0, 460755, Veil of Shadow, 0, 0
		PlaySound: VoicePack/kickcast
		ShowSpecialWarning: Veil of Shadow - interrupt Diathorus the Seeker!
	[108.21] UNIT_DIED: [->Diathorus the Seeker] "", nil, 0x0, Creature-0-5252-2784-26746-227019-000012D5C6, Diathorus the Seeker, 0xa48, -1, false, 0, 0
		EndCombat: Main CID Down
]]
