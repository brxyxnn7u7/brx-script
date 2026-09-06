setDefaultTab("Main")

if not storage.NewComboLeader then
  storage.NewComboLeader = {}
end

local settings = storage.NewComboLeader

if settings.enabled == nil then
  settings.enabled = true
end

if not settings.sdMissle then
  settings.sdMissle = 32
end

if not settings.AttackEnemiesHK then
  settings.AttackEnemiesHK = "f5"
end

-- migrate old single-slot combo UE settings to the new UE1 slot, so existing configs are not lost
if settings.LeaderSpell and not settings.LeaderSpell1 then
  settings.LeaderSpell1 = settings.LeaderSpell
end
if settings.UE and not settings.UE1 then
  settings.UE1 = settings.UE
end

local function trim(s)
  return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

-- settings.LeaderName can hold one or more names separated by ";" e.g. "Brxyxnn;Silent Killer"
local function isLeader(name)
  if not settings.LeaderName or settings.LeaderName == "" then return false end
  if not name then return false end
  name = trim(name):lower()
  for leaderName in settings.LeaderName:gmatch("[^;]+") do
    if trim(leaderName):lower() == name then
      return true
    end
  end
  return false
end

-- ---------------- POT FRIEND ----------------
-- (usa getChannelId() y manapercent(), que ya confirmamos que existen
-- en tu framework, en vez de las funciones inventadas de antes)

local lastPotTime = {}
local lastAskedAt = 0

g_ui.loadUIFromString([[
NewComboLeaderTextEdit < Panel
  height: 40

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    
  TextEdit
    id: textEdit
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 10
    step: 1
    text-align: center

NewComboLeaderItem < Panel
  height: 34
  margin-top: 7
  margin-left: 25
  margin-right: 25

  UIWidget
    id: text
    anchors.left: parent.left
    anchors.verticalCenter: next.verticalCenter

  BotItem
    id: item
    anchors.top: parent.top
    anchors.right: parent.right


NewComboLeaderWindow < MainWindow
  !text: tr('NewComboLeader')
  size: 440 360
  padding: 25

  Label
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center

  Label
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center

  VerticalScrollBar
    id: contentScroll
    anchors.top: prev.bottom
    margin-top: 3
    anchors.right: parent.right
    anchors.bottom: separator.top
    step: 28
    pixels-scroll: true
    margin-right: -10
    margin-top: 5
    margin-bottom: 5

  ScrollablePanel
    id: content
    anchors.top: prev.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    vertical-scrollbar: contentScroll
    margin-bottom: 10
      
    Panel
      id: left
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.horizontalCenter
      margin-top: 5
      margin-left: 10
      margin-right: 10
      layout:
        type: verticalBox
        fit-children: true

    Panel
      id: right
      anchors.top: parent.top
      anchors.left: parent.horizontalCenter
      anchors.right: parent.right
      margin-top: 5
      margin-left: 10
      margin-right: 10
      layout:
        type: verticalBox
        fit-children: true

    VerticalSeparator
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.horizontalCenter

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  ResizeBorder
    id: bottomResizeBorder
    anchors.fill: separator
    height: 3
    minimum: 260
    maximum: 600
    margin-left: 3
    margin-right: 3
    background: #ffffff88    

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5
]])

-- basic elements
NewComboLeaderWindow = UI.createWindow('NewComboLeaderWindow', rootWidget)
NewComboLeaderWindow:hide()
NewComboLeaderWindow.closeButton.onClick = function(widget)
  NewComboLeaderWindow:hide()
end

NewComboLeaderWindow:setHeight(350)
NewComboLeaderWindow:setWidth(450)
NewComboLeaderWindow:setText("New Combo Leader")

local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('New Combo Leader')

  Button
    id: push
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

]])

ui.title:setOn(settings.enabled)
ui.title.onClick = function(widget)
  settings.enabled = not settings.enabled
  widget:setOn(settings.enabled)
end

ui.push.onClick = function(widget)
  NewComboLeaderWindow:show()
  NewComboLeaderWindow:raise()
  NewComboLeaderWindow:focus()
end

-- available options for dest param
local rightPanel = NewComboLeaderWindow.content.right
local leftPanel = NewComboLeaderWindow.content.left

-- objects made by Kondrah - taken from creature editor, minor changes to adapt
local addItem = function(id, title, defaultItem, dest, tooltip)
  local widget = UI.createWidget('NewComboLeaderItem', dest)
  widget.text:setText(title)
  widget.text:setTooltip(tooltip)
  widget.item:setTooltip(tooltip)
  widget.item:setItemId(settings[id] or defaultItem)
  widget.item.onItemChange = function(widget)
    settings[id] = widget:getItemId()
  end
  settings[id] = settings[id] or defaultItem
end

local addTextEdit = function(id, title, defaultValue, dest, tooltip)
  local widget = UI.createWidget('NewComboLeaderTextEdit', dest)
  widget.text:setText(title)
  widget.textEdit:setText(settings[id] or defaultValue or "")
  widget.text:setTooltip(tooltip)
  widget.textEdit.onTextChange = function(widget,text)
    settings[id] = trim(text)
  end
  settings[id] = settings[id] or defaultValue or ""
end

-- panel invisible que solo ocupa espacio, para separar secciones visualmente
local addSpacer = function(dest, height)
  local spacer = UI.createWidget('Panel', dest)
  spacer:setHeight(height or 12)
end

local m_leaderTarget = macro(10000, "Leader Target", function() end, leftPanel)
local m_comboSD = macro(10000, "Combo Rune", function() end, leftPanel)
local m_comboSpell = macro(10000, "Combo UE", function() end, leftPanel)

hotkey(settings.AttackEnemiesHK, "Attack Enemy Listed",function()
  if g_game.isAttacking() then return end
  
  local enemies = {}
  for _, enemyName in ipairs(storage.playerList.enemyList) do
    local enemy = getCreatureByName(enemyName)
    if enemy then
      local enemyT = g_map.getTile(enemy:getPosition())
      if enemyT:canShoot() then
        table.insert(enemies, enemy)
      end
    end
  end
  
  table.sort(enemies, function(a, b)
    local distA = getDistanceBetween(a:getPosition(), pos())
    local distB = getDistanceBetween(b:getPosition(), pos())
    return distA < distB
  end)
  
  local t = enemies[1]
  if t then
    g_game.attack(t)
  end
end, leftPanel)

addTextEdit("LeaderName", "Leader(s)", settings.LeaderName or "name", rightPanel, "Separate multiple leader names with ';' e.g. Brxyxnn;Supeer")

addTextEdit("LeaderSpell1", "Leader UE1", settings.LeaderSpell1 or "exevo gran mas frigo", rightPanel, "Spell que tira el lider para activar UE1")

addTextEdit("UE1", "Your UE1", settings.UE1 or "exevo gran mas frigo", rightPanel, "Spell que usaras cuando el lider tire combo1")

addTextEdit("LeaderSpell2", "Leader UE2", settings.LeaderSpell2 or "", rightPanel, "Spell que tirara lider para activar UE2")

addTextEdit("UE2", "Your UE2", settings.UE2 or "", rightPanel, "Spell que usaras cuando el lider tire combo2")

addTextEdit("AttackEnemiesHK", "Attack Enemies HK", "f5", rightPanel, "Atacas en pantalla a tu enemylist")

addItem("SD", "Rune", 3155, leftPanel, "")

local m_configRune = macro(10000, "Config Rune", function() end, leftPanel)

addLabel("","Para configurar la combinacion de runas, activa la macro 'Config Rune' y pide al lider que use la runa sobre cualquier objetivo; NO ataques, solo usa la runa :)", leftPanel)

-- ---------------- POT FRIEND ----------------
addSpacer(leftPanel, 85)

local m_potFriend = macro(10000, "Pot Friend", function() end, leftPanel)

addSpacer(leftPanel, 8)

addItem("PotItem", "Item para curar", 3160, leftPanel, "Item que se va a usar sobre el amigo (pocion, runa, etc)")

addSpacer(rightPanel, 50)

addTextEdit("PotChannel", "Canal", settings.PotChannel or "Party", rightPanel, "Nombre exacto del canal donde el amigo escribe la palabra clave (ej: Party)")

addTextEdit("PotKeyword", "Palabra clave", settings.PotKeyword or "pp", rightPanel, "Palabra que el amigo debe escribir en ese canal para pedir cura")

addTextEdit("PotManaMin", "Mana min (%)", settings.PotManaMin or "40", rightPanel, "No va a curar si tu mana esta por debajo de este porcentaje")

addTextEdit("PotInterval", "Repetir cada (seg)", settings.PotInterval or "3", rightPanel, "Tiempo minimo entre curas al mismo jugador, para no gastar de mas")

-- ---------------- AUTO PARTY ----------------
addSpacer(leftPanel, 14)

local m_autoParty = macro(10000, "Auto Party", function() end, leftPanel)

addLabel("","Si sos lider (emblema amarillo) invita a tu friend list a la party, y acepta invitaciones automaticamente.", leftPanel)

--inspired by vbot 4.8 combo
onMissle(function(missle)
  if not settings.enabled then return end
  local src = missle:getSource()
  if src.z ~= posz() then return end
  
  local from = g_map.getTile(src)
  local to = g_map.getTile(missle:getDestination())
  if not from or not to then return end
  
  local fromCreatures = from:getCreatures()
  local toCreatures = to:getCreatures()
  if #fromCreatures ~= 1 or #toCreatures ~= 1 then return end
  
  local c1 = fromCreatures[1]
  local t1 = toCreatures[1]
  
  if isLeader(t1:getName()) then return end
  if table.find(storage.playerList.friendList, t1:getName(), true) then return end
  
  if isLeader(c1:getName()) then
    if m_configRune.isOn() then
      settings.sdMissle = missle:getId()      
      modules.game_textmessage.displayGameMessage("Rune Combo Configurado Carnal.")
      m_configRune:setOff()
    else
      if m_leaderTarget:isOn() then
        local target = g_game.getAttackingCreature()
        if not target or target ~= t1 then
          g_game.attack(t1)
          schedule(1000, function()
            g_game.cancelAttackAndFollow()
          end)
        end
      end
      if m_comboSD.isOn() and missle:getId() == settings.sdMissle then
        useWith(settings.SD, t1)
      end
    end
  end
end)

onTalk(function(name, level, mode, text, channelId, pos) 
  if not settings.enabled then return end
  if not m_comboSpell.isOn() then return end
  if not isLeader(name) then return end

  local spokenText = trim(text):lower()

  if settings.LeaderSpell1 ~= "" and spokenText == trim(settings.LeaderSpell1):lower() then
    say(settings.UE1)
  elseif settings.LeaderSpell2 ~= "" and spokenText == trim(settings.LeaderSpell2):lower() then
    say(settings.UE2)
  end
end)

-- ---------------- POT FRIEND ----------------
onTalk(function(name, level, mode, text, channelId, pos)
  if not settings.enabled then return end
  if not m_potFriend.isOn() then return end

  local targetChannelId = getChannelId(settings.PotChannel)
  if not targetChannelId or channelId ~= targetChannelId then return end

  local keyword = trim(settings.PotKeyword or ""):lower()
  if keyword == "" then return end
  if not trim(text):lower():find(keyword, 1, true) then return end

  local interval = tonumber(settings.PotInterval) or 3
  local cooldownMs = interval * 1000
  if lastPotTime[name] and (now - lastPotTime[name]) < cooldownMs then
    return -- todavia en cooldown para este jugador
  end

  local manaMin = tonumber(settings.PotManaMin) or 0
  if manapercent() < manaMin then
    return -- no tenes suficiente mana para curar
  end

  local friend = getCreatureByName(name)
  if not friend then return end

  -- cura 3 veces, 1 vez por segundo (0s, 1s y 2s)
  local healName = name
  local function healOnce()
    local target = getCreatureByName(healName)
    if target then
      useWith(settings.PotItem, target)
    end
  end

  healOnce()
  schedule(1000, healOnce)
  schedule(2000, healOnce)

  lastPotTime[name] = now
end)

-- si a VOS se te baja el mana, pedis ayuda diciendo la palabra clave en el
-- mismo canal (igual que hacia tu script viejo)
macro(100, function()
  if not settings.enabled then return end
  if not m_potFriend.isOn() then return end

  local targetChannelId = getChannelId(settings.PotChannel)
  if not targetChannelId then return end

  local manaMin = tonumber(settings.PotManaMin) or 0
  if manapercent() > manaMin then return end -- tenes mana de sobra, no pedis ayuda

  local cooldownMs = (tonumber(settings.PotInterval) or 3) * 1000
  if now - lastAskedAt < cooldownMs then return end

  sayChannel(targetChannelId, settings.PotKeyword)
  lastAskedAt = now
end)

-- ---------------- AUTO PARTY ----------------
-- valores de shield confirmados con tus pruebas reales:
-- 4 = sos vos, lider, con party ya armada
-- 1 = visto desde el invitado: es el lider que TE invito
-- 2 = visto desde el lider: alguien a quien VOS ya invitaste
local SHIELD_LEADER = 4
local SHIELD_INVITED_BY_OTHER = 1
local SHIELD_INVITED_BY_ME = 2
local AUTO_PARTY_MAX_DIST = 5

-- 1) si sos lider, invita a los que tenes en tu friend list
macro(1000, function()
  if not settings.enabled then return end
  if not m_autoParty.isOn() then return end
  if player:getShield() ~= SHIELD_LEADER then return end

  for _, spec in ipairs(getSpectators(posz())) do
    if spec:isPlayer() and spec ~= player
      and table.find(storage.playerList.friendList, spec:getName(), true)
      and not spec:isPartyMember()
      and spec:getShield() ~= SHIELD_INVITED_BY_ME
      and getDistanceBetween(spec:getPosition(), pos()) <= AUTO_PARTY_MAX_DIST then
      g_game.partyInvite(spec:getId())
      break
    end
  end
end)

-- 2) si alguien te invita, aceptar automaticamente
macro(1000, function()
  if not settings.enabled then return end
  if not m_autoParty.isOn() then return end
  if player:isPartyMember() then return end

  for _, spec in ipairs(getSpectators(posz())) do
    if spec:isPlayer() and spec ~= player and spec:getShield() == SHIELD_INVITED_BY_OTHER then
      g_game.partyJoin(spec:getId())
      break
    end
  end
end)

-- ---------------- AUTO OPEN PARTY CHANNEL ----------------
-- basado en la API real de OTClient: le pedimos al server la lista de
-- canales disponibles, y cuando responde nos unimos a Party.
local partyChannelJoined = false

local function openAutoChannels(channelList)
  for _, channel in pairs(channelList) do
    local channelId = channel[1]
    local channelName = channel[2]
    if channelName then
      local lname = channelName:lower()
      if lname == "party" or lname == "party channel" then
        g_game.joinChannel(channelId)
        partyChannelJoined = true
      end
    end
  end
end

if type(onChannelList) == "function" then
  onChannelList(openAutoChannels)
else
  g_game.onChannelList = openAutoChannels
end

-- pide la lista de canales solo mientras estas en una party y todavia no
-- se unio (g_game.requestChannels() es la misma funcion que abre el
-- dialogo de "Channels", por eso NO la llamamos sin parar)
macro(5000, function()
  if not settings.enabled then return end
  if not m_autoParty.isOn() then return end
  if not g_game.isOnline() then return end

  if not player:isPartyMember() then
    partyChannelJoined = false -- si salis de la party, reintentamos la proxima vez
    return
  end
  if partyChannelJoined then return end

  g_game.requestChannels()
end)
