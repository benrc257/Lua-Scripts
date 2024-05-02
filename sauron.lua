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
monitor.setBackgroundColor(colors.white)
monitor.setTextColor(colors.black)
monitor.clear();
mwidth, mheight = monitor.getSize();
resolution = mwidth*mheight;
marginW = (mwidth / 2) / 3;
marginH = (mheight / 2) / 3;
print("\nMonitor online.")

print("\nSauron boot sequence complete. Running primary script...")

exit = false;
repeat
    local recID, message = rednet.receive(protocol, 5);
    --default message structure: "type - programname.lua - message - time sent -"
    if (recID ~= nil) then
        message = string.gsub(message, '-', " Turtle (running \"");
        message = string.gsub(message, '-', "\"): ");
        message = string.gsub(message, '-', "(Sent ");
        message = string.gsub(message, '-', ")");
        message = "(ID " .. recID .. ") " .. message;
        monitor.setCursor(marginW, (marginH+1))
        monitor.clearLine()
        monitor.write(message)
        
        if (string.match(message, "sauronmine.lua")) then
            rednet.broadcast(message, "mining")
        end
    end
    monitor.setCursor(1,1)
    monitor.write(textutils.formatTime(os.time()))


until (exit);