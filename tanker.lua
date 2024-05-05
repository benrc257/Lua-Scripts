protocol = "mining";
label = "tanker";
os.setComputerLabel(label)
print("\nComputer Label (\"tanker\") successfully set and broadcasted. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

function triangulate()
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

function refuel()
    if (turtle.getFuelLevel <= 4000) then
        turtle.select(1)
        turtle.refuel()
    end
end

function resupply()

end

repeat
    commandID = rednet.lookup(protocol, "tankercommand");
until (commandID ~= nil);

repeat
    local id, message, exit = nil;
    repeat
        id, message = rednet.receive(protocol);
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

repeat
    refuel()
    local emptySlots = 0;
    for i=16, 2, -1 do 
        local present = turtle.getItemCount(i)
        if (not present) then
            emptySlots = emptySlots+1;
        end
    end

    if (emptySlots == 15) then
        local x, y, z = triangulate();
        resupply(x, y, z, sx, sy, sz);
    end

    rednet.send(commandID, "tanker free", protocol)

    local id, message = nil;
    repeat
        id, message = rednet.receive(protocol);
    until (id ~= nil);
    if (istable(message)) then
        if (message[1] == "fuel") then
            dx = message[2];
            dy = message[3]+1;
            dz = message[4]
            exit = true;
        end
    end
until (message == "end");
