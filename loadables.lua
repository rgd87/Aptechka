local _, helpers = ...
-- RAID/PVP config loading
-- instances are identified by map id (assuming they have their own map).
-- to find out current zone map id type: /dump GetCurrentMapAreaID()
AptechkaDefaultConfig.MapIDs = {
    -- [609] = "Ruby Sanctum",
    -- [604] = "Icecrown Citadel",
    -- [543] = "Trial of the Crusader",
    -- [529] = "Ulduar",
    -- [535] = "Naxxramas",
    -- [773] = "TotFW",
    -- [754] = "Blackwing Descent",
    -- [758] = "Bastion of Twilight",
    -- [781] = "ZulAman",
    -- [793] = "ZulGurub",
    -- [800] = "Firelands",
    -- [824] = "DragonSoul",
    -- [877] = "ShadoPanMonastery",
    -- [896] = "MogushanVaults",
    -- [897] = "Heart of Fear",
    -- [886] = "Terrace of Endless Spring",
    -- [930] = "Throne of Thunder",
    -- [1094] = "Emerald Nightmare",
    -- [1081] = "Black Rook Hold",
    -- [1079] = "Arcway",
    -- [1067] = "Darkheart Thicket",
    -- [1066] = "Violet Hold",
    -- [1065] = "Neltharion's Lair",
    -- [1046] = "Eye of Azshara",
    -- [1045] = "Vault of the Wardens",
    -- [1042] = "Maw of Souls",
    -- [1041] = "Halls of Valor",
}

local A = helpers.AddAura

local color1 = { 0.9, 0, 0 }
local color2 = { 0.6, 0, 1 }
local green = {0,1,0}
local teal = { 42/255, 201/255, 154/255 }
local light = { 178/255, 150/255, 150/255}
local healred = { 147/255, 54/255, 115/255 }

AptechkaDefaultConfig.BossDebuffPrototype = { type = "HARMFUL", assignto = { "bossdebuff" }, color = color1, priority = 40, pulse = true }

AptechkaDefaultConfig.LoadableDebuffs = {

    -- ["Emerald Nightmare"] = function()
    --     A{ id = 222719, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Осквернение, треш

    --     A{ id = 203097, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Nythendra, Rot
    --     A{ id = 204470, color = green, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Nythendra, Volatile Rot
    --     A{ id = 205043, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Nythendra, Infested Mind

    --     A{ id = 215449, color = green, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Elerethe Renferal, Necrotic Venom
    --     A{ id = 210863, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Elerethe Renferal, Twisting Shadows
    --     A{ id = 212993, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Elerethe Renferal, Shimmering Feather

    --     A{ id = 210099, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Il'gynoth, Ooze fixate

    --     A{ id = 198006, color = light, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Ursoc, charge target
    -- end,

    -- ["Black Rook Hold"] = function()
    --     A{ id = 194966, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Amalgam of Souls, Soul Echoes

    --     A{ id = 200261, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Stun, Soul-Torn Champion
    --     A{ id = 197974, color = teal, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Stun, Soul-Torn Vanguard

    --     A{ id = 197546, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Illysanna Ravencrest, Brutal Glaive
    --     A{ id = 197687, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Illysanna Ravencrest, Eye Beamsr2

    --     A{ id = 198079, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Smashspite, Hateful Gaze

    --     A{ id = 214002, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Risen Lancers, Raven's Dive
    -- end,

    -- ["Darkheart Thicket"] = function()
    --     A{ id = 225484, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Frenzied Nightclaw, Grievous Rip
    --     A{ id = 198477, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Nightmare Abomination, Fixate

    --     A{ id = 196376, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Archdruid Glaidalis, Grievous Tear


    --     A{ id = 198904, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Rotheart Dryads, Poison Spear
    --     A{ id = 201842, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Taintheart Summoners, Curse of Isolation

    --     A{ id = 204611, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Oakheart, Crushing Grip

    --     A{ id = 200238, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Shade of Xavius, Feed on the Weak
    --     A{ id = 200289, color = color2, priority = 30, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Shade of Xavius, Feed on the Weak
    -- end,

    -- ["Neltharion's Lair"] = function()
    --     A{ id = 202181, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Basilisks, Stone Gaze

    --     A{ id = 205549, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Naraxas, Rancid Maw
    --     A{ id = 199705, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Naraxas, Devouring

    --     A{ id = 200154, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Colossal Charskin, Burning Hatred
    --     A{ id = 193585, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Rockbound Trapper, Bound
    -- end,


    -- ["Maw of Souls"] = function()
    --     A{ id = 202181, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Seacursed Soulkeeper, Brackwater Blast
    --     -- Trace{id = 193460, type = "DAMAGE", assignto = { "bossdebuff" }, color = color2, fade = 0.7, priority = 45 } -- Bane, Ymiron
    -- end,

    -- ["Vault of the Wardens"] = function()

    -- end,

    -- ["Halls of Valor"] = function()
    --     A{ id = 198599, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Громовой удар, треш
    --     A{ id = 196838, prototype = AptechkaUserConfig.BossDebuffPrototype } -- Fenrir, Scent of Blood
    -- end,
    -- ["Throne of Thunder"] = function()
    --     A{ id = 138006, prototype = AptechkaUserConfig.BossDebuffPrototype } --Electrified Waters
    --     A{ id = 137399, prototype = AptechkaUserConfig.BossDebuffPrototype } --Focused Lightning
    --     A{ id = 138732, prototype = AptechkaUserConfig.BossDebuffPrototype } --Ionization
    --     A{ id = 138349, prototype = AptechkaUserConfig.BossDebuffPrototype } --Static Wound
    --     A{ id = 137371, prototype = AptechkaUserConfig.BossDebuffPrototype } --Thundering Throw
    --     A{ id = 136769, prototype = AptechkaUserConfig.BossDebuffPrototype } --Charge
    --     A{ id = 136767, prototype = AptechkaUserConfig.BossDebuffPrototype } --Triple Puncture
    --     A{ id = 136708, prototype = AptechkaUserConfig.BossDebuffPrototype } --Stone Gaze
    --     A{ id = 136723, prototype = AptechkaUserConfig.BossDebuffPrototype } --Sand Trap
    --     A{ id = 136587, prototype = AptechkaUserConfig.BossDebuffPrototype } --Venom Bolt Volley (dispellable)
    --     A{ id = 136710, prototype = AptechkaUserConfig.BossDebuffPrototype } --Deadly Plague
    --     A{ id = 136670, prototype = AptechkaUserConfig.BossDebuffPrototype } --Mortal Strike
    --     A{ id = 136573, prototype = AptechkaUserConfig.BossDebuffPrototype } --Frozen Bolt (Debuff used by frozen orb)
    --     A{ id = 136512, prototype = AptechkaUserConfig.BossDebuffPrototype } --Hex of Confusion
    --     A{ id = 136719, prototype = AptechkaUserConfig.BossDebuffPrototype } --Blazing Sunlight
    --     A{ id = 136654, prototype = AptechkaUserConfig.BossDebuffPrototype } --Rending Charge
    --     A{ id = 140946, prototype = AptechkaUserConfig.BossDebuffPrototype } --Dire Fixation (Heroic Only)
    -- end,

    -- ["Terrace of Endless Spring"] = function()
    --     A{ id = 111850, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Prison
    -- end,
    -- ["Heart of Fear"] = function()
    --     A{ id = 125390, prototype = AptechkaUserConfig.BossDebuffPrototype } --fixate, empress, windblades
    --     A{ id = 124862, prototype = AptechkaUserConfig.BossDebuffPrototype } --visions of demise, empress
    --     A{ id = 122370, prototype = AptechkaUserConfig.BossDebuffPrototype } --abomination
    --     A{ id = 122740, prototype = AptechkaUserConfig.BossDebuffPrototype } --zor'loc mc
    -- end,
    -- ["MogushanVaults"] = function()
    -- end,
    -- ["ShadoPanMonastery"] = function()
    --     A{ id = 115509, prototype = AptechkaUserConfig.BossDebuffPrototype } --Thundering Fist, first adds
    --     A{ id = 106872, prototype = AptechkaUserConfig.BossDebuffPrototype } --Sha of Violence, Disorient
    -- end,
    -- ["DragonSoul"] = function()
    --     A{ id = 100460, prototype = AptechkaUserConfig.BossDebuffPrototype } --Disrupting Shadows, Warlord Zon'ozz

    --     A{ id = 109325, priority = 35, prototype = AptechkaUserConfig.BossDebuffPrototype } --Frostflake, Hagara the Stormbinder
    --     A{ id = 104451, color = { 0.2, 0.2, 1 }, priority = 50, prototype = AptechkaUserConfig.BossDebuffPrototype } --Ice Tomb, Hagara the Stormbinder
    --     -- A{ id = 105369, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Conduit, Hagara the Stormbinder
    --     A{ id = 105927, prototype = AptechkaUserConfig.BossDebuffPrototype } --Faded into Twilight, Hagara the Stormbinder

    --     A{ id = 107558, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Degeneration, Warmaster Blackhorn
    --     A{ id = 107567, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Brutal Strike, Warmaster Blackhorn
    --     A{ id = 108043, priority = 50, prototype = AptechkaUserConfig.BossDebuffPrototype } --Sunder Armor, Warmaster Blackhorn

    --     A{ id = 105479, priority = 50, color = color2,  prototype = AptechkaUserConfig.BossDebuffPrototype } --Searing Plasma, Spine of Deathwing
    --     A{ id = 105490, priority = 51, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Grip, Spine of Deathwing

    --     A{ id = 106730, prototype = AptechkaUserConfig.BossDebuffPrototype } --Tetanus, Madness of Deathwing
    -- end,
    -- ["Firelands"] = function()
    --     --A{ id = 100249, prototype = AptechkaUserConfig.BossDebuffPrototype } --Combustion, Ragnaros
    --     A{ id = 98981, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lava Bolt, Ragnaros
    --     A{ id = 100460, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Blazing Heat, Ragnaros

    --     A{ id = 98443, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Cyclone, Majordomo Staghelm
    --     A{ id = 98450, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Searing Seeds, Majordomo Staghelm

    --     A{ id = 99516, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Countdown, Baleroc
    --     A{ id = 99403, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Tormented, Baleroc
    --     A{ id = 99256, prototype = AptechkaUserConfig.BossDebuffPrototype } --Torment, Baleroc

    --     A{ id = 99936, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Jagged Tear, Shannox
    --     A{ id = 99837, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Crystal Prison Trap Effect, Shannox
    --     A{ id = 101208, color = { 1, 0.27, 0}, prototype = AptechkaUserConfig.BossDebuffPrototype } --Immolation Trap, Shannox

    --     A{ id = 99308, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Gushing Wound, Alysrazor

    --     A{ id = 98492, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Eruption, Lord Rhyolith

    --     --A{ id = 97202, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Web Spin, Cinderweb Spinner, Beth'tilac
    --     A{ id = 49026, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fixate, Cinderweb Drone, Beth'tilac
    -- end,

    -- ["ZulGurub"] = function()
    --     A{ id = 96776, showDuration = true, prototype = AptechkaUserConfig.BossDebuffPrototype } --Bloodletting, Mandokir
    --     A{ id = 96478, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Toxis Link, Venoxis
    -- end,

    -- ["ZulAman"] = function()
    --     A{ id = 97300, prototype = AptechkaUserConfig.BossDebuffPrototype } --Electrical Storm, Akil'zon

    --     A{ id = 97811, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lacerating Slash, Nalorakk
    --     A{ id = 42402, prototype = AptechkaUserConfig.BossDebuffPrototype } --Surge, Nalorakk

    --     A{ id = 97490, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Flame Shock, Halazzi
    --     A{ id = 99284, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fixate, Halazzi

    --     A{ id = 97639, prototype = AptechkaUserConfig.BossDebuffPrototype } --Grievous Throw, Daakara
    --     A{ id = 97672, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Claw Rage, Daakara
    --     A{ id = 97639, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lynx Rush, Daakara (dot)
    --     A{ id = 42402, prototype = AptechkaUserConfig.BossDebuffPrototype } --Surge, Daakara
    -- end,

    -- ["Bastion of Twilight"] = function()
    --     A{ id = 92878, prototype = AptechkaUserConfig.BossDebuffPrototype } --Blackout, Valiona
    --     A{ id = 88518, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Twilight Meteorite, Valiona

    --     A{ id = 82762, color = {0.3,0.3,1}, priority = 38, prototype = AptechkaUserConfig.BossDebuffPrototype } --Waterlogged,Feludius
    --     A{ id = 82660, color = {1,0.2,0.2}, priority = 38, prototype = AptechkaUserConfig.BossDebuffPrototype } --Burning Blood,Ignacious
    --     A{ id = 83099, color = {0.3,0.3,1}, priority = 38, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Rod,Arion
    --     A{ id = 92067, color = {1,1,0.2}, prototype = AptechkaUserConfig.BossDebuffPrototype } --Static Overload,Arion,Heroic
    --     A{ id = 92075, color = {122/255,85/255,49/255}, prototype = AptechkaUserConfig.BossDebuffPrototype } --Gravity Core,Terrastra,Heroic

    --     --Magic--A{ id = 81836, prototype = AptechkaUserConfig.BossDebuffPrototype } --Corruption: Accelerated,Cho'gall
    --     A{ id = 93202, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Corruption: Sickness,Cho'gall
    --     A{ id = 93204, prototype = AptechkaUserConfig.BossDebuffPrototype } --Conversion,Cho'gall
    --     --A{ id = 93133, prototype = AptechkaUserConfig.BossDebuffPrototype } --Debilitating Beam,Cho'gall

    --     A{ id = 93133, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Wrack,Lady Sinestra
    -- end,

    -- ["Blackwing Descent"] = function()
    --     A{ id = 91911, prototype = AptechkaUserConfig.BossDebuffPrototype } --Constricting Chains, Magmaw

    --     A{ id = 82881, prototype = AptechkaUserConfig.BossDebuffPrototype } --Break, Chimaeron

    --     A{ id = 91431, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Conductor, Omnitron Defense System
    --     A{ id = 91502, color = {230/255, 117/255, 230/255 }, prototype = AptechkaUserConfig.BossDebuffPrototype } --Poison Soaked Shell, Omnitron Defense System

    --     A{ id = 92973, prototype = AptechkaUserConfig.BossDebuffPrototype } --Consuming Flames, Maloriak
    --     A{ id = 92978, color = color2, prototype = AptechkaUserConfig.BossDebuffPrototype } --Flash Freeze, Maloriak
    -- end,

    -- ["TotFW"] = function()
    --     A{ id = 89666, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Rod
    --     A{ id = 89104, prototype = AptechkaUserConfig.BossDebuffPrototype } --Relentless Storm
    -- end,

    -- ["Ruby Sanctum"] = function()
    --     A{ id = 74562, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Combustion
    --     A{ id = 74792, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2 } --Soul Consumptio
    -- end,

    -- ["Icecrown Citadel"] = function()
    --     --A{ id = 69075, prototype = AptechkaUserConfig.BossDebuffPrototype } --Bone Storm dot, Lord Marrowgar
    --     A{ id = 69062, prototype = AptechkaUserConfig.BossDebuffPrototype } --Impale, Lord Marrowgar
    --     --A{ id = 71289, prototype = AptechkaUserConfig.BossDebuffPrototype } --Dominate Mind, Lady Deathwhisper
    --     A{ id = 72442, prototype = AptechkaUserConfig.BossDebuffPrototype } --Boiling Blood, Deathbringer Saurfang
    --     A{ id = 72444, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 50 } --Mark of the Fallen Champion, Deathbringer Saurfang
    --     A{ id = 69279, prototype = AptechkaUserConfig.BossDebuffPrototype } --Gas Cloud, Festergut
    --     A{ id = 71288, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 50 } --Vile Gas, Festergut
    --     A{ id = 73022, prototype = AptechkaUserConfig.BossDebuffPrototype } --Mutated Infection, Rotface
    --     A{ id = 71340, prototype = AptechkaUserConfig.BossDebuffPrototype } --Pact of the Darkfallen, Blood-Queen Lana'thel
    --     A{ id = 71530, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 30 } --Essence of the Blood Queen, Blood-Queen Lana'thel
    --     A{ id = 70157, prototype = AptechkaUserConfig.BossDebuffPrototype } --Ice Tomb, Sindragosa

    --     --A{ id = 70337, prototype = AptechkaUserConfig.BossDebuffPrototype } --Necrotic Plague, Lich King, phase 1 & 2  // still broken in 3.3.3
    --     A{ id = 68980, prototype = AptechkaUserConfig.BossDebuffPrototype, showDuration = true, priority = 50 } --Harvest Soul, Lich King, phase 3
    --     A{ id = 70541, prototype = AptechkaUserConfig.BossDebuffPrototype, color = {230/255, 117/255, 230/255 }, priority = 20 } --Infest, Lich King
    --     A{ id = 69409, prototype = AptechkaUserConfig.BossDebuffPrototype, priority = 25, showDuration = true } --Soul Reaver debuff, Lich King
    --     --AptechkaUserConfig.LoadableDebuffs.tankcooldowns()
    -- end,


    -- ["Trial of the Crusader"] = function()
    --     A{ id = 66237, prototype = AptechkaUserConfig.BossDebuffPrototype } --Incinerate Flesh, Lord Jaraxxus
    --     A{ id = 68510, prototype = AptechkaUserConfig.BossDebuffPrototype } --Penetrating Cold, Anub'arak
    --     A{ id = 67281, prototype = AptechkaUserConfig.BossDebuffPrototype } --Touch of Darkness, Twin Val'kyrs
    --     A{ id = 67296, prototype = AptechkaUserConfig.BossDebuffPrototype } --Touch of Light, Twin Val'kyrs
    --     AptechkaUserConfig.LoadableDebuffs.PvP(true, true)
    -- end,

    -- ["Ulduar"] = function()
    --     A{ id = 64126, prototype = AptechkaUserConfig.BossDebuffPrototype } --Squeeze, Yogg-Saron
    --     A{ id = 62717, prototype = AptechkaUserConfig.BossDebuffPrototype } --Slag Pot, Ignis
    --     A{ id = 63493, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fusion Punch, Assembly of Iron
    --     A{ id = 64290, prototype = AptechkaUserConfig.BossDebuffPrototype } --Stone Grip, Kologarn
    --     A{ id = 63018, prototype = AptechkaUserConfig.BossDebuffPrototype } --Searing Light, XT-002
    -- end,

    -- ["Naxxramas"] = function()
    --     A{ id = 27808, prototype = AptechkaUserConfig.BossDebuffPrototype } --Frost Blast, Kel'Thuzad
    --     A{ id = 28622, prototype = AptechkaUserConfig.BossDebuffPrototype } --Web Wrap, Maexxna
    -- end,




    ["PvP"] = function(disable_damagereduction, disable_roots)
        A{ id = 23333, type = "HELPFUL", assignto = { "bossdebuff" }, color = {1,0,0}, priority = 95 } --Warsong Flag
        A{ id = 23335, type = "HELPFUL", assignto = { "bossdebuff" }, color = {0,0,1}, priority = 95 } --Silverwing Flag
        A{ id = 34976, type = "HELPFUL", assignto = { "bossdebuff" }, color = {0,1,0}, priority = 95 } --Netherstorm Flag

        A{ id = 118,   type = "HARMFUL", assignto = { "icon" }, priority = 90 } --Polymorph
        A{ id = 3355,  type = "HARMFUL", assignto = { "icon" }, priority = 90 } --Freezing Trap
        A{ id = 20066, type = "HARMFUL", assignto = { "icon" }, priority = 90 } --Repentance
        A{ id = 5782,  type = "HARMFUL", assignto = { "icon" }, priority = 89 } --Fear
        A{ id = 6770,  type = "HARMFUL", assignto = { "icon" }, priority = 88 } --Sap
        A{ id = 2094,  type = "HARMFUL", assignto = { "icon" }, priority = 88 } --Blind
        A{ id = 51514, type = "HARMFUL", assignto = { "icon" }, priority = 87 } --Hex
        A{ id = 853,   type = "HARMFUL", assignto = { "icon" }, priority = 86 } --Hammer of Justice
        A{ id = 44572, type = "HARMFUL", assignto = { "icon" }, priority = 86 } --Deep Freeze
        A{ id = 30108, type = "HARMFUL", assignto = { "icon" }, priority = 86 } --Unstable Affliction

        if not disable_damagereduction then
            A{ id = 871,   type = "HELPFUL", assignto = { "icon" }, priority = 84 } --Shield Wall
            A{ id = 5277,  type = "HELPFUL", assignto = { "icon" }, priority = 84 } --Evasion
            A{ id = 31224, type = "HELPFUL", assignto = { "icon" }, priority = 84 } --Cloak of Shadows
            A{ id = 1022,  type = "HELPFUL", assignto = { "icon" }, priority = 84 } --Hand of Protection
            A{ id = 45438, type = "HELPFUL", assignto = { "icon" }, priority = 85 } --Ice Block
            A{ id = 642,   type = "HELPFUL", assignto = { "icon" }, priority = 85 } --Divine Shield
            A{ id = 1784,  type = "HELPFUL", assignto = { "icon" }, priority = 85 } --Stealth
        end

        if not disable_roots then
            A{ id = 339,   type = "HARMFUL", assignto = { "icon" }, priority = 86 } --Entangling Roots
            A{ id = 122,   type = "HARMFUL", assignto = { "icon" }, priority = 86 } --Frost Nova
        end

    end,

    ['TankCooldowns'] = function()

    end,

    ['HealingReduction'] = function()
        A{ id = 8680,  color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Wound Poison
        -- A{ id = 24674, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Veil of Shadow
        A{ id = 115804, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Mortal Wounds

        -- A{ id = 30213, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Legion Strike
        -- A{ id = 54680, color = healred, prototype = AptechkaUserConfig.BossDebuffPrototype } --Monstrous Bite
    end,
}
