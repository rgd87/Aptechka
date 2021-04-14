local addonName, ns = ...

local L = Aptechka.L

local f = CreateFrame('Frame', "AptechkaOptions", InterfaceOptionsFrame)
-- f.name = "Aptechka"
-- InterfaceOptions_AddCategory(f);

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

f.globals = ns.MakeGlobalSettings()
f.profile = ns.MakeProfileSettings()
f.profileSelection = ns.MakeProfileSelection()
f.highlighting = ns.MakeDebuffHighlight()

local wconfig = ns.CreateWidgetConfig(L"Widgets"..newFeatureIcon, "Aptechka")
f.widgetConfig = wconfig
f.widgets = f.widgetConfig.frame
InterfaceOptions_AddCategory(f.widgetConfig.frame);

ns.frame = ns.CreateSpellList(L"Spell List", "Aptechka")
f.spellList = ns.frame.frame
InterfaceOptions_AddCategory(f.spellList);

f.statusList = ns.MakeStatusConfig()
f.blacklist = ns.MakeBlacklist()

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
                value = f.globals.optName,
                text = f.globals.name,
            },
            {
                value = f.profile.optName,
                text = f.profile.name,
            },
            {
                value = f.profileSelection.optName,
                text = f.profileSelection.name,
            },
            {
                value = "HIGHLIGHTS",
                text = f.highlighting.name,
            },
            {
                value = "WIDGETCONFIG",
                text = f.widgetConfig.frame.name,
            },
            {
                value = "SPELLLIST",
                text = f.spellList.name,
            },
            {
                value = "BLACKLIST",
                text = f.blacklist.name,
            },
        })

        local CustomPanels = {
            HIGHLIGHTS = f.highlighting,
            BLACKLIST = f.blacklist,
            SPELLLIST = f.spellList,
            WIDGETCONFIG = f.widgetConfig.frame,
        }


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
    window.treegroup:SelectByPath(f.profile.optName)
end