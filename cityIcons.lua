setDefaultTab("Main")
local NPCsAndCities = {
  ["Minoru"] = "Earth, terra, terrinha, konoha, snow random",
  ["Captain Bluebear"] = "Venore, Carlin",
  ["Captain Fearless"] = "Thais, Carlin",
  ["Captain Greyhound"] = "Thais, Venore",
}

local TravelWindow = setupUI([[
UIWindow
  !text: tr('Travel')
  color: #99d6ff
  font: sans-bold-16px  
  background-color: black
  opacity: 0.85
  anchors.verticalCenter: parent.verticalCenter
  anchors.horizontalCenter: parent.horizontalCenter
  size: 240 80

  ComboBox
    size: 220 20
    id: travelOptions
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center
    opacity: 1.0
    color: yellow
    font: sans-bold-16px
    margin-top: 25
    
  Button
    id: closeButton
    text: X
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: #99d6ff
    size: 15 15
    margin-bottom: 10
    margin-right: 10
]], g_ui.getRootWidget())

TravelWindow:hide()

NPC.talk = function(text)
  if (g_game.getClientVersion() >= 810) then
      NPC.say(text)
  else
    say(text)
  end
end

local setOptions = function(npc)
  TravelWindow.travelOptions:clear()
  local npcName = npc:getName()
  local cities = NPCsAndCities[npcName]
  TravelWindow.travelOptions:addOption(npcName)
  for _, city in ipairs(cities:split(",")) do
    TravelWindow.travelOptions:addOption(city:trim())
  end
end

local setup = function(npc)    
  setOptions(npc)
  TravelWindow:show()
end

local reset = function()
  TravelWindow:hide()
  TravelWindow.travelOptions:clear()
  modules.game_interface.getRootPanel():focus()
end

TravelWindow.travelOptions.onOptionChange = function(widget, option, data)
  if TravelWindow:isVisible() then         
    say("hi")
    schedule(500, function()
      NPC.talk(option)
    end)
    schedule(1000, function()
      NPC.talk("yes")
    end)
    reset()
  end
end

local getTravelNPC = function()
  for name,_ in pairs(NPCsAndCities) do
    local npc = getCreatureByName(name)
    if npc and distanceFromPlayer(npc:getPosition()) <= 2 then
      return npc
    end
  end
end

onPlayerPositionChange(function(old, new)
  local npc = getTravelNPC()
  if npc and not TravelWindow:isVisible() then
    setup(npc)
  elseif not npc and TravelWindow:isVisible() then
    reset()
  end
end)
