local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local DispelTypes = helpers.DispelTypes
local D = helpers.AddDebuff
local Trace = helpers.AddTrace
local config = AptechkaDefaultConfig

config.auras = {}
config.autoload = {}

config.skin = "GridSkin"
config.scale = 1
--config.width = 50 -- defined in skin module
--config.height = 50
-- config.cropNamesLen = 7  -- maximum amount of characters in unit name
config.raidIcons = true
config.showSolo = true     -- visible without group/raid
config.showParty = true    -- in group
config.unitGap = 10       -- gap between units
config.unitGrowth = "RIGHT" -- direction for adding new players in group. LEFT / RIGHT / TOP / BOTTOM
config.groupGrowth = "TOP"
config.groupGap = 10
config.unlocked = false  -- when addon initially loaded
config.frameStrata = "MEDIUM"

config.layouts = {  -- works ONLY with group anchors disabled.
                    -- layout functions are checked from first to last. function should return true to be accepted.
    function(self, members, role, spec)
        if role == "HEALER" and members > 27 then --resize after 27 for healers
            self:SetScale(.8); return true
        end
    end,
    function(self, members, role, spec)
        if role ~= "HEALER" and members > 11 then --after 11 for non-healers
            self:SetScale(.65); return true
        end
    end,
    -- function(self, members, role, spec) -- Example: scale to .8 for non-healer specs regardless of group size
    --     if role ~= "HEALER" then                    and switch to another anchor that you can place in the corner
    --         self:SetScale(.8)
    --         self:SwitchAnchors("GridSkinCustom")
    --         return true
    --     end
    -- end
}
config.maxgroups = 8
config.petgroup = false
config.petcolor = {1,.5,.5}
--A maximum of 5 pets can be displayed.
--You also can use /apt createpets command, it creates pet group on the fly

config.registerForClicks = { "AnyUp" }
config.enableIncomingHeals = true
config.incomingHealThreshold = 0
config.incomingHealIgnorePlayer = false
config.displayRoles = true
config.enableTraceHeals = true
config.enableVehicleSwap = false
config.enableAbsorbBar = false

config.TargetStatus = { name = "Target", assignto = "border", color = {0.7,0.2,0.5}, priority = 65 }
config.MouseoverStatus = { name = "Mouseover", assignto = "border", color = {1,0.5,0.8}, priority = 66 }
config.AggroStatus = { name = "Aggro", assignto = "raidbuff",  color = { 0.7, 0, 0},priority = 55 }
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
config.MindControlStatus = { name = "MIND_CONTROL", assignto = { "border", "mindcontrol", "innerglow", "unhealable" }, color = {0.5,0,1}, priority = 52 }
-- config.UnhealableStatus = { name = "UNHEALABLE", assignto = { "unhealable" }, color = {0.5,0,1}, priority = 50 }

config.BossDebuffs = {
    { name = "BossDebuffLevel1", assignto = "bossdebuff", color = {1,0,0}, priority = 95, pulse = true, },
    { name = "BossDebuffLevel2", assignto = "bossdebuff", color = {1,0,1}, priority = 95, pulse = true, },
    { name = "BossDebuffLevel3", assignto = { "innerglow", "border", "flash" }, color = {1,0,0}, priority = 90 },
    { name = "BossDebuffLevel4", assignto = "pixelGlow", color = {1,1,1}, priority = 95 },
    -- { name = "BossDebuffLevel3", assignto = "autocastGlow", color = {1,1,0.3}, priority = 90 },
}

local IsSpellInRange = IsSpellInRange
helpers.RangeCheckBySpell = function (spellID)
    local spellName = GetSpellInfo(spellID)
    return function(unit)
        return (IsSpellInRange(spellName,unit) == 1)
    end
end
