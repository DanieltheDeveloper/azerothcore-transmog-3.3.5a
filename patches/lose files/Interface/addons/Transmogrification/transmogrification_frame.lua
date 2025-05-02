-- Initialize the Ace3 library.
local addonName, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Transmogrification")

-- Establish AIO client protocol.
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
	return
end

-- Establish AIO handler table.
local TransmogrificationHandler = AIO.AddHandlers("TransmogrificationServer", {})

-- Define Transmogrification slot references.
PLAYER_VISIBLE_ITEM_1_ENTRYID  = 283 -- Head
PLAYER_VISIBLE_ITEM_3_ENTRYID  = 287 -- Shoulder
PLAYER_VISIBLE_ITEM_4_ENTRYID  = 289 -- Shirt
PLAYER_VISIBLE_ITEM_5_ENTRYID  = 291 -- Chest
PLAYER_VISIBLE_ITEM_6_ENTRYID  = 293 -- Waist
PLAYER_VISIBLE_ITEM_7_ENTRYID  = 295 -- Legs
PLAYER_VISIBLE_ITEM_8_ENTRYID  = 297 -- Feet
PLAYER_VISIBLE_ITEM_9_ENTRYID  = 299 -- Wrist
PLAYER_VISIBLE_ITEM_10_ENTRYID = 301 -- Hands
PLAYER_VISIBLE_ITEM_15_ENTRYID = 311 -- Back
PLAYER_VISIBLE_ITEM_16_ENTRYID = 313 -- Main Hand
PLAYER_VISIBLE_ITEM_17_ENTRYID = 315 -- Off Hand
PLAYER_VISIBLE_ITEM_18_ENTRYID = 317 -- Ranged
PLAYER_VISIBLE_ITEM_19_ENTRYID = 319 -- Tabard

transmogrificationEquipmentSlotMap = {
	[PLAYER_VISIBLE_ITEM_1_ENTRYID]  = "Head",
	[PLAYER_VISIBLE_ITEM_3_ENTRYID]  = "Shoulder",
	[PLAYER_VISIBLE_ITEM_4_ENTRYID]  = "Shirt",
	[PLAYER_VISIBLE_ITEM_5_ENTRYID]  = "Chest",
	[PLAYER_VISIBLE_ITEM_6_ENTRYID]  = "Waist",
	[PLAYER_VISIBLE_ITEM_7_ENTRYID]  = "Legs",
	[PLAYER_VISIBLE_ITEM_8_ENTRYID]  = "Feet",
	[PLAYER_VISIBLE_ITEM_9_ENTRYID]  = "Wrist",
	[PLAYER_VISIBLE_ITEM_10_ENTRYID] = "Hands",
	[PLAYER_VISIBLE_ITEM_15_ENTRYID] = "Back",
	[PLAYER_VISIBLE_ITEM_16_ENTRYID] = "MainHand",
	[PLAYER_VISIBLE_ITEM_17_ENTRYID] = "SecondaryHand",
	[PLAYER_VISIBLE_ITEM_18_ENTRYID] = "Ranged",
	[PLAYER_VISIBLE_ITEM_19_ENTRYID] = "Tabard"
}

local equipmentSlotIDs = {
	Head = PLAYER_VISIBLE_ITEM_1_ENTRYID,
	Shoulder = PLAYER_VISIBLE_ITEM_3_ENTRYID,
	Shirt = PLAYER_VISIBLE_ITEM_4_ENTRYID,
	Chest = PLAYER_VISIBLE_ITEM_5_ENTRYID,
	Waist = PLAYER_VISIBLE_ITEM_6_ENTRYID,
	Legs = PLAYER_VISIBLE_ITEM_7_ENTRYID,
	Feet = PLAYER_VISIBLE_ITEM_8_ENTRYID,
	Wrist = PLAYER_VISIBLE_ITEM_9_ENTRYID,
	Hands = PLAYER_VISIBLE_ITEM_10_ENTRYID,
	Back = PLAYER_VISIBLE_ITEM_15_ENTRYID,
	MainHand = PLAYER_VISIBLE_ITEM_16_ENTRYID,
	SecondaryHand = PLAYER_VISIBLE_ITEM_17_ENTRYID,
	Ranged = PLAYER_VISIBLE_ITEM_18_ENTRYID,
	Tabard = PLAYER_VISIBLE_ITEM_19_ENTRYID,
}

local characterEquipmentSlotNames = {
	"CharacterHeadSlot",
	"CharacterShoulderSlot",
	"CharacterBackSlot",
	"CharacterChestSlot",
	"CharacterShirtSlot",
	"CharacterTabardSlot",
	"CharacterWristSlot",
	"CharacterHandsSlot",
	"CharacterWaistSlot",
	"CharacterLegsSlot",
	"CharacterFeetSlot",
	"CharacterMainHandSlot",
	"CharacterSecondaryHandSlot",
	"CharacterRangedSlot"
}

local equipmentSlotIcons = {
	"Head",
	"",			-- Neck
	"Shoulder",
	"Shirt",
	"Chest",	-- Chest
	"Waist",
	"Legs",
	"Feet",
	"Wrists",
	"Hands",
	"",			-- Finger 1
	"",			-- Finger 2
	"",			-- Trinket 1
	"",			-- Trinket 2
	"Chest",	-- Robe
	"MainHand",
	"SecondaryHand",
	"Ranged",
	"Tabard"
}

-- Define Transmogrification frame variables.
local itemButtons = {}
local isInputHovered = false
local isTooltipHooked = false
local CurrentItemSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
local currentPage = 1
local currentSlotTooltip = nil
originalTransmogrificationIDs = originalTransmogrificationIDs or {}
previewTransmogrificationIDs = {}
currentTransmogrificationIDs = {}

for k, v in pairs(originalTransmogrificationIDs) do
	currentTransmogrificationIDs[k] = v
end

-- Cache global functions for performance.
local GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip = GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip

-- Define helper functions.
function CalculateInverseSlot(slot)
	local inverseSlot = (slot - 281) / 2
	return inverseSlot;
end

function TableSetHelper(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

-- Return equipment slot mapped entry.
function GetEquipmentSlot(displaySlot)
	local slotMapping = {
		[PLAYER_VISIBLE_ITEM_1_ENTRYID]  = 1,  -- Head
		[PLAYER_VISIBLE_ITEM_3_ENTRYID]  = 3,  -- Shoulder
		[PLAYER_VISIBLE_ITEM_4_ENTRYID]  = 4,  -- Shirt
		[PLAYER_VISIBLE_ITEM_5_ENTRYID]  = 5,  -- Chest
		[PLAYER_VISIBLE_ITEM_6_ENTRYID]  = 6,  -- Waist
		[PLAYER_VISIBLE_ITEM_7_ENTRYID]  = 7,  -- Legs
		[PLAYER_VISIBLE_ITEM_8_ENTRYID]  = 8,  -- Feet
		[PLAYER_VISIBLE_ITEM_9_ENTRYID]  = 9,  -- Wrist
		[PLAYER_VISIBLE_ITEM_10_ENTRYID] = 10, -- Hands
		[PLAYER_VISIBLE_ITEM_15_ENTRYID] = 15, -- Back
		[PLAYER_VISIBLE_ITEM_16_ENTRYID] = 16, -- Main Hand
		[PLAYER_VISIBLE_ITEM_17_ENTRYID] = 17, -- Off Hand
		[PLAYER_VISIBLE_ITEM_18_ENTRYID] = 18, -- Ranged
		[PLAYER_VISIBLE_ITEM_19_ENTRYID] = 19, -- Tabard
	}
	return slotMapping[displaySlot] or CalculateInverseSlot(displaySlot)
end

-- Return item ID for an equipment slot.
function GetItemIDForEquipmentSlot(slotName)
	local equipmentSlotName = equipmentSlotIDs[slotName]
	if equipmentSlotName then
		local equipmentSlot = GetEquipmentSlot(equipmentSlotName)
		if equipmentSlot then
			return GetInventoryItemID("player", equipmentSlot)
		end
	end
	return nil
end

-- Updates item icon texture when called.
function SetItemButtonTexture(button, texture)
	if (not button) then
		return
	end

	if (button.Icon or button.icon or (button:GetName() ~= nil and _G[button:GetName()] ~= nil and _G[button:GetName().."IconTexture"] ~= nil)) then
		local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
		if (texture) then
			icon:Show();
			_G[button:GetName().."IconTexture"]:SetTexture(texture);
		else
			icon:Hide();
		end
	end
end

-- Updates equipment slot textures when called.
function UpdateSlotTexture(slotName, isTransmogrificationFrame, useTransmogrificationPreview)
	local slotFrame
	
	-- Determines whether we are updating the Transmogrification window or the Character Info window.
	if isTransmogrificationFrame then
		slotFrame = _G["TransmogCharacter" .. slotName .. "Slot"]
	else
		slotFrame = _G["Character" .. slotName .. "Slot"]
	end
	
	if not slotFrame then return end
	
	-- Get the equipment icon texture from the button.
	local iconTexture = slotFrame.Icon or slotFrame.icon or _G[slotFrame:GetName().."IconTexture"]
	if not iconTexture then return end
	
	-- Determine which ID table to use.
	local transmogrificationTable = useTransmogrificationPreview and previewTransmogrificationIDs or currentTransmogrificationIDs
	local transmogrificationID = transmogrificationTable[slotName]
	
	-- Check to see if there is an item equipped in the slot.
	local slotID = equipmentSlotIDs[slotName]
	local equipSlot = GetEquipmentSlot(slotID)
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil
	
	-- If no item is equipped in the slot, force clear any transmogrification appearance.
	if not hasItem then
		-- No equipment means no transmogrification should be shown, reset the texture to normal.
		SetItemButtonTexture(slotFrame, slotFrame.backgroundTextureName or "")
		iconTexture:SetDesaturated(false)
		return
	end
	
	-- If there is an item equipped in the slot, proceed with transmogrification.
	if transmogrificationID ~= nil and transmogrificationID ~= 0 then
		-- Item has been transmogrified to another appearance, display the transmogrification equipment icon.
		SetItemButtonTexture(slotFrame, GetItemIcon(transmogrificationID))
		iconTexture:SetDesaturated(false)
	elseif transmogrificationID == 0 then
		-- Item appearance has been hidden, desaturate the original item icon.
		local originalTexture = GetInventoryItemTexture("player", equipSlot)
		if originalTexture then
			SetItemButtonTexture(slotFrame, originalTexture)
			iconTexture:SetDesaturated(true)
		else
			-- Fallback to the empty slot texture if for some reason the item icon could not be located.
			SetItemButtonTexture(slotFrame, slotFrame.backgroundTextureName)
			iconTexture:SetDesaturated(false)
		end
	else
		-- Item has not been transmogrified, display the original equipment icon.
		local itemTexture = GetInventoryItemTexture("player", equipSlot)
		if itemTexture then
			SetItemButtonTexture(slotFrame, itemTexture)
			iconTexture:SetDesaturated(false)
		else
			-- Fallback to the empty slot texture if for some reason the item icon could not be located.
			SetItemButtonTexture(slotFrame, slotFrame.backgroundTextureName)
			iconTexture:SetDesaturated(false)
		end
	end
end

-- Updates all equipment icons when called.
function UpdateAllSlotTextures(useTransmogrificationPreview)
	for slotName, _ in pairs(equipmentSlotIDs) do
		-- Update item icons in the Character Info window.
		UpdateSlotTexture(slotName, false, false)
		
		-- Update item icons in the Transmogrification window.
		UpdateSlotTexture(slotName, true, useTransmogrificationPreview)
	end
	
	-- Update paper doll frame (if visible) to display the new item icons.
	if PaperDollFrame:IsShown() then
		PaperDollFrame_UpdateStats()
	end
end

-- Clear transmogrification from the slot when unequipping an item.
function TransmogrificationHandler.ClearSlotTransmogrification(player, slot)
	-- Get the common slot name from the slot entry ID map.
	local slotName = transmogrificationEquipmentSlotMap[tonumber(slot)]

	-- If the common slot name is found at all, clear it from the client tables.
	if slotName then
		currentTransmogrificationIDs[slotName] = nil
		originalTransmogrificationIDs[slotName] = nil
		previewTransmogrificationIDs[slotName] = nil

		-- Update all equipment icons.
		UpdateAllSlotTextures(false)
	end
end

function OnClickItemTransmogrificationButton(btn, buttonType)
	PlaySound("igMainMenuOptionCheckBoxOn", "sfx")
	local itemID = btn:GetID()
	local textureName = GetItemIcon(itemID)
	local slotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]

	-- Determine if there is an item in the equipment slot.
	local equipSlot = GetEquipmentSlot(equipmentSlotIDs[slotName])
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil

	if not hasItem then
		return
	end

	-- Update the transmogrification preview for this slot.
	previewTransmogrificationIDs[slotName] = itemID

	-- Update the player model with the now item transmogrification preview.
	LoadTransmogrificationsFromCurrentIDs(true)

	-- Update the item icon in the Transmogrification window.
	UpdateSlotTexture(slotName, true, true)
end

function TransmogrificationHandler.SetTransmogItemIDClient(player, slot, id, realItemID)
	-- Get the equipment slot name.
	local part = transmogrificationEquipmentSlotMap[tonumber(slot)]
	if part then
		-- If the equipment slot name is found, initialize the applicable transmogrification tables.
		local currentTransmogID = currentTransmogrificationIDs[part]
		local originalTransmogID = originalTransmogrificationIDs[part]

		if (id ~= 0 and id ~= nil and (currentTransmogID == nil or currentTransmogID == 0) and realItemID ~= id) then
			currentTransmogrificationIDs[part] = id
			originalTransmogrificationIDs[part] = id
			TransmogrificationModelFrame:TryOn(id)
		elseif (currentTransmogID ~= nil and currentTransmogID ~= 0) then
				TransmogrificationModelFrame:TryOn(currentTransmogID)
		elseif (id ~= 0 and realItemID ~= 0 and realItemID ~= nil) then
			currentTransmogrificationIDs[part] = realItemID
			originalTransmogrificationIDs[part] = realItemID
				TransmogrificationModelFrame:TryOn(realItemID)
		end
	end

	-- Update all equipment icons.
	UpdateAllSlotTextures()
end

-- Receives and saves a local list of collected transmogrification appearances, useful for displaying the "New Appearance" tooltip line.
function TransmogrificationHandler.ReceiveCollectedAppearances(player, collectedAppearances, uniqueAppearancesCount)
	-- Clear the collected transmogrification appearances table.
	wipe(CollectedAppearances)

	-- Save received collected transmogrification appearances to a local table.
	for i, itemID in ipairs(collectedAppearances) do
		table.insert(CollectedAppearances, itemID)
	end
	
	local collectedAppearancesCount = uniqueAppearancesCount or 0

	if collectedAppearancesCount == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L["No transmogrification appearances could be located for this account. If you believe this is an error, please contact a Game Master."])
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L["Your transmogrification appearance collection has been successfully synchronized!"] .. "\n")
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L["You have collected "] .. "|cff" .. L["f194f7"] .. tostring(collectedAppearancesCount) .. "|cffffff00" .. L[" transmogrification appearances."] .. "\n")
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L["It is recommended that you "] .. "|cff" .. L["00ccff"] .. L["/reload"] .. "|cffffff00" .. L[" your interface to finalize any changes, otherwise the "] .. "|cff" .. L["f194f7"] .. L["New Appearance"] .. "|cffffff00" .. L[" tooltip line may not function correctly."])
		Transmogrification:DisplayReloadPrompt()
	end
end

-- Add new appearances to the local item list when receiving the new appearance system message.
-- We utilize the system message to naturally respect the server options in regards to when a new appearance should be added to the players collection.
-- That being said, this function will break if the system message string does not match the string in `server_transmog.lua`.
TransmogrificationHandler.ReceiveMatchingAppearances = function(player, originalItemID, matchingItems)
	-- Add all matching items to our local list
	for _, itemID in ipairs(matchingItems) do
		-- Check if already collected
		local alreadyCollected = false
		for _, id in ipairs(CollectedAppearances) do
			if id == itemID then
				alreadyCollected = true
				break
			end
		end
		
		-- If not already in the list, add it
		if not alreadyCollected then
			table.insert(CollectedAppearances, itemID)
		end
	end
end

local function AddNewAppearanceToLocalList()
	local chatMonitor = CreateFrame("Frame")
	chatMonitor:RegisterEvent("CHAT_MSG_SYSTEM")

	chatMonitor:SetScript("OnEvent", function(self, event, msg)
		if event == "CHAT_MSG_SYSTEM" and string.find(msg, L["has been added to your appearance collection."]) then

			-- Then extract the item from the system message using the link pattern.
			local itemLink = string.match(msg, "|Hitem:(%d+):[^|]+|h|c%x+%[[^%]]+%]|r|h|r")

			if itemLink then
				local itemID = tonumber(itemLink)

				if itemID then
					-- Determine if the item appearance has already been collected for some reason.
					local alreadyCollected = false
					for _, id in ipairs(CollectedAppearances) do
						if id == itemID then
							alreadyCollected = true
							break
						end
					end

					-- If the item appearance has not already been collected (this should always be the case) save it to the local list.
					if not alreadyCollected then
						table.insert(CollectedAppearances, itemID)
					end
					
					AIO.Handle("TransmogrificationServer", "GetItemsWithSameAppearance", itemID)
				end
			end
		end
	end)
end

-- Determine whether the new appearance system message should be displayed to the player.
-- This does not determine whether the item is added to the local list, just if the player should see the system message.
local function collectionMessageFilter(self, event, msg)
	if not Transmogrification.db.global.displayCollectionMessages and
		msg:find(L["has been added to your appearance collection."]) then
		return true -- Hide the system message.
	end
	return false -- Show the system message.
end

function LoadTransmogrificationsFromCurrentIDs(useTransmogrificationPreview)
	TransmogrificationModelFrame:SetUnit("player")

	-- Determine which IDs table to use.
	local transmogrificationTable = useTransmogrificationPreview and previewTransmogrificationIDs or currentTransmogrificationIDs

	-- Undress the model, we will update appearances further down in the function.
	TransmogrificationModelFrame:Undress()

	-- Apply equipment for equipment slots that do not have transmogrifications.
	for slotName, slotID in pairs(equipmentSlotIDs) do
		local transmogrificationID = transmogrificationTable[slotName]

		-- If no transmogrified appearance or the item has been restored (nil), display the original item.
		if transmogrificationID == nil then
			local itemID = GetItemIDForEquipmentSlot(slotName)
			if itemID then
				TransmogrificationModelFrame:TryOn(itemID)
			end
		end
	end

	-- Apply transmogrified appearances for items have been transmogrified.
	for slotName, transmogrificationID in pairs(transmogrificationTable) do
		if transmogrificationID and transmogrificationID ~= 0 then
			TransmogrificationModelFrame:TryOn(transmogrificationID)
		end
	end

	-- Update all equipment icons.
	UpdateAllSlotTextures(useTransmogrificationPreview)
end

function OnClickRestoreAllButton(btn)
	PlaySound("Glyph_MajorCreate", "sfx")
	for slotName, _ in pairs(equipmentSlotIDs) do
		previewTransmogrificationIDs[slotName] = nil
	end
	
	-- Refresh the player model.
	LoadTransmogrificationsFromCurrentIDs(true)
end

function OnClickHideAllButton(btn)
	PlaySound("Glyph_MinorDestroy", "sfx")
	for slotName, _ in pairs(equipmentSlotIDs) do
		previewTransmogrificationIDs[slotName] = 0
	end
	
	-- Refresh the player model.
	LoadTransmogrificationsFromCurrentIDs(true)
end

-- Register the equipment change event.
local function RegisterEquipmentChangeEvent()
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	eventFrame:SetScript("OnEvent", function(self, event, slot)
		if event == "PLAYER_EQUIPMENT_CHANGED" then
			-- When equipment is changed, notify the server.
			AIO.Handle("TransmogrificationServer", "OnUnequipItem")

			-- Update all equipment icons.
			UpdateAllSlotTextures(false)

			-- If the Transmogrification window is open, update it as well.
			if TransmogrificationFrame:IsShown() then
				local currentSlotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]
				local currentEquipSlot = GetEquipmentSlot(equipmentSlotIDs[currentSlotName])
				local hasItem = currentEquipSlot and GetInventoryItemID("player", currentEquipSlot) ~= nil

				-- Display the no equipment warning if there is no item equipped in the selected slot.
				if not hasItem then
					TransmogWarningText:SetText("|cff" .. L["ff4040"] .. L["No item equipped in this slot."])
					TransmogWarningFrame:Show()
				else
					TransmogWarningFrame:Hide()
					-- Request current data from the server to keep the Transmogrification window up to date.
					if CurrentItemSlot then
						AIO.Handle("TransmogrificationServer", "SetCurrentSlotItemIDs", CurrentItemSlot, currentPage)
					end
				end

				-- Refresh the player model.
				LoadTransmogrificationsFromCurrentIDs(true)
			end
		end
	end)
end

-- Define tooltip functions.
local function OnEnterItemToolTip(btn)
	local itemID = btn:GetID()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:"..itemID..":0:0:0:0:0:0:0")
	
	local slotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]
	local equipSlot = GetEquipmentSlot(equipmentSlotIDs[slotName])
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil
	
	if hasItem then
		GameTooltip:AddLine("\n|cff" .. L["00ff00"] .. L["Click to preview this item."])
	end
	
	GameTooltip:Show()
end

function TransmogItemSlotButton_OnEnter(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local slotName = self:GetName():gsub("Transmog", ""):gsub("Character", ""):gsub("Slot", "")
	local transmogID = currentTransmogrificationIDs[slotName] or originalTransmogrificationIDs[slotName]
	
	local slotID = equipmentSlotIDs[slotName]
	local equipSlot = GetEquipmentSlot(slotID)
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil
	
	if hasItem then
		if transmogID == 0 then
			GameTooltip:SetInventoryItem("player", self:GetID())
			GameTooltip:AddLine("\n|cff" .. L["ff4040"] .. L["Hidden Appearance"])
		elseif transmogID then
			GameTooltip:SetHyperlink("item:"..transmogID..":0:0:0:0:0:0:0")
		else
			GameTooltip:SetInventoryItem("player", self:GetID())
		end
	else
		GameTooltip:SetInventoryItem("player", self:GetID())
	end
	
	GameTooltip:Show()
	CursorUpdate(self)
end

function TransmogrifyToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("|cffffffff" .. L["Transmogrify"])
	GameTooltip:Show()
end

function RestoreItemToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("|cffffffff" .. L["Restore Item Appearance"])
	GameTooltip:Show()
end

function HideItemToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("|cffffffff" .. L["Hide Item"])
	GameTooltip:Show()
end

function RestoreAllItemsToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("|cffffffff" .. L["Restore All Item Appearances"])
	GameTooltip:Show()
end

function HideAllItemsToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("|cffffffff" .. L["Hide All Items"])
	GameTooltip:Show()
end

function ShowCloakToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("|cffffffff" .. L["Toggle Character Cloak Display"])
	GameTooltip:AddLine("|cffffd200" .. L["This checkbox provides the same function as\nticking or unticking the \"Show Cloak\" checkbox\nin the interface options menu. It will have no\neffect on the transmogrify preview window."])
	GameTooltip:Show()
end

function ShowHelmToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("|cffffffff" .. L["Toggle Character Helm Display"])
	GameTooltip:AddLine("|cffffd200" .. L["This checkbox provides the same function as\nticking or unticking the \"Show Helm\" checkbox\nin the interface options menu. It will have no\neffect on the transmogrify preview window."])
	GameTooltip:Show()
end

function TransmogrificationToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")

	-- Determine if there are transmogrification appearance changes to apply.
	local hasChanges = false
	for slotName, transmogID in pairs(previewTransmogrificationIDs) do
		if transmogID ~= currentTransmogrificationIDs[slotName] then
			hasChanges = true
			break
		end
	end

	if hasChanges then
		GameTooltip:AddLine("|cffffffff" .. L["Transmogrify"])
	else
		GameTooltip:AddLine("|cffffffff" .. L["Transmogrify"])
		GameTooltip:AddLine("|cff808080" .. L["No appearances to apply."])
	end

	GameTooltip:Show()
end

-- Hook into the item tooltip system to (if enabled) display the "New Appearance" tooltip text.
local function HookItemTooltip()
	local settings = Transmogrification:GetSettings()
	if not settings.displayNewAppearanceTooltip then return end

	if isTooltipHooked then return end

	local originalSetItem = GameTooltip:GetScript("OnTooltipSetItem")

	GameTooltip:SetScript("OnTooltipSetItem", function(self, ...)
		if originalSetItem then
			originalSetItem(self, ...)
		end

		local _, link = self:GetItem()
		if not link then return end

		local id = select(3, strfind(link, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)"))
		if not id then return end

		id = tonumber(id)
		if not id then return end

		local _, _, _, _, _, _, _, _, itemEquipSlot = GetItemInfo(id)

		-- Skip applying the "New Appearance" tooltip line if the item is non-transmogrifiable or the appearance has already collected.
		if IsEquippableItem(id) and itemEquipSlot and itemEquipSlot ~= "INVTYPE_AMMO" and
		itemEquipSlot ~= "INVTYPE_NECK" and itemEquipSlot ~= "INVTYPE_FINGER" and
		itemEquipSlot ~= "INVTYPE_TRINKET" and itemEquipSlot ~= "INVTYPE_BAG" and
		itemEquipSlot ~= "INVTYPE_QUIVER" and not tContains(CollectedAppearances, id) then
			self:AddLine("|cff" .. L["f194f7"] .. L["New Appearance"])
		end
	end)
	
	isTooltipHooked = true
end

function OnLeaveHideToolTip(btn)
	GameTooltip:Hide()
end

-- Search Functions
function EnterSearchInput()
	isInputHovered = true
end

function LeaveSearchInput()
	isInputHovered = false
end

function SetSearchInputFocus()
	if ( isInputHovered ) then
		ItemSearchInput:SetText("")
		ItemSearchInput:SetFocus()
	end
end

function SetSearchTab()
	PlaySound("igSpellBookSpellIconPickup", "sfx")
	currentPage = 1
	TransmogPaginationText:SetText(string.format(L["Page %s"], currentPage))
	AIO.Handle("TransmogrificationServer", "SetSearchCurrentSlotItemIDs", CurrentItemSlot, currentPage, ItemSearchInput:GetText())
	ItemSearchInput:ClearFocus()
end

-- Define equipment slot names.
characterEquipmentSlotNames = TableSetHelper(characterEquipmentSlotNames)

-- Apply player transmogrifications on login.
local function OnEvent(self, event)
	AIO.Handle("TransmogrificationServer", "LoadPlayer")
end

AIO.AddSavedVarChar("originalTransmogrificationIDs")

local function OnEventEnterWorldReloadTransmogIDs(self, event)
	if ( event == "PLAYER_ENTERING_WORLD") then
		AIO.Handle("TransmogrificationServer", "SetTransmogItemIDs")
		if CollectedAppearances == nil then
			CollectedAppearances = {}
		end
		HookItemTooltip()
		AddNewAppearanceToLocalList()
	else
		AIO.Handle("TransmogrificationServer", "OnUnequipItem")
		UpdateAllSlotTextures()
		if ( TransmogrificationFrame:IsShown() ) then
			LoadTransmogrificationsFromCurrentIDs()
		end
	end
end

-- Register event frame for AddOn functions.
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)

-- Register event frame for the new appearance system message filter.
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", collectionMessageFilter)

-- Define frame functions.
function OnClickTransmogButton(self)
	PlaySound("AchievementMenuOpen", "sfx")

	-- Wipe and initialize the preview transmogrification table. This ensures the preview window is up to date at all times.
	wipe(previewTransmogrificationIDs)
	for slot, transmogID in pairs(currentTransmogrificationIDs) do
		previewTransmogrificationIDs[slot] = transmogID
	end

	-- Display the players current appearance in the preview window.
	TransmogrificationModelFrame:SetUnit("player")
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID

	-- Set UI state variables.
	characterTransmogTab:SetChecked(true)
	isInputHovered = false
	currentPage = 1
	TransmogPaginationText:SetText(string.format(L["Page %s"], currentPage))

	-- Update all equipment icons.
	UpdateAllSlotTextures(true)

	-- Initialize the UI state.
	for slot, value in pairs(equipmentSlotIDs) do
		_G["TransmogCharacter"..slot.."Slot"].toastTexture:SetTexture("Interface\\AddOns\\Transmogrification\\assets\\Transmog-Overlay-Toast")
		_G["TransmogCharacter"..slot.."Slot"].restoreButton:Hide()
		_G["TransmogCharacter"..slot.."Slot"].hideButton:Hide()
	end

	-- Set the active equipment slot.
	local slotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]
	_G["TransmogCharacter"..slotName.."Slot"].toastTexture:SetTexture("Interface\\AddOns\\Transmogrification\\assets\\Transmog-Overlay-Selected")
	_G["TransmogCharacter"..slotName.."Slot"].restoreButton:Show()
	_G["TransmogCharacter"..slotName.."Slot"].hideButton:Show()

	-- More UI state initialization.
	ItemSearchInput:SetText("|cff" .. L["b2b2b2"] .. L["Filter Item Appearance"] .. "|r")
	ShowCloakCheckBox:SetChecked(ShowingCloak())
	ShowHelmCheckBox:SetChecked(ShowingHelm())

	-- Directly request items from the server.
	AIO.Handle("TransmogrificationServer", "SetCurrentSlotItemIDs", CurrentItemSlot, 1)

	-- Update the player model with the now item transmogrification preview.
	LoadTransmogrificationsFromCurrentIDs(true)
end

function PaperDollFrame_OnShow(self)
	PaperDollFrame_SetLevel();
	PaperDollFrame_SetResistances();
	PaperDollFrame_UpdateStats();
	if ( UnitHasRelicSlot("player") ) then
		CharacterAmmoSlot:Hide();
	else
		CharacterAmmoSlot:Show();
	end
	if ( not PlayerTitlePickerScrollFrame.titles ) then
		PlayerTitleFrame_UpdateTitles();
	end

	if ( TransmogrificationFrame:IsShown() ) then
		characterTransmogTab:SetChecked(true)
		else
		characterTransmogTab:SetChecked(false)
	end

	LoadTransmogrificationsFromCurrentIDs()
end

function OnClickApplyAllowTransmogrifications(btn)
	PlaySound("Distract Impact", "sfx")

	-- Apply transmogrifications on a server level.
	for slotName, entryID in pairs(equipmentSlotIDs) do
		local transmogID = previewTransmogrificationIDs[slotName]

		-- Determine if there is an item in the equipment slot.
		local equipSlot = GetEquipmentSlot(entryID)
		local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil

		-- Only apply transmogrifications if there is an item in the equipment slot.
		if hasItem and transmogID ~= currentTransmogrificationIDs[slotName] then
			AIO.Handle("TransmogrificationServer", "EquipTransmogItem", transmogID, entryID)
			currentTransmogrificationIDs[slotName] = transmogID
			originalTransmogrificationIDs[slotName] = transmogID
		end
	end

	-- Refresh the transmogrification preview with new information from the server.
	LoadTransmogrificationsFromCurrentIDs(false)
end

function OnClickHideCurrentTransmogSlot(btn)
	local slotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]
	local equipSlot = GetEquipmentSlot(equipmentSlotIDs[slotName])
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil

	-- Display a "warning" dialog if the player has removed the item they are attempting to hide.
	if not hasItem then
		StaticPopupDialogs["NO_ITEM_TO_HIDE_EQUIPPED_DIALOG"] = {
			text = L["You must have an item equipped in this slot to hide its appearance."],
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("NO_ITEM_TO_HIDE_EQUIPPED_DIALOG")
		return
	end

	PlaySound("ArcaneMissileImpacts", "sfx")

	-- Set the item to be (temporarily) hidden in the preview window.
	previewTransmogrificationIDs[slotName] = 0

	-- Update the player model with the now item transmogrification preview.
	LoadTransmogrificationsFromCurrentIDs(true)

	-- Update the item icon in the Transmogrification window.
	UpdateSlotTexture(slotName, true, true)
end

function OnClickRestoreCurrentTransmogSlot(btn)
	local slotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]
	local equipSlot = GetEquipmentSlot(equipmentSlotIDs[slotName])
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil

	if not hasItem then
		-- Display a "warning" dialog if the player has removed the item they are attempting to hide.
		StaticPopupDialogs["NO_ITEM_TO_RESTORE_EQUIPPED_DIALOG"] = {
			text = L["You must have an item equipped in this slot to restore its appearance."],
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("NO_ITEM_TO_RESTORE_EQUIPPED_DIALOG")
		return
	end

	PlaySound("Glyph_MinorCreate", "sfx")

	-- Set the item to be (temporarily) restored in the preview window.
	previewTransmogrificationIDs[slotName] = nil

	-- Update the player model with the now item transmogrification preview.
	LoadTransmogrificationsFromCurrentIDs(true)

	-- Update the item icon in the Transmogrification window.
	UpdateSlotTexture(slotName, true, true)
end

function TransmogModelMouseRotation(modelFrame)
	local rotationArea = CreateFrame("Frame", modelFrame:GetName().."RotationArea", modelFrame)
	rotationArea:SetSize(160, 280)
	rotationArea:SetPoint("CENTER", 0, 0)

	rotationArea:EnableMouse(true)
	modelFrame.isMouseRotating = false
	modelFrame.lastCursorX = 0

	rotationArea:SetScript("OnMouseDown", function(frame, button)
		if button == "LeftButton" then
			modelFrame.isMouseRotating = true
			modelFrame.lastCursorX = GetCursorPosition()
			if not _G["TransmogMouseCapture"] then
				local captureFrame = CreateFrame("Frame", "TransmogMouseCapture", UIParent)
				captureFrame:SetFrameStrata("TOOLTIP")
				captureFrame:SetAllPoints(UIParent)
				captureFrame:EnableMouse(true)
				captureFrame:Hide()
				captureFrame:SetScript("OnMouseUp", function(captureFrame, button)
					if button == "LeftButton" and modelFrame.isMouseRotating then
						modelFrame.isMouseRotating = false
						modelFrame:SetScript("OnUpdate", nil)
						captureFrame:Hide()
					end
				end)
			end

			TransmogMouseCapture:Show()

			modelFrame:SetScript("OnUpdate", function()
				if modelFrame.isMouseRotating then
					local currentX = GetCursorPosition()
					-- Controls mouse rotation speed.
					local diff = (currentX - modelFrame.lastCursorX) * 0.02
					modelFrame:SetFacing(modelFrame:GetFacing() + diff)
					modelFrame.lastCursorX = currentX
				end
			end)
		end
	end)

	rotationArea:SetScript("OnMouseUp", function(frame, button)
		if button == "LeftButton" and modelFrame.isMouseRotating then
			modelFrame.isMouseRotating = false
			modelFrame:SetScript("OnUpdate", nil)
			if _G["TransmogMouseCapture"] then
				TransmogMouseCapture:Hide()
			end
		end
	end)

	modelFrame:HookScript("OnHide", function(frame)
		if modelFrame.isMouseRotating then
			modelFrame.isMouseRotating = false
			modelFrame:SetScript("OnUpdate", nil)
			if _G["TransmogMouseCapture"] then
				TransmogMouseCapture:Hide()
			end
		end
	end)

	rotationArea:SetScript("OnLeave", function(frame)
		GameTooltip:Hide()
	end)

	modelFrame.rotationArea = rotationArea
end

-- Set the current tab for the Transmogrification window.
function SetTab()
	if (ItemSearchInput:GetText() ~= "" and ItemSearchInput:GetText() ~= "|cff" .. L["b2b2b2"] .. L["Filter Item Appearance"] .. "|r") then
		SetSearchTab()
		return;
	end

	PlaySound("igSpellBookSpellIconPickup", "sfx")
	currentPage = 1
	TransmogPaginationText:SetText(string.format(L["Page %s"], currentPage))

	-- Check to see if there is an item equipped in the slot.
	local slotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]
	local equipSlot = GetEquipmentSlot(equipmentSlotIDs[slotName])
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil

	-- Refresh the Transmogrification Window.
	for slot, value in pairs(equipmentSlotIDs) do
		_G["TransmogCharacter"..slot.."Slot"].toastTexture:SetTexture("Interface\\AddOns\\Transmogrification\\assets\\Transmog-Overlay-Toast")
		_G["TransmogCharacter"..slot.."Slot"].restoreButton:Hide()
		_G["TransmogCharacter"..slot.."Slot"].hideButton:Hide()
	end

	-- Set the active equipment slot.
	_G["TransmogCharacter"..slotName.."Slot"].toastTexture:SetTexture("Interface\\AddOns\\Transmogrification\\assets\\Transmog-Overlay-Selected")

	-- Display the warning message if the player is viewing an empty equipment slot.
	if not hasItem then
		TransmogWarningText:SetText("|cff" .. L["ff4040"] .. L["No item equipped in this slot."])
		TransmogWarningFrame:Show()
	else
		TransmogWarningFrame:Hide()

		-- Display the restore/hide buttons if the equipment slot is not empty.
		_G["TransmogCharacter"..slotName.."Slot"].restoreButton:Show()
		_G["TransmogCharacter"..slotName.."Slot"].hideButton:Show()
	end

	-- Query the server for applicable item appearances to show.
	AIO.Handle("TransmogrificationServer", "SetCurrentSlotItemIDs", CurrentItemSlot, currentPage)
end

function InitializeCloakHelmCheckboxes()
	ShowCloakCheckBox:SetChecked(ShowingCloak())
	ShowCloakCheckBox:SetScript("OnClick", function(self)
		local value = self:GetChecked() and "1" or "0"
		if value == "1" then
			PlaySound("igMainMenuOptionCheckBoxOn", "sfx")
		else
			PlaySound("igMainMenuOptionCheckBoxOff", "sfx")
		end
		ShowCloak(value == "1")
	end)

	ShowHelmCheckBox:SetChecked(ShowingHelm())
	ShowHelmCheckBox:SetScript("OnClick", function(self)
		local value = self:GetChecked() and "1" or "0"
		if value == "1" then
			PlaySound("igMainMenuOptionCheckBoxOn", "sfx")
		else
			PlaySound("igMainMenuOptionCheckBoxOff", "sfx")
		end
		ShowHelm(value == "1")
	end)

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	frame:SetScript("OnEvent", function(self, event, unit)
		if unit == "player" then
			ShowCloakCheckBox:SetChecked(ShowingCloak())
			ShowHelmCheckBox:SetChecked(ShowingHelm())
		end
	end)
end

function OnClickNextPage(btn)
	PlaySound("igAbiliityPageTurn", "sfx")
	currentPage = currentPage + 1
	AIO.Handle("TransmogrificationServer", "SetCurrentSlotItemIDs", CurrentItemSlot, currentPage)
end

function OnClickPrevPage(btn)
	PlaySound("igAbiliityPageTurn", "sfx")
	if ( currentPage == 1 ) then
		return;
	end
	currentPage = currentPage - 1
	AIO.Handle("TransmogrificationServer", "SetCurrentSlotItemIDs", CurrentItemSlot, currentPage)
end

function OnClickHeadTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
end

function OnClickShoulderTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_3_ENTRYID
	SetTab()
end

function OnClickShirtTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_4_ENTRYID
	SetTab()
end

function OnClickChestTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_5_ENTRYID
	SetTab()
end

function OnClickWaistTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_6_ENTRYID
	SetTab()
end

function OnClickLegsTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_7_ENTRYID
	SetTab()
end

function OnClickFeetTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_8_ENTRYID
	SetTab()
end

function OnClickWristTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_9_ENTRYID
	SetTab()
end

function OnClickHandsTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_10_ENTRYID
	SetTab()
end

function OnClickBackTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_15_ENTRYID
	SetTab()
end

function OnClickMainTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_16_ENTRYID
	SetTab()
end

function OnClickOffTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_17_ENTRYID
	SetTab()
end

function OnClickRangedTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_18_ENTRYID
	SetTab()
end

function OnClickTabardTab(btn)
	CurrentItemSlot = PLAYER_VISIBLE_ITEM_19_ENTRYID
	SetTab()
end

function OnHideTransmogrificationFrame(self)
	PlaySound("AchievementMenuClose", "sfx")

	-- Discard transmogrification preview changes.
	wipe(previewTransmogrificationIDs)

	-- Refresh the transmogrification preview with new information from the server.
	LoadTransmogrificationsFromCurrentIDs(false)
	characterTransmogTab:SetChecked(false)
end

-- Define frame layout.
function TransmogItemSlotButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local slotName = self:GetName():gsub("Transmog", "")
	local id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,10))
	self:SetID(id)
	local texture = _G["Transmog"..slotName.."IconTexture"]
	texture:SetTexture(textureName)
	self.backgroundTextureName = textureName
	self.checkRelic = checkRelic
	self.UpdateTooltip = TransmogItemSlotButton_OnEnter
end

local function InitTabSlots()
	local lastSlot
	local firstInRowSlot
	
	for i = 1, 6, 1 do
		local itemChild
		if ( i == 1 ) then
			itemChild = CreateFrame("Frame", "ItemChild"..i, TransmogrificationFrame, "TransmogItemWrapperTemplate")
			itemChild:SetPoint("TOPLEFT", 480, -240)
			firstInRowSlot = itemChild
		else
			if ( i == 4 ) then
				itemChild = CreateFrame("Frame", "ItemChild"..i, firstInRowSlot, "TransmogItemWrapperTemplate")
				itemChild:SetPoint("RIGHT", 0, -200)
				firstInRowSlot = itemChild
			else
				itemChild = CreateFrame("Button", "ItemChild"..i, lastSlot, "TransmogItemWrapperTemplate")
				itemChild:SetPoint("RIGHT", 230, 0)
			end
		end

		local rightTopItemFrame = CreateFrame("Frame", "RightTopItemFrame"..i, itemChild)
		rightTopItemFrame:SetPoint("TOPRIGHT", -4, -4)
		rightTopItemFrame:SetSize(34, 142)
		
		local rightTopTexture = rightTopItemFrame:CreateTexture(nil, "Background")
		rightTopTexture:SetTexture(DressUpTexturePath().."2")
		rightTopTexture:SetAllPoints()
		
		local rightBottomItemFrame = CreateFrame("Frame", "RightBottomItemFrame"..i, itemChild)
		rightBottomItemFrame:SetPoint("BOTTOMRIGHT", -4, -18)
		rightBottomItemFrame:SetSize(34, 53)
		
		local rightBottomTexture = rightBottomItemFrame:CreateTexture(nil, "Background")
		rightBottomTexture:SetTexture(DressUpTexturePath().."4")
		rightBottomTexture:SetAllPoints()
		
		local leftTopItemFrame = CreateFrame("Frame", "LeftTopItemFrame"..i, itemChild)
		leftTopItemFrame:SetPoint("TOPLEFT", 4, -4)
		leftTopItemFrame:SetSize(109, 142)
		
		local leftTopTexture = leftTopItemFrame:CreateTexture(nil, "Background")
		leftTopTexture:SetTexture(DressUpTexturePath().."1")
		leftTopTexture:SetAllPoints()
		
		local leftBottomItemFrame = CreateFrame("Frame", "LeftBottomItemFrame"..i, itemChild)
		leftBottomItemFrame:SetPoint("BOTTOMLEFT", 4, -18)
		leftBottomItemFrame:SetSize(109, 53)
		
		local leftBottomTexture = leftBottomItemFrame:CreateTexture(nil, "Background")
		leftBottomTexture:SetTexture(DressUpTexturePath().."3")
		leftBottomTexture:SetAllPoints()
		
		local itemModel = CreateFrame("DressUpModel", "ItemModel"..i, itemChild)
		itemModel:SetPoint("CENTER", 0, 0)
		itemModel:SetSize(142, 172)
		itemModel:Hide()
		
		local itemButton = CreateFrame("Button", "ItemButton"..i, leftBottomItemFrame, "TransmogItemButtonTemplate")
		itemButton:SetPoint("BOTTOMLEFT", 6, 28)
		itemButton:SetScript("OnClick", OnClickItemTransmogrificationButton)
		itemButton:SetScript("OnEnter", OnEnterItemToolTip)
		itemButton:SetScript("OnLeave", OnLeaveHideToolTip)
		itemButton:RegisterForClicks("AnyUp");
		itemButton:Disable()
		lastSlot = itemChild
		itemChild.itemModel = itemModel
		itemChild.itemButton = itemButton
		table.insert(itemButtons, itemChild)
	end
end

function TransmogrificationHandler.InitTab(player, newSlotItemIDs, page, hasMorePages)
	TransmogPaginationText:SetText(string.format(L["Page %s"], page))

	-- Determine if the slot is empty.
	local slotName = transmogrificationEquipmentSlotMap[CurrentItemSlot]
	local equipSlot = GetEquipmentSlot(equipmentSlotIDs[slotName])
	local hasItem = equipSlot and GetInventoryItemID("player", equipSlot) ~= nil

	-- Display the warning if the slot is empty.
	if not hasItem then
		TransmogWarningText:SetText("|cff" .. L["ff4040"] .. L["No item equipped in this slot."])
		TransmogWarningFrame:Show()
	else
		TransmogWarningFrame:Hide()

		-- Display the restore and hide buttons if the slot is not empty.
		_G["TransmogCharacter"..slotName.."Slot"].restoreButton:Show()
		_G["TransmogCharacter"..slotName.."Slot"].hideButton:Show()
	end

	-- Update pagination buttons.
	if (hasMorePages) then
		RightButton:Enable()
	else
		RightButton:Disable()
	end

	if (page > 1) then
		LeftButton:Enable()
	else
		LeftButton:Disable()
	end

	-- Display possible transmogrification appearances.
	if newSlotItemIDs and #newSlotItemIDs > 0 then
		for i, child in ipairs(itemButtons) do
			if (i > #newSlotItemIDs or newSlotItemIDs[i] == nil) then
				-- Hide empty items if we are on the last page of applicable appearances.
				child:SetID(0)
				child.itemButton:SetID(0)
				child.itemButton:Disable()
				child.itemModel:Hide()
				SetItemButtonTexture(child.itemButton, "Interface\\paperdoll\\UI-PaperDoll-Slot-" .. equipmentSlotIcons[CalculateInverseSlot(CurrentItemSlot)])
			else
				-- Display items if an applicable appearance is found.
				child:SetID(newSlotItemIDs[i])
				child.itemButton:SetID(newSlotItemIDs[i])
				local textureName = GetItemIcon(newSlotItemIDs[i])
				SetItemButtonTexture(child.itemButton, textureName)

				-- Allow the item to be clicked to change the transmogrification appearance.
				if hasItem then
					child.itemButton:Enable()
					child.itemButton:SetScript("OnClick", OnClickItemTransmogrificationButton)
				else
					-- Enable the item button in order to display a tooltip.
					child.itemButton:Enable()

					-- Remove the click event because the equipment slot is empty.
					child.itemButton:SetScript("OnClick", function(self)
						PlaySound("igMainMenuOptionCheckBoxOff", "sfx")
					end)
				end

				child.itemModel:Show()
				child.itemModel:SetUnit("player")
				
				-- Rotate the player model if an applicable slot is being viewed.
				if (CurrentItemSlot == PLAYER_VISIBLE_ITEM_15_ENTRYID) then -- Cloak
					child.itemModel:SetRotation(10, false)
				elseif (CurrentItemSlot == PLAYER_VISIBLE_ITEM_16_ENTRYID) then -- Main Hand
					child.itemModel:SetRotation(1, false)
				else
					child.itemModel:SetRotation(0, false)
				end
				child.itemModel:Undress()
				child.itemModel:TryOn(newSlotItemIDs[i])
				
				local _, playerRace = UnitRace("player")
				playerRace = string.upper(playerRace)
				local playerSex = UnitSex("player")
				local isFemale = (playerSex == 3)
				
				-- Change the position and scale of the preview model based on race to ensure they align with the frame.
				if playerRace == "HUMAN" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", 4, -1)
						child.itemModel:SetSize(169, 169)
					else
						child.itemModel:SetPoint("CENTER", 4, 2)
						child.itemModel:SetSize(180, 180)
					end
				elseif playerRace == "DWARF" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", 0, 6)
						child.itemModel:SetSize(165, 165)
					else
						child.itemModel:SetPoint("CENTER", 6, -10)
						child.itemModel:SetSize(170, 170)
					end
				elseif playerRace == "NIGHTELF" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", 3, -9)
						child.itemModel:SetSize(181, 181)
					else
						child.itemModel:SetPoint("CENTER", 2, -5)
						child.itemModel:SetSize(190, 190)
					end
				elseif playerRace == "GNOME" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", 3, -8)
						child.itemModel:SetSize(133, 133)
					else
						child.itemModel:SetPoint("CENTER", 4, -4)
						child.itemModel:SetSize(140, 140)
					end
				elseif playerRace == "DRAENEI" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", 10, 3)
						child.itemModel:SetSize(185, 185)
					else
						child.itemModel:SetPoint("CENTER", 6, 2)
						child.itemModel:SetSize(165, 165)
					end
				elseif playerRace == "ORC" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", -3, -5)
						child.itemModel:SetSize(175, 175)
					else
						child.itemModel:SetPoint("CENTER", 2, -4)
						child.itemModel:SetSize(165, 165)
					end
				elseif playerRace == "UNDEAD" or playerRace == "SCOURGE" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", 3, 0)
						child.itemModel:SetSize(188, 188)
					else
						child.itemModel:SetPoint("CENTER", 1, -6)
						child.itemModel:SetSize(175, 175)
					end
				elseif playerRace == "TAUREN" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", 2, -1)
						child.itemModel:SetSize(180, 180)
					else
						child.itemModel:SetPoint("CENTER", 1, -6)
						child.itemModel:SetSize(220, 220)
					end
				elseif playerRace == "TROLL" then
					if isFemale then
						child.itemModel:SetPoint("CENTER", -6, 2)
						child.itemModel:SetSize(180, 180)
					else
						child.itemModel:SetPoint("CENTER", -2, 2)
						child.itemModel:SetSize(170, 170)
					end
				else -- Blood Elf as fallback.
					if isFemale then
						child.itemModel:SetPoint("CENTER", 2, -2)
						child.itemModel:SetSize(180, 180)
					else
						child.itemModel:SetPoint("CENTER", -2, -4)
						child.itemModel:SetSize(190, 190)
					end
				end
			end
		end
	else
		-- Fallback behavior is to clear all applicable slots.
		for i, child in ipairs(itemButtons) do
			child:SetID(0)
			child.itemButton:SetID(0)
			child.itemButton:Disable()
			child.itemModel:Hide()
			SetItemButtonTexture(child.itemButton, "Interface\\paperdoll\\UI-PaperDoll-Slot-" .. equipmentSlotIcons[CalculateInverseSlot(CurrentItemSlot)])
		end
	end
end

function OnTransmogrificationFrameLoad(self)
	Title:SetText(L["Transmogrify"])
	Subtitle:SetText(L["Collected Item Appearances"])
	ShowCloakText:SetText(L["Show Cloak"])
	ShowHelmText:SetText(L["Show Helm"])
	TransmogPaginationText:SetText(string.format(L["Page %s"], 1))

	-- Hide the warning text by default when loading the Transmogrification frame.
	TransmogWarningFrame:Hide()
	RegisterEquipmentChangeEvent()

	-- Initialize the previewTransmogrificationIDs table.
	for slot, transmogID in pairs(currentTransmogrificationIDs) do
		previewTransmogrificationIDs[slot] = transmogID
	end

	ItemSearchInput:SetText("|cff" .. L["b2b2b2"] .. L["Filter Item Appearance"] .. "|r")
	ItemSearchInput:SetScript("OnEnterPressed", SetSearchTab)

	InitTabSlots()

	-- Create the tab button on the Character Info window.
	characterTransmogTab = CreateFrame("CheckButton", "CharacterFrameTab6", CharacterFrame, "SpellBookSkillLineTabTemplate")
	characterTransmogTab:SetSize(32, 32);
	characterTransmogTab:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", 0, -48)
	characterTransmogTab:Show()
	innerCharacterTransmogTab = characterTransmogTab:CreateTexture("Item", "ARTWORK")
	innerCharacterTransmogTab:SetTexture("Interface\\AddOns\\Transmogrification\\assets\\Transmog-Icon")
	innerCharacterTransmogTab:SetAllPoints()
	innerCharacterTransmogTab:Show()
	characterTransmogTab:SetScript("OnEnter", TransmogrifyToolTip)
	characterTransmogTab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	characterTransmogTab:SetScript("OnClick", function(self) if ( TransmogrificationFrame:IsShown() ) then TransmogrificationFrame:Hide() return; end TransmogrificationFrame:Show() end)
	TransmogCloseButton:SetScript("OnClick", function(self) if ( TransmogrificationFrame:IsShown() ) then TransmogrificationFrame:Hide() return; end TransmogrificationFrame:Show() end)

	PaperDollFrame:SetScript("OnShow", PaperDollFrame_OnShow)
	InitializeCloakHelmCheckboxes()

	-- Save the position of the Transmogrification frame.
	AIO.SavePosition(TransmogrificationFrame)

	-- Apply settings when Transmogrification frame is initialized.
	if Transmogrification and Transmogrification.db then
		local settings = Transmogrification:GetSettings()
		TransmogrificationFrame:SetScale(settings.transmogrificationWindowScale)
		TransmogrificationFrame:SetAlpha(settings.transmogrificationWindowOpacity)

		if settings.transmogrificationWindowLock then
			TransmogrificationFrame:SetMovable(false)
			TransmogrificationFrame:RegisterForDrag()
		else
			TransmogrificationFrame:SetMovable(true)
			TransmogrificationFrame:RegisterForDrag("LeftButton")
		end
	end

	_G["TransmogrificationFrame"] = TransmogrificationFrame
	tinsert(UISpecialFrames, TransmogrificationFrame:GetName())
	TransmogrificationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TransmogrificationFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	TransmogrificationFrame:SetScript("OnEvent", OnEventEnterWorldReloadTransmogIDs)

	SetItemButtonTexture(_G["SaveButton"], "Interface\\AddOns\\Transmogrification\\assets\\Transmog-Icon")

	TransmogModelMouseRotation(TransmogrificationModelFrame)

	-- Update all equipment icons.
	UpdateAllSlotTextures(false)
end
