local addonName, ns = ...

local L = Aptechka.L

local LSM = LibStub("LibSharedMedia-3.0")

local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

local AceGUI = LibStub("AceGUI-3.0")

local sortfunc = function(a,b)
    if a.order == b.order then
        return a.value < b.value
    else
        return a.order < b.order
    end
end

local MakeValuesForKeys = function(t)
    local t1 = {}
    for k,v in pairs(t) do
        t1[k] = k
    end
    return t1
end

function ns.GenerateCategoryTree(self, isGlobal, category)
    local _,class = UnitClass("player")
    local custom = isGlobal and AptechkaConfigCustom["GLOBAL"] or AptechkaConfigCustom[class]

    local t = {}
    for spellID, opts in pairs(AptechkaConfigMerged[category]) do
        if not AptechkaConfigMerged.spellClones[spellID] then
            if (isGlobal and opts.global) or (not isGlobal and not opts.global) then
                local name = (GetSpellInfo(spellID) or "<Unknown>") or opts.name
                local custom_opts = custom[category] and custom[category][spellID]
                local status
                local order = 5
                -- print(opts.name, custom_opts)
                if not custom_opts or not next(custom_opts) then
                    status = nil
                elseif custom_opts.disabled then
                    status = "|cffff0000[D] |r"
                    order = 6
                elseif not AptechkaDefaultConfig[category][spellID] then
                    status = "|cff33ff33[A] |r"
                    order = 1
                else
                    status = "|cffffaa00[M] |r"
                    order = 2
                end
                local text = status and status..name or name
                table.insert(t, {
                    value = spellID,
                    text = text,
                    icon = GetSpellTexture(spellID),
                    order = order,
                })
            end
        end
    end
    table.sort(t, sortfunc)
    return t
end


local AuraForm
local CooldownForm
local NewTimerForm


function ns.CreateNewTimerForm(self)
    local Form = AceGUI:Create("InlineGroup")
    Form:SetFullWidth(true)
    -- Form:SetHeight(0)
    Form:SetLayout("Flow")
    Form.opts = {}
    Form.controls = {}

    Form.ShowNewTimer = function(self, category)
        assert(category)
        local Frame = ns.frame
        local class = self.class

        Frame.rpane:Clear()
        if not AuraForm then
            AuraForm = ns:CreateAuraForm()
        end
        local opts
        if category == "auras" then
            opts = { assignto = Aptechka.util.set("spell1"), showDuration = true, isMine = true, type = "HELPFUL", }
        elseif category == "traces" then
            opts = { assignto = Aptechka.util.set("spell1"), fade = 0.7, type = "SPELL_HEAL" }
        end
        if class == "GLOBAL" then opts.global = true end
        ns:FillForm(AuraForm, class, category, nil, opts, true)
        Frame.rpane:AddChild(AuraForm)
    end

    local newaura = AceGUI:Create("Button")
    newaura:SetText("New Aura")
    newaura:SetFullWidth(true)
    newaura:SetCallback("OnClick", function(self, event)
        self.parent:ShowNewTimer("auras")
    end)
    Form:AddChild(newaura)
    Form.controls.newaura = newaura

    local newtrace = AceGUI:Create("Button")
    newtrace:SetText("New Trace")
    newtrace:SetFullWidth(true)
    newtrace:SetCallback("OnClick", function(self, event)
        self.parent:ShowNewTimer("traces")
    end)
    Form:AddChild(newtrace)
    Form.controls.newtrace = newtrace


    return Form
end

local tooltipOnEnter = function(self, event)
    GameTooltip:SetOwner(self.frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1);
    GameTooltip:Show();
end
local tooltipOnLeave = function(self, event)
    GameTooltip:Hide();
end
local function AddTooltip(widget, tooltipText)
    widget.tooltipText = tooltipText
    widget:SetCallback("OnEnter", tooltipOnEnter)
    widget:SetCallback("OnLeave", tooltipOnLeave)
end
ns.WidgetAddTooltip = AddTooltip

local clean = function(delta, default_opts, property, emptyValue)
    if delta[property] == emptyValue and default_opts[property] == nil then delta[property] = nil end
end

function ns.CreateCommonForm(self)
    local Form = AceGUI:Create("ScrollFrame")
    Form:SetFullWidth(true)
    -- Form:SetHeight(0)
    Form:SetLayout("Flow")
    Form.opts = {}
    Form.controls = {}




    local save = AceGUI:Create("Button")
    save:SetText("Save")
    save:SetRelativeWidth(0.5)
    save:SetCallback("OnClick", function(self, event)
        local p = self.parent
        local class = p.class
        local category = p.category
        local spellID = p.id
        local opts = p.opts

        if not spellID then -- make new timer
            spellID = tonumber(self.parent.controls.spellID:GetText())
            if not spellID or not tonumber(spellID) then
                --invalid spell id string
                return
            end
            if not GetSpellInfo(spellID) then
                return -- spell doesn't exist
            end

            -- if not opts.name then
                -- opts.name = GetSpellInfo(spellID)
            -- end
            opts.spellID = nil
        end

        if not opts.name then
            opts.name = GetSpellInfo(spellID)
            if category == "traces" then
                opts.name = opts.name.."Trace"
            end
        end

        local default_opts = AptechkaDefaultConfig[category][spellID]
        if default_opts then
            -- clean(opts, default_opts, "ghost", false)
            -- clean(opts, default_opts, "singleTarget", false)
            -- clean(opts, default_opts, "multiTarget", false)
            -- clean(opts, default_opts, "scale", 1)
            -- clean(opts, default_opts, "shine", false)
            -- clean(opts, default_opts, "shinerefresh", false)
            -- clean(opts, default_opts, "nameplates", false)
            -- clean(opts, default_opts, "group", "default")
            -- clean(opts, default_opts, "affiliation", COMBATLOG_OBJECT_AFFILIATION_MINE)
            -- clean(opts, default_opts, "fixedlen", false)
            clean(opts, default_opts, "name", false)
            clean(opts, default_opts, "priority", false)
            clean(opts, default_opts, "extend_below", false)
            clean(opts, default_opts, "refreshTime", false)
            clean(opts, default_opts, "foreigncolor", false)
            clean(opts, default_opts, "showDuration", false)
            clean(opts, default_opts, "showCount", false)
            clean(opts, default_opts, "maxCount", false)
            clean(opts, default_opts, "scale", 1)
            -- clean(opts, default_opts, "scale_until", false)
            -- clean(opts, default_opts, "hide_until", false)
            -- clean(opts, default_opts, "maxtimers", false)
            -- clean(opts, default_opts, "color2", false)
            -- clean(opts, default_opts, "arrow", false)
            -- clean(opts, default_opts, "overlay", false)
            -- clean(opts, default_opts, "tick", false)
            -- clean(opts, default_opts, "recast_mark", false)
            -- clean(opts, default_opts, "effect", "NONE")
            -- clean(opts, default_opts, "ghosteffect", "NONE")
            clean(opts, default_opts, "clones", false)
        end

        local delta = CopyTable(opts)
        delta.realID = nil -- important, clears runtime data
        delta.isforeign = nil
        delta.expirationTime = nil
        delta.realID = nil
        delta.duration = nil
        delta.texture = nil
        delta.stacks = nil

        delta.id = spellID -- very important

        -- remove clones of the previous version of the spell
        local oldOriginalSpell = AptechkaConfigMerged[category][spellID]
        if oldOriginalSpell and oldOriginalSpell.clones then
            for i, additionalSpellID in ipairs(oldOriginalSpell.clones) do
                AptechkaConfigMerged[category][additionalSpellID] = nil
                AptechkaConfigMerged.spellClones[additionalSpellID] = nil
            end
        end
        ----------

        if default_opts then
            if delta.clones then Aptechka.util.RemoveDefaultsPreserve(delta.clones, default_opts.clones) end
            Aptechka.util.ShakeAssignments(delta, default_opts)
            -- print("----")
            -- for k,v in pairs(delta.assignto) do
            --     print(k,v)
            -- end
            Aptechka.util.RemoveDefaults(delta, default_opts)
            AptechkaConfigMerged[category][spellID] = CopyTable(default_opts)
            -- if delta.disabled then
                -- AptechkaConfigMerged[category][spellID] = nil
            -- else
            Aptechka.util.MergeTable(AptechkaConfigMerged[category][spellID], delta, true)
            -- end
        else
            AptechkaConfigMerged[category][spellID] = delta
        end

        -- fill up spell clones of the new version
        local originalSpell = AptechkaConfigMerged[category][spellID]
        if originalSpell.clones then
            for i, additionalSpellID in ipairs(originalSpell.clones) do
                AptechkaConfigMerged[category][additionalSpellID] = originalSpell
                AptechkaConfigMerged.spellClones[additionalSpellID] = true
            end
        end
        ----------

        AptechkaConfigCustom[class] = AptechkaConfigCustom[class] or {}
        AptechkaConfigCustom[class][category] = AptechkaConfigCustom[class][category] or {}
        if not next(delta) then delta = nil end
        AptechkaConfigCustom[class][category][spellID] = delta

        ns.frame.tree:UpdateSpellTree()
        ns.frame.tree:SelectByPath(class, category, spellID)
        Aptechka:PostSpellListUpdate()
    end)
    Form:AddChild(save)

    local delete = AceGUI:Create("Button")
    delete:SetText("Delete")
    save:SetRelativeWidth(0.5)
    delete:SetCallback("OnClick", function(self, event)
        local p = self.parent
        local class = p.class
        local category = p.category
        local spellID = p.id
        -- local opts = p.opts

        AptechkaConfigCustom[class][category][spellID] = nil
        AptechkaConfigMerged[category][spellID] = AptechkaDefaultConfig[category][spellID]

        ns.frame.tree:UpdateSpellTree()
        ns.frame.tree:SelectByPath(class, category, spellID)
    end)
    Form.controls.delete = delete
    Form:AddChild(delete)

    local spellID = AceGUI:Create("EditBox")
    spellID:SetLabel("Spell ID")
    spellID:SetDisabled(true)
    spellID:DisableButton(true)
    spellID:SetRelativeWidth(0.2)
    spellID:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 and GetSpellInfo(v) then
            self.parent.opts["spellID"] = v
            self.editbox:SetTextColor(1,1,1)
        else
            self.editbox:SetTextColor(1,0,0)
        end
        if value == "" then self.parent.opts["spellID"] = nil end
    end)
    -- spellID:SetHeight(32)
    -- spellID.alignoffset = 30
    Form.controls.spellID = spellID
    Form:AddChild(spellID)

    local name = AceGUI:Create("EditBox")
    name:SetLabel("Internal Name")
    name:SetDisabled(false)
    -- name:SetFullWidth(true)
    name:SetRelativeWidth(0.5)
    -- name:SetCallback("OnEnterPressed", function(self, event, value)
        -- self.parent.opts["name"] = value
    -- end)
    name:SetCallback("OnTextChanged", function(self, event, value)
        if value == "" then
            self.parent.opts["name"] = false
            self:SetText("")
        else
            self.parent.opts["name"] = value
        end
    end)
    -- name:SetHeight(32)
    Form.controls.name = name
    Form:AddChild(name)
    AddTooltip(name, "Custom timer label.\nLeave blank to hide.")

    local disabled = AceGUI:Create("CheckBox")
    disabled:SetLabel("Disabled")
    disabled:SetRelativeWidth(0.2)
    disabled:SetCallback("OnValueChanged", function(self, event, value)
        if value == false then value = nil end
        self.parent.opts["disabled"] = value
    end)
    -- disabled.alignoffset = 10
    -- disabled:SetHeight(36)
    Form.controls.disabled = disabled
    Form:AddChild(disabled)


    local prio = AceGUI:Create("EditBox")
    prio:SetLabel("Priority")
    -- prio:SetFullWidth(true)
    prio:SetRelativeWidth(0.15)
    prio:DisableButton(true)
    prio:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v then
            self.parent.opts["priority"] = v
        elseif value == "" then
            self.parent.opts["priority"] = false
            self:SetText("")
        end
    end)
    -- prio:SetHeight(32)
    Form.controls.priority = prio
    Form:AddChild(prio)
    AddTooltip(prio, "Positive or negative numeric value.\nDefault priority is 80.")


    local assignto = AceGUI:Create("Dropdown")
    assignto:SetLabel("Assign to")
    assignto:SetMultiselect(true)
    assignto:SetRelativeWidth(0.30)
    assignto:SetCallback("OnValueChanged", function(self, event, slot, enabled)
        if self.parent.opts["assignto"] == nil then self.parent.opts["assignto"] = {} end
        local t = self.parent.opts["assignto"]
        t[slot] = enabled
    end)
    Form.controls.assignto = assignto
    Form:AddChild(assignto)
    AddTooltip(assignto, "Assign to indicator")

    -- local fixedlen = AceGUI:Create("EditBox")
    -- fixedlen:SetLabel("|cff00ff00Fixed Duration|r")
    -- fixedlen:SetRelativeWidth(0.2)
 --    fixedlen:DisableButton(true)
    -- fixedlen:SetCallback("OnTextChanged", function(self, event, value)
    --  local v = tonumber(value)
    --  if v and v > 0 then
    --      self.parent.opts["fixedlen"] = v
    --  elseif value == "" then
    --      self.parent.opts["fixedlen"] = false
    --      self:SetText("")
    --  end
    -- end)
    -- Form.controls.fixedlen = fixedlen
    -- Form:AddChild(fixedlen)
 --    AddTooltip(fixedlen, "Set static timer max duration to align timer decay speed with other timers")


    local color = AceGUI:Create("ColorPicker")
    color:SetLabel("Color")
    color:SetRelativeWidth(0.15)
    color:SetHasAlpha(false)
    color:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
        self.parent.opts["color"] = {r,g,b}
    end)
    Form.controls.color = color
    Form:AddChild(color)

    local foreigncolor = AceGUI:Create("ColorPicker")
    foreigncolor:SetLabel("Others' Color")
    foreigncolor:SetRelativeWidth(0.23)
    foreigncolor:SetHasAlpha(false)
    foreigncolor:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
        self.parent.opts["foreigncolor"] = {r,g,b}
    end)
    Form.controls.foreigncolor = foreigncolor
    Form:AddChild(foreigncolor)
    AddTooltip(foreigncolor, "Color for applications from other players")

    local fcr = AceGUI:Create("Button")
    fcr:SetText("X")
    fcr:SetRelativeWidth(0.1)
    fcr:SetCallback("OnClick", function(self, event)
        self.parent.opts["foreigncolor"] = false
        self.parent.controls.foreigncolor:SetColor(1,1,1,0)
    end)
    Form.controls.fcr = fcr
    Form:AddChild(fcr)
    AddTooltip(fcr, "Remove Other's Color")

    local isMissing = AceGUI:Create("CheckBox")
    isMissing:SetLabel("Show Missing")
    isMissing:SetRelativeWidth(0.26)
    isMissing:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["isMissing"] = value
    end)
    Form.controls.isMissing = isMissing
    Form:AddChild(isMissing)
    AddTooltip(isMissing, "Show indicator if aura is missing")

    local isMine = AceGUI:Create("CheckBox")
    isMine:SetLabel("Casted by Player")
    isMine:SetRelativeWidth(0.30)
    isMine:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["isMine"] = value
    end)
    Form.controls.isMine = isMine
    Form:AddChild(isMine)

    local scale = AceGUI:Create("Slider")
    scale:SetLabel(L"Scale")
    scale:SetSliderValues(0.3, 2, 0.05)
    scale:SetRelativeWidth(0.44)
    scale:SetCallback("OnValueChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v >= 0.3 and v <= 2 then
            self.parent.opts["scale"] = v
        else
            self.parent.opts["scale"] = 1
            self:SetText(self.parent.opts.scale or "1")
        end
    end)
    Form.controls.scale = scale
    Form:AddChild(scale)
    AddTooltip(scale, L"Vertical Bar scale, only applicable when assigned to bars")

    local showDuration = AceGUI:Create("CheckBox")
    showDuration:SetLabel("Show Duration")
    showDuration:SetRelativeWidth(0.95)
    showDuration:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["showDuration"] = value
        if value then
            self.parent.controls.showCount:SetValue(false)
            self.parent.opts["showCount"] = false
        end
    end)
    Form.controls.showDuration = showDuration
    Form:AddChild(showDuration)

    local showCount = AceGUI:Create("CheckBox")
    showCount:SetLabel("Show Stacks")
    showCount:SetRelativeWidth(0.55)
    showCount:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["showCount"] = value
        if value then
            self.parent.controls.showDuration:SetValue(false)
            self.parent.opts["showDuration"] = false
        end
    end)
    Form.controls.showCount = showCount
    Form:AddChild(showCount)

    local maxCount = AceGUI:Create("EditBox")
    maxCount:SetLabel("Max Count")
    maxCount:SetRelativeWidth(0.4)
    maxCount:DisableButton(true)
    maxCount:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 then
            self.parent.opts["maxCount"] = v
        elseif value == "" then
            self.parent.opts["maxCount"] = false
            self:SetText("")
        end
    end)
    Form.controls.maxCount = maxCount
    Form:AddChild(maxCount)


    local extend_below = AceGUI:Create("EditBox")
    extend_below:SetLabel("Extend Below")
    extend_below:SetRelativeWidth(0.19)
    extend_below:DisableButton(true)
    extend_below:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 then
            self.parent.opts["extend_below"] = v
        elseif value == "" then
            self.parent.opts["extend_below"] = false
            self:SetText("")
        end
    end)
    Form.controls.extend_below = extend_below
    Form:AddChild(extend_below)
    AddTooltip(extend_below, "Do not refresh duration if it's below X")

    local refreshTime = AceGUI:Create("EditBox")
    refreshTime:SetLabel("Refresh Time")
    refreshTime:SetRelativeWidth(0.19)
    refreshTime:DisableButton(true)
    refreshTime:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 then
            self.parent.opts["refreshTime"] = v
        elseif value == "" then
            self.parent.opts["refreshTime"] = false
            self:SetText("")
        end
    end)
    Form.controls.refreshTime = refreshTime
    Form:AddChild(refreshTime)
    AddTooltip(refreshTime, "Pandemic indication. Only works for bars")

    local clones = AceGUI:Create("EditBox")
    clones:SetLabel("Additional Spell IDs")
    clones:SetRelativeWidth(0.9)
    clones:SetCallback("OnEnterPressed", function(self, event, value)
        local cloneList = {}
        for spellID in string.gmatch(value, "%d+") do
            table.insert(cloneList, tonumber(spellID))
        end
        if next(cloneList) then
            self.parent.opts["clones"] = cloneList
        else
            self.parent.opts["clones"] = false
            self:SetText("")
        end
    end)
    Form.controls.clones = clones
    Form:AddChild(clones)
    AddTooltip(clones, "Spell ID list of clones / spell ranks" )

    -- Frame:AddChild(Form)
    -- Frame.top = Form
    return Form
end

function ns.CreateAuraForm(self)
    local topgroup = ns:CreateCommonForm()

    return topgroup
end

local ReverseLookup = function(self, effect)
    if not effect then return end
    for k,v in pairs(self) do
        if v == effect then
            return k
        end
    end
end
local fillAlpha = function(rgb)
    local r,g,b,a = unpack(rgb)
    a = a or 1
    return r,g,b,a
end

function ns.FillForm(self, Form, class, category, id, opts, isEmptyForm)
    Form.opts = opts
    Form.class = class
    Form.category = category
    Form.id = id
    local controls = Form.controls
    controls.spellID:SetText(id or "")
    controls.spellID:SetDisabled(not isEmptyForm)
    controls.disabled:SetValue(opts.disabled)
    controls.disabled:SetDisabled(isEmptyForm)

    local widgetSelection = opts.assignto
    controls.assignto:SetList(Aptechka:GetWidgetList())
    for slot, enabled in pairs(widgetSelection) do
        controls.assignto:SetItemValue(slot, enabled)
    end
    controls.name:SetText(opts.name or "")
    controls.priority:SetText(opts.priority)
    controls.extend_below:SetText(opts.extend_below)
    controls.isMine:SetValue(opts.isMine)
    controls.isMissing:SetValue(opts.isMissing)
    controls.showDuration:SetValue(opts.showDuration)
    controls.showCount:SetValue(opts.showCount)
    controls.maxCount:SetText(opts.maxCount)
    controls.scale:SetValue(opts.scale or 1)
    controls.refreshTime:SetText(opts.refreshTime)

    local clonesText
    if opts.clones then
        clonesText = table.concat(opts.clones, ", ")
    end
    controls.clones:SetText(clonesText)

    -- -- controls.group:SetValue(opts.group or "default")
    -- controls.duration:SetText((type(opts.duration) == "function" and "<func>") or opts.duration)
    -- controls.scale:SetValue(opts.scale or 1)
    -- controls.scale_until:SetText(opts.scale_until)
 --    controls.hide_until:SetText(opts.hide_until)
    -- controls.shine:SetValue(opts.shine)
    -- controls.shinerefresh:SetValue(opts.shinerefresh)

    -- if opts.ghost then
    -- 	controls.ghost:SetValue(true)
    -- else
    -- 	controls.ghost:SetValue(false)
    -- end
    -- controls.maxtimers:SetText(opts.maxtimers)
    -- controls.singleTarget:SetValue(opts.singleTarget)
    -- controls.multiTarget:SetValue(opts.multiTarget)

    controls.color:SetColor(fillAlpha(opts.color or {0.8, 0.1, 0.7} ))
    controls.foreigncolor:SetColor(fillAlpha(opts.foreigncolor or {1,1,1,0} ))

    -- controls.color2:SetColor(fillAlpha(opts.color2 or {1,1,1,0} ))
    -- controls.arrow:SetColor(fillAlpha(opts.arrow or {1,1,1,0} ))

    -- controls.affiliation:SetValue(opts.affiliation or COMBATLOG_OBJECT_AFFILIATION_MINE)
    -- controls.nameplates:SetValue(opts.nameplates)

    -- controls.tick:SetText(opts.tick)
    -- controls.recast_mark:SetText(opts.recast_mark)
    -- controls.fixedlen:SetText(opts.fixedlen)

    -- if opts.overlay then
    -- 	controls.overlay_start:SetText(opts.overlay[1])
    -- 	controls.overlay_end:SetText(opts.overlay[2])
    -- 	controls.overlay_haste:SetValue(opts.overlay[4])
    -- else
    -- 	controls.overlay_start:SetText("")
    -- 	controls.overlay_end:SetText("")
    -- 	controls.overlay_haste:SetValue(false)
    -- end

 --    controls.effect:SetValue(opts.effect or "NONE")
 --    controls.ghosteffect:SetValue(opts.ghosteffect or "NONE")

    if id and not AptechkaDefaultConfig[category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText("Delete")
    elseif AptechkaConfigCustom[class] and  AptechkaConfigCustom[class][category] and AptechkaConfigCustom[class][category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText("Restore")
    else
        controls.delete:SetDisabled(true)
        controls.delete:SetText("Restore")
    end


    if category == "auras" then
        controls.name:SetDisabled(false)
        controls.showDuration:SetDisabled(false)
        controls.showCount:SetDisabled(false)
        controls.maxCount:SetDisabled(false)
        -- controls.scale:SetDisabled(false)
        controls.isMine:SetDisabled(false)
        controls.extend_below:SetDisabled(false)
        controls.refreshTime:SetDisabled(false)
        controls.isMissing:SetDisabled(false)
    else
        controls.name:SetDisabled(true)
        controls.showDuration:SetDisabled(true)
        controls.showCount:SetDisabled(true)
        controls.maxCount:SetDisabled(true)
        -- controls.scale:SetDisabled(true)
        controls.isMine:SetDisabled(true)
        controls.extend_below:SetDisabled(true)
        controls.refreshTime:SetDisabled(true)
        controls.isMissing:SetDisabled(true)
    end

end



function ns.CreateWidgetSpellList(name, parent )
    -- Create a container frame
    -- local Frame = AceGUI:Create("Frame")
    -- Frame:SetTitle("ns")
    -- Frame:SetWidth(500)
    -- Frame:SetHeight(440)
    -- Frame:EnableResize(false)
    -- -- f:SetStatusText("Status Bar")
    -- -- Frame:SetParent(InterfaceOptionsFramePanelContainer)
    -- Frame:SetLayout("Flow")
    -- Frame:Hide()

    local Frame = AceGUI:Create("BlizOptionsGroup")
    Frame:SetName(name, parent)
    Frame:SetTitle("Aptechka "..L"Spell List")
    Frame:SetLayout("Fill")
    -- Frame:SetHeight(500)
    -- Frame:SetWidth(700)
    -- Frame:Show()



    -- local gr = AceGUI:Create("InlineGroup")
    -- gr:SetLayout("Fill")
    -- -- gr:SetWidth(600)
    -- -- gr:SetHeight(600)
    -- Frame:AddChild(gr)
    --
    -- local setcreate = AceGUI:Create("Button")
    -- setcreate:SetText("Save")
    -- -- setcreate:SetWidth(100)
    -- gr:AddChild(setcreate)
    -- if true then
        -- return Frame
    -- end


    -- local Frame = CreateFrame("Frame", "AptechkaOptions", UIParent) -- InterfaceOptionsFramePanelContainer)
    -- -- Frame:Hide()
    -- Frame.name = "AptechkaOptions"
    -- Frame.children = {}
    -- Frame:SetWidth(400)
    -- Frame:SetHeight(400)
    -- Frame:SetPoint("CENTER", UIParent, "CENTER",0,0)
    -- Frame.AddChild = function(self, child)
    -- 	table.insert(self.children, child)
    -- 	child:SetParent(self)
    -- end
    -- InterfaceOptions_AddCategory(Frame)


    -- local topgroup = AceGUI:Create("InlineGroup")
    -- topgroup:SetFullWidth(true)
    -- -- topgroup:SetHeight(0)
    -- topgroup:SetLayout("Flow")
    -- Frame:AddChild(topgroup)
    -- Frame.top = topgroup
    --
    -- local setname = AceGUI:Create("EditBox")
    -- setname:SetWidth(240)
    -- setname:SetText("NewSet1")F
    -- setname:DisableButton(true)
    -- topgroup:AddChild(setname)
    -- topgroup.label = setname
    --
    -- local setcreate = AceGUI:Create("Button")
    -- setcreate:SetText("Save")
    -- setcreate:SetWidth(100)
    -- setcreate:SetCallback("OnClick", function(self) ns:SaveSet() end)
    -- setcreate:SetCallback("OnEnter", function() Frame:SetStatusText("Create new/overwrite existing set") end)
    -- setcreate:SetCallback("OnLeave", function() Frame:SetStatusText("") end)
    -- topgroup:AddChild(setcreate)
    --
    -- local btn4 = AceGUI:Create("Button")
    -- btn4:SetWidth(100)
    -- btn4:SetText("Delete")
    -- btn4:SetCallback("OnClick", function() ns:DeleteSet() end)
    -- topgroup:AddChild(btn4)
    -- -- Frame.rpane:AddChild(btn4)
    -- -- Frame.rpane.deletebtn = btn4



    local treegroup = AceGUI:Create("TreeGroup") -- "InlineGroup" is also good
    -- treegroup:SetParent(InterfaceOptionsFramePanelContainer)
    -- treegroup.name = "AptechkaOptions"
    -- treegroup:SetFullWidth(true)
    -- treegroup:SetTreeWidth(200, false)
    -- treegroup:SetLayout("Flow")
    treegroup:SetFullHeight(true) -- probably?
    treegroup:SetFullWidth(true) -- probably?
    treegroup:EnableButtonTooltips(false)
    treegroup:SetCallback("OnGroupSelected", function(self, event, group)
        local path = {}
        for match in string.gmatch(group, '([^\001]+)') do
            table.insert(path, match)
        end

        local class, category, spellID = unpack(path)
        if not spellID or not category then
            Frame.rpane:Clear()
            if not NewTimerForm then
                NewTimerForm = ns:CreateNewTimerForm()
            end
            NewTimerForm.class = class
            Frame.rpane:AddChild(NewTimerForm)
            if class == "GLOBAL" then
                NewTimerForm.controls.newtrace:SetDisabled(true)
            else
                NewTimerForm.controls.newtrace:SetDisabled(false)
            end

            return
        end

        spellID = tonumber(spellID)
        local opts
        if not AptechkaConfigCustom[class] or not AptechkaConfigCustom[class][category] or not AptechkaConfigCustom[class][category][spellID] then
            opts = {}
        else
            opts = CopyTable(AptechkaConfigCustom[class][category][spellID])
        end
        Aptechka.util.SetupDefaults(opts, AptechkaDefaultConfig[category][spellID])

        -- if category == "spells" then
        Frame.rpane:Clear()
        if not AuraForm then
            AuraForm = ns:CreateAuraForm()
        end
        ns:FillForm(AuraForm, class, category, spellID, opts)
        Frame.rpane:AddChild(AuraForm)

        -- end
    end)

    Frame.rpane = treegroup
    Frame.tree = treegroup

    treegroup.UpdateSpellTree = function(self)
        local lclass, class = UnitClass("player")
        local classIcon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
        local classCoords = CLASS_ICON_TCOORDS[class]

        local t = {
            {
                value = "GLOBAL",
                text = "Global",
                icon = "Interface\\Icons\\spell_holy_resurrection",
                children = {
                    {
                        value = "auras",
                        text = "Auras",
                        icon = "Interface\\Icons\\spell_shadow_manaburn",
                        children = ns:GenerateCategoryTree(true, "auras")
                    },
                },
            },
            {
                value = class,
                text = lclass,
                icon = classIcon,
                iconCoords = classCoords,
                children = {
                    {
                        value = "auras",
                        text = "Auras",
                        icon = "Interface\\Icons\\spell_shadow_manaburn",
                        children = ns:GenerateCategoryTree(false,"auras")
                    },
                    {
                        value = "traces",
                        text = "Traces",
                        icon = "Interface\\Icons\\spell_nature_astralrecal",
                        children = ns:GenerateCategoryTree(false,"traces")
                    },
                }
            },
        }
        self:SetTree(t)
        return t
    end


    local t = treegroup:UpdateSpellTree()

    Frame:AddChild(treegroup)



    local categories = {"auras", "traces"}
    for i,group in ipairs(t) do -- expand all groups
        if group.value ~= "GLOBAL" then
            treegroup.localstatus.groups[group.value] = true
            for _, cat in ipairs(categories) do
                treegroup.localstatus.groups[group.value.."\001"..cat] = true
            end
        end
    end


    Frame.rpane.Clear = function(self)
        for i, child in ipairs(self.children) do
            child:SetParent(UIParent)
            child.frame:Hide()
        end
        table.wipe(self.children)
    end


    local _, class = UnitClass("player")
    Frame.tree:SelectByPath(class)



    return Frame
end
