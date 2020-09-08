local addonName, ns = ...

local L = Aptechka.L

local f = CreateFrame('Frame', "AptechkaOptions", InterfaceOptionsFrame)
f.name = "Aptechka"
InterfaceOptions_AddCategory(f);


f.globals = ns.MakeGlobalSettings()
f.profile = ns.MakeProfileSettings()
f.profileSelection = ns.MakeProfileSelection()
f.blacklist = ns.MakeBlacklistHelp()
-- f.widgets = ns.MakeWidgetConfig()
f.elements = ns.MakeElementConfig()
f.highlighting = ns.MakeDebuffHighlight()

ns.frame = ns.CreateWidgetSpellList(L"Spell List", "Aptechka")
f.spellList = ns.frame.frame
InterfaceOptions_AddCategory(f.spellList);

local wconfig = ns.CreateWidgetConfig(L"Widget Config", "Aptechka")
f.widgetConfig = wconfig
InterfaceOptions_AddCategory(f.widgetConfig.frame);

f:Hide()
f:SetScript("OnShow", function(self)
        self:Hide();
        local first = self.profile
        InterfaceOptionsFrame_OpenToCategory (first)
        InterfaceOptionsFrame_OpenToCategory (first)
end)
