local _, helpers = ...

helpers.frame = CreateFrame("Frame","Aptechka",UIParent)

AptechkaDefaultConfig = {}
local config = AptechkaDefaultConfig
AptechkaUserConfig = AptechkaDefaultConfig
local _, playerClass = UnitClass("player")
config["GLOBAL"] = { auras = {}, traces = {}, }
config[playerClass] = { auras = {}, traces = {}, }


local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local APILevel = math.floor(select(4,GetBuildInfo())/10000)
function helpers.GetAPILevel()
    return APILevel
end

-- default framelevels for elements
helpers.FRAMELEVEL = {
    -- BASEFRAME = 3,
    HEALTH = 4,
    POWER = 4,
    BORDER = 5,
    BAR = 8,
    INDICATOR = 8,
    DEBUFFICON = 10,
    ICON = 11,
    TEXT = 6,
    TEXTURE = 13,
    OVERLAY = 15, -- Mind Control, Vehicle
    PROGRESSICON = 17,
    FLASH = 19,
}

if C_Spell.GetSpellInfo then
    local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
    helpers.GetSpellName = function(spellId)
        local info = C_Spell_GetSpellInfo(spellId)
        if info then
            return info.name, info.iconID
        end
    end
    helpers.GetSpellTexture = C_Spell.GetSpellTexture
else
    helpers.GetSpellName = _G.GetSpellInfo
    helpers.GetSpellTexture = _G.GetSpellTexture
end
local GetSpellName = helpers.GetSpellName

if APILevel == 1 then
    helpers.spellNameToID = {}
    helpers.AddSpellNameRecognition = function(lastRankID)
        helpers.spellNameToID[GetSpellName(lastRankID)] = lastRankID
    end
end

local pmult = 1
function helpers.pixelperfect(size)
    return floor(size/pmult + 0.5)*pmult
end

local res = GetCVar("gxWindowedResolution")
if res then
    local w,h = string.match(res, "(%d+)x(%d+)")
    pmult = (768/h) / UIParent:GetScale()
end

helpers.PercentColor = function(percent)
    if percent <= 0 then
        return 0, 1, 0
    elseif percent <= 0.5 then
        return percent*2, 1, 0
    elseif percent >= 1 then
        return 1, 0, 0
    else
        return 1, 2 - percent*2, 0
    end
end

helpers.GetGradientColor2 = function(c1, c2, v)
    if v > 1 then v = 1 end
    local r = c2[1] + v*(c1[1]-c2[1])
    local g = c2[2] + v*(c1[2]-c2[2])
    local b = c2[3] + v*(c1[3]-c2[3])
    return r,g,b
end
local GetGradientColor2 = helpers.GetGradientColor2

helpers.GetGradientColor3 = function(c1, c2, c3, v)
    if v >= 1 then
        return unpack(c1)
    elseif v >= 0.5 then
        return GetGradientColor2(c1,c2, (v-0.5)*2)
    elseif v > 0 then
        return GetGradientColor2(c2,c3, v*2)
    else
        return unpack(c3)
    end
end


helpers.DebuffTypeColors = {
    Physical = { 1, 0.3 ,0.3 }, -- Used in CC List

    Magic = { 0.2, 0.6, 1},
    Curse = { 0.6, 0, 1},
    Poison = { 0, 0.6, 0},
    Disease = { 0.6, 0.4, 0},
}
helpers.BITMASK_DISEASE = 0x000F
helpers.BITMASK_POISON = 0x00F0
helpers.BITMASK_CURSE = 0x0F00
helpers.BITMASK_MAGIC = 0xF000
function helpers.DispelTypes(...)
    local numArgs = select("#", ...)
    local BITMASK_DISPELLABLE = 0
    for i=1, numArgs do
        local debuffType = select(i, ...)
        if debuffType == "Magic" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_MAGIC)
        elseif debuffType == "Poison" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_POISON)
        elseif debuffType == "Disease" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_DISEASE)
        elseif debuffType == "Curse" then
            BITMASK_DISPELLABLE = bit.bor( BITMASK_DISPELLABLE, helpers.BITMASK_CURSE)
        end
    end
    return BITMASK_DISPELLABLE
end

local protomt = { __index = function(t,k) return t.prototype[k] end }


local function SetupDefaults(t, defaults)
    if not defaults then return end
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            elseif t[k] == false then
                t[k] = false --pass
            else
                SetupDefaults(t[k], v)
            end
        else
            if type(t) == "table" and t[k] == nil then t[k] = v end
            if t[k] == "__REMOVED__" then t[k] = nil end
        end
    end
end
helpers.SetupDefaults = SetupDefaults

function helpers.UnwrapTemplate(opts)
    if not opts.template then return false end
    local templateName = opts.template
    local templateTable = AptechkaConfigMerged.templates[templateName]

    SetupDefaults(opts, templateTable)
    return true
end
local UnwrapTemplate = helpers.UnwrapTemplate

function helpers.UnwrapConfigTemplates(configCategory)
    for spellID, opts in pairs(configCategory) do
        UnwrapTemplate(opts)
    end
end

function helpers.AddLoadableAura(data, todefault)
    if data.id then data.name = GetSpellName(data.id) end
    if data.name == nil then print (data.id.." spell id missing") return end

    if data.prototype then
        setmetatable(data, protomt)
    end

    if not data.type then data.type = "HELPFUL" end

    if not Aptechka.loadedAuras then Aptechka.loadedAuras = {} end
    Aptechka.loadedAuras[data.id] = data
end


local function PrepareAuraOpts(data)
    if type(data.id) == "table" then
        local clones = data.id
        data.id = clones[1] -- extract first spell id from the last as original
        -- apparently table.remove replaces 1 index with nil, without shifting the array part
        local t = {}
        for i=2,100 do
            local spellID = clones[i]
            if not spellID then break end
            t[spellID] = true
        end
        data.clones = t
    end

    if data.id and not data.name then data.name = GetSpellName(data.id) end
    if data.name == nil then
        -- print(string.format("[Aptechka] %d spell id missing", data.id))
        return
    end

    if data.showDuration then
        data.infoType = "DURATION"
    elseif data.showCount then
        data.infoType = "COUNT"
    end

    return data
end

function helpers.AddAura(opts)
    local data = PrepareAuraOpts(opts)
    if data then
        config[playerClass].auras[data.id] = data
    end
end
function helpers.AddAuraGlobal(opts)
    local data = PrepareAuraOpts(opts)
    if data then
        config["GLOBAL"].auras[data.id] = data
    end
end

function helpers.AddAuraToDefault(data)
    helpers.AddAura(data,true)
end


function helpers.ModStatus(name, opts)

end

function helpers.AddTrace(data)
    if not config.enableTraceHeals then return end

    if type(data.id) == "table" then
        local clones = data.id
        data.id = clones[1] -- extract first spell id from the last as original
        -- apparently table.remove replaces 1 index with nil, without shifting the array part
        local t = {}
        for i=2,100 do
            local spellID = clones[i]
            if not spellID then break end
            t[spellID] = true
        end
        data.clones = t
    end

    if data.id then data.name = GetSpellName(data.id) or data.name end
    if not config.traces then config.traces = {} end
    if not data.name then
        -- print(string.format("[Aptechka] %d spell id missing", data.id))
        return
    end
    local id = data.id
    data.id = nil -- important to do that, because statuses with id field treated as aura

    config[playerClass].traces[id] = data
end

function helpers.AddDebuff(index, data)
    if not config.DebuffDisplay then config.DebuffDisplay = {} end

    config.DebuffDisplay[index] = data
end

helpers.customBossAuras = {}
function helpers.BossAura(...)
    local n = select('#', ...)
    for i=1,n do
        local spellID = select(i, ...)
        helpers.customBossAuras[spellID] = true
    end
end


function helpers.MakeTables(rootTable, ...)
    local n = select("#", ...)
    local t = rootTable
    for i=1, n do
        local key = select(i, ...)
        if not t[key] then
            t[key] = {}
        end
        t = t[key]
    end
    return t
end

helpers.ClickMacro = function(macro)
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    if not config.enableClickCasting then return end
    config.ClickCastingMacro = macro:gsub("spell:(%d+)",GetSpellName):gsub("([ \t]+)/",'/')
end

helpers.BindTarget = function(str)
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    if not str then
        config.TargetBinding = false
        return
    end
    str = str:lower()
    local alt = str:find("alt")
    local shift = str:find("shift")
    local ctrl = str:find("ctrl")
    local btn = str:match("(%d+)")
    if btn == "0" then btn = "*" end
    local tar = "type"..btn
    if shift then tar = "shift-"..tar end
    if ctrl then tar = "ctrl-"..tar end
    if alt then tar = "alt-"..tar end
    config.TargetBinding = tar
    --alt-ctrl-shift-type*     -- That order is required
end


--~ helpers.AddClickCast = function(data)
--~     if not config.enableClickCasting then return end
--~     if not data.button then print("specify mouse button") return end
--~     if not config.ClickCasting then config.ClickCasting = {} end
--~     local seq = "type"..(data.button == 0 and "*" or data.button)
--~     if data.shift then seq = "shift-"..seq end
--~     if data.ctrl then seq = "ctrl-"..seq end
--~     if data.alt then seq = "alt-"..seq end
--~     local cc = {
--~         [seq] = data.type,
--~         [data.type] = data.value
--~     }
--~     table.insert(config.ClickCasting, cc)
--~ end


local xor = bit.bxor
local byte = string.byte
function helpers.GetAuraHash(spellId, duration, expirationTime, count, caster)
    local hash = xor(spellId, expirationTime*1000)
    hash = xor(hash, duration)
    hash = xor(hash, (count+1)*100000+count)
    local casterInt = caster and (byte(caster, -2)^2 + byte(caster, -1)) or 14894
    hash = xor(hash, casterInt)
    return hash
end

-- lifted from SecureGroupHeaders.lua
function helpers.setAttributesWithoutResponse(self, ...)
	local oldIgnore = self:GetAttribute("_ignore");
	self:SetAttribute("_ignore", "attributeChanges");
	for i = 1, select('#', ...), 2 do
		self:SetAttribute(select(i, ...));
	end
	self:SetAttribute("_ignore", oldIgnore);
end

function helpers.utf8sub(str, start, numChars)
    local currentIndex = start
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        if char >= 240 then
          currentIndex = currentIndex + 4
        elseif char >= 225 then
          currentIndex = currentIndex + 3
        elseif char >= 192 then
          currentIndex = currentIndex + 2
        else
          currentIndex = currentIndex + 1
        end
        numChars = numChars - 1
    end
    return str:sub(start, currentIndex - 1)
end

function helpers.DisableBlizzPlayerFrame()
    local hiddenParent = helpers.hiddenParent or CreateFrame('Frame', nil, UIParent)
    helpers.hiddenParent = hiddenParent
    hiddenParent:SetAllPoints()
    hiddenParent:Hide()

    local frame = PlayerFrame

    frame:SetParent(hiddenParent)

    frame:UnregisterAllEvents()
    frame:Hide()

    frame.healthbar:UnregisterAllEvents()
    frame.manabar:UnregisterAllEvents()

    if not isClassic then
        -- Aspparently some issues if these events are disabled
        frame:RegisterEvent('PLAYER_ENTERING_WORLD')
        frame:RegisterEvent('UNIT_ENTERING_VEHICLE')
        frame:RegisterEvent('UNIT_ENTERED_VEHICLE')
        frame:RegisterEvent('UNIT_EXITING_VEHICLE')
        frame:RegisterEvent('UNIT_EXITED_VEHICLE')
    end

    frame:SetUserPlaced(true)
	frame:SetDontSavePosition(true)
end

function helpers.DisableBlizzParty(self)
    local hiddenParent = helpers.hiddenParent or CreateFrame('Frame', nil, UIParent)
    helpers.hiddenParent = hiddenParent
    hiddenParent:SetAllPoints()
    hiddenParent:Hide()
    for i=1,4 do
        local party = "PartyMemberFrame"..i
        local frame = _G[party]

        frame:UnregisterAllEvents()
        frame:Hide()
        frame:SetParent(hiddenParent)
        -- hooksecurefunc("ShowPartyFrame", HidePartyFrame)
        -- hooksecurefunc("PartyMemberFrame_UpdateMember", function(self)
            -- if not InCombatLockdown() then
                -- self:Hide()
            -- end
        -- end)

        _G[party..'HealthBar']:UnregisterAllEvents()
        _G[party..'ManaBar']:UnregisterAllEvents()
    end
end

function helpers.DisableBlizzRaid()
    -- disable Blizzard party & raid frame if our Raid Frames are loaded
    -- InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
    -- InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
    -- raid
    local hider = CreateFrame("Frame")
    hider:Hide()
    if CompactRaidFrameManager and CompactUnitFrameProfiles then
        CompactRaidFrameManager:SetParent(hider)
        -- CompactRaidFrameManager:UnregisterAllEvents()
        CompactUnitFrameProfiles:UnregisterAllEvents()

        local disableCompactRaidFrameUnitButton = function(self)
            if self:IsForbidden() then return end
            -- for some reason CompactUnitFrame_OnLoad also gets called for nameplates, so ignoring that
            local frameName = self:GetName()
            if not frameName then return end
            if string.sub(frameName, 1, 16) == "CompactRaidFrame" then
                -- print(frameName)
                self:UnregisterAllEvents()
            end
        end

        for i=1,60 do
            local crf = _G["CompactRaidFrame"..i]
            if not crf then break end
            disableCompactRaidFrameUnitButton(crf)
        end
        hooksecurefunc("CompactUnitFrame_OnLoad", disableCompactRaidFrameUnitButton)
        hooksecurefunc("CompactUnitFrame_UpdateUnitEvents", disableCompactRaidFrameUnitButton)
    end
end


if APILevel >= 10 then

    local hiddenFrame

	local function rehide(self)
		if not InCombatLockdown() then self:Hide() end
	end

	local function unregister(f)
		if f then f:UnregisterAllEvents() end
	end

	local function hideFrame(frame)
		if frame then
			UnregisterUnitWatch(frame)
			frame:Hide()
			frame:UnregisterAllEvents()
			frame:SetParent(hiddenFrame)
			frame:HookScript("OnShow", rehide)
			unregister(frame.healthbar)
			unregister(frame.manabar)
			unregister(frame.powerBarAlt)
			unregister(frame.spellbar)
		end
	end

	-- party frames
	function helpers.DisableBlizzParty()
		hiddenFrame = hiddenFrame or CreateFrame('Frame')
		hiddenFrame:Hide()
		if PartyFrame then
			hideFrame(PartyFrame)
			for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
				hideFrame(frame)
				hideFrame(frame.HealthBar)
				hideFrame(frame.ManaBar)
			end
			PartyFrame.PartyMemberFramePool:ReleaseAll()
		end
		hideFrame(CompactPartyFrame)
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE") -- used by compact party frame
	end

	-- raid frames
	function helpers.DisableBlizzRaid()
		if not CompactRaidFrameManager then return end
		local function HideFrames()
			CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameContainer:UnregisterAllEvents()
			if not InCombatLockdown() then
				CompactRaidFrameManager:Hide()
				local shown = CompactRaidFrameManager_GetSetting('IsShown')
				if shown and shown ~= '0' then
					CompactRaidFrameManager_SetSetting('IsShown', '0')
				end
			end
		end
		hiddenFrame = hiddenFrame or CreateFrame('Frame')
		hiddenFrame:Hide()
		hooksecurefunc('CompactRaidFrameManager_UpdateShown', HideFrames)
		CompactRaidFrameManager:HookScript('OnShow', HideFrames)
		CompactRaidFrameContainer:HookScript('OnShow', HideFrames)
		HideFrames()
	end
end


local MIRROR_POINTS = {
	["TOPLEFT"] = "BOTTOMRIGHT",
	["LEFT"] = "RIGHT",
	["BOTTOMLEFT"] = "TOPRIGHT",
	["TOPRIGHT"] = "BOTTOMLEFT",
	["RIGHT"] = "LEFT",
	["BOTTOMRIGHT"] = "TOPLEFT",
	["CENTER"] = "CENTER",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
};

local MIRROR_POINTS_HORIZONTAL = {
	["TOPLEFT"] = "TOPRIGHT",
	["LEFT"] = "RIGHT",
	["BOTTOMLEFT"] = "BOTTOMRIGHT",
	["TOPRIGHT"] = "TOPLEFT",
	["RIGHT"] = "LEFT",
	["BOTTOMRIGHT"] = "BOTTOMLEFT",
	["CENTER"] = "CENTER",
	["TOP"] = "TOP",
	["BOTTOM"] = "BOTTOM",
};

local MIRROR_POINTS_VERTICAL = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["LEFT"] = "LEFT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["RIGHT"] = "RIGHT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["CENTER"] = "CENTER",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
};
function helpers.Reverse(p1, direction)
    local mirrorTable = MIRROR_POINTS
    if direction == "HORIZONTAL" then
        mirrorTable = MIRROR_POINTS_HORIZONTAL
    elseif direction == "VERTICAL" then
        mirrorTable = MIRROR_POINTS_VERTICAL
    end
    local p2 = mirrorTable[p1]

    if p2 == "RIGHT" or p2 == "LEFT" then
        return p2, "HORIZONTAL"
    elseif p2 == "TOP" or p2 == "BOTTOM" then
        return p2, "VERTICAL"
    end
    return p2
end

local POINT_MULS = {
	["TOPLEFT"] = { 1, -1 },
	["LEFT"] = { 1, 0 },
	["BOTTOMLEFT"] = { 1, 1 },
	["TOPRIGHT"] = { -1, -1 },
	["RIGHT"] = { -1, 0 },
	["BOTTOMRIGHT"] = { -1, 1 },
	["CENTER"] = { 0, 0 },
	["TOP"] = { 0, -1 },
	["BOTTOM"] = { 0, 1 },
};
function helpers.GetMultipliersFromPoint(point)
    local muls = POINT_MULS[point]
    if muls then
        return unpack(muls)
    end
end

function helpers.GetVerticalAlignmentFromPoint(p1)
    if string.find(p1,"BOTTOM") then return "BOTTOM" end
    return "TOP"
end
function helpers.GetHorizontalAlignmentFromPoint(p1)
    if string.find(p1,"RIGHT") then return "RIGHT" end
    return "LEFT"
end


local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot

local function ForEachAuraHelper(frame, unit, index, filter, func, continuationToken, ...)
    -- continuationToken is the first return value of GetAuraSlots()
    local n = select('#', ...);
    for i=1, n do
        local slot = select(i, ...);
        local result = func(frame, unit, index, slot, filter, GetAuraDataBySlot(unit, slot))

        if result == -1 then
            -- if func returns -1 then no further slots are needed, so don't return continuationToken
            return nil;
        end

        index = index + (result or 1)
    end
    return continuationToken, index;
end

function helpers.ForEachAura(frame, unit, filter, maxCount, func)
    if maxCount and maxCount <= 0 then
        return;
    end
    local continuationToken;
    local index = 1
    repeat
        -- continuationToken is the first return value of UnitAuraSltos
        continuationToken, index = ForEachAuraHelper(frame, unit, index, filter, func, GetAuraSlots(unit, filter, maxCount, continuationToken));
    until continuationToken == nil;

    return index
end

do
    local IsSpellInRange = _G.IsSpellInRange
    function helpers.RangeCheckBySpell(spellID)
        local spellName = GetSpellName(spellID)
        return function(unit)
            return (IsSpellInRange(spellName,unit) == 1)
        end
    end
end


do
    local pow = math.pow
    local band = bit.band
    local bor = bit.bor
    function helpers.CheckBit(num, index)
        local n = pow(2,index-1)
        return band(num, n) > 0
    end
    local CheckBit = helpers.CheckBit

    function helpers.CompareBits(n1, n2, index)
        return CheckBit(n1, index) == CheckBit(n2, index)
    end

    function helpers.SetBit(num, index)
        local n = pow(2,index-1)
        return bor(num, n)
    end

    function helpers.UnsetBit(num, index)
        local n = bit.bnot( pow(2,index-1))
        return band(num, n)
    end
end

local function RemoveDefaults(t, defaults)
    if not defaults then return end
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end
helpers.RemoveDefaults = RemoveDefaults


local function MergeTable(t1, t2)
    if not t2 then return false end
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if t1[k] == nil or type(t1[k]) ~= "table" then -- assignto can be string while t2 can be table
                t1[k] = CopyTable(v)
            else
                MergeTable(t1[k], v)
            end
        elseif v == "__REMOVED__" then
            t1[k] = nil
        else
            t1[k] = v
        end
    end
    return t1
end
helpers.MergeTable = MergeTable

-- function helpers.ShallowCopyTable(tbl)
--     local copy = {}
--     for k,v in pairs(tbl) do
--         copy[k] = v
--     end
--     return copy
-- end

local Set = {}
local mt = { __index = Set }

local updateTable = function(tbl, ...)
    local numArgs = select("#", ...)
    for i=1, numArgs do
        tbl[i] = select(i, ...)
    end
end
function Set.newFromArgs(...)
    local set = setmetatable({}, mt)
    local numArgs = select("#", ...)
    for i=1, numArgs do
        local k = select(i, ...)
        set[k] = true
    end
    return set
end

function Set.new (t)
    local set = setmetatable({}, mt)
    for _, k in ipairs(t) do set[k] = true end
    return set
end

-- updated set here is b
function Set.diff(a,b)
    local res = Set.new{}
    if a == nil then return CopyTable(b) end
    if b == nil then return res end
    for k in pairs(b) do
        if not a[k] then
            res[k] = true
        end
    end
    for k in pairs(a) do
        if not b[k] then
            res[k] = false
        end
    end
    return res
end

function Set.union (a,b)
    local res = Set.new{}
    for k in pairs(a) do res[k] = a[k] end
    for k in pairs(b) do res[k] = b[k] end
    return res
end

function Set.intersection (a,b)
    local res = Set.new{}
    for k in pairs(a) do
        res[k] = b[k]
    end
    return res
end

function Set.tostring (set)
    local s = "{"
    local sep = ""
    for e in pairs(set) do
        s = s .. sep .. e
        sep = ", "
    end
    return s .. "}"
end

helpers.set = Set.newFromArgs
helpers.Set = Set


function helpers.ShakeAssignments(newOpts, defaultOpts)
    if newOpts.assignto and defaultOpts and defaultOpts.assignto then
        local toRemove = {}
        for slot, enabled in pairs(newOpts.assignto) do
                local defSlot = defaultOpts.assignto[slot]
                if not enabled and (defSlot == false or defSlot == nil) then
                    table.insert(toRemove, slot)
                end
                if enabled and defSlot == true then
                    table.insert(toRemove, slot)
                end
        end
        for _, slot in ipairs(toRemove) do
            newOpts.assignto[slot] = nil
        end
    elseif newOpts.assignto then
        local toRemove = {}
        for slot, enabled in pairs(newOpts.assignto) do
                if not enabled then
                    table.insert(toRemove, slot)
                end
        end
        for _, slot in ipairs(toRemove) do
            newOpts.assignto[slot] = nil
        end
    end
end
