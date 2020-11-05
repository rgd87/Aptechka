local addonName, ns = ...

local L = Aptechka.L

local LSM = LibStub("LibSharedMedia-3.0")

local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

local AceGUI = LibStub("AceGUI-3.0")

local FORM_CACHE = {}
local formConstructors = {
    auras = {},
    traces = {},
    templates = {},
}

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


local function GetFormForCategory(category)
    local form = FORM_CACHE[category]
    if not form then
        FORM_CACHE[category] = formConstructors[category].Create()
        form = FORM_CACHE[category]
    end
    return form
end


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

        local form = GetFormForCategory(category)

        local opts
        if category == "auras" then
            opts = { assignto = Aptechka.util.set("spell1"), infoType = "DURATION", isMine = true, type = "HELPFUL", }
        elseif category == "traces" then
            opts = { assignto = Aptechka.util.set("spell1"), fade = 0.7, type = "SPELL_HEAL" }
        end
        if class == "GLOBAL" then opts.global = true end
        form:Fill(class, category, nil, opts, true)
        Frame.rpane:AddChild(form)
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

local function form_save(form)
    local save = AceGUI:Create("Button")
    save:SetText(L"Save")
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

        local default_opts_wrapped = AptechkaDefaultConfig[category][spellID]
        local default_opts
        if default_opts_wrapped then
            default_opts = CopyTable(default_opts_wrapped)
            Aptechka.util.UnwrapTemplate(default_opts) -- Merges and removes 'prototype' property
        end
        if default_opts then
            clean(opts, default_opts, "name", false)
            clean(opts, default_opts, "priority", false)
            clean(opts, default_opts, "extend_below", false)
            clean(opts, default_opts, "refreshTime", false)
            clean(opts, default_opts, "foreigncolor", false)
            clean(opts, default_opts, "infoType", false)
            clean(opts, default_opts, "maxCount", false)
            clean(opts, default_opts, "text", false)
            clean(opts, default_opts, "scale", 1)
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

        local oldOriginalSpell = AptechkaConfigMerged[category][spellID]
        -- Kill all jobs with the old settings
        Aptechka:ForEachFrame(function(frame)
            Aptechka.FrameSetJob(frame, oldOriginalSpell, false)
        end)
        -- remove clones of the previous version of the spell
        if oldOriginalSpell and oldOriginalSpell.clones then
            for additionalSpellID in pairs(oldOriginalSpell.clones) do
                AptechkaConfigMerged[category][additionalSpellID] = nil
                AptechkaConfigMerged.spellClones[additionalSpellID] = nil
            end
        end
        ----------

        if default_opts then
            -- Uhh, all 3 of these are doing almost the same thing?
            if delta.clones then delta.clones = Aptechka.util.Set.diff(default_opts.clones, delta.clones) end
            Aptechka.util.ShakeAssignments(delta, default_opts)
            Aptechka.util.RemoveDefaults(delta, default_opts)

            -- Generating actual working table
            local finalOpts = CopyTable(default_opts_wrapped) -- Copy of original default table with prototype
            Aptechka.util.MergeTable(finalOpts, delta)
            Aptechka.util.UnwrapTemplate(finalOpts)
            AptechkaConfigMerged[category][spellID] = finalOpts
        else
            AptechkaConfigMerged[category][spellID] = delta
            delta.isAdded = true
        end

        local originalSpell = AptechkaConfigMerged[category][spellID]
        -- fill up spell clones of the new version
        if originalSpell.clones then
            for additionalSpellID, enabled in pairs(originalSpell.clones) do
                if enabled then
                AptechkaConfigMerged[category][additionalSpellID] = originalSpell
                AptechkaConfigMerged.spellClones[additionalSpellID] = true
                end
            end
        end
        -- Rescan all units' auras with new settings
        Aptechka:UpdateMissingAuraList()
        Aptechka:ForEachFrame(Aptechka.FrameScanAuras)
        ----------

        AptechkaConfigCustom[class] = AptechkaConfigCustom[class] or {}
        AptechkaConfigCustom[class][category] = AptechkaConfigCustom[class][category] or {}
        if not next(delta) then delta = nil end
        AptechkaConfigCustom[class][category][spellID] = delta

        ns.frame.tree:UpdateSpellTree()
        ns.frame.tree:SelectByPath(class, category, spellID)
    end)
    form:AddChild(save)
end

local function form_delete(form)
    local delete = AceGUI:Create("Button")
    delete:SetText(L"Delete")
    delete:SetRelativeWidth(0.5)
    delete:SetCallback("OnClick", function(self, event)
        local p = self.parent
        local class = p.class
        local category = p.category
        local spellID = p.id
        -- local opts = p.opts

        local oldOriginalSpell = AptechkaConfigMerged[category][spellID]
        -- Kill all jobs with the old settings
        Aptechka:ForEachFrame(function(frame)
            Aptechka.FrameSetJob(frame, oldOriginalSpell, false)
        end)

        AptechkaConfigCustom[class][category][spellID] = nil
        AptechkaConfigMerged[category][spellID] = AptechkaDefaultConfig[category][spellID]

        -- Rescan all units' auras with new settings
        Aptechka:ForEachFrame(Aptechka.FrameScanAuras)

        ns.frame.tree:UpdateSpellTree()
        ns.frame.tree:SelectByPath(class, category, spellID)
    end)
    form.controls.delete = delete
    form:AddChild(delete)
    return delete
end

local function form_spellID(form)
    local spellID = AceGUI:Create("EditBox")
    spellID:SetLabel(L"Spell ID")
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
    form.controls.spellID = spellID
    form:AddChild(spellID)
    return spellID
end

local function form_name(form)
    local name = AceGUI:Create("EditBox")
    name:SetLabel(L"Internal Name")
    name:SetDisabled(false)
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
    form.controls.name = name
    form:AddChild(name)
    return name
end

local function form_disabled(form)
    local disabled = AceGUI:Create("CheckBox")
    disabled:SetLabel(L"Disabled")
    disabled:SetRelativeWidth(0.24)
    disabled:SetCallback("OnValueChanged", function(self, event, value)
        if value == false then value = nil end
        self.parent.opts["disabled"] = value
    end)
    -- disabled.alignoffset = 10
    -- disabled:SetHeight(36)
    form.controls.disabled = disabled
    form:AddChild(disabled)
    return disabled
end

local function form_prio(form)
    local prio = AceGUI:Create("EditBox")
    prio:SetLabel(L"Priority")
    prio:SetRelativeWidth(0.2)
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
    form.controls.priority = prio
    form:AddChild(prio)
    AddTooltip(prio, "Positive or negative numeric value.\nDefault priority is 80.")
    return prio
end

local function form_assignto(form)
    local assignto = AceGUI:Create("Dropdown")
    assignto:SetLabel(L"Assign to")
    assignto:SetMultiselect(true)
    assignto:SetRelativeWidth(0.50)
    assignto:SetCallback("OnValueChanged", function(self, event, slot, enabled)
        if self.parent.opts["assignto"] == nil then self.parent.opts["assignto"] = {} end
        local t = self.parent.opts["assignto"]
        t[slot] = enabled
    end)
    form.controls.assignto = assignto
    form:AddChild(assignto)
    return assignto
end

local function form_color(form)
    local color = AceGUI:Create("ColorPicker")
    color:SetLabel(L"Color")
    color:SetRelativeWidth(0.15)
    color:SetHasAlpha(false)
    color:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
        self.parent.opts["color"] = {r,g,b}
    end)
    form.controls.color = color
    form:AddChild(color)
    return color
end


local function form_clones(form)
    local clones = AceGUI:Create("EditBox")
    clones:SetLabel(L"Additional Spell IDs")
    clones:SetRelativeWidth(0.9)
    clones:SetCallback("OnEnterPressed", function(self, event, value)
        local cloneTable = {}
        for spellID in string.gmatch(value, "%d+") do
            local k = tonumber(spellID)
            if k then
                cloneTable[k] = true
            end
        end
        if next(cloneTable) then
            self.parent.opts["clones"] = cloneTable
        else
            self.parent.opts["clones"] = false
            self:SetText("")
        end
    end)
    form.controls.clones = clones
    form:AddChild(clones)
    AddTooltip(clones, "Spell ID list of clones / spell ranks" )
    return clones
end

local function form_scale(form)
    local scale = AceGUI:Create("Slider")
    scale:SetLabel(L"Scale")
    scale:SetSliderValues(0.3, 2, 0.05)
    scale:SetRelativeWidth(0.95)
    scale:SetCallback("OnValueChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v >= 0.3 and v <= 2 then
            self.parent.opts["scale"] = v
        else
            self.parent.opts["scale"] = 1
            self:SetText(self.parent.opts.scale or "1")
        end
    end)
    form.controls.scale = scale
    form:AddChild(scale)
    AddTooltip(scale, L"Scale (not always applicable)")
    return scale
end

local function InitForm()
    local Form = AceGUI:Create("ScrollFrame")
    Form:SetFullWidth(true)
    -- Form:SetHeight(0)
    Form:SetLayout("Flow")
    Form.opts = {}
    Form.controls = {}
    return Form
end

local function AuraForm_Fill(Form, class, category, id, opts, isEmptyForm)
    Form.opts = opts
    Form.class = class
    Form.category = category
    Form.id = id
    local controls = Form.controls

    controls.spellID:SetText(id or "")
    controls.spellID:SetDisabled(not isEmptyForm)
    controls.disabled:SetValue(opts.disabled)
    controls.disabled:SetDisabled(isEmptyForm)

    local widgetSelection = opts.assignto or {}
    controls.assignto:SetList(Aptechka:GetWidgetList())
    for slot, enabled in pairs(widgetSelection) do
        controls.assignto:SetItemValue(slot, enabled)
    end
    controls.name:SetText(opts.name or "")
    controls.priority:SetText(opts.priority)
    controls.extend_below:SetText(opts.extend_below)
    controls.isMine:SetValue(opts.isMine)
    controls.isMissing:SetValue(opts.isMissing)
    controls.showDuration:SetValue(opts.infoType == "DURATION")
    controls.showCount:SetValue(opts.infoType == "COUNT")
    controls.maxCount:SetText(opts.maxCount)
    controls.showText:SetValue(opts.infoType == "STATIC")
    controls.text:SetText(opts.text)
    controls.scale:SetValue(opts.scale or 1)
    controls.refreshTime:SetText(opts.refreshTime)

    local clonesText
    if opts.clones then
        local cloneList = {}
        for k, enabled in pairs(opts.clones) do
            if enabled then
                table.insert(cloneList, k)
            end
        end
        table.sort(cloneList)
        clonesText = table.concat(cloneList, ", ")
    end
    controls.clones:SetText(clonesText)

    controls.color:SetColor(fillAlpha(opts.color or {1,1,1,1} ))
    controls.foreigncolor:SetColor(fillAlpha(opts.foreigncolor or {1,1,1,0} ))


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

    controls.name:SetDisabled(true)
    controls.showDuration:SetDisabled(false)
    controls.showCount:SetDisabled(false)
    controls.maxCount:SetDisabled(false)
    -- controls.scale:SetDisabled(false)
    controls.isMine:SetDisabled(false)
    controls.extend_below:SetDisabled(false)
    controls.refreshTime:SetDisabled(false)
    controls.isMissing:SetDisabled(false)
end

local function AuraForm_Create(self)
    local Form = InitForm()

    Form.Fill = AuraForm_Fill

    form_save(Form)
    form_delete(Form)
    form_spellID(Form)
    form_name(Form)
    form_disabled(Form)
    form_prio(Form)
    form_assignto(Form)
    form_color(Form)

    local isMine = AceGUI:Create("CheckBox")
    isMine:SetLabel(L"Casted by Player")
    isMine:SetRelativeWidth(0.60)
    isMine:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["isMine"] = value
    end)
    Form.controls.isMine = isMine
    Form:AddChild(isMine)

    local foreigncolor = AceGUI:Create("ColorPicker")
    foreigncolor:SetLabel(L"Others' Color")
    foreigncolor:SetRelativeWidth(0.27)
    foreigncolor:SetHasAlpha(false)
    foreigncolor:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
        self.parent.opts["foreigncolor"] = {r,g,b}
    end)
    Form.controls.foreigncolor = foreigncolor
    Form:AddChild(foreigncolor)

    local fcr = AceGUI:Create("Button")
    fcr:SetText("X")
    fcr:SetRelativeWidth(0.1)
    fcr:SetCallback("OnClick", function(self, event)
        self.parent.opts["foreigncolor"] = false
        self.parent.controls.foreigncolor:SetColor(1,1,1,0)
    end)
    Form.controls.fcr = fcr
    Form:AddChild(fcr)
    AddTooltip(fcr, L"Reset")

    local isMissing = AceGUI:Create("CheckBox")
    isMissing:SetLabel(L"Show Missing")
    isMissing:SetRelativeWidth(0.95)
    isMissing:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["isMissing"] = value
    end)
    Form.controls.isMissing = isMissing
    Form:AddChild(isMissing)
    AddTooltip(isMissing, "Show indicator if aura is missing")

    local showDuration = AceGUI:Create("CheckBox")
    showDuration:SetLabel(L"Show Duration")
    showDuration:SetRelativeWidth(0.45)
    showDuration:SetCallback("OnValueChanged", function(self, event, value)
        if value then
            self.parent.opts["infoType"] = "DURATION"
            self.parent.controls.showCount:SetValue(false)
            self.parent.controls.showText:SetValue(false)
        else
            self.parent.opts["infoType"] = false
        end
    end)
    Form.controls.showDuration = showDuration
    Form:AddChild(showDuration)

    local extend_below = AceGUI:Create("EditBox")
    extend_below:SetLabel("Extend Below")
    extend_below:SetRelativeWidth(0.25)
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
    refreshTime:SetRelativeWidth(0.25)
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

    local showCount = AceGUI:Create("CheckBox")
    showCount:SetLabel(L"Show Stacks")
    showCount:SetRelativeWidth(0.45)
    showCount:SetCallback("OnValueChanged", function(self, event, value)
        if value then
            self.parent.opts["infoType"] = "COUNT"
            self.parent.controls.showDuration:SetValue(false)
            self.parent.controls.showText:SetValue(false)
        else
            self.parent.opts["infoType"] = false
        end
    end)
    Form.controls.showCount = showCount
    Form:AddChild(showCount)

    local maxCount = AceGUI:Create("EditBox")
    maxCount:SetLabel(L"Max Count")
    maxCount:SetRelativeWidth(0.5)
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

    local showText = AceGUI:Create("CheckBox")
    showText:SetLabel(L"Show Text")
    showText:SetRelativeWidth(0.45)
    showText:SetCallback("OnValueChanged", function(self, event, value)
        if value then
            self.parent.opts["infoType"] = "STATIC"
            self.parent.controls.showCount:SetValue(false)
            self.parent.controls.showDuration:SetValue(false)
        else
            self.parent.opts["infoType"] = false
        end
    end)
    Form.controls.showText = showText
    Form:AddChild(showText)

    local text = AceGUI:Create("EditBox")
    text:SetLabel(L"Text")
    text:SetRelativeWidth(0.5)
    text:DisableButton(true)
    text:SetCallback("OnTextChanged", function(self, event, value)
        self.parent.opts["text"] = value
        if value == "" then
            self.parent.opts["text"] = false
            self:SetText("")
        end
    end)
    Form.controls.text = text
    Form:AddChild(text)

    form_scale(Form)
    form_clones(Form)

    return Form
end





local function TraceForm_Fill(Form, class, category, id, opts, isEmptyForm)
    Form.opts = opts
    Form.class = class
    Form.category = category
    Form.id = id

    local controls = Form.controls
    controls.spellID:SetText(id or "")
    controls.spellID:SetDisabled(not isEmptyForm)
    controls.disabled:SetValue(opts.disabled)
    controls.disabled:SetDisabled(isEmptyForm)

    local widgetSelection = opts.assignto or {}
    controls.assignto:SetList(Aptechka:GetWidgetList())
    for slot, enabled in pairs(widgetSelection) do
        controls.assignto:SetItemValue(slot, enabled)
    end
    controls.name:SetText(opts.name or "")
    controls.priority:SetText(opts.priority)
    controls.scale:SetValue(opts.scale or 1)

    local clonesText
    if opts.clones then
        local cloneList = {}
        for k, enabled in pairs(opts.clones) do
            if enabled then
                table.insert(cloneList, k)
            end
        end
        table.sort(cloneList)
        clonesText = table.concat(cloneList, ", ")
    end
    controls.clones:SetText(clonesText)

    controls.color:SetColor(fillAlpha(opts.color or {1,1,1,1} ))
    -- controls.foreigncolor:SetColor(fillAlpha(opts.foreigncolor or {1,1,1,0} ))

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

    controls.name:SetDisabled(true)
end

local function TraceForm_Create(self)
    local Form = InitForm()

    Form.Fill = TraceForm_Fill

    form_save(Form)
    form_delete(Form)
    form_spellID(Form)
    form_name(Form)
    form_disabled(Form)
    form_prio(Form)
    form_assignto(Form)
    form_color(Form)
    form_scale(Form)
    form_clones(Form)

    return Form
end

formConstructors.auras.Create = function(self)
    local topgroup = AuraForm_Create()
    return topgroup
end
formConstructors.traces.Create = function()
    local topgroup = TraceForm_Create()
    return topgroup
end
-- formConstructors.templates.Create = function(self)
--     local topgroup = ns:CreateCommonForm()
--     return topgroup
-- end






function ns.CreateSpellList(name, parent )
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

        local opts

        -- if category == "templates" then
        --     local templateName = spellID

        -- else
        spellID = tonumber(spellID)
        local defaultOpts = AptechkaDefaultConfig[category][spellID]
        opts = defaultOpts and CopyTable(defaultOpts) or {}

        if AptechkaConfigCustom[class] and AptechkaConfigCustom[class][category] and AptechkaConfigCustom[class][category][spellID] then
            local customOpts = AptechkaConfigCustom[class][category][spellID]
            -- Merging custom properties on top of default table
            Aptechka.util.MergeTable(opts, customOpts)
        end

        Aptechka.util.UnwrapTemplate(opts)
        -- end

        Frame.rpane:Clear()

        local form = GetFormForCategory(category)

        form:Fill(class, category, spellID, opts)
        Frame.rpane:AddChild(form)
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
