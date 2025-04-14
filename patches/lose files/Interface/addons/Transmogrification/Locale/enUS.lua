local L = LibStub("AceLocale-3.0"):NewLocale("Transmogrification", "enUS", true)

-- Transmogrification Window
L["Transmogrify"] = true
L["Collected Item Appearances"] = true
L["Filter Item Appearance"] = true
L["No item equipped in this slot."] = true
L["Page %s"] = true
L["Show Cloak"] = true
L["Show Helm"] = true
L["You must have an item equipped in this slot to hide its appearance."] = true
L["You must have an item equipped in this slot to restore its appearance."] = true

-- AddOn Functionality
L["You must "] = true
L["/reload"] = true
L[" the interface for this change to take effect."] = true
L["Querying the server for collected transmogrification appearances..."] = true
L["No transmogrification appearances could be located for this account. If you believe this is an error, please contact a Game Master."] = true
L["Your transmogrification appearance collection has been successfully synchronized!"] = true
L["You have collected "] = true
L[" transmogrification appearances."] = true
L["It is recommended that you "] = true
L[" your interface to finalize any changes, otherwise the "] = true
L[" tooltip line may not function correctly."] = true
L["Would you like to reload the interface?"] = true
L["Yes"] = true
L["No"] = true

-- Tooltip Text
L["New Appearance"] = true
L["Click to preview this item."] = true
L["Hidden Appearance"] = true
L["Restore Item Appearance"] = true
L["Hide Item"] = true
L["Restore All Item Appearances"] = true
L["Hide All Items"] = true
L["Toggle Character Cloak Display"] = true
L["This checkbox provides the same function as\nticking or unticking the \"Show Cloak\" checkbox\nin the interface options menu. It will have no\neffect on the transmogrify preview window."] = true
L["Toggle Character Helm Display"] = true
L["This checkbox provides the same function as\nticking or unticking the \"Show Helm\" checkbox\nin the interface options menu. It will have no\neffect on the transmogrify preview window."] = true
L["No appearances to apply."] = true

-- Text (Hexadecimal) Colors
L["00ccff"] = true -- Highlighted Text
L["f194f7"] = true -- New Appearance Tooltip
L["00ff00"] = true -- Preview Item
L["b2b2b2"] = true -- Search Filter Prompt
L["ff4040"] = true -- No Item Equipped Warning

-- Transmogrification Window Options
L["Transmogrification Window Options"] = true
L["Transmogrification Window Scale"] = true
L["Determines the scale of the Transmogrification window."] = true
L["Transmogrification Window Opacity"] = true
L["Determines the opacity of the Transmogrification window."] = true
L["Transmogrification Window Lock"] = true
L["Locks the position of the Transmogrification window."] = true

-- Display Options
L["Display Options"] = true
L["Display New Appearance Tooltip"] = true
L["Toggles the display of the "] = true
L[" tooltip line."] = true
L["Display Collection Messages"] = true
L["Toggles the display of the new appearance system message when collecting a new transmogrification appearance."] = true

-- Collection Management
L["Collection Management"] = true
L["Sync Collection"] = true
L["Creates a local list of collected transmogrification appearances. The collected transmogrification appearances list is used to display the "] = true
L[" tooltip."] = true
L["This button provides the same function as using the "] = true
L["/transmog sync"] = true
L[" command."] = true

-- The text below MUST match the LOOT_ITEM_LOCALE entry for this language from the server Eluna script, or
-- automatically adding new appearances to the local CollectedAppearances table will not function correctly.
--
-- Do not edit the line below unless you know what you are doing or are translating a language.
L["has been added to your appearance collection."] = true