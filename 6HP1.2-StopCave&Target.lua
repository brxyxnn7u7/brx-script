setDefaultTab("HP")

local cIcon = addIcon("CaveBotIcon", {
    item = {id=8154, count=1},
    text = "Cavebot"
}, macro(200, function(m)
    CaveBot.setOn()
    schedule(200, function()
        if m.isOff() then
            CaveBot.setOff()
        end
    end)
end))

local tIcon = addIcon("TargetBotIcon", {
    item = {id=8160, count=1},
    text = "Target"
}, macro(200, function(m)
    TargetBot.setOn()
    schedule(200, function()
        if m.isOff() then
            TargetBot.setOff()
        end
    end)
end))
