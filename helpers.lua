local _, helpers = ...

helpers.AddDispellType = function(dtype, data)
    if not InjectorConfig.DebuffTypes then InjectorConfig.DebuffTypes = {} end
    if type(data.indicator) == "string" then data.indicator = { data.indicator } end
    if type(data.icon) == "table" then data.icon = data.icon[1] end
    data.name = dtype
    InjectorConfig.DebuffTypes[dtype] = data
end
helpers.AddAura = function (data)
    if data.id then data.name = GetSpellInfo(data.id) end
    if type(data.indicator) == "string" then data.indicator = { data.indicator } end
    if type(data.icon) == "table" then data.icon = data.icon[1] end
    if data.isMine then data.type = data.type.."|PLAYER" end
    if data.debuffType then DT(data.debuffType, data) end
    if not InjectorConfig.IndicatorAuras then InjectorConfig.IndicatorAuras = {} end
    if data.prototype then setmetatable(data, { __index = function(t,k) return data.prototype[k] end }) end
    InjectorConfig.IndicatorAuras[data.name] = data
--~     table.insert(InjectorConfig.IndicatorAuras, data)
end
helpers.AddTrace = function(data)
    if not InjectorConfig.enableTraceHeals then return end
    if data.id then data.name = GetSpellInfo(data.id) end
    if type(data.indicator) == "string" then data.indicator = { data.indicator } end
    --if type(data.type) == "string" then data.type = { data.type } end
    data.type = "SPELL_"..data.type
    if not InjectorConfig.TraceHeals then InjectorConfig.TraceHeals = {} end
    if not data.name then print("id or name required") return end
    InjectorConfig.TraceHeals[data.name] = data
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

function helpers.DisableBlizzParty(self)
    for i=1,4 do
        local party = "PartyMemberFrame"..i
        local frame = _G[party]

        frame:UnregisterAllEvents()
        frame.Show = function()end
        frame:Hide()
        _G[party..'HealthBar']:UnregisterAllEvents()
        _G[party..'ManaBar']:UnregisterAllEvents()
    end
end

function helpers.Reverse(p1)
    local p2 = ""
    local dir
    if string.find(p1,"CENTER") then return "CENTER" end
    if string.find(p1,"TOP") then p2 = p2.."BOTTOM" end
    if string.find(p1,"BOTTOM") then p2 = p2.."TOP" end
    if string.find(p1,"LEFT") then p2 = p2.."RIGHT" end
    if string.find(p1,"RIGHT") then p2 = p2.."LEFT" end
    if p2 == "RIGHT" or p2 == "LEFT" then
        dir = "HORIZONTAL"
    elseif p2 == "TOP" or p2 == "BOTTOM" then
        dir = "VERTICAL"
    end
    return p2, dir
end









-- UIFrameFade clone from defauilt UI

local SCALEFRAMES = {}
local frameScaleManager = CreateFrame("FRAME");
-- Function that actually performs the scale change
--[[
Fading frame attribute listing
============================================================
frame.timeToScale  [Num]		Time it takes to scale the frame in or out
frame.mode  ["IN", "OUT"]	Scale mode
frame.finishedFunc [func()]	Function that is called when scaling is finished
frame.finishedArg1 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg2 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg3 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg4 [ANYTHING]	Argument to the finishedFunc
frame.scaleHoldTime [Num]	Time to hold the scaled state
 ]]
 
local function UIFrameScaleRemoveFrame(frame)
	tDeleteItem(SCALEFRAMES, frame);
end
 
local function UIFrameScale_OnUpdate(self, elapsed)
	local index = 1;
	local frame, scaleInfo;
	while SCALEFRAMES[index] do
		frame = SCALEFRAMES[index];
		scaleInfo = SCALEFRAMES[index].scaleInfo;
		-- Reset the timer if there isn't one, this is just an internal counter
		if ( not scaleInfo.scaleTimer ) then
			scaleInfo.scaleTimer = 0;
		end
		scaleInfo.scaleTimer = scaleInfo.scaleTimer + elapsed;

		-- If the scaleTimer is less then the desired scale time then set the scale otherwise hold the scale state, call the finished function, or just finish the scale 
		if ( scaleInfo.scaleTimer < scaleInfo.timeToScale ) then
			if ( scaleInfo.mode == "IN" ) then
				frame:SetScale((scaleInfo.scaleTimer / scaleInfo.timeToScale) * (scaleInfo.endScale - scaleInfo.startScale) + scaleInfo.startScale);
			elseif ( scaleInfo.mode == "OUT" ) then
				frame:SetScale(((scaleInfo.timeToScale - scaleInfo.scaleTimer) / scaleInfo.timeToScale) * (scaleInfo.startScale - scaleInfo.endScale)  + scaleInfo.endScale);
			end
		else
			frame:SetScale(scaleInfo.endScale);
			-- If there is a scaleHoldTime then wait until its passed to continue on
			if ( scaleInfo.scaleHoldTime and scaleInfo.scaleHoldTime > 0  ) then
				scaleInfo.scaleHoldTime = scaleInfo.scaleHoldTime - elapsed;
			else
				-- Complete the scale and call the finished function if there is one
				UIFrameScaleRemoveFrame(frame);
				if ( scaleInfo.finishedFunc ) then
					scaleInfo.finishedFunc(scaleInfo.finishedArg1, scaleInfo.finishedArg2, scaleInfo.finishedArg3, scaleInfo.finishedArg4);
					scaleInfo.finishedFunc = nil;
				end
			end
		end
		
		index = index + 1;
	end
	
	if ( #SCALEFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end


-- Generic scale function
local function UIFrameScale(frame, scaleInfo)
	if (not frame) then
		return;
	end
	if ( not scaleInfo.mode ) then
		scaleInfo.mode = "IN";
	end
	local scale;
	if ( scaleInfo.mode == "IN" ) then
		if ( not scaleInfo.startScale ) then
			scaleInfo.startScale = 0.01;
		end
		if ( not scaleInfo.endScale ) then
			scaleInfo.endScale = 1.0;
		end
		scale = 0;
	elseif ( scaleInfo.mode == "OUT" ) then
		if ( not scaleInfo.startScale ) then
			scaleInfo.startScale = 1.0;
		end
		if ( not scaleInfo.endScale ) then
			scaleInfo.endScale = 0.01;
		end
		scale = 1.0;
	end
	frame:SetScale(scaleInfo.startScale);

	frame.scaleInfo = scaleInfo;
	frame:Show();

	local index = 1;
	while SCALEFRAMES[index] do
		-- If frame is already set to scale then return
		if ( SCALEFRAMES[index] == frame ) then
			return;
		end
		index = index + 1;
	end
	tinsert(SCALEFRAMES, frame);
	frameScaleManager:SetScript("OnUpdate", UIFrameScale_OnUpdate);
end

-- Convenience function to do a simple scale in
local function UIFrameScaleIn(frame, timeToScale, startScale, endScale)
	local scaleInfo = {};
	scaleInfo.mode = "IN";
	scaleInfo.timeToScale = timeToScale;
	scaleInfo.startScale = startScale;
	scaleInfo.endScale = endScale;
	UIFrameScale(frame, scaleInfo);
end

-- Convenience function to do a simple scale out
local function UIFrameScaleOut(frame, timeToScale, startScale, endScale)
	local scaleInfo = {};
	scaleInfo.mode = "OUT";
	scaleInfo.timeToScale = timeToScale;
	scaleInfo.startScale = startScale;
	scaleInfo.endScale = endScale;
	UIFrameScale(frame, scaleInfo);
end


helpers.UIFrameScale = UIFrameScale
helpers.UIFrameScaleOut = UIFrameScaleOut
helpers.UIFrameScaleIn = UIFrameScaleIn