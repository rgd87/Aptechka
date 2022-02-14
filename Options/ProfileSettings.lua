local addonName, ns = ...

local L = Aptechka.L

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local LSM = LibStub("LibSharedMedia-3.0")

function ns.MakeProfileSettings()
    local opt = {
        type = 'group',
        name = "Aptechka "..L"Profile Settings",
        order = 1,
        args = {
            anchors = {
                type = "group",
                name = L"Anchors",
                guiInline = true,
                order = 2,
                args = {
                    unlock = {
                        name = L"Unlock",
                        type = "execute",
                        width = 0.85,
                        desc = "Unlock anchor for dragging",
                        func = function() Aptechka.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = L"Lock",
                        type = "execute",
                        width = 0.85,
                        desc = "Lock anchor",
                        func = function() Aptechka.Commands.lock() end,
                        order = 2,
                    },
                    testMode = {
                        name = L"Layout Test",
                        type = "execute",
                        width = 0.80,
                        func = function() Aptechka:ToggleTestMode() end,
                        order = 3,
                    },
                    reset = {
                        name = L"Reset",
                        type = "execute",
                        width = 0.5,
                        desc = "Reset anchor",
                        func = function() Aptechka.Commands.reset() end,
                        order = 4,
                    },
                },
            },
            currentProfile = {
                type = 'group',
                order = 2.1,
                name = L"Current Profile",
                guiInline = true,
                args = {
                    curProfile = {
                        name = "",
                        type = 'select',
                        width = 1.2,
                        order = 1,
                        values = function()
                            return ns.GetProfileList(Aptechka.db)
                        end,
                        get = function(info)
                            return Aptechka.db:GetCurrentProfile()
                        end,
                        set = function(info, v)
                            Aptechka.db:SetProfile(v)
                        end,
                    },
                    copyButton = {
                        name = L"Copy",
                        type = 'execute',
                        order = 2,
                        width = 0.6,
                        func = function(info)
                            local p = Aptechka.db:GetCurrentProfile()
                            ns.storedProfile = p
                        end,
                    },
                    pasteButton = {
                        name = L"Paste",
                        type = 'execute',
                        order = 3,
                        width = 0.6,
                        disabled = function()
                            return ns.storedProfile == nil
                        end,
                        func = function(info)
                            if ns.storedProfile then
                                Aptechka.db:CopyProfile(ns.storedProfile, true)
                            end
                        end,
                    },
                    deleteButton = {
                        name = L"Delete",
                        type = 'execute',
                        order = 4,
                        confirm = true,
                        confirmText = L"Are you sure?",
                        width = 0.6,
                        disabled = function()
                            return Aptechka.db:GetCurrentProfile() == "Default"
                        end,
                        func = function(info)
                            local p = Aptechka.db:GetCurrentProfile()
                            Aptechka.db:SetProfile("Default")
                            Aptechka.db:DeleteProfile(p, true)
                        end,
                    },
                    newProfileName = {
                        name = L"New Profile Name",
                        type = 'input',
                        order = 5,
                        width = 2,
                        get = function(info) return ns.newProfileName end,
                        set = function(info, v)
                            ns.newProfileName = v
                        end,
                    },
                    createButton = {
                        name = L"Create New Profile",
                        type = 'execute',
                        order = 6,
                        disabled = function()
                            return not ns.newProfileName
                            or strlenutf8(ns.newProfileName) == 0
                            or Aptechka.db.profiles[ns.newProfileName]
                        end,
                        func = function(info)
                            if ns.newProfileName and strlenutf8(ns.newProfileName) > 0 then
                                Aptechka.db:SetProfile(ns.newProfileName)
                                Aptechka.db:CopyProfile("Default", true)
                                ns.newProfileName = ""
                            end
                        end,
                    },
                },
            },
            switches = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3,
                args = {
                    showSolo = {
                        name = L"Show Solo",
                        type = "toggle",
                        width = 1,
                        get = function(info) return Aptechka.db.profile.showSolo end,
                        set = function(info, v)
                            Aptechka.db.profile.showSolo = not Aptechka.db.profile.showSolo
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 8,
                    },
                    showParty = {
                        name = L"Show Party",
                        type = "toggle",
                        -- disabled = function() return not Aptechka.db.profile.showRaid end,
                        width = 1,
                        get = function(info) return Aptechka.db.profile.showParty end,
                        set = function(info, v)
                            Aptechka.db.profile.showParty = not Aptechka.db.profile.showParty
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 8.1,
                    },
                    showRaid = {
                        name = L"Show Raid",
                        type = "toggle",
                        -- disabled = function() return not Aptechka.db.profile.showParty end,
                        width = 1,
                        get = function(info) return Aptechka.db.profile.showRaid end,
                        set = function(info, v)
                            Aptechka.db.profile.showRaid = not Aptechka.db.profile.showRaid
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 8.2,
                    },
                    showAggro = {
                        name = L"Show Aggro",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showAggro end,
                        set = function(info, v)
                            Aptechka.db.profile.showAggro = not Aptechka.db.profile.showAggro
                            Aptechka:UpdateAggroConfig()
                        end,
                        order = 10.9,
                    },
                    showRaidIcons = {
                        name = L"Show Raid Icons",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showRaidIcons end,
                        set = function(info, v)
                            Aptechka.db.profile.showRaidIcons = not Aptechka.db.profile.showRaidIcons
                            Aptechka:UpdateRaidIconsConfig()
                        end,
                        order = 11.1,
                    },
                    showDispels = {
                        name = L"Dispel Indicator",
                        type = "toggle",
                        order = 11.3,
                        get = function(info) return Aptechka.db.profile.showDispels end,
                        set = function(info, v)
                            Aptechka.db.profile.showDispels = not Aptechka.db.profile.showDispels
                            Aptechka:UpdateDebuffScanningMethod()
                        end
                    },
                    showCasts = {
                        name = L"Show Incoming Casts",
                        disabled = isClassic,
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showCasts end,
                        set = function(info, v)
                            Aptechka.db.profile.showCasts = not Aptechka.db.profile.showCasts
                            Aptechka:UpdateIncomingCastsConfig()
                        end,
                        order = 12,
                    },
                    damageEffect = {
                        name = L"Damage Effect"..newFeatureIcon,
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.damageEffect end,
                        set = function(info, v)
                            Aptechka.db.profile.damageEffect = not Aptechka.db.profile.damageEffect
                            Aptechka:UpdateUnprotectedUpvalues()
                        end,
                        order = 16,
                    },
                    auraUpdateEffect = {
                        name = L"Aura Update Effect"..newFeatureIcon,
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.auraUpdateEffect end,
                        set = function(info, v)
                            Aptechka.db.profile.auraUpdateEffect = not Aptechka.db.profile.auraUpdateEffect
                            Aptechka:UpdateUnprotectedUpvalues()
                        end,
                        order = 17,
                    },
                    floatingIcon = {
                        name = L"Buff Gain Floating Icons"..newFeatureIcon,
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showFloatingIcons end,
                        set = function(info, v)
                            Aptechka.db.profile.showFloatingIcons = not Aptechka.db.profile.showFloatingIcons
                            Aptechka:UpdateUnprotectedUpvalues()
                        end,
                        order = 18,
                    },
                    CCList = {
                        name = L"CC List (PvP)"..newFeatureIcon,
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showCCList end,
                        set = function(info, v)
                            Aptechka.db.profile.showCCList = not Aptechka.db.profile.showCCList
                            Aptechka:UpdateDebuffScanningMethod()
                        end,
                        order = 18.1,
                    },
                    targetedCount = {
                        name = L"Enemy Counter"..newFeatureIcon,
                        desc = "Shows how many enemies target a unit, mostly for PvP",
                        type = "toggle",
                        width = "full",
                        get = function(info) return Aptechka.db.profile.showTargetedCount end,
                        set = function(info, v)
                            Aptechka.db.profile.showTargetedCount = not Aptechka.db.profile.showTargetedCount
                            Aptechka:UpdateTargetedCountConfig()
                        end,
                        order = 18.2,
                    },
                    maxGroups = {
                        name = L"Max Groups",
                        type = "range",
                        get = function(info) return Aptechka:GetMaxGroupEnabled() end,
                        set = function(info, v)
                            Aptechka.db.profile.groupFilter = math.pow(2, v) - 1
                            Aptechka:Reconfigure()
                        end,
                        min = 1,
                        max = 8,
                        step = 1,
                        order = 19,
                    },
                    sortMethod = {
                        name = L"Sorting Method",
                        desc = L"Note that for sorting to work across the whole raid you need to enable 'Merge Groups' global option",
                        type = 'select',
                        order = 20,
                        values = {
                            NONE = L"None (Unit Index)",
                            ROLE = L"Role",
                            CLASS= L"Class",
                            NAME = L"Name",
                        },
                        get = function(info) return Aptechka.db.profile.sortMethod end,
                        set = function( info, v )
                            Aptechka.db.profile.sortMethod = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                }
            },

            petSettings = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3.6,
                args = {
                    petGroup = {
                        name = L"Enable Pet Group",
                        type = "toggle",
                        width = 1.5,
                        get = function(info) return Aptechka.db.profile.petGroup end,
                        set = function(info, v)
                            Aptechka.db.profile.petGroup = not Aptechka.db.profile.petGroup
                            Aptechka:UpdatePetGroupConfig()
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 1,
                    },
                    petScale = {
                        name = L"Pet Scale",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.petScale end,
                        set = function(info, v)
                            Aptechka.db.profile.petScale = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 0.3,
                        max = 1,
                        step = 0.01,
                        order = 2,
                    },
                    petGroupAnchor = {
                        name = L"Separate Pet Group",
                        desc = "Moves pet group to its own anchor",
                        type = "toggle",
                        width = 1,
                        get = function(info) return Aptechka.db.profile.petGroupAnchorEnabled end,
                        set = function(info, v)
                            Aptechka.db.profile.petGroupAnchorEnabled = not Aptechka.db.profile.petGroupAnchorEnabled
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 3,
                    },
                    petGroupGrowth = {
                        name = L"Group Growth Direction",
                        disabled = function() return not Aptechka.db.profile.petGroupAnchorEnabled end,
                        type = 'select',
                        order = 4,
                        values = {
                            LEFT = L"Left",
                            RIGHT = L"Right",
                            TOP = L"Up",
                            BOTTOM = L"Down",
                        },
                        get = function(info) return Aptechka.db.profile.petGroupGrowth end,
                        set = function( info, v )
                            Aptechka.db.profile.petGroupGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                    petUnitGrowth = {
                        name = L"Unit Growth Direction",
                        disabled = function() return not Aptechka.db.profile.petGroupAnchorEnabled end,
                        type = 'select',
                        order = 6,
                        values = {
                            LEFT = L"Left",
                            RIGHT = L"Right",
                            TOP = L"Up",
                            BOTTOM = L"Down",
                        },
                        get = function(info) return Aptechka.db.profile.petUnitGrowth end,
                        set = function( info, v )
                            Aptechka.db.profile.petUnitGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                }
            },

            sizeSettings = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 4,
                args = {
                    width = {
                        name = L"Width",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.width end,
                        set = function(info, v)
                            Aptechka.db.profile.width = v
                            Aptechka:Reconfigure()
                        end,
                        min = 10,
                        max = 200,
                        step = 1,
                        order = 1,
                    },
                    height = {
                        name = L"Height",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.height end,
                        set = function(info, v)
                            Aptechka.db.profile.height = v
                            Aptechka:Reconfigure()
                        end,
                        min = 10,
                        max = 150,
                        step = 1,
                        order = 2,
                    },
                    scale = {
                        name = L"Scale",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.scale end,
                        set = function(info, v)
                            Aptechka.db.profile.scale = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 0.5,
                        max = 3,
                        step = 0.01,
                        order = 3,
                    },
                    groupGrowth = {
                        name = L"Group Growth Direction",
                        type = 'select',
                        order = 4,
                        values = {
                            LEFT = L"Left",
                            RIGHT = L"Right",
                            TOP = L"Up",
                            BOTTOM = L"Down",
                        },
                        get = function(info) return Aptechka.db.profile.groupGrowth end,
                        set = function( info, v )
                            Aptechka.db.profile.groupGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                    groupGap = {
                        name = L"Group Gap",
                        type = "range",
                        width = "double",
                        get = function(info) return Aptechka.db.profile.groupGap end,
                        set = function(info, v)
                            Aptechka.db.profile.groupGap = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = -3,
                        max = 50,
                        step = 0.5,
                        order = 5,
                    },
                    unitGrowth = {
                        name = L"Unit Growth Direction",
                        type = 'select',
                        order = 6,
                        values = {
                            LEFT = L"Left",
                            RIGHT = L"Right",
                            TOP = L"Up",
                            BOTTOM = L"Down",
                        },
                        get = function(info) return Aptechka.db.profile.unitGrowth end,
                        set = function( info, v )
                            Aptechka.db.profile.unitGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                    unitGap = {
                        name = L"Unit Gap",
                        type = "range",
                        width = "double",
                        get = function(info) return Aptechka.db.profile.unitGap end,
                        set = function(info, v)
                            Aptechka.db.profile.unitGap = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = -3,
                        max = 50,
                        step = 0.5,
                        order = 7,
                    },
                    groupsInARow = {
                        name = L"Groups in a Row",
                        desc = L"Allows 10x4 layouts",
                        type = "range",
                        width = "full",
                        get = function(info) return Aptechka.db.profile.groupsInRow end,
                        set = function(info, v)
                            Aptechka.db.profile.groupsInRow = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 1,
                        max = 2,
                        step = 1,
                        order = 8,
                    },


                    orientation = {
                        name = L"Health Orientation",
                        type = 'select',
                        order = 12,
                        values = {
                            ["HORIZONTAL"] = L"Horizontal",
                            ["VERTICAL"] = L"Vertical",
                        },
                        -- values = MakeValuesForKeys(Aptechka.FrameTextures),
                        get = function(info) return Aptechka.db.profile.healthOrientation end,
                        set = function( info, v )
                            Aptechka.db.profile.healthOrientation = v
                            Aptechka:ReconfigureUnprotected()

                            local popts = Aptechka.util.MakeTables(Aptechka.db.profile, "widgetConfig", "debuffIcons")
                            if v == "HORIZONTAL" then
                                Aptechka:RealignDebuffIconsForProfile(popts,"RIGHT")
                            else
                                Aptechka:RealignDebuffIconsForProfile(popts,"UP")
                            end
                            Aptechka:ReconfigureWidget("debuffIcons")
                        end,
                    },

                    healthTexture = {
                        type = "select",
                        name = L"Health Texture",
                        order = 13,
                        get = function(info) return Aptechka.db.profile.healthTexture end,
                        set = function(info, value)
                            Aptechka.db.profile.healthTexture = value
                            Aptechka:ReconfigureUnprotected()
                        end,
                        values = LSM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                    },

                    powerTexture = {
                        type = "select",
                        name = L"Power Texture",
                        order = 14,
                        get = function(info) return Aptechka.db.profile.powerTexture end,
                        set = function(info, value)
                            Aptechka.db.profile.powerTexture = value
                            Aptechka:ReconfigureUnprotected()
                        end,
                        values = LSM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                    },
                    nameLength = {
                        name = L"Name Length",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.cropNamesLen end,
                        set = function(info, v)
                            Aptechka.db.profile.cropNamesLen = v
                            Aptechka:ReconfigureUnprotected()
                        end,
                        min = 2,
                        max = 25,
                        step = 1,
                        order = 14.5,
                    },
                    powerbarSize = {
                        name = L"Power Thickness",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.powerSize end,
                        set = function(info, v)
                            Aptechka.db.profile.powerSize = v
                            Aptechka:ReconfigureUnprotected()
                        end,
                        min = 1,
                        max = 30,
                        step = 1,
                        order = 14.6,
                    },
                    enableSeparator = {
                        name = L"Separator Line",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showSeparator end,
                        set = function(info, v)
                            Aptechka.db.profile.showSeparator = not Aptechka.db.profile.showSeparator
                            Aptechka:ReconfigureUnprotected()
                        end,
                        order = 14.7,
                    },


                    healthColorGroup = {
                        type = "group",
                        name = L"Health Color",
                        order = 15.1,
                        args = {
                            showMissingFG = {
                                name = L"Show Missing Health/Power as Foreground",
                                width = "full",
                                type = "toggle",
                                get = function(info) return Aptechka.db.profile.fgShowMissing end,
                                set = function(info, v)
                                    Aptechka.db.profile.fgShowMissing = not Aptechka.db.profile.fgShowMissing
                                    Aptechka:ReconfigureUnprotected()
                                    Aptechka:RefreshAllUnitsHealth()
                                end,
                                order = 1,
                            },
                            enableClasscolor = {
                                name = L"Use Class Color",
                                type = "toggle",
                                get = function(info) return Aptechka.db.profile.healthColorByClass end,
                                set = function(info, v)
                                    Aptechka.db.profile.healthColorByClass = not Aptechka.db.profile.healthColorByClass
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                                order = 2,
                            },
                            color1 = {
                                name = L"Base Color",
                                type = 'color',
                                width = 1,
                                order = 3,
                                disabled = function() return Aptechka.db.profile.healthColorByClass end,
                                get = function(info)
                                    local r,g,b = unpack(Aptechka.db.profile.healthColor1)
                                    return r,g,b
                                end,
                                set = function(info, r, g, b)
                                    Aptechka.db.profile.healthColor1 = {r,g,b}
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                            },
                            petColor = {
                                name = L"Pet Class Color",
                                type = 'color',
                                width = 1,
                                order = 3.1,
                                disabled = function() return not Aptechka.db.profile.healthColorByClass end,
                                get = function(info)
                                    local r,g,b = unpack(Aptechka.db.profile.petColor)
                                    return r,g,b
                                end,
                                set = function(info, r, g, b)
                                    Aptechka.db.profile.petColor = {r,g,b}
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                            },
                            enableGradient = {
                                name = L"Use Gradient Color",
                                type = "toggle",
                                get = function(info) return Aptechka.db.profile.gradientHealthColor end,
                                set = function(info, v)
                                    Aptechka.db.profile.gradientHealthColor = not Aptechka.db.profile.gradientHealthColor
                                    Aptechka:UpdateUnprotectedUpvalues()
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                                order = 4,
                            },
                            color2 = {
                                name = L"Mid Color",
                                type = 'color',
                                order = 5,
                                disabled = function() return not Aptechka.db.profile.gradientHealthColor end,
                                get = function(info)
                                    local r,g,b = unpack(Aptechka.db.profile.healthColor2)
                                    return r,g,b
                                end,
                                set = function(info, r, g, b)
                                    Aptechka.db.profile.healthColor2 = {r,g,b}
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                            },
                            color3 = {
                                name = L"End Color",
                                type = 'color',
                                order = 6,
                                disabled = function() return not Aptechka.db.profile.gradientHealthColor end,
                                get = function(info)
                                    local r,g,b = unpack(Aptechka.db.profile.healthColor3)
                                    return r,g,b
                                end,
                                set = function(info, r, g, b)
                                    Aptechka.db.profile.healthColor3 = {r,g,b}
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                            },
                            useBGColor = {
                                name = L"Use Separate Background Color",
                                type = "toggle",
                                width = 2,
                                get = function(info) return Aptechka.db.profile.useCustomBackgroundColor end,
                                set = function(info, v)
                                    Aptechka.db.profile.useCustomBackgroundColor = not Aptechka.db.profile.useCustomBackgroundColor
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                                order = 7.1,
                            },
                            bgColor = {
                                name = L"Background Color",
                                type = 'color',
                                order = 7.2,
                                disabled = function() return not Aptechka.db.profile.useCustomBackgroundColor end,
                                get = function(info)
                                    local r,g,b = unpack(Aptechka.db.profile.customBackgroundColor)
                                    return r,g,b
                                end,
                                set = function(info, r, g, b)
                                    Aptechka.db.profile.customBackgroundColor = {r,g,b}
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                            },
                            nameColorClassColor = {
                                name = L"Use Name Class Color",
                                type = "toggle",
                                width = 2,
                                get = function(info) return Aptechka.db.profile.nameColorByClass end,
                                set = function(info, v)
                                    Aptechka.db.profile.nameColorByClass = not Aptechka.db.profile.nameColorByClass
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                                order = 7.3,
                            },
                            nameColorCustom = {
                                name = L"Name Color",
                                type = 'color',
                                order = 7.4,
                                disabled = function() return Aptechka.db.profile.nameColorByClass end,
                                get = function(info)
                                    local r,g,b = unpack(Aptechka.db.profile.nameColor)
                                    return r,g,b
                                end,
                                set = function(info, r, g, b)
                                    Aptechka.db.profile.nameColor = {r,g,b}
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                            },
                            incHealColorAuto = {
                                name = L"Auto Inc.Heal Color",
                                type = "toggle",
                                width = 2,
                                get = function(info) return Aptechka.db.profile.incHealColorAuto end,
                                set = function(info, v)
                                    Aptechka.db.profile.incHealColorAuto = not Aptechka.db.profile.incHealColorAuto
                                    Aptechka:ReconfigureUnprotected()
                                end,
                                order = 8.1,
                            },
                            incHealColor = {
                                name = L"Custom Inc.Heal Color",
                                type = 'color',
                                order = 8.2,
                                hasAlpha = true,
                                disabled = function() return Aptechka.db.profile.incHealColorAuto end,
                                get = function(info)
                                    local r,g,b,a = unpack(Aptechka.db.profile.incHealColor)
                                    return r,g,b,a
                                end,
                                set = function(info, r, g, b, a)
                                    Aptechka.db.profile.incHealColor = {r,g,b,a}
                                    Aptechka:ReconfigureUnprotected()
                                end,
                            },
                            absorbColorAuto = {
                                name = L"Auto Absorb Color",
                                type = "toggle",
                                width = 2,
                                get = function(info) return Aptechka.db.profile.absorbColorAuto end,
                                set = function(info, v)
                                    Aptechka.db.profile.absorbColorAuto = not Aptechka.db.profile.absorbColorAuto
                                    Aptechka:ReconfigureUnprotected()
                                end,
                                order = 8.3,
                            },
                            absorbColor = {
                                name = L"Custom Absorb Color",
                                type = 'color',
                                order = 8.4,
                                hasAlpha = true,
                                disabled = function() return Aptechka.db.profile.absorbColorAuto end,
                                get = function(info)
                                    local r,g,b,a = unpack(Aptechka.db.profile.absorbColor)
                                    return r,g,b,a
                                end,
                                set = function(info, r, g, b, a)
                                    Aptechka.db.profile.absorbColor = {r,g,b,a}
                                    Aptechka:ReconfigureUnprotected()
                                end,
                            },
                            rangeAlpha = {
                                name = L"Out of Range Alpha"..newFeatureIcon,
                                type = "range",
                                get = function(info) return Aptechka.db.profile.alphaOutOfRange end,
                                set = function(info, v)
                                    Aptechka.db.profile.alphaOutOfRange = v
                                    Aptechka:UpdateUnprotectedUpvalues()
                                end,
                                min = 0,
                                max = 0.9,
                                step = 0.01,
                                order = 19,
                            },
                        }
                    },
                    mulGroup = {
                        type = "group",
                        name = L"Color Multipliers",
                        order = 16,
                        args = {
                            fgColor = {
                                name = L"Foreground",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.fgColorMultiplier end,
                                set = function(info, v)
                                    if v > Aptechka.db.profile.bgColorMultiplier then
                                        Aptechka.db.profile.fgColorMultiplier = v
                                        Aptechka:RefreshAllUnitsColors()
                                    else
                                        Aptechka.db.profile.fgColorMultiplier = Aptechka.db.profile.bgColorMultiplier
                                    end
                                end,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                order = 1,
                            },
                            bgColor = {
                                name = L"Background",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.bgColorMultiplier end,
                                set = function(info, v)
                                    if v < Aptechka.db.profile.fgColorMultiplier then
                                        Aptechka.db.profile.bgColorMultiplier = v
                                        Aptechka:RefreshAllUnitsColors()
                                    else
                                        Aptechka.db.profile.bgColorMultiplier = Aptechka.db.profile.fgColorMultiplier
                                    end
                                end,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                order = 2,
                            },
                            bgAlpha = {
                                name = L"Background Alpha"..newFeatureIcon,
                                type = "range",
                                get = function(info) return Aptechka.db.profile.bgAlpha end,
                                set = function(info, v)
                                    Aptechka.db.profile.bgAlpha = v
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                order = 2.5,
                            },
                            nameColor = {
                                name = L"Name",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.nameColorMultiplier end,
                                set = function(info, v)
                                    Aptechka.db.profile.nameColorMultiplier = v
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                order = 3,
                            },
                        }
                    },
                },
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaProfileSettings", opt)

    return "AptechkaProfileSettings", L"Profile Settings"
end
