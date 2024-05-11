protocol = "teleporter1"; -- controls channel for tp pairs
modem = peripheral.find("modem", rednet.open)
mode = 0;

function sending()
    repeat
        local input = redstone.getInput("bottom")
        os.sleep(0.05)
    until (input);
    print("\nInput Detected")
    mode = 1;
end

function receiving()
    repeat
        local id, message = rednet.receive(protocol, 10)
    until (message == protocol);
    print("\nMessage Received")
    mode = 2;
end

function returning()
    local id, message = rednet.receive(protocol, 10)
    print("\nReturn Requested")
    mode = 3;
end

function sendDisk()
    local loopCount = 0;
    os.sleep(1)
    turtle.select(1)
    repeat
        turtle.suckDown()
        loopCount = loopCount + 1;
        os.sleep(0.25)
    until (turtle.getItemCount() > 0 or loopCount > 8);
    if (loopCount > 8) then
        print("\nSender was stuck in loop!")
    end
    turtle.drop()
    rednet.broadcast(protocol, protocol)
    print("\nDisk Sent")
end

function receiveDisk()
    local loopCount = 0;
    os.sleep(1)
    turtle.select(1)
    repeat
        redstone.setOutput("bottom", true)
        os.sleep(0.25)
        redstone.setOutput("bottom", false)
        os.sleep(0.25)
        turtle.suckDown()
        loopCount = loopCount + 1;
    until (turtle.getItemCount() > 0 or loopCount > 8);
    if (loopCount > 8) then
        print("\nReceiver was stuck in loop!")
    end
    turtle.dropDown()
    print("\nDisk Received")
    os.sleep(4)
end

function returnDisk()
    local loopCount = 0;
    turtle.select(1)
    repeat
        redstone.setOutput("bottom", true)
        os.sleep(0.25)
        redstone.setOutput("bottom", false)
        os.sleep(0.25)
        turtle.suckDown()
        loopCount = loopCount + 1;
    until (turtle.getItemCount() > 0 or loopCount > 8);
    if (loopCount > 8) then
        print("\nReturner was stuck in loop!")
    end
    turtle.drop()
    print("\nDisk Returned")
    os.sleep(1)
end

repeat
    parallel.waitForAny(sending, receiving)
    if (mode == 1) then
        sendDisk()
    elseif (mode == 2) then
        parallel.waitForAny(receiveDisk, returning)
        if (mode == 3) then
            returnDisk()
        end
    end
until (false);