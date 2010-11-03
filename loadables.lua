local _, helpers = ...
-- RAID/PVP config loading
-- instances are identified by map id (assuming they have their own map).
-- to find out current zone map id type: /dump GetCurrentMapAreaID()
AptechkaDefaultConfig.MapIDs = {    
    [609] = "Ruby Sanctum",   -- In Cataclysm beta and 3.3.5 PTR it is 609, in Live version it's 610.. 
    [610] = "Ruby Sanctum",   -- and looks like the same thing happens with other raids. I'll just include everything for now
    [604] = "Icecrown Citadel",
    [605] = "Icecrown Citadel",
    [543] = "Trial of the Crusader",
    [544] = "Trial of the Crusader",
    [529] = "Ulduar",
    [530] = "Ulduar",
    [535] = "Naxxramas",
    [536] = "Naxxramas",
    [773] = "TotFW",
    [774] = "TotFW",
    [754] = "Blackwing Descent",
    [755] = "Blackwing Descent",
}

local A = helpers.AddAura

local color1 = { 0.9, 0, 0}
local color2 = { 0.6, 0, 1}

AptechkaDefaultConfig.BossDebuffPrototype = { type = "HARMFUL", assignto = { "bossdebuff" }, color = color1, priority = 40, pulse = true }

AptechkaDefaultConfig.LoadableDebuffs = {

    ["Blackwing Descent"] = function()
    A{ id = 82881, prototype = AptechkaUserConfig.BossDebuffPrototype } --Break, Chimaeron
    
    A{ id = 91431, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Conductor, Omnitron Defense System
    A{ id = 91502, color = {230/255, 117/255, 230/255 }, prototype = AptechkaUserConfig.BossDebuffPrototype } --Poison Soaked Shell, Omnitron Defense System
    
    A{ id = 92973, prototype = AptechkaUserConfig.BossDebuffPrototype } --Consuming Flames, Maloriak
    A{ id = 92978, color = color1, prototype = AptechkaUserConfig.BossDebuffPrototype } --Flash Freeze, Maloriak
    end,

    ["TotFW"] = function()
    A{ id = 89666, prototype = AptechkaUserConfig.BossDebuffPrototype } --Lightning Rod
    A{ id = 89104, prototype = AptechkaUserConfig.BossDebuffPrototype } --Relentless Storm
    end,
    
    ["Ruby Sanctum"] = function()
    A{ id = 74562, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fiery Combustion
    A{ id = 74792, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2 } --Soul Consumptio
    end,

    ["Icecrown Citadel"] = function()
    --A{ id = 69075, prototype = AptechkaUserConfig.BossDebuffPrototype } --Bone Storm dot, Lord Marrowgar
    A{ id = 69062, prototype = AptechkaUserConfig.BossDebuffPrototype } --Impale, Lord Marrowgar
    --A{ id = 71289, prototype = AptechkaUserConfig.BossDebuffPrototype } --Dominate Mind, Lady Deathwhisper
    A{ id = 72442, prototype = AptechkaUserConfig.BossDebuffPrototype } --Boiling Blood, Deathbringer Saurfang
    A{ id = 72444, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 50 } --Mark of the Fallen Champion, Deathbringer Saurfang
    A{ id = 69279, prototype = AptechkaUserConfig.BossDebuffPrototype } --Gas Cloud, Festergut
    A{ id = 71288, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 50 } --Vile Gas, Festergut
    A{ id = 73022, prototype = AptechkaUserConfig.BossDebuffPrototype } --Mutated Infection, Rotface
    A{ id = 71340, prototype = AptechkaUserConfig.BossDebuffPrototype } --Pact of the Darkfallen, Blood-Queen Lana'thel
    A{ id = 71530, prototype = AptechkaUserConfig.BossDebuffPrototype, color = color2, priority = 30 } --Essence of the Blood Queen, Blood-Queen Lana'thel
    A{ id = 70157, prototype = AptechkaUserConfig.BossDebuffPrototype } --Ice Tomb, Sindragosa
    
    --A{ id = 70337, prototype = AptechkaUserConfig.BossDebuffPrototype } --Necrotic Plague, Lich King, phase 1 & 2  // still broken in 3.3.3
    A{ id = 68980, prototype = AptechkaUserConfig.BossDebuffPrototype, showDuration = true, priority = 50 } --Harvest Soul, Lich King, phase 3
    A{ id = 70541, prototype = AptechkaUserConfig.BossDebuffPrototype, color = {230/255, 117/255, 230/255 }, priority = 20 } --Infest, Lich King
    A{ id = 69409, prototype = AptechkaUserConfig.BossDebuffPrototype, priority = 25, showDuration = true } --Soul Reaver debuff, Lich King
    --AptechkaUserConfig.LoadableDebuffs.tankcooldowns()
    end,
    
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
        A{ id = 55080, type = "HARMFUL", assignto = { "icon" }, priority = 86 } --Shattered Barrier
    end
    
    end,
    
    ["Trial of the Crusader"] = function()
    A{ id = 66237, prototype = AptechkaUserConfig.BossDebuffPrototype } --Incinerate Flesh, Lord Jaraxxus
    A{ id = 68510, prototype = AptechkaUserConfig.BossDebuffPrototype } --Penetrating Cold, Anub'arak
    A{ id = 67281, prototype = AptechkaUserConfig.BossDebuffPrototype } --Touch of Darkness, Twin Val'kyrs
    A{ id = 67296, prototype = AptechkaUserConfig.BossDebuffPrototype } --Touch of Light, Twin Val'kyrs
    AptechkaUserConfig.LoadableDebuffs.PvP(true, true)
    end,
    
    ["Ulduar"] = function()
    A{ id = 64126, prototype = AptechkaUserConfig.BossDebuffPrototype } --Squeeze, Yogg-Saron
    A{ id = 62717, prototype = AptechkaUserConfig.BossDebuffPrototype } --Slag Pot, Ignis
    A{ id = 63493, prototype = AptechkaUserConfig.BossDebuffPrototype } --Fusion Punch, Assembly of Iron
    A{ id = 64290, prototype = AptechkaUserConfig.BossDebuffPrototype } --Stone Grip, Kologarn
    A{ id = 63018, prototype = AptechkaUserConfig.BossDebuffPrototype } --Searing Light, XT-002
    end,
    
    ["Naxxramas"] = function()
    A{ id = 27808, prototype = AptechkaUserConfig.BossDebuffPrototype } --Frost Blast, Kel'Thuzad
    A{ id = 28622, prototype = AptechkaUserConfig.BossDebuffPrototype } --Web Wrap, Maexxna
    end,
    
    ['tankcooldowns'] = function()

    end,
}