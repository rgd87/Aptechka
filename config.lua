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
--You also can use /apt createpets command, it creates pet group on the fly

config.registerForClicks = { "AnyUp" }
config.enableIncomingHeals = true
config.incomingHealIgnorePlayer = false
config.displayRoles = true
config.enableTraceHeals = true
config.enableVehicleSwap = false
config.enableAbsorbBar = false

config.TargetStatus = { name = "Target", assignto = "border", color = {0.7,0.2,0.5}, priority = 65 }
config.MouseoverStatus = { name = "Mouseover", assignto = "border", color = {1,0.5,0.8}, priority = 66 }
config.AggroStatus = { name = "Aggro", assignto = "raidbuff",  color = { 0.7, 0, 0},priority = 55, jump = true }
config.ReadyCheck = { name = "Readycheck", priority = 90, assignto = "spell3", stackcolor = {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { .8, .6, 0},
                                                                        }}

config.LeaderStatus = { name = "Leader", priority = 59, assignto = "text3", color = {1,.8,.2}, text = "L" }
-- config.AssistStatus = { name = "Assist", priority = 59, assignto = "text3", color = {1,.8,.2}, text = "A" }
config.VoiceChatStatus = { name = "VoiceChat", assignto = "text3", color = {0.3, 1, 0.3}, text = "S", priority = 99 }
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = "border", color = {0.6,0.6,0.6} }
config.DeadStatus = { name = "DEAD", assignto = { "text2","health" }, color = {.05,.05,.05}, textcolor = {0,1,0}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "GHOST", assignto = { "text2","health" }, color = {.05,.05,.05},  textcolor = {0,1,0}, text = "GHOST", priority = 62}
config.OfflineStatus = { name = "OFFLINE", assignto = { "text2","text3","health" }, color = {.15,.15,.15}, textcolor = {0,1,0}, text = "OFFLINE",  priority = 70}
config.AwayStatus = { name = "AFK", assignto = { "text2","text3" }, color = {.15,.15,.15}, textcolor = {1,0.8,0}, text = "AFK",  priority = 60}
config.IncomingHealStatus = { name = "IncomingHeal", assignto = "text2", color = { 0, 1, 0}, priority = 15 }
config.HealthDeficitStatus = { name = "HealthDeficit", assignto = "healthtext", color = { 54/255, 201/255, 99/256 }, priority = 10 }
config.UnitNameStatus = { name = "UnitName", assignto = "text1", classcolor = true, priority = 20 }
config.HealthBarColor = { name = "HealthBar", assignto = "health", color = {1, .3, .3}, classcolor = true, priority = 20 }
config.PowerBarColor = { name = "PowerBar", assignto = "power", color = {.5,.5,1}, priority = 20 }
config.OutOfRangeStatus = { name = "OOR", assignto = "self", color = {0.5,0.5,0.5}, alpha = 0.5, text = "OOR", priority = 50 }
config.InVehicleStatus = { name = "InVehicle", assignto = "vehicle", color = {0.3,1,0.3}, priority = 21 }
config.LOSStatus = { name = "OutOfSight", assignto = "healfeedback", scale = 1.6, color = {1,0.1,0.1}, resetAnimation = true, priority = 95, fade = 0.3 }
config.DispelStatus = { name = "Dispel", assignto = "bossdebuff", scale = 0.8, priority = 6 }

-- config.MindControl = { name = "MIND_CONTROL", assignto = { "mindcontrol" }, color = {1,0,0}, priority = 52 }
config.MindControlStatus = { name = "MIND_CONTROL", assignto = { "border", "mindcontrol", "innerglow" }, color = {0.5,0,1}, priority = 52 }
-- config.UnhealableStatus = { name = "UNHEALABLE", assignto = { "unhealable" }, color = {0.5,0,1}, priority = 50 }

config.DefaultWidgets = {
    raidbuff = { type = "BarArray", width = 5, height = 5, point = "TOPLEFT", x = 0, y = 0, vertical = true, growth = "DOWN", max = 5 },
    mitigation = { type = "Bar", width=14, height=5, point="TOPLEFT", x=pixelperfect(6), y=0, vertical = false},
    icon = { type = "Icon", width = 24, height = 24, point = "CENTER", x = 0, y = 0, alpha = 1, textsize = 12, outline = true, edge = true },
    spell1 = { type = "Indicator", width = 9, height = 8, point = "BOTTOMRIGHT", x = 0, y = 0, },
    -- spell2 = { type = "Indicator", width = 9, height = 8, point = "TOP", x = 0, y = 0, },
    spell3 = { type = "Indicator", width = 9, height = 8, point = "TOPRIGHT", x = 0, y = 0, },
    bar4 = { type = "Bar", width=21, height=5, point="TOPRIGHT", x=0, y=2, vertical = false},
    buffIcons = { type = "IconArray", width = 12, height = 18, point = "TOPRIGHT", x = 5, y = -6, alpha = 1, growth = "LEFT", max = 3, edge = true, outline = true, textsize = 12 },
    bars = { type = "BarArray", width = 21, height = 5, point = "BOTTOMRIGHT", x = 0, y = 0, vertical = false, growth = "UP", max = 7 },
    vbar1 = { type = "Bar", width=4, height=20, point="TOPRIGHT", x=-9, y=2, vertical = true},
    text1 = { type = "StaticText", point="CENTER", x=0, y=0, textsize = 12, effect = "SHADOW" },
    text2 = { type = "StaticText", point="CENTER", x=0, y=-10, textsize = 10, effect = "NONE" },
    text3 = { type = "Text", point="TOPLEFT", x=2, y=0, textsize = 9, effect = "NONE" },
}
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
