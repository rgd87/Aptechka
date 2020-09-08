
local addonName, ns = ...

local L = Aptechka.L

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

local AceGUI = LibStub("AceGUI-3.0")

--[==[
function ns.MakeWidgetConfig()
    local opt = {
        type = 'group',
        name = "Aptechka "..L"Widgets",
        order = 1,
        args = {
            msg = {
                name = L[[
Frame element customization is only avaiable through command line

Examples:
|cff888888List all existing customizable widgets:|r
/apt widget list
|cff888888Create your own new widget of specified type:|r
/apt widget create type=Bar name=MyBar
|cff888888Change its global/default settings:|r
/apt widget set name=MyBar point=TOPRIGHT width=5 height=15 x=-10 y=0 vertical=true
|cff888888Change settings only for current profile:|r
/apt widget pset name=MyBar point=TOPRIGHT width=7 height=20
|cff888888List all widget properties:|r
/apt widget info name=MyBar
|cff888888Clear profile-specific settings from current or all profiles:|r
/apt widget pclear name=MyBar all=true
|cff888888Remove widget:|r
/apt widget delete name=MyBar

|cff888888Other types:|r
/apt widget create type=BarArray name=bars2
/apt widget set name=bars2 growth=UP max=6 width=18 height=18 point=TOPLEFT x=0 y=0 vertical=true

/apt widget create type=Icon name=customIcon1
/apt widget set name=customIcon1 width=24 height=24 point=TOPLEFT x=0 y=0 alpha=0.5 textsize=13 edge=true outline=true

/apt widget create type=IconArray name=icons
/apt widget set name=icons growth=DOWN max=3 width=18 height=18 point=TOPLEFT x=0 y=0 alpha=0.5 textsize=13 edge=true outline=true

/apt widget create type=Text name=customText1
/apt widget set name=customText1 textsize=15 point=TOPRIGHT x=0 y=0 font="Arial Narrow" effect=OUTLINE
Text effect possible values: NONE, SHADOW, OUTLINE

/apt widget create type=Indicator name=customSquare1
/apt widget set name=customSquare1 width=8 height=8 point=TOPLEFT x=0 y=0


]],
                type = "description",
                fontSize = "medium",
                width = "full",
                order = 1,
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaWidgetConfig", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaWidgetConfig", L"Widgets"..newFeatureIcon, "Aptechka")

    return panelFrame
end
]==]

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
    frame:SetTitle("Aptechka "..L"Widget Config")
    -- frame:SetLayout("Fill")
    frame:SetLayout("Flow")


    frame.header = {}
    frame.header.Update = UpdateHeader

    frame.SelectForConfig = SelectForConfig

    local new = AceGUI:Create("Button")
    new:SetText(L"New")
    new:SetRelativeWidth(0.14)
    new:SetCallback("OnClick", function(self, event)
        local rootFrame = AptechkaOptions.widgetConfig
        rootFrame.rpane:Clear()
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
        DebuffIcon = "Interface\\Icons\\spell_shadow_curseofsargeras",
        DebuffIconArray = "Interface\\Icons\\spell_shadow_curseofsargeras",
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

