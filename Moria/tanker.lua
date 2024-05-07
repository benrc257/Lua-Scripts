print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem");
    os.sleep(0.05)
until (modem)
modemName = peripheral.getName(modem);
rednet.open(modemName)
print("\nWireless modem found. Opening...")

protocol = "moria"; 

protocol = "moria"; 
label = "tanker";
os.setComputerLabel(label)
print("\nTurtle Label (\"" .. label .. "\") successfully set. Hosting moria rednet...")
rednet.host(protocol, label) -- opening moria rednet
print("\nHosting Successful.")

print("\nRequesting storage coordinates...")
print("\nEnter the X coordinate: ")
sx = read();
print("\nEnter the Y coordinate: ")
sy = read();
sy = sy+1;
print("\nEnter the Z coordinate: ")
sz = read();
print("\nEnter the minimum ascension height for tanker.\nThis should be no greater than 318:")
mah = read();

print("\nLaunching relay...")
multishell.launch({}, "tankerrelay.lua")
print("\nRelay launched.")

function awaitCoords()
    local event, returnCoords = os.pullEvent("coordinates");
    return returnCoords;
end

function triangulate()
    repeat
        x, y, z = gps.locate(5)
    until (x ~= nil);
    return x, y, z;
end

function findFacing()
    local x1, y1, z1 = triangulate();
    repeat turtle.dig() until (turtle.forward());
    local x2, y2, z2 = triangulate();
    turtle.back();
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
    if (facing == 1) then facing = 4; else facing = facing-1; end
end

function turnL() -- 1 = north, 2 = east, 3 = south, 4 = west
    turtle.turnLeft()
    if (facing == 4) then facing = 1; else facing = facing+1; end
end

function face(direction)
    if (facing == direction) then
        os.sleep(0.05)
    elseif ((facing-direction) == -3) then
        turnR()
    elseif ((facing-direction) == 3) then
        turnL()
    elseif (facing < direction) then
        repeat turnL() until (facing == direction);
    else
        repeat turnR() until (facing == direction);
    end
end

function ascend()
    for i=y, coords[7] do
        repeat turtle.digUp() until (turtle.up());
    end
end

function goTo(dx, dy, dz)
    triangulate()

    if (dx ~= x or dz ~= z) then
        ascend()
    end
    
    while (x < dx) do
        face(2)
        repeat turtle.dig() until (turtle.forward());
    end
    while (x > dx) do
        face(4)
        repeat turtle.dig() until (turtle.forward());
    end

    while (z < dz) do
        face(3)
        repeat turtle.dig() until (turtle.forward());
    end
    while (z > dz) do
        face(1)
        repeat turtle.dig() until (turtle.forward());
    end

    while (y < dy) do
        repeat turtle.digUp() until (turtle.up());
    end
    while (y > dy) do
        repeat turtle.digUp() until (turtle.up());
    end
end

function refuel()
    if (turtle.getFuelLevel() <= 2000) then
        for i=1, 16 do
            turtle.select(i)
            if (turtle.getItemCount() > 63) then
                turtle.refuel(63)
                break
            end
        end
    end
end

function empty()
    local full = 0;
    for i=2, 16 do
        if(turtle.getItemCount(i)) then
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
    refuel()
    findFacing()
    goTo(coords[1], coords[2], coords[3])

    for i=1, 16 do
        if(turtle.getItemCount(i) > 63) then
            turtle.select(i)
            turtle.dropDown(63)
            break;
        end
    end

    empty()
    ascend()
    local id, message = rednet.receive(protocol, 5)
until (message == "end");