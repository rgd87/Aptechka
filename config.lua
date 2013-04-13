local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID")
local A = helpers.AddAura
local DT = helpers.AddDispellType
local D = helpers.AddDebuff
local ClickMacro = helpers.ClickMacro
local Trace = helpers.AddTrace
AptechkaDefaultConfig = {}
AptechkaDefaultConfig.IndicatorAuras = {}
local config = AptechkaDefaultConfig

config.skin = "GridSkin"
config.scale = 1
--config.width = 50 -- defined in skin module
--config.height = 50
config.cropNamesLen = 7  -- maximum amount of characters in unit name
config.raidIcons = true
config.showSolo = true     -- visible without group/raid
config.showParty = true    -- in group
config.unitGap = 10       -- gap between units
config.unitGrowth = "RIGHT" -- direction for adding new players in group. LEFT / RIGHT / TOP / BOTTOM
config.groupGrowth = "TOP"
config.groupGap = 10
config.unlocked = false  -- when addon initially loaded
config.disableBlizzardParty = true
config.hideBlizzardRaid = true
config.useGroupAnchors = false -- use separate anchors for each group
config.layouts = {  -- works ONLY with group anchors disabled.
                    -- layout functions are checked from first to last. function should return true to be accepted.
    function(self, members, role, spec)
        if role == "HEALER" and members > 27 then --resize after 27 for healers
            self:SetScale(.7); return true
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
--Pet group is always on separate anchor. Use /apt unlockall.
--A maximum of 5 pets can be displayed. 
--You also can use /apt createpets command, it creates pet group on the fly

config.registerForClicks = { "AnyUp" }
config.enableIncomingHeals = true
config.incomingHealThreshold = 15000
config.incomingHealIgnorePlayer = false
config.enableTraceHeals = true
config.enableVehicleSwap = true
config.enableAbsorbBar = true
config.enableClickCasting = false
-- if for some reason you don't want to use Clique you can
-- enable native click casting support here, it activates ClickMacro function.
-- ClickMacro syntax is like usual macro, but don't forget [@mouseover] for every command
-- spell:<id> is an alias for localized spellname.
-- Unmodified left click is reserved for targeting by default.
-- Use helpers.BindTarget("shift 1") to change it. Syntax: any combination of "shift" "alt" "ctrl" and button number

-- config.useCombatLogFiltering = false
-- useCombatLogFiltering provides a huge perfomance boost over default behavior, which would be to listen only to UNIT_AURA event.
-- UNIT_AURA doesn't tell what exactly changed and every time addon had to scan current buffs/debuffs,
-- in raid combat unit_aura sometimes fired up to 8 times per second for each member with all the stacking trinkets and procs.
-- useCombatLogFiltering option moves this process mainly to combat log, where we can see what spell was updated.
-- Only if it's one of OUR spells from assigntos it will update buff data for this unit.
-- The drawback is that it only works in combat log range, but it's big enough, and there's a fallback on throttled unit_aura (updates every 5s) for out of range units.
-- On lich king there was an issue, and maybe it's still present, that necrotic plague removal event didn't appear in combat log
-- and that caused glitches with boss debuff assignto. But that's a rare blizzard side bug.
-- Dispel idicators still work from unit_aura, so you'll see plague regardless as disease if you can dispel it. Necrotic plague removed from default loadables.lua setup.
config.useCombatLogHealthUpdates = isHealer

config.TargetStatus = { name = "Target", assignto = { "border" }, color = {1,0.7,0.7}, priority = 65 }
config.AggroStatus = { name = "Aggro", assignto = { "raidbuff" },  color = { 0.7, 0, 0},priority = 55 }
config.ReadyCheck = { name = "Readycheck", priority = 90, assignto = { "spell3" }, stackcolor = {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { .8, .6, 0},
                                                                        }}
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = { "border" }, color = {0.6,0.6,0.6} }
config.DeadStatus = { name = "DEAD", assignto = { "text2","health","power" }, color = {.05,.05,.05}, textcolor = {0,1,0}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "GHOST", assignto = { "text2","health","power" }, color = {.05,.05,.05},  textcolor = {0,1,0}, text = "GHOST", priority = 62}
config.OfflineStatus = { name = "OFFLINE", assignto = { "text2","health","power" }, color = {.15,.15,.15}, textcolor = {0,1,0}, text = "OFFLINE",  priority = 70}
config.IncomingHealStatus = { name = "IncomingHeal", assignto = { "text2" }, inchealtext = true, color = { 0, 1, 0}, priority = 15 }
config.HealthDificitStatus = { name = "HPD", assignto = { "healthtext" }, healthtext = true, color = { 54/255, 201/255, 99/256 }, priority = 10 }
-- config.ResurrectStatus = { name = "Resurrection", assignto = { "icon" }, texture = "Interface\\Icons\\spell_holy_resurrection", priority = 80 } -- disabled, buggy
config.UnitNameStatus = { name = "UnitName", assignto = { "text1" }, nametext = true, classcolor = true, priority = 20 }
config.HealthBarColor = { name = "HealthBar", assignto = { "health" }, color = {1, .3, .3}, classcolor = true, priority = 20 }
config.PowerBarColor = { name = "PowerBar", assignto = { "power" }, color = {.5,.5,1}, priority = 20 }
config.OutOfRangeStatus = { name = "OOR", assignto = { "self" }, color = {0.5,0.5,0.5}, alpha = 0.3, text = "OOR", priority = 50 }
config.InVehicleStatus = { name = "InVehicle", assignto = { "border" }, color = {0.3,1,0.3}, priority = 21 }
config.LOSStatus = { name = "OutOfSight", assignto = { "spell2", "dispel" }, color = {1,0.1,0.1}, priority = 95, fade = 1.0 }

-- default priority is 80

D(1, { name = "DI1", assignto = { "dicon1" }, pulse = true, color = { 0, 1, 0}, showDuration = true })
D(2, { name = "DI2", assignto = { "dicon2" }, pulse = true, color = { 0, 1, 0}, showDuration = true })
D(3, { name = "DI3", assignto = { "dicon3" }, pulse = true, color = { 0, 1, 0}, showDuration = true })

function DispelTypes(str)
    str = str:upper()
    if str:find("MAGIC") then DT("Magic", { assignto = { "dispel" }, color = { 0.2, 0.6, 1}, priority = 6 }) end
    if str:find("CURSE") then DT("Curse", { assignto = { "dispel" }, color = { 0.6, 0, 1}, priority = 5 }) end
    if str:find("POISON") then DT("Poison", { assignto = { "dispel" }, color = { 0, 0.6, 0}, priority = 4 }) end
    if str:find("DISEASE") then DT("Disease", { assignto = { "dispel" }, color = { 0.6, 0.4, 0}, priority = 3}) end
end

if playerClass == "PRIEST" then
        -- long buffs
    --A{ id = 21562, type = "HELPFUL", assignto = { "raidbuff" }, color = { 1, 1, 1}, isMissing = true } --Power Word: Fortitude
    
    A{ id = 139,   type = "HELPFUL", assignto = { "bar1" }, pulse = true, color = { 0, 1, 0}, showDuration = true, isMine = true } --Renew
    A{ id = 88684, type = "HELPFUL", assignto = { "spell3" }, priority = 75, color = {0.5,0.7,1}, showDuration = true, isMine = true } --Serenity
    A{ id = 77613, type = "HELPFUL", assignto = { "spell3" }, priority = 75, showDuration = true, stackcolor = {
                                                                            [1] = {0.4,0.5,1},
                                                                            [2] = {0.5,0.7,1},
                                                                            [3] = {0.7,0.8,1},
                                                                        }} --Grace
    A{ id = 7001,  type = "HELPFUL", assignto = { "bar1" }, priority = 62, color = { 1, 1, 0}, showDuration = true, isMine = true } --Lightwell
    A{ id = 126154,type = "HELPFUL", assignto = { "bar1" }, priority = 62, color = { 1, 1, 0}, showDuration = true, isMine = true } --Lightspring
    A{ id = 17,    type = "HELPFUL", assignto = { "spell2" }, color = { 1, .85, 0}, showDuration = true } --Power Word: Shield
    A{ id = 114908,type = "HELPFUL", assignto = { "bar1" }, priority = 82, color = { 188/255, 37/255, 186/255 }, foreigncolor = { 164/255, 125/255, 169/255}, showDuration = true } --Spirit Shell absorb
    A{ id = 6788,  type = "HARMFUL", assignto = { "spell2" }, color = { 0.6, 0, 0}, staticDuration = 15, showDuration = true, priority = 40 } --Weakened Soul
    A{ id = 41635, type = "HELPFUL", assignto = { "spell3" }, priority = 70, foreigncolor = { 164/255, 125/255, 169/255 },
                                                                        stackcolor =   {
                                                                            [1] = { 1, 0, 0},
                                                                            [2] = { 1, 0, 102/255},
                                                                            [3] = { 1, 0, 190/255},
                                                                            [4] = { 204/255, 0, 1},
                                                                            [5] = { 108/255, 0, 1},
                                                                        }} --Prayer of Mending
                                                                        -- stackcolor =   {
                                                                        --     [1] = { .8, 0, 0},
                                                                        --     [2] = { 1, 0, 0},
                                                                        --     [3] = { 1, .2, .2},
                                                                        --     [4] = { 1, .4, .4},
                                                                        --     [5] = { 1, .6, .6},
                                                                        -- }} --Prayer of Mending
    
    -- Trace{id = 94472, type = "HEAL", minamount = 10000, assignto = { "spell3" }, color = { .2, 1, .2}, fade = .5, priority = 90 } -- Atonement
    Trace{id = 34861, type = "HEAL", assignto = { "spell3" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Circle of Healing
    Trace{id = 33076, type = "HEAL", assignto = { "spell3" }, color = { .3, 1, .3}, fade = 1.5, priority = 97 } -- PoM Trace
                                                                        
    -- config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(2061),unit) == 1) end
            --// Use Flash Heal for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.
    
    DispelTypes("MAGIC|DISEASE")
end

if playerClass == "MONK" then
    A{ id = 119611, type = "HELPFUL", assignto = { "spell2" }, color = {38/255, 221/255, 163/255} } --Renewing Mist
    A{ id = 132120, type = "HELPFUL", assignto = { "spell3" }, showDuration = true, color = {38/255, 221/255, 163/255}, priority = 92 } --Enveloping Mist

    A{ id = 115175, type = "HELPFUL", assignto = { "bar1" }, showDuration = true, color = { 0, .8, 0}, priority = 92 } --Soothing Mist

    A{ id = 124081, type = "HELPFUL", assignto = { "spell3" }, showDuration = true, color = {0.7,0.8,1}, priority = 88 } --Zen Sphere

    Trace{id = 115464, type = "HEAL", assignto = { "spell3" }, color = { 1, .7, .2}, fade = 0.7, priority = 96 } -- Light of Dawn
    Trace{id = 116670, type = "HEAL", assignto = { "spell3" }, color = { 1, .7, .2}, fade = 0.7, priority = 96 } -- Light of Dawn

    -- config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(115450),unit) == 1) end
            --// Use Detox for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DispelTypes("MAGIC|DISEASE|POISON")
end

if playerClass == "WARLOCK" then
    A{ id = 20707, type = "HELPFUL", assignto = { "raidbuff" }, color = { 180/255, 0, 1 }, priority = 81 } --Soulstone Resurrection
end

if playerClass == "PALADIN" then
    --A{ id = 20217, type = "HELPFUL", assignto = { "raidbuff" }, color = { .6 , .3, 1}, isMissing = true } --Blessing of Kings
    --A{ id = 19740, type = "HELPFUL", assignto = { "raidbuff" }, color = { 1 , 0.5, 0.3}, isMissing = true } --Blessing of Might
    A{ id = 114163, type = "HELPFUL", assignto = { "spell3" }, color = { 1, .8, 0}, priority = 70, showDuration = true, isMine = true } --Eternal Flame
    A{ id =114917,  type = "HELPFUL", assignto = { "bar1" }, showDuration = true, isMine = true, color = { 1 , .9, 0} } --Stay of Execution
    A{ id = 53563, type = "HELPFUL", assignto = { "raidbuff" }, showDuration = true,
                                                                            isMine = true,
                                                                            color = { 0,.9,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon
                                                                        
    Trace{id = 85222, type = "HEAL", assignto = { "spell3" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Light of Dawn
    -- Trace{id = 82327, type = "HEAL", assignto = { "spell3" }, color = { .8, .5, 1}, fade = 0.7, priority = 96 } -- Holy Radiance
    -- Trace{id =121129, type = "HEAL", assignto = { "spell3" }, color = { 1, .5, 0}, fade = 0.7, priority = 96 } -- Daybreak

    
    -- config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(635),unit) == 1) end
            --// Use Holy Light for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.
    -- ClickMacro[[
    --     /cast [@mouseover,btn:2,mod:alt] spell:53563; [@mouseover,btn:2] spell:19750;
    -- ]] -- Beacon of Light (id 53563) Flash of Light (id 19750)

    DispelTypes("MAGIC|DISEASE|POISON")
end
if playerClass == "SHAMAN" then
    -- config.useCombatLogFiltering = false -- Earth Shield got problems with combat log
    
    A{ id = 61295,  type = "HELPFUL", assignto = { "bar1" }, showDuration = true, isMine = true, color = { 0.2 , 0.2, 1} } --Riptide    
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
    Trace{id = 52042, type = "PERIODIC_HEAL", assignto = { "spell3" }, color = { 0.4 , 0.4, 1}, fade = 0.7, priority = 93 } -- Chain Heal
                                                                        
    Trace{id = 1064, type = "HEAL", assignto = { "spell3" }, color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Chain Heal
    --Trace{id = 73921, type = "HEAL", assignto = { "spell3" }, color = { 0.6, 0.6, 1}, fade = 0.4, priority = 95 } -- Healing Rain
    Trace{id = 52752, type = "HEAL", assignto = { "spell3" }, color = { 1, 0.6, 0.6 }, fade = 0.7, priority = 95 } -- Ancestral Awakening
                                                                        
    -- config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(8004),unit) == 1) end
            --// Use Healing Surge for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.


    DispelTypes("MAGIC|CURSE")
end
if playerClass == "DRUID" then
    --A{ id = 1126,  type = "HELPFUL", assignto = { "raidbuff" }, color = { 235/255 , 145/255, 199/255}, isMissing = true } --Mark of the Wild
    
    A{ id = 102351, type = "HELPFUL", assignto = { "spell3" }, priority = 70, color = {38/255, 221/255, 163/255} }
    A{ id = 774,   type = "HELPFUL", assignto = { "bar1"}, pulse = true, color = { 1, 0.2, 1}, showDuration = true, isMine = true } --Rejuvenation
    --A{ id = 8936,  type = "HELPFUL", assignto = { "topright" }, priority = 82, color = { 198/255, 233/255, 80/255}, showDuration = true, isMine = true } --Regrowth
    A{ id = 33763, type = "HELPFUL", assignto = { "spell2","text3" }, showDuration = true, isMine = true, stackcolor = {
                                                                            [1] = { 0, 0.8, 0},
                                                                            [2] = { 0.2, 1, 0.2},
                                                                            [3] = { 0.5, 1, 0.5},
                                                                        }} --Lifebloom
    A{ id = 48438, type = "HELPFUL", assignto = { "spell3" }, color = { 0.4, 1, 0.4}, priority = 70, showDuration = true, isMine = true } --Wild Growth
    
    -- config.UnitInRangeFunc = function(unit) return (IsSpellInRange(GetSpellInfo(774),unit) == 1) end
            --// Use Rejuvenation for range check. Usual UnitInRange is about 38yd, not 41, tho it's probably good to have that margin. Disabled by default.

    DispelTypes("MAGIC|CURSE|POISON")
end
if playerClass == "MAGE" then
    --A{ id = 1459,  type = "HELPFUL", assignto = { "spell2" }, color = { .4 , .4, 1}, priority = 50 } --Arcane Intellect
    --A{ id = 61316, type = "HELPFUL", assignto = { "spell2" }, color = { .4 , .4, 1}, priority = 50 } --Dalaran Intellect
    --A{ id = 54648, type = "HELPFUL", assignto = { "spell2" }, color = { 180/255, 0, 1 }, priority = 60, isMine = true } --Focus Magic
    
    DispelTypes("CURSE")
end
-- if not isHealer or playerClass == "PALADIN" then
    -- config.redirectPowerBar = "spell1"
-- end

config.autoload = {
    "HealingReduction",
    "TankCooldowns"
}