
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

local CURRENT_FORM

local function MakeCheckbox(name, parent)
    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    cb:SetWidth(25)
    cb:SetHeight(25)
    cb:Show()

    local cblabel = cb:CreateFontString(nil, "OVERLAY")
    cblabel:SetFontObject("GameFontHighlight")
    cblabel:SetPoint("LEFT", cb,"RIGHT", 5,0)
    cb.label = cblabel
    return cb
end

local formCache = {
}

function ns.CreateWidgetConfig(name, parent)

    local frame = AceGUI:Create("BlizOptionsGroup")
    frame:SetName(name, parent)
    frame:SetTitle("Aptechka "..L"Widget Config")
    frame:SetLayout("Fill")

    local profileCheckbox = MakeCheckbox("AptWidgetProfileSpecificSwitch", frame.frame)
    profileCheckbox:SetPoint("TOPLEFT", 220, -13)
    profileCheckbox.label:SetText("Profile-specific")
    profileCheckbox:SetScript("OnClick",function(self,button)
        self.value = not self.value
        CURRENT_FORM:SetTargetWidget(CURRENT_FORM.widgetName, self.value)
    end)


    local treegroup = AceGUI:Create("TreeGroup") -- "InlineGroup" is also good
    treegroup:SetFullHeight(true)
    treegroup:SetFullWidth(true)
    treegroup:EnableButtonTooltips(false)
    treegroup:SetCallback("OnGroupSelected", function(self, event, path)
        local name = path

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
            if form.isProfile == nil then
                local hasProfileSettings = Aptechka.db.profile.widgetConfig and Aptechka.db.profile.widgetConfig[name]
                profileCheckbox:SetChecked(hasProfileSettings)
                profileCheckbox.value = hasProfileSettings
            end

            form.profileCheckbox = profileCheckbox
            local isProfile = profileCheckbox:GetChecked()
            form.Fill = widgetFormFunctions.Fill
            form:SetTargetWidget(name, isProfile)
            frame.rpane:AddChild(form)
            CURRENT_FORM = form
        end
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

