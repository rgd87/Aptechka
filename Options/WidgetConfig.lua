
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
Currently custom frame elements can be only created from command line.

Some examples:

/apt widget create type=Bar name=MyBar
/apt widget list
/apt widget set name=MyBar point=TOPRIGHT width=5 height=15 x=-10 y=0 vertical=true
/apt widget info name=MyBar
/apt widget delete name=MyBar

/apt widget create type=Text name=customText1
/apt widget set name=customText1 textsize=15 point=TOPRIGHT x=0 y=0 justify=RIGHT

/apt widget create type=Indicator name=customSquare1
/apt widget set name=customSquare1 width=8 height=8 point=TOPLEFT x=0 y=0

/apt widget create type=Icon name=customIcon1
/apt widget set name=customIcon1 width=24 height=24 point=TOPLEFT x=0 y=0 alpha=0.5 textsize=13 edge=true outline=true

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
