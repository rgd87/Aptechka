
local addonName, ns = ...

local L = Aptechka.L

function ns.MakeStatusConfig()
    local opt = {
        type = 'group',
        name = "Aptechka "..L"Status List",
        order = 1,
        args = {
        },
    }

    local configurableWidgets = {
        "AggroStatus",
        "TargetStatus",
        "MouseoverStatus",
        "MainTankStatus",
        "DispelStatus",
        "RunicPowerStatus",
        "AlternatePowerStatus",
    }

    for i, status in ipairs(configurableWidgets) do
        opt.args[status] = {
            type = "group",
            name = status,
            order = i,
            args = {
                priority = {
                    name = L"Priority",
                    type = "input",
                    width = 0.5,
                    get = function(info) return tostring(AptechkaConfigMerged[status].priority) end,
                    set = function(info, v)
                        -- local st = info[1]
                        -- print(st)
                        local value = tonumber(v)
                        if value then
                            AptechkaConfigMerged[status].priority = value
                            Aptechka.util.MakeTables(AptechkaConfigCustom, "WIDGET", status)
                            AptechkaConfigCustom.WIDGET[status].priority = value

                            Aptechka:ReapplyJob(AptechkaConfigMerged[status])
                        end
                    end,
                    order = 1,
                },

                widgets = {
                    name = L"Assign to",
                    type = 'multiselect',
                    order = 2,
                    width = 1,
                    dialogControl = "Dropdown",
                    values = Aptechka.GetWidgetList,
                    get = function(info, slot)
                        local wl = AptechkaConfigMerged[status].assignto
                        return wl[slot]
                    end,
                    set = function(info, slot, enabled)
                        local customOpts = Aptechka.util.MakeTables(AptechkaConfigCustom, "WIDGET", status)

                        if customOpts.assignto == nil then customOpts.assignto = {} end

                        local t = customOpts.assignto
                        t[slot] = enabled

                        local defaultOpts = AptechkaDefaultConfig[status]

                        Aptechka.util.ShakeAssignments(customOpts, defaultOpts)
                        local newMergedSet = Aptechka.util.Set.union(defaultOpts.assignto, customOpts.assignto)

                        AptechkaConfigMerged[status].assignto = newMergedSet

                        local mergedOpts = AptechkaConfigMerged[status]

                        -- Removing that status from all frames if something was disabled
                        if not enabled then
                            Aptechka:ForEachFrame(function(frame)
                                Aptechka.AssignToSlot(frame, mergedOpts, false, slot)
                                -- Aptechka.FrameSetJob(frame, AptechkaConfigMerged[status], false)
                            end)
                        end
                    end,
                },

                color = {
                    name = L"Color",
                    type = "color",
                    width = 0.6,
                    get = function(info)
                        local color = AptechkaConfigMerged[status].color
                        if color then
                            return unpack(AptechkaConfigMerged[status].color)
                        else
                            return 0,0,0
                        end
                    end,
                    set = function(info, r,g,b)
                        local c = {r,g,b}
                        AptechkaConfigMerged[status].color = c
                        Aptechka.util.MakeTables(AptechkaConfigCustom, "WIDGET", status)
                        AptechkaConfigCustom.WIDGET[status].color = c

                        Aptechka:ReapplyJob(AptechkaConfigMerged[status])
                    end,
                    order = 3,
                },
                scale = {
                    name = L"Scale",
                    type = "range",
                    get = function(info) return AptechkaConfigMerged[status].scale or 1 end,
                    set = function(info, value)
                        AptechkaConfigMerged[status].scale = value
                        Aptechka.util.MakeTables(AptechkaConfigCustom, "WIDGET", status)
                        AptechkaConfigCustom.WIDGET[status].scale = value

                        Aptechka:ReapplyJob(AptechkaConfigMerged[status])
                    end,
                    min = 0.5,
                    max = 3,
                    step = 0.1,
                    order = 4,
                },
                reset = {
                    name = L"Reset",
                    type = "execute",
                    width = "full",
                    func = function()
                        local opts = AptechkaConfigMerged[status]
                        Aptechka:ForEachFrame(function(frame, unit)
                            Aptechka.FrameSetJob(frame, opts, false)
                        end)

                        if AptechkaConfigCustom.WIDGET then
                            AptechkaConfigCustom.WIDGET[status] = nil
                        end
                        AptechkaConfigMerged[status] = CopyTable(AptechkaDefaultConfig[status])
                    end,
                    order = 16,
                },
            },
        }
    end

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaStatusConfig", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaStatusConfig", L"Status List", "Aptechka")

    return panelFrame
end
