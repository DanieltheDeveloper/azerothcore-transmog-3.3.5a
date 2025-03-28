-- TooltipClient.lua (WoTLK 3.3.5a Compatible Version with Localization)
-- v1.3
local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local TransmogTooltip = CreateFrame("Frame")

local TransmogItemCache = {}

-- Detect Player Locale
local L_NewAppearance = {}
L_NewAppearance["enUS"] = "New Appearance"
L_NewAppearance["frFR"] = "Nouvelle Apparence"
L_NewAppearance["deDE"] = "Neues Aussehen"
L_NewAppearance["esES"] = "Nueva Apariencia"
L_NewAppearance["ruRU"] = "Новый внешний вид"
 
local L_CheckingAppearance = {}
L_CheckingAppearance["enUS"] = "Checking Appearance..."
L_CheckingAppearance["frFR"] = "Vérification de l'apparence..."
L_CheckingAppearance["deDE"] = "Aussehen wird überprüft..."
L_CheckingAppearance["esES"] = "Comprobando apariencia..."
L_CheckingAppearance["ruRU"] = "Проверка внешнего вида..."
 
local locale = GetLocale()
local transmogMessage = L_NewAppearance[locale] or L_NewAppearance["enUS"]
local checkingMessage = L_CheckingAppearance[locale] or L_CheckingAppearance["enUS"]
 
if AIO.AddHandlers then
    AIO.AddHandlers("TransmogTooltip", {
    ItemCheckResult = function(player, itemID, isUnlocked)
        -- print("[Transmog Debug] Received ItemCheckResult for itemID:", itemID, "Unlocked:", isUnlocked)
        TransmogItemCache[itemID] = isUnlocked
        
        -- Force tooltip refresh if the item is currently hovered
        if GameTooltip:IsShown() then
            local _, itemLink = GameTooltip:GetItem()
            if itemLink then
                local hoveredItemID = tonumber(itemLink:match("item:(%d+)"))
                if hoveredItemID == itemID then
                    -- print("[Transmog Debug] Refreshing tooltip for itemID:", itemID)
                    GameTooltip:ClearLines()
                    GameTooltip:SetHyperlink(itemLink) -- Re-add the tooltip
                    GameTooltip:Show()
                end
            end
        end
    end,
    
    -- print("[Transmog Debug] AIO Handlers for TransmogTooltip registered.")
    
    RegisterUnlockedItem = function(player, itemID) -- server_transmog.lua notification
        TransmogItemCache[itemID] = true
    end
    })	
else
    -- print("[Transmog Debug] AIO AddHandlers not available.")
end

local VALID_INVENTORY_TYPES = {
    INVTYPE_2HWEAPON        = true,   -- 2H Weapon
    INVTYPE_AMMO            = false,  -- Ammo (No visual)
    INVTYPE_BAG             = false,  -- Bags (No visual)
    INVTYPE_BODY            = true,   -- Shirt
    INVTYPE_CHEST           = true,   -- Chest
    INVTYPE_CLOAK           = true,   -- Back
    INVTYPE_FEET            = true,   -- Feet
    INVTYPE_FINGER          = false,  -- Rings (No visual)
    INVTYPE_HAND            = true,   -- Hands
    INVTYPE_HEAD            = true,   -- Head
    INVTYPE_HOLDABLE        = true,   -- Tome, orbs, etc
    INVTYPE_LEGS            = true,   -- Legs
    INVTYPE_NECK            = false,  -- Neck (No visual)
    INVTYPE_QUIVER          = false,  -- Quiver (No visual)
    INVTYPE_RANGED          = true,   -- Ranged (Bows, Guns)
    INVTYPE_RANGEDRIGHT     = true,   -- Ranged Right (Wands, Guns)
    INVTYPE_RELIC           = false,  -- Idols, Librams, Totems, Sigils (No visual)
    INVTYPE_ROBE            = true,   -- Robe (may be redundant with INVTYPE_CHEST )
    INVTYPE_SHIELD          = true,   -- Shield
    INVTYPE_SHOULDER        = true,   -- Shoulders
    INVTYPE_TABARD          = true,   -- Tabard
    INVTYPE_TRINKET         = false,  -- Trinkets (No visual)
    INVTYPE_THROWN          = true,   -- Thrown (Treated like Ranged?)
    INVTYPE_WAIST           = true,   -- Waist
    INVTYPE_WEAPON          = true,   -- 1H Weapon
    INVTYPE_WEAPONMAINHAND  = true,   -- Main Hand
    INVTYPE_WEAPONOFFHAND   = true,   -- Off Hand
    INVTYPE_WRIST           = true,   -- Wrists
}

local function ShouldCheckItem(itemLink)
    if not itemLink then return false end

    local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)
    return VALID_INVENTORY_TYPES[equipSlot] or false
end
 
local function OnTooltipSetItem(self)
    local _, itemLink = self:GetItem()
    if not itemLink then
        -- print("[Transmog Debug] No item link found for tooltip.")
        return
    end
 
    local itemID = tonumber(itemLink:match("item:(%d+)"))
    if not itemID or not ShouldCheckItem(itemLink) then return end

    if TransmogItemCache[itemID] ~= nil then -- Display L_CheckingAppearance in red as placeholder before server replies
        if TransmogItemCache[itemID] == false then -- Tooltip should display L_NewAppearance when server has sent false
            self:AddLine("|cffff8000" .. transmogMessage .. "|r")
            self:Show()
        end
        return
    end 

    AIO.Handle("TransmogTooltip", "CheckItem", itemID)
    self:AddLine("|cffff8000" .. checkingMessage  .. "|r")
    self:Show()
end

GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefShoppingTooltip3:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip1:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip3:HookScript("OnTooltipSetItem", OnTooltipSetItem)
