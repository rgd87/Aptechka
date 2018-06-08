--[================[
LibCombatLogHealth-1.0 
Author: d87
Description: Provides unit health updates from combat log event.

Combat log events occur a lot more frequentrly than UNIT_HEALTH
This library tracks incoming healing and damage and adjusts health values.
As a result you can see health updates sooner and more often.

This implementation is safe and accurate.
For each unit we keep history of health values after each change from combat log.
When UNIT_HEALTH arrives, UnitHealth value is searched in this log.
If it's found, then chain is valid, and library proceeds to return latest value from it.
If not it falls back onto UnitHealth value. If UnitHealth values in the next 1.4 seconds
also could not be found to re-validate combat log chain,
then it is reset with current UnitHealth value as a starting point.


Why it's like that and not simplier
-----------------------------------

UNIT_HEALTH and CLEU are asynchronous, UNIT_AURA throttles and usually is slower,
but sometimes it comes first, and with CLEU immediately after it, double damage/healing
occurs. I'm avoiding that, keeping them separate
and only checking whether combat log value has deviated from UnitHealth.

UNIT_HEALTH_FREQUENT
--------------------

Afaik this new event, that was introduced in 5.0, still throttles damage, but not heals.
Or at least it doesn't mash up heals with damage.
In short, if you just listen to both UNIT_HEALTH and UNIT_HEALTH_FREQUENT,
that's a decent compromise.


Usage:

    local f = CreateFrame("Frame") -- your addon
    local LibCLHealth = LibStub("LibCombatLogHealth-1.0")
    if LibCLHealth then
        f:UnregisterEvent("UNIT_HEALTH")
        LibCLHealth.RegisterCallback(f, "COMBAT_LOG_HEALTH", function(event, unit, eventType)
            local health = LibCLHealth.UnitHealth(unit)
            print(event, unit, health)
        end)
    end

eventType - either nil when event comes from combat log, or "UNIT_AURA" to indicate
            events that can carry update to death/ghost states.

--]================]


local MAJOR, MINOR = "LibCombatLogHealth-1.0", 1.3
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end


lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.frame = lib.frame or CreateFrame("Frame")
lib.guidMap = lib.guidMap or {}

local LOG_HEALTH = 1
local LOG_TIME = 2
local SYNC = 3
local SYNC_TIME = 4

local function blank_data(unit)
    return {
        { UnitHealth(unit) }, -- health log
        { GetTime() }, -- corresponding time log
        true, -- synchronization status
        nil, -- time when sync was lost
    }
end

lib.data = lib.data or  {}

local f = lib.frame
local callbacks = lib.callbacks
local guidMap =  lib.guidMap
local CLHealth = lib.data
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local table_insert = table.insert
local table_remove = table.remove
local table_wipe = table.wipe
local select, unpack = select, unpack
local LOG_LENGTH = 8

local isGlobal = true

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

function f:GROUP_ROSTER_UPDATE()
    table_wipe(guidMap)
    table_wipe(CLHealth)
    if not isGlobal then
        local unit = "player"
        local guid = UnitGUID(unit)
        CLHealth[unit] = blank_data(unit)
        guidMap[guid] = unit
    elseif IsInRaid() then
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


-- local function debug_mark_value(log, value)
--     local str
--     for i=1,#log do
--         if log[i] == value then
--             log[i] = string.format("|cffff2222%s|r",value)
--             str = table.concat(log, " ")
--             log[i] = value
--         end
--     end
--     return str or "<NO MATCH>"
-- end

-- local olduh = 0
function f:UNIT_HEALTH(event, unit)
    local clh = rawget(CLHealth, unit)
    if not clh then
        callbacks:Fire("COMBAT_LOG_HEALTH", unit, event)
        return
    end

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
                clh[SYNC] = true -- synchronized
                clh[SYNC_TIME] = nil
                if not was_synced or uh == 0 then
                    -- Second condition: Library already sent update with 0,
                    -- but UnitIsDeadOrGhost function at that time still
                    -- returned old data. Sending it again.
                    callbacks:Fire("COMBAT_LOG_HEALTH", unit, event)
                end
                -- print(GetTime(), "synced", uh, "  |   ", debug_mark_value(log, uh))
                return true
            end
        end
    end

    clh[SYNC] = false -- not synchronized
    if was_synced then
        clh[SYNC_TIME] = GetTime()
    elseif not sync_lost_time or uht - sync_lost_time > 1.3 then
        if log[2] then
            table_wipe(log)
            table_wipe(logtime)
        end
        log[1] = uh
        logtime[1] = uht
    end
    -- print(GetTime(), "__lost__", uh, "  |   ", unpack(log))

    callbacks:Fire("COMBAT_LOG_HEALTH", unit, event)
end

function f:PLAYER_ENTERING_WORLD()
    for unit, data in pairs(CLHealth) do
        data[SYNC] = false
    end
end

function f:COMBAT_LOG_EVENT_UNFILTERED(event)

    local timestamp, eventType, hideCaster,
    srcGUID, srcName, srcFlags, srcFlags2,
    dstGUID, dstName, dstFlags, dstFlags2,
    arg1, arg2, arg3, arg4, arg5 = CombatLogGetCurrentEventInfo()
    
    local unit = guidMap[dstGUID]
    if unit then
        local amount
        if(eventType == "SWING_DAMAGE") then --autoattack
            amount = -arg1; -- putting in braces will autoselect the first arg, no need to use select(1, ...);
        elseif(eventType == "SPELL_PERIODIC_DAMAGE" or eventType == "SPELL_DAMAGE"
        or eventType == "DAMAGE_SPLIT" or eventType == "DAMAGE_SHIELD") then
            amount = -arg4;
        elseif(eventType == "ENVIRONMENTAL_DAMAGE") then
            amount = -arg2;
        elseif(eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL") then
            amount = arg4 - arg5 -- heal amount - overheal
            if amount == 0 then return end
        end

        if amount then
            local clh = CLHealth[unit]
            if not clh then
                clh = blank_data(unit)
                CLHealth[unit] = clh
            end
            local log, logtime, was_synced = unpack(clh)
            local health = log[1]

            -- add new health value to chain
            local newhealth = health + amount
            while #log > LOG_LENGTH do table_remove(log); table_remove(logtime) end
            table_insert(log, 1, newhealth)
            table_insert(logtime, 1, GetTime())

            -- if unit == 'player' then
            --     local diff = amount
            --     local diffstr = string.format("|cff%s%s|r", diff > 0 and "00ff00" or "ff0000", amount)
            --     ChatFrame3:AddMessage(table.concat({GetTime(), eventType, newhealth,  diffstr}, "   "))
            -- end

            if was_synced then
                callbacks:Fire("COMBAT_LOG_HEALTH", unit)
            end
        end
    end
end

function lib.UnitHealth(unit)
    local clh = rawget(CLHealth, unit)
    if clh and clh[SYNC] then
        return clh[LOG_HEALTH][1]
    else
        return UnitHealth(unit)
    end
end

-- function lib.RegisterUnit(unit)
    -- allowedUnits[unit] = true
-- end

function callbacks.OnUsed()
    f:RegisterEvent"GROUP_ROSTER_UPDATE"
    f:RegisterEvent"PLAYER_LOGIN"
    f:RegisterEvent"PLAYER_ENTERING_WORLD"
    f:RegisterEvent"COMBAT_LOG_EVENT_UNFILTERED"
    -- f:RegisterEvent"UNIT_HEALTH_FREQUENT"
    f:RegisterEvent"UNIT_HEALTH"
    if not UnitGUID("player") then return end -- for cases when they aren't available yet
    f:GROUP_ROSTER_UPDATE()
end

function callbacks.OnUnused()
    f:UnregisterAllEvents()
end