local addonName, ns = ...

local L = Aptechka.L

local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
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
                    sortUnitsByRole = {
                        name = L"Sort Units by Role",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.sortMethod == "ROLE" end,
                        set = function(info, v)
                            if Aptechka.db.global.sortMethod == "ROLE" then
                                Aptechka.db.global.sortMethod = "NONE"
                            else
                                Aptechka.db.global.sortMethod = "ROLE"
                            end
                            Aptechka:PrintReloadUIWarning()
                        end,
                        order = 8.5,
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
                        name = L"Thick Frame Outline"..newFeatureIcon,
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.borderWidth == 2 end,
                        set = function(info, v)
                            Aptechka.db.global.borderWidth = (Aptechka.db.global.borderWidth == 2) and 1 or 2
                            Aptechka:PrintReloadUIWarning()
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
                    supportNickTag = {
                        name = L"Use Details Nicknames",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.enableNickTag end,
                        set = function(info, v)
                            Aptechka.db.global.enableNickTag = not Aptechka.db.global.enableNickTag
                            Aptechka:ReconfigureUnprotected()
                        end,
                        order = 10.1,
                    },
                    translitCyrillic = {
                        name = L"Transliterate Russian Names"..newFeatureIcon,
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
                    disableTooltip = {
                        name = L"Disable Tooltips",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.disableTooltip end,
                        set = function(info, v)
                            Aptechka.db.global.disableTooltip = not Aptechka.db.global.disableTooltip
                        end,
                        order = 10.8,
                    },
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
                    showAFK = {
                        name = L"Show AFK",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.showAFK end,
                        set = function(info, v)
                            Aptechka.db.global.showAFK = not Aptechka.db.global.showAFK
                            Aptechka:PrintReloadUIWarning()
                        end,
                        order = 11,
                    },
                    useDebuffOrdering = {
                        name = L"Use Debuff Ordering",
                        desc = L"Orders CC and dispellable debuffs to be first in the list".."\n"..L"Shows spell locks as debuffs",
                        width = "full",
                        type = "toggle",
                        order = 11.2,
                        get = function(info) return Aptechka.db.global.useDebuffOrdering end,
                        set = function(info, v)
                            Aptechka.db.global.useDebuffOrdering = not Aptechka.db.global.useDebuffOrdering
                            Aptechka:UpdateDebuffScanningMethod()
                        end
                    },
                    forceShamanColor = {
                        name = "Retail Shaman Color",
                        desc = "Use the usual blue color for shamans. Overriden by ClassColors addon if present",
                        type = "toggle",
                        confirm = true,
						confirmText = "Warning: Requires UI reloading.",
                        get = function(info) return Aptechka.db.global.forceShamanColor end,
                        set = function(info, v)
                            Aptechka.db.global.forceShamanColor = not Aptechka.db.global.forceShamanColor
                            ReloadUI()
                        end,
                        order = 15.8,
                    },
                    useCLH = {
                        name = L"Use LibCLHealth",
                        desc = L"More frequent health updates based combat log",
                        type = "toggle",
                        disabled = not isClassic,
                        width = "full",
                        order = 18,
                        get = function(info) return isClassic and Aptechka.db.global.useCombatLogHealthUpdates end,
                        set = function(info, v)
                            Aptechka.db.global.useCombatLogHealthUpdates = not Aptechka.db.global.useCombatLogHealthUpdates
                            Aptechka:PrintReloadUIWarning()
                        end
                    },
                }
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaGlobalSettings", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaGlobalSettings", L"Global Settings", "Aptechka")

    return panelFrame
end
