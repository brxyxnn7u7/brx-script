setDefaultTab("HP")
-- ======================================================
--  EQUIP SET (6 sets independientes, con switch exclusivo)
--
--  Cada set tiene su propio switch y su propio boton
--  "Setup" (9 casilleros). Solo puede haber UN switch
--  prendido a la vez: si prendes el Set 2, el Set 1 (o
--  cualquier otro que estuviera prendido) se apaga solo, y
--  se equipa lo que hayas configurado en el Set 2.
--
--  Los sets se guardan con claves de texto (no con el numero
--  de slot), porque los numeros de slot no son consecutivos y
--  eso hacia que el storage se corrompiera al guardarse como
--  JSON y volver a cargar.
-- ======================================================

-- Made By VivoDibra, originally VivoDibra#1182
local function equipItem(id, slot)
  local item = getInventoryItem(slot)
  if item and item:getId() == id then
    return
  end
  local itemToEquip = findItem(id)
  if itemToEquip then
    moveToSlot(itemToEquip, slot, itemToEquip:getCount())
  end
end

local SLOT_KEYS = {
  { key = "head",   widget = "headItem",   slot = SlotHead },
  { key = "neck",   widget = "neckItem",   slot = SlotNeck },
  { key = "finger", widget = "fingerItem", slot = SlotFinger },
  { key = "right",  widget = "rightItem",  slot = SlotRight },
  { key = "body",   widget = "bodyItem",   slot = SlotBody },
  { key = "left",   widget = "leftItem",   slot = SlotLeft },
  { key = "leg",    widget = "legItem",    slot = SlotLeg },
  { key = "feet",   widget = "feetItem",   slot = SlotFeet },
  { key = "ammo",   widget = "ammoItem",   slot = SlotAmmo },
}

-- Set actualmente activo (0 = ninguno) y lista de switches, para poder
-- apagar todos los demas cuando prendes uno nuevo.
storage.activeEquipSet = storage.activeEquipSet or 0
local allSwitches = {}

local function setActiveSet(setNumber)
  storage.activeEquipSet = setNumber
  for i, sw in pairs(allSwitches) do
    sw:setOn(i == setNumber)
  end
end

-- Crea un set completo: storage propio, ventana propia, switch propio y
-- boton de Setup propio. setNumber tiene que ser distinto para cada uno
-- (1, 2, 3...) para que no se pisen los nombres internos.
local function createEquipSet(setNumber)
  local windowClass = "EquipSetWin" .. setNumber
  local storageKey = "equipSetConfig" .. setNumber

  local c = storage[storageKey] or {}
  storage[storageKey] = c
  c.slots = c.slots or {}
  c.name = c.name or ("Set " .. setNumber)

  -- se declara aqui para que nameEdit.onTextChange (mas abajo) pueda
  -- actualizar el texto del switch en cuanto exista
  local switchWidget

  local function equipSavedSet()
    local delay = 0
    for _, sk in ipairs(SLOT_KEYS) do
      local id = c.slots[sk.key]
      if id and id >= 100 then
        local slot = sk.slot
        schedule(delay, function()
          equipItem(id, slot)
        end)
        delay = delay + 500
      end
    end
  end

  -- ---------------- INTERFAZ (ventana de setup) ----------------

  g_ui.loadUIFromString(string.format([[
%s < MainWindow
  text: Equip Set %d Setup
  size: 280 330
  @onEscape: self:hide()

  Label
    id: lblName
    text: Nombre:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 55

  TextEdit
    id: nameEdit
    anchors.left: lblName.right
    anchors.right: parent.right
    anchors.top: lblName.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblNeck
    text: Neck
    anchors.top: nameEdit.bottom
    anchors.left: parent.left
    margin-top: 15
    margin-left: 20
    text-align: center
    width: 60

  Label
    id: lblHead
    text: Head
    anchors.top: nameEdit.bottom
    anchors.left: lblNeck.right
    margin-top: 15
    margin-left: 20
    text-align: center
    width: 60

  Label
    id: lblFinger
    text: Ring
    anchors.top: nameEdit.bottom
    anchors.left: lblHead.right
    margin-top: 15
    margin-left: 20
    text-align: center
    width: 60

  BotItem
    id: neckItem
    anchors.top: lblNeck.bottom
    anchors.horizontalCenter: lblNeck.horizontalCenter
    margin-top: 4

  BotItem
    id: headItem
    anchors.top: lblHead.bottom
    anchors.horizontalCenter: lblHead.horizontalCenter
    margin-top: 4

  BotItem
    id: fingerItem
    anchors.top: lblFinger.bottom
    anchors.horizontalCenter: lblFinger.horizontalCenter
    margin-top: 4

  Label
    id: lblRight
    text: Weapon
    anchors.top: neckItem.bottom
    anchors.horizontalCenter: lblNeck.horizontalCenter
    margin-top: 12
    text-align: center
    width: 60

  Label
    id: lblBody
    text: Body
    anchors.top: neckItem.bottom
    anchors.horizontalCenter: lblHead.horizontalCenter
    margin-top: 12
    text-align: center
    width: 60

  Label
    id: lblLeft
    text: Shield
    anchors.top: neckItem.bottom
    anchors.horizontalCenter: lblFinger.horizontalCenter
    margin-top: 12
    text-align: center
    width: 60

  BotItem
    id: rightItem
    anchors.top: lblRight.bottom
    anchors.horizontalCenter: lblRight.horizontalCenter
    margin-top: 4

  BotItem
    id: bodyItem
    anchors.top: lblBody.bottom
    anchors.horizontalCenter: lblBody.horizontalCenter
    margin-top: 4

  BotItem
    id: leftItem
    anchors.top: lblLeft.bottom
    anchors.horizontalCenter: lblLeft.horizontalCenter
    margin-top: 4

  Label
    id: lblLeg
    text: Legs
    anchors.top: rightItem.bottom
    anchors.horizontalCenter: lblRight.horizontalCenter
    margin-top: 12
    text-align: center
    width: 60

  Label
    id: lblFeet
    text: Feet
    anchors.top: rightItem.bottom
    anchors.horizontalCenter: lblBody.horizontalCenter
    margin-top: 12
    text-align: center
    width: 60

  Label
    id: lblAmmo
    text: Ammo
    anchors.top: rightItem.bottom
    anchors.horizontalCenter: lblLeft.horizontalCenter
    margin-top: 12
    text-align: center
    width: 60

  BotItem
    id: legItem
    anchors.top: lblLeg.bottom
    anchors.horizontalCenter: lblLeg.horizontalCenter
    margin-top: 4

  BotItem
    id: feetItem
    anchors.top: lblFeet.bottom
    anchors.horizontalCenter: lblFeet.horizontalCenter
    margin-top: 4

  BotItem
    id: ammoItem
    anchors.top: lblAmmo.bottom
    anchors.horizontalCenter: lblAmmo.horizontalCenter
    margin-top: 4

  Button
    id: closeButton
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-right: 12
    margin-bottom: 12
    size: 55 21
]], windowClass, setNumber))

  local win = UI.createWindow(windowClass)
  win:hide()

  win.nameEdit:setText(c.name)
  win.nameEdit.onTextChange = function(widget, text)
    if text == "" then
      text = "Set " .. setNumber
    end
    c.name = text
    if switchWidget then
      switchWidget:setText(text)
    end
  end

  for _, sk in ipairs(SLOT_KEYS) do
    local w = win[sk.widget]
    w:setItemId(c.slots[sk.key] or 0)
    w.onItemChange = function(widget)
      c.slots[sk.key] = widget:getItemId()
    end
  end

  win.closeButton.onClick = function()
    win:hide()
  end

  local function openSetupWindow()
    win.nameEdit:setText(c.name)
    for _, sk in ipairs(SLOT_KEYS) do
      win[sk.widget]:setItemId(c.slots[sk.key] or 0)
    end
    win:show()
    win:raise()
    win:focus()
  end

  -- ---------------- SWITCH + BOTON DE SETUP (una fila) ----------------

  local rowPanel = setupUI(string.format([[
Panel
  height: 20
  BotSwitch
    id: setSwitch%d
    anchors.left: parent.left
    anchors.top: parent.top
    width: 90
    text: %s
  Button
    id: setupBtn%d
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]], setNumber, c.name, setNumber))

  local setupButton = rowPanel["setupBtn" .. setNumber]
  switchWidget = rowPanel["setSwitch" .. setNumber]

  allSwitches[setNumber] = switchWidget
  switchWidget:setOn(storage.activeEquipSet == setNumber)

  switchWidget.onClick = function(w)
    if storage.activeEquipSet == setNumber then
      -- ya estaba encendido: lo apagamos y queda sin set activo
      setActiveSet(0)
    else
      setActiveSet(setNumber)
      equipSavedSet()
    end
  end

  setupButton.onClick = function()
    openSetupWindow()
  end
end

-- ---------------- CREAR LOS 6 SETS ----------------

createEquipSet(1)
createEquipSet(2)
createEquipSet(3)
createEquipSet(4)
createEquipSet(5)
createEquipSet(6)