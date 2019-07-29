local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local DT = helpers.AddDispellType
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
config.enableClickCasting = false
-- if for some reason you don't want to use Clique you can
-- enable native click casting support here, it activates ClickMacro function.
-- ClickMacro syntax is like usual macro, but don't forget [@mouseover] for every command
-- spell:<id> is an alias for localized spellname.
-- Unmodified left click is reserved for targeting by default.
-- Use helpers.BindTarget("shift 1") to change it. Syntax: any combination of "shift" "alt" "ctrl" and button number


config.TargetStatus = { name = "Target", assignto = "border", color = {1,0.7,0.7}, priority = 65 }
config.ReadyCheck = { name = "Readycheck", priority = 90, assignto = "spell3", stackcolor = {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { .8, .6, 0},
                                                                        }}

config.LeaderStatus = { name = "Leader", priority = 59, assignto = "text3", color = {1,.8,.2}, text = "L" }
-- config.AssistStatus = { name = "Assist", priority = 59, assignto = "text3", color = {1,.8,.2}, text = "A" }
config.VoiceChatStatus = { name = "VoiceChat", priority = 59, assignto = "text3", color = {0.3, 1, 0.3}, text = "S", priority = 99 }
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = "border", color = {0.6,0.6,0.6} }
config.DeadStatus = { name = "DEAD", assignto = { "text2","health","power" }, color = {.05,.05,.05}, textcolor = {0,1,0}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "GHOST", assignto = { "text2","health","power" }, color = {.05,.05,.05},  textcolor = {0,1,0}, text = "GHOST", priority = 62}
config.OfflineStatus = { name = "OFFLINE", assignto = { "text2","text3","health","power" }, color = {.15,.15,.15}, textcolor = {0,1,0}, text = "OFFLINE",  priority = 70}
config.AwayStatus = { name = "AFK", assignto = { "text2","text3" }, color = {.15,.15,.15}, textcolor = {1,0.8,0}, text = "AFK",  priority = 60}
config.IncomingHealStatus = { name = "IncomingHeal", assignto = "healthtext", inchealtext = true, color = { 0, 1, 0}, priority = 15 }
config.HealthDeficitStatus = { name = "HPD", assignto = "healthtext", healthtext = true, color = { 54/255, 201/255, 99/256 }, priority = 10 }
config.UnitNameStatus = { name = "UnitName", assignto = "text1", nametext = true, classcolor = true, priority = 20 }
config.HealthBarColor = { name = "HealthBar", assignto = "health", color = {1, .3, .3}, classcolor = true, priority = 20 }
config.PowerBarColor = { name = "PowerBar", assignto = "power", color = {.5,.5,1}, priority = 20 }
config.OutOfRangeStatus = { name = "OOR", assignto = "self", color = {0.5,0.5,0.5}, alpha = 0.3, text = "OOR", priority = 50 }
config.PhasedOutStatus = { name = "Phased", assignto = "self", color = {0.5,0.5,0.5}, alpha = 0.4, text = "Phased", priority = 40 }
config.InVehicleStatus = { name = "InVehicle", assignto = "border", color = {0.3,1,0.3}, priority = 21 }
config.LOSStatus = { name = "OutOfSight", assignto = "healfeedback", scale = 2, color = {1,0.1,0.1}, resetAnimation = true, priority = 95, fade = 0.3 }

-- default priority is 80

D(1, { name = "DI1", assignto = "dicon1", pulse = true, showDuration = true })
D(2, { name = "DI2", assignto = "dicon2", pulse = true, showDuration = true })
D(3, { name = "DI3", assignto = "dicon3", pulse = true, showDuration = true })
D(4, { name = "DI4", assignto = "dicon4", pulse = true, showDuration = true })

helpers.DispelTypes = function(str)
    str = str:upper()
    if str:find("MAGIC") then DT("Magic", { assignto = "dispel", color = { 0.2, 0.6, 1}, priority = 6 }) end
    if str:find("CURSE") then DT("Curse", { assignto = "dispel", color = { 0.6, 0, 1}, priority = 5 }) end
    if str:find("POISON") then DT("Poison", { assignto = "dispel", color = { 0, 0.6, 0}, priority = 4 }) end
    if str:find("DISEASE") then DT("Disease", { assignto = "dispel", color = { 0.6, 0.4, 0}, priority = 3}) end
end

helpers.RangeCheckBySpell = function (spellID)
    local spellName = GetSpellInfo(spellID)
    return function(unit)
        return (IsSpellInRange(spellName,unit) == 1)
    end
end
