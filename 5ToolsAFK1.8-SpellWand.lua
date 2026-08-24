setDefaultTab("Tools")
-- ======================================================
--  AUTO SELL ITEMS
--
--  Switch para prender/apagar + boton Setup donde eliges el
--  item/wand que se usa para vender, la cantidad minima para
--  evitar spam, y la lista de items a vender.
-- ======================================================

local c = storage.venderConfig or {}
storage.venderConfig = c
c.items = c.items or {3366, 3281}
c.wandId = c.wandId or 651
c.minCount = c.minCount or 2

g_ui.loadUIFromString([[
VenderWin < MainWindow
  text: Auto Sell Items
  size: 320 195
  @onEscape: self:hide()

  Label
    id: lblWand
    text: Vender con:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 70

  BotItem
    id: wand
    anchors.left: lblWand.right
    anchors.top: parent.top
    margin-left: 8
    margin-top: 10

  Label
    id: lblMinCount
    text: Cantidad minima:
    anchors.left: wand.right
    anchors.top: parent.top
    margin-left: 20
    margin-top: 15
    width: 85

  TextEdit
    id: minCountEdit
    anchors.left: lblMinCount.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 8
    margin-right: 12
    margin-top: 10
    height: 21

  Label
    id: lblItems
    text: Items a vender:
    anchors.left: lblWand.left
    anchors.top: wand.bottom
    margin-top: 14
    width: 85

  BotContainer
    id: list
    anchors.left: lblItems.right
    anchors.right: parent.right
    anchors.top: wand.bottom
    anchors.bottom: separator.top
    margin-left: 8
    margin-right: 12
    margin-top: 8
    margin-bottom: 8

  HorizontalSeparator
    id: separator
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: closeButton.top
    margin-bottom: 8

  Button
    id: clearButton
    text: Clear
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    margin-left: 12
    size: 55 21

  Button
    id: closeButton
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-right: 12
    size: 55 21
]])

local ui = setupUI([[
Panel
  height: 20
  BotSwitch
    id: sw
    anchors.left: parent.left
    anchors.top: parent.top
    width: 130
    text: Auto Sell
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("VenderWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

win.wand:setItemId(c.wandId)
win.wand.onItemChange = function(w) c.wandId = w:getItemId() end

win.minCountEdit:setText(tostring(c.minCount))
win.minCountEdit.onTextChange = function(w, text) c.minCount = tonumber(text) or c.minCount end

local itemContainer = UI.Container(function(w, items) c.items = items end, true, nil, win.list)
itemContainer:setItems(c.items)

win.clearButton.onClick = function()
  c.items = {}
  itemContainer:setItems(c.items)
end

win.closeButton.onClick = function()
  win:hide()
end

ui.setup.onClick = function()
  win.wand:setItemId(c.wandId)
  win.minCountEdit:setText(tostring(c.minCount))
  itemContainer:setItems(c.items)
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

macro(50, function()
  local c = storage.venderConfig
  if not c or not c.enabled or not c.items or not c.items[1] then return end

  local minCount = tonumber(c.minCount) or 1
  local itemCounts = {} -- cuenta cuantos hay de cada item

  for _, container in pairs(g_game.getContainers()) do
    for _, item in ipairs(container:getItems()) do
      for _, venderItem in ipairs(c.items) do
        local venderId = type(venderItem) == "table" and venderItem.id or venderItem
        if (not item:isStackable() or (item:isStackable() and item:getCount() == 100))
          and item:getId() == venderId then

          local itemId = item:getId()
          itemCounts[itemId] = (itemCounts[itemId] or 0) + item:getCount()
        end
      end
    end
  end

  -- buscamos el item con mayor cantidad acumulada
  local maxCount = 0
  local itemToSell = nil
  for itemId, count in pairs(itemCounts) do
    if count > maxCount and count >= minCount then
      maxCount = count
      itemToSell = itemId
    end
  end

  if itemToSell then
    for _, container in pairs(g_game.getContainers()) do
      for _, item in ipairs(container:getItems()) do
        if item:getId() == itemToSell then
          return useWith(c.wandId, item)
        end
      end
    end
  end
end)