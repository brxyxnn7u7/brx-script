setDefaultTab("HP")
-- ======================================================
--  EQUIP SET (6 sets independientes, por palabra clave)
--
--  Cada set tiene su propia palabra clave, configurable
--  desde su boton "Setup". Cuando ESCRIBES esa palabra en
--  el chat (canal default) se equipa ese set. El mensaje
--  se sigue enviando al chat normal, esto solo lo detecta
--  de pasada.
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

-- Lista de {keyword, equip} de todos los sets, y el listener del chat
-- que revisa cada mensaje que TU escribes en el canal default.
local keywordHandlers = {}

onTalk(function(name, level, mode, text, channelId, pos)
  if not player or name ~= player:getName() then
    return
  end
  local msg = text:lower():gsub("^%s+", ""):gsub("%s+$", "")
  for _, h in ipairs(keywordHandlers) do
    if msg == h.keyword:lower() then
      h.equip()
      break
    end
  end
end)

-- Crea un set completo: storage propio, ventana propia, switch propio y
-- boton de Setup propio. setNumber tiene que ser distinto para cada uno
-- (1, 2, 3...) para que no se pisen los nombres internos.
local function createEquipSet(setNumber)
  local windowClass = "EquipSetWin" .. setNumber
  local storageKey = "equipSetConfig" .. setNumber

  local c = storage[storageKey] or {}
  storage[storageKey] = c
  c.slots = c.slots or {}
  c.keyword = c.keyword or ("set" .. setNumber)

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

  -- se guarda como tabla para poder actualizar la keyword en vivo
  -- cuando el usuario la cambia en el TextEdit de abajo, y tambien
  -- el texto del boton de Setup (se asigna mas abajo)
  local handlerEntry = { keyword = c.keyword, equip = equipSavedSet }
  table.insert(keywordHandlers, handlerEntry)

  -- ---------------- INTERFAZ (ventana de setup) ----------------

  g_ui.loadUIFromString(string.format([[
%s < MainWindow
  text: Equip Set %d Setup
  size: 280 330
  @onEscape: self:hide()

  Label
    id: lblName
    text: Palabra:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 12
    margin-left: 12
    width: 55

  TextEdit
    id: keywordEdit
    anchors.left: lblName.right
    anchors.right: parent.right
    anchors.top: lblName.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblNeck
    text: Neck
    anchors.top: keywordEdit.bottom
    anchors.left: parent.left
    margin-top: 15
    margin-left: 20
    text-align: center
    width: 60

  Label
    id: lblHead
    text: Head
    anchors.top: keywordEdit.bottom
    anchors.left: lblNeck.right
    margin-top: 15
    margin-left: 20
    text-align: center
    width: 60

  Label
    id: lblFinger
    text: Ring
    anchors.top: keywordEdit.bottom
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
    text: Shield
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
    text: Weapon
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

  win.keywordEdit:setText(c.keyword)

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
    win.keywordEdit:setText(c.keyword)
    for _, sk in ipairs(SLOT_KEYS) do
      win[sk.widget]:setItemId(c.slots[sk.key] or 0)
    end
    win:show()
    win:raise()
    win:focus()
  end

  -- ---------------- BOTON DE SETUP ----------------

  local rowPanel = setupUI(string.format([[
Panel
  height: 20
  Button
    id: setupBtn%d
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: 20
    text: Set %d Setup (%s)
]], setNumber, setNumber, c.keyword))

  local setupButton = rowPanel["setupBtn" .. setNumber]
  setupButton.onClick = function()
    openSetupWindow()
  end

  win.keywordEdit.onTextChange = function(widget, text)
    if text == "" then
      text = "set" .. setNumber
    end
    c.keyword = text
    handlerEntry.keyword = text
    setupButton:setText("Equip Set " .. setNumber .. " Setup (" .. text .. ")")
  end
end

-- ---------------- CREAR LOS 6 SETS ----------------

createEquipSet(1)
createEquipSet(2)
createEquipSet(3)
createEquipSet(4)
createEquipSet(5)
createEquipSet(6)
