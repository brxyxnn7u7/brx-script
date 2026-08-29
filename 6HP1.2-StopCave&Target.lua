setDefaultTab("HP")

local ctIcon = addIcon("ctI",{
  text="Cave\nTarget",
  switchable=false,
  moveable=true
}, function()
  if CaveBot.isOff() and TargetBot.isOff() then
    CaveBot.setOn()
    TargetBot.setOn()
  else
    CaveBot.setOff()
    TargetBot.setOff()
    g_game.attack(nil)
  end
end)

ctIcon:setSize({height=30,width=50})
ctIcon.text:setFont('verdana-11px-rounded')

macro(50,function()
  if CaveBot.isOn() and TargetBot.isOn() then
    ctIcon.text:setColoredText({"Cave\nTarget\n","white","ON","green"})
  else
    ctIcon.text:setColoredText({"Cave\nTarget\n","white","OFF","red"})
  end
end)
