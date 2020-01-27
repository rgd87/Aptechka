local addonName, ns = ...

local L = Aptechka.L

local profilesTable = {}
local function GetProfileList(db)
    local profiles = db:GetProfiles(profilesTable)
    local t = {}
    for i,v in ipairs(profiles) do
        t[v] = v
    end
    return t
end

function ns.MakeProfileSelection()
    local opt = {
        type = 'group',
        name = L"Aptechka Profiles",
        order = 1,
        args = {
            currentProfile = {
                type = 'group',
                order = 1,
                name = " ",
                guiInline = true,
                args = {
                    normalScale = {
                        name = L"Current Profile",
                        type = 'select',
                        width = 1.5,
                        order = 1,
                        values = function()
                            return GetProfileList(Aptechka.db)
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
                },
            },
            healerGroup = {
                type = 'group',
                name = L"Profile Auto-Switching",
                order = 2,

                guiInline = true,
                args = {
                    HEALER_solo = {
                        name = L"HEALER"..": Solo",
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
                        name = L"DAMAGER"..": Solo",
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
                        name = L"HEALER"..": 5-man",
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
                        name = L"DAMAGER"..": 5-man",
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
                        name = L"HEALER"..": Small Raid (6-15)",
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
                        name = L"DAMAGER"..": Small Raid (6-15)",
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
                        name = L"HEALER"..": Medium Raid (16-25)",
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
                        name = L"DAMAGER"..": Medium Raid (16-25)",
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
                        name = L"HEALER"..": Big Raid (26-40)",
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
                        name = L"DAMAGER"..": Big Raid (26-40)",
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
                },
            },

            NewProfile = {
                type = 'group',
                order = 4,
                name = " ",
                guiInline = true,
                args = {
                    profileName = {
                        name = L"New Profile Name",
                        type = 'input',
                        order = 1,
                        width = 1.6,
                        get = function(info) return ns.newProfileName end,
                        set = function(info, v)
                            ns.newProfileName = v
                        end,
                    },
                    createButton = {
                        name = L"Create New Profile",
                        type = 'execute',
                        order = 2,
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
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaProfile", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaProfile", "Profile Selection", "Aptechka")

    return panelFrame
end
