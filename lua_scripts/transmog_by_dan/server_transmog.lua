---------------------|Created by DanielTheDeveloper|-----------------------|

local AIO = AIO or require("AIO")

local TransmogHandlers = AIO.AddHandlers("Transmog", {})

local NPCID = 11326

local SLOTS = 8

local CALC = 281

local PLAYER_VISIBLE_ITEM_1_ENTRYID  = 283
local PLAYER_VISIBLE_ITEM_3_ENTRYID  = 287
local PLAYER_VISIBLE_ITEM_4_ENTRYID  = 289
local PLAYER_VISIBLE_ITEM_5_ENTRYID  = 291
local PLAYER_VISIBLE_ITEM_6_ENTRYID  = 293 
local PLAYER_VISIBLE_ITEM_7_ENTRYID  = 295
local PLAYER_VISIBLE_ITEM_8_ENTRYID  = 297
local PLAYER_VISIBLE_ITEM_9_ENTRYID  = 299
local PLAYER_VISIBLE_ITEM_10_ENTRYID  = 301
local PLAYER_VISIBLE_ITEM_15_ENTRYID  = 311
local PLAYER_VISIBLE_ITEM_16_ENTRYID  = 313
local PLAYER_VISIBLE_ITEM_17_ENTRYID  = 315
local PLAYER_VISIBLE_ITEM_18_ENTRYID  = 317
local PLAYER_VISIBLE_ITEM_19_ENTRYID  = 319

function Transmog_CalculateSlot(slot)
	if (slot == 0) then
		slot = 1
	elseif ( slot >= 2 ) then
		slot = slot + 1
	end
	return CALC + (slot * 2);
end

function Transmog_CalculateSlotReverse(slot)
	local reverseSlot = (slot - CALC) / 2
	if ( reverseSlot == 1 ) then
		return 0;
	end
	return reverseSlot;
end

function Transmog_OnCharacterCreate(event, player)
	local playerGUID = player:GetGUIDLow()
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_1_ENTRYID.."', '', '');") -- Head
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_3_ENTRYID.."', '', '');") -- Shoulder
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_4_ENTRYID.."', '', '');") -- Shirt
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_5_ENTRYID.."', '', '');") -- Chest
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_6_ENTRYID.."', '', '');") -- Waist
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_7_ENTRYID.."', '', '');") -- Legs
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_8_ENTRYID.."', '', '');") -- Feet
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_9_ENTRYID.."', '', '');") -- Wrist
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_10_ENTRYID.."', '', '');") -- Hands
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_15_ENTRYID.."', '', '');") -- Back
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_16_ENTRYID.."', '', '');") -- Main
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_17_ENTRYID.."', '', '');") -- Off
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_18_ENTRYID.."', '', '');") -- Ranged
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..PLAYER_VISIBLE_ITEM_19_ENTRYID.."', '', '');") -- Tabard
end

function Transmog_OnCharacterDelete(event, guid)
	CharDBQuery("DELETE FROM character_transmog WHERE player_guid = "..guid.."")
end

function TransmogHandlers.LootItemLocale(player, item, count, locale)
    local accountGUID = player:GetAccountId()
    local itemId = item
    local itemTemplate = GetItemTemplate(itemId)
    local class = itemTemplate:GetClass()

    if class == 2 or class == 4 then
        -- Transmogs are unlocked on account level!
        local inventoryType = itemTemplate:GetInventoryType()
        local displayId = itemTemplate:GetDisplayId()
        local itemName = itemTemplate:GetName()

        itemName = itemName:gsub("'", "''")
        AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `display_id`, `inventory_type`, `item_name`) VALUES (" .. accountGUID .. ", " .. itemId .. ", " .. displayId .. ", " .. inventoryType .. ", '" .. itemName .. "');")
        local locItemName = itemTemplate:GetName(locale)

        if locItemName == nil then
            locItemName = itemTemplate:GetName(0)
        end

        local itemLink = "|cffff80ff|Hitem:" .. itemId .. ":0:0:0:0:0:0:0:0|h[" .. locItemName .. "]|h|r"
        local message = itemLink .. " wurde deiner Transmog-Sammlung hinzugefügt."
        player:SendBroadcastMessage(message)
    end
end

function Transmog_OnLootItem(event, player, item, count)
    AIO.Handle(player, "Transmog", "GetLocale", item:GetItemTemplate():GetItemId(), count)
end

function Transmog_OnEquipItem(event, player, item, bag, slot)
	local accountGUID = player:GetAccountId()
	local playerGUID = player:GetGUIDLow()
	
	local class = item:GetClass()
	local inventoryType = item:GetItemTemplate():GetInventoryType()
	if ( class == 2 or class == 4 ) and inventoryType ~= 28 then
		-- Transmogs are unlocked on account level!
		local itemId = item:GetItemTemplate():GetItemId()
		local displayId = item:GetItemTemplate():GetDisplayId()
		local itemName = item:GetName()
		itemName = itemName:gsub("'", "''")
		AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `display_id`, `inventory_type`, `item_name`) VALUES ("..accountGUID..", "..itemId..", "..displayId..", "..inventoryType..", '"..itemName.."');") -- ON DUPLICATE KEY UPDATE account_id = VALUES(account_id), display_id = VALUES(display_id), inventory_type = VALUES(inventory_type), item_name = VALUES(item_name)
		local constSlot = Transmog_CalculateSlot(slot)
		
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `real_item`) VALUES ("..playerGUID..", '"..constSlot.."', "..itemId..") ON DUPLICATE KEY UPDATE real_item = VALUES(real_item);")
		
		local transmog = CharDBQuery("SELECT item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..constSlot.." AND item IS NOT NULL;")
		if transmog == nil then
			return;
		end
		local transmogItem = transmog:GetUInt32(0)
		local isPlayerInitDone = player:GetUInt32Value(147) -- Use unit padding
		if transmogItem == nil or ( transmogItem == 0 and isPlayerInitDone ~= 1 ) then
			return;
		end
		
		player:SetUInt32Value(constSlot, transmogItem)
	end
end

-- Todo add lua/c++ function for unequip!!
function TransmogHandlers.OnUnequipItem(player)
	local playerGUID = player:GetGUIDLow()

	local transmogs = CharDBQuery('SELECT item, real_item, slot FROM character_transmog WHERE player_guid = '..playerGUID..' AND item IS NOT NULL;') -- AND slot NOT IN ("313", "315", "317")
	if transmogs == nil then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local item = currentRow["item"]
		local slot = currentRow["slot"]
		local realItem = currentRow["real_item"] or "NULL"
		local validSlotItem = player:GetUInt32Value(tonumber(slot))
		if validSlotItem == 0 then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', "..item..", "..realItem..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
			player:SetUInt32Value(slot, item)
		end
		transmogs:NextRow()
	end
end

function Transmog_Load(player)
	local playerGUID = player:GetGUIDLow()
	
	local transmogs = CharDBQuery( "SELECT item, slot FROM character_transmog WHERE player_guid = "..playerGUID..";")
	if ( transmogs == nil ) then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local slot = currentRow["slot"]
		local item = currentRow["item"]
		if ( item ~= nil and item ~= '' ) then
			player:SetUInt32Value(tonumber(slot), item)
		end
		transmogs:NextRow()
	end
	AIO.Handle(player, "Transmog", "LoadTransmogsAfterSave")
end

function Transmog_OnLogin(event, player)
	-- Apply transmog on login
	-- Transmog_Load(player)
	--local item = player:GetEquippedItemBySlot(4)
	--print(item:GetName())
end

function TransmogHandlers.LoadPlayer(player)
	Transmog_Load(player)
	player:SetUInt32Value(147, 1) -- use unit padding
end

function TransmogHandlers.EquipTransmogItem(player, item, slot)
	local playerGUID = player:GetGUIDLow()
	
	if item == nil and item ~= 0 then
		local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
		local oldItemId = oldItem:GetUInt32(0)
		if oldItemId == nil or oldItemId == 0 then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', NULL) ON DUPLICATE KEY UPDATE item = VALUES(item);")
			player:SetUInt32Value(tonumber(slot), 0)
			return
		end

		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', NULL, "..oldItemId..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		player:SetUInt32Value(tonumber(slot), oldItemId)
		return
	end
	
	local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
	local oldItemId = oldItem:GetUInt32(0)
	if oldItemId == nil or oldItemId == 0 then
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', "..item..") ON DUPLICATE KEY UPDATE item = VALUES(item);")
	else
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', "..item..", "..oldItemId..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
	end
	player:SetUInt32Value(tonumber(slot), item)
end

function TransmogHandlers.EquipAllTransmogItems(player, transmogPreview)
	if ( transmogPreview == {} ) then
		return;
	end
	
	local playerGUID = player:GetGUIDLow()
	
	for slot, item in ipairs(transmogPreview) do
		player:SetUInt32Value(tonumber(slot), item)
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', "..item..") ON DUPLICATE KEY UPDATE item = VALUES(item);")
	end
end

function TransmogHandlers.UnequipTransmogItem(player, slot)
	local playerGUID = player:GetGUIDLow()
	
	local oldItem = CharDBQuery( "SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
	local oldItemId = oldItem:GetUInt32(0)
	if ( oldItemId == nil or oldItemId == 0) then
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', 0, 0) ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		player:SetUInt32Value(tonumber(slot), 0)
		return;
	end
	
	CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', 0, '"..oldItemId.."') ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
	player:SetUInt32Value(tonumber(slot), oldItemId)
end

function TransmogHandlers.displayTransmog(player, spellid)
	AIO.Handle(player, "Transmog", "TransmogFrame")
	return false
end

function TransmogHandlers.Print(player, ...)
    print(...)
end

function TransmogHandlers.SetTransmogItemIds(player)
	local playerGUID = player:GetGUIDLow()
	
	local transmogs = CharDBQuery( 'SELECT item, real_item, slot FROM character_transmog WHERE player_guid = '..playerGUID..';') -- AND slot NOT IN ("313", "315", "317")
	if ( transmogs == nil ) then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local item = currentRow["item"]
		local slot = currentRow["slot"]
		local real_item = currentRow["real_item"]
		local validSlotItem = player:GetUInt32Value(tonumber(slot))
		if ( validSlotItem == 0 ) then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', 0, "..real_item..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		end
		if (  not item or item == 0 and real_item ~= nil and real_item ~= 0 and ( validSlotItem ~= 0 or not validSlotItem )) then
			AIO.Handle(player, "Transmog", "SetTransmogItemIdClient", slot, 0, real_item)
		else
			AIO.Handle(player, "Transmog", "SetTransmogItemIdClient", slot, item, real_item)
		end
		transmogs:NextRow()
	end
end

function TransmogHandlers.SetCurrentSlotItemIds(player, slot, page)
    -- Get the account ID
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

    -- Calculate page offset for pagination
    local pageOffset = (page > 1) and (SLOTS * (page - 1)) or 0

    -- Query to count matching transmogs
    local countQuery = string.format(
        "SELECT COUNT(unlocked_item_id) FROM account_transmog WHERE account_id = %d AND inventory_type %s;",
        accountGUID, inventoryTypes
    )
    local countResult = AuthDBQuery(countQuery)
    if not countResult then
        AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
        return
    end

    -- Get the total number of transmogs
    local totalTransmogs = countResult:GetUInt32(0)
    local hasMorePages = (totalTransmogs > SLOTS * page)

    -- Query to retrieve transmogs for the current page
    local transmogQuery = string.format(
        "SELECT unlocked_item_id FROM account_transmog WHERE account_id = %d AND inventory_type %s LIMIT %d OFFSET %d;",
        accountGUID, inventoryTypes, SLOTS, pageOffset
    )
    local transmogs = AuthDBQuery(transmogQuery)
    if not transmogs then
        AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
        return
    end

    -- Collect the unlocked item IDs
    local currentSlotItemIds = {}
    for i = 1, transmogs:GetRowCount() do
        local currentRow = transmogs:GetRow()
        local item = currentRow["unlocked_item_id"]
        table.insert(currentSlotItemIds, item)
        transmogs:NextRow()
    end

    -- Return the result to the player
    AIO.Handle(player, "Transmog", "InitTab", currentSlotItemIds, page, hasMorePages)
end

function TransmogHandlers.SetSearchCurrentSlotItemIds(player, slot, page, search)
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

    -- Calculate page offset
    local pageOffset = (page > 1) and (SLOTS * (page - 1)) or 0
	
    -- Query to count matching transmogs
    local countQuery = string.format(
        "SELECT COUNT(unlocked_item_id) FROM account_transmog WHERE account_id = %d AND inventory_type %s AND (display_id LIKE '%%%s%%' OR item_name LIKE '%%%s%%');", 
        player:GetAccountId(), inventoryTypes, search, search
    )
    local countResult = AuthDBQuery(countQuery)
    if not countResult then
        AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
        return
    end

    local totalTransmogs = countResult:GetUInt32(0)
    local hasMorePages = (totalTransmogs > SLOTS * page)

    -- Query to get transmogs
    local transmogQuery = string.format(
        "SELECT unlocked_item_id FROM account_transmog WHERE account_id = %d AND inventory_type %s AND (display_id LIKE '%%%s%%' OR item_name LIKE '%%%s%%') LIMIT %d OFFSET %d;", 
        player:GetAccountId(), inventoryTypes, search, search, SLOTS, pageOffset
    )
    local transmogs = AuthDBQuery(transmogQuery)
    if not transmogs then
        AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
        return
    end

    -- Collect the unlocked item IDs
    local currentSlotItemIds = {}
    for i = 1, transmogs:GetRowCount() do
        local currentRow = transmogs:GetRow()
        local item = currentRow["unlocked_item_id"]
        table.insert(currentSlotItemIds, item)
        transmogs:NextRow()
    end

    -- Return the result
    AIO.Handle(player, "Transmog", "InitTab", currentSlotItemIds, page, hasMorePages)
end

function TransmogHandlers.SetEquipmentTransmogInfo(player, slot, currentTooltipSlot)
	local playerGUID = player:GetGUIDLow()
	
	local transmog = CharDBQuery( "SELECT COUNT(item) FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = '"..slot.."';")
	if ( transmog == nil ) then
		return;
	end
	
	if ( transmog:GetUInt32(0) ~= 0) then
		AIO.Handle(player, "Transmog", "SetEquipmentTransmogInfoClient", currentTooltipSlot)
	end
end

RegisterPlayerEvent(1, Transmog_OnCharacterCreate)
RegisterPlayerEvent(2, Transmog_OnCharacterDelete)
RegisterPlayerEvent(32, Transmog_OnLootItem)
RegisterPlayerEvent(51, Transmog_OnLootItem)
RegisterPlayerEvent(52, Transmog_OnLootItem)
RegisterPlayerEvent(53, Transmog_OnLootItem)
RegisterPlayerEvent(56, Transmog_OnLootItem)
RegisterPlayerEvent(29, Transmog_OnEquipItem)
RegisterPlayerEvent(3, Transmog_OnLogin)
