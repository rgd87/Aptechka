local addonName, helpers = ...

do
    local CURRENT_DB_VERSION = 15
    function Aptechka:DoMigrations(db)
        if not next(db) or db.DB_VERSION == CURRENT_DB_VERSION then -- skip if db is empty or current
            db.DB_VERSION = CURRENT_DB_VERSION
            return
        end

        if db.DB_VERSION == nil then
            if not db.roleProfile then
                db.roleProfile = {}
            end
            if db["GridSkin"] then
                local oldAnchorData = db["GridSkin"][1]
                db.roleProfile.DAMAGER = oldAnchorData
                db.roleProfile.HEALER = oldAnchorData
                db.GridSkin = nil
            end
            if db.autoscale then
                db.roleProfile.DAMAGER.scaleMediumRaid = db.autoscale.damageMediumRaid
                db.roleProfile.DAMAGER.scaleBigRaid = db.autoscale.damageBigRaid
                db.roleProfile.HEALER.scaleMediumRaid = db.autoscale.healerMediumRaid
                db.roleProfile.HEALER.scaleBigRaid = db.autoscale.healerBigRaid
                db.autoscale = nil
            end

            db.DB_VERSION = 1
        end

        if db.DB_VERSION == 1 then
            db.global = {}
            db.global.disableBlizzardParty = db.disableBlizzardParty
            db.global.hideBlizzardRaid = db.hideBlizzardRaid
            db.global.RMBClickthrough = db.RMBClickthrough
            db.global.sortUnitsByRole = db.sortUnitsByRole
            db.global.showAFK = db.showAFK
            db.global.customBlacklist = db.customBlacklist
            db.global.useCombatLogHealthUpdates = db.useCombatLogHealthUpdates
            db.global.disableTooltip = db.disableTooltip
            db.global.useDebuffOrdering = db.useDebuffOrdering

            db.profiles = {
                Default = {}
            }
            local default_profile = db.profiles["Default"]
            default_profile.width = db.width
            default_profile.height = db.height
            default_profile.healthOrientation = db.healthOrientation
            default_profile.unitGrowth = db.unitGrowth
            default_profile.groupGrowth = db.groupGrowth
            default_profile.unitGap = db.unitGap
            default_profile.groupGap = db.groupGap
            default_profile.showSolo = db.showSolo
            default_profile.showParty = db.showParty
            default_profile.cropNamesLen = db.cropNamesLen
            default_profile.showCasts = db.showCasts
            default_profile.showAggro = db.showAggro
            default_profile.petGroup = db.petGroup
            default_profile.showRaidIcons = db.showRaidIcons
            default_profile.showDispels = db.showDispels
            default_profile.healthTexture = db.healthTexture
            default_profile.powerTexture = db.powerTexture

            default_profile.scale = db.scale
            default_profile.debuffSize = db.debuffSize
            default_profile.debuffLimit = db.debuffLimit
            default_profile.debuffBossScale = db.debuffBossScale
            default_profile.stackFontName = db.stackFontName
            default_profile.stackFontSize = db.stackFontSize
            default_profile.nameFontName = db.nameFontName
            default_profile.nameFontSize = db.nameFontSize
            default_profile.nameFontOutline = db.nameFontOutline
            default_profile.nameColorMultiplier = db.nameColorMultiplier
            default_profile.fgShowMissing = db.fgShowMissing
            default_profile.fgColorMultiplier = db.fgColorMultiplier
            default_profile.bgColorMultiplier = db.bgColorMultiplier

            if db.roleProfile then
                if db.roleProfile["HEALER"] then
                    local old_healer_profile = db.roleProfile["HEALER"]
                    default_profile.point = old_healer_profile.point
                    default_profile.x = old_healer_profile.x
                    default_profile.y = old_healer_profile.y
                end
                if db.useRoleProfiles and db.roleProfile["DAMAGER"] then
                    local old_damager_profile = db.roleProfile["DAMAGER"]
                    -- Create a second profile, copied from our new Default profile
                    db.profiles["DefaultNonHealer"] = CopyTable(default_profile)

                    local default_damager_profile = db.profiles["DefaultNonHealer"]

                    default_damager_profile.point = old_damager_profile.point
                    default_damager_profile.x = old_damager_profile.x
                    default_damager_profile.y = old_damager_profile.y

                    db.global.profileSelection = {
                        DAMAGER = {
                            solo = "DefaultNonHealer",
                            party = "DefaultNonHealer",
                            smallRaid = "DefaultNonHealer",
                            mediumRaid = "DefaultNonHealer",
                            bigRaid = "DefaultNonHealer",
                            fullRaid = "DefaultNonHealer",
                        },
                    }
                end
            end

            db.disableBlizzardParty = nil
            db.hideBlizzardRaid = nil
            db.RMBClickthrough = nil
            db.sortUnitsByRole = nil
            db.showAFK = nil
            db.customBlacklist = nil
            db.useCombatLogHealthUpdates = nil
            db.disableTooltip = nil
            db.useDebuffOrdering = nil

            db.width = nil
            db.height = nil
            db.healthOrientation = nil
            db.unitGrowth = nil
            db.groupGrowth = nil
            db.unitGap = nil
            db.groupGap = nil
            db.showSolo = nil
            db.showParty = nil
            db.cropNamesLen = nil
            db.showCasts = nil
            db.showAggro = nil
            db.petGroup = nil
            db.showRaidIcons = nil
            db.showDispels = nil
            db.healthTexture = nil
            db.powerTexture = nil
            db.scale = nil
            db.debuffSize = nil
            db.debuffLimit = nil
            db.debuffBossScale = nil
            db.stackFontName = nil
            db.stackFontSize = nil
            db.nameFontName = nil
            db.nameFontSize = nil
            db.nameFontOutline = nil
            db.nameColorMultiplier = nil
            db.fgShowMissing = nil
            db.fgColorMultiplier = nil
            db.bgColorMultiplier = nil

            db.roleProfile = nil
            db.useRoleProfiles = nil

            db.charspec = nil

            db.DB_VERSION = 2
        end
        if db.DB_VERSION == 2 then
            local dbc = AptechkaConfigCustom

            local amIDs = {132404, 132403, 203819, 192081 }

            for i=1, 15 do -- GetNumClasses() doesn't exist in classic
                local class = select(2,C_CreatureInfo.GetClassInfo(i))
                if not class then break end
                if AptechkaConfigCustom[class] and AptechkaConfigCustom[class]["auras"] then
                    for _, spellId in ipairs(amIDs) do
                        AptechkaConfigCustom[class]["auras"] = nil
                    end
                end
            end

            db.DB_VERSION = 3
        end
        if db.DB_VERSION == 3 then

            if db.profiles then
                for name, profile in pairs(db.profiles) do
                    if profile.nameFontSize then
                        profile.widgetConfig = profile.widgetConfig or {}
                        profile.widgetConfig.text1 = profile.widgetConfig.text1 or {}
                        profile.widgetConfig.text1.textsize = profile.nameFontSize
                    end
                    profile.nameFontSize = nil

                    if profile.nameFontOutline then
                        profile.widgetConfig = profile.widgetConfig or {}
                        profile.widgetConfig.text1 = profile.widgetConfig.text1 or {}
                        profile.widgetConfig.text1.effect = profile.nameFontOutline
                    end
                    profile.nameFontOutline = nil
                end
            end

            db.DB_VERSION = 4
        end
        if db.DB_VERSION == 4 then
            if db.global and db.global.widgetConfig then
                for wname, opts in pairs(db.global.widgetConfig) do
                    if not opts.font then
                        opts.font = "ClearFont"
                    end
                end
            end

            if db.profiles then
                for name, profile in pairs(db.profiles) do
                    if profile.nameFontName then
                        profile.widgetConfig = profile.widgetConfig or {}
                        profile.widgetConfig.text1 = profile.widgetConfig.text1 or {}
                        profile.widgetConfig.text1.font = profile.nameFontName
                    end
                    profile.nameFontName = nil
                end
            end

            db.DB_VERSION = 5
        end
        if db.DB_VERSION == 5 then
            if db.profiles then
                for name, profile in pairs(db.profiles) do
                    if profile.healthOrientation == "HORIZONTAL" then
                        local popts = Aptechka.util.MakeTables(profile, "widgetConfig", "debuffIcons")
                        Aptechka:RealignDebuffIconsForProfile(popts, "RIGHT")
                    end

                    if profile.debuffSize then
                        local popts = Aptechka.util.MakeTables(profile, "widgetConfig", "debuffIcons")
                        popts.width = profile.debuffSize
                        popts.height = profile.debuffSize
                        profile.debuffSize = nil
                    end

                    if profile.debuffLimit then
                        local popts = Aptechka.util.MakeTables(profile, "widgetConfig", "debuffIcons")
                        popts.max = profile.debuffLimit
                        profile.debuffLimit = nil
                    end

                    if profile.stackFontSize then
                        local popts = Aptechka.util.MakeTables(profile, "widgetConfig", "debuffIcons")
                        popts.textsize = profile.stackFontSize
                        profile.stackFontSize = nil
                    end
                end
            end

            db.DB_VERSION = 6
        end
        if db.DB_VERSION == 6 then
            local func = function(opts, defaultOpts)
                if opts.assignto then
                    if type(opts.assignto) == "string" then
                        opts.assignto = { opts.assignto }
                    end
                    local newSet = helpers.Set.new(opts.assignto)
                    newSet["__REMOVED__"] = nil
                    opts.assignto = newSet
                end
                if defaultOpts then
                    Aptechka.util.ShakeAssignments(opts, defaultOpts)
                end
            end

            if AptechkaConfigCustom.WIDGET then -- .WIDGET is actually elements
                for status, opts in pairs(AptechkaConfigCustom.WIDGET) do
                    local defaultOpts = AptechkaDefaultConfig[status]
                    func(opts, defaultOpts)
                end
            end

            local categories = helpers:GetAllSpellCategories()

            local spellTypes = { "auras", "traces" }
            for _,category in ipairs(categories) do
                for _,spellType in ipairs(spellTypes) do
                    if AptechkaConfigCustom[category] and AptechkaConfigCustom[category][spellType] then
                        for spellID, opts in pairs(AptechkaConfigCustom[category][spellType]) do
                            local defaultOpts = AptechkaDefaultConfig[category] and AptechkaDefaultConfig[category][spellType] and AptechkaDefaultConfig[category][spellType][spellID]
                            func(opts, defaultOpts)
                        end
                    end
                end
            end

            db.DB_VERSION = 7
        end
        if db.DB_VERSION == 7 then
            -- Just in case there's a leftover from some older versions, remove type from all the profile settings for widgets.
            -- Widget's .type field should always be from the global table via metatable
            if db.profiles then
                for name, profile in pairs(db.profiles) do
                    if profile.widgetConfig then
                        for name, popts in pairs(profile.widgetConfig) do
                            popts.type = nil
                        end
                    end
                end
            end

            db.DB_VERSION = 8
        end

        if db.DB_VERSION == 8 then
            local categories = helpers:GetAllSpellCategories()

            local spellTypes = { "auras", "traces" }
            for _,category in ipairs(categories) do
                for _,spellType in ipairs(spellTypes) do
                    if AptechkaConfigCustom[category] and AptechkaConfigCustom[category][spellType] then
                        for spellID, opts in pairs(AptechkaConfigCustom[category][spellType]) do
                            if opts.clones then
                                local oldClones = opts.clones
                                local newClones = {}
                                local startIndex = 1
                                if oldClones[startIndex] == nil then startIndex = 2 end
                                for i=startIndex,40 do
                                    local SID = oldClones[i]
                                    if SID == nil then break end
                                    if SID ~= "__REMOVED__" then
                                        newClones[SID] = true
                                    end
                                end
                                opts.clones = newClones
                            end
                        end
                    end
                end
            end

            db.DB_VERSION = 9
        end

        if db.DB_VERSION == 9 then
            local function SwapFont(opts, widgetName, profileName)
                if opts.font and opts.font == "ClearFont" then
                    opts.font = "AlegreyaSans-Medium"
                end
            end
            local func = SwapFont
            if db and db.global and db.global.widgetConfig then
                for wname, opts in pairs(db.global.widgetConfig) do
                    func(opts, wname, "global")
                end
            end
            if db.profiles then
                for profileName, profile in pairs(db.profiles) do
                    if profile.widgetConfig then
                        for wname, opts in pairs(profile.widgetConfig) do
                            func(opts, wname, profileName)
                        end
                    end
                end
            end

            db.DB_VERSION = 10
        end

        if db.DB_VERSION == 10 then
            local categories = helpers:GetAllSpellCategories()

            local spellTypes = { "auras", "traces" }
            for _,category in ipairs(categories) do
                for _,spellType in ipairs(spellTypes) do
                    if AptechkaConfigCustom[category] and AptechkaConfigCustom[category][spellType] then
                        for spellID, opts in pairs(AptechkaConfigCustom[category][spellType]) do
                            if opts.showDuration then
                                opts.infoType = "DURATION"
                            elseif opts.showCount then
                                opts.infoType = "COUNT"
                            elseif opts.showText then
                                opts.infoType = "STATIC"
                            end
                            opts.showDuration = nil
                            opts.showCount = nil
                            opts.showText = nil
                        end
                    end
                end
            end

            db.DB_VERSION = 11
        end

        if db.DB_VERSION == 11 then
            if db.global and db.global.sortUnitsByRole == false then
                db.global.sortMethod = "NONE"
            end

            db.DB_VERSION = 12
        end

        if db.DB_VERSION == 12 then
            if db.global and db.global.profileSelection and db.global.profileSelection.HEALER and db.global.profileSelection.HEALER.party then
                db.global.profileSelection.HEALER.arena = db.global.profileSelection.HEALER.party
            end
            if db.global and db.global.profileSelection and db.global.profileSelection.DAMAGER and db.global.profileSelection.DAMAGER.party then
                db.global.profileSelection.DAMAGER.arena = db.global.profileSelection.DAMAGER.party
            end

            db.DB_VERSION = 13
        end

        if db.DB_VERSION == 13 then
            if db.global and db.global.sortMethod then
                local globalMethod = db.global.sortMethod
                if db.profiles then
                    for profileName, profile in pairs(db.profiles) do
                        profile.sortMethod = globalMethod
                    end
                end

                db.global.sortMethod = nil
            end

            db.DB_VERSION = 14
        end

        if db.DB_VERSION == 14 then
            if db.global and db.global.customDebuffHighlights then
                for category, spells in pairs(db.global.customDebuffHighlights) do
                    for spellId, opts in pairs(spells) do
                        if opts == "__REMOVED__" then
                            db.global.customDebuffHighlights[category][spellId] = false
                        end
                    end
                end
            end

            db.DB_VERSION = 15
        end

        db.DB_VERSION = CURRENT_DB_VERSION
    end
end

function helpers:GetAllSpellCategories()
    local categories = { "GLOBAL" }
    for i=1, 15 do
        local classData = C_CreatureInfo.GetClassInfo(i)
        if not classData then break end
        table.insert(categories, classData.classFile)
    end
    return categories
end
function helpers:GetCurrentClassCategories()
    local categories = { "GLOBAL" }
    local playerClass = select(2, UnitClass("player"))
    table.insert(categories, playerClass)
    return categories
end

function Aptechka:ForAllCustomWidgets(func)
    for profileName, profile in pairs(self.db.profiles) do
        if profile.widgetConfig then
            for wname, opts in pairs(profile.widgetConfig) do
                func(opts, wname, profileName)
            end
        end
    end
end

--[[
function Aptechka:ForAllWidgets(func)
    for wname, opts in pairs(self.db.global.widgetConfig) do
        func(opts, wname, "global")
    end
    for profileName, profile in pairs(self.db.profiles) do
        if profile.widgetConfig then
            for wname, opts in pairs(profile.widgetConfig) do
                func(opts, wname, profileName)
            end
        end
    end
end
]]

function Aptechka:ForAllCustomStatuses(func, searchAllClasses)
    local list = Aptechka.GetWidgetList()

    if AptechkaConfigCustom.WIDGET then -- .WIDGET is actually elements
        for status, opts in pairs(AptechkaConfigCustom.WIDGET) do
            func(opts, status, list)
        end
    end

    searchAllClasses = searchAllClasses == nil and true
    local categories
    if searchAllClasses then
        categories = helpers:GetAllSpellCategories()
    else
        categories = helpers:GetCurrentClassCategories()
    end

    local spellTypes = { "auras", "traces" }
    for _,category in ipairs(categories) do
        for _,spellType in ipairs(spellTypes) do
            if AptechkaConfigCustom[category] and AptechkaConfigCustom[category][spellType] then
                for status, opts in pairs(AptechkaConfigCustom[category][spellType]) do
                    func(opts, status, list)
                end
            end
        end
    end
end


local cleanOpts = function(opts, status, list)
    if not opts.assignto then return end
    local toRemove = {}
    for slot, enabled in pairs(opts.assignto) do
        if not list[slot] then
            table.insert(toRemove, slot)
        end
    end
    for _, slot in ipairs(toRemove) do
        opts.assignto[slot] = nil
    end
end

function Aptechka.PurgeDeadAssignments(searchAllClasses)
    Aptechka:ForAllCustomStatuses(cleanOpts)

    ReloadUI()
end

function Aptechka:RealignDebuffIconsForProfile(popts, direction)
    if direction == "RIGHT" then
        popts.animdir = "DOWN"
        popts.style = "STRIP_BOTTOM"
        popts.growth = direction
        popts.y = 4
    elseif direction == "UP" then
        popts.animdir = "LEFT"
        popts.style = "STRIP_RIGHT"
        popts.growth = direction
        popts.y = 0
    end
end
