local addonName, helpers = ...
local L = Aptechka.L
local LDBIcon = LibStub("LibDBIcon-1.0")

function Aptechka:ToggleMinimapIcon()
    self.db.global.LDBData.hide = not self.db.global.LDBData.hide
    if self.db.global.LDBData.hide then
        LDBIcon:Hide(addonName)
    else
        if not LDBIcon:IsRegistered(addonName) then
            self:CreteMinimapIcon()
        end
        LDBIcon:Show(addonName)
    end
end

function Aptechka:CreteMinimapIcon()
    local db = self.db.global.LDBData
    local LDB_Object = LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
		type = 'launcher',

        icon = 135966, -- spell_holy_sealofsacrifice
        iconCoords = { 0.12, 0.82, 0.15, 0.85 },

        OnClick = function(_, button)
            if button == "MiddleButton" then
                db.hide = true
                LDBIcon:Hide(addonName)
                return
            end

            if button == "LeftButton" and IsControlKeyDown() then
                return Aptechka:ToggleUnlock()
            end


            LoadAddOn('AptechkaOptions')
            InterfaceOptionsFrame_OpenToCategory("Aptechka")
			if button == 'LeftButton' then
				if IsShiftKeyDown() then
					InterfaceOptionsFrame_OpenToCategory(AptechkaOptions.widgets)
				else
					InterfaceOptionsFrame_OpenToCategory(AptechkaOptions.profile)
				end
			elseif button == 'RightButton' then
				if IsShiftKeyDown() then
					InterfaceOptionsFrame_OpenToCategory(AptechkaOptions.statusList)
				else
					InterfaceOptionsFrame_OpenToCategory(AptechkaOptions.spellList)
				end
			end
		end,

		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end

            GameTooltip_SetTitle(tooltip, addonName)
            GameTooltip_AddInstructionLine(tooltip, "LeftClick - Profile Settings")
            GameTooltip_AddInstructionLine(tooltip, "Shift-LeftClick - Widgets")
            GameTooltip_AddInstructionLine(tooltip, "|cffc9e06cCtrl-LeftClick - Toggle Unlock|r")
            GameTooltip_AddInstructionLine(tooltip, "RightClick - Spell List")
            GameTooltip_AddInstructionLine(tooltip, "Shift-RightClick - Status List")
            GameTooltip_AddInstructionLine(tooltip, "|cffe0896cMiddleClick - Hide Icon|r")
		end
	})

    LDBIcon:Register(addonName, LDB_Object, db)
end