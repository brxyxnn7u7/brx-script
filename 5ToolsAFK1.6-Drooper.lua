setDefaultTab("Tools")
-- ======================================================
--  ITEM DROPPER
--
--  En el Setup agregas items y les pones un numero (el campo
--  de cantidad del contenedor) que funciona como UMBRAL: cuando
--  tengas esa cantidad o mas de ese item, lo tira al piso.
--
--  Ejemplo: agregas "worm" con count=100 -> cuando tengas 100
--  worms (un stack lleno), los tira automaticamente.
-- ======================================================

local c = storage.itemDropper or {}
storage.itemDropper = c
c.items = c.items or {}

g_ui.loadUIFromString([[
DropperWin < MainWindow
  text: Item Dropper
  size: 320 175
  @onEscape: self:hide()

  Label
    id: lblHelp
    text: Cantidad = a partir de cuantos lo tira
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 4
    text-align: center
    font: verdana-11px-rounded

  BotContainer
    id: list
    anchors.top: lblHelp.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: clr.top
    margin-top: 6
    margin-bottom: 6

  Button
    id: clr
    text: Clear
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    size: 60 22

  Button
    id: cls
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 22
]])

local ui = setupUI([[
Panel
  height: 20
  BotSwitch
    id: sw
    anchors.left: parent.left
    anchors.top: parent.top
    width: 130
    text: Item Dropper
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("DropperWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

local itemList = UI.Container(function(w, i) c.items = i end, true, nil, win.list)
itemList:setItems(c.items)

win.clr.onClick = function()
  c.items = {}
  itemList:setItems(c.items)
end

win.cls.onClick = function()
  win:hide()
end

ui.setup.onClick = function()
  itemList:setItems(c.items)
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

macro(200, function()
  local c = storage.itemDropper
  if not c or not c.enabled or not c.items or #c.items == 0 then return end

  for _, entry in ipairs(c.items) do
    local id = type(entry) == "table" and entry.id or entry
    local threshold = type(entry) == "table" and entry.count or 0

    if id and threshold and threshold > 0 then
      local item = findItem(id)
      if item and item:getCount() >= threshold then
        g_game.move(item, pos(), item:getCount())
        return -- una accion por tick, para no floodear
      end
    end
  end
end)