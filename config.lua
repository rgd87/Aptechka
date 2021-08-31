local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local AG = helpers.AddAuraGlobal
local DispelTypes = helpers.DispelTypes
local D = helpers.AddDebuff
local Trace = helpers.AddTrace
local pixelperfect= helpers.pixelperfect
local config = AptechkaDefaultConfig
local set = helpers.set

config.frameStrata = "MEDIUM"
config.maxgroups = 8
--A maximum of 5 pets can be displayed.

config.defaultFont = "AlegreyaSans-Medium"
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
config.RangeStatus = { name = "OutOfRange", assignto = set("frameAlpha"), color = {0,0,0,0.65}, priority = 90 }
config.TargetStatus = { name = "Target", assignto = set("border"), color = {0.7,0.2,0.5}, priority = 65 }
config.MouseoverStatus = { name = "Mouseover", assignto = set("border", "mouseoverHighlight"), color = {1,0.5,0.8}, priority = 66 }
config.AggroStatus = { name = "Aggro", assignto = set("raidbuff"),  color = { 0.7, 0, 0},priority = 85 }
config.RCReady = { name = "RCReady", priority = 90, assignto = set("statusIcon"), color = { 0, 1, 0}, text = "READY" }
config.RCNotReady = { name = "RCNotReady", priority = 91, assignto = set("statusIcon"), color = { 1, 0, 0}, text = "NOT READY" }
config.RCWaiting = { name = "RCWaiting", priority = 89, assignto = set("statusIcon"), color = { 0.8, 0.6, 0}, text = "WAITING" }
config.IncResStatus = { name = "IncRes", priority = 86, assignto = set("statusIcon"), color = { 1, 1, 1} }
config.PhasedStatus = { name = "Phased", priority = 84, assignto = set("statusIcon"), color = { 0.3, 0.3, 0.45, 0.77} }
config.RoleStatus = { name = "RoleIcon", assignto = set("roleIcon"), priority = 65, color = { 1, 1, 1 } }
config.RaidTargetStatus = { name = "RaidTarget", assignto = set("raidTargetIcon"), priority = 70, color = { 1, 1, 1 } }
config.IncomingCastStatus = { name = "IncomingCast", priority = 97, assignto = set("incomingCastIcon"), color = { 1, 1, 1} }
config.OutgoingCastStatus = { name = "OutgoingCast", priority = 96, assignto = set("incomingCastIcon"), color = { 1, 1, 1} }
config.LeaderStatus = { name = "Leader", priority = 59, assignto = set("text3"), color = {1,.8,.2}, text = "L" }
-- config.AssistStatus = { name = "Assist", priority = 59, assignto = set("text3"), color = {1,.8,.2}, text = "A" }
config.VoiceChatStatus = { name = "VoiceChat", assignto = set("text3"), color = {0.3, 1, 0.3}, text = "S", priority = 99 }
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = set("border"), color = {0.6,0.6,0.6} }
config.LowHealthStatus = { name = "LowHealth", priority = 60, assignto = set("border"), color = {1,0,0} }
config.DeadStatus = { name = "Dead", assignto = set("text2","healthColor"), color = {.05,.05,.05}, textcolor = {0,1,0}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "Ghost", assignto = set("text2","healthColor"), color = {.05,.05,.05},  textcolor = {0,1,0}, text = "GHOST", priority = 62}
config.OfflineStatus = { name = "Offline", assignto = set("text2","text3","healthColor"), color = {0.5,0.5,0.5}, textcolor = {0,1,0}, text = "OFFLINE",  priority = 70}
config.AwayStatus = { name = "AFK", assignto = set("text2","text3"), color = {0.4,0.4,0.4}, textcolor = {1,0.8,0}, text = "AFK",  priority = 15}
config.IncomingHealStatus = { name = "IncHealText", assignto = set("text2"), color = { 0, 1, 0}, priority = 15 }
-- config.AbsorbTextStatus = { name = "AbsorbText", assignto = set("text2"), color = { 0.7, 0.7, 1 }, priority = 11, formatType = "PERCENTAGE" }
config.HealthTextStatus = { name = "HealthText", assignto = set("text2"), color = { 54/255, 201/255, 99/256 }, priority = 10, formatType = "MISSING_VALUE_SHORT" }
config.UnitNameStatus = { name = "UnitName", assignto = set("text1"), classcolor = true, priority = 20 }
config.HealthBarColor = { name = "HealthBar", assignto = set("health"), color = {1, .3, .3}, classcolor = true, priority = 10 }
config.PowerBarColor = { name = "PowerBar", assignto = set("power"), color = {.5,.5,1}, priority = 20 }
config.InVehicleStatus = { name = "InVehicle", assignto = set("vehicle"), color = {0.3,1,0.3}, priority = 21 }
config.LOSStatus = { name = "OutOfSight", assignto = set("healfeedback"), scale = 1.6, color = {1,0.1,0.1}, priority = 95, fade = 0.3 }
config.DispelStatus = { name = "Dispel", assignto = set("debuffHighlight"), scale = 1, pulse = 2, spin = true, priority = 86 }
config.StaggerStatus = { name = "Stagger", assignto = set("text2"), priority = 20 }
config.RunicPowerStatus = { name = "RunicPower", assignto = set("mitigation"), priority = 10, color = { 0, 0.82, 1 }, icon = 237517, formatType = "VALUE" }
config.AltPowerStatus = { name = "AltPower", assignto = set("text3"), priority = 65, color = { 1, 0.7, 1 }, formatType = "PERCENTAGE" }

config.SummonPending = { name = "SummonPending", assignto = set("text2"), color = {1,0.7,0}, text = "PENDING", priority = 50 }
config.SummonAccepted = { name = "SummonAccepted", assignto = set("text2"), color = {0,1,0}, text = "ACCEPTED", priority = 51 }
config.SummonDeclined = { name = "SummonDeclined", assignto = set("text2"), color = {1,0,0}, text = "DECLINED", priority = 52 }
config.DebuffAlert1 = { name = "DebuffAlert1", assignto = set("debuffHighlight", "flash"), color = {1,0,0}, priority = 95, scale = 1.15, pulse = 10, }
config.DebuffAlert2 = { name = "DebuffAlert2", assignto = set("debuffHighlight", "flash"), color = {1,0,1}, priority = 95, scale = 1.15, pulse = 10, }
config.DebuffAlert3 = { name = "DebuffAlert3", assignto = set("innerglow", "border", "flash"), color = {1,0,0}, priority = 90 }
config.DebuffAlert4 = { name = "DebuffAlert4", assignto = set("pixelGlow"), color = {1,1,1}, priority = 95 }
config.DebuffAlert5 = { name = "DebuffAlert5", assignto = set("frameAlpha"), color = {0,0,0, 0.8}, priority = 50 }

config.TargetedCountStatus = { name = "TargetedCount", assignto = set("EnemyCounter"), color = {1,0.2,0.2}, priority = 70 }
-- config.MindControl = { name = "MIND_CONTROL", assignto = set("mindcontrol"), color = {1,0,0}, priority = 52 }
config.MindControlStatus = { name = "MIND_CONTROL", assignto = set("border", "mindcontrol", "innerglow"), color = {0.5,0,1}, priority = 52 }
-- config.UnhealableStatus = { name = "UNHEALABLE", assignto = set("unhealable"), color = {0.5,0,1}, priority = 50 }

local DEFAULT_TEXLEVEL = 13
config.DefaultWidgets = {
    raidbuff = { type = "IndicatorArray", width = 5, height = 5, point = "TOPLEFT", x = 0, y = 0, growth = "DOWN", max = 5 },
    mitigation = { type = "Bar", width=22, height=4, point="BOTTOMLEFT", x=4, y=-5, vertical = false},
    -- icon = { type = "Icon", width = 24, height = 24, point = "CENTER", x = 0, y = 0, alpha = 1, font = config.defaultFont, textsize = 12, outline = true, edge = true },
    icon = { type = "BarIcon", width = 24, height = 24, point = "CENTER", x = 0, y = 0, alpha = 1, font = config.defaultFont, textsize = 12, outline = true, edge = true, vertical = true },
    spell1 = { type = "Indicator", width = 9, height = 8, point = "BOTTOMRIGHT", x = 0, y = 0, },
    -- spell2 = { type = "Indicator", width = 9, height = 8, point = "TOP", x = 0, y = 0, },
    spell3 = { type = "Indicator", width = 9, height = 8, point = "TOPRIGHT", x = 0, y = 0, },
    bar4 = { type = "Bar", width=21, height=5, point="TOPRIGHT", x=0, y=2, vertical = false},
    bar4text = { type = "StaticText", point="TOPRIGHT", width = 30, height = 10, x=-23, y=5, font = config.defaultFont, textsize = 12, effect = "NONE", bg = false, bgAlpha = 0.5, padding = 0, justify = "RIGHT" },
    buffIcons = { type = "BarIconArray", width = 12, height = 18, point = "TOPRIGHT", x = 5, y = -6, alpha = 1, growth = "LEFT", max = 3, edge = true, outline = true, vertical = true, font = config.defaultFont, textsize = 12 },
    bars = { type = "BarArray", width = 21, height = 5, point = "BOTTOMRIGHT", x = 0, y = 0, vertical = false, growth = "UP", max = 7 },
    vbar1 = { type = "Bar", width=4, height=20, point="TOPRIGHT", x=-9, y=2, vertical = true},
    text1 = { type = "StaticText", point="CENTER", width = 60, height = 16, x=0, y=0, font = config.defaultFont, textsize = 12, effect = "SHADOW", bg = false, bgAlpha = 0.5, padding = 0, justify = "CENTER" },
    text2 = { type = "StaticText", point="CENTER", width = 60, height = 10, x=0, y=-11, font = config.defaultFont, textsize = 10, effect = "NONE", bg = false, bgAlpha = 0.5, padding = 0, justify = "CENTER" },
    text3 = { type = "Text", point="TOPLEFT", width = 30, height = 10, x=2, y=0, font = config.defaultFont, textsize = 9, effect = "NONE", bg = false, bgAlpha = 0.5, padding = 0, justify = "LEFT" },
    incomingCastIcon = { type = "ProgressIcon", width = 18, height = 18, point = "TOPLEFT", x = -3, y = 3, alpha = 1, font = config.defaultFont, textsize = 12, outline = false, edge = false },
    debuffIcons = { type = "DebuffIconArray", width = 13, height = 13, point = "BOTTOMLEFT", x = 0, y = 0, style = "STRIP_RIGHT", animdir = "LEFT", alpha = 1, growth = "UP", max = 4, edge = true, outline = true, font = config.defaultFont, textsize = 12, bigscale = 1.3 },
    floatingIcon = { type = "FloatingIcon", width = 16, height = 16, point = "TOPLEFT", x = 15, y = -5, alpha = 1, font = config.defaultFont, textsize = 12, outline = false, edge = false, angle = 60, range = 45, spreadArc = 30, animDuration = 2 },
    statusIcon = { type = "Texture", width = 20, height = 20, point = "CENTER", x = 0, y = 14, texture = nil, rotation = 0, zorder = 6-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = false },
    roleIcon = { type = "Texture", width = 13, height = 13, point = "BOTTOMLEFT", x = -8, y = -8, texture = nil, rotation = 0, zorder = 6-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = false },
    raidTargetIcon = { type = "Texture", width = 20, height = 20, point = "TOPLEFT", x = -10, y = 10, texture = nil, rotation = 0, zorder = 16-DEFAULT_TEXLEVEL, alpha = 0.3, blendmode = "BLEND", disableOverrides = false },
    healfeedback = { type = "Texture", width = 16, height = 30, point = "TOPRIGHT", x = 0, y = 0, texture = "Interface\\AddOns\\Aptechka\\corner", rotation = 270, zorder = 7-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = true },
    debuffHighlight = { type = "Texture", width = 12, height = 15, point = "TOPLEFT", x = 0, y = 0, texture = "Interface\\AddOns\\Aptechka\\corner", rotation = 180, zorder = 13-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = true },
    CCList = { type = "TextArray", point="BOTTOMLEFT", width = 60, height = 12, x=0, y=-15, font = config.defaultFont, textsize = 10, effect = "NONE", bg = true, bgAlpha = 0.7, padding = 1.5, growth = "DOWN", max = 4, justify = "LEFT" },
    EnemyCounter = { type = "Text", point="TOPLEFT", width = 20, height = 15, x=19, y=6, font = config.defaultFont, textsize = 13, effect = "OUTLINE", bg = false, bgAlpha = 0.5, padding = 0, justify = "CENTER" },
}

-- default priority is 80

local RangeCheckBySpell = helpers.RangeCheckBySpell

helpers.BuffGainTypes = {
    AURA = { events = set("SPELL_AURA_APPLIED", "SPELL_AURA_REFRESH"), target = "DST", scale = 1 },
    CAST = { events = set("SPELL_CAST_SUCCESS"), target = "SRC", scale = 1 },
    HEAL = { events = set("SPELL_HEAL"), target = "DST", scale = 1 },
}

config.templates = {
    TankCD = { assignto = set("icon"), infoType = "DURATION", priority = 94, color = { 1, 0.2, 1}, refreshTime = 2 },
    SurvivalCD = { assignto = set("buffIcons"), infoType = "DURATION", priority = 90, color = { 0.4, 1, 0.4} },
    AreaDR = { assignto = set("buffIcons"), infoType = "DURATION", priority = 89, color = { 0.4, 1, 0.4} },
    ActiveMitigation = { assignto = set("mitigation"), infoType = "DURATION", color = {0.7, 0.7, 0.7}, priority = 80 },
    HealTrace = { assignto = set("healfeedback"), color = { 1, 0.7, 0.35}, fade = 0.7, priority = 96 },
}

local isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
if not isMainline then return end

-- DUNGEON MECHANICS
AG{ id = 324092, template = "AreaDR" } -- Sanguine Depths, Shining Radiance (Naaru thing)

-- ESSENCES
AG{ id = 296094, template = "TankCD" } --Standstill (Artifice of Time)
AG{ id = 296230, template = "SurvivalCD" } --Vitality Conduit

-- ACTIVE MITIGATION
AG{ id = 132404, template = "ActiveMitigation" } -- Shield Block
AG{ id = 132403, template = "ActiveMitigation" } -- Shield of the Righteousness
AG{ id = 203819, template = "ActiveMitigation" } -- Demon Spikes
AG{ id = 192081, template = "ActiveMitigation" } -- Ironfur

-- COVENANT
AG{ id = 330749, template = "SurvivalCD" } -- Phial of Serenity (Patience, overtime soulbind trait from pelagos)

-- MONK
AG{ id = 122783, template = "SurvivalCD" } -- Diffuse Magic
AG{ id = 122278, template = "SurvivalCD" } -- Dampen Harm
AG{ id = 132578, template = "SurvivalCD" } -- Invoke Niuzao
AG{ id = 243435, template = "SurvivalCD", priority = 91 } -- Fortifying Brew (Mistweaver/Windwalker)
AG{ id = 125174, template = "SurvivalCD", priority = 91 } -- Touch of Karma
AG{ id = 115176, template = "TankCD" } -- Zen Meditation
AG{ id = 116849, template = "SurvivalCD", priority = 88 } --Life Cocoon
AG{ id = 120954, template = "TankCD" } --Fortifying Brew (Brewmaster)
-- Spell( 209584 ,{ name = "Zen Focus Tea", color = colors.LBLUE, shine = true, group = "buffs", duration = 5 })

-- WARRIOR
AG{ id = 184364, template = "SurvivalCD" } -- Enraged Regeneration
AG{ id = 118038, template = "SurvivalCD" } -- Die by the Sword
AG{ id = 12975,  template = "SurvivalCD" } --Last Stand
AG{ id = 871,    template = "TankCD" } --Shield Wall 40%
AG{ id = 107574, template = "SurvivalCD", priority = 85 } --Avatar
AG{ id = 23920, template = "SurvivalCD", priority = 85 } --Spell Reflect

-- DEMON HUNTER
AG{ id = 212800, template = "SurvivalCD" } -- Blur
AG{ id = 187827, template = "SurvivalCD" } -- Vengeance Meta
AG{ id = 209426, template = "AreaDR" } -- Darkness

-- ROGUE
AG{ id = 185311, template = "SurvivalCD" } -- Crimson Vial
-- AG{ id = 1784,   template = "SurvivalCD" } -- Stealh
AG{ id = 11327,  template = "SurvivalCD" } -- Vanish
AG{ id = 5277,   template = "SurvivalCD" } -- Evasion
AG{ id = 1966,   template = "SurvivalCD" } -- Feint
AG{ id = 31224,  template = "SurvivalCD", priority = 91 } -- Cloak of Shadows
AG{ id = 45182,  template = "TankCD" } -- Cheating Death

-- WARLOCK
AG{ id = 104773, template = "SurvivalCD" } -- Unending Resolve
AG{ id = 132413, template = "SurvivalCD" } -- Shadow Bulwark

-- DRUID
-- local druidColor = { RAID_CLASS_COLORS.DRUID:GetRGB() }
AG{ id = 22812,  template = "SurvivalCD" } -- Barkskin
AG{ id = 102342, template = "TankCD", priority = 93 } --Ironbark
AG{ id = 61336,  template = "TankCD" } --Survival Instincts 50% (Feral & Guardian)
AG{ id = 236696,  template = "SurvivalCD" } -- Thorns

-- PRIEST
AG{ id = 19236,  template = "SurvivalCD" } -- Desperate Prayer
AG{ id = 15286,  template = "SurvivalCD" } -- Vampiric Embrace
AG{ id = 586,  template = "SurvivalCD" } -- Fade
AG{ id = 47585,  template = "SurvivalCD" } -- Dispersion
AG{ id = 47788, template = "TankCD", priority = 90 } --Guardian Spirit
AG{ id = 33206, template = "TankCD", priority = 93 } --Pain Suppression
AG{ id = 81782, template = "AreaDR" } -- Power Word: Barrier
-----
AG{ id = 213610, template = "SurvivalCD" } -- Holy Ward (PVP)
AG{ id = 289655, template = "SurvivalCD" } -- Holy Word: Concentration
AG{ id = 213602, template = "TankCD" } -- Greater Fade
AG{ id = 329543, template = "TankCD" } -- Divine Ascension

-- PALADIN
AG{ id = 642,    template = "TankCD", priority = 95 } -- Divine Shield
AG{ id = 1022,   template = "SurvivalCD" } -- Blessing of Protection
AG{ id = 204018, template = "SurvivalCD" } -- Blessing of Spellwarding
AG{ id = 1044,   template = "SurvivalCD" } -- Blessing of Freedom
AG{ id = 184662, template = "SurvivalCD" } -- Shield of Vengeance
AG{ id = 205191, template = "SurvivalCD" } -- Eye for an Eye
AG{ id = 498,    template = "SurvivalCD" } -- Divine Protection
AG{ id = 6940,   template = "SurvivalCD" } -- Blessing of Sacrifice
AG{ id = 31850,  template = "SurvivalCD", priority = 88 } --Ardent Defender
AG{ id = 86659,  template = "TankCD" } --Guardian of Ancient Kings 50%
-- AG{ id = 204150, template = "TankCD", priority = 85 } -- Aegis of Light
-- Guardian of the Forgotten Queen - Divine Shield (PvP)
AG{ id = 228050, template = "TankCD", priority = 97 }

-- DEATH KNIGHT
AG{ id = 194679, template = "SurvivalCD" } -- Rune Tap
AG{ id = 55233,  template = "TankCD", priority = 94 } --Vampiric Blood
AG{ id = 48792,  template = "TankCD", priority = 94 } --Icebound Fortitude 50%
AG{ id = 81256,  template = "SurvivalCD" } -- Dancing Rune Weapon
AG{ id = 145629, template = "AreaDR" } -- Anti-Magic Zone
AG{ id = 48707, template = "SurvivalCD" } -- Anti-Magic Shell

-- MAGE
-- AG{ id = 190319, template = "SurvivalCD" } -- Combustion
AG{ id = 113862, template = "SurvivalCD" } -- Arcane Greater Invisibility
AG{ id = 45438,  template = "TankCD" } -- Ice Block
AG{ id = { 110909, 342246 },  template = "SurvivalCD" } -- Alter Time

-- HUNTER
AG{ id = 186265, template = "SurvivalCD" } -- Aspect of the Turtle
AG{ id = 264735, template = "SurvivalCD" } -- Survival of the Fittest
-- AG{ id = 53480, template = "SurvivalCD" } -- Roar of Sacrifice (PVP)

-- SHAMAN
AG{ id = 108271, template = "SurvivalCD" } -- Astral Shift
AG{ id = 325174, template = "AreaDR" } -- Spirit Link Totem
AG{ id = 204293, template = "SurvivalCD" } -- Spirit Link (PvP)
-- AG{ id = 207498, template = "AreaDR", priority = 60 } -- Ancestral Protection Totem
-- AG{ id = 210918, template = "SurvivalCD" } -- Ethereal Form


-- Stealth, Prowl, Camo, Shadowmeld
AG{ id = {1784, 5215, 199483, 58984}, assignto = set("text2"), color = {0.2, 1, 0.3}, text = "STEALTH", priority = 20 }
-- Feign Death
AG{ id = 5384, assignto = set("text2"), color = {0, 0.7, 1}, text = "FD", global = true, priority = 75 }

AG{ id = {
    430, 431, 432, 1133, 1135, 1137, 22734, 24355, 29007, 26473, 26261, -- Classic water
    34291, 43183, 43182, -- BC & WotLK water
    80166, 80167, 105232, 118358, -- Cata water
    104262, 104269, -- MoP water
    172786, -- WoD water
    225738, 192001, -- Legion water
    274914, -- BfA water
    314646, -- Shadowlands water
    167152, -- Mage Food
    170906, 192002, 195472, 225743, 251232, 257427, 257428, 272819, 279739, 297098, -- Food & Drink
    308429, 308433, 327786, 340109, 348436,-- Shadowlands Food & Drink
}, assignto = set("text2"), color = {0.7, 0.7, 1}, text = "DRINKING", priority = 30 }


if playerClass == "PRIEST" then
    -- Power Word: Fortitude
    A{ id = 21562, type = "HELPFUL", assignto = set("raidbuff"), color = { 1, 1, 1}, priority = 50, isMissing = true, isKnownCheck = function() return IsPlayerSpell(21562) end}

    --Renew
    A{ id = 139,   type = "HELPFUL", assignto = set("bars"), refreshTime = 15*0.3, priority = 50, color = { 0, 1, 0}, infoType = "DURATION", isMine = true, pandemicTime = 4.5 }
    --Power Word: Shield
    A{ id = 17,    type = "HELPFUL", assignto = set("bars"), priority = 90, isMine = true, color = { 1, .85, 0}, infoType = "DURATION" }
    -- Weakened Soul
    A{ id = 6788,    type = "HELPFUL", assignto = set("bars"), priority = 70, scale = 0.5, color = { 0.8, 0, 0}, infoType = "DURATION", isMine = true }
    --Prayer of Mending
    A{ id = 41635, type = "HELPFUL", assignto = set("bar4"), priority = 70, isMine = true, color = { 1, 0, 102/255 }, maxCount = 5, infoType = "COUNT" }

    --Atonement, Trinity Atonement
    A{ id = { 194384, 214206 },type = "HELPFUL", assignto = set("bar4"), extend_below = 15, color = { 1, .3, .3}, infoType = "DURATION", isMine = true}
    --Luminous Barrier
    A{ id = 271466,type = "HELPFUL", assignto = set("bars"), priority = 70, color = { 1, .65, 0}, infoType = "DURATION", isMine = true}

    -- Penance
    Trace{id = 47750, template = "HealTrace", color = { 52/255, 172/255, 114/255 } }
    -- Circle of Healing
    Trace{id = 204883, template = "HealTrace", color = { 1, 0.7, 0.35} }
    -- Holy Word: Sanctify
    Trace{id = 34861, template = "HealTrace", color = { 1, 0.7, 0.35} }
    -- Prayer of Healing
    Trace{id = 596, template = "HealTrace", color = { .5, .5, 1} }
    -- Prayer of Mending
    Trace{id = 33110, template = "HealTrace", color = { 1, 0.3, 0.55 }, fade = 0.5, priority = 95 }
    -- Flash Heal
    Trace{id = 2061, template = "HealTrace", color = { 0.6, 1, 0.6} }
    -- Binding Heal
    Trace{id = 32546, template = "HealTrace", color = { 0.7, 1, 0.7} }
    -- Trail of Light
    Trace{id = 234946, template = "HealTrace", color = { 1, 0.7, 0.35} }
    -- Shadowmend
    Trace{id = 186263, template = "HealTrace", color = { 0.8, 0.35, 0.7} }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(17), -- Disc: PWS
        RangeCheckBySpell(17), -- Holy: PWS
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
    A{ id = 119611, type = "HELPFUL", assignto = set("bar4"), refreshTime = 20*0.3, extend_below = 20, isMine = true, color = {38/255, 221/255, 163/255}, infoType = "DURATION" }
    --Enveloping Mist
    A{ id = 124682, type = "HELPFUL", assignto = set("bars"), refreshTime = 6*0.3, isMine = true, infoType = "DURATION", color = { 1,1,0 }, priority = 75 }
    --Soothing Mist
    A{ id = 115175, type = "HELPFUL", assignto = set("bars"), isMine = true, infoType = "DURATION", color = { 0, .8, 0}, priority = 80 }
    --Bonedust Brew
    A{ id = 325216, type = "HELPFUL", assignto = set("bars"), isMine = true, infoType = "DURATION", color = { 0.3, 0.35, 0.5}, scale = 0.5, priority = 80 }
    --Statue's Soothing Mist
    -- A{ id = 198533, type = "HELPFUL", name = "Statue Mist", assignto = set("spell3"), isMine = true, color = { 0.4, 1, 0.4}, priority = 50 }

    --Essence Font
    A{ id = { 191840, 344006 }, type = "HELPFUL", assignto = set("bars"), priority = 50, color = {0.5,0.7,1}, infoType = "DURATION", isMine = true }


    Trace{id = 116670, template = "HealTrace", color = {38/255, 221/255, 163/255} } -- Vivify
    Trace{id = 343819, template = "HealTrace", color = { 1, 0.3, 0.55} } -- Gust of Mists

    -- A{ id = 157627, type = "HELPFUL", assignto = set("bar2"), infoType = "DURATION", color = {1, 1, 0}, priority = 95 } --Breath of the Serpent

    -- Dome of Mist
    A{ id = 205655, type = "HELPFUL", assignto = set("buffIcons"), infoType = "DURATION", priority = 97 }

    --Surging Mist Buff (PvP)
    A{ id = 227344, type = "HELPFUL", assignto = set("raidbuff"), priority = 50, stackcolor = {
        [1] = {16/255, 110/255, 81/255},
        [2] = {38/255, 221/255, 163/255},
    }, infoType = "DURATION", isMine = true }

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
    A{ id = 20707, type = "HELPFUL", assignto = set("raidbuff"), color = { 180/255, 0, 1 }, priority = 81 } --Soulstone Resurrection
    config.DispelBitmasks = {
        DispelTypes("Magic"),
        DispelTypes(),
        DispelTypes("Magic"),
    }
end

if playerClass == "PALADIN" then

    --Glimmer of Light
    A{ id = 287280,type = "HELPFUL", assignto = set("bars"), color = { 1, .3, .3}, infoType = "DURATION", isMine = true}

    A{ id = { 328282, 328620, 328622, 328281 },  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 0.4 , 0.4, 1} } -- Blessing of Seasons

    --Tyr's Deliverance
    A{ id = 200654, type = "HELPFUL", assignto = set("spell3"), color = { 1, .8, 0}, priority = 70, infoType = "DURATION", isMine = true }
     --Bestow Faith
    A{ id = 223306,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 1 , .9, 0} }

    -- Forbearance
    A{ id = 25771, type = "HARMFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 0.8, 0, 0 } }

    -- Beacon of Virtue
    A{ id = 200025, type = "HELPFUL", assignto = set("bar4"), infoType = "DURATION", isMine = true, color = { 0,.9,0 } }
    A{ id = 53563, type = "HELPFUL", assignto = set("bar4"), infoType = "DURATION",
                                                                            isMine = true,
                                                                            color = { 0,.9,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Light

    A{ id = 156910, type = "HELPFUL", assignto = set("bar4"), infoType = "DURATION",
                                                                            isMine = true,
                                                                            color = { 1,.7,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Faith

    A{ id = 465,  type = "HELPFUL", assignto = set("raidbuff"), priority = 40, isMine = true, color = { .4, .4, 1} } --Devotion Aura

    Trace{id = 225311, template = "HealTrace", color = { 1, 0.7, 0.2} } -- Light of Dawn
    -- Flash of Light
    Trace{id = 19750, template = "HealTrace", color = { 0.6, 1, 0.6} }
    -- Holy Light
    Trace{id = 82326, template = "HealTrace", color = { 1, 0.3, 0.55 } }
    -- Light of the Martyr
    Trace{id = 183998, template = "HealTrace", color = { 1, 0.3, 0.55 } }
    -- Holy Shock
    Trace{id = 25914, template = "HealTrace", color = { 1, 0.6, 0.3 } }
    -- Word of Glory
    Trace{id = 85673, template = "HealTrace", color = { 1, 0.7, 0.1 } }

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

    A{ id = 61295,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", scale = 1.3, refreshTime = 5.4, refreshColor = { 1, 0.1, 0.1}, isMine = true, color = { 0.4 , 0.4, 1} } --Riptide
    A{ id = 974,    type = "HELPFUL", assignto = set("bar4"), infoType = "COUNT", maxCount = 9, isMine = true, color = {0.2, 1, 0.2}, foreigncolor = {0, 0.5, 0} }
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
    Trace{id = 320747, template = "HealTrace", color = { 0.8, 0.4, 0.1} }
    -- Downpour
    Trace{id = 207778, template = "HealTrace", color = { 0.4, 0.4, 1} }

    Trace{id = 77472, template = "HealTrace", color = { 0.5, 1, 0.4 } } -- Healing Wave
    Trace{id = 8004, template = "HealTrace", color = { 0.5, 1, 0.4 } } -- Healing Surge

    Trace{id = 1064, template = "HealTrace", color = { 0.9, 0.7, 0.1} } -- Chain Heal
    --Trace{id = 73921, type = "HEAL", assignto = set("spell3"), color = { 0.6, 0.6, 1}, fade = 0.4, priority = 95 } -- Healing Rain

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(8004), -- Healing Surge
        RangeCheckBySpell(8004), -- Enh Healing Surge
        RangeCheckBySpell(8004),
    }

    config.DispelBitmasks = {
        DispelTypes("Curse"),
        DispelTypes("Curse"),
        DispelTypes("Magic", "Curse"),
    }
end
if playerClass == "HUNTER" then
    A{ id = 136, template = "SurvivalCD" } -- Mend Pet
end
if playerClass == "DRUID" then
    --A{ id = 1126,  type = "HELPFUL", assignto = set("raidbuff"), color = { 235/255 , 145/255, 199/255}, isMissing = true } --Mark of the Wild

    -- A{ id = 327037,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 0.4 , 0.4, 1} } -- Kindred Protection
    A{ id = 327071,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 0.4 , 0.4, 1} } -- Kindred Focus
    -- A{ id = 327022,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 0.4 , 0.4, 1} } -- Kindred Empowerment
    A{ id = 325748,  type = "HELPFUL", assignto = set("bars"), infoType = "DURATION", isMine = true, color = { 0.4 , 0.4, 1} } -- Adaptive Swarm

    -- Tranquility
    --[[
    A{ id = 157982, type = "HELPFUL", assignto = set("mitigation"), priority = 60, isMine = true, stackcolor =   {
        [1] = { 1, 0, 0},
        [2] = { 1, 0, 102/255},
        [3] = { 1, 0, 190/255},
        [4] = { 204/255, 0, 1},
        [5] = { 108/255, 0, 1},
        [6] = { 148/255, 0, 1},
        [7] = { 148/255, 0, 1},
    }, infoType = "COUNT"}
    ]]

    -- Cenarion Ward
    A{ id = 102351, type = "HELPFUL", assignto = set("bars"), priority = 55, scale = 0.75, color = { 0, 0.5, 0.7 }, isMine = true }
    -- Cenarion Ward effect
    A{ id = 102352, type = "HELPFUL", assignto = set("bars"), priority = 55, scale = 0.8, color = { 0, 0.7, 0.9 }, isMine = true }
    -- Rejuvenation
    A{ id = 774,   type = "HELPFUL", assignto = set("bars"), extend_below = 15, scale = 1.25, refreshTime = 4.5, priority = 90, color = { 1, 0.2, 1}, refreshColor = { 1, 0.1, 0.1}, foreigncolor = { 0.4, 0, 0.4 }, infoType = "DURATION", isMine = true }
    -- Germination
    A{ id = 155777,type = "HELPFUL", assignto = set("bars"), extend_below = 15, scale = 1, refreshTime = 4.5, priority = 80, color = { 1, 0.4, 1}, refreshColor = { 1, 0.1, 0.1}, foreigncolor = { 0.4, 0.1, 0.4 }, infoType = "DURATION", isMine = true }
    -- Lifebloom
    -- 188550 -- dark titan's lesson legendary
    A{ id = { 33763, 188550 } , type = "HELPFUL", assignto = set("bar4"), extend_below = 14, refreshTime = 4.5, refreshColor = { 1, 0.6, 0.2}, priority = 60, infoType = "DURATION", isMine = true, color = { 0.2, 1, 0.2}, }
    -- Lifebloom PVP Talent Focused Growth
    A{ id = 203554, type = "HELPFUL", assignto = set("bar4text"), priority = 60, infoType = "COUNT", isMine = true, color = { 0.2, 1, 0.2}, }
    -- Regrowth
    A{ id = 8936, type = "HELPFUL", assignto = set("bars"), isMine = true, scale = 0.5, color = { 0, 0.8, 0.2},priority = 50, infoType = "DURATION" }
    -- Wild Growth
    A{ id = 48438, type = "HELPFUL", assignto = set("bars"), color = { 0, 0.9, 0.7}, priority = 60, infoType = "DURATION", isMine = true }

    Trace{id = 8936, template = "HealTrace", color = { 0, 0.8, 0.2 } } -- Regrowth

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
    A{ id = 6673,  type = "HELPFUL", assignto = set("raidbuff"), color = { 1, .4 , .4}, priority = 50, isMissing = true, isKnownCheck = function() return IsPlayerSpell(6673) end}
end
if playerClass == "MAGE" then
    -- Focus Magic
    A{ id = 321358,  type = "HELPFUL", assignto = set("bars"), color = { 206/255, 4/256, 56/256 }, priority = 50, isMine = true} --Arcane Intellect

    A{ id = 1459,  type = "HELPFUL", assignto = set("raidbuff"), color = { .4 , .4, 1}, priority = 50, isMissing = true, isKnownCheck = function() return IsPlayerSpell(1459) end} --Arcane Intellect
    -- A{ id = 61316, type = "HELPFUL", assignto = set("spell2"), color = { .4 , .4, 1}, priority = 50 } --Dalaran Intellect
    -- A{ id = 54648, type = "HELPFUL", assignto = set("spell2"), color = { 180/255, 0, 1 }, priority = 60, isMine = true } --Focus Magic

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

-------------------------
-- Debuff Highlights
-------------------------

-- To find out current zone map id type: /dump C_Map.GetBestMapForUnit("player")
-- OR
-- Open dungeon in Encounter Journal and type: /dump EJ_GetInstanceInfo(), 7th return value will be the mapID
-- Getting Spell IDs from Encounter Journal:
-- Mouseover the spell and use this macro /dump GetMouseFocus():GetParent().spellID

config.MapIDs = {
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

    [1998] = "Sanctum of Domination",

    [704] = "Halls of Valor",
    [706] = "Maw of Souls",
    [731] = "Neltharion's Lair",
    [733] = "Darkheart Thicket",
    [751] = "Black Rook Hold",
}

config.defaultDebuffHighlights = {
    ["PvP"] = {
        [207736] = { 207736, 3, "Shadowy Duel" },
        [212183] = { 212183, 3, "Smoke Bomb" },
        [33786] = { 33786, 3, "Cyclone" },
    },
    ["Sanctum of Domination"] = {
        [358610] = { 358610, 1, "Eye of the Jailer, Desolation Beam" },
        [350388] = { 350388, 1, "The Nine, Sorrowful Procession" },
        [350496] = { 350496, 1, "Guardian of the First Ones, Threat Neutralization" },
        [350217] = { 350217, 1, "Soulrender Dormazain, Torment" },
        [355506] = { 355506, 1, "Painsmith Raznal, Shadowsteel Chains" },
        [350568] = { 350568, 2, "Fatescribe Roh-Kalo, Call of Eternity" },
        [357686] = { 357686, 2, "Fatescribe Roh-Kalo, Exposed Threads of Fate" },
        [347670] = { 347670, 1, "Sylvanas, Shadow Dagger" },
        [358433] = { 358433, 2, "Sylvanas, Death Knives" },

        [348508] = { 348508, 4, "Painsmith Raznal, Reverberating Hammer" },
        [355568] = { 355568, 4, "Painsmith Raznal, Cruciform Axe" },
        [355778] = { 355778, 4, "Painsmith Raznal, Dualblade Scythe" },

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

-------------------------
-- Blacklist
-------------------------

helpers.auraBlacklist = {
    -- Castle Nathria
    [325184] = true, -- Darkvein, Loose Anima
    [334909] = true, -- The Council of Blood, Oppressive Atmosphere
    [332443] = true, -- Sludgefist, Crumbling Foundation

    [329492] = true, -- Slumberwood Band
    [328891] = true, -- Tantalizingly Large Gilded Plum

    [340556] = true, -- Some Druid cd
    [211319] = true, -- Some priest legendary thing

    -- Maw Debuffs
    -- [330030] = true, -- Gorgoan Lament Damage taken increased by 5%. Damage inflicted increased by 5%.
    [326790] = true, -- Sanguine Depths, Naaru cooldown
    [304510] = true, -- Ravendreth debuff
    [337646] = true, -- Torghast: +25% chance to get critted
    [320227] = true, -- Ardenweald debuff

    -- cast blacklist is shared with auras
    [120651] = true, -- explosive orb affix cast

    [178394] = true, -- Honorless Target

    [338906] = true, -- Jailer's Chains (Torghast debuff)
    [331148] = true, -- Torment: Eye of Skoldus
    [326469] = true, -- Torment: Soulforge Heat
    [331149] = true, -- Torment: Fracturing Forces
    [331151] = true, -- Torment: Breath of Coldheart
    [331153] = true, -- Torment: Mort'regar's Echoes
    [331154] = true, -- Torment: Might of the Upper Reaches
    [296847] = true, -- Torghast: Opressive Aura
    [294720] = true, -- Torghast: Bottled Enigma


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

    [45181] = true, -- Cheat Death cooldown
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
    [337341] = true, -- 9.0 WW Monk: Skyreach Exhaustion, Keerer's Skyreach artifact CD

    -- WARRIOR

    -- DEMON HUNTER
    [1490] = true, -- 8.0 DH: Chaos Brand, Magic damage taken increased by 5%.
    [258860] = true, -- 8.0 DH: Dark Slash

    -- DEATH KNIGHT
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

    -- HUNTER
    -- [131894] = true, -- Hunter: A Murder of Crows
    [259277] = true, -- Survival Hunter: Bloodseeker
    -- Wildfire Bombs
    -- [269747] = true, -- Wildfire Bomb
    [271049] = true, -- Volatile Wildfire
    [270339] = true, -- Scorching Shrapnel
    [270332] = true, -- Scorching Pheromones
    [132951] = true, -- Hunter Flare


}

helpers.importantTargetedCasts = {
    -- Castle Nathria
    [325877] = true, -- Sun King's Salvation, Shade, Ember Blast
    [325361] = true, -- Xy'mox, Glyph of Destruction
    [329774] = true, -- Hungering Destroyer, Overwhelm
    [332318] = true, -- Sludgefist, Destructive Stomp
    -- [334404] = true, -- Hustsman, Spreadshot
    [334929] = true, -- Stone Legion Generals, Kaal, Serrated Swipe
    [342425] = true, -- Stone Legion Generals, Stone Fist

    -- Plaguefall
    [324667] = true, -- Globgrog, Slime Wave
    [329110] = true, -- Doctor Ickus Slime Injection
    [325552] = true, -- Cytotoxic Slash, Domina Venomblade
    [330403] = true, -- Plagueroc, Wing Buffet
    -- [327233] = true, -- Plaguebelcher, Belch Plague
    -- [319070] = true, -- Rotmarrow Slime, Corrosive Gunk

    -- Halls of Atonement
    [322936] = true, -- Halkias, Crumbling Slam
    [319941] = true, -- Echelon, Stone Shattering Leap
    -- [326450] = true, -- Depraved Houndmaster, Loyal Beasts (Gargon buff)
    [325523] = true, -- Depraved Darkblade, Deadly Thrust
    -- [325876] = true, -- Depraved Obliterator, Curse of Obliteration

    -- Mists of Tirna Scithe
    [323137] = true, -- Droman Oulfarran, Bewildering Pollen
    [322614] = true, -- Tred'ova, Mind Link
    [337255] = true, -- Tred'ova, Parasitic Domination
    [322977] = true, -- Halkias, Sinlight Visions
    [321891] = true, -- Mistcaller Vulpin, Freeze Tag Fixation
    --trash
    -- [321968] = true, -- Tirnenn Villager, Bewildering Pollen
    [324776] = true, -- Mistveil Shaper, Bramblethorn Coat
    [324987] = true, -- Mistveil Stalker, Mistveil Bite (leap)
    -- [325223] = true, -- Mistveil Stinger, Anima Injection
    [325418] = true, -- Spinemaw Acidgullet, Volatile Acid

    -- Necrotic Wake
    -- [321894] = true, -- Nalthor the Rimebinder, Dark Exile
    [320596] = true, -- Blightbone, Heaving Retch
    -- [320614] = true, -- Blightbone, Carrion Worm, Blood Gorge
    [320655] = true, -- Blightbone, Crunch, tank damage
    [320376] = true, -- Stitchflesh, Mutilate
    [320788] = true, -- Nalthor, Frozen Binds
    [334748] = true, -- Corpse Harvester, Drain Fluids
    -- [321807] = true, -- Boneflay, Zolramus Bonecarver
    -- [320462] = true, -- Necrotic Bolt, Zolramus Sorcerer
    -- [327399] = true, -- Nar'zudah, Shared Agony
    [324394] = true, -- Skeletal Monstrosity, Shatter, tank damage
    [328667] = true, -- Frostbolt Volley, Brittlebone/Reanimated Mage
    -- [338353] = true, -- Corpse Collector, Goresplatter
    [338357] = true, -- Kyrian Stitchwerk, Tenderize, tank damage
    -- [323496] = true, -- Flesh Crafter, Throw Cleaver 4s
    -- [327130] = true, -- Flesh Crafter, Repair Flesh
    [338606] = true, -- Separation Assistant, Morbid Fixation
    [333477] = true, -- Goregrind, Gut Slice, Targeted Cone aoe

    -- Sanguine Depths
    [319650] = true, -- Kryxis, Vicious Headbutt
    [319713] = true, -- Kryxis, Juggernaut Rush
    [322554] = true, -- Executor Tarvold, Castigate
    [325254] = true, -- Beryilla, Iron Spikes
    [324103] = true, -- General Kaal, Gloom Squall
    [336277] = true, -- Explosive Anger, Remnant of Fury. Big curse

    -- [320991] = true, -- Regal Mistdancer, Echoing Thrust
    [321178] = true, -- Insatiable Brute, Slam
    [326836] = true, -- Wicked Oppressor/Grand Overseer, Curse of Suppression
    [335308] = true, --	Depths Warden, Crushing Strike

    -- Spires of Ascension
    [324608] = true, -- Oryphrion, Charged Stomp

    -- [317936] = true, -- Forsworn Mender/Champion, Forsworn Doctrine (Heal)
    [327413] = true, -- Forswordn Goliath, Rebellious Fist (aoe dmg)
    [320966] = true, -- Kin-Tara, Overhead Slash

    -- [317661] = true, -- Etherdiver, Insidious Venom
    [327648] = true, -- Forsworn Inquisitor, Internal Strife

    -- Theather of pain
    [320063] = true, -- Challengers, Dessia, Slam
    [320069] = true, -- Challengers, Mortal Strike
    [323515] = true, -- Gorechop, Hateful Strike
    [320644] = true, -- Xav the Unfallen, Brutal Combo
    [339415] = true, -- Xav the Unfallen, Deafening Crash
    [324079] = true, -- Mordretha, Reaping Scythe
    [341969] = true, -- Blighted Sludge-Spewer, Withering Discharge
    -- [330614] = true, -- Vile Eruption
    [330810] = true, -- Shackled Soul, Bind Soul

    -- De other side
    [322736] = true, -- Hakkar the Soulflayer, Piercing Barb
    [320144] = true, -- Millificent Manastorm, Buzz-Saw
    [334051] = true, -- Death Speaker, Erupting Darkness, Cone
    [333787] = true, -- Enraged Spirit, Rage, [Targeted?]
    [332605] = true, -- Atal'ai Hoodoo Hexxer, Hex
    [331846] = true, -- ARF-ARF, W-00F
    -- [331548] = true, -- ARF-ARF, Metallic Jaws
    -- [321764] = true, -- Bark Armor, DR



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
do
local AURA = helpers.BuffGainTypes.AURA
local CAST = helpers.BuffGainTypes.CAST
local HEAL = helpers.BuffGainTypes.HEAL
helpers.buffGainWhitelist = {
    [6262]   = HEAL, -- Healthstone
    [323436] = HEAL, -- Phial of Serenity 20%
    --[[DUP]] [330749] = HEAL, -- Phial of Patience 55% (HoT)
    [307192] = HEAL, -- Spiritual Healing Potion (SL)
    [301308] = HEAL, -- Abyssal Healing Potion (BFA)

    [7744] = AURA, -- Will of the Forsaken

    -- Shadowlands Potions
    [344314] = AURA, -- Potion of Psychopomp's Speed
    [307195] = AURA, -- Potion of Invisibility
    [307164] = AURA, -- Potion of Spectral Strength
    [307159] = AURA, -- Potion of Spectral Agility
    [307162] = AURA, -- Potion of Spectral Intellect
    [307494] = AURA, -- Potion of Empowered Exorcisms
    [307495] = AURA, -- Potion of Phantom Fire
    [307496] = AURA, -- Potion of Divine Awakening

    -- BFA Potions
    --[[DUP]] [298225] = AURA, -- Potion of Empowered Proximity
    --[[DUP]] [300714] = AURA, -- Potion of Unbridled Fury
    --[[DUP]] [298317] = AURA, -- Potion of Focused Resolve
    --[[DUP]] [298154] = AURA, -- Superior Battle Potion of Strength
    --[[DUP]] [298152] = AURA, -- Superior Battle Potion of Intellect
    --[[DUP]] [298146] = AURA, -- Superior Battle Potion of Intellect

    -- WARLOCK
    [221703] = CAST, -- Casting Circle
    [113860] = AURA, -- Dark Soul: Misery
    [113858] = AURA, -- Dark Soul: Instability
    [1122] = CAST, -- Summon Infernal
    [265187] = CAST, -- Summon Demonic Tyrant

    --[[DUP]] [212295] = AURA, -- Nether Ward
    --[[DUP]] [104773] = AURA, -- Unending Resolve

    -- PRIEST
    [325013] = AURA, -- Boon of the Ascended
    [232707] = AURA, -- Ray of Hope
    [322105] = AURA, -- Shadow Covenant
    [109964] = AURA, -- Spirit Shell
    [47536] = AURA, -- Rapture
    [200183] = AURA, -- Apotheosis
    [10060] = AURA, -- Power Infusion
    [194249] = AURA, -- Voidform
    [319952] = AURA, -- Surrender to Madness
    [118594] = HEAL, -- Void Shift
    --[[DUP]] [47788] = AURA, -- Guardian Spirit
    --[[DUP]] [62618] = CAST, -- PW: Barrier
    [64843] = CAST, -- Divine Hymn
    --[[DUP]] [213602] = AURA, -- Greater Fade
    --[[DUP]] [289655] = AURA, -- Holy Word: Concentration
    --[[DUP]] [213610] = AURA, -- Holy Ward (PVP)

    -- ROGUE
    --[[DUP]] [1966] = AURA, -- Feint
    [2983] = AURA, -- Sprint
    --[[DUP]] [5277] = AURA, -- Evasion
    --[[DUP]] [31224] = AURA, -- Cloak of Shadows
    --[[DUP]] [185311] = AURA, -- Crimson Vial
    -- VendettaPlayer buff
    [289467] = AURA, -- Vendetta
    [13750] = AURA, -- Adrenaline Rush
    [185422] = AURA, -- Shadow Dance
    [121471] = AURA, -- Shadow Blades

    -- WARRIOR
    [97463] = CAST, -- Rallying Cry
    [236320] = CAST, -- War Banner
    --[[DUP]] [23920] = AURA, -- Spell Reflect
    [262228] = AURA, -- Deadly Calm
    --[[DUP]] [184364] = AURA, -- Enraged Regeneration
    --[[DUP]] [107574] = AURA, -- Avatar
    [1719] = AURA, -- Recklessness
    [118038] = AURA, -- Die by the Sword
    --[[DUP]] [871] = AURA, -- Shield Wall

    -- MONK
    [326860] = AURA, -- Fallen Order
    [247483] = AURA, -- Tigereye Brew
    -- [124507] = HEAL, -- BrM Healing Spheres
    --[[DUP]] [209584] = AURA, -- Zen Focus Tea
    --[[DUP]] [120954] = AURA, -- Fortifying Brew
    --[[DUP]] [243435] = AURA, -- Fortifying Brew (MW/WW)
    -- monk summons
    [123904] = CAST, -- Xuen
    --[[DUP]] [132578] = CAST, -- Niuzao
    [322118] = CAST, -- Yu'lon

    --[[DUP]] [116849] = AURA, -- Life Cocoon
    [137639] = AURA, -- Storm, Earth and Fire
    [197908] = AURA, -- Mana Tea
    --[[DUP]] [122783] = AURA, -- Diffuse Magic
    --[[DUP]] [122278] = AURA, -- Dampen Harm
    [152173] = AURA, -- Serenity

    -- DEATHKNIGHT
    [152279] = AURA, -- Breath of Sindragosa
    [207256] = AURA, -- Pillar of Frost
    [207289] = AURA, -- Unholy Frenzy
    --[[DUP]] [194679] = AURA, -- Rune Tap
    [49998] = CAST, -- Death Strike
    --[[DUP]] [55233] = AURA, -- Vampiric Blood
    --[[DUP]] [48792] = AURA, -- Icebound Fortitude
    [48707] = AURA, -- Anti-Magic Shell
    [51271] = AURA, -- Pillar of Frost
    [81256] = AURA, -- Dancing Rune Weapon

    -- MAGE
    [324220] = AURA, -- Deathborne (Necrolord)
    --[[DUP]] [110909] = AURA, -- Alter Time
    [12042] = AURA, -- Arcane Power
    [55342] = AURA, -- Mirror Image
    [12472] = AURA, -- Icy Veins
    [190319] = AURA, -- Combustion
    [45438] = AURA, -- Ice Block
    [32612] = AURA, -- Invisibility
    [110960] = AURA, -- Greater Invisibility

    -- PALADIN
    --[[DUP]] [205191] = AURA, -- Eye for an Eye
    --[[DUP]] [184662] = AURA, -- Shield of Vengeance
    [231895] = AURA, -- Crusade
    [31884] = AURA, -- Avenging Wrath
    [216331] = AURA, -- Avenging Crusader
    --[[DUP]] [498] = AURA, -- Divine Protection
    --[[DUP]] [642] = AURA, -- Divine Shield
    --[[DUP]] [31850] = AURA, -- Ardent Defender
    --[[DUP]] [86659] = AURA, -- Guardian
    --[[DUP]] [1022] = AURA, -- Blessing of Protection
    --[[DUP]] [204018] = AURA, -- Blessing of Spellwarding
    [1044] = AURA, -- Blessing of Freedom
    [105809] = AURA, -- Holy Avenger

    -- DRUID
    [323546] = AURA, -- Ravenous Frenzy
    --[[DUP]] [236696] = AURA, -- Thorns
    [22842] = AURA, -- Frenzied Regeneration
    [106951] = AURA, -- Berserk
    [117679] = AURA, -- Incarnation: Tree of Life
    [102558] = AURA, -- Incarnation: Son of Ursoc
    [102560] = AURA, -- Incarnation: Chosen of Elune
    [102543] = AURA, -- Incarnation: King of the Jungle
    [194223] = AURA, -- Celestial Alignment
    [197721] = AURA, -- Flourish
    [77764] = CAST, -- Stampeding Roar
    [50334] = AURA, -- Berserk (Bear)
    -- [5215] = AURA, -- Prowl
    --[[DUP]] [22812] = AURA, -- Barkskin
    --[[DUP]] [1850] = AURA, -- Dash
    --[[DUP]] [252216] = AURA, -- Tiger Dash
    --[[DUP]] [61336] = AURA, -- Survival Instincts
    --[[DUP]] [102342] = AURA, -- Ironbark

    -- DEMONHUNTER
    --[[DUP]] [187827] = AURA, -- Metamorphosis Veng
    [162264] = AURA, -- Metamorphosis Havoc
    [206803] = AURA, -- Rain from Above
    --[[DUP]] [212800] = AURA, -- Blur
    --[[DUP]] [196718] = CAST, -- Darkness

    -- HUNTER
    [266779] = AURA, -- Coordinated Assault
    [19574] = AURA, -- Bestial Wrath
    [288613] = AURA, -- Trueshot
    --[[DUP]] [186265] = AURA, -- Aspect of the Turtle
    --[[DUP]] [264735] = AURA, -- Survival of the Fittest

    -- SHAMAN
    --[[DUP]] [108271] = AURA, -- Astral Shift
    [58875] = AURA, -- Spirit Walk
    [51533] = CAST, -- Feral Spirit
    [210918] = AURA, -- Ethereal Form
    [204336] = CAST, -- Grounding Totem
    [98008] = CAST, -- Spirit Link Totem
    [108280] = CAST, -- Healing Tide Totem
}
end
