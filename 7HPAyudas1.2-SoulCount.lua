setDefaultTab("HP")
-- ======================================================
--  CONTADOR DE SOUL POINTS
--
--  Icono "Soul Counter" para mostrar/ocultar el panel.
--  Muestra "Soul: X" en pantalla, actualizado cada 1s,
--  con color segun el rango:
--    < 15         -> rojo
--    15 a 100     -> amarillo
--    > 100        -> verde
--
--  La posicion del panel se guarda en storage y se puede
--  editar con el boton "Setup" de al lado del switch.
-- ======================================================

-- POSICION DEL PANEL: se guarda en storage y se edita con el boton "Setup"
if not storage.SoulCounter then
  storage.SoulCounter = {}
end
local posSettings = storage.SoulCounter

if not posSettings.posX then
  posSettings.posX = 1405
end
if not posSettings.posY then
  posSettings.posY = 395
end
if posSettings.enabled == nil then
  posSettings.enabled = true
end

local enabled = posSettings.enabled

local ui = setupUI(string.format([[
Panel
  id: soulCounterPanel
  height: 20
  width: 140
  clipping: false
  anchors.top: parent.top
  anchors.left: parent.left
  margin-left: %d
  margin-top: %d
  Label
    id: lblSoulCounter
    text: Soul: --
    color: #58D68D
    font: verdana-11px-rounded
    text-align: center
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
]], posSettings.posX, posSettings.posY), modules.game_interface.getMapPanel())

local function applyPosition()
  ui:setMarginLeft(posSettings.posX)
  ui:setMarginTop(posSettings.posY)
end

local function updateLabel()
  if not enabled then
    ui:setVisible(false)
    return
  end
  ui:setVisible(true)

  local soul = player:getSoul()
  if not soul then
    ui.lblSoulCounter:setText("Soul: --")
    ui.lblSoulCounter:setColor("#AAAAAA")
    return
  end

  ui.lblSoulCounter:setText("Soul: " .. soul)
  if soul < 30 then
    ui.lblSoulCounter:setColor("#E74C3C") -- rojo
  elseif soul <= 100 then
    ui.lblSoulCounter:setColor("#F1C40F") -- amarillo
  else
    ui.lblSoulCounter:setColor("#58D68D") -- verde
  end
end

local function tick()
  updateLabel()
  schedule(1000, tick)
end
tick()

-- ---------------- SETUP (posicion) ----------------

g_ui.loadUIFromString([[
SoulCounterSetupWindow < MainWindow
  !text: tr('Soul Counter - Setup')
  size: 260 190
  padding: 15

  Label
    id: lblInfo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: Posicion del contador en pantalla

  Label
    id: lblX
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 12
    text-align: center
    text: Pos X (desde el borde izquierdo)

  TextEdit
    id: editX
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    minimum: 0
    maximum: 3000
    step: 5
    text-align: center

  Label
    id: lblY
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 12
    text-align: center
    text: Pos Y (desde el borde superior)

  TextEdit
    id: editY
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    minimum: 0
    maximum: 2000
    step: 5
    text-align: center

  Button
    id: closeButton
    !text: tr('Close')
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
]])

SoulCounterSetupWindow = UI.createWindow('SoulCounterSetupWindow', rootWidget)
SoulCounterSetupWindow:hide()

SoulCounterSetupWindow.editX:setText(tostring(posSettings.posX))
SoulCounterSetupWindow.editY:setText(tostring(posSettings.posY))

SoulCounterSetupWindow.editX.onTextChange = function(widget, text)
  local n = tonumber(text)
  if n then
    posSettings.posX = n
    applyPosition()
  end
end

SoulCounterSetupWindow.editY.onTextChange = function(widget, text)
  local n = tonumber(text)
  if n then
    posSettings.posY = n
    applyPosition()
  end
end

SoulCounterSetupWindow.closeButton.onClick = function(widget)
  SoulCounterSetupWindow:hide()
end

-- ---------------- SWITCH ON/OFF ----------------

local switchUi = setupUI([[
Panel
  height: 20

  BotSwitch
    id: sw
    anchors.left: parent.left
    anchors.top: parent.top
    width: 100
    text: Soul Counter

  Button
    id: setupBtn
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]])

switchUi.setupBtn.onClick = function(widget)
  SoulCounterSetupWindow:show()
  SoulCounterSetupWindow:raise()
  SoulCounterSetupWindow:focus()
end

switchUi.sw.onClick = function(w)
  enabled = not enabled
  posSettings.enabled = enabled -- persistimos el estado en storage
  w:setOn(enabled)
  updateLabel()
end

switchUi.sw:setOn(enabled)