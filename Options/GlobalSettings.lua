local addonName, ns = ...

local L = Aptechka.L

local APILevel = math.floor(select(4,GetBuildInfo())/10000)
local isClassic = APILevel <= 3
local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

function ns.MakeGlobalSettings()
    local opt = {
        type = 'group',
        name = "Aptechka "..L"Global Settings",
        order = 1,
        args = {
            switches = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3,
                args = {
                    MinimapIcon = {
                        name = L"Hide Minimap Icon",
                        type = "toggle",
                        width = "full",
                        get = function(info) return Aptechka.db.global.LDBData.hide end,
                        set = function(info, v)
                            Aptechka:ToggleMinimapIcon()
                        end,
                        order = 1,
                    },
                    alwaysUnlocked = {
                        name = L"Permanently Unlocked",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.stayUnlocked end,
                        set = function(info, v)
                            Aptechka.db.global.stayUnlocked = not Aptechka.db.global.stayUnlocked
                            if Aptechka.db.global.stayUnlocked then
                                Aptechka:Unlock()
                            else
                                Aptechka:Lock()
                            end
                        end,
                        order = 2,
                    },
                    RMBClickthrough = {
                        name = L"RMB Mouselook Clickthrough"..newFeatureIcon,
                        desc = L"Allows to turn with RMB without moving mouse away from the unitframes. With Clique this will override its RMB binding",
                        type = "toggle",
                        width = "full",
                        confirm = true,
                        confirmText = L"Warning: Requires UI reloading.",
                        get = function(info) return Aptechka.db.global.RMBClickthrough end,
                        set = function(info, v)
                            Aptechka.db.global.RMBClickthrough = not Aptechka.db.global.RMBClickthrough
                            ReloadUI()
                        end,
                        order = 8.3,
                    },
                    singleHeaderMode = {
                        name = L"Merge Groups",
                        desc = L"Lose distinction between groups, but sorting will work across the whole raid",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.singleHeaderMode end,
                        set = function(info, v)
                            Aptechka.db.global.singleHeaderMode = not Aptechka.db.global.singleHeaderMode
                            Aptechka:PrintReloadUIWarning()
                        end,
                        order = 8.4,
                    },
                    mouseoverStatus = {
                        name = L"Mouseover Status",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.enableMouseoverStatus end,
                        set = function(info, v)
                            Aptechka.db.global.enableMouseoverStatus = not Aptechka.db.global.enableMouseoverStatus
                        end,
                        order = 8.6,
                    },
                    thickBorder = {
                        name = L"Thick Frame Outline",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.borderWidth == 2 end,
                        set = function(info, v)
                            Aptechka.db.global.borderWidth = (Aptechka.db.global.borderWidth == 2) and 1 or 2
                            Aptechka:ReconfigureUnprotected()
                        end,
                        order = 8.7,
                    },
                    disableBlizzardPlayer = {
                        name = L"Disable Blizzard Player Frame",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.disableBlizzardPlayer end,
                        set = function(info, v)
                            Aptechka.db.global.disableBlizzardPlayer = not Aptechka.db.global.disableBlizzardPlayer
                            Aptechka:PrintReloadUIWarning()
                        end,
                        order = 8.9,
                    },
                    disableBlizzardParty = {
                        name = L"Disable Blizzard Party Frames",
                        width = "double",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.disableBlizzardParty end,
                        set = function(info, v)
                            Aptechka.db.global.disableBlizzardParty = not Aptechka.db.global.disableBlizzardParty
                            Aptechka:PrintReloadUIWarning()
                        end,
                        order = 9,
                    },
                    hideBlizzardRaid = {
                        name = L"Hide Blizzard Raid Frames",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.hideBlizzardRaid end,
                        set = function(info, v)
                            Aptechka.db.global.hideBlizzardRaid = not Aptechka.db.global.hideBlizzardRaid
                            Aptechka:PrintReloadUIWarning()
                        end,
                        order = 10,
                    },
                    translitCyrillic = {
                        name = L"Transliterate Cyrillic Names",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.translitCyrillic end,
                        set = function(info, v)
                            Aptechka.db.global.translitCyrillic = not Aptechka.db.global.translitCyrillic
                            Aptechka:ReconfigureUnprotected()
                        end,
                        order = 10.2,
                    },
                    -- disableBlizzardRaid = {
                    --     name = "Disable Blizzard Raid Frames (not recommended)",
                    --     width = "full",
                    --     type = "toggle",
                    --     confirm = true,
                    -- 	confirmText = "Warning: Will completely disable Blizzard CompactRaidFrames, but you also lose raid leader functionality. If you delete this addon, you can only revert with this macro:\n/script EnableAddOn('Blizzard_CompactRaidFrames'); EnableAddOn('Blizzard_CUFProfiles')",
                    --     get = function(info) return not IsAddOnLoaded("Blizzard_CompactRaidFrames") end,
                    --     set = function(info, v)
                    --         Aptechka:ToggleCompactRaidFrames()
                    --     end,
                    --     order = 10.4,
                    -- },
                    --[[
                    disableTooltip = {
                        name = L"Disable Unit Tooltips",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.disableTooltip end,
                        set = function(info, v)
                            Aptechka.db.global.disableTooltip = not Aptechka.db.global.disableTooltip
                        end,
                        order = 10.8,
                    },]]
                    disableAbsorbBar = {
                        name = L"Disable Absorb Side Bar",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.disableAbsorbBar end,
                        set = function(info, v)
                            Aptechka.db.global.disableAbsorbBar = not Aptechka.db.global.disableAbsorbBar
                            Aptechka:UpdateAbsorbBarConfig()
                            -- Aptechka:PrintReloadUIWarning()
                        end,
                        order = 10.9,
                    },
                    --[[
                    enableRoles = {
                        name = L"Display Roles",
                        desc = L"Disable role icons for WotLK",
                        type = "toggle",
                        width = "full",
                        order = 17,
                        get = function(info) return Aptechka.db.global.enableRoles end,
                        set = function(info, v)
                            Aptechka.db.global.enableRoles = not Aptechka.db.global.enableRoles
                            Aptechka:PrintReloadUIWarning()
                        end
                    },]]
                }
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaGlobalSettings", opt)

    return "AptechkaGlobalSettings", L"Global Settings"
end
