do
    local CURRENT_DB_VERSION = 3
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

            for i=1, GetNumClasses() do
                local class = select(2,GetClassInfo(i))
                if AptechkaConfigCustom[class] and AptechkaConfigCustom[class]["auras"] then
                    for _, spellId in ipairs(amIDs) do
                        AptechkaConfigCustom[class]["auras"] = nil
                    end
                end
            end

            db.DB_VERSION = 3
        end
    end
end

function Aptechka.PurgeDeadAssignments(searchAllClasses)
    local list = Aptechka.GetWidgetListRaw()

    local cleanOpts = function(list, opts)
        if type(opts.assignto) == "string" then
            local slot = opts.assignto
            if not list[slot] then opts.assignto = { } end
        else
            local i = 1
            while (i <= #opts.assignto) do
                local slot = opts.assignto[i]
                if not list[slot] then
                    table.remove(opts.assignto, i)
                    i = i - 1
                end
                i = i + 1
            end
        end
    end

    if AptechkaConfigCustom.WIDGET then
    for status, opts in pairs(AptechkaConfigCustom.WIDGET) do
        cleanOpts(list, opts)
    end
    end


    local categories = { "GLOBAL" }
    if searchAllClasses then
        for i=1, GetNumClasses() do
            local class = select(2,GetClassInfo(i))
            table.insert(categories, class)
        end
    else
        local playerClass = select(2, UnitClass("player"))
        table.insert(categories, playerClass)
    end

    local spellTypes = { "auras", "traces" }
    for _,category in ipairs(categories) do
        for _,spellType in ipairs(spellTypes) do
            if AptechkaConfigCustom[category] and AptechkaConfigCustom[category][spellType] then
            for status, opts in pairs(AptechkaConfigCustom[category][spellType]) do
                cleanOpts(list, opts)
            end
            end
        end
    end

    ReloadUI()
end