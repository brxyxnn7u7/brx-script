setDefaultTab("Main")

local panelName = "fastPickItems"

if type(storage[panelName]) ~= "table" then
  storage[panelName] = {
    enabled = false,
    container = 0,
    mincap = 200,
    items = {
      {id = 3031, count = 1},
      {id = 3035, count = 1}
    }
  }
end

local config = storage[panelName]
config.items = config.items or {}
config.container = config.container or 0
config.mincap = config.mincap or 200

g_ui.loadUIFromString([[
FastPickItemsWindow < MainWindow
  text: Fast Pick Items
  size: 390 185
  @onEscape: self:hide()

  Label
    id: lblContainer
    anchors.left: parent.left
    anchors.top: parent.top
    margin-left: 12
    margin-top: 15
    width: 75
    text: Container:
    font: verdana-11px-rounded

  BotItem
    id: containerItem
    anchors.left: lblContainer.right
    anchors.top: parent.top
    margin-left: 8
    margin-top: 10

  Label
    id: lblMinCap
    anchors.left: containerItem.right
    anchors.top: parent.top
    margin-left: 20
    margin-top: 15
    width: 55
    text: Min Cap:
    font: verdana-11px-rounded

  TextEdit
    id: minCapEdit
    anchors.left: lblMinCap.right
    anchors.top: parent.top
    margin-left: 8
    margin-top: 12
    width: 50
    height: 21

  Label
    id: lblItems
    anchors.left: lblContainer.left
    anchors.top: containerItem.bottom
    margin-top: 14
    width: 75
    text: Items:
    font: verdana-11px-rounded

  BotContainer
    id: itemList
    anchors.left: lblItems.right
    anchors.right: parent.right
    anchors.top: containerItem.bottom
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
    font: cipsoftFont

  Button
    id: closeButton
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-right: 12
    size: 55 21
    font: cipsoftFont
]])

local ui = setupUI([[
Panel
  height: 20
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: Fast Pick
    font: verdana-11px-rounded

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
    font: verdana-11px-rounded
]])

ui.title:setOn(config.enabled)

local setupWindow = UI.createWindow("FastPickItemsWindow")
setupWindow:hide()

local itemContainer = UI.Container(function(widget, items)
  config.items = items
end, true, nil, setupWindow.itemList)

itemContainer:setItems(config.items)

setupWindow.containerItem:setItemId(config.container)

setupWindow.containerItem.onItemChange = function(widget)
  config.container = widget:getItemId()
end

setupWindow.minCapEdit:setText(tostring(config.mincap))

setupWindow.minCapEdit.onTextChange = function(widget, text)
  local value = tonumber(text)
  if value then
    config.mincap = value
  end
end

setupWindow.closeButton.onClick = function()
  setupWindow:hide()
end

setupWindow.clearButton.onClick = function()
  config.items = {}
  itemContainer:setItems(config.items)
end

ui.title.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
end

ui.setup.onClick = function()
  setupWindow.containerItem:setItemId(config.container)
  itemContainer:setItems(config.items)
  setupWindow:show()
  setupWindow:raise()
  setupWindow:focus()
end

local function hasFastPickItem(itemId)
  for _, item in ipairs(config.items) do
    local id = type(item) == "table" and item.id or item
    if id == itemId then
      return true
    end
  end
  return false
end

local function getTargetContainer()
  if not config.container or config.container < 100 then
    return nil
  end

  for _, container in pairs(g_game.getContainers()) do
    local containerItem = container:getContainerItem()
    if containerItem and containerItem:getId() == config.container then
      return container
    end
  end

  return nil
end

local function moveFastPickItem(item)
  local count = item:getCount()
  local targetContainer = getTargetContainer()

  if targetContainer then
    local slot = targetContainer:getItemsCount()
    return g_game.move(item, targetContainer:getSlotPosition(slot), count)
  end

  return moveToSlot(item, SlotBack, count)
end

local function findPickItem(tile)
  if not tile then return nil end

  if tile.getItems then
    for _, item in ipairs(tile:getItems()) do
      if item and hasFastPickItem(item:getId()) then
        return item
      end
    end
  end

  local topItem = tile:getTopThing()
  if topItem and hasFastPickItem(topItem:getId()) then
    return topItem
  end

  return nil
end

-- ================== CAMBIOS PARA BUSCAR EN TODA LA PANTALLA ==================

-- Rango de busqueda en tiles (a la redonda de tu personaje). 8 cubre
-- aproximadamente una pantalla completa en zoom normal. Puedes subirlo o
-- bajarlo segun lo que necesites.
local SCAN_RANGE = 8

-- Estado para no recalcular el camino en cada tick si ya estamos yendo
-- hacia el mismo item.
local walkTargetPos = nil
local lastWalkTime = 0
local WALK_RETRY_MS = 1000 -- cada cuanto reintenta el autoWalk hacia el mismo item

local function findClosestPickItem(myPos)
  local allTiles = g_map.getTiles(myPos.z)
  local bestItem, bestTile, bestDistance = nil, nil, math.huge

  for _, tile in ipairs(allTiles) do
    local tp = tile:getPosition()
    if math.abs(tp.x - myPos.x) <= SCAN_RANGE and math.abs(tp.y - myPos.y) <= SCAN_RANGE then
      local item = findPickItem(tile)
      if item then
        local distance = getDistanceBetween(myPos, tp)
        if distance < bestDistance then
          bestItem, bestTile, bestDistance = item, tile, distance
        end
      end
    end
  end

  return bestItem, bestTile, bestDistance
end

macro(100, function()
  if not config.enabled then return end

  if freecap() < config.mincap then
    walkTargetPos = nil
    return
  end

  local myPos = pos()
  local item, tile, distance = findClosestPickItem(myPos)

  if not item then
    walkTargetPos = nil
    return
  end

  -- si ya esta al lado (o encima), lo recogemos directo, igual que antes
  if distance <= 1 then
    walkTargetPos = nil
    moveFastPickItem(item)
    return
  end

  -- si esta mas lejos, caminamos hacia el tile del item
  local tilePos = tile:getPosition()
  local samTarget = walkTargetPos and walkTargetPos.x == tilePos.x and walkTargetPos.y == tilePos.y and walkTargetPos.z == tilePos.z

  if not samTarget or (now - lastWalkTime) > WALK_RETRY_MS then
    autoWalk(tilePos, distance * 2, { ignoreNonPathable = true })
    walkTargetPos = tilePos
    lastWalkTime = now
  end
end)