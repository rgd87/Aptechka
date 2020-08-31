local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local DispelTypes = helpers.DispelTypes
local D = helpers.AddDebuff
local Trace = helpers.AddTrace
local pixelperfect= helpers.pixelperfect
local config = AptechkaDefaultConfig

config.raidIcons = true
config.frameStrata = "MEDIUM"
config.maxgroups = 8
config.petcolor = {1,.5,.5}
--A maximum of 5 pets can be displayed.

config.defaultFont = "ClearFont"
do
    local locale = GetLocale()
    if locale == "zhTW" or locale == "zhCN" or locale == "koKR" then
        config.defaultFont = LibStub("LibSharedMedia-3.0").DefaultMedia["font"]
        -- "預設" - zhTW
        -- "默认" - zhCN
        -- "기본 글꼴" - koKR
    end
end

config.registerForClicks = { "AnyUp" }
config.enableIncomingHeals = true
config.incomingHealIgnorePlayer = false
config.displayRoles = true
config.enableTraceHeals = true
config.enableVehicleSwap = true
config.enableAbsorbBar = true

config.TargetStatus = { name = "Target", assignto = "border", color = {0.7,0.2,0.5}, priority = 65 }
config.MouseoverStatus = { name = "Mouseover", assignto = "border", color = {1,0.5,0.8}, priority = 66 }
config.AggroStatus = { name = "Aggro", assignto = "raidbuff",  color = { 0.7, 0, 0},priority = 110, jump = true }
config.ReadyCheck = { name = "Readycheck", priority = 90, assignto = "spell3", stackcolor = {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { .8, .6, 0},
                                                                        }}

config.LeaderStatus = { name = "Leader", priority = 59, assignto = "text3", color = {1,.8,.2}, text = "L" }
-- config.AssistStatus = { name = "Assist", priority = 59, assignto = "text3", color = {1,.8,.2}, text = "A" }
config.VoiceChatStatus = { name = "VoiceChat", assignto = "text3", color = {0.3, 1, 0.3}, text = "S", priority = 99 }
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = "border", color = {0.6,0.6,0.6} }
config.LowHealthStatus = { name = "LowHealth", priority = 60, assignto = "border", color = {1,0,0} }
config.DeadStatus = { name = "DEAD", assignto = { "text2","health" }, color = {.05,.05,.05}, textcolor = {0,1,0}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "GHOST", assignto = { "text2","health" }, color = {.05,.05,.05},  textcolor = {0,1,0}, text = "GHOST", priority = 62}
config.OfflineStatus = { name = "OFFLINE", assignto = { "text2","text3","health" }, color = {.15,.15,.15}, textcolor = {0,1,0}, text = "OFFLINE",  priority = 70}
config.AwayStatus = { name = "AFK", assignto = { "text2","text3" }, color = {.15,.15,.15}, textcolor = {1,0.8,0}, text = "AFK",  priority = 60}
-- config.IncomingHealStatus = { name = "IncomingHeal", assignto = "text2", color = { 0, 1, 0}, priority = 15 }
config.HealthDeficitStatus = { name = "HealthDeficit", assignto = "healthtext", color = { 54/255, 201/255, 99/256 }, priority = 10 }
config.UnitNameStatus = { name = "UnitName", assignto = "text1", classcolor = true, priority = 20 }
config.HealthBarColor = { name = "HealthBar", assignto = "health", color = {1, .3, .3}, classcolor = true, priority = 10 }
config.PowerBarColor = { name = "PowerBar", assignto = "power", color = {.5,.5,1}, priority = 20 }
config.InVehicleStatus = { name = "InVehicle", assignto = "vehicle", color = {0.3,1,0.3}, priority = 21 }
config.LOSStatus = { name = "OutOfSight", assignto = "healfeedback", scale = 1.6, color = {1,0.1,0.1}, priority = 95, fade = 0.3 }
config.DispelStatus = { name = "Dispel", assignto = "bossdebuff", scale = 0.8, priority = 20 }
config.StaggerStatus = { name = "Stagger", assignto = "text2", priority = 20 }
config.RunicPowerStatus = { name = "RunicPower", assignto = "mitigation", priority = 10, color = { 0, 0.82, 1 } }

config.SummonPending = { name = "SUMMON_PENDING", assignto = { "text2" }, color = {1,0.7,0}, text = "PENDING", priority = 50 }
config.SummonAccepted = { name = "SUMMON_ACCEPTED", assignto = { "text2" }, color = {0,1,0}, text = "ACCEPTED", priority = 51 }
config.SummonDeclined = { name = "SUMMON_DECLINED", assignto = { "text2" }, color = {1,0,0}, text = "DECLINED", priority = 52 }

-- config.MindControl = { name = "MIND_CONTROL", assignto = { "mindcontrol" }, color = {1,0,0}, priority = 52 }
config.MindControlStatus = { name = "MIND_CONTROL", assignto = { "border", "mindcontrol", "innerglow" }, color = {0.5,0,1}, priority = 52 }
-- config.UnhealableStatus = { name = "UNHEALABLE", assignto = { "unhealable" }, color = {0.5,0,1}, priority = 50 }

config.DefaultWidgets = {
    raidbuff = { type = "BarArray", width = 5, height = 5, point = "TOPLEFT", x = 0, y = 0, vertical = true, growth = "DOWN", max = 5 },
    mitigation = { type = "Bar", width=22, height=4, point="BOTTOMLEFT", x=4, y=-5, vertical = false},
    icon = { type = "Icon", width = 24, height = 24, point = "CENTER", x = 0, y = 0, alpha = 1, font = "ClearFont", textsize = 12, outline = true, edge = true },
    spell1 = { type = "Indicator", width = 9, height = 8, point = "BOTTOMRIGHT", x = 0, y = 0, },
    -- spell2 = { type = "Indicator", width = 9, height = 8, point = "TOP", x = 0, y = 0, },
    spell3 = { type = "Indicator", width = 9, height = 8, point = "TOPRIGHT", x = 0, y = 0, },
    bar4 = { type = "Bar", width=21, height=5, point="TOPRIGHT", x=0, y=2, vertical = false},
    buffIcons = { type = "IconArray", width = 12, height = 18, point = "TOPRIGHT", x = 5, y = -6, alpha = 1, growth = "LEFT", max = 3, edge = true, outline = true, font = "ClearFont", textsize = 12 },
    bars = { type = "BarArray", width = 21, height = 5, point = "BOTTOMRIGHT", x = 0, y = 0, vertical = false, growth = "UP", max = 7 },
    vbar1 = { type = "Bar", width=4, height=20, point="TOPRIGHT", x=-9, y=2, vertical = true},
    text1 = { type = "StaticText", point="CENTER", x=0, y=0, font = config.defaultFont, textsize = 12, effect = "SHADOW" },
    text2 = { type = "StaticText", point="CENTER", x=0, y=-10, font = "ClearFont", textsize = 10, effect = "NONE" },
    text3 = { type = "Text", point="TOPLEFT", x=2, y=0, font = "ClearFont", textsize = 9, effect = "NONE" },
    incomingCastIcon = { type = "ProgressIcon", width = 18, height = 18, point = "TOPLEFT", x = -3, y = 3, alpha = 1, font = "ClearFont", textsize = 12, outline = false, edge = false },
}
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
if isClassic then
    config.DefaultWidgets.totemCluster1 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(6), y = 0 }
    config.DefaultWidgets.totemCluster2 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(12), y = 0 }
    config.DefaultWidgets.totemCluster3 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(19), y = 0 }
end
-- for name,w in pairs(config.DefaultWidgets) do
--     w.__protected = true
-- end

config.BossDebuffs = {
    { name = "BossDebuffLevel1", assignto = "bossdebuff", color = {1,0,0}, priority = 95, pulse = true, },
    { name = "BossDebuffLevel2", assignto = "bossdebuff", color = {1,0,1}, priority = 95, pulse = true, },
    { name = "BossDebuffLevel3", assignto = { "innerglow", "border", "flash" }, color = {1,0,0}, priority = 90 },
    { name = "BossDebuffLevel4", assignto = "pixelGlow", color = {1,1,1}, priority = 95 },
    -- { name = "BossDebuffLevel3", assignto = "autocastGlow", color = {1,1,0.3}, priority = 90 },
}

-- default priority is 80

local RangeCheckBySpell = helpers.RangeCheckBySpell



local tankCD = { type = "HELPFUL", assignto = "icon", global = true, showDuration = true, priority = 94, color = { 1, 0.2, 1} }
local survivalCD = { type = "HELPFUL", assignto = "buffIcons", global = true, showDuration = true, priority = 90, color = { 0.4, 1, 0.4} }
local activeMitigation = { type = "HELPFUL", assignto = "mitigation", showDuration = true, global = true, color = {0.7, 0.7, 0.7}, priority = 80 }

-- A{ id = 25163, type = "HARMFUL", assignto = "bossdebuff", scale = 0.85, color = { 1,0,0 }, priority = 40, pulse = true } -- Oozeling

-- ESSENCES
A{ id = 296094, prototype = tankCD } --Standstill (Artifice of Time)
A{ id = 296230, prototype = survivalCD } --Vitality Conduit
-- A{ id = 296211, type = "HELPFUL", assignto = "bars", color = { 1, 0.7, 0}, priority = 50, showDuration = true, isMine = true }

-- ACTIVE MITIGATION
A{ id = 132404, prototype = activeMitigation } -- Shield Block
A{ id = 132403, prototype = activeMitigation } -- Shield of the Righteousness
A{ id = 203819, prototype = activeMitigation } -- Demon Spikes
A{ id = 192081, prototype = activeMitigation } -- Ironfur

-- COVENANT
A{ id = 330749, prototype = survivalCD } -- Phial of Serenity

-- MONK
A{ id = 122783, prototype = survivalCD } -- Diffuse Magic
A{ id = 122278, prototype = survivalCD } -- Dampen Harm
A{ id = 132578, prototype = survivalCD } -- Invoke Niuzao
A{ id = 243435, prototype = survivalCD, priority = 91 } -- Fortifying Brew (Mistweaver/Windwalker)
A{ id = 125174, prototype = survivalCD, priority = 91 } -- Touch of Karma
A{ id = 115176, prototype = tankCD } -- Zen Meditation
A{ id = 116849, prototype = survivalCD, priority = 88 } --Life Cocoon
A{ id = 120954, prototype = tankCD } --Fortifying Brew (Brewmaster)

-- WARRIOR
A{ id = 184364, prototype = survivalCD } -- Enraged Regeneration
A{ id = 118038, prototype = survivalCD } -- Die by the Sword
A{ id = 12975,  prototype = activeMitigation, priority = 75 } --Last Stand
A{ id = 871,    prototype = tankCD } --Shield Wall 40%
A{ id = 107574, prototype = survivalCD, priority = 85 } --Avatar
A{ id = 23920, prototype = survivalCD, priority = 85 } --Spell Reflect

-- DEMON HUNTER
A{ id = 212800, prototype = survivalCD } -- Blur
A{ id = 187827, prototype = tankCD } -- Vengeance Meta

-- ROGUE
A{ id = 185311, prototype = survivalCD } -- Crimson Vial
-- A{ id = 1784,   prototype = survivalCD } -- Stealh
A{ id = 11327,  prototype = survivalCD } -- Vanish
A{ id = 5277,   prototype = survivalCD } -- Evasion
A{ id = 1966,   prototype = survivalCD } -- Feint
A{ id = 31224,  prototype = survivalCD, priority = 91 } -- Cloak of Shadows
A{ id = 45182,  prototype = tankCD } -- Cheating Death

-- WARLOCK
A{ id = 104773, prototype = survivalCD } -- Unending Resolve
A{ id = 132413, prototype = survivalCD } -- Shadow Bulwark

-- DRUID
-- local druidColor = { RAID_CLASS_COLORS.DRUID:GetRGB() }
A{ id = 22812,  prototype = survivalCD } -- Barkskin
A{ id = 102342, prototype = tankCD, priority = 93 } --Ironbark
A{ id = 61336,  prototype = tankCD } --Survival Instincts 50% (Feral & Guardian)

-- PRIEST
A{ id = 19236,  prototype = survivalCD } -- Desperate Prayer
A{ id = 586,  prototype = survivalCD } -- Fade
A{ id = 47585,  prototype = survivalCD } -- Dispersion
A{ id = 47788, prototype = tankCD, priority = 90 } --Guardian Spirit
A{ id = 33206, prototype = tankCD, priority = 93 } --Pain Suppression

-- PALADIN
A{ id = 642,    prototype = tankCD, priority = 95 } -- Divine Shield
A{ id = 1022,   prototype = survivalCD } -- Blessing of Protection
A{ id = 204018, prototype = survivalCD } -- Blessing of Spellwarding
A{ id = 184662, prototype = survivalCD } -- Shield of Vengeance
A{ id = 205191, prototype = survivalCD } -- Eye for an Eye
A{ id = 498,    prototype = survivalCD } -- Divine Protection
A{ id = 6940,   prototype = survivalCD } -- Blessing of Sacrifice
A{ id = 31850,  prototype = survivalCD, priority = 88 } --Ardent Defender
A{ id = 86659,  prototype = tankCD } --Guardian of Ancient Kings 50%
-- A{ id = 204150, prototype = tankCD, priority = 85 } -- Aegis of Light
-- Guardian of the Forgotten Queen - Divine Shield (PvP)
A{ id = 228050, prototype = tankCD, priority = 97 }

-- DEATH KNIGHT
A{ id = 194679, prototype = survivalCD } -- Rune Tap
A{ id = 55233,  prototype = tankCD, priority = 94 } --Vampiric Blood
A{ id = 48792,  prototype = tankCD, priority = 94 } --Icebound Fortitude 50%
A{ id = 81256,  prototype = survivalCD } -- Dancing Rune Weapon

-- MAGE
A{ id = 113862, prototype = survivalCD } -- Arcane Greater Invisibility
A{ id = 45438,  prototype = tankCD } -- Ice Block

-- HUNTER
A{ id = 186265, prototype = survivalCD } -- Aspect of the Turtle

-- SHAMAN
A{ id = 108271, prototype = survivalCD } -- Astral Shift
A{ id = 204293, prototype = survivalCD } -- Spirit Link (PvP)


A{ id = {
    170906, 192002, 195472, 225743, 251232, 257427, 257428, 272819, 279739, 297098, -- Food & Drink
    308429, 308433, 327786, 340109, -- Shadowlands Food & Drink
    167152, -- Mage Food
    430, 431, 432, 1133, 1135, 1137, 22734, -- Classic water
    34291, 43183, 43182, -- BC & WotLK water
    80166, 80167, 105232, 118358, -- Cata water
    104262, 104269, -- MoP water
    172786, -- WoD water
    225738, 192001, -- Legion water
    274914, -- BfA water
    314646, -- Shadowlands water
}, assignto = "text2", color = {0.7, 0.7, 1}, text = "DRINKING", global = true, priority = 30 }


if playerClass == "PRIEST" then
    -- Power Word: Fortitude
    A{ id = 21562, type = "HELPFUL", assignto = "raidbuff", color = { 1, 1, 1}, priority = 50, isMissing = true, isKnownCheck = function() return IsPlayerSpell(21562) end}

    --Renew
    A{ id = 139,   type = "HELPFUL", assignto = "bars", refreshTime = 15*0.3, priority = 50, color = { 0, 1, 0}, showDuration = true, isMine = true, pandemicTime = 4.5 }
    --Power Word: Shield
    A{ id = 17,    type = "HELPFUL", assignto = "bars", priority = 90, isMine = true, color = { 1, .85, 0}, showDuration = true }
    -- Weakened Soul
    A{ id = 6788,    type = "HELPFUL", assignto = "bars", priority = 70, scale = 0.5, color = { 0.8, 0, 0}, showDuration = true, isMine = true }
    --Prayer of Mending
    A{ id = 41635, type = "HELPFUL", assignto = "bar4", priority = 70, isMine = true, stackcolor =   {
                                                                            [1] = { 1, 0, 0},
                                                                            [2] = { 1, 0, 102/255},
                                                                            [3] = { 1, 0, 190/255},
                                                                            [4] = { 204/255, 0, 1},
                                                                            [5] = { 108/255, 0, 1},
                                                                            [6] = { 148/255, 0, 1},
                                                                            [7] = { 148/255, 0, 1},
                                                                            [8] = { 148/255, 0, 1},
                                                                            [9] = { 148/255, 0, 1},
                                                                            [10] = { 148/255, 0, 1},
                                                                        }, maxCount = 5, showCount = true}
                                                                        -- stackcolor =   {
                                                                        --     [1] = { .8, 0, 0},
                                                                        --     [2] = { 1, 0, 0},
                                                                        --     [3] = { 1, .2, .2},
                                                                        --     [4] = { 1, .4, .4},
                                                                        --     [5] = { 1, .6, .6},
                                                                        -- }} --Prayer of Mending
    --Atonement
    A{ id = 194384,type = "HELPFUL", assignto = "bar4", extend_below = 15, color = { 1, .3, .3}, showDuration = true, isMine = true}
    --Trinity Atonement
    A{ id = 214206,type = "HELPFUL", assignto = "bar4", extend_below = 15, color = { 1, .3, .3}, showDuration = true, isMine = true}
    --Luminous Barrier
    A{ id = 271466,type = "HELPFUL", assignto = "bars", priority = 70, color = { 1, .65, 0}, showDuration = true, isMine = true}

    -- Atonement
    -- Trace{id = 81751, type = "HEAL", minamount = 1000, assignto = "healfeedback", color = { .2, 1, .2}, fade = .5, priority = 90 }

    -- Penance
    Trace{id = 47750, type = "HEAL", assignto = "healfeedback", color = { 52/255, 172/255, 114/255 }, fade = 0.7, priority = 96 }
    -- Circle of Healing
    Trace{id = 204883, type = "HEAL", assignto = "healfeedback", color = { 1, 0.7, 0.35}, fade = 0.7, priority = 96 }
    -- Holy Word: Sanctify
    Trace{id = 34861, type = "HEAL", assignto = "healfeedback", color = { 1, 0.7, 0.35}, fade = 0.7, priority = 96 }
    -- Prayer of Healing
    Trace{id = 596, type = "HEAL", assignto = "healfeedback", color = { .5, .5, 1}, fade = 0.7, priority = 96 }
    -- Prayer of Mending
    Trace{id = 33110, type = "HEAL", assignto = "healfeedback", color = { 1, 0.3, 0.55 }, fade = 0.5, priority = 95 }
    -- Flash Heal
    Trace{id = 2061, type = "HEAL", assignto = "healfeedback", color = { 0.6, 1, 0.6}, fade = 0.7, priority = 96 }
    -- Binding Heal
    Trace{id = 32546, type = "HEAL", assignto = "healfeedback", color = { 0.7, 1, 0.7}, fade = 0.7, priority = 96 }
    -- Trail of Light
    Trace{id = 234946, type = "HEAL", assignto = "healfeedback", color = { 1, 0.7, 0.35}, fade = 0.7, priority = 96 }
    -- Shadowmend
    Trace{id = 186263, type = "HEAL", assignto = "healfeedback", color = { 0.8, 0.35, 0.7}, fade = 0.7, priority = 96 }

    -- Holy Ward (PvP)
    A{ id = 213610, type = "HELPFUL", assignto = "spell3", showDuration = true, priority = 70, color = { 1, .3, .3}, isMine = true }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(17), -- Disc: PWS
        RangeCheckBySpell(139),-- Holy: Renew
        RangeCheckBySpell(17), -- Shadow: PWS
    }

    config.DispelBitmasks = {
        DispelTypes("Magic", "Disease"),
        DispelTypes("Magic", "Disease"),
        DispelTypes("Disease")
    }

end

if playerClass == "MONK" then
    --Renewing Mist
    A{ id = 119611, type = "HELPFUL", assignto = "bar4", refreshTime = 20*0.3, extend_below = 20, isMine = true, color = {38/255, 221/255, 163/255}, showDuration = true }
    --Enveloping Mist
    A{ id = 124682, type = "HELPFUL", assignto = "bars", refreshTime = 6*0.3, isMine = true, showDuration = true, color = { 1,1,0 }, priority = 75 }
    --Soothing Mist
    A{ id = 115175, type = "HELPFUL", assignto = "bars", isMine = true, showDuration = true, color = { 0, .8, 0}, priority = 80 }
    --Statue's Soothing Mist
    -- A{ id = 198533, type = "HELPFUL", name = "Statue Mist", assignto = "spell3", isMine = true, showDuration = false, color = { 0.4, 1, 0.4}, priority = 50 }

    --Essence Font
    A{ id = 191840, type = "HELPFUL", assignto = "bars", priority = 50, color = {0.5,0.7,1}, showDuration = true, isMine = true }


    Trace{id = 116670, type = "HEAL", assignto = "healfeedback", color = {38/255, 221/255, 163/255}, fade = 0.7, priority = 96 } -- Vivify
    Trace{id = 216161, type = "HEAL", assignto = "healfeedback", color = { 1, 0.3, 0.55}, fade = 0.7, priority = 96 } -- Way of the Crane

    -- A{ id = 157627, type = "HELPFUL", assignto = "bar2", showDuration = true, color = {1, 1, 0}, priority = 95 } --Breath of the Serpent

    -- Dome of Mist
    A{ id = 205655, type = "HELPFUL", assignto = "buffIcons", showDuration = true, priority = 97 }

    --Surging Mist Buff (PvP)
    A{ id = 227344, type = "HELPFUL", assignto = "raidbuff", priority = 50, stackcolor = {
        [1] = {16/255, 110/255, 81/255},
        [2] = {38/255, 221/255, 163/255},
    }, showDuration = true, isMine = true }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(116670), -- Vivify
        RangeCheckBySpell(116670),
        RangeCheckBySpell(116670),
    }

    config.DispelBitmasks = {
        DispelTypes("Disease", "Poison"),
        DispelTypes("Magic", "Disease", "Poison"),
        DispelTypes("Disease", "Poison"),
    }
end

if playerClass == "WARLOCK" then
    A{ id = 20707, type = "HELPFUL", assignto = "raidbuff", color = { 180/255, 0, 1 }, priority = 81 } --Soulstone Resurrection
    config.DispelBitmasks = {
        DispelTypes("Magic"),
        DispelTypes(),
        DispelTypes("Magic"),
    }
end

if playerClass == "PALADIN" then

    --Glimmer of Light
    A{ id = 287280,type = "HELPFUL", assignto = "bars", color = { 1, .3, .3}, showDuration = true, isMine = true}

    A{ id = { 328282, 328620, 328622, 328281 },  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.4 , 0.4, 1} } -- Blessing of Seasons

    --Tyr's Deliverance
    A{ id = 200654, type = "HELPFUL", assignto = "spell3", color = { 1, .8, 0}, priority = 70, showDuration = true, isMine = true }
     --Bestow Faith
    A{ id = 223306,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 1 , .9, 0} }

    -- Forbearance
    A{ id = 25771, type = "HARMFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.8, 0, 0 } }

    -- Beacon of Virtue
    A{ id = 200025, type = "HELPFUL", assignto = "bar4", showDuration = true, isMine = true, color = { 0,.9,0 } }
    A{ id = 53563, type = "HELPFUL", assignto = "bar4", showDuration = true,
                                                                            isMine = true,
                                                                            color = { 0,.9,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Light

    A{ id = 156910, type = "HELPFUL", assignto = "bar4", showDuration = true,
                                                                            isMine = true,
                                                                            color = { 1,.7,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Faith

    A{ id = 465,  type = "HELPFUL", assignto = "raidbuff", isMine = true, color = { .4, .4, 1} } --Devotion Aura

    Trace{id = 225311, type = "HEAL", assignto = "healfeedback", color = { 1, 0.7, 0.2}, fade = 0.4, priority = 96 } -- Light of Dawn
    -- Flash of Light
    Trace{id = 19750, type = "HEAL", assignto = "healfeedback", color = { 0.6, 1, 0.6}, fade = 0.7, priority = 96 }
    -- Holy Light
    Trace{id = 82326, type = "HEAL", assignto = "healfeedback", color = { 1, 0.3, 0.55 }, fade = 0.7, priority = 95 }
    -- Light of the Martyr
    Trace{id = 183998, type = "HEAL", assignto = "healfeedback", color = { 1, 0.3, 0.55 }, fade = 0.7, priority = 95 }
    -- Holy Shock
    Trace{id = 25914, type = "HEAL", assignto = "healfeedback", color = { 1, 0.6, 0.3 }, fade = 0.7, priority = 95 }
    -- Word of Glory
    Trace{id = 85673, type = "HEAL", assignto = "healfeedback", color = { 1, 0.7, 0.1 }, fade = 0.7, priority = 95 }

    -- Trace{id = 82327, type = "HEAL", assignto = "spell3", color = { .8, .5, 1}, fade = 0.7, priority = 96 } -- Holy Radiance
    -- Trace{id =121129, type = "HEAL", assignto = "spell3", color = { 1, .5, 0}, fade = 0.7, priority = 96 } -- Daybreak

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(19750), -- Flash of Light
        RangeCheckBySpell(19750),
        RangeCheckBySpell(19750),
    }

    config.DispelBitmasks = {
        DispelTypes("Magic", "Disease", "Poison"),
        DispelTypes("Disease", "Poison"),
        DispelTypes("Disease", "Poison"),
    }
end
if playerClass == "SHAMAN" then
    -- config.useCombatLogFiltering = false -- Earth Shield got problems with combat log

    A{ id = 61295,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.4 , 0.4, 1} } --Riptide
    A{ id = 974,    type = "HELPFUL", assignto = "bar4", showCount = true, maxCount = 9, isMine = true, color = {0.2, 1, 0.2}, foreigncolor = {0, 0.5, 0} }
                                                                        -- stackcolor =   {
                                                                        --     [1] = { 0,.4, 0},
                                                                        --     [2] = { 0,.5, 0},
                                                                        --     [3] = { 0,.6, 0},
                                                                        --     [4] = { 0,.7, 0},
                                                                        --     [5] = { 0,.8, 0},
                                                                        --     [6] = { 0, 0.9, 0},
                                                                        --     [7] = {.1, 1, .1},
                                                                        --     [8] = {.2, 1, .2},
                                                                        --     [9] = {.4, 1, .4},
                                                                        -- },
                                                                        --, } --Earth Shield

    -- Surge of Earth
    Trace{id = 320747, type = "HEAL", assignto = "healfeedback", color = { 0.8, 0.4, 0.1}, fade = 0.7, priority = 96 }
    -- Downpour
    Trace{id = 207778, type = "HEAL", assignto = "healfeedback", color = { 0.4, 0.4, 1}, fade = 0.7, priority = 96 }

    Trace{id = 77472, type = "HEAL", assignto = "healfeedback", color = { 0.5, 1, 0.4 }, fade = 0.7, priority = 96 } -- Healing Wave
    Trace{id = 8004, type = "HEAL", assignto = "healfeedback", color = { 0.5, 1, 0.4 }, fade = 0.7, priority = 96 } -- Healing Surge

    Trace{id = 1064, type = "HEAL", assignto = "healfeedback", color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Chain Heal
    --Trace{id = 73921, type = "HEAL", assignto = "spell3", color = { 0.6, 0.6, 1}, fade = 0.4, priority = 95 } -- Healing Rain

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(8004), -- Healing Surge
        RangeCheckBySpell(188070), -- Enh Healing Surge
        RangeCheckBySpell(8004),
    }

    config.DispelBitmasks = {
        DispelTypes("Curse"),
        DispelTypes("Curse"),
        DispelTypes("Magic", "Curse"),
    }
end
if playerClass == "DRUID" then
    --A{ id = 1126,  type = "HELPFUL", assignto = "raidbuff", color = { 235/255 , 145/255, 199/255}, isMissing = true } --Mark of the Wild

    -- A{ id = 327037,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.4 , 0.4, 1} } -- Kindred Protection
    A{ id = 327071,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.4 , 0.4, 1} } -- Kindred Focus
    -- A{ id = 327022,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.4 , 0.4, 1} } -- Kindred Empowerment
    A{ id = 325748,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.4 , 0.4, 1} } -- Adaptive Swarm

    -- Tranquility
    --[[
    A{ id = 157982, type = "HELPFUL", assignto = "mitigation", priority = 60, isMine = true, stackcolor =   {
        [1] = { 1, 0, 0},
        [2] = { 1, 0, 102/255},
        [3] = { 1, 0, 190/255},
        [4] = { 204/255, 0, 1},
        [5] = { 108/255, 0, 1},
        [6] = { 148/255, 0, 1},
        [7] = { 148/255, 0, 1},
    }, showCount = 5}
    ]]

    -- Cenarion Ward
    A{ id = 102351, type = "HELPFUL", assignto = "bars", priority = 70, scale = 0.75, color = { 0, 0.7, 0.9 }, isMine = true }
    -- Rejuvenation
    A{ id = 774,   type = "HELPFUL", assignto = "bars", extend_below = 15, scale = 1.25, refreshTime = 4.5, priority = 90, pulse = true, color = { 1, 0.2, 1}, foreigncolor = { 0.4, 0, 0.4 }, showDuration = true, isMine = true }
    -- Germination
    A{ id = 155777,type = "HELPFUL", assignto = "bars", extend_below = 15, scale = 1, refreshTime = 4.5, priority = 80, pulse = true, color = { 1, 0.4, 1}, foreigncolor = { 0.4, 0.1, 0.4 }, showDuration = true, isMine = true }
    -- Lifebloom
    A{ id = 33763, type = "HELPFUL", assignto = "bar4", extend_below = 14, refreshTime = 4.5, priority = 60, showDuration = true, isMine = true, color = { 0.2, 1, 0.2}, }
    -- Regrowth
    A{ id = 8936, type = "HELPFUL", assignto = "bars", isMine = true, scale = 0.5, color = { 0, 0.8, 0.2},priority = 60, showDuration = true }
    -- Wild Growth
    A{ id = 48438, type = "HELPFUL", assignto = "bars", color = { 0, 0.9, 0.7}, priority = 60, showDuration = true, isMine = true }

    Trace{id = 8936, type = "HEAL", assignto = "healfeedback", color = { 0, 0.8, 0.2 }, fade = 0.5, priority = 96 } -- Regrowth

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(8936),
        RangeCheckBySpell(8936),
        RangeCheckBySpell(8936),
        RangeCheckBySpell(8936),
    }

    config.DispelBitmasks = {
        DispelTypes("Curse", "Poison"),
        DispelTypes("Curse", "Poison"),
        DispelTypes("Curse", "Poison"),
        DispelTypes("Magic", "Curse", "Poison"),
    }
end

if playerClass == "WARRIOR" then
    -- Battle Shout
    A{ id = 6673,  type = "HELPFUL", assignto = "raidbuff", color = { 1, .4 , .4}, priority = 50, isMissing = true, isKnownCheck = function() return IsPlayerSpell(6673) end}
end
if playerClass == "MAGE" then
    -- Focus Magic
    A{ id = 321358,  type = "HELPFUL", assignto = "bars", color = { 206/255, 4/256, 56/256 }, priority = 50, isMine = true} --Arcane Intellect

    A{ id = 1459,  type = "HELPFUL", assignto = "raidbuff", color = { .4 , .4, 1}, priority = 50, isMissing = true, isKnownCheck = function() return IsPlayerSpell(1459) end} --Arcane Intellect
    -- A{ id = 61316, type = "HELPFUL", assignto = "spell2", color = { .4 , .4, 1}, priority = 50 } --Dalaran Intellect
    -- A{ id = 54648, type = "HELPFUL", assignto = "spell2", color = { 180/255, 0, 1 }, priority = 60, isMine = true } --Focus Magic

    config.DispelBitmasks = {
        DispelTypes("Curse"),
        DispelTypes("Curse"),
        DispelTypes("Curse"),
    }
end
-- if not isHealer or playerClass == "PALADIN" then
    -- config.redirectPowerBar = "spell1"
-- end

config.autoload = {
    "HealingReduction",
    "TankCooldowns"
}


helpers.auraBlacklist = {
    -- cast blacklist is shared with auras
    [120651] = true, -- explosive orb affix cast

    -- nazjatar pvp event participation states
    [304966] = true,
    [304959] = true,
    [304851] = true,

    [312243] = true, -- Amber Casing (Eternal Blossoms assault debuff)
    [318391] = true, -- Great Worm's Foul Stench

    [26218] = true, -- Winterveil something
    [26680] = true, -- Adored (Love is in the Air)

    [287825] = true, -- Lethargy, Hit or run azerite trait

    [209261] = true, -- Uncontained Fel (DH, Last Resort cooldown)
    [264689] = true, -- Fatigued (Hunter BL)
    [219521] = true, -- Shadow Covenant (Disc Priest Talent)
    [139485] = true, -- Throne of Thudner passive debuff
    [57724] = true, -- Sated (BL)
    [80354] = true, -- Temporal Displacement (Mage BL)
    [95809] = true, -- Insanity (old Hunter BL, Ancient Hysteria)
    [57723] = true, -- Drums BL debuff, and Heroism?
    [26013] = true, -- PVP Deserter
    [71041] = true, -- Deserter
    [8326] = true, -- Ghost
    [25771] = true, -- Forbearance
    [41425] = true, -- Hypothermia (after Ice Block)
    [6788] = true, -- Weakened Soul
    [113942] = true, -- demonic gates debuff
    [123981] = true, -- dk cooldown debuff
    [87024] = true, -- mage cooldown debuffц
    [97821] = true, -- dk battleres debuff
    [124275] = true, -- brewmaster light stagger debuff
    [174528] = true, -- Griefer debuff
    [206151] = true, -- Challenger's Burden

    [256200] = true, -- Heartstopper Venom, Tol'Dagor
    [271544] = true, -- Ablative Shielding, Tank Azerite trait

    [45182] = true, -- Cheat Death cooldown
    [187464] = true, -- Shadowmend debuff

    -- PvP trash debuffs
    [110310] = true, -- Dampening
    [195901] = true, -- Adaptation

    -- Azerite Traits
    [280286] = true, -- Dagger in the Back
    [279956] = true, -- Azerite Globules



    -- Common

    -- Healing Reduction
    -- [115804] = true, -- Mortal Wound, Healing effects received reduced by 25%.
    -- [197046] = true, -- Assa Rogue PvP Talent: Minor Wound Poison, Poison, Healing effects reduced by 15%.
    -- [8680] = true, -- Assa Rogue: Wound Poison, Poison, Healing effects reduced by 30%.
    [30213] = true, -- Demonology Warlock: Legion Strike, Effectiveness of any healing reduced by 10%.

    -- Slows
    -- [1715] = true, -- Warrior Hamstring, Physical 50%
    -- [12323] = true, -- Fury Warrior, Piercing Howl, Physical 50%
    -- [116095] = true, -- WW Monk, Disable, Physical 50%
    -- [183218] = true, -- Paladin, Hand of Hindrance, Magic 70%
    -- [185763] = true, -- Outlaw Rogue, Pistol Shot, Physical 50%
    -- [206760] = true, -- Subtlety Rogue, Shadow's Grasp, Magic 30%
    -- [3409] = true, -- Crippling Poison, Poison 50%
    [248744] = true, -- Assa Rogue, Shiv, Physical 70%. 4s
    -- [205708] = true, -- Frost Mage, Chilled, Magic 65% 15s
    -- [212792] = true, -- Frost Mage, Cone of Cold, Magic 85% 5s
    -- [31589] = true, -- Arcane Mage, Slow, Magic 50%
    -- [157981] = true, -- Fire Mage, Blast Wave, Physical 70% 4s
    -- [186387] = true, -- Hunter, Bursting Shot, Physical 50s 4s
    -- [195645] = true, -- Hunter Survival: Wing Clip, Physical 50%
    -- [5116] = true, -- Hunter: Concussive Shot, Physical 50% 6s



    -- MONK
    [113746] = true, -- 8.0 Monk: Mystic Touch, Physical damage taken increased by 5%.
    [228287] = true, -- 8.0 WW Monk: Mark of the Crane, Increases the damage of the Monk's Spinning Crane Kick by 10%.
    [273299] = true, -- 8.0 Monk Azerite Trait Sunrise Technique, Taking additional damage from Melee abilities.

    -- WARRIOR
    [262115] = true, -- 8.0 Warrior Deep Wounds 6s

    -- DEMON HUNTER
    [1490] = true, -- 8.0 DH: Chaos Brand, Magic damage taken increased by 5%.
    [258860] = true, -- 8.0 DH: Dark Slash

    -- DEATH KNIGHT
    [199720] = true, -- 8.0 DK PvP Talent, Decomposing Aura, Your body is decaying, losing 3% maximum health every 5 sec.
    [214968] = true, -- 8.0 DK PvP Talent, Necrotic Aura, Taking 8% increased magical damage.
    [214975] = true, -- 8.0 DK PvP Talent, Heartstop Aura, Cooldown recovery rate decreased by 20%.
    [51714] = true, -- 8.0 Frost DK:  Razorice, Frost damage taken from the Death Knight's abilities increased by 3%.

    -- PALADIN
    [197277] = true, -- 8.0 Paladin: Judgement, Taking 25% increased damage from the Paladin's next Holy Power spender.
    [246807] = true, -- 8.0 Paladin PvP Talent: Lawbringer, Suffering up to 5% of maximum health in Holy damage when Judgment is cast.
    [204242] = true, -- 8.0 Paladin Holy, Consecration

    -- ROGUE
    [255909] = true, -- Rogue: Prey on the Weak, Damage taken increased by 10%. 6s
    [196937] = true, -- Outlaw Rogue: Ghostly Strike, Taking 10% increased damage from the Rogue's abilities.
    [137619] = true, -- Rogue: Marked for Death, Marked for Death will reset upon death.
    [91021] = true, -- Sub Rogue Talent: Find Weakness, 40% of armor is ignored by the attacking Rogue.
    [245389] = true, -- Assa Rogue Talent: Toxic Blade, 30% increased damage taken from poisons from the casting Rogue.
    [256148] = true, -- Assa Rogue Talent: Iron Wire, Damage done reduced by 15%.
    [154953] = true, -- Assa Rogue Talent: Internal Bleeding, Suffering (3.12% of Attack power) damage every 1 sec.
    [198222] = true, -- Assa Rogue PvP Talent: System Shock, Poison, Movement speed reduced by 90%. 2s
    -- [198097] = true, -- Assa Rogue PvP Talent: Creeping Venom, Poison, Suffering (2% of Attack power) Nature damage every 0.5 seconds.  Moving while afflicted by Creeping Poison causes it to refresh its duration to 4 sec.
    [197091] = true, -- Assa Rogue PvP Talent: Neurotoxin, Poison, Poisoned with a deadly neurotoxin.  Any ability used will incur an additional 3 second cooldown.
    [197051] = true, -- Assa Rogue PvP Talent: Mind-Numbing Poison, Poison, Casting spells while under the effects of Mind-numbing Poison will cause you to take Nature damage.


    -- MAGE
    [226757] = true, -- Fire Mage Talent: Conflagration, Deals (1.65% of Spell power) Fire damage every 2 sec.
    [12654] = true, -- Fire Mage: Ignite
    [2120] = true, -- Fire Mage, Flamestrike Slow, Physical 20% 8s

    -- WARLOCK
    [32390] = true, -- Aff Warlock Talent: Shadow Embrace
    [198590] = true, -- Aff Warlock: Drain Soul
    [234153] = true, -- Warlock: Drain Life
    [265931] = true, -- Destruction Warlock: Conflagrate

    -- HUNTER
    -- [131894] = true, -- Hunter: A Murder of Crows
    [259277] = true, -- Survival Hunter: Bloodseeker
    -- Wildfire Bombs
    [269747] = true, -- Wildfire Bomb
    [271049] = true, -- Volatile Wildfire
    [270339] = true, -- Scorching Shrapnel
    [270332] = true, -- Scorching Pheromones
    [132951] = true, -- Hunter Flare


}

helpers.importantTargetedCasts = {
    [324667] = true, -- Globgrog, Slime Wave
    [325552] = true, -- Cytotoxic Slash, Domina Venomblade

    [323137] = true, -- Ingra Maloch, Bewildering Pollen
    [322614] = true, -- Tred'ova, Mind Link
    [322977] = true, -- Halkias, Sinlight Visions

    [320376] = true, -- Stitchflesh, Mutilate
    [320788] = true, -- Nalthor, Frozen Binds

    [319650] = true, -- Kryxis, Vicious Headbutt
    [322554] = true, -- Executor Tarvold, Castigate
    [325254] = true, -- Beryilla, Iron Spikes

    [324608] = true, -- Oryphrion, Charged Stomp

    [320069] = true, -- Challengers, Mortal Strike
    [323515] = true, -- Gorechop, Hateful Strike
    [320644] = true, -- Xav the Unfallen, Brutal Combo
    [324079] = true, -- Mordretha, Reaping Scythe


    -- bfa spell ids borrowed from https://wago.io/BFADungeonTargetedSpells

    -- Operation Mechagon
    [298669] = true, -- Trixie Tazer - Taze
    [298718] = true, -- Trixie Tazer - Mega Taze
    [298940] = true, -- Naeno Megacrash - Bolt Buster -- avoidable

    [297254] = true, -- King Gobbamak - Charged Smash

    [302279] = true, -- Tank Buster MK1 - Wreck
    [302274] = true, -- Fulminating Zap
    [303885] = true, -- Fulminating Burst (HM)

    [291939] = true, -- King Mechagon - GigaZap
    [292267] = true, -- King Mechagon - GigaZap 2nd Phase

    [294860] = true, -- Head Machinist Sparkflux - Inconspicuous Plant - Blossom Blast

    [300777] = true, -- Slime Elemental - Slimewave
    [300650] = true, -- Toxic Lurker - Suffocating Smog
    [301990] = true, -- Heavy Scrapbot - Disassembling Protocol --
    [300188] = true, -- Weaponized Crawler - Scrap Cannon --
    [300436] = true, -- Scrapbone Shaman - Grasping Hex
    [300296] = true, -- Scrapbone Grinder - Skullcracker
    [284219] = true, -- Mechagon Renormalizer - Shrink
    -- [301689] = true, -- Charged Coil
    -- [294290] = true, -- Waste Processing Units will periodically cast  Process Waste.



    [259832] = true, -- Massive Glaive - Stormbound Conqueror (Warport Wastari, Zuldazar, for testing purpose only)
    [259744] = true,
    [259817] = true,
    [114807] = true, -- Monk Boss in Scarlet Hallds

    -- Raid
    [284405] = true, -- Sirens - Tormented Song (Stormwall Blockade)

    -- Affixes
    [288693] = true, -- Tormented Soul - Grave Bolt (Reaping affix)

    -- Atal'Dazar
    [253239] = true, -- Dazar'ai Juggernaut - Merciless Assault
    [256846] = true, -- Dinomancer Kish'o - Deadeye Aim
    [257407] = true, -- Rezan - Pursuit

    -- Freehold
    [257739] = true, -- Blacktooth Scrapper - Blind Rage
    [258338] = true, -- Captain Raoul - Blackout Barrel
    [256979] = true, -- Captain Eudora - Powder Shot

    -- Kings'Rest
    [266231] = true, -- Kula the Butcher - Severing Axe
    [270507] = true, --  Spectral Beastmaster - Poison Barrage
    [265773] = true, -- The Golden Serpent - Spit Gold
    [270506] = true, -- Spectral Beastmaster - Deadeye Shot

    -- Shrine of the Storm
    [264166] = true, -- Aqu'sirr - Undertow
    [268214] = true, -- Runecarver Sorn - Carve Flesh

    -- Siege of Boralus
    [257641] = true, -- Kul Tiran Marksman - Molten Slug
    [272874] = true, -- Ashvane Commander - Trample
    [272581] = true, -- Bilge Rat Tempest - Water Spray
    [272528] = true, -- Ashvane Sniper - Shoot
    [272542] = true, -- Ashvane Sniper - Ricochet

    -- Temple of Sethraliss
    [268703] = true, -- Charged Dust Devil - Lightning Bolt
    [272670] = true, -- Sandswept Marksman - Shoot
    [267278] = true, -- Static-charged Dervish - Electrocute
    [272820] = true, -- Spark Channeler - Shock
    [274642] = true, -- Hoodoo Hexer - Lava Burst
    [268061] = true, -- Plague Doctor - Chain Lightning

    -- The Motherlode!!
    [268185] = true, -- Refreshment Vendor, Iced Spritzer
    [258674] = true, -- Off-Duty Laborer - Throw Wrench
    [276304] = true, -- Rowdy Reveler - Penny For Your Thoughts
    [263628] = true, -- Mechanized Peacekeeper - Charged Claw
    [263209] = true, -- Mine Rat - Throw Rock
    [263202] = true, -- Venture Co. Earthshaper - Rock Lance
    [262794] = true, -- Venture Co. Mastermind - Energy Lash
    [260669] = true, -- Rixxa Fluxflame - Propellant Blast

    -- The Underrot
    [265376] = true, -- Fanatical Headhunter - Barbed Spear
    [265084] = true, -- Devout Blood Priest - Blood Bolt
    [265625] = true, -- Befouled Spirit - Dark Omen

    -- Tol Dagor
    [256039] = true, -- Overseer Korgus - Deadeye
    [185857] = true, -- Ashvane Spotter - Shoot

    -- Waycrest Manor
    [263891] = true, -- Heartsbane Vinetwister - Grasping Thorns
    [264510] = true, -- Crazed Marksman - Shoot
    [260699] = true, -- Coven Diviner - Soul Bolt
    [260551] = true, -- Soulbound Goliath - Soul Thorns
    [260741] = true, -- Heartsbane Triad - Jagged Nettles
    [268202] = true, -- Gorak Tul - Death Lens
}

--[[
-- Now Using LiBAuraTypes instead
helpers.customBossAuras = {
    [47476] = true, -- Strangulate
    [207167] = true, -- Blinding Sleet
    -- [207171] = true, -- Winter is Coming
    [108194] = true, -- Asphyxiate
        [221562] = true, -- Asphyxiate (Blood)

    [204490] = true, -- Sigil of Silence
    [205630] = true, -- Illidan's Grasp
    [207685] = true, -- Sigil of Misery
    [211881] = true, -- Fel Eruption
    [221527] = true, -- Imprison (Detainment Honor Talent)
        [217832] = true, -- Imprison (Baseline Undispellable)

    [5211] = true, -- Mighty Bash
    [81261] = true, -- Solar Beam
    [163505] = true, -- Rake
    [209749] = true, -- Faerie Swarm (Slow/Disarm)
    [209753] = true, -- Cyclone
        [33786] = true, -- Cyclone
    [22570] = true, -- Maim
        [203123] = true, -- Maim
        [236025] = true, -- Enraged Maim (Feral Honor Talent)


    [3355] = true, -- Freezing Trap
    [19386] = true, -- Wyvern Sting
    [19577] = true, -- Intimidation
    [117526] = true, -- Binding Shot Stun
    [238559] = true, -- Bursting Shot
    [202914] = true, -- Spider Sting (Armed)
        [202933] = true, -- Spider Sting (Silenced)
        [233022] = true, -- Spider Sting (Silenced)
    [209790] = true, -- Freezing Arrow
    [213691] = true, -- Scatter Shot


    [118] = true, -- Polymorph
    [28271] = true, -- Polymorph Turtle
    [28272] = true, -- Polymorph Pig
    [61025] = true, -- Polymorph Serpent
    [61305] = true, -- Polymorph Black Cat
    [61721] = true, -- Polymorph Rabbit
    [61780] = true, -- Polymorph Turkey
    [126819] = true, -- Polymorph Porcupine
    [161353] = true, -- Polymorph Polar Bear Cub
    [161354] = true, -- Polymorph Monkey
    [161355] = true, -- Polymorph Penguin
    [161372] = true, -- Polymorph Peacock
    [122] = true, -- Frost Nova
        [33395] = true, -- Freeze
    [157997] = true, -- Ice Nova
    [228600] = true, -- Glacial Spike Root
    [31661] = true, -- Dragon's Breath
    [82691] = true, -- Ring of Frost


    [115078] = true, -- Paralysis
    [116706] = true, -- Disable
    [119381] = true, -- Leg Sweep
    [122470] = true, -- Touch of Karma
    [198909] = true, -- Song of Chi-Ji
    [202274] = true, -- Incendiary Brew
    [233759] = true, -- Grapple Weapon

    [853] = true, -- Hammer of Justice
    [20066] = true, -- Repentance
    [31935] = true, -- Avenger's Shield
    [115750] = true, -- Blinding Light
        [105421] = true, -- Blinding Light

    [605] = true, -- Mind Control
    [8122] = true, -- Psychic Scream
    [9484] = true, -- Shackle Undead
    [15487] = true, -- Silence
        [199683] = true, -- Last Word
    [87204] = true, -- Sin and Punishment
    [200196] = true, -- Holy Word: Chastise
        [200200] = true, -- Holy Word: Chastise (Stun)
    [205369] = true, -- Mind Bomb
        [226943] = true, -- Mind Bomb (Stun)


    [408] = true, -- Kidney Shot
    [1330] = true, -- Garrote - Silence
    [1776] = true, -- Gouge
    [1833] = true, -- Cheap Shot
    [2094] = true, -- Blind
    [6770] = true, -- Sap
    [199804] = true, -- Between the Eyes
    [212183] = true, -- Smoke Bomb


    [51514] = true, -- Hex
        [196932] = true, -- Voodoo Totem
        [210873] = true, -- Hex (Compy)
        [211004] = true, -- Hex (Spider)
        [211010] = true, -- Hex (Snake)
        [211015] = true, -- Hex (Cockroach)
    [77505] = true, -- Earthquake (Stun)
    [118345] = true, -- Pulverize
    [118905] = true, -- Static Charge
    [197214] = true, -- Sundering


    [710] = true, -- Banish
    [5484] = true, -- Howl of Terror
    [6358] = true, -- Seduction
    [6789] = true, -- Mortal Coil
    [30283] = true, -- Shadowfury
    [89766] = true, -- Axe Toss
    [118699] = true, -- Fear

    [196364] = true, -- Unstable Affliction (Silence)
    [233490] = true, -- Unstable Affliction applications
    [233496] = true, -- Unstable Affliction applications
    [233497] = true, -- Unstable Affliction applications
    [233498] = true, -- Unstable Affliction applications
    [233499] = true, -- Unstable Affliction applications

    [5246] = true, -- Intimidating Shout
    [132169] = true, -- Storm Bolt
    [46968] = true, -- Shockwave
    [236077] = true, -- Disarm
        [236236] = true, -- Disarm
}
]]
