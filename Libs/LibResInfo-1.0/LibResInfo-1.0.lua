--[[--------------------------------------------------------------------
LibResInfo-1.0
Library to provide information about resurrections in your group.
Copyright (c) 2012-2013 A. Kinley <addons@phanx.net>. All rights reserved.
See the accompanying README and LICENSE files for more information.

Things to do:
* Refactor messy and redundant sections.
* Fire ResCastStarted for units who die while Mass Res is casting.
* Fire ResCastStopped for units who res while Mass Res is casting.

Things that can't be done:
* Detect when a pending res is declined manually.
* Detect resurrections cast by or on players outside the group.
* Detect pending resurrections on units who were not in the group
  when the res spell was cast.
----------------------------------------------------------------------]]

local DEBUG_LEVEL = 0
local DEBUG_FRAME = ChatFrame1

------------------------------------------------------------------------

local MAJOR, MINOR = "LibResInfo-1.0", 7
assert(LibStub, MAJOR.." requires LibStub")
assert(LibStub("CallbackHandler-1.0"), MAJOR.." requires CallbackHandler-1.0")
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

------------------------------------------------------------------------

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")

lib.guidFromUnit = lib.guidFromUnit or {}
lib.nameFromGUID = lib.nameFromGUID or {}
lib.unitFromGUID = lib.unitFromGUID or {}

lib.castStart = lib.castStart or {}
lib.castEnd = lib.castEnd or {}
lib.castTarget = lib.castTarget or {}
lib.castMass = lib.castMass or {}

lib.resCasting = lib.resCasting or {}
lib.resPending = lib.resPending or {}

lib.total = lib.total or {}

lib.ghost = lib.ghost or {}

------------------------------------------------------------------------

local callbacks = lib.callbacks
local f = lib.eventFrame

local guidFromUnit = lib.guidFromUnit -- unit = guid
local nameFromGUID = lib.nameFromGUID -- guid = name
local unitFromGUID = lib.unitFromGUID -- guid = unit

local castStart = lib.castStart   -- caster guid = cast start time
local castEnd = lib.castEnd       -- caster guid = cast end time
local castTarget = lib.castTarget -- caster guid = target guid
local castMass = lib.castMass     -- caster guid = casting Mass Res

local resCasting = lib.resCasting  -- dead guid = # res spells being cast on them
local resPending  = lib.resPending -- dead guid = expiration time

local total = lib.total
total.casting = total.casting or 0 -- # res spells being cast
total.pending = total.pending or 0 -- # resses available to take

local ghost = lib.ghost

if DEBUG_LEVEL > 0 then
	LibResInfo = lib
end

------------------------------------------------------------------------

local RESURRECT_PENDING_TIME = 60
local RECENTLY_MASS_RESURRECTED = GetSpellInfo(95223)

local resSpells = {
	[2008]   = GetSpellInfo(2008),   -- Ancestral Spirit (shaman)
	[8342]   = GetSpellInfo(8342),   -- Defibrillate (item: Goblin Jumper Cables)
	[22999]  = GetSpellInfo(22999),  -- Defibrillate (item: Goblin Jumper Cables XL)
	[54732]  = GetSpellInfo(54732),  -- Defibrillate (item: Gnomish Army Knife)
	[126393] = GetSpellInfo(126393), -- Eternal Guardian (hunter pet: quilien)
	[61999]  = GetSpellInfo(61999),  -- Raise Ally (death knight)
	[20484]  = GetSpellInfo(20484),  -- Rebirth (druid)
	[113269] = GetSpellInfo(113269), -- Rebirth (prot/holy paladin symbiosis)
	[7328]   = GetSpellInfo(7328),   -- Redemption (paladin)
	[2006]   = GetSpellInfo(2006),   -- Resurrection (priest)
	[115178] = GetSpellInfo(115178), -- Resuscitate (monk)
	[50769]  = GetSpellInfo(50769),  -- Revive (druid)
	[982]    = GetSpellInfo(982),    -- Revive Pet (hunter)
	[20707]  = GetSpellInfo(20707),  -- Soulstone (warlock)
	[83968]  = GetSpellInfo(83968),  -- Mass Resurrection
}

------------------------------------------------------------------------

f:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("INCOMING_RESURRECT_CHANGED")
f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
f:RegisterEvent("UNIT_SPELLCAST_START")
f:RegisterEvent("UNIT_SPELLCAST_STOP")
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

------------------------------------------------------------------------

local function debug(level, text, ...)
	if level <= DEBUG_LEVEL then
		if select("#", ...) > 0 then
			if type(text) == "string" and strfind(text, "%%[dfqsx%d%.]") then
				text = format(text, ...)
			else
				text = strjoin(" ", tostringall(text, ...))
			end
		else
			text = tostring(text)
		end
		DEBUG_FRAME:AddMessage("|cff00ddba[LRI]|r " .. text)
	end
end

------------------------------------------------------------------------

function lib:UnitHasIncomingRes(unit)
	if type(unit) == "string" then
		local guid
		if strmatch(unit, "^0x") then
			guid = unit
			unit = unitFromGUID[unit]
		else
			guid = UnitGUID(unit)
			unit = unitFromGUID[guid]
		end
		if guid and unit and UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) then
			if resPending[guid] then
				debug(2, "UnitHasIncomingRes", nameFromGUID[guid], "PENDING")
				return "PENDING", resPending[guid]
			else
				local firstCaster, firstEnd
				for casterGUID, targetGUID in pairs(castTarget) do
					if targetGUID == guid then
						local endTime = castEnd[casterGUID]
						if endTime and (not firstEnd or endTime < firstEnd) then
							firstCaster, firstEnd = casterGUID, endTime
						end
					end
				end
				if not UnitDebuff(unit, RECENTLY_MASS_RESURRECTED) then
					for casterGUID in pairs(castMass) do
						local endTime = castEnd[casterGUID]
						if endTime and (not firstEnd or endTime < firstEnd) then
							firstCaster, firstEnd = casterGUID, endTime
						end
					end
				end
				if firstCaster and firstEnd then
					debug(2, "UnitHasIncomingRes", nameFromGUID[guid], "CASTING", nameFromGUID[firstCaster])
					return "CASTING", firstEnd, unitFromGUID[firstCaster], firstCaster
				end
			end
		end
		debug(3, "UnitHasIncomingRes", nameFromGUID[guid], "nil")
	end
end

function lib:UnitIsCastingRes(unit)
	if type(unit) == "string" then
		local guid
		if strmatch(unit, "^0x") then
			guid = unit
			unit = unitFromGUID[unit]
		else
			guid = UnitGUID(unit)
			unit = unitFromGUID[guid]
		end
		if guid and unit then
			debug(4, unit, guid, nameFromGUID[guid])
			local isFirst, targetGUID, endTime = true, castTarget[guid], castEnd[guid]
			if targetGUID then
				if resPending[targetGUID] then
					isFirst = nil
				else
					for k, v in pairs(castTarget) do
						if k ~= guid and v == targetGUID and castEnd[k] < endTime then
							isFirst = nil
							break
						end
					end
					for k in pairs(castMass) do
						if k ~= guid and castEnd[k] < endTime then
							isFirst = nil
							break
						end
					end
				end
				debug(2, "UnitIsCastingRes", nameFromGUID[guid], nameFromGUID[targetGUID], isFirst)
				return endTime, unitFromGUID[targetGUID], targetGUID, isFirst

			elseif castMass[guid] then
				for k in pairs(castMass) do
					if k ~= guid and castEnd[k] < endTime then
						isFirst = nil
						break
					end
				end
				debug(2, "UnitIsCastingRes", nameFromGUID[guid], "MASS", isFirst)
				return endTime, nil, nil, isFirst
			end
			return debug(3, "UnitIsCastingRes", nameFromGUID[guid], "NIL")
		end
		return debug(3, "UnitIsCastingRes", unit, "INVALID")
	end
	debug(3, "UnitIsCastingRes", tostring(unit), "INVALID", type(unit))
end

------------------------------------------------------------------------

local unitFromGUID_old, guidFromUnit_old = {}, {}

function f:GROUP_ROSTER_UPDATE()
	debug(3, "GROUP_ROSTER_UPDATE")

	wipe(guidFromUnit_old)
	wipe(unitFromGUID_old)
	for k,v in pairs(unitFromGUID) do
		unitFromGUID_old[k] = v
		unitFromGUID[k] = nil
	end
	for k,v in pairs(guidFromUnit) do
		guidFromUnit_old[k] = v
		guidFromUnit[k] = nil
	end

	if IsInRaid() then
		debug(4, "raid")
		local unit, guid
		for i = 1, GetNumGroupMembers() do
			unit = "raid"..i
			guid = UnitGUID(unit)
			if guid then
				guidFromUnit[unit] = guid
				nameFromGUID[guid] = UnitName(unit)
				unitFromGUID[guid] = unit
			end
			unit = "raidpet"..i
			guid = UnitGUID(unit)
			if guid then
				guidFromUnit[unit] = guid
				nameFromGUID[guid] = UnitName(unit)
				unitFromGUID[guid] = unit
			end
		end
	else
		local unit, guid = "player", UnitGUID("player")
		guidFromUnit[unit] = guid
		nameFromGUID[guid] = UnitName(unit)
		unitFromGUID[guid] = unit

		unit, guid = "pet", UnitGUID("pet")
		if guid then
			guidFromUnit[unit] = guid
			nameFromGUID[guid] = UnitName(unit)
			unitFromGUID[guid] = unit
		end

		if IsInGroup() then
			debug(4, "party")
			for i = 1, GetNumGroupMembers() - 1 do
				unit = "party"..i
				guid = UnitGUID(unit)
				if guid then
					guidFromUnit[unit] = guid
					nameFromGUID[guid] = UnitName(unit)
					unitFromGUID[guid] = unit
				end
				unit = "partypet"..i
				guid = UnitGUID(unit)
				if guid then
					guidFromUnit[unit] = guid
					nameFromGUID[guid] = UnitName(unit)
					unitFromGUID[guid] = unit
				end
			end
		else
			debug(4, "solo")
		end
	end

	-- Someone left the group while casting a res.
	-- Find who they were casting on and cancel it.
	for caster in pairs(castEnd) do
		if not unitFromGUID[caster] then
			debug(4, nameFromGUID[caster], "left while casting.")
			castStart[caster], castEnd[caster] = nil, nil
			local target = castTarget[caster]
			if target then
				if resCasting[target] > 1 then
					resCasting[target] = resCasting[target] - 1
				else
					resCasting[target] = nil
				end
				castTarget[caster] = nil
				debug(1, ">> ResCastCancelled", "on", nameFromGUID[target], "by", nameFromGUID[caster])
				callbacks:Fire("LibResInfo_ResCastCancelled", unitFromGUID[target], target, unitFromGUID_old[caster], caster)
			elseif castMass[caster] then
				castMass[caster] = nil
				for guid, unit in pairs(guidFromUnit) do
					if UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) and not UnitDebuff(unit, RECENTLY_MASS_RESURRECTED) then
						if resCasting[guid] > 0 then
							resCasting[guid] = resCasting[guid] - 1
						else
							resCasting[guid] = nil
						end
						debug(1, ">> ResCastCancelled", "on", nameFromGUID[caster], "by", nameFromGUID[guid])
						callbacks:Fire("LibResInfo_ResCastCancelled", unitFromGUID[target], target, unitFromGUID_old[caster], caster)
					end
				end
			end
		end
	end

	-- Someone left the group while a res was being cast on them.
	-- Find the cast and cancel it.
	for target, n in pairs(resCasting) do
		if not unitFromGUID[target] then
			debug(4, nameFromGUID[target], "left while incoming.")
			for caster, castertarget in pairs(castTarget) do
				if target == castertarget then
					resCasting[target] = nil
					castTarget[caster], castStart[caster], castEnd[caster] = nil, nil, nil
					debug(1, ">> ResCastCancelled", "on", nameFromGUID[target], "by", nameFromGUID[caster])
					callbacks:Fire("LibResInfo_ResCastCancelled", unitFromGUID[target], target, unitFromGUID_old[caster], caster)
				end
			end
			for caster in pairs(castMass) do
				debug(1, ">> ResCastCancelled", "on", nameFromGUID[target], "by", nameFromGUID[caster])
				callbacks:Fire("LibResInfo_ResCastCancelled", unitFromGUID[target], target, unitFromGUID_old[caster], caster)
			end
		end
	end

	-- Someone left the group when they had a res available.
	-- Find the res and cancel it.
	for target in pairs(resPending) do
		if not unitFromGUID[target] then
			debug(3, nameFromGUID[target], "left while pending.")
			resPending[target] = nil
			total.pending = total.pending - 1
			debug(1, ">> ResExpired", "on", nameFromGUID[target])
			callbacks:Fire("LibResInfo_ResExpired", unitFromGUID_old[target], target)
		end
	end

	-- Check events
	debug(3, "# pending:", total.pending)
	if total.pending == 0 then
		self:UnregisterEvent("UNIT_HEALTH")
		self:Hide()
	end

	local most = 0
	for _, n in pairs(resCasting) do
		most = max(n, most)
	end
	debug(3, "highest # casting:", most)
	if most < 2 then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end

	for guid, name in pairs(nameFromGUID) do
		if not unitFromGUID[guid] then
			nameFromGUID[guid] = nil
		end
	end
end

------------------------------------------------------------------------

function f:INCOMING_RESURRECT_CHANGED(event, unit)
	if guidFromUnit[unit] then
		local guid = UnitGUID(unit)
		local hasRes = UnitHasIncomingResurrection(unit)
		debug(3, "INCOMING_RESURRECT_CHANGED", nameFromGUID[guid], hasRes)

		if hasRes then
			local now, found = GetTime()
			for casterGUID, startTime in pairs(castStart) do
				if startTime - now < 10 and not castTarget[casterGUID] and not castMass[casterGUID] then -- time in ms between cast start and res gain
					if not castMass[casterGUID] then
						castTarget[casterGUID] = guid
					end
					if resCasting[guid] then
						resCasting[guid] = resCasting[guid] + 1
					else
						resCasting[guid] = 1
					end
					local casterUnit = unitFromGUID[casterGUID]
					debug(1, ">> ResCastStarted", "on", nameFromGUID[guid], "by", nameFromGUID[casterGUID], "DIFF", floor(now - startTime * 100) / 100, "#", resCasting[guid])
					callbacks:Fire("LibResInfo_ResCastStarted", unit, guid, casterUnit, casterGUID, castEnd[casterGUID])
					found = true
				end
			end
			if not found then
				debug(4, "No new cast found.")
			end
			for casterGUID, endTime in pairs(castEnd) do
				if endTime - now < 10 and not castStart[casterGUID] and not castMass[casterGUID] then -- time in ms between cast end and res loss
					local targetGUID = castTarget[casterGUID]
					if targetGUID == guid then
						local casterUnit = unitFromGUID[casterGUID]
						castTarget[casterGUID], castEnd[casterGUID] = nil, nil
						debug(1, ">> ResCastFinished", "on",nameFromGUID[guid], "by", nameFromGUID[casterGUID], "#", resCasting[guid], "hasRes")
						callbacks:Fire("LibResInfo_ResCastFinished", unit, guid, casterUnit, casterGUID)
					end
					total.casting = total.casting + 1
					debug(4, n, "casting, waiting for CLEU.")
					self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				end
			end

		elseif resCasting[guid] then
			-- had a res, doesn't anymore
			local finished, stopped
			for casterGUID, targetGUID in pairs(castTarget) do
				if targetGUID == guid then
					debug(4, nameFromGUID[casterGUID], "was casting...")
					if castStart[casterGUID] then
						debug(4, "...and stopped.")
						castStart[casterGUID], castEnd[casterGUID], castTarget[casterGUID] = nil, nil, nil

						debug(1, ">> ResCastCancelled", "on", nameFromGUID[guid], "by", nameFromGUID[casterGUID], "#", resCasting[guid] - 1)
						resCasting[guid] = nil
						callbacks:Fire("LibResInfo_ResCastCancelled", unit, guid, unitFromGUID[casterGUID], casterGUID)
					else
						debug(4, "...and finished.")
						castStart[casterGUID], castEnd[casterGUID], castTarget[casterGUID] = nil, nil, nil

						debug(1, ">> ResCastFinished", "on", nameFromGUID[guid], "by", nameFromGUID[casterGUID], "#", resCasting[guid] - 1, "resCasting")
						callbacks:Fire("LibResInfo_ResCastFinished", unit, guid, unitFromGUID[casterGUID], casterGUID)

						total.casting = total.casting + 1
						debug(3, n, "casting, waiting for CLEU")
						self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
					end
					break
				end
			end
		end
	end
end

------------------------------------------------------------------------

function f:UNIT_SPELLCAST_START(event, unit, spellName, _, _, spellID)
	if guidFromUnit[unit] and resSpells[spellID] then
		local guid = UnitGUID(unit)
		debug(3, event, "=>", nameFromGUID[guid], "=>", spellName)

		local _, _, _, _, startTime, endTime = UnitCastingInfo(unit)
		debug(4, "UnitCastingInfo =>", spellID, spellName, floor(startTime / 1000), floor(endTime / 1000))

		castStart[guid] = startTime / 1000
		castEnd[guid] = endTime / 1000

		if spellID == 83968 then -- Mass Resurrection
			castMass[guid] = true
			for targetGUID, targetUnit in pairs(unitFromGUID) do
				if UnitIsDeadOrGhost(targetUnit) and UnitIsConnected(targetUnit) and not UnitDebuff(targetUnit, RECENTLY_MASS_RESURRECTED) then
					debug(1, ">> ResCastStarted", "on", nameFromGUID[targetGUID], "by", nameFromGUID[guid])
					callbacks:Fire("LibResInfo_ResCastStarted", targetUnit, targetGUID, unit, guid, endTime / 1000)
				end
			end
		end
	end
end

function f:UNIT_SPELLCAST_SUCCEEDED(event, unit, spellName, _, _, spellID)
	if guidFromUnit[unit] and resSpells[spellID] then
		local guid = UnitGUID(unit)
		if castStart[guid] then
			debug(3, event, "=>", nameFromGUID[guid], "=>", spellName)
			castStart[guid] = nil

			if castMass[guid] then -- Mass Resurrection
				castEnd[guid] = nil

				local n = total.casting

				for targetGUID, targetUnit in pairs(unitFromGUID) do
					if UnitIsDeadOrGhost(targetUnit) and UnitIsConnected(targetUnit) and not UnitDebuff(targetUnit, RECENTLY_MASS_RESURRECTED) then
						debug(1, ">> ResCastFinished", "on", nameFromGUID[targetGUID], "by", nameFromGUID[guid])
						callbacks:Fire("LibResInfo_ResCastFinished", targetUnit, targetGUID, unit, guid)
						n = n + 1
					end
				end

				if n > 0 then
					debug(4, n, "casting, waiting for CLEU.")
					self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				end
			end
		end
	end
end

function f:UNIT_SPELLCAST_STOP(event, unit, spellName, _, _, spellID)
	if guidFromUnit[unit] and resSpells[spellID] then
		local guid = UnitGUID(unit)
		if castStart[guid] then
			debug(3, event, "=>", nameFromGUID[guid], "=>", spellName)
			local targetGUID = castTarget[guid]
			if targetGUID then
				local n = resCasting[targetGUID]
				if n and n > 1 then
					-- someone else is still casting, send cancellation here
					local targetUnit = unitFromGUID[targetGUID]
					castStart[guid], castEnd[guid], castTarget[guid] = nil, nil
					resCasting[targetGUID] = n - 1
					debug(1, ">> ResCastCancelled", "on", nameFromGUID[targetGUID], "by", nameFromGUID[guid])
					callbacks:Fire("LibResInfo_ResCastCancelled", targetUnit, targetGUID, unit, guid)
				else
					debug(4, "Waiting for IRC.")
				end

			elseif castMass[guid] then -- Mass Resurrection
				castStart[guid], castEnd[guid], castMass[guid] = nil, nil, nil
				for targetGUID, targetUnit in pairs(unitFromGUID) do
					if UnitIsDeadOrGhost(targetUnit) and UnitIsConnected(targetUnit) and not UnitDebuff(targetUnit, RECENTLY_MASS_RESURRECTED) then
						local n = resCasting[targetGUID]
						if n and n > 1 then
							resCasting[targetGUID] = n - 1
						else
							resCasting[targetGUID] = nil
						end
						debug(1, ">> ResCastCancelled", "on", nameFromGUID[targetGUID], "by", nameFromGUID[guid])
						callbacks:Fire("LibResInfo_ResCastCancelled", targetUnit, targetGUID, unit, guid)
					end
				end
			end
		end
	end
end

f.UNIT_SPELLCAST_INTERRUPTED = f.UNIT_SPELLCAST_STOP

------------------------------------------------------------------------

function f:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool)
	if combatEvent == "SPELL_RESURRECT" then
		local destUnit = unitFromGUID[destGUID]
		if destUnit then
			local now = GetTime()
			debug(3, combatEvent, "=>", sourceName, "=>", spellName, "=>", destName)

			local casting = resCasting[destGUID]
			if casting or castMass[sourceGUID] then
				debug(4, "yes")

				if casting and casting > 1 then
					resCasting[destGUID] = casting - 1
				else
					resCasting[destGUID] = nil
				end

				local new = not resPending[destGUID]
				resPending[destGUID] = now + RESURRECT_PENDING_TIME

				total.casting = total.casting - 1
				if total.casting == 0 then
					debug(4, "0 casting, unregister CLEU")
					self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				end

				if castMass[sourceGUID] then
					local n = 0
					for guid, unit in pairs(unitFromGUID) do
						if guid ~= destGUID and (not resPending[guid] or resPending[guid] - now > RESURRECT_PENDING_TIME) and UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) and not UnitDebuff(unit, RECENTLY_MASS_RESURRECTED) then
							n = n + 1
						end
					end
					if n == 0 then
						castMass[sourceGUID] = nil
					end
					debug(4, n, "mass targets left")
				end

				ghost[destUnit] = UnitIsGhost(destUnit)

				if new then
					total.pending = total.pending + 1
					debug(4, total.pending, "pending, start timer, register UNIT_HEALTH/AURA")
					self:RegisterEvent("UNIT_HEALTH")
					self:RegisterEvent("UNIT_AURA")
					self:Show()
				else
					debug(4, total.pending, "pending, timer already running")
				end

				debug(1, ">> ResPending", "on", strmatch(destName, "[^%-]+"), "by", strmatch(sourceName, "[^%-]+"))
				callbacks:Fire("LibResInfo_ResPending", destUnit, destGUID, now + RESURRECT_PENDING_TIME)
			end
		end
	end
end

------------------------------------------------------------------------

function f:UNIT_HEALTH(event, unit)
	local guid = guidFromUnit[unit]
	if guidFromUnit[unit] then
		if resPending[guid] then
			debug(3, event, nameFromGUID[guid], "Dead", UnitIsDead(unit), "Ghost", UnitIsGhost(unit), "Offline", not UnitIsConnected(unit))

			local lost

			if not UnitIsConnected(unit) then
				lost = "LibResInfo_ResExpired"

			elseif UnitIsGhost(unit) and not ghost[guid] then
				ghost[guid] = true
				lost = "LibResInfo_ResExpired"

			elseif not UnitIsDead(unit) then
				ghost[guid] = nil
				lost = "LibResInfo_ResUsed"
			end

			if lost then
				resPending[guid] = nil
				debug(1, ">>", lost, nameFromGUID[guid])
				callbacks:Fire(lost, unit, guid)

				total.pending = total.pending - 1
				if total.pending == 0 then
					debug(4, "0 pending, unregister UNIT_HEALTH/AURA")
					self:UnregisterEvent("UNIT_AURA")
					self:UnregisterEvent("UNIT_HEALTH")
				end
			end
		end
	end
end

f.UNIT_AURA = f.UNIT_HEALTH

------------------------------------------------------------------------

f:Hide()

local timer = 0
local INTERVAL = 0.5
f:SetScript("OnUpdate", function(self, elapsed)
	timer = timer + elapsed
	if timer >= INTERVAL then
		debug(6, "timer update")
		local now = GetTime()
		for guid, expiry in pairs(resPending) do
			if expiry - now < INTERVAL then -- will expire before next update
				local unit = unitFromGUID[guid]
				resPending[guid] = nil
				debug(1, ">> ResExpired", nameFromGUID[guid])
				callbacks:Fire("LibResInfo_ResExpired", unit, guid, true)

				total.pending = total.pending - 1
				if total.pending == 0 then
					self:UnregisterEvent("UNIT_HEALTH")
					self:Hide()
				end
			end
		end
		timer = 0
	end
end)

f:SetScript("OnShow", function()
	debug(4, "timer start")
end)

f:SetScript("OnHide", function()
	debug(4, "timer stop")
	timer = 0
end)

------------------------------------------------------------------------

SLASH_LIBRESINFO1 = "/lri"
SlashCmdList.LIBRESINFO = function(input)
	input = gsub(input, "[^A-Za-z0-9]", "")
	if strlen(input) > 0 then
		if strmatch(input, "%D") then
			local f = _G[input]
			if type(f) == "table" and type(f.AddMessage) == "function" then
				DEBUG_FRAME = f
				debug(0, "Debug frame set to", input)
			else
				debug(0, input, "is not a valid debug output frame!")
			end
		else
			local v = tonumber(input)
			if v and v >= 0 then
				DEBUG_LEVEL = v
				debug(0, "Debug level set to", input)
			else
				debug(0, input, "is not a valid debug level!")
			end
		end
	end
end