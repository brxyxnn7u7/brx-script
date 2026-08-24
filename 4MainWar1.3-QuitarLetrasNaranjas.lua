setDefaultTab("Main")

-- script
--[[Esconder Magias Naranjas En Pantalla]]--
TH = macro(100, "Ocultar Msg", function() end)
onStaticText(function(thing, text)
    if TH.isOff() then return end
    if not text:find('says:') then
        g_map.cleanTexts()
    end
end)


--[[esconder MAGIAS(SPRITES)]]--
sprh = macro(100, "Ocultar Sprite", function() end)
onAddThing(function(tile, thing)
    if sprh.isOff() then return end
    if thing:isEffect() then
        thing:hide()
    end
end)