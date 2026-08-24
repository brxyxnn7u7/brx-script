setDefaultTab("Tools")
local c = storage.skinner or {}
storage.skinner = c
c.bodies = c.bodies or {}
c.knifeId = c.knifeId or 5808

g_ui.loadUIFromString([[
SkinnerWin < MainWindow
  text: Obsidian Skinner
  size: 320 175
  @onEscape: self:hide()

  BotItem
    id: kn
    anchors.top: parent.top
    anchors.left: parent.left

  BotContainer
    id: list
    anchors.top: parent.top
    anchors.left: kn.right
    anchors.right: parent.right
    anchors.bottom: clr.top
    margin-left: 12
    margin-bottom: 6

  Button
    id: clr
    text: Clear
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    size: 60 22

  Button
    id: cls
    text: Close
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 22
]])

local ui = setupUI([[
Panel
  height: 20
  BotSwitch
    id: sw
    anchors.left: parent.left
    anchors.top: parent.top
    width: 130
    text: Skinner
  Button
    id: setup
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    height: 20
    text: Setup
]])

local win = UI.createWindow("SkinnerWin")
win:hide()

ui.sw:setOn(c.enabled)
ui.sw.onClick = function(w) c.enabled = not c.enabled w:setOn(c.enabled) end

win.kn:setItemId(c.knifeId)
win.kn.onItemChange = function(w) c.knifeId = w:getItemId() end

local bl = UI.Container(function(w,i) c.bodies = i end, true, nil, win.list)
bl:setItems(c.bodies)

win.clr.onClick = function() c.bodies = {} bl:setItems(c.bodies) end
win.cls.onClick = function() win:hide() end
ui.setup.onClick = function() win.kn:setItemId(c.knifeId) bl:setItems(c.bodies) win:show() win:raise() win:focus() end


setDefaultTab("Tools")
local tr, lw = {}, 0

macro(200, function()
local c = storage.skinner
if not c or not c.enabled or not c.bodies or #c.bodies == 0 or (c.knifeId or 0) < 100 then return end
for k,t in pairs(tr) do if now-t > 3000 then tr[k]=nil end end
local ts = getNearTiles(pos())
table.insert(ts, g_map.getTile(pos()))
for _,tile in ipairs(ts) do
if tile then
local p = tile:getPosition()
local key = p.x..","..p.y..","..p.z
if not tr[key] then
for _,it in ipairs(tile:getItems()) do
local id = it:getId()
for _,b in ipairs(c.bodies) do
if (type(b)=="table" and b.id or b) == id then
local kn = findItem(c.knifeId)
if not kn then
if now-lw > 5000 then warn("[Skinner] no knife "..c.knifeId) lw=now end
return
end
g_game.useWith(kn, it)
tr[key] = now
return
end end end end end end
end)

