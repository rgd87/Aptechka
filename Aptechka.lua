Aptechka = CreateFrame("Frame","Aptechka",UIParent)

Aptechka:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

AptechkaUserConfig = setmetatable({},{ __index = function(t,k) return AptechkaDefaultConfig[k] end })
-- When AptechkaUserConfig __empty__ field is accessed, it will return AptechkaDefaultConfig field

local AptechkaUnitInRange
local auras
local dtypes
local traceheals
local colors

local config = AptechkaUserConfig
local OORUnits = setmetatable({},{__mode = 'k'})
local inCL = setmetatable({},{__index = function (t,k) return 0 end})
local buffer = {}
local loaded = {}
local auraUpdateEvents
local Roster = {}
local guidMap = {}
local group_headers = {}
local anchors = {}
local skinAnchorsName

if not ClickCastFrames then ClickCastFrames = {} end -- clique
local AptechkaString = "|cffff7777Aptechka: |r"
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitAura = UnitAura
local UnitAffectingCombat = UnitAffectingCombat
local bit_band = bit.band
local _, helpers = ...
Aptechka.helpers = helpers
local utf8sub = helpers.utf8sub
local reverse = helpers.Reverse
local AptechkaDB = {}
local QuickHealth

Aptechka:RegisterEvent("PLAYER_LOGIN")
function Aptechka.PLAYER_LOGIN(self,event,arg1)
    AptechkaUnitInRange = config.UnitInRangeFunc or UnitInRange
    auras = config.IndicatorAuras or {}
    dtypes = config.DebuffTypes or {}
    traceheals = config.TraceHeals or {}
    colors = setmetatable(config.Colors or {},{ __index = function(t,k) return RAID_CLASS_COLORS[k] end })
    
    AptechkaDB_Global = AptechkaDB_Global or {}
    AptechkaDB_Char = AptechkaDB_Char or {}
    AptechkaDB_Global.charspec = AptechkaDB_Global.charspec or {}
    user = UnitName("player").."@"..GetRealmName()
    if AptechkaDB_Global.charspec[user] then
        setmetatable(AptechkaDB,{ __index = function(t,k) return AptechkaDB_Char[k] end, __newindex = function(t,k,v) rawset(AptechkaDB_Char,k,v) end})
    else
        setmetatable(AptechkaDB,{ __index = function(t,k) return AptechkaDB_Global[k] end, __newindex = function(t,k,v) rawset(AptechkaDB_Global,k,v) end})
    end
    
    AptechkaDB.pos = AptechkaDB.pos or {}
    AptechkaDB.pos.x = AptechkaDB.pos.x or 0
    AptechkaDB.pos.y = AptechkaDB.pos.y or 0
    AptechkaDB.pos.point = AptechkaDB.pos.point or "CENTER"

    AptechkaDB.pet_pos = AptechkaDB.pet_pos or {}
    AptechkaDB.pet_pos.x = AptechkaDB.pet_pos.x or 0
    AptechkaDB.pet_pos.y = AptechkaDB.pet_pos.y or 0
    AptechkaDB.pet_pos.point = AptechkaDB.pet_pos.point or "CENTER"
    
    AptechkaDB.scale = AptechkaDB.scale or 1
    
    if config.disableBlizzardParty then
        helpers.DisableBlizzParty()
    end
    
    if config.enableIncomingHeals then
        self:RegisterEvent("UNIT_HEAL_PREDICTION")
    end
    if config.useQuickHealth then
        QuickHealth = LibStub and LibStub("LibQuickHealth-2.0", true)
        if QuickHealth then
            UnitHealth = QuickHealth.UnitHealth
            Aptechka.UnitHealthUpdated = function(self, event, unit, h, hm)
                if Roster[unit] then
                    self:UNIT_HEALTH(nil, unit)
                end
            end
            QuickHealth.RegisterCallback(self, "UnitHealthUpdated")
        end
    end
    
    self.initConfSnippet = [[
        local id = tonumber(self:GetName():match(".+UnitButton(%d)"))
        owner:CallMethod("initConf",id)    
    ]]
    
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    Aptechka.UNIT_MAXHEALTH = Aptechka.UNIT_HEALTH
    self:RegisterEvent("UNIT_CONNECTION")
    
    if not config.disableManaBar then
        self:RegisterEvent("UNIT_POWER")
        self:RegisterEvent("UNIT_MAXPOWER")
        self:RegisterEvent("UNIT_DISPLAYPOWER")
        Aptechka.UNIT_MAXPOWER = Aptechka.UNIT_POWER
    end
    if config.AggroStatus then
        self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    end
    if config.ReadyCheck then
        self:RegisterEvent("READY_CHECK")
        self:RegisterEvent("READY_CHECK_CONFIRM")
        self:RegisterEvent("READY_CHECK_FINISHED")
    end
    if config.TargetStatus then
        self.previousTarget = "player"
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end
    
    self:RegisterEvent("UNIT_AURA")
    
    if config.TraceHeals then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
    
    self:RegisterEvent("RAID_ROSTER_UPDATE")
    
    if config.raidIcons then
        self:RegisterEvent("RAID_TARGET_UPDATE")
    end
    self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    
    if config[config.skin.."Settings"] then  config[config.skin.."Settings"]() end
    skinAnchorsName = config.useAnchors or config.skin
    local i = 1
    while (i <= config.maxgroups) do
        local f  = Aptechka:CreateHeader(i)
        group_headers[i] = f
        f:SetScale(AptechkaDB.scale)
        f:Show()
        i = i + 1
    end
                
    Aptechka:SetScript("OnUpdate",Aptechka.OnRangeUpdate)
    Aptechka:Show()
        
    SLASH_APTECHKA1= "/aptechka"
    SLASH_APTECHKA2= "/apt"
    SLASH_APTECHKA3= "/inj"
    SLASH_APTECHKA4= "/injector"
    SlashCmdList["APTECHKA"] = Aptechka.SlashCmd
    
    
    if config.enableTraceHeals then

        Aptechka.COMBAT_LOG_EVENT_UNFILTERED = function( self, event, timestamp, eventType, srcGUID,
                                                    srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName,
                                                    spellSchool, amount, overhealing, absorbed, critical)
            if (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
                local opts = traceheals[spellName]
                if opts and eventType == opts.type then
                    if guidMap[dstGUID] then
                        Aptechka.SetJob(guidMap[dstGUID],opts,true)
                    end
                end
            end
        end

    end

    --raid/pvp debuffs loading 
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    loader:RegisterEvent("PLAYER_ENTERING_WORLD")
    local mapIDs = config.MapIDs

    loader:SetScript("OnEvent",function (self,event)
        local instance
        local _, instanceType = GetInstanceInfo()
        if instanceType == "arena" or instanceType == "pvp" then
            instance = "PvP"
        else
            instance = mapIDs[GetCurrentMapAreaID()]
        end
        if not instance then return end
        local add = config.LoadableDebuffs[instance]
        if add and not loaded[instance] then
            add()
            print (AptechkaString..instance.." debuffs loaded.")
            loaded[instance] = true
        end
    end)




    if config.useCombatLogFiltering then
        local timer = CreateFrame("Frame")
        timer.OnUpdateCounter = 0
        timer:SetScript("OnUpdate",function(self, time)
            self.OnUpdateCounter = self.OnUpdateCounter + time
            if self.OnUpdateCounter < 1 then return end
            self.OnUpdateCounter = 0
            for unit in pairs(buffer) do
                Aptechka.ScanAuras(unit)
                buffer[unit] = nil
            end
        end)

        Aptechka.UNIT_AURA = function(self, event, unit)
            if not Roster[unit] then return end    
            Aptechka.ScanDispels(unit)
            if OORUnits[unit] and inCL[unit] +5 < GetTime() then
                buffer[unit] = true
            end
        end

        auraUpdateEvents = {
            ["SPELL_AURA_REFRESH"] = true,
            ["SPELL_AURA_APPLIED"] = true,
            ["SPELL_AURA_APPLIED_DOSE"] = true,
            ["SPELL_AURA_REMOVED"] = true,
            ["SPELL_AURA_REMOVED_DOSE"] = true,
        }
        local cleuEvent = CreateFrame("Frame")
        cleuEvent:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        cleuEvent:SetScript("OnEvent",
        function( self, event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType, amount)
            if auras[spellName] then
                if auraUpdateEvents[eventType] then
                    local unit = guidMap[dstGUID]
                    if unit then
                        buffer[unit] = nil
                        inCL[unit] = GetTime()
                        Aptechka.ScanAuras(unit)
                    end
                end
            end
        end)
    end
    
    
        
end  -- END PLAYER_LOGIN

function Aptechka.UNIT_HEAL_PREDICTION(self,event,unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local heal = UnitGetIncomingHeals(unit)
        local threshold = 3000
        local showHeal = (heal and heal > threshold)
        if self.health.incoming then 
            self.health.incoming:SetValue( showHeal and self.health:GetValue()+(heal/UnitHealthMax(unit)*100) or 0)
        end
        if config.IncomingHealStatus then
            if showHeal then
                self.vIncomingHeal = heal
                Aptechka.SetJob(unit, config.IncomingHealStatus, true)
            else
                self.vIncomingHeal = 0
                Aptechka.SetJob(unit, config.IncomingHealStatus, false)
            end
        end
    end
end


function Aptechka.UNIT_HEALTH(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local h,hm = UnitHealth(unit), UnitHealthMax(unit)
        self.vHealth = h
        self.vHealthMax = hm
        self.health:SetValue(h/hm*100)
        Aptechka.SetJob(unit,config.HealthDificitStatus, ((hm-h) > 1000) )
        
        
        
        if event then -- quickhealth calls this function without event
            if UnitIsDeadOrGhost(unit) then
                Aptechka.SetJob(unit, config.AggroStatus, false)
                local deadorghost = UnitIsGhost(unit) and config.GhostStatus or config.DeadStatus
                Aptechka.SetJob(unit, deadorghost, true)
                Aptechka.SetJob(unit,config.HealthDificitStatus, false )
                self.isDead = true
                if self.OnDead then self:OnDead() end
            else
                if self.isDead then
                    self.isDead = false
                    if self.OnAlive then self:OnAlive() end
                    Aptechka.ScanAuras(unit)
                    Aptechka.SetJob(unit, config.GhostStatus, false)
                    Aptechka.SetJob(unit, config.DeadStatus, false)
                end
            end
        end
        
    end
end

function Aptechka.UNIT_CONNECTION(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        Aptechka.SetJob(unit, config.OfflineStatus, (not UnitIsConnected(unit)) )
    end
end

function Aptechka.UNIT_POWER(self, event, unit, ptype)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if self.power then
            local mp = UnitPower(unit)/UnitPowerMax(unit)*100
            self.power:SetValue(mp)
        end
    end
end
function Aptechka.UNIT_DISPLAYPOWER(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if self.power and self.power.OnPowerTypeChange then
            local tnum, tname = UnitPowerType(unit)
            self.power:OnPowerTypeChange(tname)
        end
    end
end

-- STAY AWAY FROM DA VOODOO
local vehicleHack = function (self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 1 then return end
    self.OnUpdateCounter = 0
    if not UnitHasVehicleUI(self.parent.unitOwner) then
        if Roster[self.parent.unit] then
            Roster[self.parent.unitOwner] = Roster[self.parent.unit]
            Roster[self.parent.unit] = nil
            self.parent.unit = self.parent.unitOwner
            self:SetScript("OnUpdate",nil)
        end
    end
end
function Aptechka.UNIT_ENTERED_VEHICLE(self, event, unit)
    if not Roster[unit] then return end  
    for self in pairs(Roster[unit]) do
        self.unitOwner = unit
        local vehicleUnit = SecureButton_GetModifiedUnit(self)
        if self.unitOwner == vehicleUnit then return end
        Aptechka:Colorize(nil, unit)
        self.unit = vehicleUnit
        Roster[self.unit] = Roster[self.unitOwner]
        Roster[self.unitOwner] = nil
        if not self.vehicleFrame then self.vehicleFrame = CreateFrame("Frame"); self.vehicleFrame.parent = self end

        self.vehicleFrame:SetScript("OnUpdate",vehicleHack)

    end
end
-- VOODOO ENDS HERE


--Range check
Aptechka.OnRangeUpdate = function (self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 0.5 then return end
    self.OnUpdateCounter = 0
    
    for unit, frames in pairs(Roster) do
        for frame in pairs(frames) do
            if AptechkaUnitInRange(unit) then
                if not frame.inRange then
                    frame.inRange = true
                    Aptechka.FrameSetJob(frame, config.OutOfRangeStatus, false)
                    OORUnits[unit] = nil
                end
            else
                if frame.inRange or frame.inRange == nil then
                    frame.inRange = false
                    Aptechka.FrameSetJob(frame, config.OutOfRangeStatus, true)
                    OORUnits[unit] = true
                end
            end
        end
    end
end

--Aggro
function Aptechka.UNIT_THREAT_SITUATION_UPDATE(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local sit = UnitThreatSituation(unit)
        if sit and sit > 1 then
            Aptechka.SetJob(unit, config.AggroStatus, true)
        else
            Aptechka.SetJob(unit, config.AggroStatus, false)
        end
    end
end

-- maintanks, resize
function Aptechka.CheckLFDTank( self,unit )
    if not config.MainTankStatus then return end
    Aptechka.SetJob(unit, config.MainTankStatus, UnitGroupRolesAssigned(unit) == "TANK") 
end
function Aptechka.RAID_ROSTER_UPDATE(self,event,arg1)
    if not InCombatLockdown() then
        if config.resize then
            if GetNumRaidMembers() > config.resize.after then
                for i = 1, config.maxgroups do
                    group_headers[i]:SetScale(config.resize.to)
                end
            else
                for i = 1, config.maxgroups do
                    group_headers[i]:SetScale(AptechkaDB.scale)
                end
            end
        end
    end
end

--raid icons
function Aptechka.RAID_TARGET_UPDATE(self, event)
    for unit, frames in pairs(Roster) do
        for self in pairs(frames) do
            local index = GetRaidTargetIndex(unit)
            local icon = self.raidicon
            if icon then
            if index then
                SetRaidTargetIconTexture(icon.texture, index)
                icon:Show()
            else
                icon:Hide()
            end
            end
        end
    end
end

--Target Indicator
function Aptechka.PLAYER_TARGET_CHANGED(self, event)
    local newTargetUnit = guidMap[UnitGUID("target")]
    if newTargetUnit and Roster[newTargetUnit] then
        Aptechka.SetJob(Aptechka.previousTarget, config.TargetStatus, false)
        Aptechka.SetJob(newTargetUnit, config.TargetStatus, true)
        Aptechka.previousTarget = newTargetUnit
    else
        Aptechka.SetJob(Aptechka.previousTarget, config.TargetStatus, false)
    end
end

-- Readycheck
function Aptechka.READY_CHECK(self, event)
    for unit in pairs(Roster) do
        self:READY_CHECK_CONFIRM(event, unit)
    end
end
function Aptechka.READY_CHECK_CONFIRM(self, event, unit)
    local rci = config.ReadyCheck
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local status = GetReadyCheckStatus(unit)
        if not status or not rci.stackcolor[status] then return end
        rci.color = rci.stackcolor[status]
        Aptechka.SetJob(unit, rci, true)
    end
end
function Aptechka.READY_CHECK_FINISHED(self, event)
    for unit in pairs(Roster) do
        Aptechka.SetJob(unit, config.ReadyCheck, false)
    end
end

--applying UnitButton color
function Aptechka.Colorize(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local _,class = UnitClass(unit)
        if class then
            local color = colors[class] -- or { r = 1, g = 1, b = 0}
            self.classcolor = {color.r,color.g,color.b}
        end
    end
end

--UnitButton initialization
local OnAttributeChanged = function(self, name, unit)
    if name ~= "unit" then return end
    local unit = self:GetAttribute("unit")
      
    for unit, frames in pairs(Roster) do
        if frames[self] and self:GetAttribute("unit") ~= unit then
            frames[self] = nil
        end
    end
    
    if self.OnUnitChanged then self:OnUnitChanged(unit) end
    if not unit then return end
    local name, realm = UnitName(unit)
    self.name = utf8sub(name,1,config.cropNamesLen)

    self.guid = UnitGUID(unit)
    self.unit = unit
    Roster[unit] = Roster[unit] or {}
    Roster[unit][self] = true

    guidMap[UnitGUID(unit)] = unit
    for guid, gunit in pairs(guidMap) do
        if not Roster[gunit] or guid ~= UnitGUID(gunit) then guidMap[guid] = nil end
    end
    
    Aptechka:Colorize(nil, unit)
    Aptechka.FrameSetJob(self,config.HealthBarColor,true)
    Aptechka.FrameSetJob(self,config.PowerBarColor,true)
    Aptechka.ScanAuras(unit)
    Aptechka.FrameSetJob(self, config.UnitNameStatus, true)
    Aptechka:UNIT_HEALTH("ONATTR", unit)
    Aptechka:UNIT_POWER("ONATTR", unit)
    Aptechka:UNIT_CONNECTION(nil, unit)
    if not config.disableManaBar then
        Aptechka:UNIT_DISPLAYPOWER(nil, unit)
        Aptechka:UNIT_POWER(nil, unit)
    end
        
    Aptechka:UNIT_THREAT_SITUATION_UPDATE(nil, unit)
    if config.raidIcons then
        Aptechka:RAID_TARGET_UPDATE()
    end
    Aptechka:CheckLFDTank(unit)
    if config.enableIncomingHeals then Aptechka:UNIT_HEAL_PREDICTION(nil,unit) end
end

function Aptechka.CreateHeader(self,group)
    local frameName = "NugRaid"..group
    local xgap = config.unitGap
    local ygap = config.unitGap
    local unitgr = reverse(config.unitGrowth)

    local f = CreateFrame("Button",frameName, UIParent, "SecureGroupHeaderTemplate")

    f:SetAttribute("template", "SecureUnitButtonTemplate")
    f:SetAttribute("templateType", "Button")
    if unitgr == "RIGHT" then
        xgap = -xgap
    elseif unitgr == "TOP" then
        ygap = -ygap
    end
    f:SetAttribute("point", unitgr)
	f:SetAttribute("groupFilter", group)
    f:SetAttribute("showRaid", true)
    f:SetAttribute("xOffset", xgap)
    f:SetAttribute("yOffset", ygap)
    f:SetAttribute("showParty", config.showParty)
    f:SetAttribute("showSolo", config.showSolo)
    f:SetAttribute("showPlayer", true)
    f.initConf = Aptechka.CreateStuff
    f:SetAttribute("initialConfigFunction", self.initConfSnippet)
    
    Aptechka:CreateAnchor(f,group)

    return f
end

function Aptechka.CreateAnchor(self,hdr,num)
    local f = CreateFrame("Frame",nil,UIParent)
--~     local backdrop = {
--~         bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
--~         insets = {left = -2, right = -2, top = -2, bottom = -2},
--~     }
--~     f:SetBackdrop(backdrop)
--~     if num == 1 then f:SetBackdropColor(1,0,0,0.8)
--~     else f:SetBackdropColor(0,0,1,0.8) end
    f:SetHeight(20)
    f:SetWidth(20)

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)
    
    t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    if num == 1 then t:SetVertexColor(1, 0, 0) else t:SetVertexColor(0, 1, 0) end
    t:SetAllPoints(f)
    
    local text = f:CreateFontString()
    text:SetPoint("RIGHT",f,"LEFT",0,0)
    text:SetFontObject("GameFontNormal")
    text:SetJustifyH("RIGHT")
    text:SetText(num)

    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetFrameStrata("HIGH")
    hdr:SetPoint("TOPLEFT",f,"TOPRIGHT",0,0)
    anchors[num] = f
    f:Hide()
    
    if not AptechkaDB[skinAnchorsName] then AptechkaDB[skinAnchorsName] = {} end
    if not AptechkaDB[skinAnchorsName][num] then
        if num == 1 then AptechkaDB[skinAnchorsName][num] = { point = "CENTER", x = 0, y = 0 }
        else AptechkaDB[skinAnchorsName][num] = { point = "TOPLEFT", x = 0, y = 60} end
    end
    local san = AptechkaDB[skinAnchorsName][num]
    if num == 1 then
        f.root = true
        f:SetPoint(san.point,UIParent,san.point,san.x,san.y)
    else
        f.prev = anchors[#anchors-1]
        f:SetPoint(san.point,f.prev,san.point,san.x,san.y)
    end
    f.san = san
    
    f:SetScript("OnDragStart",function(self) self:StartMoving() end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        if self.root then
            _,_, self.san.point, self.san.x, self.san.y = self:GetPoint(1)
        else
            self.san.y = self:GetTop() - self.prev:GetTop()
            self.san.x = self:GetLeft() - self.prev:GetLeft()
            self:ClearAllPoints()
            self:SetPoint(san.point,self.prev,san.point,san.x,san.y)
        end
    end)
end

function Aptechka.CreateStuff(header,id)
    local f = header[id]

    f:SetAttribute("toggleForVehicle", true)
    
    ClickCastFrames[f] = true -- autoadd to clique list
    
    if config.TargetBinding ~= false then
        if config.TargetBinding == nil then config.TargetBinding = "type1" end
        f:SetAttribute(config.TargetBinding, "target")
    end
    
    
    if config.ClickCastingMacro then
        f:RegisterForClicks("AnyUp")
        f:SetAttribute("*type*", "macro")
        f:SetAttribute("macrotext", config.ClickCastingMacro)
    end
    
    if config[config.skin] then
        config[config.skin](f)
    else
        config["GridSkin"](f)
    end
    f.self = f
    f.HideFunc = f.HideFunc or function() end
    
    --shit
    if config.disableManaBar or not f.power then
        Aptechka:UnregisterEvent("UNIT_POWER")
        Aptechka:UnregisterEvent("UNIT_MAXPOWER")
        Aptechka:UnregisterEvent("UNIT_DISPLAYPOWER")
        if f.power and f.power.OnPowerTypeChange then f.power:OnPowerTypeChange("none") end
        f.power = nil
    end
    
    if f.raidicon then
        f.raidicon.texture:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]
    end
    
        f:SetScript("OnEnter", function(self)
            if self.OnMouseEnterFunc then self:OnMouseEnterFunc() end
            if UnitAffectingCombat("player") then return end
            UnitFrame_OnEnter(self)
            self:SetScript("OnUpdate", UnitFrame_OnUpdate)
        end)
        f:SetScript("OnLeave", function(self)
            if self.OnMouseLeaveFunc then self:OnMouseLeaveFunc() end
            UnitFrame_OnLeave(self)
            self:SetScript("OnUpdate", nil)
        end)
        
    f:SetScript("OnAttributeChanged", OnAttributeChanged)
end

function Aptechka.SetJob(unit, opts, status)
    if not Roster[unit] then return end
    for frame in pairs(Roster[unit]) do
        Aptechka.FrameSetJob(frame, opts, status)
    end
end

function Aptechka.FrameSetJob(frame, opts, status)
        if opts and opts.assignto then
        for _, slot in ipairs(opts.assignto) do
            local self = frame[slot]
            if self then
            if opts.isMissing then status = not status end
            if not self.jobs then self.jobs = {} end
            if status then
                self.jobs[opts.name] = opts
            else
                self.jobs[opts.name] = nil
            end
            
            if next(self.jobs) then
                local max
                local max_priority = 0
                for name, opts in pairs(self.jobs) do
                    if not opts.priority then opts.priority = 80 end
                    if max_priority < opts.priority then
                        max_priority = opts.priority
                        max = name
                    end
                end
                if self ~= frame then self:Show() end   -- taint if we show protected unitbutton frame
                if self.SetJob  then self:SetJob(self.jobs[max]) end
                self.currentJob = self.jobs[max]
                
            else
                if self.HideFunc then self:HideFunc() else self:Hide() end
                self.currentJob = nil
            end
            end
        end
        end
end


local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable
function Aptechka.ScanAuras(unit)
    for auraname,opts in pairs(auras) do
        name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(unit, auraname, nil, opts.type)
        if name then
            if opts.stackcolor then
                opts.color = opts.stackcolor[count]
            end
            if opts.foreigncolor then
                opts.isforeign = (caster ~= "player")
            end
            opts.expirationTime = expirationTime
            opts.duration = duration
            opts.texture = opts.texture or icon
            opts.stacks = count
            Aptechka.SetJob(unit, opts, true)
        else
            Aptechka.SetJob(unit, opts, false)
        end
    end
end

function Aptechka.UNIT_AURA(self, event, unit)
    if not Roster[unit] then return end
    Aptechka.ScanAuras(unit)
    Aptechka.ScanDispels(unit)
end

function Aptechka.ScanDispels(unit)
    if dtypes then
        if UnitAura(unit, 1, "HARMFUL|RAID") then
            for _,opts in pairs(dtypes) do
                opts.gotone = false
            end
            for i = 1, 100 do
                name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(unit, i, "HARMFUL|RAID")
                if not name then break end
                if dtypes[debuffType] then
                    local opts = dtypes[debuffType]
                    opts.gotone = true
                    opts.start = expirationTime - duration
                    opts.duration = duration
                    opts.stacks = count
                    opts.texture = icon
                end
            end
            for _,opts in pairs(dtypes) do
                Aptechka.SetJob(unit, opts, opts.gotone)
            end
        else
            for _,opts in pairs(dtypes) do
                Aptechka.SetJob(unit, opts, false)
            end
        end
    end
end

local ParseOpts = function(str)
    local fields = {}
    for opt,args in string.gmatch(str,"(%w*)%s*=%s*([%w%,%-%_%.%:%\\%']+)") do
        fields[opt:lower()] = tonumber(args) or args
    end
    return fields
end
function Aptechka.SlashCmd(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
      |cff00ff00/aptechka|r lock
      |cff00ff00/aptechka|r unlock
      |cff00ff00/aptechka|r unlock|cffff7777all|r
      |cff00ff00/aptechka|r reset|r
      |cff00ff00/aptechka|r scale <0-2+>
      |cff00ff00/aptechka|r setpos <point=center x=0 y=0>
      |cff00ff00/aptechka|r load <setname>
      |cff00ff00/aptechka|r charspec
      |cff00ff00/aptechka|r toggle | show | hide
      |cff00ff00/aptechka|r togglegroup <1-8>]]
    )end
    if k == "unlockall" then
        for _,anchor in ipairs(anchors) do
            anchor:Show()
        end
    end
    if k == "unlock" then
        anchors[1]:Show()
    end
    if k == "lock" then
        for _,anchor in ipairs(anchors) do
            anchor:Hide()
        end
    end
    if k == "reset" then
        anchors[1].san.point = "CENTER"
        anchors[1].san.x = 0
        anchors[1].san.y = 0
        anchors[1]:ClearAllPoints()
        anchors[1]:SetPoint(anchors[1].san.point, UIParent, anchors[1].san.point, anchors[1].san.x, anchors[1].san.y)
    end
    if k == "scale" then
        local s = tonumber(v)
        if not s then
            print(AptechkaString.."Current scale = "..AptechkaDB.scale)
            return
        end
        AptechkaDB.scale = s
        for i = 1, config.maxgroups do
            group_headers[i]:SetScale(s)
        end
    end
    if k == "togglegroup" then
        local group = tonumber(v)
        if group then
            local hdr = group_headers[group]
            if hdr:IsVisible() then
                hdr:Hide()
            else
                hdr:Show()
            end
        end
    end
    if k == "toggle" then
        if group_headers[1]:IsVisible() then k = "hide" else k = "show" end
    end
    if k == "show" then
        for i=1,config.maxgroups do
            group_headers[i]:Show()
        end
    end
    if k == "hide" then
        for i=1,config.maxgroups do
            group_headers[i]:Hide()
        end
    end
    if k == "load" then
        local add = config.LoadableDebuffs[v]
        if v == "" then
            print("Spell sets:")
            for k,v in pairs(config.LoadableDebuffs) do
                print(k)
            end return
        end
        if add then
            if loaded[v] then return end
            add()
            print(AptechkaString..v.." loaded.")
            loaded[v] = true
        else
            print(AptechkaString..v.." doesn't exist")
        end
    end
    if k == "setpos" then
        local fields = ParseOpts(v)
        if not next(fields) then print("Usage: /apt setpos point=center x=0 y=0") return end
        local point,x,y = string.upper(fields['point'] or "CENTER"), fields['x'] or 0, fields['y'] or 0
        anchors[1].san.point = point
        anchors[1].san.x = x
        anchors[1].san.y = y
        anchors[1]:ClearAllPoints()
        anchors[1]:SetPoint(point, UIParent, point, x, y)
    end
    if k == "charspec" then
        local user = UnitName("player").."@"..GetRealmName()
        if AptechkaDB_Global.charspec[user] then AptechkaDB_Global.charspec[user] = nil
        else AptechkaDB_Global.charspec[user] = true
        end
        print (AptechkaString..(AptechkaDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload",0.7,1,0.7)
    end
end