local _, helpers = ...
local _, playerClass = UnitClass("player")
local isHealer = (playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "DRUID" or playerClass == "MONK")
local A = helpers.AddAura
local DT = helpers.AddDispellType
local D = helpers.AddDebuff
local Trace = helpers.AddTrace
local config = AptechkaDefaultConfig

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
config.incomingHealThreshold = 300000
config.incomingHealIgnorePlayer = false
config.showPhaseIcon = true
config.displayRoles = true
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

config.TargetStatus = { name = "Target", assignto = "border", color = {1,0.7,0.7}, priority = 65 }
config.AggroStatus = { name = "Aggro", assignto = "raidbuff",  color = { 0.7, 0, 0},priority = 55 }
config.ReadyCheck = { name = "Readycheck", priority = 90, assignto = "spell3", stackcolor = {
                                                                            ['ready'] = { 0, 1, 0},
                                                                            ['notready'] = { 1, 0, 0},
                                                                            ['waiting'] = { .8, .6, 0},
                                                                        }}

config.LeaderStatus = { name = "Leader", priority = 59, assignto = "text3", color = {1,.8,.2}, text = "L" }
config.MainTankStatus = { name = "MainTank", priority = 60, assignto = "border", color = {0.6,0.6,0.6} }
config.DeadStatus = { name = "DEAD", assignto = { "text2","health","power" }, color = {.05,.05,.05}, textcolor = {0,1,0}, text = "DEAD", priority = 60}
config.GhostStatus = { name = "GHOST", assignto = { "text2","health","power" }, color = {.05,.05,.05},  textcolor = {0,1,0}, text = "GHOST", priority = 62}
config.CastingMassResStatus = { name = "MassResCast", assignto = { "icon", "text3" }, text = "MASSRES", color = { .4,1,.4 }, texture = "INTERFACE\\ICONS\\achievement_guildperk_massresurrection", priority = 96 }
config.ResIncomingStatus = { name = "ResIncoming", assignto = { "text2", "text3" }, text = "INC RES", color = { 1,1,.4 }, priority = 80 }
config.ResPendingStatus = { name = "ResPending", assignto = { "text2" }, text = "PENDING", color = { 0.6,0.6,1 }, priority = 82 }
config.OfflineStatus = { name = "OFFLINE", assignto = { "text2","health","power" }, color = {.15,.15,.15}, textcolor = {0,1,0}, text = "OFFLINE",  priority = 70}
config.IncomingHealStatus = { name = "IncomingHeal", assignto = "text2", inchealtext = true, color = { 0, 1, 0}, priority = 15 }
config.HealthDificitStatus = { name = "HPD", assignto = "healthtext", healthtext = true, color = { 54/255, 201/255, 99/256 }, priority = 10 }
config.UnitNameStatus = { name = "UnitName", assignto = "text1", nametext = true, classcolor = true, priority = 20 }
config.HealthBarColor = { name = "HealthBar", assignto = "health", color = {1, .3, .3}, classcolor = true, priority = 20 }
config.PowerBarColor = { name = "PowerBar", assignto = "power", color = {.5,.5,1}, priority = 20 }
config.OutOfRangeStatus = { name = "OOR", assignto = "self", color = {0.5,0.5,0.5}, alpha = 0.3, text = "OOR", priority = 50 }
config.PhasedOutStatus = { name = "Phased", assignto = "self", color = {0.5,0.5,0.5}, alpha = 0.4, text = "Phased", priority = 40 }
config.InVehicleStatus = { name = "InVehicle", assignto = "border", color = {0.3,1,0.3}, priority = 21 }
config.LOSStatus = { name = "OutOfSight", assignto = "spell2", color = {1,0.1,0.1}, priority = 95, fade = 1.0 }

-- default priority is 80

D(1, { name = "DI1", assignto = "dicon1", pulse = true, showDuration = true })
D(2, { name = "DI2", assignto = "dicon2", pulse = true, showDuration = true })
D(3, { name = "DI3", assignto = "dicon3", pulse = true, showDuration = true })
D(4, { name = "DI4", assignto = "dicon4", pulse = true, showDuration = true })

local function DispelTypes(str)
    str = str:upper()
    if str:find("MAGIC") then DT("Magic", { assignto = "dispel", color = { 0.2, 0.6, 1}, priority = 6 }) end
    if str:find("CURSE") then DT("Curse", { assignto = "dispel", color = { 0.6, 0, 1}, priority = 5 }) end
    if str:find("POISON") then DT("Poison", { assignto = "dispel", color = { 0, 0.6, 0}, priority = 4 }) end
    if str:find("DISEASE") then DT("Disease", { assignto = "dispel", color = { 0.6, 0.4, 0}, priority = 3}) end
end

local function RangeCheckBySpell(spellID)
    local spellName = GetSpellInfo(spellID)
    return function(unit)
        return (IsSpellInRange(spellName,unit) == 1)
    end
end



local tankCD = { type = "HELPFUL", assignto = "icon", global = true, showDuration = true, priority = 94}
local survivalCD = { type = "HELPFUL", assignto = "shieldicon", global = true, showDuration = true, priority = 90 }

-- MONK
A{ id = 122783, prototype = survivalCD } -- Diffuse Magic
A{ id = 122278, prototype = survivalCD } -- Dampen Harm
A{ id = 243435, prototype = survivalCD, priority = 91 } -- Fortifying Brew (Mistweaver)
A{ id = 125174, prototype = survivalCD, priority = 91 } -- Touch of Karma
A{ id = 115176, prototype = survivalCD } -- Zen Meditation
A{ id = 116849, prototype = tankCD, priority = 88 } --Life Cocoon
A{ id = 120954, prototype = tankCD } --Fortifying Brew (Brewmaster)

-- WARRIOR
A{ id = 184364, prototype = survivalCD } -- Enraged Regeneration
A{ id = 118038, prototype = survivalCD } -- Die by the Sword
A{ id = 12975,  prototype = tankCD, priority = 85 } --Last Stand
A{ id = 871,    prototype = tankCD } --Shield Wall 40%

-- DEMON HUNTER
A{ id = 212800, prototype = survivalCD } -- Blur
A{ id = 187827, prototype = tankCD } -- Vengeance Meta

-- ROGUE
A{ id = 1966,   prototype = survivalCD } -- Feint
A{ id = 31224,  prototype = survivalCD, priority = 91 } -- Cloak of Shadows
A{ id = 45182,  prototype = tankCD } -- Cheating Death

-- WARLOCK
A{ id = 104773, prototype = survivalCD } -- Unending Resolve
A{ id = 132413, prototype = survivalCD } -- Shadow Bulwark

-- DRUID
A{ id = 22812,  prototype = survivalCD } -- Barkskin
A{ id = 102342, prototype = tankCD, priority = 93 } --Ironbark
A{ id = 61336,  prototype = tankCD } --Survival Instincts 50% (Feral & Guardian)

-- PRIEST
A{ id = 19236,  prototype = survivalCD } -- Desperate Prayer
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
A{ id = 31850,  prototype = tankCD, priority = 88 } --Ardent Defender
A{ id = 86659,  prototype = tankCD } --Guardian of Ancient Kings 50%
A{ id = 204150, prototype = tankCD, priority = 85 } -- Aegis of Light
-- Guardian of the Forgotten Queen - Divine Shield (PvP)
A{ id = 228050, prototype = tankCD, priority = 97 }

-- DEATH KNIGHT
-- A{ id = 194679, prototype = survivalCD } -- Rune Tap
A{ id = 55233,  prototype = tankCD, priority = 94 } --Vampiric Blood
A{ id = 48792,  prototype = tankCD, priority = 94 } --Icebound Fortitude 50%

-- MAGE
A{ id = 113862, prototype = survivalCD } -- Arcane Greater Invisibility
A{ id = 45438,  prototype = tankCD } -- Ice Block

-- HUNTER
A{ id = 186265, prototype = survivalCD } -- Aspect of the Turtle

-- SHAMAN
A{ id = 108271, prototype = survivalCD } -- Astral Shift
A{ id = 204293, prototype = survivalCD } -- Spirit Link (PvP)

if playerClass == "PRIEST" then
    -- Power Word: Fortitude
    A{ id = 21562, type = "HELPFUL", assignto = "raidbuff", color = { 1, 1, 1}, priority = 100, isMissing = true }

    --Renew
    A{ id = 139,   type = "HELPFUL", assignto = "bars", priority = 50, pulse = true, color = { 0, 1, 0}, showDuration = true, isMine = true, pandemicTime = 4.5 }
    --Power Word: Shield
    A{ id = 17,    type = "HELPFUL", assignto = "bars", priority = 90, isMine = true, color = { 1, .85, 0}, showDuration = true }
    --Prayer of Mending
    A{ id = 41635, type = "HELPFUL", assignto = "bar4", priority = 70, stackcolor =   {
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
                                                                        }, showStacks = 5}
                                                                        -- stackcolor =   {
                                                                        --     [1] = { .8, 0, 0},
                                                                        --     [2] = { 1, 0, 0},
                                                                        --     [3] = { 1, .2, .2},
                                                                        --     [4] = { 1, .4, .4},
                                                                        --     [5] = { 1, .6, .6},
                                                                        -- }} --Prayer of Mending
    --Shadow Covenant
    A{ id = 219521,type = "HARMFUL", assignto = "bars", priority = 50, color = { 0.6, 0, 1 }, showDuration = true, isMine = true} 
    --Atonement
    A{ id = 194384,type = "HELPFUL", assignto = "bar4", extend_below = 15, color = { 1, .3, .3}, showDuration = true, isMine = true} 
    --Luminous Barrier
    A{ id = 271466,type = "HELPFUL", assignto = "bars", priority = 70, color = { 1, .65, 0}, showDuration = true, isMine = true}
    
    -- Atonement
    -- Trace{id = 94472, type = "HEAL", minamount = 70000, assignto = "spell3", color = -{ .2, 1, .2}, fade = .5, priority = 90 }

    -- Circle of Healing
    Trace{id = 204883, type = "HEAL", assignto = "spell3", color = { 1, 1, 0}, fade = 0.7, priority = 96 }
    -- Prayer of Healing
    Trace{id = 596, type = "HEAL", assignto = "spell3", color = { .5, .5, 1}, fade = 0.7, priority = 96 }

    -- Holy Ward (PvP)
    A{ id = 213610, type = "HELPFUL", assignto = "spell3", showDuration = true, priority = 70, color = { 1, .3, .3}, isMine = true }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(17), -- Disc: PWS
        RangeCheckBySpell(139),-- Holy: Renew
        RangeCheckBySpell(17), -- Shadow: PWS
    }

    -- DispelTypes("MAGIC|DISEASE")

end

if playerClass == "MONK" then
    --Renewing Mist
    A{ id = 119611, type = "HELPFUL", assignto = "bar4", isMine = true, color = {38/255, 221/255, 163/255}, showDuration = true }
    --Enveloping Mist
    A{ id = 124682, type = "HELPFUL", assignto = "bars", isMine = true, showDuration = true, color = { 1,1,0 }, priority = 75 }
    --Soothing Mist
    A{ id = 115175, type = "HELPFUL", assignto = "bars", isMine = true, showDuration = false, color = { 0, .8, 0}, priority = 80 }

    --Statue's Soothing Mist
    -- A{ id = 198533, type = "HELPFUL", assignto = "spell3", priority = 60, color = { 0, .4, 0} }

    --Essence Font
    A{ id = 191840, type = "HELPFUL", assignto = "bars", priority = 50, color = {0.5,0.7,1}, showDuration = true, isMine = true }


    Trace{id = 116670, type = "HEAL", assignto = "spell3", color = { 1, .7, .2}, fade = 0.7, priority = 96 } -- Vivify

    -- A{ id = 157627, type = "HELPFUL", assignto = "bar2", showDuration = true, color = {1, 1, 0}, priority = 95 } --Breath of the Serpent

    -- Dome of Mist
    A{ id = 205655, type = "HELPFUL", assignto = "shieldicon", showDuration = true, priority = 97 }

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

    -- DispelTypes("MAGIC|DISEASE|POISON")
end

if playerClass == "WARLOCK" then
    A{ id = 20707, type = "HELPFUL", assignto = "raidbuff", color = { 180/255, 0, 1 }, priority = 81 } --Soulstone Resurrection
end

if playerClass == "PALADIN" then
    --Tyr's Deliverance
    A{ id = 200654, type = "HELPFUL", assignto = "spell3", color = { 1, .8, 0}, priority = 70, showDuration = true, isMine = true }
     --Bestow Faith
    A{ id = 223306,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 1 , .9, 0} }


    -- Beacon of Virtue
    A{ id = 200025, type = "HELPFUL", assignto = "bar4", showDuration = true, isMine = true, color = { 0,.9,0 } }
    A{ id = 53563, type = "HELPFUL", assignto = "spell3", showDuration = true,
                                                                            isMine = true,
                                                                            color = { 0,.9,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Light

    A{ id = 156910, type = "HELPFUL", assignto = "spell3", showDuration = true,
                                                                            isMine = true,
                                                                            color = { 1,.7,0 },
                                                                            foreigncolor = { 0.96/2, 0.55/2, 0.73/2 },
                                                                        } -- Beacon of Faith

    A{ id = 210320,  type = "HELPFUL", assignto = "raidbuff", isMine = true, color = { .4, .4, 1} } --Devotion Aura
    A{ id = 183416,  type = "HELPFUL", assignto = "raidbuff", isMine = true, color = { 1, .4, .4} } --Aura of Sacrifice

    -- Trace{id = 85222, type = "HEAL", assignto = "spell3", color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Light of Dawn

    -- Trace{id = 82327, type = "HEAL", assignto = "spell3", color = { .8, .5, 1}, fade = 0.7, priority = 96 } -- Holy Radiance
    -- Trace{id =121129, type = "HEAL", assignto = "spell3", color = { 1, .5, 0}, fade = 0.7, priority = 96 } -- Daybreak

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(19750), -- Flash of Light
        RangeCheckBySpell(19750),
        RangeCheckBySpell(19750),
    }

    -- DispelTypes("MAGIC|DISEASE|POISON")
end
if playerClass == "SHAMAN" then
    -- config.useCombatLogFiltering = false -- Earth Shield got problems with combat log

    A{ id = 61295,  type = "HELPFUL", assignto = "bars", showDuration = true, isMine = true, color = { 0.2 , 0.2, 1} } --Riptide
    A{ id = 974,    type = "HELPFUL", assignto = "bar4", showStacks = 9, isMine = true, color = {0.2, 1, 0.2}, foreigncolor = {0, 0.5, 0} }
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
    -- Trace{id = 52042, type = "PERIODIC_HEAL", assignto = "spell3", color = { 0.4 , 0.4, 1}, fade = 0.7, priority = 93 } -- Chain Heal

    Trace{id = 1064, type = "HEAL", assignto = "spell3", color = { 1, 1, 0}, fade = 0.7, priority = 96 } -- Chain Heal
    --Trace{id = 73921, type = "HEAL", assignto = "spell3", color = { 0.6, 0.6, 1}, fade = 0.4, priority = 95 } -- Healing Rain

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(8004), -- Healing Surge
        RangeCheckBySpell(188070), -- Enh Healing Surge
        RangeCheckBySpell(8004),
    }


    -- DispelTypes("MAGIC|CURSE")
end
if playerClass == "DRUID" then
    --A{ id = 1126,  type = "HELPFUL", assignto = "raidbuff", color = { 235/255 , 145/255, 199/255}, isMissing = true } --Mark of the Wild

    -- Cenarion Ward
    A{ id = 102351, type = "HELPFUL", assignto = "spell2", priority = 70, color = {38/255, 221/255, 163/255}, isMine = true }
    -- Rejuvenation
    A{ id = 774,   type = "HELPFUL", assignto = "bars", extend_below = 15, priority = 90, pulse = true, color = { 1, 0.2, 1}, showDuration = true, isMine = true }
    -- Germination
    A{ id = 155777,type = "HELPFUL", assignto = "bars", extend_below = 15, priority = 80, pulse = true, color = { 1, 0.4, 1}, showDuration = true, isMine = true }
    -- Lifebloom
    A{ id = 33763, type = "HELPFUL", assignto = "bar4", extend_below = 14, priority = 60, showDuration = true, isMine = true, color = { 0.5, 1, 0.5}, }
    -- Regrowth
    -- A{ id = 8936, type = "HELPFUL", assignto = "spell3", isMine = true, color = { 0.2, 1, 0.2},priority = 60, showDuration = true }
    -- Wild Growth
    A{ id = 48438, type = "HELPFUL", assignto = "bars", color = { 0.4, 1, 0.4}, priority = 60, showDuration = true, isMine = true }

    config.UnitInRangeFunctions = {
        RangeCheckBySpell(8936),
        RangeCheckBySpell(8936),
        RangeCheckBySpell(8936),
        RangeCheckBySpell(8936),
    }

    -- DispelTypes("MAGIC|CURSE|POISON")
end

if playerClass == "WARRIOR" then
    -- Battle Shout
    A{ id = 6673,  type = "HELPFUL", assignto = "raidbuff", color = { 1, .4 , .4}, priority = 50, isMissing = true}
end
if playerClass == "MAGE" then
    A{ id = 1459,  type = "HELPFUL", assignto = "raidbuff", color = { .4 , .4, 1}, priority = 50, isMissing = true} --Arcane Intellect
    -- A{ id = 61316, type = "HELPFUL", assignto = "spell2", color = { .4 , .4, 1}, priority = 50 } --Dalaran Intellect
    -- A{ id = 54648, type = "HELPFUL", assignto = "spell2", color = { 180/255, 0, 1 }, priority = 60, isMine = true } --Focus Magic

    -- DispelTypes("CURSE")
end
-- if not isHealer or playerClass == "PALADIN" then
    -- config.redirectPowerBar = "spell1"
-- end

config.autoload = {
    "HealingReduction",
    "TankCooldowns"
}
