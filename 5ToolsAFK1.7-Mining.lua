setDefaultTab("Tools")
-- ======================================================
--  MINING
--
--  Switch para prender/apagar + boton Setup donde eliges el
--  pico (o herramienta) a usar y la lista de piedras/items
--  minables sobre los que se va a usar.
-- ======================================================

local c = storage.mining or {}
storage.mining = c
c.stones = c.stones or {}
c.pickId = c.pickId or 3457
c.distance = c.distance or 1

g_ui.loadUIFromString([[
MiningWin < MainWindow
  text: Mining
  size: 320 175
  @onEscape: self:hide()

  Label
    id: lblPick
    text: Pico:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 60

  BotItem
    id: pick
    anchors.left: lblPick.right
    anchors.top: parent.top
    margin-left: 8
    margin-top: 10

  Label
    id: lblDistance
    text: Distancia:
    anchors.left: pick.right
    anchors.top: parent.top
    margin-left: 20
    margin-top: 15
    width: 65

  TextEdit
    id: distanceEdit
    anchors.left: lblDistance.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 8
    margin-right: 12
    margin-top: 10
    height: 21

  Label
    id: lblStones
    text: Piedras:
    anchors.left: lblPick.left
    anchors.top: pick.bottom
    margin-top: 14
    width: 60

  BotContainer
    id: list
    anchors.left: lblStones.right
    anchors.right: parent.right
    anchors.top: pick.bottom
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
    text: Mining
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("MiningWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

win.pick:setItemId(c.pickId)
win.pick.onItemChange = function(w) c.pickId = w:getItemId() end

win.distanceEdit:setText(tostring(c.distance))
win.distanceEdit.onTextChange = function(w, text) c.distance = tonumber(text) or c.distance end

local stoneList = UI.Container(function(w, i) c.stones = i end, true, nil, win.list)
stoneList:setItems(c.stones)

win.clearButton.onClick = function()
  c.stones = {}
  stoneList:setItems(c.stones)
end

win.closeButton.onClick = function()
  win:hide()
end

ui.setup.onClick = function()
  win.pick:setItemId(c.pickId)
  win.distanceEdit:setText(tostring(c.distance))
  stoneList:setItems(c.stones)
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

macro(500, function()
  local c = storage.mining
  if not c or not c.enabled or not c.stones or #c.stones == 0 or (c.pickId or 0) < 100 then return end

  local distance = tonumber(c.distance) or 1

  for i, tile in ipairs(g_map.getTiles(posz())) do
    for j, item in pairs(tile:getItems()) do
      if item then
        local id = item:getId()
        for _, entry in ipairs(c.stones) do
          local stoneId = type(entry) == "table" and entry.id or entry
          if stoneId == id then
            if getDistanceBetween(pos(), tile:getPosition()) <= distance then
              return useWith(c.pickId, item)
            end
          end
        end
      end
    end
  end
end)