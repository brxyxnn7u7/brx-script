setDefaultTab("Tools")
-- ======================================================
--  ML TRAIN
--
--  Switch para prender/apagar + boton Setup que abre una
--  ventanita donde pones los dos hechizos a decir en secuencia
--  (el segundo se dice 1 segundo despues del primero).
-- ======================================================

local c = storage.mlTrain or {}
storage.mlTrain = c
c.spell1 = c.spell1 or "Nome da Magia"
c.spell2 = c.spell2 or "Nome da Magia"
c.minMana = c.minMana or 10

g_ui.loadUIFromString([[
MlTrainWin < MainWindow
  text: ML Train
  size: 280 165
  @onEscape: self:hide()

  Label
    id: lblSpell1
    text: Hechizo 1:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 90

  TextEdit
    id: spell1Edit
    anchors.top: lblSpell1.top
    anchors.left: lblSpell1.right
    anchors.right: parent.right
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblSpell2
    text: Hechizo 2:
    anchors.top: lblSpell1.bottom
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 90

  TextEdit
    id: spell2Edit
    anchors.top: lblSpell2.top
    anchors.left: lblSpell2.right
    anchors.right: parent.right
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblMinMana
    text: Mana min (%):
    anchors.top: lblSpell2.bottom
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 90

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
    anchors.top: lblMinMana.bottom
    margin-right: 12
    margin-top: 16
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
    text: ML Train
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("MlTrainWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

win.spell1Edit:setText(c.spell1)
win.spell1Edit.onTextChange = function(w, text) c.spell1 = text end

win.spell2Edit:setText(c.spell2)
win.spell2Edit.onTextChange = function(w, text) c.spell2 = text end

win.minManaEdit:setText(tostring(c.minMana))
win.minManaEdit.onTextChange = function(w, text) c.minMana = tonumber(text) or c.minMana end

win.cls.onClick = function() win:hide() end

ui.setup.onClick = function()
  win.spell1Edit:setText(c.spell1)
  win.spell2Edit:setText(c.spell2)
  win.minManaEdit:setText(tostring(c.minMana))
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

macro(1000, function()
  local c = storage.mlTrain
  if not c or not c.enabled then return end

  if manapercent() > tonumber(c.minMana) then
    say(c.spell1)
    schedule(1000, function()
      say(c.spell2)
    end)
  end
end)