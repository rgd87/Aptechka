local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID")
local A = helpers.AddAura
local DT = helpers.AddDispellType
local Trace = helpers.AddTrace
InjectorConfig = {}

-- size
InjectorConfig.width = 50
InjectorConfig.height = 50
InjectorConfig.scale = 1

-- frame config
InjectorConfig.texture = [[Interface\AddOns\Injector\gradient]]
InjectorConfig.font = [[Interface\AddOns\Injector\ClearFont.ttf]]
InjectorConfig.fontsize = 12

InjectorConfig.cropNamesLen = 7  -- maximum amount of characters in unit name
InjectorConfig.manabarwidth = 6
InjectorConfig.orientation = "VERTICAL"    -- HORIZONTAL / VERTICAL
InjectorConfig.outOfRangeAlpha = 0.4
InjectorConfig.disableManaBar = false
InjectorConfig.invertColor = false             -- if true hp lost becomes dark, current hp becomes bright
InjectorConfig.incomingHealTimeframe = 1.5     -- incoming in next 1.5 seconds heals are displayed, including hot ticks
InjectorConfig.incomingHealDisplayAmount = true  -- on second line
InjectorConfig.incomingHealIgnoreHots = true
InjectorConfig.raidIcons = true
InjectorConfig.enableTraceHeals = true
InjectorConfig.mouseoverTooltip = "outofcombat"      -- always / outofcombat / disabled

-- layout
InjectorConfig.maxgroups = 8
InjectorConfig.showSolo = true
InjectorConfig.unitGap = 10        -- gap between units
InjectorConfig.groupGap = 10
InjectorConfig.unitGrowth = "RIGHT" -- direction for adding new players in group. LEFT / RIGHT / TOP / BOTTOM
InjectorConfig.groupGrowth = "TOP" -- new groups direction. LEFT / RIGHT / TOP / BOTTOM
InjectorConfig.resize = { after = 27, to = 0.8 } -- = if number of players in raid exeeds 27 then resize to 0.8.   "InjectorConfig.resize = nil" disables it
InjectorConfig.anchorpoint = "BOTTOMLEFT" -- anchor position relative to 1st unit of 1st group. if you want to grow frames to TOP and RIGHT it better be BOTTOMLEFT.
InjectorConfig.lockedOnStartUp = true
InjectorConfig.disableBlizzardParty = true

-- pets 
-- petframes suck in this addon, i know. It's more like outdated plugin.
InjectorConfig.petFrames = false
InjectorConfig.petScale = 1
InjectorConfig.petFramesSeparation = false


-- bells and whistles
InjectorConfig.useCombatLogFiltering = true
-- useCombatLogFiltering provides a huge perfomance boost over default behavior, which would be to listen only to UNIT_AURA event.
-- UNIT_AURA doesn't tell what exactly changed and every time addon had to scan current buffs/debuffs,
-- in raid combat unit_aura sometimes fired up to 8 times per second for each member with all the stacking trinkets and procs.
-- useCombatLogFiltering option moves this process mainly to combat log, where we can see what spell was updated.
-- Only if it's one of OUR spells from indicators it will update buff data for this unit.
-- The drawback is that it only works in combat log range, but it's big enough, and there's a fallback on throttled unit_aura (updates every 5s) for out of range units.
-- On lich king there was an issue, and maybe it's still present, that necrotic plague removal event didn't appear in combat log
-- and that caused glitches with boss debuff indicator. But that's a rare blizzard side bug.
-- Dispel idicators still work from unit_aura, so you'll see plague regardless as disease if you can dispel it. Necrotic plague removed from default loadables.lua setup.

-- libs
InjectorConfig.useHealComm = true -- incoming  heal library
InjectorConfig.useQuickHealth = isHealer -- combat log event faster than UNIT_HEALTH event. And that's what this lib does, allows you to see health updates sooner.

InjectorConfig.SetupIndicators = {
    ["topleft"] =  { point = "TOPLEFT", size = 5, },
    ["topleft2"] =  { point = "TOPLEFT", size = 5, xOffset = 7},
    ["topleft3"] =  { point = "TOPLEFT", size = 5, yOffset = -7},
    ["topright"] =  { point = "TOPRIGHT", size = 7 },
    ["bottomright"] =  { point = "BOTTOMRIGHT", size = 8, },
    ["bottomleft"] =  { point = "BOTTOMLEFT", size = 4, },
    ["bottom"] =  { point = "BOTTOM", size = 7, },
    ["top"] =  { point = "TOP", size = 10, },
    ["left"] =  { point = "LEFT", size = 10, },
    
    ["border_right"] = { point = "RIGHT", width = 2, height = InjectorConfig.height+8, xOffset = 4 , nobackdrop = true},
    ["border_left"] = { point = "LEFT", width = 2, height = InjectorConfig.height+8, xOffset = -4 , nobackdrop = true},
    ["border_top"] = { point = "TOP", width = InjectorConfig.width+4, height = 2, yOffset = 4 , nobackdrop = true},
    ["border_bottom"] = { point = "BOTTOM", width = InjectorConfig.width+4, height = 2, yOffset = -4   , nobackdrop = true },
}
-- so border actually is built from 4 indicators, you can use them separately
local BORDER = { "border_left", "border_right", "border_top", "border_bottom" } -- shortcut, e.g. indicator = BORDER

InjectorConfig.SetupIcons = {
    ["raidicon"] = { point = "BOTTOMLEFT", size = 24, xOffset = -9, yOffset = -9, alpha = 0.6 },   --special icon for raid targets
    ["center"] = { point = "CENTER", size = 24, alpha = 0.6, omnicc = false, stacktext = true },
}
--customizing stack label: stacktext = { font = [[Interface\AddOns\Injector\ClearFont.ttf]], size = 10, flags = "OUTLINE", color = {1,0,0} },

--InjectorConfig.TargetStatus = { name = "Target", type = "HELPFUL", indicator = BORDER, color = {1,0.7,0.7}, priority = 65 }
InjectorConfig.IncomingHealStatus = nil  --{ name = "IncomingHeal", type = "HELPFUL", indicator = { "bottomleft" },  color = { 0, 1, 0}, priority = 60 }
InjectorConfig.AggroStatus = { name = "Aggro", type = "HARMFUL", indicator = { "bottomleft" },  color = { 0.7, 0, 0} } -- InjectorConfig.AggroStatus = nil will disable aggro monitoring at all
InjectorConfig.ReadyCheck = { name = "Readycheck", type = "HELPFUL", priority = 90, indicator = { "top" },  stackcolor =   {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { 1, 1, 0},
                                                                        }}
InjectorConfig.MainTankStatus = { name = "MainTank", type = "HELPFUL", priority = 60, indicator = BORDER, color = {0.6,0.6,0.6} }


InjectorConfig.Colors = {
    --["PRIEST"] = { r = 1, g = 1, b = 1 },
    ["VEHICLE"] = { r = 1, g = 0.5, b = 0.5 },
}

--[[
Spell parameters
================
    id - spell id to query localized spell name.
    name - spell name
    type - HELPFUL/HARMFUL  for buffs/debuffs
    priority - if multiple spells assigned to same indicator, the one with highest priority will be displayed. Default is 80.
    showDuration - enables cooldownlike duration circle
    isMine  - only your spells
]]

if playerClass == "PRIEST" then
        -- long buffs      
    A{ id = 1243,  type = "HELPFUL", indicator = { "topleft" }, pulse = true, color = { 1, 1, 1} } --Power Word: Fortitude
    A{ id = 21562, type = "HELPFUL", indicator = { "topleft" }, color = { 0.8, 1, 0.8} } --Prayer of Fortitude
    A{ id = 14752, type = "HELPFUL", indicator = { "topleft2" }, color = { .6 , .6, 1} } --Divine Spirit
    A{ id = 27681, type = "HELPFUL", indicator = { "topleft2" }, color = { .6 , .6, 1} } --Prayer of Spirit
    A{ id = 976,   type = "HELPFUL", indicator = { "topleft3" }, color = { 102/255 , 0, 187/255 } } --Shadow Protection
    A{ id = 27683, type = "HELPFUL", indicator = { "topleft3" }, color = { 102/255 , 0, 187/255 } } --Prayer of Shadow Protection
    
    --A{ id = 1706,  type = "HELPFUL", indicator = { "topright" }, color = { 1, 1, 1}, priority = 60, showDuration = true } --Levitate
    --A{ id = 552,   type = "HELPFUL", indicator = { "topleft3" }, priority = 82, color = { 0, 1, 0 } } --Abolish Disease
    
    A{ id = 139,   type = "HELPFUL", indicator = { "bottomright" }, pulse = true, color = { 0, 1, 0}, showDuration = true, isMine = true } --Renew
    A{ id = 17,    type = "HELPFUL", indicator = { "top" }, color = { 1, 1, 0}, showDuration = true } --Power Word: Shield
    A{ id = 6788,  type = "HARMFUL", indicator = { "top" }, color = { 0.6, 0, 0}, showDuration = true, priority = 40 } --Weakened Soul
    A{ id = 33076, type = "HELPFUL", indicator = { "topright" }, stackcolor =   {
                                                                            [1] = { 0.4, 0, 0},
                                                                            [2] = { 0.7, 0, 0},
                                                                            [3] = { 1, 0, 0},
                                                                            [4] = { 1, 0.3, 0.3},
                                                                            [5] = { 1, 0.6, 0.6},
                                                                            [6] = { 1, 0.9, 0.9}, -- Tier7 set bonus
                                                                        }} --Prayer of Mending
                                                                        
    Trace{id = 34861, type = "HEAL", indicator = { "topright" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Circle of Healing
    Trace{id = 33076, type = "HEAL", indicator = { "topright" }, color = { 1, 0.6, 0.6}, fade = 1.5, priority = 97 } -- PoM Trace
                                                                        
    --InjectorConfig.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(2061),unit) == 1) end
            --// Use Flash Heal for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.
    
    DT("Magic", { indicator = { "bottom" }, color = { 0.2, 0.6, 1}, priority = 81 })
    DT("Disease", { indicator = { "bottom" }, color = { 0.6, 0.4, 0} })
end

if playerClass == "WARLOCK" then
    A{ id = 20707, type = "HELPFUL", indicator = { "topleft" }, color = { 180/255, 0, 1 }, priority = 81 } --Soulstone Resurrection
--~     A{ id = 6307,  type = "HELPFUL", indicator = { "topleft" }, color = { 1, 0, 0 }, priority = 81 } --Blood Pact
--~     A{ id = 54424, type = "HELPFUL", indicator = { "topleft" }, color = { .6 , .6, 1 } } --Fel Intelligence
end
if playerClass == "PALADIN" then
    --A{ id = 20217, type = "HELPFUL", indicator = { "topleft" }, color = { .6 , .3, 1} } --Blessing of Kings
    --A{ id = 25898, type = "HELPFUL", indicator = { "topleft" }, color = { .6 , .3, 1} } --Greater Blessing of Kings
    
    --A{ id = 19740, type = "HELPFUL", indicator = { "topleft2" }, color = { 1 , 0.5, 0.3} } --Blessing of Might
    --A{ id = 25782, type = "HELPFUL", indicator = { "topleft2" }, color = { 1 , 0.5, 0.3} } --Greater Blessing of Might
    
    --A{ id = 19742, type = "HELPFUL", indicator = { "topleft3" }, color = { 0.4, 1, 0.4} } --Blessing of Wisdom
    --A{ id = 25894, type = "HELPFUL", indicator = { "topleft3" }, color = { 0.4, 1, 0.4} } --Greater Blessing of Wisdom
    A{ id = 53563, type = "HELPFUL", indicator = { "top" }, showDuration = true,
                                                                            isMine = true,
                                                                            color = { 0,1,0 },
                                                                            --foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        }
    
    Trace{id = 54968, type = "HEAL", indicator = { "topright" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Glyph of Holy Light
    
    --InjectorConfig.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(635),unit) == 1) end
            --// Use Holy Light for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Magic", { indicator = { "bottom" }, color = { 0.2, 0.6, 1} })
    DT("Disease", { indicator = { "bottom" }, color = { 0.6, 0.4, 0} })
    DT("Poison", { indicator = { "bottom" }, color = { 0, 0.6, 0} })
end
if playerClass == "SHAMAN" then
    A{ id = 61295,  type = "HELPFUL", indicator = { "bottomright" }, showDuration = true, isMine = true, color = { 0.2 , 0.2, 1} } --Riptide
    A{ id = 974,    type = "HELPFUL", indicator = { "top" }, showDuration = true,
                                                                        --isMine = true,     
                                                                        stackcolor =   {
                                                                            [1] = { 0,.4, 0},
                                                                            [2] = { 0,.5, 0},
                                                                            [3] = { 0,.6, 0},
                                                                            [4] = { 0,.7, 0},
                                                                            [5] = { 0,.8, 0},
                                                                            [6] = { 0, 0.9, 0},
                                                                            [7] = {.1, 1, .1},
                                                                            [8] = {.2, 1, .2},
                                                                        },
                                                                        foreigncolor = {0,0,.5}, } --Earth Shield
                                                                        
    Trace{id = 1064, type = "HEAL", indicator = { "topright" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Chain Heal
    --Trace{id = 51558, type = "HEAL", indicator = { "topright" }, color = { 1, 0.6, 0.6 }, fade = 0.7, priority = 95 } -- Ancestral Awakening
                                                                        
    --InjectorConfig.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(331),unit) == 1) end
            --// Use Healing Wave for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Disease", { indicator = { "bottom" }, color = { 0.6, 0.4, 0} })
    DT("Poison", { indicator = { "bottom" }, color = { 0, 0.6, 0} })
    DT("Curse", { indicator = { "bottom" }, color = { 0.6, 0, 1} })
end
if playerClass == "DRUID" then
    A{ id = 1126,  type = "HELPFUL", indicator = { "topleft" }, color = { 235/255 , 145/255, 199/255} } --Mark of the Wild
    A{ id = 21849, type = "HELPFUL", indicator = { "topleft" }, color = { 235/255 , 145/255, 199/255} } --Gift of the Wild
    A{ id = 467,   type = "HELPFUL", indicator = { "topleft3" }, color = { 150/255, 100/255, 0 } } --Thorns
    
    A{ id = 774,   type = "HELPFUL", indicator = { "bottomright" }, pulse = true, color = { 1, 0.2, 1}, showDuration = true, isMine = true } --Rejuvenation
    A{ id = 8936,  type = "HELPFUL", indicator = { "topright" }, priority = 82, color = { 198/255, 233/255, 80/255}, showDuration = true, isMine = true } --Regrowth
    A{ id = 33763, type = "HELPFUL", indicator = { "top" }, showDuration = true, isMine = true, stackcolor = {
                                                                            [1] = { 0, 0.8, 0},
                                                                            [2] = { 0.2, 1, 0.2},
                                                                            [3] = { 0.5, 1, 0.5},
                                                                        }} --Lifebloom
    A{ id = 48438, type = "HELPFUL", indicator = { "topright" }, color = { 0.4, 1, 0.4}, showDuration = true, isMine = true } --Wild Growth
    --A{ id = 2893, type = "HELPFUL", indicator = { "topleft3" }, priority = 82, color = { 0, 1, 0 } } --Abolish Poison
    
    --InjectorConfig.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(774),unit) == 1) end
            --// Use Rejuvenation for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Poison", { indicator = { "bottom" }, color = { 0, 0.6, 0} })
    DT("Curse", { indicator = { "bottom" }, color = { 0.6, 0, 1} })
end
if playerClass == "MAGE" then
    A{ id = 1459,  type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Arcane Intellect
    A{ id = 23028, type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Arcane Brilliance
    A{ id = 61316, type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Dalaran Brilliance
    A{ id = 61024, type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Dalaran Intellect
    A{ id = 54648, type = "HELPFUL", indicator = { "topleft2" }, color = { 180/255, 0, 1 }, isMine = true } --Focus Magic
    
    DT("Curse", { indicator = { "bottom" }, color = { 0.6, 0, 1} })
end