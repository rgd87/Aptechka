
local addonName, ns = ...

local L = Aptechka.L

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

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
