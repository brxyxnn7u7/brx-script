setDefaultTab("Main")

local hold = 0
local candidates = {}
local shouldHold = false

local holdMWIcon = addIcon("holdIcon",{item={id=3180, count=1}, text ="Hold MW/WG"}, macro(200, function(m)
  shouldHold = true
  schedule(200, function()
    if m.isOn() then return end
    shouldHold = false
    candidates = {}
    for _, t in ipairs(g_map.getTiles(posz())) do
      t:setText("")
    end
  end)
end))

holdMWIcon:breakAnchors()
holdMWIcon:move(80,80)
 
  setDefaultTab("tools")

  local function botPrintMessage(message)
    modules.game_textmessage.displayGameMessage(message)
  end
  
  botPrintMessage("Hold MW WG --> (test)")

local m = macro(20, function()
    if #candidates == 0 then return end
    for i, pos in pairs(candidates) do
      local tile = g_map.getTile(pos)
      if tile then
        if tile:getText():len() == 0 then 
          table.remove(candidates, i)
        end
        local rune = tile:getText() == "HOLD MW" and 3180 or tile:getText() == "HOLD WG" and 3156
        if tile:canShoot() and not isInPz() and tile:isWalkable() and tile:getTopUseThing():getId() ~= 2130 then
          if math.abs(player:getPosition().x-tile:getPosition().x) < 8 and math.abs(player:getPosition().y-tile:getPosition().y) < 6 then
            rune = findItem(rune)            
            return useWith(rune, tile:getTopUseThing())
          end
        end
      end
    end
end)

onRemoveThing(function(tile, thing)  
    if thing:getId() ~= 2129 then return end
    if tile:getText():find("HOLD") then
        table.insert(candidates, tile:getPosition())
        local rune = tile:getText() == "HOLD MW" and 3180 or tile:getText() == "HOLD WG" and 3156
        if math.abs(player:getPosition().x-tile:getPosition().x) < 8 and math.abs(player:getPosition().y-tile:getPosition().y) < 6 then
          print(rune)
          rune = findItem(rune)  
          return useWith(rune, tile:getTopUseThing())
        end
    end
end)

onAddThing(function(tile, thing)  
    if m.isOff() then return end
    if thing:getId() ~= 2129 then return end
    if tile:getText():len() > 0 then
        table.remove(candidates, table.find(candidates,tile))
    end
end)

onUseWith(function(pos, itemId, target, subType)
    if not shouldHold or (itemId ~= 3180 and itemId ~= 3156 ) then return end
    
    hold = now    
    local tile = g_map.getTile(target:getPosition())
    if not tile then return end

    if itemId == 3180 then
  
        tile:setText("HOLD MW")
    else
        tile:setText("HOLD WG")
    end
    table.insert(candidates, tile:getPosition()) 
end)
