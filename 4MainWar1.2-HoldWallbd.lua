setDefaultTab("Main")
storage.WGPoses = storage.WGPoses or { }

macro(50, "Force Hold WG", function()
  for _, candidate in ipairs(storage.WGPoses) do
    local wgTile = g_map.getTile(candidate)
    if wgTile and wgTile:canShoot() then
      if wgTile:getTopUseThing():getId() ~= 2129 then
        wgTile:setText("Force WG")
        useWith(3180, wgTile:getGround())
      end
    end
  end
end)

addButton("","Set WG Pos", function()
  table.insert(storage.WGPoses, pos())
end)

addButton("","Clean All Positions", function()
  for _, candidate in ipairs(storage.WGPoses) do
    local wgTile = g_map.getTile(candidate)
    if wgTile then
      wgTile:setText("")
    end
  end
  storage.WGPoses = { }
end)
