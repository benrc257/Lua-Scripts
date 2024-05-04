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

            repeat
                tankerID = rednet.lookup(protocol, "tanker") -- fuel assignment computer is named "tanker"
            until (tankerID);
            rednet.send(tankerID, message, protocol)

            repeat
                time.sleep(1)
            until (turtle.getItemCount());
        end
        turtle.refuel()
    end
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
    if (direction ~= facing) then repeat turnL(facing) until (direction == facing); end
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
        if (coords[2] < x) then face(facing, 4) else face(facing, 2)
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
        if (coords[4] < z) then face(facing, 1) else face(facing, 3)
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
        for j=1, coords[6] do
            for k=1, coords[7] do
                face(facing, 3)
                fillLiquid()
                turtle.dig()
                turtle.forward()
            end -- left off here length and depth need to be done
        end
    end

until 