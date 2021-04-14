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
        iconCoords = { 0.125, 0.825, 0.11, 0.81 },

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
            Aptechka:OpenGUI()
            --[[
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
            ]]
		end,

		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end

            GameTooltip_SetTitle(tooltip, string.format("%s    %s",addonName, GetAddOnMetadata(addonName, "version")))
            GameTooltip_AddInstructionLine(tooltip, string.format("LeftClick - %s", L"Profile Settings"))
            GameTooltip_AddInstructionLine(tooltip, string.format("Shift-LeftClick - %s", L"Widgets"))
            GameTooltip_AddInstructionLine(tooltip, string.format("|cffc9e06cCtrl-LeftClick - %s|r", L"Unlock"))
            GameTooltip_AddInstructionLine(tooltip, string.format("RightClick - %s", L"Spell List"))
            GameTooltip_AddInstructionLine(tooltip, string.format("Shift-RightClick - %s", L"Status List"))
            GameTooltip_AddInstructionLine(tooltip, string.format("|cffe0896cMiddleClick - %s|r", L"Hide Icon"))
		end
	})

    LDBIcon:Register(addonName, LDB_Object, db)
end