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
            opts = { assignto = "spell1", showDuration = true, isMine = true, type = "HELPFUL", }
        elseif category == "traces" then
            opts = { assignto = "spell1", fade = 0.7, type = "SPELL_HEAL" }
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
            if delta.clones then Aptechka.RemoveDefaultsPreserve(delta.clones, default_opts.clones) end
            Aptechka.RemoveDefaults(delta, default_opts)
            AptechkaConfigMerged[category][spellID] = CopyTable(default_opts)
            -- if delta.disabled then
                -- AptechkaConfigMerged[category][spellID] = nil
            -- else
            Aptechka.MergeTable(AptechkaConfigMerged[category][spellID], delta, true)
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
    local slotList = Aptechka.widget_list
    assignto:SetList(slotList)
    assignto:SetRelativeWidth(0.30)
    assignto:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["assignto"] = value
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
    foreigncolor:SetLabel("Other's Color")
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

    local showDuration = AceGUI:Create("CheckBox")
    showDuration:SetLabel("Show Duration")
    showDuration:SetRelativeWidth(0.4)
    showDuration:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["showDuration"] = value
    end)
    Form.controls.showDuration = showDuration
    Form:AddChild(showDuration)



    local isMine = AceGUI:Create("CheckBox")
    isMine:SetLabel("Casted by Player")
    isMine:SetRelativeWidth(0.3)
    isMine:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["isMine"] = value
    end)
    Form.controls.isMine = isMine
    Form:AddChild(isMine)


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

    local widgetName = opts.assignto
    if type(widgetName) == "table" then
        widgetName = widgetName[1]
    end
    controls.assignto:SetValue(widgetName)
    controls.name:SetText(opts.name or "")
    controls.priority:SetText(opts.priority)
    controls.extend_below:SetText(opts.extend_below)
    controls.isMine:SetValue(opts.isMine)
    controls.isMissing:SetValue(opts.isMissing)
    controls.showDuration:SetValue(opts.showDuration)
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
        controls.isMine:SetDisabled(false)
        controls.extend_below:SetDisabled(false)
        controls.refreshTime:SetDisabled(false)
        controls.isMissing:SetDisabled(false)
    else
        controls.name:SetDisabled(true)
        controls.showDuration:SetDisabled(true)
        controls.isMine:SetDisabled(true)
        controls.extend_below:SetDisabled(true)
        controls.refreshTime:SetDisabled(true)
        controls.isMissing:SetDisabled(true)
    end

end



function ns.Create(self, name, parent )
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
    Frame:SetTitle("Aptechka Spell List")
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
        Aptechka.SetupDefaults(opts, AptechkaDefaultConfig[category][spellID])

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

function ns.MakeProfileSettings()
    local opt = {
        type = 'group',
        name = L"Aptechka Profile Settings",
        order = 1,
        args = {
            anchors = {
                type = "group",
                name = L"Anchors",
                guiInline = true,
                order = 2,
                args = {
                    unlock = {
                        name = L"Unlock",
                        type = "execute",
                        -- width = "half",
                        desc = "Unlock anchor for dragging",
                        func = function() Aptechka.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = L"Lock",
                        type = "execute",
                        -- width = "half",
                        desc = "Lock anchor",
                        func = function() Aptechka.Commands.lock() end,
                        order = 2,
                    },
                    reset = {
                        name = L"Reset",
                        type = "execute",
                        desc = "Reset anchor",
                        func = function() Aptechka.Commands.reset() end,
                        order = 3,
                    },
                },
            },
            currentProfile = {
                type = 'group',
                order = 2.1,
                name = L"Current Profile",
                guiInline = true,
                args = {
                    curProfile = {
                        name = "",
                        type = 'select',
                        width = 1.5,
                        order = 1,
                        values = function()
                            return ns.GetProfileList(Aptechka.db)
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
                    newProfileName = {
                        name = L"New Profile Name",
                        type = 'input',
                        order = 5,
                        width = 2,
                        get = function(info) return ns.newProfileName end,
                        set = function(info, v)
                            ns.newProfileName = v
                        end,
                    },
                    createButton = {
                        name = L"Create New Profile",
                        type = 'execute',
                        order = 6,
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
            switches = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3,
                args = {
                    showSolo = {
                        name = L"Show Solo",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showSolo end,
                        set = function(info, v)
                            Aptechka.db.profile.showSolo = not Aptechka.db.profile.showSolo
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 8,
                    },
                    showParty = {
                        name = L"Show In Party",
                        type = "toggle",
                        width = "double",
                        get = function(info) return Aptechka.db.profile.showParty end,
                        set = function(info, v)
                            Aptechka.db.profile.showParty = not Aptechka.db.profile.showParty
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 8.1,
                    },
                    petGroup = {
                        name = L"Enable Pet Group",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.petGroup end,
                        set = function(info, v)
                            Aptechka.db.profile.petGroup = not Aptechka.db.profile.petGroup
                            Aptechka:UpdatePetGroupConfig()
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 15.7,
                    },
                    showAggro = {
                        name = L"Show Aggro",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showAggro end,
                        set = function(info, v)
                            Aptechka.db.profile.showAggro = not Aptechka.db.profile.showAggro
                            Aptechka:UpdateAggroConfig()
                        end,
                        order = 10.9,
                    },
                    showRaidIcons = {
                        name = L"Show Raid Icons",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showRaidIcons end,
                        set = function(info, v)
                            Aptechka.db.profile.showRaidIcons = not Aptechka.db.profile.showRaidIcons
                            Aptechka:UpdateRaidIconsConfig()
                        end,
                        order = 11.1,
                    },
                    showDispels = {
                        name = L"Dispel Indicator",
                        type = "toggle",
                        order = 11.3,
                        get = function(info) return Aptechka.db.profile.showDispels end,
                        set = function(info, v)
                            Aptechka.db.profile.showDispels = not Aptechka.db.profile.showDispels
                            Aptechka:UpdateDebuffScanningMethod()
                        end
                    },
                    showCasts = {
                        name = L"Show Casts",
                        disabled = isClassic,
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.showCasts end,
                        set = function(info, v)
                            Aptechka.db.profile.showCasts = not Aptechka.db.profile.showCasts
                            Aptechka:UpdateCastsConfig()
                        end,
                        order = 12,
                    },
                }
            },

            sizeSettings = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 4,
                args = {
                    width = {
                        name = L"Width",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.width end,
                        set = function(info, v)
                            Aptechka.db.profile.width = v
                            Aptechka:Reconfigure()
                        end,
                        min = 10,
                        max = 100,
                        step = 1,
                        order = 1,
                    },
                    height = {
                        name = L"Height",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.height end,
                        set = function(info, v)
                            Aptechka.db.profile.height = v
                            Aptechka:Reconfigure()
                        end,
                        min = 10,
                        max = 100,
                        step = 1,
                        order = 2,
                    },
                    scale = {
                        name = L"Scale",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.scale end,
                        set = function(info, v)
                            Aptechka.db.profile.scale = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 0.5,
                        max = 3,
                        step = 0.01,
                        order = 3,
                    },
                    groupGrowth = {
                        name = L"Group Growth Direction",
                        type = 'select',
                        order = 4,
                        values = {
                            LEFT = L"Left",
                            RIGHT = L"Right",
                            TOP = L"Up",
                            BOTTOM = L"Down",
                        },
                        get = function(info) return Aptechka.db.profile.groupGrowth end,
                        set = function( info, v )
                            Aptechka.db.profile.groupGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                    groupGap = {
                        name = L"Group Gap",
                        type = "range",
                        width = "double",
                        get = function(info) return Aptechka.db.profile.groupGap end,
                        set = function(info, v)
                            Aptechka.db.profile.groupGap = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 3,
                        max = 20,
                        step = 1,
                        order = 5,
                    },
                    unitGrowth = {
                        name = L"Unit Growth Direction",
                        type = 'select',
                        order = 6,
                        values = {
                            LEFT = L"Left",
                            RIGHT = L"Right",
                            TOP = L"Up",
                            BOTTOM = L"Down",
                        },
                        get = function(info) return Aptechka.db.profile.unitGrowth end,
                        set = function( info, v )
                            Aptechka.db.profile.unitGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                    unitGap = {
                        name = L"Unit Gap",
                        type = "range",
                        width = "double",
                        get = function(info) return Aptechka.db.profile.unitGap end,
                        set = function(info, v)
                            Aptechka.db.profile.unitGap = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 3,
                        max = 20,
                        step = 1,
                        order = 7,
                    },
                    groupsInARow = {
                        name = L"Groups in a Row"..newFeatureIcon,
                        desc = L"Allows 10x4 layouts",
                        type = "range",
                        width = "full",
                        get = function(info) return Aptechka.db.profile.groupsInRow end,
                        set = function(info, v)
                            Aptechka.db.profile.groupsInRow = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 1,
                        max = 2,
                        step = 1,
                        order = 8,
                    },


                    orientation = {
                        name = L"Health Orientation",
                        type = 'select',
                        order = 12,
                        values = {
                            ["HORIZONTAL"] = L"Horizontal",
                            ["VERTICAL"] = L"Vertical",
                        },
                        -- values = MakeValuesForKeys(Aptechka.FrameTextures),
                        get = function(info) return Aptechka.db.profile.healthOrientation end,
                        set = function( info, v )
                            Aptechka.db.profile.healthOrientation = v
                            Aptechka:ReconfigureUnprotected()
                        end,
                    },

                    healthTexture = {
                        type = "select",
                        name = L"Health Texture",
                        order = 13,
                        desc = L"Set the statusbar texture.",
                        get = function(info) return Aptechka.db.profile.healthTexture end,
                        set = function(info, value)
                            Aptechka.db.profile.healthTexture = value
                            Aptechka:ReconfigureUnprotected()
                        end,
                        values = LSM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                    },

                    powerTexture = {
                        type = "select",
                        name = L"Power Texture",
                        order = 14,
                        desc = L"Set the statusbar texture.",
                        get = function(info) return Aptechka.db.profile.powerTexture end,
                        set = function(info, value)
                            Aptechka.db.profile.powerTexture = value
                            Aptechka:ReconfigureUnprotected()
                        end,
                        values = LSM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                    },
                    nameFont = {
                        type = "select",
                        name = L"Name Font",
                        order = 14.1,
                        get = function(info) return Aptechka.db.profile.nameFontName end,
                        set = function(info, value)
                            Aptechka.db.profile.nameFontName = value
                            Aptechka:ReconfigureUnprotected()
                        end,
                        values = LSM:HashTable("font"),
                        dialogControl = "LSM30_Font",
                    },
                    nameFontSize = {
                        name = L"Name Font Size",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.nameFontSize end,
                        set = function(info, v)
                            Aptechka.db.profile.nameFontSize = v
                            Aptechka:ReconfigureUnprotected()
                        end,
                        min = 3,
                        max = 30,
                        step = 0.5,
                        order = 14.2,
                    },
                    nameFontOutline = {
                        name = L"Name Outline",
                        type = 'select',
                        order = 14.25,
                        values = {
                            NONE = L"None",
                            SHADOW = L"Shadow",
                            OUTLINE = L"Outline",
                        },
                        get = function(info) return Aptechka.db.profile.nameFontOutline end,
                        set = function( info, v )
                            Aptechka.db.profile.nameFontOutline = v
                            Aptechka:ReconfigureUnprotected()
                        end,
                    },
                    nameLength = {
                        name = L"Name Length",
                        type = "range",
                        get = function(info) return Aptechka.db.profile.cropNamesLen end,
                        set = function(info, v)
                            Aptechka.db.profile.cropNamesLen = v
                            Aptechka:ReconfigureUnprotected()
                        end,
                        min = 2,
                        max = 25,
                        step = 1,
                        order = 14.5,
                    },

                    showMissingFG = {
                        name = L"Show Missing Health/Power as Foreground",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.profile.fgShowMissing end,
                        set = function(info, v)
                            Aptechka.db.profile.fgShowMissing = not Aptechka.db.profile.fgShowMissing
                            Aptechka:ReconfigureUnprotected()
                            Aptechka:RefreshAllUnitsHealth()
                        end,
                        order = 15,
                    },
                    mulGroup = {
                        type = "group",
                        name = L"Color Multipliers",
                        order = 16,
                        args = {
                            fgColor = {
                                name = L"Foreground",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.fgColorMultiplier end,
                                set = function(info, v)
                                    if v > Aptechka.db.profile.bgColorMultiplier then
                                        Aptechka.db.profile.fgColorMultiplier = v
                                        Aptechka:RefreshAllUnitsColors()
                                    else
                                        Aptechka.db.profile.fgColorMultiplier = Aptechka.db.profile.bgColorMultiplier
                                    end
                                end,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                order = 1,
                            },
                            bgColor = {
                                name = L"Background",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.bgColorMultiplier end,
                                set = function(info, v)
                                    if v < Aptechka.db.profile.fgColorMultiplier then
                                        Aptechka.db.profile.bgColorMultiplier = v
                                        Aptechka:RefreshAllUnitsColors()
                                    else
                                        Aptechka.db.profile.bgColorMultiplier = Aptechka.db.profile.fgColorMultiplier
                                    end
                                end,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                order = 2,
                            },
                            nameColor = {
                                name = L"Name",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.nameColorMultiplier end,
                                set = function(info, v)
                                    Aptechka.db.profile.nameColorMultiplier = v
                                    Aptechka:RefreshAllUnitsColors()
                                end,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                order = 3,
                            },
                        }
                    },

                    debuffGroup = {
                        type = "group",
                        name = L"Debuffs",
                        order = 17,
                        args = {

                            debuffSize = {
                                name = L"Debuff Size",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.debuffSize end,
                                set = function(info, v)
                                    Aptechka.db.profile.debuffSize = v
                                    Aptechka:ReconfigureUnprotected()
                                end,
                                min = 5,
                                max = 30,
                                step = 0.1,
                                order = 1,
                            },
                            stackFont = {
                                type = "select",
                                name = L"Font",
                                order = 2,
                                get = function(info) return Aptechka.db.profile.stackFontName end,
                                set = function(info, value)
                                    Aptechka.db.profile.stackFontName = value
                                    Aptechka:ReconfigureUnprotected()
                                end,
                                values = LSM:HashTable("font"),
                                dialogControl = "LSM30_Font",
                            },
                            stackFontSize = {
                                name = L"Stack Font Size",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.stackFontSize end,
                                set = function(info, v)
                                    Aptechka.db.profile.stackFontSize = v
                                    Aptechka:ReconfigureUnprotected()
                                end,
                                min = 3,
                                max = 30,
                                step = 0.1,
                                order = 3,
                            },
                            debuffLimit = {
                                name = L"Debuff Limit",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.debuffLimit end,
                                set = function(info, v)
                                    Aptechka.db.profile.debuffLimit = v
                                    Aptechka:UpdateUnprotectedUpvalues()
                                end,
                                min = 1,
                                max = 4.9,
                                step = 0.1,
                                order = 4,
                            },
                            debuffBossScale = {
                                name = L"Boss Aura Scale",
                                type = "range",
                                get = function(info) return Aptechka.db.profile.debuffBossScale end,
                                set = function(info, v)
                                    Aptechka.db.profile.debuffBossScale = v
                                end,
                                min = 1,
                                max = 1.8,
                                step = 0.01,
                                order = 5,
                            },
                            debuffTest = {
                                name = L"Test Debuffs",
                                type = "execute",
                                func = function() Aptechka.TestDebuffSlots() end,
                                order = 10,
                            },
                        }
                    },
                },
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaProfileSettings", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaProfileSettings", "Profile Settings", "Aptechka")

    return panelFrame
end

local function MakeBlacklistHelp()
    local opt = {
        type = 'group',
        name = "Debuff Blacklist",
        order = 1,
        args = {
            msg = {
                name = [[
Blacklist is only accesible with console commands:

/apt blacklist show
/apt blacklist add <spellID>
/apt blacklist del <spellID>
]],
                type = "description",
                fontSize = "medium",
                width = "full",
                order = 1,
            },
        },
    }
    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaHelp", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaHelp", "Blacklist", "Aptechka")

    return panelFrame
end




do
    local f = CreateFrame('Frame', "AptechkaOptions", InterfaceOptionsFrame)
    f.name = "Aptechka"
    InterfaceOptions_AddCategory(f);


    f.globals = ns.MakeGlobalSettings()
    f.profile = ns.MakeProfileSettings()
    f.profileSelection = ns.MakeProfileSelection()
    f.blacklist = MakeBlacklistHelp()
    f.blacklist = ns.MakeDebuffHighlight()

    ns.frame = ns:Create("Spell List", "Aptechka")
    f.spell_list = ns.frame.frame
    InterfaceOptions_AddCategory(f.spell_list);

    f:Hide()
    f:SetScript("OnShow", function(self)
            self:Hide();
            local first = self.profile
            InterfaceOptionsFrame_OpenToCategory (first)
            InterfaceOptionsFrame_OpenToCategory (first)
    end)
end
