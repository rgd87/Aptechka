local _, helpers = ...
-- RAID/PVP config loading
-- instances are identified by map id (assuming they have their own map).
-- to find out current zone map id type: /dump C_Map.GetBestMapForUnit("player")
-- OR
-- Open dungeon in Encounter Journal and type: /dump EJ_GetInstanceInfo(), 7th return value will be the mapID
-- Getting Spell IDs from Encounter Journal:
-- Mouseover the spell and use this macro /dump GetMouseFocus():GetParent().spellID
AptechkaDefaultConfig.MapIDs = {
    [147] = "Ulduar",
    -- This table used to be map IDs, but now it's just used to content relevance sorting

    [934] = "Atal'Dazar",
    [936] = "Freehold",
    [974] = "Tol Dagor",
    [1004] = "Kings Rest",
    [1010] = "The MOTHERLODE!!",
    [1015] = "Waycrest Manor",
    [1038] = "Temple of Sethraliss",
    [1039] = "Shrine of the Storm",
    [1041] = "The Underrot",
    [1162] = "Siege of Boralus",
    [1148] = "Uldir",

    [1469] = "Horrific Visions", -- Orgrimmar
    [1470] = "Horrific Visions", -- Stormwind

    [1490] = "Operation: Mechagon",

    [1580] = "Ny'alotha", -- Wrathion room
    [1581] = "Ny'alotha",
    [1600] = "Mythic+ 8.3",

    [1663] = "Halls of Atonement",
    [1666] = "The Necrotic Wake",
    [1669] = "Mists of Tirna Scithe",
    [1674] = "Plaguefall",
    [1675] = "Sanguine Depths",
    [1679] = "De Other Side",
    [1683] = "Theater of Pain",
    [1693] = "Spires of Ascension",

    [1701] = "PvP",

    [1735] = "Castle Nathria",

    [704] = "Halls of Valor",
    [706] = "Maw of Souls",
    [731] = "Neltharion's Lair",
    [733] = "Darkheart Thicket",
    [751] = "Black Rook Hold",
}

AptechkaDefaultConfig.defaultDebuffHighlights = {
    ["PvP"] = {
        [207736] = { 207736, 3, "Shadowy Duel" },
        [212183] = { 212183, 3, "Smoke Bomb" },
        [33786] = { 33786, 3, "Cyclone" },
    },
    ["Castle Nathria"] = {

        -- [342077] = { 342077, 1, "Shriekwing, Echolocation" },
        [343303] = { 343303, 3, "Shriekwing, Blood Lantern" },
        [343024] = { 343024, 2, "Shriekwing, Horrified" },

        -- [334971] = { 334971, 1, "Huntsman Altimor, Margore, Jagged Claws" },

        [341473] = { 341473, 1, "Kael'thas, Bleakwing Assassin, Crimson Flurry" },
        -- [328889] = { 328889, 4, "Kael'thas, Greater Castigation" },
        -- [332871] = { 332871, 4, "Kael'thas, Greater Castigation" },

        [325236] = { 325236, 4, "Artificer Xy'mox, Glyph of Destruction" },
        [326302] = { 326302, 3, "Artificer Xy'mox, Stasis Trap" },
        [340860] = { 340860, 1, "Artificer Xy'mox, Withering Touch" },
        -- [328468] = { 328468, 2, "Artificer Xy'mox, Displacement Cypher" },
        -- [328448] = { 328448, 2, "Artificer Xy'mox, Displacement Cypher" },

        [329298] = { 329298, 3, "Hungering Destroyer, Gluttonous Miasma" },
        -- [334064] = { 334064, 1, "Hungering Destroyer, Volatile Ejection" },

        [340477] = { 340477, 2, "Lady Inerva Darkvein, Highly Concentrated Anima (Mythic)" },
        [325382] = { 325382, 1, "Lady Inerva Darkvein, Warped Desires" },
        [340452] = { 340452, 3, "Lady Inerva Darkvein, Change of Heart" },
        -- [324982] = { 324982, 4, "Lady Inerva Darkvein, Shared Suffering" },
        -- [324983] = { 324983, 4, "Lady Inerva Darkvein, Shared Suffering" },

        [346651] = { 346651, 4, "Blood Council, Drain Essence" },

        -- [331209] = { 331209, 1, "Sludgefist, Hateful Gaze" },
        -- [335354] = { 335354, 1, "Sludgefist, Chain Slam" },

        -- [334765] = { 334765, 2, "Stone Legion Generals, Kaal, Heart Rend" },
        -- [333377] = { 333377, 2, "Stone Legion Generals, Kaal, Wicked Mark" },
        [334771] = { 334771, 1, "Stone Legion Generals, Kaal, Heart Hemorrhage" },
        [342735] = { 342735, 4, "Stone Legion Generals, Kaal, Ravenous Feast" },


        [329951] = { 329951, 2, "Sire Denathrius, Impale" },
        [341732] = { 341732, 3, "Sire Denathrius, Searing Censure" },
        [332794] = { 332794, 1, "Sire Denathrius, Fatal Finesse" },
        [332797] = { 332797, 1, "Sire Denathrius, Fatal Finesse" },

        -- [25163] = { 25163, 3, "Placeholder Disgusting Oozeling" },
    },
    ["Halls of Atonement"] = {
        [326607] = { 326607, 3, "Stoneborn Reaver, Turn to Stone" },
        [322977] = { 322977, 1, "Halkias, Sinlight Visions" },
        [325701] = { 325701, 1, "Depraved Collector, Siphon Life" },
    },
    ["Theater of Pain"] = {
        [320069] = { 320069, 1, "Dessia the Decapitator, Mortal Strike" },
        [323831] = { 323831, 3, "Mordretha, Death Grasp" },
        [330608] = { 330608, 2, "Rancid Gasbag, Vile Eruption" },
        [341949] = { 341949, 1, "Blighted Sludge-Spewer, Withering Blight from Withering Discharge" },
        -- [319626] = { 319626, 1, "Kul'tharok, Phantasmal Parasite" },
        [319539] = { 319539, 2, "Kul'tharok, Soulless" },
    },
    ["Spires of Ascension"] = {
        [323744] = { 323744, 1, "Forsworn Stealthclaw, Pounce" },
        [324154] = { 324154, 1, "Ventunax, Dark Stride" },
    },
    ["Sanguine Depths"] = {
        [322554] = { 322554, 4, "Executor Tarvold, Castigate" },
        [326836] = { 326836, 3, "Oppressor/Overseer, Curse of Suppression (Silence)" },
        [336277] = { 336277, 2, "Remnant of Fury, Explosive Anger" },
    },
    ["The Necrotic Wake"] = {
        -- 320596/heaving-retch -- Blightbone dot
        -- 320462 -- Necrotic bolt debuff, blacklist?
        -- [323198] = { 323198, 1, "Nalthor, Dark Exile" },
        [334748] = { 334748, 3, "Corpse Harvester, Drain Fluids" },
        [338606] = { 338606, 1, "Separation Assistant, Morbid Fixation" },
        [343556] = { 343556, 1, "Surgeon Stitchflesh, Morbid Fixation" },

    },
    ["Plaguefall"] = {
        [329110] = { 329110, 1, "Docktor Ickus, Slime Injection" },
        [325552] = { 325552, 1, "Domina Venomblade, Cryotoxic Slash" },
    },
    ["Mists of Tirna Scithe"] = {
        -- [322563] = { 322563, 1, "Tred'ova, Marked Prey" },
        -- [337253] = { 337253, 1, "Tred'ova, Parasitic Domination MC" },
        [322557] = { 322557, 2, "Drust Soulcleaver, Soul Split" },
        [321968] = { 321968, 1, "Tirnenn Villager, Bewildering Pollen" },
        -- [322486] = { 322486, 1, "Tirnenn Villager, Overgrowth" },
        [322487] = { 322487, 1, "Tirnenn Villager, Overgrowth Stun" },
        [323137] = { 321968, 1, "Droman Oulfarran, Bewildering Pollen" },
        [321891] = { 321891, 1, "Mistcaller Vulpin, Freeze Tag Fixation" },
        -- 325224 -- Mistveil Stinger, Anima Injection, If Anima Injection expires, Anima Detonation is triggered.
    },
    ["De Other Side"] = {
        [332605] = { 332605, 1, "Atal'ai Hoodoo Hexxer, Hex" },
        [334505] = { 334505, 3, "Shimmerdust Sleep" },
    },
    ["Mythic+ 8.3"] = {
        [314308] = { 314308, 1, "Spirit Breaker, increase all damage taken by 100% for 8 sec." },
    },
    ["Horrific Visions"] = {
        [306965] = { 306965, 1, "Madness: Dark Delusions Stun" },
        [306545] = { 306545, 2, "Madness: Haunting Shadows Fear" },
        [316510] = { 316510, 2, "Madness: Split Personality Disorient" },
        [298033] = { 298033, 1, "K'thir Dominator and SI:7 Informant, Touch of the Abyss" },
        [300530] = { 300530, 1, "K'thir Mindcarver, Mind Carver" },
        [298514] = { 298514, 1, "Aqiri Mind Toxin Stun" },
        -- [11641] = { 11641, 1, "Bwemba, Hex" },
        [304969] = { 304969, 1, "Inquisitor Gnshal, Void Torrent Stun" },
        -- [304634] = { 304634, 1, "Oblivion Elemental, Despair Stun" },
        [304350] = { 304350, 1, "Rexxar, Mind Trap Stun" },
        -- [306726] = { 306726, 1, "Vez'okk the Lightless, Defiled Ground Stun" },
        -- [306646] = { 306646, 1, "Vez'okk the Lightless, Ring of Chaos Stun" },
        -- [305378] = { 305378, 1, "Voidbound Honor Guard, Horrifying Shout Fear" },
        -- [298630] = { 298630, 1, "Voidbound Shieldbearer, Shockwave Stun" },
        -- Agustus Moulaine Stun
        [309648] = { 309648, 1, "Magister Umbric, Tainted Polymorph" },
        [309882] = { 309882, 1, "Cultist Slavedriver, Brutal Smash" },
        -- Fallen Riftwalker, Rift Strike
        [308380] = { 308380, 3, "Inquisitor Darkspeak, Convert" }, -- Will normal MC pick it up?
        -- 308375 Portal Keeper, Psychic Scream
        -- [298770] = { 298770, 1, "Slavemaster Ul'rok, Chains of Servitude Stun" },
    },
    ["Ny'alotha"] = {
        [314992] = { 314992, 1, "Maut, Drain Essence" },

        [307645] = { 307645, 1, "Vexiona, Heart of Darkness fear" },
        [310224] = { 310224, 1, "Vexiona, Annihilation" },

        [310361] = { 310361, 1, "Drest'agath, Unleashed Insanity stun" },

        [312486] = { 312486, 1, "Il'gynoth, Recurring Nightmare" },

        [313400] = { 313400, 1, "N'Zoth, the Corruptor, Corrupted Mind" },
        [313793] = { 313793, 1, "N'Zoth, the Corruptor, Flames of Insanity disorient" },
    },

    ["Operation: Mechagon"] = {
        [294929] = { 294929, 1, "K.U.-J.0., Blazing Chomp" },
        [299572] = { 299572, 3, "Mechagon Renormalizer, Shrink" },
    },
    ["Freehold"] = {
        [258323] = { 258323, 1, "Infected Wound" },
        [257908] = { 257908, 1, "Oiled Blade" },
    },

    ["Shrine of the Storm"] = {
        [268233] = { 268233, 1, "Electrifying Shock" },
    },

    ["Temple of Sethraliss"] = {
        [280032] = { 280032, 1, "Neurotoxin" },
        [268008] = { 268008, 1, "Snake Charm" },
        [263958] = { 263958, 1, "A Knot of Snakes" },
    },

    ["Atal'Dazar"] = {
        [257407] = { 257407, 1, "Pursuit" },
    },

    ["Waycrest Manor"] = {
        [260741] = { 260741, 1, "Jagged Nettles" },
        [267907] = { 267907, 1, "Soul Thorns" },
        [268202] = { 268202, 1, "Death Lens" },
        [263891] = { 263891, 1, "Grasping Thorns" },
    },

    ["Kings Rest"] = {
        [270920] = { 270920, 1, "Seduction" },
        [270865] = { 270865, 1, "Hidden Blade" },
        [270487] = { 270487, 1, "Severing Blade" },
    },

    ["The Underrot"] = {
        [278961] = { 278961, 1, "Decaying Mind" },
    },

    ["Siege of Boralus"] = {
        [272571] = { 272571, 1, "Choking Waters" },
    },

    --[[
    ["Ulduar"] = {
        [64125] = { 64125, 1, "Squeeze, Yogg-Saron" },
        [62717] = { 62717, 1, "Slag Pot, Ignis" },
        [61903] = { 61903, 1, "Fusion Punch, Assembly of Iron" },
        [64290] = { 64290, 1, "Stone Grip, Kologarn" },
    },
    ]]
}



local A = helpers.AddLoadableAura

local color1 = { 0.9, 0, 0 }
local color2 = { 0.6, 0, 1 }
local green = {0,1,0}
local teal = { 42/255, 201/255, 154/255 }
local light = { 178/255, 150/255, 150/255}
local healred = { 147/255, 54/255, 115/255 }

local BossDebuff = { type = "HARMFUL", assignto = "bossdebuff", color = color1, priority = 40, pulse = true }
AptechkaDefaultConfig.BossDebuffPrototype = BossDebuff

AptechkaDefaultConfig.LoadableDebuffs = {
--[[
    ["Ny'alotha"] = function()
        A{ id = 314992, prototype = BossDebuff } -- Maut, Drain Essence

        A{ id = 307645, prototype = BossDebuff } -- Vexiona, Heart of Darkness fear
        A{ id = 310224, prototype = BossDebuff } -- Vexiona, Annihilation

        A{ id = 310361, prototype = BossDebuff } -- Drest'agath, Unleashed Insanity stun

        A{ id = 312486, prototype = BossDebuff } -- Il'gynoth, Recurring Nightmare

        A{ id = 313400, prototype = BossDebuff } -- N'Zoth, the Corruptor, Corrupted Mind
        A{ id = 313793, prototype = BossDebuff } -- N'Zoth, the Corruptor, Flames of Insanity disorient
    end,

    ["Freehold"] = function()
        A{ id = 258323, prototype = BossDebuff } -- Infected Wound
        A{ id = 257908, prototype = BossDebuff } -- Oiled Blade
    end,
    ["Shrine of the Storm"] = function()
        A{ id = 268233, prototype = BossDebuff } -- Electrifying Shock
    end,
    ["Temple of Sethraliss"] = function()
        A{ id = 280032, prototype = BossDebuff } -- Neurotoxin
        A{ id = 268008, prototype = BossDebuff } -- Snake Charm
        A{ id = 263958, prototype = BossDebuff } -- A Knot of Snakes
    end,

    ["Atal'Dazar"] = function()
        A{ id = 257407, prototype = BossDebuff } -- Pursuit
    end,

    ["Waycrest Manor"] = function()
        A{ id = 260741, prototype = BossDebuff } -- Jagged Nettles
        A{ id = 267907, prototype = BossDebuff } -- Soul Thorns
        A{ id = 268202, prototype = BossDebuff } -- Death Lens
        A{ id = 263891, prototype = BossDebuff } -- Grasping Thorns
    end,

    ["Kings Rest"] = function()
        A{ id = 270920, prototype = BossDebuff } -- Seduction
        A{ id = 270865, prototype = BossDebuff } -- Hidden Blade
    end,

    ["The Underrot"] = function()
        A{ id = 278961, prototype = BossDebuff } -- Decaying Mind
    end,

    ["Siege of Boralus"] = function()
        A{ id = 272571, prototype = BossDebuff } -- Choking Waters
    end,
]]


    -- ["Emerald Nightmare"] = function()
    --     A{ id = 222719, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Осквернение, треш

    --     A{ id = 203097, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Nythendra, Rot
    --     A{ id = 204470, color = green, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Nythendra, Volatile Rot
    --     A{ id = 205043, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Nythendra, Infested Mind

    --     A{ id = 215449, color = green, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Elerethe Renferal, Necrotic Venom
    --     A{ id = 210863, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Elerethe Renferal, Twisting Shadows
    --     A{ id = 212993, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Elerethe Renferal, Shimmering Feather

    --     A{ id = 210099, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Il'gynoth, Ooze fixate

    --     A{ id = 198006, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Ursoc, charge target
    -- end,

    -- ["Black Rook Hold"] = function()
    --     A{ id = 194966, color = color2, prototype = BossDebuff } -- Amalgam of Souls, Soul Echoes

    --     A{ id = 200261, prototype = BossDebuff } -- Stun, Soul-Torn Champion
    --     A{ id = 197974, color = teal, prototype = BossDebuff } -- Stun, Soul-Torn Vanguard

    --     A{ id = 197546, prototype = BossDebuff } -- Illysanna Ravencrest, Brutal Glaive
    --     A{ id = 197687, prototype = BossDebuff } -- Illysanna Ravencrest, Eye Beamsr2

    --     A{ id = 198079, prototype = BossDebuff } -- Smashspite, Hateful Gaze

    --     A{ id = 214002, prototype = BossDebuff } -- Risen Lancers, Raven's Dive
    -- end,

    -- ["Darkheart Thicket"] = function()
    --     A{ id = 225484, prototype = BossDebuff } -- Frenzied Nightclaw, Grievous Rip
    --     A{ id = 198477, color = color2, prototype = BossDebuff } -- Nightmare Abomination, Fixate

    --     A{ id = 196376, prototype = BossDebuff } -- Archdruid Glaidalis, Grievous Tear


    --     A{ id = 198904, prototype = BossDebuff } -- Rotheart Dryads, Poison Spear
    --     A{ id = 201842, color = color2, prototype = BossDebuff } -- Taintheart Summoners, Curse of Isolation

    --     A{ id = 204611, prototype = BossDebuff } -- Oakheart, Crushing Grip

    --     A{ id = 200238, prototype = BossDebuff } -- Shade of Xavius, Feed on the Weak
    --     A{ id = 200289, color = color2, priority = 30, prototype = BossDebuff } -- Shade of Xavius, Feed on the Weak
    -- end,

    -- ["Neltharion's Lair"] = function()
    --     A{ id = 202181, prototype = BossDebuff } -- Basilisks, Stone Gaze

    --     A{ id = 205549, color = color2, prototype = BossDebuff } -- Naraxas, Rancid Maw
    --     A{ id = 199705, prototype = BossDebuff } -- Naraxas, Devouring

    --     A{ id = 200154, prototype = BossDebuff } -- Colossal Charskin, Burning Hatred
    --     A{ id = 193585, color = color2, prototype = BossDebuff } -- Rockbound Trapper, Bound
    -- end,


    -- ["Maw of Souls"] = function()
    --     A{ id = 202181, prototype = BossDebuff } -- Seacursed Soulkeeper, Brackwater Blast
    --     -- Trace{id = 193460, type = "DAMAGE", assignto = { "bossdebuff" }, color = color2, fade = 0.7, priority = 45 } -- Bane, Ymiron
    -- end,

    -- ["Halls of Valor"] = function()
    --     A{ id = 198599, prototype = BossDebuff } -- Громовой удар, треш
    --     A{ id = 196838, prototype = BossDebuff } -- Fenrir, Scent of Blood
    -- end,

    -- ["Throne of Thunder"] = function()
    --     A{ id = 138006, prototype = AptechkaUserConfig.BossDebuffPrototype } --Electrified Waters
    --     A{ id = 137399, prototype = AptechkaUserConfig.BossDebuffPrototype } --Focused Lightning
    --     A{ id = 138732, prototype = AptechkaUserConfig.BossDebuffPrototype } --Ionization
    --     A{ id = 138349, prototype = AptechkaUserConfig.BossDebuffPrototype } --Static Wound
    --     A{ id = 137371, prototype = AptechkaUserConfig.BossDebuffPrototype } --Thundering Throw
    --     A{ id = 136769, prototype = AptechkaUserConfig.BossDebuffPrototype } --Charge
    --     A{ id = 136767, prototype = AptechkaUserConfig.BossDebuffPrototype } --Triple Puncture
    --     A{ id = 136708, prototype = AptechkaUserConfig.BossDebuffPrototype } --Stone Gaze
    --     A{ id = 136723, prototype = AptechkaUserConfig.BossDebuffPrototype } --Sand Trap
    --     A{ id = 136587, prototype = AptechkaUserConfig.BossDebuffPrototype } --Venom Bolt Volley (dispellable)
    --     A{ id = 136710, prototype = AptechkaUserConfig.BossDebuffPrototype } --Deadly Plague
    --     A{ id = 136670, prototype = AptechkaUserConfig.BossDebuffPrototype } --Mortal Strike
    --     A{ id = 136573, prototype = AptechkaUserConfig.BossDebuffPrototype } --Frozen Bolt (Debuff used by frozen orb)
    --     A{ id = 136512, prototype = AptechkaUserConfig.BossDebuffPrototype } --Hex of Confusion
    --     A{ id = 136719, prototype = AptechkaUserConfig.BossDebuffPrototype } --Blazing Sunlight
    --     A{ id = 136654, prototype = AptechkaUserConfig.BossDebuffPrototype } --Rending Charge
    --     A{ id = 140946, prototype = AptechkaUserConfig.BossDebuffPrototype } --Dire Fixation (Heroic Only)
    -- end,

    -- ["Terrace of Endless Spring"] = function()
    --     A{ id = 111850, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Prison
    -- end,
    -- ["Heart of Fear"] = function()
    --     A{ id = 125390, prototype = AptechkaUserConfig.BossDebuffPrototype } --fixate, empress, windblades
    --     A{ id = 124862, prototype = AptechkaUserConfig.BossDebuffPrototype } --visions of demise, empress
    --     A{ id = 122370, prototype = AptechkaUserConfig.BossDebuffPrototype } --abomination
    --     A{ id = 122740, prototype = AptechkaUserConfig.BossDebuffPrototype } --zor'loc mc
    -- end,
    -- ["MogushanVaults"] = function()
    -- end,
    -- ["ShadoPanMonastery"] = function()
    --     A{ id = 115509, prototype = AptechkaUserConfig.BossDebuffPrototype } --Thundering Fist, first adds
    --     A{ id = 106872, prototype = AptechkaUserConfig.BossDebuffPrototype } --Sha of Violence, Disorient
    -- end,
    -- ["DragonSoul"] = function()
    --     A{ id = 100460, prototype = AptechkaUserConfig.BossDebuffPrototype } --Disrupting Shadows, Warlord Zon'ozz

    --     A{ id = 109325, priority = 35, prototype = AptechkaUserConfig.BossDebuffPrototype } --Frostflake, Hagara the Stormbinder
    --     A{ id = 104451, color = { 0.2, 0.2, 1 }, priority = 50, prototype = AptechkaUserConfig.BossDebuffPrototype } --Ice Tomb, Hagara the Stormbinder
    --     -- A{ id = 105369, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Conduit, Hagara the Stormbinder
    --     A{ id = 105927, prototype = AptechkaUserConfig.BossDebuffPrototype } --Faded into Twilight, Hagara the Stormbinder

    --     A{ id = 107558, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Degeneration, Warmaster Blackhorn
    --     A{ id = 107567, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Brutal Strike, Warmaster Blackhorn
    --     A{ id = 108043, priority = 50, prototype = AptechkaUserConfig.BossDebuffPrototype } --Sunder Armor, Warmaster Blackhorn

    --     A{ id = 105479, priority = 50, color = color2,  prototype = AptechkaUserConfig.BossDebuffPrototype } --Searing Plasma, Spine of Deathwing
    --     A{ id = 105490, priority = 51, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Grip, Spine of Deathwing

    --     A{ id = 106730, prototype = AptechkaUserConfig.BossDebuffPrototype } --Tetanus, Madness of Deathwing
    -- end,
    -- ["Firelands"] = function()
    --     --A{ id = 100249, prototype = AptechkaUserConfig.BossDebuffPrototype } --Combustion, Ragnaros
    --     A{ id = 98981, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lava Bolt, Ragnaros
    --     A{ id = 100460, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Blazing Heat, Ragnaros

    --     A{ id = 98443, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Cyclone, Majordomo Staghelm
    --     A{ id = 98450, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Searing Seeds, Majordomo Staghelm

    --     A{ id = 99516, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Countdown, Baleroc
    --     A{ id = 99403, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Tormented, Baleroc
    --     A{ id = 99256, prototype = AptechkaUserConfig.BossDebuffPrototype } --Torment, Baleroc

    --     A{ id = 99936, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Jagged Tear, Shannox
    --     A{ id = 99837, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Crystal Prison Trap Effect, Shannox
    --     A{ id = 101208, color = { 1, 0.27, 0}, prototype = AptechkaUserConfig.BossDebuffPrototype } --Immolation Trap, Shannox

    --     A{ id = 99308, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Gushing Wound, Alysrazor

    --     A{ id = 98492, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Eruption, Lord Rhyolith

    --     --A{ id = 97202, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Web Spin, Cinderweb Spinner, Beth'tilac
    --     A{ id = 49026, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fixate, Cinderweb Drone, Beth'tilac
    -- end,

    -- ["ZulGurub"] = function()
    --     A{ id = 96776, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Bloodletting, Mandokir
    --     A{ id = 96478, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Toxis Link, Venoxis
    -- end,

    -- ["ZulAman"] = function()
    --     A{ id = 97300, prototype = AptechkaUserConfig.BossDebuffPrototype } --Electrical Storm, Akil'zon

    --     A{ id = 97811, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lacerating Slash, Nalorakk
    --     A{ id = 42402, prototype = AptechkaUserConfig.BossDebuffPrototype } --Surge, Nalorakk

    --     A{ id = 97490, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Flame Shock, Halazzi
    --     A{ id = 99284, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fixate, Halazzi

    --     A{ id = 97639, prototype = AptechkaUserConfig.BossDebuffPrototype } --Grievous Throw, Daakara
    --     A{ id = 97672, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Claw Rage, Daakara
    --     A{ id = 97639, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lynx Rush, Daakara (dot)
    --     A{ id = 42402, prototype = AptechkaUserConfig.BossDebuffPrototype } --Surge, Daakara
    -- end,

    -- ["Bastion of Twilight"] = function()
    --     A{ id = 92878, prototype = AptechkaUserConfig.BossDebuffPrototype } --Blackout, Valiona
    --     A{ id = 88518, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Twilight Meteorite, Valiona

    --     A{ id = 82762, color = {0.3,0.3,1}, priority = 38, prototype = AptechkaUserConfig.BossDebuffPrototype } --Waterlogged,Feludius
    --     A{ id = 82660, color = {1,0.2,0.2}, priority = 38, prototype = AptechkaUserConfig.BossDebuffPrototype } --Burning Blood,Ignacious
    --     A{ id = 83099, color = {0.3,0.3,1}, priority = 38, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Rod,Arion
    --     A{ id = 92067, color = {1,1,0.2}, prototype = AptechkaUserConfig.BossDebuffPrototype } --Static Overload,Arion,Heroic
    --     A{ id = 92075, color = {122/255,85/255,49/255}, prototype = AptechkaUserConfig.BossDebuffPrototype } --Gravity Core,Terrastra,Heroic

    --     --Magic--A{ id = 81836, prototype = AptechkaUserConfig.BossDebuffPrototype } --Corruption: Accelerated,Cho'gall
    --     A{ id = 93202, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Corruption: Sickness,Cho'gall
    --     A{ id = 93204, prototype = AptechkaUserConfig.BossDebuffPrototype } --Conversion,Cho'gall
    --     --A{ id = 93133, prototype = AptechkaUserConfig.BossDebuffPrototype } --Debilitating Beam,Cho'gall

    --     A{ id = 93133, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Wrack,Lady Sinestra
    -- end,

    -- ["Blackwing Descent"] = function()
    --     A{ id = 91911, prototype = AptechkaUserConfig.BossDebuffPrototype } --Constricting Chains, Magmaw

    --     A{ id = 82881, prototype = AptechkaUserConfig.BossDebuffPrototype } --Break, Chimaeron

    --     A{ id = 91431, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Conductor, Omnitron Defense System
    --     A{ id = 91502, color = {230/255, 117/255, 230/255 }, prototype = AptechkaUserConfig.BossDebuffPrototype } --Poison Soaked Shell, Omnitron Defense System

    --     A{ id = 92973, prototype = AptechkaUserConfig.BossDebuffPrototype } --Consuming Flames, Maloriak
    --     A{ id = 92978, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Flash Freeze, Maloriak
    -- end,

    -- ["TotFW"] = function()
    --     A{ id = 89666, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Rod
    --     A{ id = 89104, prototype = AptechkaUserConfig.BossDebuffPrototype } --Relentless Storm
    -- end,

    -- ["Ruby Sanctum"] = function()
    --     A{ id = 74562, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Combustion
    --     A{ id = 74792, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2 } --Soul Consumptio
    -- end,

    -- ["Icecrown Citadel"] = function()
    --     --A{ id = 69075, prototype = AptechkaUserConfig.BossDebuffPrototype } --Bone Storm dot, Lord Marrowgar
    --     A{ id = 69062, prototype = AptechkaUserConfig.BossDebuffPrototype } --Impale, Lord Marrowgar
    --     --A{ id = 71289, prototype = AptechkaUserConfig.BossDebuffPrototype } --Dominate Mind, Lady Deathwhisper
    --     A{ id = 72442, prototype = AptechkaUserConfig.BossDebuffPrototype } --Boiling Blood, Deathbringer Saurfang
    --     A{ id = 72444, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 50 } --Mark of the Fallen Champion, Deathbringer Saurfang
    --     A{ id = 69279, prototype = AptechkaUserConfig.BossDebuffPrototype } --Gas Cloud, Festergut
    --     A{ id = 71288, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 50 } --Vile Gas, Festergut
    --     A{ id = 73022, prototype = AptechkaUserConfig.BossDebuffPrototype } --Mutated Infection, Rotface
    --     A{ id = 71340, prototype = AptechkaUserConfig.BossDebuffPrototype } --Pact of the Darkfallen, Blood-Queen Lana'thel
    --     A{ id = 71530, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 30 } --Essence of the Blood Queen, Blood-Queen Lana'thel
    --     A{ id = 70157, prototype = AptechkaUserConfig.BossDebuffPrototype } --Ice Tomb, Sindragosa

    --     --A{ id = 70337, prototype = AptechkaUserConfig.BossDebuffPrototype } --Necrotic Plague, Lich King, phase 1 & 2  // still broken in 3.3.3
    --     A{ id = 68980, prototype = AptechkaUserConfig.BossDebuffPrototype, showDuration = true, priority = 50 } --Harvest Soul, Lich King, phase 3
    --     A{ id = 70541, prototype = AptechkaUserConfig.BossDebuffPrototype, color = {230/255, 117/255, 230/255 }, priority = 20 } --Infest, Lich King
    --     A{ id = 69409, prototype = AptechkaUserConfig.BossDebuffPrototype, priority = 25, showDuration = true } --Soul Reaver debuff, Lich King
    --     --AptechkaUserConfig.LoadableDebuffs.tankcooldowns()
    -- end,


    -- ["Trial of the Crusader"] = function()
    --     A{ id = 66237, prototype = AptechkaUserConfig.BossDebuffPrototype } --Incinerate Flesh, Lord Jaraxxus
    --     A{ id = 68510, prototype = AptechkaUserConfig.BossDebuffPrototype } --Penetrating Cold, Anub'arak
    --     A{ id = 67281, prototype = AptechkaUserConfig.BossDebuffPrototype } --Touch of Darkness, Twin Val'kyrs
    --     A{ id = 67296, prototype = AptechkaUserConfig.BossDebuffPrototype } --Touch of Light, Twin Val'kyrs
    --     AptechkaUserConfig.LoadableDebuffs.PvP(true, true)
    -- end,

    -- ["Ulduar"] = function()
    --     A{ id = 64126, prototype = AptechkaUserConfig.BossDebuffPrototype } --Squeeze, Yogg-Saron
    --     A{ id = 62717, prototype = AptechkaUserConfig.BossDebuffPrototype } --Slag Pot, Ignis
    --     A{ id = 63493, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fusion Punch, Assembly of Iron
    --     A{ id = 64290, prototype = AptechkaUserConfig.BossDebuffPrototype } --Stone Grip, Kologarn
    --     A{ id = 63018, prototype = AptechkaUserConfig.BossDebuffPrototype } --Searing Light, XT-002
    -- end,

    -- ["Naxxramas"] = function()
    --     A{ id = 27808, prototype = AptechkaUserConfig.BossDebuffPrototype } --Frost Blast, Kel'Thuzad
    --     A{ id = 28622, prototype = AptechkaUserConfig.BossDebuffPrototype } --Web Wrap, Maexxna
    -- end,




    --[==[
    ["PvP"] = function(disable_damagereduction, disable_roots)
        -- A{ id = 23333, type = "HELPFUL", assignto = "bossdebuff", color = {1,0,0}, priority = 95 } --Warsong Flag
        -- A{ id = 23335, type = "HELPFUL", assignto = "bossdebuff", color = {0,0,1}, priority = 95 } --Silverwing Flag
        -- A{ id = 34976, type = "HELPFUL", assignto = "bossdebuff", color = {0,1,0}, priority = 95 } --Netherstorm Flag
    end,

    ['HealingReduction'] = function()
        A{ id = 8680,  color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Wound Poison
        -- A{ id = 24674, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Veil of Shadow
        A{ id = 115804, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Mortal Wounds

        -- A{ id = 30213, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Legion Strike
        -- A{ id = 54680, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Monstrous Bite
    end,
    ]==]
}
