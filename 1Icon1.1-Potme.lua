-- script
local ICON_ID = 238
local x = macro(200, function()
  if manapercent() <= 80 then 
    useWith(238, player)
  end
end)

addIcon("POT ON/OFF", {item={id = ICON_ID}, movable=true, hotkey="F2"}, function(icon, isOn)
  x.setOn(isOn) 
end)
