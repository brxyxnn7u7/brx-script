setDefaultTab("Main")
-----------------------------------------------------
-- DRAG PUSH - CAVEBOT 1.3 (OTClientV8)
-- Detecta 1 player a tu lado y lo "arrastra" 1 sqm
-----------------------------------------------------

local INTERVAL = 200  -- ms entre intentos

macro(INTERVAL, "Drag Push", function()
  local me = g_game.getLocalPlayer()
  if not me then return end

  local myPos = me:getPosition()
  if not myPos then return end

  local target = nil
  local tPos = nil

  -- 1) Buscar UN player pegado (distancia 1)
  local specs = getSpectators()
  for i = 1, #specs do
    local c = specs[i]
    if c:isPlayer() and not c:isLocalPlayer() then
      local pos = c:getPosition()
      if getDistanceBetween(myPos, pos) == 1 then
        target = c
        tPos = pos
        break
      end
    end
  end

  if not target or not tPos then return end

  -- 2) Elegir una direcciï¿½n aleatoria para el arrastre (1 sqm)
  local dirs = {
    {dx =  1, dy =  0},  -- este
    {dx = -1, dy =  0},  -- oeste
    {dx =  0, dy =  1},  -- sur
    {dx =  0, dy = -1},  -- norte
  }

  local idx = math.random(1, 4)
  local dx = dirs[idx].dx
  local dy = dirs[idx].dy

  -- Posiciï¿½n destino del arrastre (como si arrastraras con el mouse)
  local newPos = {x = tPos.x + dx, y = tPos.y + dy, z = tPos.z}

  -------------------------------------------------
  -- 3) Simular el "drag":
  --    click en el player -> arrastrar a newPos
  -------------------------------------------------

  -- Opciï¿½n A: si tu cliente tiene funciï¿½n push(dx, dy, dz)
  if type(push) == "function" then
    -- muchos debug-push usan desplazamiento relativo al PLAYER
    local relDx = newPos.x - myPos.x
    local relDy = newPos.y - myPos.y
    push(relDx, relDy, 0)
    return
  end

  -- Opciï¿½n B: usar g_game.move (si tu build lo soporta para criaturas)
  if g_game.move then
    g_game.move(target, newPos, 1)
  end
end)