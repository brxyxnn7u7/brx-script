setDefaultTab("Main")
-- ======================================================
--  ITEM MOVER (3 grupos independientes)
--
--  Switch para prender/apagar + boton Setup con 3 filas.
--  Cada fila tiene SU PROPIO contenedor destino y SU PROPIA
--  lista de items: los items de la fila 1 van a la mochila 1,
--  los de la fila 2 a la mochila 2, etc. Totalmente independientes.
-- ======================================================

local c = storage.itemMover or {}
storage.itemMover = c
c.groups = c.groups or {
  { containerId = 0, items = {} },
  { containerId = 0, items = {} },
  { containerId = 0, items = {} },
}

g_ui.loadUIFromString([[
ItemMoverWin < MainWindow
  text: Item Move
  size: 340 330
  @onEscape: self:hide()

  Label
    id: lblG1
    text: Contenedor 1:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 85

  BotItem
    id: cont1
    anchors.left: lblG1.right
    anchors.top: parent.top
    margin-left: 8
    margin-top: 10

  Label
    id: lblItems1
    text: Items:
    anchors.left: cont1.right
    anchors.top: parent.top
    margin-left: 16
    margin-top: 15
    width: 45

  BotContainer
    id: list1
    anchors.left: lblItems1.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 8
    margin-right: 12
    margin-top: 10

  HorizontalSeparator
    id: sep1
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: cont1.bottom
    margin-top: 50
    margin-left: 12
    margin-right: 12

  Label
    id: lblG2
    text: Contenedor 2:
    anchors.top: sep1.bottom
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 85

  BotItem
    id: cont2
    anchors.left: lblG2.right
    anchors.top: sep1.bottom
    margin-left: 8
    margin-top: 7

  Label
    id: lblItems2
    text: Items:
    anchors.left: cont2.right
    anchors.top: sep1.bottom
    margin-left: 16
    margin-top: 12
    width: 45

  BotContainer
    id: list2
    anchors.left: lblItems2.right
    anchors.right: parent.right
    anchors.top: sep1.bottom
    margin-left: 8
    margin-right: 12
    margin-top: 7

  HorizontalSeparator
    id: sep2
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: cont2.bottom
    margin-top: 50
    margin-left: 12
    margin-right: 12

  Label
    id: lblG3
    text: Contenedor 3:
    anchors.top: sep2.bottom
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 85

  BotItem
    id: cont3
    anchors.left: lblG3.right
    anchors.top: sep2.bottom
    margin-left: 8
    margin-top: 7

  Label
    id: lblItems3
    text: Items:
    anchors.left: cont3.right
    anchors.top: sep2.bottom
    margin-left: 16
    margin-top: 12
    width: 45

  BotContainer
    id: list3
    anchors.left: lblItems3.right
    anchors.right: parent.right
    anchors.top: sep2.bottom
    margin-left: 8
    margin-right: 12
    margin-top: 7

  Button
    id: closeButton
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-right: 12
    margin-bottom: 1
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
    text: Item Move
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("ItemMoverWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

-- referencias a los widgets de cada fila, para no repetir codigo
local rows = {
  { containerWidget = win.cont1, listWidget = win.list1 },
  { containerWidget = win.cont2, listWidget = win.list2 },
  { containerWidget = win.cont3, listWidget = win.list3 },
}

local itemContainers = {}

for i, row in ipairs(rows) do
  row.containerWidget:setItemId(c.groups[i].containerId)
  row.containerWidget.onItemChange = function(w)
    c.groups[i].containerId = w:getItemId()
  end

  local ic = UI.Container(function(w, items)
    c.groups[i].items = items
  end, true, nil, row.listWidget)
  ic:setItems(c.groups[i].items)
  itemContainers[i] = ic
end

win.closeButton.onClick = function()
  win:hide()
end

ui.setup.onClick = function()
  for i, row in ipairs(rows) do
    row.containerWidget:setItemId(c.groups[i].containerId)
    itemContainers[i]:setItems(c.groups[i].items)
  end
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

local function getTargetContainer(containerId)
  if not containerId or containerId < 100 then
    return nil
  end
  for _, container in pairs(g_game.getContainers()) do
    local containerItem = container:getContainerItem()
    if containerItem and containerItem:getId() == containerId then
      return container
    end
  end
  return nil
end

local function hasItemId(items, itemId)
  for _, entry in ipairs(items) do
    local id = type(entry) == "table" and entry.id or entry
    if id == itemId then
      return true
    end
  end
  return false
end

macro(100, function()
  local cfg = storage.itemMover
  if not cfg or not cfg.enabled then return end

  for _, group in ipairs(cfg.groups) do
    if group.containerId and group.containerId >= 100 and group.items and #group.items > 0 then
      local targetContainer = getTargetContainer(group.containerId)
      if targetContainer then
        for _, container in pairs(g_game.getContainers()) do
          if container ~= targetContainer then
            for _, item in ipairs(container:getItems()) do
              if hasItemId(group.items, item:getId()) then
                local slot = targetContainer:getItemsCount()
                g_game.move(item, targetContainer:getSlotPosition(slot), item:getCount())
                return -- una accion por tick
              end
            end
          end
        end
      end
    end
  end
end)