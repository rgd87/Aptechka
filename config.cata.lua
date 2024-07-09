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
local isCata = apiLevel == 4
if not isCata then return end

config.HealthTextStatus.formatType = "MISSING_HEALING_SHORT"

local color1 = { 0.9, 0, 0 }

-- WARLOCK
AG{ id = { 6229, 11739, 11740, 28610, 47891 }, template = "SurvivalCD" } -- Shadow Ward

-- DRUID
AG{ id = 22812,  template = "SurvivalCD" } -- Barkskin
AG{ id = 44203,  template = "SurvivalCD" } -- Tranquility
-- AG{ id = 29166,  template = "SurvivalCD" } -- Innervate

-- PRIEST
AG{ id = 33206, template = "TankCD", priority = 93 } --Pain Suppression
AG{ id = 47585, template = "SurvivalCD" } -- Dispersion
AG{ id = 47788, template = "SurvivalCD", priority = 90 } --Guardian Spirit
AG{ id = 64843, template = "SurvivalCD" } -- Hymn of Hope

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
AG{ id = 98007, template = "AreaDR" } -- Spirit Link Totem

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
    80166, 80167, 87959, 105232, 118358, -- Cata
    24707, 26263, 66041, -- % Food
}, assignto = set("text2"), color = {0.7, 0.7, 1}, text = "DRINKING", global = true, priority = 30 }

-- Stealth, Prowl
AG{ id = {1784, 5215 }, assignto = set("text2"), color = {0.2, 1, 0.3}, text = "STEALTH", priority = 20 }

-- AG{ id = 5384, assignto = set("text2"), color = {0, 0.7, 1}, text = "FD", global = true, priority = 75 } -- Feign Death

if playerClass == "PRIEST" then
    -- Power Word: Fortitude
    A{ id = 79105, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 1, 1}, priority = 50, isMissing = true, isKnownCheck = function() return IsPlayerSpell(21562) end}

    -- Prayer of Shadow Protection
    A{ id = 79107 , type = "HELPFUL", assignto = set("raidbuff"), color = { 151/255, 86/255, 168/255 }, priority = 80, isMissing = true, isKnownCheck = function() return IsPlayerSpell(27683) end }

    A{ id = 6346, type = "HELPFUL", assignto = set("bar4"), priority = 30, color = { 1, 0.7, 0} , infoType = "DURATION" } -- Fear Ward

    -- Abolish Disease
    A{ id = 552, type = "HELPFUL", assignto = set("bars"), priority = 30, color = { 118/255, 69/255, 50/255} , infoType = "DURATION" }
    -- Renew
    A{ id = 139, type = "HELPFUL", isMine = true, assignto = set("bars"), priority = 50, color = { 0, 1, 0}, foreigncolor = {0.1, 0.4, 0.1}, infoType = "DURATION" }
    -- Lightwell Renew
    A{ id = 7001, type = "HELPFUL", assignto = set("bars"), priority = 20, color = { 0.5, 0.7, 0}, infoType = "DURATION" }
    -- Power Word: Shield
    A{ id = 17, type = "HELPFUL", assignto = set("bars"), priority = 90, color = { 1, 0.85, 0}, foreigncolor = {0.4, 0.35, 0.1}, infoType = "DURATION" }
    -- Weakened Soul
    A{ id = 6788, type = "HARMFUL", assignto = set("spell3"), priority = 70, color = { 0.8, 0, 0}, infoType = "DURATION" }
    --Prayer of Mending
    A{ id = 41635, type = "HELPFUL", assignto = set("bar4"), priority = 70, isMine = true, color = { 1, 0, 102/255 }, maxCount = 5, infoType = "COUNT" }

    -- Penance
    Trace{id = 47750, template = "HealTrace", color = { 52/255, 172/255, 114/255 } }
    -- Prayer of Healing
    Trace{id = 596, template = "HealTrace", color = { .5, .5, 1} }
    -- Flash Heal
    Trace{id = 2061, template = "HealTrace", color = { 0.6, 1, 0.6} }
    -- Greater Heal
    Trace{id = 2060, template = "HealTrace", color = { 0.7, 1, 0.7} }
    -- Heal
    Trace{id = 2050, template = "HealTrace", color = { 0.7, 1, 0.7} }

    -- Circle of Healing
    Trace{id = 34861, template = "HealTrace", color = { 1, 0.7, 0.35} }
    -- Prayer of Mending
    Trace{id = 33110, template = "HealTrace", color = { 1, 0.3, 0.55 }, fade = 0.5, priority = 95 }


    config.UnitInRangeFunctions = {
        RangeCheckBySpell(2061), -- Flash Heal
        RangeCheckBySpell(2061),
        RangeCheckBySpell(2061),
    }

    config.DispelBitmasks = {
        DispelTypes("Magic", "Disease")
    }

end

if playerClass == "DRUID" then
    -- Mark of the Wild
    A{ id = 79061, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 0.2, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(1126) end }


    -- Rejuvenation
    A{ id = 774, type = "HELPFUL", assignto = set("bars"), isMine = true, priority = 90, color = { 1, 0.2, 1}, foreigncolor = { 0.4, 0.1, 0.4 }, infoType = "DURATION" }
    -- Regrowth
    A{ id = 8936, type = "HELPFUL", assignto = set("bars"), isMine = true, scale = 0.5, color = { 0, 0.8, 0.2}, priority = 50, infoType = "DURATION" }
    -- Abolish Poison
    A{ id = 2893, type = "HELPFUL", assignto = set("bars"), priority = 30, color = {15/255, 78/255, 60/255} , infoType = "DURATION", isMine = false }
    -- Lifebloom
    A{ id = 33763, type = "HELPFUL", assignto = set("bar4", "bar4text"), priority = 60, infoType = "DURATION", isMine = true, color = { 0.2, 1, 0.2}, }
    -- Wild Growth
    A{ id = 48438, type = "HELPFUL", assignto = set("bars"), color = { 0, 0.9, 0.7}, priority = 60, infoType = "DURATION", isMine = true }

    -- Healing Touch
    Trace{id = 5185, template = "HealTrace", color = { 0.6, 1, 0.6} }
    Trace{id = 8936, template = "HealTrace", color = { 0, 0.8, 0.2 } } -- Regrowth
    Trace{id = 50464, template = "HealTrace", color = { 0.6, 0.2, 0.4 } } -- Nourish

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
        RangeCheckBySpell(5185),
    }

    config.DispelBitmasks = {
        function(spec)
            if IsPlayerSpell(88423) then -- Nature's Cure
                return DispelTypes("Magic", "Curse", "Poison")
            else
                return DispelTypes("Curse", "Poison")
            end
        end
    }
end


if playerClass == "PALADIN" then


    -- Holy Radiance
    A{ id = 82327, type = "HARMFUL", assignto = set("bars"), infoType = "DURATION", color = { 0, 0.9, 0.7 } }
    -- Forbearance
    A{ id = 25771, type = "HARMFUL", assignto = set("bars"), infoType = "DURATION", color = { 0.8, 0, 0 } }
    -- Blessing of Freedom
    A{ id = 1044, type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 1, 0.4, 0.2} }

    A{ id = 53563, type = "HELPFUL", assignto = set("bar4"), infoType = "DURATION",
                                                                            isMine = true,
                                                                            color = { 0, 0.9,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Light

    Trace{id = 85222, template = "HealTrace", color = { 1, 0.7, 0.2} } -- Light of Dawn
    -- Flash of Light
    Trace{id = 19750, template = "HealTrace", color = { 0.6, 1, 0.6} }
    -- Holy Light
    Trace{id = 82326, template = "HealTrace", color = { 1, 0.3, 0.55 } }
    -- Holy Shock
    Trace{id = 25914, template = "HealTrace", color = { 1, 0.6, 0.3 } }


    config.UnitInRangeFunctions = {
        RangeCheckBySpell(635), -- Holy Light
        RangeCheckBySpell(635),
        RangeCheckBySpell(635),
    }

    config.DispelBitmasks = {
        function(spec)
            if IsPlayerSpell(53551) then -- Sacred Cleansing
                return DispelTypes("Magic", "Disease", "Poison")
            else
                return DispelTypes("Disease", "Poison")
            end
        end
    }

end

-- if playerClass == "HUNTER" then
--     -- Trueshot Aura
--     A{ id = { 19506, 20905, 20906 }, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 1, 1}, priority = 100, isMissing = true, isKnownCheck = function() return IsPlayerSpell(19506) end }
-- end

if playerClass == "SHAMAN" then

    -- Earth Shield
    A{ id = 974, type = "HELPFUL", assignto = set("bar4"), infoType = "COUNT", maxCount = 6, color = {0.2, 1, 0.2}, foreigncolor = {0, 0.5, 0} }
    --Riptide
    A{ id = 61295,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", scale = 1.3, refreshTime = 5.4, refreshColor = { 1, 0.1, 0.1}, isMine = true, color = { 0.4 , 0.4, 1} } --Riptide

    -- Ancestral Fortitude
    A{ id = { 16177, 16236, 16237 }, type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", color = { 1, 0.85, 0} }

    Trace{id = 77472, template = "HealTrace", color = { 0.5, 1, 0.4 } } -- Greater Healing Wave
    Trace{id = 331, template = "HealTrace", color = { 0.5, 1, 0.4 } } -- Healing Wave
    Trace{id = 8004, template = "HealTrace", color = { 0.5, 1, 0.4 } } -- Healing Surge
    Trace{id = 1064, template = "HealTrace", color = { 0.9, 0.7, 0.1} } -- Chain Heal

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
        RangeCheckBySpell(331),
    }

    config.DispelBitmasks = {
        function(spec)
            if IsPlayerSpell(77130) then -- Improved Cleanse Spirit
                return DispelTypes("Magic", "Curse")
            else
                return DispelTypes("Curse")
            end
        end
    }

end

if playerClass == "MAGE" then

    -- Arcane Intellect and Brilliance
    A{ id = 79058, type = "HELPFUL", assignto = set("raidbuff"), color = { .4 , .4, 1 }, priority = 50, isMissing = true }

    config.DispelBitmasks = {
        DispelTypes("Curse")
    }
end

if playerClass == "WARRIOR" then

    -- Battle Shout
    -- A{ id = 6673, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, .4 , .4}, priority = 50 }
    -- Commanding Shout
    -- A{ id = 469, type = "HELPFUL", assignto = set("raidbuff"), color = { 0.4, 0.4 , 1}, priority = 49 }

end

if playerClass == "DEATHKNIGHT" then

    -- Horn of Winter
    A{ id = 57330, type = "HELPFUL", assignto = set("raidbuff"), color = { 0.6, 0, 1 }, priority = 50 }

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
    [142] = "The Ruby Sanctum",

    [111] = "Utgarde Keep",
    [112] = "The Culling of Stratholme",

    [773] = "TotFW",
    [754] = "Blackwing Descent",
    [757] = "Bastion of Twilight",
    [780] = "ZulAman",
    [792] = "ZulGurub",
    [799] = "Firelands",
    [824] = "DragonSoul",

    [1701] = "PvP",
}

config.defaultDebuffHighlights = {
    ["PvP"] = {
        [33786] = { 33786, 3, "Cyclone" },
    },



    ["DragonSoul"] = {
        [100460] = { 100460, 1, "Disrupting Shadows, Warlord Zon'ozz" },

        [109325] = { 109325, 1, "Frostflake, Hagara the Stormbinder" },
        [104451] = { 104451, 3, "Ice Tomb, Hagara the Stormbinder" },
        [105369] = { 105369, 2, "Lightning Conduit, Hagara the Stormbinder" },
        [105927] = { 105927, 1, "Faded into Twilight, Hagara the Stormbinder" },

        [107558] = { 107558, 2, "Degeneration, Warmaster Blackhorn" },
        [107567] = { 107567, 2, "Brutal Strike, Warmaster Blackhorn" },
        [108043] = { 108043, 1, "Sunder Armor, Warmaster Blackhorn" },

        [105479] = { 105479, 2, "Searing Plasma, Spine of Deathwing" },
        [105490] = { 105490, 1, "Fiery Grip, Spine of Deathwing" },

        [106730] = { 106730, 1, "Tetanus, Madness of Deathwing" },
    },
    ["Firelands"] = {
        [98981] = { 98981, 1, "Lava Bolt, Ragnaros" },
        [100460] = { 100460, 2, "Blazing Heat, Ragnaros" },

        [98443] = { 98443, 1, "Fiery Cyclone, Majordomo Staghelm" },
        [98450] = { 98450, 2, "Searing Seeds, Majordomo Staghelm" },

        [99516] = { 99516, 2, "Countdown, Baleroc" },
        -- [99403] = { 99403, 4, "Tormented, Baleroc" },
        [99256] = { 99256, 1, "Torment, Baleroc" },

        [99936] = { 99936, 1, "Jagged Tear, Shannox" },
        [99837] = { 99837, 3, "Crystal Prison Trap Effect, Shannox" },
        -- [101208] = { 101208, 2, "Immolation Trap, Shannox" },

        [99308] = { 99308, 1, "Gushing Wound, Alysrazor" },

        [98492] = { 98492, 1, "Eruption, Lord Rhyolith" },

        --[97202] = { 97202, 1, "Fiery Web Spin, Cinderweb Spinner, Beth'tilac" },
        [49026] = { 49026, 1, "Fixate, Cinderweb Drone, Beth'tilac" },
    },

    ["ZulGurub"] = {
        [96776] = { 96776, 1, "Bloodletting, Mandokir" },
        [96475] = { 96475, 2, "Toxis Link, Venoxis" },
    },

    ["ZulAman"] = {
        [43657] = { 43657, 1, "Electrical Storm, Akil'zon" },

        -- [97811] = { 97811, 2, "Lacerating Slash, Nalorakk" },
        -- [42402] = { 42402, 1, "Surge, Nalorakk" },

        -- [188389] = { 188389, 2, "Flame Shock, Halazzi" },
        [78617] = { 78617, 1, "Fixate, Halazzi" },

        [43093] = { 43093, 1, "Grievous Throw, Daakara" },
        [43150] = { 43150, 4, "Claw Rage, Daakara" },
    },

    ["Bastion of Twilight"] = {
        [86788] = { 86788, 3, "Blackout, Valiona" },
        [86013] = { 86013, 2, "Twilight Meteorite, Valiona" },


        --Magic--
        [81836] = { 81836, 1, "Corruption: Accelerated, Cho'gall" },
        -- [93202] = { 93202, 2, "Corruption: Sickness, Cho'gall" },
        [91303] = { 91303, 3, "Conversion, Cho'gall" },
        -- [93133] = { 93133, 1, "Debilitating Beam,Cho'gall" },

        [89421] = { 89421, 2, "Wrack, Lady Sinestra" },
    },

    ["Blackwing Descent"] = {
        [79589] = { 79589, 4, "Constricting Chains, Drakonid Chainwielder" },
        [77786] = { 77786, 4, "Consuming Flames, Maloriak" },
        [79889] = { 79889, 1, "Lightning Conductor, Omnitron Defense System" },
        [80011] = { 80011, 2, "Soaked In Poison, Omnitron Defense System" },
        [77699] = { 77699, 3, "Flash Freeze, Maloriak" },
    },

    ["TotFW"] = {
        [89666] = { 89666, 1, "Lightning Rod" },
    },



    -- Wrath
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
    },
    ["Icecrown Citadel"] = {
        [72670] = { 72670, 1, "Impale, Lord Marrowgar" },
        [72385] = { 72385, 1, "Boiling Blood, Deathbringer Saurfang" },
        [72293] = { 72293, 2, "Mark of the Fallen Champion, Deathbringer Saurfang" },
        -- [69279] = { 69279, 1, "Gas Spore, Festergut" },
        [72272] = { 72272, 3, "Vile Gas, Festergut" },
        [69674] = { 69674, 3, "Mutated Infection, Rotface" },
        [70157] = { 70157, 3, "Ice Tomb, Sindragosa" },
        [70126] = { 70126, 4, "Frost Beacon, Sindragosa" },

        [70338] = { 70338, 1, "Necrotic Plague, Lich King" },
        [68980] = { 68980, 2, "Harvest Soul, Lich King" },
        [69409] = { 69409, 4, "Soul Reaper, Lich King" },
    },
    ["The Ruby Sanctum"] = {
        [74562] = { 74562, 1, "Fiery Combustion, Halion" },
        [74792] = { 74792, 2, "Soul Consumption, Halion" },
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
        [2825] = CAST, -- Bloodlust
        [32182] = CAST, -- Heroism
        [2894] = CAST, -- Fire Elemental Totem
        [16166] = AURA, -- Elemental Mastery
        [51533] = CAST, -- Feral Spirit
        [98008] = CAST, -- Spirit Link Totem
    }
    end
