setDefaultTab("Main")

-- ======================================================
--  POT FRIEND + COMBO GUILD + COMBO SPELL (Setup combinado)
--
--  Un solo switch "Pot + Combo" prende/apaga las tres funciones
--  a la vez, pero un solo boton "Setup" abre UNA ventana con
--  toda la configuracion de las tres.
--
--  Combo Spell: el lider dice "UE", "UE2" o "SD" en el canal
--  compartido, y los demas reaccionan:
--  - "UE"  -> decis el SpellUE
--  - "UE2" -> decis el SpellUE2
--  - "SD"  -> usas la ComboRune sobre tu objetivo actual
-- ======================================================

local potC = storage.potFriend or {}
storage.potFriend = potC
potC.channelName = potC.channelName or "Party"
potC.sayCommand = potC.sayCommand or "pp"
potC.potItemId = potC.potItemId or 238
potC.minMana = potC.minMana or 40
potC.cooldownSeconds = potC.cooldownSeconds or 3

local comboC = storage.comboGuild or {}
storage.comboGuild = comboC
comboC.prefix = comboC.prefix or "."

local spellC = storage.comboSpellCombo or {}
storage.comboSpellCombo = spellC
spellC.leader = spellC.leader or "player name;player name 2"
spellC.spellUE = spellC.spellUE or "UE Spell"
spellC.spellUE2 = spellC.spellUE2 or "UE2 Spell"
spellC.runeId = spellC.runeId or 3155

g_ui.loadUIFromString([[
CombinedSetupWin < MainWindow
  text: Pot Friend & Combo Guild Setup
  size: 320 560
  @onEscape: self:hide()

  Label
    id: lblPotTitle
    text: -- Pot Friend --
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 10
    text-align: center
    font: verdana-11px-rounded

  Label
    id: lblChannel
    text: Canal (compartido):
    anchors.top: lblPotTitle.bottom
    anchors.left: parent.left
    margin-top: 14
    margin-left: 12
    width: 95

  TextEdit
    id: channelEdit
    anchors.left: lblChannel.right
    anchors.right: parent.right
    anchors.top: lblChannel.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblCommand
    text: Palabra clave:
    anchors.left: lblChannel.left
    anchors.top: lblChannel.bottom
    margin-top: 12
    width: 95

  TextEdit
    id: commandEdit
    anchors.left: lblCommand.right
    anchors.right: parent.right
    anchors.top: lblCommand.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblItem
    text: Item para curar:
    anchors.left: lblChannel.left
    anchors.top: lblCommand.bottom
    margin-top: 14
    width: 95

  BotItem
    id: potItem
    anchors.left: lblItem.right
    anchors.top: lblItem.top
    margin-left: 8

  Label
    id: lblMinMana
    text: Mana min (%):
    anchors.left: lblChannel.left
    anchors.top: potItem.bottom
    margin-top: 10
    width: 95

  TextEdit
    id: minManaEdit
    anchors.left: lblMinMana.right
    anchors.right: parent.right
    anchors.top: lblMinMana.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblCooldown
    text: Repetir cada (seg):
    anchors.left: lblChannel.left
    anchors.top: lblMinMana.bottom
    margin-top: 12
    width: 95

  TextEdit
    id: cooldownEdit
    anchors.left: lblCooldown.right
    anchors.right: parent.right
    anchors.top: lblCooldown.top
    margin-left: 8
    margin-right: 12
    height: 21

  HorizontalSeparator
    id: sep1
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: lblCooldown.bottom
    margin-top: 14
    margin-left: 12
    margin-right: 12

  Label
    id: lblComboTitle
    text: -- Combo Guild --
    anchors.top: sep1.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 10
    text-align: center
    font: verdana-11px-rounded

  Label
    id: lblPrefix
    text: Prefijo:
    anchors.left: parent.left
    anchors.top: lblComboTitle.bottom
    margin-top: 14
    margin-left: 12
    width: 95

  TextEdit
    id: prefixEdit
    anchors.left: lblPrefix.right
    anchors.right: parent.right
    anchors.top: lblPrefix.top
    margin-left: 8
    margin-right: 12
    height: 21

  HorizontalSeparator
    id: sep2
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: lblPrefix.bottom
    margin-top: 14
    margin-left: 12
    margin-right: 12

  Label
    id: lblSpellTitle
    text: -- Combo Spell --
    anchors.top: sep2.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 10
    text-align: center
    font: verdana-11px-rounded

  Label
    id: lblLeader
    text: Leader(s):
    anchors.left: parent.left
    anchors.top: lblSpellTitle.bottom
    margin-top: 14
    margin-left: 12
    width: 95

  TextEdit
    id: leaderEdit
    anchors.left: lblLeader.right
    anchors.right: parent.right
    anchors.top: lblLeader.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblSpellUE
    text: SpellUE:
    anchors.left: lblLeader.left
    anchors.top: lblLeader.bottom
    margin-top: 12
    width: 95

  TextEdit
    id: spellUEEdit
    anchors.left: lblSpellUE.right
    anchors.right: parent.right
    anchors.top: lblSpellUE.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblSpellUE2
    text: SpellUE2:
    anchors.left: lblLeader.left
    anchors.top: lblSpellUE.bottom
    margin-top: 12
    width: 95

  TextEdit
    id: spellUE2Edit
    anchors.left: lblSpellUE2.right
    anchors.right: parent.right
    anchors.top: lblSpellUE2.top
    margin-left: 8
    margin-right: 12
    height: 21

  Label
    id: lblComboRune
    text: ComboRune:
    anchors.left: lblLeader.left
    anchors.top: lblSpellUE2.bottom
    margin-top: 14
    width: 95

  BotItem
    id: comboRuneItem
    anchors.left: lblComboRune.right
    anchors.top: lblComboRune.top
    margin-left: 8

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
    text: Pot + Combo
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("CombinedSetupWin")
win:hide()

ui.sw:setOn(potC.enabled and comboC.enabled and spellC.enabled)
ui.sw.onClick = function(w)
  local newState = not (potC.enabled and comboC.enabled and spellC.enabled)
  potC.enabled = newState
  comboC.enabled = newState
  spellC.enabled = newState
  w:setOn(newState)
end

local function refreshWindowFields()
  win.channelEdit:setText(potC.channelName)
  win.commandEdit:setText(potC.sayCommand)
  win.potItem:setItemId(potC.potItemId)
  win.minManaEdit:setText(tostring(potC.minMana))
  win.cooldownEdit:setText(tostring(potC.cooldownSeconds))
  win.prefixEdit:setText(comboC.prefix)
  win.leaderEdit:setText(spellC.leader)
  win.spellUEEdit:setText(spellC.spellUE)
  win.spellUE2Edit:setText(spellC.spellUE2)
  win.comboRuneItem:setItemId(spellC.runeId)
end

win.channelEdit.onTextChange = function(w, text) potC.channelName = text end
win.commandEdit.onTextChange = function(w, text) potC.sayCommand = text end
win.potItem.onItemChange = function(w) potC.potItemId = w:getItemId() end
win.minManaEdit.onTextChange = function(w, text) potC.minMana = tonumber(text) or potC.minMana end
win.cooldownEdit.onTextChange = function(w, text) potC.cooldownSeconds = tonumber(text) or potC.cooldownSeconds end
win.prefixEdit.onTextChange = function(w, text) comboC.prefix = text end
win.leaderEdit.onTextChange = function(w, text) spellC.leader = text end
win.spellUEEdit.onTextChange = function(w, text) spellC.spellUE = text end
win.spellUE2Edit.onTextChange = function(w, text) spellC.spellUE2 = text end
win.comboRuneItem.onItemChange = function(w) spellC.runeId = w:getItemId() end

win.closeButton.onClick = function()
  win:hide()
end

ui.setup.onClick = function()
  refreshWindowFields()
  win:show()
  win:raise()
  win:focus()
end

-- ---------------- LOGICA: POT FRIEND ----------------

onTalk(function(name, level, mode, text, channelId, pos)
  local cfg = storage.potFriend
  if not cfg or not cfg.enabled then return end

  local guildChannelId = getChannelId(cfg.channelName)
  if not guildChannelId or channelId ~= guildChannelId then
    return -- no vino del canal compartido, lo ignoramos
  end

  local lowerText = text:lower()
  if lowerText:find(cfg.sayCommand:lower()) then
    local creature = getCreatureByName(name)
    if not creature then
      return false
    end

    if creature:getEmblem() == 0 then
      useWith(cfg.potItemId, creature)
    end
  end
end)

macro(100, function()
  local cfg = storage.potFriend
  if not cfg or not cfg.enabled then return end

  local channelName = getChannelId(cfg.channelName)
  if manapercent() <= tonumber(cfg.minMana) then
    local cooldownMs = (tonumber(cfg.cooldownSeconds) or 3) * 1000
    if now - (cfg.lastSaidAt or 0) >= cooldownMs then
      sayChannel(channelName, cfg.sayCommand)
      cfg.lastSaidAt = now
    end
  end
end)

-- ---------------- LOGICA: COMBO GUILD ----------------

onTalk(function(name, level, mode, text, channelId, pos)
  local cfg = storage.comboGuild
  local potCfg = storage.potFriend
  if not cfg or not cfg.enabled then return end

  local guildChannelId = getChannelId(potCfg.channelName)
  if not guildChannelId or channelId ~= guildChannelId then
    return -- no vino del canal compartido, lo ignoramos
  end

  local prefixLen = #cfg.prefix
  if text:sub(1, prefixLen) == cfg.prefix then
    local target = getCreatureByName(text:sub(prefixLen + 1))
    if target and target:getPosition().z == posz() and target ~= g_game.getAttackingCreature() then
      g_game.attack(target)
    end
  end
end)

-- ---------------- LOGICA: COMBO SPELL (UE / UE2 / SD) ----------------

onTalk(function(name, level, mode, text, channelId, pos)
  local cfg = storage.comboSpellCombo
  local potCfg = storage.potFriend
  if not cfg or not cfg.enabled then return end

  local guildChannelId = getChannelId(potCfg.channelName)
  if not guildChannelId or channelId ~= guildChannelId then
    return -- no vino del canal compartido, lo ignoramos
  end

  local lowerName = name:lower()
  local isLeader = false
  for leaderName in (cfg.leader or ""):gmatch("[^;]+") do
    if leaderName:lower():gsub("^%s+", ""):gsub("%s+$", "") == lowerName then
      isLeader = true
      break
    end
  end
  if not isLeader then return end

  if text == "UE" then
    say(cfg.spellUE)
  elseif text == "UE2" then
    say(cfg.spellUE2)
  elseif text == "SD" then
    if g_game.isAttacking() then
      useWith(cfg.runeId, g_game.getAttackingCreature())
    end
  end
end)