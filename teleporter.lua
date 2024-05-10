protocol = "teleporter1";
modem = peripheral.find("modem", rednet.open)
mode = 0;

function sending()
    repeat
        local output = redstone.getInput("bottom")
        os.sleep(0.05)
    until (output);
    mode = 1;
end

function receiving()
    repeat
        local id, message = rednet.receive(protocol)
    until (message == "teleporting");
    mode = 2;
end

function receivingExecute()
    repeat
        os.sleep(4)
        redstone.setOutput("bottom", true)
        os.sleep(0.5)
        redstone.setOutput("bottom", false)
        os.sleep(0.5)
        turtle.suckDown()
        os.sleep(0.5)
        local success = turtle.dropDown()
        os.sleep(5)
    until (success);
    print("Receiving...")
end

function returning()
    repeat
        local id, message = rednet.receive(protocol)
    until (message == "teleporting");
    print("Sending...")
    mode = 3;
end

repeat
    parallel.waitForAny(sending, receiving)
    if (mode == 1) then
        os.sleep(2)
        repeat
            turtle.suckDown()
            os.sleep(0.05)
            local success = turtle.drop()
        until (success);
        rednet.broadcast("teleporting", protocol)
        print("Sending...")
    else
        parallel.waitForAny(returning, receivingExecute)
        if (mode == 3) then
            redstone.setOutput("bottom", true)
            os.sleep(0.5)
            redstone.setOutput("bottom", false)
            repeat
                turtle.suckDown()
                os.sleep(0.05)
                local success = turtle.drop()
            until (success);
        end
    end
    os.sleep(5)
until false;