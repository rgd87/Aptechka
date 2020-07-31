
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
        "DispelStatus",
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
                            Aptechka.helpers.MakeTables(AptechkaConfigCustom, "WIDGET", status)
                            AptechkaConfigCustom.WIDGET[status].priority = value
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
                        if type(wl) == "string" then
                            return wl == slot
                        end

                        for i,s in ipairs(wl) do
                            if s == slot then return true end
                        end
                    end,
                    set = function(info, slot, enabled)
                        Aptechka.helpers.MakeTables(AptechkaConfigCustom, "WIDGET", status)

                        local oldvalue = AptechkaConfigCustom.WIDGET[status].assignto
                        if type(oldvalue) == "string" then
                            AptechkaConfigCustom.WIDGET[status].assignto = { oldvalue }
                        end
                        if AptechkaConfigCustom.WIDGET[status].assignto == nil then AptechkaConfigCustom.WIDGET[status].assignto = {} end

                        local t = AptechkaConfigCustom.WIDGET[status].assignto
                        local foundIndex
                        for i,s in ipairs(t) do
                            if s == slot then
                                foundIndex = i
                                break
                            end
                        end
                        if enabled then
                            if foundIndex then return end
                            table.insert(t, slot)
                        else
                            if foundIndex then
                                table.remove(t, foundIndex)
                            end
                        end

                        AptechkaConfigMerged[status].assignto = AptechkaConfigCustom.WIDGET[status].assignto

                        -- Removing that status from all frames if something was disabled
                        if not enabled then
                            Aptechka:ForEachFrame(function(frame)
                                Aptechka.FrameSetJob(frame, AptechkaConfigMerged[status], false)
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
