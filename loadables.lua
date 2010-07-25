local _, helpers = ...

local A = helpers.AddAura

local color1 = { 0.9, 0, 0}
local color2 = { 0.6, 0, 1}

local defaultIndicator = { type = "HARMFUL", indicator = { "left" }, color = color1, priority = 40, pulse = true }

InjectorConfig.LoadableDebuffs = {
    ["Ruby Sanctum"] = function()
    A{ id = 74562, type = "HARMFUL", prototype = defaultIndicator } --Fiery Combustion
    A{ id = 74792, type = "HARMFUL", prototype = defaultIndicator, color = color2 } --Soul Consumptio
    end,

    ["Icecrown Citadel"] = function()
    --A{ id = 69075, prototype = defaultIndicator } --Bone Storm dot, Lord Marrowgar
    A{ id = 69062, prototype = defaultIndicator } --Impale, Lord Marrowgar
    --A{ id = 71289, prototype = defaultIndicator } --Dominate Mind, Lady Deathwhisper
    A{ id = 72442, prototype = defaultIndicator } --Boiling Blood, Deathbringer Saurfang
    A{ id = 72444, prototype = defaultIndicator, color = color2, priority = 50 } --Mark of the Fallen Champion, Deathbringer Saurfang
    A{ id = 69279, prototype = defaultIndicator } --Gas Cloud, Festergut
    A{ id = 71288, prototype = defaultIndicator, color = color2, priority = 50 } --Vile Gas, Festergut
    A{ id = 73022, prototype = defaultIndicator } --Mutated Infection, Rotface
    A{ id = 71340, prototype = defaultIndicator } --Pact of the Darkfallen, Blood-Queen Lana'thel
    A{ id = 71530, prototype = defaultIndicator, color = color2, priority = 30 } --Essence of the Blood Queen, Blood-Queen Lana'thel
    A{ id = 70157, prototype = defaultIndicator } --Ice Tomb, Sindragosa
    
    --A{ id = 70337, prototype = defaultIndicator } --Necrotic Plague, Lich King, phase 1 & 2  // still broken in 3.3.3
    A{ id = 68980, prototype = defaultIndicator, showDuration = true, priority = 50 } --Harvest Soul, Lich King, phase 3
    A{ id = 70541, prototype = defaultIndicator, color = {230/255, 117/255, 230/255 }, priority = 20 } --Infest, Lich King
    A{ id = 69409, prototype = defaultIndicator, priority = 25, showDuration = true } --Soul Reaver debuff, Lich King
    --InjectorConfig.LoadableDebuffs.tankcooldowns()
    end,
    
    ["PvP"] = function(disable_damagereduction, disable_roots)
    A{ id = 118,   type = "HARMFUL", icon = "center", priority = 90 } --Polymorph
    A{ id = 3355,  type = "HARMFUL", icon = "center", priority = 90 } --Freezing Trap
    A{ id = 20066, type = "HARMFUL", icon = "center", priority = 90 } --Repentance
    A{ id = 5782,  type = "HARMFUL", icon = "center", priority = 89 } --Fear
    A{ id = 6770,  type = "HARMFUL", icon = "center", priority = 88 } --Sap
    A{ id = 2094,  type = "HARMFUL", icon = "center", priority = 88 } --Blind
    A{ id = 51514, type = "HARMFUL", icon = "center", priority = 87 } --Hex
    A{ id = 853,   type = "HARMFUL", icon = "center", priority = 86 } --Hammer of Justice
    A{ id = 44572, type = "HARMFUL", icon = "center", priority = 86 } --Deep Freeze
    A{ id = 30108, type = "HARMFUL", icon = "center", priority = 86 } --Unstable Affliction
    
    if not disable_damagereduction then
        A{ id = 871,   type = "HELPFUL", icon = "center", priority = 84 } --Shield Wall
        A{ id = 5277,  type = "HELPFUL", icon = "center", priority = 84 } --Evasion
        A{ id = 31224, type = "HELPFUL", icon = "center", priority = 84 } --Cloak of Shadows
        A{ id = 1022,  type = "HELPFUL", icon = "center", priority = 84 } --Hand of Protection
        A{ id = 45438, type = "HELPFUL", icon = "center", priority = 85 } --Ice Block
        A{ id = 642,   type = "HELPFUL", icon = "center", priority = 85 } --Divine Shield
        A{ id = 1784,  type = "HELPFUL", icon = "center", priority = 85 } --Stealth
    end

    if not disable_roots then
        A{ id = 339,   type = "HARMFUL", icon = "center", priority = 86 } --Entangling Roots
        A{ id = 122,   type = "HARMFUL", icon = "center", priority = 86 } --Frost Nova
        A{ id = 55080, type = "HARMFUL", icon = "center", priority = 86 } --Shattered Barrier
        A{ id = 12494, type = "HARMFUL", icon = "center", priority = 86 } --Frostbite
    end
    
    end,
    
    ["Trial of the Crusader"] = function()
    A{ id = 66237, prototype = defaultIndicator } --Incinerate Flesh, Lord Jaraxxus
    A{ id = 68510, prototype = defaultIndicator } --Penetrating Cold, Anub'arak
    A{ id = 67281, prototype = defaultIndicator } --Touch of Darkness, Twin Val'kyrs
    A{ id = 67296, prototype = defaultIndicator } --Touch of Light, Twin Val'kyrs
    InjectorConfig.LoadableDebuffs.PvP(true, true)
    end,
    
    ["Ulduar"] = function()
    A{ id = 64126, prototype = defaultIndicator } --Squeeze, Yogg-Saron
    A{ id = 62717, prototype = defaultIndicator } --Slag Pot, Ignis
    A{ id = 63493, prototype = defaultIndicator } --Fusion Punch, Assembly of Iron
    A{ id = 64290, prototype = defaultIndicator } --Stone Grip, Kologarn
    A{ id = 63018, prototype = defaultIndicator } --Searing Light, XT-002
    end,
    
    ["Naxxramas"] = function()
    A{ id = 27808, prototype = defaultIndicator } --Frost Blast, Kel'Thuzad
    A{ id = 28622, prototype = defaultIndicator } --Web Wrap, Maexxna
    end,
    
    ['tankcooldowns'] = function()
    A{ id = 871,   type = "HELPFUL", icon = "center", priority = 90 } --Shield Wall
    A{ id = 498,   type = "HELPFUL", icon = "center", priority = 90 } --Divine Protection
    A{ id = 48792, type = "HELPFUL", icon = "center", priority = 90 } --Icebound Fortitude
    A{ id = 33206, type = "HELPFUL", icon = "center", priority = 90 } --Pain Suppression
    
    A{ id = 55233, type = "HELPFUL", icon = "center", priority = 88 } --Vampiric Blood
    A{ id = 47788, type = "HELPFUL", icon = "center", priority = 88 } --Guardian Spirit
    
    A{ id = 12975, type = "HELPFUL", icon = "center", priority = 86 } --Last Stand
    A{ id = 61336, type = "HELPFUL", icon = "center", priority = 86 } --Survival Instincts
    end,
}