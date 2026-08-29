setDefaultTab("Main")
-- ======================================================
--  REVIVE ITEM
--
--  Switch para prender/apagar + boton Setup donde configuras:
--  - Item a usar (arrastralo al cuadrito)
--  - Cooldown (segundos entre cada uso)
--  - Modo: HP% o Mana% (elegis cual de los dos monitorear)
--  - Umbral (%): a partir de que porcentaje usar el item
--
--  Cuando el HP (o Mana, segun el modo elegido) cae a ese % o
--  menos, usa el item automaticamente, respetando el cooldown
--  para no floodear.
-- ======================================================

local c = storage.reviveItem or {}
storage.reviveItem = c
c.itemId = c.itemId or 0
c.cooldownSeconds = c.cooldownSeconds or 5
c.mode = c.mode or "hp" -- "hp" o "mana"
c.threshold = c.threshold or 30

local lastUsedAt = 0

-- ---------------- INTERFAZ ----------------

g_ui.loadUIFromString([[
ReviveItemWin < MainWindow
  text: Revive Item Setup
  size: 340 220
  @onEscape: self:hide()

  Label
    id: lblItem
    text: Item a usar:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 90

  BotItem
    id: itemSelector
    anchors.left: lblItem.right
    anchors.top: lblItem.top
    margin-left: 8

  Label
    id: lblCooldown
    text: Cooldown (seg):
    anchors.left: lblItem.left
    anchors.top: itemSelector.bottom
    margin-top: 12
    width: 90

  TextEdit
    id: cooldownEdit
    anchors.left: lblCooldown.right
    anchors.right: parent.right
    anchors.top: lblCooldown.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblMode
    text: Usar segun:
    anchors.left: lblItem.left
    anchors.top: lblCooldown.bottom
    margin-top: 14
    width: 90

  BotSwitch
    id: modeHpSwitch
    anchors.left: lblMode.right
    anchors.top: lblMode.top
    margin-left: 8
    width: 100
    text: HP%

  BotSwitch
    id: modeManaSwitch
    anchors.left: modeHpSwitch.right
    anchors.top: lblMode.top
    margin-left: 6
    width: 100
    text: Mana%

  Label
    id: lblThreshold
    text: Umbral (%):
    anchors.left: lblItem.left
    anchors.top: modeHpSwitch.bottom
    margin-top: 14
    width: 90

  TextEdit
    id: thresholdEdit
    anchors.left: lblThreshold.right
    anchors.right: parent.right
    anchors.top: lblThreshold.top
    margin-left: 8
    margin-right: 12
    height: 21

  Button
    id: closeButton
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-right: 12
    margin-bottom: 12
    size: 55 21
]])

local win = UI.createWindow("ReviveItemWin")
win:hide()

local function refreshModeSwitches()
  win.modeHpSwitch:setOn(c.mode == "hp")
  win.modeManaSwitch:setOn(c.mode == "mana")
end

win.itemSelector:setItemId(c.itemId)
win.itemSelector.onItemChange = function(w) c.itemId = w:getItemId() end

win.cooldownEdit:setText(tostring(c.cooldownSeconds))
win.cooldownEdit.onTextChange = function(w, text) c.cooldownSeconds = tonumber(text) or c.cooldownSeconds end

win.thresholdEdit:setText(tostring(c.threshold))
win.thresholdEdit.onTextChange = function(w, text) c.threshold = tonumber(text) or c.threshold end

win.modeHpSwitch.onClick = function(w)
  c.mode = "hp"
  refreshModeSwitches()
end

win.modeManaSwitch.onClick = function(w)
  c.mode = "mana"
  refreshModeSwitches()
end

win.closeButton.onClick = function()
  win:hide()
end

local ui = setupUI([[
Panel
  height: 20
  BotSwitch
    id: sw
    anchors.left: parent.left
    anchors.top: parent.top
    width: 130
    text: Revive Item
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

ui.setup.onClick = function()
  win.itemSelector:setItemId(c.itemId)
  win.cooldownEdit:setText(tostring(c.cooldownSeconds))
  win.thresholdEdit:setText(tostring(c.threshold))
  refreshModeSwitches()
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

local function getManaPercentSafe()
  local ok, result = pcall(function() return manapercent() end)
  if ok and type(result) == "number" and result >= 0 then
    return result
  end

  local currentMana = player:getMana()
  local maxMana = player:getMaxMana()
  if not currentMana or not maxMana or maxMana <= 0 then
    return nil
  end
  return math.floor((currentMana / maxMana) * 100)
end

local function getCurrentPercent(mode)
  if mode == "mana" then
    return getManaPercentSafe()
  end
  return player:getHealthPercent()
end

macro(200, function()
  local cfg = storage.reviveItem
  if not cfg or not cfg.enabled then return end
  if not cfg.itemId or cfg.itemId < 100 then return end

  local percent = getCurrentPercent(cfg.mode)
  if not percent then return end

  if percent > tonumber(cfg.threshold) then return end

  local cooldownMs = (tonumber(cfg.cooldownSeconds) or 5) * 1000
  if now - lastUsedAt < cooldownMs then return end

  local item = findItem(cfg.itemId)
  if not item then return end

  g_game.use(item)
  lastUsedAt = now
end)