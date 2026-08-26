-- script
local s = {}

s.color = {
  first = 77, --min: 1
  last = 94,  --max: 133
  sets = {}
}
s.parts = {"head", "body", "legs", "feet"}
s.setIndex = 1

for i = s.color.first, s.color.last - 3 do
  local set = {}
  
  for j = i, i + 3 do
    table.insert(set, j)
  end

  table.insert(s.color.sets, set)
end

s.m_main = macro(10000, "Walk Rainbow Outfit", function(m) end)

onPlayerPositionChange(function(newPos, oldPos)
  if s.m_main.isOff() then return end

  s.playerOutfit = player:getOutfit()

  if s.setIndex > #s.color.sets then
    s.setIndex = 1
  end

  local currentSet = s.color.sets[s.setIndex]

  for i, part in ipairs(s.parts) do
    s.playerOutfit[part] = currentSet[i]
  end

  setOutfit(s.playerOutfit)
  
  s.setIndex = s.setIndex + 1
end)