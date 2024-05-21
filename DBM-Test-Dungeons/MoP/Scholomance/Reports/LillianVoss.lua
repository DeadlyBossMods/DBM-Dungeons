DBM.Test:Report[[
Test: MoP/Party/Scholomance/LillianVoss/MoP-Remix
Mod:  DBM-Party-MoP/666

Findings:
	Unused event registration: SPELL_AURA_APPLIED 111585 (Dark Blaze)
	Unused event registration: SPELL_AURA_APPLIED 111649 (Unleashed Anguish)
	Unused event registration: SPELL_AURA_APPLIED 115350 (Fixate Anger)
	Unused event registration: SPELL_CAST_START 111570 (Death's Grasp)
	Unused event registration: SPELL_CAST_START 114262 (Reanimate Corpse)
	Unused event registration: SPELL_CAST_SUCCESS 111585 (Dark Blaze)
	Unused event registration: SPELL_DAMAGE 111628 (Dark Blaze)
	Unused event registration: SPELL_MISSED 111628 (Dark Blaze)

Unused objects:
	[Announce] Unleashed Anguish, type=spell, spellId=111649
	[Announce] Reanimate Corpse, type=spell, spellId=114262
	[Announce] Fixate Anger on >%s<, type=target, spellId=115350
	[Special Warning] Death's Grasp!, type=spell, spellId=111570
	[Special Warning] %s damage - move away, type=gtfo, spellId=111585
	[Special Warning] Fixate Anger - run away, type=run, spellId=115350
	[Timer] Dark Blaze ends, time=8.00, type=active, spellId=111585
	[Timer] Fixate Anger, time=12.00, type=cd, spellId=115350
	[Timer] Fixate Anger: %s, time=10.00, type=target, spellId=115350

Timers:
	Death's Grasp, time=34.00, type=cd, spellId=111570, triggerDeltas = 0.00
		[ 0.00] ENCOUNTER_START: 1429, Lilian Voss, 1, 5, 0
	Shadow Shiv, time=12.50, type=cd, spellId=111775, triggerDeltas = 0.00, 12.06
		[ 0.00] ENCOUNTER_START: 1429, Lilian Voss, 1, 5, 0
		[12.06] SPELL_CAST_START: [Lilian Voss: Shadow Shiv] Creature-0-3888-1007-7106-58722-00004B3A00, Lilian Voss, 0xa48, "", nil, 0x0, 111775, Shadow Shiv, 0, 0

Announces:
	Shadow Shiv, type=spell, spellId=111775, triggerDeltas = 12.06
		[12.06] SPELL_CAST_START: [Lilian Voss: Shadow Shiv] Creature-0-3888-1007-7106-58722-00004B3A00, Lilian Voss, 0xa48, "", nil, 0x0, 111775, Shadow Shiv, 0, 0

Special warnings:
	None

Yells:
	None

Voice pack sounds:
	None

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 1429, Lilian Voss, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_AURA_APPLIED 111585 111649 115350, SPELL_CAST_START 111570 111775 114262, SPELL_CAST_SUCCESS 111585, SPELL_DAMAGE 111628, SPELL_MISSED 111628
		StartTimer: 12.0, Shadow Shiv
		StartTimer: 30.0, Death's Grasp
	[12.06] SPELL_CAST_START: [Lilian Voss: Shadow Shiv] Creature-0-3888-1007-7106-58722-00004B3A00, Lilian Voss, 0xa48, "", nil, 0x0, 111775, Shadow Shiv, 0, 0
		ShowAnnounce: Shadow Shiv
		StartTimer: 12.5, Shadow Shiv
	[29.05] ENCOUNTER_END: 1429, Lilian Voss, 1, 5, 1, 0
		EndCombat: ENCOUNTER_END
]]
