setDefaultTab("HP")
-- ======================================================
--  CONTADOR + AUTO-CAST DE UTAMO VITA (Magic Shield) - Tibia 8.6
--
--  Icono "Utamo Vita" para prender/apagar. Mientras esta prendido:
--  - Si el contador no esta corriendo, dice "utamo vita" enseguida.
--  - Cuando el contador llega a 0 (se vencio el shield), lo vuelve
--    a decir automaticamente, y el ciclo se repite solo.
--
--  El contador visual sigue funcionando exactamente igual que
--  antes (se sincroniza cada vez que detecta que dijiste "utamo",
--  sea automatico o manual).
-- ======================================================

local UTAMO_DURATION = 190 -- segundos (ajustado a pedido, 8.6 clasico seria 200)

-- POSICION DEL PANEL: cambia estos dos numeros a tu gusto para moverlo.
-- POS_X = distancia en pixeles desde el borde IZQUIERDO de la pantalla.
-- POS_Y = distancia en pixeles desde el borde SUPERIOR de la pantalla.
local POS_X = 1405
local POS_Y = 370

local timerState = {
  remaining = 0,
  active = false
}

local autoEnabled = false
local awaitingCast = false
local RETRY_INTERVAL_MS = 1500 -- reintenta cada 1.5 segundos hasta confirmar el cast

local ui = setupUI(string.format([[
Panel
  id: utamoTimerPanel
  height: 20
  width: 140
  clipping: false
  anchors.top: parent.top
  anchors.left: parent.left
  margin-left: %d
  margin-top: %d
  Label
    id: lblUtamoTimer
    text: UtamoVita: --
    color: #58D68D
    font: verdana-11px-rounded
    text-align: center
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
]], POS_X, POS_Y), modules.game_interface.getMapPanel())

local function updateLabel()
  if timerState.active then
    ui.lblUtamoTimer:setText("UtamoVita: " .. timerState.remaining .. "s")
    if timerState.remaining <= 20 then
      ui.lblUtamoTimer:setColor("#E74C3C") -- rojo, se esta por acabar
    else
      ui.lblUtamoTimer:setColor("#58D68D") -- verde, activo
    end
  else
    ui.lblUtamoTimer:setText("UtamoVita: --")
    ui.lblUtamoTimer:setColor("#AAAAAA")
  end
end

local function attemptCast()
  if not autoEnabled or not awaitingCast then
    return -- se apago el switch o ya se confirmo el cast, cortamos los reintentos
  end
  say("utamo vita")
  schedule(RETRY_INTERVAL_MS, attemptCast)
end

local function requestCast()
  awaitingCast = true
  attemptCast()
end

local function startTimer()
  timerState.remaining = UTAMO_DURATION
  timerState.active = true
  updateLabel()
end

local function tick()
  if timerState.active then
    timerState.remaining = timerState.remaining - 1
    if timerState.remaining <= 0 then
      timerState.remaining = 0
      timerState.active = false

      -- se vencio el shield: si el auto-cast esta prendido, insistimos
      -- hasta que confirmemos que lo dijimos de verdad
      if autoEnabled then
        requestCast()
      end
    end
    updateLabel()
  end
  schedule(1000, tick)
end
tick()

-- ---------------- SWITCH ON/OFF ----------------

local switchUi = setupUI([[
Panel
  height: 20
  BotSwitch
    id: sw
    anchors.left: parent.left
    anchors.top: parent.top
    width: 130
    text: Utamo Vita
]])

switchUi.sw.onClick = function(w)
  autoEnabled = not autoEnabled
  w:setOn(autoEnabled)

  -- si lo prendes y no hay shield activo en este momento, insistimos
  -- hasta que confirmemos que lo dijimos de verdad
  if autoEnabled and not timerState.active then
    requestCast()
  end
end

-- Detecta cuando VOS decis "utamo vita" (o solo "utamo") en el chat.
-- Funciona tanto si lo dijo el auto-cast como si lo escribiste vos a mano.
-- channelId == 0 es el canal de mensajes locales/default en estos bots.
onTalk(function(name, level, mode, text, channelId, pos)
  if name == player:getName() then
    local lower = text:lower()
    if lower:find("utamo") then
      awaitingCast = false -- se confirmo el cast, cortamos los reintentos
      startTimer()
    end
  end
end)