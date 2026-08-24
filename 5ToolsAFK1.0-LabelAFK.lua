setDefaultTab("Tools")
UI.Separator()
local botName = "AFK:"
local lNameps = UI.Label(botName)
UI.Separator()

local colors = {"red", "orange", "yellow", "green", "blue", "#00008b", "#ee82ee"}
local colorI = 0
macro(100, function()
  colorI = colorI==#colors and 0 or colorI+1
  lNameps:setColor(colors[colorI])
end)