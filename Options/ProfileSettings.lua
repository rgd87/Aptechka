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
                        -- width = "half",
                        desc = "Unlock anchor for dragging",
                        func = function() Aptechka.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = L"Lock",
                        type = "execute",
                        -- width = "half",
                        desc = "Lock anchor",
                        func = function() Aptechka.Commands.lock() end,
                        order = 2,
                    },
                    reset = {
                        name = L"Reset",
                        type = "execute",
                        desc = "Reset anchor",
                        func = function() Aptechka.Commands.reset() end,
                        order = 3,
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
                        width = 1.5,
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
                        width = 0.5,
                        func = function(info)
                            local p = Aptechka.db:GetCurrentProfile()
                            ns.storedProfile = p
                        end,
                    },
                    pasteButton = {
                        name = L"Paste",
                        type = 'execute',
                        order = 3,
                        width = 0.5,
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
                        width = 0.5,
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
                    petGroup = {
                        name = L"Enable Pet Group",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.petGroup end,
                        set = function(info, v)
                            Aptechka.db.profile.petGroup = not Aptechka.db.profile.petGroup
                            Aptechka:UpdatePetGroupConfig()
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 15.7,
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
                        name = L"Show Casts",
                        disabled = isClassic,
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showCasts end,
                        set = function(info, v)
                            Aptechka.db.profile.showCasts = not Aptechka.db.profile.showCasts
                            Aptechka:UpdateCastsConfig()
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
                        order = 16,
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
                        min = 3,
                        max = 20,
                        step = 1,
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
                        min = 3,
                        max = 20,
                        step = 1,
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
                        desc = L"Set the statusbar texture.",
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
                        desc = L"Set the statusbar texture.",
                        get = function(info) return Aptechka.db.profile.powerTexture end,
                        set = function(info, value)
                            Aptechka.db.profile.powerTexture = value
                            Aptechka:ReconfigureUnprotected()
                        end,
                        values = LSM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                    },
                    nameFont = {
                        type = "select",
                        name = L"Name Font",
                        order = 14.1,
                        get = function(info)
                            local opts = Aptechka:GetWidgetsOptionsMerged("text1")
                            return opts.font
                        end,
                        set = function(info, value)
                            Aptechka.db.profile.widgetConfig = Aptechka.db.profile.widgetConfig or {}
                            Aptechka.db.profile.widgetConfig.text1 = Aptechka.db.profile.widgetConfig.text1 or {}
                            Aptechka.db.profile.widgetConfig.text1.font = value
                            Aptechka:ReconfigureAllWidgets()
                        end,
                        values = LSM:HashTable("font"),
                        dialogControl = "LSM30_Font",
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
                                width = 2,
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

                    debuffGroup = {
                        type = "group",
                        name = L"Debuffs",
                        order = 17,
                        args = {
                            message = {
                                name = L"Debuff Icons are now available as a widget. Use /apt widget info name=debuffIcons for their settings",
                                type = "description",
                                fontSize = "medium",
                                width = "full",
                                order = 1,
                            },
                            debuffBossScale = {
                                name = L"Boss Aura Scale",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.debuffBossScale end,
                                set = function(info, v)
                                    Aptechka.db.profile.debuffBossScale = v
                                end,
                                min = 1,
                                max = 1.8,
                                step = 0.01,
                                order = 5,
                            },
                            debuffTest = {
                                name = L"Test Debuffs",
                                type = "execute",
                                func = function() Aptechka.TestDebuffSlots() end,
                                order = 10,
                            },
                        }
                    },
                },
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaProfileSettings", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaProfileSettings", L"Profile Settings", "Aptechka")

    return panelFrame
end
