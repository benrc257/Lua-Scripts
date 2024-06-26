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
    local lookup =  rednet.lookup(protocol, "supplier " .. label);
    if (lookup ~= nil) then
        print("\nSupplier " .. label .. " found.")
    end
    os.sleep(0.05)
until (lookup == nil);
label = ("supplier " .. label);

os.setComputerLabel(label)
print("\nTurtle Label (\"" .. label .. "\") successfully set. Hosting moria rednet...")
rednet.host(protocol, label) -- opening moria rednet
print("\nHosting Successful.")

function triangulate()
    repeat
        x, y, z = gps.locate(5)
    until (x ~= nil);
    return x, y, z;
end

print("\nRequesting storage coordinates...")
sx, sy, sz = triangulate()
print("\nEnter the minimum ascension height for tanker.\nThis should be no greater than 318:")
mah = read();

print("\nLaunching relay...")
multishell.launch({}, "supplierrelay.lua")
print("\nRelay launched.")

function awaitCoords()
    os.queueEvent("ready")
    local event, returnCoords = os.pullEvent("coordinates");
    return returnCoords;
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
    for i=y, mah do
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
            until (turtle.refuel(0))
            turtle.refuel()
        else
            turtle.refuel()
        end
    end
end

function empty()
    local full = 0;
    for i=2, 16 do
        if(turtle.getItemCount(i) ~= 0) then
            full = full+1;
        end
    end

    if (full <= 2) then
        goTo(sx, sy, sz)
        for i=1, 16 do
            turtle.suckDown()
        end
    end
end

repeat
    coords = awaitCoords(); -- {x, y, z, depth, length, width, mah}
    coords[2] = coords[2]+1;
    if (turtle.getItemCount(1) ~= 0) then
        turtle.select(1)
        turtle.refuel()
    end
    refuel()
    findFacing()
    goTo(coords[1], coords[2], coords[3])


    for i=1, 16 do
        turtle.select(i)
        turtle.dropUp()
        turtle.suckDown()
    end
    turtle.select(1)
    turtle.dropDown()

    face(4)
    crosswalk()
    repeat turtle.dig() until (turtle.forward());
    x = x-1;

    goTo(sx, sy, sz)

    for i=1, 16 do
        turtle.select(i)
        turtle.dropDown(64)
    end

    refuel()
    ascend()
until (false);