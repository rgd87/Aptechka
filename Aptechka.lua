Aptechka = CreateFrame("Frame","Aptechka",UIParent)

Aptechka:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

AptechkaUserConfig = setmetatable({},{ __index = function(t,k) return AptechkaDefaultConfig[k] end })
-- When AptechkaUserConfig __empty__ field is accessed, it will return AptechkaDefaultConfig field

local AptechkaUnitInRange
local auras
local dtypes
local debuffs
local traceheals
local colors
local threshold --incoming heals
local ignoreplayer 

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

local LastCastSentTime
local LastCastTargetName

local AptechkaString = "|cffff7777Aptechka: |r"
local UnitHealth = UnitHealth
local __UnitHealth = UnitHealth
local CLHealth = setmetatable({},{__mode = 'k', __index = function (t,k)
            rawset(t,k, { __UnitHealth(k), 0, 0 } )
            return t[k]
        end })
local CLHealthUpdate
local UnitHealthMax = UnitHealthMax
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitAura = UnitAura
local UnitAffectingCombat = UnitAffectingCombat
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitThreatSituation = UnitThreatSituation
local table_wipe = table.wipe
local SetJob
local FrameSetJob
local DispelFilter

local bit_band = bit.band
local IsInGroup = IsInGroup
local pairs = pairs
local next = next
local _, helpers = ...
Aptechka.helpers = helpers
local utf8sub = helpers.utf8sub
local reverse = helpers.Reverse
local AptechkaDB = {}
local QuickHealth
local CreatePetsFunc

Aptechka:RegisterEvent("PLAYER_LOGIN")
function Aptechka.PLAYER_LOGIN(self,event,arg1)
    local uir = config.UnitInRangeFunc or UnitInRange
    local uir2 = function(unit) --or UnitInRange
        if not IsInGroup()
            then return true
            else return uir(unit)
        end
    end

    AptechkaUnitInRange = uir2
    auras = config.IndicatorAuras or {}
    dtypes = config.DebuffTypes or {}
    debuffs = config.DebuffDisplay or {}
    traceheals = config.TraceHeals or {}
    Aptechka.SetJob = SetJob
    Aptechka.FrameSetJob = FrameSetJob
    threshold = config.incomingHealThreshold or 10000
    ignoreplayer = config.incomingHealIgnorePlayer or false
    colors = setmetatable(config.Colors or {},{ __index = function(t,k) return RAID_CLASS_COLORS[k] end })
    
    AptechkaDB_Global = AptechkaDB_Global or {}
    AptechkaDB_Char = AptechkaDB_Char or {}
    AptechkaDB_Global.charspec = AptechkaDB_Global.charspec or {}
    user = UnitName("player").."@"..GetRealmName()
    if AptechkaDB_Global.charspec[user] then
        AptechkaDB = AptechkaDB_Char
    else
        AptechkaDB = AptechkaDB_Global
    end
    Aptechka.Roster = Roster
    
    if config.disableBlizzardParty then
        helpers.DisableBlizzParty()
    end
    if config.hideBlizzardRaid then
	   -- disable Blizzard party & raid frame if our Raid Frames are loaded
       -- InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
       -- InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
       -- raid
       local hider = CreateFrame("Frame")
       hider:Hide()
       CompactRaidFrameManager:SetParent(hider)
       CompactUnitFrameProfiles:UnregisterAllEvents()
	end

    if config.enableIncomingHeals then
        self:RegisterEvent("UNIT_HEAL_PREDICTION")
    end
    
    if not config[config.skin.."Settings"]
        then config["GridSkinSettings"]()
        else config[config.skin.."Settings"]() -- receiving width and height for current skin
    end
    
    local tbind
    if config.TargetBinding == nil then tbind = "*type1"
    elseif config.TargetBinding == false then tbind = "__none__"
    else tbind = config.TargetBinding end
    
    local ccmacro = config.ClickCastingMacro or "__none__"
    self.initConfSnippet = string.format([=[
        self:SetWidth(%f)
        self:SetHeight(%f)
        
        local hdr = self:GetParent()
        if not hdr:GetAttribute("custom_scale") then hdr:SetScale(%f) end
        
        self:SetAttribute("toggleForVehicle", true)
        local tbind = "%s"
        local ccmacro = "%s"
        if tbind ~= "__none__" then self:SetAttribute(tbind,"target") end
        if ccmacro ~= "__none__" then
            self:SetAttribute("*type*", "macro")
            self:SetAttribute("macrotext", ccmacro)
        end
        
        local ccheader = self:GetParent():GetFrameRef("clickcast_header")
        if ccheader then
            ccheader:SetAttribute("clickcast_button", self)
            ccheader:RunAttribute("clickcast_register")
        end
        
    ]=],config.width, config.height,config.scale,tbind,ccmacro)
    
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_HEALTH_FREQUENT")
    self:RegisterEvent("UNIT_MAXHEALTH")
    Aptechka.UNIT_HEALTH_FREQUENT = Aptechka.UNIT_HEALTH
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
    if config.ResurrectStatus then
        self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    end

    if config.useCombatLogHealthUpdates then
        local CLH = LibStub("LibCLHealth-1.0")
        UnitHealth = function(unit) return CLH:UnitHealth(unit) end
        self:UnregisterEvent("UNIT_HEALTH")
        self:UnregisterEvent("UNIT_HEALTH_FREQUENT")
        -- table.insert(config.HealthBarColor.assignto, "health2")
        CLH.RegisterCallback(self, "COMBAT_LOG_HEALTH", function(event, unit, health)
            return Aptechka:UNIT_HEALTH(nil, unit)
            -- return Aptechka:COMBAT_LOG_HEALTH(nil, unit, health)
        end)
    end
    
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    if config.raidIcons then
        self:RegisterEvent("RAID_TARGET_UPDATE")
    end
    if config.enableVehicleSwap then
        self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    end
    
    if not config.anchorpoint then
        config.anchorpoint = Aptechka:SetAnchorpoint()
    end

    skinAnchorsName = config.useAnchors or config.skin
    local i = 1
    while (i <= config.maxgroups) do
        local f  = Aptechka:CreateHeader(i) -- if second arg is true then it's petgroup
        group_headers[i] = f
        i = i + 1
    end    
    CreatePetsFunc = function()
        local pets  = Aptechka:CreateHeader(9,true)
        group_headers[9] = pets
    end
    if config.petgroup then
        CreatePetsFunc()
    end
    if config.unlocked then anchors[1]:Show() end

    if not next(debuffs) and not next(dtypes) then
        Aptechka.ScanDispels = function() end
    end    
    -- if config.DispelFilterAll
    --     then DispelFilter = "HARMFUL"
    --     else DispelFilter = "HARMFUL|RAID"
    -- end
                
    Aptechka:SetScript("OnUpdate",Aptechka.OnRangeUpdate)
    Aptechka:Show()
        
    SLASH_APTECHKA1= "/aptechka"
    SLASH_APTECHKA2= "/apt"
    SLASH_APTECHKA3= "/inj"
    SLASH_APTECHKA4= "/injector"
    SlashCmdList["APTECHKA"] = Aptechka.SlashCmd

    if config.LOSStatus then
        self:RegisterEvent("UNIT_SPELLCAST_SENT")
        self:RegisterEvent("UI_ERROR_MESSAGE")
    end
    
    if config.enableTraceHeals and next(traceheals) then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self.COMBAT_LOG_EVENT_UNFILTERED = function( self, event, timestamp, eventType, hideCaster,
                                                    srcGUID, srcName, srcFlags, srcFlags2,
                                                    dstGUID, dstName, dstFlags, dstFlags2,
                                                    spellID, spellName, spellSchool, amount, overhealing, absorbed, critical)
            if bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE then
                local opts = traceheals[spellName]
                if opts and eventType == opts.type then
                    if guidMap[dstGUID] then
                        SetJob(guidMap[dstGUID],opts,true)
                    end
                end
            end
        end

    end

    --autoloading
    for _,spell_group in pairs(config.autoload) do
        config.LoadableDebuffs[spell_group]()
        loaded[spell_group] = true
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
        if select(2,UnitClass("player")) == "SHAMAN" then auraUpdateEvents["SPELL_HEAL"] = true end
        local cleuEvent = CreateFrame("Frame")
        cleuEvent:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        cleuEvent:SetScript("OnEvent",
        function( self, event, timestamp, eventType, hideCaster,
                        srcGUID, srcName, srcFlags, srcFlags2,
                        dstGUID, dstName, dstFlags, dstFlags2,
                        spellID, spellName, spellSchool, auraType, amount)
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
        if ignoreplayer then
            local myheal = UnitGetIncomingHeals(unit, "player")
            if heal and myheal then heal = heal - myheal end
        end
        local showHeal = (heal and heal > threshold)
        if self.health.incoming then 
            self.health.incoming:SetValue( showHeal and self.health:GetValue()+(heal/UnitHealthMax(unit)*100) or 0)
        end
        if config.IncomingHealStatus then
            if showHeal then
                self.vIncomingHeal = heal
                SetJob(unit, config.IncomingHealStatus, true)
            else
                self.vIncomingHeal = 0
                SetJob(unit, config.IncomingHealStatus, false)
            end
        end
    end
end

-- function Aptechka.COMBAT_LOG_HEALTH(self, event, unit, h)
--     if not Roster[unit] then return end
--     -- print(event, unit, UnitHealth(unit))
--     for self in pairs(Roster[unit]) do
--         local hm = UnitHealthMax(unit)
--         if hm == 0 then return end
--         self.health2:SetValue(h/hm*100)
--     end
-- end

function Aptechka.UNIT_HEALTH(self, event, unit)
    if not Roster[unit] then return end
    -- print(event, unit, UnitHealth(unit))
    for self in pairs(Roster[unit]) do
        local h,hm = UnitHealth(unit), UnitHealthMax(unit)
        if hm == 0 then return end
        self.vHealth = h
        self.vHealthMax = hm
        self.health:SetValue(h/hm*100)
        SetJob(unit,config.HealthDificitStatus, ((hm-h) > 1000) )
        
        if event then -- quickhealth calls this function without event
            if UnitIsDeadOrGhost(unit) then
                SetJob(unit, config.AggroStatus, false)
                local deadorghost = UnitIsGhost(unit) and config.GhostStatus or config.DeadStatus
                SetJob(unit, deadorghost, true)
                SetJob(unit,config.HealthDificitStatus, false )
                self.isDead = true
                if self.OnDead then self:OnDead() end
            else
                if self.isDead then
                    self.isDead = false
                    Aptechka.ScanAuras(unit)
                    Aptechka.ScanDispels(unit)
                    SetJob(unit, config.GhostStatus, false)
                    SetJob(unit, config.DeadStatus, false)
                    SetJob(unit, config.ResurrectStatus, false)
                    if self.OnAlive then self:OnAlive() end
                end
            end
        end
        
    end
end

function Aptechka.UNIT_CONNECTION(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        SetJob(unit, config.OfflineStatus, (not UnitIsConnected(unit)) )
    end
end

function Aptechka.UNIT_POWER(self, event, unit, ptype)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        if self.power and not self.power.disabled then
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
    self.OnUpdateCounter = self.OnUpdateCounter + time
    if self.OnUpdateCounter < 1 then return end
    self.OnUpdateCounter = 0
    local owner = self.parent.unitOwner
    if not ( UnitHasVehicleUI(owner) or UnitInVehicle(owner) or UnitUsingVehicle(owner) ) then
        if Roster[self.parent.unit] then
            -- local original_unit = self.parent.unit
            -- print(string.format("L1>>Unit: %s-",original_unit))
            -- print(string.format("L1>>Unit- Owner: %s",self.parent.unitOwner))
            -- print(string.format("D3>>-Dumping Roster"))
            -- d87add.dump("ROSTER")-
            -- print(string.format("Restoring %s <- %s", owner, self.parent.unit) )
            Roster[owner] = Roster[self.parent.unit]
            Roster[self.parent.unit] = nil
            self.parent.unit = owner
            self.parent.unitOwner = nil
            self.parent.guid = UnitGUID(owner)
            self.parent.InVehicle = nil

            -- print(string.format("L1>>Unit: %-s",original_unit))
            -- print(string.format("D4>[%s]>Dumping- Roster",NAME))
            -- d87add.dump("ROSTER")-
            
            SetJob(owner,config.InVehicleStatus,false)
            Aptechka:UNIT_HEALTH("VEHICLE",owner)
            if self.parent.power then
                Aptechka:UNIT_DISPLAYPOWER(nil, owner)
                Aptechka:UNIT_POWER(nil,owner)
            end
            Aptechka.ScanAuras(owner)
            
            self:SetScript("OnUpdate",nil)
        end
    end
end
function Aptechka.UNIT_ENTERED_VEHICLE(self, event, unit)
    if not Roster[unit] then return end  
    for self in pairs(Roster[unit]) do
        if not self.InVehicle then --print("Already in vehicle")            
            local vehicleUnit = SecureButton_GetModifiedUnit(self)
            if unit ~= vehicleUnit then
                self.InVehicle = true
                self.unitOwner = unit --original unit
                self.unit = vehicleUnit
                
                Aptechka:Colorize(nil, self.unitOwner)
                self.guid = UnitGUID(vehicleUnit)
                if self.guid then guidMap[self.guid] = vehicleUnit end

                -- print(string.format("Overriding %s with %s", self.unitOwner, self.unit))
                Roster[self.unit] = Roster[self.unitOwner]
                Roster[self.unitOwner] = nil

                -- ROSTER = Roster
                -- local NAME = UnitName(unit)
                -- print(string.format("D1>[%s]>Dumping Roster",NAME))
                -- d87add.dump("ROSTER")
                
                if not self.vehicleFrame then self.vehicleFrame = CreateFrame("Frame"); self.vehicleFrame.parent = self end
                self.vehicleFrame.OnUpdateCounter = -1.5
                self.vehicleFrame:SetScript("OnUpdate",vehicleHack)
                
                SetJob(self.unit,config.InVehicleStatus,true)
                Aptechka:UNIT_HEALTH("VEHICLE",self.unit)
                if self.power then Aptechka:UNIT_POWER(nil,self.unit) end
                Aptechka.ScanAuras(self.unit)
            end
        end
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
                    FrameSetJob(frame, config.OutOfRangeStatus, false)
                    OORUnits[unit] = nil
                end
            else
                if frame.inRange or frame.inRange == nil then
                    frame.inRange = false
                    FrameSetJob(frame, config.OutOfRangeStatus, true)
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
            SetJob(unit, config.AggroStatus, true)
        else
            SetJob(unit, config.AggroStatus, false)
        end
    end
end

function Aptechka.UNIT_SPELLCAST_SENT(self, event, unit, spell, rank, targetName, lineID)
    if unit ~= "player" or not targetName then return end
    LastCastTargetName = targetName
    LastCastSentTime = GetTime()
end
function Aptechka.UI_ERROR_MESSAGE(self, event, errmsg)
    if errmsg == SPELL_FAILED_LINE_OF_SIGHT then -- amount var here is actually failedType
        if LastCastSentTime > GetTime() - 0.5 then
            for unit in pairs(Roster) do
                if UnitName(unit) == LastCastTargetName then
                    SetJob(unit, config.LOSStatus, true)
                    return
                end
            end
        end 
    end
end

-- maintanks, resize
function Aptechka.CheckLFDTank( self,unit )
    if not config.MainTankStatus then return end
    SetJob(unit, config.MainTankStatus, UnitGroupRolesAssigned(unit) == "TANK") 
end

function Aptechka.SetScale(self, scale)
    if InCombatLockdown() then return end
    if scale and scale > 0 then
        for i,hdr in pairs(group_headers) do
            hdr:SetAttribute("custom_scale",true)
            hdr:SetScale(scale)
        end
    else
        for i,hdr in pairs(group_headers) do
            hdr:SetAttribute("custom_scale",nil)
            hdr:SetScale(config.scale)
        end
    end
end
function Aptechka.PLAYER_REGEN_ENABLED(self,event)
    self:GROUP_ROSTER_UPDATE()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end
function Aptechka.GROUP_ROSTER_UPDATE(self,event,arg1)
    if not InCombatLockdown() then
        if not config.useGroupAnchors then -- config.resize and 
            Aptechka:LayoutUpdate()
        end
    else
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
end
Aptechka.SPELLS_CHANGED = Aptechka.GROUP_ROSTER_UPDATE

function Aptechka.LayoutUpdate(self)
    local numMembers = GetNumGroupMembers()
    local spec = GetSpecialization()
    local role = spec and select(6,GetSpecializationInfo(spec)) or "DAMAGER"
    for _, layout in ipairs(config.layouts) do
        if layout(self, numMembers, role, spec) then return end
    end
    self:SetScale(nil)
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


function Aptechka.INCOMING_RESURRECT_CHANGED(self, event, unit)
    -- print(event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        -- print(unit,UnitHasIncomingResurrection(unit))
        SetJob(unit, config.ResurrectStatus, UnitHasIncomingResurrection(unit))
    end
end

--Target Indicator
function Aptechka.PLAYER_TARGET_CHANGED(self, event)
    local newTargetUnit = guidMap[UnitGUID("target")]
    if newTargetUnit and Roster[newTargetUnit] then
        SetJob(Aptechka.previousTarget, config.TargetStatus, false)
        SetJob(newTargetUnit, config.TargetStatus, true)
        Aptechka.previousTarget = newTargetUnit
    else
        SetJob(Aptechka.previousTarget, config.TargetStatus, false)
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
        SetJob(unit, rci, true)
    end
end
function Aptechka.READY_CHECK_FINISHED(self, event)
    for unit in pairs(Roster) do
        SetJob(unit, config.ReadyCheck, false)
    end
end

--applying UnitButton color
function Aptechka.Colorize(self, event, unit)
    if not Roster[unit] then return end
    for self in pairs(Roster[unit]) do
        local hdr = self:GetParent()
        --if hdr.isPetGroup then   -- use owner color
        --    unit = string.gsub(unit,"pet","")
        --    if unit == "" then unit = "player" end
        --end
        if hdr.isPetGroup then
            self.classcolor = config.petcolor
        else
            local _,class = UnitClass(unit)
            if class then
                local color = colors[class] -- or { r = 1, g = 1, b = 0}
                self.classcolor = {color.r,color.g,color.b}
            end
        end
    end
end

--UnitButton initialization
local OnAttributeChanged = function(self, attrname, unit)
    if attrname ~= "unit" then return end

    local owner = unit
    if self.InVehicle and unit and unit == self.unitOwner then
        unit = self.unit
        owner = self.unitOwner
        -- print("InVehicle:", self.InVehicle, "  unitOwner:", self.unitOwner, "  unit:", unit)
        --if for some reason game will decide to update unit whose frame is mapped to vehicleunit in roster
    else
        if self.vehicleFrame then
            self.vehicleFrame:SetScript("OnUpdate",nil)
            self.vehicleFrame = nil
            self.InVehicle = nil
            FrameSetJob(self,config.InVehicleStatus,false)
            -- print ("Killing orphan vehicle frame")
        end
    end

    -- Removing frames that no longer associated with this unit from Roster
    for roster_unit, frames in pairs(Roster) do
        if frames[self] and (  self:GetAttribute("unit") ~= roster_unit   ) then -- or (self.InVehicle and self.unitOwner ~= roster_unit) 
            -- print ("Removing frame", self:GetName(), roster_unit, "=>", self:GetAttribute("unit"))
            frames[self] = nil
        end
    end
    
    if self.OnUnitChanged then self:OnUnitChanged(owner) end
    if not unit then return end
    
    local name, realm = UnitName(owner)
    self.name = utf8sub(name,1,config.cropNamesLen)

    self.unit = unit
    Roster[unit] = Roster[unit] or {}
    Roster[unit][self] = true
    self.guid = UnitGUID(unit) -- is it even needed?
    if self.guid then guidMap[self.guid] = unit end
    for guid, gunit in pairs(guidMap) do
        if not Roster[gunit] or guid ~= UnitGUID(gunit) then guidMap[guid] = nil end
    end
    
    Aptechka:Colorize(nil, owner)
    FrameSetJob(self,config.HealthBarColor,true)
    FrameSetJob(self,config.PowerBarColor,true)
    Aptechka.ScanAuras(unit)
    FrameSetJob(self, config.UnitNameStatus, true)
    Aptechka:UNIT_HEALTH("ONATTR", unit)
    Aptechka:UNIT_POWER("ONATTR", unit)
    Aptechka:UNIT_CONNECTION(nil, owner)
    if not config.disableManaBar then
        Aptechka:UNIT_DISPLAYPOWER(nil, unit)
        Aptechka:UNIT_POWER(nil, unit)
    end
    Aptechka:UNIT_THREAT_SITUATION_UPDATE(nil, unit)
    if config.raidIcons then
        Aptechka:RAID_TARGET_UPDATE()
    end
    if config.enableVehicleSwap and UnitHasVehicleUI(owner) then
        Aptechka:UNIT_ENTERED_VEHICLE(nil,owner) -- scary
    end
    Aptechka:CheckLFDTank(unit)
    if config.enableIncomingHeals then Aptechka:UNIT_HEAL_PREDICTION(nil,unit) end    
end

local arrangeHeaders = function(prv_group, notreverse, unitGrowth, groupGrowth)
        local p1, p2
        local xgap = 0
        local ygap = config.groupGap
        local point, direction = reverse(unitGrowth or config.unitGrowth) 
        local grgrowth = groupGrowth or (notreverse and reverse(config.groupGrowth) or config.groupGrowth)
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
function Aptechka.CreateHeader(self,group,petgroup)
    local frameName = "NugRaid"..group

    local HeaderTemplate = petgroup and "SecureGroupPetHeaderTemplate" or "SecureGroupHeaderTemplate"
    local f = CreateFrame("Button",frameName, UIParent, HeaderTemplate)
    

    f:SetAttribute("template", "AptechkaUnitButtonTemplate")
    f:SetAttribute("templateType", "Button")


    local xgap = config.unitGap
    local ygap = config.unitGap
    local unitgr = reverse(config.unitGrowth)
    if unitgr == "RIGHT" then
        xgap = -xgap
    elseif unitgr == "TOP" then
        ygap = -ygap
    end
    f:SetAttribute("point", unitgr)
    f:SetAttribute("xOffset", xgap)
    f:SetAttribute("yOffset", ygap)

	if not petgroup
    then
        f:SetAttribute("groupFilter", group)
    else
        f.isPetGroup = true
        f:SetAttribute("maxColumns", 1 )
        f:SetAttribute("unitsPerColumn", 5)
        --f:SetAttribute("startingIndex", 5*((group - config.maxgroups)-1))
    end
    --our group header doesn't really inherits SecureHandlerBaseTemplate
    if ClickCastHeader then SecureHandlerSetFrameRef(f,"clickcast_header", ClickCastHeader) end
    f:SetAttribute("showRaid", true)
    f:SetAttribute("showParty", config.showParty)
    f:SetAttribute("showSolo", config.showSolo)
    f:SetAttribute("showPlayer", true)
    f.initConf = Aptechka.SetupFrame
    f:SetAttribute("initialConfigFunction", self.initConfSnippet)

    if config.useGroupAnchors or group == 1 or petgroup then
        Aptechka:CreateAnchor(f,group)
    else
        f:SetPoint(arrangeHeaders(group_headers[group-1]))
    end
    
    f:Show()

    return f
end

do -- this function supposed to be called from layout switchers
    -- local reversed = false
    function Aptechka:SetGrowth(unitGrowth, groupGrowth)
        if config.useGroupAnchors then return end
        -- reversed = to or (not reversed)

        local anchorpoint = self:SetAnchorpoint(unitGrowth, groupGrowth)

        local xgap = config.unitGap
        local ygap = config.unitGap
        local unitgr = reverse(unitGrowth)
        if unitgr == "RIGHT" then
            xgap = -xgap
        elseif unitgr == "TOP" then
            ygap = -ygap
        end

        for group,hdr in ipairs(group_headers) do
            for _,button in ipairs{ hdr:GetChildren() } do -- group header doesn't clear points when attribute value changes
                button:ClearAllPoints()
            end
            hdr:SetAttribute("point", unitgr)
            hdr:SetAttribute("xOffset", xgap)
            hdr:SetAttribute("yOffset", ygap)

            hdr:ClearAllPoints()
            if group == 1 then
                hdr:SetPoint(anchorpoint, anchors[group], reverse(anchorpoint),0,0)
            else
                hdr:SetPoint(arrangeHeaders(group_headers[group-1], nil, unitGrowth, groupGrowth))
            end
        end
    end
end

function Aptechka:SetAnchorpoint(unitGrowth, groupGrowth)
    local ug = unitGrowth or config.unitGrowth
    local gg = groupGrowth or config.groupGrowth
    local rug, ud = reverse(ug)
    local rgg, gd = reverse(gg)
    if config.useGroupAnchors then return rug
    elseif ud == gd then return rug
    elseif gd == "VERTICAL" and ud == "HORIZONTAL" then return rgg..rug
    elseif ud == "VERTICAL" and gd == "HORIZONTAL" then return rug..rgg
    end
end

function Aptechka.CreateAnchor(self,hdr,num)
    local f = CreateFrame("Frame","NugRaidAnchor"..num,UIParent)

    f:SetHeight(20)
    f:SetWidth(20)

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)
    
    t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    if num == 1 then t:SetVertexColor(1, 0, 0)
    elseif num == 9 then t:SetVertexColor(1, 0.6, 0)
    else t:SetVertexColor(0, 1, 0) end
    t:SetAllPoints(f)
    
    local text = f:CreateFontString()
    text:SetPoint("RIGHT",f,"LEFT",0,0)
    text:SetFontObject("GameFontNormal")
    text:SetJustifyH("RIGHT")
    if num ~= 1 then text:SetText(num) end
    if num == 9 then text:SetText("P") end

    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetFrameStrata("HIGH")
    
    hdr:SetPoint(config.anchorpoint,f,reverse(config.anchorpoint),0,0)
    anchors[num] = f
    f:Hide()
    
    if not AptechkaDB[skinAnchorsName] then AptechkaDB[skinAnchorsName] = {} end
    if not AptechkaDB[skinAnchorsName][num] then
        if num == 1 then AptechkaDB[skinAnchorsName][num] = { point = "CENTER", x = 0, y = 0 }
        elseif num == 9 then AptechkaDB[skinAnchorsName][num] = { point = "BOTTOMLEFT", x = 0, y = -60 }
        else AptechkaDB[skinAnchorsName][num] = { point = "TOPLEFT", x = 0, y = 60} end
    end
    local san = AptechkaDB[skinAnchorsName][num]
    if num == 1 then
        f.root = true
        f:SetPoint(san.point,UIParent,san.point,san.x,san.y)
    else
        f.prev = anchors[#anchors-1]
        if num == 9 then f.prev = anchors[1] end
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

function Aptechka.SwitchAnchors(self, newAnchors)
    skinAnchorsName = newAnchors
    for num, f in ipairs(anchors) do
        if not AptechkaDB[skinAnchorsName] then AptechkaDB[skinAnchorsName] = {} end
        if not AptechkaDB[skinAnchorsName][num] then
            if num == 1 then AptechkaDB[skinAnchorsName][num] = { point = "CENTER", x = 0, y = 0 }
            elseif num == 9 then AptechkaDB[skinAnchorsName][num] = { point = "BOTTOMLEFT", x = 0, y = -60 }
            else AptechkaDB[skinAnchorsName][num] = { point = "TOPLEFT", x = 0, y = 60} end
        end
        local san = AptechkaDB[skinAnchorsName][num]
        if num == 1 then
            f.root = true
            f:ClearAllPoints()
            f:SetPoint(san.point,UIParent,san.point,san.x,san.y)
        else
            f.prev = anchors[num-1]
            if num == 9 then f.prev = anchors[1] end
            f:ClearAllPoints()
            f:SetPoint(san.point,f.prev,san.point,san.x,san.y)
        end
        f.san = san
    end
end

local onenter = function(self)
    if self.OnMouseEnterFunc then self:OnMouseEnterFunc() end
    if UnitAffectingCombat("player") then return end
    UnitFrame_OnEnter(self)
    self:SetScript("OnUpdate", UnitFrame_OnUpdate)
end
local onleave = function(self)
    if self.OnMouseLeaveFunc then self:OnMouseLeaveFunc() end
    UnitFrame_OnLeave(self)
    self:SetScript("OnUpdate", nil)
end
--~ function Aptechka.SetupFrame(header,id)
function Aptechka.SetupFrame(f)
--~     local f = header[id]

    f.onenter = onenter
    f.onleave = onleave
    -- f:SetAttribute("_onenter",[[
    --     local snippet = self:GetAttribute('clickcast_onenter'); if snippet then self:Run(snippet) end
    --     self:CallMethod("onenter")
    -- ]])
    -- --self:SetScale( 1 )
    -- f:SetAttribute("_onleave",[[
    --     local snippet = self:GetAttribute('clickcast_onleave'); if snippet then self:Run(snippet) end
    --     self:CallMethod("onleave")
    -- ]])

    -- print(unpack(config.registerForClicks))
    f:RegisterForClicks(unpack(config.registerForClicks))
    
    --ClickCastFrames[f] = true -- add to clique list
    
    if config[config.skin] then
        config[config.skin](f)
    else
        config["GridSkin"](f)
    end
    f.self = f
    f.HideFunc = f.HideFunc or function() end
    
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

    f:SetScript("OnAttributeChanged", OnAttributeChanged)
end

FrameSetJob = function (frame, opts, status)
        if opts and opts.assignto then
        for _, slot in ipairs(opts.assignto) do
            local self = frame[slot]
            if self then
            if opts.isMissing then status = not status end
            if not self.jobs then self.jobs = {} end
            if status
            then self.jobs[opts.name] = opts
            else self.jobs[opts.name] = nil
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

SetJob = function (unit, opts, status)
    if not Roster[unit] then return end
    for frame in pairs(Roster[unit]) do
        FrameSetJob(frame, opts, status)
    end
end

local encountered = {}
function Aptechka.ScanAuras(unit)
    for auraType, auraNames in pairs(auras) do
        table_wipe(encountered)
        for i=1,100 do
            local name, _, icon, count, _, duration, expirationTime, caster, _,_, spellID = UnitAura(unit, i, auraType)
            local opts = auraNames[spellID]
            if opts then
                if caster == "player" or not opts.isMine then
                    encountered[spellID] = true

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
                    SetJob(unit, opts, true)
                end
            end
        end

        for spellID, opts in pairs(auraNames) do
            if not encountered[spellID] then
                SetJob(unit, opts, false)
            end
        end
    end
end

function Aptechka.UNIT_AURA(self, event, unit)
    if not Roster[unit] then return end
    Aptechka.ScanAuras(unit)
    Aptechka.ScanDispels(unit)
end

local presentDebuffs = {}
local blacklist = {
    [57724] = true, -- Sated
    [80354] = true, -- Temporal Displacement
    [95223] = true, -- Mass Res
    [71041] = true, -- Deserter
    [8326] = true, -- Ghost
    [6788] = true, -- Weakened Soul
    [119050] = true, -- Kil'Jaeden Cunning
    [113942] = true, -- demonic gates debuff
    [123981] = true, -- dk cooldown debuff
    [87024] = true, -- mage cooldown debuff
    [36032] = true, -- arcane charge
    [97821] = true, -- dk battleres debuff
}

function Aptechka.ScanDispels(unit)
        table_wipe(presentDebuffs)

        local debuffLineLenght = #debuffs
        local shown = 0

        for i=1,100 do
            local name, _, icon, count, debuffType, duration, expirationTime, caster, _,_, aura_spellID = UnitAura(unit, i, "HARMFUL")
            if not name then
                break
            end

            if shown < debuffLineLenght then
                if not blacklist[aura_spellID] then
                    shown = shown + 1

                    local opts = debuffs[shown]
                    opts.debuffType = debuffType
                    opts.debuffType = debuffType
                    opts.expirationTime = expirationTime
                    opts.duration = duration
                    opts.stacks = count
                    opts.texture = icon
                    SetJob(unit, opts, true)
                end
            end

            local opts = dtypes[debuffType]
            if opts and not presentDebuffs[debuffType] then
                presentDebuffs[debuffType] = true

                opts.expirationTime = expirationTime
                opts.duration = duration
                opts.stacks = count
                opts.texture = icon

                SetJob(unit, opts, true)
            end
        end

        for i=shown+1, debuffLineLenght do
            local opts = debuffs[i]
            SetJob(unit, opts, false)
        end

        for debuffType, opts in pairs(dtypes) do
            if not presentDebuffs[debuffType] then
                SetJob(unit, opts, false)
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
    if not k or k == "help" then print([=[Usage:
      |cff00ff00/aptechka|r lock
      |cff00ff00/aptechka|r unlock
      |cff00ff00/aptechka|r unlock|cffff7777all|r
      |cff00ff00/aptechka|r reset|r
      |cff00ff00/aptechka|r setpos <point=center x=0 y=0>
      |cff00ff00/aptechka|r load <setname>
      |cff00ff00/aptechka|r spells
      |cff00ff00/aptechka|r charspec
      |cff00ff00/aptechka|r toggle | show | hide
      |cff00ff00/aptechka|r createpets
      |cff00ff00/aptechka|r togglegroup <1-8>]=]
    )end
    if k == "unlockall" then
        for _,anchor in pairs(anchors) do
            anchor:Show()
        end
    end
    if k == "unlock" then
        anchors[1]:Show()
    end
    if k == "lock" then
        for _,anchor in pairs(anchors) do
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
--~     if k == "scale" then
--~         local s = tonumber(v)
--~         if not s then
--~             print(AptechkaString.."Current scale = "..AptechkaDB.scale)
--~             return
--~         end
--~         AptechkaDB.scale = s
--~         for i = 1, config.maxgroups do
--~             group_headers[i]:SetScale(s)
--~         end
--~     end
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
    if k == "createpets" then
        if not config.petgroup then
            if not InCombatLockdown() then
                CreatePetsFunc()
            else
                local f = CreateFrame('Frame')
                f:SetScript("OnEvent",function(self)
                    CreatePetsFunc()
                    self:SetScript("OnEvent",nil)
                end)
                f:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
        end
    end
    if k == "toggle" then
        if group_headers[1]:IsVisible() then k = "hide" else k = "show" end
    end
    if k == "show" then
        for i,hdr in pairs(group_headers) do
            hdr:Show()
        end
    end
    if k == "hide" then
        for i,hdr in pairs(group_headers) do
            hdr:Hide()
        end
    end
    if k == "spells" then
        print("=== Spells ===")
        local spellset = AptechkaUserConfig.IndicatorAuras or AptechkaDefaultConfig.IndicatorAuras
        for spellName,opts in pairs(spellset) do
            local format = string.find(opts.type,"HARMFUL") and "|cffff7777%s|r" or "|cff77ff77%s|r"
            print(string.format(format,spellName))
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