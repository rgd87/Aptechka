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


function ns.GenerateCategoryTree(self, settingsClass, category)
    local _,class = UnitClass("player")
    local isGlobal = settingsClass == "GLOBAL"
    local isTemplate = settingsClass == "TEMPLATES"
    local default = AptechkaDefaultConfig[settingsClass] or {}
    local custom = AptechkaConfigCustom[settingsClass] or {}

    local spellList = AptechkaConfigMerged[category]
    local defaultSpellList = default[category] or {}
    local customSpellList = custom[category] or {}
    if settingsClass == "TEMPLATES" then
        spellList = AptechkaConfigMerged.templates
        defaultSpellList = AptechkaDefaultConfig.templates
        customSpellList = AptechkaConfigCustom.TEMPLATES or {}
    end

    local t = {}
    for spellID, opts in pairs(spellList) do
        if not AptechkaConfigMerged.spellClones[spellID] then
            if isTemplate or defaultSpellList[spellID] or customSpellList[spellID] then
                local name
                if type(spellID) == "number" then
                    name = (GetSpellInfo(spellID) or "<Unknown>") or opts.name
                else
                    name = spellID
                end
                local custom_opts = customSpellList and customSpellList[spellID]
                local status
                local order = 5
                -- print(opts.name, custom_opts)
                if not custom_opts or not next(custom_opts) then
                    status = nil
                elseif custom_opts.disabled then
                    status = "|cffff0000[D] |r"
                    order = 6
                elseif not defaultSpellList[spellID] then
                    status = "|cff33ff33[A] |r"
                    order = 1
                else
                    status = "|cffffaa00[M] |r"
                    order = 2
                end
                local text = status and status..name or name
                local icon = not isTemplate and GetSpellTexture(spellID)
                table.insert(t, {
                    value = spellID,
                    text = text,
                    icon = icon,
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
            opts = { assignto = Aptechka.util.set("spell1"), infoType = "DURATION", isMine = true }
        elseif category == "traces" then
            opts = { assignto = Aptechka.util.set("spell1"), fade = 0.7 }
        elseif category == "templates" then
            opts = { assignto = {}, priority = 80, fade = 0.7 }
        end
        if class == "GLOBAL" then opts.global = true end
        form:Fill(class, category, nil, opts, true)
        Frame.rpane:AddChild(form)
    end

    local newaura = AceGUI:Create("Button")
    newaura:SetText(L"New Aura")
    newaura:SetFullWidth(true)
    newaura:SetCallback("OnClick", function(self, event)
        self.parent:ShowNewTimer("auras")
    end)
    Form:AddChild(newaura)
    Form.controls.newaura = newaura

    local newtrace = AceGUI:Create("Button")
    newtrace:SetText(L"New Trace")
    newtrace:SetFullWidth(true)
    newtrace:SetCallback("OnClick", function(self, event)
        self.parent:ShowNewTimer("traces")
    end)
    Form:AddChild(newtrace)
    Form.controls.newtrace = newtrace

    local newtemplate = AceGUI:Create("Button")
    newtemplate:SetText(L"New Template")
    newtemplate:SetFullWidth(true)
    newtemplate:SetCallback("OnClick", function(self, event)
        self.parent:ShowNewTimer("templates")
    end)
    Form:AddChild(newtemplate)
    Form.controls.newtemplate = newtemplate


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

        local isTemplate = category == "templates"
        if isTemplate and not spellID then
            spellID = opts.name
            opts.name = nil
        elseif not spellID then -- make new timer
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


        local default_opts
        local default_opts_wrapped
        if not isTemplate then
            default_opts_wrapped = AptechkaDefaultConfig[class][category][spellID]
            if default_opts_wrapped then
                default_opts = CopyTable(default_opts_wrapped)
                Aptechka.util.UnwrapTemplate(default_opts) -- Merges and removes 'prototype' property
            end
        else
            local default_template = AptechkaDefaultConfig.templates[spellID]
            default_opts = default_template and CopyTable(default_template)
        end
        if default_opts then
            clean(opts, default_opts, "name", false)
            clean(opts, default_opts, "priority", false)
            clean(opts, default_opts, "extend_below", false)
            clean(opts, default_opts, "refreshTime", false)
            clean(opts, default_opts, "foreigncolor", false)
            clean(opts, default_opts, "infoType", false)
            clean(opts, default_opts, "template", false)
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


        if isTemplate then
            delta.id = nil

            -- 1) Kill old config active spells
            local templateName = spellID
            local spellsWithTemplate = {}
            for _sid, opts in pairs(AptechkaConfigMerged["auras"]) do
                spellsWithTemplate[opts] = true
            end
            Aptechka:ForEachFrame(function(frame)
                for opts in pairs(spellsWithTemplate) do
                    Aptechka.FrameSetJob(frame, opts, false)
                end
            end)

            -- Merge changes into working config templates
            if default_opts then
                Aptechka.util.ShakeAssignments(delta, default_opts)
                Aptechka.util.RemoveDefaults(delta, default_opts)

                -- Generating actual working table
                local finalOpts = CopyTable(default_opts) -- Copy of original default table with prototype
                Aptechka.util.MergeTable(finalOpts, delta)
                AptechkaConfigMerged[category][spellID] = finalOpts
            else
                AptechkaConfigMerged[category][spellID] = delta
                delta.isAdded = true
            end

            AptechkaConfigCustom[class] = AptechkaConfigCustom[class] or {}
            if not next(delta) then delta = nil end
            AptechkaConfigCustom[class][templateName] = delta

            -- Regenerate spells with new template
            Aptechka:GenerateMergedConfig()

            ns.frame.tree:UpdateSpellTree()
            ns.frame.tree:SelectByPath(class, templateName)
        else

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
                local templateOpts = delta.template and AptechkaConfigMerged.templates[delta.template]
                if templateOpts then
                    Aptechka.util.ShakeAssignments(delta, templateOpts)
                    Aptechka.util.RemoveDefaults(delta, templateOpts)
                end
                AptechkaConfigMerged[category][spellID] = delta
                delta.isAdded = true
            end

            Aptechka:UpdateSpellNameToIDTable()

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

            AptechkaConfigCustom[class] = AptechkaConfigCustom[class] or {}
            AptechkaConfigCustom[class][category] = AptechkaConfigCustom[class][category] or {}
            if not next(delta) then delta = nil end
            AptechkaConfigCustom[class][category][spellID] = delta

            ns.frame.tree:UpdateSpellTree()
            ns.frame.tree:SelectByPath(class, category, spellID)
        end

        -- Rescan all units' auras with new settings
        Aptechka:UpdateMissingAuraList()
        Aptechka:ForEachFrame(Aptechka.FrameScanAuras)
        ----------

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

        local isTemplate = category == "templates"

        if isTemplate then
            -- 1) Kill old config active spells
            local templateName = spellID
            local spellsWithTemplate = {}
            for _sid, opts in pairs(AptechkaConfigMerged["auras"]) do
                spellsWithTemplate[opts] = true
            end
            Aptechka:ForEachFrame(function(frame)
                for opts in pairs(spellsWithTemplate) do
                    Aptechka.FrameSetJob(frame, opts, false)
                end
            end)

            AptechkaConfigCustom.TEMPLATES[templateName] = nil
            AptechkaConfigMerged.templates[templateName] = AptechkaDefaultConfig.templates[templateName]

            -- Regenerate spells with new template
            Aptechka:GenerateMergedConfig()

            ns.frame.tree:UpdateSpellTree()
            ns.frame.tree:SelectByPath(class, templateName)
        else

            local oldOriginalSpell = AptechkaConfigMerged[category][spellID]
            -- Kill all jobs with the old settings
            Aptechka:ForEachFrame(function(frame)
                Aptechka.FrameSetJob(frame, oldOriginalSpell, false)
            end)

            AptechkaConfigCustom[class][category][spellID] = nil
            AptechkaConfigMerged[category][spellID] = AptechkaDefaultConfig[class][category][spellID]

            ns.frame.tree:UpdateSpellTree()
            ns.frame.tree:SelectByPath(class, category, spellID)
        end

        -- Rescan all units' auras with new settings
        Aptechka:UpdateMissingAuraList()
        Aptechka:ForEachFrame(Aptechka.FrameScanAuras)
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

local function form_showDuration(form)
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
    form.controls.showDuration = showDuration
    form:AddChild(showDuration)
    return showDuration
end

local function form_showCount(form)
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
    form.controls.showCount = showCount
    form:AddChild(showCount)
    return showCount
end

local function form_showText(form)
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
    form.controls.showText = showText
    form:AddChild(showText)
    return showText
end

local function form_isMine(form)
    local isMine = AceGUI:Create("CheckBox")
    isMine:SetLabel(L"Casted by Player")
    isMine:SetRelativeWidth(0.60)
    isMine:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["isMine"] = value
    end)
    form.controls.isMine = isMine
    form:AddChild(isMine)
    return form
end

local function form_template(form)
    local template = AceGUI:Create("Dropdown")
    template:SetLabel(L"Template")
    template:SetRelativeWidth(1)
    template:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["template"] = value
        local templateOpts = Aptechka:GetTemplateOpts(value)
        if templateOpts then
            local topts = CopyTable(templateOpts)
            for k,v in pairs(topts) do
                self.parent.opts[k] = v
            end
            self.parent:Refill()
        end
    end)
    form.controls.template = template
    form:AddChild(template)
    return template
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

local function Form_FillAssignments(controls, opts)
    local widgetSelection = opts.assignto or {}
    controls.assignto:SetList(Aptechka:GetWidgetList())
    for slot, enabled in pairs(widgetSelection) do
        controls.assignto:SetItemValue(slot, enabled)
    end
end

local function Form_FillClones(controls, opts)
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
end

local function Form_FillTemplate(controls, opts)
    local tmplOrder = { false }
    local templateList = { [false] = "None" }
    for templateName, opts in pairs(AptechkaConfigMerged.templates) do
        templateList[templateName] = templateName
        table.insert(tmplOrder, templateName)
    end

    controls.template:SetList(templateList, tmplOrder)
    local v = opts.template
    if v == nil then v = false end
    controls.template:SetValue(v)
end

local function Form_Refill(form)
    form:Fill(form.class, form.category, form.id, form.opts, form.isNew)
end

local function AuraForm_Fill(Form, class, category, id, opts, isEmptyForm)
    Form.opts = opts
    Form.class = class
    Form.category = category
    Form.id = id
    Form.isNew = isEmptyForm
    local controls = Form.controls

    controls.spellID:SetText(id or "")
    controls.spellID:SetDisabled(not isEmptyForm)
    controls.disabled:SetValue(opts.disabled)
    controls.disabled:SetDisabled(isEmptyForm)

    Form_FillAssignments(controls, opts)
    controls.name:SetText(opts.name or "")
    controls.name:SetDisabled(true)
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

    Form_FillTemplate(controls, opts)

    Form_FillClones(controls, opts)

    controls.color:SetColor(fillAlpha(opts.color or {1,1,1,1} ))
    controls.foreigncolor:SetColor(fillAlpha(opts.foreigncolor or {1,1,1,0} ))


    if id and not AptechkaDefaultConfig[class][category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Delete")
    elseif AptechkaConfigCustom[class] and  AptechkaConfigCustom[class][category] and AptechkaConfigCustom[class][category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Restore")
    else
        controls.delete:SetDisabled(true)
        controls.delete:SetText(L"Restore")
    end

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
    Form.Refill = Form_Refill

    form_save(Form)
    form_delete(Form)
    form_spellID(Form)
    form_name(Form)
    form_disabled(Form)
    form_template(Form)
    form_prio(Form)
    form_assignto(Form)
    form_color(Form)
    form_isMine(Form)

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

    form_showDuration(Form)

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

    form_showCount(Form)

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

    form_showText(Form)

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


local function TemplateForm_Fill(Form, class, category, id, opts, isEmptyForm)
    Form.opts = opts
    Form.class = class
    Form.category = category
    Form.id = id
    local controls = Form.controls

    controls.name:SetText(id or "")
    controls.name:SetDisabled(not isEmptyForm)

    Form_FillAssignments(controls, opts)
    controls.priority:SetText(opts.priority)
    controls.isMine:SetValue(opts.isMine)
    controls.showDuration:SetValue(opts.infoType == "DURATION")
    controls.showCount:SetValue(opts.infoType == "COUNT")
    controls.color:SetColor(fillAlpha(opts.color or {1,1,1,1} ))
    -- controls.foreigncolor:SetColor(fillAlpha(opts.foreigncolor or {1,1,1,0} ))
    controls.showText:SetValue(opts.infoType == "STATIC")
    controls.scale:SetValue(opts.scale or 1)

    if id and not AptechkaDefaultConfig.templates[id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Delete")
    elseif AptechkaConfigCustom.TEMPLATES and AptechkaConfigCustom.TEMPLATES[id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Restore")
    else
        controls.delete:SetDisabled(true)
        controls.delete:SetText(L"Restore")
    end
end

local function TemplateForm_Create(self)
    local form = InitForm()

    form.Fill = TemplateForm_Fill
    form.Refill = Form_Refill

    form_save(form)
    form_delete(form)
    -- form_spellID(form)
    form_name(form)
    -- form_disabled(form)
    form.controls.name:SetLabel(L"Name")
    form.controls.name:SetRelativeWidth(1)
    form_prio(form)
    form_assignto(form)
    form_color(form)
    form_isMine(form)
    form_showDuration(form)
    form.controls.showDuration:SetRelativeWidth(1)
    form_showCount(form)
    form.controls.showCount:SetRelativeWidth(1)
    form_showText(form)
    form.controls.showText:SetRelativeWidth(1)
    form_scale(form)
    return form
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

    Form_FillAssignments(controls, opts)
    controls.name:SetText(opts.name or "")
    controls.priority:SetText(opts.priority)
    controls.scale:SetValue(opts.scale or 1)

    Form_FillTemplate(controls, opts)
    Form_FillClones(controls, opts)

    controls.color:SetColor(fillAlpha(opts.color or {1,1,1,1} ))
    -- controls.foreigncolor:SetColor(fillAlpha(opts.foreigncolor or {1,1,1,0} ))

    if id and not AptechkaDefaultConfig[class][category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Delete")
    elseif AptechkaConfigCustom[class] and  AptechkaConfigCustom[class][category] and AptechkaConfigCustom[class][category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Restore")
    else
        controls.delete:SetDisabled(true)
        controls.delete:SetText(L"Restore")
    end

    controls.name:SetDisabled(true)
end

local function TraceForm_Create(self)
    local Form = InitForm()

    Form.Fill = TraceForm_Fill
    Form.Refill = Form_Refill

    form_save(Form)
    form_delete(Form)
    form_spellID(Form)
    form_name(Form)
    form_disabled(Form)
    form_template(Form)
    form_prio(Form)
    form_assignto(Form)
    form_color(Form)
    form_scale(Form)
    form_clones(Form)

    return Form
end

formConstructors.auras.Create = function(self)
    local form = AuraForm_Create()
    return form
end
formConstructors.traces.Create = function()
    local form = TraceForm_Create()
    return form
end
formConstructors.templates.Create = function(self)
    local form = TemplateForm_Create()
    return form
end

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
        if class == "TEMPLATES" then
            spellID = category
            category = "templates"
        end
        if not spellID or not category then
            Frame.rpane:Clear()
            if not NewTimerForm then
                NewTimerForm = ns:CreateNewTimerForm()
            end
            NewTimerForm.class = class
            Frame.rpane:AddChild(NewTimerForm)
            if class == "GLOBAL" then
                NewTimerForm.controls.newtrace:SetDisabled(true)
                NewTimerForm.controls.newaura:SetDisabled(false)
                NewTimerForm.controls.newtemplate:SetDisabled(true)
            elseif class == "TEMPLATES" then
                NewTimerForm.controls.newtrace:SetDisabled(true)
                NewTimerForm.controls.newaura:SetDisabled(true)
                NewTimerForm.controls.newtemplate:SetDisabled(false)
            else
                NewTimerForm.controls.newtrace:SetDisabled(false)
                NewTimerForm.controls.newaura:SetDisabled(false)
                NewTimerForm.controls.newtemplate:SetDisabled(true)
            end

            return
        end

        local opts

        if class == "TEMPLATES" then
            local templateName = spellID

            local defaultOpts = AptechkaDefaultConfig.templates[templateName]
            opts = defaultOpts and CopyTable(defaultOpts) or {}

            -- class = "TEMPLATES"
            if AptechkaConfigCustom.TEMPLATES and AptechkaConfigCustom.TEMPLATES[templateName] then
                local customOpts = AptechkaConfigCustom.TEMPLATES[templateName]
                -- Merging custom properties on top of default table
                Aptechka.util.MergeTable(opts, customOpts)
            end
        else
            spellID = tonumber(spellID)
            local defaultOpts = AptechkaDefaultConfig[class][category][spellID]
            opts = defaultOpts and CopyTable(defaultOpts) or {}

            if AptechkaConfigCustom[class] and AptechkaConfigCustom[class][category] and AptechkaConfigCustom[class][category][spellID] then
                local customOpts = AptechkaConfigCustom[class][category][spellID]
                -- Merging custom properties on top of default table
                Aptechka.util.MergeTable(opts, customOpts)
            end

            Aptechka.util.UnwrapTemplate(opts)
        end

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
                value = "TEMPLATES",
                text = "Templates",
                icon = "Interface\\Icons\\spell_holy_sealofwisdom",
                children = ns:GenerateCategoryTree("TEMPLATES", "auras"),
            },
            {
                value = "GLOBAL",
                text = "Global",
                icon = "Interface\\Icons\\spell_holy_resurrection",
                children = {
                    {
                        value = "auras",
                        text = "Auras",
                        icon = "Interface\\Icons\\spell_shadow_manaburn",
                        children = ns:GenerateCategoryTree("GLOBAL", "auras")
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
                        children = ns:GenerateCategoryTree(class,"auras")
                    },
                    {
                        value = "traces",
                        text = "Traces",
                        icon = "Interface\\Icons\\spell_nature_astralrecal",
                        children = ns:GenerateCategoryTree(class,"traces")
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
