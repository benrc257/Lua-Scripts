turtle.select(2)
repeat
    local item = turtle.getItemDetail();
    if (item ~= nil) then if (not (item.name == "minecraft:sand" or item.name == "minecraft:gravel")) then
        success = turtle.placeDown();
    end end
   os.sleep(0.05)
until false;