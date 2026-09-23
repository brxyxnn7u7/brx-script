local config = {
    citys = { "carlin", "thais", "edron" }
}

for _, city in ipairs(config.citys) do
    --Made By VivoDibra, originally VivoDibra#1182 
    addIcon(city.."Icon", {item={id=4989, count=1}, text=city}, macro(100, function(m)
        m.setOff()
        say("bring me to "..city)
    end))
end

--Join Discord server for free scripts
--https://discord.gg/RkQ9nyPMBH
--Made By VivoDibra, originally VivoDibra#1182 
--Tested on vBot 4.8 / OTCV8 3.2 rev 4