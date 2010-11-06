local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID")
local A = helpers.AddAura
local DT = helpers.AddDispellType
local ClickMacro = helpers.ClickMacro
local Trace = helpers.AddTrace
AptechkaDefaultConfig = {}
local config = AptechkaDefaultConfig


config.skin = "GridSkin"
config.cropNamesLen = 7  -- maximum amount of characters in unit name
config.raidIcons = true
config.maxgroups = 8
config.showSolo = false     -- visible without group/raid
config.showParty = true    -- in group
config.unitGap = 10       -- gap between units
config.unitGrowth = "RIGHT" -- direction for adding new players in group. LEFT / RIGHT / TOP / BOTTOM
config.groupGrowth = "TOP"
config.groupGap = 10
config.unlocked = false  -- when addon initially loaded
config.disableBlizzardParty = true
config.useGroupAnchors = false
config.resize = { after = 27, to = 0.8 } -- ONLY WORKS with group anchors disabled. If number of players in raid exeeds 27 then resize to 0.8.   "config.resize = false" disables it


config.enableIncomingHeals = true
config.incomingHealThreshold = 3000
config.enableTraceHeals = true
config.enableClickCasting = false
-- if for some reason you don't want to use Clique you can
-- enable native click casting support here, it activates ClickMacro function.
-- ClickMacro syntax is like usual macro, but don't forget [@mouseover] for every command
-- spell:<id> is an alias for localized spellname.
-- Unmodified left click is reserved for targeting by default.
-- Use helpers.BindTarget("shift 1") to change it. Syntax: any combination of "shift" "alt" "ctrl" and button number
config.useCombatLogFiltering = true
-- useCombatLogFiltering provides a huge perfomance boost over default behavior, which would be to listen only to UNIT_AURA event.
-- UNIT_AURA doesn't tell what exactly changed and every time addon had to scan current buffs/debuffs,
-- in raid combat unit_aura sometimes fired up to 8 times per second for each member with all the stacking trinkets and procs.
-- useCombatLogFiltering option moves this process mainly to combat log, where we can see what spell was updated.
-- Only if it's one of OUR spells from assigntos it will update buff data for this unit.
-- The drawback is that it only works in combat log range, but it's big enough, and there's a fallback on throttled unit_aura (updates every 5s) for out of range units.
-- On lich king there was an issue, and maybe it's still present, that necrotic plague removal event didn't appear in combat log
-- and that caused glitches with boss debuff assignto. But that's a rare blizzard side bug.
-- Dispel idicators still work from unit_aura, so you'll see plague regardless as disease if you can dispel it. Necrotic plague removed from default loadables.lua setup.

-- libs
config.useQuickHealth = isHealer -- combat log event is faster than UNIT_HEALTH event.
                                         -- And that's what this lib does, allows you to see health updates more often/sooner.

                                         
                                         
                                         
config.TargetStatus = { name = "Target", assignto = { "border" }, color = {1,0.7,0.7}, priority = 65 }
config.AggroStatus = { name = "Aggro", assignto = { },  color = { 0.7, 0, 0},priority = 55 }
config.ReadyCheck = { name = "Readycheck", priority = 90, assignto = { "spell3" }, stackcolor = {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { 1, 1, 0},
                                                                        }}
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = { "border" }, color = {0.6,0.6,0.6} }
config.DeadStatus = { name = "DEAD", assignto = { "text2","health","power" }, color = {.2,.2,.2}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "GHOST", assignto = { "text2","health","power" }, color = {.2,.2,.2}, text = "GHOST", priority = 62}
config.OfflineStatus = { name = "OFFLINE", assignto = { "text2","health","power" }, color = {.2,.2,.2}, text = "OFFLINE",  priority = 70}
config.IncomingHealStatus = { name = "IncomingHeal", assignto = { "text2" }, inchealtext = true,  color = { 0, 1, 0}, priority = 15 }
config.HealthDificitStatus = { name = "HPD", assignto = { "healthtext" }, healthtext = true, priority = 80 }
config.UnitNameStatus = { name = "UnitName", assignto = { "text1" }, nametext = true, classcolor = true, priority = 20 }
config.HealthBarColor = { name = "HealthBar", assignto = { "health" }, color = {1, .3, .3}, classcolor = true, priority = 20 }
config.PowerBarColor = { name = "PowerBar", assignto = { "power" }, color = {.5,.5,1}, priority = 20 }
config.OutOfRangeStatus = { name = "OOR", assignto = { "self" }, color = {0.5,0.5,0.5}, alpha = 0.3, text = "OOR", priority = 50 }
config.InVehicleStatus = { name = "InVehicle", assignto = { "border" }, color = {0.3,1,0.3}, priority = 21 }

-- default priority is 80

if playerClass == "PRIEST" then
        -- long buffs
    --A{ id = 21562, type = "HELPFUL", assignto = { "raidbuff" }, color = { 1, 1, 1}, isMissing = true } --Power Word: Fortitude
    --A{ id = 27683, type = "HELPFUL", assignto = { "raidbuff" }, color = { 102/255 , 0, 187/255 }, isMissing = true } --Shadow Protection
    
    A{ id = 139,   type = "HELPFUL", assignto = { "spell1" }, pulse = true, color = { 0, 1, 0}, showDuration = true, isMine = true } --Renew
    A{ id = 88682, type = "HELPFUL", assignto = { "spell2" }, pulse = true, priority = 70, color = {1,0.7,0.5}, showDuration = true, isMine = true } --Aspire
    A{ id = 7001,  type = "HELPFUL", assignto = { "spell2" }, pulse = true, priority = 72, color = { 1, 1, 0}, showDuration = true, isMine = true } --Lightwell
    A{ id = 17,    type = "HELPFUL", assignto = { "spell2" }, color = { 1, 1, 0}, showDuration = true } --Power Word: Shield
    A{ id = 6788,  type = "HARMFUL", assignto = { "spell2" }, color = { 0.6, 0, 0}, staticDuration = 15, showDuration = true, priority = 40 } --Weakened Soul
    A{ id = 33076, type = "HELPFUL", assignto = { "spell3" }, priority = 70, stackcolor =   {
                                                                            [1] = { 1, 0, 0},
                                                                            [2] = { 1, .2, .2},
                                                                            [3] = { 1, .4, .4},
                                                                            [4] = { 1, .6, .6},
                                                                            [5] = { 1, .6, .6},
                                                                        }} --Prayer of Mending
                                                                        
    Trace{id = 34861, type = "HEAL", assignto = { "spell3" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Circle of Healing
    Trace{id = 33076, type = "HEAL", assignto = { "spell3" }, color = { 1, 0.6, 0.6}, fade = 1.5, priority = 97 } -- PoM Trace
                                                                        
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(2061),unit) == 1) end
            --// Use Flash Heal for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.
    
    DT("Magic", { assignto = { "dispel" }, color = { 0.2, 0.6, 1}, priority = 81 })
    DT("Disease", { assignto = { "dispel" }, color = { 0.6, 0.4, 0} })
end

if playerClass == "WARLOCK" then
    A{ id = 20707, type = "HELPFUL", assignto = { "spell2" }, color = { 180/255, 0, 1 }, priority = 81 } --Soulstone Resurrection
    A{ id = 85767, type = "HELPFUL", assignto = { "spell1" }, color = { 180/255, 0.5, 1 }, priority = 83 } --Dark Intent
end
if playerClass == "PALADIN" then
    --A{ id = 20217, type = "HELPFUL", assignto = { "raidbuff" }, color = { .6 , .3, 1}, isMissing = true } --Blessing of Kings
    --A{ id = 19740, type = "HELPFUL", assignto = { "raidbuff" }, color = { 1 , 0.5, 0.3}, isMissing = true } --Blessing of Might
    
    A{ id = 53563, type = "HELPFUL", assignto = { "spell2" }, showDuration = true,
                                                                            isMine = true,
                                                                            color = { 0,1,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        }
                                                                        
    Trace{id = 85222, type = "HEAL", assignto = { "spell3" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Light of Dawn
    
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(635),unit) == 1) end
            --// Use Holy Light for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.
    ClickMacro[[
        /cast [@mouseover,btn:2,mod:alt] spell:53563; [@mouseover,btn:2] spell:19750;
    ]] -- Beacon of Light (id 53563) Flash of Light (id 19750)

    DT("Magic", { assignto = { "dispel" }, color = { 0.2, 0.6, 1}, priority = 82 })
    DT("Disease", { assignto = { "dispel" }, color = { 0.6, 0.4, 0}, priority = 81 })
    DT("Poison", { assignto = { "dispel" }, color = { 0, 0.6, 0} })    
end
if playerClass == "SHAMAN" then
    A{ id = 61295,  type = "HELPFUL", assignto = { "spell1" }, showDuration = true, isMine = true, color = { 0.2 , 0.2, 1} } --Riptide
    A{ id = 974,    type = "HELPFUL", assignto = { "spell2" }, showDuration = true,
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
                                                                            [9] = {.4, 1, .4},
                                                                        },
                                                                        foreigncolor = {0,0,.5}, } --Earth Shield
                                                                        
    Trace{id = 1064, type = "HEAL", assignto = { "spell3" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Chain Heal
    --Trace{id = 73921, type = "HEAL", assignto = { "spell3" }, color = { 0.6, 0.6, 1}, fade = 0.4, priority = 95 } -- Healing Rain
    Trace{id = 52752, type = "HEAL", assignto = { "spell3" }, color = { 1, 0.6, 0.6 }, fade = 0.7, priority = 95 } -- Ancestral Awakening
                                                                        
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(331),unit) == 1) end
            --// Use Healing Wave for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Magic", { assignto = { "dispel" }, color = { 0.2, 0.6, 1}, priority = 82 })
    DT("Curse", { assignto = { "dispel" }, color = { 0.6, 0, 1} })
end
if playerClass == "DRUID" then
    --A{ id = 1126,  type = "HELPFUL", assignto = { "raidbuff" }, color = { 235/255 , 145/255, 199/255}, isMissing = true } --Mark of the Wild
    
    A{ id = 774,   type = "HELPFUL", assignto = { "spell1"}, pulse = true, color = { 1, 0.2, 1}, showDuration = true, isMine = true } --Rejuvenation
    --A{ id = 8936,  type = "HELPFUL", assignto = { "topright" }, priority = 82, color = { 198/255, 233/255, 80/255}, showDuration = true, isMine = true } --Regrowth
    A{ id = 33763, type = "HELPFUL", assignto = { "spell2","text3" }, showDuration = true, isMine = true, stackcolor = {
                                                                            [1] = { 0, 0.8, 0},
                                                                            [2] = { 0.2, 1, 0.2},
                                                                            [3] = { 0.5, 1, 0.5},
                                                                        }} --Lifebloom
    A{ id = 48438, type = "HELPFUL", assignto = { "spell3" }, color = { 0.4, 1, 0.4}, priority = 70, showDuration = true, isMine = true } --Wild Growth
    
    --config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(774),unit) == 1) end
            --// Use Rejuvenation for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DT("Poison",{ assignto = { "dispel" }, color = { 0, 0.6, 0},priority = 80 })
    DT("Curse", { assignto = { "dispel" }, color = { 0.6, 0, 1}, priority = 81 })
    DT("Magic", { assignto = { "dispel" }, color = { 0.2, 0.6, 1}, priority = 82 })
end
if playerClass == "MAGE" then
    --A{ id = 1459,  type = "HELPFUL", assignto = { "spell2" }, color = { .4 , .4, 1}, priority = 50 } --Arcane Intellect
    --A{ id = 61316, type = "HELPFUL", assignto = { "spell2" }, color = { .4 , .4, 1}, priority = 50 } --Dalaran Intellect
    A{ id = 54648, type = "HELPFUL", assignto = { "spell2" }, color = { 180/255, 0, 1 }, priority = 60, isMine = true } --Focus Magic
    
    DT("Curse", { assignto = { "dispel" }, color = { 0.6, 0, 1} })
end
if not isHealer or playerClass == "PALADIN" then
    config.redirectPowerBar = "spell1"
end

A{ id = 871,   type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 90 } --Shield Wall
A{ id = 498,   type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 90 } --Divine Protection
A{ id = 48792, type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 90 } --Icebound Fortitude
A{ id = 33206, type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 90 } --Pain Suppression
 
A{ id = 55233, type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 88 } --Vampiric Blood
A{ id = 47788, type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 88 } --Guardian Spirit
    
A{ id = 12975, type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 86 } --Last Stand
A{ id = 61336, type = "HELPFUL", assignto = { "icon" }, showDuration = true, priority = 86 } --Survival Instincts