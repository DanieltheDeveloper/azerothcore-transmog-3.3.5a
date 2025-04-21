-- Initialize the Ace3 library.
local addonName, addon = ...
Transmogrification = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Transmogrification")

-- Declare default AddOn options. AddOn options are saved globally.
local defaultTransmogrificationOptions = {
	global = {
		windowScale = 1.0,
		windowOpacity = 1.0,
		windowLock = false,
		displayNewAppearanceTooltip = true,
		displayCollectionMessages = true
	}
}

-- Disable the item tooltip system (if disabled) to save performance.
function Transmogrification:HookItemTooltip()
	if not self.db.global.displayNewAppearanceTooltip then return end
end

-- Hook into the system chat message function.
function Transmogrification:HookChatFilter()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
		-- Filter appearance collection messages if the player has decided to hide new item appearance messages.
		if not Transmogrification.db.global.displayCollectionMessages and
			-- Ensure the new item appearance messages matches the locale sent by the server.
			msg:find(L["has been added to your appearance collection."]) then
			return true
		end
		return false
	end)
end

-- Apply custom Transmogrification window styling.
function Transmogrification:ApplyWindowSettings()
	-- Set the Transmogrification window scale.
	if not TransmogrificationFrame then return end
	TransmogrificationFrame:SetScale(self.db.global.windowScale)
	
	-- Set the Transmogrification window opacity.
	if TransmogrificationFrame.SetAlpha then
		TransmogrificationFrame:SetAlpha(self.db.global.windowOpacity)
	end
	
	-- Lock the Transmogrification window if the player has decided to.
	if self.db.global.windowLock then
		TransmogrificationFrame:SetMovable(false)
		TransmogrificationFrame:RegisterForDrag()
	else
		TransmogrificationFrame:SetMovable(true)
		TransmogrificationFrame:RegisterForDrag("LeftButton")
	end
end

-- Reload prompt function.
function Transmogrification:DisplayReloadPrompt()
	StaticPopupDialogs["TRANSMOGRIFICATION_RELOAD_PROMPT"] = {
		text = L["Would you like to reload the interface?"],
		button1 = L["Yes"],
		button2 = L["No"],
		OnAccept = function()
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	StaticPopup_Show("TRANSMOGRIFICATION_RELOAD_PROMPT")
end

function Transmogrification:OnInitialize()
	-- Initialize the TransmogrificationOptions database and options table.
	self.db = LibStub("AceDB-3.0"):New("TransmogrificationOptions", defaultTransmogrificationOptions)
	self:RegisterOptions()
	
	-- Register chat commands.
	self:RegisterChatCommand("tmog", "HandleSlashCommand")
	self:RegisterChatCommand("transmog", "HandleSlashCommand")
	self:RegisterChatCommand("transmogrify", "HandleSlashCommand")
	self:RegisterChatCommand("transmogrification", "HandleSlashCommand")
	
	-- Initialize the CollectedAppearances table if it does not already exist.
	if CollectedAppearances == nil then
		CollectedAppearances = {}
	end
end

function Transmogrification:OnEnable()
	-- Hook into the item tooltip system to (if enabled) display the "New Appearance" tooltip text.
	self:HookItemTooltip()
	
	-- Hook into the system chat message function to (if enabled) hide new item appearance system messages.
	self:HookChatFilter()
	
	-- Apply custom Transmogrification window styling.
	self:ApplyWindowSettings()
end

function Transmogrification:HandleSlashCommand(input)
	-- Display the options panel if the command argument is "config(s)", "option(s)", or "setting(s)".
	if input:trim() == "config" or input:trim() == "configs" or input:trim() == "option" or input:trim() == "options" or input:trim() == "setting" or input:trim() == "settings" then
		InterfaceOptionsFrame_OpenToCategory(addonName)
	-- Sync collected appearances from the server to the CollectedAppearances table and send the reload prompt when finished if the command argument is "sync".
	elseif input:trim() == "sync" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L["Querying the server for collected transmogrification appearances..."] .. "\n")
		ChatFrame1EditBox:SetText(".transmog sync")
		ChatEdit_SendText(ChatFrame1EditBox, 1)
	else
		if TransmogrificationFrame and TransmogrificationFrame:IsShown() then
			TransmogrificationFrame:Hide()
		else
			if TransmogrificationFrame then
				TransmogrificationFrame:Show()
			end
		end
	end
end

-- Register the options window within the Interface AddOn window.
function Transmogrification:RegisterOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, GetTransmogrificationOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
end

-- Register the ConsoleVariableOptions database.
function Transmogrification:GetSettings()
	return self.db.global
end

-- Update settings.
function Transmogrification:UpdateSetting(key, value)
	if self.db.global[key] ~= nil then
		self.db.global[key] = value
		self:ApplyWindowSettings()
	end
end
