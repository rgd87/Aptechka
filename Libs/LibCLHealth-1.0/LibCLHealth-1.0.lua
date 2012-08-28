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

lib.data = lib.data or  setmetatable({},{
    __mode = 'k',
    __index = function (t,k)
        rawset(t,k, { {UnitHealth(k)}, { GetTime() } } )
        return t[k]
    end
})

local f = lib.frame
local callbacks = lib.callbacks
local guidMap =  lib.guidMap
local CLHealth = lib.data

local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local table_insert = table.insert
local table_remove = table.remove
local select, unpack = select, unpack


-- local DEBUG = true
-- local print = function(...)
--     if DEBUG then return print(...) end
-- end

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

f:RegisterEvent"GROUP_ROSTER_UPDATE"
f:RegisterEvent"PLAYER_LOGIN"

function f:GROUP_ROSTER_UPDATE()
    table.wipe(guidMap)
    if IsInRaid() then
        for i=1,GetNumGroupMembers() do
            local unit = "raid"..i
            local guid = UnitGUID(unit)
            if guid then guidMap[guid] = unit end
        end
    else
        if IsInGroup() then
            for i=1, GetNumGroupMembers() - 1 do
                local unit = "party"..i
                local guid = UnitGUID(unit)
                if guid then guidMap[guid] = unit end
            end
        end
        local unit = "player"
        local guid = UnitGUID(unit)
        guidMap[guid] = unit
    end
end
f.PLAYER_LOGIN = f.GROUP_ROSTER_UPDATE

f:RegisterEvent"COMBAT_LOG_EVENT_UNFILTERED"
f:RegisterEvent"UNIT_HEALTH"

function f:UNIT_HEALTH(event, unit)
    local clh = rawget(CLHealth, unit)
    if not clh then return end

    local uh = UnitHealth(unit)
    local uht = GetTime()

    local log, logtime, was_synced = unpack(clh)

    local synced = false
    for i,hval in ipairs(log) do
        if hval == uh then
            if uht - logtime[i] < 2 then 
                synced = true
                -- print(now, "synced", uh, "  |   ", unpack(log))
                return true
            end
        end
    end
    if not synced then
        -- print(now, "__lost__", uh, "  |   ", unpack(log))
        table_insert(log, 1, uh)
        table_insert(logtime, 1, uht)
    end
    clh[3] = synced
    callbacks:Fire("COMBAT_LOG_HEALTH", unit, log[1])
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
        if amount then
            local clh = CLHealth[unit]
            local log, logtime, synced = unpack(clh)
            local health = log[1]
            -- local health = synced and log[1] or UnitHealth(unit)

            local newhealth = health + amount
            while #log > 7 do table_remove(log); table_remove(logtime) end
            table_insert(log, 1, newhealth)
            table_insert(logtime, 1, GetTime())
            clh[3] = true

            callbacks:Fire("COMBAT_LOG_HEALTH", unit, newhealth)
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