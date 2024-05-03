modem = peripheral.find("modem", rednet.open);
print("\nWireless modem found. Opening...")

protocol = "sauron";
label = "eye";
ID = os.computerID();
os.setComputerLabel(label)
rednet.broadcast(label, protocol)
print("\nComputer Label (\"eye\") successfully set and broadcasted. Hosting sauron rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

print("\nCreating monitor interface...")
monitor = peripheral.find("monitor");
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear();
mwidth, mheight = monitor.getSize();
resolution = mwidth*mheight;
monitor.setTextScale(1)
marginW = (mwidth / 20);
marginH = (mheight / 2) / 3;
print("\nMonitor online.")

print("\nSauron boot sequence complete. Running primary script...")

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