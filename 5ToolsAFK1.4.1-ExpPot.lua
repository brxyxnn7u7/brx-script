setDefaultTab("Tools")
-- ======================================================
--  EXP POTION
--
--  Switch para prender/apagar + boton Setup donde eliges
--  las pociones de exp a usar (se usan todas en secuencia,
--  con 250ms entre cada una) y cada cuantos minutos repetir.
-- ======================================================

local c = storage.expPotion or {}
storage.expPotion = c
c.items = c.items or {7443, 7440}
c.waitMinutes = c.waitMinutes or 31

g_ui.loadUIFromString([[
ExpPotionWin < MainWindow
  text: Exp Potion
  size: 300 175
  @onEscape: self:hide()

  Label
    id: lblWait
    text: Esperar (min):
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 85

  TextEdit
    id: waitEdit
    anchors.left: lblWait.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 8
    margin-right: 12
    margin-top: 10
    height: 21

  Label
    id: lblItems
    text: Pociones:
    anchors.left: lblWait.left
    anchors.top: lblWait.bottom
    margin-top: 14
    width: 85

  BotContainer
    id: list
    anchors.left: lblItems.right
    anchors.right: parent.right
    anchors.top: waitEdit.bottom
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
    text: Exp Potion
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("ExpPotionWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

win.waitEdit:setText(tostring(c.waitMinutes))
win.waitEdit.onTextChange = function(w, text) c.waitMinutes = tonumber(text) or c.waitMinutes end

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
  win.waitEdit:setText(tostring(c.waitMinutes))
  itemContainer:setItems(c.items)
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

macro(100, function()
  local c = storage.expPotion
  if not c or not c.enabled or not c.items or #c.items == 0 then return end

  local time = 0
  for i = 1, #c.items do
    local entry = c.items[i]
    local itemId = type(entry) == "table" and entry.id or entry
    schedule(time, function()
      g_game.useInventoryItem(itemId)
    end)
    time = time + 250
  end

  local waitMinutes = tonumber(c.waitMinutes) or 0
  delay(waitMinutes * 60 * 1000)
end)