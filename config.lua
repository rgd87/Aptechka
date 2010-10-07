local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID")
local A = helpers.AddAura
local DT = helpers.AddDispellType
local ClickMacro = helpers.ClickMacro
local Trace = helpers.AddTrace
InjectorDefaultConfig = {}
local config = InjectorDefaultConfig


config.skin = "GridSkin"
--config.width = 50
--config.height = 50
--config.scale = 1
--config.texture = [[Interface\AddOns\Injector\gradient]]
--config.font = [[Interface\AddOns\Injector\ClearFont.ttf]]
--config.fontsize = 12
config.cropNamesLen = 7  -- maximum amount of characters in unit name
--config.manabarwidth = 6
--config.orientation = "VERTICAL"    -- HORIZONTAL / VERTICAL
config.outOfRangeAlpha = 0.4
config.disableManaBar = false
config.incomingHealDisplayAmount = true  -- on second line
config.raidIcons = true
config.mouseoverTooltip = "outofcombat"      -- always / outofcombat / disabled

config.maxgroups = 8
config.showSolo = false     -- visible without group/raid
config.showParty = true    -- in group
config.unitGap = 10        -- gap between units
config.groupGap = 10
config.unitGrowth = "RIGHT" -- direction for adding new players in group. LEFT / RIGHT / TOP / BOTTOM
config.groupGrowth = "TOP" -- new groups direction. LEFT / RIGHT / TOP / BOTTOM
config.resize = { after = 27, to = 0.8 } -- = if number of players in raid exeeds 27 then resize to 0.8.   "config.resize = false" disables it
config.anchorpoint = "BOTTOMLEFT" -- anchor position relative to 1st unit of 1st group. if you want to grow frames to TOP and RIGHT it better be BOTTOMLEFT.
config.lockedOnStartUp = true
config.disableBlizzardParty = true

-- pets are broken

-- bells and whistles
config.enableIncomingHeals = true
config.enableTraceHeals = true
config.enableClickCasting = false
-- enable click casting support, activates ClickMacro function.
-- ClickMacro syntax is like usual macro, but don't forget [target=mouseover]
-- spell:<id> is an alias for localized spellname.
-- Unmodified left click is reserved for targeting by default.
-- Use helpers.BindTarget("shift 1") to change it. Syntax: any combination of "shift" "alt" "ctrl" and button number
config.useCombatLogFiltering = true
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
config.useQuickHealth = isHealer -- combat log event is faster than UNIT_HEALTH event.
                                         -- And that's what this lib does, allows you to see health updates more often/sooner.

config.SetupIndicators = {
    ["topleft"] =  { point = "TOPLEFT", size = 5, },
    ["topleft2"] =  { point = "TOPLEFT", size = 5, xOffset = 7},
    ["topleft3"] =  { point = "TOPLEFT", size = 5, yOffset = -7},
    ["topright"] =  { point = "TOPRIGHT", size = 7 },
    ["bottomright"] =  { point = "BOTTOMRIGHT", size = 8, },
    ["bottomleft"] =  { point = "BOTTOMLEFT", size = 4, },
    ["bottom"] =  { point = "BOTTOM", size = 7, },
    ["top"] =  { point = "TOP", size = 10, },
    ["left"] =  { point = "LEFT", size = 10, },
    
    ["border_right"] = { point = "RIGHT",  nobackdrop = true, xOffset = 4, init = function(self) self.width = 2; self.height = InjectorUserConfig.height+8; end },
    ["border_left"] = { point = "LEFT", xOffset = -4 , nobackdrop = true, init = function(self) self.width = 2; self.height = InjectorUserConfig.height+8; end },
    ["border_top"] = { point = "TOP", yOffset = 4 , nobackdrop = true, init = function(self) self.width = InjectorUserConfig.width+4; self.height = 2; end },
    ["border_bottom"] = { point = "BOTTOM", yOffset = -4   , nobackdrop = true, init = function(self) self.width = InjectorUserConfig.width+4; self.height = 2; end },
}
-- so border actually is built from 4 indicators, you can use them separately
local BORDER = { "border_left", "border_right", "border_top", "border_bottom" } -- shortcut, e.g. indicator = BORDER

config.SetupIcons = {
    ["raidicon"] = { point = "BOTTOMLEFT", size = 24, xOffset = -9, yOffset = -9, alpha = 0.6 },   --special icon for raid targets
    ["center"] = { point = "CENTER", size = 24, alpha = 0.6, omnicc = false, stacktext = true },
}
--customizing stack label: stacktext = { font = [[Interface\AddOns\Injector\ClearFont.ttf]], size = 10, flags = "OUTLINE", color = {1,0,0} },

config.TargetStatus = { name = "Target", type = "HELPFUL", indicator = BORDER, color = {1,0.7,0.7}, priority = 65 }
config.IncomingHealStatus = { name = "IncomingHeal", type = "HELPFUL", indicator = { "bottomleft" },  color = { 0, 1, 0}, priority = 60 }
config.AggroStatus = { name = "Aggro", type = "HARMFUL", indicator = { "bottomleft" },  color = { 0.7, 0, 0} } -- config.AggroStatus = false will disable aggro monitoring at all
config.ReadyCheck = { name = "Readycheck", type = "HELPFUL", priority = 90, indicator = { "top" },  stackcolor =   {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { 1, 1, 0},
                                                                        }}
config.MainTankStatus = { name = "MainTank", type = "HELPFUL", priority = 60, indicator = BORDER, color = {0.6,0.6,0.6} }


config.Colors = {
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
    A{ id = 21562, type = "HELPFUL", indicator = { "topleft" }, color = { 1, 1, 1} } --Power Word: Fortitude
    A{ id = 27683, type = "HELPFUL", indicator = { "topleft2" }, color = { 102/255 , 0, 187/255 } } --Shadow Protection
    
    --A{ id = 1706,  type = "HELPFUL", indicator = { "topright" }, color = { 1, 1, 1}, priority = 60, showDuration = true } --Levitate
    
    A{ id = 139,   type = "HELPFUL", indicator = { "bottomright" }, pulse = true, color = { 0, 1, 0}, showDuration = true, isMine = true } --Renew
    A{ id = 88682, type = "HELPFUL", indicator = { "bottom" }, pulse = true, priority = 70, color = {1,0.7,0.5}, showDuration = true, isMine = true } --Aspire
    A{ id = 7001,  type = "HELPFUL", indicator = { "bottom" }, pulse = true, priority = 72, color = { 1, 1, 0}, showDuration = true, isMine = true } --Lightwell
    A{ id = 17,    type = "HELPFUL", indicator = { "top" }, color = { 1, 1, 0}, showDuration = true } --Power Word: Shield
    A{ id = 6788,  type = "HARMFUL", indicator = { "top" }, color = { 0.6, 0, 0}, showDuration = true, priority = 40 } --Weakened Soul
    A{ id = 33076, type = "HELPFUL", indicator = { "topright" }, priority = 90, stackcolor =   {
                                                                            [1] = { 0.4, 0, 0},
                                                                            [2] = { 0.7, 0, 0},
                                                                            [3] = { 1, 0, 0},
                                                                            [4] = { 1, 0.3, 0.3},
                                                                            [5] = { 1, 0.6, 0.6},
                                                                            [6] = { 1, 0.9, 0.9}, -- Tier7 set bonus
                                                                        }} --Prayer of Mending
                                                                        
    Trace{id = 34861, type = "HEAL", indicator = { "topright" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Circle of Healing
    Trace{id = 33076, type = "HEAL", indicator = { "topright" }, color = { 1, 0.6, 0.6}, fade = 1.5, priority = 97 } -- PoM Trace
                                                                        
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(2061),unit) == 1) end
            --// Use Flash Heal for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.
    
    DT("Magic", { indicator = { "bottom" }, color = { 0.2, 0.6, 1}, priority = 81 })
    DT("Disease", { indicator = { "bottom" }, color = { 0.6, 0.4, 0} })

    --helpers.BindTarget("shift 1")     -- Override target binding. Syntax: any combination of "shift" "alt" "ctrl" and button number
    ClickMacro[[
        /cast [target=mouseover,btn:2,mod:alt] spell:17; [target=mouseover,btn:2] spell:139; [target=mouseover,btn:1,mod:alt] spell:139;
    ]] -- Default Example: PW:S (id 17) on Alt+RMB, Renew (id 139) on RMB
end

if playerClass == "WARLOCK" then
    A{ id = 20707, type = "HELPFUL", indicator = { "topleft" }, color = { 180/255, 0, 1 }, priority = 81 } --Soulstone Resurrection
    --A{ id = 6307,  type = "HELPFUL", indicator = { "topleft" }, color = { 1, 0, 0 }, priority = 81 } --Blood Pact
    --A{ id = 54424, type = "HELPFUL", indicator = { "topleft" }, color = { .6 , .6, 1 } } --Fel Intelligence
end
if playerClass == "PALADIN" then
    A{ id = 20217, type = "HELPFUL", indicator = { "topleft" }, color = { .6 , .3, 1} } --Blessing of Kings
    
    A{ id = 19740, type = "HELPFUL", indicator = { "topleft2" }, color = { 1 , 0.5, 0.3} } --Blessing of Might
    
    A{ id = 53563, type = "HELPFUL", indicator = { "top" }, showDuration = true,
                                                                            isMine = true,
                                                                            color = { 0,1,0 },
                                                                            --foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        }
    
    Trace{id = 54968, type = "HEAL", indicator = { "topright" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Glyph of Holy Light
    
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(635),unit) == 1) end
            --// Use Holy Light for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Magic", { indicator = { "bottom" }, color = { 0.2, 0.6, 1} })
    DT("Disease", { indicator = { "bottom" }, color = { 0.6, 0.4, 0} })
    DT("Poison", { indicator = { "bottom" }, color = { 0, 0.6, 0} })
    
    --helpers.BindTarget("shift 1")     -- Override target binding. Syntax: any combination of "shift" "alt" "ctrl" and button number
    ClickMacro[[
        /cast [target=mouseover,btn:2,mod:alt] spell:53563; [target=mouseover,btn:2] spell:19750;
    ]] -- Default Example: Beacon of Light (id 53563) on Alt+RMB, Flash of Light (id 19750) on RMB
    
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
    --Trace{id = 73921, type = "HEAL", indicator = { "topright" }, color = { 0.6, 0.6, 1}, fade = 0.4, priority = 95 } -- Healing Rain
    --Trace{id = 51558, type = "HEAL", indicator = { "topright" }, color = { 1, 0.6, 0.6 }, fade = 0.7, priority = 95 } -- Ancestral Awakening
                                                                        
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(331),unit) == 1) end
            --// Use Healing Wave for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Magic", { indicator = { "bottom" }, color = { 0.2, 0.6, 1} })
    DT("Curse", { indicator = { "bottom" }, color = { 0.6, 0, 1} })
    
    ClickMacro[[
        /cast [target=mouseover,btn:2,mod:alt] spell:974; [target=mouseover,btn:2] spell:61295;
    ]] -- Default Example: Earth Shield (id 974) on Alt+RMB, Riptide (id 61295) on RMB
end
if playerClass == "DRUID" then
    A{ id = 1126,  type = "HELPFUL", indicator = { "topleft" }, color = { 235/255 , 145/255, 199/255} } --Mark of the Wild
    
    A{ id = 774,   type = "HELPFUL", indicator = { "bottomright" }, pulse = true, color = { 1, 0.2, 1}, showDuration = true, isMine = true } --Rejuvenation
    A{ id = 8936,  type = "HELPFUL", indicator = { "topright" }, priority = 82, color = { 198/255, 233/255, 80/255}, showDuration = true, isMine = true } --Regrowth
    A{ id = 33763, type = "HELPFUL", indicator = { "top" }, showDuration = true, isMine = true, stackcolor = {
                                                                            [1] = { 0, 0.8, 0},
                                                                            [2] = { 0.2, 1, 0.2},
                                                                            [3] = { 0.5, 1, 0.5},
                                                                        }} --Lifebloom
    A{ id = 48438, type = "HELPFUL", indicator = { "topright" }, color = { 0.4, 1, 0.4}, showDuration = true, isMine = true } --Wild Growth
    
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(774),unit) == 1) end
            --// Use Rejuvenation for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Poison", { indicator = { "bottom" }, color = { 0, 0.6, 0} })
    DT("Curse", { indicator = { "bottom" }, color = { 0.6, 0, 1} })
    DT("Magic", { indicator = { "bottom" }, color = { 0.2, 0.6, 1} })
    
    --helpers.BindTarget("shift 1")     -- Override target binding. Syntax: any combination of "shift" "alt" "ctrl" and button number
    ClickMacro[[
        /cast [target=mouseover,btn:2,mod:alt] spell:8936; [target=mouseover,btn:2] spell:774
    ]] -- Default Example: Regrowth (id 8936) on Alt+RMB, Rejuvenation (id 774) on RMB
end
if playerClass == "MAGE" then
    A{ id = 1459,  type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Arcane Intellect
    A{ id = 23028, type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Arcane Brilliance
    A{ id = 61316, type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Dalaran Brilliance
    A{ id = 61024, type = "HELPFUL", indicator = { "topleft" }, color = { .4 , .4, 1} } --Dalaran Intellect
    A{ id = 54648, type = "HELPFUL", indicator = { "topleft2" }, color = { 180/255, 0, 1 }, isMine = true } --Focus Magic
    
    DT("Curse", { indicator = { "bottom" }, color = { 0.6, 0, 1} })
end