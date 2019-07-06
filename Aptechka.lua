local _, helpers = ...

Aptechka = CreateFrame("Frame","Aptechka",UIParent)
local Aptechka = Aptechka

Aptechka:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

--- Compatibility with Classic
local isClassic = select(4,GetBuildInfo()) <= 19999
local dummyFalse = function() return false end
local dummy0 = function() return 0 end
local dummyNil = function() return nil end
local UnitHasVehicleUI = isClassic and dummyFalse or _G.UnitHasVehicleUI
local UnitInVehicle = isClassic and dummyFalse or _G.UnitInVehicle
local UnitUsingVehicle = isClassic and dummyFalse or _G.UnitUsingVehicle
local UnitGetIncomingHeals = isClassic and dummy0 or _G.UnitGetIncomingHeals
local UnitGetTotalAbsorbs = isClassic and dummy0 or _G.UnitGetTotalAbsorbs
local UnitThreatSituation = isClassic and dummy0 or _G.UnitThreatSituation
local UnitGroupRolesAssigned = isClassic and dummyNil or _G.UnitGroupRolesAssigned
local UnitIsWarModePhased = isClassic and dummyFalse or _G.UnitIsWarModePhased
local UnitInPhase = isClassic and function() return true end or _G.UnitInPhase
local GetSpecialization = isClassic and function() return 1 end or _G.GetSpecialization
local GetSpecializationInfo = isClassic and function() return "DAMAGER" end or _G.GetSpecializationInfo

-- AptechkaUserConfig = setmetatable({},{ __index = function(t,k) return AptechkaDefaultConfig[k] end })
-- When AptechkaUserConfig __empty__ field is accessed, it will return AptechkaDefaultConfig field

local AptechkaUnitInRange
local uir -- current range check function
local auras
local dtypes
local debuffs
local traceheals
local colors
local threshold --incoming heals
local ignoreplayer

local config = AptechkaDefaultConfig
Aptechka.loadedAuras = {}
local loadedAuras = Aptechka.loadedAuras
local customBossAuras = helpers.customBossAuras
local default_blacklist = helpers.auraBlacklist
local blacklist
local OORUnits = setmetatable({},{__mode = 'k'})
local inCL = setmetatable({},{__index = function (t,k) return 0 end})
local buffer = {}
local loaded = {}
local auraUpdateEvents
local Roster = {}
local guidMap = {}
local group_headers = {}
local missingFlagSpells = {}
local anchors = {}
local skinAnchorsName

local LastCastSentTime = 0
local LastCastTargetName

local AptechkaString = "|cffff7777Aptechka: |r"
local GetTime = GetTime
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitAura = UnitAura
local UnitAffectingCombat = UnitAffectingCombat
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local customColors
local table_wipe = table.wipe
local SetJob
local FrameSetJob
local DispelFilter

local pixelperfect = helpers.pixelperfect

local bit_band = bit.band
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local pairs = pairs
local next = next
local _, helpers = ...
Aptechka.helpers = helpers
local utf8sub = helpers.utf8sub
local reverse = helpers.Reverse
local AptechkaDB = {}
local LibSpellLocks
local LibAuraTypes
local LibClassicDurations = LibStub("LibClassicDurations")
local tinsert = table.insert
local tsort = table.sort
local CreatePetsFunc


local defaults = {
    growth = "up",
    width = 55,
    height = 55,
    unitGrowth = "RIGHT",
    groupGrowth = "TOP",
    unitGap = 7,
    groupGap = 7,
    showSolo = true,
    cropNamesLen = 7,
    disableBlizzardParty = true,
    hideBlizzardRaid = true,
    petGroup = false,
    sortUnitsByRole = false,
    showAFK = false,
    healthOrientation = "VERTICAL",
    customBlacklist = {},
    healthTexture = "Gradient",
    powerTexture = "Gradient",
    invertedColors = false,
    forceShamanColor = true,
    useCombatLogHealthUpdates = false,
    useDebuffOrdering = true,
    disableTooltip = false,
    scale = 1,
    autoscale = {
        damageMediumRaid = 0.8,
        damageBigRaid = 0.7,
        healerMediumRaid = 1,
        healerBigRaid = 0.8,
    }
}

local function SetupDefaults(t, defaults)
    if not defaults then return end
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            elseif t[k] == false then
                t[k] = false --pass
            else
                SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
            if t[k] == "__REMOVED__" then t[k] = nil end
        end
    end
end
Aptechka.SetupDefaults = SetupDefaults

local function RemoveDefaults(t, defaults)
    if not defaults then return end
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end
Aptechka.RemoveDefaults = RemoveDefaults

local function RemoveDefaultsPreserve(t, defaults)
    if not defaults then return end
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            RemoveDefaultsPreserve(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == nil and v ~= nil then
            t[k] = "__REMOVED__"
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end
Aptechka.RemoveDefaultsPreserve = RemoveDefaultsPreserve

local function MergeTable(t1, t2)
    if not t2 then return false end
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if t1[k] == nil then
                t1[k] = CopyTable(v)
            else
                MergeTable(t1[k], v)
            end
        elseif v == "__REMOVED__" then
            t1[k] = nil
        else
            t1[k] = v
        end
    end
    return t1
end
Aptechka.MergeTable = MergeTable

Aptechka:RegisterEvent("PLAYER_LOGIN")
Aptechka:RegisterEvent("PLAYER_LOGOUT")
function Aptechka.PLAYER_LOGIN(self,event,arg1)
    Aptechka:UpdateRangeChecker()
    local uir2 = function(unit)
		if UnitIsDeadOrGhost(unit) then --IsSpellInRange doesn't work with dead people
			return UnitInRange(unit)
		else
			return uir(unit)
		end
    end

    AptechkaUnitInRange = uir2

    AptechkaDB_Global = AptechkaDB_Global or {}
    AptechkaDB_Char = AptechkaDB_Char or {}
    AptechkaDB_Global.charspec = AptechkaDB_Global.charspec or {}
    local user = UnitName("player").."@"..GetRealmName()
    if AptechkaDB_Global.charspec[user] then
        AptechkaDB = AptechkaDB_Char
    else
        AptechkaDB = AptechkaDB_Global
    end
    Aptechka.db = AptechkaDB
    SetupDefaults(AptechkaDB, defaults)

    Aptechka.SetJob = SetJob
    Aptechka.FrameSetJob = FrameSetJob
    threshold = UnitHealthMax("player")/40
    ignoreplayer = config.incomingHealIgnorePlayer or false
    if AptechkaDB.forceShamanColor and not CUSTOM_CLASS_COLORS then
        customColors = {
            SHAMAN = {
                b=0.86666476726532,
                g=0.4392147064209,
                r=0,
            }
        }
    end
    -- CUSTOM_CLASS_COLORS is from phanx's ClassColors addons
    colors = setmetatable(customColors or {},{ __index = function(t,k) return (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[k] end })

    blacklist = setmetatable(AptechkaDB.customBlacklist, { __index = default_blacklist})

    AptechkaConfigCustom = AptechkaConfigCustom or {}
    AptechkaConfigMerged = CopyTable(AptechkaDefaultConfig)
    config = AptechkaConfigMerged
    config.DebuffTypes = config.DebuffTypes or {}
    config.DebuffDisplay = config.DebuffDisplay or {}
    config.auras = config.auras or {}
    config.traces = config.traces or {}
    auras = config.auras
    traceheals = config.traces
    dtypes = config.DebuffTypes
    debuffs = config.DebuffDisplay

    local _, class = UnitClass("player")
    local categories = {"auras", "traces"}
    if not AptechkaConfigCustom[class] then AptechkaConfigCustom[class] = {} end

    local globalConfig = AptechkaConfigCustom["GLOBAL"]
    MergeTable(AptechkaConfigMerged, globalConfig)
    local classConfig = AptechkaConfigCustom[class]
    MergeTable(AptechkaConfigMerged, classConfig)


    -- compiling a list of spells that should activate indicator when missing
    self:UpdateMissingAuraList()

    -- filling up ranks for auras
    local cloneIDs = {}
    local rankCategories = { "auras", "traces" }
    local tempTable = {}
    for _, category in ipairs(rankCategories) do
        table.wipe(tempTable)
        for spellID, opts in pairs(config[category]) do
            if not cloneIDs[spellID] and opts.clones then
                for i, additionalSpellID in ipairs(opts.clones) do
                    tempTable[additionalSpellID] = opts
                    cloneIDs[additionalSpellID] = true
                end
            end
        end
        for spellID, opts in pairs(tempTable) do
            config[category][spellID] = opts
        end
    end
    config.spellClones = cloneIDs

    for spellID, originalSpell in pairs(traceheals) do
        if not cloneIDs[spellID] and originalSpell.clones then
			for i, additionalSpellID in ipairs(originalSpell.clones) do
                traceheals[additionalSpellID] = originalSpell
                cloneIDs[additionalSpellID] = true
			end
		end
    end



    Aptechka.Roster = Roster

    if AptechkaDB.disableBlizzardParty then
        helpers.DisableBlizzParty()
    end
    if AptechkaDB.hideBlizzardRaid then
        -- disable Blizzard party & raid frame if our Raid Frames are loaded
        -- InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
        -- InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
        -- raid
        local hider = CreateFrame("Frame")
        hider:Hide()
        if CompactRaidFrameManager then
            CompactRaidFrameManager:SetParent(hider)
            -- CompactRaidFrameManager:UnregisterAllEvents()
            CompactUnitFrameProfiles:UnregisterAllEvents()

            local disableCompactRaidFrameUnitButton = function(self)
                -- for some reason CompactUnitFrame_OnLoad also gets called for nameplates, so ignoring that
                local frameName = self:GetName()
                if string.sub(frameName, 1, 16) == "CompactRaidFrame" then
                    -- print(frameName)
                    self:UnregisterAllEvents()
                end
            end

            for i=1,60 do
                local crf = _G["CompactRaidFrame"..i]
                if not crf then break end
                disableCompactRaidFrameUnitButton(crf)
            end
            hooksecurefunc("CompactUnitFrame_OnLoad", disableCompactRaidFrameUnitButton)
            hooksecurefunc("CompactUnitFrame_UpdateUnitEvents", disableCompactRaidFrameUnitButton)
        end
	end

    if config.enableIncomingHeals then
        self:RegisterEvent("UNIT_HEAL_PREDICTION")
    end

    if not config[config.skin.."Settings"]
        then config["GridSkinSettings"]()
        else config[config.skin.."Settings"]() -- receiving width and height for current skin
    end

    -- local tbind
    -- if config.TargetBinding == nil then tbind = "*type1"
    -- elseif config.TargetBinding == false then tbind = "__none__"
    -- else tbind = config.TargetBinding end

    -- local ccmacro = config.ClickCastingMacro or "__none__"

    local width = pixelperfect(AptechkaDB.width or config.width)
    local height = pixelperfect(AptechkaDB.height or config.height)
    -- local scale = AptechkaDB.scale or config.scale
    local strata = config.frameStrata or "LOW"
    local scale = 1
    self.makeConfSnippet = function(...)
        return string.format([=[
            RegisterUnitWatch(self)

            self:SetWidth(%f)
            self:SetHeight(%f)
            self:SetFrameStrata("%s")
            self:SetFrameLevel(3)

            self:SetAttribute("toggleForVehicle", true)
            self:SetAttribute("allowVehicleTarget", false)

            self:SetAttribute("*type1","target")
            self:SetAttribute("shift-type2","togglemenu")

            local header = self:GetParent()
            local ccheader = header:GetFrameRef("clickcast_header")
            if ccheader then
                ccheader:SetAttribute("clickcast_button", self)
                ccheader:RunAttribute("clickcast_register")
            end
            header:CallMethod("initialConfigFunction", self:GetName())
        ]=], ...)
    end
    self.initConfSnippet = self.makeConfSnippet(width, height, strata)

    self:LayoutUpdate()

    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_HEALTH_FREQUENT")
    self:RegisterEvent("UNIT_MAXHEALTH")
    Aptechka.UNIT_HEALTH_FREQUENT = Aptechka.UNIT_HEALTH
    Aptechka.UNIT_MAXHEALTH = Aptechka.UNIT_HEALTH
    self:RegisterEvent("UNIT_CONNECTION")
    if AptechkaDB.showAFK then
        self:RegisterEvent("PLAYER_FLAGS_CHANGED") -- UNIT_AFK_CHANGED
    end

    self:RegisterEvent("UNIT_PHASE")

    if not config.disableManaBar then
        self:RegisterEvent("UNIT_POWER_UPDATE")
        self:RegisterEvent("UNIT_MAXPOWER")
        self:RegisterEvent("UNIT_DISPLAYPOWER")
        Aptechka.UNIT_MAXPOWER = Aptechka.UNIT_POWER_UPDATE
    end
    if config.AggroStatus then
        self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    end
    if config.ReadyCheck then
        self:RegisterEvent("READY_CHECK")
        self:RegisterEvent("READY_CHECK_CONFIRM")
        self:RegisterEvent("READY_CHECK_FINISHED")
    end
    if config.TargetStatus then
        self.previousTarget = "player"
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end

    if config.VoiceChatStatus then
        self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED")
        self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED")
        if (C_VoiceChat.GetActiveChannelType()) then
            self:VOICE_CHAT_CHANNEL_ACTIVATED()
        end
    end

    self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    self.INCOMING_RESURRECT_CHANGED = self.UNIT_PHASE

    if LibClassicDurations then
        LibClassicDurations:RegisterFrame(self)
    end

    LibAuraTypes = LibStub("LibAuraTypes")
    if AptechkaDB.useDebuffOrdering then
        LibSpellLocks = LibStub("LibSpellLocks")

        LibSpellLocks.RegisterCallback(self, "UPDATE_INTERRUPT", function(event, guid)
            local unit = guidMap[guid]
            if unit then
                Aptechka.ScanDebuffSlots(unit)
            end
        end)

        Aptechka.ScanDebuffSlots = Aptechka.OrderedScanDebuffSlots
    else
        Aptechka.ScanDebuffSlots = Aptechka.SimpleScanDebuffSlots
    end

    if config.enableAbsorbBar then
        self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    end

    if AptechkaDB.useCombatLogHealthUpdates then
        local CLH = LibStub("LibCombatLogHealth-1.0")
        UnitHealth = CLH.UnitHealth
        self:UnregisterEvent("UNIT_HEALTH")
        self:UnregisterEvent("UNIT_HEALTH_FREQUENT")
        -- table.insert(config.HealthBarColor.assignto, "health2")
        CLH.RegisterCallback(self, "COMBAT_LOG_HEALTH", function(event, unit, eventType)
            return Aptechka:UNIT_HEALTH(eventType, unit)
            -- return Aptechka:COMBAT_LOG_HEALTH(nil, unit, health)
        end)
    end

    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    if config.raidIcons then
        self:RegisterEvent("RAID_TARGET_UPDATE")
    end
    if config.enableVehicleSwap then
        self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    end

    if not config.anchorpoint then
        config.anchorpoint = Aptechka:SetAnchorpoint()
    end

    skinAnchorsName = config.useAnchors or config.skin
    local i = 1
    while (i <= config.maxgroups) do
        local f  = Aptechka:CreateHeader(i) -- if second arg is true then it's petgroup
        group_headers[i] = f
        i = i + 1
    end
    CreatePetsFunc = function()
        local pets  = Aptechka:CreateHeader(9,true)
        group_headers[9] = pets
    end
    if AptechkaDB.petGroup then
        CreatePetsFunc()
    end
    if config.unlocked then anchors[1]:Show() end

    if not next(debuffs) and not next(dtypes) then
        Aptechka.ScanDebuffSlots = function() end
    end
    -- if config.DispelFilterAll
    --     then DispelFilter = "HARMFUL"
    --     else DispelFilter = "HARMFUL|RAID"
    -- end

    Aptechka:SetScript("OnUpdate",Aptechka.OnRangeUpdate)
    Aptechka:Show()

    SLASH_APTECHKA1= "/aptechka"
    SLASH_APTECHKA2= "/apt"
    SLASH_APTECHKA3= "/inj"
    SLASH_APTECHKA4= "/injector"
    SlashCmdList["APTECHKA"] = Aptechka.SlashCmd

    SLASH_APTROLEPOLL1= "/rolepoll"
    SLASH_APTROLEPOLL2= "/rolecheck"
    SlashCmdList["APTROLEPOLL"] = InitiateRolePoll

    if config.LOSStatus then
        self:RegisterEvent("UNIT_SPELLCAST_SENT")
        self:RegisterEvent("UI_ERROR_MESSAGE")
    end

    if config.enableTraceHeals and next(traceheals) then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self.COMBAT_LOG_EVENT_UNFILTERED = function( self, event)
            local timestamp, eventType, hideCaster,
            srcGUID, srcName, srcFlags, srcFlags2,
            dstGUID, dstName, dstFlags, dstFlags2,
            spellID, spellName, spellSchool, amount, overhealing, absorbed, critical = CombatLogGetCurrentEventInfo()
            if bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE then
                local opts = traceheals[spellID]
                if opts and eventType == opts.type then
                    if guidMap[dstGUID] then
                        local minamount = opts.minamount
                        if not minamount or amount > minamount then
                            SetJob(guidMap[dstGUID],opts,true)
                        end
                    end
                end
            end
        end

    end

    -- --autoloading
    for _,spell_group in pairs(config.autoload) do
        config.LoadableDebuffs[spell_group]()
        loaded[spell_group] = true
    end
    --raid/pvp debuffs loading
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    loader:RegisterEvent("PLAYER_ENTERING_WORLD")
    local mapIDs = config.MapIDs

    local CheckCurrentMap = function()
        local instance
        local _, instanceType = GetInstanceInfo()
        if instanceType == "arena" or instanceType == "pvp" then
            instance = "PvP"
        else
            local uiMapID = C_Map.GetBestMapForUnit("player")
            instance = mapIDs[uiMapID]
        end
        if not instance then return end
        local add = config.LoadableDebuffs[instance]
        if add and not loaded[instance] then
            add()
            print (AptechkaString..instance.." debuffs loaded.")
            loaded[instance] = true
        end
    end

    loader:SetScript("OnEvent",function (self,event)
        C_Timer.After(2, CheckCurrentMap)
    end)




    -- if config.useCombatLogFiltering then
    --     local timer = CreateFrame("Frame")
    --     timer.OnUpdateCounter = 0
    --     timer:SetScript("OnUpdate",function(self, time)
    --         self.OnUpdateCounter = self.OnUpdateCounter + time
    --         if self.OnUpdateCounter < 1 then return end
    --         self.OnUpdateCounter = 0
    --         for unit in pairs(buffer) do
    --             Aptechka.ScanAuras(unit)
    --             buffer[unit] = nil
    --         end
    --     end)

    --     Aptechka.UNIT_AURA = function(self, event, unit)
    --         if not Roster[unit] then return end
    --         Aptechka.ScanDispels(unit)
    --         if OORUnits[unit] and inCL[unit] +5 < GetTime() then
    --             buffer[unit] = true
    --         end
    --     end

    --     auraUpdateEvents = {
    --         ["SPELL_AURA_REFRESH"] = true,
    --         ["SPELL_AURA_APPLIED"] = true,
    --         ["SPELL_AURA_APPLIED_DOSE"] = true,
    --         ["SPELL_AURA_REMOVED"] = true,
    --         ["SPELL_AURA_REMOVED_DOSE"] = true,
    --     }
    --     if select(2,UnitClass("player")) == "SHAMAN" then auraUpdateEvents["SPELL_HEAL"] = true end
    --     local cleuEvent = CreateFrame("Frame")
    --     cleuEvent:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    --     cleuEvent:SetScript("OnEvent",
    --     function( self, event, timestamp, eventType, hideCaster,
    --                     srcGUID, srcName, srcFlags, srcFlags2,
    --                     dstGUID, dstName, dstFlags, dstFlags2,
    --                     spellID, spellName, spellSchool, auraType, amount)
    --         if auras[spellName] then
    --             if auraUpdateEvents[eventType] then
    --                 local unit = guidMap[dstGUID]
    --                 if unit then
    --                     buffer[unit] = nil
    --                     inCL[unit] = GetTime()
    --                     Aptechka.ScanAuras(unit)
    --                 end
    --             end
    --         end
    --     end)
    -- end

    local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
    f:SetScript('OnShow', function(self)
        self:SetScript('OnShow', nil)
        LoadAddOn('AptechkaOptions')
    end)
end  -- END PLAYER_LOGIN

function Aptechka.PLAYER_LOGOUT(self, event)
    RemoveDefaults(AptechkaDB, defaults)
end


function Aptechka:ToggleCompactRaidFrames()
	local v = IsAddOnLoaded("Blizzard_CompactRaidFrames")
	local f = v and DisableAddOn or EnableAddOn
	f("Blizzard_CompactRaidFrames")
    f("Blizzard_CUFProfiles")
    ReloadUI()
end

function Aptechka:PostSpellListUpdate()
    self:UpdateMissingAuraList()
    for unit, frames in pairs(Roster) do
        self:UNIT_AURA(nil, unit)
    end
end

function Aptechka:UpdateMissingAuraList()
    table.wipe(missingFlagSpells)
    for spellID, opts in pairs(auras) do
        if opts.isMissing and not opts.disabled then
            missingFlagSpells[opts] = true
        end
    end
end

function Aptechka:Reconfigure()
    self:ReconfigureUnprotected()
    self:ReconfigureProtected()
end
function Aptechka:ReconfigureUnprotected()
    for group, header in ipairs(group_headers) do
        for _, f in ipairs({ header:GetChildren() }) do
            f:ReconfigureUnitFrame()
        end
    end
end
function Aptechka:ReconfigureProtected()
    if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end

    local width = pixelperfect(AptechkaDB.width or config.width)
    local height = pixelperfect(AptechkaDB.height or config.height)
    -- local scale = AptechkaDB.scale or config.scale
    local strata = config.frameStrata or "LOW"
    local scale = 1
    self.initConfSnippet = self.makeConfSnippet(width, height, strata)
    for group, header in ipairs(group_headers) do

        for _, f in ipairs({ header:GetChildren() }) do
            f:SetWidth(width)
            f:SetHeight(height)
            f:SetScale(scale)
            if f:CanChangeAttribute() then
                f:SetAttribute("initial-width", width)
                f:SetAttribute("initial-height", height)
            end
        end

        local showSolo = AptechkaDB.showSolo
        header:SetAttribute("showSolo", showSolo)

        -- header:SetAttribute("initialConfigFunction", self.initConfSnippet)

        -- local xgap = AptechkaDB.unitGap or config.unitGap
        -- local ygap = AptechkaDB.unitGap or config.unitGap
        -- local unitGrowth = AptechkaDB.unitGrowth or config.unitGrowth
        -- local groupGrowth = AptechkaDB.groupGrowth or config.groupGrowth
        -- local unitgr = reverse(unitGrowth)
        -- if unitgr == "RIGHT" then
        --     xgap = -xgap
        -- elseif unitgr == "TOP" then
        --     ygap = -ygap
        -- end
        -- header:SetAttribute("point", unitgr)
        -- header:SetAttribute("xOffset", xgap)
        -- header:SetAttribute("yOffset", ygap)

        -- if group >= 2 then
        --     f:SetPoint(arrangeHeaders(group_headers[group-1], nil, unitGrowth, groupGrowth))
        -- end



    end

    local unitGrowth = AptechkaDB.unitGrowth or config.unitGrowth
    local groupGrowth = AptechkaDB.groupGrowth or config.groupGrowth
    Aptechka:SetGrowth(unitGrowth, groupGrowth)
end

function Aptechka.UNIT_HEAL_PREDICTION(self,event,unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local heal = UnitGetIncomingHeals(unit)
		-- print(heal)
        if ignoreplayer then
            local myheal = UnitGetIncomingHeals(unit, "player")
            if heal and myheal then heal = heal - myheal end
        end
        local showHeal = (heal and heal > threshold)
        if self.health.incoming then
			local h = UnitHealth(unit)
			local hi = showHeal and heal or 0
			local hm = UnitHealthMax(unit)
			self.health.incoming.current = hi
            self.health.incoming:Update(h, hi, hm)
			-- SetValue( showHeal and self.health:GetValue()+(heal/UnitHealthMax(unit)*100) or 0)
        end
        -- if config.IncomingHealStatus then
        --     if showHeal then
        --         self.vIncomingHeal = heal
        --         SetJob(unit, config.IncomingHealStatus, true)
        --     else
        --         self.vIncomingHeal = 0
        --         SetJob(unit, config.IncomingHealStatus, false)
        --     end
        -- end
    end
end

-- function Aptechka.COMBAT_LOG_HEALTH(self, event, unit, h)
--     if not Roster[unit] then return end
--     -- print(event, unit, UnitHealth(unit))
--     for self in pairs(Roster[unit]) do
--         local hm = UnitHealthMax(unit)
--         if hm == 0 then return end
--         self.health2:SetValue(h/hm*100)
--     end
-- end


function Aptechka.UNIT_ABSORB_AMOUNT_CHANGED(self, event, unit)
    local rosterunit = Roster[unit]
    if not rosterunit then return end
    for self in pairs(rosterunit) do
        local a,hm = UnitGetTotalAbsorbs(unit), UnitHealthMax(unit)
        local h = UnitHealth(unit)
        local ch, p, p2 = 0,0,0
        if hm ~= 0 then
            ch = (h/hm)*100
		    p = a/hm*100
            p2 = (h+a)/hm*100
        end
        self.absorb:SetValue(p, ch)
        self.absorb2:SetValue(p2)
    end
end

function Aptechka.UNIT_HEALTH(self, event, unit)
    local rosterunit = Roster[unit]
    if not rosterunit then return end
    for self in pairs(rosterunit) do
        local h,hm = UnitHealth(unit), UnitHealthMax(unit)
        local shields = UnitGetTotalAbsorbs(unit)
        if hm == 0 then return end
        self.vHealth = h
        self.vHealthMax = hm
        self.health:SetValue(h/hm*100)
        self.absorb:SetValue(shields/hm*100, h/hm*100)
        self.absorb2:SetValue((h+shields)/hm*100)
		self.health.incoming:Update(h, nil, hm)
        SetJob(unit,config.HealthDeficitStatus, ((hm-h) > hm*0.05) )

        if event then
            if UnitIsDeadOrGhost(unit) then
                SetJob(unit, config.AggroStatus, false)
                local deadorghost = UnitIsGhost(unit) and config.GhostStatus or config.DeadStatus
                SetJob(unit, deadorghost, true)
                SetJob(unit,config.HealthDeficitStatus, false )
                self.isDead = true
                if self.OnDead then self:OnDead() end
            elseif self.isDead then
                self.isDead = false
                Aptechka.ScanAuras(unit)
                Aptechka.ScanDebuffSlots(unit)
                SetJob(unit, config.GhostStatus, false)
                SetJob(unit, config.DeadStatus, false)
                SetJob(unit, config.ResPendingStatus, false)
                SetJob(unit, config.ResIncomingStatus, false)
                if self.OnAlive then self:OnAlive() end
            end
        end

    end
end


function Aptechka:CheckPhase(frame, unit)
    if UnitHasIncomingResurrection(unit) then
        frame.centericon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez");
        frame.centericon.texture:SetTexCoord(0,1,0,1);
        frame.centericon:Show()
    elseif (not UnitInPhase(unit) or UnitIsWarModePhased(unit)) and not frame.InVehicle then
        frame.centericon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
        frame.centericon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
        frame.centericon:Show()
        FrameSetJob(frame, config.PhasedOutStatus, true)
    else
        frame.centericon:Hide()
        FrameSetJob(frame, config.PhasedOutStatus, false)
    end
end
function Aptechka:CheckPhase1(unit)
    local rosterunit = Roster[unit]
    if not rosterunit then return end
    for frame in pairs(rosterunit) do
        Aptechka:CheckPhase(frame, unit)
    end
end

function Aptechka.UNIT_PHASE(self, event, unit)
    for unit, frames in pairs(Roster) do
        for frame in pairs(frames) do
            Aptechka:CheckPhase(frame,unit)
        end
    end
end

local afkPlayerTable = {}
function Aptechka.UNIT_AFK_CHANGED(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local name = UnitGUID(unit)
        if UnitIsAFK(unit) then
            if name then
                local startTime = afkPlayerTable[name]
                if not startTime then
                    startTime = GetTime()
                    afkPlayerTable[name] = startTime
                end

                local job = config.AwayStatus
                job.startTime = startTime
            end
            SetJob(unit, config.AwayStatus, true)
        else
            if name then
                afkPlayerTable[name] = nil
            end
            SetJob(unit, config.AwayStatus, false)
        end
    end
end
Aptechka.PLAYER_FLAGS_CHANGED = Aptechka.UNIT_AFK_CHANGED


local offlinePlayerTable = {}
function Aptechka.UNIT_CONNECTION(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        -- if self.unitOwner then unit = self.unitOwner end
        local name = UnitGUID(unit)
        if not UnitIsConnected(unit) then
            if name then
                local startTime = offlinePlayerTable[name]
                if not startTime then
                    startTime = GetTime()
                    offlinePlayerTable[name] = startTime
                end

                local job = config.OfflineStatus
                job.startTime = startTime
            end
            SetJob(unit, config.OfflineStatus, true)
        else
            if name then
                offlinePlayerTable[name] = nil
            end
            SetJob(unit, config.OfflineStatus, false)
        end
    end
end

function Aptechka.UNIT_POWER_UPDATE(self, event, unit, ptype)
    local rosterunit = Roster[unit]
    if not rosterunit then return end
    for self in pairs(rosterunit) do
        if self.power and not self.power.disabled then
            local powermax = UnitPowerMax(unit)
            local mp = 0
            if powermax > 0 then
                mp = UnitPower(unit)/UnitPowerMax(unit)*100
            end
            self.power:SetValue(mp)
        end
    end
end
function Aptechka.UNIT_DISPLAYPOWER(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if self.power and self.power.OnPowerTypeChange then
            local tnum, tname = UnitPowerType(unit)
            self.power:OnPowerTypeChange(tname)
        end
    end
end

-- STAY AWAY FROM DA VOODOO
local vehicleHack = function (self, time)
    self.OnUpdateCounter = self.OnUpdateCounter + time
    if self.OnUpdateCounter < 1 then return end
    self.OnUpdateCounter = 0
    local owner = self.parent.unitOwner
    if not ( UnitHasVehicleUI(owner) or UnitInVehicle(owner) or UnitUsingVehicle(owner) ) then
        if Roster[self.parent.unit] then
            -- local original_unit = self.parent.unit
            -- print(string.format("L1>>Unit: %s-",original_unit))
            -- print(string.format("L1>>Unit- Owner: %s",self.parent.unitOwner))
            -- print(string.format("D3>>-Dumping Roster"))
            -- d87add.dump("ROSTER")-
            -- print(string.format("Restoring %s <- %s", owner, self.parent.unit) )
            Roster[owner] = Roster[self.parent.unit]
            Roster[self.parent.unit] = nil
            self.parent.unit = owner
            self.parent.unitOwner = nil
            self.parent.guid = UnitGUID(owner)
            self.parent.InVehicle = nil

            -- print(string.format("L1>>Unit: %-s",original_unit))
            -- print(string.format("D4>[%s]>Dumping- Roster",NAME))
            -- d87add.dump("ROSTER")-

            SetJob(owner,config.InVehicleStatus,false)
            Aptechka:UNIT_HEALTH("VEHICLE",owner)
            if self.parent.power then
                Aptechka:UNIT_DISPLAYPOWER(nil, owner)
                Aptechka:UNIT_POWER_UPDATE(nil,owner)
            end
			if self.parent.absorb then
				Aptechka:UNIT_ABSORB_AMOUNT_CHANGED(nil, owner)
			end
            Aptechka.ScanAuras(owner)

            self:SetScript("OnUpdate",nil)
        end
    end
end
function Aptechka.UNIT_ENTERED_VEHICLE(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if not self.InVehicle then --print("Already in vehicle")
            local vehicleUnit = SecureButton_GetModifiedUnit(self)
            if unit ~= vehicleUnit then
                self.InVehicle = true
                self.unitOwner = unit --original unit
                self.unit = vehicleUnit

                Aptechka:Colorize(nil, self.unitOwner)
                self.guid = UnitGUID(vehicleUnit)
                if self.guid then guidMap[self.guid] = vehicleUnit end

                -- print(string.format("Overriding %s with %s", self.unitOwner, self.unit))
                Roster[self.unit] = Roster[self.unitOwner]
                Roster[self.unitOwner] = nil

                -- ROSTER = Roster
                -- local NAME = UnitName(unit)
                -- print(string.format("D1>[%s]>Dumping Roster",NAME))
                -- d87add.dump("ROSTER")

                if not self.vehicleFrame then self.vehicleFrame = CreateFrame("Frame"); self.vehicleFrame.parent = self end
                self.vehicleFrame.OnUpdateCounter = -1.5
                self.vehicleFrame:SetScript("OnUpdate",vehicleHack)

                SetJob(self.unit,config.InVehicleStatus,true)
                Aptechka:UNIT_HEALTH("VEHICLE",self.unit)
                if self.power then Aptechka:UNIT_POWER_UPDATE(nil,self.unit) end
				if self.absorb then Aptechka:UNIT_ABSORB_AMOUNT_CHANGED(nil,self.unit) end
                Aptechka:CheckPhase1(self.unit)
                Aptechka.ScanAuras(self.unit)
            end
        end
    end
end
-- VOODOO ENDS HERE


--Range check
Aptechka.OnRangeUpdate = function (self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 0.3 then return end
    self.OnUpdateCounter = 0

	if not IsInGroup() then --UnitInRange returns false when not grouped
		for unit, frames in pairs(Roster) do
        	for frame in pairs(frames) do
				if not frame.inRange then
                    frame.inRange = true
                    FrameSetJob(frame, config.OutOfRangeStatus, false)
                    OORUnits[unit] = nil
                end
			end
		end
		return
	end

    for unit, frames in pairs(Roster) do
        for frame in pairs(frames) do
            if AptechkaUnitInRange(unit) then
                if not frame.inRange then
                    frame.inRange = true
                    FrameSetJob(frame, config.OutOfRangeStatus, false)
                    OORUnits[unit] = nil
                end
            else
                if frame.inRange or frame.inRange == nil then
                    frame.inRange = false
                    FrameSetJob(frame, config.OutOfRangeStatus, true)
                    OORUnits[unit] = true
                end
            end
        end
    end
end

--Aggro
function Aptechka.UNIT_THREAT_SITUATION_UPDATE(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local sit = UnitThreatSituation(unit)
        if sit and sit > 1 then
            SetJob(unit, config.AggroStatus, true)
        else
            SetJob(unit, config.AggroStatus, false)
        end
    end
end

function Aptechka.UNIT_SPELLCAST_SENT(self, event, unit, targetName, lineID, spellID)
    if unit ~= "player" or not targetName then return end
    LastCastTargetName = string.match(targetName, "(.+)-") or targetName
    LastCastSentTime = GetTime()
end
function Aptechka.UI_ERROR_MESSAGE(self, event, errcode, errtext)
    if errcode == 50 then -- Out of Range code
        if LastCastSentTime > GetTime() - 0.5 then
            for unit in pairs(Roster) do
                if UnitName(unit) == LastCastTargetName then
                    SetJob(unit, config.LOSStatus, true)
                    return
                end
            end
        end
    end
end

function Aptechka.CheckRoles(apt, self, unit )
    --self is UnitButton here
    if config.MainTankStatus then
        FrameSetJob(self, config.MainTankStatus, UnitGroupRolesAssigned(unit) == "TANK")
    end

    if config.displayRoles then
        local isLeader = UnitIsGroupLeader(unit)
        local role = UnitGroupRolesAssigned(unit)

        FrameSetJob(self, config.LeaderStatus, isLeader)
        if config.AssistStatus then
            local isAssistant = UnitIsGroupAssistant(unit)
            FrameSetJob(self, config.AssistStatus, isAssistant)
        end
        -- self.text3:SetFormattedText("%s%s", isLeader and "L" or "",
            -- (role == "HEALER" and "|cff88ff88H|r") or
            -- (role == "TANK" and "|cff8888ffT|r") or ""
        -- )

        local icon = self.roleicon.texture
        if icon then
            if UnitGroupRolesAssigned(unit) == "HEALER" then
                -- icon:SetTexCoord(0, 0.25, 0, 1); icon:Show()
                icon:SetTexCoord(GetTexCoordsForRoleSmallCircle("HEALER")); icon:Show()
            elseif UnitGroupRolesAssigned(unit) == "TANK" then
                -- icon:SetTexCoord(0.25, 0.5, 0, 1); icon:Show()
                icon:SetTexCoord(GetTexCoordsForRoleSmallCircle("TANK")); icon:Show()
            else
                icon:Hide()
            end
        end
    end
end

function Aptechka.SetScale(self, scale)
    if InCombatLockdown() then return end
    for i,hdr in pairs(group_headers) do
        hdr:SetScale(scale)
    end
end
function Aptechka.PLAYER_REGEN_ENABLED(self,event)
    self:GROUP_ROSTER_UPDATE()
    self:ReconfigureProtected()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function Aptechka:UpdateRangeChecker()
	local spec = GetSpecialization() or 1
	if config.UnitInRangeFunctions and config.UnitInRangeFunctions[spec] then
		-- print('using function')
		uir = config.UnitInRangeFunctions[spec]
	else
		uir = UnitInRange
	end
end

function Aptechka.GROUP_ROSTER_UPDATE(self,event,arg1)
    --raid autoscaling
    if not InCombatLockdown() then
        Aptechka:LayoutUpdate()
    else
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    end

    for unit, frames in pairs(Roster) do
        for frame in pairs(frames) do
            Aptechka:CheckRoles(frame, unit)
        end
    end

	Aptechka:UpdateRangeChecker()
end
Aptechka.SPELLS_CHANGED = Aptechka.GROUP_ROSTER_UPDATE

-- Aptechka.SetScale1 = Aptechka.SetScale
-- Aptechka.SetScale = function(self, scale)
--     self:SetScale1(UIParent:GetScale()*scale)
-- end
function Aptechka:DecideGroupScale(numMembers, role, spec)
    if role == "HEALER" then
        if numMembers > 30 then
            return AptechkaDB.autoscale.healerBigRaid
        elseif numMembers > 12 then
            return AptechkaDB.autoscale.healerMediumRaid
        else
            return AptechkaDB.scale
        end
    else
        if numMembers > 30 then
            return AptechkaDB.autoscale.damageBigRaid
        elseif numMembers > 12 then
            return AptechkaDB.autoscale.damageMediumRaid
        else
            return AptechkaDB.scale
        end
    end
end

function Aptechka.LayoutUpdate(self)
    local numMembers = GetNumGroupMembers()

    Aptechka:UpdateDebuffScanningMethod()

    local spec = GetSpecialization()
    local role = spec and select(5,GetSpecializationInfo(spec)) or "DAMAGER"

    local scale = self:DecideGroupScale(numMembers, role, spec)

    -- for _, layout in ipairs(config.layouts) do
    --     if layout(self, numMembers, role, spec) then return end
    -- end
    -- local scale = AptechkaDB.scale or config.scale

    self:SetScale(scale or 1)
end

--raid icons
function Aptechka.RAID_TARGET_UPDATE(self, event)
    for unit, frames in pairs(Roster) do
        for self in pairs(frames) do
            local index = GetRaidTargetIndex(unit)
            local icon = self.raidicon
            if icon then
            if index then
                SetRaidTargetIconTexture(icon.texture, index)
                icon:Show()
            else
                icon:Hide()
            end
            end
        end
    end
end


-- function Aptechka.INCOMING_RESURRECT_CHANGED(self, event, unit)
    -- if not Roster[unit] then return end
    -- for self in pairs(Roster[unit]) do
        -- SetJob(unit, config.ResurrectStatus, UnitHasIncomingResurrection(unit))
    -- end
-- end

--Target Indicator
function Aptechka.PLAYER_TARGET_CHANGED(self, event)
    local newTargetUnit = guidMap[UnitGUID("target")]
    if newTargetUnit and Roster[newTargetUnit] then
        SetJob(Aptechka.previousTarget, config.TargetStatus, false)
        SetJob(newTargetUnit, config.TargetStatus, true)
        Aptechka.previousTarget = newTargetUnit
    else
        SetJob(Aptechka.previousTarget, config.TargetStatus, false)
    end
end

-- Readycheck
function Aptechka.READY_CHECK(self, event)
    for unit in pairs(Roster) do
        self:READY_CHECK_CONFIRM(event, unit)
    end
end
function Aptechka.READY_CHECK_CONFIRM(self, event, unit)
    local rci = config.ReadyCheck
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local status = GetReadyCheckStatus(unit)
        if not status or not rci.stackcolor[status] then return end
        rci.color = rci.stackcolor[status]
        SetJob(unit, rci, true)
    end
end
function Aptechka.READY_CHECK_FINISHED(self, event)
    for unit in pairs(Roster) do
        SetJob(unit, config.ReadyCheck, false)
    end
end

--applying UnitButton color
function Aptechka.Colorize(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local hdr = self:GetParent()
        --if hdr.isPetGroup then   -- use owner color
        --    unit = string.gsub(unit,"pet","")
        --    if unit == "" then unit = "player" end
        --end
        if hdr.isPetGroup then
            self.classcolor = config.petcolor
        else
            local _,class = UnitClass(unit)
            if class then
                local color = colors[class] -- or { r = 1, g = 1, b = 0}
                self.classcolor = {color.r,color.g,color.b}
            end
        end
    end
end


local has_unknowns = true
local UNKNOWNOBJECT = UNKNOWNOBJECT

local function updateUnitButton(self, unit)
    local owner = unit
    -- print("InVehicle:", self.InVehicle, "  unitOwner:", self.unitOwner, "  unit:", unit)
    if self.InVehicle and unit and unit == self.unitOwner then
        unit = self.unit
        owner = self.unitOwner
        --if for some reason game will decide to update unit whose frame is mapped to vehicleunit in roster
    elseif self.InVehicle and unit then
        owner = self.unitOwner
    else
        if self.vehicleFrame then
            self.vehicleFrame:SetScript("OnUpdate",nil)
            self.vehicleFrame = nil
            self.InVehicle = nil
            FrameSetJob(self,config.InVehicleStatus,false)
            -- print ("Killing orphan vehicle frame")
        end
    end

    -- Removing frames that no longer associated with this unit from Roster
    for roster_unit, frames in pairs(Roster) do
        if frames[self] and (  self:GetAttribute("unit") ~= roster_unit   ) then -- or (self.InVehicle and self.unitOwner ~= roster_unit)
            -- print ("Removing frame", self:GetName(), roster_unit, "=>", self:GetAttribute("unit"))
            frames[self] = nil
        end
    end

    if self.OnUnitChanged then self:OnUnitChanged(owner) end
    if not unit then return end

    local name, realm = UnitName(owner)
    if name == UNKNOWNOBJECT then
        has_unknowns = true
    end
    self.name = utf8sub(name,1, AptechkaDB.cropNamesLen)

    self.unit = unit
    Roster[unit] = Roster[unit] or {}
    Roster[unit][self] = true
    self.guid = UnitGUID(unit) -- is it even needed?
    if self.guid then guidMap[self.guid] = unit end
    for guid, gunit in pairs(guidMap) do
        if not Roster[gunit] or guid ~= UnitGUID(gunit) then guidMap[guid] = nil end
    end

    Aptechka:Colorize(nil, owner)
    FrameSetJob(self,config.HealthBarColor,true)
    FrameSetJob(self,config.PowerBarColor,true)
    Aptechka.ScanAuras(unit)
    FrameSetJob(self, config.UnitNameStatus, true)
    Aptechka:UNIT_HEALTH("UNIT_HEALTH", unit)
    if config.enableAbsorbBar then
        Aptechka:UNIT_ABSORB_AMOUNT_CHANGED(nil, unit)
    end
    Aptechka:UNIT_CONNECTION("ONATTR", owner)

    if AptechkaDB.showAFK then
        Aptechka:UNIT_AFK_CHANGED(nil, owner)
    end
    Aptechka:CheckPhase1(unit)
    SetJob(unit, config.ReadyCheck, false)
    if not config.disableManaBar then
        Aptechka:UNIT_DISPLAYPOWER(nil, unit)
        Aptechka:UNIT_POWER_UPDATE(nil, unit)
    end
    Aptechka:UNIT_THREAT_SITUATION_UPDATE(nil, unit)
    if config.raidIcons then
        Aptechka:RAID_TARGET_UPDATE()
    end
    if config.enableVehicleSwap and UnitHasVehicleUI(owner) then
        Aptechka:UNIT_ENTERED_VEHICLE(nil,owner) -- scary
    end
    Aptechka:CheckRoles(self, unit)
    if config.enableIncomingHeals then Aptechka:UNIT_HEAL_PREDICTION(nil,unit) end
end

local delayedUpdateTimer = C_Timer.NewTicker(5, function()
    if has_unknowns then
        has_unknowns = false
        for unit, frames in pairs(Roster) do
            for frame in pairs(frames) do
                -- updateUnitButton may change has_unknowns back to true
                updateUnitButton(frame, unit)
            end
        end
    end
end)

--UnitButton initialization
local OnAttributeChanged = function(self, attrname, unit)
    if attrname == "unit" then
        updateUnitButton(self, unit)
    end
end



local arrangeHeaders = function(prv_group, notreverse, unitGrowth, groupGrowth)
        local p1, p2
        local xgap = 0
        local ygap = AptechkaDB.groupGap or config.groupGap
        local point, direction = reverse(unitGrowth or config.unitGrowth)
        local grgrowth = groupGrowth or (notreverse and reverse(config.groupGrowth) or config.groupGrowth)
        -- print(point, direction, grgrowth)
        if grgrowth == "TOP" then
            if direction == "VERTICAL" then point = "" end
            p1 = "BOTTOM"..point; p2 = "TOP"..point;
        elseif grgrowth == "BOTTOM" then
            if direction == "VERTICAL" then point = "" end
            p2 = "BOTTOM"..point; p1 = "TOP"..point
            ygap = -ygap
        elseif grgrowth == "RIGHT" then
            if direction == "HORIZONTAL" then point = "" end
            p1 = point.."LEFT"; p2 = point.."RIGHT"
            xgap, ygap = ygap, xgap
        elseif grgrowth == "LEFT" then
            if direction == "HORIZONTAL" then point = "" end
            p2 = point.."LEFT"; p1 = point.."RIGHT"
            xgap, ygap = -ygap, xgap
        end
        return p1, prv_group, p2, xgap, ygap
end
function Aptechka.CreateHeader(self,group,petgroup)
    local frameName = "NugRaid"..group

    local HeaderTemplate = petgroup and "SecureGroupPetHeaderTemplate" or "SecureGroupHeaderTemplate"
    local f = CreateFrame("Button",frameName, UIParent, HeaderTemplate)

    f:SetFrameStrata("BACKGROUND")

    -- f:SetAttribute("template", "AptechkaUnitButtonTemplate")
    -- f:SetAttribute("templateType", "Button")
    if ClickCastHeader then
        f:SetAttribute("template", "ClickCastUnitTemplate,SecureUnitButtonTemplate")
        SecureHandler_OnLoad(f)
        f:SetFrameRef("clickcast_header", Clique.header)
    else
        f:SetAttribute("template", "SecureUnitButtonTemplate")
    end


    local xgap = AptechkaDB.unitGap or config.unitGap
    local ygap = AptechkaDB.unitGap or config.unitGap
    local unitgr = reverse(AptechkaDB.unitGrowth or config.unitGrowth)
    if unitgr == "RIGHT" then
        xgap = -xgap
    elseif unitgr == "TOP" then
        ygap = -ygap
    end
    f:SetAttribute("point", unitgr)
    f:SetAttribute("xOffset", xgap)
    f:SetAttribute("yOffset", ygap)

	if not petgroup
    then
        f:SetAttribute("groupFilter", group)
        if not isClassic and AptechkaDB.sortUnitsByRole then
            f:SetAttribute("groupBy", "ASSIGNEDROLE")
            f:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
        end
    else
        f.isPetGroup = true
        f:SetAttribute("maxColumns", 1 )
        f:SetAttribute("unitsPerColumn", 5)
        --f:SetAttribute("startingIndex", 5*((group - config.maxgroups)-1))
    end
    --our group header doesn't really inherits SecureHandlerBaseTemplate

    local showSolo = AptechkaDB.showSolo -- or config.showSolo
    f:SetAttribute("showRaid", true)
    f:SetAttribute("showParty", config.showParty)
    f:SetAttribute("showSolo", showSolo)
    f:SetAttribute("showPlayer", true)
    f.initialConfigFunction = Aptechka.SetupFrame
    f:SetAttribute("initialConfigFunction", self.initConfSnippet)

    local unitGrowth = AptechkaDB.unitGrowth or config.unitGrowth
    local groupGrowth = AptechkaDB.groupGrowth or config.groupGrowth

    if group == 1 then
        Aptechka:CreateAnchor(f,group)
    elseif petgroup then
        f:SetPoint(arrangeHeaders(group_headers[1], nil, unitGrowth, reverse(groupGrowth)))
    else
        f:SetPoint(arrangeHeaders(group_headers[group-1]))
    end

    f:Show()

    return f
end

do -- this function supposed to be called from layout switchers
    -- local reversed = false
    function Aptechka:SetGrowth(unitGrowth, groupGrowth)
        if config.useGroupAnchors then return end
        -- reversed = to or (not reversed)

        local anchorpoint = self:SetAnchorpoint(unitGrowth, groupGrowth)

        local xgap = AptechkaDB.unitGap or config.unitGap
        local ygap = AptechkaDB.unitGap or config.unitGap
        local unitgr = reverse(unitGrowth)
        if unitgr == "RIGHT" then
            xgap = -xgap
        elseif unitgr == "TOP" then
            ygap = -ygap
        end

        for group,hdr in ipairs(group_headers) do
            for _,button in ipairs{ hdr:GetChildren() } do -- group header doesn't clear points when attribute value changes
                button:ClearAllPoints()
            end
            hdr:SetAttribute("point", unitgr)
            hdr:SetAttribute("xOffset", xgap)
            hdr:SetAttribute("yOffset", ygap)
            local petgroup = hdr.isPetGroup

            hdr:ClearAllPoints()
            if group == 1 then
                hdr:SetPoint(anchorpoint, anchors[group], reverse(anchorpoint),0,0)
            elseif petgroup then
                hdr:SetPoint(arrangeHeaders(group_headers[1], nil, unitGrowth, reverse(groupGrowth)))
            else
                hdr:SetPoint(arrangeHeaders(group_headers[group-1], nil, unitGrowth, groupGrowth))
            end
        end
    end
end

function Aptechka:SetAnchorpoint(unitGrowth, groupGrowth)
    local ug = unitGrowth or config.unitGrowth
    local gg = groupGrowth or config.groupGrowth
    local rug, ud = reverse(ug)
    local rgg, gd = reverse(gg)
    if config.useGroupAnchors then return rug
    elseif ud == gd then return rug
    elseif gd == "VERTICAL" and ud == "HORIZONTAL" then return rgg..rug
    elseif ud == "VERTICAL" and gd == "HORIZONTAL" then return rug..rgg
    end
end

function Aptechka.CreateAnchor(self,hdr,num)
    local f = CreateFrame("Frame","NugRaidAnchor"..num,UIParent)

    f:SetHeight(20)
    f:SetWidth(20)

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)

    t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    if num == 1 then t:SetVertexColor(1, 0, 0)
    elseif num == 9 then t:SetVertexColor(1, 0.6, 0)
    else t:SetVertexColor(0, 1, 0) end
    t:SetAllPoints(f)

    local text = f:CreateFontString()
    text:SetPoint("RIGHT",f,"LEFT",0,0)
    text:SetFontObject("GameFontNormal")
    text:SetJustifyH("RIGHT")
    if num ~= 1 then text:SetText(num) end
    if num == 9 then text:SetText("P") end

    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetFrameStrata("HIGH")

    hdr:SetPoint(config.anchorpoint,f,reverse(config.anchorpoint),0,0)
    anchors[num] = f
    f:Hide()

    if not AptechkaDB[skinAnchorsName] then AptechkaDB[skinAnchorsName] = {} end
    if not AptechkaDB[skinAnchorsName][num] then
        if num == 1 then AptechkaDB[skinAnchorsName][num] = { point = "CENTER", x = 0, y = 0 }
        elseif num == 9 then AptechkaDB[skinAnchorsName][num] = { point = "BOTTOMLEFT", x = 0, y = -60 }
        else AptechkaDB[skinAnchorsName][num] = { point = "TOPLEFT", x = 0, y = 60} end
    end
    local san = AptechkaDB[skinAnchorsName][num]
    if num == 1 then
        f.root = true
        f:SetPoint(san.point,UIParent,san.point,san.x,san.y)
    else
        f.prev = anchors[#anchors-1]
        if num == 9 then f.prev = anchors[1] end
        f:SetPoint(san.point,f.prev,san.point,san.x,san.y)
    end
    f.san = san

    f:SetScript("OnDragStart",function(self) self:StartMoving() end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        if self.root then
            _,_, self.san.point, self.san.x, self.san.y = self:GetPoint(1)
        else
            self.san.y = self:GetTop() - self.prev:GetTop()
            self.san.x = self:GetLeft() - self.prev:GetLeft()
            self:ClearAllPoints()
            self:SetPoint(san.point,self.prev,san.point,san.x,san.y)
        end
    end)
end

function Aptechka.SwitchAnchors(self, newAnchors)
    skinAnchorsName = newAnchors
    for num, f in ipairs(anchors) do
        if not AptechkaDB[skinAnchorsName] then AptechkaDB[skinAnchorsName] = {} end
        if not AptechkaDB[skinAnchorsName][num] then
            if num == 1 then AptechkaDB[skinAnchorsName][num] = { point = "CENTER", x = 0, y = 0 }
            elseif num == 9 then AptechkaDB[skinAnchorsName][num] = { point = "BOTTOMLEFT", x = 0, y = -60 }
            else AptechkaDB[skinAnchorsName][num] = { point = "TOPLEFT", x = 0, y = 60} end
        end
        local san = AptechkaDB[skinAnchorsName][num]
        if num == 1 then
            f.root = true
            f:ClearAllPoints()
            f:SetPoint(san.point,UIParent,san.point,san.x,san.y)
        else
            f.prev = anchors[num-1]
            if num == 9 then f.prev = anchors[1] end
            f:ClearAllPoints()
            f:SetPoint(san.point,f.prev,san.point,san.x,san.y)
        end
        f.san = san
    end
end

local onenter = function(self)
    if self.OnMouseEnterFunc then self:OnMouseEnterFunc() end
    if AptechkaDB.disableTooltip or UnitAffectingCombat("player") then return end
    UnitFrame_OnEnter(self)
    self:SetScript("OnUpdate", UnitFrame_OnUpdate)
end
local onleave = function(self)
    if self.OnMouseLeaveFunc then self:OnMouseLeaveFunc() end
    UnitFrame_OnLeave(self)
    self:SetScript("OnUpdate", nil)
end

function Aptechka.SetupFrame(header, frameName)
    local f = _G[frameName]

    local width = pixelperfect(AptechkaDB.width or config.width)
    local height = pixelperfect(AptechkaDB.height or config.height)
    --[[if f:CanChangeAttribute() then
        f:SetAttribute("initial-width", width) -- what is it even doing?
        f:SetAttribute("initial-height", height)
    end]]
    if not InCombatLockdown() then
        f:SetSize(width, height)
    end

    f.onenter = onenter
    f.onleave = onleave

    f:RegisterForClicks(unpack(config.registerForClicks))
    f.vHealthMax = 1
    f.vHealth = 1


    f.activeAuras = {}

    if config[config.skin] then
        config[config.skin](f)
    else
        config["GridSkin"](f)
    end
    f:ReconfigureUnitFrame()

    f.self = f
    f.HideFunc = f.HideFunc or function() end

    if config.disableManaBar or not f.power then
        Aptechka:UnregisterEvent("UNIT_POWER_UPDATE")
        Aptechka:UnregisterEvent("UNIT_MAXPOWER")
        Aptechka:UnregisterEvent("UNIT_DISPLAYPOWER")
        if f.power and f.power.OnPowerTypeChange then f.power:OnPowerTypeChange("none") end
        f.power = nil
    end

    if f.raidicon then
        f.raidicon.texture:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]
    end

    f:SetScript("OnAttributeChanged", OnAttributeChanged)
end

local AssignToSlot = function(frame, opts, status, slot)
    local self = frame[slot]
    if not self then
        if frame._optional_widgets[slot] then
            frame[slot] = frame._optional_widgets[slot](frame)
            self = frame[slot]
        end
    end
    if self then
            -- short exit if disabling auras on already empty widget
            if not self.currentJob and status == false then return end

            local jobs = self.jobs
            if not jobs then
                self.jobs = {}
                jobs = self.jobs
            end


            if status then
                jobs[opts.name] = opts
                if opts.id and not opts.isMissing then
                    frame.activeAuras[opts.realID] = opts
                end
            else
                jobs[opts.name] = nil
            end
            -- print("Job Status:", opts.name, jobs[opts.name])

            if next(jobs) then
                local max
                if not self.rawAssignments then
                    local max_priority = 0
                    for name, opts in pairs(jobs) do
                        local opts_priority = opts.priority or 80
                        if max_priority < opts_priority then
                            max_priority = opts_priority
                            max = name
                        end
                    end
                    self.currentJob = jobs[max] -- important that it's before SetJob
                else
                    max = opts.name
                end
                if self ~= frame then self:Show() end   -- taint if we show protected unitbutton frame
                if self.SetJob  then self:SetJob(jobs[max]) end
            else
                if self.rawAssignments then self:SetJob(opts) end
                if self.HideFunc then self:HideFunc() else self:Hide() end
                self.currentJob = nil
            end
    end
end

FrameSetJob = function (frame, opts, status)
    if opts and opts.assignto then
        if type(opts.assignto) == "string" then
            AssignToSlot(frame, opts, status, opts.assignto)
        else
            for _, slot in ipairs(opts.assignto) do
                AssignToSlot(frame, opts, status, slot)
            end
        end
    end
end

Aptechka.FrameSetJob = FrameSetJob

SetJob = function (unit, opts, status)
    if not Roster[unit] then return end
    for frame in pairs(Roster[unit]) do
        FrameSetJob(frame, opts, status)
    end
end

local GetRealID = function(id)
    if type(id) == "table" then
        return id[1]
    else
        return id
    end
end

local encountered = {}
local auraTypes = {"HELPFUL", "HARMFUL"}
function Aptechka.ScanAuras(unit)
    table_wipe(encountered)
    for _,auraType in ipairs(auraTypes) do
        for i=1,100 do
            local name, icon, count, _, duration, expirationTime, caster, _,_, spellID = UnitAura(unit, i, auraType)
            if not name then break end
            duration = 0
            expirationTime = 0
            local durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(unit, spellID, caster)
            if durationNew then
                duration = durationNew
                expirationTime = expirationTimeNew
            end
            -- print(auraType, spellID, name, auras[spellID])
            local opts = auras[spellID] or loadedAuras[spellID]
            if opts and not opts.disabled then
                if caster == "player" or not opts.isMine then
                    local realID = GetRealID(opts.id)
                    opts.realID = realID

                    encountered[realID] = opts

                    local status = true
                    if opts.isMissing then status = false end

                    if opts.stackcolor then
                        opts.color = opts.stackcolor[count]
                    end
                    if opts.foreigncolor then
                        opts.isforeign = (caster ~= "player")
                    end
                    opts.expirationTime = expirationTime
                    local minduration = opts.extend_below
                    if minduration and opts.duration and duration < minduration then
                        duration = opts.duration
                    end
                    opts.duration = duration
                    opts.texture = opts.texture or icon
                    opts.stacks = count
                    SetJob(unit, opts, status)
                end
            end
        end
    end
    local frames = Roster[unit]
    if frames then
    for frame in pairs(frames) do
        for realID, opts in pairs(frame.activeAuras) do
            if not encountered[realID] then
                FrameSetJob(frame, opts, false)
                frame.activeAuras[realID] = nil
            end
        end
        for optsMissing in pairs(missingFlagSpells) do
            local isPresent
            for spellID, opts in pairs(encountered) do
                if optsMissing == opts then
                    isPresent = true
                    break
                end
            end
            if not isPresent then
                FrameSetJob(frame, optsMissing, true)
            end
        end
    end
    end
end

function Aptechka.UNIT_AURA(self, event, unit)
    if not Roster[unit] then return end
    Aptechka.ScanAuras(unit)
    -- local beginTime = debugprofilestop()
    Aptechka.ScanDebuffSlots(unit)
    -- local timeUsed = debugprofilestop() - beginTime
    -- print("used", timeUsed, "ms")
end


function Aptechka:UpdateDebuffScanningMethod()
    local useOrdering = false
    if AptechkaDB.useDebuffOrdering  then
        local numMembers = GetNumGroupMembers()
        local _, instanceType = GetInstanceInfo()
        local isBattleground = instanceType == "arena" or instanceType == "pvp"
        useOrdering = not IsInRaid() or (isBattleground and numMembers <= 15)
    end
    if useOrdering then
        Aptechka.ScanDebuffSlots = Aptechka.OrderedScanDebuffSlots
    else
        Aptechka.ScanDebuffSlots = Aptechka.SimpleScanDebuffSlots
    end
end

-- local presentDebuffs = {}

local function SetDebuffIcon(unit, index, debuffType, expirationTime, duration, icon, count, isBossAura)
    local opts = debuffs[index]
    opts.debuffType = debuffType
    opts.expirationTime = expirationTime
    opts.duration = duration
    opts.stacks = count
    opts.texture = icon
    opts.isBossAura = isBossAura
    SetJob(unit, opts, true)
end

local function UtilShouldDisplayDebuff(spellId, unitCaster, visType)
    if spellId == 212183 then -- smoke bomb
        local reaction = unitCaster and UnitReaction("player", unitCaster) or 0
        return reaction <= 4 -- display enemy smoke bomb, hide friendly
    end
    local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, visType);
	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );	--Would only be "mine" in the case of something like forbearance.
	else
		return true;
	end
end


local debuffList = {}
local sortfunc = function(a,b)
    return a[2] > b[2]
end
function Aptechka.OrderedScanDebuffSlots(unit)
    -- table_wipe(presentDebuffs)
    table_wipe(debuffList)
    local debuffLineLength = #debuffs
    local shown = 0
    local fill = 0

    local visType = UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT"
    -- scan for boss buffs only
    for i=1,100 do
        local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAura(unit, i, "HARMFUL")
        if not name then break end
        if UtilShouldDisplayDebuff(spellID, caster, visType) and not blacklist[spellID] then
            local rootSpellID, spellType, prio = LibAuraTypes.GetDebuffInfo(spellID)
            if not prio then
                prio = (isBossAura and 10) or (debuffType and 1) or 0
            end
            tinsert(debuffList, { i, prio })
        end
    end

    if LibSpellLocks then
        local spellLocked = LibSpellLocks:GetSpellLockInfo(unit)
        if spellLocked then
            tinsert(debuffList, { -1, LibAuraTypes.GetDebuffTypePriority("SILENCE")})
        end
    end

    tsort(debuffList, sortfunc)

    for i, debuffIndexCont in ipairs(debuffList) do
        local index, prio = unpack(debuffIndexCont)
        local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura
        if index > 0 then
            name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAura(unit, index, "HARMFUL")
            if prio >= 9 then
                isBossAura = true
            end
        else
            spellID, name, icon, duration, expirationTime = LibSpellLocks:GetSpellLockInfo(unit)
            count = 0
            isBossAura = true
        end
        fill = fill + (isBossAura and 1.5 or 1)

        if fill <= debuffLineLength then
            shown = shown + 1
            SetDebuffIcon(unit, shown, debuffType, expirationTime, duration, icon, count, isBossAura)
        else
            break
        end
    end

    for i=shown+1, debuffLineLength do
        local opts = debuffs[i]
        SetJob(unit, opts, false)
    end
end


function Aptechka.TestDebuffSlots()
    local debuffLineLength = #debuffs
    local shown = 0
    local fill = 0
    local unit = "player"

    local numBossAuras = math.random(3)-1

    local debuffTypes = { "none", "Magic", "Poison", "Curse", "Disease" }
    local randomIDs = { 5211, 163505, 209753, 19577, 213691, 118, 119381, 605 }
    for i=1,6 do
        local spellID = randomIDs[math.random(#randomIDs)]
        local _, _, icon = GetSpellInfo(spellID)
        local duration = math.random(20)+5
        local now = GetTime()
        local count = 1
        local debuffType = debuffTypes[math.random(#debuffTypes)]
        local expirationTime = now + duration
        local isBossAura = shown < numBossAuras
        fill = fill + (isBossAura and 1.5 or 1)

        print(fill, debuffLineLength, fill < debuffLineLength)

        if fill <= debuffLineLength then
            shown = shown + 1
            SetDebuffIcon(unit, shown, debuffType, expirationTime, duration, icon, count, isBossAura)
        else
            break
        end
    end

    for i=shown+1, debuffLineLength do
        local opts = debuffs[i]
        SetJob(unit, opts, false)
    end
end

function Aptechka.SimpleScanDebuffSlots(unit)
        -- table_wipe(presentDebuffs)

        local debuffLineLength = #debuffs
        local shown = 0

        -- scan for boss buffs only
        for i=1,100 do
            local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAura(unit, i, "HELPFUL")
            if not name then break end
            if isBossAura and shown < debuffLineLength then
                if not blacklist[spellID] then
                    shown = shown + 1

                    SetDebuffIcon(unit, shown, "Helpful", expirationTime, duration, icon, count, isBossAura)
                end
            end
        end

        -- scan for boss debuffs only
        for i=1,100 do
            local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAura(unit, i, "HARMFUL")
            if not name then break end
            if not isBossAura then
                local _, spellType, prio = LibAuraTypes.GetDebuffInfo(spellID)
                isBossAura = prio and prio >= 9
            end
            if isBossAura and shown < debuffLineLength then
                if not blacklist[spellID] then
                    shown = shown + 1

                    SetDebuffIcon(unit, shown, debuffType, expirationTime, duration, icon, count, isBossAura)
                end
            end
        end

        -- scan debuffs
        local visType = UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT"
        for i=1,100 do
            local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAura(unit, i, "HARMFUL")
            if not name then break end
            if not isBossAura then
                local _, spellType, prio = LibAuraTypes.GetDebuffInfo(spellID)
                isBossAura = prio and prio >= 9
            end

            if not isBossAura and shown < debuffLineLength then
                -- I don't even understand what this SpellGetVisibilityInfo thing is doing, but default UI is using it
                if UtilShouldDisplayDebuff(spellID, caster, visType) and not blacklist[spellID] then
                    shown = shown + 1

                    SetDebuffIcon(unit, shown, debuffType, expirationTime, duration, icon, count, isBossAura)
                end
            end

            -- local opts = dtypes[debuffType]
            -- if opts and not presentDebuffs[debuffType] then
            --     presentDebuffs[debuffType] = true

            --     opts.expirationTime = expirationTime
            --     opts.duration = duration
            --     opts.stacks = count
            --     opts.texture = icon

            --     SetJob(unit, opts, true)
            -- end
        end

        for i=shown+1, debuffLineLength do
            local opts = debuffs[i]
            SetJob(unit, opts, false)
        end

        -- for debuffType, opts in pairs(dtypes) do
        --     if not presentDebuffs[debuffType] then
        --         SetJob(unit, opts, false)
        --     end
        -- end
end

local ParseOpts = function(str)
    local t = {}
    local capture = function(k,v)
        t[k:lower()] = tonumber(v) or v
        return ""
    end
    str:gsub("(%w+)%s*=%s*%[%[(.-)%]%]", capture):gsub("(%w+)%s*=%s*(%S+)", capture)
    return t
end
Aptechka.Commands = {
    ["unlockall"] = function()
        for _,anchor in pairs(anchors) do
            anchor:Show()
        end
    end,
    ["unlock"] = function()
        anchors[1]:Show()
    end,
    ["lock"] = function()
        for _,anchor in pairs(anchors) do
            anchor:Hide()
        end
    end,
    ["reset"] = function()
        anchors[1].san.point = "CENTER"
        anchors[1].san.x = 0
        anchors[1].san.y = 0
        anchors[1]:ClearAllPoints()
        anchors[1]:SetPoint(anchors[1].san.point, UIParent, anchors[1].san.point, anchors[1].san.x, anchors[1].san.y)
    end,
    ["togglegroup"] = function()
        local group = tonumber(v)
        if group then
            local hdr = group_headers[group]
            if hdr:IsVisible() then
                hdr:Hide()
            else
                hdr:Show()
            end
        end
    end,
    ["createpets"] = function()
        if not AptechkaDB.petGroup then
            if not InCombatLockdown() then
                CreatePetsFunc()
            else
                local f = CreateFrame('Frame')
                f:SetScript("OnEvent",function(self)
                    CreatePetsFunc()
                    self:SetScript("OnEvent",nil)
                end)
                f:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
        end
    end,
    ["toggle"] = function()
        if group_headers[1]:IsVisible() then k = "hide" else k = "show" end
    end,
    ["show"] = function()
        for i,hdr in pairs(group_headers) do
            hdr:Show()
        end
    end,
    ["hide"] = function()
        for i,hdr in pairs(group_headers) do
            hdr:Hide()
        end
    end,
    ["spells"] = function()
        print("=== Spells ===")
        local spellset = AptechkaUserConfig.auras or AptechkaDefaultConfig.auras
        for spellName,opts in pairs(spellset) do
            local format = string.find(opts.type,"HARMFUL") and "|cffff7777%s|r" or "|cff77ff77%s|r"
            print(string.format(format,spellName))
        end
    end,
    ["load"] = function()
        local add = config.LoadableDebuffs[v]
        if v == "" then
            print("Spell sets:")
            for k,v in pairs(config.LoadableDebuffs) do
                print(k)
            end return
        end
        if add then
            if loaded[v] then return end
            add()
            print(AptechkaString..v.." loaded.")
            loaded[v] = true
        else
            print(AptechkaString..v.." doesn't exist")
        end
    end,
    ["setpos"] = function()
        local fields = ParseOpts(v)
        if not next(fields) then print("Usage: /apt setpos point=center x=0 y=0") return end
        local point,x,y = string.upper(fields['point'] or "CENTER"), fields['x'] or 0, fields['y'] or 0
        anchors[1].san.point = point
        anchors[1].san.x = x
        anchors[1].san.y = y
        anchors[1]:ClearAllPoints()
        anchors[1]:SetPoint(point, UIParent, point, x, y)
    end,
    ["charspec"] = function()
        local user = UnitName("player").."@"..GetRealmName()
        if AptechkaDB_Global.charspec[user] then AptechkaDB_Global.charspec[user] = nil
        else AptechkaDB_Global.charspec[user] = true
        end
        print (AptechkaString..(AptechkaDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload",0.7,1,0.7)
    end,
    ["listauras"] = function(v)
        local unit = v
        local h = false
        for i=1, 100 do
            local name, _,_,_,duration,_,_,_,_, spellID = UnitAura(unit, i, "HELPFUL")
            if not name then break end
            if not h then print("BUFFS:"); h = true; end
            print(string.format("    %s (id: %d) Duration: %s", name, spellID, duration or "none" ))
        end
        h = false
        for i=1, 100 do
            local name, _,_,_,duration,_,_,_,_, spellID = UnitAura(unit, i, "HARMFUL")
            if not name then break end
            if not h then print("DEBUFFS:"); h = true; end
            print(string.format("    %s (id: %d) Duration: %s", name, spellID, duration or "none" ))
        end

    end,
    ["blacklist"] = function(v)
        local cmd,args = string.match(v, "([%w%-]+) ?(.*)")
        if cmd == "add" then
            local spellID = tonumber(args)
            if spellID then
                blacklist[spellID] = true
                local spellName = GetSpellInfo(spellID) or "<Unknown spell>"
                print(string.format("%s (%d) added to debuff blacklist", spellName, spellID))
            end
        elseif cmd == "del" then
            local spellID = tonumber(args)
            if spellID then
                local val = nil
                if default_blacklist[spellID] then val = false end -- if nil it'll fallback on __index
                blacklist[spellID] = val
                local spellName = GetSpellInfo(spellID) or "<Unknown spell>"
                print(string.format("%s (%d) removed from debuff blacklist", spellName, spellID))
            end
        else
            print("Default blacklist:")
            for spellID in pairs(default_blacklist) do
                local spellName = GetSpellInfo(spellID) or "<Unknown spell>"
                print(string.format("    %s (%d)", spellName, spellID))
            end
            print("Custom blacklist:")
            for spellID in pairs(blacklist) do
                local spellName = GetSpellInfo(spellID) or "<Unknown spell>"
                print(string.format("    %s (%d)", spellName, spellID))
            end
        end
    end,
}
function Aptechka.SlashCmd(msg)
    local k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([=[Usage:
      |cff00ff00/aptechka|r lock
      |cff00ff00/aptechka|r unlock
      |cff00ff00/aptechka|r reset|r
      |cff00ff00/aptechka|r createpets
      |cff00ff00/aptechka|r blacklist add <spellID>
      |cff00ff00/aptechka|r blacklist del <spellID>
      |cff00ff00/aptechka|r blacklist show
    ]=]
    )end

    if Aptechka.Commands[k] then
        Aptechka.Commands[k](v)
    end
end

local PARTY_CHAT = Enum.ChatChannelType.Private_Party
local INSTANCE_CHAT = Enum.ChatChannelType.Public_Party
function Aptechka:VOICE_CHAT_CHANNEL_ACTIVATED(event)
    local channelType = C_VoiceChat.GetActiveChannelType()
    if channelType == PARTY_CHAT or channelType == INSTANCE_CHAT then
        self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED")
    else
        self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED")
    end
end

function Aptechka:VOICE_CHAT_CHANNEL_DEACTIVATED(event, channelID)
    self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED")
end

function Aptechka:VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED(event, memberID, channelID, isSpeaking)
    local guid = C_VoiceChat.GetMemberGUID(memberID, channelID)
    local unit = guidMap[guid]
    if unit then
        SetJob(unit, config.VoiceChatStatus, isSpeaking)
    end
end