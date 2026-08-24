setDefaultTab("Tools")
-- ======================================================
--  ANTY RS
--
--  Switch para prender/apagar + boton Setup donde configuras:
--  - Frag Limit: cuantos "warning of murder" toleras antes de
--    apagar TargetBot y CaveBot
--  - Frag Text: el texto que busca en los mensajes del server
--    (por defecto "warning! the murder of")
-- ======================================================

local c = storage.antyRS or {}
storage.antyRS = c
c.fragsLimit = c.fragsLimit or 3
c.fragtext = c.fragtext or "warning! the murder of"

local frags = 0

g_ui.loadUIFromString([[
AntyRSWin < MainWindow
  text: Anty RS Setup
  size: 320 150
  @onEscape: self:hide()

  Label
    id: lblFragsLimit
    text: Frag Limit:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 90

  TextEdit
    id: fragsLimitEdit
    anchors.left: lblFragsLimit.right
    anchors.right: parent.right
    anchors.top: lblFragsLimit.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblFragText
    text: Frag Text:
    anchors.left: lblFragsLimit.left
    anchors.top: lblFragsLimit.bottom
    margin-top: 14
    width: 90

  TextEdit
    id: fragTextEdit
    anchors.left: lblFragText.right
    anchors.right: parent.right
    anchors.top: lblFragText.top
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

local ui = setupUI([[
Panel
  height: 20
  BotSwitch
    id: sw
    anchors.left: parent.left
    anchors.top: parent.top
    width: 130
    text: ANTY RS
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("AntyRSWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w)
  c.enabled = not c.enabled
  w:setOn(c.enabled)
end

win.fragsLimitEdit:setText(tostring(c.fragsLimit))
win.fragsLimitEdit.onTextChange = function(w, text) c.fragsLimit = tonumber(text) or c.fragsLimit end

win.fragTextEdit:setText(c.fragtext)
win.fragTextEdit.onTextChange = function(w, text) c.fragtext = text end

win.closeButton.onClick = function()
  win:hide()
end

ui.setup.onClick = function()
  win.fragsLimitEdit:setText(tostring(c.fragsLimit))
  win.fragTextEdit:setText(c.fragtext)
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA ----------------

onTextMessage(function(mode, text)
  local cfg = storage.antyRS
  if not cfg or not cfg.enabled then return end

  if text:lower():find(cfg.fragtext:lower()) then
    frags = frags + 1
    if frags >= tonumber(cfg.fragsLimit) then
      TargetBot.setOff()
      CaveBot.setOff()
    end
  end
end)