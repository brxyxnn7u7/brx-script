setDefaultTab("Tools")
-- ======================================================
--  REVIDE PK
--
--  Switch para prender/apagar + boton Setup donde configuras:
--  - Spell de soporte: se dice UNA vez apenas se detecta que
--    alguien con skull te ataca (ej: "utamo vita")
--  - Spell/palabras de ataque: se repite constantemente
--    mientras el atacante siga presente (ej: "exevo gran mas
--    frigo", o las palabras de una runa como "sd")
--  - Intervalo de ataque: cada cuantos ms repetir el spell de
--    ataque (por defecto 1000ms, ajustalo segun el cooldown de
--    tu hechizo/runa)
--
--  Como funciona:
--  1) Detecta un misil de un jugador con skull (cualquier color)
--     apuntandote directamente.
--  2) Apaga CaveBot y TargetBot (para no pelearte con ellos).
--  3) Dice el spell de soporte una vez.
--  4) Ataca al agresor y repite el spell de ataque hasta que el
--     atacante desaparece (muere, se va del piso, o pasan mas
--     de 60s sin confirmarlo como amenaza).
-- ======================================================

local c = storage.revidePK2 or {}
storage.revidePK2 = c
c.supportSpell = c.supportSpell or "utamo vita"
c.attackSpell = c.attackSpell or "exevo gran mas frigo"
c.attackRuneId = c.attackRuneId or 0
c.attackIntervalMs = c.attackIntervalMs or 1000

local CLEANUP_SECONDS = 60 -- si pasan mas de esto sin re-confirmar el ataque, se olvida del atacante

-- ---------------- INTERFAZ ----------------

g_ui.loadUIFromString([[
RevidePKWin < MainWindow
  text: Revide PK Setup
  size: 320 215
  @onEscape: self:hide()

  Label
    id: lblSupport
    text: Spell soporte:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 100

  TextEdit
    id: supportEdit
    anchors.left: lblSupport.right
    anchors.right: parent.right
    anchors.top: lblSupport.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblAttack
    text: Spell ataque:
    anchors.left: lblSupport.left
    anchors.top: lblSupport.bottom
    margin-top: 14
    width: 100

  TextEdit
    id: attackEdit
    anchors.left: lblAttack.right
    anchors.right: parent.right
    anchors.top: lblAttack.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblRune
    text: Runa ataque:
    anchors.left: lblSupport.left
    anchors.top: lblAttack.bottom
    margin-top: 14
    width: 100

  BotItem
    id: runeItem
    anchors.left: lblRune.right
    anchors.top: lblRune.top
    margin-left: 8

  Label
    id: lblInterval
    text: Intervalo (ms):
    anchors.left: lblSupport.left
    anchors.top: runeItem.bottom
    margin-top: 12
    width: 100

  TextEdit
    id: intervalEdit
    anchors.left: lblInterval.right
    anchors.right: parent.right
    anchors.top: lblInterval.top
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

local win = UI.createWindow("RevidePKWin")
win:hide()

win.supportEdit:setText(c.supportSpell)
win.supportEdit.onTextChange = function(w, text) c.supportSpell = text end

win.attackEdit:setText(c.attackSpell)
win.attackEdit.onTextChange = function(w, text) c.attackSpell = text end

win.runeItem:setItemId(c.attackRuneId)
win.runeItem.onItemChange = function(w) c.attackRuneId = w:getItemId() end

win.intervalEdit:setText(tostring(c.attackIntervalMs))
win.intervalEdit.onTextChange = function(w, text) c.attackIntervalMs = tonumber(text) or c.attackIntervalMs end

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
    text: Revide PK
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
  win.supportEdit:setText(c.supportSpell)
  win.attackEdit:setText(c.attackSpell)
  win.runeItem:setItemId(c.attackRuneId)
  win.intervalEdit:setText(tostring(c.attackIntervalMs))
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- ESTADO ----------------

local attacker = nil
local targetTime = 0
local lastAttackSpellAt = 0

local function clearAttacker()
  attacker = nil
  targetTime = 0
end

-- ---------------- DETECCION DEL ATAQUE ----------------

onMissle(function(missle)
  local cfg = storage.revidePK2
  if not cfg or not cfg.enabled then return end

  local src = missle:getSource()
  if src.z ~= posz() then return end

  local shooterTile = g_map.getTile(src)
  if not shooterTile then return end

  local creatures = shooterTile:getCreatures()
  if not creatures[1] then return end

  local shooter = creatures[1]
  if not shooter:isPlayer() then return end
  if player:getName() == shooter:getName() then return end

  local destination = missle:getDestination()
  if posx() ~= destination.x or posy() ~= destination.y then return end

  if shooter:getSkull() == 0 then return end -- sin skull, no lo consideramos agresor
  if attacker == shooter then return end -- ya lo teniamos marcado

  attacker = shooter
  targetTime = now
  lastAttackSpellAt = 0 -- para que diga el spell de ataque ya en el proximo tick

  CaveBot.setOff()
  TargetBot.setOff()
  say(cfg.supportSpell)
end)

-- Si el atacante desaparece (muere, se va, etc.) cortamos de inmediato,
-- sin esperar los 60 segundos de limpieza.
onCreatureDisappear(function(creature)
  if attacker and creature == attacker then
    clearAttacker()
  end
end)

-- ---------------- ATAQUE CONTINUO ----------------

macro(100, function()
  local cfg = storage.revidePK2
  if not cfg or not cfg.enabled then return end

  if not attacker then return end

  local attackerPos = attacker:getPosition()
  if not attackerPos or attackerPos.z ~= posz() then
    -- se fue de piso, no lo perseguimos pero tampoco lo olvidamos todavia
    return
  end

  if not g_game.isAttacking() or g_game.getAttackingCreature() ~= attacker then
    g_game.attack(attacker)
  end

  if now - lastAttackSpellAt > tonumber(cfg.attackIntervalMs) then
    local runeId = tonumber(cfg.attackRuneId) or 0
    if runeId >= 100 then
      local rune = findItem(runeId)
      if rune then
        g_game.useWith(rune, attacker)
      end
    elseif cfg.attackSpell and cfg.attackSpell ~= "" then
      say(cfg.attackSpell)
    end
    lastAttackSpellAt = now
  end

  if now - targetTime > CLEANUP_SECONDS * 1000 then
    clearAttacker()
  end
end)