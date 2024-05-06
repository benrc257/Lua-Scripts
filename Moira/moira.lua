print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem", rednet.open);
    os.sleep(2);
until (modem);
print("\nWireless modem found. Opening...")

protocol = "moria"; 
sauron = "sauron";
label = "Moria";
os.setComputerLabel(label)
print("\nComputer Label (\"" .. label .. "\") successfully set and broadcasted. Hosting moria rednet...")
rednet.host(protocol, label) -- opening moria rednet
print("\nHosting Successful.")

print("\nSearching for monitor...")
repeat -- opening monitor
    monitor = peripheral.find("monitor");
    os.sleep(2);
until (monitor);
print("\nCreating monitor interface...")
monitorName = peripheral.getName(monitor);
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear();
mwidth, mheight = monitor.getSize();
resolution = mwidth*mheight;
monitor.setTextScale(1.5)
marginW = (mwidth / 20);
marginH = (mheight / 2) / 3;
monitor.setCursorPos(marginW, ((mheight/2)-(mheight*.3)))
monitor.write("Booting...")
print("\nMonitor online.")

print("\nScanning for turtles...")
turtles = {{}};
turtleTotal = 0;
repeat
    turtleTotal = turtleTotal+1;
    local id = rednet.lookup(protocol, ("" .. turtleTotal));
    if (id ~= nil) then
        turtles[turtleTotal] = {id, true};
    end
    os.sleep(0.05)
until (id == nil);
turtleTotal = turtleTotal-1;
print("\n" .. turtleTotal .. "turtles found...")

print("\nSearching for disk drive...")
repeat -- opening disk drive
    drive = peripheral.find("drive");
    os.sleep(2);
until (drive);
print("\nDisk drive found.")
driveName = peripheral.getName(drive);
print("\nSearching for disk...")
if (not drive.isDiskPresent()) then
    print("\nNo disk found. Please insert the disk...")
    repeat
        os.sleep(2)
    until (drive.isDiskPresent())
end
disk = drive.getDiskLabel();
print("\n\"" .. disk .. "\" found.")
print("\nSearching for file \"coords\"")
file = fs.open("/disk/coords.txt", "r")
if (not file) then

end




