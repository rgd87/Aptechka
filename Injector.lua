Injector = CreateFrame("Frame","Injector",UIParent)

Injector:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

InjectorConfig.SetupIndicators = InjectorConfig.SetupIndicators or {}

InjectorConfig.showParty = (InjectorConfig.showParty == nil) or InjectorConfig.showParty
InjectorConfig.unitGap = InjectorConfig.unitGap or 10
InjectorConfig.groupGap = InjectorConfig.groupGap or 10
InjectorConfig.unitGrowth = InjectorConfig.unitGrowth or "RIGHT"
InjectorConfig.groupGrowth = InjectorConfig.groupGrowth or "TOP"
InjectorConfig.resize = InjectorConfig.resize or { after = 27, to = 0.8 } -- = if number of players in raid exeeds 27 then resize to 0.8
InjectorConfig.anchorpoint = InjectorConfig.anchorpoint or "BOTTOMLEFT"
InjectorConfig.outOfRangeAlpha = InjectorConfig.outOfRangeAlpha or 0.4
InjectorConfig.incomingHealTimeframe = InjectorConfig.incomingHealTimeframe or 1.5
InjectorConfig.IndicatorAuras = InjectorConfig.IndicatorAuras or {}
InjectorConfig.skin = InjectorConfig.skin or "GridSkin"
local InjectorUnitInRange = InjectorConfig.UnitInRangeFunc or UnitInRange

local auras = InjectorConfig.IndicatorAuras
local dtypes = InjectorConfig.DebuffTypes
local traceheals = InjectorConfig.TraceHeals
local colors = setmetatable(InjectorConfig.Colors or {},{ __index = function(t,k) return RAID_CLASS_COLORS[k] end })
local OORUnits = setmetatable({},{__mode = 'k'})
local inCL = setmetatable({},{__index = function (t,k) return 0 end})
local buffer = {}
local loaded = {}

if not ClickCastFrames then
		ClickCastFrames = {}
	end
local InjectorString = "|cffff7777Injector: |r"
local Roster = {}
local guidMap = {}
local group_headers = {}

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitAura = UnitAura
local UnitAffectingCombat = UnitAffectingCombat
local bit_band = bit.band
local _, helpers = ...
local utf8sub = helpers.utf8sub
local reverse = helpers.Reverse
local InjectorDB = {}

local QuickHealth
local HealComm

Injector:RegisterEvent("ADDON_LOADED")
function Injector.ADDON_LOADED(self,event,arg1)
    if arg1 == "Injector" then
    
        InjectorDB_Global = InjectorDB_Global or {}
        InjectorDB_Char = InjectorDB_Char or {}
        InjectorDB_Global.charspec = InjectorDB_Global.charspec or {}
        user = UnitName("player").."@"..GetRealmName()
        if InjectorDB_Global.charspec[user] then
            setmetatable(InjectorDB,{ __index = function(t,k) return InjectorDB_Char[k] end, __newindex = function(t,k,v) rawset(InjectorDB_Char,k,v) end})
        else
            setmetatable(InjectorDB,{ __index = function(t,k) return InjectorDB_Global[k] end, __newindex = function(t,k,v) rawset(InjectorDB_Global,k,v) end})
        end

        InjectorDB.pos = InjectorDB.pos or {}
        InjectorDB.pos.x = InjectorDB.pos.x or 0
        InjectorDB.pos.y = InjectorDB.pos.y or 0
        InjectorDB.pos.point = InjectorDB.pos.point or "CENTER"
        
        InjectorDB.pet_pos = InjectorDB.pet_pos or {}
        InjectorDB.pet_pos.x = InjectorDB.pet_pos.x or 0
        InjectorDB.pet_pos.y = InjectorDB.pet_pos.y or 0
        InjectorDB.pet_pos.point = InjectorDB.pet_pos.point or "CENTER"
        
        InjectorDB.scale = InjectorDB.scale or 1
        
        if InjectorConfig.disableBlizzardParty then
            helpers.DisableBlizzParty()
        end
    
        if InjectorConfig.enableIncomingHeals then
            self:RegisterEvent("UNIT_HEAL_PREDICTION")
--~             HealComm = LibStub:GetLibrary("LibHealComm-4.0",true);
--~             if HealComm then
--~                 if InjectorConfig.incomingHealIgnoreHots then
--~                     HealComm.InjectorHealType = HealComm.CASTED_HEALS
--~                 else    
--~                     HealComm.InjectorHealType = HealComm.ALL_HEALS
--~                     HealComm.RegisterCallback(self, "HealComm_HealUpdated", "HealUpdated");     -- hots
--~                 end
--~                 HealComm.RegisterCallback(self, "HealComm_HealStarted", "HealUpdated");
--~                 HealComm.RegisterCallback(self, "HealComm_HealStopped", "HealUpdated");
--~             end
        end
        if InjectorConfig.useQuickHealth then
            QuickHealth = LibStub and LibStub("LibQuickHealth-2.0", true)
            if QuickHealth then
                UnitHealth = QuickHealth.UnitHealth
                Injector.UnitHealthUpdated = function(self, event, unit, h, hm)
                    if Roster[unit] then
                        self:UNIT_HEALTH(nil, unit)
                    end
                end
                QuickHealth.RegisterCallback(self, "UnitHealthUpdated")
            end
        end
        
        self.initConfSnippet = string.format([[
            self:SetWidth(%d)
            self:SetHeight(%d)
            self:SetScale(%d)
        ]], InjectorConfig.width, InjectorConfig.height, InjectorConfig.scale)..[[
            local id = tonumber(self:GetName():match(".+UnitButton(%d)"))
            owner:CallMethod("initConf",id)    
        ]]
        
        self:RegisterEvent("UNIT_HEALTH")
        self:RegisterEvent("UNIT_MAXHEALTH")
        Injector.UNIT_MAXHEALTH = Injector.UNIT_HEALTH
        self:RegisterEvent("UNIT_CONNECTION")
        
        if not InjectorConfig.disableManaBar then
            self:RegisterEvent("UNIT_POWER")
            self:RegisterEvent("UNIT_MAXPOWER")
            self:RegisterEvent("UNIT_DISPLAYPOWER")
            Injector.UNIT_MAXPOWER = Injector.UNIT_POWER
        end
        if InjectorConfig.AggroStatus then
            self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
        end
        if InjectorConfig.ReadyCheck then
            self:RegisterEvent("READY_CHECK")
            self:RegisterEvent("READY_CHECK_CONFIRM")
            self:RegisterEvent("READY_CHECK_FINISHED")
        end
        if InjectorConfig.TargetStatus then
            self.previousTarget = "player"
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
        end
        if InjectorConfig.MainTankStatus then
            self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
			self:RegisterEvent("PARTY_MEMBERS_CHANGED")
            self.PLAYER_ROLES_ASSIGNED = self.UpdateMainTanks
            self.PARTY_MEMBERS_CHANGED = self.UpdateMainTanks
        end
        
        self:RegisterEvent("UNIT_AURA")
        
        if InjectorConfig.TraceHeals then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
        
        self:RegisterEvent("RAID_ROSTER_UPDATE")
        
        if not InjectorConfig.raidIcons or not InjectorConfig.SetupIcons.raidicon then
            InjectorConfig.SetupIcons.raidicon = nil
        else
            self:RegisterEvent("RAID_TARGET_UPDATE")
        end
        
        self:RegisterEvent("UNIT_ENTERED_VEHICLE")
        self:RegisterEvent("UNIT_EXITED_VEHICLE")

        
        self.anchor = self:CreateAnchor("pos")
        
        InjectorConfig.maxgroups = InjectorConfig.maxgroups or 8
        
        
        local arrangeHeaders = function(prv_group, notreverse)
                local p1, p2
                local xgap = 0
                local ygap = InjectorConfig.groupGap
                local point, direction = reverse(InjectorConfig.unitGrowth) 
                local grgrowth = notreverse and reverse(InjectorConfig.groupGrowth) or InjectorConfig.groupGrowth
                if grgrowth == "TOP" then
                    if direction == "VERTICAL" then point = "" end
                    p1 = "BOTTOM"..point; p2 = "TOP"..point;
                elseif grgrowth == "BOTTOM" then
                    if direction == "VERTICAL" then point = "" end
                    p2 = "BOTTOM"..point; p1 = "TOP"..point
                    ygap = -ygap
                elseif grgrowth == "RIGHT" then
                    if direction == "HORIZONTAL" then point = "" end
                    p1 = point.."LEFT"; p2 = point.."RIGHT"
                    xgap, ygap = ygap, xgap
                elseif grgrowth == "LEFT" then
                    if direction == "HORIZONTAL" then point = "" end
                    p2 = point.."LEFT"; p1 = point.."RIGHT"
                    xgap, ygap = -ygap, xgap
                end
                return p1, prv_group, p2, xgap, ygap
        end        
        
        local i = 1
        while (i <= InjectorConfig.maxgroups) do
            local f  = Injector:CreateHeader(i)
            
    
            group_headers[i] = f
            if i == 1 then
                f:SetPoint(InjectorConfig.anchorpoint, self.anchor, reverse(InjectorConfig.anchorpoint), 0, 0)
--~                 f:SetPoint(InjectorConfig.anchorpoint, self.backdrop, InjectorConfig.anchorpoint, 0, 0)
                f:SetAttribute("showParty", InjectorConfig.showParty)
                f:SetAttribute("showSolo", InjectorConfig.showSolo)
                f:SetAttribute("showPlayer", true)
            else
                f:SetPoint(arrangeHeaders(group_headers[i-1]))
            end
            f:SetScale(InjectorDB.scale)
            f:Show()
            i = i + 1
        end
        
        --pet module
        if InjectorPet then
            local pets = InjectorPet:Init()
            if InjectorConfig.petFramesSeparation then
                self.petanchor = self:CreateAnchor("pet_pos")
                pets:SetPoint(InjectorConfig.anchorpoint, self.petanchor, reverse(InjectorConfig.anchorpoint), 0, 0)
            else
                -- damn pets
                pets:SetPoint(arrangeHeaders(group_headers[1], true))
            end
        end
        
        Injector:SetScript("OnUpdate",Injector.OnRangeUpdate)
        Injector:Show()
        
        SLASH_INJECTOR1= "/injector"
        SLASH_INJECTOR2= "/inj"
        SlashCmdList["INJECTOR"] = Injector.SlashCmd
    end
end

local HealTextStatus = { name = "IncHealText", priority = 15 }
function Injector.UNIT_HEAL_PREDICTION(self,event,unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
                --local heal = HealComm:GetHealAmount(guid, HealComm.InjectorHealType, GetTime()+InjectorConfig.incomingHealTimeframe)
                local heal = UnitGetIncomingHeals(unit)
                self.incoming:SetValue(  heal and self.hp:GetValue()+(heal/UnitHealthMax(unit)*100) or 0)
                if InjectorConfig.incomingHealDisplayAmount then
                        if heal and heal > 0 then
                            self.text2.jobs[HealTextStatus.name] = HealTextStatus
                        else
                            self.text2.jobs[HealTextStatus.name] = nil
                        end
                        Injector.UpdateStatus(self.text2, "text", heal and ("%.1fk"):format( heal / 1e3) )
                end
                if InjectorConfig.IncomingHealStatus then
                    if heal and heal > 0 then
                        Injector.UpdateAura(unit, InjectorConfig.IncomingHealStatus, true)
                    else
                        Injector.UpdateAura(unit, InjectorConfig.IncomingHealStatus, false)
                    end
                end
    end
end


--Health Text string updates
function Injector.UpdateHealthText(self, h, hm)
        if hm - h > 1000 then
            self.text:SetText(("%.1fk"):format( (h-hm) / 1e3))
        else
            self.text:SetText(self.name)
        end
end

local DeadStatus = { name = "DEAD", text = "DEAD", priority = 20}
local GhostStatus = { name = "GHOST", text = "GHOST", priority = 22}
local OfflineStatus = { name = "OFFLINE", text = "OFFLINE",  priority = 30}
function Injector.UNIT_HEALTH(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local h,hm = UnitHealth(unit), UnitHealthMax(unit)
        Injector.UpdateHealthText(self, h, hm)
        self.hp:SetValue(h/hm*100)
        
        if event then -- quickhealth calls this function without event
            if UnitIsDeadOrGhost(unit) then
                self.hp.bg:Hide()
                Injector.UpdateAura(unit, InjectorConfig.AggroStatus, false)
                local opts = UnitIsGhost(unit) and GhostStatus or DeadStatus
                self.text:SetText(self.name)
                self.text2.jobs[opts.name] = opts
            else
                if not self.hp.bg:IsVisible() then
                    self.hp.bg:Show()
                    Injector.ScanAuras(unit)
                    Injector.UpdateHealthText(self, h, hm)
                    self.text2.jobs[DeadStatus.name] = nil
                    self.text2.jobs[GhostStatus.name] = nil
                end
            end
            Injector.UpdateStatus(self.text2, "text")
        end
        
    end
end

function Injector.UNIT_CONNECTION(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if not UnitIsConnected(unit) then
            self.text2.jobs[OfflineStatus.name] = OfflineStatus
        else
            self.text2.jobs[OfflineStatus.name] = nil
        end
    end
end

function Injector.UNIT_POWER(self, event, unit, ptype)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if not self.mb:IsVisible() then return end
        self.mb:SetValue(UnitPower(unit)/UnitPowerMax(unit)*100)
    end
end

local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable
function Injector.ScanAuras(unit)
    for auraname,opts in pairs(auras) do
        name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(unit, auraname, nil, opts.type)
        if name then
            if opts.stackcolor then
                opts.color = opts.stackcolor[count]
            end
            if opts.foreigncolor then
                opts.isforeign = (caster ~= "player")
            end
            opts.start = expirationTime - duration
            opts.duration = duration
            opts.texture = opts.texture or icon
            opts.stacks = count
            Injector.UpdateAura(unit, opts, true)
        else
            Injector.UpdateAura(unit, opts, false)
        end
    end
end
function Injector.ScanDispels(unit)
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
                Injector.UpdateAura(unit, opts, opts.gotone)
            end
        else
            for _,opts in pairs(dtypes) do
                Injector.UpdateAura(unit, opts, false)
            end
        end
    end
end

function Injector.UNIT_AURA(self, event, unit)
    if not Roster[unit] then return end
    Injector.ScanAuras(unit)
    Injector.ScanDispels(unit)
end

--~ local function VehicleHack(self, time)
--~     self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
--~     if self.OnUpdateCounter < 0.5 then return end
--~     self.OnUpdateCounter = 0
--~     self.count = (self.count or 0) +1
--~     
--~     if( self.count >= 6 or not UnitHasVehicleUI(self.unitOwner) ) then
--~         if self.unit ~=  self.unitOwner then
--~             Roster[self.unitOwner] = Roster[self.unit]
--~             Injector:Colorize(nil, self.unitOwner)
--~             Roster[self.unit] = nil
--~             self.unit = self.unitOwner
--~             self.unitOwner = nil
--~             Injector:UNIT_HEALTH(nil,self.unit)
--~             self:SetScript("OnUpdate", nil) 
--~         end
--~         Injector:UNIT_POWER(nil,self.unit)
--~     elseif( UnitIsConnected(self.unit) or UnitHealthMax(self.unit) > 0 ) then
--~         if self.unit ~=  self.unitOwner then
--~             Injector:Colorize(nil, self.unitOwner)
--~             Roster[self.unit] = Roster[self.unitOwner]
--~             Roster[self.unitOwner] = nil
--~             Injector:UNIT_HEALTH(nil,self.unit)
--~             self:SetScript("OnUpdate", nil)
--~         end
--~     end
--~ end

--~ local function TranslateModifiedUnit(unit)
--~     if unit == "player" then return "pet" end
--~     return gsub("raid1","(%w+)(%d+)","%1pet%2")
--~ end

function Injector.UNIT_ENTERED_VEHICLE(self, event, unit)
    if not Roster[unit] then return end
    Injector:Colorize(nil, unit)
--~     for self in pairs(Roster[unit]) do
--~         self.unitOwner = unit
--~         self.unit = SecureButton_GetModifiedUnit(self)
--~         self:SetScript("OnUpdate",VehicleHack)
--~     end
end
function Injector.UNIT_EXITED_VEHICLE(self, event, unit)
--~     local modunit = TranslateModifiedUnit(unit)
    if not Roster[unit] then return end
    Injector:Colorize(nil, unit)
end
--Range check
Injector.OnRangeUpdate = function (self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 0.5 then return end
    self.OnUpdateCounter = 0
    
    for unit, frames in pairs(Roster) do
        for frame in pairs(frames) do
--~             local unit1 = frame.unit
            if InjectorUnitInRange(unit) then
                frame:SetAlpha(1)
                OORUnits[unit] = nil
            else
                frame:SetAlpha(InjectorConfig.outOfRangeAlpha)
                OORUnits[unit] = true
            end
        end
    end
end

--Aggro
function Injector.UNIT_THREAT_SITUATION_UPDATE(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local sit = UnitThreatSituation(unit)
        if sit and sit > 1 then
            Injector.UpdateAura(unit, InjectorConfig.AggroStatus, true)
        else
            Injector.UpdateAura(unit, InjectorConfig.AggroStatus, false)
        end
    end
end

-- maintanks, resize
function Injector.UpdateMainTanks( self )
    if InjectorConfig.MainTankStatus then
        for unit in pairs(Roster) do
            if UnitExists(unit) and (GetPartyAssignment("MAINTANK", unit) or UnitGroupRolesAssigned(unit) == "TANK") then
                Injector.UpdateAura(unit, InjectorConfig.MainTankStatus, true)
            else
                Injector.UpdateAura(unit, InjectorConfig.MainTankStatus, false)
            end
        end
    end
end
function Injector.RAID_ROSTER_UPDATE(self,event,arg1)
    if not InCombatLockdown() then
        if InjectorConfig.resize then
            if GetNumRaidMembers() > InjectorConfig.resize.after then
                for i = 1, InjectorConfig.maxgroups do
                    group_headers[i]:SetScale(InjectorConfig.resize.to)
                end
            else
                for i = 1, InjectorConfig.maxgroups do
                    group_headers[i]:SetScale(InjectorDB.scale)
                end
            end
        end
    end
    self:UpdateMainTanks()
end

--raid icons
function Injector.RAID_TARGET_UPDATE(self, event)
    for unit, frames in pairs(Roster) do
        for self in pairs(frames) do
            local index = GetRaidTargetIndex(unit)
            local icon = self.icons.raidicon
            if index then
                SetRaidTargetIconTexture(icon.texture, index)
                icon:Show()
            else
                icon:Hide()
            end
        end
    end
end

function Injector.PLAYER_TARGET_CHANGED(self, event)
    local newTargetUnit = guidMap[UnitGUID("target")]
    if newTargetUnit and Roster[newTargetUnit] then
        Injector.UpdateAura(Injector.previousTarget, InjectorConfig.TargetStatus, false)
        Injector.UpdateAura(newTargetUnit, InjectorConfig.TargetStatus, true)
        Injector.previousTarget = newTargetUnit
    else
        Injector.UpdateAura(Injector.previousTarget, InjectorConfig.TargetStatus, false)
    end
end

-- readycheck
function Injector.READY_CHECK(self, event)
    for unit in pairs(Roster) do
        self:READY_CHECK_CONFIRM(event, unit)
    end
end
function Injector.READY_CHECK_CONFIRM(self, event, unit)
    local rci = InjectorConfig.ReadyCheck
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local status = GetReadyCheckStatus(unit)
        if not status or not rci.stackcolor[status] then return end
        rci.color = rci.stackcolor[status]
        Injector.UpdateAura(unit, rci, true)
    end
end
function Injector.READY_CHECK_FINISHED(self, event)
    for unit in pairs(Roster) do
        Injector.UpdateAura(unit, InjectorConfig.ReadyCheck, false)
    end
end

--power type changed
function Injector.UNIT_DISPLAYPOWER(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local x,y,p1,p2
        if UnitPowerType(unit) == 0 then
            self.mb:Show()
            self.mb.bg:Show()

            self.hp:ClearAllPoints()
            self.hp:SetPoint(InjectorConfig.mbst.p1,self,InjectorConfig.mbst.p1, -InjectorConfig.mbst.x, InjectorConfig.mbst.y)
            self.hp:SetPoint(InjectorConfig.mbst.p3,self,InjectorConfig.mbst.p3, 0, 0)
            self.hp.bg:ClearAllPoints()
            self.hp.bg:SetAllPoints(self.hp)
            self.text:SetPoint("CENTER",InjectorConfig.mbst.x/2,0)
        else
            
            self.hp:ClearAllPoints()
            self.hp:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
            self.hp:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
            self.hp.bg:ClearAllPoints()
            self.hp.bg:SetAllPoints(self.hp)
            self.text:SetPoint("CENTER",0,0)
        
            self.mb:Hide()
            self.mb.bg:Hide()
        end
    end
end

--applying UnitButton color
function Injector.Colorize(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if UnitHasVehicleUI(unit) then
            local color = colors["VEHICLE"] or { r = 0, g = 1, b = 0 }
            self:SetColor(color.r,color.g,color.b)
        else
            local _,class = UnitClass(unit)
            if class then
                local color = colors[class] -- or { r = 1, g = 1, b = 0}
                self:SetColor(color.r,color.g,color.b)
            end
        end
    end
end

--UnitButton initialization
local OnAttributeChanged = function(self, name, unit)
--~     if name ~= "unit" then return end
    local unit = self:GetAttribute("unit")
      
        for unit, frames in pairs(Roster) do
            if frames[self] and self:GetAttribute("unit") ~= unit then
                frames[self] = nil
            end
        end
        
        if not unit then return end

        local name, realm = UnitName(unit)
        self.name = utf8sub(name,1,InjectorConfig.cropNamesLen)

        self.guid = UnitGUID(unit)
        self.unit = unit
        Roster[unit] = Roster[unit] or {}
        Roster[unit][self] = true

        guidMap[UnitGUID(unit)] = unit
        for guid, gunit in pairs(guidMap) do
            if not Roster[gunit] or guid ~= UnitGUID(gunit) then guidMap[guid] = nil end
        end
        
        Injector:Colorize(nil, unit)
        Injector.ScanAuras(unit)
        Injector:UNIT_HEALTH("ONATTR", unit)
        Injector:UNIT_CONNECTION(nil, unit)
        if not InjectorConfig.disableManaBar then
            Injector:UNIT_DISPLAYPOWER(nil, unit)
            Injector:UNIT_POWER(nil, unit)
        end
        
        Injector:UNIT_THREAT_SITUATION_UPDATE(nil, unit)
        if InjectorConfig.SetupIcons.raidicon then
            Injector:RAID_TARGET_UPDATE()
        end
        Injector:UpdateMainTanks()
        if InjectorConfig.enableIncomingHeals then Injector:UNIT_HEAL_PREDICTION(nil,unit) end
end

--building header, frame, anchor
function Injector.CreateHeader(self,group)
    local frameName = "NR"..group
    local xgap = InjectorConfig.unitGap
    local ygap = InjectorConfig.unitGap
    local unitgr = reverse(InjectorConfig.unitGrowth)

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
    
    --f.initialConfigFunction = Injector.CreateFrame
    f.initConf = Injector.CreateStuff
    f:SetAttribute("initialConfigFunction", self.initConfSnippet)
    

    return f
end
--function Injector.CreateFrame(f)
function Injector.CreateStuff(header,id)
    local f = header[id]
    
--~     f:SetAttribute("initial-width", InjectorConfig.width)
--~     f:SetAttribute("initial-height", InjectorConfig.height)
--~     f:SetAttribute("initial-scale", InjectorConfig.scale)

    f:SetAttribute("toggleForVehicle", true)
    
    ClickCastFrames[f] = true -- autoadd to clique list
    
    f:SetAttribute("type1", "target")
    
    if InjectorConfig.ClickCastingMacro then
        f:RegisterForClicks("AnyUp")
        f:SetAttribute("*type*", "macro")
        f:SetAttribute("macrotext", InjectorConfig.ClickCastingMacro)
    end
    
    InjectorConfig[InjectorConfig.skin](f)
    
    
    f.SetColor = function(self,r,g,b)
        if not InjectorConfig.invertColor then
            self.hp:SetStatusBarColor(0,0,0,0.8)
            self.hp.bg:SetVertexColor(r,g,b,1)
            self.text:SetTextColor(r,g,b)
        else
            self.hp:SetStatusBarColor(r,g,b,1)
            self.hp.bg:SetVertexColor(r,g,b,0.2)
            self.text:SetTextColor(r*0.75,g*0.75,b*0.75)
        end
    end
    
    if InjectorConfig.mouseoverTooltip and InjectorConfig.mouseoverTooltip ~= "disabled" then
        if InjectorConfig.mouseoverTooltip == "always" then UnitAffectingCombat = function() return false end end
        f:SetScript("OnEnter", function(self)
            if UnitAffectingCombat("player") then return end
            UnitFrame_OnEnter(self)
            self:SetScript("OnUpdate", UnitFrame_OnUpdate)
        end)
        f:SetScript("OnLeave", function(self)
            UnitFrame_OnLeave(self)
            self:SetScript("OnUpdate", nil)
        end)
    end
        
--~     f:SetScript("OnAttributeChanged", OnAttributeChanged)
    f.onUnitChanged = OnAttributeChanged
    f:SetAttribute('refreshUnitChange',[[
        self:CallMethod("onUnitChanged")
    ]])
    
    f.indicators = {}
    for name, opts in pairs(InjectorConfig.SetupIndicators) do
        f.indicators[name] = Injector.CreateIndicator(f, name, opts)
        f.indicators[name].jobs = {}
    end
    
    f.icons = {}
    for name, opts in pairs(InjectorConfig.SetupIcons) do
        f.icons[name] = Injector.CreateIcon(f, name, opts)
        if name == "raidicon" then f.icons[name].texture:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]] end
        f.icons[name].jobs = {}
    end
end
function Injector.CreateAnchor(self, tbl)
    local f = CreateFrame("Frame",nil,UIParent)
    f:SetHeight(20)
    f:SetWidth(20)
    f.cols = cols
    f.filter = filter

    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(2)
    if InjectorConfig.lockedOnStartUp then
        f:Hide()
    else
        f:Show()
    end
    
    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)
    
    t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    t:SetVertexColor(1, 0, 0)
    t:SetAllPoints(f)
    
    f:SetScript("OnDragStart",function(self) self:StartMoving() end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        _,_, InjectorDB[tbl].point, InjectorDB[tbl].x, InjectorDB[tbl].y = self:GetPoint(1)
    end)
    
    f.SetPos = function(self,point, x, y )
        InjectorDB[tbl].point = point
        InjectorDB[tbl].x = x
        InjectorDB[tbl].y = y
        self:ClearAllPoints()
        self:SetPoint(point, UIParent, point, x, y) 
    end
    
    f:SetPos(InjectorDB[tbl].point, InjectorDB[tbl].x, InjectorDB[tbl].y)
    
    return f
end

function Injector.CreateIcon(f,name,opts)
    local icon = CreateFrame("Frame", f:GetName()..name, f)
    icon:SetPoint(opts.point, f, opts.point, opts.xOffset or 0, opts.yOffset or 0 )
    icon:SetWidth(opts.size)
    icon:SetHeight(opts.size)
    icon:SetAlpha(opts.alpha or 1)
    icon:SetFrameLevel(10)
    local texture = f:CreateTexture(f:GetName()..name,"ARTWORK")--CreateFrame("Frame", nil,f)
    texture:SetAllPoints(icon)
    texture:SetParent(icon)
    texture:SetTexCoord(.07, .93, .07, .93)
    
    local cd = CreateFrame("Cooldown",nil,icon)
    if not opts.omnicc then
        cd.noCooldownCount = true -- for OmniCC
    end
    cd:SetReverse(true)
    cd:SetAllPoints(icon)
    
    icon.texture = texture
    icon.cd = cd
    
    if opts.stacktext then
        local stacktext = icon:CreateFontString(nil, "OVERLAY")
        if type(opts.stacktext) ~= "table" then opts.stacktext = {} end
        local sfont = opts.stacktext.font or InjectorConfig.font
        local ssize = opts.stacktext.size or InjectorConfig.fontsize - 2
        local sflags = opts.stacktext.flags or "OUTLINE"
        stacktext:SetFont(sfont, ssize, sflags)
        stacktext:SetWidth(icon:GetWidth())
        stacktext:SetJustifyH("RIGHT")
        local color = opts.stacktext.color or {1,1,1}
        stacktext:SetTextColor(unpack(color))
        stacktext:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT",0,0)
        stacktext:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT",0,0)
        icon.stacktext = stacktext
    end
    
    icon:Hide()
    
    return icon
end

function Injector.CreateIndicator(f, name, opts)
    local ind = CreateFrame("Frame", f:GetName()..name, f)
    if not opts.nobackdrop then
        ind:SetBackdrop{
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
            insets = {left = -2, right = -2, top = -2, bottom = -2},
        }
        ind:SetBackdropColor(0, 0, 0, 1)
    end
    ind:SetPoint(opts.point, f, opts.point, opts.xOffset or 0, opts.yOffset or 0 )
    if opts.size then
        ind:SetWidth(opts.size)
        ind:SetHeight(opts.size)
    else
        ind:SetWidth(opts.width)
        ind:SetHeight(opts.height)
    end
    ind:SetFrameLevel(10)
    
    local it = ind:CreateTexture(nil,"ARTWORK")
    it:SetAllPoints(ind)
    it:SetTexture("Interface\\Addons\\Injector\\white")
    ind.color = it
    
    local cd = CreateFrame("Cooldown",nil,ind)
    if not opts.omnicc then
        cd.noCooldownCount = true -- for OmniCC
    end
    cd:SetReverse(true)
    cd:SetAllPoints(ind)
    ind.cd = cd
    
    local pag = ind:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("Scale")
    pa1:SetScale(2,2)
    pa1:SetDuration(0.2)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Scale")
    pa2:SetScale(0.5,0.5)
    pa2:SetDuration(0.8)
    pa2:SetOrder(2)
    
    ind.pulse = pag
    
    local bag = ind:CreateAnimationGroup()
    local ba1 = bag:CreateAnimation("Alpha")
    ba1:SetChange(1)
    ba1:SetDuration(0.1)
    ba1:SetOrder(1)
    local ba2 = bag:CreateAnimation("Alpha")
    ba2:SetChange(-1)
    ba2:SetDuration(0.7)
    ba2:SetOrder(2)
    
    bag:SetScript("OnFinished",function(self)
        self:GetParent():Hide()
    end)
    
    bag.a2 = ba2
    ind.blink = bag
    
--~     local twag = ind:CreateAnimationGroup()
--~     local twa1 = twag:CreateAnimation("Rotation")
--~     twa1:SetDegrees(20)
--~     twa1:SetDuration(0.2)
--~     twa1:SetSmoothing("OUT")
--~     twa1:SetOrder(1)
--~     local twa2 = twag:CreateAnimation("Rotation")
--~     twa2:SetDegrees(-40)
--~     twa2:SetDuration(0.4)
--~     twa2:SetSmoothing("IN_OUT")
--~     twa2:SetOrder(2)
--~     local twa3 = twag:CreateAnimation("Rotation")
--~     twa3:SetDegrees(20)
--~     twa3:SetDuration(0.2)
--~     twa3:SetSmoothing("IN")
--~     twa3:SetOrder(3)
--~     twag:SetLooping("REPEAT")    
--~     ind.twitch = twag

--~     local bzzag = ind:CreateAnimationGroup()
--~     local bzz1 = bzzag:CreateAnimation("Translation")
--~     bzz1:SetOffset(2,2)
--~     bzz1:SetDuration(0.05)
--~     bzz1:SetOrder(1)
--~     local bzz2 = bzzag:CreateAnimation("Translation")
--~     bzz2:SetOffset(-5,-3)
--~     bzz2:SetDuration(0.08)
--~     bzz2:SetOrder(2)
--~     local bzz3 = bzzag:CreateAnimation("Translation")
--~     bzz3:SetOffset(2,4)
--~     bzz3:SetDuration(0.05)
--~     bzz3:SetOrder(3)
    
--~     local twa1 = twag:CreateAnimation("Rotation")
    
    
--~     if opts.stacktext then
--~         local stacktext = icon:CreateFontString(nil, "OVERLAY")
--~         stacktext:SetFont(InjectorConfig.font, opts.size)
--~         stacktext:SetAllPoints(ind)
--~         stacktext:SetJustifyH("CENTER")
--~         ind.stacktext = stacktext
--~     end
    
    ind:Hide()
    
    return ind
end

function Injector.UpdateAura(unit, opts, status)
    if not Roster[unit] then return end
    for frame in pairs(Roster[unit]) do
        if opts.indicator then
            for _, iname in ipairs(opts.indicator) do
                local self = frame.indicators[iname]
                if self then
                    if opts.isMissing then status = not status end
                    if status then
                        local n = opts.name
                        if opts.fade then n = n.."Fade" end
                        self.jobs[n] = opts
                    else
                        self.jobs[opts.name] = nil
                    end
                    Injector.UpdateStatus(self, "indicator")
                end
            end
        end
        if opts.icon then
            local self = frame.icons[opts.icon]
            if self then
                self.jobs[opts.name] = status and opts or nil
                Injector.UpdateStatus(self, "icon")
            end
        end
--~         if opts.textind then
--~             local self = frame.text2
--~             if self then
--~                 self.jobs[opts.name] = status and opts or nil
--~                 Injector.UpdateStatus(self, "textind")
--~             end
--~         end
    end
end

function Injector.UpdateStatus(self, statustype, arg1)
    if next(self.jobs) then -- if not empty
        local max
        --if self.currentJob and self.jobs[self.currentJob] then max = self.currentJob end
        local max_priority = 0--max and self.jobs[max].priority
        for name, opts in pairs(self.jobs) do
            if not opts.priority then opts.priority = 80 end
            if max_priority < opts.priority then
                max_priority = opts.priority
                max = name
            end
        end
        local job = self.jobs[max]
        if statustype == "indicator" then
            local color
            if job.foreigncolor and job.isforeign then
                color = job.foreigncolor
            else
                color = job.color or { 1,1,1,1 }
            end
            self.color:SetVertexColor(color[1],color[2],color[3],color[4] or 1)
            self:SetBackdropColor(0,0,0,color[4] or 1)
            if job.pulse and self.currentPriority and job.priority > self.currentPriority then
                if not self.pulse:IsPlaying() then self.pulse:Play() end
            end
            self.currentPriority = job.priority
        end
        if statustype == "icon" then
            local texture = job.texture
            self.texture:SetTexture(texture)
            if self.stacktext and job.stacks then self.stacktext:SetText(job.stacks > 1 and job.stacks or "") end
        end
        if statustype == "text" then
            local text = arg1 or job.text
            if text then
                self:SetText(text)
                self:Show()
            end
            return
        end
        
        self:Show()
        if job.fade then
            self.blink.a2:SetDuration(job.fade)
            if not self.blink:IsPlaying() then self.blink:Play() end
--~             self:SetAlpha(1);
--~             self.fading = true
--~             
--~             UIFrameFade(self, {
--~                 mode = "OUT",
--~                 timeToFade = job.fade,
--~                 finishedFunc = function(self, name)
--~                     --print("hiding")
--~                     self:Hide();
--~                     self:SetAlpha(1);
--~                     self.jobs[name] = nil;
--~                     self.fading = false;
--~                     Injector.UpdateStatus(self, "indicator");
--~                 end,
--~                 finishedArg1 = self,
--~                 finishedArg2 = max,
--~             });
        end
        
        if job.showDuration and job.start then
            self.cd:SetCooldown(job.start, job.duration)
            self.cd:Show()
        else
            self.cd:Hide()
        end
    else
        self.currentPriority = 0
        self:Hide()
    end
end

local ParseOpts = function(str)
    local fields = {}
    for opt,args in string.gmatch(str,"(%w*)%s*=%s*([%w%,%-%_%.%:%\\%']+)") do
        fields[opt:lower()] = tonumber(args) or args
    end
    return fields
end
function Injector.SlashCmd(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
      |cff00ff00/injector lock|r
      |cff00ff00/injector unlock|r
      |cff00ff00/injector reset|r
      |cff00ff00/injector scale <0-2+>|r
      |cff00ff00/injector setpos <point=center x=0 y=0>|r
      |cff00ff00/injector load <setname>
      |cff00ff00/injector charspec|r
      |cff00ff00/injector toggle | show | hide
      |cff00ff00/injector togglegroup <1-8>]]
    )end
    if k == "unlock" then
        Injector.anchor:Show()
        if InjectorPet and Injector.petanchor then Injector.petanchor:Show() end
    end
    if k == "lock" then
        Injector.anchor:Hide()
        if InjectorPet and Injector.petanchor then Injector.petanchor:Hide() end
    end
    if k == "reset" then
        Injector.anchor:SetPos("CENTER", 0, 0)
        if InjectorPet then
            Injector.petanchor:ClearAllPoints()
            Injector.petanchor:SetPoint("CENTER",UIParent,"CENTER",0,0)
        end
    end
    if k == "scale" then
        local s = tonumber(v)
        if not s then
            print(InjectorString.."Current scale = "..InjectorDB.scale)
            return
        end
        InjectorDB.scale = s
        for i = 1, InjectorConfig.maxgroups do
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
        for i=1,InjectorConfig.maxgroups do
            group_headers[i]:Show()
        end
    end
    if k == "hide" then
        for i=1,InjectorConfig.maxgroups do
            group_headers[i]:Hide()
        end
    end
    if k == "load" then
        local add = InjectorConfig.LoadableDebuffs[v]
        if v == "" then
            print("Spell sets:")
            for k,v in pairs(InjectorConfig.LoadableDebuffs) do
                print(k)
            end return
        end
        if add then
            if loaded[v] then return end
            add()
            print(InjectorString..v.." loaded.")
            loaded[v] = true
        else
            print(InjectorString..v.." doesn't exist")
        end
    end
    if k == "setpos" then
        local fields = ParseOpts(v)
        if not next(fields) then print("Usage: /inj setpos point=center x=0 y=0") return end
        Injector.anchor:SetPos(string.upper(fields['point'] or "CENTER"), fields['x'] or 0, fields['y'] or 0)
    end
    if k == "charspec" then
        local user = UnitName("player").."@"..GetRealmName()
        if InjectorDB_Global.charspec[user] then InjectorDB_Global.charspec[user] = nil
        else InjectorDB_Global.charspec[user] = true
        end
        print (InjectorString..(InjectorDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload",0.7,1,0.7)
    end
end

if InjectorConfig.enableTraceHeals then

--~ local TraceHealEvents = {}
--~ for name, opts in pairs(traceheals) do
--~     TraceHealEvents[opts.type] = true
--~ end

function Injector.COMBAT_LOG_EVENT_UNFILTERED( self, event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, amount, overhealing, absorbed, critical)    
    if (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
        local opts = traceheals[spellName]
        if opts and eventType == opts.type then
            if guidMap[dstGUID] then
                Injector.UpdateAura(guidMap[dstGUID],opts,true)
            end
        end
    end
end

end

--raid/pvp debuffs loading 
local loader = CreateFrame("Frame")
loader:RegisterEvent("ZONE_CHANGED_NEW_AREA")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
local mapIDs = {
    [610] = "Ruby Sanctum",
    [605] = "Icecrown Citadel",
    [544] = "Trial of the Crusader",
    [530] = "Ulduar",
    [536] = "Naxxramas",
}
loader:SetScript("OnEvent",function (self,event)
    local instance
    local _, instanceType = GetInstanceInfo()
    if instanceType == "arena" or instanceType == "pvp" then
        instance = "PvP"
    else
        instance = mapIDs[GetCurrentMapAreaID()]
    end
    if not instance then return end
    local add = InjectorConfig.LoadableDebuffs[instance]
    if add and not loaded[instance] then
        add()
        print (InjectorString..instance.." debuffs loaded.")
        loaded[instance] = true
    end
end)


if InjectorConfig.useCombatLogFiltering then

local timer = CreateFrame("Frame")
timer.OnUpdateCounter = 0
timer:SetScript("OnUpdate",function(self, time)
    self.OnUpdateCounter = self.OnUpdateCounter + time
    if self.OnUpdateCounter < 1 then return end
    self.OnUpdateCounter = 0
    
    for unit in pairs(buffer) do
        Injector.ScanAuras(unit)
        buffer[unit] = nil
    end
end)

function Injector.UNIT_AURA(self, event, unit)
    if not Roster[unit] then return end    
    Injector.ScanDispels(unit)
    if OORUnits[unit] and inCL[unit] +5 < GetTime() then
        buffer[unit] = true
    end
end

local auraUpdateEvents = {
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
                Injector.ScanAuras(unit) 
            end
        end
    end
end)

end