setDefaultTab("Main")
-- ======================================================
--  REVIVE ITEM (3 items independientes)
--
--  Switch para prender/apagar + boton Setup con 3 filas.
--  Cada fila tiene SU PROPIO item, cooldown, modo (HP% o
--  Mana%) y umbral - totalmente independientes entre si.
--
--  Cuando el HP (o Mana, segun el modo de esa fila) cae al
--  umbral configurado o menos, usa ese item, respetando su
--  propio cooldown.
-- ======================================================

local c = storage.reviveItem or {}
storage.reviveItem = c
c.items = c.items or {
  { itemId = 0, cooldownSeconds = 5, mode = "hp", threshold = 30 },
  { itemId = 0, cooldownSeconds = 5, mode = "hp", threshold = 30 },
  { itemId = 0, cooldownSeconds = 5, mode = "hp", threshold = 30 },
}
c.lastUsedAt = c.lastUsedAt or { 0, 0, 0 }

-- ---------------- INTERFAZ ----------------

local function itemRowOtml(i, topAnchor, topMargin)
  return string.format([[
  Label
    id: lblItem%d
    text: Item %d:
    anchors.left: parent.left
    anchors.top: %s
    margin-top: %d
    margin-left: 12
    width: 60

  BotItem
    id: itemSelector%d
    anchors.left: lblItem%d.right
    anchors.top: lblItem%d.top
    margin-left: 8

  Label
    id: lblCooldown%d
    text: CD (seg):
    anchors.left: itemSelector%d.right
    anchors.top: lblItem%d.top
    margin-top: 5
    margin-left: 16
    width: 60

  TextEdit
    id: cooldownEdit%d
    anchors.left: lblCooldown%d.right
    anchors.right: parent.right
    anchors.top: lblCooldown%d.top
    margin-left: 8
    margin-right: 12
    height: 21

  BotSwitch
    id: modeHpSwitch%d
    anchors.left: lblItem%d.left
    anchors.top: itemSelector%d.bottom
    margin-top: 10
    width: 90
    text: HP%%

  BotSwitch
    id: modeManaSwitch%d
    anchors.left: modeHpSwitch%d.right
    anchors.top: modeHpSwitch%d.top
    margin-left: 6
    width: 90
    text: Mana%%

  Label
    id: lblThreshold%d
    text: Umbral (%%):
    anchors.left: modeManaSwitch%d.right
    anchors.top: modeHpSwitch%d.top
    margin-top: 5
    margin-left: 16
    width: 65

  TextEdit
    id: thresholdEdit%d
    anchors.left: lblThreshold%d.right
    anchors.right: parent.right
    anchors.top: lblThreshold%d.top
    margin-left: 8
    margin-right: 12
    height: 21
]],
    i, i, topAnchor, topMargin,
    i, i, i,
    i, i, i,
    i, i, i,
    i, i, i,
    i, i, i,
    i, i, i,
    i, i, i,
    i, i, i
  )
end

local separatorOtml = [[
  HorizontalSeparator
    id: sepAFTER
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: ANCHORAFTER
    margin-top: 14
    margin-left: 12
    margin-right: 12
]]

local row1 = itemRowOtml(1, "parent.top", 15)
local sep1 = separatorOtml:gsub("ANCHORAFTER", "thresholdEdit1.bottom"):gsub("AFTER", "1")
local row2 = itemRowOtml(2, "sep1.bottom", 14)
local sep2 = separatorOtml:gsub("ANCHORAFTER", "thresholdEdit2.bottom"):gsub("AFTER", "2")
local row3 = itemRowOtml(3, "sep2.bottom", 14)

g_ui.loadUIFromString([[
ReviveItemWin < MainWindow
  text: Revive Item Setup
  size: 400 375
  @onEscape: self:hide()

]] .. row1 .. sep1 .. row2 .. sep2 .. row3 .. [[

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

local rowWidgets = {}
for i = 1, 3 do
  rowWidgets[i] = {
    item = win["itemSelector" .. i],
    cooldown = win["cooldownEdit" .. i],
    modeHp = win["modeHpSwitch" .. i],
    modeMana = win["modeManaSwitch" .. i],
    threshold = win["thresholdEdit" .. i],
  }
end

local function refreshRow(i)
  local rw = rowWidgets[i]
  local entry = c.items[i]
  rw.item:setItemId(entry.itemId)
  rw.cooldown:setText(tostring(entry.cooldownSeconds))
  rw.modeHp:setOn(entry.mode == "hp")
  rw.modeMana:setOn(entry.mode == "mana")
  rw.threshold:setText(tostring(entry.threshold))
end

local function refreshAllRows()
  for i = 1, 3 do
    refreshRow(i)
  end
end

for i = 1, 3 do
  local rw = rowWidgets[i]
  local entry = c.items[i]

  rw.item.onItemChange = function(w) entry.itemId = w:getItemId() end
  rw.cooldown.onTextChange = function(w, text) entry.cooldownSeconds = tonumber(text) or entry.cooldownSeconds end
  rw.threshold.onTextChange = function(w, text) entry.threshold = tonumber(text) or entry.threshold end

  rw.modeHp.onClick = function(w)
    entry.mode = "hp"
    refreshRow(i)
  end
  rw.modeMana.onClick = function(w)
    entry.mode = "mana"
    refreshRow(i)
  end
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
  refreshAllRows()
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

  for i, entry in ipairs(cfg.items) do
    if entry.itemId and entry.itemId >= 100 then
      local percent = getCurrentPercent(entry.mode)
      if percent and percent <= tonumber(entry.threshold) then
        local cooldownMs = (tonumber(entry.cooldownSeconds) or 5) * 1000
        if now - (cfg.lastUsedAt[i] or 0) >= cooldownMs then
          local item = findItem(entry.itemId)
          if item then
            g_game.use(item)
            cfg.lastUsedAt[i] = now
          end
        end
      end
    end
  end
end)
