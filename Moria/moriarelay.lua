progressIncrement = {...};
progressIncrement = progressIncrement[1]
modem = peripheral.find("modem");
protocol = "moria"; 
monitor = peripheral.find("monitor");
progressTracker = 0;
mwidth, mheight = monitor.getSize();
marginW = (mwidth / 20);
marginH = (mheight / 2) / 3;

awaiting = 1;
print("Moria relay active!")

counter = 1;
awaiting = 1;
messages = {}
function receiver()
    repeat
        local id, message = rednet.receive(protocol)
        if (message == "free") then
            messages[counter] = id;
            counter = counter+1;
        end
    until (message == "end")
    os.reboot()
end

function waiter()
    os.pullEvent("ready");
end

repeat
    parallel.waitForAny(waiter, receiver)
    
    if (messages[awaiting] == nil) then
        repeat
            local id, message = rednet.receive(protocol)
            if (message == "free") then
                messages[counter] = id;
                counter = counter+1;
            end
        until (message == "free");
    end

    os.queueEvent("turtleFree", messages[awaiting])
    print("Message from turtle containing \"free\", set as event " .. awaiting)
    awaiting = awaiting+1

    progressTracker = progressTracker+1;
    old = term.redirect(monitor)
        paintutils.drawFilledBox((marginW), ((mheight/2)+(mheight*.1)), (marginW+((progressIncrement*progressTracker))), ((mheight/2)+(mheight*.2)), colors.red)
    term.redirect(old)
until (false);