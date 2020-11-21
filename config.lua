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
config.petcolor = {1,.5,.5}
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
config.enableVehicleSwap = false
config.enableAbsorbBar = false

config.TargetStatus = { name = "Target", assignto = set("border"), color = {0.7,0.2,0.5}, priority = 65 }
config.MouseoverStatus = { name = "Mouseover", assignto = set("border"), color = {1,0.5,0.8}, priority = 66 }
config.AggroStatus = { name = "Aggro", assignto = set("raidbuff"),  color = { 0.7, 0, 0},priority = 85 }
config.RCReady = { name = "RCReady", priority = 90, assignto = set("statusIcon"), color = { 0, 1, 0}, text = "READY" }
config.RCNotReady = { name = "RCNotReady", priority = 91, assignto = set("statusIcon"), color = { 1, 0, 0}, text = "NOT READY" }
config.RCWaiting = { name = "RCWaiting", priority = 89, assignto = set("statusIcon"), color = { 0.8, 0.6, 0}, text = "WAITING" }
config.IncResStatus = { name = "IncRes", priority = 86, assignto = set("statusIcon"), color = { 1, 1, 1} }
config.PhasedStatus = { name = "Phased", priority = 84, assignto = set("statusIcon"), color = { 0.3, 0.3, 0.45} }
config.RoleStatus = { name = "RoleIcon", assignto = set("roleIcon"), priority = 65, color = { 1, 1, 1 } }
config.RaidTargetStatus = { name = "RaidTarget", assignto = set("raidTargetIcon"), priority = 70, color = { 1, 1, 1 } }
config.IncomingCastStatus = { name = "IncomingCast", priority = 97, assignto = set("incomingCastIcon"), color = { 1, 1, 1} }
config.LeaderStatus = { name = "Leader", priority = 59, assignto = set("text3"), color = {1,.8,.2}, text = "L" }
-- config.AssistStatus = { name = "Assist", priority = 59, assignto = set("text3"), color = {1,.8,.2}, text = "A" }
config.VoiceChatStatus = { name = "VoiceChat", assignto = set("text3"), color = {0.3, 1, 0.3}, text = "S", priority = 99 }
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = set("border"), color = {0.6,0.6,0.6} }
config.LowHealthStatus = { name = "LowHealth", priority = 60, assignto = set("border"), color = {1,0,0} }
config.DeadStatus = { name = "Dead", assignto = set("text2","health"), color = {.05,.05,.05}, textcolor = {0,1,0}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "Ghost", assignto = set("text2","health"), color = {.05,.05,.05},  textcolor = {0,1,0}, text = "GHOST", priority = 62}
config.OfflineStatus = { name = "Offline", assignto = set("text2","text3","health"), color = {0.5,0.5,0.5}, textcolor = {0,1,0}, text = "OFFLINE",  priority = 70}
config.AwayStatus = { name = "AFK", assignto = set("text2","text3"), color = {0.4,0.4,0.4}, textcolor = {1,0.8,0}, text = "AFK",  priority = 15}
config.IncomingHealStatus = { name = "IncHealText", assignto = set("text2"), color = { 0, 1, 0}, priority = 15 }
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
    buffIcons = { type = "BarIconArray", width = 12, height = 18, point = "TOPRIGHT", x = 5, y = -6, alpha = 1, growth = "LEFT", max = 3, edge = true, outline = true, vertical = true, font = config.defaultFont, textsize = 12 },
    bars = { type = "BarArray", width = 21, height = 5, point = "BOTTOMRIGHT", x = 0, y = 0, vertical = false, growth = "UP", max = 7 },
    vbar1 = { type = "Bar", width=4, height=20, point="TOPRIGHT", x=-9, y=2, vertical = true},
    text1 = { type = "StaticText", point="CENTER", x=0, y=0, font = config.defaultFont, textsize = 12, effect = "SHADOW" },
    text2 = { type = "StaticText", point="CENTER", x=0, y=-11, font = config.defaultFont, textsize = 10, effect = "NONE" },
    text3 = { type = "Text", point="TOPLEFT", x=2, y=0, font = config.defaultFont, textsize = 9, effect = "NONE" },
    incomingCastIcon = { type = "ProgressIcon", width = 18, height = 18, point = "TOPLEFT", x = -3, y = 3, alpha = 1, font = config.defaultFont, textsize = 12, outline = false, edge = false },
    debuffIcons = { type = "DebuffIconArray", width = 13, height = 13, point = "BOTTOMLEFT", x = 0, y = 0, style = "STRIP_RIGHT", animdir = "LEFT", alpha = 1, growth = "UP", max = 4, edge = true, outline = true, font = config.defaultFont, textsize = 12, bigscale = 1.3 },
    floatingIcon = { type = "FloatingIcon", width = 16, height = 16, point = "TOPLEFT", x = 15, y = -5, alpha = 1, font = config.defaultFont, textsize = 12, outline = false, edge = false, angle = 60, range = 45, spreadArc = 30, animDuration = 2 },
    statusIcon = { type = "Texture", width = 20, height = 20, point = "CENTER", x = 0, y = 14, texture = nil, rotation = 0, zorder = 6-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = false },
    roleIcon = { type = "Texture", width = 13, height = 13, point = "BOTTOMLEFT", x = -8, y = -8, texture = nil, rotation = 0, zorder = 6-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = false },
    raidTargetIcon = { type = "Texture", width = 20, height = 20, point = "TOPLEFT", x = -10, y = 10, texture = nil, rotation = 0, zorder = 16-DEFAULT_TEXLEVEL, alpha = 0.3, blendmode = "BLEND", disableOverrides = false },
    healfeedback = { type = "Texture", width = 16, height = 30, point = "TOPRIGHT", x = 0, y = 0, texture = "Interface\\AddOns\\Aptechka\\corner", rotation = 270, zorder = 7-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = true },
    debuffHighlight = { type = "Texture", width = 12, height = 15, point = "TOPLEFT", x = 0, y = 0, texture = "Interface\\AddOns\\Aptechka\\corner", rotation = 180, zorder = 13-DEFAULT_TEXLEVEL, alpha = 1, blendmode = "BLEND", disableOverrides = true },
}
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
if isClassic then
    config.DefaultWidgets.totemCluster1 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(6), y = 0 }
    config.DefaultWidgets.totemCluster2 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(12), y = 0 }
    config.DefaultWidgets.totemCluster3 = { type = "Indicator", width = 5, height = 5, point = "TOPLEFT", x = pixelperfect(19), y = 0 }
end

-- default priority is 80

local RangeCheckBySpell = helpers.RangeCheckBySpell


config.templates = {
    TankCD = { assignto = set("icon"), infoType = "DURATION", priority = 94, color = { 1, 0.2, 1}, refreshTime = 2 },
    SurvivalCD = { assignto = set("buffIcons"), infoType = "DURATION", priority = 90, color = { 0.4, 1, 0.4} },
    AreaDR = { assignto = set("buffIcons"), infoType = "DURATION", priority = 89, color = { 0.4, 1, 0.4} },
    ActiveMitigation = { assignto = set("mitigation"), infoType = "DURATION", color = {0.7, 0.7, 0.7}, priority = 80 },
    HealTrace = { assignto = set("healfeedback"), color = { 1, 0.7, 0.35}, fade = 0.7, priority = 96 },
}
