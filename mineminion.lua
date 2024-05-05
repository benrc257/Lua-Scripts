modem = peripheral.find("modem", rednet.open);
print("\nWireless modem found. Opening...")

protocol = "mining";
ID = os.computerID();

function triangulate()
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

function refuel(x, y, z)
    if (turtle.getFuelLevel <= 2000) then
        turtle.select(1)
        if (turtle.refuel(0)) then
            turtle.drop()
            local message = []
            message[1] = "fuel";
            table.insert(message, x)
            table.insert(message, y)
            table.insert(message, z)
            local supplyID = nil;
            repeat
                supplyID = rednet.lookup(protocol, "fueler")
            until (supplyID);
            rednet.send(supplyID, message, protocol)

            repeat
                time.sleep(1)
            until (turtle.getItemCount());
        end
        turtle.refuel()
    end
end

function dropOff(x, y, z)
    local message = []
    message[1] = "full";
    table.insert(message, x)
    table.insert(message, y)
    table.insert(message, z)

    local supplyID = nil;
    repeat
        supplyID = rednet.lookup(protocol, "supplier")
    until (supplyID);
    rednet.send(supplyID, message, protocol)

    repeat
        local success = false;
        local present, block = turtle.inspectDown();
        if (present) then if (block.name == "computercraft:turtle_advanced" or block.name == "computercraft:turtle") then success = true; end end
    until (success)

    for i=2, 16 do 
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(1)
end

function turnR(facing) -- 1 = north, 2 = east, 3 = south, 4 = west
    turtle.turnRight()
    if (facing == 1) then facing = 4; else facing = facing-1; end
    return facing;
end

function turnL(facing) -- 1 = north, 2 = east, 3 = south, 4 = west
    turtle.turnLeft()
    if (facing == 4) then facing = 1; else facing = facing+1; end
    return facing;
end

function face(facing, direction) -- direction is an int
    if (direction ~= facing) then 
        if (direction > facing) then
            repeat 
                facing = turnL(facing);
            until (direction == facing);
        else
            repeat 
                facing = turnR(facing);
            until (direction == facing);
        end
    end
    return facing;
end

function fillLiquid()
    local present, block = turtle.inspectDown();
    if (present) then if (block.name == "minecraft:lava" or block.name == "minecraft:water") then
        local slot = 1
        while (slot < 16 and not success) do
            slot = slot+1;
            turtle.select(slot)
            local success = turtle.placeDown();
        end
        turtle.select(1);
    end end
end

print("\nSearching for existing turtles...")
local label = 0;
repeat
    label = label+1;
    local lookup =  rednet.lookup(protocol, "" .. label);
    if (lookup ~= nil) then
        print("\nTurtle " .. label .. " found.")
    end
until (lookup == nil);
label = ("" .. label);

os.setComputerLabel(label)
print("\nComputer Label (\"" .. label .. "\") successfully set. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting successful.")

print("\nTriangulating position...")
x, y, z = triangulate();
print("\nPosition found: " .. x .. " " .. y .. " ".. z)

repeat
    print("\nWaiting for coordinates...")

    local received = []
    repeat
        local exit = false;
        coords = rednet.receive(protocol, 10) -- {"coords", x, y, z, depth, length, width}
        if (istable(coords)) then
            if (coords[1] == "coords") then 
                exit = true; 
            end
        end
    until (exit);
    print ("\nCoordinates received...")

    turtle.select(1)
    turtle.refuel()

    print ("\nFueled. Ascending...")
    for i=y, 383 do
        turtle.digUp()
        turtle.up()
    end

    oldX = x;
    oldZ = z;
    turtle.dig()
    turtle.forward()
    x, y, z = triangulate();
    if (oldX ~= x) then -- 1 = north, 2 = east, 3 = south, 4 = west
        if (x > oldX) then facing = 2; else facing = 4; end
    else
        if (z > oldZ) then facing = 3; else facing = 1; end
    end

    if (x ~= coords[2]) then -- going to destination X
        if (coords[2] < x) then facing = face(facing, 4); else facing = face(facing, 2); end
        repeat
            if (x ~= coords[2]) then
                turtle.dig()
                turtle.forward()
                if (facing == 4) then
                    x=x-1;
                else
                    x=x+1;
                end
            end
        until (x == coords[2]);
    end

    if (z ~= coords[4]) then -- going to destination Z
        if (coords[4] < z) then facing = face(facing, 1); else facing = face(facing, 3); end
        repeat
            if (z ~= coords[4]) then
                turtle.dig()
                turtle.forward()
                if (facing == 1) then
                    z=z-1;
                else
                    z=z+1;
                end
            end
        until (z == coords[4]);
    end

    if (y ~= coords[3]) then -- going to destination Y
        repeat
            if (y ~= coords[3]) then
                turtle.digDown()
                turtle.down()
                z=z-1;
            end
        until (z == coords[4]);
    end

    
    for i=1, coords[5] do -- {"coords", x, y, z, depth, length, width}
        refuel(x, y, z)
        for j=1, coords[6] do
            for k=2, coords[7] do
                if (j%2) then
                    facing = face(facing, 3); -- odd
                    z=z+1;
                else
                    facing = face(facing, 1); -- even
                    z=z-1;
                end
                fillLiquid()
                turtle.dig()
                turtle.forward()
            end
            if (j~=coords[6]) then
                facing = face(facing, 4);
                turtle.dig()
                turtle.forward()
                x=x-1;
            end
        end
        if (coords[6]%2) then
            facing = face(facing, 1);
            for i=1, coords[7] do
                turtle.forward()
                z=z-1;
            end
            facing = face(facing, 2);
            for i=1, coords[6] do 
                turtle.forward()
                x=x+1;
            end
        else
            facing = face(facing, 2);
            for i=1, coords[6] do 
                turtle.forward()
                x=x+1;
            end
        end
        if (i~=coords[5]) then
            turtle.digDown()
            turtle.down()
            y=y-1;
        end
        dropOff(x, y, z)
    end
    local gemstone = rednet.lookup(protocol, "gemstone")
    rednet.send(gemstone, "done")
until (false);