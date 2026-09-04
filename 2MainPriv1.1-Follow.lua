setDefaultTab("Tools")
-- =========================================================
-- ADVANCED FOLLOW PRO
-- =========================================================
-- FOLLOW INDEPENDIENTE
--
-- Funciones:
-- • Sigue al jugador configurado.
-- • Mantiene una distancia configurable.
-- • Guarda la última posición conocida del líder.
-- • Detecta cambio de piso.
-- • Busca escaleras, agujeros, rope spots, ladders y sewers.
--
-- NO incluye Hold Target.
-- NO modifica ataques.
-- =========================================================

local AF = storage.AdvancedFollowPro

if not AF then
    AF = {
        player = "",
        keepDistance = 1,
        enabled = true
    }

    storage.AdvancedFollowPro = AF
end

AF.player = AF.player or ""
AF.keepDistance = tonumber(AF.keepDistance) or 1
AF.enabled = AF.enabled ~= false

local toFollowPos = {}
local lastKnownPosition = nil

-- =========================================================
-- UI
-- =========================================================

UI.Separator()

local followUI = setupUI([[
Panel
  height: 20

  BotSwitch
    id: follow
    anchors.left: parent.left
    anchors.top: parent.top
    width: 105
    text: Follow

  Label
    id: status
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 5
    text-align: center
    text: Advanced
]])

followUI.follow:setOn(AF.enabled)

followUI.follow.onClick = function(widget)

    AF.enabled = not AF.enabled

    widget:setOn(AF.enabled)

end

UI.Label("Follow Player:")

local followEdit = UI.TextEdit(
    AF.player,
    function(widget, text)

        AF.player = text

        -- Limpiar posiciones antiguas
        toFollowPos = {}
        lastKnownPosition = nil

    end
)

UI.Label("Keep Distance:")

local distanceEdit = UI.TextEdit(
    tostring(AF.keepDistance),
    function(widget, text)

        local value = tonumber(text)

        if value and value >= 0 then

            AF.keepDistance = value

        end

    end
)

-- =========================================================
-- FLOOR CHANGERS
-- =========================================================

local FloorChangers = {

    Ladders = {

        Up = {
            1948,
            5542,
            16693,
            16692
        },

        Down = {
            432,
            412,
            469,
            1949
        }
    },

    Holes = {

        Up = {},

        Down = {
            293,
            294,
            595,
            4728,
            385,
            9853
        }
    },

    RopeSpots = {

        Up = {
            386
        },

        Down = {}
    },

    Stairs = {

        Up = {
            16690,
            1958,
            7548,
            7544,
            1952,
            1950,
            1947,
            7542,
            855,
            856,
            1978,
            1977,
            6911,
            6915,
            1954,
            5259,
            20492,
            1956,
            1957,
            1955,
            5257
        },

        Down = {
            482,
            414,
            413,
            437,
            7731,
            469,
            434,
            859,
            438,
            6127,
            566,
            7476,
            4826
        }
    },

    Sewers = {

        Up = {},

        Down = {
            435
        }
    }
}

-- =========================================================
-- FLOOR CHANGE ACTIONS
-- =========================================================

local function goLastKnown()

    if not lastKnownPosition then
        return
    end

    if getDistanceBetween(
        pos(),
        lastKnownPosition
    ) <= 1 then

        return
    end

    local tile =
        g_map.getTile(
            lastKnownPosition
        )

    if not tile then
        return
    end

    local thing =
        tile:getTopUseThing()

    if not thing then
        return
    end

    g_game.use(thing)

    delay(
        math.random(300, 700)
    )
end

-- =========================================================
-- USE
-- =========================================================

local function handleUse(changePos)

    goLastKnown()

    if posz() ~= changePos.z then
        return
    end

    local tile =
        g_map.getTile(changePos)

    if not tile then
        return
    end

    local thing =
        tile:getTopUseThing()

    if not thing then
        return
    end

    g_game.use(thing)

    delay(
        math.random(400, 800)
    )
end

-- =========================================================
-- STEP
-- =========================================================

local function handleStep(changePos)

    goLastKnown()

    if posz() ~= changePos.z then
        return
    end

    autoWalk(
        changePos
    )

    delay(
        math.random(400, 800)
    )
end

-- =========================================================
-- ROPE
-- =========================================================

local function handleRope(changePos)

    goLastKnown()

    if posz() ~= changePos.z then
        return
    end

    local tile =
        g_map.getTile(changePos)

    if not tile then
        return
    end

    local thing =
        tile:getTopUseThing()

    if not thing then
        return
    end

    useWith(
        3003,
        thing
    )

    delay(
        math.random(400, 800)
    )
end

-- =========================================================
-- SELECTOR
-- =========================================================

local floorChangeSelector = {

    Ladders = {
        Up = handleUse,
        Down = handleStep
    },

    Holes = {
        Up = handleStep,
        Down = handleStep
    },

    RopeSpots = {
        Up = handleRope,
        Down = handleRope
    },

    Stairs = {
        Up = handleStep,
        Down = handleStep
    },

    Sewers = {
        Up = handleUse,
        Down = handleUse
    }
}

-- =========================================================
-- UPDATE LEADER POSITION
-- =========================================================

local function updateLeaderPosition()

    if AF.player == "" then
        return nil
    end

    local leader =
        getCreatureByName(
            AF.player
        )

    if not leader then
        return nil
    end

    local leaderPos =
        leader:getPosition()

    if not leaderPos then
        return nil
    end

    toFollowPos[leaderPos.z] =
        leaderPos

    if leaderPos.z == posz() then

        lastKnownPosition = {
            x = leaderPos.x,
            y = leaderPos.y,
            z = leaderPos.z
        }
    end

    return leader
end

-- =========================================================
-- TARGET MISSING / DIFFERENT FLOOR
-- =========================================================

local function targetMissing()

    if AF.player == "" then
        return true
    end

    local spectators =
        getSpectators(false)

    for _, creature in ipairs(
        spectators
    ) do

        if creature:getName() ==
           AF.player then

            local creaturePos =
                creature:getPosition()

            if creaturePos then

                return creaturePos.z ~=
                       posz()
            end
        end
    end

    return true
end

-- =========================================================
-- DISTANCE TO LAST POSITION
-- =========================================================

local function positionDistance(position)

    local reference =
        lastKnownPosition or pos()

    return math.abs(
        position.x - reference.x
    )
    +
    math.abs(
        position.y - reference.y
    )
end

-- =========================================================
-- EXECUTE CLOSEST FLOOR CHANGE
-- =========================================================

local function executeClosest(
    possibilities
)

    local closest = nil
    local closestDistance = 99999

    for _, data in ipairs(
        possibilities
    ) do

        local distance =
            positionDistance(
                data.pos
            )

        if distance <
           closestDistance then

            closestDistance =
                distance

            closest = data
        end
    end

    if closest then

        closest.changer(
            closest.pos
        )
    end
end

-- =========================================================
-- FIND FLOOR CHANGE
-- =========================================================

local function handleFloorChange()

    if not AF.enabled then
        return
    end

    local range = 2
    local currentPos = pos()

    local possibilities = {}

    for _, direction in ipairs({
        "Down",
        "Up"
    }) do

        for changer, data in pairs(
            FloorChangers
        ) do

            local ids =
                data[direction]

            if ids then

                for x = -range, range do

                    for y = -range, range do

                        local tile =
                            g_map.getTile({
                                x = currentPos.x + x,
                                y = currentPos.y + y,
                                z = currentPos.z
                            })

                        if tile then

                            local thing =
                                tile:getTopUseThing()

                            if thing then

                                local itemId =
                                    thing:getId()

                                if table.find(
                                    ids,
                                    itemId
                                ) then

                                    local changerFunction =
                                        floorChangeSelector
                                        [changer]
                                        [direction]

                                    if changerFunction then

                                        table.insert(
                                            possibilities,
                                            {
                                                changer =
                                                    changerFunction,

                                                pos = {
                                                    x = currentPos.x + x,
                                                    y = currentPos.y + y,
                                                    z = currentPos.z
                                                }
                                            }
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    executeClosest(
        possibilities
    )
end

-- =========================================================
-- LEADER POSITION EVENT
-- =========================================================

onCreaturePositionChange(
    function(creature, newPos)

        if not AF.enabled then
            return
        end

        if not creature then
            return
        end

        if AF.player == "" then
            return
        end

        if creature:getName() ~=
           AF.player then

            return
        end

        if not newPos then
            return
        end

        toFollowPos[newPos.z] =
            newPos

        if newPos.z == posz() then

            lastKnownPosition = {
                x = newPos.x,
                y = newPos.y,
                z = newPos.z
            }
        end
    end
)

-- =========================================================
-- MAIN FOLLOW ENGINE
-- =========================================================

macro(
    100,
    "Advanced Follow PRO",
    function()

        if not AF.enabled then
            return
        end

        if AF.player == "" then
            return
        end

        local leader =
            updateLeaderPosition()

        -- =================================================
        -- LEADER ESTÁ EN PANTALLA
        -- =================================================

        if leader then

            local leaderPos =
                leader:getPosition()

            if leaderPos.z ==
               posz() then

                if player:isWalking() then
                    return
                end

                local distance =
                    getDistanceBetween(
                        pos(),
                        leaderPos
                    )

                local desiredDistance =
                    tonumber(
                        AF.keepDistance
                    ) or 1

                if distance >
                   desiredDistance then

                    autoWalk(
                        leaderPos,
                        30,
                        {
                            ignoreNonPathable = true,
                            precision = 1,
                            marginMin = desiredDistance,
                            marginMax = desiredDistance + 1
                        }
                    )
                end

                return
            end
        end

        -- =================================================
        -- LEADER EN OTRO PISO / FUERA DE VISTA
        -- =================================================

        if targetMissing()
           and lastKnownPosition then

            handleFloorChange()

        end
    end
)

-- =========================================================
-- LIMPIAR SI CAMBIA EL PERSONAJE / LÍDER
-- =========================================================

onPlayerPositionChange(
    function()

        if not AF.enabled then
            return
        end

        -- No hacemos nada aquí.
        -- El evento solo evita tener lógica duplicada.
    end
)
