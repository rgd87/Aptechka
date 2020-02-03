local addonName, ns = ...

local L = Aptechka.L

local profilesTable = {}
function ns.GetProfileList(db)
    local profiles = db:GetProfiles(profilesTable)
    local t = {}
    for i,v in ipairs(profiles) do
        t[v] = v
    end
    return t
end
local GetProfileList = ns.GetProfileList

function ns.MakeProfileSelection()
    local opt = {
        type = 'group',
        name = L"Aptechka Profiles",
        order = 1,
        args = {
            enableAutoProfiles = {
                name = L"Enable Profile Auto-Switching",
                type = "toggle",
                width = "full",
                get = function(info) return Aptechka.db.global.enableProfileSwitching end,
                set = function(info, v)
                    Aptechka.db.global.enableProfileSwitching = not Aptechka.db.global.enableProfileSwitching
                    Aptechka:ReconfigureProtected()
                end,
                order = 0.5,
            },
            manualRoleSelection = {
                type = "group",
                name = L"Manual Role selection for current character",
                width = "double",
                disabled = function() return not Aptechka.db.global.enableProfileSwitching end,
                guiInline = true,
                order = 1.5,
                args = {
                    healer = {
                        name = L"Healer",
                        type = "toggle",
                        get = function(info) return AptechkaDB_Char.forcedClassicRole == "HEALER" end,
                        set = function(info, v)
                            AptechkaDB_Char.forcedClassicRole = "HEALER"
                            Aptechka:OnRoleChanged()
                        end,
                        order = 1,
                    },
                    damager = {
                        name = L"Damager/Tank",
                        type = "toggle",
                        get = function(info) return AptechkaDB_Char.forcedClassicRole == "DAMAGER" end,
                        set = function(info, v)
                            AptechkaDB_Char.forcedClassicRole = "DAMAGER"
                            Aptechka:OnRoleChanged()
                        end,
                        order = 2,
                    },
                }
            },
            healerGroup = {
                type = 'group',
                name = " ",
                order = 2,
                disabled = function() return not Aptechka.db.global.enableProfileSwitching end,
                guiInline = true,
                args = {
                    HEALER_solo = {
                        name = string.format("%s: %s", L"HEALER", L"Solo"),
                        type = 'select',
                        order = 1,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.HEALER.solo end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.HEALER.solo = v
                            Aptechka:Reconfigure()
                        end,
                    },
                    DAMAGER_solo = {
                        name = string.format("%s: %s", L"DAMAGER", L"Solo"),
                        type = 'select',
                        order = 2,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.DAMAGER.solo end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.DAMAGER.solo = v
                            Aptechka:Reconfigure()
                        end,
                    },


                    HEALER_party = {
                        name = string.format("%s: %s", L"HEALER", L"5-man"),
                        type = 'select',
                        order = 3,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.HEALER.party end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.HEALER.party = v
                            Aptechka:Reconfigure()
                        end,
                    },
                    DAMAGER_party = {
                        name = string.format("%s: %s", L"DAMAGER", L"5-man"),
                        type = 'select',
                        order = 4,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.DAMAGER.party end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.DAMAGER.party = v
                            Aptechka:Reconfigure()
                        end,
                    },


                    HEALER_smallRaid = {
                        name = string.format("%s: %s %s", L"HEALER", L"Small Raid", "(6-10)"),
                        type = 'select',
                        order = 5,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.HEALER.smallRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.HEALER.smallRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },
                    DAMAGER_smallRaid = {
                        name = string.format("%s: %s %s", L"DAMAGER", L"Small Raid", "(6-10)"),
                        type = 'select',
                        order = 6,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.DAMAGER.smallRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.DAMAGER.smallRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },


                    HEALER_mediumRaid = {
                        name = string.format("%s: %s %s", L"HEALER", L"Medium Raid", "(11-22)"),
                        type = 'select',
                        order = 7,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.HEALER.mediumRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.HEALER.mediumRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },
                    DAMAGER_mediumRaid = {
                        name = string.format("%s: %s %s", L"DAMAGER", L"Medium Raid", "(11-22)"),
                        type = 'select',
                        order = 8,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.DAMAGER.mediumRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.DAMAGER.mediumRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },


                    HEALER_bigRaid = {
                        name = string.format("%s: %s %s", L"HEALER", L"Big Raid", "(23-30)"),
                        type = 'select',
                        order = 9,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.HEALER.bigRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.HEALER.bigRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },
                    DAMAGER_bigRaid = {
                        name = string.format("%s: %s %s", L"DAMAGER", L"Big Raid", "(23-30)"),
                        type = 'select',
                        order = 10,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.DAMAGER.bigRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.DAMAGER.bigRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },

                    HEALER_fullRaid = {
                        name = string.format("%s: %s %s", L"HEALER", L"Full Raid", "(31-40)"),
                        type = 'select',
                        order = 11,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.HEALER.fullRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.HEALER.fullRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },
                    DAMAGER_fullRaid = {
                        name = string.format("%s: %s %s", L"DAMAGER", L"Full Raid", "(31-40)"),
                        type = 'select',
                        order = 12,
                        width = 1.6,
                        values = function()
                            return GetProfileList(Aptechka.db)
                        end,
                        get = function(info) return Aptechka.db.global.profileSelection.DAMAGER.fullRaid end,
                        set = function(info, v)
                            Aptechka.db.global.profileSelection.DAMAGER.fullRaid = v
                            Aptechka:Reconfigure()
                        end,
                    },
                },
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaProfile", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaProfile", "Profile Selection", "Aptechka")

    return panelFrame
end
