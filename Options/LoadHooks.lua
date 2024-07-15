local addonName, ns = ...

local L = Aptechka.L

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local f = CreateFrame('Frame', "AptechkaOptions", InterfaceOptionsFrame)
-- f.name = "Aptechka"
-- InterfaceOptions_AddCategory(f);

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

local globalsOptName, globalsName, globalsFrame = ns.MakeGlobalSettings()
-- globalsFrame = AceConfigDialog:AddToBlizOptions(globalsOptName, globalsName, "Aptechka")

local profileOptName, profileName, profileFrame = ns.MakeProfileSettings()
-- profileFrame = AceConfigDialog:AddToBlizOptions(profileOptName, profileName, "Aptechka")

local profileSelOptName, profileSelName, profileSelFrame =  ns.MakeProfileSelection()
-- profileSelFrame = AceConfigDialog:AddToBlizOptions(profileSelOptName, profileSelName, "Aptechka")

local _, highlightingName, highlightingFrame = ns.MakeDebuffHighlight()
highlightingFrame.name = highlightingName
highlightingFrame.parent = "Aptechka"
-- InterfaceOptions_AddCategory(highlightingFrame);

local _, widgetsName, widgetsFrame = ns.CreateWidgetConfig(L"Widgets"..newFeatureIcon, "Aptechka")
widgetsFrame.name = widgetsName
widgetsFrame.parent = "Aptechka"
f.widgetConfig = widgetsFrame.rootFrame
-- InterfaceOptions_AddCategory(f.widgetConfig.frame);

local spellListOptName, spellListName, spellListFrame = ns.CreateSpellList()
spellListFrame.name = spellListName
spellListFrame.parent = "Aptechka"
-- InterfaceOptions_AddCategory(f.spellList);

local statusOptName, statusName, statusFrame = ns.MakeStatusConfig()
-- statusFrame = AceConfigDialog:AddToBlizOptions("AptechkaStatusConfig", L"Status List", "Aptechka")

local blacklistOptName, blacklistName, blacklistFrame = ns.MakeBlacklist()
blacklistFrame.name = blacklistName
blacklistFrame.parent = "Aptechka"
-- InterfaceOptions_AddCategory(blacklistFrame);

f:Hide()
f:SetScript("OnShow", function(self)
    self:Hide();
    local first = self.profile
    InterfaceOptionsFrame_OpenToCategory (first)
    InterfaceOptionsFrame_OpenToCategory (first)
end)


local window

function f.Open()
    if not window then

        local AceGUI = LibStub("AceGUI-3.0")

        window = AceGUI:Create("Window")
        window:SetWidth(840)
        window:SetHeight(750)
        window:SetLayout("Fill")
        window:EnableResize(false)
        window:SetTitle("Aptechka Config")

        local treegroup = AceGUI:Create("TreeGroup")
        treegroup:SetTree({
            {
                value = globalsOptName,
                text = globalsName,
            },
            {
                value = profileOptName,
                text = profileName,
            },
            {
                value = profileSelOptName,
                text = profileSelName,
            },
            {
                value = "HIGHLIGHTS",
                text = highlightingName,
            },
            {
                value = "WIDGETCONFIG",
                text = widgetsName,
            },

            {
                value = statusOptName,
                text = statusName,
            },
            {
                value = "SPELLLIST",
                text = spellListName,
            },
            {
                value = "BLACKLIST",
                text = blacklistName,
            },
        })

        local CustomPanels = {
            HIGHLIGHTS = highlightingFrame,
            BLACKLIST = blacklistFrame,
            SPELLLIST = spellListFrame,
            WIDGETCONFIG = widgetsFrame,
        }

        treegroup.text = "123"
        treegroup:SetCallback("OnGroupSelected", function(self, event, group)

            if self.customPanel then
                self.customPanel:SetParent(nil)
                -- self.customPanel:ClearAllPoints()
                self.customPanel:Hide()
                self.customPanel = nil
            end
            self:ReleaseChildren()

            local customPanel = CustomPanels[group]
            if customPanel then
                self.customPanel = customPanel
                customPanel:SetParent(self.content)
                customPanel:SetAllPoints(self.content)
                customPanel:Show()
            else
                local AceConfigDialog = LibStub("AceConfigDialog-3.0")
                AceConfigDialog:Open(group, self)
            end
        end)

        treegroup:SetFullHeight(true) -- probably?
        treegroup:SetFullWidth(true) -- probably?
        -- treegroup:SelectByPath(f.profile.optName)

        window:AddChild(treegroup)
        window.treegroup = treegroup
    end

    window:Show()
    window.treegroup:SelectByPath(profileOptName)
end