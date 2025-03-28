---------------------|Created by DanielTheDeveloper|-----------------------|

local AIO = AIO or require("AIO")

local TransmogHandlers = AIO.AddHandlers("Transmog", {})

local NPCID = 11326

local SLOTS = 6

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

local UNUSABLE_INVENTORY_TYPES = {[2] = true, [11] = true, [12] = true, [18] = true, [24] = true, [27] = true, [28] = true}
-- use .recovertransmog in game to recover missing rewarded transmog from quests
local RECOVERY_COMMAND = "recovertransmog" -- Change this if you want a different command

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

-- lang 
local LOOT_ITEM_LOCALE = {
    [0] = " has been added to your transmog collection.",                   -- enUS
    [2] = " a été ajouté à votre collection de transmogrification.",        -- frFR
    [3] = " wurde deiner Transmog-Sammlung hinzugefügt.",                   -- deDE
    [6] = " ha sido añadido a tu colección de transfiguraciones.",          -- esES
    [8] = " был добавлен в вашу коллекцию трансмогрификации."               -- ruRU
}
local RECOVER_MESSAGES = {
    noQuests = {
        [0] = "No rewarded quests found for your account.",                                  -- enUS
        [2] = "Aucune quête à récompenses trouvée pour votre compte.",                       -- frFR
        [3] = "Keine Belohnungsquests für deinen Account gefunden.",                         -- deDE
        [6] = "No se encontraron misiones con recompensa en tu cuenta.",                     -- esES
        [8] = "Для вашей учетной записи не найдено заданий с наградами."                     -- ruRU
    },
    noneFound = {
        [0] = "No missing transmog-eligible rewards found in your completed quests.",                     -- enUS
        [2] = "Aucune apparence manquante trouvée dans vos quêtes terminées.",                            -- frFR
        [3] = "Keine fehlenden transmog-fähigen Belohnungen in deinen abgeschlossenen Quests gefunden.",  -- deDE
        [6] = "No se encontraron apariencias faltantes en tus misiones completadas.",                     -- esES
        [8] = "Не найдено отсутствующих трансмогов среди завершённых заданий."                            -- ruRU
    },
    recovered = {
        [0] = "Recovered %d missing transmog item(s) from completed quests.",                                -- enUS
        [2] = "%d objet(s) de transmogrification récupéré(s) depuis les quêtes terminées.",                  -- frFR
        [3] = "%d fehlende Transmog-Gegenstand/Gegenstände aus abgeschlossenen Quests wiederhergestellt.",   -- deDE
        [6] = "Se recuperaron %d apariencia(s) de misiones completadas.",                                    -- esES
        [8] = "Восстановлено предметов трансмогрификации из завершённых заданий: %d."                        -- ruRU
    }
}

function TransmogHandlers.LootItemLocale(player, item, count, locale)
    local accountGUID = player:GetAccountId()
    local itemId = item
    local itemTemplate = GetItemTemplate(itemId)
    local inventoryType = itemTemplate:GetInventoryType()
    local class = itemTemplate:GetClass()

    if (class == 2 or class == 4 ) and not UNUSABLE_INVENTORY_TYPES[inventoryType] then
        -- Transmogs are unlocked on account level!
        local displayId = itemTemplate:GetDisplayId()
        local itemName = itemTemplate:GetName():gsub("'", "''")
		
		-- **Check if the item is already unlocked**
		local checkQuery = AuthDBQuery("SELECT COUNT(*) FROM account_transmog WHERE account_id = " .. accountGUID .. " AND unlocked_item_id = " .. itemId .. ";")
		if checkQuery and checkQuery:GetUInt32(0) > 0 then
		    return -- Item already unlocked, no need to add or send message again
		end
		
		-- Insert new unlocked item
		AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `display_id`, `inventory_type`, `item_name`) VALUES (" 
		    .. accountGUID .. ", " .. itemId .. ", " .. displayId .. ", " .. inventoryType .. ", '" .. itemName .. "');")
		
		-- Register the item client-side
		AIO.Handle(player, "TransmogTooltip", "RegisterUnlockedItem", itemId)
		
		-- Send notification once
		local locItemName = itemTemplate:GetName(locale) or itemTemplate:GetName(0)
		local itemLink = "|cffff80ff|Hitem:" .. itemId .. ":0:0:0:0:0:0:0:0|h[" .. locItemName .. "]|h|r"
		local message = itemLink .. (LOOT_ITEM_LOCALE[locale] or LOOT_ITEM_LOCALE[0])
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
	if ( class == 2 or class == 4 ) and not UNUSABLE_INVENTORY_TYPES[inventoryType] then
		-- Transmogs are unlocked on account level!
		local itemId = item:GetItemTemplate():GetItemId()
		local displayId = item:GetItemTemplate():GetDisplayId()
		local itemName = item:GetName()
		itemName = itemName:gsub("'", "''")
		AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `display_id`, `inventory_type`, `item_name`) VALUES ("..accountGUID..", "..itemId..", "..displayId..", "..inventoryType..", '"..itemName.."');") -- ON DUPLICATE KEY UPDATE account_id = VALUES(account_id), display_id = VALUES(display_id), inventory_type = VALUES(inventory_type), item_name = VALUES(item_name)
		AIO.Handle(player, "TransmogTooltip", "RegisterUnlockedItem", itemId)
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

function TransmogHandlers.RecoverQuestTransmogs(player, locale)
    local langId = locale or 0
    local accountGUID = player:GetAccountId()
	local messageSent = false
    -- Query all REWARDED quests for all characters on the account
    local completedQuestsQuery = CharDBQuery("SELECT DISTINCT quest FROM character_queststatus_rewarded WHERE guid IN (SELECT guid FROM characters WHERE account = " .. accountGUID .. ");")

    if not completedQuestsQuery then
		if not messageSent then
			player:SendBroadcastMessage(RECOVER_MESSAGES.noQuests[langId] or RECOVER_MESSAGES.noQuests[0])
			messageSent = true
		end
        return
    end

    local recoveredItems = {}

    repeat
        local questId = completedQuestsQuery:GetUInt32(0)

        -- Get all possible rewards for the rewarded quest
        local rewardsQuery = WorldDBQuery("SELECT RewardChoiceItemID1, RewardChoiceItemID2, RewardChoiceItemID3, RewardChoiceItemID4, RewardChoiceItemID5, RewardChoiceItemID6, RewardItem1, RewardItem2, RewardItem3, RewardItem4 FROM quest_template WHERE ID = " .. questId .. ";")

        if rewardsQuery then
            local rewardItems = {}

            -- Collect Choice Rewards (RewardChoiceItemID1-6)
            for i = 0, 5 do
                local itemId = rewardsQuery:GetUInt32(i)
                if itemId and itemId > 0 then
                    table.insert(rewardItems, itemId)
                end
            end

            -- Collect Guaranteed Rewards (RewardItem1-4)
            for i = 6, 9 do
                local itemId = rewardsQuery:GetUInt32(i)
                if itemId and itemId > 0 then
                    table.insert(rewardItems, itemId)
                end
            end

            -- Filter out only transmog-eligible items
            local transmogItems = {}
            for _, itemId in ipairs(rewardItems) do
                local itemTemplate = GetItemTemplate(itemId)
                if itemTemplate then
                    local class = itemTemplate:GetClass()
                    local inventoryType = itemTemplate:GetInventoryType()
                    if (class == 2 or class == 4) and not UNUSABLE_INVENTORY_TYPES[inventoryType] then
                        table.insert(transmogItems, itemId)
                    end
                end
            end

            -- Check which transmog-eligible items are missing from `account_transmog`
            if #transmogItems > 0 then
                local itemIdList = table.concat(transmogItems, ", ")

                -- Query to check which items are already unlocked
                local existingItemsQuery = AuthDBQuery("SELECT unlocked_item_id FROM account_transmog WHERE account_id = " .. accountGUID .. " AND unlocked_item_id IN (" .. itemIdList .. ");")

                -- Store already unlocked items
                local unlockedItems = {}
                if existingItemsQuery then
                    repeat
                        local unlockedItemId = existingItemsQuery:GetUInt32(0)
                        unlockedItems[unlockedItemId] = true
                    until not existingItemsQuery:NextRow()
                end

                -- Identify missing transmog rewards
                local missingRewards = {}
                for _, itemId in ipairs(transmogItems) do
                    if not unlockedItems[itemId] then
                        table.insert(missingRewards, itemId)
                    end
                end

                -- Unlock only missing items
                for _, itemId in ipairs(missingRewards) do
                    local itemTemplate = GetItemTemplate(itemId)
                    if itemTemplate then
                        local displayId = itemTemplate:GetDisplayId()
                        local inventoryType = itemTemplate:GetInventoryType()
                        local itemName = itemTemplate:GetName():gsub("'", "''")

                        -- Insert missing item into `account_transmog`
                        AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `display_id`, `inventory_type`, `item_name`) VALUES (" 
                            .. accountGUID .. ", " .. itemId .. ", " .. displayId .. ", " .. inventoryType .. ", '" .. itemName .. "');")

                        -- Register the item in tooltip
                        AIO.Handle(player, "TransmogTooltip", "RegisterUnlockedItem", itemId)

                        -- Store in recovered list for notification
                        table.insert(recoveredItems, itemId)
                    end
                end
            end
        end
    until not completedQuestsQuery:NextRow()

    -- Notify player about recovered transmogs
	if not messageSent then
		if #recoveredItems > 0 then
			player:SendBroadcastMessage(string.format(RECOVER_MESSAGES.recovered[langId] or RECOVER_MESSAGES.recovered[0], #recoveredItems))
		else
			player:SendBroadcastMessage(RECOVER_MESSAGES.noneFound[langId] or RECOVER_MESSAGES.noneFound[0])
		end
		messageSent = true
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
	
	if item == nil then
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
		if (item == nil) and (real_item ~= nil and real_item ~= 0) then
			AIO.Handle(player, "Transmog", "SetTransmogItemIdClient", slot, real_item, real_item)
		elseif (item == 0) and (real_item ~= nil and real_item ~= 0) then
			AIO.Handle(player, "Transmog", "SetTransmogItemIdClient", slot, item, real_item)
		else
			AIO.Handle(player, "Transmog", "SetTransmogItemIdClient", slot, item or 0, real_item or 0)
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
	if ( search == nil or search == '' ) then
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
RegisterPlayerEvent(42, function(event, player, command)
    if command == RECOVERY_COMMAND then
        TransmogHandlers.RecoverQuestTransmogs(player)
        return false -- Prevents default handling of the command
    end
end)