AptechkaGUI = CreateFrame("Frame","AptechkaGUI")

local LSM = LibStub("LibSharedMedia-3.0")

-- AptechkaGUI:SetScript("OnEvent", function(self, event, ...)
	-- self[event](self, event, ...)
-- end)
-- AptechkaGUI:RegisterEvent("ADDON_LOADED")

local AceGUI = LibStub("AceGUI-3.0")

function AptechkaGUI.SlashCmd(msg)
    AptechkaGUI.frame:Show()
end

local sortfunc = function(a,b)
	if a.order == b.order then
		return a.value < b.value
	else
		return a.order < b.order
	end
end

local MakeValuesForKeys = function(t)
    local t1 = {}
    for k,v in pairs(t) do
        t1[k] = k
    end
    return t1
end

function AptechkaGUI.GenerateCategoryTree(self, isGlobal, category)
	local _,class = UnitClass("player")
	local custom = isGlobal and AptechkaConfigCustom["GLOBAL"] or AptechkaConfigCustom[class]

	local t = {}
    for spellID, opts in pairs(AptechkaConfigMerged[category]) do
        if not AptechkaConfigMerged.spellClones[spellID] then
            if (isGlobal and opts.global) or (not isGlobal and not opts.global) then
                local name = (GetSpellInfo(spellID) or "<Unknown>") or opts.name
                local custom_opts = custom[category] and custom[category][spellID]
                local status
                local order = 5
                -- print(opts.name, custom_opts)
                if not custom_opts or not next(custom_opts) then
                    status = nil
                elseif custom_opts.disabled then
                    status = "|cffff0000[D] |r"
                    order = 6
                elseif not AptechkaDefaultConfig[category][spellID] then
                    status = "|cff33ff33[A] |r"
                    order = 1
                else
                    status = "|cffffaa00[M] |r"
                    order = 2
                end
                local text = status and status..name or name
                table.insert(t, {
                    value = spellID,
                    text = text,
                    icon = GetSpellTexture(spellID),
                    order = order,
                })
            end
        end
	end
	table.sort(t, sortfunc)
	return t
end


local AuraForm
local CooldownForm
local NewTimerForm


function AptechkaGUI.CreateNewTimerForm(self)
	local Form = AceGUI:Create("InlineGroup")
    Form:SetFullWidth(true)
    -- Form:SetHeight(0)
    Form:SetLayout("Flow")
	Form.opts = {}
    Form.controls = {}

	Form.ShowNewTimer = function(self, category)
		assert(category)
		local Frame = AptechkaGUI.frame
		local class = self.class

		Frame.rpane:Clear()
		if not AuraForm then
			AuraForm = AptechkaGUI:CreateAuraForm()
		end
		local opts
        if category == "auras" then
            opts = { assignto = "spell1", showDuration = true, isMine = true, type = "HELPFUL", }
        elseif category == "traces" then
            opts = { assignto = "spell1", fade = 0.7, type = "SPELL_HEAL" }
        end
		if class == "GLOBAL" then opts.global = true end
		AptechkaGUI:FillForm(AuraForm, class, category, nil, opts, true)
		Frame.rpane:AddChild(AuraForm)
	end

	local newaura = AceGUI:Create("Button")
	newaura:SetText("New Aura")
	newaura:SetFullWidth(true)
	newaura:SetCallback("OnClick", function(self, event)
		self.parent:ShowNewTimer("auras")
	end)
	Form:AddChild(newaura)
    Form.controls.newaura = newaura

	local newtrace = AceGUI:Create("Button")
	newtrace:SetText("New Trace")
	newtrace:SetFullWidth(true)
	newtrace:SetCallback("OnClick", function(self, event)
		self.parent:ShowNewTimer("traces")
	end)
	Form:AddChild(newtrace)
    Form.controls.newtrace = newtrace


	return Form
end

local tooltipOnEnter = function(self, event)
    GameTooltip:SetOwner(self.frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1);
    GameTooltip:Show();
end
local tooltipOnLeave = function(self, event)
    GameTooltip:Hide();
end
local function AddTooltip(widget, tooltipText)
    widget.tooltipText = tooltipText
    widget:SetCallback("OnEnter", tooltipOnEnter)
    widget:SetCallback("OnLeave", tooltipOnLeave)
end

local clean = function(delta, default_opts, property, emptyValue)
    if delta[property] == emptyValue and default_opts[property] == nil then delta[property] = nil end
end

function AptechkaGUI.CreateCommonForm(self)
	local Form = AceGUI:Create("ScrollFrame")
    Form:SetFullWidth(true)
    -- Form:SetHeight(0)
    Form:SetLayout("Flow")
	Form.opts = {}
	Form.controls = {}




	local save = AceGUI:Create("Button")
	save:SetText("Save")
	save:SetRelativeWidth(0.5)
	save:SetCallback("OnClick", function(self, event)
		local p = self.parent
		local class = p.class
		local category = p.category
		local spellID = p.id
		local opts = p.opts

		if not spellID then -- make new timer
			spellID = tonumber(self.parent.controls.spellID:GetText())
			if not spellID or not tonumber(spellID) then
				--invalid spell id string
				return
			end
            if not GetSpellInfo(spellID) then
                return -- spell doesn't exist
            end

			-- if not opts.name then
				-- opts.name = GetSpellInfo(spellID)
			-- end
			opts.spellID = nil
		end

        if not opts.name then
            opts.name = GetSpellInfo(spellID)
            if category == "traces" then
                opts.name = opts.name.."Trace"
            end
        end

        local default_opts = AptechkaDefaultConfig[category][spellID]
        if default_opts then
            -- clean(opts, default_opts, "ghost", false)
            -- clean(opts, default_opts, "singleTarget", false)
            -- clean(opts, default_opts, "multiTarget", false)
            -- clean(opts, default_opts, "scale", 1)
            -- clean(opts, default_opts, "shine", false)
            -- clean(opts, default_opts, "shinerefresh", false)
            -- clean(opts, default_opts, "nameplates", false)
            -- clean(opts, default_opts, "group", "default")
            -- clean(opts, default_opts, "affiliation", COMBATLOG_OBJECT_AFFILIATION_MINE)
            -- clean(opts, default_opts, "fixedlen", false)
            clean(opts, default_opts, "name", false)
            clean(opts, default_opts, "priority", false)
            clean(opts, default_opts, "extend_below", false)
            clean(opts, default_opts, "refreshTime", false)
            -- clean(opts, default_opts, "scale_until", false)
            -- clean(opts, default_opts, "hide_until", false)
            -- clean(opts, default_opts, "maxtimers", false)
            -- clean(opts, default_opts, "color2", false)
            -- clean(opts, default_opts, "arrow", false)
            -- clean(opts, default_opts, "overlay", false)
            -- clean(opts, default_opts, "tick", false)
            -- clean(opts, default_opts, "recast_mark", false)
            -- clean(opts, default_opts, "effect", "NONE")
            -- clean(opts, default_opts, "ghosteffect", "NONE")
            clean(opts, default_opts, "clones", false)
        end

		local delta = CopyTable(opts)
        delta.realID = nil -- important, clears runtime data
        delta.isforeign = nil
        delta.expirationTime = nil
        delta.realID = nil
        delta.duration = nil
        delta.texture = nil
        delta.stacks = nil

        -- remove clones of the previous version of the spell
		local oldOriginalSpell = AptechkaConfigMerged[category][spellID]
		if oldOriginalSpell and oldOriginalSpell.clones then
			for i, additionalSpellID in ipairs(oldOriginalSpell.clones) do
				AptechkaConfigMerged[category][additionalSpellID] = nil
				AptechkaConfigMerged.spellClones[additionalSpellID] = nil
			end
		end
		----------

        if default_opts then
            if delta.clones then Aptechka.RemoveDefaultsPreserve(delta.clones, default_opts.clones) end
            Aptechka.RemoveDefaults(delta, default_opts)
			AptechkaConfigMerged[category][spellID] = CopyTable(default_opts)
            -- if delta.disabled then
                -- AptechkaConfigMerged[category][spellID] = nil
            -- else
            Aptechka.MergeTable(AptechkaConfigMerged[category][spellID], delta, true)
            -- end
		else
			AptechkaConfigMerged[category][spellID] = delta
		end

        -- fill up spell clones of the new version
		local originalSpell = AptechkaConfigMerged[category][spellID]
		if originalSpell.clones then
			for i, additionalSpellID in ipairs(originalSpell.clones) do
				AptechkaConfigMerged[category][additionalSpellID] = originalSpell
				AptechkaConfigMerged.spellClones[additionalSpellID] = true
			end
		end
		----------

		AptechkaConfigCustom[class] = AptechkaConfigCustom[class] or {}
		AptechkaConfigCustom[class][category] = AptechkaConfigCustom[class][category] or {}
		if not next(delta) then delta = nil end
		AptechkaConfigCustom[class][category][spellID] = delta

		AptechkaGUI.frame.tree:UpdateSpellTree()
		AptechkaGUI.frame.tree:SelectByPath(class, category, spellID)
		-- POSTSAVE = delta
	end)
	Form:AddChild(save)

	local delete = AceGUI:Create("Button")
	delete:SetText("Delete")
	save:SetRelativeWidth(0.5)
	delete:SetCallback("OnClick", function(self, event)
		local p = self.parent
		local class = p.class
		local category = p.category
		local spellID = p.id
		-- local opts = p.opts

		AptechkaConfigCustom[class][category][spellID] = nil
		AptechkaConfigMerged[category][spellID] = AptechkaDefaultConfig[category][spellID]

		AptechkaGUI.frame.tree:UpdateSpellTree()
		AptechkaGUI.frame.tree:SelectByPath(class, category, spellID)
	end)
	Form.controls.delete = delete
	Form:AddChild(delete)

	local spellID = AceGUI:Create("EditBox")
	spellID:SetLabel("Spell ID")
	spellID:SetDisabled(true)
    spellID:DisableButton(true)
	spellID:SetRelativeWidth(0.2)
	spellID:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 and GetSpellInfo(v) then
            self.parent.opts["spellID"] = v
            self.editbox:SetTextColor(1,1,1)
        else
            self.editbox:SetTextColor(1,0,0)
        end
        if value == "" then self.parent.opts["spellID"] = nil end
	end)
	-- spellID:SetHeight(32)
	-- spellID.alignoffset = 30
	Form.controls.spellID = spellID
	Form:AddChild(spellID)

    local name = AceGUI:Create("EditBox")
    name:SetLabel("Internal Name")
    name:SetDisabled(false)
    -- name:SetFullWidth(true)
    name:SetRelativeWidth(0.5)
    -- name:SetCallback("OnEnterPressed", function(self, event, value)
        -- self.parent.opts["name"] = value
    -- end)
    name:SetCallback("OnTextChanged", function(self, event, value)
        if value == "" then
            self.parent.opts["name"] = false
            self:SetText("")
        else
            self.parent.opts["name"] = value
        end
    end)
    -- name:SetHeight(32)
    Form.controls.name = name
    Form:AddChild(name)
    AddTooltip(name, "Custom timer label.\nLeave blank to hide.")

	local disabled = AceGUI:Create("CheckBox")
	disabled:SetLabel("Disabled")
	disabled:SetRelativeWidth(0.2)
	disabled:SetCallback("OnValueChanged", function(self, event, value)
        if value == false then value = nil end
		self.parent.opts["disabled"] = value
	end)
	-- disabled.alignoffset = 10
	-- disabled:SetHeight(36)
	Form.controls.disabled = disabled
	Form:AddChild(disabled)


    local prio = AceGUI:Create("EditBox")
    prio:SetLabel("Priority")
    -- prio:SetFullWidth(true)
    prio:SetRelativeWidth(0.15)
    prio:DisableButton(true)
    prio:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v then
            self.parent.opts["priority"] = v
        elseif value == "" then
            self.parent.opts["priority"] = false
            self:SetText("")
        end
    end)
    -- prio:SetHeight(32)
    Form.controls.priority = prio
    Form:AddChild(prio)
    AddTooltip(prio, "Positive or negative numeric value.\nDefault priority is 80.")


    local assignto = AceGUI:Create("Dropdown")
    assignto:SetLabel("Assign to")
    local slotList = Aptechka.widget_list
    assignto:SetList(slotList)
    assignto:SetRelativeWidth(0.30)
    assignto:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["assignto"] = value
    end)
    Form.controls.assignto = assignto
    Form:AddChild(assignto)
    AddTooltip(assignto, "Assign to indicator")

    -- local fixedlen = AceGUI:Create("EditBox")
    -- fixedlen:SetLabel("|cff00ff00Fixed Duration|r")
    -- fixedlen:SetRelativeWidth(0.2)
 --    fixedlen:DisableButton(true)
    -- fixedlen:SetCallback("OnTextChanged", function(self, event, value)
    --  local v = tonumber(value)
    --  if v and v > 0 then
    --      self.parent.opts["fixedlen"] = v
    --  elseif value == "" then
    --      self.parent.opts["fixedlen"] = false
    --      self:SetText("")
    --  end
    -- end)
    -- Form.controls.fixedlen = fixedlen
    -- Form:AddChild(fixedlen)
 --    AddTooltip(fixedlen, "Set static timer max duration to align timer decay speed with other timers")


    local color = AceGUI:Create("ColorPicker")
    color:SetLabel("Color")
    color:SetRelativeWidth(0.20)
    color:SetHasAlpha(false)
    color:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
        self.parent.opts["color"] = {r,g,b}
    end)
    Form.controls.color = color
    Form:AddChild(color)

    local showDuration = AceGUI:Create("CheckBox")
    showDuration:SetLabel("Show Duration")
    showDuration:SetRelativeWidth(0.4)
    showDuration:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["showDuration"] = value
    end)
    Form.controls.showDuration = showDuration
    Form:AddChild(showDuration)

	

    local isMine = AceGUI:Create("CheckBox")
    isMine:SetLabel("Casted by Player")
    isMine:SetRelativeWidth(0.4)
    isMine:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["isMine"] = value
    end)
    Form.controls.isMine = isMine
    Form:AddChild(isMine)

    
    local extend_below = AceGUI:Create("EditBox")
    extend_below:SetLabel("Extend Below")
    extend_below:SetRelativeWidth(0.19)
    extend_below:DisableButton(true)
    extend_below:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 then
            self.parent.opts["extend_below"] = v
        elseif value == "" then
            self.parent.opts["extend_below"] = false
            self:SetText("")
        end
    end)
    Form.controls.extend_below = extend_below
    Form:AddChild(extend_below)
    AddTooltip(extend_below, "Do not refresh duration if it's below X")

    local refreshTime = AceGUI:Create("EditBox")
    refreshTime:SetLabel("Refresh Time")
    refreshTime:SetRelativeWidth(0.19)
    refreshTime:DisableButton(true)
    refreshTime:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 then
            self.parent.opts["refreshTime"] = v
        elseif value == "" then
            self.parent.opts["refreshTime"] = false
            self:SetText("")
        end
    end)
    Form.controls.refreshTime = refreshTime
    Form:AddChild(refreshTime)
    AddTooltip(refreshTime, "Pandemic indication. Only works for bars")

    local clones = AceGUI:Create("EditBox")
	clones:SetLabel("Additional Spell IDs")
	clones:SetRelativeWidth(0.9)
	clones:SetCallback("OnEnterPressed", function(self, event, value)
		local cloneList = {}
		for spellID in string.gmatch(value, "%d+") do
			table.insert(cloneList, tonumber(spellID))
		end
        if next(cloneList) then
            self.parent.opts["clones"] = cloneList
        else
            self.parent.opts["clones"] = false
            self:SetText("")
        end
	end)
	Form.controls.clones = clones
	Form:AddChild(clones)
	AddTooltip(clones, "Spell ID list of clones / spell ranks" )

    -- Frame:AddChild(Form)
    -- Frame.top = Form
	return Form
end

function AptechkaGUI.CreateAuraForm(self)
	local topgroup = AptechkaGUI:CreateCommonForm()

	return topgroup
end

local ReverseLookup = function(self, effect)
    if not effect then return end
    for k,v in pairs(self) do
        if v == effect then
            return k
        end
    end
end
local fillAlpha = function(rgb)
    local r,g,b,a = unpack(rgb)
    a = a or 1
    return r,g,b,a
end

function AptechkaGUI.FillForm(self, Form, class, category, id, opts, isEmptyForm)
	Form.opts = opts
	Form.class = class
	Form.category = category
	Form.id = id
	local controls = Form.controls
	controls.spellID:SetText(id or "")
	controls.spellID:SetDisabled(not isEmptyForm)
	controls.disabled:SetValue(opts.disabled)
	controls.disabled:SetDisabled(isEmptyForm)

    controls.assignto:SetValue(opts.assignto)
	controls.name:SetText(opts.name or "")
	controls.priority:SetText(opts.priority)
    controls.extend_below:SetText(opts.extend_below)
    controls.isMine:SetValue(opts.isMine)
    controls.showDuration:SetValue(opts.showDuration)
    controls.refreshTime:SetText(opts.refreshTime)

    local clonesText
	if opts.clones then
		clonesText = table.concat(opts.clones, ", ")
	end
	controls.clones:SetText(clonesText)

	-- -- controls.group:SetValue(opts.group or "default")
	-- controls.duration:SetText((type(opts.duration) == "function" and "<func>") or opts.duration)
	-- controls.scale:SetValue(opts.scale or 1)
	-- controls.scale_until:SetText(opts.scale_until)
 --    controls.hide_until:SetText(opts.hide_until)
	-- controls.shine:SetValue(opts.shine)
	-- controls.shinerefresh:SetValue(opts.shinerefresh)

	-- if opts.ghost then
	-- 	controls.ghost:SetValue(true)
	-- else
	-- 	controls.ghost:SetValue(false)
	-- end
	-- controls.maxtimers:SetText(opts.maxtimers)
	-- controls.singleTarget:SetValue(opts.singleTarget)
	-- controls.multiTarget:SetValue(opts.multiTarget)

	controls.color:SetColor(fillAlpha(opts.color or {0.8, 0.1, 0.7} ))

	-- controls.color2:SetColor(fillAlpha(opts.color2 or {1,1,1,0} ))
	-- controls.arrow:SetColor(fillAlpha(opts.arrow or {1,1,1,0} ))

	-- controls.affiliation:SetValue(opts.affiliation or COMBATLOG_OBJECT_AFFILIATION_MINE)
	-- controls.nameplates:SetValue(opts.nameplates)

	-- controls.tick:SetText(opts.tick)
	-- controls.recast_mark:SetText(opts.recast_mark)
	-- controls.fixedlen:SetText(opts.fixedlen)

	-- if opts.overlay then
	-- 	controls.overlay_start:SetText(opts.overlay[1])
	-- 	controls.overlay_end:SetText(opts.overlay[2])
	-- 	controls.overlay_haste:SetValue(opts.overlay[4])
	-- else
	-- 	controls.overlay_start:SetText("")
	-- 	controls.overlay_end:SetText("")
	-- 	controls.overlay_haste:SetValue(false)
	-- end

 --    controls.effect:SetValue(opts.effect or "NONE")
 --    controls.ghosteffect:SetValue(opts.ghosteffect or "NONE")

	if id and not AptechkaDefaultConfig[category][id] then
		controls.delete:SetDisabled(false)
		controls.delete:SetText("Delete")
	elseif AptechkaConfigCustom[class] and  AptechkaConfigCustom[class][category] and AptechkaConfigCustom[class][category][id] then
		controls.delete:SetDisabled(false)
		controls.delete:SetText("Restore")
	else
		controls.delete:SetDisabled(true)
		controls.delete:SetText("Restore")
	end


    if category == "auras" then
        controls.name:SetDisabled(false)
		controls.showDuration:SetDisabled(false)
		controls.isMine:SetDisabled(false)
        controls.extend_below:SetDisabled(false)
        controls.refreshTime:SetDisabled(false)
    else
        controls.name:SetDisabled(true)
		controls.showDuration:SetDisabled(true)
        controls.isMine:SetDisabled(true)
        controls.extend_below:SetDisabled(true)
        controls.refreshTime:SetDisabled(true)
	end

end



function AptechkaGUI.Create(self, name, parent )
    -- Create a container frame
    -- local Frame = AceGUI:Create("Frame")
    -- Frame:SetTitle("AptechkaGUI")
    -- Frame:SetWidth(500)
    -- Frame:SetHeight(440)
    -- Frame:EnableResize(false)
    -- -- f:SetStatusText("Status Bar")
	-- -- Frame:SetParent(InterfaceOptionsFramePanelContainer)
    -- Frame:SetLayout("Flow")
	-- Frame:Hide()

	local Frame = AceGUI:Create("BlizOptionsGroup")
	Frame:SetName(name, parent)
	Frame:SetTitle("Aptechka Spell List")
	Frame:SetLayout("Fill")
	-- Frame:SetHeight(500)
	-- Frame:SetWidth(700)
	-- Frame:Show()



	-- local gr = AceGUI:Create("InlineGroup")
	-- gr:SetLayout("Fill")
	-- -- gr:SetWidth(600)
	-- -- gr:SetHeight(600)
	-- Frame:AddChild(gr)
	--
	-- local setcreate = AceGUI:Create("Button")
    -- setcreate:SetText("Save")
    -- -- setcreate:SetWidth(100)
	-- gr:AddChild(setcreate)
	-- if true then
		-- return Frame
	-- end


	-- local Frame = CreateFrame("Frame", "AptechkaOptions", UIParent) -- InterfaceOptionsFramePanelContainer)
	-- -- Frame:Hide()
	-- Frame.name = "AptechkaOptions"
	-- Frame.children = {}
	-- Frame:SetWidth(400)
	-- Frame:SetHeight(400)
	-- Frame:SetPoint("CENTER", UIParent, "CENTER",0,0)
	-- Frame.AddChild = function(self, child)
	-- 	table.insert(self.children, child)
	-- 	child:SetParent(self)
	-- end
	-- InterfaceOptions_AddCategory(Frame)


    -- local topgroup = AceGUI:Create("InlineGroup")
    -- topgroup:SetFullWidth(true)
    -- -- topgroup:SetHeight(0)
    -- topgroup:SetLayout("Flow")
    -- Frame:AddChild(topgroup)
    -- Frame.top = topgroup
	--
    -- local setname = AceGUI:Create("EditBox")
    -- setname:SetWidth(240)
    -- setname:SetText("NewSet1")F
    -- setname:DisableButton(true)
    -- topgroup:AddChild(setname)
    -- topgroup.label = setname
	--
    -- local setcreate = AceGUI:Create("Button")
    -- setcreate:SetText("Save")
    -- setcreate:SetWidth(100)
    -- setcreate:SetCallback("OnClick", function(self) AptechkaGUI:SaveSet() end)
    -- setcreate:SetCallback("OnEnter", function() Frame:SetStatusText("Create new/overwrite existing set") end)
    -- setcreate:SetCallback("OnLeave", function() Frame:SetStatusText("") end)
    -- topgroup:AddChild(setcreate)
	--
    -- local btn4 = AceGUI:Create("Button")
    -- btn4:SetWidth(100)
    -- btn4:SetText("Delete")
    -- btn4:SetCallback("OnClick", function() AptechkaGUI:DeleteSet() end)
    -- topgroup:AddChild(btn4)
    -- -- Frame.rpane:AddChild(btn4)
    -- -- Frame.rpane.deletebtn = btn4



    local treegroup = AceGUI:Create("TreeGroup") -- "InlineGroup" is also good
	-- treegroup:SetParent(InterfaceOptionsFramePanelContainer)
	-- treegroup.name = "AptechkaOptions"
    -- treegroup:SetFullWidth(true)
    -- treegroup:SetTreeWidth(200, false)
    -- treegroup:SetLayout("Flow")
    treegroup:SetFullHeight(true) -- probably?
	treegroup:SetFullWidth(true) -- probably?
    treegroup:EnableButtonTooltips(false)
    treegroup:SetCallback("OnGroupSelected", function(self, event, group)
		local path = {}
		for match in string.gmatch(group, '([^\001]+)') do
			table.insert(path, match)
		end

		local class, category, spellID = unpack(path)
		if not spellID or not category then
			Frame.rpane:Clear()
			if not NewTimerForm then
				NewTimerForm = AptechkaGUI:CreateNewTimerForm()
			end
			NewTimerForm.class = class
			Frame.rpane:AddChild(NewTimerForm)
            if class == "GLOBAL" then
                NewTimerForm.controls.newtrace:SetDisabled(true)
            else
                NewTimerForm.controls.newtrace:SetDisabled(false)
            end

			return
		end

		spellID = tonumber(spellID)
		local opts
		if not AptechkaConfigCustom[class] or not AptechkaConfigCustom[class][category] or not AptechkaConfigCustom[class][category][spellID] then
			opts = {}
		else
			opts = CopyTable(AptechkaConfigCustom[class][category][spellID])
		end
		Aptechka.SetupDefaults(opts, AptechkaDefaultConfig[category][spellID])

		-- if category == "spells" then
		Frame.rpane:Clear()
		if not AuraForm then
			AuraForm = AptechkaGUI:CreateAuraForm()
		end
		AptechkaGUI:FillForm(AuraForm, class, category, spellID, opts)
		Frame.rpane:AddChild(AuraForm)

		-- end
	end)

	Frame.rpane = treegroup
	Frame.tree = treegroup

	treegroup.UpdateSpellTree = function(self)
		local lclass, class = UnitClass("player")
		local classIcon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
		local classCoords = CLASS_ICON_TCOORDS[class]

		local t = {
			{
				value = "GLOBAL",
				text = "Global",
				icon = "Interface\\Icons\\spell_holy_resurrection",
				children = {
					{
						value = "auras",
						text = "Auras",
						icon = "Interface\\Icons\\spell_shadow_manaburn",
						children = AptechkaGUI:GenerateCategoryTree(true, "auras")
					},
				},
			},
			{
				value = class,
				text = lclass,
				icon = classIcon,
				iconCoords = classCoords,
				children = {
					{
						value = "auras",
						text = "Auras",
						icon = "Interface\\Icons\\spell_shadow_manaburn",
						children = AptechkaGUI:GenerateCategoryTree(false,"auras")
					},
					{
						value = "traces",
						text = "Traces",
						icon = "Interface\\Icons\\spell_nature_astralrecal",
						children = AptechkaGUI:GenerateCategoryTree(false,"traces")
					},
				}
			},
		}
		self:SetTree(t)
		return t
	end


	local t = treegroup:UpdateSpellTree()

	Frame:AddChild(treegroup)



	local categories = {"auras", "traces"}
	for i,group in ipairs(t) do -- expand all groups
		if group.value ~= "GLOBAL" then
			treegroup.localstatus.groups[group.value] = true
			for _, cat in ipairs(categories) do
				treegroup.localstatus.groups[group.value.."\001"..cat] = true
			end
		end
	end


	Frame.rpane.Clear = function(self)
		for i, child in ipairs(self.children) do
			child:SetParent(UIParent)
			child.frame:Hide()
		end
		table.wipe(self.children)
	end


	local _, class = UnitClass("player")
	Frame.tree:SelectByPath(class)



    return Frame
end

local function MakeGeneralOptions()
    local opt = {
        type = 'group',
        name = "Aptechka Settings",
        order = 1,
        args = {
            anchors = {
                type = "group",
                name = "Anchors",
                guiInline = true,
                order = 2,
                args = {
                    unlock = {
                        name = "Unlock",
                        type = "execute",
                        -- width = "half",
                        desc = "Unlock anchor for dragging",
                        func = function() Aptechka.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = "Lock",
                        type = "execute",
                        -- width = "half",
                        desc = "Lock anchor",
                        func = function() Aptechka.Commands.lock() end,
                        order = 2,
                    },
                    reset = {
                        name = "Reset",
                        type = "execute",
                        desc = "Reset anchor",
                        func = function() Aptechka.Commands.reset() end,
                        order = 3,
                    },
                },
            }, --
            sizeSettings = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3,
                args = {
                    width = {
                        name = "Width",
                        type = "range",
                        get = function(info) return Aptechka.db.width end,
                        set = function(info, v)
                            Aptechka.db.width = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 10,
                        max = 100,
                        step = 1,
                        order = 1,
                    },
                    height = {
                        name = "Height",
                        type = "range",
                        get = function(info) return Aptechka.db.height end,
                        set = function(info, v)
                            Aptechka.db.height = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 10,
                        max = 100,
                        step = 1,
                        order = 2,
                    },
                    nameLength = {
                        name = "Name Length",
                        type = "range",
                        get = function(info) return Aptechka.db.cropNamesLen end,
                        set = function(info, v)
                            Aptechka.db.cropNamesLen = v
                        end,
                        min = 2,
                        max = 25,
                        step = 1,
                        order = 3,
                    },
                    groupGrowth = {
                        name = "Group Growth Direction",
                        type = 'select',
                        order = 4,
                        values = {
                            LEFT = "Left",
                            RIGHT = "Right",
                            TOP = "Up",
                            BOTTOM = "Down",
                        },
                        get = function(info) return Aptechka.db.groupGrowth end,
                        set = function( info, v )
                            Aptechka.db.groupGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                    groupGap = {
                        name = "Group Gap",
                        type = "range",
                        width = "double",
                        get = function(info) return Aptechka.db.groupGap end,
                        set = function(info, v)
                            Aptechka.db.groupGap = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 4,
                        max = 20,
                        step = 1,
                        order = 5,
                    },
                    unitGrowth = {
                        name = "Unit Growth Direction",
                        type = 'select',
                        order = 6,
                        values = {
                            LEFT = "Left",
                            RIGHT = "Right",
                            TOP = "Up",
                            BOTTOM = "Down",
                        },
                        get = function(info) return Aptechka.db.unitGrowth end,
                        set = function( info, v )
                            Aptechka.db.unitGrowth = v
                            Aptechka:ReconfigureProtected()
                        end,
                    },
                    unitGap = {
                        name = "Unit Gap",
                        type = "range",
                        width = "double",
                        get = function(info) return Aptechka.db.unitGap end,
                        set = function(info, v)
                            Aptechka.db.unitGap = v
                            Aptechka:ReconfigureProtected()
                        end,
                        min = 4,
                        max = 20,
                        step = 1,
                        order = 7,
                    },
                    showSolo = {
                        name = "Show Solo",
                        type = "toggle",
                        width = "double",
                        get = function(info) return Aptechka.db.showSolo end,
                        set = function(info, v)
                            Aptechka.db.showSolo = not Aptechka.db.showSolo
                            Aptechka:ReconfigureProtected()
                        end,
                        order = 8,
                    },
                    sortUnitsByRole = {
                        name = "Sort Units by Role",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.sortUnitsByRole end,
                        set = function(info, v)
                            Aptechka.db.sortUnitsByRole = not Aptechka.db.sortUnitsByRole
                            print("Aptechka: Changes will effect after /reload")
                        end,
                        order = 8.5,
                    },
                    
                    disableBlizzardParty = {
                        name = "Disable Blizzard Party Frames",
                        width = "double",
                        type = "toggle",
                        get = function(info) return Aptechka.db.disableBlizzardParty end,
                        set = function(info, v)
                            Aptechka.db.disableBlizzardParty = not Aptechka.db.disableBlizzardParty
                            print("Aptechka: Changes will effect after /reload")
                        end,
                        order = 9,
                    },
                    hideBlizzardRaid = {
                        name = "Hide Blizzard Raid Frames",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.hideBlizzardRaid end,
                        set = function(info, v)
                            Aptechka.db.hideBlizzardRaid = not Aptechka.db.hideBlizzardRaid
                            print("Aptechka: Changes will effect after /reload")
                        end,
                        order = 10,
                    },
                    -- disableBlizzardRaid = {
                    --     name = "Disable Blizzard Raid Frames (not recommended)",
                    --     width = "full",
                    --     type = "toggle",
                    --     confirm = true,
					-- 	confirmText = "Warning: Will completely disable Blizzard CompactRaidFrames, but you also lose raid leader functionality. If you delete this addon, you can only revert with this macro:\n/script EnableAddOn('Blizzard_CompactRaidFrames'); EnableAddOn('Blizzard_CUFProfiles')",
                    --     get = function(info) return not IsAddOnLoaded("Blizzard_CompactRaidFrames") end,
                    --     set = function(info, v)
                    --         Aptechka:ToggleCompactRaidFrames()
                    --     end,
                    --     order = 10.4,
                    -- },
                    petGroup = {
                        name = "Enable Pet Group",
                        type = "toggle",
                        get = function(info) return Aptechka.db.petGroup end,
                        set = function(info, v)
                            Aptechka.db.petGroup = not Aptechka.db.petGroup
                            print("Aptechka: Changes will effect after /reload")
                        end,
                        order = 10.7,
                    },
                    disableTooltip = {
                        name = "Disable Tooltips",
                        width = "double",
                        type = "toggle",
                        get = function(info) return Aptechka.db.disableTooltip end,
                        set = function(info, v)
                            Aptechka.db.disableTooltip = not Aptechka.db.disableTooltip
                        end,
                        order = 10.8,
                    },
                    showAFK = {
                        name = "Show AFK",
                        type = "toggle",
                        get = function(info) return Aptechka.db.showAFK end,
                        set = function(info, v)
                            Aptechka.db.showAFK = not Aptechka.db.showAFK
                            print("Aptechka: Changes will effect after /reload")
                        end,
                        order = 11,
                    },
                    useCLH = {
                        name = "Use LibCLH",
                        type = "toggle",
                        confirm = true,
						confirmText = "Warning: Requires UI reloading.",
                        order = 11.2,
                        get = function(info) return Aptechka.db.useCombatLogHealthUpdates end,
                        set = function(info, v)
                            Aptechka.db.useCombatLogHealthUpdates = not Aptechka.db.useCombatLogHealthUpdates
                            ReloadUI()
                        end
                    },
                    useDebuffOrdering = {
                        name = "Use Debuff Ordering",
                        type = "toggle",
                        confirm = true,
						confirmText = "Warning: Requires UI reloading.",
                        order = 11.2,
                        get = function(info) return Aptechka.db.useDebuffOrdering end,
                        set = function(info, v)
                            Aptechka.db.useDebuffOrdering = not Aptechka.db.useDebuffOrdering
                            ReloadUI()
                        end
                    },

                    orientation = {
                        name = "Health Orientation",
                        type = 'select',
                        order = 12,
                        values = {
                            ["HORIZONTAL"] = "Horizontal",
                            ["VERTICAL"] = "Vertical",
                        },
                        -- values = MakeValuesForKeys(Aptechka.FrameTextures),
                        get = function(info) return Aptechka.db.healthOrientation end,
                        set = function( info, v )
                            Aptechka.db.healthOrientation = v
                            Aptechka:ReconfigureUnprotected()
                        end,
                    },

                    healthTexture = {
						type = "select",
						name = "Health Texture",
						order = 13,
						desc = "Set the statusbar texture.",
						get = function(info) return Aptechka.db.healthTexture end,
						set = function(info, value)
							Aptechka.db.healthTexture = value
                            Aptechka:ReconfigureUnprotected()
						end,
						values = LSM:HashTable("statusbar"),
						dialogControl = "LSM30_Statusbar",
					},

                    powerTexture = {
						type = "select",
						name = "Power Texture",
						order = 14,
						desc = "Set the statusbar texture.",
						get = function(info) return Aptechka.db.powerTexture end,
						set = function(info, value)
							Aptechka.db.powerTexture = value
                            Aptechka:ReconfigureUnprotected()
						end,
						values = LSM:HashTable("statusbar"),
						dialogControl = "LSM30_Statusbar",
					},

                    inverted = {
                        name = "Inverted Colors",
                        width = "full",
                        type = "toggle",
                        get = function(info) return Aptechka.db.invertedColors end,
                        set = function(info, v)
                            Aptechka.db.invertedColors = not Aptechka.db.invertedColors
                            Aptechka:ReconfigureUnprotected()
                        end,
                        order = 15,
                    },
                    -- incomingHealThreshold = {
                    --     name = "Incoming Heal Threshold",
                    --     type = "input",
                    --     -- desc = "Display spell name on timers",
                    --     get = function(info) return Aptechka.db.incomingHealThreshold end,
                    --     set = function(info, v)
                    --         if tonumber(v) then
                    --             Aptechka.db.incomingHealThreshold = tonumber(v)
                    --             Aptechka:ReconfigureProtected()
                    --         end
                    --     end,
                    --     order = 6,
                    -- },
                },
            },
        
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaGeneral", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaGeneral", "General", "Aptechka")

    return panelFrame
end



local function MakeScalingOptions()
    local opt = {
        type = 'group',
        name = "Aptechka Autoscaling",
        order = 1,
        args = {
            normalScale = {
                name = "Normal Scale (1-11 players)",
                type = "range",
                get = function(info) return Aptechka.db.scale end,
                set = function(info, v)
                    Aptechka.db.scale = v
                    Aptechka:LayoutUpdate()
                end,
                min = 0.3,
                max = 3,
                step = 0.01,
                order = 1,
            },
            healer = {
                type = "group",
                name = "Healer Autoscale",
                width = "double",
                guiInline = true,
                order = 2,
                args = {

                    healerRaid = {
                        name = "Raid (12-30 players)",
                        type = "range",
                        get = function(info) return Aptechka.db.autoscale.healerMediumRaid end,
                        set = function(info, v)
                            Aptechka.db.autoscale.healerMediumRaid = v
                            Aptechka:LayoutUpdate()
                        end,
                        min = 0.3,
                        max = 3,
                        step = 0.01,
                        order = 1,
                    },
                    healerBigRaid = {
                        name = "Big Raid (30+ players)",
                        type = "range",
                        get = function(info) return Aptechka.db.autoscale.healerBigRaid end,
                        set = function(info, v)
                            Aptechka.db.autoscale.healerBigRaid = v
                            Aptechka:LayoutUpdate()
                        end,
                        min = 0.3,
                        max = 3,
                        step = 0.01,
                        order = 2,
                    },
                    
                },
            },
            damage = {
                type = "group",
                name = "Damage Autoscale",
                width = "double",
                guiInline = true,
                order = 3,
                args = {

                    damageRaid = {
                        name = "Raid (12-30 players)",
                        type = "range",
                        get = function(info) return Aptechka.db.autoscale.damageMediumRaid end,
                        set = function(info, v)
                            Aptechka.db.autoscale.damageMediumRaid = v
                            Aptechka:LayoutUpdate()
                        end,
                        min = 0.3,
                        max = 3,
                        step = 0.01,
                        order = 1,
                    },
                    damageBigRaid = {
                        name = "Big Raid (30+ players)",
                        type = "range",
                        get = function(info) return Aptechka.db.autoscale.damageBigRaid end,
                        set = function(info, v)
                            Aptechka.db.autoscale.damageBigRaid = v
                            Aptechka:LayoutUpdate()
                        end,
                        min = 0.3,
                        max = 3,
                        step = 0.01,
                        order = 2,
                    },
                    
                },
            },    
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("AptechkaScaling", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("AptechkaScaling", "Scaling", "Aptechka")

    return panelFrame
end






do
    local f = CreateFrame('Frame', "AptechkaOptions", InterfaceOptionsFrame)
    f.name = "Aptechka"
    InterfaceOptions_AddCategory(f);


    f.general = MakeGeneralOptions()

    f.scaling = MakeScalingOptions()

    AptechkaGUI.frame = AptechkaGUI:Create("Spell List", "Aptechka")
    f.spell_list = AptechkaGUI.frame.frame
    InterfaceOptions_AddCategory(f.spell_list);

    f:Hide()
    f:SetScript("OnShow", function(self)
            self:Hide();
            -- local first = self.spell_list
            local first = self.general
            InterfaceOptionsFrame_OpenToCategory (first)
            InterfaceOptionsFrame_OpenToCategory (first)
    end)
end
