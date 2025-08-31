local L = LibStub("AceLocale-3.0"):NewLocale("Transmogrification", "ruRU")
if not L then return end

-- Transmogrification Window
L["Transmogrification"] = "Трансмогрификация"
L["Transmogrify"] = "Трансмогрификация"
L["Apply Transmogrification"] = "Применить трансмогрификацию"
L["Open Transmogrification Interface"] = "Открыть окно трансмогрификации"
L["Collected Item Appearances"] = "Собранные облики предметов"
L["Filter Item Appearance"] = "Фильтр обликов"
L["No item equipped in this slot."] = "Нет предмета в этом слоте."
L["Page %s"] = "Страница %s"
L["Show Cloak"] = "Показать плащ"
L["Show Helm"] = "Показать шлем"
L["You must have an item equipped in this slot to hide its appearance."] = "Необходимо надеть предмет в этот слот, чтобы скрыть его внешний вид."
L["You must have an item equipped in this slot to restore its appearance."] = "Необходимо надеть предмет в этот слот, чтобы восстановить его внешний вид."

-- AddOn Functionality
L["You must "] = "Вы должны "
L["/reload"] = "/reload"
L[" the interface for this change to take effect."] = " интерфейс, чтобы изменения вступили в силу."
L["Querying the server for collected transmogrification appearances..."] = "Запрос к серверу для получения собранных обликов..."
L["No transmogrification appearances could be located for this account. If you believe this is an error, please contact a Game Master."] = "Не удалось найти облики трансмогрификации для этого аккаунта. Если вы считаете, что это ошибка, обратитесь к Администратору игры."
L["Your transmogrification appearance collection has been successfully synchronized!"] = "Ваша коллекция обликов успешно синхронизирована!"
L["You have collected "] = "Вы собрали "
L[" transmogrification appearances."] = " обликов трансмогрификации."
L["It is recommended that you "] = "Рекомендуется "
L[" your interface to finalize any changes, otherwise the "] = " интерфейс для завершения изменений, иначе "
L[" tooltip line may not function correctly."] = " строка подсказки может работать некорректно."
L["Would you like to reload the interface?"] = "Хотите перезагрузить интерфейс?"
L["Yes"] = "Да"
L["No"] = "Нет"

-- Tooltip Text
L["New Appearance"] = "Новый облик"
L["Click to preview this item."] = "Нажмите, чтобы просмотреть этот предмет."
L["Hidden Appearance"] = "Скрытый облик"
L["Restore Item Appearance"] = "Восстановить облик предмета"
L["Hide Item"] = "Скрыть предмет"
L["Restore All Item Appearances"] = "Восстановить все облики"
L["Hide All Items"] = "Скрыть все предметы"
L["Toggle Character Cloak Display"] = "Переключить отображение плаща"
L["This checkbox provides the same function as\nticking or unticking the \"Show Cloak\" checkbox\nin the interface options menu. It will have no\neffect on the transmogrify preview window."] = "Этот флажок выполняет ту же функцию, что и\nфлажок \"Показать плащ\" в меню настроек\nинтерфейса. Он не влияет на окно\nпредварительного просмотра трансмогрификации."
L["Toggle Character Helm Display"] = "Переключить отображение шлема"
L["This checkbox provides the same function as\nticking or unticking the \"Show Helm\" checkbox\nin the interface options menu. It will have no\neffect on the transmogrify preview window."] = "Этот флажок выполняет ту же функцию, что и\nфлажок \"Показать шлем\" в меню настроек\nинтерфейса. Он не влияет на окно\nпредварительного просмотра трансмогрификации."
L["No appearances to apply."] = "Нет обликов для применения."

-- Text (Hexadecimal) Colors
L["00ccff"] = true -- Highlighted Text
L["f194f7"] = true -- New Appearance Tooltip
L["00ff00"] = true -- Preview Item
L["b2b2b2"] = true -- Search Filter Prompt
L["ff4040"] = true -- No Item Equipped Warning

-- Transmogrification Window Options
L["Transmogrification Window Options"] = "Настройки окна трансмогрификации"
L["Transmogrification Window Scale"] = "Масштаб окна трансмогрификации"
L["Determines the scale of the Transmogrification window."] = "Определяет масштаб окна трансмогрификации."
L["Transmogrification Window Opacity"] = "Прозрачность окна трансмогрификации"
L["Determines the opacity of the Transmogrification window."] = "Определяет прозрачность окна трансмогрификации."
L["Transmogrification Window Lock"] = "Блокировка окна трансмогрификации"
L["Locks the position of the Transmogrification window."] = "Блокирует положение окна трансмогрификации."

-- Display Options
L["Display Options"] = "Настройки отображения"
L["Display New Appearance Tooltip"] = "Показывать подсказку о новом облике"
L["Toggles the display of the "] = "Включает отображение "
L[" tooltip line."] = " строки подсказки."
L["Display Collection Messages"] = "Показывать сообщения о коллекции"
L["Toggles the display of the new appearance system message when collecting a new transmogrification appearance."] = "Включает отображение системного сообщения при получении нового облика трансмогрификации."

-- Collection Management
L["Collection Management"] = "Управление коллекцией"
L["Sync Collection"] = "Синхронизировать коллекцию"
L["Creates a local list of collected transmogrification appearances. The collected transmogrification appearances list is used to display the "] = "Создает локальный список собранных обликов трансмогрификации. Список собранных обликов используется для отображения "
L[" tooltip."] = " подсказки."
L["This button provides the same function as using the "] = "Эта кнопка выполняет ту же функцию, что и команда "
L["/transmog sync"] = "/transmog sync"
L[" command."] = "."

-- The text below MUST match the LOOT_ITEM_LOCALE entry for this language from the server Eluna script, or
-- automatically adding new appearances to the local CollectedAppearances table will not function correctly.
--
-- Do not edit the line below unless you know what you are doing or are translating a language.
L["has been added to your appearance collection."] = true