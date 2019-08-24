local _, helpers = ...
local Aptechka

local pixelperfect = helpers.pixelperfect

local LSM = LibStub("LibSharedMedia-3.0")

LSM:Register("statusbar", "Gradient", [[Interface\AddOns\Aptechka\gradient.tga]])
LSM:Register("font", "ClearFont", [[Interface\AddOns\Aptechka\ClearFont.ttf]], GetLocale() ~= "enUS" and 15)

--[[
2 shield icon border
0 shield icon texture
0 normal icon texture
0 corner indicators
0 text3 fontstring

-2 powerbar
-2 status bar bg
-2 debuff type texture

-3 powerbar bg
-4 absorb sidebar fg
-5 absorb sidebar bg
-5 heal absorb checkered
-6 healthbar
-7 absorb checkered fill
-7 incoming healing
-8 healthbar bg
]]

local MakeBorder = function(self, tex, left, right, top, bottom, level)
    local t = self:CreateTexture(nil,"BORDER",nil,level)
    t:SetTexture(tex)
    t:SetPoint("TOPLEFT", self, "TOPLEFT", left, -top)
    t:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -right, bottom)
    return t
end


local SetJob_Frame = function(self, job)
    if job.alpha then
        self:SetAlpha(job.alpha)
        -- if self.health2 then
        --     if job.alpha < 1 then
        --         self.health2:Hide()
        --     else
        --         self.health2:Show()
        --     end
        -- end
    end
end
local Frame_HideFunc = function(self)
    self:SetAlpha(1) -- to exit frrom OOR status
end

local HealthBarSetColorInverted = function(self, r,g,b)
    self:SetStatusBarColor(r,g,b)
    self.bg:SetVertexColor(r*.2, g*.2, b*.2)
end

local HealthBarSetColor = function(self, r,g,b)
    self:SetStatusBarColor(r*.2, g*.2, b*.2)
    self.bg:SetVertexColor(r,g,b)
end

local SetJob_HealthBar = function(self, job)
    local c
    if job.classcolor then
        c = self.parent.classcolor
    elseif job.color then
        c = job.color
    end
    if c then
        self:SetColor(unpack(c))
    end
end
local OnDead = function(self)
    self.power:Hide()
end
local OnAlive = function(self)
    if not self.power.disabled then
        self.power:Show()
    else
        self.power:Hide()
    end
end
local PowerBar_OnPowerTypeChange = function(self, powertype)
    local self = self.parent
    if powertype ~= "MANA" then
        self.power.disabled = true
        self.power:Hide()
    else
        self.power.disabled = nil
        self.power:Show()
    end

    -- if self.healfeedbackpassive then
    --     self.healfeedbackpassive:ClearAllPoints()
    --     if self.power:IsShown() and Aptechka.db.healthOrientation == "VERTICAL" then
    --         self.healfeedbackpassive:SetPoint("TOPRIGHT", self.power, "TOPLEFT", 0,0)
    --     else
    --         self.healfeedbackpassive:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0,0)
    --     end
    -- end
end
local SetJob_Indicator = function(self,job)
    if job.showDuration then
        self.cd:SetReverse(not job.reverseDuration)
        self.cd:SetCooldown(job.expirationTime - job.duration,job.duration,0,0)
        self.cd:Show()
    elseif job.showStacks then
        local stime = 300
        local completed = (job.showStacks - job.stacks) * stime
        local total = job.showStacks * stime
        local start = GetTime() - completed
        self.cd:SetReverse(true)
        self.cd:SetCooldown(start, total)
    else
        self.cd:Hide()
    end

    local color
    if job.foreigncolor and job.isforeign then
        color = job.foreigncolor
    else
        color = job.color or { 1,1,1,1 }
    end
    self.color:SetVertexColor(unpack(color))

    if job.fade then
        if self.traceJob ~= job or not self.blink:IsPlaying() then


            if self.blink:IsPlaying() then
                self.blink:Stop()
                if self.traceJob ~= job then
                    self.jobs[self.traceJob] = nil
                end
            end
            self.traceJob = job
            -- if job.noshine then
            --     self.blink.a2:SetChange(1)
            -- else
                self.blink.a2:SetFromAlpha(1)
                self.blink.a2:SetToAlpha(0)
            -- end
            self.blink.a2:SetDuration(job.fade)
            self.blink:Play()

        end
    else
        if self.traceJob then
            self.jobs[self.traceJob] = nil
            self.blink:Stop()
            self.traceJob = nil
        end
    end
    -- if job.pulse and (not self.currentJob or job.priority > self.currentJob.priority) then
        -- if not self.pulse:IsPlaying() then self.pulse:Play() end
    -- end
end

local CreateIndicator = function (parent,w,h,point,frame,to,x,y,nobackdrop)
    local f = CreateFrame("Frame",nil,parent)
    local w = pixelperfect(w)
    local h = pixelperfect(h)
    local border = pixelperfect(2)

    f:SetWidth(w); f:SetHeight(h);
    if not nobackdrop then
    f:SetBackdrop{
        bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 0,
        insets = {left = -border, right = -border, top = -border, bottom = -border},
    }
    f:SetBackdropColor(0, 0, 0, 1)
    end
    f:SetFrameLevel(6)
    local t = f:CreateTexture(nil,"ARTWORK")
    t:SetTexture[[Interface\BUTTONS\WHITE8X8]]
    t:SetAllPoints(f)
    f.color = t
    local icd = CreateFrame("Cooldown",nil,f, "CooldownFrameTemplate")
    icd.noCooldownCount = true -- disable OmniCC for this cooldown

        icd:SetEdgeTexture("Interface\\Cooldown\\edge");
        icd:SetSwipeColor(0, 0, 0);
        icd:SetDrawEdge(false);
        -- icd:SetDrawSwipe(true);
        icd:SetHideCountdownNumbers(true);


    icd:SetReverse(true)
    icd:SetAllPoints(f)
    f.cd = icd
    f:SetPoint(point,frame,to,x,y)
    f.parent = parent
    f.SetJob = SetJob_Indicator

    local pag = f:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("Scale")
    pa1:SetScale(2,2)
    pa1:SetDuration(0.2)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Scale")
    pa2:SetScale(0.5,0.5)
    pa2:SetDuration(0.8)
    pa2:SetOrder(2)

    f.pulse = pag

    local bag = f:CreateAnimationGroup()
    bag:SetLooping("NONE")
    local ba1 = bag:CreateAnimation("Alpha")
    ba1:SetFromAlpha(0)
    ba1:SetToAlpha(1)
    ba1:SetDuration(0.1)
    ba1:SetOrder(1)
    local ba2 = bag:CreateAnimation("Alpha")
    ba2:SetFromAlpha(1)
    ba2:SetToAlpha(0)
    ba2:SetDuration(0.7)
    ba2:SetOrder(2)
    bag.a2 = ba2

    bag:SetScript("OnFinished",function(ag)
        local self = ag:GetParent()
        ag:Stop()
        self:Hide()
        return Aptechka.FrameSetJob(self.parent, self.traceJob, false)
    end)
    f.blink = bag


    f.SetMinMaxValues = function(self, min, max )
        self._min = min
        self._max = max
    end
    f:SetMinMaxValues(0,1)
    f.SetValue = function(self, val)
        local duration = 259200 -- 3 days
        local progress = (val - self._min) / (self._max - self._min)
        local start = GetTime() - duration * progress
        self.cd:SetCooldown(start, duration,0,0)
    end

    f:Hide()
    return f
end


local SetJob_Corner = function(self,job)
    local color
    if job.foreigncolor and job.isforeign then
        color = job.foreigncolor
    else
        color = job.color or { 1,1,1,1 }
    end
    if job.pulse then
        -- UIFrameFlash(self, 0.15, 0.15, 1.2, true)
        if not self.pulse.done and not self.pulse:IsPlaying() then self.pulse:Play() end
    end
    self.color:SetVertexColor(unpack(color))

    if job.scale then
        self:SetScale(job.scale)
    else
        self:SetScale(1)
    end

    if job.fade then
        if (self.traceJob ~= job or not self.blink:IsPlaying()) or job.resetAnimation then

            if self.blink:IsPlaying() then
                self.blink:Stop()
                if self.traceJob ~= job then
                    self.jobs[self.traceJob] = nil
                end
            end
            self.traceJob = job
            self.blink.a2:SetFromAlpha(1)
            self.blink.a2:SetToAlpha(0)
            self.blink.a2:SetDuration(job.fade)
            self.blink:Play()

        end
    else
        if self.traceJob then
            self.jobs[self.traceJob] = nil
            self.blink:Stop()
            self.traceJob = nil
        end
    end

    -- if job.pulse and (not self.currentJob or job.priority > self.currentJob.priority) then
        -- if not self.pulse:IsPlaying() then self.pulse:Play() end
    -- end
end
local Corner_PulseAnimOnFinished = function(self)
    self.pulses = self.pulses + 1
    if self.pulses > 10 then
        local ag = self:GetParent()
        ag:Stop()
        ag.done = true
    end
end
local Corner_PulseAnimGroupOnPlay = function(ag)
    ag.a2.pulses = 0
end
local Corner_OnHide = function(self)
    self.pulse.done = false
end
local Corner_BlinkAnimOnFinished = function(ag)
    local self = ag:GetParent()
    ag:Stop()
    self:Hide()
    return Aptechka.FrameSetJob(self.parent, self.traceJob, false)
end
local CreateCorner = function (parent,w,h,point,frame,to,x,y, orientation, zOrderMod)
    local f = CreateFrame("Frame",nil,parent)
    f:SetWidth(w); f:SetHeight(h);

    zOrderMod = zOrderMod or 0

    local t = f:CreateTexture(nil,"ARTWORK", nil, 0+zOrderMod )
    t:SetTexture[[Interface\AddOns\Aptechka\corner]]
    if orientation == "BOTTOMLEFT" then
        -- (ULx,ULy,LLx,LLy,URx,URy,LRx,LRy);
        -- 00 1
        t:SetTexCoord(1,0,1,1,0,0,0,1)
    elseif orientation == "TOPRIGHT" then
        t:SetTexCoord(0,1,0,0,1,1,1,0)
    elseif orientation == "TOPLEFT" then
        t:SetTexCoord(1,1,0,1,1,0,0,0)
    end
    t:SetAllPoints(f)

    if point == "TOPRIGHT" then
        t:SetTexCoord(0,1,1,0)
    elseif point == "TOPLEFT" then
        t:SetTexCoord(1,0,1,0)
    elseif point == "BOTTOMLEFT" then
        t:SetTexCoord(1,0,0,1)
    end

    f.color = t
    f:SetPoint(point,frame,to,x,y)
    f.parent = parent
    f.SetJob = SetJob_Corner

    local bag = f:CreateAnimationGroup()
    bag:SetLooping("NONE")
    local ba1 = bag:CreateAnimation("Alpha")
    ba1:SetFromAlpha(0)
    ba1:SetToAlpha(1)
    ba1:SetDuration(0.1)
    ba1:SetOrder(1)
    local ba2 = bag:CreateAnimation("Alpha")
    ba2:SetFromAlpha(1)
    ba2:SetToAlpha(0)
    ba2:SetDuration(0.7)
    ba2:SetOrder(2)
    bag.a2 = ba2

    bag:SetScript("OnFinished", Corner_BlinkAnimOnFinished)
    f.blink = bag

    local pag = f:CreateAnimationGroup()
    pag:SetLooping("REPEAT")
    local pa1 = pag:CreateAnimation("Alpha")
    pa1:SetFromAlpha(1)
    pa1:SetToAlpha(0)
    pa1:SetDuration(0.15)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Alpha")
    pa2:SetFromAlpha(0)
    pa2:SetToAlpha(1)
    pa2:SetDuration(0.15)
    pa2:SetOrder(2)
    pag.a2 = pa2
    pa2:SetScript("OnFinished", Corner_PulseAnimOnFinished)

    pag:SetScript("OnPlay", Corner_PulseAnimGroupOnPlay)
    f.pulse = pag

    f:SetScript("OnHide", Corner_OnHide)

    f:Hide()
    return f
end


local StatusBarOnUpdate = function(self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 0.05 then return end
    self.OnUpdateCounter = 0

    local timeLeft = self.expires - GetTime()

    if self.pandemic and timeLeft < self.pandemic then
        local color = self.currentJob.color
        -- self.pandot:Show()
        self:SetStatusBarColor(color[1]*0.75, color[2]*0.75, color[3]*0.75)
        self.pandemic = nil
    end

    self:SetValue(timeLeft)
end
local SetJob_StatusBar = function(self,job)
    local color
    if job.foreigncolor and job.isforeign then
        color = job.foreigncolor
    else
        color = job.color or { 1,1,1,1 }
    end

    if job.showStacks then
        self:SetMinMaxValues(0, job.showStacks)
        self:SetValue(job.stacks)
        self:SetScript("OnUpdate", nil)
        self:SetStatusBarColor(unpack(color))
    else
        self.expires = job.expirationTime
        local pandemic = job.refreshTime
        self.pandemic = pandemic
        self:SetMinMaxValues(0, job.duration)
        local timeLeft = self.expires - GetTime()
        if pandemic and pandemic >= timeLeft then
            self:SetStatusBarColor(color[1]*0.75, color[2]*0.75, color[3]*0.75)
        else
            self:SetStatusBarColor(unpack(color))
        end
        if not job.showDuration then
            self:SetMinMaxValues(0, 1)
            self:SetValue(1)
            self:SetScript("OnUpdate", nil)
        else
            self:SetValue(timeLeft)
            self:SetScript("OnUpdate", StatusBarOnUpdate)
        end
    end

    self.bg:SetVertexColor(color[1]*0.25, color[2]*0.25, color[3]*0.25)
    -- self.pandot:SetVertexColor(color[1]*0.6, color[2]*0.6, color[3]*0.6)
end
local CreateStatusBar = function (parent,w,h,point,frame,to,x,y,nobackdrop, isVertical)
    local f = CreateFrame("StatusBar",nil,parent)
    local w = pixelperfect(w)
    local h = pixelperfect(h)
    local border = pixelperfect(2)
    f:SetWidth(w); f:SetHeight(h);
    if not nobackdrop then
    f:SetBackdrop{
        bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 0,
        insets = {left = -border, right = -border, top = -border, bottom = -border},
    }
    f:SetBackdropColor(0, 0, 0, 1)
    end
    f:SetFrameLevel(7)

    if isVertical then
        f:SetOrientation("VERTICAL")
    end

    f:SetStatusBarTexture[[Interface\BUTTONS\WHITE8X8]]
    -- f:SetMinMaxValues(0,100)
    -- f:SetStatusBarColor(1,1,1)

    local bg = f:CreateTexture(nil,"ARTWORK",nil,-2)
    bg:SetTexture[[Interface\BUTTONS\WHITE8X8]]
    bg:SetAllPoints(f)
    f.bg = bg


    -- local pandot = f:CreateTexture(nil, "ARTWORK", nil, -1)
    -- pandot:SetTexture[[Interface\BUTTONS\WHITE8X8]]
    -- pandot:SetWidth(pixelperfect(3))
    -- pandot:SetHeight(pixelperfect(3))
    -- pandot:SetPoint("CENTER", f, "RIGHT", -pixelperfect(4), 0)
    -- f.pandot = pandot

    f:SetPoint(point,frame,to,x,y)
    f.parent = parent
    f.SetJob = SetJob_StatusBar
    f:SetScript("OnUpdate", StatusBarOnUpdate)

    -- local pag = f:CreateAnimationGroup()
    -- local pa1 = pag:CreateAnimation("Scale")
    -- pa1:SetScale(2,2)
    -- pa1:SetDuration(0.2)
    -- pa1:SetOrder(1)
    -- local pa2 = pag:CreateAnimation("Scale")
    -- pa2:SetScale(0.5,0.5)
    -- pa2:SetDuration(0.8)
    -- pa2:SetOrder(2)

    -- f.pulse = pag

    f:Hide()
    return f
end
AptechkaDefaultConfig.GridSkin_CreateIndicator = CreateIndicator


local SetJob_Icon = function(self,job)
    if job.fade then self.jobs[job.name] = nil; return end
    if job.showDuration then
        self.cd:SetReverse(not job.reverseDuration)
        self.cd:SetCooldown(job.expirationTime - job.duration,job.duration)
        self.cd:Show()
    else
        self.cd:Hide()
    end
    self.texture:SetTexture(job.texture)

    if self.stacktext then
        if job.stacks then self.stacktext:SetText(job.stacks > 1 and job.stacks or "") end
    end
    -- if job.pulse and (not self.currentJob or job.priority > self.currentJob.priority) then
        -- if not self.pulse:IsPlaying() then self.pulse:Play() end
    -- end
end

local CreateShieldIcon = function(parent,w,h,alpha,point,frame,to,x,y)
    local icon = CreateFrame("Frame",nil,parent)
    icon:SetWidth(w); icon:SetHeight(h)
    icon:SetPoint(point,frame,to,x,y)
    icon:SetFrameLevel(7)

    local shield = icon:CreateTexture(nil, "ARTWORK", nil, 2)
    shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-IconFrame]])
    shield:SetTexCoord(0,0.5625,0,0.5625)
    shield:SetWidth(h*1.8)
    shield:SetHeight(h*1.8)
    shield:SetPoint("CENTER", icon,"CENTER",0,0)
    -- shield:Hide()

    local icontex = icon:CreateTexture(nil,"ARTWORK")
    icontex:SetTexCoord(.1, .9, .1, .9)
    icontex:SetPoint("TOPLEFT",icon, "TOPLEFT",0,0)
    icontex:SetPoint("BOTTOMRIGHT",icon, "BOTTOMRIGHT",0,0)
    icontex:SetWidth(h);
    icontex:SetHeight(h);

    icon.texture = icontex
    icon:SetAlpha(alpha)

    local icd = CreateFrame("Cooldown",nil,icon, "CooldownFrameTemplate")
    icd.noCooldownCount = true -- disable OmniCC for this cooldown
    icd:SetReverse(true)
    icd:SetDrawEdge(false)
    icd:SetAllPoints(icontex)
    icon.cd = icd

    icon:Hide()

    icon.SetJob = SetJob_Icon

    return icon
end

local CreateIcon = function(parent,w,h,alpha,point,frame,to,x,y)
    w = pixelperfect(w)
    h = pixelperfect(h)

    local icon = CreateFrame("Frame",nil,parent)
    icon:SetWidth(w); icon:SetHeight(h)
    icon:SetPoint(point,frame,to,x,y)
    local icontex = icon:CreateTexture(nil,"ARTWORK")
    icontex:SetTexCoord(.1, .9, .1, .9)
    icon:SetFrameLevel(6)
    icontex:SetPoint("TOPLEFT",icon, "TOPLEFT",0,0)
    icontex:SetPoint("BOTTOMRIGHT",icon, "BOTTOMRIGHT",0,0)
    -- icontex:SetWidth(h);
    -- icontex:SetHeight(h);
    icon.texture = icontex
    icon:SetAlpha(alpha)

    local icd = CreateFrame("Cooldown",nil,icon, "CooldownFrameTemplate")
    icd.noCooldownCount = true -- disable OmniCC for this cooldown
    icd:SetReverse(true)
    icd:SetDrawEdge(false)
    icd:SetAllPoints(icontex)
    icon.cd = icd

    local pag = icon:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("Scale")
    pa1:SetScale(2,2)
    pa1:SetDuration(.2)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Scale")
    pa2:SetScale(.5,.5)
    pa2:SetDuration(.8)
    -- pa2:SetSmoothing("OUT")
    pa2:SetOrder(2)

    icon.pulse = pag

    local stackframe = CreateFrame("Frame", nil, icon)
    stackframe:SetAllPoints(icon)
    local stacktext = stackframe:CreateFontString(nil,"ARTWORK")
    stacktext:SetDrawLayer("ARTWORK",1)
    local stackFont = LSM:Fetch("font",  Aptechka.db.nameFontName)
    local stackFontSize = Aptechka.db.stackFontSize
    stacktext:SetFont(stackFont, stackFontSize, "OUTLINE")
    -- stackframe:SetFrameLevel(7)

    stacktext:SetJustifyH"RIGHT"
    stacktext:SetPoint("BOTTOMRIGHT",icontex,"BOTTOMRIGHT", 3,-1)
    stacktext:SetTextColor(1,1,1)
    icon.stacktext = stacktext
    icon.SetJob = SetJob_Icon

    return icon
end
AptechkaDefaultConfig.GridSkin_CreateIcon = CreateIcon


local DebuffTypeColor = DebuffTypeColor
local helpful_color = { r = 0, g = 1, b = 0}
local function SetJob_DebuffIcon(self, debuffType, expirationTime, duration, icon, count, isBossAura)
    if expirationTime then
        self.cd:SetReverse(true)
        self.cd:SetCooldown(expirationTime - duration, duration)
        self.cd:Show()
    else
        self.cd:Hide()
    end
    self.texture:SetTexture(icon)

    if count then self.stacktext:SetText(count > 1 and count) end

    local color
    if debuffType == "Helpful" then
        color = helpful_color
    else
        color = debuffType and DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
    end
    self.debuffTypeTexture:SetVertexColor(color.r, color.g, color.b, 1)

    if isBossAura then
        self:SetScale(1.4)
    else
        self:SetScale(1)
    end
end

local SetDebuffOrientation = function(self, orientation, size)
    local it = self.texture
    local dtt = self.debuffTypeTexture
    -- local w = self.width
    -- local h = self.height
    local w = size
    local h = size
    local p = pixelperfect(1)
    it:ClearAllPoints()
    dtt:ClearAllPoints()

    -- local simple = false

    -- if simple then
    --     it:SetSize(pixelperfect(h - 2), pixelperfect(h - 2*p))
    --     it:SetPoint("TOPLEFT", self, "TOPLEFT", p, -p)
    --     dtt:SetSize(h, h)
    --     dtt:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    -- else
        if orientation == "VERTICAL" then
            self:SetSize(w,h)
            it:SetSize(h,h)
            it:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
            dtt:SetSize(h*0.2,h)
            dtt:SetPoint("TOPLEFT", it, "TOPRIGHT", 0, 0)
            -- dtt:SetSize(h+2,h+2)
            -- dtt:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
        else
            self:SetSize(h,w)

            -- dtt:SetSize(h,h*0.2)
            -- dtt:SetPoint("BOTTOMLEFT", it, "TOPLEFT", 0, 0)

            dtt:SetSize(w,h*0.2)
            dtt:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
            -- dtt:SetPoint("TOPLEFT", it, "TOPLEFT", 0, h*0.2)
            -- dtt:SetPoint("BOTTOMRIGHT", it, "BOTTOMRIGHT", 0, 0)

            it:SetSize(h,h)
            it:SetPoint("BOTTOMLEFT", dtt, "TOPLEFT", 0, 0)
        end
    -- end
end

local AlignDebuffIcons = function(icons, orientation)
    local attachTo, attachPoint
    if orientation == "VERTICAL" then
        for i,icon in ipairs(icons) do
            if i == 1 then
                attachTo = icons.parent
                attachPoint = "BOTTOMLEFT"
            else
                attachTo = icons[i-1]
                attachPoint = "TOPLEFT"
            end
            icon:ClearAllPoints()
            icon:SetPoint("BOTTOMLEFT", attachTo, attachPoint, 0,0)
        end
    else
        for i,icon in ipairs(icons) do
            if i == 1 then
                attachTo = icons.parent.power
                attachPoint = "TOPLEFT"
            else
                attachTo = icons[i-1]
                attachPoint = "BOTTOMRIGHT"
            end
            icon:ClearAllPoints()
            icon:SetPoint("BOTTOMLEFT", attachTo, attachPoint, 0,0)
        end
    end
end

local CreateDebuffIcon = function(parent, width, height, alpha, point, frame, to, x, y)
    local icon = CreateIcon(parent, width, height, alpha, point, frame, to, x, y)

    local w = pixelperfect(width)
    local h = pixelperfect(height)

    local icontex = icon.texture
    icontex:SetTexCoord(.2, .8, .2, .8)

    local dttex = icon:CreateTexture(nil, "ARTWORK", nil, -2)
    dttex:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    icon.debuffTypeTexture = dttex

    icon.SetOrientation = SetDebuffOrientation

    icon:SetOrientation("VERTICAL", w)

    -- icon:SetBackdrop{
        -- bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 0,
        -- insets = {left = 0, right = -2, top = 0, bottom = 0},
    -- }
    -- icon:SetBackdropColor(0, 0, 0, 1)

    icon.SetJob = SetJob_DebuffIcon

    icon:Hide()

    return icon
end

local SetJob_ProgressIcon = function(self, job)
    SetJob_Icon(self, job)

    self.cd:SetReverse(job.reverseDuration)

    local r,g,b
    local job_color = job.color
    if job_color then
        r,g,b = unpack(job_color)
    else
        r,g,b = 0.75, 1, 0.2
    end
    self.cd:SetSwipeColor(r,g,b)
end

local CreateProgressIcon = function(parent, width, height, alpha, point, frame, to, x, y)
    local icon = CreateIcon(parent, width, height, alpha, point, frame, to, x, y)
    local border = pixelperfect(3)
    local frameborder = MakeBorder(icon, "Interface\\BUTTONS\\WHITE8X8", -border, -border, -border, -border, -2)
    frameborder:SetVertexColor(0,0,0,1)
    frameborder:SetDrawLayer("ARTWORK", 2)

    icon:SetFrameStrata("MEDIUM")
    -- icon:SetFrameLevel(7)

    local cdf = icon.cd
    cdf.noCooldownCount = true -- disable OmniCC for this cooldown
    -- cdf:SetEdgeTexture("Interface\\Cooldown\\edge");
    cdf:SetSwipeColor(0.8, 1, 0.2, 1);
    cdf:SetDrawEdge(false);
    cdf:SetSwipeTexture("Interface\\BUTTONS\\WHITE8X8")
    cdf:SetHideCountdownNumbers(true);
    -- cdf:SetReverse(false)
    cdf:ClearAllPoints()
    local offset = border - pixelperfect(1)
    cdf:SetPoint("TOPLEFT", -offset, offset)
    cdf:SetPoint("BOTTOMRIGHT", offset, -offset)

    cdf:SetScript("OnCooldownDone", function(self)
        self:GetParent():Hide()
    end)

    local icontex = icon.texture
    icontex:SetParent(cdf)
    icontex:SetDrawLayer("ARTWORK", 3)

    icon.SetJob = SetJob_ProgressIcon

    icon:Hide()

    return icon
end

local Text1_SetColor = function(self, r,g,b)
    self:SetTextColor(r,g,b)
end
local Text1_SetColorInverted = function(self, r,g,b)
    self:SetTextColor(r*0.2,g*0.2,b*0.2)
end
local SetJob_Text1 = function(self,job)
    if job.healthtext then
        self:SetFormattedText("-%.0fk", (self.parent.vHealthMax - self.parent.vHealth) / 1e3)
    elseif job.nametext then
        self:SetText(self.parent.name)
    elseif job.text then
        self:SetText(job.text)
    end
    local c
    if job.classcolor then
        c = self.parent.classcolor
    elseif job.color then
        c = job.textcolor or job.color
    end
    if c then self:SetColor(unpack(c)) end
end
local formatMissingHealth = function(text, mh)
    if mh < 1000 then
        text:SetFormattedText("-%d", mh)
    elseif mh < 10000 then
        text:SetFormattedText("-%.1fk", mh / 1e3)
    else
        text:SetFormattedText("-%.0fk", mh / 1e3)
    end
end
local SetJob_Text2 = function(self,job) -- text2 is always green
    if job.healthtext then
        formatMissingHealth(self, self.parent.vHealthMax - self.parent.vHealth)
    -- elseif job.inchealtext then
        -- self:SetFormattedText("+%.0fk", self.parent.vIncomingHeal / 1e3)
    elseif job.nametext then
        self:SetText(self.parent.name)
    elseif job.text then
        self:SetText(job.text)
    end

    local c
    if job.percentColor then
        self:SetTextColor(helpers.PercentColor(job.text))
        self:SetFormattedText("%.0f%%", job.text*100)
    else
        if job.color then
            c = job.textcolor or job.color
            self:SetTextColor(unpack(c))
        end
    end
end

----------------
-- HEAL ABSORB
----------------
local HealAbsorbUpdatePositionVertical = function(self, p, health, parent)
    local frameLength = parent.frameLength
    self:SetHeight(p*frameLength)
    local offset = (health-p)*frameLength
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, offset)
    self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, offset)
end
local HealAbsorbUpdatePositionHorizontal = function(self, p, health, parent)
    local frameLength = parent.frameLength
    self:SetWidth(p*frameLength)
    local offset = (health-p)*frameLength
    self:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, 0)
    self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", offset, 0)
end
local HealAbsorbSetValue = function(self, p, health)
    if p < 0.005 then
        self:Hide()
        return
    end

    local parent = self:GetParent()

    if p > health then
        p = health
    end

    self:Show()
    self:UpdatePosition(p, health, parent)
end

local function CreateHealAbsorb(hp)
    local healAbsorb = hp:CreateTexture(nil, "ARTWORK", nil, -5)

    healAbsorb:SetHorizTile(true)
    healAbsorb:SetVertTile(true)
    healAbsorb:SetTexture("Interface\\AddOns\\Aptechka\\shieldtex", "REPEAT", "REPEAT")
    healAbsorb:SetVertexColor(0.5,0.1,0.1)
    healAbsorb:SetBlendMode("ADD")
    healAbsorb:SetAlpha(0.65)

    healAbsorb.UpdatePositionVertical = HealAbsorbUpdatePositionVertical
    healAbsorb.UpdatePositionHorizontal = HealAbsorbUpdatePositionHorizontal
    healAbsorb.UpdatePosition = HealAbsorbUpdatePositionVertical

    healAbsorb.SetValue = HealAbsorbSetValue
    return healAbsorb
end
--------------------
-- ABSORB BAR
--------------------
local AbsorbUpdatePositionVertical = function(self, p, health, parent)
    local frameLength = parent.frameLength
    self:SetHeight(p*frameLength)
    local offset = health*frameLength
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, offset)
    self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, offset)
end
local AbsorbUpdatePositionHorizontal = function(self, p, health, parent)
    local frameLength = parent.frameLength
    self:SetWidth(p*frameLength)
    local offset = health*frameLength
    self:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, 0)
    self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", offset, 0)
end
local AbsorbSetValue = function(self, p, health)
    if p + health > 1 then
        p = 1 - health
    end

    if p < 0.005 then
        self:Hide()
        return
    end

    local parent = self:GetParent()

    self:Show()
    self:UpdatePosition(p, health, parent)
end
local function CreateAbsorbBar(hp)
    local absorb = hp:CreateTexture(nil, "ARTWORK", nil, -5)

    absorb:SetHorizTile(true)
    absorb:SetVertTile(true)
    absorb:SetTexture("Interface\\AddOns\\Aptechka\\shieldtex", "REPEAT", "REPEAT")
    absorb:SetVertexColor(0,0,0)
    -- absorb:SetBlendMode("ADD")
    absorb:SetAlpha(0.65)

    absorb.UpdatePositionVertical = AbsorbUpdatePositionVertical
    absorb.UpdatePositionHorizontal = AbsorbUpdatePositionHorizontal
    absorb.UpdatePosition = AbsorbUpdatePositionVertical

    absorb.SetValue = AbsorbSetValue
    return absorb
end


local AlignAbsorbVertical = function(self, absorb_height, missing_health_height)
    self:SetHeight(absorb_height)
    if absorb_height >= missing_health_height then
        self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", -3 ,0)
    else
        self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", -3, -(missing_health_height - absorb_height))
    end
end
local AlignAbsorbHorizontal = function(self, absorb_height, missing_health_height)
    self:SetWidth(absorb_height)
    if absorb_height >= missing_health_height then
        self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", 0 ,-3)
    else
        self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -(missing_health_height - absorb_height), -3)
    end
end


    local hour, minute = 3600, 60
    local format = string.format
    local ceil = math.ceil
    local function FormatTime(s)
        if s >= hour then
            return "%dh", ceil(s / hour)
        elseif s >= minute then
            return "%dm", ceil(s / minute)
        end
        return "%ds", floor(s)
    end

    local Text3_OnUpdate = function(t3frame,time)
        local remains = t3frame.text.expirationTime - GetTime()
        if remains >= 0 then
            t3frame.text:SetText(string.format("%.1f", remains))
        else
            t3frame:SetScript("OnUpdate", nil)
        end
    end
    local Text3_OnUpdateForward = function(t3frame,time)
        local elapsed = GetTime() - t3frame.text.startTime
        if elapsed >= 0 then
            t3frame.text:SetFormattedText(FormatTime(elapsed))
        end
    end
    local Text3_HideFunc = function(self)
        self.frame:SetScript("OnUpdate",nil)
        self:Hide()
    end
local SetJob_Text3 = function(self,job)
    -- if job.startTime then
        -- self.expirationTime = nil
        -- self.startTime = job.startTime
    -- end
    if job.expirationTime then
        self.expirationTime = job.expirationTime
        self.startTime = nil
        self.frame:SetScript("OnUpdate",Text3_OnUpdate) --.frame is for text3 container
    elseif job.startTime then
        self.startTime = job.startTime
        self.expirationTime = nil
        self.frame:SetScript("OnUpdate",Text3_OnUpdateForward) --.frame is for text3 container
    else
        self.frame:SetScript("OnUpdate",nil)
    end

    if job.text then
        self:SetText(job.text)
    end

    local c = job.textcolor or job.color
    if c then
        self:SetTextColor(unpack(c))
    else
        self:SetTextColor(1,1,1)
    end
end
local CreateTextTimer = function(parent,point,frame,to,x,y,hjustify,fontsize,font,flags)
    local text3container = CreateFrame("Frame", nil, parent) -- We need frame to create OnUpdate handler for time updates
    local text3 = text3container:CreateFontString(nil, "ARTWORK")
    text3container.text = text3
--~     text3container:Hide()
    text3:SetPoint(point,frame,to,x,y)--"TOPLEFT",self,"TOPLEFT",-2,0)
    text3:SetJustifyH"LEFT"
    text3:SetFont(font, fontsize or 11, flags)
    text3.SetJob = SetJob_Text3
    text3.HideFunc = Text3_HideFunc
    text3.parent = parent
    text3.frame = text3container
    return text3
end
AptechkaDefaultConfig.GridSkin_CreateTextTimer = CreateTextTimer


local SetJob_Border = function(self,job)
    if job.color then
        -- self:SetBackdropColor(unpack(job.color))
        local r,g,b = unpack(job.color)
        self:SetVertexColor(r,g,b,0.5)
    end
end

local ordered_jobs = {}
local table_wipe = table.wipe
local table_sort = table.sort
local table_insert = table.insert
local sortfunc = function(a,b)
    local ap = a.priority or 80
    local bp = b.priority or 80
    if ap == bp then
        return a.expirationTime > b.expirationTime
    else
        return ap > bp
    end
end
local SetJob_Bars = function(self, _job)
    table_wipe(ordered_jobs)

    for name, job in pairs(self.jobs) do
        table_insert(ordered_jobs, job)
    end

    self.currentJob = ordered_jobs[1]

    table_sort(ordered_jobs, sortfunc)

    local frame = self:GetParent()

    for i, widgetname in ipairs(self.widgets) do
        local bar = frame[widgetname]
        local ojob = ordered_jobs[i]
        -- print(i, widgetname, ojob and ojob.name)
        if ojob then
            bar:SetJob(ojob)
            bar.currentJob = ojob
            bar:Show()
        else
            bar.currentJob = nil
            bar:Hide()
        end
    end
end


local CreateBars = function(self, optional_widgets)
    local  bars = CreateFrame("Frame", nil, self)
    bars.widgets = { "bar1", "bar2", "bar3" }
    bars.rawAssignments = true
    bars.SetJob = SetJob_Bars

    for i, widget in ipairs(bars.widgets) do
        self[widget] = optional_widgets[widget](self)
    end

    return bars
end

local OnMouseEnterFunc = function(self)
    self.mouseover:Show()
end
local OnMouseLeaveFunc = function(self)
    self.mouseover:Hide()
end


local optional_widgets = {
        raidbuff = function(self) return CreateIndicator(self,5,5,"TOPLEFT",self,"TOPLEFT",0,0) end,
        --top
        spell1  = function(self) return CreateIndicator(self,9,9,"BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0) end,
        --bottomright
        spell2  = function(self) return CreateIndicator(self,9,9,"TOP",self,"TOP",0,0) end,
        --topright
        spell3  = function(self) return CreateIndicator(self,9,9,"TOPRIGHT",self,"TOPRIGHT",0,0) end,
        --bottom
        spell4  = function(self) return CreateIndicator(self,7,7,"BOTTOM",self,"BOTTOM",0,0) end,
        --left
        spell5  = function(self) return CreateIndicator(self,7,7,"LEFT",self,"LEFT",0,0) end,

        -- shieldicon = function(self) return CreateShieldIcon(self,15,15,1,"CENTER",self,"TOPLEFT",14,0) end,
        shieldicon = function(self) return CreateProgressIcon(self,15,15,1,"TOPRIGHT",self,"TOPRIGHT",2,-12) end,

        bar1    = function(self) return CreateStatusBar(self, 21, 6, "BOTTOMRIGHT",self, "BOTTOMRIGHT",0,0) end,
        bar2    = function(self)
            if self.bar1 then
                return CreateStatusBar(self, 21, 4, "BOTTOMLEFT", self.bar1, "TOPLEFT",0, pixelperfect(1))
            end
        end,
        bar3    = function(self)
            if self.bar2 then
                return CreateStatusBar(self, 21, 4, "BOTTOMLEFT", self.bar2, "TOPLEFT",0, pixelperfect(1))
            end
        end,
        bar4    = function(self) return CreateStatusBar(self, 21, 5, "TOPRIGHT", self, "TOPRIGHT",0,2) end,

        bars = CreateBars,

        vbar1   = function(self) return CreateStatusBar(self, 4, 20, "TOPRIGHT", self, "TOPRIGHT",-9,2, nil, true) end,

        smist  = function(self) return CreateIndicator(self,7,7,"TOPRIGHT",self.vbar1,"TOPLEFT",-1,0) end,
}

local function Reconf(self)
    local config = AptechkaDefaultConfig

    local db = Aptechka.db
    local isVertical = db.healthOrientation == "VERTICAL"

    local texpath = LSM:Fetch("statusbar", db.healthTexture)
    self.health:SetStatusBarTexture(texpath)
    self.health:GetStatusBarTexture():SetDrawLayer("ARTWORK",-6)
    self.health.bg:SetTexture(texpath)

    local texpath2 = LSM:Fetch("statusbar", db.powerTexture)
    self.power:SetStatusBarTexture(texpath2)
    self.power:GetStatusBarTexture():SetDrawLayer("ARTWORK",-2)
    self.power.bg:SetTexture(texpath2)

    if db.invertedColors then
        -- self.health:SetFillStyle("REVERSE")
        self.health.SetColor = HealthBarSetColorInverted
        self.power.SetColor = HealthBarSetColorInverted
        self.text1.SetColor = Text1_SetColorInverted
        self.text1:SetShadowOffset(0,0)
        self.health.absorb2:SetVertexColor(0.7,0.7,1)
    else
        -- self.health:SetFillStyle("STANDARD")
        self.health.SetColor = HealthBarSetColor
        self.power.SetColor = HealthBarSetColor
        self.text1.SetColor = Text1_SetColor
        self.text1:SetShadowOffset(1,-1)
        self.health.absorb2:SetVertexColor(0,0,0)
    end
    Aptechka.FrameSetJob(self,config.HealthBarColor,true)
    Aptechka.FrameSetJob(self,config.PowerBarColor,true)
    Aptechka.FrameSetJob(self,config.UnitNameStatus,true)

    local nameFont = LSM:Fetch("font",  Aptechka.db.nameFontName)
    local nameFontSize = Aptechka.db.nameFontSize
    self.text1:SetFont(nameFont, nameFontSize)

    local stackFont = nameFont
    local stackFontSize = Aptechka.db.stackFontSize
    for i, icon in ipairs(self.debuffIcons) do
        icon.stacktext:SetFont(stackFont, stackFontSize, "OUTLINE")
    end

    if isVertical then
        self.health:SetOrientation("VERTICAL")
        self.power:SetOrientation("VERTICAL")
        self.health.incoming:SetOrientation("VERTICAL")

        local  absorb = self.health.absorb
        absorb:ClearAllPoints()
        absorb:SetWidth(3)
        absorb.orientation = "VERTICAL"
        absorb.maxheight = db.height
        absorb.AlignAbsorb = AlignAbsorbVertical
        Aptechka:UNIT_ABSORB_AMOUNT_CHANGED(nil, self.unit)

        self.health.frameLength = db.height
        local healAbsorb = self.health.healabsorb
        healAbsorb:ClearAllPoints()
        healAbsorb.UpdatePosition = healAbsorb.UpdatePositionVertical

        local absorb2 = self.health.absorb2
        absorb2:ClearAllPoints()
        absorb2.UpdatePosition = absorb2.UpdatePositionVertical

        -- self.health.lost.maxheight = db.height

        -- self.health:ClearAllPoints()
        -- self.health:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
        -- self.health:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)

        self.power:ClearAllPoints()
        self.power:SetWidth(4)
        self.power:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
        self.power:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)

        local debuffSize = pixelperfect(Aptechka.db.debuffSize)
        for i, icon in ipairs(self.debuffIcons) do
            icon:SetOrientation("VERTICAL", debuffSize)
        end
        self.debuffIcons:Align("VERTICAL")

    else
        self.health:SetOrientation("HORIZONTAL")
        self.power:SetOrientation("HORIZONTAL")
        self.health.incoming:SetOrientation("HORIZONTAL")

        local absorb = self.health.absorb
        absorb:ClearAllPoints()
        absorb:SetHeight(3)
        absorb.orientation = "HORIZONTAL"
        absorb.maxheight = db.width
        absorb.AlignAbsorb = AlignAbsorbHorizontal
        Aptechka:UNIT_ABSORB_AMOUNT_CHANGED(nil, self.unit)

        self.health.frameLength = db.width
        local healAbsorb = self.health.healabsorb
        healAbsorb:ClearAllPoints()
        healAbsorb.UpdatePosition = healAbsorb.UpdatePositionHorizontal

        local absorb2 = self.health.absorb2
        absorb2:ClearAllPoints()
        absorb2.UpdatePosition = absorb2.UpdatePositionHorizontal

        -- self.health:ClearAllPoints()
        -- self.health:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
        -- self.health:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)

        self.power:ClearAllPoints()
        self.power:SetHeight(4)
        self.power:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
        self.power:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)

        local debuffSize = pixelperfect(Aptechka.db.debuffSize)
        for i, icon in ipairs(self.debuffIcons) do
            icon:SetOrientation("HORIZONTAL", debuffSize)
        end
        self.debuffIcons:Align("HORIZONTAL")
    end

end

AptechkaDefaultConfig.GridSkin = function(self)
    Aptechka = _G.Aptechka

    local db = Aptechka.db

    local config = AptechkaDefaultConfig

    local texture = LSM:Fetch("statusbar", db.healthTexture)
    local powertexture = LSM:Fetch("statusbar", db.powerTexture)
    local font = LSM:Fetch("font",  Aptechka.db.nameFontName)
    local fontsize = Aptechka.db.nameFontSize
    local manabar_width = config.manabarwidth
    local border = pixelperfect(2)

    self.ReconfigureUnitFrame = Reconf

    -- local backdrop = {
    --     bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 0,
    --     insets = {left = -2, right = -2, top = -2, bottom = -2},
    -- }
    -- self:SetBackdrop(backdrop)
    -- self:SetBackdropColor(0, 0, 0, 1)

    local frameborder = MakeBorder(self, "Interface\\BUTTONS\\WHITE8X8", -border, -border, -border, -border, -2)
    frameborder:SetVertexColor(0,0,0,1)

    local powerbar = CreateFrame("StatusBar", nil, self)
	powerbar:SetWidth(4)
    powerbar:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
    powerbar:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
	powerbar:SetStatusBarTexture(powertexture)
    powerbar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-2)
    powerbar:SetMinMaxValues(0,100)
    powerbar.parent = self
    powerbar:SetOrientation("VERTICAL")
    powerbar.SetJob = SetJob_HealthBar
    powerbar.OnPowerTypeChange = PowerBar_OnPowerTypeChange
    powerbar.SetColor = HealthBarSetColor

    local pbbg = powerbar:CreateTexture(nil,"ARTWORK",nil,-3)
	pbbg:SetAllPoints(powerbar)
	pbbg:SetTexture(powertexture)
    powerbar.bg = pbbg


    local hp = CreateFrame("StatusBar", nil, self)
	--hp:SetAllPoints(self)
    hp:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    -- hp:SetPoint("TOPRIGHT",powerbar,"TOPLEFT",0,0)
    hp:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
	hp:SetStatusBarTexture(texture)
    hp:GetStatusBarTexture():SetDrawLayer("ARTWORK",-6)
    hp:SetMinMaxValues(0,100)
    hp:SetOrientation("VERTICAL")
    hp.parent = self
    hp.SetJob = SetJob_HealthBar
    hp.SetColor = HealthBarSetColor
    --hp:SetValue(0)

    --[[
    ----------------------
    -- HEALTH LOST EFFECT
    ----------------------

    hplost = hp:CreateTexture(nil, "ARTWORK", nil, -4)
    hplost:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    hplost:SetVertexColor(0.8, 0, 0)
    hp.lost = hplost

    hp._SetValue = hp.SetValue
    hp.SetValue = function(self, v)
        local max = 100
        local vp = v/max
        local hl = self.lost
        local offset = vp*hl.maxheight
        hl:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, offset)
        hl:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, offset)
        -- self.lost:SmoothFade(v)
        hl:SetNewHealthTarget(vp)
        self:_SetValue(v)
    end

    hplost:SetPoint("BOTTOMLEFT", hp, "BOTTOMLEFT", 0, 0)
    hplost:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", 0, 0)

    hplost.currentvalue = 0
    hplost.endvalue = 0

    hplost.UpdateDiff = function(self)
        local diff = self.currentvalue - self.endvalue
        if diff > 0 then
            self:SetHeight((diff)*self.maxheight)
            self:SetAlpha(1)
        else
            self:SetHeight(1)
            self:SetAlpha(0)
        end
    end

    hp:SetScript("OnUpdate", function(self, time)
        self._elapsed = (self._elapsed or 0) + time
        if self._elapsed < 0.025 then return end
        self._elapsed = 0


        local hl = self.lost
        local diff = hl.currentvalue - hl.endvalue
        if diff > 0 then
            local d = (diff > 0.1) and diff/15 or 0.006
            hl.currentvalue = hl.currentvalue - d
            -- self:SetValue(self.currentvalue)
            hl:UpdateDiff()
        end
    end)

    hplost.SetNewHealthTarget = function(self, vp)
        if vp >= self.currentvalue then
            self.currentvalue = vp
            self.endvalue = vp
            -- self:SetValue(vp)
            self:UpdateDiff()
        else
            self.endvalue = vp
        end
    end
    ]]

    ------------------------
    -- Mouseover highlight
    ------------------------

    local mot = hp:CreateTexture(nil,"OVERLAY")
    mot:SetAllPoints(hp)
    mot:SetTexture(136810)
    -- /dump GetFileIDFromPath("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    -- mot:SetVertexColor(0.7,0.7,1)
    mot:SetTexCoord(0,1,0,0.9)
    mot:SetAlpha(0.1)
    mot:SetBlendMode("ADD")
    mot:Hide()
    self.mouseover = mot

--------------------

    local absorb = CreateFrame("Frame", nil, self)
    absorb:SetParent(hp)
    -- absorb:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    absorb:SetPoint("TOPLEFT",self,"TOPLEFT",-3,0)
    absorb:SetWidth(3)

    local at = absorb:CreateTexture(nil, "ARTWORK", nil, -4)
    at:SetTexture[[Interface\BUTTONS\WHITE8X8]]
    at:SetVertexColor(.7, .7, 1, 1)
    at:SetAllPoints(absorb)

    local atbg = absorb:CreateTexture(nil, "ARTWORK", nil, -5)
    atbg:SetTexture[[Interface\BUTTONS\WHITE8X8]]
    atbg:SetVertexColor(0,0,0,1)
    atbg:SetPoint("TOPLEFT", at, "TOPLEFT", -1,1)
    atbg:SetPoint("BOTTOMRIGHT", at, "BOTTOMRIGHT", 1,-1)

    absorb.maxheight = config.height
    absorb.AlignAbsorb = AlignAbsorbVertical

    absorb.SetValue = function(self, v, health)
        local p = v/100
        if p > 1 then p = 1 end
        if p < 0 then p = 0 end
        if p <= 0.015 then self:Hide(); return; else self:Show() end

        local h = (health/100)
        local missing_health_height = (1-h)*self.maxheight
        local absorb_height = p*self.maxheight

        self:AlignAbsorb(absorb_height, missing_health_height)
    end
    absorb:SetValue(0)
    hp.absorb = absorb

    -------------------

    local absorb2 = CreateAbsorbBar(hp)
    -- absorb2.parent = self
    hp.absorb2 = absorb2

    -------------------

    local healAbsorb = CreateHealAbsorb(hp)
    -- healAbsorb.parent = self
    hp.healabsorb = healAbsorb


    -----------------------

    -- local absorb = CreateFrame("StatusBar", nil, self)
    -- absorb:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    -- absorb:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    -- absorb:SetWidth(1)
    -- -- absorb:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
    -- absorb:SetStatusBarTexture[[Interface\BUTTONS\WHITE8X8]]  --absorbOverlay]]
    -- absorb:GetStatusBarTexture():SetDrawLayer("ARTWORK",-4)
    -- absorb:SetStatusBarColor(.6, .6, 1)
    -- absorb:SetMinMaxValues(0,100)
    -- absorb:SetOrientation("VERTICAL")
    -- absorb:SetReverseFill(true)
    -- absorb:SetValue(50)
    -- hp.absorb = absorb
    -- self.absorb = absorb

    -- local abg = hp:CreateTexture(nil,"ARTWORK",nil,-5)
    -- abg:SetPoint("BOTTOMLEFT",absorb,"BOTTOMLEFT",0,0)
    -- abg:SetPoint("TOPLEFT",absorb,"TOPLEFT",0,0)
    -- abg:SetWidth(2)
    -- abg:SetTexture("Interface\\Addons\\Aptechka\\gradient")
    -- abg:SetVertexColor(0,0,0, .3)
    -- absorb.bg = abg

    local hpbg = hp:CreateTexture(nil,"ARTWORK",nil,-8)
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
    hp.bg = hpbg

    -- if AptechkaDefaultConfig.useCombatLogHealthUpdates or AptechkaDefaultConfig.useCombatLogHealthUpdates then
    --     print('p2')
    --     local hp2 = CreateFrame("StatusBar", nil, self)
    --     --hp:SetAllPoints(self)
    --     hp2:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    --     -- hp:SetPoint("TOPRIGHT",powerbar,"TOPLEFT",0,0)
    --     hp2:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    --     hp2:SetWidth(13)
    --     hp2:SetStatusBarTexture(texture)
    --     hp2:GetStatusBarTexture():SetDrawLayer("ARTWORK",-4)
    --     hp2:SetMinMaxValues(0,100)
    --     hp2:SetOrientation("VERTICAL")
    --     hp2.parent = self
    --     hp2.SetJob = SetJob_HealthBar
    --     --hp:SetValue(0)

    --     local hp2bg = hp:CreateTexture(nil,"ARTWORK",nil,-5)
    --     hp2bg:SetAllPoints(hp2)
    --     hp2bg:SetTexture(texture)
    --     hp2.bg = hp2bg
    --     self.health2 = hp2
    -- end
    local hpi = CreateFrame("StatusBar", nil, self)
	hpi:SetAllPoints(self)
	hpi:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    -- hpi:SetOrientation("VERTICAL")
    hpi:SetStatusBarColor(0, 0, 0, 0.5)
    -- hpi:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
    hpi:GetStatusBarTexture():SetDrawLayer("ARTWORK",-7)
    hpi:SetOrientation("VERTICAL")
    -- hpi:SetStatusBarColor(0,1,0)
    hpi:SetMinMaxValues(0,100)
    --hpi:SetValue(0)
    hpi.current = 0
    hpi.Update = function(self, h, hi, hm)
        hi = hi or self.current
        if hm == 0 then
            self:SetValue(0)
        else
            self:SetValue((h+hi)/hm*100)
        end
    end

    -- local border = CreateFrame("Frame",nil,self)
    -- border:SetAllPoints(self)
    -- border:SetFrameStrata("LOW")
    -- border:SetFrameLevel(0)
    -- border:SetBackdrop{
    --     bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 0,
    --     insets = {left = -4, right = -4, top = -4, bottom = -4},
    -- }
    -- border:SetAlpha(0.5)
    -- border.SetJob = SetJob_Border
    -- border:Hide()

    local p4 = pixelperfect(3.5)
    local border = MakeBorder(self, "Interface\\BUTTONS\\WHITE8X8", -p4, -p4, -p4, -p4, -5)
    border:SetVertexColor(1, 1, 1, 0.5)
    border.SetJob = SetJob_Border
    border:Hide()


    local text = hp:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("CENTER",self,"CENTER",0,0)
    text:SetJustifyH"CENTER"
    text:SetFont(font, fontsize)
    text:SetTextColor(1, 1, 1)
    text:SetShadowColor(0,0,0)
    text:SetShadowOffset(1,-1)
    text.SetColor = Text1_SetColor
    text.SetJob = SetJob_Text1
    text.parent = self

    local text2 = hp:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text2:SetPoint("TOP",text,"BOTTOM",0,0)
    text2:SetJustifyH"CENTER"
    text2:SetFont(font, fontsize-3)
    text2.SetJob = SetJob_Text2
    text2:SetTextColor(0.2, 1, 0.2)
    text2.parent = self

    local icon = CreateIcon(self,24,24,0.4,"CENTER",self,"CENTER",0,0)
    local progressIcon = CreateProgressIcon(self,18,18, 1,"TOPLEFT",self,"TOPLEFT",-3,3)

    local raidicon = CreateFrame("Frame",nil,self)
    raidicon:SetWidth(20); raidicon:SetHeight(20)
    raidicon:SetPoint("CENTER",hp,"TOPLEFT",0,0)
    local raidicontex = raidicon:CreateTexture(nil,"OVERLAY")
    raidicontex:SetAllPoints(raidicon)
    raidicon.texture = raidicontex
    raidicon:SetAlpha(0.3)


    local centericon = CreateFrame("Frame",nil,self)
    centericon:SetWidth(20); centericon:SetHeight(20)
    centericon:SetPoint("CENTER",hp,"CENTER",0,14)
    centericon:SetFrameLevel(7)
    local centericontex = centericon:CreateTexture(nil,"OVERLAY")
    centericontex:SetAllPoints(centericon)
    centericon.texture = centericontex
    centericon:SetAlpha(1)


    local roleicon = CreateFrame("Frame",nil,self)
    roleicon:SetWidth(13); roleicon:SetHeight(13)
    -- roleicon:SetPoint("BOTTOMLEFT",hp,"CENTER",-20,-23)
    -- roleicon:SetPoint("TOPLEFT",hp,"TOPLEFT",1,-8)
    roleicon:SetPoint("BOTTOMLEFT",hp,"BOTTOMLEFT",-8, -8)
    local roleicontex = roleicon:CreateTexture(nil,"OVERLAY")
    roleicontex:SetAllPoints(roleicon)
    roleicontex:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"); --("Interface\\AddOns\\Aptechka\\roles")
    roleicontex:SetTexCoord(GetTexCoordsForRoleSmallCircle("TANK"));--(0.25, 0.5, 0,1)
    -- roleicontex:SetVertexColor(0,0,0,0.2)
    roleicon.texture = roleicontex


    -- local topind = CreateIndicator(self,9,9,"TOP",self,"TOP",0,0)
    -- local tr = CreateIndicator(self,9,9,"TOPRIGHT",self,"TOPRIGHT",0,0)
    -- local br = CreateIndicator(self,9,9,"BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
    -- local btm = CreateIndicator(self,7,7,"BOTTOM",self,"BOTTOM",0,0)
    -- local left = CreateIndicator(self,7,7,"LEFT",self,"LEFT",0,0)
    -- local tl = CreateIndicator(self,5,5,"TOPLEFT",self,"TOPLEFT",0,0)
    local text3 = CreateTextTimer(self,"TOPLEFT",self,"TOPLEFT",2,0,"LEFT",fontsize-3,font)--,"OUTLINE")

    -- local bar1 = CreateStatusBar(self, 21, 6, "BOTTOMRIGHT",self, "BOTTOMRIGHT",0,0)
    -- local bar2 = CreateStatusBar(self, 21, 4, "BOTTOMLEFT", bar1, "TOPLEFT",0,1)
    -- local bar3 = CreateStatusBar(self, 21, 4, "TOPRIGHT", self, "TOPRIGHT",0,1)
    -- local vbar1 = CreateStatusBar(self, 4, 19, "TOPRIGHT", self, "TOPRIGHT",-9,2, nil, true)

    local debuffSize = Aptechka.db.debuffSize
    self.debuffIcons = { parent = self }
    self.debuffIcons.Align = AlignDebuffIcons

    for i=1, 4 do
        local dicon = CreateDebuffIcon(self, debuffSize, debuffSize, 1, "BOTTOMLEFT", self, "BOTTOMLEFT", 0,0)
        table.insert(self.debuffIcons, dicon)
    end

    self.debuffIcons:Align("VERTICAL")

    -- local brcorner = CreateCorner(self, 21, 21, "BOTTOMRIGHT", self, "BOTTOMRIGHT",0,0)
    local blcorner = CreateCorner(self, 12, 12, "BOTTOMLEFT", self.dicon1, "BOTTOMRIGHT",0,0, "BOTTOMLEFT") --last arg changes orientation

    local trcorner = CreateCorner(self, 16, 30, "TOPRIGHT", self, "TOPRIGHT",0,0, "TOPRIGHT")
    self.healfeedback = trcorner

    self.SetJob = SetJob_Frame
    self.HideFunc = Frame_HideFunc

    self.health = hp
    self.health.incoming = hpi
    self.text1 = text
    self.text2 = text2
    self.healthtext = self.text2
    self.text3 = text3
    self.power = powerbar

    self.border = border

    -- self.spell1 = br
    -- self.spell2 = topind
    -- self.spell3 = tr
    -- self.spell4 = btm
    -- self.spell5 = left
    -- self.bar1 = bar1
    -- self.bar2 = bar2
    -- self.bar3 = bar3
    -- self.bar4 = vbar1
    -- self.bars = bars




    -- self.bars = bars

    self._optional_widgets = optional_widgets

    if not Aptechka.widget_list then
        local list = {}
        for slot in pairs(optional_widgets) do
            list[slot] = slot
        end
        list["raidbuff"] = "raidbuff"
        list["healfeedback"] = "healfeedback"
        list["icon"] = "icon"
        list["bar1"] = nil
        list["bar2"] = nil
        list["bar3"] = nil
        Aptechka.widget_list = list
    end

    for id, spell in pairs(config.auras) do
        if type(spell.assignto) == "string" then
            local widget = spell.assignto
            if not self[widget] and optional_widgets[widget] then
                self[widget] = optional_widgets[widget](self, optional_widgets)
            end
        else
            for _,widget in ipairs(spell.assignto) do
                if not self[widget] and optional_widgets[widget] then
                    self[widget] = optional_widgets[widget](self, optional_widgets)
                end
            end
        end
    end

    self.bossdebuff = blcorner
    self.dispel = nil
    self.icon = icon
    self.castIcon = progressIcon
    self.raidicon = raidicon
    self.roleicon = roleicon
    self.healabsorb = healAbsorb
    self.absorb = absorb
    self.absorb2 = absorb2
    self.centericon = centericon

    self.OnMouseEnterFunc = OnMouseEnterFunc
    self.OnMouseLeaveFunc = OnMouseLeaveFunc
    self.OnDead = OnDead
    self.OnAlive = OnAlive
end

--~ AptechkaDefaultConfig.GridSkinInverted = function(self)  -- oooh, it looks like shit
--~     AptechkaDefaultConfig.GridSkin(self)
--~     AptechkaDefaultConfig.useAnchors = "GridSkin" -- use parent skin anchors
--~     local newSetJob_HealthBar = function(self, job)
--~         local c
--~         if job.classcolor then
--~             c = self.parent.classcolor
--~         elseif job.color then
--~             c = job.color
--~         end
--~         if c then
--~             self:SetStatusBarColor(unpack(c))
--~             self.bg:SetVertexColor(c[1]/3,c[2]/3,c[3]/3)
--~         end
--~     end
--~     self.health.SetJob = newSetJob_HealthBar
--~     self.power.SetJob = newSetJob_HealthBar
--~ end
