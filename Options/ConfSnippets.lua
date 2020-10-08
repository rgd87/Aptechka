
local addonName, ns = ...

local L = Aptechka.L

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

local AceGUI = LibStub("AceGUI-3.0")

local color_scheme = {[0] = "|r"}
color_scheme[IndentationLib.tokens.TOKEN_SPECIAL] = "|c00c999c0"
color_scheme[IndentationLib.tokens.TOKEN_KEYWORD] = "|c007d70b4"
color_scheme[IndentationLib.tokens.TOKEN_COMMENT_SHORT] = "|c0065614E"
color_scheme[IndentationLib.tokens.TOKEN_COMMENT_LONG] = "|c0065614E"
color_scheme[IndentationLib.tokens.TOKEN_NUMBER] = "|c00af8af2"
color_scheme[IndentationLib.tokens.TOKEN_STRING] = "|c00bf7e52"

local initialized = false
local function CreateSnippetsWindow()
    local window = AceGUI:Create("Window")
    window:SetWidth(800)
    window:SetHeight(500)
    window:SetLayout("Flow")

    local editor = AceGUI:Create("MultiLineEditBox")
    window:SetLayout("Fill")
    -- editor:SetWidth(400)
    editor.label:Hide()
    editor.button:Hide()
    -- local fontPath = SharedMedia:Fetch("font", "Fira Mono Medium")
    -- if (fontPath) then
        -- editor.editBox:SetFont(fontPath, 12)
    -- end
    editor.editBox:SetFont("Interface\\AddOns\\InconsolataSemiExpanded-Medium.ttf", 12)
    window:AddChild(editor)

    if IndentationLib then
        IndentationLib.enable(editor.editBox, color_scheme, 4)
    end
end

function Aptechka:OpenSnippets()
    if not initialized then
        CreateSnippetsWindow()
    end

end


--[[
local widgetTypes = {}
for wtype in pairs(Aptechka.Widget) do
    if wtype ~= "DebuffIcon" and wtype ~= "DebuffIconArray" then
        widgetTypes[wtype] = wtype
    end
end

local function CreateNewWidgetForm()
    local form = AceGUI:Create("ScrollFrame")
    form:SetFullWidth(true)
    form:SetLayout("Flow")

    form.controls = {}
    form.opts = {
        widgetType = "Indicator",
        name = "MyIndicator"
    }

    local widgetType = AceGUI:Create("Dropdown")
    widgetType:SetLabel(L"Widget Type")
    widgetType:SetList(widgetTypes)
    widgetType:SetValue(form.opts.widgetType)
    widgetType:SetRelativeWidth(0.34)
    widgetType:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["widgetType"] = value
    end)
    form.controls.widgetType = widgetType
    form:AddChild(widgetType)


    local name = AceGUI:Create("EditBox")
    name:SetLabel(L"Name")
    name:DisableButton(true)
    name:SetText(form.opts.name)
    name:SetRelativeWidth(0.60)
    name:SetCallback("OnTextChanged", function(self, event, value)
        self.parent.opts["name"] = value
    end)
    form.controls.name = name
    form:AddChild(name)

    local create = AceGUI:Create("Button")
    create:SetText(L"Create")
    create:SetRelativeWidth(0.2)
    create:SetCallback("OnClick", function(self, event)
        local wtype = self.parent.opts.widgetType
        local wname = self.parent.opts.name
        Aptechka:CreateNewWidget(wtype, wname)
        local rootFrame = AptechkaOptions.widgetConfig
        rootFrame.tree:UpdateWidgetTree()
        rootFrame.tree:SetSelected(wname)
        rootFrame:SelectForConfig(wname)
    end)
    form:AddChild(create)
    form.controls.create = create

    return form
end


local CURRENT_FORM
local formCache = {}

local function UpdateHeader(header)
    if not CURRENT_FORM then
        header.delete:SetDisabled(true)
        header.profileClear:SetDisabled(true)
        header.profileCheckbox:SetDisabled(true)
        header.reset:SetDisabled(true)
        return
    end
    header.profileCheckbox:SetDisabled(false)
    local name = CURRENT_FORM.widgetName
    local popts, gopts = Aptechka:GetWidgetsOptions(name)
    local isProtected = AptechkaDefaultConfig.DefaultWidgets[name]
    header.delete:SetDisabled(isProtected)
    header.reset:SetDisabled(not isProtected)

    local hasProfileSettings = popts ~= nil -- and next(popts)
    header.profileClear:SetDisabled(not hasProfileSettings)
    header.profileCheckbox:SetValue(hasProfileSettings)
end

local function SelectForConfig(frame, name)
    local gwidgets = Aptechka.db.global.widgetConfig
    local gwidget = gwidgets[name]
    if gwidget then

        local wtype = gwidget.type

        frame.rpane:Clear()
        local form = formCache[wtype]

        -- Pick a Create & Fill functions corresponding to widget type
        local widgetFormFunctions = ns.WidgetForms[wtype]
        if not form then
            if not widgetFormFunctions then return end
            form = widgetFormFunctions.Create()
            formCache[wtype] = form
        end

        -- Setting initial profile-specific flag
        local hasProfileSettings = Aptechka.db.profile.widgetConfig and Aptechka.db.profile.widgetConfig[name]
        frame.header.profileCheckbox:SetValue(hasProfileSettings)

        local isProfile = hasProfileSettings
        form.Fill = widgetFormFunctions.Fill
        form:SetTargetWidget(name, isProfile)
        frame.rpane:AddChild(form)
        CURRENT_FORM = form
        frame.header:Update()
    end
end


function ns.CreateWidgetConfig(name, parent)

    local frame = AceGUI:Create("BlizOptionsGroup")
    frame:SetName(name, parent)
    frame:SetTitle("Aptechka "..L"Widgets")
    -- frame:SetLayout("Fill")
    frame:SetLayout("Flow")

    local helpButton = CreateFrame("Button", nil, frame.frame, "UIPanelButtonTemplate")
    helpButton:SetSize(60, 25)
    helpButton:SetPoint("TOPRIGHT", 0,0)
    helpButton:GetFontString():SetText("Help")
    helpButton:SetScript("OnClick", function()
        print("text1 - name text")
        print("text2 - missing health text")
        print("text3 - used to display group leader and timers")
        print("debuffIcons - special widget for debuffs and only that")
        print("roleIcon - assigned role icon")
        print("icon - big center icon")
        print("buffIcons - survival cooldowns row")
        print("statusIcon - used to display Res, RC, Phase icons")
    end)


    frame.header = {}
    frame.header.Update = UpdateHeader

    frame.SelectForConfig = SelectForConfig

    local new = AceGUI:Create("Button")
    new:SetText(L"New")
    new:SetRelativeWidth(0.14)
    new:SetCallback("OnClick", function(self, event)
        local rootFrame = AptechkaOptions.widgetConfig
        rootFrame.rpane:Clear()
        rootFrame.header:Update()
        if not formCache["_NewWidgetForm"] then
            formCache["_NewWidgetForm"] = CreateNewWidgetForm()
        end
        local form = formCache["_NewWidgetForm"]

        rootFrame.rpane:AddChild(form)
    end)
    frame:AddChild(new)
    frame.header.new = new

    local delete = AceGUI:Create("Button")
    delete:SetText(L"Delete")
    delete:SetDisabled(true)
    delete:SetRelativeWidth(0.15)
    delete:SetCallback("OnClick", function(self, event)
        local name = CURRENT_FORM.widgetName
        if not name then return end
        Aptechka:RemoveWidget(name)
        local rootFrame = AptechkaOptions.widgetConfig
        rootFrame.tree:UpdateWidgetTree()
        rootFrame.rpane:Clear()
        rootFrame.header:Update()
    end)
    frame:AddChild(delete)
    frame.header.delete = delete

    local profileCheckbox = AceGUI:Create("CheckBox")
    -- profileCheckbox:SetLabel(L"Profile-specific")
    profileCheckbox.Update = function(self)
        self:SetLabel(string.format("%s : %s", L"Profile-specific", Aptechka.db:GetCurrentProfile()))
    end
    profileCheckbox:Update()
    profileCheckbox:SetRelativeWidth(0.37)
    profileCheckbox:SetCallback("OnValueChanged", function(self, event, value)
        CURRENT_FORM:SetTargetWidget(CURRENT_FORM.widgetName, value)
    end)
    frame.header.profileCheckbox = profileCheckbox
    frame:AddChild(profileCheckbox)

    local profileClear = AceGUI:Create("Button")
    profileClear:SetText(L"Profile Clear")
    profileClear:SetDisabled(true)
    profileClear:SetRelativeWidth(0.2)
    profileClear:SetCallback("OnClick", function(self, event)
        local name = CURRENT_FORM.widgetName
        if not name then return end
        Aptechka:ClearWidgetProfileSettings(name)
        CURRENT_FORM:SetTargetWidget(name, false)
        frame.header:Update()
        frame.tree:UpdateWidgetTree()
        Aptechka:ReconfigureWidget(name)
    end)
    frame:AddChild(profileClear)
    frame.header.profileClear = profileClear

    local reset = AceGUI:Create("Button")
    reset:SetText(L"Reset")
    reset:SetDisabled(true)
    reset:SetRelativeWidth(0.13)
    reset:SetCallback("OnClick", function(self, event)
        local name = CURRENT_FORM.widgetName
        if not name then return end
        Aptechka:ResetWidget(name)
        CURRENT_FORM:SetTargetWidget(name, false)
        frame.header:Update()
        frame.tree:UpdateWidgetTree()
        Aptechka:ReconfigureWidget(name)
    end)
    frame:AddChild(reset)
    frame.header.reset = reset




    local treegroup = AceGUI:Create("TreeGroup") -- "InlineGroup" is also good
    treegroup:SetFullHeight(true)
    treegroup:SetFullWidth(true)
    treegroup:EnableButtonTooltips(false)
    treegroup:SetCallback("OnGroupSelected", function(self, event, path)
        local name = path

        frame:SelectForConfig(name)
    end)

    frame.rpane = treegroup
    frame.tree = treegroup

    local IconsByType = {
        Icon = "Interface\\Icons\\spell_nature_moonglow",
        IconArray = "Interface\\Icons\\spell_nature_moonglow",
        ProgressIcon = "Interface\\Icons\\spell_shadow_requiem",
        Bar = "Interface\\Icons\\spell_nature_lightningshield",
        BarArray = "Interface\\Icons\\spell_nature_lightningshield",
        Text = "Interface\\Icons\\spell_holy_sealofwisdom",
        StaticText = "Interface\\Icons\\spell_magic_magearmor",
        Indicator = "Interface\\Icons\\spell_frost_windwalkon",
        IndicatorArray = "Interface\\Icons\\spell_frost_windwalkon",
        DebuffIcon = "Interface\\Icons\\spell_shadow_curseofsargeras",
        DebuffIconArray = "Interface\\Icons\\spell_shadow_curseofsargeras",
        Texture = "Interface\\Icons\\spell_shadow_ritualofsacrifice",
    }

    treegroup.UpdateWidgetTree = function(self)
        local gconfig = Aptechka.db.global.widgetConfig

        local t = {}
        for name, opts in pairs(gconfig) do
            local defaultWidgets = AptechkaDefaultConfig.DefaultWidgets

            local popts = Aptechka.db.profile.widgetConfig and Aptechka.db.profile.widgetConfig[name]
            local hasProfileSettings = popts and next(popts)

            local displayName = hasProfileSettings and name.."|cffaaffaa*|r" or name
            displayName = defaultWidgets[name] and string.format("|cffdddddd%s|r", displayName) or string.format("|cffaaffaa%s|r", displayName)
            displayName = displayName..string.format(" |cff888888[%s]|r", opts.type)
            local icon = IconsByType[opts.type] or "Interface\\Icons\\spell_holy_resurrection"
            table.insert(t,
            {
                value = name,
                text = displayName,
                icon = icon,
            })
        end

        self:SetTree(t)
        return t
    end

    local t = treegroup:UpdateWidgetTree()
    frame:SetCallback("OnShow", function(self)
        self.tree:UpdateWidgetTree()
        self.header.profileCheckbox:Update()
        self.header:Update()
        if CURRENT_FORM then
            local oldFormWidgetName = CURRENT_FORM.widgetName
            if oldFormWidgetName then
                self:SelectForConfig(oldFormWidgetName)
            end
        end
    end)

    frame:AddChild(treegroup)


    frame.rpane.Clear = function(self)
        for i, child in ipairs(self.children) do
            child:SetParent(UIParent)
            child.isProfile = nil
            child.frame:Hide()
        end
        table.wipe(self.children)
        CURRENT_FORM = nil
    end

    -- Frame.tree:SelectByPath("debuffIcons")

    return frame
end

]]