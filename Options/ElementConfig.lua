
local addonName, ns = ...

local L = Aptechka.L

function ns.MakeElementConfig()
    local opt = {
        type = 'group',
        name = "Aptechka "..L"Elements",
        order = 1,
        args = {
        },
    }

    local configurableWidgets = {
        "AggroStatus",
        "TargetStatus",
        "MouseoverStatus",
        "MainTankStatus",
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
                    width = 0.3,
                    get = function(info) return tostring(AptechkaConfigMerged[status].priority) end,
                    set = function(info, v)
                        -- local st = info[1]
                        -- print(st)
                        local value = tonumber(v)
                        if value then
                            AptechkaConfigMerged[status].priority = value
                            Aptechka.helpers.MakeTables(AptechkaConfigCustom, "WIDGET", status)
                            AptechkaConfigCustom.WIDGET[status].priority = value
                        end
                    end,
                    order = 1,
                },

                widgets = {
                    name = L"Assign to",
                    type = 'select',
                    order = 2,
                    width = 1,
                    values = Aptechka.widget_list,
                    get = function(info)
                        local w = AptechkaConfigMerged[status].assignto
                        if type(w) == "table" then
                            w = AptechkaConfigMerged[status].assignto[1]
                        end
                        return w
                    end,
                    set = function(info, v)
                        Aptechka:ForEachFrame(function(frame)
                            Aptechka.FrameSetJob(frame, AptechkaConfigMerged[status], false)
                        end)
                        AptechkaConfigMerged[status].assignto = v
                        Aptechka.helpers.MakeTables(AptechkaConfigCustom, "WIDGET", status)
                        AptechkaConfigCustom.WIDGET[status].assignto = v
                    end,
                },

                color = {
                    name = L"Color",
                    type = "color",
                    width = 0.6,
                    get = function(info) return unpack(AptechkaConfigMerged[status].color) end,
                    set = function(info, r,g,b)
                        local c = {r,g,b}
                        AptechkaConfigMerged[status].color = c
                        Aptechka.helpers.MakeTables(AptechkaConfigCustom, "WIDGET", status)
                        AptechkaConfigCustom.WIDGET[status].color = c
                    end,
                    order = 3,
                },
            },
        }
    end

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaElementConfig", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaElementConfig", L"Elements", "Aptechka")

    return panelFrame
end
