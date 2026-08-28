setDefaultTab("HP")

local cIcon = addIcon("cI",{text="Cave\nBot",switchable=false,moveable=true}, function()
  if CaveBot.isOff() then 
    CaveBot.setOn()
  else 
    CaveBot.setOff()
  end
end)
cIcon:setSize({height=80,width=80})
cIcon.text:setFont('verdana-11px-rounded')

local tIcon = addIcon("tI",{text="Target\nBot",switchable=false,moveable=true}, function()
  if TargetBot.isOff() then 
    TargetBot.setOn()
  else 
    TargetBot.setOff()
    g_game.attack(nil)
  end
end)
tIcon:setSize({height=10,width=50})
tIcon.text:setFont('verdana-11px-rounded')

macro(50,function()
  if CaveBot.isOn() then
    cIcon.text:setColoredText({"CaveBot\n","white","ON","green"})
  else
    cIcon.text:setColoredText({"CaveBot\n","white","OFF","red"})
  end
  if TargetBot.isOn() then
    tIcon.text:setColoredText({"Target\n","white","ON","green"})
  else
    tIcon.text:setColoredText({"Target\n","white","OFF","red"})
  end
end)

-- ======================================================
--  SETUP DE POSICION (Pos X / Pos Y) para los iconos de
--  CaveBot y TargetBot. Se guarda en storage y se edita
--  desde el boton "Setup Position" de abajo.
--  NOTA: los iconos ya son "moveable" (arrastrables con el
--  mouse); esto es una forma alternativa/precisa de ubicarlos
--  escribiendo las coordenadas a mano.
-- ======================================================

if not storage.CaveTargetIcons then
  storage.CaveTargetIcons = {}
end
local iconPos = storage.CaveTargetIcons

local function getCurrentPos(widget, fallbackX, fallbackY)
  local okX, x = pcall(function() return widget:getMarginLeft() end)
  local okY, y = pcall(function() return widget:getMarginTop() end)
  if okX and okY and x and y then
    return x, y
  end
  return fallbackX, fallbackY
end

-- la primera vez, tomamos la posicion que ya tenian los iconos como punto
-- de partida, para no moverlos de sorpresa
if iconPos.caveX == nil or iconPos.caveY == nil then
  iconPos.caveX, iconPos.caveY = getCurrentPos(cIcon, 10, 10)
end
if iconPos.targetX == nil or iconPos.targetY == nil then
  iconPos.targetX, iconPos.targetY = getCurrentPos(tIcon, 20, 10)
end

local function applyIconPositions()
  cIcon:setMarginLeft(iconPos.caveX)
  cIcon:setMarginTop(iconPos.caveY)
  tIcon:setMarginLeft(iconPos.targetX)
  tIcon:setMarginTop(iconPos.targetY)
end

applyIconPositions()

g_ui.loadUIFromString([[
CaveTargetSetupWindow < MainWindow
  !text: tr('CaveBot / TargetBot - Setup Posicion')
  size: 280 300
  padding: 15

  Label
    id: lblCave
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: CaveBot Icon

  Label
    id: lblCaveX
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 8
    text-align: center
    text: Pos X

  TextEdit
    id: editCaveX
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    minimum: 0
    maximum: 3000
    step: 5
    text-align: center

  Label
    id: lblCaveY
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 8
    text-align: center
    text: Pos Y

  TextEdit
    id: editCaveY
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    minimum: 0
    maximum: 2000
    step: 5
    text-align: center

  Label
    id: lblTarget
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 16
    text-align: center
    text: TargetBot Icon

  Label
    id: lblTargetX
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 8
    text-align: center
    text: Pos X

  TextEdit
    id: editTargetX
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    minimum: 0
    maximum: 3000
    step: 5
    text-align: center

  Label
    id: lblTargetY
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 8
    text-align: center
    text: Pos Y

  TextEdit
    id: editTargetY
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

CaveTargetSetupWindow = UI.createWindow('CaveTargetSetupWindow', rootWidget)
CaveTargetSetupWindow:hide()

CaveTargetSetupWindow.editCaveX:setText(tostring(iconPos.caveX))
CaveTargetSetupWindow.editCaveY:setText(tostring(iconPos.caveY))
CaveTargetSetupWindow.editTargetX:setText(tostring(iconPos.targetX))
CaveTargetSetupWindow.editTargetY:setText(tostring(iconPos.targetY))

CaveTargetSetupWindow.editCaveX.onTextChange = function(widget, text)
  local n = tonumber(text)
  if n then
    iconPos.caveX = n
    applyIconPositions()
  end
end

CaveTargetSetupWindow.editCaveY.onTextChange = function(widget, text)
  local n = tonumber(text)
  if n then
    iconPos.caveY = n
    applyIconPositions()
  end
end

CaveTargetSetupWindow.editTargetX.onTextChange = function(widget, text)
  local n = tonumber(text)
  if n then
    iconPos.targetX = n
    applyIconPositions()
  end
end

CaveTargetSetupWindow.editTargetY.onTextChange = function(widget, text)
  local n = tonumber(text)
  if n then
    iconPos.targetY = n
    applyIconPositions()
  end
end

CaveTargetSetupWindow.closeButton.onClick = function(widget)
  CaveTargetSetupWindow:hide()
end

local setupUi = setupUI([[
Panel
  height: 20

  Button
    id: setupBtn
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: 17
    text: Setup Position
]])

setupUi.setupBtn.onClick = function(widget)
  CaveTargetSetupWindow:show()
  CaveTargetSetupWindow:raise()
  CaveTargetSetupWindow:focus()
end
