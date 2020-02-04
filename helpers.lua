local _, helpers = ...

helpers.frame = CreateFrame("Frame","Aptechka",UIParent)

AptechkaDefaultConfig = {}
local config = AptechkaDefaultConfig
AptechkaUserConfig = AptechkaDefaultConfig

helpers.spellNameToID = {}

local pmult = 1
function helpers.pixelperfect(size)
    return floor(size/pmult + 0.5)*pmult
end

local res = GetCVar("gxWindowedResolution")
if res then
    local w,h = string.match(res, "(%d+)x(%d+)")
    pmult = (768/h) / UIParent:GetScale()
end

helpers.PercentColor = function(percent)
    if percent <= 0 then
        return 0, 1, 0
    elseif percent <= 0.5 then
        return percent*2, 1, 0
    elseif percent >= 1 then
        return 1, 0, 0
    else
        return 1, 2 - percent*2, 0
    end
end

helpers.BITMASK_DISEASE = 0xF000
helpers.BITMASK_POISON = 0x0F00
helpers.BITMASK_CURSE = 0x00F0
helpers.BITMASK_MAGIC = 0x000F
function helpers.DispelTypes(...)
    local numArgs = select("#", ...)
    local BITMASK_DISPELLABLE = 0
    for i=1, numArgs do
        local debuffType = select(i, ...)
        if debuffType == "Magic" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_MAGIC)
        elseif debuffType == "Poison" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_POISON)
        elseif debuffType == "Disease" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_DISEASE)
        elseif debuffType == "Curse" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_CURSE)
        end
    end
    return BITMASK_DISPELLABLE
end

local protomt = { __index = function(t,k) return t.prototype[k] end }
helpers.AddLoadableAura = function (data, todefault)
    if data.id then data.name = GetSpellInfo(data.id) end
    if data.name == nil then print (data.id.." spell id missing") return end

    if data.prototype then
        setmetatable(data, protomt)
    end

    if not data.type then data.type = "HELPFUL" end

    if not Aptechka.loadedAuras then Aptechka.loadedAuras = {} end
    Aptechka.loadedAuras[data.id] = data
end
helpers.AddAura = function (data, todefault)
    if type(data.id) == "table" then
        local clones = data.id
        data.id = table.remove(clones, 1) -- extract first spell id from the last as original
        data.clones = clones
    end

    if data.id and not data.name then data.name = GetSpellInfo(data.id) end
    if data.name == nil then print (data.id.." spell id missing") return end
    -- if data.isMine then data.type = data.type.."|PLAYER" end

    if data.prototype then -- metatables break because of config merging for gui
        -- setmetatable(data, { __index = function(t,k) return t.prototype[k] end })
        for k,v in pairs(data.prototype) do
            if not data[k] then
                data[k] = v
            end
        end
        data.prototype = nil
    end

    if not data.type then data.type = "HELPFUL" end

    if not config.auras then config.auras = {} end
    -- if not config.auras[data.type] then config.auras[data.type] = {} end
    config.auras[data.id] = data
end
helpers.AddAuraToDefault = function(data)
    helpers.AddAura(data,true)
end


helpers.AddSpellNameRecognition = function(lastRankID)
    helpers.spellNameToID[GetSpellInfo(lastRankID)] = lastRankID
end

helpers.AddTrace = function(data)
    if not config.enableTraceHeals then return end

    if type(data.id) == "table" then
        local clones = data.id
        data.id = table.remove(clones, 1) -- extract first spell id from the last as original
        data.clones = clones
    end

    if data.id then data.name = GetSpellInfo(data.id) or data.name end
    data.type = "SPELL_"..data.type
    if not config.traces then config.traces = {} end
    if not data.name then print((data.id or "nil").."id or name required") return end
    data.actualname = data.name

    data.name = data.actualname.."Trace"
    local id = data.id
    data.id = nil -- important to do that, because statuses with id field treated as aura
    config.traces[id] = data
end

helpers.AddDebuff = function (index, data)
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
    local hiddenParent = helpers.hiddenParent or CreateFrame('Frame', nil, UIParent)
    helpers.hiddenParent = hiddenParent
    hiddenParent:SetAllPoints()
    hiddenParent:Hide()
    for i=1,4 do
        local party = "PartyMemberFrame"..i
        local frame = _G[party]

        frame:UnregisterAllEvents()
        frame:Hide()
        frame:SetParent(hiddenParent)
        -- hooksecurefunc("ShowPartyFrame", HidePartyFrame)
        -- hooksecurefunc("PartyMemberFrame_UpdateMember", function(self)
            -- if not InCombatLockdown() then
                -- self:Hide()
            -- end
        -- end)

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

local UnitAuraSlots = UnitAuraSlots
local UnitAuraBySlot = UnitAuraBySlot

local function ForEachAuraHelper(unit, index, filter, func, continuationToken, ...)
    -- continuationToken is the first return value of UnitAuraSlots()
    local n = select('#', ...);
    for i=1, n do
        local slot = select(i, ...);
        local result = func(unit, index, slot, filter, UnitAuraBySlot(unit, slot))

        if result == -1 then
            -- if func returns -1 then no further slots are needed, so don't return continuationToken
            return nil;
        end

        index = index + (result or 1)
    end
    return continuationToken, index;
end

function helpers.ForEachAura(unit, filter, maxCount, func)
    if maxCount and maxCount <= 0 then
        return;
    end
    local continuationToken;
    local index = 1
    repeat
        -- continuationToken is the first return value of UnitAuraSltos
        continuationToken, index = ForEachAuraHelper(unit, index, filter, func, UnitAuraSlots(unit, filter, maxCount, continuationToken));
    until continuationToken == nil;

    return index
end


do
    local pow = math.pow
    local band = bit.band
    local bor = bit.bor
    function helpers.CheckBit(num, index)
        local n = pow(2,index-1)
        return band(num, n) > 0
    end

    function helpers.SetBit(num, index)
        local n = pow(2,index-1)
        return bor(num, n)
    end

    function helpers.UnsetBit(num, index)
        local n = pow(2,index-1)
        if n >= num then
            return num - n
        end
        return num
    end
end
