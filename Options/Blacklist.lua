local addonName, ns = ...

local L = Aptechka.L

local defaultBlacklist = Aptechka.util.auraBlacklist


function Aptechka:DeleteFromBlacklist(spellId)
    local customBlacklist = Aptechka.db.global.customBlacklist

    if defaultBlacklist[spellId] then
        customBlacklist[spellId] = false
    else
        customBlacklist[spellId] = nil
    end

    Aptechka:ForEachFrame(Aptechka.FrameScanAuras)
end

function Aptechka:AddToBlacklist(spellId)
    local customBlacklist = Aptechka.db.global.customBlacklist

    if defaultBlacklist[spellId] then
        customBlacklist[spellId] = nil
    else
        customBlacklist[spellId] = true
    end

    Aptechka:ForEachFrame(Aptechka.FrameScanAuras)
end

function Aptechka:RestoreDeletedFromBlacklist()
    local customBlacklist = Aptechka.db.global.customBlacklist

    local toRemove = {}
    for spellId, enabled in pairs(customBlacklist) do
        if not enabled then
            table.insert(toRemove, spellId)
        end
    end
    for i, spellId in ipairs(toRemove) do
        customBlacklist[spellId] = nil
    end

    Aptechka:ForEachFrame(Aptechka.FrameScanAuras)
end


local function GenListItems()

    local merged = CopyTable(defaultBlacklist)
    Aptechka.util.MergeTable(merged, Aptechka.db.global.customBlacklist)

    local orderedBlacklist = {}
    for spellID, enabled in pairs(merged) do
        local spellName = GetSpellInfo(spellID)
        if spellName and enabled then
            table.insert(orderedBlacklist, spellID)
        -- else
        --     Aptechka:Print("missing spell ID in blacklist:")
        end
    end



    table.sort(orderedBlacklist, function(a,b) return a > b end)

    local orderedList = orderedBlacklist

    -- local orderedList = {}

    -- -- for category, spells in pairs(merged) do
    -- for i, category in ipairs(orderedCategories) do
    --     local spells = merged[category]

    --     -- table.insert(orderedList, { -19, category })
    --     local count = 0
    --     for spellId, opts in pairs(spells) do
    --         -- table.insert(orderedList, opts)
    --         count = count + 1
    --     end
    --     if count == 0 then -- Remove empty headers
    --         table.remove(orderedList)
    --     end
    -- end


    return orderedList;
end

local AptechkaHybridScrollBlacklistMixin = {};

function AptechkaHybridScrollBlacklistMixin:SelectItem(index)
    local form = self.editForm -- header form
    local spell = self.items[index]
    local spellID = spell


    form.opts = {
        spellID = spellID,
    }
    form.controls.spellID:SetText(spellID)
    form.controls.add:SetDisabled(false)
end

function AptechkaHybridScrollBlacklistMixin:RefreshLayout()
    local items = self.items;
    local buttons = HybridScrollFrame_GetButtons(self.ListScrollFrame);
    local offset = HybridScrollFrame_GetOffset(self.ListScrollFrame);
    local customBlacklist = Aptechka.db.global.customBlacklist

    for buttonIndex = 1, #buttons do
        local button = buttons[buttonIndex];
        local itemIndex = buttonIndex + offset;

        -- Usually the check you'd want to apply here is that if itemIndex
        -- is greater than the size of your model contents, you'll hide the
        -- button. Otherwise, update it visually and show it.
        if itemIndex <= #items then
            local item = items[itemIndex];
            button:SetID(itemIndex);

            local icon = button.Icon
            local text = button.Text
            local comment = button.Comment


                button.categoryLeft:Hide();
				button.categoryRight:Hide();
                button.categoryMiddle:Hide();

                local spellId = item
                local spellName, _, tex = GetSpellInfo(spellId)
                button.spellId = spellId
                icon:SetPoint("LEFT", 15, 0)
                icon:SetTexture(tex);
                if customBlacklist[spellId] then
                    spellName = string.format("|cff88ff88%s|r", spellName)
                end
                text:SetText(spellName)
                comment:SetText(spellId)
                text:SetPoint("LEFT", icon, "RIGHT", 8, 0)


            -- One caveat is buttons are only anchored below one another with
            -- one point, so an explicit width is needed on each row or you
            -- need to add the second point manually.
            button:SetWidth(self.ListScrollFrame.scrollChild:GetWidth());
            button:Show();
        else
            button:Hide();
        end
    end

    -- The last step is to ensure the scroll range is updated appropriately.
    -- Calculate the total height of the scrollable region (using the model
    -- size), and the displayed height based on the number of shown buttons.
    local buttonHeight = self.ListScrollFrame.buttonHeight;
    local totalHeight = #items * buttonHeight;
    local shownHeight = #buttons * buttonHeight;

    HybridScrollFrame_Update(self.ListScrollFrame, totalHeight, shownHeight);
end

function ns.CreateBlacklistHeaderButtons()
    local AceGUI = LibStub("AceGUI-3.0")

    local Group = AceGUI:Create("SimpleGroup")
    Group:SetFullWidth(true)
    Group:SetLayout("Flow")
    Group.opts = {}
    Group.controls = {}

    local spellID = AceGUI:Create("EditBox")
    spellID:SetLabel(L"Spell ID")
    -- spellID:SetDisabled(true)
    spellID:DisableButton(true)
    spellID:SetRelativeWidth(0.13)
    spellID:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 and GetSpellInfo(v) then
            self.parent.opts["spellID"] = v
            self.editbox:SetTextColor(1,1,1)
            self.parent.controls.add:SetDisabled(false)
        else
            self.editbox:SetTextColor(1,0,0)
            self.parent.controls.add:SetDisabled(true)
        end
        if value == "" then
            self.parent.opts["spellID"] = nil
            self.parent.controls.add:SetDisabled(true)
        end
    end)
    Group.controls.spellID = spellID
    Group:AddChild(spellID)

    local add = AceGUI:Create("Button")
    add:SetText(L"Add")
    add:SetDisabled(true)
    add:SetRelativeWidth(0.20)
    add:SetCallback("OnClick", function(self, event)
        local opts = self.parent.opts
        local spellId = opts.spellID
        if not spellId then return end
        Aptechka:AddToBlacklist(spellId)
        AptechkaBlacklistHybridScrollFrame:RefreshItems()
        AptechkaBlacklistHybridScrollFrame:RefreshLayout()
    end)
    Group.controls.add = add
    Group:AddChild(add)

    local delete = AceGUI:Create("Button")
    delete:SetText(L"Delete")
    delete:SetRelativeWidth(0.15)
    delete:SetCallback("OnClick", function(self, event)
        local opts = self.parent.opts
        local spellId = opts.spellID
        Aptechka:DeleteFromBlacklist(spellId)
        AptechkaBlacklistHybridScrollFrame:RefreshItems()
        AptechkaBlacklistHybridScrollFrame:RefreshLayout()
    end)
    Group.controls.delete = delete
    Group:AddChild(delete)

    local restore = AceGUI:Create("Button")
    restore:SetText(L"Restore Deleted")
    restore:SetRelativeWidth(0.25)
    restore:SetCallback("OnClick", function(self, event)
        Aptechka:RestoreDeletedFromBlacklist()
        AptechkaBlacklistHybridScrollFrame:RefreshItems()
        AptechkaBlacklistHybridScrollFrame:RefreshLayout()
    end)
    Group.controls.restore = restore
    Group:AddChild(restore)

    return Group
end

local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}
function ns.MakeBlacklist()
    local panel = CreateFrame("Frame", nil, InterfaceOptionsFrame)
    panel.name = L"Blacklist".."|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"
    panel.parent = "Aptechka"
    InterfaceOptions_AddCategory(panel);
    panel:Hide() -- hide initially, otherwise OnShow won't fire on the first activation
    panel:SetScript("OnShow", function(self)
        if not self.isCreated then

            local form = ns.CreateBlacklistHeaderButtons()
            form.frame:SetParent(panel)
            -- form:SetWidth(400)
            -- form:SetHeight(200)
            form:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10)
            form:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", -10, -200)
            form:PerformLayout() -- That's AceGUI Layout

            -- local helpButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            -- helpButton:SetSize(60, 25)
            -- helpButton:SetPoint("TOPRIGHT", 0,0)
            -- helpButton:GetFontString():SetText("Help")
            -- helpButton:SetScript("OnClick", function()
            -- end)

            local f = CreateFrame("Frame", "AptechkaBlacklistHybridScrollFrame", panel, "AptechkaHybridScrollFrameTemplate")
            f.GenListItems = GenListItems
            Mixin(f, AptechkaHybridScrollMixin)
            Mixin(f, AptechkaHybridScrollBlacklistMixin)

            -- f:SetWidth(623)
            f:SetWidth(603)
            f:SetHeight(500)
            -- f:SetPoint("TOPLEFT", panel, "TOPLEFT", 15,-50)
            f:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)

            f.editForm = form

            f.ListScrollFrame.scrollBar.ScrollBarTop:Hide()
            f.ListScrollFrame.scrollBar.ScrollBarBottom:Hide()
            f.ListScrollFrame.scrollBar.ScrollBarMiddle:Hide()

            f:RefreshItems()
            f:Initialize()
            f:CreateButtons()

            local border = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
            border:SetPoint("TOPLEFT", 0, -17)
            border:SetPoint("BOTTOMRIGHT", -1, 0)
            border:SetBackdrop(PaneBackdrop)
            border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
            border:SetBackdropBorderColor(0.4, 0.4, 0.4)

            self.isCreated = true
        end
    end)

    return panel
end
