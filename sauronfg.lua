modem = peripheral.find("modem", rednet.open);
print("\nWireless modem found. Opening...")

exit = false;
repeat
    local recID, message = rednet.receive(protocol, 1);
    --default message structure: "type-programname.lua-message-time sent-"
    if (recID ~= nil) then
        message = string.gsub(message, '-', " Turtle (running \"", 1);
        message = string.gsub(message, '-', "\"): ", 1);
        message = string.gsub(message, '-', " (Sent ", 1);
        message = string.gsub(message, '-', ")", 1);
        message = "(ID " .. recID .. ") " .. message;
        monitor.setCursorPos(marginW, (marginH+1))
        monitor.clearLine()
        monitor.write(message)
        print(message)
        
        if (string.match(message, "sauronmine.lua")) then
            rednet.broadcast(message, "mining")
        end
    end

    monitor.setCursorPos(1,1)
    monitor.clearLine()
    monitor.write(textutils.formatTime(os.time()))

until (exit);