local addonName, ns = ...

local L = Aptechka.L

local defaultDebuffHighlights = AptechkaDefaultConfig.defaultDebuffHighlights

local function IsSpellInList(list, id)
    for cat, spells in pairs(list) do
        for spellId, opts in pairs(spells) do
            if spellId == id then return true, cat, opts end
        end
    end
end

local function IsSpellDataEqual(opts1, opts2)
    for name, value1 in pairs(opts1) do
        local value2 = opts2[name]
        if value1 ~= value2 then return false end
    end
    return true
end

function Aptechka:DeleteHighlightInfo(spellId, noRegen, customOnly)
    local customDebuffHighlights = self.db.global.customDebuffHighlights

    local exists, category
    repeat
        exists, category = IsSpellInList(customDebuffHighlights, spellId)
        if exists then
            customDebuffHighlights[category][spellId] = nil
            if not next(customDebuffHighlights[category]) then
                customDebuffHighlights[category] = nil
            end
        end
    until not exists

    if not customOnly then
        exists, category = IsSpellInList(defaultDebuffHighlights, spellId)
        if exists then
            customDebuffHighlights[category] = customDebuffHighlights[category] or {}
            customDebuffHighlights[category][spellId] = false
        end
    end

    if not noRegen then
        self:UpdateHighlightedDebuffsHashMap()
    end
end

function Aptechka:SaveHighlightInfo(spellId, category, priority, comment)
    self:DeleteHighlightInfo(spellId, true)
    local customDebuffHighlights = self.db.global.customDebuffHighlights

    local defaultExists, defaultCategory, defaultOpts = IsSpellInList(defaultDebuffHighlights, spellId)

    local newOpts = { spellId, priority or 1, comment }

    if defaultExists and IsSpellDataEqual(defaultOpts, newOpts) then
        self:DeleteHighlightInfo(spellId, true, true)
    else
        category = category or "Custom"
        customDebuffHighlights[category] = customDebuffHighlights[category] or {}
        customDebuffHighlights[category][spellId] = newOpts
    end
    self:UpdateHighlightedDebuffsHashMap()
end


local function GenListItems()

    local merged = CopyTable(defaultDebuffHighlights)
    Aptechka.util.MergeTable(merged, Aptechka.db.global.customDebuffHighlights)

    local mapIDs = AptechkaDefaultConfig.MapIDs
    local reverseMapsIDs = {}
    for id,name in pairs(mapIDs) do
        reverseMapsIDs[name] = id
    end

    local orderedCategories = {}
    for name in pairs(merged) do
        table.insert(orderedCategories, name)
    end



    table.sort(orderedCategories, function(a,b)
        local ap = reverseMapsIDs[a] or 9999999
        local bp = reverseMapsIDs[b] or 9999999
        return ap > bp
    end)

    local orderedList = {}

    -- for category, spells in pairs(merged) do
    for i, category in ipairs(orderedCategories) do
        local spells = merged[category]

        -- Adding a header for the category
        table.insert(orderedList, { -19, category })
        local count = 0

        local categorySpellsOrdered = {}
        for spellId, opts in pairs(spells) do
            if opts then
                table.insert(categorySpellsOrdered, opts)
            end
        end
        table.sort(categorySpellsOrdered, function(a,b)
            return (a[3] or "") > (b[3] or "")
        end)

        for _, opts in ipairs(categorySpellsOrdered) do
            -- Adding all its spells
            table.insert(orderedList, opts)
            count = count + 1
        end
        if count == 0 then -- Remove empty header (previously created), if it was empty
            table.remove(orderedList)
        end
    end

    return orderedList;
end

AptechkaHybridScrollMixin = {};

function AptechkaHybridScrollMixin:RefreshItems()
    -- Create the item model that we'll be displaying.
    self.items = self:GenListItems()
end

function AptechkaHybridScrollMixin:Initialize()
    -- Bind the update field on the scrollframe to a function that'll update
    -- the displayed contents. This is called when the frame is scrolled.
    self.ListScrollFrame.update = function() self:RefreshLayout(); end

    -- OPTIONAL: Keep the scrollbar visible even if there's nothing to scroll.
    HybridScrollFrame_SetDoNotHideScrollBar(self.ListScrollFrame, true);
end

function AptechkaHybridScrollMixin:CreateButtons()
    -- Create the buttons for the scrollframe when we initially show. This
    -- can be done OnLoad, but we might as well wait until the UI is in use.
    --
    -- If the frame size ever changes, you'll generally want to re-call this.
    HybridScrollFrame_CreateButtons(self.ListScrollFrame,
        "AptechkaHybridScrollSpellListItemTemplate");
    self:RefreshLayout();
end

function AptechkaHybridScrollMixin:RemoveItem(index)
    table.remove(self.items, index);
    self:RefreshLayout();
end

function AptechkaHybridScrollMixin:SelectItem(index)
    local form = self.editForm
    local spell = self.items[index]
    local spellID, prio, comment = unpack(spell)

    local categoryName
    for i=index,1,-1 do
        local item = self.items[i]
        if item[1] == -19 then
            categoryName = item[2]
            break
        end
    end

    form.opts = {
        spellID = spellID,
        priority = prio,
        comment = comment,
        category = categoryName
    }
    form.controls.spellID:SetText(spellID)
    form.controls.save:SetDisabled(false)
    form.controls.priority:SetText(prio)
    form.controls.comment:SetText(comment)
    form.controls.category:SetText(categoryName)
end

-- function AptechkaHybridScrollMixin.ItemOnEnter(mixin, self)
--     local parent = self:GetParent()
--     local prevMouseoverFrame = parent.mouseoverFrame
--     if prevMouseoverFrame then
--         prevMouseoverFrame.DeleteButton:Hide()
--     end

--     if self.isHeader then
--         parent.mouseoverFrame = nil
--     else
--         self.DeleteButton:Show()
--         parent.mouseoverFrame = self
--     end
-- end

function AptechkaHybridScrollMixin:RefreshLayout()
    local items = self.items;
    local buttons = HybridScrollFrame_GetButtons(self.ListScrollFrame);
    local offset = HybridScrollFrame_GetOffset(self.ListScrollFrame);

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

            local isHeader = item[1] == -19
            if isHeader then
                button.categoryLeft:Show();
				button.categoryRight:Show();
                button.categoryMiddle:Show();

                local name = item[2]
                text:SetText(name)
                icon:SetTexture(nil)
                comment:SetText(nil)
                text:SetPoint("LEFT", button, "LEFT", 8, 0)
            else
                button.categoryLeft:Hide();
				button.categoryRight:Hide();
                button.categoryMiddle:Hide();

                local spellId, prio, commentText = unpack(item)
                local spellName, _, tex = GetSpellInfo(spellId)
                button.spellId = spellId
                icon:SetPoint("LEFT", 15, 0)
                icon:SetTexture(tex);
                text:SetText(spellName)
                comment:SetText(prio.."   "..(commentText or ""))
                text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            end
            button.isHeader = isHeader

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

function ns.CreateSpellDataPanel()
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
            self.parent.controls.save:SetDisabled(false)
        else
            self.editbox:SetTextColor(1,0,0)
            self.parent.controls.save:SetDisabled(true)
        end
        if value == "" then
            self.parent.opts["spellID"] = nil
            self.parent.controls.save:SetDisabled(true)
        end
    end)
    Group.controls.spellID = spellID
    Group:AddChild(spellID)

    local priority = AceGUI:Create("Button")
    priority:SetText("1")
    priority:SetRelativeWidth(0.08)
    priority:SetCallback("OnClick", function(self, event)
        local priority = self.parent.opts["priority"] or 1
        self.parent.opts["priority"] = priority + 1
        if self.parent.opts["priority"] > 4 then
            self.parent.opts["priority"] = 1
        end
        self:SetText(self.parent.opts["priority"])
    end)
    Group.controls.priority = priority
    Group:AddChild(priority)
    ns.WidgetAddTooltip(priority, "1 - Red Corner\n2 - Pink Corner\n3 - Red Border\n4 - Pixel Glow")

    local category = AceGUI:Create("EditBox")
    category:SetLabel(L"Category")
    -- category:SetDisabled(true)
    category:DisableButton(true)
    category:SetRelativeWidth(0.40)
    category:SetCallback("OnTextChanged", function(self, event, text)
        self.parent.opts["category"] = text
        if text == "" then self.parent.opts["category"] = nil end
    end)
    Group.controls.category = category
    Group:AddChild(category)


    local save = AceGUI:Create("Button")
    save:SetText(L"Save")
    save:SetDisabled(true)
    save:SetRelativeWidth(0.20)
    save:SetCallback("OnClick", function(self, event)
        local opts = self.parent.opts
        local spellId = opts.spellID
        if not spellId then return end
        local category = opts.category
        local comment = opts.comment
        local priority = opts.priority
        Aptechka:SaveHighlightInfo(spellId, category, priority, comment)
        AptechkaHighlightHybridScrollFrame:RefreshItems()
        AptechkaHighlightHybridScrollFrame:RefreshLayout()
    end)
    Group.controls.save = save
    Group:AddChild(save)

    local delete = AceGUI:Create("Button")
    delete:SetText(L"Delete")
    delete:SetRelativeWidth(0.15)
    delete:SetCallback("OnClick", function(self, event)
        local opts = self.parent.opts
        local spellId = opts.spellID
        local category = opts.category
        local comment = opts.comment
        local priority = opts.priority
        Aptechka:DeleteHighlightInfo(spellId)
        AptechkaHighlightHybridScrollFrame:RefreshItems()
        AptechkaHighlightHybridScrollFrame:RefreshLayout()
    end)
    Group.controls.delete = delete
    Group:AddChild(delete)



    local comment = AceGUI:Create("EditBox")
    comment:SetLabel(L"Comment")
    -- comment:SetDisabled(true)
    comment:DisableButton(true)
    comment:SetRelativeWidth(0.94)
    comment:SetCallback("OnTextChanged", function(self, event, text)
        self.parent.opts["comment"] = text
        if text == "" then self.parent.opts["comment"] = nil end
    end)
    Group.controls.comment = comment
    Group:AddChild(comment)

    -- local help = AceGUI:Create("Button")
    -- help:SetText("help")
    -- help:SetRelativeWidth(0.08)
    -- help:SetCallback("OnClick", function(self, event)
    --     print(Aptechka.InfoString, "To quickly find out spell IDs from Encounter Journal, use this macro when mo")
    -- end)
    -- Group.controls.help = help
    -- Group:AddChild(help)

    return Group
end

local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}
function ns.MakeDebuffHighlight()
    local panel = CreateFrame("Frame", nil, InterfaceOptionsFrame)
    panel.name = L"Debuff Highlighting"
    panel.parent = "Aptechka"
    InterfaceOptions_AddCategory(panel);
    panel:Hide() -- hide initially, otherwise OnShow won't fire on the first activation
    panel:SetScript("OnShow", function(self)
        if not self.isCreated then

            local form = ns.CreateSpellDataPanel()
            form.frame:SetParent(panel)
            -- form:SetWidth(400)
            -- form:SetHeight(200)
            form:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10)
            form:SetWidth(600)
            form:SetHeight(190)
            form.frame:Show()
            form:PerformLayout() -- That's AceGUI Layout

            -- local helpButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            -- helpButton:SetSize(60, 25)
            -- helpButton:SetPoint("TOPRIGHT", 0,0)
            -- helpButton:GetFontString():SetText("Help")
            -- helpButton:SetScript("OnClick", function()
            -- end)

            local f = CreateFrame("Frame", "AptechkaHighlightHybridScrollFrame", panel, "AptechkaHybridScrollFrameTemplate")
            f.GenListItems = GenListItems
            Mixin(f, AptechkaHybridScrollMixin)
            -- f:SetWidth(623)
            f:SetWidth(603)
            f:SetHeight(450)
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
