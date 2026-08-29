setDefaultTab("HP")

local icon = addIcon("CaveTargetIcon", {
    item = {id = 10227, count = 1},
    text = "Cave\nTarget",
    switchable = true
}, function(widget)
    if widget.isOn() then
        CaveBot.setOn()
        TargetBot.setOn()
    else
        CaveBot.setOff()
        TargetBot.setOff()
    end
end)
