local mod	= DBM:NewMod("WarchiefRendBlackhand", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10339, 10429) -- Gyth, Rend
mod:SetMainBossID(10429)
mod:SetMinSyncRevision(20240729000000)
mod:SetZone(229)

mod:RegisterCombat("combat")

if not DBM:IsPostCata() then
	--vanilla, TBC, and wrath should have same old instance, it's revamped in cata
	mod:RegisterEvents("CHAT_MSG_MONSTER_YELL")
end

local timerCombatStart = DBM:IsClassic() and mod:NewCombatTimer(94.6) or nil -- TODO: migrate to NilWarning after core release

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Pull1 or msg:find(L.Pull1) then
		self:SendSync("Pull1")
	elseif msg == L.Pull2 or msg:find(L.Pull2) then
		self:SendSync("Pull2")
	end
end

function mod:OnSync(msg)
	if msg == "Pull1" and timerCombatStart then
		if DBM:IsSeasonal("SeasonOfDiscovery") then
			-- In SoD the initial clear time is somewhat deterministic because people are fast.
			-- Since we re-sync 95s before start this being off by +/- 15 seconds isn't as noticable (even if it's +/- 30 it's fine)
			timerCombatStart:Start(455 + 94.6)
		end
	elseif msg == "Pull2" and timerCombatStart then
		if timerCombatStart:IsStarted() then
			timerCombatStart:Update(455, 455 + 94.6)
		else
			timerCombatStart:Start()
		end
	end
end


--[[
Combat start after yells

      "<1018.87 13:52:41> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#3167#nil#0#false#false#false#false",
94.64 "<1113.51 13:54:16> [CLEU] SPELL_CAST_SUCCESS#66834#Player-5826-0233FD7B#Penno#Creature-0-5210-229-17836-10339-0000150DDD#Gyth#401556#Living Flame#nil#nil#nil#nil#nil#nil",
95.46 "<1114.33 13:54:17> [PLAYER_REGEN_DISABLED] +Entering combat!",

In this try I ran directly at him
      "<1038.56 19:31:20> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#18179#nil#0#false#false#false#false",
90.81 "<1129.37 19:32:51> [PLAYER_TARGET_CHANGED] 62 Hostile (elite Dragonkin) - Gyth # Creature-0-5209-229-21842-10339-0000252F3C",
94.61 "<1133.17 19:32:54> [CLEU] SPELL_CAST_SUCCESS#Player-5826-020CBDBB#Tandanu#Creature-0-5209-229-21842-10339-0000252F3C#Gyth#10448#Flame Shock#nil#nil#nil#nil#nil#nil",
94.65 "<1133.21 19:32:54> [PLAYER_REGEN_DISABLED] +Entering combat!",

No one ran at him
      "<684.40 12:22:41> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#1804#nil#0#false#false#false#false",
95.33 "<779.73 12:24:17> [CLEU] SWING_DAMAGE#Creature-0-5252-229-15748-10339-000024CAC6#Gyth#Player-5826-01FDC54A#Natarka#307#-1#nil#nil#false#false#nil#nil",
97.32 "<781.72 12:24:19> [PLAYER_REGEN_DISABLED] +Entering combat!",

Targeting as soon as possible, but no one was up front just waiting to attack
      "<922.44 01:13:04> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#9039#nil#0#false#false#false#false",
95.07 "<1017.51 01:14:39> [PLAYER_TARGET_CHANGED] 62 Hostile (elite Dragonkin) - Gyth # Creature-0-5250-229-385-10339-0000257F54",
95.72 "<1018.16 01:14:39> [CLEU] SPELL_CAST_SUCCESS#Player-5826-02011C01#Lisbeath#Creature-0-5250-229-385-10339-0000257F54#Gyth#10894#Shadow Word: Pain#nil#nil#nil#nil#nil#nil",
96.05 "<1018.49 01:14:40> [PLAYER_REGEN_DISABLED] +Entering combat!",

So looks like ~94.6 is the earliest you can attack him

Overall the RP does not seem to be just a simple timer :(
But at least in SoD people are clearing it *fast*, so it's mostly deterministic.

"<221.24 12:14:58> [CHAT_MSG_MONSTER_YELL] Excellent... it would appear as if the meddlesome insects have arrived just in time to feed my legion. Welcome, mortals!#Lord Victor Nefarius###Poolo##0#0##0#1362#nil#0#false#false#false#false",
"<229.38 12:15:06> [CHAT_MSG_MONSTER_YELL] Let not even a drop of their blood remain upon the arena floor, my children. Feast on their souls!#Lord Victor Nefarius###Poolo##0#0##0#1366#nil#0#false#false#false#false",
"<248.87 12:15:26> [CHAT_MSG_MONSTER_SAY] They have freed the human, Windsor, sire. It will not be long until Onyxia is uncovered.#Warchief Rend Blackhand###Lord Victor Nefarius##0#0##0#1385#nil#0#false#false#false#false",
"<529.05 12:20:06> [CHAT_MSG_MONSTER_YELL] Defilers!#Warchief Rend Blackhand###Poolo##0#0##0#1663#nil#0#false#false#false#false",
"<673.09 12:22:30> [CHAT_MSG_MONSTER_YELL] Curse you, mortal.#Lord Victor Nefarius###Leonax##0#0##0#1793#nil#0#false#false#false#false",
"<684.40 12:22:41> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#1804#nil#0#false#false#false#false",
"<686.00 12:22:43> [CHAT_MSG_MONSTER_YELL] With pleasure...#Warchief Rend Blackhand###Lord Victor Nefarius##0#0##0#1807#nil#0#false#false#false#false",
"<687.62 12:22:45> [CHAT_MSG_MONSTER_YELL] The Warchief shall make quick work of you, mortals. Prepare yourselves!#Lord Victor Nefarius#####0#0##0#1811#nil#0#false#false#false#false",
466.38 total

"<578.45 13:45:21> [CHAT_MSG_MONSTER_YELL] Excellent... it would appear as if the meddlesome insects have arrived just in time to feed my legion. Welcome, mortals!#Lord Victor Nefarius###Latjo##0#0##0#2880#nil#0#false#false#false#false",
"<586.57 13:45:29> [CHAT_MSG_MONSTER_YELL] Let not even a drop of their blood remain upon the arena floor, my children. Feast on their souls!#Lord Victor Nefarius###Latjo##0#0##0#2886#nil#0#false#false#false#false",
"<604.41 13:45:47> [CHAT_MSG_MONSTER_YELL] Concentrate your attacks upon the healer!#Lord Victor Nefarius###Lagrosemoula##0#0##0#2900#nil#0#false#false#false#false",
"<617.33 13:46:00> [CHAT_MSG_MONSTER_SAY] The next clutch is due to hatch soon, sire. We will be ready to launch the attacks by week's end.#Warchief Rend Blackhand###Lord Victor Nefarius##0#0##0#2909#nil#0#false#false#false#false",
"<622.20 13:46:05> [CHAT_MSG_MONSTER_SAY] Sssplendid... Then let us watch as my children tear these mortals to pieces.#Lord Victor Nefarius###Warchief Rend Blackhand##0#0##0#2916#nil#0#false#false#false#false",
"<672.43 13:46:55> [CHAT_MSG_MONSTER_YELL] Concentrate your attacks upon the healer!#Lord Victor Nefarius###Tzeppu##0#0##0#2952#nil#0#false#false#false#false",
"<811.58 13:49:14> [CHAT_MSG_MONSTER_YELL] You will learn of the sanctuary only death can offer...#Warchief Rend Blackhand###Tzeppu##0#0##0#3056#nil#0#false#false#false#false",
"<1015.67 13:52:38> [CHAT_MSG_MONSTER_YELL] Impossible!#Warchief Rend Blackhand###Tzeppu##0#0##0#3162#nil#0#false#false#false#false",
"<1018.87 13:52:41> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#3167#nil#0#false#false#false#false",
"<1020.47 13:52:43> [CHAT_MSG_MONSTER_YELL] With pleasure...#Warchief Rend Blackhand###Lord Victor Nefarius##0#0##0#3168#nil#0#false#false#false#false",
"<1022.10 13:52:45> [CHAT_MSG_MONSTER_YELL] The Warchief shall make quick work of you, mortals. Prepare yourselves!#Lord Victor Nefarius#####0#0##0#3170#nil#0#false#false#false#false",
443.65 total

"<567.27 19:23:28> [CHAT_MSG_MONSTER_YELL] Excellent... it would appear as if the meddlesome insects have arrived just in time to feed my legion. Welcome, mortals!#Lord Victor Nefarius###Tandanu##0#0##0#17712#nil#0#false#false#false#false",
"<575.36 19:23:37> [CHAT_MSG_MONSTER_YELL] Let not even a drop of their blood remain upon the arena floor, my children. Feast on their souls!#Lord Victor Nefarius###Tandanu##0#0##0#17718#nil#0#false#false#false#false",
"<601.14 19:24:02> [CHAT_MSG_MONSTER_SAY] Then we must not waste anymore time. Are the chromatic dragonflight ready?#Lord Victor Nefarius###Warchief Rend Blackhand##0#0##0#17749#nil#0#false#false#false#false",
"<606.09 19:24:07> [CHAT_MSG_MONSTER_SAY] The next clutch is due to hatch soon, sire. We will be ready to launch the attacks by week's end.#Warchief Rend Blackhand###Lord Victor Nefarius##0#0##0#17754#nil#0#false#false#false#false",
"<610.76 19:24:12> [CHAT_MSG_MONSTER_SAY] Sssplendid... Then let us watch as my children tear these mortals to pieces.#Lord Victor Nefarius###Warchief Rend Blackhand##0#0##0#17761#nil#0#false#false#false#false",
"<884.57 19:28:46> [CHAT_MSG_MONSTER_YELL] Your efforts will prove fruitless. None shall stand in our way!#Lord Victor Nefarius###Moderjord##0#0##0#18040#nil#0#false#false#false#false",
"<1019.21 19:31:00> [CHAT_MSG_MONSTER_YELL] Curse you, mortal.#Lord Victor Nefarius###Teryelmoo##0#0##0#18162#nil#0#false#false#false#false",
"<1027.18 19:31:08> [CHAT_MSG_MONSTER_YELL] Concentrate your attacks upon the healer!#Lord Victor Nefarius###Chawdow##0#0##0#18170#nil#0#false#false#false#false",
"<1038.56 19:31:20> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#18179#nil#0#false#false#false#false",
"<1040.21 19:31:21> [CHAT_MSG_MONSTER_YELL] With pleasure...#Warchief Rend Blackhand###Lord Victor Nefarius##0#0##0#18183#nil#0#false#false#false#false",
"<1041.83 19:31:23> [CHAT_MSG_MONSTER_YELL] The Warchief shall make quick work of you, mortals. Prepare yourselves!#Lord Victor Nefarius#####0#0##0#18185#nil#0#false#false#false#false",
474.56 total

"<475.10 01:05:36> [CHAT_MSG_MONSTER_YELL] Excellent... it would appear as if the meddlesome insects have arrived just in time to feed my legion. Welcome, mortals!#Lord Victor Nefarius###Aliani##0#0##0#8707#nil#0#false#false#false#false",
"<483.21 01:05:45> [CHAT_MSG_MONSTER_YELL] Let not even a drop of their blood remain upon the arena floor, my children. Feast on their souls!#Lord Victor Nefarius###Aliani##0#0##0#8711#nil#0#false#false#false#false",
"<505.90 01:06:07> [CHAT_MSG_MONSTER_YELL] Curse you, mortal.#Lord Victor Nefarius###Aliani##0#0##0#8721#nil#0#false#false#false#false",
"<570.62 01:07:12> [CHAT_MSG_MONSTER_YELL] I promise you an eternity of dung clean up duty for that failure!#Lord Victor Nefarius###Orcalas##0#0##0#8772#nil#0#false#false#false#false",
"<898.14 01:12:39> [CHAT_MSG_MONSTER_YELL] Do not consume the entire corpse just yet, children! Save room for dessert!#Lord Victor Nefarius#####0#0##0#9017#nil#0#false#false#false#false",
"<898.14 01:12:39> [CHAT_MSG_MONSTER_YELL] I want those boots! Nobody touch that corpse!#Warchief Rend Blackhand#####0#0##0#9018#nil#0#false#false#false#false",
"<904.63 01:12:46> [CHAT_MSG_MONSTER_YELL] Concentrate your attacks upon the healer!#Lord Victor Nefarius###Lisbeath##0#0##0#9026#nil#0#false#false#false#false",
"<922.44 01:13:04> [CHAT_MSG_MONSTER_YELL] THIS CANNOT BE!!! Rend, deal with these insects.#Lord Victor Nefarius#####0#0##0#9039#nil#0#false#false#false#false",
"<923.96 01:13:05> [CHAT_MSG_MONSTER_YELL] With pleasure...#Warchief Rend Blackhand###Lord Victor Nefarius##0#0##0#9040#nil#0#false#false#false#false",
"<925.69 01:13:07> [CHAT_MSG_MONSTER_YELL] The Warchief shall make quick work of you, mortals. Prepare yourselves!#Lord Victor Nefarius#####0#0##0#9043#nil#0#false#false#false#false",
450.59 total -- this was a "clean" run, doing everything as intended, i.e., no weird extra pulls through the walls, at least the long ones definitely had the extra pulls

]]
