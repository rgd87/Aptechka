local addonName, ns = ...

local L = Aptechka.L

local f = CreateFrame('Frame', "AptechkaOptions", InterfaceOptionsFrame)
f.name = "Aptechka"
InterfaceOptions_AddCategory(f);

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

f.globals = ns.MakeGlobalSettings()
f.profile = ns.MakeProfileSettings()
f.profileSelection = ns.MakeProfileSelection()
f.highlighting = ns.MakeDebuffHighlight()

local wconfig = ns.CreateWidgetConfig(L"Widgets"..newFeatureIcon, "Aptechka")
f.widgetConfig = wconfig
InterfaceOptions_AddCategory(f.widgetConfig.frame);

ns.frame = ns.CreateSpellList(L"Spell List", "Aptechka")
f.spellList = ns.frame.frame
InterfaceOptions_AddCategory(f.spellList);

f.status = ns.MakeStatusConfig()
f.blacklist = ns.MakeBlacklist()

f:Hide()
f:SetScript("OnShow", function(self)
        self:Hide();
        local first = self.profile
        InterfaceOptionsFrame_OpenToCategory (first)
        InterfaceOptionsFrame_OpenToCategory (first)
end)
