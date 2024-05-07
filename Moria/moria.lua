print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem");
    os.sleep(0.05)
until (modem)
modemName = peripheral.getName(modem);
rednet.open(modemName)
print("\nWireless modem found. Opening...")

protocol = "moria"; 
label = "Moria";
os.setComputerLabel(label)
print("\nComputer Label (\"" .. label .. "\") successfully set and broadcasted. Hosting moria rednet...")
rednet.host(protocol, label) -- opening moria rednet
print("\nHosting Successful.")

print("\nSearching for monitor...")
repeat -- opening monitor
    monitor = peripheral.find("monitor");
    os.sleep(0.05)
until (monitor ~= nil);
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
print("\n" .. turtleTotal .. " turtles found...")

print("\nSearching for disk drive...")
repeat -- opening disk drive
    drive = peripheral.find("drive");
    os.sleep(2);
until (drive ~= nil);
print("\nDisk drive found.")
driveName = peripheral.getName(drive);
print("\nSearching for disk...")
if (not drive.isDiskPresent()) then
    print("\nNo disk found. Please insert the disk...")
    repeat
        os.sleep(0.05)
    until (drive.isDiskPresent())
end
disk = drive.getDiskLabel();
print("\nDisk found.")
print("\nSearching for file \"coords.txt\"")
file = fs.open("/disk/coords.txt", "r")
if (not file) then
    print("\nFile \"coords.txt\" could not be opened. Returning...")
    return;
end
print("\nFile opened. Reading...")
coords = {}
for i=1, 7 do table.insert(coords, tonumber(file.readLine())) end -- 1 - x1, 2 - y1, 3 - z1, 4 - x2, 5 - y2, 6 - z2, 7 - mah

if (not coords[1]) then
    print("\nFile \"coords.txt\" is empty. Returning...")
    return;
end
print("\nCoordinates found. Closing file...")
file.close()

print("\nPartioning...")
length = math.abs(coords[1]-coords[4]); -- length is x
width = math.abs(coords[2]-coords[5]); -- depth is y
depth = math.abs(coords[3]-coords[6]); -- width is z
mah = coords[7];

lengthRemainder = length%16;
widthRemainder = width%16;

if (lengthRemainder) then
    chunkLength = math.floor(length/16)+1;
else
    chunkLength = length/16;
end

if (widthRemainder) then
    chunkWidth = math.floor(width/16)+1;
else
    chunkWidth = width/16;
end

print("\nArea is " .. chunkLength .. " by " .. chunkWidth .. " chunks, with a depth of " .. depth .. " blocks.")

if (coords[1] > coords[4]) then
    originX = coords[1];
else
    originX = coords[4];
end

if (coords[2] > coords[5]) then
    originY = coords[2];
else
    originY = coords[5];
end

if (coords[3] > coords[6]) then
    originZ = coords[3];
else
    originZ = coords[6];
end

print("\nOrigin found at " .. originX .. ", " .. originY .. ", " .. originZ .. ".") -- mining from +,+ to -,- or greater to lesser

partions = {};
totalPartions = 0;
for i=1, chunkLength do
    partions[i] = {}
    for j=1, chunkWidth do
        partions[i][j] = {(originX-(16*(i-1))), (originY), (originZ-(16*(j-1)))}
        totalPartions = totalPartions+1;
    end
end
progressIncrement = (mwidth - (marginW))/totalPartions; -- used for progress bar

print("\n" .. totalPartions .. " partions created.")

print("\nLaunching Moria relay...")
relayID = multishell.launch({}, "moriarelay.lua")

function findFree()
    local returnID, event = nil;

    for i=1, turtleTotal do -- detects if a turtle is free
        if (turtles[i][2]) then
            returnID = turtles[i][1];
            turtles[i][2] = false; -- once a turtle is set to busy by findFree(), findFree() cannot revert the value to true
            break;
        end
    end

    if (returnID == nil) then -- if no turtle is free, waits for event from the relay
        event, returnID = os.pullEvent("turtleFree");
    end

    return returnID;
end

function findTurtleSlot(check)
    for i=1, turtleTotal do -- detects if a turtle is free
        if (check == turtles[i][1]) then
            check = i;
            break;
        end
    end

    return check;
end

monitor.clear();
monitor.setTextColor(colors.white)
monitor.setCursorPos(marginW, ((mheight/2)-(mheight*.3)))
monitor.write("Progress:")
monitor.setCursorPos(1, 1)
old = term.redirect(monitor)
    paintutils.drawFilledBox((marginW), ((mheight/2)+(mheight*.1)), (mwidth-marginW), ((mheight/2)+(mheight*.2)), colors.lightGray)
term.redirect(old)

progressTracker = 1;
for i=1, chunkLength do
    for j=1, chunkWidth do
        local id = findFree();
        local slot = findTurtleSlot(id);
        
        table.insert(partions[i][j], depth)
        if (currentLength == chunkLength and lengthRemainder) then
            table.insert(partions[i][j], lengthRemainder)
        else
            table.insert(partions[i][j], 16)
        end
        if (currentWidth == chunkWidth and widthRemainder) then
            table.insert(partions[i][j], widthRemainder)
        else
            table.insert(partions[i][j], 16)
        end
        table.insert(partions[i][j], (mah+slot))

        rednet.send(id, partions[i][j], protocol) -- {x, y, z, depth, length, width, mah}

        progressTracker = progressTracker+1;
        old = term.redirect(monitor)
            paintutils.drawFilledBox((marginW), ((mheight/2)+(mheight*.1)), (marginW+((progressIncrement*progressTracker))), ((mheight/2)+(mheight*.2)), colors.red)
        term.redirect(old)
    end
end


totalFree = 1;
for i=1, turtleTotal do
    if (turtles[i][2]) then
        totalFree = totalFree+1
    end
end

for i=totalFree, turtleTotal do
    os.pullEvent("turtleFree");
end

monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.setCursorPos(marginW, ((mheight/2)-(mheight*.3)))
monitor.write("Mining Complete!")

rednet.unhost(protocol)