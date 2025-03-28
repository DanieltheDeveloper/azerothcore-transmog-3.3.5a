-- TooltipServer.lua (WoTLK 3.3.5a Compatible Version)
-- v1.2
local AIO = AIO or require("AIO")

local TransmogTooltipHandler = AIO.AddHandlers("TransmogTooltip", {})

local VALID_INVENTORY_TYPES = {
    [0]  = false, -- None (No visual)
    [1]  = true,  -- Head
    [2]  = false, -- Neck (No visual)
    [3]  = true,  -- Shoulders
    [4]  = true,  -- Shirt
    [5]  = true,  -- Vest (Chest)
    [6]  = true,  -- Waist
    [7]  = true,  -- Legs
    [8]  = true,  -- Feet
    [9]  = true,  -- Wrist
    [10] = true,  -- Hands
    [11] = false, -- Ring (No visual)
    [12] = false, -- Trinket (No visual)
    [13] = true,  -- One Hand
    [14] = true,  -- Shield
    [15] = true,  -- Bow (Ranged Weapon)
    [16] = true,  -- Back (Cloak)
    [17] = true,  -- Two Hand
    [18] = false, -- Bag (No visual)
    [19] = true,  -- Tabard
    [20] = true,  -- Robe (Treated as Chest)
    [21] = true,  -- Main Hand
    [22] = true,  -- Off Hand
    [23] = true,  -- Held in Off Hand
    [24] = false, -- Ammo (No visual)
    [25] = true,  -- Thrown
    [26] = true,  -- Ranged
    [27] = false, -- Ranged (Quiver ?)
    [28] = false, -- Relic (No visual)
}

local function GetItemInventoryType(itemID)
    local query = WorldDBQuery("SELECT InventoryType FROM item_template WHERE entry = " .. itemID)
    if query then
        return query:GetInt32(0)
    end
    return nil
end

function TransmogTooltipHandler.CheckItem(player, itemID)
    -- print("[Transmog Debug] Received CheckItem request for itemID:", itemID, "from player:", player:GetName())

    local inventoryType = GetItemInventoryType(itemID)
    -- print("[Transmog Debug] ItemID:", itemID, "has InventoryType:", inventoryType)

    if not inventoryType or not VALID_INVENTORY_TYPES[inventoryType] then
        -- print("[Transmog Debug] Skipping itemID", itemID, "- Not a valid transmog type.")
        AIO.Handle(player, "TransmogTooltip", "ItemCheckResult", itemID, nil)
        return
    end

    local accountID = player:GetAccountId()
    local query = AuthDBQuery("SELECT 1 FROM account_transmog WHERE account_id = " .. accountID .. " AND unlocked_item_id = " .. itemID)

    local isUnlocked = query ~= nil
    -- print("[Transmog Debug] ItemID:", itemID, "Unlocked status:", isUnlocked)

    AIO.Handle(player, "TransmogTooltip", "ItemCheckResult", itemID, isUnlocked)
    -- print("[Transmog Debug] Sent ItemCheckResult for itemID:", itemID, "Unlocked:", isUnlocked)
end
