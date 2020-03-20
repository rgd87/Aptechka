local addonName, ns = ...

local L = Aptechka.L

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

function ns.MakeGlobalSettings()
    local opt = {
        type = 'group',
        name = L"Aptechka Global Settings",
        order = 1,
        args = {
            switches = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3,
                args = {
                    RMBClickthrough = {
                        name = L"RMB Mouselook Clickthrough"..newFeatureIcon,
                        desc = L"Allows to turn with RMB without moving mouse away from the unitframes.\nIf using Clique, this will override its RMB binding",
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
                        get = function(info) return Aptechka.db.global.sortUnitsByRole end,
                        set = function(info, v)
                            Aptechka.db.global.sortUnitsByRole = not Aptechka.db.global.sortUnitsByRole
                            Aptechka:PrintReloadUIWarning()
                        end,
                        order = 8.5,
                    },

                    mouseoverStatus = {
                        name = L"Mouseover Border"..newFeatureIcon,
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.enableMouseoverStatus end,
                        set = function(info, v)
                            Aptechka.db.global.enableMouseoverStatus = not Aptechka.db.global.enableMouseoverStatus
                        end,
                        order = 8.6,
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
                        type = "toggle",
                        get = function(info) return Aptechka.db.global.disableTooltip end,
                        set = function(info, v)
                            Aptechka.db.global.disableTooltip = not Aptechka.db.global.disableTooltip
                        end,
                        order = 10.8,
                    },
                    showAFK = {
                        name = L"Show AFK",
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
                        name = L"Use LibCLHealth"..newFeatureIcon,
                        desc = L"More frequent health updates based combat log",
                        type = "toggle",
                        width = "full",
                        order = 18,
                        get = function(info) return Aptechka.db.global.useCombatLogHealthUpdates end,
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
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaGlobalSettings", "Global Settings", "Aptechka")

    return panelFrame
end
