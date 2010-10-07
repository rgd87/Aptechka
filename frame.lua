-- Skins and configs aren't ready
AptechkaDefaultConfig.GridSkin = function(self)
    local config
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    AptechkaDefaultConfig.width = 50
    AptechkaDefaultConfig.height = 50
    AptechkaDefaultConfig.texture = [[Interface\AddOns\Aptechka\gradient]]
    AptechkaDefaultConfig.font = [[Interface\AddOns\Aptechka\ClearFont.ttf]]
    AptechkaDefaultConfig.fontsize = 12
    AptechkaDefaultConfig.manabarwidth = 6
    AptechkaDefaultConfig.orientation = "VERTICAL"
    AptechkaDefaultConfig.invertColor = false             -- if true hp lost becomes dark, current hp becomes bright
    
    local texture = config.texture
    local font = config.font
    local fontsize = config.fontsize
    local manabar_width = config.manabarwidth
    
    self:SetWidth(config.width)
    self:SetHeight(config.height)
    
    local backdrop = {
        bgFile = "Interface\\Addons\\Aptechka\\white", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
    
    local hpi = CreateFrame("StatusBar", nil, self)
	hpi:SetAllPoints(self)
    hpi:SetOrientation(config.orientation)
	hpi:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    hpi:SetStatusBarColor(0,0,0,0.3)
    hpi:SetMinMaxValues(0,100)
    hpi:SetValue(0)
    self.incoming = hpi
    
    
    local hp = CreateFrame("StatusBar", nil, self)
	hp:SetAllPoints(self)
    hp:SetOrientation(config.orientation)
	hp:SetStatusBarTexture(texture)

    hp:SetStatusBarColor(1,1,1,1)
    hp:SetMinMaxValues(0,100)
    hp:SetValue(0)
    
    local hpbg = self:CreateTexture()
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)

    hp.bg = hpbg    
    self.hp = hp
    
    --==< HEALTH BAR TEXT >==--
        local text = hp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER",0,0)
        text:SetJustifyH"CENTER"
        text:SetFont(font, fontsize)
        text:SetTextColor(1, 1, 1)
        self.text = text
        
    --==< HEALTH BAR TEXT - SECOND LINE >==--
        local text2 = hp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text2:SetPoint("TOP",text,"BOTTOM",0,0)
        text2:SetJustifyH"CENTER"
        text2:SetFont(font, fontsize-3)
        text2:SetTextColor(0.2, 1, 0.2)
        text2.jobs = {}
        self.text2 = text2
        
        
    --- mana bar
  if not config.disableManaBar then
    
    local mb = CreateFrame("StatusBar",nil, self)
    
    if config.orientation == "VERTICAL" then
        config.mbst = {
            x = manabar_width,
            y = 0,
            p1 = "TOPRIGHT",
            p2 = "BOTTOMRIGHT",
            p3 = "BOTTOMLEFT",
        }
    else
        config.mbst = {
            x = 0,
            y = manabar_width,
            p1 = "BOTTOMLEFT",
            p2 = "BOTTOMRIGHT",
            p3 = "TOPRIGHT",
        }
    end
    
    mb:SetPoint(config.mbst.p1,self,config.mbst.p1,0,0)
    mb:SetPoint(config.mbst.p3,self,config.mbst.p2, -config.mbst.x , config.mbst.y)

    mb:SetOrientation(config.orientation)
	mb:SetStatusBarTexture(texture)
    mb:SetStatusBarColor(0,0,0,0.7)
    mb:SetMinMaxValues(0,100)
    mb:SetValue(100)
    
    local mbbg = self:CreateTexture()
    mbbg:SetAllPoints(mb)
	mbbg:SetTexture(texture)
    mbbg:SetVertexColor(0.2, 0.45, 0.75)

    hp:ClearAllPoints()
    hp:SetPoint("TOPRIGHT",self,"TOPRIGHT",-manabar_width,0)
    hp:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    hp.bg:ClearAllPoints()
    hp.bg:SetAllPoints(hp)
    
    
    mb.bg = mbbg
    mb.width = manabar_width
    self.mb = mb
    
    
    self.mb = mb
  end
    
    self:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
end