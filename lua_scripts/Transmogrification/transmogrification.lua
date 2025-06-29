-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║           Transmog System Eluna Script by DanielTheDeveloper           ║
-- ╚════════════════════════════════════════════════════════════════════════╝
--
--                        ╔══════════════════════════╗
-- ╔══════════════════════║ Transmog System Settings ║══════════════════════╗
-- ║                      ╚══════════════════════════╝                      ║
-- ║ Automatically adds transmog appearances to the players account-wide    ║
-- ║ transmog collection when they equip an item for the first time.        ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled.                        ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local ADD_NEWLY_EQUIPPED_ITEMS_TO_THE_TRANSMOG_LIST = true          --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Automatically adds transmog appearances to the players account-wide    ║
-- ║ transmog collection when they loot an item for the first time.         ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option disabled as it creates the      ║
-- ║ potential for a more healthy transmog economy to exist inside the      ║
-- ║ auction house.                                                         ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local ADD_NEWLY_LOOTED_ITEMS_TO_THE_TRANSMOG_LIST = false           --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Automatically adds all applicable quest reward items as transmog       ║
-- ║ appearances to the players account-wide transmog collection when       ║
-- ║ completing a quest, regardless of which quest reward the player        ║
-- ║ actually decided to select.                                            ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled as it eliminates the    ║
-- ║ dilemma of deciding between a potential transmog appearance or gear    ║
-- ║ that is useful for the character.                                      ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local ADD_QUEST_REWARD_ITEMS_TO_THE_TRANSMOG_LIST = true            --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Restricts armor transmog appearances to items made up of the same      ║
-- ║ material. As an example, with this option enabled, cloth chest pieces  ║
-- ║ can only be transmogrified to appear as other cloth chest pieces.      ║
-- ║ When this option is disabled, cloth chest pieces can be                ║
-- ║ transmogrified to appear as a cloth, leather, mail, or plate chest     ║
-- ║ piece.                                                                 ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled as it leaves the        ║
-- ║ class fantasy intact.                                                  ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local RESTRICT_ARMOR_TRANSMOG_TO_SIMILAR_MATERIALS = true           --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Restricts weapon transmog appearances to the same weapon. As an        ║
-- ║ example, with this option enabled, two-handed swords can only be       ║
-- ║ transmogrified to appear as other two-handed swords. When this option  ║
-- ║ is disabled, two-handed swords can be transmogrified to appear as a    ║
-- ║ one-handed sword, staff, polearm, fishing pole, etc.                   ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled as it leaves the        ║
-- ║ class fantasy intact.                                                  ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local RESTRICT_WEAPON_TRANSMOG_TO_SIMILAR_WEAPONS = true            --║
-- ╚════════════════════════════════════════════════════════════════════════╝

local AIO = AIO or require("AIO")
local TransmogrificationHandler = AIO.AddHandlers("TransmogrificationServer", {})

local SLOTS = 6
local CALC = 281
local PLAYER_VISIBLE_ITEM_1_ENTRYID = 283  -- Head
local PLAYER_VISIBLE_ITEM_3_ENTRYID = 287  -- Shoulder
local PLAYER_VISIBLE_ITEM_4_ENTRYID = 289  -- Shirt
local PLAYER_VISIBLE_ITEM_5_ENTRYID = 291  -- Chest
local PLAYER_VISIBLE_ITEM_6_ENTRYID = 293  -- Waist
local PLAYER_VISIBLE_ITEM_7_ENTRYID = 295  -- Legs
local PLAYER_VISIBLE_ITEM_8_ENTRYID = 297  -- Feet
local PLAYER_VISIBLE_ITEM_9_ENTRYID = 299  -- Wrist
local PLAYER_VISIBLE_ITEM_10_ENTRYID = 301 -- Hands
local PLAYER_VISIBLE_ITEM_15_ENTRYID = 311 -- Back
local PLAYER_VISIBLE_ITEM_16_ENTRYID = 313 -- Main
local PLAYER_VISIBLE_ITEM_17_ENTRYID = 315 -- Off
local PLAYER_VISIBLE_ITEM_18_ENTRYID = 317 -- Ranged
local PLAYER_VISIBLE_ITEM_19_ENTRYID = 319 -- Tabard
local UNUSABLE_INVENTORY_TYPES = {[2] = true, [11] = true, [12] = true, [18] = true, [24] = true, [27] = true, [28] = true}

-- TODO: Add further language support.
local localeMessages = {
	LOOT_ITEM_LOCALE = {
		[0] = " has been added to your appearance collection.", -- enUS/enGB
		[3] = " wurde deiner Transmog-Sammlung hinzugefügt.", -- deDE
	}
}

local function GetLocalizedMessage(messageID, locale, ...)
	 local message = localeMessages[messageID][locale] or localeMessages[messageID][0]
	 if select("#", ...) > 0 then
		  return string.format(message, ...)
	 end
	 return message
end

function Transmog_CalculateSlot(slot)
	if (slot == 0) then
		slot = 1
	elseif (slot >= 2) then
		slot = slot + 1
	end
	return CALC + (slot * 2);
end

function Transmog_CalculateSlotReverse(slot)
	local reverseSlot = (slot - CALC) / 2
	if (reverseSlot == 1) then
		return 0;
	end
	return reverseSlot;
end

function Transmog_OnCharacterCreate(event, player)
	local playerGUID = player:GetGUIDLow()
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_1_ENTRYID .. "', NULL, '');")  -- Head
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_3_ENTRYID .. "', NULL, '');")  -- Shoulder
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_4_ENTRYID .. "', NULL, '');")  -- Shirt
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_5_ENTRYID .. "', NULL, '');")  -- Chest
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_6_ENTRYID .. "', NULL, '');")  -- Waist
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_7_ENTRYID .. "', NULL, '');")  -- Legs
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_8_ENTRYID .. "', NULL, '');")  -- Feet
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_9_ENTRYID .. "', NULL, '');")  -- Wrist
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_10_ENTRYID .. "', NULL, '');") -- Hands
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_15_ENTRYID .. "', NULL, '');") -- Back
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_16_ENTRYID .. "', NULL, '');") -- Main
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_17_ENTRYID .. "', NULL, '');") -- Off
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_18_ENTRYID .. "', NULL, '');") -- Ranged
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_19_ENTRYID .. "', NULL, '');") -- Tabard
end

function Transmog_OnCharacterDelete(event, guid)
	CharDBQuery("DELETE FROM character_transmog WHERE player_guid = " .. guid .. "")
end

function Transmog_OnCharacterLogin(event, player)
	local playerGUID = player:GetGUIDLow()
	local playerExistsQuery = CharDBQuery("SELECT COUNT(*) FROM character_transmog WHERE player_guid = " .. playerGUID .. ";")
	local playerExists = playerExistsQuery:GetUInt32(0) > 0
	if not playerExists then
		Transmog_OnCharacterCreate(event, player)
	end
end

function TransmogrificationHandler.LootItemLocale(player, item, count, locale)
	local accountGUID = player:GetAccountId()
	local itemID
	local itemTemplate
	
	if type(item) == "number" then
		itemID = item
		itemTemplate = GetItemTemplate(itemID)
	else
		itemTemplate = item:GetItemTemplate()
		itemID = itemTemplate:GetItemId()
	end
	
	local inventoryType = itemTemplate:GetInventoryType()
	local inventorySubType = itemTemplate:GetSubClass()
	local class = itemTemplate:GetClass()

	if (class == 2 or class == 4) and not UNUSABLE_INVENTORY_TYPES[inventoryType] then
		local countQuery = AuthDBQuery("SELECT COUNT(*) FROM account_transmog WHERE account_id = " .. accountGUID .. " AND unlocked_item_id = " .. itemID .. ";")
		local count = countQuery:GetUInt32(0)
		local isNewTransmog = (count == 0)
		
		local displayID = itemTemplate:GetDisplayId()
		
		local displayExistsQuery = AuthDBQuery("SELECT COUNT(*) FROM account_transmog WHERE account_id = " .. accountGUID .. " AND display_id = " .. displayID .. ";")
		local displayExists = displayExistsQuery:GetUInt32(0) > 0
		
		if isNewTransmog and not displayExists then
			local itemName = itemTemplate:GetName()
			local locItemName = itemTemplate:GetName(locale)
			local itemQuality = itemTemplate:GetQuality()
			
			itemName = itemName:gsub("'", "''")
			AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `inventory_type`, `inventory_subtype`,`display_id`, `item_name`) VALUES (" .. accountGUID .. ", " .. itemID .. ", " .. inventoryType .. ", " .. inventorySubType .. ", " .. displayID .. ", '" .. itemName .. "');")
			
			if locItemName == nil then
				locItemName = itemTemplate:GetName(0)
			end
			
			local qualityColors = {
				[0] = "|cff9d9d9d", -- Poor
				[1] = "|cffffffff", -- Common
				[2] = "|cff1eff00", -- Uncommon
				[3] = "|cff0070dd", -- Rare
				[4] = "|cffa335ee", -- Epic
				[5] = "|cffff8000", -- Legendary
				[6] = "|cffe6cc80"  -- Heirloom
			}
			
			local colorCode = qualityColors[itemQuality] or "|cffffffff" -- Default to white if quality not found
			
			local itemLink = "|Hitem:" .. itemID .. ":0:0:0:0:0:0:0:0|h" .. colorCode .. "[" .. locItemName .. "]|r|h|r"
			player:SendBroadcastMessage(itemLink .. GetLocalizedMessage("LOOT_ITEM_LOCALE", locale))
		end
	end
end

function GetDisplaySlotForEquipmentSlot(equipSlot)
	local slotMapping = {
		[0] = PLAYER_VISIBLE_ITEM_1_ENTRYID,    -- Head
		[2] = PLAYER_VISIBLE_ITEM_3_ENTRYID,    -- Shoulders
		[3] = PLAYER_VISIBLE_ITEM_4_ENTRYID,    -- Shirt
		[4] = PLAYER_VISIBLE_ITEM_5_ENTRYID,    -- Chest
		[5] = PLAYER_VISIBLE_ITEM_6_ENTRYID,    -- Waist
		[6] = PLAYER_VISIBLE_ITEM_7_ENTRYID,    -- Legs
		[7] = PLAYER_VISIBLE_ITEM_8_ENTRYID,    -- Feet
		[8] = PLAYER_VISIBLE_ITEM_9_ENTRYID,    -- Wrists
		[9] = PLAYER_VISIBLE_ITEM_10_ENTRYID,   -- Hands
		[14] = PLAYER_VISIBLE_ITEM_15_ENTRYID,  -- Back
		[15] = PLAYER_VISIBLE_ITEM_16_ENTRYID,  -- Main Hand
		[16] = PLAYER_VISIBLE_ITEM_17_ENTRYID,  -- Off Hand
		[17] = PLAYER_VISIBLE_ITEM_18_ENTRYID,  -- Ranged
		[18] = PLAYER_VISIBLE_ITEM_19_ENTRYID   -- Tabard
	}
	
	return slotMapping[equipSlot]
end

function Transmog_OnEquipItem(event, player, item, bag, slot)
	local itemID = item:GetItemTemplate():GetItemId()
	local locale = player:GetDbLocaleIndex()
	
	if ADD_NEWLY_EQUIPPED_ITEMS_TO_THE_TRANSMOG_LIST then
		TransmogrificationHandler.LootItemLocale(player, itemID, 1, locale)
	end
	
	local class = item:GetItemTemplate():GetClass()
	local inventoryType = item:GetItemTemplate():GetInventoryType()
	
	if (class == 2 or class == 4) and not UNUSABLE_INVENTORY_TYPES[inventoryType] then
		local playerGUID = player:GetGUIDLow()
		local displaySlot = GetDisplaySlotForEquipmentSlot(slot)
		
		if displaySlot then
			CharDBQuery("UPDATE character_transmog SET real_item = " .. itemID .. " WHERE player_guid = " .. playerGUID .. " AND slot = " .. displaySlot)
		end
	end
end

function Transmog_OnLootItem(event, player, item, count)
	local locale = player:GetDbLocaleIndex()
	TransmogrificationHandler.LootItemLocale(player, item, 1, locale)
end

function Transmog_OnQuestComplete(event, player, quest)
	local questID = quest:GetId()
	local locale = player:GetDbLocaleIndex()
	
	local questRewardsQuery = WorldDBQuery("SELECT RewardItem1, RewardItem2, RewardItem3, RewardItem4, RewardChoiceItemID1, RewardChoiceItemID2, RewardChoiceItemID3, RewardChoiceItemID4, RewardChoiceItemID5, RewardChoiceItemID6 FROM quest_template WHERE ID = " .. questID .. ";")
	
	if not questRewardsQuery then
		return
	end
	
	for i = 0, 9 do
		local itemID = questRewardsQuery:GetUInt32(i)
		if itemID and itemID > 0 then
			TransmogrificationHandler.LootItemLocale(player, itemID, 1, locale)
		end
	end
end

function GetEquipmentSlot(displaySlot)
	-- Map from display/visual slots to actual equipment slots
	local slotMapping = {
		[PLAYER_VISIBLE_ITEM_1_ENTRYID] = 0,     -- Head (0 in equipment slot system)
		[PLAYER_VISIBLE_ITEM_3_ENTRYID] = 2,     -- Shoulders
		[PLAYER_VISIBLE_ITEM_4_ENTRYID] = 3,     -- Shirt
		[PLAYER_VISIBLE_ITEM_5_ENTRYID] = 4,     -- Chest
		[PLAYER_VISIBLE_ITEM_6_ENTRYID] = 5,     -- Waist
		[PLAYER_VISIBLE_ITEM_7_ENTRYID] = 6,     -- Legs
		[PLAYER_VISIBLE_ITEM_8_ENTRYID] = 7,     -- Feet
		[PLAYER_VISIBLE_ITEM_9_ENTRYID] = 8,     -- Wrists
		[PLAYER_VISIBLE_ITEM_10_ENTRYID] = 9,    -- Hands
		[PLAYER_VISIBLE_ITEM_15_ENTRYID] = 14,   -- Back/Cloak
		[PLAYER_VISIBLE_ITEM_16_ENTRYID] = 15,   -- Main Hand
		[PLAYER_VISIBLE_ITEM_17_ENTRYID] = 16,   -- Off Hand
		[PLAYER_VISIBLE_ITEM_18_ENTRYID] = 17,   -- Ranged
		[PLAYER_VISIBLE_ITEM_19_ENTRYID] = 18,   -- Tabard
	}
	
	return slotMapping[displaySlot] or Transmog_CalculateSlotReverse(displaySlot)
end

-- TODO: add lua/c++ function for unequip!!
function TransmogrificationHandler.OnUnequipItem(player)
	local playerGUID = player:GetGUIDLow()
	
	-- Check all slots to see if any items were unequipped
	local slots = {
		PLAYER_VISIBLE_ITEM_1_ENTRYID,  -- Head
		PLAYER_VISIBLE_ITEM_3_ENTRYID,  -- Shoulder
		PLAYER_VISIBLE_ITEM_4_ENTRYID,  -- Shirt
		PLAYER_VISIBLE_ITEM_5_ENTRYID,  -- Chest
		PLAYER_VISIBLE_ITEM_6_ENTRYID,  -- Waist
		PLAYER_VISIBLE_ITEM_7_ENTRYID,  -- Legs
		PLAYER_VISIBLE_ITEM_8_ENTRYID,  -- Feet
		PLAYER_VISIBLE_ITEM_9_ENTRYID,  -- Wrist
		PLAYER_VISIBLE_ITEM_10_ENTRYID, -- Hands
		PLAYER_VISIBLE_ITEM_15_ENTRYID, -- Back
		PLAYER_VISIBLE_ITEM_16_ENTRYID, -- Main
		PLAYER_VISIBLE_ITEM_17_ENTRYID, -- Off
		PLAYER_VISIBLE_ITEM_18_ENTRYID, -- Ranged
		PLAYER_VISIBLE_ITEM_19_ENTRYID  -- Tabard
	}
	
	for _, slot in ipairs(slots) do
		-- Get the corresponding equipment slot
		local equipmentSlot = GetEquipmentSlot(slot)
		
		-- Check if this slot has an item equipped
		local currentItem = player:GetEquippedItemBySlot(equipmentSlot)
		
		-- If the slot is empty but we have a transmog value, we need to clear it
		if not currentItem then
			local transmogQuery = CharDBQuery("SELECT item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
			
			if transmogQuery and transmogQuery:GetUInt32(0) and transmogQuery:GetUInt32(0) > 0 then
				-- Clear the transmog by setting both item and real_item to NULL
				CharDBQuery("UPDATE character_transmog SET item = NULL, real_item = NULL WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
				player:SetUInt32Value(tonumber(slot), 0)
				
				-- Inform the client to update the display for this slot
				AIO.Handle(player, "TransmogrificationServer", "ClearSlotTransmogrification", slot)
			end
		end
	end
end

function Transmog_Load(player)
	local playerGUID = player:GetGUIDLow()
	
	local transmogs = CharDBQuery("SELECT item, slot FROM character_transmog WHERE player_guid = "..playerGUID..";")
	if (transmogs == nil) then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local slot = currentRow["slot"]
		local item = currentRow["item"]
		if (item ~= nil and item ~= '') then
			player:SetUInt32Value(tonumber(slot), item)
		end
		transmogs:NextRow()
	end
end

function Transmog_OnLogin(event, player)
	-- Apply transmog on login
	-- Transmog_Load(player)
	--local item = player:GetEquippedItemBySlot(4)
	--print(item:GetName())
end

function TransmogrificationHandler.LoadPlayer(player)
	Transmog_Load(player)
	player:SetUInt32Value(147, 1) -- use unit padding
end

function TransmogrificationHandler.EquipTransmogItem(player, item, slot)
	local playerGUID = player:GetGUIDLow()
	
	if item == nil and item ~= 0 then
		local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
		local oldItemID = oldItem:GetUInt32(0)
		if oldItemID == nil or oldItemID == 0 then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', NULL) ON DUPLICATE KEY UPDATE item = VALUES(item);")
			player:SetUInt32Value(tonumber(slot), 0)
			return
		end

		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', NULL, "..oldItemID..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		player:SetUInt32Value(tonumber(slot), oldItemID)
		return
	end
	
	local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
	local oldItemID = oldItem:GetUInt32(0)
	if oldItemID == nil or oldItemID == 0 then
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', "..item..") ON DUPLICATE KEY UPDATE item = VALUES(item);")
	else
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', "..item..", "..oldItemID..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
	end
	player:SetUInt32Value(tonumber(slot), item)
end

function TransmogrificationHandler.EquipAllTransmogItems(player, transmogPreview)
	if (transmogPreview == {}) then
		return;
	end
	
	local playerGUID = player:GetGUIDLow()
	
	for slot, item in ipairs(transmogPreview) do
		player:SetUInt32Value(tonumber(slot), item)
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', "..item..") ON DUPLICATE KEY UPDATE item = VALUES(item);")
	end
end

function TransmogrificationHandler.UnequipTransmogItem(player, slot)
	local playerGUID = player:GetGUIDLow()
	
	-- Get the corresponding equipment slot using our mapping function
	local equipmentSlot = GetEquipmentSlot(slot)
	
	-- Check if there's an actual item equipped in this slot
	local currentItem = player:GetEquippedItemBySlot(equipmentSlot)
	
	-- If no item is currently equipped, we should set the visual to 0
	if not currentItem then
		CharDBQuery("UPDATE character_transmog SET item = NULL, real_item = NULL WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
		player:SetUInt32Value(tonumber(slot), 0)
		return
	end
	
	-- Otherwise, handle normally but ensure we're setting to the real item or 0
	local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
	
	-- If no record or null real_item, set to the actual item's appearance
	if not oldItem or not oldItem:GetUInt32(0) or oldItem:GetUInt32(0) == 0 then
		-- Here we set item to NULL (not 0) to indicate no transmog is applied
		CharDBQuery("UPDATE character_transmog SET item = NULL WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
		
		-- Get the current equipped item's ID to display
		local realItemID = currentItem:GetItemTemplate():GetItemId()
		player:SetUInt32Value(tonumber(slot), realItemID)
		return
	end
	
	-- If we have a real_item value, restore that appearance
	local oldItemID = oldItem:GetUInt32(0)
	CharDBQuery("UPDATE character_transmog SET item = NULL WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
	player:SetUInt32Value(tonumber(slot), oldItemID)
end

function TransmogrificationHandler.displayTransmog(player, spellid)
	AIO.Handle(player, "TransmogrificationServer", "TransmogrificationFrame")
	return false
end

function TransmogrificationHandler.Print(player, ...)
	print(...)
end

function TransmogrificationHandler.SetTransmogItemIDs(player)
	local playerGUID = player:GetGUIDLow()
	
	local transmogs = CharDBQuery('SELECT item, real_item, slot FROM character_transmog WHERE player_guid = '..playerGUID..';') -- AND slot NOT IN ("313", "315", "317")
	if (transmogs == nil) then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local item = currentRow["item"]
		local slot = currentRow["slot"]
		local real_item = currentRow["real_item"]
		local validSlotItem = player:GetUInt32Value(tonumber(slot))
		if (validSlotItem == 0) then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', 0, "..real_item..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		end
		if (not item or item == 0 and real_item ~= nil and real_item ~= 0 and (validSlotItem ~= 0 or not validSlotItem)) then
			AIO.Handle(player, "TransmogrificationServer", "SetTransmogItemIDClient", slot, 0, real_item)
		else
			AIO.Handle(player, "TransmogrificationServer", "SetTransmogItemIDClient", slot, item, real_item)
		end
		transmogs:NextRow()
	end
end

function TransmogrificationHandler.SetCurrentSlotItemIDs(player, slot, page)
    local accountGUID = player:GetAccountId()

    -- Define inventory type mapping
    local inventoryTypesMapping = {
        [PLAYER_VISIBLE_ITEM_1_ENTRYID] = "= 1",
        [PLAYER_VISIBLE_ITEM_3_ENTRYID] = "= 3",
        [PLAYER_VISIBLE_ITEM_4_ENTRYID] = "= 4",
        [PLAYER_VISIBLE_ITEM_5_ENTRYID] = "IN (5, 20)",
        [PLAYER_VISIBLE_ITEM_6_ENTRYID] = "= 6",
        [PLAYER_VISIBLE_ITEM_7_ENTRYID] = "= 7",
        [PLAYER_VISIBLE_ITEM_8_ENTRYID] = "= 8",
        [PLAYER_VISIBLE_ITEM_9_ENTRYID] = "= 9",
        [PLAYER_VISIBLE_ITEM_10_ENTRYID] = "= 10",
        [PLAYER_VISIBLE_ITEM_15_ENTRYID] = "= 16",
        [PLAYER_VISIBLE_ITEM_16_ENTRYID] = "IN (13, 17, 21)",
        [PLAYER_VISIBLE_ITEM_17_ENTRYID] = "IN (13, 17, 22, 23, 14)",
        [PLAYER_VISIBLE_ITEM_18_ENTRYID] = "IN (15, 25, 26)",
        [PLAYER_VISIBLE_ITEM_19_ENTRYID] = "= 19"
    }

    -- Get the inventory type for the given slot
    local inventoryTypes = inventoryTypesMapping[slot]
    if not inventoryTypes then
        return -- Slot not valid, exit early
    end
    
    local equipmentSlot = nil
    
    if slot == PLAYER_VISIBLE_ITEM_3_ENTRYID then
        equipmentSlot = 2 -- Shoulder
    elseif slot == PLAYER_VISIBLE_ITEM_4_ENTRYID then
        equipmentSlot = 3 -- Shirt
    elseif slot == PLAYER_VISIBLE_ITEM_5_ENTRYID then
        equipmentSlot = 4 -- Chest
    elseif slot == PLAYER_VISIBLE_ITEM_6_ENTRYID then
        equipmentSlot = 5 -- Waist
    elseif slot == PLAYER_VISIBLE_ITEM_10_ENTRYID then
        equipmentSlot = 9 -- Hands
    elseif slot == PLAYER_VISIBLE_ITEM_15_ENTRYID then
        equipmentSlot = 14 -- Back
    elseif slot == PLAYER_VISIBLE_ITEM_16_ENTRYID then
        equipmentSlot = 15 -- Main
    elseif slot == PLAYER_VISIBLE_ITEM_17_ENTRYID then
        equipmentSlot = 16 -- Off
    elseif slot == PLAYER_VISIBLE_ITEM_18_ENTRYID then
        equipmentSlot = 17 -- Ranged
    else
        equipmentSlot = Transmog_CalculateSlotReverse(slot)
    end
    
    local currentItem = player:GetEquippedItemBySlot(equipmentSlot)
    local equippedItemType = nil
    local equippedItemSubType = nil
    
    if currentItem then
        equippedItemType = currentItem:GetClass()
        equippedItemSubType = currentItem:GetSubClass()
    end

    -- Calculate page offset for pagination
    local pageOffset = (page > 1) and (SLOTS * (page - 1)) or 0
    
    local queryConditions = "account_id = " .. accountGUID .. " AND inventory_type " .. inventoryTypes
    
	if equippedItemSubType then
		if (RESTRICT_ARMOR_TRANSMOG_TO_SIMILAR_MATERIALS and equippedItemType == 4) then
			if slot == PLAYER_VISIBLE_ITEM_5_ENTRYID then -- Special check for chestpiece/robes.
				queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
			else
				queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
			end
		elseif (RESTRICT_WEAPON_TRANSMOG_TO_SIMILAR_WEAPONS and equippedItemType == 2) then
			queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
		end
	end

    -- Query to count matching transmogs
    local countQuery = string.format(
        "SELECT COUNT(unlocked_item_id) FROM account_transmog WHERE %s",
        queryConditions
    )
    local countResult = AuthDBQuery(countQuery)
    if not countResult then
        AIO.Handle(player, "TransmogrificationServer", "InitTab", {}, page, false)
        return
    end

    -- Get the total number of transmogs
    local totalTransmogs = countResult:GetUInt32(0)
    local hasMorePages = (totalTransmogs > SLOTS * page)

    -- Query to retrieve transmogs for the current page
    local transmogQuery = string.format(
        "SELECT unlocked_item_id FROM account_transmog WHERE %s LIMIT %d OFFSET %d;",
        queryConditions, SLOTS, pageOffset
    )
    local transmogs = AuthDBQuery(transmogQuery)
    if not transmogs then
        AIO.Handle(player, "TransmogrificationServer", "InitTab", {}, page, false)
        return
    end

    -- Collect the unlocked item IDs
    local currentSlotItemIDs = {}
    for i = 1, transmogs:GetRowCount() do
        local currentRow = transmogs:GetRow()
        local item = currentRow["unlocked_item_id"]
        table.insert(currentSlotItemIDs, item)
        transmogs:NextRow()
    end

    -- Return the result to the player
    AIO.Handle(player, "TransmogrificationServer", "InitTab", currentSlotItemIDs, page, hasMorePages)
end

function TransmogrificationHandler.SetSearchCurrentSlotItemIDs(player, slot, page, search)
	-- Ensure search is not empty or nil
	if ( search == nil or serach == '' ) then
		return;
	end

	-- Escape special characters in search string
	search = search:gsub("[%'`&\"]", "%%")

	-- Define slot-to-inventory type mapping
	local inventoryTypesMapping = {
		[PLAYER_VISIBLE_ITEM_1_ENTRYID] = "= 1",
		[PLAYER_VISIBLE_ITEM_3_ENTRYID] = "= 3",
		[PLAYER_VISIBLE_ITEM_4_ENTRYID] = "= 4",
		[PLAYER_VISIBLE_ITEM_5_ENTRYID] = "IN (5, 20)",
		[PLAYER_VISIBLE_ITEM_6_ENTRYID] = "= 6",
		[PLAYER_VISIBLE_ITEM_7_ENTRYID] = "= 7",
		[PLAYER_VISIBLE_ITEM_8_ENTRYID] = "= 8",
		[PLAYER_VISIBLE_ITEM_9_ENTRYID] = "= 9",
		[PLAYER_VISIBLE_ITEM_10_ENTRYID] = "= 10",
		[PLAYER_VISIBLE_ITEM_15_ENTRYID] = "= 16",
		[PLAYER_VISIBLE_ITEM_16_ENTRYID] = "IN (13, 17, 21)",
		[PLAYER_VISIBLE_ITEM_17_ENTRYID] = "IN (13, 17, 22, 23, 14)",
		[PLAYER_VISIBLE_ITEM_18_ENTRYID] = "IN (15, 25, 26)",
		[PLAYER_VISIBLE_ITEM_19_ENTRYID] = "= 19"
	}

	-- Get inventory type for the given slot
	local inventoryTypes = inventoryTypesMapping[slot]
	if not inventoryTypes then
		return -- Slot not valid
	end
	
	local equipmentSlot = nil
	
	if slot == PLAYER_VISIBLE_ITEM_3_ENTRYID then
		equipmentSlot = 2 -- Shoulder
    elseif slot == PLAYER_VISIBLE_ITEM_4_ENTRYID then
        equipmentSlot = 3 -- Shirt
    elseif slot == PLAYER_VISIBLE_ITEM_5_ENTRYID then
        equipmentSlot = 4 -- Chest
    elseif slot == PLAYER_VISIBLE_ITEM_6_ENTRYID then
        equipmentSlot = 5 -- Waist
    elseif slot == PLAYER_VISIBLE_ITEM_10_ENTRYID then
        equipmentSlot = 9 -- Hands
	elseif slot == PLAYER_VISIBLE_ITEM_15_ENTRYID then
		equipmentSlot = 14 -- Back
	elseif slot == PLAYER_VISIBLE_ITEM_16_ENTRYID then
		equipmentSlot = 15 -- Main
	elseif slot == PLAYER_VISIBLE_ITEM_17_ENTRYID then
		equipmentSlot = 16 -- Off
	elseif slot == PLAYER_VISIBLE_ITEM_18_ENTRYID then
		equipmentSlot = 17 -- Ranged
	else
		equipmentSlot = Transmog_CalculateSlotReverse(slot)
	end
	
	local currentItem = player:GetEquippedItemBySlot(equipmentSlot)
	local equippedItemType = nil
	local equippedItemSubType = nil
	
	if currentItem then
		equippedItemType = currentItem:GetClass()
		equippedItemSubType = currentItem:GetSubClass()
	end

	-- Calculate page offset
	local pageOffset = (page > 1) and (SLOTS * (page - 1)) or 0
	
	local queryConditions = "account_id = " .. player:GetAccountId() .. " AND inventory_type " .. inventoryTypes .. " AND (display_id LIKE '%" .. search .. "%' OR item_name LIKE '%" .. search .. "%')"
	
	if equippedItemSubType then
		if (RESTRICT_ARMOR_TRANSMOG_TO_SIMILAR_MATERIALS and equippedItemType == 4) then
			if slot == PLAYER_VISIBLE_ITEM_5_ENTRYID then -- Special check for chestpiece/robes.
				queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
			else
				queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
			end
		elseif (RESTRICT_WEAPON_TRANSMOG_TO_SIMILAR_WEAPONS and equippedItemType == 2) then
			queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
		end
	end
	
	-- Query to count matching transmogs
	local countQuery = string.format(
		"SELECT COUNT(unlocked_item_id) FROM account_transmog WHERE %s;", 
		queryConditions
	)
	local countResult = AuthDBQuery(countQuery)
	if not countResult then
		AIO.Handle(player, "TransmogrificationServer", "InitTab", {}, page, false)
		return
	end

	local totalTransmogs = countResult:GetUInt32(0)
	local hasMorePages = (totalTransmogs > SLOTS * page)

	-- Query to get transmogs
	local transmogQuery = string.format(
		"SELECT unlocked_item_id FROM account_transmog WHERE %s LIMIT %d OFFSET %d;", 
		queryConditions, SLOTS, pageOffset
	)
	local transmogs = AuthDBQuery(transmogQuery)
	if not transmogs then
		AIO.Handle(player, "TransmogrificationServer", "InitTab", {}, page, false)
		return
	end

	-- Collect the unlocked item IDs
	local currentSlotItemIDs = {}
	for i = 1, transmogs:GetRowCount() do
		local currentRow = transmogs:GetRow()
		local item = currentRow["unlocked_item_id"]
		table.insert(currentSlotItemIDs, item)
		transmogs:NextRow()
	end

	-- Return the result
	AIO.Handle(player, "TransmogrificationServer", "InitTab", currentSlotItemIDs, page, hasMorePages)
end

function TransmogrificationHandler.SetEquipmentTransmogInfo(player, slot, currentSlotTooltip)
	local playerGUID = player:GetGUIDLow()
	
	local transmog = CharDBQuery("SELECT COUNT(item) FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = '"..slot.."';")
	if (transmog == nil) then
		return;
	end
	
	if (transmog:GetUInt32(0) ~= 0) then
		AIO.Handle(player, "TransmogrificationServer", "SetEquipmentTransmogInfoClient", currentSlotTooltip)
	end
end

function TransmogrificationHandler.GetItemsWithSameAppearance(player, itemID)
	-- Query the server for the display ID of the new item
	local displayIDQuery = "SELECT displayid FROM item_template WHERE entry = " .. itemID .. ";"
	local displayIDResult = WorldDBQuery(displayIDQuery)
	
	if not displayIDResult then
		return
	end
	
	local displayID = displayIDResult:GetUInt32(0)
	
	-- Find all items with the same display ID
	local matchingItemsQuery = "SELECT entry FROM item_template WHERE displayid = " .. displayID .. ";"
	local matchingItemsResult = WorldDBQuery(matchingItemsQuery)
	
	if not matchingItemsResult then
		return
	end
	
	-- Collect the matching item IDs into a table
	local matchingItems = {}
	for i = 1, matchingItemsResult:GetRowCount() do
		local currentRow = matchingItemsResult:GetRow()
		local matchingItemID = currentRow["entry"]
		table.insert(matchingItems, matchingItemID)
		matchingItemsResult:NextRow()
	end
	
	-- Send the matching transmogs to the client
	AIO.Handle(player, "TransmogrificationServer", "ReceiveMatchingAppearances", itemID, matchingItems)
end

function TransmogrificationHandler.SendCollectedTransmogItemIDs(player)
	local accountGUID = player:GetAccountId()
	
	-- Query to retrieve collected transmog display IDs
	local collectedDisplayIDsQuery = "SELECT DISTINCT display_id FROM account_transmog WHERE account_id = " .. accountGUID .. ";"
	local displayIDsResult = AuthDBQuery(collectedDisplayIDsQuery)
	
	if not displayIDsResult then
		AIO.Handle(player, "TransmogrificationServer", "ReceiveCollectedAppearances", {}, 0)
		return
	end
	
	-- Count the unique appearances.
	local uniqueAppearancesCount = displayIDsResult:GetRowCount()
	
	-- Collect the display IDs into a table
	local collectedDisplayIDs = {}
	for i = 1, displayIDsResult:GetRowCount() do
		local currentRow = displayIDsResult:GetRow()
		local displayID = currentRow["display_id"]
		table.insert(collectedDisplayIDs, displayID)
		displayIDsResult:NextRow()
	end
	
	local collectedAppearances = {}
	
	-- For each display ID, find all items that share the appearance
	for _, displayID in ipairs(collectedDisplayIDs) do
		local itemsWithDisplayQuery = "SELECT entry FROM item_template WHERE displayid = " .. displayID .. ";"
		local itemsResult = WorldDBQuery(itemsWithDisplayQuery)
		
		if itemsResult then
			for j = 1, itemsResult:GetRowCount() do
				local itemRow = itemsResult:GetRow()
				local itemID = itemRow["entry"]
				table.insert(collectedAppearances, itemID)
				itemsResult:NextRow()
			end
		end
	end
	
	-- Send the collected transmogs to the client
	AIO.Handle(player, "TransmogrificationServer", "ReceiveCollectedAppearances", collectedAppearances, uniqueAppearancesCount)
end

RegisterPlayerEvent(1, Transmog_OnCharacterCreate)
RegisterPlayerEvent(2, Transmog_OnCharacterDelete)
RegisterPlayerEvent(3, Transmog_OnCharacterLogin)

RegisterPlayerEvent(29, Transmog_OnEquipItem)

RegisterPlayerEvent(30, function(event, player, bag, slot) 
    if bag == 255 then
        TransmogrificationHandler.OnUnequipItem(player)
    end
end)

if ADD_NEWLY_LOOTED_ITEMS_TO_THE_TRANSMOG_LIST then
	RegisterPlayerEvent(32, Transmog_OnLootItem)
	RegisterPlayerEvent(51, Transmog_OnLootItem)
	RegisterPlayerEvent(52, Transmog_OnLootItem)
	RegisterPlayerEvent(53, Transmog_OnLootItem)
	RegisterPlayerEvent(56, Transmog_OnLootItem)
end

if ADD_QUEST_REWARD_ITEMS_TO_THE_TRANSMOG_LIST then
	RegisterPlayerEvent(54, Transmog_OnQuestComplete)
end

RegisterPlayerEvent(42, function(event, player, command)
	if command:lower() == "transmog sync" then
		TransmogrificationHandler.SendCollectedTransmogItemIDs(player)
		return false
	end
	return true
end)

print("[Eluna] Transmog System loaded successfully.")
