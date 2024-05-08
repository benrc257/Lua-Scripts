modem = peripheral.find("modem")
protocol = "moria"; 

function istable(t)
    return (type(t) == "table")
end

counter = 1;
awaiting = 1;
messages = {}
function receiver()
    repeat
        local id, message = rednet.receive(protocol)
        if (istable(message)) then
            if ((#message) == 7) then
                messages[counter] = message;
                counter = counter+1;
            end
        end
        os.sleep(0.05)
    until (message == "end")
    os.reboot()
end

function waiter()
    os.pullEvent("ready");
end

repeat
    parallel.waitForAny(waiter, receiver)
    
    if ((#messages) < awaiting) then
        repeat
            local exit = false;
            local id, message = rednet.receive(protocol)
            if (istable(message)) then
                if ((#message) == 7) then
                    messages[counter] = message;
                    counter = counter+1;
                    exit = true;
                end
            end
        until (exit);
    end

    os.queueEvent("coordinates", messages[awaiting])
    print("Message from turtle containing \"coordinates\", set as event " .. awaiting)
    awaiting = awaiting+1;
until (false);
