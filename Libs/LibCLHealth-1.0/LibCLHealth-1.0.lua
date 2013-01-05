--[================[
LibCLHealth-1.0 
Provides unit health updates from combat log event.

Combat log events occur a lot more frequentrly than UNIT_HEALTH
This library tracks incoming healing and damage and adjusts health values.
As a result you can see health updates more frequent and sooner.

It's experimental and I haven't even tested it in actual raid or even dungeon.
But at worst you'll get incorrect value until next UNIT_HEALTH in case of messed up event order

Usage:
local f = CreateFrame("Frame") -- your addon
local LibCLHealth = LibStub("LibCLHealth-1.0")
LibCLHealth.RegisterCallback(f, "COMBAT_LOG_HEALTH", function(event, unit, health)
    print(event, unit, health)
end)

LibCLHealth:UnitHealth(unit) -- get unit current combatlog health
--]================]


local MAJOR, MINOR = "LibCLHealth-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end


lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.frame = lib.frame or CreateFrame("Frame")
lib.guidMap = lib.guidMap or {}
lib.unitMap = lib.unitMap or {}


local function blank_data(unit)
    return {
        { UnitHealth(unit) }, -- health log
        { GetTime() }, -- corresponding time log
        false, -- synchronization status
        0, -- first sync lost time
    }
end

lib.data = lib.data or  setmetatable({},{
    __mode = 'k',
})

local f = lib.frame
local callbacks = lib.callbacks
local guidMap =  lib.guidMap
local CLHealth = lib.data

local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local table_insert = table.insert
local table_remove = table.remove
local table_wipe = table.wipe
local select, unpack = select, unpack
local LOGLEN = 10

-- local DEBUG = true
-- local print = function(...)
--     if DEBUG then return print(...) end
-- end

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

function f:GROUP_ROSTER_UPDATE()
    table.wipe(guidMap)
    if IsInRaid() then
        for i=1,GetNumGroupMembers() do
            local unit = "raid"..i
            local guid = UnitGUID(unit)
            CLHealth[unit] = blank_data(unit)
            if guid then guidMap[guid] = unit end
        end
    else
        if IsInGroup() then
            for i=1, GetNumGroupMembers() - 1 do
                local unit = "party"..i
                local guid = UnitGUID(unit)
                CLHealth[unit] = blank_data(unit)
                if guid then guidMap[guid] = unit end
            end
        end
        local unit = "player"
        local guid = UnitGUID(unit)
        CLHealth[unit] = blank_data(unit)
        guidMap[guid] = unit
    end
end
f.PLAYER_LOGIN = f.GROUP_ROSTER_UPDATE


local function debug_mark_value(log, value)
    local str
    for i=1,#log do
        if log[i] == value then
            log[i] = string.format("|cffff2222%s|r",value)
            str = table.concat(log, " ")
            log[i] = value
        end
    end
    return str or "<NO MATCH>"
end


local olduh = 0
function f:UNIT_HEALTH(event, unit)
    local clh = rawget(CLHealth, unit)
    if not clh then return end

    local uh = UnitHealth(unit)
    local uht = GetTime()
    -- if unit == 'player' then
    --     local diff = uh - olduh
    --     local diffstr = string.format("|cff%s%s|r", diff > 0 and "00ff00" or "ff0000", diff)
    --     ChatFrame1:AddMessage(table.concat({GetTime(), "|cffffff55UNIT_HEALTH|r", uh,  diffstr}, "   "))
    --     ChatFrame3:AddMessage(table.concat({GetTime(), "|cffffff55----------------------|r"}, "   "))
    --     olduh = uh
    -- end

    local log, logtime, was_synced, sync_lost_time = unpack(clh)

    for i,hval in ipairs(log) do
        if hval == uh then
            if uht - logtime[i] < 2 then 
                clh[3] = true -- synchronized
                clh[4] = nil
                -- print(now, "synced", uh, "  |   ", debug_mark_value(log, uh))
                return true
            end
        end
    end

    clh[3] = false -- not synchronized
    if was_synced then
        clh[4] = GetTime()
    elseif uht - sync_lost_time > 1.3 then
        if log[2] then
            table_wipe(log)
            table_wipe(logtime)
        end
        log[1] = uh
        logtime[1] = uht
    end
    -- print(now, "__lost__", uh, "  |   ", unpack(log))

    callbacks:Fire("COMBAT_LOG_HEALTH", unit)
end

function f:COMBAT_LOG_EVENT_UNFILTERED(
                event, timestamp, eventType, hideCaster,
                srcGUID, srcName, srcFlags, srcFlags2,
                dstGUID, dstName, dstFlags, dstFlags2, ...)
    
    local unit = guidMap[dstGUID]
    if unit then
        local amount
        if(eventType == "SWING_DAMAGE") then --autoattack
            amount = -(...); -- putting in braces will autoselect the first arg, no need to use select(1, ...);
        elseif(eventType == "SPELL_PERIODIC_DAMAGE" or eventType == "SPELL_DAMAGE"
        or eventType == "DAMAGE_SPLIT" or eventType == "DAMAGE_SHIELD") then
            amount = -select(4, ...);
        elseif(eventType == "ENVIRONMENTAL_DAMAGE") then
            amount = -select(2, ...);
        elseif(eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL") then
            amount = select(4, ...) - select(5, ...) -- heal amount - overheal
            if amount == 0 then return end
        end
        -- print(GetTime(), eventType, amount)
        if amount then
            local clh = CLHealth[unit]
            if not clh then
                clh = blank_data(unit)
                CLHealth[unit] = clh
            end
            local log, logtime, synced = unpack(clh)
            local health = log[1]

            local newhealth = health + amount
            while #log > LOGLEN do table_remove(log); table_remove(logtime) end
            table_insert(log, 1, newhealth)
            table_insert(logtime, 1, GetTime())

            -- if unit == 'player' then
            --     local diff = amount
            --     local diffstr = string.format("|cff%s%s|r", diff > 0 and "00ff00" or "ff0000", amount)
            --     ChatFrame3:AddMessage(table.concat({GetTime(), eventType, newhealth,  diffstr}, "   "))
            -- end

            callbacks:Fire("COMBAT_LOG_HEALTH", unit)
        end
    end
end

function lib:UnitHealth(unit)
    local clh = rawget(CLHealth, unit)
    if clh and clh[3] then
        return clh[1][1]
    else
        return UnitHealth(unit)
    end
end

function callbacks.OnUsed()
    f:RegisterEvent"GROUP_ROSTER_UPDATE"
    f:RegisterEvent"PLAYER_LOGIN"
    f:RegisterEvent"COMBAT_LOG_EVENT_UNFILTERED"
    -- f:RegisterEvent"UNIT_HEALTH_FREQUENT"
    f:RegisterEvent"UNIT_HEALTH"
    f:GROUP_ROSTER_UPDATE()
end

function callbacks.OnUnused()
    f:UnregisterAllEvents()
end