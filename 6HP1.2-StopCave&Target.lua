setDefaultTab("HP")

addIcon("StopCTIcon", {item={id=10227, count=1}, text="Cavebot"}, macro(200, function(m)
    CaveBot.setOn()
    TargetBot.setOn()

    schedule(200, function()
        if m.isOff() then
            CaveBot.setOff()
            TargetBot.setOff()
        end
    end)
end))
