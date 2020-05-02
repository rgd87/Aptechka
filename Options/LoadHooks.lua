local addonName, ns = ...

local L = Aptechka.L

local f = CreateFrame('Frame', "AptechkaOptions", InterfaceOptionsFrame)
f.name = "Aptechka"
InterfaceOptions_AddCategory(f);


f.globals = ns.MakeGlobalSettings()
f.profile = ns.MakeProfileSettings()
f.profileSelection = ns.MakeProfileSelection()
f.blacklist = ns.MakeBlacklistHelp()
f.highlighting = ns.MakeDebuffHighlight()

ns.frame = ns.CreateWidgetSpellList(L"Spell List", "Aptechka")
f.spell_list = ns.frame.frame
InterfaceOptions_AddCategory(f.spell_list);

f:Hide()
f:SetScript("OnShow", function(self)
        self:Hide();
        local first = self.profile
        InterfaceOptionsFrame_OpenToCategory (first)
        InterfaceOptionsFrame_OpenToCategory (first)
end)
