-- Options table for Transmogrification AddOn.
local addonName, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Transmogrification")

-- Function to get the options table.
function GetTransmogrificationOptions()
	local options = {
		name = addonName,
		handler = Transmogrification,
		type = "group",
		args = {
			transmogrificationWindow = {
				name = L["Transmogrification Window Options"],
				order = 1,
				type = "header",
			},
			windowScale = {
				name = "|cffffffff" .. L["Transmogrification Window Scale"],
				desc = "|cffffd200" .. L["Determines the scale of the Transmogrification window."],
				order = 2,
				type = "range",
				min = 0.2,
				max = 4,
				softMin = 0.5,
				softMax = 2,
				step = 0.05,
				width = "double",
				get = function() return Transmogrification:GetSettings().windowScale end,
				set = function(_, value) Transmogrification:UpdateSetting("windowScale", value) end,
			},
			windowOpacity = {
				name = "|cffffffff" .. L["Transmogrification Window Opacity"],
				desc = "|cffffd200" .. L["Determines the opacity of the Transmogrification window."],
				order = 3,
				type = "range",
				min = 0.1,
				max = 1,
				softMin = 0.2,
				softMax = 1,
				step = 0.05,
				width = "double",
				get = function() return Transmogrification:GetSettings().windowOpacity end,
				set = function(_, value) Transmogrification:UpdateSetting("windowOpacity", value) end,
			},
			windowLock = {
				name = "|cffffffff" .. L["Transmogrification Window Lock"],
				desc = "|cffffd200" .. L["Locks the position of the Transmogrification window."],
				order = 4,
				type = "toggle",
				width = "double",
				get = function() return Transmogrification:GetSettings().windowLock end,
				set = function(_, value) Transmogrification:UpdateSetting("windowLock", value) end,
			},
			spacer1 = {
				name = " ",
				desc = " ",
				order = 4,
				type = "description",
				fontSize = "large",
				width = "full",
			},
			spacer2 = {
				name = " ",
				desc = " ",
				order = 5,
				type = "description",
				fontSize = "medium",
				width = "full",
			},
			displayOptions = {
				name = L["Display Options"],
				order = 10,
				type = "header",
			},
			displayNewAppearanceTooltip = {
				name = "|cffffffff" .. L["Display New Appearance Tooltip"],
				desc = "|cffffd200" .. L["Toggles the display of the "] .. "|cff" .. L["f194f7"] .. L["New Appearance"] .. "|cffffd200" .. L[" tooltip line."],
				order = 11,
				type = "toggle",
				width = "double",
				get = function() return Transmogrification:GetSettings().displayNewAppearanceTooltip end,
				set = function(_, value) Transmogrification:UpdateSetting("displayNewAppearanceTooltip", value)
					DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L["You must "] .. "|cff" .. L["00ccff"] .. L["/reload"] .. "|cffffff00" .. L[" the interface for this change to take effect."])
					Transmogrification:DisplayReloadPrompt()
					end,
			},
			displayCollectionMessages = {
				name = "|cffffffff" .. L["Display Collection Messages"],
				desc = "|cffffd200" .. L["Toggles the display of the new appearance system message when collecting a new transmogrification appearance."],
				order = 12,
				type = "toggle",
				width = "double",
				get = function() return Transmogrification:GetSettings().displayCollectionMessages end,
				set = function(_, value) Transmogrification:UpdateSetting("displayCollectionMessages", value) end,
			},
			spacer3 = {
				name = " ",
				desc = " ",
				order = 13,
				type = "description",
				fontSize = "large",
				width = "full",
			},
			spacer4 = {
				name = " ",
				desc = " ",
				order = 14,
				type = "description",
				fontSize = "medium",
				width = "full",
			},
			collectionManagement = {
				name = L["Collection Management"],
				order = 20,
				type = "header",
			},
			syncCollection = {
				name = "|cffffffff" .. L["Sync Collection"],
				desc = "|cffffd200" .. L["Creates a local list of collected transmogrification appearances. The collected transmogrification appearances list is used to display the "] .. "|cff" .. L["f194f7"] .. L["New Appearance"] .. "|cffffd200" .. L[" tooltip."] .. "\n\n" .. L["This button provides the same function as using the "] .. "|cff" .. L["00ccff"] .. L["/transmog sync"] .. "|cffffd200" .. L[" command."],
				order = 21,
				type = "execute",
				func = function()
					ChatFrame1EditBox:SetText(".transmog sync")
					ChatEdit_SendText(ChatFrame1EditBox, 1)
					Transmogrification:DisplayReloadPrompt()
				end,
			},
		},
	}
	return options
end