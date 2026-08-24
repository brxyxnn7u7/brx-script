setDefaultTab("Tools")
-- ======================================================
--  STAMINA POTION
--
--  Switch para prender/apagar + boton Setup donde eliges
--  las pociones de stamina y a partir de cuantas horas
--  restantes se toma una.
-- ======================================================

local c = storage.staminaPotion or {}
storage.staminaPotion = c
c.potions = c.potions or {10009, 11372, 3233}
c.minHours = c.minHours or 40

g_ui.loadUIFromString([[
StaminaPotionWin < MainWindow
  text: Stamina Potion
  size: 300 175
  @onEscape: self:hide()

  Label
    id: lblHours
    text: Horas minimas:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 85

  TextEdit
    id: hoursEdit
    anchors.left: lblHours.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 8
    margin-right: 12
    margin-top: 10
    height: 21

  Label
    id: lblPotions
    text: Pociones:
    anchors.left: lblHours.left
    anchors.top: lblHours.bottom
    margin-top: 14
    width: 85

  BotContainer
    id: list
    anchors.left: lblPotions.right
    anchors.right: parent.right
    anchors.top: hoursEdit.bottom
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
    text: Stamina Potion
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("StaminaPotionWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

win.hoursEdit:setText(tostring(c.minHours))
win.hoursEdit.onTextChange = function(w, text) c.minHours = tonumber(text) or c.minHours end

local potionContainer = UI.Container(function(w, items) c.potions = items end, true, nil, win.list)
potionContainer:setItems(c.potions)

win.clearButton.onClick = function()
  c.potions = {}
  potionContainer:setItems(c.potions)
end

win.closeButton.onClick = function()
  win:hide()
end

ui.setup.onClick = function()
  win.hoursEdit:setText(tostring(c.minHours))
  potionContainer:setItems(c.potions)
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

macro(1000, function()
  local c = storage.staminaPotion
  if not c or not c.enabled or not c.potions or #c.potions == 0 then return end

  local minHours = tonumber(c.minHours) or 0

  if stamina() < minHours * 60 then
    for _, entry in ipairs(c.potions) do
      local potId = type(entry) == "table" and entry.id or entry
      local pot = findItem(potId)
      if pot then
        return g_game.use(pot)
      end
    end
  end
end)