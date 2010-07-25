if InjectorConfig.petFrames then

local _, helpers = ...
local reverse = helpers.Reverse

InjectorPet = CreateFrame("Frame",nil,UIParent)
InjectorPet.Roster = {}

function InjectorPet.OnEvent(self, event, unit) -- only UNIT_HEALTH (=MAXHEALTH)
    if not InjectorPet.Roster[unit] then return end
    for self in pairs(InjectorPet.Roster[unit]) do
        local h,hm = UnitHealth(unit), UnitHealthMax(unit)
        Injector.UpdateHealthText(self, h, hm)
        self.hp:SetValue(h/hm*100)
                    
--~         if UnitIsDeadOrGhost(unit) then
--~             self.hp.bg:Hide()
--~             self.text:SetText(self.name)
--~         else
--~             if not self.hp.bg:IsVisible() then
--~                 self.hp.bg:Show()
--~                 Injector.UpdateHealthText(self, h, hm)
--~             end
--~         end
    end
end

local PetOnAttributeChanged = function(self, name, unit)
--~     print("pet attr changed: "..(name or "nil")..'  '..(unit or "nil"))
    if name ~= "unit" then return end
    
        for unit, frames in pairs(InjectorPet.Roster) do
            if frames[self] and self:GetAttribute("unit") ~= unit then
                frames[self] = nil
            end
        end
        
        if not unit then return end
    
        local name, realm = UnitName(unit)
        self.name = helpers.utf8sub(name,1,InjectorConfig.cropNamesLen)
--~         self.text:SetText(self.name)
        local ownerunit = string.gsub(unit,"pet","")
        if ownerunit == "" then ownerunit = "player" end
        local _, class = UnitClass(ownerunit) -- owner class
    
    if class then
        local color = RAID_CLASS_COLORS[class] -- or { r = 1, g = 1, b = 0}
        self.hp.bg:SetVertexColor(color.r,color.g,color.b)
        self.text:SetTextColor(color.r,color.g,color.b)
    end

        self.guid = UnitGUID(unit)
        self.unit = unit
        InjectorPet.Roster[unit] = InjectorPet.Roster[unit] or {}
        InjectorPet.Roster[unit][self] = true
        
--~         for guid, unit in pairs(guid_roster) do
--~             if guid ~= UnitGUID(unit) then
--~                 guid_roster[guid] = nil
--~             end
--~         end
--~         guid_roster[UnitGUID(unit)] = unit        
--~         InjectorPet:UNIT_MAXHEALTH(nil, unit)
        InjectorPet:OnEvent(nil, unit)
end

function InjectorPet.ConfigFunc(f)
    local texture = InjectorConfig.texture
    local font = InjectorConfig.font
    local fontsize = InjectorConfig.fontsize

    
    f:SetAttribute("initial-width", InjectorConfig.width)
    f:SetAttribute("initial-height", InjectorConfig.height)
    f:SetAttribute("initial-scale", InjectorConfig.petScale or InjectorConfig.scale*0.7 )
    
    ClickCastFrames[f] = true
    
    f:SetAttribute("*type1", "target")
    
    local backdrop = {
--~         bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
        bgFile = "Interface\\Addons\\Injector\\white", tile = true, tileSize = 0,
--~         edgeFile = "Interface\\Addons\\Injector\\white", edgeSize = 2,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    f:SetBackdrop(backdrop)
	f:SetBackdropColor(0, 0, 0, 1) 
    
    local hp = CreateFrame("StatusBar", nil, f)
	hp:SetAllPoints(f)
    hp:SetOrientation(InjectorConfig.orientation)
	hp:SetStatusBarTexture(texture)
    hp:SetStatusBarColor(0,0,0,0.8)
    hp:SetMinMaxValues(0,100)
    hp:SetValue(0)
    
    local hpbg = f:CreateTexture()
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
    
    
    hp.bg = hpbg
    f.hp = hp
    
    --==< HEALTH BAR TEXT >==--
        local text = hp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER",0,0)
        text:SetJustifyH"CENTER"
        text:SetFont(font, fontsize)
        text:SetTextColor(1, 1, 1)
        f.text = text        
    
--~     f:EnableMouse(true)
    f:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
    
    f:SetScript("OnEnter", function(self)
        if UnitAffectingCombat("player") then return end
		UnitFrame_OnEnter(self)
		self:SetScript("OnUpdate", UnitFrame_OnUpdate)
    end)
    f:SetScript("OnLeave", function(self)
        UnitFrame_OnLeave(self)
        self:SetScript("OnUpdate", nil)
    end)
    f:SetScript("OnAttributeChanged", PetOnAttributeChanged)
end

function InjectorPet.Init(self)
    local xgap = InjectorConfig.unitGap
    local ygap = InjectorConfig.unitGap
    local unitgr = InjectorConfig.petFramesSeparation and reverse(InjectorConfig.unitGrowth) or InjectorConfig.unitGrowth

    local f = CreateFrame("Button","InjectorPet", UIParent, "SecureGroupPetHeaderTemplate")
            
    f:SetAttribute("showParty", true)
    f:SetAttribute("showSolo", true)
    f:SetAttribute("showPlayer", true)
            
    f:SetAttribute("template", "SecureUnitButtonTemplate")
    f:SetAttribute("templateType", "Button")
    
    if unitgr == "RIGHT" then 
        xgap = -xgap
    elseif unitgr == "TOP" then 
        ygap = -ygap
    end
    f:SetAttribute("point", unitgr)
--~ 	f:SetAttribute("groupFilter", group)
	f:SetAttribute("showRaid", true)
    f:SetAttribute("xOffset", xgap)
    f:SetAttribute("yOffset", ygap)
    
    f:SetAttribute("unitsPerColumn",5)
    f.initialConfigFunction = InjectorPet.ConfigFunc
--~     f:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOMRIGHT",0,0)
            

    InjectorPet:RegisterEvent("UNIT_HEALTH")
    InjectorPet:RegisterEvent("UNIT_MAXHEALTH")
    InjectorPet:SetScript("OnEvent",InjectorPet.OnEvent)
            
    InjectorPet.header = f
            
    f:Show()
    
    return f
end

end