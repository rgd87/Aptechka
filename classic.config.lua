local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local DT = helpers.AddDispellType
local D = helpers.AddDebuff
local Trace = helpers.AddTrace
local config = AptechkaDefaultConfig
local DispelTypes = helpers.DispelTypes
local RangeCheckBySpell = helpers.RangeCheckBySpell


local bossDebuff = { type = "HARMFUL", assignto = "bossdebuff", color = color1, priority = 40, pulse = true }
local tankCD = { type = "HELPFUL", assignto = "icon", global = true, showDuration = true, priority = 94}
local survivalCD = { type = "HELPFUL", assignto = "shieldicon", global = true, showDuration = true, priority = 90 }

-- WARLOCK
A{ id = { 6229, 11739, 11740, 28610 }, prototype = survivalCD } -- Shadow Ward

-- DRUID
A{ id = 22812,  prototype = survivalCD } -- Barkskin
A{ id = 29166,  prototype = survivalCD } -- Innervate


-- MAGE
A{ id = 11958,  prototype = tankCD } -- Ice Block
A{ id = { 543, 8457, 8458, 10223, 10225 },  prototype = survivalCD } -- Fire Ward
A{ id = { 6143, 8461, 8462, 10177, 28609 },  prototype = survivalCD } -- Frost Ward

-- PALADIN
A{ id = { 498, 5573, 642, 1020 }, prototype = tankCD, priority = 95 } -- Divine Shield
A{ id = { 1022, 5599, 10278 }, prototype = survivalCD } -- Blessing of Protection
A{ id = 1044, prototype = survivalCD, priority = 40 } -- Blessing of Freedom

-- HUNTER
A{ id = 19263, prototype = survivalCD } -- Deterrence

-- WARRIOR
A{ id = 20230, prototype = survivalCD } -- Retaliation
A{ id = 12976, prototype = survivalCD, priority = 85 } --Last Stand
A{ id = 871,   prototype = tankCD } --Shield Wall 40%

-- ROGUE
A{ id = 5277, prototype = survivalCD } -- Evasion
A{ id = { 1856, 1857 }, prototype = tankCD } -- Vanish

-- WARLOCK
A{ id = { 6229, 11739, 11740, 28610 },  prototype = survivalCD } -- Shadow Ward

-- Healing Reduction
A{ id = { 12294, 21551, 21552, 21553 }, color = { 147/255, 54/255, 115/255 }, prototype = bossDebuff, global = true, } --Mortal Strike

-- Battleground
A{ id = 23333, type = "HELPFUL", assignto = "bossdebuff", color = {1,0,0}, priority = 95, global = true, } --Warsong Flag
A{ id = 23335, type = "HELPFUL", assignto = "bossdebuff", color = {0,0,1}, priority = 95, global = true, } --Silverwing Flag

-- Soulstone Resurrection
A{ id = { 20707, 20762, 20763, 20764, 20765 }, type = "HELPFUL", global = true, assignto = "raidbuff", color = { 0.6, 0, 1 }, priority = 20 }

if playerClass == "PRIEST" then
    -- Power Word: Fortitude and Prayer of Fortitude
    A{ id = { 1243, 1244, 1245, 2791, 10937, 10938, 21562, 21564 }, type = "HELPFUL", assignto = "raidbuff", color = { 1, 1, 1}, priority = 100, isMissing = true }
    -- Prayer of Shadow Protection
    -- A{ id = { 976, 10957, 10958, 27683 }, type = "HELPFUL", assignto = "raidbuff", color = { 151/255, 86/255, 168/255 }, priority = 80, isMissing = true }
    -- Prayer of Spirit, Divine Spirit
    -- A{ id = { 14752, 14818, 14819, 27841, 27681 }, type = "HELPFUL", assignto = "raidbuff", color = {52/255, 172/255, 114/255}, priority = 90, isMissing = true }

    A{ id = 6346, type = "HELPFUL", assignto = "bar4", priority = 30, color = { 1, 0.7, 0} , showDuration = true } -- Fear Ward

    -- Abolish Disease
    A{ id = 552, type = "HELPFUL", assignto = "bars", priority = 30, color = { 118/255, 69/255, 50/255} , showDuration = true }
    -- Renew
    A{ id = { 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 },   type = "HELPFUL", assignto = "bars", priority = 50, color = { 0, 1, 0}, showDuration = true, isMine = true }
    -- Lightwell Renew
    A{ id = { 7001, 27873, 27874 }, type = "HELPFUL", assignto = "bars", priority = 20, color = { 0.5, 0.7, 0}, showDuration = true }
    -- Power Word: Shield
    A{ id = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 },    type = "HELPFUL", assignto = "bars", priority = 90, isMine = true, color = { 1, .85, 0}, showDuration = true }
    -- Weakened Soul
    A{ id = 6788, type = "HARMFUL", assignto = "spell3", priority = 70, color = { 0.8, 0, 0}, showDuration = true }

    -- Prayer of Healing
    Trace{id = { 596, 996, 10960, 10961, 15019, 25316 }, type = "HEAL", assignto = "healfeedback", color = { .5, .5, 1}, fade = 0.7, priority = 96 }
    -- Flash Heal
    Trace{id = { 2061, 9472, 9473, 9474, 10915, 10916, 10917 } , type = "HEAL", assignto = "healfeedback", color = { 0.6, 1, 0.6}, fade = 0.7, priority = 96 }
    -- Greater Heal
    Trace{id = { 2060, 10963, 10964, 10965, 25314 }, type = "HEAL", assignto = "healfeedback", color = { 0.7, 1, 0.7}, fade = 0.7, priority = 96 }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(17), -- Disc: PWS
        RangeCheckBySpell(139),-- Holy: Renew
        RangeCheckBySpell(17), -- Shadow: PWS
    }

    -- DispelTypes("MAGIC|DISEASE")

end

if playerClass == "DRUID" then
    -- Mark of the Wild, Gift of the Wild
    A{ id = { 1126, 5232, 5234, 6756, 8907, 9884, 9885, 21849, 21850 }, type = "HELPFUL", assignto = "raidbuff", color = { 1, 0.2, 1}, priority = 100, isMissing = true }

    -- Rejuvenation
    A{ id = { 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299 }, type = "HELPFUL", assignto = "bars", priority = 90, color = { 1, 0.2, 1}, showDuration = true, isMine = true }
    -- Regrowth
    A{ id = { 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858 }, type = "HELPFUL", assignto = "bars", priority = 80, color = { 0.4, 1, 0.4}, showDuration = true, isMine = true }
    --Abolish Poison
    A{ id = 2893, type = "HELPFUL", assignto = "bars", priority = 30, color = {15/255, 78/255, 60/255} , showDuration = true, isMine = true }

    -- Healing Touch
    Trace{id = { 5185, 5186, 5187, 5188, 5189, 6778, 8903, 9758, 9888, 9889, 25297 } , type = "HEAL", assignto = "healfeedback", color = { 0.6, 1, 0.6}, fade = 0.7, priority = 96 }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
    }

     -- DispelTypes("MAGIC|CURSE|POISON")
end


if playerClass == "PALADIN" then

    -- Forbearance
    A{ id = 25771, type = "HARMFUL", assignto = "bars", showDuration = true, color = { 0.8, 0, 0 } }
    -- Blessing of Freedom
    -- A{ id = 1044, type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 1, 0.4, 0.2} }

    -- Holy Light
    Trace{id = { 635, 639, 647, 1026, 1042, 3472, 10328, 10329, 25292 } , type = "HEAL", assignto = "healfeedback", color = { 1, 1, 0.6}, fade = 0.7, priority = 96 }
    -- Flash of Light
    Trace{id = { 19750, 19939, 19940, 19941, 19942, 19943 } , type = "HEAL", assignto = "healfeedback", color = { 0.6, 1, 0.6}, fade = 0.7, priority = 96 }


    config.UnitInRangeFunctions = {
        RangeCheckBySpell(635), -- Holy Light
        RangeCheckBySpell(635),
        RangeCheckBySpell(635),
    }

    -- DispelTypes("MAGIC|DISEASE|POISON")

end

-- if playerClass == "HUNTER" then
--     -- Trueshot Aura
--     A{ id = { 19506, 20905, 20906 }, type = "HELPFUL", assignto = "raidbuff", color = { 1, 1, 1}, priority = 100, isMissing = true }
-- end

if playerClass == "SHAMAN" then

    -- Healing Way
    A{ id = 29203, type = "HELPFUL", assignto = "bar4", showStacks = 3, color = {38/255, 221/255, 163/255} }

    -- Ancestral Healing
    A{ id = { 16177, 16236, 16237 }, type = "HELPFUL", assignto = "bars", showDuration = true, color = { 1, 0.85, 0} }

    -- Chain Heal
    Trace{id = { 1064, 10622, 10623 }, type = "HEAL", assignto = "healfeedback", color = { 1, 1, 0 }, fade = 0.7, priority = 96 }
    -- Healing Wave incl Lesser Wave
    Trace{id = { 331, 332, 547, 913, 939, 959, 8004, 8005, 8008, 8010, 10395, 10396, 10466, 10467, 10468, 25357 }, type = "HEAL", assignto = "healfeedback", color = { 0.5, 1, 0.5 }, fade = 0.7, priority = 96 }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
    }

    -- DispelTypes("POISON|DISEASE")

end

if playerClass == "MAGE" then

    -- Arcane Intellect and Brilliance
    A{ id = { 1459, 1460, 1461, 10156, 10157, 23028 }, type = "HELPFUL", assignto = "raidbuff", color = { .4 , .4, 1 }, priority = 50, isMissing = true }
    -- Dampen Magic
    A{ id = { 604, 8450, 8451, 10173, 10174 }, type = "HELPFUL", assignto = "spell3", color = {52/255, 172/255, 114/255}, priority = 80 }
    -- Amplify Magic
    A{ id = { 1008, 8455, 10169, 10170 }, type = "HELPFUL", assignto = "spell3", color = {1,0.7,0.5}, priority = 80 }

    -- DispelTypes("CURSE")
end

if playerClass == "WARRIOR" then

    -- Battle Shout
    A{ id = { 5242, 6192, 6673, 11549, 11550, 11551, 25289 }, type = "HELPFUL", assignto = "raidbuff", color = { 1, .4 , .4}, priority = 50 }

end


helpers.auraBlacklist = {
    [26013] = true, -- PVP Deserter
    [8326] = true, -- Ghost
    [25771] = true, -- Forbearance
    [6788] = true, -- Weakened Soul
    [11196] = true, -- Recently Bandaged

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