protocol = "mining";
label = "tanker";
os.setComputerLabel(label)
print("\nComputer Label (\"tanker\") successfully set and broadcasted. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

function istable(t)
    return (type(t) == "table")
end

function triangulate()
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

function findFacing(x, z)
    local oldX = x;
    local oldZ = z;
    turtle.dig()
    turtle.forward()
    x, y, z = triangulate();
    if (oldX ~= x) then -- 1 = north, 2 = east, 3 = south, 4 = west
        if (x > oldX) then facing = 2; else facing = 4; end
    else
        if (z > oldZ) then facing = 3; else facing = 1; end
    end
    turtle.back()
    return facing;
end

function refuel()
    if (turtle.getFuelLevel <= 4000) then
        local currentSlot = 1;
        repeat
            turtle.select(currentSlot)
            if (turtle.getItemCount() == 64) then
                turtle.refuel(63)
            end
            currentSlot = currentSlot+1;
        until (currentSlot > 16 or turtle.getFuelLevel >= 4000)
        turtle.select(1)
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
    if (direction ~= facing) then 
        if ((facing-direction) == 3) then
            facing = turnL(facing);
        elseif ((facing-direction) == -3) then
            facing = turnR(facing);
        elseif (direction > facing) then
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

function resupply(x, y, z, x2, y2, z2, turtOrInv) -- 1 = north, 2 = east, 3 = south, 4 = west, true = turtle, false = inventory
    if (x~=x2 or z~=z2) then
        for i=y, 383 do
            repeat turtle.digUp() until (turtle.up());
        end
    end
    --facing = findFacing(x, z)
    if (x ~= x2) then
        if (x < x2) then
            facing = face(facing, 2)
            while (x ~= x2) do
                repeat turtle.dig() until (turtle.forward());
                x=x+1;
            end
        else
            facing = face(facing, 4)
            while (x ~= x2) do
                repeat turtle.dig() until (turtle.forward());
                x=x-1;
            end
        end
    end
    if (z ~= z2) then
        if (z < z2) then
            facing = face(facing, 3)
            while (z ~= z2) do
                repeat turtle.dig() until (turtle.forward());
                z=z+1;
            end
        else
            facing = face(facing, 1)
            while (z ~= z2) do
                repeat turtle.dig() until (turtle.forward());
                z=z-1;
            end
        end
    end
    if (y~=y2) then
        while (y~=y2) do
            repeat turtle.digDown() until (turtle.down());
            y=y-1;
        end
    end
    facing = face(facing, 3)
    if (turtOrInv) then
        for i=16, 1, -1 do
            turtle.select(i)
            if (turtle.getItemCount() > 63) then
                local item = turtle.getItemDetail();
                if (item.name == "minecraft:dried_kelp_block") then
                    turtle.dropDown()
                    break;
                end
            end
        end
        turtle.select(1)
        for i=y, 383 do
            repeat turtle.digUp() until (turtle.up());
        end
    else
        repeat 
            local success = turtle.suckDown();
        until (not success);
        for i=y, 383 do
            repeat turtle.digUp() until (turtle.up());
        end
    end
end

repeat
    commandID = rednet.lookup(protocol, "tankercommand");
    os.sleep(0.05)
until (commandID ~= nil);

repeat
    local id, message, exit = nil;
    repeat
        id, message = rednet.receive(protocol);
        os.sleep(0.05)
    until (id ~= nil);
    if (id == commandID and istable(message)) then
        if (message[1] == "coords") then
            sx = message[2];
            sy = message[3]+1;
            sz = message[4]
            exit = true;
        end
    end
until (exit)

facing = findFacing(x, z)

repeat
    refuel()
    local emptySlots = 0;
    for i=16, 1, -1 do 
        if (turtle.getItemCount(i) < 64) then
            emptySlots = emptySlots+1;
        end
    end

    x, y, z = triangulate();
    if (emptySlots >= 14) then
        resupply(x, y, z, sx, sy, sz, false);
    end

    rednet.send(commandID, "tanker free", protocol)

    local id, message, exit = nil;
    repeat
        id, message = rednet.receive(protocol);
        if (id == commandID) then if (istable(message)) then
            if (message[1] == "fuel") then
                dx = message[2];
                dy = message[3]+1;
                dz = message[4]
                exit = true;
            end
        end end
        os.sleep(0.05)
    until (exit);
    x, y, z = triangulate();
    resupply(x, y, z, dx, dy, dz, true)
until (message == "end");

rednet.unhost(protocol)