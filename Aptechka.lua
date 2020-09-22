local _, helpers = ...

local Aptechka = helpers.frame

Aptechka:SetScript("OnEvent", function(self, event, ...)
    self[event](self, event, ...)
end)

--- Compatibility with Classic
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isShadowlands = select(4,GetBuildInfo()) > 90000

local UnitHasVehicleUI = UnitHasVehicleUI
local UnitInVehicle = UnitInVehicle
local UnitUsingVehicle = UnitUsingVehicle
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitThreatSituation = UnitThreatSituation
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitPhaseReason = UnitPhaseReason
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local HasIncomingSummon = C_IncomingSummon and C_IncomingSummon.HasIncomingSummon
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_UPTORAID = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE

local dummyNil = function() return nil end
if isClassic then
    local dummyFalse = function() return false end
    local dummy0 = function() return 0 end

    UnitHasVehicleUI = dummyFalse
    UnitInVehicle = dummyFalse
    UnitUsingVehicle = dummyFalse
    UnitGetIncomingHeals = dummy0
    UnitGetTotalAbsorbs = dummy0
    UnitGetTotalHealAbsorbs = dummy0
    UnitPhaseReason = dummyFalse
    UnitGroupRolesAssigned = function(unit) if GetPartyAssignment("MAINTANK", unit) then return "TANK" end end
    GetSpecialization = function() return 1 end
    GetSpecializationInfo = function() return "DAMAGER" end
    HasIncomingSummon = dummyNil
end

-- AptechkaUserConfig = setmetatable({},{ __index = function(t,k) return AptechkaDefaultConfig[k] end })
-- When AptechkaUserConfig __empty__ field is accessed, it will return AptechkaDefaultConfig field

local AptechkaUnitInRange
local uir -- current range check function
local auras
local traceheals
local colors
local threshold = 0 --incoming heals
local ignoreplayer
local fgShowMissing
local gradientHealthColor
local damageEffect

local config = AptechkaDefaultConfig
Aptechka.loadedAuras = {}
local loadedAuras = Aptechka.loadedAuras
local customBossAuras = helpers.customBossAuras
local defaultBlacklist = helpers.auraBlacklist
local blacklist
local importantTargetedCasts = helpers.importantTargetedCasts
local loaded = {}
local Roster = {}
local guidMap = {}
local group_headers = {}
local missingFlagSpells = {}
local anchors = {}
local skinAnchorsName
local BITMASK_DISPELLABLE = 0
local RosterUpdateOccured
local LastCastSentTime = 0
local LastCastTargetName
local highlightedDebuffs = {}
local GetNumGroupMembers = GetNumGroupMembers

local AptechkaString = "|cffff7777Aptechka: |r"
local GetTime = GetTime
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitAura = UnitAura
local ForEachAura = helpers.ForEachAura
local UnitAffectingCombat = UnitAffectingCombat
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local customColors
local table_wipe = table.wipe
local SetJob
local FrameSetJob
local DispelFilter

local pixelperfect = helpers.pixelperfect
Aptechka.util = helpers
Aptechka.helpers = helpers -- Used by old userconfigs
local bit_band = bit.band
local bit_bor = bit.bor
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local pairs = pairs
local next = next
local utf8sub = helpers.utf8sub
local reverse = helpers.Reverse
local GetAuraHash = helpers.GetAuraHash
local AptechkaDB
local NickTag
local LibSpellLocks
local LibAuraTypes
local LibTargetedCasts
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local BuffProc
local DebuffProc, DebuffPostUpdate
local DispelTypeProc, DispelTypePostUpdate
local enableTraceheals
local enableAuraEvents
-- local enableLowHealthStatus
local debuffLimit
local tankUnits = {}
local staggerUnits = {}
local LibTranslit = LibStub("LibTranslit-1.0")

Aptechka.L = setmetatable({}, {
    __index = function(t, k)
        -- print(string.format('L["%s"] = ""',k:gsub("\n","\\n")));
        return k
    end,
    __call = function(t,k) return t[k] end,
})

local defaults = {
    global = {
        disableBlizzardParty = true,
        hideBlizzardRaid = true,
        RMBClickthrough = false,
        enableNickTag = false,
        sortUnitsByRole = true,
        showAFK = false,
        translitCyrillic = false,
        enableMouseoverStatus = true,
        customBlacklist = {},
        LDBData = {}, -- minimap icon settings
        useCombatLogHealthUpdates = false,
        disableTooltip = false,
        disableAbsorbBar = false,
        debuffTooltip = false,
        useDebuffOrdering = true, -- On always?
        customDebuffHighlights = {},
        borderWidth = 1,
        enableProfileSwitching = true,
        profileSelection = {
            HEALER = {
                solo = "Default",
                party = "Default",
                smallRaid = "Default",
                mediumRaid = "Default",
                bigRaid = "Default",
                fullRaid = "Default",
            },
            DAMAGER = {
                solo = "Default",
                party = "Default",
                smallRaid = "Default",
                mediumRaid = "Default",
                bigRaid = "Default",
                fullRaid = "Default",
            },
        },
        widgetConfig = config.DefaultWidgets,
    },
    profile = {
        point = "CENTER",
        x = 0,
        y = 0,
        width = 55,
        height = 55,
        healthOrientation = "VERTICAL",
        unitGrowth = "RIGHT",
        groupGrowth = "TOP",
        groupsInRow = 1,
        unitGap = 7,
        groupGap = 7,
        showSolo = true,
        showParty = true,
        showRaid = true,
        cropNamesLen = 7,
        showCasts = true,
        showAggro = true,
        petGroup = false,
        showRaidIcons = true,
        showDispels = true,
        healthTexture = "Gradient",
        powerTexture = "Gradient",
        damageEffect = true,
        auraUpdateEffect = true,
        gradientHealthColor = false,
        healthColorByClass = true,
        healthColor1 = {0,1,0},
        healthColor2 = {1,1,0},
        healthColor3 = {1,0,0},

        scale = 1, --> into
        debuffBossScale = 1.3,
        nameColorMultiplier = 1,
        fgShowMissing = true,
        fgColorMultiplier = 1,
        bgColorMultiplier = 0.2,
        groupFilter = 255,
        bgAlpha = 1,
        widgetConfig = {},
    },
}

Aptechka:RegisterEvent("PLAYER_LOGIN")
function Aptechka.PLAYER_LOGIN(self,event,arg1)
    local uir2 = function(unit)
        if UnitIsDeadOrGhost(unit) or UnitIsEnemy(unit, "player") then --IsSpellInRange doesn't work with dead people
            return UnitInRange(unit)
        else
            return uir(unit)
        end
    end

    AptechkaUnitInRange = uir2

    local firstTimeUse = AptechkaDB_Global == nil
    AptechkaDB_Global = AptechkaDB_Global or {}
    AptechkaDB_Char = AptechkaDB_Char or {}
    self:DoMigrations(AptechkaDB_Global)
    self.db = LibStub("AceDB-3.0"):New("AptechkaDB_Global", defaults, "Default") -- Create a DB using defaults and using a shared default profile
    AptechkaDB = self.db

    self.db.RegisterCallback(self, "OnProfileChanged", "Reconfigure")
    self.db.RegisterCallback(self, "OnProfileCopied", "Reconfigure")
    self.db.RegisterCallback(self, "OnProfileReset", "Reconfigure")

    -- CUSTOM_CLASS_COLORS is from phanx's ClassColors addons
    colors = setmetatable(customColors or {},{ __index = function(t,k) return (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[k] end })

    local customBlacklist = AptechkaDB.global.customBlacklist
    blacklist = setmetatable({}, {
        __index = function(t,k)
            return customBlacklist[k] or defaultBlacklist[k]
        end,
    })

    AptechkaConfigCustom = AptechkaConfigCustom or {}
    AptechkaConfigMerged = CopyTable(AptechkaDefaultConfig)
    config = AptechkaConfigMerged
    config.DebuffTypes = config.DebuffTypes or {}
    config.DebuffDisplay = config.DebuffDisplay or {}
    config.auras = config.auras or {}
    config.traces = config.traces or {}
    auras = config.auras
    traceheals = config.traces

    Aptechka:UpdateUnprotectedUpvalues()

    local _, class = UnitClass("player")
    local categories = {"auras", "traces"}
    if not AptechkaConfigCustom[class] then AptechkaConfigCustom[class] = {} end

    local function fixRemovedDefaultSpells(customConfig, defaultConfig)
        if not (customConfig and defaultConfig) then return end
        local toRemove = {}
        for spellID, opts in pairs(customConfig) do
            local dopts = defaultConfig[spellID]
            if not dopts and not opts.name then
                table.insert(toRemove, spellID)
            elseif opts.name then -- then it's a is probably an added spell
                opts.isAdded = true -- making sure it's marked as added
            end
        end
        for _, spellID in ipairs(toRemove) do
            customConfig[spellID] = nil
        end
    end

    local fixOldAuraFormat = function(customConfigPart)
        if not customConfigPart then return end
        for id, opts in pairs(customConfigPart) do
            if opts.id == nil then
                opts.id = id
            end
        end
    end

    local globalConfig = AptechkaConfigCustom["GLOBAL"]
    if globalConfig then
        fixOldAuraFormat(globalConfig.auras)
        fixOldAuraFormat(globalConfig.traces)
        fixRemovedDefaultSpells(globalConfig.auras, config.auras)
        fixRemovedDefaultSpells(globalConfig.traces, config.traces)
    end
    Aptechka.util.MergeTable(AptechkaConfigMerged, globalConfig)

    local classConfig = AptechkaConfigCustom[class]
    if classConfig then
        fixOldAuraFormat(classConfig.auras)
        fixOldAuraFormat(classConfig.traces)
        fixRemovedDefaultSpells(classConfig.auras, config.auras)
        fixRemovedDefaultSpells(classConfig.traces, config.traces)
    end
    Aptechka.util.MergeTable(AptechkaConfigMerged, classConfig)

    local widgetConfig = AptechkaConfigCustom["WIDGET"]
    Aptechka.util.MergeTable(AptechkaConfigMerged, widgetConfig)

    Aptechka:FixWidgetsAfterUpgrade()

    -- compiling a list of spells that should activate indicator when missing
    self:UpdateMissingAuraList()

    -- filling up ranks for auras
    local cloneIDs = {}
    local rankCategories = { "auras", "traces" }
    local tempTable = {}
    for _, category in ipairs(rankCategories) do
        table_wipe(tempTable)
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

    if AptechkaDB.global.disableBlizzardParty then
        helpers.DisableBlizzParty()
    end
    if AptechkaDB.global.hideBlizzardRaid then
        -- disable Blizzard party & raid frame if our Raid Frames are loaded
        -- InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
        -- InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
        -- raid
        local hider = CreateFrame("Frame")
        hider:Hide()
        if CompactRaidFrameManager and CompactUnitFrameProfiles then
            CompactRaidFrameManager:SetParent(hider)
            -- CompactRaidFrameManager:UnregisterAllEvents()
            CompactUnitFrameProfiles:UnregisterAllEvents()

            local disableCompactRaidFrameUnitButton = function(self)
                if self:IsForbidden() then return end
                -- for some reason CompactUnitFrame_OnLoad also gets called for nameplates, so ignoring that
                local frameName = self:GetName()
                if not frameName then return end
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

    -- local tbind
    -- if config.TargetBinding == nil then tbind = "*type1"
    -- elseif config.TargetBinding == false then tbind = "__none__"
    -- else tbind = config.TargetBinding end

    -- local ccmacro = config.ClickCastingMacro or "__none__"

    -- local width = pixelperfect(AptechkaDB.profile.width or config.width)
    -- local height = pixelperfect(AptechkaDB.profile.height or config.height)
    -- local scale = AptechkaDB.profile.scale or config.scale
    -- local strata = config.frameStrata or "LOW"
    self.initConfSnippet = [=[
            RegisterUnitWatch(self)

            local header = self:GetParent()
            local width = header:GetAttribute("frameWidth")
            local height = header:GetAttribute("frameHeight")
            self:SetWidth(width)
            self:SetHeight(height)
            self:SetFrameStrata("LOW")
            self:SetFrameLevel(3)

            local isPetFrame = header:GetAttribute("isPetHeader")
            self:SetAttribute("toggleForVehicle", not isPetFrame)
            self:SetAttribute("allowVehicleTarget", false)

            self:SetAttribute("*type1","target")
            self:SetAttribute("shift-type2","togglemenu")


            local ccheader = header:GetFrameRef("clickcast_header")
            if ccheader then
                ccheader:SetAttribute("clickcast_button", self)
                ccheader:RunAttribute("clickcast_register")
            end
            header:CallMethod("initialConfigFunction", self:GetName())
    ]=]

    if config.initialConfigPostHookSnippet then
        self.initConfSnippet = self.initConfSnippet..config.initialConfigPostHookSnippet
    end


    Aptechka:SPELLS_CHANGED() -- Does the following:
    -- Aptechka:UpdateRangeChecker()
    -- Aptechka:UpdateDispelBitmask()
    -- self:LayoutUpdate()
    -- Switches to proper profile for the role
    -- Reconf from it won't run until initialization is finished
    self:UpdateDebuffScanningMethod()
    self:UpdateHighlightedDebuffsHashMap()

    self:RegisterEvent("UNIT_HEALTH")
    if not isShadowlands then self:RegisterEvent("UNIT_HEALTH_FREQUENT") end
    self:RegisterEvent("UNIT_MAXHEALTH")
    Aptechka.UNIT_HEALTH_FREQUENT = Aptechka.UNIT_HEALTH
    self:RegisterEvent("UNIT_CONNECTION")
    if AptechkaDB.global.showAFK then
        self:RegisterEvent("PLAYER_FLAGS_CHANGED") -- UNIT_AFK_CHANGED
    end

    self:RegisterEvent("UNIT_FACTION")
    self:RegisterEvent("UNIT_FLAGS")
    self.UNIT_FLAGS = self.UNIT_FACTION

    self:RegisterEvent("UNIT_PHASE")
    --[[
    -- default ui only checks updates alt power on these events
    self:RegisterEvent("PARTY_MEMBER_ENABLE")
    self:RegisterEvent("PARTY_MEMBER_DISABLE")
    self.PARTY_MEMBER_ENABLE = self.UNIT_PHASE
    self.PARTY_MEMBER_DISABLE = self.UNIT_PHASE
    ]]

    self:RegisterEvent("INCOMING_SUMMON_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    if not config.disableManaBar then
        self:RegisterEvent("UNIT_POWER_UPDATE")
        self:RegisterEvent("UNIT_MAXPOWER")
        self:RegisterEvent("UNIT_DISPLAYPOWER")
        Aptechka.UNIT_MAXPOWER = Aptechka.UNIT_POWER_UPDATE
    end

    Aptechka:UpdateAggroConfig()

    self:RegisterEvent("READY_CHECK")
    self:RegisterEvent("READY_CHECK_CONFIRM")
    self:RegisterEvent("READY_CHECK_FINISHED")

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

    NickTag = LibStub("NickTag-1.0", true)
    if NickTag then
        NickTag.RegisterCallback("Aptechka", "NickTag_Update", function()
            Aptechka:ForEachUnitFrame("player", function(frame)
                Aptechka:UpdateName(frame)
            end)
        end)
    end

    LibAuraTypes = LibStub("LibAuraTypes")
    if AptechkaDB.global.useDebuffOrdering then
        LibSpellLocks = LibStub("LibSpellLocks")

        LibSpellLocks.RegisterCallback("Aptechka", "UPDATE_INTERRUPT", function(event, guid)
            local unit = guidMap[guid]
            if unit then
                Aptechka.ScanAuras(unit)
            end
        end)

        DebuffProc = Aptechka.OrderedDebuffProc
        DebuffPostUpdate = Aptechka.OrderedDebuffPostUpdate
    else
        DebuffProc = Aptechka.SimpleDebuffProc
        DebuffPostUpdate = Aptechka.SimpleDebuffPostUpdate
    end

    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

    self:UpdateCastsConfig()


    -- AptechkaDB.global.useCombatLogHealthUpdates = false
    if isClassic and AptechkaDB.global.useCombatLogHealthUpdates then
        local CLH = LibStub("LibCombatLogHealth-1.0")
        UnitHealth = CLH.UnitHealth
        self:UnregisterEvent("UNIT_HEALTH")
        if not isShadowlands then self:UnregisterEvent("UNIT_HEALTH_FREQUENT") end
        -- table.insert(config.HealthBarColor.assignto, "health2")
        CLH.RegisterCallback(self, "COMBAT_LOG_HEALTH", function(event, unit, eventType)
            return Aptechka:UNIT_HEALTH(eventType, unit)
            -- return Aptechka:COMBAT_LOG_HEALTH(nil, unit, health)
        end)
    end

    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    if AptechkaDB.profile.showRaidIcons then
        self:RegisterEvent("RAID_TARGET_UPDATE")
    end
    if config.enableVehicleSwap then
        self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    end

    skinAnchorsName = "GridSkin"
    local i = 1
    while (i <= config.maxgroups) do
        local f  = Aptechka:CreateHeader(i) -- if second arg is true then it's petgroup
        group_headers[i] = f
        i = i + 1
    end
    self:UpdatePetGroupConfig()

    if config.unlocked then anchors[1]:Show() end
    local unitGrowth = AptechkaDB.profile.unitGrowth or config.unitGrowth
    local groupGrowth = AptechkaDB.profile.groupGrowth or config.groupGrowth
    Aptechka:SetGrowth(group_headers, unitGrowth, groupGrowth)

    Aptechka:SetScript("OnUpdate",Aptechka.OnRangeUpdate)
    Aptechka:Show()

    if firstTimeUse then
        Aptechka.Commands.unlock()
    end

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

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    --[[ --autoloading
    for _,spell_group in pairs(config.autoload) do
        config.LoadableDebuffs[spell_group]()
        loaded[spell_group] = true
    end
    ]]
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

    if not self.db.global.LDBData.hide then
        Aptechka:CreteMinimapIcon()
    end

    local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
    f:SetScript('OnShow', function(self)
        self:SetScript('OnShow', nil)
        LoadAddOn('AptechkaOptions')
        Aptechka:ForAllCustomStatuses(function(opts, status, list)
            if not opts.assignto then return end
            for slot in pairs(opts.assignto) do
                if not list[slot] then
                    Aptechka:PrintDeadAssignmentWarning(slot, opts.name or status)
                end
            end
        end, false)
    end)

    self.isInitialized = true
end  -- END PLAYER_LOGIN


function Aptechka:ToggleCompactRaidFrames()
    local v = IsAddOnLoaded("Blizzard_CompactRaidFrames")
    local f = v and DisableAddOn or EnableAddOn
    f("Blizzard_CompactRaidFrames")
    f("Blizzard_CUFProfiles")
    ReloadUI()
end

function Aptechka:UpdateMissingAuraList()
    table_wipe(missingFlagSpells)
    for spellID, opts in pairs(auras) do
        if opts.isMissing and not opts.disabled then
            missingFlagSpells[opts] = true
        end
    end
end


function Aptechka:CreatePetGroup()
    if group_headers[9] then return end -- already exists
    local pets  = Aptechka:CreateHeader(9,true)
    group_headers[9] = pets
    pets:Show()
end
function Aptechka:UpdatePetGroupConfig()
    if self.db.profile.petGroup then
        Aptechka:CreatePetGroup()
    end
end

function Aptechka:UpdateName(frame)
    local name = frame.state.nameFull
    if Aptechka.db.global.translitCyrillic then
        name = LibTranslit:Transliterate(name)
    end
    if NickTag and self.db.global.enableNickTag then
        local nickname = NickTag:GetNickname(name, nil, true) -- name, default, silent
        if nickname then name = nickname end
    end
    frame.state.name = name and utf8sub(name,1, AptechkaDB.profile.cropNamesLen) or "Unknown"
    FrameSetJob(frame, config.UnitNameStatus, true)
end

function Aptechka.GetWidgetListRaw()
    local list = {}
    for slot in pairs(Aptechka.optional_widgets) do
        list[slot] = string.format("|cffbbbbbb%s|r",slot)--slot
    end
    for slot, opts in pairs(Aptechka.db.global.widgetConfig) do
        if config.DefaultWidgets[slot] then
            list[slot] = slot
        else
            list[slot] = string.format("|cff77ff77%s|r",slot)
        end
    end
    list["border"] = "border"
    list["healthColor"] = "healthColor"
    return list
end

function Aptechka.GetWidgetList()
    local list = Aptechka.GetWidgetListRaw()
    list["statusIcon"] = nil
    list["debuffIcons"] = nil
    list["mindcontrol"] = nil
    list["unhealable"] = nil
    list["vehicle"] = nil
    list["text1"] = nil
    list["incomingCastIcon"] = nil
    return list
end


function Aptechka:Reconfigure()
    if not self.isInitialized then return end
    if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
    self:ReconfigureProtected()
    self:ReconfigureAllWidgets()
    self:ReconfigureUnprotected()

    self:UpdateDebuffScanningMethod()
    self:UpdateRaidIconsConfig()
    self:UpdateAggroConfig()
    self:UpdateCastsConfig()
end
function Aptechka:RefreshAllUnitsHealth()
    Aptechka:ForEachFrame(Aptechka.FrameUpdateHealth)
    Aptechka:ForEachFrame(Aptechka.FrameUpdatePower)
end
function Aptechka.FrameUpdateUnitColor(frame, unit)
    Aptechka.FrameColorize(frame, unit)
    FrameSetJob(frame, config.UnitNameStatus, true)
    FrameSetJob(frame, config.HealthBarColor, true)
    if not frame.power.disabled then FrameSetJob(frame, config.PowerBarColor, true) end
end
function Aptechka:RefreshAllUnitsColors()
    Aptechka:ForEachFrame(Aptechka.FrameUpdateUnitColor)
end

function Aptechka:ReconfigureAllWidgets()
    for widgetName in pairs(Aptechka.db.global.widgetConfig) do
        self:ReconfigureWidget(widgetName)
    end
end

function Aptechka:ReconfigureWidget(widgetName)
    local gopts = Aptechka.db.global.widgetConfig[widgetName]
    local popts = Aptechka.db.profile.widgetConfig[widgetName]
    local reconfFunc = Aptechka.Widget[gopts.type].Reconf
    if reconfFunc then
        Aptechka:ForEachFrame(function(frame)
            local widget = frame[widgetName]
            if widget then
                reconfFunc(frame, widget, popts, gopts)
            end
        end)
    end
end

function Aptechka:ReconfigureUnprotected()
    self:UpdateUnprotectedUpvalues()
    self:RefreshAllUnitsColors()
    for group, header in ipairs(group_headers) do
        for _, f in ipairs({ header:GetChildren() }) do
            self:UpdateName(f)
            f:ReconfigureUnitFrame()
            if Aptechka.PostFrameUpdate then
                Aptechka.PostFrameUpdate(f)
            end
        end
    end
end
function Aptechka:UpdateUnprotectedUpvalues()
    ignoreplayer = config.incomingHealIgnorePlayer or false
    fgShowMissing = Aptechka.db.profile.fgShowMissing
    gradientHealthColor = Aptechka.db.profile.gradientHealthColor
    damageEffect = Aptechka.db.profile.damageEffect
    enableTraceheals = config.enableTraceHeals and next(traceheals)
    enableAuraEvents = Aptechka.db.profile.auraUpdateEffect
end
function Aptechka:ReconfigureProtected()
    if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end

    self:RepositionAnchor()
    self:UpdatePetGroupConfig()
    self:ReconfigureTestHeaders()

    local width = pixelperfect(AptechkaDB.profile.width or config.width)
    local height = pixelperfect(AptechkaDB.profile.height or config.height)
    local scale = AptechkaDB.profile.scale or config.scale
    -- local strata = config.frameStrata or "LOW"
    -- self.initConfSnippet = self.makeConfSnippet(width, height, strata)
    for groupId, header in ipairs(group_headers) do
        if header:CanChangeAttribute() then
            header:SetAttribute("frameWidth", width)
            header:SetAttribute("frameHeight", height)
        end
        header:SetScale(scale)
        for _, f in ipairs({ header:GetChildren() }) do
            f:SetWidth(width)
            f:SetHeight(height)
        end

        local groupEnabled = self:IsGroupEnabled(groupId)
        if groupId == 9 then groupEnabled = self.db.profile.petGroup end
        if groupEnabled then
            header:Enable()
        else
            header:Disable()
        end
    end

    local unitGrowth = AptechkaDB.profile.unitGrowth or config.unitGrowth
    local groupGrowth = AptechkaDB.profile.groupGrowth or config.groupGrowth
    Aptechka:SetGrowth(group_headers, unitGrowth, groupGrowth)
end

local function GetIncomingHealsCustom(unit, excludePlayer)
    local heal = UnitGetIncomingHeals(unit)
    if excludePlayer then
        local myheal = UnitGetIncomingHeals(unit, "player")
        if heal and myheal then
            heal = heal - myheal
        end
    end
    return heal or 0
end

function Aptechka.UNIT_HEAL_PREDICTION(self,event,unit)
    self:UNIT_HEALTH(event, unit)

    -- local heal = GetIncomingHealsCustom(unit, false)
    -- local showHeal = (heal and heal > threshold)
    -- if not Roster[unit] then return end
    -- for self in pairs(Roster[unit]) do
        -- if config.IncomingHealStatus then
        --     if showHeal then
        --         self.vIncomingHeal = heal
        --         SetJob(unit, config.IncomingHealStatus, true)
        --     else
        --         self.vIncomingHeal = 0
        --         SetJob(unit, config.IncomingHealStatus, false)
        --     end
        -- end
    -- end
end

local AbsorbBarDisable = function(f)
    if not f.absorb._SetValue then
        f.absorb._SetValue = f.absorb.SetValue
    end
    f.absorb.SetValue = dummyNil
    f.absorb:Hide()
end
local AbsorbBarEnable = function(f)
    if f.absorb._SetValue then
        f.absorb.SetValue = f.absorb._SetValue
    end
end
function Aptechka:UpdateAbsorbBarConfig()
    if Aptechka.db.global.disableAbsorbBar then
        self:ForEachFrame(AbsorbBarDisable)
    else
        self:ForEachFrame(AbsorbBarEnable)
        self:ForEachFrame(Aptechka.FrameUpdateAbsorb)
    end
end
function Aptechka.FrameUpdateAbsorb(frame, unit)
    local a,hm = UnitGetTotalAbsorbs(unit), UnitHealthMax(unit)
    local h = UnitHealth(unit)
    local ch, p = 0, 0
    if hm ~= 0 then
        p = a/hm
        ch = h/hm
    end
    frame.absorb:SetValue(p, ch)
    frame.absorb2:SetValue(p, ch)
end
function Aptechka.UNIT_ABSORB_AMOUNT_CHANGED(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateAbsorb)
end
function Aptechka.FrameUpdateHealAbsorb(frame, unit)
    local a = UnitGetTotalHealAbsorbs(unit)
    local hm = UnitHealthMax(unit)
    local h = UnitHealth(unit)
    local ch, p = 0, 0
    if hm ~= 0 then
        ch = (h/hm)
        p = a/hm
    end
    frame.healabsorb:SetValue(p, ch)
end
function Aptechka.UNIT_HEAL_ABSORB_AMOUNT_CHANGED(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateHealAbsorb)
end

local function GetForegroundSeparation(health, healthMax, showMissing)
    if showMissing then
        return (healthMax - health)/healthMax, health/healthMax
    else
        return health/healthMax, health/healthMax
    end
end

function Aptechka:UNIT_MAXHEALTH(event, unit)
    if unit == "player" then
        threshold = UnitHealthMax("player")*0.04 -- 4% of player max health
    end
    return Aptechka:UNIT_HEALTH(event, unit)
end
function Aptechka.FrameUpdateHealth(self, unit, event)
    local h,hm = UnitHealth(unit), UnitHealthMax(unit)
    local shields = UnitGetTotalAbsorbs(unit)
    local healabsorb = UnitGetTotalHealAbsorbs(unit)
    local incomingHeal = GetIncomingHealsCustom(unit, ignoreplayer)
    if hm == 0 then return end
    local foregroundValue, perc = GetForegroundSeparation(h, hm, fgShowMissing)
    local state = self.state
    state.vHealth = h
    state.vHealthMax = hm
    self.health:SetValue(foregroundValue*100)
    self.healabsorb:SetValue(healabsorb/hm, perc)
    self.absorb2:SetValue(shields/hm, perc)
    self.absorb:SetValue(shields/hm, perc)
    self.health.incoming:SetValue(incomingHeal/hm, perc)

    if damageEffect then
        local diff = perc - (state.healthPercent or perc)
        local flashes = state.flashes
        if not flashes then
            state.flashes = {}
            flashes = state.flashes
        end

        if diff < -0.02 then -- Damage taken is more than 2%
            local flash = self.flashPool:Acquire()
            local oldPerc = perc + (-diff)
            if self.flashPool:FireEffect(flash, diff, perc, state, oldPerc) then
                flashes[oldPerc] = flash
            end
        elseif diff > 0 then -- Heals
            for oldPerc, flash in pairs(flashes) do
                if perc >= oldPerc then
                    self.flashPool:StopEffect(flash)
                end
            end
        end
    end

    --[[
    if enableLowHealthStatus then
        local old_perc = state.healthPercent or 1
        local wasLow = old_perc < 0.35
        local isLow = perc < 0.35
        if wasLow ~= isLow then
            FrameSetJob(self, config.LowHealthStatus, isLow)
        end
    end
    ]]

    state.healthPercent = perc
    if gradientHealthColor then
        FrameSetJob(self, config.HealthBarColor, true)
    end
    FrameSetJob(self, config.HealthDeficitStatus, ((hm-h) > hm*0.05) )

    local isDead = UnitIsDeadOrGhost(unit)
    if isDead then
        FrameSetJob(self, config.AggroStatus, false)
        local isGhost = UnitIsGhost(unit)
        local deadorghost = isGhost and config.GhostStatus or config.DeadStatus
        FrameSetJob(self, deadorghost, true)
        FrameSetJob(self,config.HealthDeficitStatus, false )
        state.isDead = true
        state.isGhost = isGhost
        Aptechka.FrameUpdateDisplayPower(self, unit, true)
    elseif state.wasDead ~= isDead then
        state.isDead = nil
        state.isGhost = nil
        Aptechka.FrameScanAuras(self, unit)
        FrameSetJob(self, config.GhostStatus, false)
        FrameSetJob(self, config.DeadStatus, false)
        Aptechka.FrameUpdateDisplayPower(self, unit, false)
    end
    state.wasDead = isDead
end
function Aptechka.UNIT_HEALTH(self, event, unit)
    -- local beginTime1 = debugprofilestop();

    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateHealth, event)

    -- local timeUsed1 = debugprofilestop();
    -- print("UNIT_HEALTH", timeUsed1 - beginTime1)
end

function Aptechka.FrameUpdateIncomingRes(frame, unit)
    FrameSetJob(frame, config.IncResStatus, UnitHasIncomingResurrection(unit))
end
function Aptechka.INCOMING_RESURRECT_CHANGED(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateIncomingRes)
end

function Aptechka.FrameCheckPhase(frame, unit)
    --[[
    elseif HasIncomingSummon(unit) then
        local status = C_IncomingSummon.IncomingSummonStatus(unit);
        if(status == Enum.SummonStatus.Pending) then
            frame.centericon.texture:SetAtlas("Raid-Icon-SummonPending");
        elseif( status == Enum.SummonStatus.Accepted ) then
            frame.centericon.texture:SetAtlas("Raid-Icon-SummonAccepted");
        elseif( status == Enum.SummonStatus.Declined ) then
            frame.centericon.texture:SetAtlas("Raid-Icon-SummonDeclined");
        end
        frame.centericon.texture:SetTexCoord(0,1,0,1);
        frame.centericon:Show()
    ]]
    local isPhased = UnitIsPlayer(unit) and UnitPhaseReason(unit) and not frame.state.isInVehicle
    FrameSetJob(frame, config.PhasedStatus, isPhased)
end

function Aptechka.UNIT_PHASE(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameCheckPhase)
end

function Aptechka.FrameUpdateMindControl(frame, unit)
    -- local currentUnit = SecureButton_GetModifiedUnit(frame)
    local ownerUnit = SecureButton_GetUnit(frame)
    -- if a button is currently overridden by pet(vehicle) unit, it'll report as charmed
    -- so always using owner unit to check
    local isMindControlled = UnitIsCharmed(ownerUnit)

    FrameSetJob(frame, config.MindControlStatus, isMindControlled)
end
function Aptechka:UpdateMindControl(unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateMindControl)
end


local function WidgetStartTrace(widget, slot, frame, opts)
    if not widget then
        widget = Aptechka:CreateDynamicWidget(frame, slot)
    end
    if widget then
        widget:StartTrace(opts)
    end
end
local function FrameStartTrace(frame, unit, opts)
    Aptechka:ForEachWidget(frame, opts, WidgetStartTrace, frame, opts)
end
Aptechka.FrameStartTrace = FrameStartTrace

local function FrameBumpAuraEvent(frame, unit, spellID)
    frame.auraEvents[spellID] = GetTime()
end

function Aptechka:COMBAT_LOG_EVENT_UNFILTERED(event)
    local timestamp, eventType, hideCaster,
    srcGUID, srcName, srcFlags, srcFlags2,
    dstGUID, dstName, dstFlags, dstFlags2,
    spellID, spellName, spellSchool, amount, overhealing, absorbed, critical = CombatLogGetCurrentEventInfo()
    if enableTraceheals and bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE then
        local opts = traceheals[spellID]
        if opts and eventType == opts.type then
            if guidMap[dstGUID] and not opts.disabled then
                local minamount = opts.minamount
                if not minamount or amount > minamount then
                    local unit = guidMap[dstGUID]
                    Aptechka:ForEachUnitFrame(unit, FrameStartTrace, opts)
                end
            end
        end
    end
    if enableAuraEvents and bit_band(dstFlags, COMBATLOG_OBJECT_AFFILIATION_UPTORAID) > 0 then
        if  eventType == "SPELL_AURA_APPLIED" or
            eventType == "SPELL_AURA_REFRESH" or
            eventType == "SPELL_AURA_APPLIED_DOSE"
        then
            local unit = guidMap[dstGUID]
            Aptechka:ForEachUnitFrame(unit, FrameBumpAuraEvent, spellID)
        end
    end
end

function Aptechka.UNIT_FACTION(self, event, unit)
    self:UpdateMindControl(unit)
end

local purgeOldAuraEvents = function(frame)
    table.wipe(frame.auraEvents)
end

function Aptechka:PLAYER_ENTERING_WORLD(event)
    self:ForEachFrame(Aptechka.FrameUpdateIncomingSummon)
    Aptechka:ForEachFrame(purgeOldAuraEvents)
end

function Aptechka.FrameUpdateIncomingSummon(frame, unit)
    if HasIncomingSummon(unit) then
        local status = C_IncomingSummon.IncomingSummonStatus(unit);
        if(status == Enum.SummonStatus.Pending) then
            FrameSetJob(frame, config.SummonPending, true)
        elseif( status == Enum.SummonStatus.Accepted ) then
            FrameSetJob(frame, config.SummonAccepted, true)
        elseif( status == Enum.SummonStatus.Declined ) then
            FrameSetJob(frame, config.SummonDeclined, true)
        end
    else
        FrameSetJob(frame, config.SummonPending, false)
        FrameSetJob(frame, config.SummonAccepted, false)
        FrameSetJob(frame, config.SummonDeclined, false)
    end
end
function Aptechka.INCOMING_SUMMON_CHANGED(self, event, unit)
    self:ForEachUnitFrame(unit, Aptechka.FrameUpdateIncomingSummon)
end

local afkPlayerTable = {}
function Aptechka.FrameUpdateAFK(frame, unit)
    local guid = UnitGUID(unit)
    if UnitIsAFK(unit) then
        local startTime = afkPlayerTable[guid]
        if not startTime then
            startTime = GetTime()
            afkPlayerTable[guid] = startTime
        end

        FrameSetJob(frame, config.AwayStatus, true, "TIMER", startTime)
    else
        if guid then
            afkPlayerTable[guid] = nil
        end
        FrameSetJob(frame, config.AwayStatus, false)
    end
end
function Aptechka.UNIT_AFK_CHANGED(self, event, unit)
    self:ForEachUnitFrame(unit, Aptechka.FrameUpdateAFK)
end
Aptechka.PLAYER_FLAGS_CHANGED = Aptechka.UNIT_AFK_CHANGED


local offlinePlayerTable = {}
function Aptechka.FrameUpdateConnection(frame, unit)
    -- if self.unitOwner then unit = self.unitOwner end
    local name = UnitGUID(unit)
    if not UnitIsConnected(unit) then
        if name then
            local startTime = offlinePlayerTable[name]
            if not startTime then
                startTime = GetTime()
                offlinePlayerTable[name] = startTime
            end
            FrameSetJob(frame, config.OfflineStatus, true, "TIMER", startTime)
        else
            FrameSetJob(frame, config.OfflineStatus, true)
        end
    else
        if name then
            offlinePlayerTable[name] = nil
        end
        FrameSetJob(frame, config.OfflineStatus, false)
    end
end
function Aptechka.UNIT_CONNECTION(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateConnection)
end

local Enum_RunicPower = Enum.PowerType.RunicPower
local Enum_Alternate = Enum.PowerType.Alternate
function Aptechka.FrameUpdatePower(frame, unit, ptype)
    if ptype == "MANA" then-- not frame.power.disabled then
        local powerMax = UnitPowerMax(unit)
        local power = UnitPower(unit)
        if powerMax == 0 then
            power = 1
            powerMax = 1
        end
        local manaPercent = GetForegroundSeparation(power, powerMax, fgShowMissing)
        frame.power:SetValue(manaPercent*100)
    elseif ptype == "RUNIC_POWER" then
        if not Aptechka:UnitIsTank(unit) then
            return FrameSetJob(frame, config.RunicPowerStatus, false)
        end
        local powerMax = UnitPowerMax(unit, Enum_RunicPower)
        local power = UnitPower(unit, Enum_RunicPower)
        if power > 40 then
            local p = power/powerMax
            FrameSetJob(frame, config.RunicPowerStatus, true, "PROGRESS", p)
        else
            FrameSetJob(frame, config.RunicPowerStatus, false)
        end
    elseif ptype == "ALTERNATE" then
        local powerMax = UnitPowerMax(unit, Enum_Alternate)
        local power = UnitPower(unit, Enum_Alternate)
        if power > 0 then
            local p = power/powerMax
            FrameSetJob(frame, config.AlternatePowerStatus, true, "PROGRESS", p)
        else
            FrameSetJob(frame, config.AlternatePowerStatus, false)
        end
    end
end
function Aptechka.UNIT_POWER_UPDATE(self, event, unit, ptype)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdatePower, ptype)
end

function Aptechka.FrameUpdateDisplayPower(frame, unit, isDead)
    if frame.power and frame.power.OnPowerTypeChange then
        local tnum, tname = UnitPowerType(unit)
        frame.power:OnPowerTypeChange(tname, isDead)
    end
end
function Aptechka.UNIT_DISPLAYPOWER(self, event, unit, isDead)
    self:ForEachUnitFrame(unit, Aptechka.FrameUpdateDisplayPower, isDead)
end

local vehicleHack = function (self, time)
    self.OnUpdateCounter = self.OnUpdateCounter + time
    if self.OnUpdateCounter < 1 then return end
    self.OnUpdateCounter = 0
    local frame = self.parent
    local owner = frame.unitOwner
    if not ( UnitHasVehicleUI(owner) or UnitInVehicle(owner) or UnitUsingVehicle(owner) ) then
        if Roster[frame.unit] then
            -- Restore owner unit in the roster, delete vehicle unit
            Roster[owner] = Roster[frame.unit]
            Roster[frame.unit] = nil
            frame.unit = owner
            frame.unitOwner = nil
            frame.guid = UnitGUID(owner)
            frame.state.isInVehicle = nil

            -- Remove vehicle status
            SetJob(owner, config.InVehicleStatus,false)
            -- Update unitframe back to owner's unit health, etc.
            Aptechka.FrameUpdateHealth(frame, owner, "VEHICLE")
            if frame.power then
                Aptechka.FrameUpdateDisplayPower(frame, owner)
                local ptype = select(2,UnitPowerType(owner))
                Aptechka.FrameUpdatePower(frame, owner, ptype)
                Aptechka.FrameUpdatePower(frame, owner, "ALTERNATE")
            end
            if frame.absorb then
                Aptechka:UNIT_ABSORB_AMOUNT_CHANGED(nil, owner)
            end
            Aptechka.FrameScanAuras(frame, owner)
            Aptechka.FrameUpdateMindControl(frame, owner)

            -- Stop periodic checks
            self:SetScript("OnUpdate",nil)
        end
    end
end

function Aptechka.FrameOnEnteredVehicle(frame, unit)
    local state = frame.state
    if not state.isInVehicle then
        local vehicleUnit = SecureButton_GetModifiedUnit(frame)
        -- local vehicleOwner = SecureButton_GetUnit(frame)
        if unit ~= vehicleUnit then
            state.isInVehicle = true
            frame.unitOwner = unit --original unit
            frame.unit = vehicleUnit

            frame.guid = UnitGUID(vehicleUnit)
            if frame.guid then guidMap[frame.guid] = vehicleUnit end

            -- Delete owner unit from Roster and add point vehicle unit to this button instead
            Roster[frame.unit] = Roster[frame.unitOwner]
            Roster[frame.unitOwner] = nil

            -- A small frame is crated to start 1s periodic OnUpdate checks when unit has left the vehicle
            if not frame.vehicleFrame then frame.vehicleFrame = CreateFrame("Frame", nil, frame); frame.vehicleFrame.parent = frame end
            frame.vehicleFrame.OnUpdateCounter = -1.5
            frame.vehicleFrame:SetScript("OnUpdate",vehicleHack)

            -- Set in vehicle status
            SetJob(frame.unit, config.InVehicleStatus,true)
            -- Update unitframe for the new vehicle unit
            Aptechka.FrameUpdateHealth(frame, frame.unit, "VEHICLE")
            if frame.power then Aptechka.FrameUpdatePower(frame, frame.unit) end
            if frame.absorb then Aptechka.FrameUpdateAbsorb(frame, frame.unit) end
            Aptechka.FrameCheckPhase(frame, frame.unit)
            Aptechka.FrameUpdateIncomingRes(frame, frame.unit)
            Aptechka.FrameScanAuras(frame, frame.unit)

            Aptechka.FrameUpdateMindControl(frame, frame.unit) -- pet unit will be marked as 'charmed'

            -- Except class color, it's still tied to owner
            Aptechka.FrameColorize(frame, frame.unitOwner)
        end
    end
end
function Aptechka.UNIT_ENTERED_VEHICLE(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameOnEnteredVehicle)
end


local function FrameUpdateRangeAlpha(frame, unit)
    if AptechkaUnitInRange(unit) then
        frame:SetAlpha(1)
    else
        frame:SetAlpha(0.45)
    end
end
local function FrameResetRangeAlpha(frame, unit)
    frame:SetAlpha(1)
end
--Range check
Aptechka.OnRangeUpdate = function (self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 0.3 then return end
    self.OnUpdateCounter = 0

    Aptechka:UpdateStagger()

    if not IsInGroup() then --UnitInRange returns false when not grouped
        Aptechka:ForEachFrame(FrameResetRangeAlpha)
        return
    end

    if (RosterUpdateOccured) then
        if RosterUpdateOccured + 3 < GetTime() then
            if not InCombatLockdown() then
                RosterUpdateOccured = nil

                for i,hdr in pairs(group_headers) do
                    local showSolo = hdr:GetAttribute("showSolo")
                    hdr:SetAttribute("showSolo", not showSolo)
                    hdr:SetAttribute("showSolo", showSolo)
                end
            end
        end
    end

    Aptechka:ForEachFrame(FrameUpdateRangeAlpha)
end

--Aggro
function Aptechka:UpdateAggroConfig()
    if not config.AggroStatus then return end
    if AptechkaDB.profile.showAggro then
        self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    else
        self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE")

        if self.isInitialized then
            self:ForEachFrame(function(frame)
                FrameSetJob(frame, config.AggroStatus, false)
            end)
        end
    end
end
function Aptechka.FrameUpdateThreat(frame, unit)
    local sit = UnitThreatSituation(unit)
    if sit and sit > 1 then
        FrameSetJob(frame, config.AggroStatus, true)
    else
        FrameSetJob(frame, config.AggroStatus, false)
    end
end
function Aptechka.UNIT_THREAT_SITUATION_UPDATE(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateThreat)
end

function Aptechka.UNIT_SPELLCAST_SENT(self, event, unit, targetName, lineID, spellID)
    if unit ~= "player" or not targetName then return end
    LastCastTargetName = string.match(targetName, "(.+)-") or targetName
    LastCastSentTime = GetTime()
end
function Aptechka.UI_ERROR_MESSAGE(self, event, errcode, errtext)
    if errcode == 51 then -- Out of Range code
        if LastCastSentTime > GetTime() - 0.5 then
            for unit in pairs(Roster) do
                if UnitName(unit) == LastCastTargetName then
                    Aptechka:ForEachUnitFrame(unit, FrameStartTrace, config.LOSStatus)
                    return
                end
            end
        end
    end
end

function Aptechka.FrameUpdateStagger(frame, unit)
    local currentStagger = UnitStagger(unit)
    if not currentStagger then
        return FrameSetJob(frame, config.StaggerStatus, false)
    end
    local maxHP = UnitHealthMax(unit)
    local staggerPercent = currentStagger/maxHP
    frame.state.stagger = staggerPercent
    FrameSetJob(frame, config.StaggerStatus, currentStagger > 0)
end
function Aptechka:UpdateStagger()
    for unit in pairs(staggerUnits) do
        Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateStagger)
    end
end

function Aptechka:UnitIsTank(unit)
    return tankUnits[unit]
end

function Aptechka.FrameCheckRoles(self, unit )

    local isRaidMaintank = GetPartyAssignment("MAINTANK", unit) -- gets updated on GROUP_ROSTER_UPDATE and PLAYER_ROLES_ASSIGNED
    local isTankRoleAssigned = UnitGroupRolesAssigned(unit) == "TANK"
    if unit == "player" then
        local spec = GetSpecialization()
        local specRole = GetSpecializationRole(spec)
        if specRole == "TANK" then
            isTankRoleAssigned = true
        end
    end
    local isAnyTank = isRaidMaintank or isTankRoleAssigned

    if isAnyTank and select(2, UnitClass(unit)) == "MONK" then
        staggerUnits[unit] = true
    elseif staggerUnits[unit] then
        staggerUnits[unit] = nil
        FrameSetJob(self, config.StaggerStatus, false)
    end

    if isAnyTank then
        tankUnits[unit] = true
    else
        tankUnits[unit] = nil
    end

    if config.MainTankStatus then
        FrameSetJob(self, config.MainTankStatus, isAnyTank)
    end

    if config.displayRoles then
        local isLeader = UnitIsGroupLeader(unit)
        local role = UnitGroupRolesAssigned(unit)

        FrameSetJob(self, config.LeaderStatus, isLeader)
        if config.AssistStatus then
            local isAssistant = UnitIsGroupAssistant(unit)
            FrameSetJob(self, config.AssistStatus, isAssistant)
        end

        local icon = self.roleicon.texture
        if icon then
            if UnitGroupRolesAssigned(unit) == "HEALER" then
                -- GetTexCoordsForRoleSmallCircle("HEALER") -- Classic doesn't have this function
                icon:SetTexCoord(20/64, 39/64, 1/64, 20/64); icon:Show()
            elseif isTankRoleAssigned then
                icon:SetTexCoord(0, 19/64, 22/64, 41/64); icon:Show()
            else
                icon:Hide()
            end
        end
    end
end

function Aptechka.PLAYER_REGEN_ENABLED(self,event)
    self:LayoutUpdate()
    self:Reconfigure()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function Aptechka:UpdateRangeChecker()
    local spec = GetSpecialization() or 1
    if config.UnitInRangeFunctions and config.UnitInRangeFunctions[spec] then
        uir = config.UnitInRangeFunctions[spec]
    else
        uir = UnitInRange
    end
end

function Aptechka:UpdateDispelBitmask()
    local spec = GetSpecialization() or 1
    if config.DispelBitmasks and config.DispelBitmasks[spec] then
        BITMASK_DISPELLABLE = config.DispelBitmasks[spec]
    else
        BITMASK_DISPELLABLE = 0
    end
end

function Aptechka.GROUP_ROSTER_UPDATE(self,event,arg1)
    RosterUpdateOccured = GetTime()

    --raid autoscaling
    Aptechka:LayoutUpdate()
    Aptechka:ForEachFrame(Aptechka.FrameCheckRoles)
end


function Aptechka:OnRoleChanged()
    if not InCombatLockdown() then
        -- Will switch profile immediately if possible
        Aptechka:LayoutUpdate()
    else
        -- Reconfigure in combat does nothing, but schedules LayoutUpdate and Reconf on combat exit
        Aptechka:Reconfigure()
    end
end
do
    local currentRole
    function Aptechka:SPELLS_CHANGED()
        Aptechka:UpdateRangeChecker()
        Aptechka:UpdateDispelBitmask()
        Aptechka:ForEachUnitFrame("player", Aptechka.FrameCheckRoles)
        -- enableLowHealthStatus = IsPlayerSpell(265259)

        local role = self:GetSpecRole()
        if role ~= currentRole then
            self:OnRoleChanged()
            currentRole = role
        end
    end
end

function Aptechka:GetCurrentGroupType()
    if IsInRaid() then
        local numMembers = GetNumGroupMembers()
        if numMembers > 30 then
            return "fullRaid"
        elseif numMembers > 22 then
            return "bigRaid"
        elseif numMembers > 10 then
            return "mediumRaid"
        elseif numMembers > 5 then
            return "smallRaid"
        else
            return "party"
        end
    elseif IsInGroup() then
        local numMembers = GetNumGroupMembers()
        if numMembers > 1 then
            return "party"
        else
            return "solo"
        end
    else
        return "solo"
    end
end

function Aptechka.LayoutUpdate(self)
    if not self.db.global.enableProfileSwitching then return end
    local numMembers = GetNumGroupMembers()
    local spec = GetSpecialization()
    local role = self:GetSpecRole()
    local groupType = self:GetCurrentGroupType()

    local newProfileName = self.db.global.profileSelection[role][groupType]

    self.db:SetProfile(newProfileName)
end

--raid icons
function Aptechka:UpdateRaidIconsConfig()
    if not Aptechka.db.profile.showRaidIcons then
        Aptechka:ForEachFrame(function(self) self.raidicon:Hide() end)
        Aptechka:UnregisterEvent("RAID_TARGET_UPDATE")
    else
        Aptechka:RAID_TARGET_UPDATE()
        Aptechka:RegisterEvent("RAID_TARGET_UPDATE")
    end
end

function Aptechka.FrameUpdateRaidTarget(frame, unit)
    local index = GetRaidTargetIndex(unit)
    local icon = frame.raidicon
    if icon then
        if index then
            SetRaidTargetIconTexture(icon.texture, index)
            icon:Show()
        else
            icon:Hide()
        end
    end
end
function Aptechka.RAID_TARGET_UPDATE(self, event)
    if not AptechkaDB.profile.showRaidIcons then return end
    Aptechka:ForEachFrame(Aptechka.FrameUpdateRaidTarget)
end

function Aptechka:ForEachFrame(func)
    for unit, frames in pairs(Roster) do
        for frame in pairs(frames) do
            func(frame, unit)
        end
    end
end

function Aptechka:ForEachUnitFrame(unit, func, ...)
    local frames = Roster[unit]
    if not frames then return end
    for frame in pairs(frames) do
        func(frame, unit, ...)
    end
end

function Aptechka:UpdateTargetStatusConfig()
    if not self.db.global.enableTargetStatus then
        Aptechka:ForEachFrame(function(self) SetJob(self, config.TargetStatus, false) end)
        Aptechka:UnregisterEvent("PLAYER_TARGET_CHANGED")
    else
        Aptechka:PLAYER_TARGET_CHANGED()
        Aptechka:RegisterEvent("PLAYER_TARGET_CHANGED")
    end
end
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
function Aptechka.FrameReadyCheckConfirm(frame, unit)
    local status = GetReadyCheckStatus(unit)
    local opts
    if status == 'ready' then
        FrameSetJob(frame, config.RCWaiting, false)
        FrameSetJob(frame, config.RCReady, true)
    elseif status == 'notready' then
        FrameSetJob(frame, config.RCWaiting, false)
        FrameSetJob(frame, config.RCNotReady, true)
    elseif status == 'waiting' then
        FrameSetJob(frame, config.RCWaiting, true)
    else
        return Aptechka.FrameReadyCheckFinished(frame, unit)
    end
end
function Aptechka.FrameReadyCheckFinished(frame, unit)
    FrameSetJob(frame, config.RCReady, false)
    FrameSetJob(frame, config.RCNotReady, false)
    FrameSetJob(frame, config.RCWaiting, false)
end
function Aptechka:READY_CHECK(event)
    Aptechka:ForEachFrame(Aptechka.FrameReadyCheckConfirm)
end
function Aptechka:READY_CHECK_CONFIRM(event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameReadyCheckConfirm)
end
function Aptechka:READY_CHECK_FINISHED(event)
    Aptechka:ForEachFrame(Aptechka.FrameReadyCheckFinished)
end

--applying UnitButton color

function Aptechka.FrameColorize(frame, unit)
    local hdr = frame:GetParent()

    local state = frame.state

    if hdr.isPetGroup then
        state.classColor = config.petcolor
    else
        local _,class = UnitClass(unit)
        if class then
            local color = colors[class]
            state.classColor = {color.r,color.g,color.b}
        end
    end

    local profile = Aptechka.db.profile

    if profile.healthColorByClass then
        state.healthColor1 = state.classColor
    else
        state.healthColor1 = profile.healthColor1
    end

    state.gradientHealthColor = profile.gradientHealthColor
    if profile.gradientHealthColor then
        state.healthColor2 = profile.healthColor2
        state.healthColor3 = profile.healthColor3
    end
end

function Aptechka.Colorize(self, event, unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameColorize)
end


local has_unknowns = true
local UNKNOWNOBJECT = UNKNOWNOBJECT

local function updateUnitButton(self, unit)
    local owner = unit
    local state = self.state


    -- Why Roster is nested:
    -- Basically because of vehicles. There'll be a moment
    -- when 2 different frames will be assigned to a single 'pet' unit

    -- These checks protect the frame from remapping back from vehicle swap
    -- by a random group header update
    if state.isInVehicle and unit and unit == self.unitOwner then -- GH update for owner unit
        unit = self.unit
        owner = self.unitOwner
    elseif state.isInVehicle and unit then -- GH update is for the pet(vehicle) unit
        owner = self.unitOwner
    else -- update to nil or an unrelated new unit
        if self.vehicleFrame then
            self.vehicleFrame:SetScript("OnUpdate",nil)
            state.isInVehicle = nil
            FrameSetJob(self,config.InVehicleStatus,false)
            -- print ("Killing orphan vehicle frame")
        end
    end

    -- Each group header updates sequentially after GUILD_ROSTER_UPDATE, from 1 to 8
    -- Units tho can be in any order due to sorting and raid groups
    -- When something about unit order changes, it could happen that first new frame was associated with a unit
    -- But then the old frame is either hidden or updated with another unit
    -- And if was hidden, you can't just Roster[oldframe.unit] = nil,
    -- because this unit could already be using a different frame

    -- Removing frames that no longer associated with this unit from Roster
    for roster_unit, frames in pairs(Roster) do
        if frames[self] and (  self:GetAttribute("unit") ~= roster_unit   ) then
            -- print ("Removing frame", self:GetName(), roster_unit, "=>", self:GetAttribute("unit"))
            frames[self] = nil
        end
    end

    -- Header hidden the frame and unit is nil
    if not unit then return end

    local name, realm = UnitName(owner)
    if name == UNKNOWNOBJECT or name == nil then
        has_unknowns = true
    end

    self.unit = unit
    Roster[unit] = Roster[unit] or {}
    Roster[unit][self] = true
    self.guid = UnitGUID(unit) -- is it even needed?
    if self.guid then guidMap[self.guid] = unit end
    for guid, gunit in pairs(guidMap) do
        if not Roster[gunit] or guid ~= UnitGUID(gunit) then guidMap[guid] = nil end
    end

    Aptechka.FrameColorize(self, owner)
    self.state.nameFull = name
    Aptechka:UpdateName(self)

    FrameSetJob(self,config.HealthBarColor,true)
    FrameSetJob(self,config.PowerBarColor,true)
    Aptechka.FrameScanAuras(self, unit)
    state.wasDead = nil
    Aptechka.FrameUpdateHealth(self, unit, "UNIT_HEALTH")
    Aptechka:UNIT_ABSORB_AMOUNT_CHANGED(nil, unit)
    Aptechka.FrameUpdateConnection(self, owner)
    Aptechka.FrameUpdateIncomingSummon(self, owner)

    if AptechkaDB.global.showAFK then
        Aptechka.FrameUpdateAFK(self, owner)
    end
    Aptechka.FrameCheckPhase(self, unit)
    Aptechka.FrameUpdateIncomingRes(self, unit)
    Aptechka.FrameReadyCheckConfirm(self, unit)
    if not config.disableManaBar then
        Aptechka.FrameUpdateDisplayPower(self, unit)
        local ptype = select(2,UnitPowerType(owner))
        Aptechka.FrameUpdatePower(self, unit, ptype)
        Aptechka.FrameUpdatePower(self, unit, "RUNIC_POWER")
        Aptechka.FrameUpdatePower(self, unit, "ALTERNATE")
    end
    Aptechka.FrameUpdateThreat(self, unit)
    Aptechka.FrameUpdateMindControl(self, unit)
    Aptechka:RAID_TARGET_UPDATE()
    if config.enableVehicleSwap and UnitHasVehicleUI(owner) then
        Aptechka:UNIT_ENTERED_VEHICLE(nil,owner) -- scary
    end
    Aptechka.FrameCheckRoles(self, unit)
    if config.enableIncomingHeals then Aptechka:UNIT_HEAL_PREDICTION(nil,unit) end
end

local delayedUpdateTimer = C_Timer.NewTicker(5, function()
    if has_unknowns then
        has_unknowns = false
        -- updateUnitButton may change has_unknowns back to true
        Aptechka:ForEachFrame(updateUnitButton)
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
        local ygap = AptechkaDB.profile.groupGap or config.groupGap
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
Aptechka.arrangeHeaders = arrangeHeaders
local AptechkaHeader_Disable = function(hdr)
    hdr:SetAttribute("showRaid", false)
    hdr:SetAttribute("showParty", false)
    hdr:SetAttribute("showSolo", false)
end
local AptechkaHeader_Enable = function(hdr)
    local groupID = hdr:GetID()
    hdr:SetAttribute("showRaid", AptechkaDB.profile.showRaid)
    if groupID >= 2 and groupID <= 8 then
        hdr:SetAttribute("showParty", false)
        hdr:SetAttribute("showSolo", false)
    else
        hdr:SetAttribute("showParty", AptechkaDB.profile.showParty)
        hdr:SetAttribute("showSolo", AptechkaDB.profile.showSolo)
    end
end
function Aptechka:IsGroupEnabled(id)
    return helpers.CheckBit(self.db.profile.groupFilter, id)
end
function Aptechka:GroupFilterSet(id, state)
    local filterBits = self.db.profile.groupFilter
    if state then
        self.db.profile.groupFilter = helpers.SetBit(filterBits, id)
    else
        self.db.profile.groupFilter = helpers.UnsetBit(filterBits, id)
    end
end
function Aptechka.CreateHeader(self,group,petgroup)
    local frameName = "NugRaid"..group

    local HeaderTemplate = petgroup and "SecureGroupPetHeaderTemplate" or "SecureGroupHeaderTemplate"
    local f = CreateFrame("Button",frameName, UIParent, HeaderTemplate)

    f:SetFrameStrata("BACKGROUND")

    f:SetAttribute("template", "SecureUnitButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate")
    if(Clique) then
        SecureHandlerSetFrameRef(f, 'clickcast_header', Clique.header)
    end


    local xgap = AptechkaDB.profile.unitGap or config.unitGap
    local ygap = AptechkaDB.profile.unitGap or config.unitGap
    local unitgr = reverse(AptechkaDB.profile.unitGrowth or config.unitGrowth)
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
        if AptechkaDB.global.sortUnitsByRole then
            f:SetAttribute("groupBy", "ASSIGNEDROLE")
            f:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
        end
    else
        f.isPetGroup = true
        f:SetAttribute("maxColumns", 1 )
        f:SetAttribute("unitsPerColumn", 5)
        f:SetAttribute("isPetHeader", true)
        --f:SetAttribute("startingIndex", 5*((group - config.maxgroups)-1))
    end
    --our group header doesn't really inherits SecureHandlerBaseTemplate

    f:SetID(group)
    f.Enable = AptechkaHeader_Enable
    f.Disable = AptechkaHeader_Disable
    f:Enable()
    f:SetAttribute("showPlayer", true)
    f.initialConfigFunction = Aptechka.SetupFrame
    f:SetAttribute("initialConfigFunction", self.initConfSnippet)

    local width = pixelperfect(AptechkaDB.profile.width or config.width)
    local height = pixelperfect(AptechkaDB.profile.height or config.height)
    local scale = AptechkaDB.profile.scale or config.scale
    f:SetAttribute("frameWidth", width)
    f:SetAttribute("frameHeight", height)

    f:SetAttribute('_initialAttributeNames', '_onenter,_onleave,refreshUnitChange,_onstate-vehicleui')
    f:SetAttribute('_initialAttribute-_onenter', [[
        local snippet = self:GetAttribute('clickcast_onenter')
        if(snippet) then self:Run(snippet) end
        self:CallMethod("onenter")
    ]])
    f:SetAttribute('_initialAttribute-_onleave', [[
        local snippet = self:GetAttribute('clickcast_onleave')
        if(snippet) then self:Run(snippet) end
        self:CallMethod("onleave")
    ]])

    --[[
    f:SetAttribute('_initialAttribute-_onmousedown', [==[
        print("OnMouseDown", self:GetName(), button)
        if (button == "RightButton") then
            self:SetAttribute("mouselook", "started")
        end
        --self:CallMethod("onMouseDown", button)
    ]==])
    f:SetAttribute('_initialAttribute-_onmouseup', [==[
        print("OnMouseUp", self:GetName(), button)
        if (button == "RightButton") then
            self:SetAttribute("mouselook", "stopped")
        end
        --self:CallMethod("onMouseUp")
    ]==])
    ]]
    -- f:SetAttribute('_initialAttribute-refreshUnitChange', [[
    --     local unit = self:GetAttribute('unit')
    --     if(unit) then
    --         RegisterStateDriver(self, 'vehicleui', '[@' .. unit .. ',unithasvehicleui]vehicle; novehicle')
    --     else
    --         UnregisterStateDriver(self, 'vehicleui')
    --     end
    -- ]])
    -- f:SetAttribute('_initialAttribute-_onstate-vehicleui', [[
    --     local unit = self:GetAttribute('unit')
    --     if(newstate == 'vehicle' and unit and UnitPlayerOrPetInRaid(unit) and not UnitTargetsVehicleInRaidUI(unit)) then
    --         self:SetAttribute('toggleForVehicle', false)
    --     else
    --         self:SetAttribute('toggleForVehicle', true)
    --     end
    -- ]])

    if group == 1 then
        Aptechka:CreateAnchor(f,group)
    end

    -- Buttons will be created after Show
    f:Show()

    return f
end

do -- this function supposed to be called from layout switchers
    function Aptechka:SetGrowth(headers, unitGrowth, groupGrowth)

        local anchorpoint = self:SetAnchorpoint(unitGrowth, groupGrowth)

        local xgap = AptechkaDB.profile.unitGap or config.unitGap
        local ygap = AptechkaDB.profile.unitGap or config.unitGap
        local unitgr = reverse(unitGrowth)
        if unitgr == "RIGHT" then
            xgap = -xgap
        elseif unitgr == "TOP" then
            ygap = -ygap
        end

        local maxGroupsInRow = self.db.profile.groupsInRow

        local numGroups = #headers

        local groupIndex = 1
        local prevRowIndex = 1

        local groupRowGrowth = unitGrowth
        local _, unitDirection = reverse(unitGrowth)
        local _, groupDirection = reverse(groupGrowth)
        -- Group Growth within a single row is typically the same as unit growth, but
        -- if for some reason both directions are on the same axis we use the other axis
        if unitDirection == groupDirection then
            groupRowGrowth = groupDirection == "VERTICAL" and "RIGHT" or "TOP"
        end

        while groupIndex <= numGroups do

            local hdr = headers[groupIndex]

            for _,button in ipairs{ hdr:GetChildren() } do -- group header doesn't clear points when attribute value changes
                button:ClearAllPoints()
            end
            hdr:SetAttribute("point", unitgr)
            hdr:SetAttribute("xOffset", xgap)
            hdr:SetAttribute("yOffset", ygap)
            local petgroup = hdr.isPetGroup

            hdr:ClearAllPoints()
            if groupIndex == 1 then
                hdr:SetPoint(anchorpoint, anchors[groupIndex], reverse(anchorpoint),0,0)
            elseif petgroup then
                hdr:SetPoint(arrangeHeaders(headers[1], nil, unitGrowth, reverse(groupGrowth)))
            else
                if groupIndex >= prevRowIndex + maxGroupsInRow then
                    local prevRowHeader = headers[prevRowIndex]
                    hdr:SetPoint(arrangeHeaders(prevRowHeader, nil, unitGrowth, groupGrowth))
                    prevRowIndex = groupIndex
                else
                    local prevHeader = headers[groupIndex-1]
                    hdr:SetPoint(arrangeHeaders(prevHeader, nil, groupGrowth, groupRowGrowth))
                end
            end
            groupIndex = groupIndex + 1
        end
    end
end

function Aptechka:SetAnchorpoint(unitGrowth, groupGrowth)
    local ug = unitGrowth or config.unitGrowth
    local gg = groupGrowth or config.groupGrowth
    local rug, ud = reverse(ug)
    local rgg, gd = reverse(gg)
    if ud == gd then return rug
    elseif gd == "VERTICAL" and ud == "HORIZONTAL" then return rgg..rug
    elseif ud == "VERTICAL" and gd == "HORIZONTAL" then return rug..rgg
    end
end

function Aptechka:GetSpecRole()
    local spec = GetSpecialization()
    local role = GetSpecializationRole(spec)
    if role ~= "HEALER" then role = "DAMAGER" end
    return role
end

function Aptechka:RepositionAnchor()
    -- local role = self:GetSpecRole()
    local anchorTable = AptechkaDB.profile
    anchors[1].san = anchorTable
    local san = anchorTable
    anchors[1]:ClearAllPoints()
    anchors[1]:SetPoint(san.point,UIParent,san.point,san.x,san.y)
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

    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetFrameStrata("HIGH")

    anchors[num] = f
    f:Hide()
    self:RepositionAnchor()

    f:SetScript("OnDragStart",function(self) self:StartMoving() end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        _,_, self.san.point, self.san.x, self.san.y = self:GetPoint(1)
    end)
end

local onenter = function(self)
    if self.OnMouseEnterFunc then self:OnMouseEnterFunc() end
    if AptechkaDB.global.enableMouseoverStatus then
        FrameSetJob(self, config.MouseoverStatus, true)
    end
    if AptechkaDB.global.disableTooltip or UnitAffectingCombat("player") then return end
    UnitFrame_OnEnter(self)
    self:SetScript("OnUpdate", UnitFrame_OnUpdate)
end
local onleave = function(self)
    if self.OnMouseLeaveFunc then self:OnMouseLeaveFunc() end
    FrameSetJob(self, config.MouseoverStatus, false)
    UnitFrame_OnLeave(self)
    self:SetScript("OnUpdate", nil)
end

function Aptechka.SetupFrame(header, frameName)
    local f = _G[frameName]

    local width = pixelperfect(AptechkaDB.profile.width or config.width)
    local height = pixelperfect(AptechkaDB.profile.height or config.height)
    if InCombatLockdown() then
        Aptechka:ReconfigureProtected()
    end

    if not InCombatLockdown() then
        f:SetSize(width, height)
    end

    f.onenter = onenter
    f.onleave = onleave

    if AptechkaDB.global.RMBClickthrough then
        -- Another way of doing this:
        -- f:RegisterForClicks("AnyUp", "RightButtonDown")
        -- And then in button setup
        -- self:SetAttribute("type2","macro")
        -- self:SetAttribute("macrotext2", "/script MouselookStart()"
        -- But click on mouse down screws up unit's menu
        -- And using OnMouseDown allows it to still work with Clique, only breaking the nomodifier-RMB bind

        f:SetScript("OnMouseDown", function(self, button)
            if not IsModifierKeyDown() then
                if button == "RightButton" then
                    MouselookStart()
                -- elseif LMBClickThrough and button == "LeftButton" then
                --     MouselookStart()
                end
            end
        end)

        -- f:SetScript("OnMouseUp", function(self, button)
        --     print(GetTime(), "OnMouseUp", self:GetName(), button)
        --     if RMBClickthrough and button == "RightButton" then
        --         if (IsMouselooking()) then MouselookStop() end
        --     elseif LMBClickThrough and button == "LeftButton" then
        --         if (IsMouselooking()) then MouselookStop() end
        --     end
        -- end)
    end

    f:RegisterForClicks(unpack(config.registerForClicks))

    f.state = {
        widgets = {}
    }
    local state = f.state

    f.activeAuras = {}
    f.auraEvents = {}

    config.GridSkin(f)
    if Aptechka.db.global.disableAbsorbBar then
        AbsorbBarDisable(f)
    end
    f:ReconfigureUnitFrame()
    if Aptechka.PostFrameCreate then
        Aptechka.PostFrameCreate(f)
    end
    if Aptechka.PostFrameUpdate then
        Aptechka.PostFrameUpdate(f)
    end

    f.self = f
    f.HideFunc = f.HideFunc or Aptechka.DummyFunction

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

    f:HookScript("OnAttributeChanged", OnAttributeChanged)
end


local updateTable = function(tbl, ...)
    local numArgs = select("#", ...)
    for i=1, numArgs do
        tbl[i] = select(i, ...)
    end
end

local jobSortFunc = function(a,b)
    local ap = a.job.priority or 80
    local bp = b.job.priority or 80
    if ap == bp then
        if not a[3] then return false end
        if not b[3] then return true end
        return a[3] > b[3] -- expirationTime
    else
        return ap > bp
    end
end


local function OrderedHashMap_Add(t, dataID, job, ...)
    local existingIndex = t[dataID]
    if existingIndex then
        updateTable(t[existingIndex], ...)
        -- print(dataID, "table update")
    else
        local newData = { ... }
        newData.job = job
        tinsert(t, newData)
        -- print(dataID, "new table")
    end

    tsort(t, jobSortFunc)

    -- check if after sorting with overwritten data job remained in the same place
    if not existingIndex or t[existingIndex].job.name ~= dataID then
        -- print("Updating hash part")
        for i=1, #t do
            local id = t[i].job.name
            t[id] = i
        end
    end
end

local function OrderedHashMap_Remove(t, dataID)
    local existingIndex = t[dataID]
    if existingIndex then
        tremove(t, existingIndex)
        t[dataID] = nil
        tsort(t, jobSortFunc)
        for i=1, #t do
            local id = t[i].job.name
            t[id] = i
        end
    end
end

local lastDeadAssignmentError = 0
function Aptechka:PrintDeadAssignmentWarning(slot, statusName)
    if GetTime() - lastDeadAssignmentError > 120 then
        Aptechka:Print(string.format("Widget '%s' called by '%s' doesn't exist. Use |cff88ff99/apt purge|r to clear dead assignments and reload UI.", slot, statusName))
        lastDeadAssignmentError = GetTime()
    end
end

local AssignToSlot = function(frame, opts, enabled, slot, contentType, ...)
    -- if widgetSet and not widgetSet[slot] then return end

    local widget = frame[slot]
    local state = frame.state

    if not widget then
        if not enabled then return end
        widget = Aptechka:CreateDynamicWidget(frame, slot)
        if not widget then
            Aptechka:PrintDeadAssignmentWarning(slot, opts.name)
            return
        end
    end

    local widgetState = state.widgets[widget]
    if not widgetState then
        widgetState = {}
        state.widgets[widget] = widgetState
    end


    -- short exit if disabling auras on already empty widget
    if not widget.currentJob and enabled == false then return end

    local jobName = opts.name
    if not jobName then return end

    if enabled then
        contentType = contentType or jobName
        OrderedHashMap_Add(widgetState, jobName, opts, contentType, ...)

        if contentType == "AURA" and opts.realID and not opts.isMissing then
            frame.activeAuras[opts.realID] = opts
        end
    else
        OrderedHashMap_Remove(widgetState, jobName)
    end


    local currentJobData = widgetState[1]
    if currentJobData then
        widget.previousJob = widget.currentJob
        widget.currentJob = currentJobData.job -- important that it's before SetJob

        if widget ~= frame then widget:Show() end   -- taint if we show protected unitbutton frame
        widget:SetJob(currentJobData.job, state, unpack(currentJobData))
    else
        if widget ~= frame then widget:Hide() end
        widget.previousJob = widget.currentJob
        widget.currentJob = nil
    end

end
Aptechka.AssignToSlot = AssignToSlot

-- Partially duplicates the function above, used to refresh widget after trace animation override
function Aptechka:UpdateWidget(frame, widget)
    local state = frame.state
    local widgetState = state.widgets[widget]
    if not widgetState then
        widget:Hide()
        return
    end

    local currentJobData = widgetState[1]
    if currentJobData then
        widget.previousJob = widget.currentJob
        widget.currentJob = currentJobData.job -- important that it's before SetJob

        if widget ~= frame then widget:Show() end   -- taint if we show protected unitbutton frame
        if widget.SetJob then
            widget:SetJob(currentJobData.job, state, unpack(currentJobData))
        end
    else
        if widget ~= frame then widget:Hide() end
        widget.previousJob = widget.currentJob
        widget.currentJob = nil
    end
end

-- Clears and reapplies a job with the same args, used in statau list for dynamic updates
function Aptechka:ReapplyJob(opts)
    assert(opts)
    Aptechka:ForEachFrame(function(frame, unit)
        local args = Aptechka:GetJobArgs(frame, opts)
        if args then
            Aptechka.FrameSetJob(frame, opts, false)
            Aptechka.FrameSetJob(frame, opts, true, unpack(args))
        end
    end)
end


-- Doubles as a check whether a job is active
function Aptechka:GetJobArgs(frame, opts)
    if opts.assignto then
        for slot, slotEnabled in pairs(opts.assignto) do
            if slotEnabled then
                local widget = frame[slot]
                local state = frame.state
                local widgetState = state.widgets[widget]
                if not widgetState or not widgetState[opts.name] then
                    return nil
                end

                local index = widgetState[opts.name]
                return widgetState[index]
            end
        end
    end
end

function Aptechka.FrameSetJob(frame, opts, enabled, ...)
    if opts and opts.assignto then
        for slot, slotEnabled in pairs(opts.assignto) do
            if slotEnabled then
                AssignToSlot(frame, opts, enabled, slot, ...)
            end
        end
    end
end
FrameSetJob = Aptechka.FrameSetJob


local FSJProxy = function(frame, unit, ...)
    FrameSetJob(frame, ...)
end
function Aptechka.SetJob(unit, opts, enabled, ...)
    Aptechka:ForEachUnitFrame(unit, FSJProxy, opts, enabled, ...)
end
SetJob = Aptechka.SetJob

function Aptechka:ForEachWidget(frame, opts, func, ...)
    if opts and opts.assignto then
        for slot in pairs(opts.assignto) do
            func(frame[slot], slot, ...)
        end
    end
end

local GetRealID = function(id) return type(id) == "table" and id[1] or id end
-----------------------
-- AURAS
-----------------------

local function SetDebuffIcon(frame, unit, index, debuffType, expirationTime, duration, icon, count, isBossAura, spellID, spellName)
        local iconFrame = frame.debuffIcons[index]
        if debuffType == false then
            iconFrame:Hide()
        else
            iconFrame:SetJob(debuffType, expirationTime, duration, icon, count, isBossAura, spellID)
            iconFrame:Show()

            local refreshTimestamp = frame.auraEvents[spellID]
            local now = GetTime()
            if refreshTimestamp and now - refreshTimestamp < 0.1 then
                frame.auraEvents[spellID] = nil

                iconFrame.eyeCatcher:Stop()
                iconFrame.eyeCatcher:Play()
            end
        end
end


local encountered = {}

local function IndicatorAurasProc(frame, unit, index, slot, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID )
    -- local name, icon, count, _, duration, expirationTime, caster, _,_, spellID = UnitAura(unit, i, auraType)

    local opts = auras[spellID] or loadedAuras[spellID]
    if opts and not opts.disabled then
        if caster == "player" or not opts.isMine then
            local realID = GetRealID(opts.id)
            opts.realID = realID

            encountered[realID] = opts

            local status = true
            if opts.isMissing then status = false end

            local minduration = opts.extend_below
            if minduration and duration < minduration then
                duration = minduration
            end
            -- local hash = GetAuraHash(spellID, duration, expirationTime, count, caster)

            FrameSetJob(frame, opts, status, "AURA", duration, expirationTime, count, icon, spellID, caster)
        end
    end
end

local function IndicatorAurasPostUpdate(frame, unit)
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
                    local isKnown = true
                    if optsMissing.isKnownCheck then
                        isKnown = optsMissing.isKnownCheck(unit)
                    end
                    if isKnown then
                        FrameSetJob(frame, optsMissing, true)
                    end
                end
            end
end

-----------------------
-- Debuff Handling
-----------------------

local debuffList = {}
local sortfunc = function(a,b)
    return a[2] > b[2]
end
local visType = "RAID_OUTOFCOMBAT"

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

local function SpellLocksProc(unit)
    -- local spellLocked = LibSpellLocks:GetSpellLockInfo(unit)
    local spellID, name, icon, duration, expirationTime = LibSpellLocks:GetSpellLockInfo(unit)
    if spellID then
        tinsert(debuffList, { -1, LibAuraTypes.GetAuraTypePriority("SILENCE", "ALLY")})
    end
end

---------------------------
-- Ordered
---------------------------
local BITMASK_DISEASE = helpers.BITMASK_DISEASE
local BITMASK_POISON = helpers.BITMASK_POISON
local BITMASK_CURSE = helpers.BITMASK_CURSE
local BITMASK_MAGIC = helpers.BITMASK_MAGIC
local function GetDebuffTypeBitmask(debuffType)
    if debuffType == "Magic" then
        return BITMASK_MAGIC
    elseif debuffType == "Poison" then
        return BITMASK_POISON
    elseif debuffType == "Disease" then
        return BITMASK_DISEASE
    elseif debuffType == "Curse" then
        return BITMASK_CURSE
    end
    return 0
end

function Aptechka.OrderedDebuffProc(frame, unit, index, slot, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura)
    if UtilShouldDisplayDebuff(spellID, caster, visType) and not blacklist[spellID] then
        local prio, spellType = LibAuraTypes.GetAuraInfo(spellID, "ALLY")
        if not prio then
            prio = (isBossAura and 60) or 0
        end
        if debuffType then
            local mask = GetDebuffTypeBitmask(debuffType)
            if bit_band( mask, BITMASK_DISPELLABLE ) > 0 then
                prio = prio + 15
            end
        end
        tinsert(debuffList, { slot or index, prio, filter })
        -- tinsert(debuffList, { index, prio, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura })
        return 1
    end
    return 0
end

function Aptechka.OrderedBuffProc(frame, unit, index, slot, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura)
    if isBossAura and not blacklist[spellID] then
        local prio = 60
        tinsert(debuffList, { slot or index, prio, filter })
        return 1
    end
    return 0
end

function Aptechka.OrderedDebuffPostUpdate(frame, unit)
    local debuffIcons = frame.debuffIcons
    local debuffLineLength = debuffIcons.maxChildren
    local shown = 0
    local fill = 0

    if LibSpellLocks then
        SpellLocksProc(unit)
    end

    tsort(debuffList, sortfunc)

    for i, debuffIndexCont in ipairs(debuffList) do
        local indexOrSlot, prio, auraFilter = unpack(debuffIndexCont)
        local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura
        if indexOrSlot >= 0 then
            name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAuraBySlot(unit, indexOrSlot) -- UnitAura(unit, indexOrSlot, auraFilter)
            if auraFilter == "HELPFUL" then
                debuffType = "Helpful"
            end
            -- name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAuraBySlot(unit, indexOrSlot)
            if prio >= 50 then -- 50 is roots
                isBossAura = true
            end
        else
            spellID, name, icon, duration, expirationTime = LibSpellLocks:GetSpellLockInfo(unit)
            count = 0
            isBossAura = true
        end

        fill = fill + (isBossAura and Aptechka._BossDebuffScale or 1)

        if fill <= debuffLineLength then
            shown = shown + 1
            debuffIcons:SetDebuffIcon(frame, unit, shown, name, debuffType, expirationTime, duration, icon, count, isBossAura, spellID)
        else
            break
        end
    end

    for i=shown+1, debuffLineLength do
        debuffIcons:SetDebuffIcon(frame, unit, i, nil)
    end
end

---------------------------
-- Simple
---------------------------
function Aptechka.SimpleDebuffProc(frame, unit, index, slot, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura)
    if UtilShouldDisplayDebuff(spellID, caster, visType) and not blacklist[spellID] then
        if isBossAura then
            tinsert(debuffList, 1, slot or index)
        else
            tinsert(debuffList, slot or index)
        end
    end
end

function Aptechka.SimpleBuffProc(frame, unit, index, slot, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura)
    -- Uncommen when moving to Slot API
    if isBossAura then
        tinsert(debuffList, 1, slot or index)
    end
end

function Aptechka.SimpleDebuffPostUpdate(frame, unit)
    local shown = 0
    local fill = 0
    local debuffLineLength = debuffLimit

    for i, indexOrSlot in ipairs(debuffList) do
        local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAuraBySlot(unit, indexOrSlot) -- UnitAura(unit, indexOrSlot, "HARMFUL")
        -- local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAuraBySlot(unit, indexOrSlot)

        fill = fill + (isBossAura and Aptechka._BossDebuffScale or 1)

        if fill <= debuffLineLength then
            shown = shown + 1
            SetDebuffIcon(frame, unit, shown, debuffType, expirationTime, duration, icon, count, isBossAura, spellID, name)
        else
            break
        end
    end

    for i=shown+1, debuffLineLength do
        SetDebuffIcon(frame, unit, i, false)
    end
end
---------------------------
-- Debuff Highlight
---------------------------
local highlightedDebuffsBits -- Resets to 0 at the start of every aura scan
function Aptechka.HighlightProc(frame, unit, index, slot, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID)
    if highlightedDebuffs[spellID] then
        local opts = highlightedDebuffs[spellID]
        local priority = opts[2]
        highlightedDebuffsBits = helpers.SetBit( highlightedDebuffsBits, priority)
        return true
    end
end

function Aptechka.HighlightPostUpdate(frame, unit)
    if frame.state.highlightedDebuffsBits ~= highlightedDebuffsBits then
        for i=1,#config.BossDebuffs do
            FrameSetJob(frame, config.BossDebuffs[i], helpers.CheckBit(highlightedDebuffsBits, i))
        end
        frame.state.highlightedDebuffsBits = highlightedDebuffsBits
    end
end
local HighlightProc = Aptechka.HighlightProc
local HighlightPostUpdate = Aptechka.HighlightPostUpdate

---------------------------
-- Dispel Type Indicator
---------------------------
local debuffTypeMask -- Resets to 0 at the start of every aura scan
function Aptechka.DispelTypeProc(frame, unit, index, slot, filter, name, icon, count, debuffType)
    debuffTypeMask = bit_bor( debuffTypeMask,  GetDebuffTypeBitmask(debuffType))
end

local MagicColor = { 0.2, 0.6, 1}
local CurseColor = { 0.6, 0, 1}
local PoisonColor = { 0, 0.6, 0}
local DiseaseColor = { 0.6, 0.4, 0}
function Aptechka.DispelTypePostUpdate(frame, unit)
    local debuffTypeMaskDispellable = bit_band( debuffTypeMask, BITMASK_DISPELLABLE )

    if frame.debuffTypeMask ~= debuffTypeMaskDispellable then

        local color
        -- local debuffType
        if bit_band(debuffTypeMaskDispellable, BITMASK_MAGIC) > 0 then
            color = MagicColor
            -- debuffType = 1
        elseif bit_band(debuffTypeMaskDispellable, BITMASK_POISON) > 0 then
            color = PoisonColor
            -- debuffType = 2
        elseif bit_band(debuffTypeMaskDispellable, BITMASK_DISEASE) > 0 then
            color = DiseaseColor
            -- debuffType = 3
        elseif bit_band(debuffTypeMaskDispellable, BITMASK_CURSE) > 0 then
            color = CurseColor
            -- debuffType = 4
        end

        if color then
            config.DispelStatus.color = color
            -- config.DispelStatus.debuffType = debuffType
            FrameSetJob(frame, config.DispelStatus, true) --, debuffType)
        else
            FrameSetJob(frame, config.DispelStatus, false)
        end

        frame.debuffTypeMask = debuffTypeMaskDispellable
    end
end
function Aptechka.DummyFunction() end

local handleBuffs = function(frame, unit, index, slot, filter, ...)
    IndicatorAurasProc(frame, unit, index, slot, filter, ...)
    BuffProc(frame, unit, index, slot, filter, ...)
end

local handleDebuffs = function(frame, unit, index, slot, filter, ...)
    IndicatorAurasProc(frame, unit, index, slot, filter, ...)
    DebuffProc(frame, unit, index, slot, filter, ...)
    HighlightProc(frame, unit, index, slot, filter, ...)
    DispelTypeProc(frame, unit, index, slot, filter, ...)
end

function Aptechka.FrameScanAuras(frame, unit)
    -- indicator cleanup
    table_wipe(encountered)
    debuffTypeMask = 0
    highlightedDebuffsBits = 0
    -- debuffs cleanup
    table_wipe(debuffList)


    visType = UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT"

    -- Old API
    --[[
    local filter = "HELPFUL"
    for i=1,100 do
        local name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura = UnitAura(unit, i, filter)
        if not name then break end
        handleBuffs(frame, unit, i, nil, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura)
    end

    filter = "HARMFUL"
    for numDebuffs=1,100 do
        local name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura = UnitAura(unit, numDebuffs, filter)
        if not name then
            -- numDebuffs = numDebuffs-1
            break
        end
        handleDebuffs(frame, unit, numDebuffs, nil, filter, name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowSelf, spellID, canApplyAura, isBossAura)
    end
    ]]

    -- New API
    ForEachAura(frame, unit, "HELPFUL", 5, handleBuffs)
    ForEachAura(frame, unit, "HARMFUL", 5, handleDebuffs)

    IndicatorAurasPostUpdate(frame, unit)
    DebuffPostUpdate(frame, unit)
    DispelTypePostUpdate(frame, unit)
    HighlightPostUpdate(frame, unit)
end
function Aptechka.ScanAuras(unit)
    Aptechka:ForEachUnitFrame(unit, Aptechka.FrameScanAuras)
end

local debugprofilestop = debugprofilestop
function Aptechka.UNIT_AURA(self, event, unit)
    if not Roster[unit] then return end
    -- local beginTime1 = debugprofilestop();
    Aptechka.ScanAuras(unit)
    -- local timeUsed1 = debugprofilestop();
    -- print("ScanAuras", timeUsed1 - beginTime1)
end


function Aptechka:UpdateDebuffScanningMethod()
    local useOrdering = AptechkaDB.global.useDebuffOrdering
    --[[
    if AptechkaDB.global.useDebuffOrdering  then
        local numMembers = GetNumGroupMembers()
        local _, instanceType = GetInstanceInfo()
        local isBattleground = instanceType == "arena" or instanceType == "pvp"
        useOrdering = not IsInRaid() or (isBattleground and numMembers <= 15)
    end
    ]]
    if useOrdering then
        DebuffProc = Aptechka.OrderedDebuffProc
        BuffProc = Aptechka.OrderedBuffProc
        DebuffPostUpdate = Aptechka.OrderedDebuffPostUpdate
    else
        DebuffProc = Aptechka.SimpleDebuffProc
        BuffProc = Aptechka.SimpleBuffProc
        DebuffPostUpdate = Aptechka.SimpleDebuffPostUpdate
    end
    if AptechkaDB.profile.showDispels then
        DispelTypeProc = Aptechka.DispelTypeProc
        DispelTypePostUpdate = Aptechka.DispelTypePostUpdate
    else
        DispelTypeProc = Aptechka.DummyFunction
        DispelTypePostUpdate = Aptechka.DummyFunction
    end
end

function Aptechka:UpdateHighlightedDebuffsHashMap()
    table.wipe(highlightedDebuffs)
    for cat, spells in pairs(config.defaultDebuffHighlights) do
        for spellId, opts in pairs(spells) do
            highlightedDebuffs[spellId] = opts
        end
    end
    for cat, spells in pairs(self.db.global.customDebuffHighlights) do
        for spellId, opts in pairs(spells) do
            if opts == false then
                highlightedDebuffs[spellId] = nil
            else
                highlightedDebuffs[spellId] = opts
            end
        end
    end
end


function Aptechka:TestProfileSwaps()
    local numMembers = math.random(40)
    local fakeRole = math.random(2) == 2 and "HEALER" or "DAMAGER"
    local origGetSpecRole = self.GetSpecRole
    self.GetSpecRole = function()
        return fakeRole
    end

    print("Group size:", numMembers, "Role:", fakeRole)
    GetNumGroupMembers = function()
        return numMembers
    end
    IsInGroup = function()
        return true
    end
    if numMembers > 5 then
        IsInRaid = function()
            return true
        end
    end

    Aptechka:LayoutUpdate()

    GetNumGroupMembers = _G.GetNumGroupMembers
    IsInGroup = _G.IsInGroup
    IsInRaid = _G.IsInRaid
    self.GetSpecRole = origGetSpecRole
end

function Aptechka:TestDebuffSlots()
    Aptechka:ForEachFrame(Aptechka.TestDebuffSlotsForUnit)
end
function Aptechka.TestDebuffSlotsForUnit(frame, unit)
    local shown = 0
    local fill = 0
    local debuffLineLength = frame.debuffIcons.maxChildren

    local numBossAuras = math.random(3)-1
    local now = GetTime()
    local debuffTypes = { "none", "Magic", "Poison", "Curse", "Disease" }
    local randomIDs = { 5211, 19577, 172, 408, 15286, 853, 980, 589, 118, 605 }
    for i=1,6 do
        local spellID = randomIDs[math.random(#randomIDs)]
        local name, _, icon = GetSpellInfo(spellID)
        local duration = math.random(20)+5
        local hasCount = math.random(3) == 1
        local count = hasCount and math.random(18) or 0
        local debuffType = debuffTypes[math.random(#debuffTypes)]
        local expirationTime = now + duration
        local isBossAura = shown < numBossAuras
        fill = fill + (isBossAura and Aptechka._BossDebuffScale or 1)

        -- print(fill, debuffLineLength, fill < debuffLineLength)

        if fill <= debuffLineLength then
            shown = shown + 1
            frame.debuffIcons:SetDebuffIcon(frame, unit, shown, name, debuffType, expirationTime, duration, icon, count, isBossAura, spellID)
        else
            break
        end
    end


    -- local icon = frame.incomingCastIcon
    -- local spellID = randomIDs[math.random(#randomIDs)]
    -- local _, _, texture = GetSpellInfo(spellID)
    -- local startTime = now
    -- local duration = math.random(20)+5
    -- local endTime = startTime + duration
    -- local count = math.random(18)
    -- local castType = "CAST"
    -- icon.texture:SetTexture(texture)
    -- icon.cd:SetReverse(castType == "CAST")

    -- local r,g,b = 1, 0.65, 0

    -- icon.cd:SetSwipeColor(r,g,b);

    -- duration = endTime - startTime
    -- icon.cd:SetCooldown(startTime, duration)
    -- icon.cd:Show()

    -- icon.stacktext:SetText(count > 1 and count)
    -- icon:Show()

    for i=shown+1, debuffLineLength do
        frame.debuffIcons:SetDebuffIcon(frame, unit, i, false)
    end
end

local ParseOpts = function(str)
    local t = {}
    local capture = function(k,v)
        if type(v) == "string" then
            local v2 = v:lower()
            if v2 == "true" then v = true end
            if v2 == "false" then v = false end
            if v2 == "nil" then v = nil end
        end
        t[k:lower()] = tonumber(v) or v
        return ""
    end
    str = str:gsub("(%w+)%s*=%s*%[%[(.-)%]%]", capture)
    str = str:gsub("(%w+)%s*=%s*%\"(.-)%\"", capture)
    str:gsub("(%w+)%s*=%s*(%S+)", capture)
    return t
end
function Aptechka:PrintReloadUIWarning()
    print(AptechkaString..Aptechka.L"Changes will take effect after /reload")
    -- print("|cffffffff|Hgarrmission:APTECHKAReload:|h[/reload]|h|r")
end
-- hooksecurefunc("SetItemRef", function(link, text)
--     local _, linkType = strsplit(":", link)
--     if linkType == "APTECHKAReload" then
--         ReloadUI()
--     end
-- end)

function Aptechka:CreateNewWidget(wtype, wname)
    if not Aptechka.db.global.widgetConfig[wname] then
        Aptechka.db.global.widgetConfig[wname] = Aptechka.Widget[wtype].default
        print("Created", wtype, wname)
    else
        print("Widget already exists:", wname)
    end
end

function Aptechka:ClearWidgetProfileSettings(wname)
    if Aptechka.db.profile.widgetConfig then
        Aptechka.db.profile.widgetConfig[wname] = nil
    end
end

function Aptechka:ResetWidget(wname)
    for profileName, profile in pairs(Aptechka.db.profiles) do
        if profile.widgetConfig then
            profile.widgetConfig[wname] = nil
        end
    end
    local gopts = Aptechka.db.global.widgetConfig[wname]
    local defaultOpts = AptechkaDefaultConfig.DefaultWidgets[wname]
    for k,v in pairs(gopts) do
        gopts[k] = defaultOpts[k]
    end
end

function Aptechka:RemoveWidget(wname)
    if config.DefaultWidgets[wname] then
        print("Can't remove default widget")
        return
    end

    Aptechka.db.global.widgetConfig[wname] = nil
    for profileName, profile in pairs(Aptechka.db.profiles) do
        if profile.widgetConfig then
            profile.widgetConfig[wname] = nil
        end
    end

    Aptechka:ForEachFrame(function(frame)
        local widget = frame[wname]
        if widget then
            widget:SetScript("OnUpdate", nil)
            widget:Hide()
            frame[wname] = nil
        end
    end)
end

function Aptechka:OpenGUI()
    if not IsAddOnLoaded("AptechkaOptions") then
        LoadAddOn("AptechkaOptions")
    end
    InterfaceOptionsFrame_OpenToCategory("Aptechka")
    InterfaceOptionsFrame_OpenToCategory("Aptechka")
end

function Aptechka:Unlock()
    anchors[1]:Show()
end

function Aptechka:ToggleUnlock()
    if anchors[1]:IsShown() then
        Aptechka:Lock()
    else
        Aptechka:Unlock()
    end
end

function Aptechka:Lock()
    for _,anchor in pairs(anchors) do
        anchor:Hide()
    end
    Aptechka:DisableTestMode()
end

Aptechka.Commands = {
    ["unlockall"] = function()
        for _,anchor in pairs(anchors) do
            anchor:Show()
        end
    end,
    ["unlock"] = Aptechka.Unlock,
    ["lock"] = Aptechka.Lock,
    ["gui"] = Aptechka.OpenGUI,
    ["config"] = Aptechka.OpenGUI,
    ["reset"] = function()
        anchors[1].san.point = "CENTER"
        anchors[1].san.x = 0
        anchors[1].san.y = 0
        anchors[1]:ClearAllPoints()
        anchors[1]:SetPoint(anchors[1].san.point, UIParent, anchors[1].san.point, anchors[1].san.x, anchors[1].san.y)
    end,
    ["purge"] = function()
        Aptechka.PurgeDeadAssignments(true)
    end,
    ["togglegroup"] = function(v)
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
        if not AptechkaDB.profile.petGroup then
            if not InCombatLockdown() then
                Aptechka:CreatePetGroup()
            else
                local f = CreateFrame('Frame')
                f:SetScript("OnEvent",function(self)
                    Aptechka:CreatePetGroup()
                    self:SetScript("OnEvent",nil)
                end)
                f:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
        end
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
    ["load"] = function(v)
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
    ["setpos"] = function(v)
        local fields = ParseOpts(v)
        if not next(fields) then print("Usage: /apt setpos point=center x=0 y=0") return end
        local point,x,y = string.upper(fields['point'] or "CENTER"), fields['x'] or 0, fields['y'] or 0
        anchors[1].san.point = point
        anchors[1].san.x = x
        anchors[1].san.y = y
        anchors[1]:ClearAllPoints()
        anchors[1]:SetPoint(point, UIParent, point, x, y)
    end,

    ["widget"] = function(cmdLine)
        local cmd,params = string.match(cmdLine, "([%w%+%-%=]+) ?(.*)")

        if cmd == "create" then
            local p = ParseOpts(params)
            local wtype = p.type

            -- wtype = wtype:upper()
            local wname = p.name
            if not wname then
                print("Widget name not specified")
                return
            end

            if wtype == "DebuffIcon" or wtype == "DebuffIconArray" then
                print("Custom DebuffIcons aren't allowed")
                return
            end

            if wtype and Aptechka.Widget[wtype] then
                Aptechka:CreateNewWidget(wtype, wname)
            else
                print("Unknown widget type:", wtype)
                print("Available types (case sensitive):")
                for k,v in pairs(Aptechka.Widget) do
                    print("  ", k)
                end
            end
        elseif cmd == "delete" or cmd == "remove" then
            local p = ParseOpts(params)
            local wname = p.name
            if wname and Aptechka.db.global.widgetConfig[wname] then
                Aptechka:RemoveWidget(wname)
                print("Removed", wname)
            else
                print("Widget doesn't exist:", wname)
            end
        elseif cmd == "pclear" then
            local p = ParseOpts(params)
            local wname = p.name
            local forAll = p.all
            if wname and Aptechka.db.global.widgetConfig[wname] then
                if forAll then
                    for profileName, profile in pairs(Aptechka.db.profiles) do
                        if profile.widgetConfig then
                            profile.widgetConfig[wname] = nil
                        end
                    end
                    print(string.format("Removed '%s' widget settings on all profiles.", wname))
                else
                    Aptechka:ClearWidgetProfileSettings(wname)
                    print(string.format("Removed '%s' widget settings on '%s' profile.", wname, Aptechka.db:GetCurrentProfile()))
                end

                Aptechka:ReconfigureWidget(wname)
            else
                print("Widget doesn't exist:", wname)
            end
        elseif cmd == "set" or cmd == "pset" then
            local p = ParseOpts(params)
            local forProfile = cmd == "pset"
            local wname = p.name
            local gconfig = Aptechka.db.global.widgetConfig
            local pconfig = Aptechka.db.profile.widgetConfig

            if not wname then
                print("Widget name not specified")
            end

            if gconfig[wname] then
                if forProfile then
                    if not Aptechka.db.profile.widgetConfig then
                        Aptechka.db.profile.widgetConfig = {}
                    end
                    if not Aptechka.db.profile.widgetConfig[wname] then
                        Aptechka.db.profile.widgetConfig[wname] = { }
                        print(string.format("Created '%s' settings for '%s' profile.", wname, Aptechka.db:GetCurrentProfile()))
                    end
                end

                local gopts = gconfig[wname]
                local popts = pconfig and pconfig[wname]
                local opts
                if forProfile then
                    opts = pconfig[wname]
                else
                    opts = gconfig[wname]
                end
                local wtype = gconfig[wname].type
                print("|cffffcc55===", wname, forProfile and "(profile) ===|r" or "===|r")

                for property in pairs(Aptechka.Widget[wtype].default) do
                    if p[property] ~= nil then
                        local oldvalue = tostring(opts[property]) or "NONE"
                        opts[property] = p[property]
                        local newvalue = tostring(opts[property])
                        local text = string.format("%s:     |cffff5555%s|r => |cff88ff88%s|r", property, oldvalue, newvalue)
                        if not forProfile and popts then
                            if popts[property] ~= opts[property] then
                                text = text.." (overriden by profile settings)"
                            end
                        end
                        print("  ", text)
                    end
                end

                Aptechka:ReconfigureWidget(wname)
            else
                print("Widget doesn't exist:", wname)
            end
        elseif cmd == "rename" then
            local p = ParseOpts(params)
            local wname = p.name
            if wname and Aptechka.db.global.widgetConfig[wname] then
                local to = p.to
                if not to then
                    print("New name not specified")
                    return
                end

                if config.DefaultWidgets[wname] or config.DefaultWidgets[to] then
                    print("Can't raname default widget")
                    return
                end

                Aptechka.db.global.widgetConfig[to] = Aptechka.db.global.widgetConfig[wname]
                Aptechka.db.global.widgetConfig[wname] = nil
                for profileName, profile in pairs(Aptechka.db.profiles) do
                    if profile.widgetConfig[wname] then
                        profile.widgetConfig[to] = profile.widgetConfig[wname]
                        profile.widgetConfig[wname] = nil
                    end
                end
                print("Renamed", wname, "to", to)
            else
                print("Widget doesn't exist:", wname)
            end
        elseif cmd == "info" then
            local p = ParseOpts(params)
            local wname = p.name
            if wname and Aptechka.db.global.widgetConfig[wname] then
                local gopts = Aptechka.db.global.widgetConfig[wname]
                print("|cffffcc55===", wname, "(default) ===|r")
                for k,v in pairs(gopts) do
                    print("  ", k, "=", v)
                end

                local popts = Aptechka.db.profile.widgetConfig and Aptechka.db.profile.widgetConfig[wname]
                if popts then
                    print("|cffffcc55===", wname, "(profile) ===|r")
                    for k,v in pairs(popts) do
                        if v ~= gopts[k] then
                            print("  ", k, "=", v)
                        end
                    end
                end
            else
                print("Widget doesn't exist:", wname)
            end
        elseif cmd == "trim" then
            for profileName, profile in pairs(Aptechka.db.profiles) do
                if profile.widgetConfig then
                    for wname, popts in pairs(profile.widgetConfig) do
                        local gopts = Aptechka.db.global.widgetConfig[wname]
                        Aptechka.RemoveDefaults(popts, gopts)
                    end
                end
            end
        elseif cmd == "copy" then
            local p = ParseOpts(params)
            local wname = p.name
            if wname and Aptechka.db.global.widgetConfig[wname] then
                local from = p.from
                local srcProfile = Aptechka.db.profiles[from]
                if srcProfile then
                    local srcpopts = srcProfile.widgetConfig and srcProfile.widgetConfig[wname]
                    if srcpopts then
                        Aptechka.db.profile.widgetConfig[wname] = CopyTable(srcpopts)
                    else
                        print(string.format("Profile %s doesn't have specific settings for %s", from, wname))
                    end
                else
                    print("Profile doesn't exist:", from)
                end
            else
                print("Widget doesn't exist:", wname)
            end
        elseif cmd == "list" then
            print("|cff99FF99Customizable Widgets:|r")
            for wname, opts in pairs(Aptechka.db.global.widgetConfig) do
                local cname = wname
                if config.DefaultWidgets[wname] then
                    cname = string.format("|cffaaaaaa%s|r", wname)
                end
                print(string.format("     %s [%s]", cname, opts.type))
            end
        end
    end,
    -- ["charspec"] = function()
    --     local user = UnitName("player").."@"..GetRealmName()
    --     if AptechkaDB_Global.charspec[user] then AptechkaDB_Global.charspec[user] = nil
    --     else AptechkaDB_Global.charspec[user] = true
    --     end
    --     print (AptechkaString..(AptechkaDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload",0.7,1,0.7)
    -- end,
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
                Aptechka.db.global.customBlacklist[spellID] = true
                local spellName = GetSpellInfo(spellID) or "<Unknown spell>"
                print(string.format("%s (%d) added to debuff blacklist", spellName, spellID))
            end
        elseif cmd == "del" then
            local spellID = tonumber(args)
            if spellID then
                local val = nil
                if defaultBlacklist[spellID] then val = false end -- if nil it'll fallback on __index
                Aptechka.db.global.customBlacklist[spellID] = val
                local spellName = GetSpellInfo(spellID) or "<Unknown spell>"
                print(string.format("%s (%d) removed from debuff blacklist", spellName, spellID))
            end
        else
            print("Default blacklist:")
            for spellID in pairs(defaultBlacklist) do
                local spellName = GetSpellInfo(spellID) or "<Unknown spell>"
                print(string.format("    %s (%d)", spellName, spellID))
            end
            print("Custom blacklist:")
            for spellID in pairs(Aptechka.db.global.customBlacklist) do
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
      |cff00ff00/aptechka|r gui
      |cff00ff00/aptechka|r reset|r
      |cff00ff00/aptechka|r createpets
      |cff00ff00/aptechka|r blacklist add <spellID>
      |cff00ff00/aptechka|r blacklist del <spellID>
      |cff00ff00/aptechka|r blacklist show
      |cff00ff00/aptechka|r widget create type=<Type> name=<Name>
      |cff00ff00/aptechka|r widget list
      |cff00ff00/aptechka|r widget set name=<Name> |cffaaaaaapoint=TOPRIGHT width=5 height=15 x=-10 y=0 vertical=true|r
      |cff00ff00/aptechka|r widget pset name=<Name> |cffaaaaaa...|r - same but for current profile
      |cff00ff00/aptechka|r widget info name=<Name>
      |cff00ff00/aptechka|r widget delete name=<Name>
      |cff00ff00/aptechka|r widget pclear name=<Name> |cffaaaaaa[all=true]|r - Clear settings for profile
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


function Aptechka:UpdateCastsConfig()
    LibTargetedCasts = LibStub("LibTargetedCasts", true)
    if LibTargetedCasts then
        if AptechkaDB.profile.showCasts then
            LibTargetedCasts.RegisterCallback("Aptechka", "SPELLCAST_UPDATE", Aptechka.SPELLCAST_UPDATE)
        else
            LibTargetedCasts.UnregisterCallback("Aptechka", "SPELLCAST_UPDATE")

            if self.isInitialized then
                self:ForEachFrame(function(self)
                    self.incomingCastIcon:Hide()
                end)
            end
        end
    end
end

function Aptechka.FrameUpdateIncomingCast(frame, unit)
    local minSrcGUID
    local minTime
    local totalCasts = 0
    for i, castInfo in ipairs(LibTargetedCasts:GetUnitIncomingCastsTable(unit)) do
        local srcGUID, dstGUID, castType, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = unpack(castInfo)

        local isImportant = importantTargetedCasts[spellID]
        if not blacklist[spellID] then
            totalCasts = totalCasts + 1
            if castType == "CHANNEL" then endTime = endTime - 5 end -- prioritizing channels
            if isImportant then endTime = endTime - 100 end

            if not minTime or endTime < minTime then
                minSrcGUID = srcGUID
                minTime = endTime
                -- print(i)
            end
        end
    end

    local icon = frame.incomingCastIcon
    if minSrcGUID then
        local srcGUID, dstGUID, castType, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = LibTargetedCasts:GetCastInfoBySourceGUID(minSrcGUID)

        icon.texture:SetTexture(texture)
        icon.cd:SetReverse(castType == "CAST")

        local r,g,b
        -- if notInterruptible then
        --     r,g,b = 0.7, 0.7, 0.7
        -- else
        if castType == "CHANNEL" then
            r,g,b = 0.8, 1, 0.3
        else
            r,g,b = 1, 0.65, 0
        end

        icon.cd:SetSwipeColor(r,g,b);

        local duration = endTime - startTime
        icon.cd:SetCooldown(startTime, duration)
        icon.cd:Show()

        icon.stacktext:SetText(totalCasts > 1 and totalCasts)

        icon:Show()
    else
        icon:Hide()
    end
end

function Aptechka.SPELLCAST_UPDATE(event, GUID)
    local unit = guidMap[GUID]
    if unit then
        Aptechka:ForEachUnitFrame(unit, Aptechka.FrameUpdateIncomingCast)
    end
end

function Aptechka:Print(...)
    print(AptechkaString, ...)
end
