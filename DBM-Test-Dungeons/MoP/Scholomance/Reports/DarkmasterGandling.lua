DBM.Test:Report[[
Test: MoP/Party/Scholomance/DarkmasterGandling/MoP-Remix
Mod:  DBM-Party-MoP/684

Findings:
	Unused event registration: SPELL_AURA_APPLIED 113143 (Rise!)

Unused objects:
	[Announce] Rise!, type=spell, spellId=113143

Timers:
	Harsh Lesson, time=30.00, type=next, spellId=113395, triggerDeltas = 0.00, 17.14
		[ 0.00] ENCOUNTER_START: 1430, Darkmaster Gandling, 1, 5, 0
		[17.14] CHAT_MSG_RAID_BOSS_EMOTE: |TInterface\Icons\inv_misc_book_01.blp:20|t%s assigns Caldera a |cFFFF0000|Hspell:113395|h[Harsh Lesson]|h|r!, Darkmaster Gandling, "", "", Caldera, "", 0, 0, "", 0, 329, nil, 0, false, false, false, false, 0

Announces:
	Harsh Lesson on >%s<, type=target, spellId=113395, triggerDeltas = 17.14
		[17.14] CHAT_MSG_RAID_BOSS_EMOTE: |TInterface\Icons\inv_misc_book_01.blp:20|t%s assigns Caldera a |cFFFF0000|Hspell:113395|h[Harsh Lesson]|h|r!, Darkmaster Gandling, "", "", Caldera, "", 0, 0, "", 0, 329, nil, 0, false, false, false, false, 0

Special warnings:
	None

Yells:
	None

Voice pack sounds:
	None

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 1430, Darkmaster Gandling, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_AURA_APPLIED 113143, CHAT_MSG_RAID_BOSS_EMOTE
		StartTimer: 17.0, Harsh Lesson
	[17.14] CHAT_MSG_RAID_BOSS_EMOTE: |TInterface\Icons\inv_misc_book_01.blp:20|t%s assigns Caldera a |cFFFF0000|Hspell:113395|h[Harsh Lesson]|h|r!, Darkmaster Gandling, "", "", Caldera, "", 0, 0, "", 0, 329, nil, 0, false, false, false, false, 0
		ShowAnnounce: Harsh Lesson on Unknown
		StartTimer: 30.0, Harsh Lesson
	[34.79] UNIT_DIED: [->Darkmaster Gandling] "", nil, 0x0, Creature-0-3888-1007-7106-59080-00004B386C, Darkmaster Gandling, 0xa48, -1, false, 0, 0
		EndCombat: Main CID Down
]]
