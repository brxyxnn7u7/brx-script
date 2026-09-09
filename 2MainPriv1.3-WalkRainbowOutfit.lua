-- script
setDefaultTab("Main")

-- ======================================================================
--  TOOLS OUTFITS - COMBINADO
--  Junta todos los scripts de outfits/herramientas en UNA sola ventana,
--  con panel izquierdo y derecho (mismo estilo que New Combo Leader).
--
--  FIX aplicado: varios scripts originales usaban las mismas variables
--  GLOBALES (rainbowOutfit, changeColor) para cosas distintas. Como todos
--  los scripts corren en el mismo entorno Lua, el ultimo que se cargaba
--  pisaba al anterior y por eso se comportaban raro / se "autoactivaban".
--  Ahora cada script vive en su propio bloque do...end con nombres unicos
--  y variables locales, asi nunca mas se van a pisar entre si.
--
--  Por pedido: los outfit-changers quedan INDEPENDIENTES (no se apagan
--  entre si). Friend Outfit y Master Outfiter mantienen sus propias
--  ventanas de configuracion (boton Setup dentro del panel combinado).
-- ======================================================================

g_ui.loadUIFromString([[
ToolsOutfitsWindow < MainWindow
  !text: tr('Tools Outfits')
  size: 480 420
  padding: 25

  VerticalScrollBar
    id: contentScroll
    anchors.top: parent.top
    margin-top: 3
    anchors.right: parent.right
    anchors.bottom: separator.top
    step: 28
    pixels-scroll: true
    margin-right: -10
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
    maximum: 700
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

ToolsOutfitsWindow = UI.createWindow('ToolsOutfitsWindow', rootWidget)
ToolsOutfitsWindow:hide()
ToolsOutfitsWindow.closeButton.onClick = function(widget)
  ToolsOutfitsWindow:hide()
end

-- boton en la tab "Tools" que abre la ventana combinada
local mainUi = setupUI([[
Panel
  height: 19

  Button
    id: push
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 17
    text: Tools Outfits
]])

mainUi.push.onClick = function(widget)
  ToolsOutfitsWindow:show()
  ToolsOutfitsWindow:raise()
  ToolsOutfitsWindow:focus()
end

local leftPanel = ToolsOutfitsWindow.content.left
local rightPanel = ToolsOutfitsWindow.content.right

-- panel invisible que solo ocupa espacio, para separar secciones visualmente
local function addSpacerTools(dest, height)
  local spacer = UI.createWidget('Panel', dest)
  spacer:setHeight(height or 10)
end

-- ======================================================================
--  PANEL IZQUIERDO
-- ======================================================================

-- ---------------- DANCE ----------------
do
  macro(100, "Dance", function()
    turn(math.random(0, 3))
  end, leftPanel)
end

addSpacerTools(leftPanel, 6)

-- ---------------- FULL ADDON ----------------
do
  macro(100, "Full Addon", function()
    local myOutfit = player:getOutfit()
    if myOutfit.addons ~= 3 then
      myOutfit.addons = 3
      player:setOutfit(myOutfit)
    end
  end, leftPanel)
end

addSpacerTools(leftPanel, 6)

-- ---------------- CHANGE OUTFIT ----------------
do
  local looktypes = {
    {outfitID = 128, addons = 0}, {outfitID = 129, addons = 0}, {outfitID = 130, addons = 0},
    {outfitID = 131, addons = 0}, {outfitID = 132, addons = 0}, {outfitID = 133, addons = 0},
    {outfitID = 134, addons = 0}, {outfitID = 143, addons = 0}, {outfitID = 144, addons = 0},
    {outfitID = 145, addons = 0}, {outfitID = 146, addons = 0}, {outfitID = 151, addons = 0},
    {outfitID = 152, addons = 0}, {outfitID = 153, addons = 0}, {outfitID = 154, addons = 0},
    {outfitID = 251, addons = 0}, {outfitID = 268, addons = 0}, {outfitID = 273, addons = 0},
    {outfitID = 278, addons = 0}, {outfitID = 289, addons = 0}, {outfitID = 324, addons = 0},
    {outfitID = 335, addons = 0}, {outfitID = 366, addons = 0}, {outfitID = 136, addons = 0},
    {outfitID = 137, addons = 0}, {outfitID = 138, addons = 0}, {outfitID = 139, addons = 0},
    {outfitID = 140, addons = 0}, {outfitID = 141, addons = 0}, {outfitID = 142, addons = 0},
    {outfitID = 147, addons = 0}, {outfitID = 148, addons = 0}, {outfitID = 149, addons = 0},
    {outfitID = 150, addons = 0}, {outfitID = 155, addons = 0}, {outfitID = 156, addons = 0},
    {outfitID = 157, addons = 0}, {outfitID = 158, addons = 0}, {outfitID = 252, addons = 0},
    {outfitID = 269, addons = 0}, {outfitID = 270, addons = 0}, {outfitID = 279, addons = 0},
    {outfitID = 288, addons = 0}, {outfitID = 325, addons = 0}, {outfitID = 336, addons = 0},
    {outfitID = 367, addons = 0},
  }

  local outfit = { head = 2, body = 114, legs = 76, feet = 78 }
  local outfitIndex = 1

  macro(1100, "ChangeOutfit", function()
    local currentOutfit = looktypes[outfitIndex]

    outfit.type = currentOutfit.outfitID
    outfit.addons = currentOutfit.addons
    setOutfit(outfit)

    outfitIndex = outfitIndex + 1
    if outfitIndex > #looktypes then
      outfitIndex = 1
    end

    print("Cambiado a outfit: " .. outfit.type .. " addons: " .. outfit.addons)
  end, leftPanel)
end

addSpacerTools(leftPanel, 6)

-- ---------------- CHANGE OUTFIT + MOUNT ----------------
do
  local looktypes = {
    {outfitID = 128, addons = 0}, {outfitID = 129, addons = 0}, {outfitID = 130, addons = 0},
    {outfitID = 131, addons = 0}, {outfitID = 132, addons = 0}, {outfitID = 133, addons = 0},
    {outfitID = 134, addons = 0}, {outfitID = 143, addons = 0}, {outfitID = 144, addons = 0},
    {outfitID = 145, addons = 0}, {outfitID = 146, addons = 0}, {outfitID = 151, addons = 0},
    {outfitID = 152, addons = 0}, {outfitID = 153, addons = 0}, {outfitID = 154, addons = 0},
    {outfitID = 251, addons = 0}, {outfitID = 268, addons = 0}, {outfitID = 273, addons = 0},
    {outfitID = 278, addons = 0}, {outfitID = 289, addons = 0}, {outfitID = 324, addons = 0},
    {outfitID = 335, addons = 0}, {outfitID = 366, addons = 0},
  }

  local mounts = {
    {mountID = 369}, {mountID = 370}, {mountID = 371}, {mountID = 372}, {mountID = 387},
    {mountID = 388}, {mountID = 390}, {mountID = 392}, {mountID = 402}, {mountID = 405},
    {mountID = 447}, {mountID = 450}, {mountID = 506}, {mountID = 571},
  }

  local outfit = { head = 2, body = 67, legs = 76, feet = 0, mount = mounts[1].mountID }
  local outfitIndex = 1
  local mountIndex = 1

  macro(1100, "ChangeOutfit+Mount", function()
    local currentOutfit = looktypes[outfitIndex]
    local currentMount = mounts[mountIndex]

    outfit.type = currentOutfit.outfitID
    outfit.addons = currentOutfit.addons
    setOutfit(outfit)

    outfit.mount = currentMount.mountID
    setOutfit(outfit)

    outfitIndex = outfitIndex + 1
    if outfitIndex > #looktypes then
      outfitIndex = 1
    end

    mountIndex = mountIndex + 1
    if mountIndex > #mounts then
      mountIndex = 1
    end

    print("Cambiado a outfit: " .. outfit.type .. " addons: " .. outfit.addons .. " y a la montura: " .. outfit.mount)
  end, leftPanel)
end

addSpacerTools(leftPanel, 6)

-- ---------------- RAINBOW FULL ----------------
do
  macro(70, "R-Full", function()
    local randomColor = math.random(1, 132)
    local pOutfit = player:getOutfit()
    local newOutfit = { type = pOutfit.type, head = randomColor, body = randomColor, legs = randomColor, feet = randomColor, addons = pOutfit.addons }
    setOutfit(newOutfit)
  end, leftPanel)
end

addSpacerTools(leftPanel, 6)

-- ---------------- WALK RAINBOW OUTFIT ----------------
do
  local s = {}

  s.color = {
    first = 77, -- min: 1
    last = 94,  -- max: 133
    sets = {}
  }
  s.parts = {"head", "body", "legs", "feet"}
  s.setIndex = 1

  for i = s.color.first, s.color.last - 3 do
    local set = {}
    for j = i, i + 3 do
      table.insert(set, j)
    end
    table.insert(s.color.sets, set)
  end

  s.m_main = macro(10000, "Walk Rainbow Outfit", function(m) end, leftPanel)

  onPlayerPositionChange(function(newPos, oldPos)
    if s.m_main.isOff() then return end

    s.playerOutfit = player:getOutfit()

    if s.setIndex > #s.color.sets then
      s.setIndex = 1
    end

    local currentSet = s.color.sets[s.setIndex]

    for i, part in ipairs(s.parts) do
      s.playerOutfit[part] = currentSet[i]
    end

    setOutfit(s.playerOutfit)

    s.setIndex = s.setIndex + 1
  end)
end

-- ======================================================================
--  PANEL DERECHO
-- ======================================================================

-- ---------------- R-FAVORITE COLORS ----------------
do
  local colors = {0, 78, 113, 114, 124}
  local rainbowOutfitTime = 1100

  macro(rainbowOutfitTime, "R-FavoriteColors", function()
    local headColor = colors[math.random(#colors)]
    local feetColor = colors[math.random(#colors)]
    local bodyColor = colors[math.random(#colors)]
    local legsColor = colors[math.random(#colors)]
    local pOutfit = player:getOutfit()
    local newOutfit = { type = pOutfit.type, head = headColor, body = bodyColor, legs = legsColor, feet = feetColor, addons = pOutfit.addons }
    setOutfit(newOutfit)
  end, rightPanel)
end

addSpacerTools(rightPanel, 6)

-- ---------------- RAINBOW CAMBIOS 1 (Gold1) ----------------
do
  local rainbowOutfitTime = 1100
  local colorIndex = 1

  local function changeColorGold1()
    local pOutfit = player:getOutfit()
    local c195 = { type = pOutfit.type, head = 115, body = 95, legs = 95, feet = 124, addons = pOutfit.addons }
    local c196 = { type = pOutfit.type, head = 115, body = 95, legs = 124, feet = 95, addons = pOutfit.addons }
    local c197 = { type = pOutfit.type, head = 115, body = 124, legs = 95, feet = 95, addons = pOutfit.addons }
    local c198 = { type = pOutfit.type, head = 124, body = 95, legs = 95, feet = 95, addons = pOutfit.addons }
    local camcolor = {c195, c196, c197, c198}
    local cambiocolor = camcolor[colorIndex]
    setOutfit(cambiocolor)
    colorIndex = colorIndex + 1
    if colorIndex > #camcolor then
      colorIndex = 1
    end
  end

  macro(rainbowOutfitTime, "Rainbow cambios1", function()
    changeColorGold1()
  end, rightPanel)
end

addSpacerTools(rightPanel, 6)

-- ---------------- RAINBOW CAMBIOS 8 (Gold8) ----------------
do
  local rainbowOutfitTime = 1100
  local colorIndex = 1
  local cabello = 116 -- Cafe
  local basee = 0     -- Blanco
  local color1 = 77   -- Naranja
  local color2 = 79   -- Amarillo
  local color3 = 81   -- Verde
  local color4 = 85   -- Azul
  local color5 = 87   -- Azulrey
  local color6 = 89   -- Morado
  local color7 = 91   -- Rosa
  local color8 = 94   -- Rojo

  local function changeColorGold8()
    local pOutfit = player:getOutfit()
    local c160 = { type = pOutfit.type, head = color1, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c161 = { type = pOutfit.type, head = cabello, body = color1, legs = basee, feet = basee, addons = pOutfit.addons }
    local c162 = { type = pOutfit.type, head = cabello, body = basee, legs = color1, feet = basee, addons = pOutfit.addons }
    local c163 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color1, addons = pOutfit.addons }
    local c164 = { type = pOutfit.type, head = color2, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c165 = { type = pOutfit.type, head = cabello, body = color2, legs = basee, feet = basee, addons = pOutfit.addons }
    local c166 = { type = pOutfit.type, head = cabello, body = basee, legs = color2, feet = basee, addons = pOutfit.addons }
    local c167 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color2, addons = pOutfit.addons }
    local c168 = { type = pOutfit.type, head = color3, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c169 = { type = pOutfit.type, head = cabello, body = color3, legs = basee, feet = basee, addons = pOutfit.addons }
    local c170 = { type = pOutfit.type, head = cabello, body = basee, legs = color3, feet = basee, addons = pOutfit.addons }
    local c171 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color3, addons = pOutfit.addons }
    local c172 = { type = pOutfit.type, head = color4, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c173 = { type = pOutfit.type, head = cabello, body = color4, legs = basee, feet = basee, addons = pOutfit.addons }
    local c174 = { type = pOutfit.type, head = cabello, body = basee, legs = color4, feet = basee, addons = pOutfit.addons }
    local c175 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color4, addons = pOutfit.addons }
    local c176 = { type = pOutfit.type, head = color5, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c177 = { type = pOutfit.type, head = cabello, body = color5, legs = basee, feet = basee, addons = pOutfit.addons }
    local c178 = { type = pOutfit.type, head = cabello, body = basee, legs = color5, feet = basee, addons = pOutfit.addons }
    local c179 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color5, addons = pOutfit.addons }
    local c180 = { type = pOutfit.type, head = color6, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c181 = { type = pOutfit.type, head = cabello, body = color6, legs = basee, feet = basee, addons = pOutfit.addons }
    local c182 = { type = pOutfit.type, head = cabello, body = basee, legs = color6, feet = basee, addons = pOutfit.addons }
    local c183 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color6, addons = pOutfit.addons }
    local c184 = { type = pOutfit.type, head = color7, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c185 = { type = pOutfit.type, head = cabello, body = color7, legs = basee, feet = basee, addons = pOutfit.addons }
    local c186 = { type = pOutfit.type, head = cabello, body = basee, legs = color7, feet = basee, addons = pOutfit.addons }
    local c187 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color7, addons = pOutfit.addons }
    local c188 = { type = pOutfit.type, head = color8, body = basee, legs = basee, feet = basee, addons = pOutfit.addons }
    local c189 = { type = pOutfit.type, head = cabello, body = color8, legs = basee, feet = basee, addons = pOutfit.addons }
    local c190 = { type = pOutfit.type, head = cabello, body = basee, legs = color8, feet = basee, addons = pOutfit.addons }
    local c191 = { type = pOutfit.type, head = cabello, body = basee, legs = basee, feet = color8, addons = pOutfit.addons }
    local camcolor = {c160, c161, c162, c163, c164, c165, c166, c167, c168, c169, c170, c171, c172, c173, c174, c175, c176, c177, c178, c179, c180, c181, c182, c183, c184, c185, c186, c187, c188, c189, c190, c191}
    local cambiocolor = camcolor[colorIndex]
    setOutfit(cambiocolor)
    colorIndex = colorIndex + 1
    if colorIndex > #camcolor then
      colorIndex = 1
    end
  end

  macro(rainbowOutfitTime, "Rainbow cambios8", function()
    changeColorGold8()
  end, rightPanel)
end

addSpacerTools(rightPanel, 6)

-- ---------------- BLACK & WHITE OUTFIT ----------------
do
  storage.bwOutfit = storage.bwOutfit or { increasing = true, colors = {3, 2, 1, 0} }
  local bw = storage.bwOutfit

  macro(100, "Black e White Outfit", function()
    local lastColor = bw.colors[1]
    local baseColor = 0
    local gap = 19

    if lastColor == 6 then
      bw.increasing = false
    elseif lastColor == 0 and not bw.increasing then
      bw.increasing = true
    end

    if bw.increasing then
      table.insert(bw.colors, 1, lastColor + 1)
      table.remove(bw.colors, 5)
    else
      table.insert(bw.colors, 1, lastColor - 1)
      table.remove(bw.colors, 5)
    end

    local head = bw.colors[1] * gap + baseColor
    local body = bw.colors[2] * gap + baseColor
    local legs = bw.colors[3] * gap + baseColor
    local feet = bw.colors[4] * gap + baseColor

    local pOutfit = player:getOutfit()
    local newColors = { type = pOutfit.type, head = head, body = body, legs = legs, feet = feet, addons = pOutfit.addons, mount = pOutfit.mount }
    setOutfit(newColors)
  end, rightPanel)
end

addSpacerTools(rightPanel, 10)

-- ---------------- FRIEND OUTFIT LOOKTYPE ----------------
do
  local targetColorName = "targetcolor"
  if not storage[targetColorName] then
    storage[targetColorName] = { outfitNumber = 35, enabled = false }
  end
  local c = storage[targetColorName]

  storage.playerList = storage.playerList or {}
  storage.playerList.friendList = storage.playerList.friendList or {}

  local function displayMessages()
    local messages = {
      "-LOOK TYPES-",
      "> 12 archdemon", "> 35 demon", "> 75 gamemaster1", "> 127 retrocitizen",
      "> 194 cult", "> 226 frog", "> 229 ferumbras", "> 230 hand",
      "> 253 axeman", "> 254 svorenthemad", "> 266 gamemaster2", "> 300 grimreaper",
      "> 302 god", "> 306 skullguard", "> 309 yalaharia", "> 332 king",
      "> 333 stoneman", "> 345 lizardguard",
      "> No olvides agregar tu nombre y el de tus aliados en -Player List / Friends-",
      "--Leer el Server Log By: Brxyxnn--"
    }
    for _, message in ipairs(messages) do
      modules.game_textmessage.displayGameMessage(message)
    end
  end

  g_ui.loadUIFromString([[
FriendOutfitWin < MainWindow
  text: Friend Outfit Looktype
  size: 300 150
  @onEscape: self:hide()

  Label
    id: lblOutfit
    text: Numero de Outfit:
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-left: 12
    width: 100

  TextEdit
    id: outfitEdit
    anchors.left: lblOutfit.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 8
    margin-right: 12
    margin-top: 10
    height: 21

  Button
    id: listButton
    text: Ver lista de looktypes
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: lblOutfit.bottom
    margin-left: 12
    margin-right: 12
    margin-top: 16
    height: 22

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
    text: Friend Outfit
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]], rightPanel)

  local win = UI.createWindow("FriendOutfitWin")
  win:hide()

  ui.sw:setOn(c.enabled)
  ui.sw.onClick = function(w)
    c.enabled = not c.enabled
    w:setOn(c.enabled)
  end

  win.outfitEdit:setText(tostring(c.outfitNumber))
  win.outfitEdit.onTextChange = function(w, text)
    c.outfitNumber = tonumber(text) or c.outfitNumber
  end

  win.listButton.onClick = function()
    displayMessages()
  end

  win.closeButton.onClick = function()
    win:hide()
  end

  ui.setup.onClick = function()
    win.outfitEdit:setText(tostring(c.outfitNumber))
    win:show()
    win:raise()
    win:focus()
  end

  macro(100, function()
    local cfg = storage[targetColorName]
    if not cfg or not cfg.enabled then return end

    local outfitNumber = cfg.outfitNumber
    local specs = getSpectators()

    for _, spec in ipairs(specs) do
      if spec:isPlayer() then
        local playerName = spec:getName()
        if table.contains(storage.playerList.friendList, playerName) then
          local specOutfit = spec:getOutfit()
          specOutfit.type = outfitNumber
          spec:setOutfit(specOutfit)
        end
      end
    end
  end)
end

addSpacerTools(rightPanel, 10)

-- ---------------- MASTER OUTFITER ----------------
do
  local panelName = "MasterOutfiter"

  if not storage[panelName] then
    storage[panelName] = {}
  end

  local config = storage[panelName]

  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Master Outfiter')

  Button
    id: push
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], rightPanel)

  g_ui.loadUIFromString([[
MobOutfitWindow < MainWindow
  !text: tr('Master Outfiter, Made by: VivoDibra')
  size: 1024 750
  @onEscape: self:hide()

  Panel
    id: itemList
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.bottom: separator.top
    anchors.top: parent.top
    layout:
      type: grid
      cell-size: 80 80
      flow: true

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  Button
    id: backButton
    !text: tr('Back')
    font: cipsoftFont
    anchors.left: parent.left
    anchors.bottom: parent.bottom

  Button
    id: nextButton
    !text: tr('Next')
    font: cipsoftFont
    anchors.left: backButton.right
    anchors.bottom: parent.bottom

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom

  Label
    id: page
    text: 500/30000
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    width:100

OutfitWidget < UIWidget
  size: 80 80
  margin-left: 2
  layout: verticalBox

  UICreature
    id: creature
    size: 60 60
    phantom: true

  Button
    id: select
    text: select
    size: 50 20
]])

  local MobOutfitWindow = UI.createWindow('MobOutfitWindow', g_ui.getRootWidget())

  if not config.type then
    config.type = player:getOutfit().type
  end

  local function setPlayerOutfit()
    if not config.enabled then return end
    local baseOutfit = player:getOutfit()
    if baseOutfit.type == config.type then return end
    baseOutfit.type = config.type
    baseOutfit.addons = 3
    player:setOutfit(baseOutfit)
    modules.game_interface.getRootPanel():focus()
  end

  local function addOutfit(id)
    local widget = UI.createWidget("OutfitWidget", MobOutfitWindow.itemList)
    widget.select.onClick = function()
      config.type = id
      setPlayerOutfit()
    end
    local tempOutfit = player:getOutfit()
    tempOutfit.type = id
    tempOutfit.addons = 3
    widget.creature:setOutfit(tempOutfit)
  end

  onPlayerPositionChange(function()
    setPlayerOutfit()
  end)

  setPlayerOutfit()

  MobOutfitWindow:hide()

  ui.push.onClick = function()
    MobOutfitWindow:show()
    MobOutfitWindow:raise()
    MobOutfitWindow:focus()
  end

  ui.title:setOn(config.enabled)
  ui.title.onClick = function(widget)
    config.enabled = not config.enabled
    widget:setOn(config.enabled)
  end

  local firstPage = 0
  local lastPage = 2000
  local pageSize = 95
  local currentPage = firstPage

  local function setOutfits()
    MobOutfitWindow.itemList:destroyChildren()
    for i = currentPage, (currentPage + pageSize) do
      addOutfit(i)
    end
    MobOutfitWindow.page:setText(currentPage .. "/" .. lastPage)
  end

  MobOutfitWindow.closeButton.onClick = function(widget)
    MobOutfitWindow:hide()
  end

  MobOutfitWindow.backButton.onClick = function(widget)
    if currentPage > firstPage then
      currentPage = currentPage - pageSize
      setOutfits()
    end
  end

  MobOutfitWindow.nextButton.onClick = function(widget)
    if currentPage < lastPage then
      currentPage = currentPage + pageSize
      setOutfits()
    end
  end

  setOutfits()

  local directionCounter = 0
  macro(500, function()
    if not config.enabled or not MobOutfitWindow:isVisible() then return end
    for _, wdg in ipairs(MobOutfitWindow.itemList:getChildren()) do
      wdg.creature:setDirection(directionCounter)
    end
    directionCounter = directionCounter + 1
    if directionCounter > 3 then
      directionCounter = 0
    end
  end)
end
