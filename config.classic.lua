local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local AG = helpers.AddAuraGlobal
local DT = helpers.AddDispellType
local D = helpers.AddDebuff
local Trace = helpers.AddTrace
local pixelperfect = helpers.pixelperfect
local config = AptechkaDefaultConfig
local DispelTypes = helpers.DispelTypes
local RangeCheckBySpell = helpers.RangeCheckBySpell
local IsPlayerSpell = IsPlayerSpell
local set = helpers.set

local apiLevel = math.floor(select(4,GetBuildInfo())/10000)
if not apiLevel == 1 then return end

if apiLevel <= 3 then
    config.DefaultWidgets.totemCluster1 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(6), y = 0 }
    config.DefaultWidgets.totemCluster2 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(12), y = 0 }
    config.DefaultWidgets.totemCluster3 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(19), y = 0 }
end

local color1 = { 0.9, 0, 0 }

-- WARLOCK
AG{ id = { 6229, 11739, 11740, 28610 }, template = "SurvivalCD" } -- Shadow Ward

-- DRUID
AG{ id = 22812,  template = "SurvivalCD" } -- Barkskin
AG{ id = 29166,  template = "SurvivalCD" } -- Innervate


-- MAGE
AG{ id = 11958,  template = "TankCD" } -- Ice Block
AG{ id = { 543, 8457, 8458, 10223, 10225 },  template = "SurvivalCD" } -- Fire Ward
AG{ id = { 6143, 8461, 8462, 10177, 28609 },  template = "SurvivalCD" } -- Frost Ward

-- PALADIN
AG{ id = { 498, 5573, 642, 1020 }, template = "TankCD", priority = 95 } -- Divine Shield
AG{ id = { 1022, 5599, 10278 }, template = "SurvivalCD" } -- Blessing of Protection
AG{ id = 1044, template = "SurvivalCD", priority = 40 } -- Blessing of Freedom

-- HUNTER
AG{ id = 19263, template = "SurvivalCD" } -- Deterrence

-- WARRIOR
AG{ id = 20230, template = "SurvivalCD" } -- Retaliation
AG{ id = 12976, template = "SurvivalCD", priority = 85 } --Last Stand
AG{ id = 871,   template = "TankCD" } --Shield Wall 40%

-- ROGUE
AG{ id = 5277, template = "SurvivalCD" } -- Evasion
AG{ id = { 1856, 1857 }, template = "TankCD" } -- Vanish

-- WARLOCK
AG{ id = { 6229, 11739, 11740, 28610 },  template = "SurvivalCD" } -- Shadow Ward

-- Healing Reduction
-- AG{ id = { 12294, 21551, 21552, 21553 }, color = { 147/255, 54/255, 115/255 }, template = "bossDebuff", global = true, } --Mortal Strike

-- Battleground
AG{ id = 23333, type = "HELPFUL", assignto = set("raidbuff"), scale = 1.7, color = {1,0,0}, priority = 95, global = true, } --Warsong Flag
AG{ id = 23335, type = "HELPFUL", assignto = set("raidbuff"), scale = 1.7, color = {0,0,1}, priority = 95, global = true, } --Silverwing Flag

-- Soulstone Resurrection
AG{ id = { 20707, 20762, 20763, 20764, 20765 }, type = "HELPFUL", global = true, assignto = set("raidbuff"), color = { 0.6, 0, 1 }, priority = 20 }

AG{ id = {
    430, 431, 432, 1133, 1135, 1137, 22734, 24355, 29007, 26473, 26261, -- Classic water
}, assignto = set("text2"), color = {0.7, 0.7, 1}, text = "DRINKING", global = true, priority = 30 }

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
    A{ id = { 1243, 1244, 1245, 2791, 10937, 10938, 21562, 21564 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 1, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(1243) end }
    -- Prayer of Shadow Protection
    -- A{ id = { 976, 10957, 10958, 27683 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 151/255, 86/255, 168/255 }, priority = 80, isMissing = true, isKnownCheck = function() return IsPlayerSpell(976) end }

    -- Prayer of Spirit, Divine Spirit
    A{ id = { 14752, 14818, 14819, 27841, 27681 }, type = "HELPFUL", assignto = set("raidbuff"), color = {52/255, 172/255, 114/255}, priority = 90, isMissing = true,
        isKnownCheck = function(unit)
            local isKnown = IsPlayerSpell(14752)
            local isSpiritClass = manaClasses[select(2,UnitClass(unit))]
            return isKnown and isSpiritClass
        end }

    A{ id = 6346, type = "HELPFUL", assignto = set("bar4"), priority = 30, color = { 1, 0.7, 0} , showDuration = true } -- Fear Ward

    -- Abolish Disease
    A{ id = 552, type = "HELPFUL", assignto = set("bars"), priority = 30, color = { 118/255, 69/255, 50/255} , showDuration = true }
    -- Renew
    A{ id = { 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 },   type = "HELPFUL", assignto = set("bars"), priority = 50, color = { 0, 1, 0}, foreigncolor = {0.1, 0.4, 0.1}, showDuration = true }
    -- Lightwell Renew
    A{ id = { 7001, 27873, 27874 }, type = "HELPFUL", assignto = set("bars"), priority = 20, color = { 0.5, 0.7, 0}, showDuration = true }
    -- Power Word: Shield
    A{ id = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 },    type = "HELPFUL", assignto = set("bars"), priority = 90, color = { 1, 0.85, 0}, foreigncolor = {0.4, 0.35, 0.1}, showDuration = true }
    -- Weakened Soul
    A{ id = 6788, type = "HARMFUL", assignto = set("spell3"), priority = 70, color = { 0.8, 0, 0}, showDuration = true }

    -- Prayer of Healing
    Trace{id = { 596, 996, 10960, 10961, 15019, 25316 }, template = "HealTrace", color = { .5, .5, 1} }
    -- Flash Heal
    Trace{id = { 2061, 9472, 9473, 9474, 10915, 10916, 10917 } , template = "HealTrace", color = { 0.6, 1, 0.6} }
    -- Greater Heal
    Trace{id = { 2060, 10963, 10964, 10965, 25314 }, template = "HealTrace", color = { 0.7, 1, 0.7} }

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
    A{ id = { 1126, 5232, 5234, 6756, 8907, 9884, 9885, 21849, 21850 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 0.2, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(1126) end }

    -- Rejuvenation
    A{ id = { 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299 }, type = "HELPFUL", assignto = set("bars"), priority = 90, color = { 1, 0.2, 1}, foreigncolor = { 0.4, 0.1, 0.4 }, showDuration = true }
    -- Regrowth
    A{ id = { 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858 }, type = "HELPFUL", assignto = set("bars"), priority = 80, color = { 0.4, 1, 0.4}, foreigncolor = { 0.1, 0.4, 0.1 }, showDuration = true }
    --Abolish Poison
    A{ id = 2893, type = "HELPFUL", assignto = set("bars"), priority = 30, color = {15/255, 78/255, 60/255} , showDuration = true, isMine = false }

    -- Healing Touch
    Trace{id = { 5185, 5186, 5187, 5188, 5189, 6778, 8903, 9758, 9888, 9889, 25297 } , template = "HealTrace", color = { 0.6, 1, 0.6} }

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
    A{ id = 25771, type = "HARMFUL", assignto = set("bars"), showDuration = true, color = { 0.8, 0, 0 } }
    -- Blessing of Freedom
    -- A{ id = 1044, type = "HELPFUL", assignto = set("bars"), showDuration = true, isMine = true, color = { 1, 0.4, 0.2} }

    -- Holy Light
    Trace{id = { 635, 639, 647, 1026, 1042, 3472, 10328, 10329, 25292 } , template = "HealTrace", color = { 1, 1, 0.6} }
    -- Flash of Light
    Trace{id = { 19750, 19939, 19940, 19941, 19942, 19943 } , template = "HealTrace", color = { 0.6, 1, 0.6} }


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

    -- Healing Way
    A{ id = 29203, type = "HELPFUL", assignto = set("bar4"), showStacks = 3, color = {38/255, 221/255, 163/255} }

    local prioWater = 75
    local prioAir = 74
    local prioEarth = 73
    local prioFire = 72
    -- Earth
    A{ id = { 8072, 8156, 8157, 10403, 10404, 10405 }, type = "HELPFUL", assignto = set("totemCluster2"), priority = prioEarth, isMine = true, color = { 162/255, 77/255, 48/255 } }  -- Stoneskin Totem
    A{ id = { 8076, 8162, 8163, 10441, 25362 }, type = "HELPFUL", assignto = set("totemCluster2"), priority = prioEarth, isMine = true, color = { 0.1, 0.8, 0.1 } }  -- Strength of Earth Totem
    -- Fire
    A{ id = { 8182, 10476, 10477 }, type = "HELPFUL", assignto = set("raidbuff"), priority = prioFire, isMine = true, color = { 1,0.4,0.4} }  -- Frost Resistance Totem
    -- Water
    A{ id = { 16191, 17355, 17360 }, type = "HELPFUL", assignto = set("totemCluster1"), priority = prioWater, isMine = true, color = {38/255, 221/255, 163/255} }  -- Mana Tide Totem
    A{ id = { 5677, 10491, 10493, 10494 }, type = "HELPFUL", assignto = set("totemCluster1"), priority = prioWater, isMine = true, color = { 187/255, 75/255, 128/255 } }  -- Mana Spring Totem
    A{ id = { 5672, 6371, 6372, 10460, 10461 }, type = "HELPFUL", assignto = set("totemCluster1"), priority = prioWater, isMine = true, color = { 0.63, 0.8, 0.35 } }  -- Healing Stream Totem
    A{ id = { 8185, 10534, 10535 }, type = "HELPFUL", assignto = set("totemCluster1"), priority = prioWater, isMine = true, color = { 65/255, 110/255, 1 } }  -- Fire Resistance Totem
    -- Air
    A{ id = 8178, type = "HELPFUL", assignto = set("totemCluster3"), priority = prioAir, isMine = true, color = { 0.6, 0, 1 } }  -- Grounding Totem
    A{ id = 25909, type = "HELPFUL", assignto = set("totemCluster3"), priority = prioAir, isMine = true, color = {149/255, 121/255, 214/255} }  -- Tranquil Air Totem
    A{ id = { 8836, 10626, 25360 }, type = "HELPFUL", assignto = set("totemCluster3"), priority = prioAir, isMine = true, color = { 65/255, 110/255, 1 } }  -- Grace of Air Totem
    A{ id = { 10596, 10598, 10599 }, type = "HELPFUL", assignto = set("totemCluster3"), priority = prioAir, isMine = true, color = {52/255, 172/255, 114/255} }  -- Nature Resistance Totem

    -- Ancestral Healing
    A{ id = { 16177, 16236, 16237 }, type = "HELPFUL", assignto = set("bars"), showDuration = true, color = { 1, 0.85, 0} }

    -- Chain Heal
    Trace{id = { 1064, 10622, 10623 }, template = "HealTrace", color = { 1, 1, 0 } }
    -- Healing Wave incl Lesser Wave
    Trace{id = { 331, 332, 547, 913, 939, 959, 8004, 8005, 8008, 8010, 10395, 10396, 10466, 10467, 10468, 25357 }, template = "HealTrace", color = { 0.5, 1, 0.5 } }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
    }

    config.DispelBitmasks = {
        DispelTypes("Poison", "Disease")
    }

end

if playerClass == "MAGE" then

    -- Arcane Intellect and Brilliance
    A{ id = { 1459, 1460, 1461, 10156, 10157, 23028 }, type = "HELPFUL", assignto = set("raidbuff"), color = { .4 , .4, 1 }, priority = 50, isMissing = true,
        isKnownCheck = function(unit)
            local isKnown = IsPlayerSpell(1459)
            local isSpiritClass = manaClasses[select(2,UnitClass(unit))]
            return isKnown and isSpiritClass
        end }
    -- Dampen Magic
    A{ id = { 604, 8450, 8451, 10173, 10174 }, type = "HELPFUL", assignto = set("spell3"), color = {52/255, 172/255, 114/255}, priority = 80 }
    -- Amplify Magic
    A{ id = { 1008, 8455, 10169, 10170 }, type = "HELPFUL", assignto = set("spell3"), color = {1,0.7,0.5}, priority = 80 }


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
    A{ id = { 5242, 6192, 6673, 11549, 11550, 11551, 25289 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, .4 , .4}, priority = 50 }

end

-------------------------
-- Debuff Highlights
-------------------------

config.MapIDs = {
    -- Classic semi-random map ids, there's no maps in classic anyway
    [232] = "Molten Core",
    [233] = "Zul'Gurub",
    [247] = "Ruins of Ahn'Qiraj",
    [319] = "Ahn'Qiraj",
    [287] = "Blackwing Lair",
    [400] = "Naxxramas",

    [1701] = "PvP",
}

config.defaultDebuffHighlights = {
    ["Naxxramas"] = {
        [27808] = { 27808, 3, "Kel'Thuzad, Frost Blast" },
        [28622] = { 28622, 1, "Maexxna, Web Wrap" },
    },
    ["Molten Core"] = {
        [20475] = { 20475, 4, "Living Bomb" },
    },
    ["Blackwing Lair"] = {
        [22687] = { 22687, 3, "Nefarian, Veil of Shadow" },
    },
}

-------------------------
-- Blacklist
-------------------------

helpers.auraBlacklist = {
    [26013] = true, -- PVP Deserter
    [8326] = true, -- Ghost
    [25771] = true, -- Forbearance
    [6788] = true, -- Weakened Soul
    [11196] = true, -- Recently Bandaged

    [26680] = true, -- Adored (Love is in the Air)

    -- Trash
    [22959] = true, -- Fire Vulnerability
    [15258] = true, -- Shadow Vulnerability
    [12579] = true, -- Winter's Chill

    -- 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 -- Fireball shitty dot
    -- 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 -- Pyroblast dot
}



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

    [339] = true, -- Entangling Roots
    [1062] = true,
    [5195] = true,
    [5196] = true,
    [9852] = true,
    [9853] = true,

    [9005] = true, -- Pounce Stun
    [9823] = true,
    [9827] = true,

    [18469] = true, -- Silence (Improved Counterspell)

    [118] = true, -- Polymorph 7 variants
    [12824] = true,
    [12825] = true,
    [12826] = true,
    [28270] = true,
    [28271] = true,
    [28272] = true,

    [12494] = true, -- Frostbite

    [122] = true, -- Frost Nova 4 rank
    [865] = true,
    [6131] = true,
    [10230] = true,


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
