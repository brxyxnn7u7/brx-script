setDefaultTab("Tools")
-- ======================================================
--  RUNE MAKER
--
--  Switch para prender/apagar + boton Setup que abre una
--  ventanita con el hechizo, ID de runa, cantidad maxima y
--  mana minima requerida.
-- ======================================================

local c = storage.runeMaker or {}
storage.runeMaker = c
c.spell = c.spell or "adori mas frigo"
c.runeId = c.runeId or 3161
c.maxAmount = c.maxAmount or 50
c.minMana = c.minMana or 80

g_ui.loadUIFromString([[
RuneMakerWin < MainWindow
  text: Rune Maker
  size: 280 190
  @onEscape: self:hide()

  Label
    id: lblSpell
    text: Hechizo:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 110

  TextEdit
    id: spellEdit
    anchors.top: lblSpell.top
    anchors.left: lblSpell.right
    anchors.right: parent.right
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblRuneId
    text: ID de la runa:
    anchors.top: lblSpell.bottom
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 110

  TextEdit
    id: runeIdEdit
    anchors.top: lblRuneId.top
    anchors.left: lblRuneId.right
    anchors.right: parent.right
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblMaxAmount
    text: Cantidad maxima:
    anchors.top: lblRuneId.bottom
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 110

  TextEdit
    id: maxAmountEdit
    anchors.top: lblMaxAmount.top
    anchors.left: lblMaxAmount.right
    anchors.right: parent.right
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblMinMana
    text: Mana minima (%):
    anchors.top: lblMaxAmount.bottom
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 110

  TextEdit
    id: minManaEdit
    anchors.top: lblMinMana.top
    anchors.left: lblMinMana.right
    anchors.right: parent.right
    margin-left: 8
    margin-right: 12
    height: 21

  Button
    id: cls
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-right: 12
    margin-bottom: 10
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
    text: Rune Maker
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("RuneMakerWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

win.spellEdit:setText(c.spell)
win.spellEdit.onTextChange = function(w, text) c.spell = text end

win.runeIdEdit:setText(tostring(c.runeId))
win.runeIdEdit.onTextChange = function(w, text) c.runeId = tonumber(text) or c.runeId end

win.maxAmountEdit:setText(tostring(c.maxAmount))
win.maxAmountEdit.onTextChange = function(w, text) c.maxAmount = tonumber(text) or c.maxAmount end

win.minManaEdit:setText(tostring(c.minMana))
win.minManaEdit.onTextChange = function(w, text) c.minMana = tonumber(text) or c.minMana end

win.cls.onClick = function() win:hide() end

ui.setup.onClick = function()
  win.spellEdit:setText(c.spell)
  win.runeIdEdit:setText(tostring(c.runeId))
  win.maxAmountEdit:setText(tostring(c.maxAmount))
  win.minManaEdit:setText(tostring(c.minMana))
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

macro(1000, function()
  local c = storage.runeMaker
  if not c or not c.enabled then return end

  local runeId = tonumber(c.runeId) or 0
  if runeId <= 0 then return end

  local cantidad = itemAmount(runeId)
  if cantidad < tonumber(c.maxAmount) and manapercent() > tonumber(c.minMana) then
    say(c.spell)
  end
end)