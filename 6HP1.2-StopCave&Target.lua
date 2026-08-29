setDefaultTab("HP")

addIcon("CaveTargetIcon", {
    item = {id=8154, count=1},
    text = "Cave\nTarget"
}, macro(200, function(m)

    if CaveBot.isOn() or TargetBot.isOn() then
        CaveBot.setOff()
        TargetBot.setOff()
    else
        CaveBot.setOn()
        TargetBot.setOn()
    end
end))
