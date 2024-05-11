print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem");
    os.sleep(0.05)
until (modem)
modemName = peripheral.getName(modem);
rednet.open(modemName)
print("\nWireless modem found. Opening...")

protocol = "moria"; 

print("\nSearching for existing turtles...")
label = 0;
repeat
    label = label+1;
    local lookup =  rednet.lookup(protocol, "Turtle " .. label);
    if (lookup ~= nil) then
        print("\nTurtle " .. label .. " found.")
    end
    os.sleep(0.05)
until (lookup == nil);
labelNum = label;
label = ("Turtle " .. label);

supplierName = math.ceil((labelNum/3));
supplierName = "supplier " .. supplierName;
print("\nSupplier number set to \"" .. supplierName .. "\".") 

os.setComputerLabel(label)
print("\nTurtle Label (\"" .. label .. "\") successfully set. Hosting moria rednet...")
rednet.host(protocol, label) -- opening moria rednet
print("\nHosting Successful.")

print("\nLaunching relay...")
multishell.launch({}, "dwarfrelay.lua")
print("\nRelay launched.")

function awaitCoords()
    os.queueEvent("ready")
    local event, returnCoords = os.pullEvent("coordinates");
    return returnCoords;
end

function triangulate()
    x, y, z = nil;
    repeat
        x, y, z = gps.locate(5)
    until (x ~= nil);
    return x, y, z;
end

function findFacing()
    repeat turtle.dig() until (turtle.forward());
    local x2, y2, z2 = triangulate();
    turtle.back();
    local x1, y1, z1 = triangulate();
    if ((z2-z1) == -1) then -- 1 north, 2 east, 3 south, 4 west
        facing = 1;
    elseif ((x2-x1) == 1) then
        facing = 2;
    elseif (z2-z1 == 1) then
        facing = 3;
    else
        facing = 4;
    end
    return facing;
end

function turnR() -- 1 = north, 2 = east, 3 = south, 4 = west
    turtle.turnRight()
    if (facing == 4) then facing = 1; else facing = facing+1; end
end

function turnL() -- 1 = north, 2 = east, 3 = south, 4 = west
    turtle.turnLeft()
    if (facing == 1) then facing = 4; else facing = facing-1; end
end

function face(direction)
    if (facing == direction) then
        os.sleep(0.05)
    elseif ((facing-direction) == -3) then
        turnL()
    elseif ((facing-direction) == 3) then
        turnR()
    elseif (facing < direction) then
        repeat turnR() until (facing == direction);
    else
        repeat turnL() until (facing == direction);
    end
end

function crosswalk()
    repeat
        local pedestrian = true;
        local present, block = turtle.inspect();
        if (present) then if (block.name == "computercraft:turtle_advanced") then
            os.sleep(3)
            pedestrian = false;
        end end
    until (pedestrian);
end

function crosswalkUp()
    repeat
        local pedestrian = true;
        local present, block = turtle.inspectUp();
        if (present) then if (block.name == "computercraft:turtle_advanced") then
            os.sleep(3)
            pedestrian = false;
        end end
    until (pedestrian);
end

function crosswalkDown()
    repeat
        local pedestrian = true;
        local present, block = turtle.inspectDown();
        if (present) then if (block.name == "computercraft:turtle_advanced") then
            os.sleep(3)
            pedestrian = false;
        end end
    until (pedestrian);
end

function ascend()
    triangulate()
    for i=y, coords[7] do
        crosswalkUp()
        repeat turtle.digUp() until (turtle.up());
        y=y+1;
    end
    triangulate()
end

function goTo(dx, dy, dz)
    triangulate()

    if (dx ~= x or dz ~= z) then
        ascend()
    end
    
    while (x < dx) do
        face(2)
        crosswalk()
        repeat turtle.dig() until (turtle.forward());
        x=x+1;
    end
    while (x > dx) do
        face(4)
        crosswalk()
        repeat turtle.dig() until (turtle.forward());
        x=x-1;
    end

    triangulate()

    while (z < dz) do
        face(3)
        crosswalk()
        repeat turtle.dig() until (turtle.forward());
        z=z+1;
    end
    while (z > dz) do
        face(1)
        crosswalk()
        repeat turtle.dig() until (turtle.forward());
        z=z-1;
    end

    triangulate()

    while (y < dy) do
        crosswalkUp()
        repeat turtle.digUp() until (turtle.up());
        y=y+1;
    end
    while (y > dy) do
        crosswalkDown()
        repeat turtle.digDown() until (turtle.down());
        y=y-1;
    end

    triangulate()
end

function refuel()
    turtle.select(1)
    if (turtle.getFuelLevel() <= 1000) then
        if (turtle.getItemCount() < 64 or not turtle.refuel(0)) then
            local tanker = rednet.lookup(protocol, "tanker");
            local position = {};
            position[1], position[2], position[3] = triangulate();
            rednet.send(tanker, position, protocol)
            repeat
                os.sleep(1)
            until (turtle.getItemCount() > 63 and turtle.refuel(0))
            turtle.refuel(63)
        else
            turtle.refuel(63)
        end
    end
end

function full()
    local full = 0;
    for i=2, 16 do
        if(turtle.getItemCount(i) ~= 0) then
            full = full+1;
        end
    end

    if (full >= 10) then
        local supplier = rednet.lookup(protocol, supplierName);
        local position = {};
        position[1], position[2], position[3] = triangulate();
        rednet.send(supplier, position, protocol)
        repeat
            full = 0;
            for i=2, 16 do
                if(turtle.getItemCount(i) ~= 0) then
                    full = full+1;
                end
            end
            os.sleep(1)
        until (full == 0)
    end
end

function fillLiquid()
    local present, block = turtle.inspectDown();
    if (present) then if (block.name == "minecraft:lava" or block.name == "minecraft:water") then
        local slot = 1;
        local success = false;
        while (slot < 16 and not success) do
            slot = slot+1;
            turtle.select(slot)
            local item = turtle.getItemDetail();
            if (not (item.name == "minecraft:sand" or item.name == "minecraft:gravel")) then
                success = turtle.placeDown();
            end
        end
        turtle.select(1);
    end end
end

repeat
    coords = awaitCoords(); -- {x, y, z, depth, length, width, mah}
    if (turtle.getFuelLevel() <= 2000 and turtle.getItemCount(1) > 63) then
        turtle.select(1)
        turtle.refuel(63)
    end
    findFacing()
    print(coords[1])
    print(coords[2])
    print(coords[3])
    print(facing)
    print(x)
    print(y)
    print(z)
    goTo(coords[1], coords[2], coords[3])
    triangulate()

    for i=1, coords[4] do
        refuel()
        face(1)
        for j=1, coords[5] do
            for k=2, coords[6] do
                repeat turtle.dig() until (turtle.forward());
                fillLiquid()
            end
            face(4)
            if ((j%2) ~= 0 and j~=coords[5]) then
                repeat turtle.dig() until (turtle.forward());
                fillLiquid()
                face(3)
            elseif (j~=coords[5]) then
                repeat turtle.dig() until (turtle.forward());
                fillLiquid()
                face(1)
            end
        end
        triangulate()
        if (z ~= coords[3]) then
            face(3)
            for j=2, coords[6] do
                repeat turtle.dig() until (turtle.forward());
            end
        end
        face(2)
        for j=2, coords[5] do
            repeat turtle.dig() until (turtle.forward());
        end
        if (i ~= coords[4]) then
            repeat turtle.digDown() until (turtle.down());
            fillLiquid()
        end
        full()
    end

    local moria = rednet.lookup(protocol, "Moria")
    rednet.send(moria, "free", protocol)
until (false);