local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local AG = helpers.AddAuraGlobal
local DT = helpers.AddDispellType
local D = helpers.AddDebuff
local BossAura = helpers.BossAura
local Trace = helpers.AddTrace
local pixelperfect = helpers.pixelperfect
local config = AptechkaDefaultConfig
local DispelTypes = helpers.DispelTypes
local RangeCheckBySpell = helpers.RangeCheckBySpell
local IsPlayerSpell = IsPlayerSpell
local set = helpers.set

local apiLevel = math.floor(select(4,GetBuildInfo())/10000)
local isWrath = apiLevel == 3
if not isWrath then return end

config.HealthTextStatus.formatType = "MISSING_HEALING_SHORT"

local color1 = { 0.9, 0, 0 }

-- WARLOCK
AG{ id = { 6229, 11739, 11740, 28610, 47891 }, template = "SurvivalCD" } -- Shadow Ward

-- DRUID
AG{ id = 22812,  template = "SurvivalCD" } -- Barkskin
-- AG{ id = 29166,  template = "SurvivalCD" } -- Innervate

-- PRIEST
AG{ id = 33206, template = "TankCD", priority = 93 } --Pain Suppression
AG{ id = 47585, template = "SurvivalCD" } -- Dispersion
AG{ id = 47788, template = "SurvivalCD", priority = 90 } --Guardian Spirit

-- MAGE
AG{ id = 11958,  template = "TankCD" } -- Ice Block
AG{ id = { 543, 8457, 8458, 10223, 10225, 27128, 43010 },  template = "SurvivalCD" } -- Fire Ward
AG{ id = { 6143, 8461, 8462, 10177, 28609, 32796, 43012 },  template = "SurvivalCD" } -- Frost Ward

-- PALADIN
AG{ id = { 498, 642 }, template = "TankCD", priority = 95 } -- Divine Shield, Divine Protection
AG{ id = 19752, template = "TankCD", priority = 95 } -- Divine Intervention
AG{ id = { 1022, 5599, 10278 }, template = "SurvivalCD" } -- Hand of Protection
AG{ id = 1044, template = "SurvivalCD", priority = 40 } -- Hand of Freedom
AG{ id = 6940, template = "SurvivalCD" } -- Hand of Sacrifice

-- HUNTER
AG{ id = 19263, template = "SurvivalCD" } -- Deterrence

-- WARRIOR
AG{ id = 20230, template = "SurvivalCD" } -- Retaliation
AG{ id = 12976, template = "SurvivalCD", priority = 85 } --Last Stand
AG{ id = 871,   template = "TankCD" } --Shield Wall 40%

-- ROGUE
AG{ id = { 5277, 26669 }, template = "SurvivalCD" } -- Evasion
AG{ id = { 1856, 1857, 26888 }, template = "SurvivalCD" } -- Vanish
AG{ id = 45182,  template = "TankCD" } -- Cheating Death
AG{ id = 31224,  template = "SurvivalCD", priority = 91 } -- Cloak of Shadows

-- WARLOCK
AG{ id = { 6229, 11739, 11740, 28610 },  template = "SurvivalCD" } -- Shadow Ward

-- SHAMAN
AG{ id = 30823,  template = "SurvivalCD" } -- Shamanistic Rage

-- DEATH KNIGHT
AG{ id = 48792, template = "TankCD" } -- Icebound Fortitude
AG{ id = 55233, template = "SurvivalCD" } -- Vampiric Blood

-- Healing Reduction
-- AG{ id = { 12294, 21551, 21552, 21553 }, color = { 147/255, 54/255, 115/255 }, template = "bossDebuff", global = true, } --Mortal Strike

-- Battleground
AG{ id = 23333, type = "HELPFUL", assignto = set("raidbuff"), scale = 1.7, color = {1,0,0}, priority = 95, global = true, } --Warsong Flag
AG{ id = 23335, type = "HELPFUL", assignto = set("raidbuff"), scale = 1.7, color = {0,0,1}, priority = 95, global = true, } --Silverwing Flag

-- Soulstone Resurrection
AG{ id = { 20707, 20762, 20763, 20764, 20765, 27239, 47883 }, type = "HELPFUL", global = true, assignto = set("raidbuff"), color = { 0.6, 0, 1 }, priority = 20 }

AG{ id = {
    430, 431, 432, 1133, 1135, 1137, 22734, 24355, 29007, 26473, 26261, -- Classic water
    34291, 43183, 43182, 43706, -- BC & WotLK water,
    27089, 46755, -- BC mage water
    52911, 57073, 61830, 64356, -- WotLK
    24707, 26263, 66041, -- % Food
}, assignto = set("text2"), color = {0.7, 0.7, 1}, text = "DRINKING", global = true, priority = 30 }

-- Stealth, Prowl
AG{ id = {1784, 5215 }, assignto = set("text2"), color = {0.2, 1, 0.3}, text = "STEALTH", priority = 20 }

AG{ id = 5384, assignto = set("text2"), color = {0, 0.7, 1}, text = "FD", global = true, priority = 75 } -- Feign Death

local manaClasses = {
    HUNTER = true,
    MAGE = true,
    DRUID = true,
    PRIEST = true,
    SHAMAN = true,
    WARLOCK = true,
    PALADIN = true
}
if playerClass == "PRIEST" then
    -- Power Word: Fortitude and Prayer of Fortitude
    A{ id = { 1243, 1244, 1245, 2791, 10937, 10938, 25389, 48161,     21562, 21564, 25392, 48162 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 1, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(1243) end }
    -- Prayer of Shadow Protection
    -- A{ id = { 976, 10957, 10958, 25433, 48169,   27683, 39374, 48170 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 151/255, 86/255, 168/255 }, priority = 80, isMissing = true, isKnownCheck = function() return IsPlayerSpell(976) end }

    -- Prayer of Spirit, Divine Spirit
    A{ id = { 14752, 14818, 14819, 25312, 27841, 48073,   27681, 32999, 48074 }, type = "HELPFUL", assignto = set("raidbuff"), color = {52/255, 172/255, 114/255}, priority = 90, isMissing = true,
        isKnownCheck = function(unit)
            local isKnown = IsPlayerSpell(14752)
            local isSpiritClass = manaClasses[select(2,UnitClass(unit))]
            return isKnown and isSpiritClass
        end }

    A{ id = 6346, type = "HELPFUL", assignto = set("bar4"), priority = 30, color = { 1, 0.7, 0} , infoType = "DURATION" } -- Fear Ward

    -- Abolish Disease
    A{ id = 552, type = "HELPFUL", assignto = set("bars"), priority = 30, color = { 118/255, 69/255, 50/255} , infoType = "DURATION" }
    -- Renew
    A{ id = { 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25221, 25222, 25315, 48067, 48068 }, type = "HELPFUL", isMine = true, assignto = set("bars"), priority = 50, color = { 0, 1, 0}, foreigncolor = {0.1, 0.4, 0.1}, infoType = "DURATION" }
    -- Lightwell Renew
    A{ id = { 7001, 27873, 27874, 28276, 48084, 48085 }, type = "HELPFUL", assignto = set("bars"), priority = 20, color = { 0.5, 0.7, 0}, infoType = "DURATION" }
    -- Power Word: Shield
    A{ id = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 25217, 25218, 48065, 48066 }, type = "HELPFUL", assignto = set("bars"), priority = 90, color = { 1, 0.85, 0}, foreigncolor = {0.4, 0.35, 0.1}, infoType = "DURATION" }
    -- Weakened Soul
    A{ id = 6788, type = "HARMFUL", assignto = set("spell3"), priority = 70, color = { 0.8, 0, 0}, infoType = "DURATION" }
    --Prayer of Mending
    A{ id = { 41635, 48110, 48111 }, type = "HELPFUL", assignto = set("bar4"), priority = 70, isMine = true, color = { 1, 0, 102/255 }, maxCount = 5, infoType = "COUNT" }

    -- Penance
    Trace{id = { 47750, 52983, 52984, 52985 }, template = "HealTrace", color = { 52/255, 172/255, 114/255 } }
    -- Prayer of Healing
    Trace{id = { 596, 996, 10960, 10961, 25308, 25316, 48072 }, template = "HealTrace", color = { .5, .5, 1} }
    -- Flash Heal
    Trace{id = { 2061, 9472, 9473, 9474, 10915, 10916, 10917, 25233, 25235, 48070, 48071 } , template = "HealTrace", color = { 0.6, 1, 0.6} }
    -- Greater Heal, Heal, Lesser heal
    Trace{id = { 2060, 10963, 10964, 10965, 25210, 25213, 25314, 48062, 48063,   2054, 2055, 6063, 6064,   2050, 2052, 2053 }, template = "HealTrace", color = { 0.7, 1, 0.7} }

    -- Circle of Healing
    Trace{id = { 34861, 34863, 34864, 34865, 34866, 48088, 48089 }, template = "HealTrace", color = { 1, 0.7, 0.35} }
    -- Prayer of Mending // NOT UPDATED
    Trace{id = 33110, template = "HealTrace", color = { 1, 0.3, 0.55 }, fade = 0.5, priority = 95 }


    config.UnitInRangeFunctions = {
        RangeCheckBySpell(2050), -- Lesser Heal Rank 1
        RangeCheckBySpell(2050),
        RangeCheckBySpell(2050),
    }

    config.DispelBitmasks = {
        DispelTypes("Magic", "Disease")
    }

end

if playerClass == "DRUID" then
    -- Mark of the Wild, Gift of the Wild
    A{ id = { 1126, 5232, 5234, 6756, 8907, 9884, 9885, 26990, 48469,   21849, 21850, 26991, 48470 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 0.2, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(1126) end }
    -- Rejuvenation
    A{ id = { 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299, 26981, 26982, 48440, 48441 }, type = "HELPFUL", assignto = set("bars"), isMine = true, priority = 90, color = { 1, 0.2, 1}, foreigncolor = { 0.4, 0.1, 0.4 }, infoType = "DURATION" }
    -- Regrowth
    A{ id = { 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 26980, 48442, 48443 }, type = "HELPFUL", assignto = set("bars"), isMine = true, scale = 0.5, color = { 0, 0.8, 0.2}, priority = 50, infoType = "DURATION" }
    -- Abolish Poison
    A{ id = 2893, type = "HELPFUL", assignto = set("bars"), priority = 30, color = {15/255, 78/255, 60/255} , infoType = "DURATION", isMine = false }
    -- Lifebloom
    A{ id = { 33763, 48450, 48451 }, type = "HELPFUL", assignto = set("bar4", "bar4text"), priority = 60, infoType = "DURATION", isMine = true, color = { 0.2, 1, 0.2}, }
    -- Wild Growth
    A{ id = { 48438, 53248, 53249, 53251} , type = "HELPFUL", assignto = set("bars"), color = { 0, 0.9, 0.7}, priority = 60, infoType = "DURATION", isMine = true }

    -- Healing Touch
    Trace{id = { 5185, 5186, 5187, 5188, 5189, 6778, 8903, 9758, 9888, 9889, 25297, 26978, 26979, 48377, 48378 } , template = "HealTrace", color = { 0.6, 1, 0.6} }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
    }

    config.DispelBitmasks = {
        DispelTypes("Curse", "Poison")
    }
end


if playerClass == "PALADIN" then

    -- Forbearance
    A{ id = 25771, type = "HARMFUL", assignto = set("bars"), infoType = "DURATION", color = { 0.8, 0, 0 } }
    -- Blessing of Freedom
    A{ id = 1044, type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 1, 0.4, 0.2} }

    A{ id = 53563, type = "HELPFUL", assignto = set("bar4"), infoType = "DURATION",
                                                                            isMine = true,
                                                                            color = { 0, 0.9,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Light

    -- Sacred Shield
    A{ id = 53601, type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", priority = 86, scale = 0.5, isMine = true, color = { 1 , 0.9, 0} }
    -- Sacred Shield Proc
    A{ id = 58597, type = "HELPFUL", name = "SacredShieldProc", assignto = set("bars"), infoType = "DURATION", priority = 85, scale = 1, isMine = true, color = { 1 , 0.7, 0} }

    -- Holy Light
    Trace{id = { 635, 639, 647, 1026, 1042, 3472, 10328, 10329, 25292, 27135, 27136, 48781, 48782 } , template = "HealTrace", color = { 1, 0.3, 0.55 } }
    -- Flash of Light
    Trace{id = { 19939, 19940, 19941, 19942, 19943, 27137, 48784, 48785 } , template = "HealTrace", color = { 0.6, 1, 0.6} }
    -- Holy Shock
    Trace{id = { 25914, 25913, 25903, 27175, 33074, 48820, 48821 }, template = "HealTrace", color = { 1, 0.6, 0.3 } }
    -- Glyph of Holy Light
    Trace{id = 54968, template = "HealTrace", color = { 1, 0.7, 0.2} }


    config.UnitInRangeFunctions = {
        RangeCheckBySpell(635), -- Holy Light
        RangeCheckBySpell(635),
        RangeCheckBySpell(635),
    }

    config.DispelBitmasks = {
        DispelTypes("Magic", "Disease", "Poison")
    }

end

-- if playerClass == "HUNTER" then
--     -- Trueshot Aura
--     A{ id = { 19506, 20905, 20906 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 1, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(19506) end }
-- end

if playerClass == "SHAMAN" then

    -- Earth Shield
    A{ id = { 974, 32593, 32594, 49283, 49284 } , type = "HELPFUL", assignto = set("bar4"), infoType = "COUNT", maxCount = 6, color = {0.2, 1, 0.2}, foreigncolor = {0, 0.5, 0} }
    --Riptide
    A{ id = { 61295, 61299, 61300, 61301 },  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", scale = 1.3, isMine = true, color = { 0.4 , 0.4, 1} }

    -- Ancestral Fortitude
    A{ id = { 16177, 16236, 16237 }, type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", color = { 1, 0.85, 0} }

    -- Chain Heal
    Trace{id = { 1064, 10622, 10623, 25422, 25423, 55458, 55459 }, template = "HealTrace", color = { 1, 1, 0 } }
    -- Healing Wave
    Trace{id = { 331, 332, 547, 913, 939, 959, 8005, 10395, 10396, 25357, 25391, 25396, 49272, 49273 }, template = "HealTrace", color = { 0.5, 1, 0.5 } }
    -- Lesser Healing Wave
    Trace{id = { 8004, 8008, 8010, 10466, 10467, 10468, 25420, 49275, 49276 }, template = "HealTrace", color = { 0.5, 1, 0.5 } }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
    }

    config.DispelBitmasks = {
        DispelTypes("Poison", "Disease", "Curse")
    }

end

if playerClass == "MAGE" then

    -- Arcane Intellect and Brilliance
    A{ id = { 1459, 1460, 1461, 10156, 10157, 27126, 42995,    23028, 27127, 43002 }, type = "HELPFUL", assignto = set("raidbuff"), color = { .4 , .4, 1 }, priority = 50, isMissing = true,
        isKnownCheck = function(unit)
            local isKnown = IsPlayerSpell(1459)
            local isSpiritClass = manaClasses[select(2,UnitClass(unit))]
            return isKnown and isSpiritClass
        end }
    -- Dampen Magic
    A{ id = { 604, 8450, 8451, 10173, 10174, 33944, 43015 }, type = "HELPFUL", assignto = set("spell3"), color = {52/255, 172/255, 114/255}, priority = 80 }
    -- Amplify Magic
    A{ id = { 1008, 8455, 10169, 10170, 27130, 33946, 43017 }, type = "HELPFUL", assignto = set("spell3"), color = {1,0.7,0.5}, priority = 80 }


    if IsPlayerSpell(1459) then
        config.UnitInRangeFunctions = {
            RangeCheckBySpell(1459), -- Arcane Intellect, 30yd range
        }
    end

    config.DispelBitmasks = {
        DispelTypes("Curse")
    }
end

if playerClass == "WARRIOR" then

    -- Battle Shout
    A{ id = { 5242, 2048, 6192, 6673, 11549, 11550, 11551, 25289, 47436 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, .4 , .4}, priority = 50 }
    -- Commanding Shout
    A{ id = { 469, 47439, 47440 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 0.4, 0.4 , 1}, priority = 49 }

end

if playerClass == "DEATHKNIGHT" then

    -- Horn of Winter
    A{ id = { 57330, 57623 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 0.6, 0, 1 }, priority = 50 }

end

-------------------------
-- Debuff Highlights
-------------------------

config.MapIDs = {
    [99] = "Karazhan",
    [100] = "Naxxramas",
    [121] = "Ulduar",
    [131] = "Trial of the Grand Crusader",
    [141] = "Icecrown Citadel",

    [111] = "Utgarde Keep",
    [112] = "The Culling of Stratholme",

    [1701] = "PvP",
}

config.defaultDebuffHighlights = {
    ["PvP"] = {
        [33786] = { 33786, 3, "Cyclone" },
    },
    ["Karazhan"] = {
        [29522] = { 29522, 1, "Maiden of Virtue, Holy Fire" },
        [34694] = { 34694, 1, "Moroes, Blind" },
        [30898] = { 30898, 1, "Prince Malchezaar, Shadow Word: Pain" },
    },
    ["Ulduar"] = {
        [64125] = { 64125, 1, "Squeeze, Yogg-Saron 10" },
        [64126] = { 64126, 1, "Squeeze, Yogg-Saron 25" },
        [65722] = { 65722, 1, "Slag Pot, Ignis 10" },
        [65723] = { 65723, 1, "Slag Pot, Ignis 25" },
        [61903] = { 61903, 4, "Fusion Punch, Assembly of Iron 10" },
        [63493] = { 63493, 4, "Fusion Punch, Assembly of Iron 25" },
        [64290] = { 64290, 1, "Stone Grip, Kologarn 10" },
        [64292] = { 64292, 1, "Stone Grip, Kologarn 25" },
        [63018] = { 63018, 1, "Searing Light, XT-002 10" },
        [65121] = { 65121, 1, "Searing Light, XT-002 25" },

    },
    ["Trial of the Grand Crusader"] = {
        [66237] = { 66237, 1, "Incinerate Flesh, Lord Jaraxxus" },
        [66013] = { 66013, 1, "Penetrating Cold, Anub'arak" },
        [67281] = { 67281, 1, "Touch of Darkness, Twin Val'kyrs" },
        [67296] = { 67296, 2, "Touch of Light, Twin Val'kyrs" },
    },
    ["Icecrown Citadel"] = {
        [72670] = { 72670, 1, "Impale, Lord Marrowgar" },
        [72385] = { 72385, 1, "Boiling Blood, Deathbringer Saurfang" },
        [72293] = { 72293, 2, "Mark of the Fallen Champion, Deathbringer Saurfang" },
        -- [69279] = { 69279, 1, "Gas Spore, Festergut" },
        [72272] = { 72272, 3, "Vile Gas, Festergut" },
        [69674] = { 69674, 3, "Mutated Infection, Rotface" },
        [70157] = { 70157, 3, "Ice Tomb, Sindragosa" },

        [70338] = { 70338, 1, "Necrotic Plague, Lich King" },
        [68980] = { 68980, 2, "Harvest Soul, Lich King" },
        [69409] = { 69409, 4, "Soul Reaper, Lich King" },
    },
    ["Naxxramas"] = {
        [27808] = { 27808, 3, "Kel'Thuzad, Frost Blast" },
        [28622] = { 28622, 1, "Maexxna, Web Wrap" },
    },
    ["Utgarde Keep"] = {
        [48400] = { 48400, 3, "Keleseth, Frost Tomb" },
    },
    ["The Culling of Stratholme"] = {
        [58849] = { 58849, 1, "Mal'Ganis, Sleep" },
    },
}

-------------------------
-- Blacklist
-------------------------

helpers.auraBlacklist = {
    [72145] = true, -- Green Blight Residue (Weekly Quest debuff)
    [72144] = true, -- Orange Blight Residue (Weekly Quest debuff)
    [71041] = true, -- Dungeon Deserter
    [71387] = true, -- Frost Aura
    [70084] = true, -- Frost Aura
    [69127] = true, -- Chill of the Throne

    [51120] = true, -- Tinnitus
    [26013] = true, -- PVP Deserter
    [8326] = true, -- Ghost
    [25771] = true, -- Forbearance
    [41425] = true, -- Hypothermia
    [6788] = true, -- Weakened Soul
    [11196] = true, -- Recently Bandaged
    [57723] = true, -- Exhaustion (Bloodlust)
    [57724] = true, -- Sated (Heroism)

    [26680] = true, -- Adored (Love is in the Air)

    -- Trash
    [22959] = true, -- Fire Vulnerability
    [15258] = true, -- Shadow Vulnerability
    [12579] = true, -- Winter's Chill

    -- 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 -- Fireball shitty dot
    -- 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 -- Pyroblast dot
}


helpers.importantTargetedCasts = {}


helpers.customBossAuras = {
    [5782] = true, -- Fear 3 ranks
    [6213] = true,
    [6215] = true,

    [5484] = true, -- Howl of Terror 2 ranks
    [17928] = true,

    [6358] = true, -- Seduction

    [853] = true, -- Hammer of Justice 4 ranks
    [5588] = true,
    [5589] = true,
    [10308] = true,

    [20066] = true, -- Repentance

    [3355] = true, -- Freezing Trap Effect 3 ranks
    [14308] = true,
    [14309] = true,

    [19503] = true, -- Scatter Shot
    [19229] = true, -- Wing Clip Root
    [19410] = true, -- Conc stun
    [24394] = true, -- Intimidation

    [2637] = true, -- Hibernate 3 ranks
    [18657] = true,
    [18658] = true,

    [5211] = true, -- Bash 3 ranks
    [6798] = true,
    [8983] = true,

    [18469] = true, -- Silence (Improved Counterspell)

    [118] = true, -- Polymorph 7 variants
    [12824] = true,
    [12825] = true,
    [12826] = true,
    [28270] = true,
    [28271] = true,
    [28272] = true,

    [12494] = true, -- Frostbite

    [15487] = true, -- Silence (Priest)

    [15269] = true, -- Blackout

    [8122] = true, -- Psychic Scream
    [8124] = true,
    [10888] = true,
    [10890] = true,

    [1833] = true, -- Cheap Shot
    [2094] = true, -- Blind

    [2070] = true, -- Sap 3 ranks
    [6770] = true,
    [11297] = true,

    [408] = true, -- Kidney Shot 2 ranks
    [8643] = true,

    [23694] = true, -- Improved Hamstring Root
    [676] = true, -- Disarm
    [12809] = true, -- Concussion Blow
}

BossAura(30153, 30195, 30197, 47995) -- Felguard Intercept
BossAura(9005, 9823, 9827, 27006, 49803) -- Pounce Stun
BossAura(6789, 17925, 17926, 27223, 47859, 47860) -- Death Coil
BossAura(122, 865, 6131, 10230, 27088, 42917) -- Frost Nova
BossAura(30108, 30404, 30405, 47841, 47843) -- Unstable Affliction
BossAura(339, 1062, 5195, 5196, 9852, 9853, 26989, 53308) -- Entangling Roots

do
    local AURA = helpers.BuffGainTypes.AURA
    local CAST = helpers.BuffGainTypes.CAST
    local HEAL = helpers.BuffGainTypes.HEAL
    helpers.buffGainWhitelist = {
        [27237] = HEAL, -- Master Healthstone
        [27236] = HEAL,
        [27235] = HEAL,

        [47877] = HEAL, -- Fel Healthstone
        [47876] = HEAL,
        [47875] = HEAL,

        [26297] = AURA, -- Berserking
        [33697] = AURA, -- Blood Fury Shaman
        [33702] = AURA, -- Blood Fury Caster
        [20572] = AURA, -- Blood Fury Melee

        [28495] = HEAL, -- Super Healing Potion (TBC)
        [43185] = HEAL, -- Runic Healing Potion (Wrath)

        -- POTIONS
        [53909] = AURA, -- Potion of Wild Magic
        [53908] = AURA, -- Potion of Speed

        [7744] = CAST, -- Will of the Forsaken

        -- WARLOCK
        [27239] = AURA, -- Soulstone
        [47241] = AURA, -- Metamorphosis

        -- PRIEST
        [10060] = AURA, -- Power Infusion
        [28276] = AURA, -- Lightwell Renew, 70lvl rank
        [64843] = CAST, -- Divine Hymn

        -- ROGUE
        [2983] = AURA, -- Sprint
        [8696] = AURA,
        [11305] = AURA,

        --[[DUP]] [5277] = AURA, -- Evasion
        [26669] = AURA,
        --[[DUP]] [31224] = AURA, -- Cloak of Shadows
        [1784] = AURA, -- Stealth last rank
        [13750] = AURA, -- Adrenaline Rush

        -- WARRIOR
        [12292] = AURA, -- Death Wish
        [1719] = AURA, -- Recklessness
        --[[DUP]] [23920] = AURA, -- Spell Reflect

        -- MAGE
        [12042] = AURA, -- Arcane Power
        [12472] = AURA, -- Icy Veins
        [28682] = AURA, -- Combustion
        [11958] = AURA, -- Ice Block
        [66] = AURA, -- Invisiblity Fade
        [32612] = AURA, -- Invisibility

        -- DEATHKNIGHT
        --[[DUP]] [55233] = AURA, -- Vampiric Blood
        --[[DUP]] [48792] = AURA, -- Icebound Fortitude

        -- PALADIN
        [31884] = AURA, -- Avenging Wrath
        --[[DUP]] [498] = AURA, -- Divine Protection
        --[[DUP]] [642] = AURA, -- Divine Shield
        --[[DUP]] [1020] = AURA,
        [1022] = AURA, -- Blessing of Protection
        [5599] = AURA,
        [10278] = AURA,
        [1044] = AURA, -- Blessing of Freedom


        -- DRUID
        [5215] = AURA, -- Prowl 60 lvl rank
        --[[DUP]] [22812] = AURA, -- Barkskin
        --[[DUP]] [1850] = AURA, -- Dash
        [29166] = AURA, -- Innervate
        [9821] = AURA,
        [33357] = AURA,
        [48447] = CAST, -- Tranquility
        [50334] = AURA, -- Berserk
        [48518] = AURA, -- Lunar Eclipse
        -- [48517] = AURA, -- Solar Eclipse

        -- HUNTER
        [19574] = AURA, -- Bestial Wrath

        -- SHAMAN
        [2894] = CAST, -- Fire Elemental Totem
        [16166] = AURA, -- Elemental Mastery
        [51533] = CAST, -- Feral Spirit
    }
    end
