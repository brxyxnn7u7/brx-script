setDefaultTab("Tools")
setDefaultTab("Tools")
-----------------------------------------------------
-- MAGE AOE SMART + WHITELIST - OTCLIENT V8
--
-- Switch para prender/apagar + boton Setup donde configuras:
-- - Spell de area a lanzar
-- - Minimo de monstruos para castear
-- - Distancia maxima de los monstruos (sqms)
-- - Rango de seguridad con players no amigos
--
-- La whitelist de amigos se sigue editando directo en el
-- codigo (tabla "friends" mas abajo), ya que no la pediste
-- en el Setup.
-----------------------------------------------------

local c = storage.mageAoeSmart or {}
storage.mageAoeSmart = c
c.aoeSpell = c.aoeSpell or "exevo gran mas flam"
c.minTargets = c.minTargets or 1
c.maxMonsterDist = c.maxMonsterDist or 1
c.playerSafeRange = c.playerSafeRange or 4

-- Whitelist de amigos (exactamente como se llaman in-game)
local friends = {
  [""] = true,
  [""] = true,
  ["Amigo 3"] = true
}

-- ---------------- INTERFAZ ----------------

g_ui.loadUIFromString([[
MageAoeSmartWin < MainWindow
  text: Mage AoE Smart Setup
  size: 300 200
  @onEscape: self:hide()

  Label
    id: lblSpell
    text: Spell AoE:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 110

  TextEdit
    id: spellEdit
    anchors.left: lblSpell.right
    anchors.right: parent.right
    anchors.top: lblSpell.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblMinTargets
    text: Min monstruos:
    anchors.left: lblSpell.left
    anchors.top: lblSpell.bottom
    margin-top: 14
    width: 110

  TextEdit
    id: minTargetsEdit
    anchors.left: lblMinTargets.right
    anchors.right: parent.right
    anchors.top: lblMinTargets.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblMaxDist
    text: Max distancia (sqm):
    anchors.left: lblSpell.left
    anchors.top: lblMinTargets.bottom
    margin-top: 14
    width: 110

  TextEdit
    id: maxDistEdit
    anchors.left: lblMaxDist.right
    anchors.right: parent.right
    anchors.top: lblMaxDist.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblSafeRange
    text: Player safe range:
    anchors.left: lblSpell.left
    anchors.top: lblMaxDist.bottom
    margin-top: 14
    width: 110

  TextEdit
    id: safeRangeEdit
    anchors.left: lblSafeRange.right
    anchors.right: parent.right
    anchors.top: lblSafeRange.top
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

local win = UI.createWindow("MageAoeSmartWin")
win:hide()

win.spellEdit:setText(c.aoeSpell)
win.spellEdit.onTextChange = function(w, text) c.aoeSpell = text end

win.minTargetsEdit:setText(tostring(c.minTargets))
win.minTargetsEdit.onTextChange = function(w, text) c.minTargets = tonumber(text) or c.minTargets end

win.maxDistEdit:setText(tostring(c.maxMonsterDist))
win.maxDistEdit.onTextChange = function(w, text) c.maxMonsterDist = tonumber(text) or c.maxMonsterDist end

win.safeRangeEdit:setText(tostring(c.playerSafeRange))
win.safeRangeEdit.onTextChange = function(w, text) c.playerSafeRange = tonumber(text) or c.playerSafeRange end

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
    text: Mage AoE Smart
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
  win.spellEdit:setText(c.aoeSpell)
  win.minTargetsEdit:setText(tostring(c.minTargets))
  win.maxDistEdit:setText(tostring(c.maxMonsterDist))
  win.safeRangeEdit:setText(tostring(c.playerSafeRange))
  win:show()
  win:raise()
  win:focus()
end

-- ===== FUNCIONES AUXILIARES ===== --

local function isFriend(name)
  return friends[name] == true
end

local function distance(a, b)
  local dx = math.abs(a.x - b.x)
  local dy = math.abs(a.y - b.y)
  return math.max(dx, dy)
end

-- ===== MACRO PRINCIPAL ===== --

macro(200, function()
  local cfg = storage.mageAoeSmart
  if not cfg or not cfg.enabled then return end

  local player = g_game.getLocalPlayer()
  if not player then return end

  local myPos = player:getPosition()
  if not myPos then return end

  -- 1) REVISAR PLAYERS CERCA (SEGURIDAD)
  for _, cr in ipairs(getSpectators(false)) do
    if cr:isPlayer() and not cr:isLocalPlayer() then
      local name = cr:getName()
      if not isFriend(name) then
        if distance(myPos, cr:getPosition()) <= tonumber(cfg.playerSafeRange) then
          -- Player desconocido o enemigo cerca: NO atacar
          if g_game.isAttacking() then
            g_game.cancelAttack()
          end
          return
        end
      end
    end
  end

  -- 2) CONTAR MONSTRUOS EN RANGO PARA AOE
  local count = 0
  for _, cr in ipairs(getSpectators(false)) do
    if cr:isMonster() then
      if distance(myPos, cr:getPosition()) <= tonumber(cfg.maxMonsterDist) then
        count = count + 1
        if count >= tonumber(cfg.minTargets) then
          -- Lanzar spell de area
          say(cfg.aoeSpell)
          return
        end
      end
    end
  end
end)