local _, helpers = ...
local config

local _GetSpellInfo = GetSpellInfo
local GetSpellInfo = function(...)
    local name = _GetSpellInfo(...)
    if name == "" then return nil end
    return _GetSpellInfo(...)
end

helpers.AddDispellType = function(dtype, data)
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    if not config.DebuffTypes then config.DebuffTypes = {} end
    local _,class = UnitClass("player")
    
    if class == "PRIEST" then
        if dtype ~= "Disease" and dtype ~= "Magic" then config.DispelFilterAll = true end
    elseif class == "DRUID" then
        if dtype ~= "Curse" and dtype ~= "Magic" and dtype ~= "Poison" then config.DispelFilterAll = true end
    elseif class == "PALADIN" then
        if dtype ~= "Disease" and dtype ~= "Magic" and dtype ~= "Poison" then config.DispelFilterAll = true end
    elseif class == "SHAMAN" then
        if dtype ~= "Curse" and dtype ~= "Magic" then config.DispelFilterAll = true end
    elseif class == "MAGE" then
        if dtype ~= "Curse" then config.DispelFilterAll = true end
    else
        config.DispelFilterAll = true
    end
    data.name = dtype
    config.DebuffTypes[dtype] = data
end
helpers.AddAura = function (data, todefault)
    if AptechkaUserConfig and not todefault then config = AptechkaUserConfig else config = AptechkaDefaultConfig end

    if data.id then data.name = GetSpellInfo(data.id) end
    if data.name == nil then print (data.id.." spell id missing") return end
    -- if data.isMine then data.type = data.type.."|PLAYER" end
    if data.debuffType then DT(data.debuffType, data) end

    if data.prototype then setmetatable(data, { __index = function(t,k) return data.prototype[k] end }) end

    if not data.type then data.type = "HELPFUL" end

    if not config.IndicatorAuras then config.IndicatorAuras = {} end
    if not config.IndicatorAuras[data.type] then config.IndicatorAuras[data.type] = {} end
    config.IndicatorAuras[data.type][data.id] = data
end
helpers.AddAuraToDefault = function(data)
    helpers.AddAura(data,true)
end
helpers.AddTrace = function(data)
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    if not config.enableTraceHeals then return end
    if data.id then data.name = GetSpellInfo(data.id) or data.name end
    data.type = "SPELL_"..data.type
    if not config.TraceHeals then config.TraceHeals = {} end
    if not data.name then print((data.id or "nil").."id or name required") return end
    data.actualname = data.name
    data.name = data.actualname.."Trace"
    config.TraceHeals[data.actualname] = data
end

helpers.AddDebuff = function (index, data)
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    if not config.DebuffDisplay then config.DebuffDisplay = {} end

    config.DebuffDisplay[index] = data
end


helpers.ClickMacro = function(macro)
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    if not config.enableClickCasting then return end
    config.ClickCastingMacro = macro:gsub("spell:(%d+)",GetSpellInfo):gsub("([ \t]+)/",'/')
end

helpers.BindTarget = function(str)
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    if not str then
        config.TargetBinding = false
        return
    end
    str = str:lower()
    local alt = str:find("alt")
    local shift = str:find("shift")
    local ctrl = str:find("ctrl")
    local btn = str:match("(%d+)")
    if btn == "0" then btn = "*" end
    local tar = "type"..btn
    if shift then tar = "shift-"..tar end
    if ctrl then tar = "ctrl-"..tar end
    if alt then tar = "alt-"..tar end
    config.TargetBinding = tar
    --alt-ctrl-shift-type*     -- That order is required
end


--~ helpers.AddClickCast = function(data)
--~     if not config.enableClickCasting then return end
--~     if not data.button then print("specify mouse button") return end
--~     if not config.ClickCasting then config.ClickCasting = {} end
--~     local seq = "type"..(data.button == 0 and "*" or data.button)
--~     if data.shift then seq = "shift-"..seq end
--~     if data.ctrl then seq = "ctrl-"..seq end
--~     if data.alt then seq = "alt-"..seq end
--~     local cc = {
--~         [seq] = data.type,
--~         [data.type] = data.value
--~     }
--~     table.insert(config.ClickCasting, cc)
--~ end






function helpers.utf8sub(str, start, numChars) 
    local currentIndex = start 
    while numChars > 0 and currentIndex <= #str do 
        local char = string.byte(str, currentIndex) 
        if char >= 240 then 
          currentIndex = currentIndex + 4 
        elseif char >= 225 then 
          currentIndex = currentIndex + 3 
        elseif char >= 192 then 
          currentIndex = currentIndex + 2 
        else 
          currentIndex = currentIndex + 1 
        end 
        numChars = numChars - 1 
    end 
    return str:sub(start, currentIndex - 1) 
end

function helpers.DisableBlizzParty(self)
    for i=1,4 do
        local party = "PartyMemberFrame"..i
        local frame = _G[party]

        frame:UnregisterAllEvents()
        frame.Show = function()end
        frame:Hide()
        _G[party..'HealthBar']:UnregisterAllEvents()
        _G[party..'ManaBar']:UnregisterAllEvents()
    end
end

function helpers.Reverse(p1)
    local p2 = ""
    local dir
    if string.find(p1,"CENTER") then return "CENTER" end
    if string.find(p1,"TOP") then p2 = p2.."BOTTOM" end
    if string.find(p1,"BOTTOM") then p2 = p2.."TOP" end
    if string.find(p1,"LEFT") then p2 = p2.."RIGHT" end
    if string.find(p1,"RIGHT") then p2 = p2.."LEFT" end
    if p2 == "RIGHT" or p2 == "LEFT" then
        dir = "HORIZONTAL"
    elseif p2 == "TOP" or p2 == "BOTTOM" then
        dir = "VERTICAL"
    end
    return p2, dir
end