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
local AddAuraToContainer = helpers.AddAuraToContainer
local ChangeWidgetColorForContainer = helpers.ChangeWidgetColorForContainer

local isForever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
if not isForever then return end


AddAuraToContainer("BigDefensive", {
    871, -- Shield Wall
    20230, -- 20230

    1856, 1857, -- Vanish

    498, 5573, 642, 1020, -- Divine Shield
    1022, 5599, 10278, -- Blessing of Protection
    11958, -- Ice Block
})


AddAuraToContainer("PersonalDefensive", {
    -- WARLOCK
    6229, 11739, 11740, 28610, -- Shadow Ward

    -- DRUID
    22812, 428713, -- Barkskin
    29166, -- Innervate
    408024, -- Survival Instincts[SoD]


    -- MAGE
    543, 8457, 8458, 10223, 10225, -- Fire Ward
    6143, 8461, 8462, 10177, 28609, -- Frost Ward

    -- PALADIN
    1022, 5599, 10278, -- Blessing of Protection
    1044, -- Blessing of Freedom

    -- HUNTER
    19263, -- Deterrence

    -- WARRIOR
    20230, -- Retaliation
    12976, --Last Stand
    -- 402913, -- Enraged Regeneration[SoD]

    -- ROGUE
    5277, -- Evasion

    -- WARLOCK
    6229, 11739, 11740, 28610, -- Shadow Ward


    -- Healing Reduction
    -- { 12294, 21551, 21552, 21553 }, color = { 147/255, 54/255, 115/255 }, template = "bossDebuff", global = true, } --Mortal Strike

    -- Battleground
    23333, --Warsong Flag
    23335, --Silverwing Flag


    1784, 5215, 20580, -- Stealth, Prowl, Shadowmeld

    5384, -- Feign Death
})



-- Used for Water on Forever
AddAuraToContainer("OffensiveCD", {
    430, 431, 432, 1133, 1135, 1137, 22734, 24355, 29007, 26473, 26261, -- Classic water
    468767, -- SoD
})

--[[
-- WARLOCK
AG{ id = { 6229, 11739, 11740, 28610 }, template = "SurvivalCD" } -- Shadow Ward

-- DRUID
AG{ id = { 22812, 428713 } ,  template = "SurvivalCD" } -- Barkskin
AG{ id = 29166,  template = "SurvivalCD" } -- Innervate
AG{ id = 408024,  template = "SurvivalCD" } -- Survival Instincts[SoD]


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
AG{ id = 402913, template = "SurvivalCD" } -- Enraged Regeneration[SoD]

-- ROGUE
AG{ id = 5277, template = "SurvivalCD" } -- Evasion
AG{ id = { 1856, 1857 }, template = "TankCD" } -- Vanish

-- WARLOCK
AG{ id = { 6229, 11739, 11740, 28610 },  template = "SurvivalCD" } -- Shadow Ward

-- PRIEST [SOD]
AG{ id = 402004,  template = "TankCD" } -- Pain Suppression [SoD]
AG{ id = 425294,  template = "SurvivalCD" } -- Dispersion [SoD]
AG{ id = 425284,  template = "SurvivalCD" } -- Spirit of the Redeemer[SoD]


-- Healing Reduction
-- AG{ id = { 12294, 21551, 21552, 21553 }, color = { 147/255, 54/255, 115/255 }, template = "bossDebuff", global = true, } --Mortal Strike

-- Battleground
AG{ id = 23333, type = "HELPFUL", assignto = set("raidbuff"), scale = 1.7, color = {1,0,0}, priority = 95, global = true, } --Warsong Flag
AG{ id = 23335, type = "HELPFUL", assignto = set("raidbuff"), scale = 1.7, color = {0,0,1}, priority = 95, global = true, } --Silverwing Flag

-- Soulstone Resurrection
AG{ id = { 20707, 20762, 20763, 20764, 20765 }, type = "HELPFUL", global = true, assignto = set("raidbuff"), color = { 0.6, 0, 1 }, priority = 20 }

AG{ id = {
    430, 431, 432, 1133, 1135, 1137, 22734, 24355, 29007, 26473, 26261, -- Classic water
    468767, -- SoD
}, assignto = set("text2"), color = {0.7, 0.7, 1}, text = "DRINKING", global = true, priority = 30 }

-- Stealth, Prowl, Shadowmeld
AG{ id = {1784, 5215, 20580}, assignto = set("text2"), color = {0.2, 1, 0.3}, text = "STEALTH", priority = 20 }

AG{ id = 5384, assignto = set("text2"), color = {0, 0.7, 1}, text = "FD", global = true, priority = 75 } -- Feign Death
]]

if playerClass == "PRIEST" then

    AddAuraToContainer("bars", {
        139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315, -- Renew
        7001, 27873, 27874, -- Lightwell Renew
        17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, -- Power Word: Shield
        6788, -- Weakened Soul
        552, -- Abolish Disease
        10060, -- Power Infusion
    })

    AddAuraToContainer("bar4", {
        401877, 1240848, 1240849, -- Prayer of Mending
    })
    ChangeWidgetColorForContainer("bar4",  1, .3, .3)

    --[[
    -- Season of Discovery
    -- Prayer of Mending
    A{ id = { 401859, 402832, 401882, 401880, 401877, 401863 }, type = "HELPFUL", assignto = set("bar4"), priority = 70, isMine = true, color = { 1, 0, 102/255 }, maxCount = 5, infoType = "COUNT" }
    -- Penance
    Trace{id = 402289, template = "HealTrace", color = { 52/255, 172/255, 114/255 } }
    -- Circle of Healing
    Trace{id = 401946, template = "HealTrace", color = { 1, 0.7, 0.35} }
    -- Emp Renew
    A{ id = { 425268, 425269, 425270, 425271, 425272, 425273, 425274, 425275, 425276, 425277 }, type = "HELPFUL", isMine = true, assignto = set("bars"), priority = 50, color = { 0, 1, 0}, foreigncolor = {0.1, 0.4, 0.1}, showDuration = true }



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
    ]]

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(2050), -- Lesser Heal Rank 1
        RangeCheckBySpell(2050),
        RangeCheckBySpell(2050),
    }

end

if playerClass == "DRUID" then
    AddAuraToContainer("bars", {
        774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299, -- Rejuvenation
        8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, -- Regrowth
        2893, -- Abolish Poison
        408120, 1238214, 1238215 -- Wild Growth
    })

    AddAuraToContainer("bar4", {
        408124, -- Lifebloom
        29166, -- Innervate
    })
    ChangeWidgetColorForContainer("bar4", 0.2, 1, 0.2)


    --[[
    -- Season of Discovery
    -- Lifebloom
    A{ id = 408124, type = "HELPFUL", assignto = set("bar4", "bar4text"), priority = 60, infoType = "DURATION", isMine = true, color = { 0.2, 1, 0.2}, foreigncolor =  { 0.1, 0.5, 0.1} }
    -- Wild Growth
    A{ id = 408120, type = "HELPFUL", assignto = set("bars"), color = { 0, 0.9, 0.7}, priority = 60, infoType = "DURATION", isMine = true, foreigncolor =  { 0, 0.45, 0.35}}
    -- Rejuvenation with Enhanced Restoration
    A{ id = { 417057, 417058, 417059, 417060, 417061, 417062, 417063, 417064, 417065, 417066, 417068 }, name = "EnhancedRejuvenation", type = "HELPFUL", assignto = set("bars"), isMine = true, priority = 90, color = { 1, 0.2, 1}, foreigncolor = { 0.4, 0.1, 0.4 }, showDuration = true }
    -- Regrowth with Enhanced Restoration
    A{ id = { 436937, 436938, 436939, 436940, 436942, 436943, 436944, 436945, 436946 }, name = "EnhancedRegrowth", type = "HELPFUL", assignto = set("bars"), isMine = true, priority = 80, color = { 0.4, 1, 0.4}, foreigncolor = { 0.1, 0.4, 0.1 }, showDuration = true }



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
    ]]

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
    }
end


if playerClass == "PALADIN" then

    AddAuraToContainer("bars", {
        1044, -- Blessing of Freedom
    })

    AddAuraToContainer("bar4", {
        1310909, 1311593, 1311597, -- Light's Vigil
    })
    ChangeWidgetColorForContainer("bar4",  0.96/2, 0.55/2, 0.73/2)

    --[[
    -- Season of Discovery
    -- Beacon of Light
    A{ id = 407613, type = "HELPFUL", assignto = set("bar4"), infoType = "DURATION", isMine = true, color = { 0,.9,0 }, foreigncolor = { 0.96/2, 0.55/2, 0.73/2 }, }
    -- Horn of Lordaeron
    A{ id = 425600, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, .4 , 1}, priority = 50 }
    -- Sacred Shield
    A{ id = 412019, type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", priority = 86, scale = 0.5, isMine = true, color = { 1 , 0.9, 0} }
    -- Sacred Shield Proc
    A{ id = 412018, type = "HELPFUL", name = "SacredShieldProc", assignto = set("bars"), infoType = "DURATION", priority = 85, scale = 1, isMine = true, color = { 1 , 0.7, 0} }



    -- Forbearance
    A{ id = 25771, type = "HARMFUL", assignto = set("bars"), showDuration = true, color = { 0.8, 0, 0 } }
    -- Blessing of Freedom
    -- A{ id = 1044, type = "HELPFUL", assignto = set("bars"), showDuration = true, isMine = true, color = { 1, 0.4, 0.2} }

    -- Holy Light
    Trace{id = { 635, 639, 647, 1026, 1042, 3472, 10328, 10329, 25292 } , template = "HealTrace", color = { 1, 1, 0.6} }
    -- Flash of Light
    Trace{id = { 19750, 19939, 19940, 19941, 19942, 19943 } , template = "HealTrace", color = { 0.6, 1, 0.6} }
    ]]

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(635), -- Holy Light
        RangeCheckBySpell(635),
        RangeCheckBySpell(635),
    }
end

-- if playerClass == "HUNTER" then
--     -- Trueshot Aura
--     A{ id = { 19506, 20905, 20906 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 1, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(19506) end }
-- end

if playerClass == "SHAMAN" then
    AddAuraToContainer("bars", {
        408521, 1239242, 1239243, -- Riptide
    })

    AddAuraToContainer("bar4", {
        408514, -- Earth Shield
    })
    ChangeWidgetColorForContainer("bar4",  0.2, 1, 0.2)

    --[[
    -- SoD
    A{ id = 408696, type = "HELPFUL", assignto = set("spell3"), color = { 1, .4 , 1}, priority = 50 } -- Spirit of the Alpha
    -- Riptide SoD
    A{ id = 408521,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", scale = 1.3, isMine = true, color = { 0.4 , 0.4, 1} }

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
    -- Healing Wave
    Trace{id = { 331, 332, 547, 913, 939, 959, 8005, 10395, 10396, 25357 }, template = "HealTrace", color = { 0.5, 1, 0.5 } }
    -- Lesser Healing Wave
    Trace{id = { 8004, 8008, 8010, 10466, 10467, 10468 }, template = "HealTrace", color = { 0.5, 1, 0.5 } }

    ]]
    config.UnitInRangeFunctions = {
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
    }
end

if playerClass == "MAGE" then
    AddAuraToContainer("bars", {
        604, 8450, 8451, 10173, 10174, -- Dampen Magic
        1008, 8455, 10169, 10170, -- Amplify Magic
    })

    --[[
    -- Season of Discovery
    -- Regeneration
    A{ id = 401417, type = "HELPFUL", assignto = set("bars"), priority = 50, color = { 0, 1, 0}, foreigncolor = {0.1, 0.4, 0.1}, infoType = "DURATION", }
    -- Mass Regeneration
    A{ id = 412510, type = "HELPFUL", assignto = set("bars"), priority = 51, color = { 0, 0.9, 0}, foreigncolor = {0.1, 0.4, 0.1}, infoType = "DURATION", }
    -- Temporal Beacon
    A{ id = 400735, type = "HELPFUL", assignto = set("bar4"), extend_below = 30, color = { 1, .3, .3}, infoType = "DURATION", isMine = true}



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
    ]]
end

if playerClass == "WARRIOR" then
    AddAuraToContainer("bars", {
        5242, 6192, 6673, 11549, 11550, 11551, 25289, -- Battle Shout
    })

    -- Battle Shout
    -- A{ id = { 5242, 6192, 6673, 11549, 11550, 11551, 25289 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, .4 , .4}, priority = 50 }

end

-------------------------
-- Blacklist
-------------------------

helpers.auraBlacklist = {
    [1229451] = true, -- Boosted Rest

    [432069] = true, -- Tangled Causality (Season of Discovery Mage Healing debuff)
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


helpers.importantTargetedCasts = {}
