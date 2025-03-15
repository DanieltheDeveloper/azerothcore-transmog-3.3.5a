---------------------|Created by DanielTheDeveloper|-----------------------|

local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local TransmogHandlers = AIO.AddHandlers("Transmog", {})

local function OnEvent(self, event)
	AIO.Handle("Transmog", "LoadPlayer")
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)

local CALC = 281

PLAYER_VISIBLE_ITEM_1_ENTRYID  = 283
PLAYER_VISIBLE_ITEM_3_ENTRYID  = 287
PLAYER_VISIBLE_ITEM_4_ENTRYID  = 289
PLAYER_VISIBLE_ITEM_5_ENTRYID  = 291
PLAYER_VISIBLE_ITEM_6_ENTRYID  = 293
PLAYER_VISIBLE_ITEM_7_ENTRYID  = 295
PLAYER_VISIBLE_ITEM_8_ENTRYID  = 297
PLAYER_VISIBLE_ITEM_9_ENTRYID  = 299
PLAYER_VISIBLE_ITEM_10_ENTRYID  = 301
PLAYER_VISIBLE_ITEM_15_ENTRYID  = 311
PLAYER_VISIBLE_ITEM_16_ENTRYID  = 313
PLAYER_VISIBLE_ITEM_17_ENTRYID  = 315
PLAYER_VISIBLE_ITEM_18_ENTRYID  = 317
PLAYER_VISIBLE_ITEM_19_ENTRYID  = 319

function Transmog_CalculateSlotReverse(slot)
	local reverseSlot = (slot - CALC) / 2
	return reverseSlot;
end

local SLOT_IDS = {
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

function TableSetHelper(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local EMPTY_TEXTURE = "Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Icon-Inactive"
local EMPTY_EQUIPMENT_ICON_BACKGROUND_PATH = "Interface\\paperdoll\\UI-PaperDoll-Slot-"
local EQUIPMENT_ICON_TYPES = {"Head", "", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrists", "Hands", "", "", "", "", "Chest", "MainHand", "SecondaryHand", "Ranged", "Tabard"}
-- List of character item frames that will be used
local EQUIPMENT_SLOT_FRAME_NAMES = {"CharacterHeadSlot", "CharacterShoulderSlot", "CharacterBackSlot", "CharacterChestSlot", "CharacterShirtSlot", "CharacterTabardSlot", "CharacterWristSlot", "CharacterHandsSlot", "CharacterWaistSlot", "CharacterLegsSlot", "CharacterFeetSlot", "CharacterMainHandSlot", "CharacterSecondaryHandSlot", "CharacterRangedSlot"}
EQUIPMENT_SLOT_FRAME_NAMES = TableSetHelper(EQUIPMENT_SLOT_FRAME_NAMES)

TRANSMOG_SLOT_MAPPING = {
	[PLAYER_VISIBLE_ITEM_1_ENTRYID] = "Head",
	[PLAYER_VISIBLE_ITEM_3_ENTRYID] = "Shoulder",
	[PLAYER_VISIBLE_ITEM_4_ENTRYID] = "Shirt",
	[PLAYER_VISIBLE_ITEM_5_ENTRYID] = "Chest",
	[PLAYER_VISIBLE_ITEM_6_ENTRYID] = "Waist",
	[PLAYER_VISIBLE_ITEM_7_ENTRYID] = "Legs",
	[PLAYER_VISIBLE_ITEM_8_ENTRYID] = "Feet",
	[PLAYER_VISIBLE_ITEM_9_ENTRYID] = "Wrist",
	[PLAYER_VISIBLE_ITEM_10_ENTRYID] = "Hands",
	[PLAYER_VISIBLE_ITEM_15_ENTRYID] = "Back",
	[PLAYER_VISIBLE_ITEM_16_ENTRYID] = "MainHand",
	[PLAYER_VISIBLE_ITEM_17_ENTRYID] = "SecondaryHand",
	[PLAYER_VISIBLE_ITEM_18_ENTRYID] = "Ranged",
	[PLAYER_VISIBLE_ITEM_19_ENTRYID] = "Tabard"
}

-- Cached globals for performance
local GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip = 
      GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip

-- State management
local itemButtons = {}
local isInputHovered = false
local currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID

originalTransmogIds = originalTransmogIds or {}
AIO.AddSavedVarChar("originalTransmogIds")
currentTransmogIds = {}
for k, v in pairs(originalTransmogIds) do
	currentTransmogIds[k] = v
end


local currentSlotItemIds = nil -- hold ids and icon paths
local currentPage = 1
local morePages = false
local itemButtons = {}
local currentTooltipSlot = nil
local isInputHovered = false


-- TODO Add spam preventing measures

function SetItemButtonTexture(button, texture)
	if ( not button ) then
		return;
	end

	if (button.Icon or button.icon or (button:GetName() ~= nil and _G[button:GetName()] ~= nil and _G[button:GetName().."IconTexture"] ~= nil)) then
		local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
		if ( texture ) then
			icon:Show();
			_G[button:GetName().."IconTexture"]:SetTexture(texture);
		else
			icon:Hide();
		end
	end
end

function TransmogHandlers.SetEquipmentTransmogInfoClient(player, tooltipSlot)
	if ( currentTooltipSlot == tooltipSlot ) then
		GameTooltip:AddLine("Item is transmogrified!", 1, 0, 0)
	end
end

GameTooltip:HookScript("OnTooltipCleared", function(tooltip, ...)
	currentTooltipSlot = nil
end)

GameTooltip:HookScript("OnTooltipSetItem", function(tooltip, ...)
	local name, link = tooltip:GetItem()
	local ownerFrame, anchor = tooltip:GetOwner()
	local slotName = ownerFrame:GetName()
	if ( currentTooltipSlot == slotName ) then
		return;
	end
	currentTooltipSlot = slotName
	if ( EQUIPMENT_SLOT_FRAME_NAMES[slotName] ) then
		--if ( not name ) then 
			--GameTooltip:SetHyperlink("item:"..itemId..":0:0:0:0:0:0:0")
		--end
		if ( not tooltip:IsEquippedItem() ) then
			tooltip:AddLine(" ")
			tooltip:AddLine("This item is a transmog and purely cosmetic!", 1, 0, 0)
			return;
		end
		
        -- TODO remove Character and Slot from string slotName to search slot id in table
		if ( slotId ) then
            -- TODO just search db for item in accoumt_transmog
			--AIO.Handle("Transmog", "SetEquipmentTransmogInfo", slotId, currentTooltipSlot) TODO This will only work with cached slots?? Inf loop when trying to call server and back
		end
		return;
	end
	tooltip:Show()
end)

function UpdateSlotTexture(slotName, isTransmogFrame)
    local slotFrame
	if isTransmogFrame then
		slotFrame = _G["TransmogCharacter" .. slotName .. "Slot"]
	else
		slotFrame = _G["Character" .. slotName .. "Slot"]
	end
	local transmogId = currentTransmogIds[slotName]
	if ( transmogId ~= nil and transmogId ~= 0 ) then
		SetItemButtonTexture(slotFrame, GetItemIcon(transmogId))
	elseif ( transmogId == 0 ) then
		SetItemButtonTexture(slotFrame, EMPTY_TEXTURE)
	end
end

function UpdateAllSlotTextures()
    for slotName, _ in pairs(SLOT_IDS) do
        PaperDollItemSlotButton_Update(_G["Character" .. slotName .. "Slot"])
		TransmogItemSlotButton_Update(_G["TransmogCharacter" .. slotName .. "Slot"])
    end
end

function LoadTransmogsFromCurrentIds()
    TransmogModelFrame:SetUnit("player")
    TransmogModelFrame:Undress()
    
    for slotName, transmogId in pairs(currentTransmogIds) do
        if transmogId and slotName ~= "MainHand" and slotName ~= "SecondaryHand" and slotName ~= "Ranged" then
            TransmogModelFrame:TryOn(transmogId)
        end
    end
    
    UpdateAllSlotTextures()
end

local function OnClickItemTransmogButton(btn, buttonType)
	PlaySound("igMainMenuOptionCheckBoxOn", "sfx")
	LoadTransmogsFromCurrentIds()
	local itemId = btn:GetID()
	local textureName = GetItemIcon(itemId)
	local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
	currentTransmogIds[slotName] = itemId
	TransmogModelFrame:TryOn(itemId)
	UpdateAllSlotTextures()
    --SetItemButtonTexture(_G["Character" .. slotName .. "Slot"], textureName)
end

function OnClickHideAllButton(btn)
	PlaySound("Glyph_MinorDestroy", "sfx")
    for slotName, _ in pairs(SLOT_IDS) do
        currentTransmogIds[slotName] = 0
    end
	TransmogModelFrame:SetUnit("player")
	TransmogModelFrame:Undress()
    UpdateAllSlotTextures()
end

function OnClickRestoreAllButton(btn)
	PlaySound("Glyph_MajorCreate", "sfx")
    for slotName, slotId in pairs(SLOT_IDS) do
        currentTransmogIds[slotName] = nil
		originalTransmogIds[slotName] = nil
		AIO.Handle("Transmog", "EquipTransmogItem", nil, slotId)
    end
    LoadTransmogsFromCurrentIds()
	TransmogModelFrame:SetUnit("player")
	TransmogModelFrame:Undress()
end

function OnLeaveHideToolTip(btn)
	GameTooltip:Hide()
end

local function OnEnterItemToolTip(btn)
	local itemId = btn:GetID()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:"..itemId..":0:0:0:0:0:0:0")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Click to preview this item.", 0, 1, 0)
	GameTooltip:Show()
end

function TransmogrifyToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Transmogrify", 1, 1, 1)
	GameTooltip:Show()
end

function RestoreItemToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Restore Item Appearance", 1, 1, 1)
	GameTooltip:Show()
end

function HideItemToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Hide Item", 1, 1, 1)
	GameTooltip:Show()
end

function RestoreAllItemsToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Restore All Item Appearances", 1, 1, 1)
	GameTooltip:Show()
end

function HideAllItemsToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Hide All Items", 1, 1, 1)
	GameTooltip:Show()
end

function ShowCloakToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Toggle Character Cloak Display", 1, 1, 1)
	GameTooltip:AddLine("This checkbox provides the same function as", 1, 0.8, 0)
	GameTooltip:AddLine("ticking or unticking the \"Show Cloak\" checkbox", 1, 0.8, 0)
	GameTooltip:AddLine("in the interface options menu. It will have no", 1, 0.8, 0)
	GameTooltip:AddLine("effect on the transmogrify preview window.", 1, 0.8, 0)
	GameTooltip:Show()
end

function ShowHelmToolTip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Toggle Character Helm Display", 1, 1, 1)
	GameTooltip:AddLine("This checkbox provides the same function as", 1, 0.8, 0)
	GameTooltip:AddLine("ticking or unticking the \"Show Helm\" checkbox", 1, 0.8, 0)
	GameTooltip:AddLine("in the interface options menu. It will have no", 1, 0.8, 0)
	GameTooltip:AddLine("effect on the transmogrify preview window.", 1, 0.8, 0)
	GameTooltip:Show()
end

local function InitTabSlots()
	local lastSlot
	local firstInRowSlot
	for i = 1, 6, 1 do
		local itemChild
		if ( i == 1 ) then
			itemChild = CreateFrame("Frame", "ItemChild"..i, TransmogFrame, "TransmogItemWrapperTemplate") 
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
		itemButton:SetScript("OnClick", OnClickItemTransmogButton)
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

function OnClickNextPage(btn)
	PlaySound("igAbiliityPageTurn", "sfx")
	currentPage = currentPage + 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

function OnClickPrevPage(btn)
	PlaySound("igAbiliityPageTurn", "sfx")
	if ( currentPage == 1 ) then
		return;
	end
	currentPage = currentPage - 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

-- function PaperDollItemSlotButton_Update(self)
-- 	for slotName, _ in pairs(SLOT_IDS) do
--         UpdateSlotTexture(slotName, false)
--     end

-- 	local textureName = GetInventoryItemTexture("player", self:GetID());
-- 	local cooldown = _G[self:GetName().."Cooldown"];
-- 	if ( textureName ) then
-- 		SetItemButtonTexture(self, textureName);
-- 		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
-- 		if ( GetInventoryItemBroken("player", self:GetID()) ) then
-- 			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
-- 			SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
-- 		else
-- 			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 			SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 		end
-- 		if ( cooldown ) then
-- 			local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
-- 			CooldownFrame_SetTimer(cooldown, start, duration, enable);
-- 		end
-- 		self.hasItem = 1;
-- 	else
-- 		local textureName = self.backgroundTextureName;
-- 		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
-- 			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
-- 		end
-- 		SetItemButtonTexture(self, textureName);
-- 		SetItemButtonCount(self, 0);
-- 		SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 		SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 		if ( cooldown ) then
-- 			cooldown:Hide();
-- 		end
-- 		self.hasItem = nil;
-- 	end
	
-- 	if ( not GearManagerDialog:IsShown() ) then
-- 		self.ignored = nil;
-- 	end
	
-- 	if ( self.ignored and self.ignoreTexture ) then
-- 		self.ignoreTexture:Show();
-- 	elseif ( self.ignoreTexture ) then
-- 		self.ignoreTexture:Hide();
-- 	end

-- 	PaperDollItemSlotButton_UpdateLock(self);

-- 	-- Update repair all button status
-- 	MerchantFrame_UpdateGuildBankRepair();
-- 	MerchantFrame_UpdateCanRepairAll();
-- end

function TransmogItemSlotButton_Update(self)
	local textureName = GetInventoryItemTexture("player", self:GetID());
	if ( textureName ) then
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
		if ( GetInventoryItemBroken("player", self:GetID()) ) then
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		end
		self.hasItem = 1;
	else
		local textureName = self.backgroundTextureName;
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, 0);
		SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		self.hasItem = nil;
	end

	for slotName, _ in pairs(SLOT_IDS) do
        UpdateSlotTexture(slotName, true)
    end

	PaperDollItemSlotButton_UpdateLock(self);
end

function OnClickHideCurrentTransmogSlot(btn)
	PlaySound("ArcaneMissileImpacts", "sfx")
    local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
    currentTransmogIds[slotName] = 0
    UpdateSlotTexture(slotName, false)
	UpdateSlotTexture(slotName, true)
	AIO.Handle("Transmog", "EquipTransmogItem", 0, currentSlot)
	originalTransmogIds[slotName] = transmogId
    LoadTransmogsFromCurrentIds()
end

-- Why restore only working without the transmog 0 applied? Why transmog 0?!
function OnClickRestoreCurrentTransmogSlot(btn)
	PlaySound("Glyph_MinorCreate", "sfx")
    local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
    currentTransmogIds[slotName] = nil
    originalTransmogIds[slotName] = nil
    AIO.Handle("Transmog", "EquipTransmogItem", nil, currentSlot)
    LoadTransmogsFromCurrentIds()
end

function TransmogHandlers.LoadTransmogsAfterSave(player)
	LoadTransmogsFromCurrentIds()
end

-- language support
-- fallback = enUS
local CLIENT_FALLBACK_LANG = 0
local LANG_ID_TABLE = {
    ["enUS"] = 0,
    ["deDE"] = 3,
}

local function HandleLocale()
    local langId = LANG_ID_TABLE[GetLocale()]
    if not langId then
        langId = CLIENT_FALLBACK_LANG
    end

    return langId
end

function TransmogHandlers.GetLocale(player, item, count)
    AIO.Handle("Transmog", "LootItemLocale", item, count, HandleLocale())
end

function OnClickApplyAllowTransmogs(btn)
	PlaySound("Distract Impact", "sfx")
    for slotName, entryId in pairs(SLOT_IDS) do
        local transmogId = currentTransmogIds[slotName]
        AIO.Handle("Transmog", "EquipTransmogItem", transmogId, entryId)
        originalTransmogIds[slotName] = transmogId
    end
    LoadTransmogsFromCurrentIds()
end

local function TransmogTabTooltip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Transmogrify", 1, 1, 1)
	GameTooltip:Show()
end

function TransmogHandlers.InitTab(player, newSlotItemIds, page, hasMorePages)
	currentSlotItemIds = newSlotItemIds
	TransmogPaginationText:SetText("Page "..page)
	
	if ( hasMorePages ) then
		RightButton:Enable()
	else
		RightButton:Disable()
	end
	
	if ( page > 1 ) then
		LeftButton:Enable()
	else
		LeftButton:Disable()
	end

	for i, child in ipairs(itemButtons) do
		if ( currentSlotItemIds[i] == nil ) then
			child:SetID(0)
			child.itemButton:SetID(0)
			child.itemButton:Disable()
			child.itemModel:Hide()
		    SetItemButtonTexture(child.itemButton, EMPTY_EQUIPMENT_ICON_BACKGROUND_PATH..EQUIPMENT_ICON_TYPES[Transmog_CalculateSlotReverse(currentSlot)])
		else
			child:SetID(currentSlotItemIds[i])
			child.itemButton:SetID(currentSlotItemIds[i])
			local textureName = GetItemIcon(currentSlotItemIds[i])
			SetItemButtonTexture(child.itemButton, textureName)
			child.itemButton:Enable()
			child.itemModel:Show()
			child.itemModel:SetUnit("player")
			if ( currentSlot == PLAYER_VISIBLE_ITEM_15_ENTRYID ) then
				child.itemModel:SetRotation(180, false)
			else
				child.itemModel:SetRotation(0, false)
			end
			child.itemModel:Undress()
			child.itemModel:TryOn(currentSlotItemIds[i])
			child.itemModel:SetPoint("CENTER", 0, -15)

			-- TODO Camera? currently not usable because of lacking ultrawide support
			--if currentSlot == PLAYER_VISIBLE_ITEM_1_ENTRYID then
				--child.itemModel:SetPoint("CENTER", 0, 0)
				--child.itemModel:SetCamera(0)
			--else
				--child.itemModel:SetPoint("CENTER", 0, -15)
				--child.itemModel:SetCamera(1)
				--child.itemModel:SetViewTranslation(0.2, 0.2)
				--child.itemModel:Show()
			--end
		end
	end
end

function SetSearchTab()
	PlaySound("igSpellBookSpellIconPickup", "sfx")
	currentPage = 1
	TransmogPaginationText:SetText("Page 1")
	AIO.Handle("Transmog", "SetSearchCurrentSlotItemIds", currentSlot, currentPage, ItemSearchInput:GetText())
	ItemSearchInput:ClearFocus()
end

function SetTab()
	if ( ItemSearchInput:GetText() ~= "" and ItemSearchInput:GetText() ~= "|cff808080Filter Item Appearance|r") then
		SetSearchTab()
		return;
	end
	PlaySound("igSpellBookSpellIconPickup", "sfx")
	currentPage = 1
	TransmogPaginationText:SetText("Page 1")
	for slot, value in pairs(SLOT_IDS) do
		_G["TransmogCharacter"..slot.."Slot"].toastTexture:SetTexture("Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Overlay-Toast")
		_G["TransmogCharacter"..slot.."Slot"].restoreButton:Hide()
		_G["TransmogCharacter"..slot.."Slot"].hideButton:Hide()
	end
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].toastTexture:SetTexture("Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Overlay-Selected")
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].restoreButton:Show()
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].hideButton:Show()
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

function TransmogHandlers.SetTransmogItemIdClient(player, slot, id, realItemId)
    -- Get the transmog part name based on the slot
    local part = TRANSMOG_SLOT_MAPPING[tonumber(slot)]
    if part then
        -- If the part is found, use the current and original transmog tables
        local currentTransmogId = currentTransmogIds[part]
        local originalTransmogId = originalTransmogIds[part]
        
        if (id ~= 0 and id ~= nil and (currentTransmogId == nil or currentTransmogId == 0) and realItemId ~= id) then
            currentTransmogIds[part] = id
            originalTransmogIds[part] = id
		if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
			TransmogModelFrame:TryOn(id)
		end
        elseif (currentTransmogId ~= nil and currentTransmogId ~= 0) then
			if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
				TransmogModelFrame:TryOn(currentTransmogId)
			end
        elseif (id ~= 0 and realItemId ~= 0 and realItemId ~= nil) then
            currentTransmogIds[part] = realItemId
            originalTransmogIds[part] = realItemId
			if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
				TransmogModelFrame:TryOn(realItemId)
			end
        end
    end

    -- Restore all slot textures
    UpdateAllSlotTextures()
end

function OnClickHeadTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
end

function OnClickShoulderTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_3_ENTRYID
    SetTab()
end

function OnClickShirtTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_4_ENTRYID
    SetTab()
end

function OnClickChestTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_5_ENTRYID
    SetTab()
end

function OnClickWaistTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_6_ENTRYID
    SetTab()
end

function OnClickLegsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_7_ENTRYID
    SetTab()
end

function OnClickFeetTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_8_ENTRYID
    SetTab()
end

function OnClickWristTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_9_ENTRYID
    SetTab()
end

function OnClickHandsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_10_ENTRYID
    SetTab()
end

function OnClickBackTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_15_ENTRYID
    SetTab()
end

function OnClickMainTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_16_ENTRYID
    SetTab()
end

function OnClickOffTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_17_ENTRYID
    SetTab()
end

function OnClickRangedTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_18_ENTRYID
    SetTab()
end

function OnClickTabardTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_19_ENTRYID
    SetTab()
end

local function OnEventEnterWorldReloadTransmogIds(self, event)
	if ( event == "PLAYER_ENTERING_WORLD") then
		AIO.Handle("Transmog", "SetTransmogItemIds")
	else
		AIO.Handle("Transmog", "OnUnequipItem")
		UpdateAllSlotTextures()
		if ( TransmogFrame:IsShown() ) then
			LoadTransmogsFromCurrentIds()
		end
	end
end

function TransmogItemSlotButton_OnEnter(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local slotName = self:GetName():gsub("Transmog", ""):gsub("Character", ""):gsub("Slot", "")
	local transmogId = currentTransmogIds[slotName] or originalTransmogIds[slotName]
	if transmogId then
		GameTooltip:SetHyperlink("item:"..transmogId..":0:0:0:0:0:0:0")
		--GameTooltip_ClearMoney(GameTooltip)
		--GameTooltip_ClearStatusBars(GameTooltip)
		--GameTooltip:Show()
		CursorUpdate(self)
		return
	end
	GameTooltip:SetInventoryItem("player", self:GetID())
	CursorUpdate(self)
end

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
	--itemSlotButtons[id] = self;
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

function TransmogModelMouseRotation(modelFrame)
	local rotationArea = CreateFrame("Frame", modelFrame:GetName().."RotationArea", modelFrame)
	rotationArea:SetSize(160, 280)
	rotationArea:SetPoint("CENTER", 0, 0)
	
	-- Highlight the rotation area for development
	-- local texture = rotationArea:CreateTexture(nil, "OVERLAY")
	-- texture:SetAllPoints()
	-- texture:SetTexture(1, 0, 0, 0.3)
	
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
					-- Controls mouse rotation speed
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

function OnTransmogFrameLoad(self)
	ItemSearchInput:SetText("|cff808080Filter Item Appearance|r")
	ItemSearchInput:SetScript("OnEnterPressed", SetSearchTab)
	
	InitTabSlots()
	
	characterTransmogTab = CreateFrame("CheckButton", "CharacterFrameTab6", CharacterFrame, "SpellBookSkillLineTabTemplate")
	characterTransmogTab:SetSize(32, 32);
	characterTransmogTab:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", 0, -48)
	characterTransmogTab:Show()
	innerCharacterTransmogTab = characterTransmogTab:CreateTexture("Item", "ARTWORK")
	innerCharacterTransmogTab:SetTexture("Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Icon")
	innerCharacterTransmogTab:SetAllPoints()
	innerCharacterTransmogTab:Show()
	characterTransmogTab:SetScript("OnEnter", TransmogTabTooltip)
	characterTransmogTab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	characterTransmogTab:SetScript("OnClick", function(self) if ( TransmogFrame:IsShown() ) then TransmogFrame:Hide() return; end TransmogFrame:Show() end)
	TransmogCloseButton:SetScript("OnClick", function(self) if ( TransmogFrame:IsShown() ) then TransmogFrame:Hide() return; end TransmogFrame:Show() end)

	PaperDollFrame:SetScript("OnShow", PaperDollFrame_OnShow)
	InitializeCloakHelmCheckboxes()
	
	-- This enables saving of the position of the frame over reload of the UI or restarting game
	AIO.SavePosition(TransmogFrame)
	TransmogFrame:RegisterForDrag("LeftButton");

	_G["TransmogFrame"] = TransmogFrame
	tinsert(UISpecialFrames, TransmogFrame:GetName())
	TransmogFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TransmogFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	TransmogFrame:SetScript("OnEvent", OnEventEnterWorldReloadTransmogIds)

	SetItemButtonTexture(_G["SaveButton"], "Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Icon")

	TransmogModelMouseRotation(TransmogModelFrame)

	UpdateAllSlotTextures()
end

function OnClickTransmogButton(self)
	PlaySound("AchievementMenuOpen", "sfx")
	for slot, _ in pairs(SLOT_IDS) do
		currentTransmogIds[slot] = originalTransmogIds[slot]
	end
	TransmogModelFrame:SetUnit("player")
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
	characterTransmogTab:SetChecked(true)
	isInputHovered = false
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, 1)
	ItemSearchInput:SetText("|cff808080Filter Item Appearance|r")
	LoadTransmogsFromCurrentIds()
	ShowCloakCheckBox:SetChecked(ShowingCloak())
	ShowHelmCheckBox:SetChecked(ShowingHelm())
end

function OnHideTransmogFrame(self)
	PlaySound("AchievementMenuClose", "sfx")
	for slot, _ in pairs(SLOT_IDS) do
		currentTransmogIds[slot] = originalTransmogIds[slot]
	end
	UpdateAllSlotTextures()
	characterTransmogTab:SetChecked(false)
end

function PaperDollFrame_OnShow(self)
	--PaperDollFrame_SetGuild();
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
	
	-- custom code
	if ( TransmogFrame:IsShown() ) then
		characterTransmogTab:SetChecked(true)
		else
		characterTransmogTab:SetChecked(false)
	end

	LoadTransmogsFromCurrentIds()
	-- end custom code
end
