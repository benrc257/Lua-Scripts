modem = peripheral.find("modem", rednet.open);
print("\nWireless modem found. Opening...")

protocol = "mining";
sauron = "sauron";
label = "gemstone";
os.setComputerLabel(label)
print("\nComputer Label (\"gemstone\") successfully set and broadcasted. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

print("\nCreating monitor interface...")
monitor = peripheral.find("monitor");
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear();
mwidth, mheight = monitor.getSize();
resolution = mwidth*mheight;
monitor.setTextScale(1.5)
marginW = (mwidth / 20);
marginH = (mheight / 2) / 3;
print("\nMonitor online.")

print("\nSauron boot sequence complete. Running mining script...")

function istable(t)
    return (type(t) == "table")
end

print("\nScanning for turtles...")
turtles = {};
turtleTotal = 0
repeat
    turtleTotal = turtleTotal+1;
    local searchID = rednet.lookup(protocol, ("" .. turtleTotal));
    table.insert(turtles, searchID)
    os.sleep(0.05)
until (searchID == nil)
turtleTotal = turtleTotal-1;
turtlesFree = {};
for i=1, turtleTotal do 
    turtlesFree[i] = true;
end

print("\n" .. turtleTotal .. " turtles found.")

print("\nRequesting coordinates...")
print("\nEnter the first X coordinate: ")
x1 = read();
print("\nEnter the first Y coordinate: ")
y1 = read();
print("\nEnter the first Z coordinate: ")
z1 = read();
print("\nEnter the second X coordinate: ")
x2 = read();
print("\nEnter the second Y coordinate: ")
y2 = read();
print("\nEnter the second Z coordinate: ")
z2 = read();



print("\nPartioning...")
length = math.abs(x1-x2);
width = math.abs(z1-z2);
depth = math.abs(y1-y2);

if (length%16 == 0) then 
    chunkLength = length/16;
else
    chunkLength = (length/16)+1;
end

if (width%16 == 0) then 
    chunkWidth = width/16;
else
    chunkWidth = (width/16)+1;
end

chunks = chunkLength*chunkWidth;

if (x1 > x2) then
    originX = x1;
else
    originX = x2;
end

if (y1 > y2) then
    originY = y1;
else
    originY = y2;
end

if (z1 < z2) then
    originZ = z1;
else
    originZ = z2;
end

corners = {};
for i=1, 1000 do
    corners[i] = {};
    for j=1, 2 do
        corners[i][j] = {};
    end
end
corners[1][1] = {originX, originZ};

for i=1, chunkLength do
    for j=1, chunkWidth do
        if (i == 1 and j == 1) then
            os.sleep(0.05)
        else
            corners[i][j] = {(corners[1][1][1]-(16*(i-1))), (corners[1][1][2]+(16*(j-1)))}
        end
    end
end

monitor.setCursorPos(marginW, ((mheight/2)-(mheight*.3)))
monitor.write("Progress: ")
old = term.redirect(monitor)
paintutils.drawFilledBox((marginW), ((mheight/2)+(mheight*.1)), (mwidth-marginW), ((mheight/2)+(mheight*.3)), colors.lightGray)
term.redirect(old)

chunksComplete = 0;
currentLength = 1;
currentWidth = 1;
repeat
    repeat
        for i=1, turtleTotal do
            if (turtlesFree[i]) then
                freeSlot = i;
                break;
            else 
                freeslot = 0;
            end
        end

        if (freeslot == 0) then
            repeat
                local freed = false;
                local id, message = rednet.receive(protocol, 10)
                if (id ~= nil and message == "free") then -- send free as string when done mining !!!
                    for i=1, turtleTotal do
                        if (turtles[i] == id) then
                            turtlesFree[i] = true;
                            freed = true;
                        end
                    end
                end
                os.sleep(0.05)
            until (freed)
        end
        os.sleep(0.05)
    until (freeSlot > 0);
    
    local message = {}; -- {"coords", x, y, z, depth, length, width}
    message[1] = "coords";
    message[2] = corners[currentLength][currentWidth][1];
    message[3] = originY;
    message[4] = corners[currentLength][currentWidth][2];
    message[5] = depth;
    if (currentLength == chunkLength and length%16) then
        message[6] = length%16;
    else
        message[6] = 16;
    end
    if (currentWidth == chunkWidth and width%16) then
        message[7] = width%16;
    else
        message[7] = 16;
    end
    rednet.send(turtles[freeSlot], message, protocol)
    turtlesFree[freeslot] = false;

    old = term.redirect(monitor)
    paintutils.drawFilledBox((marginW), ((mheight/2)+(mheight*.1)), ((mwidth-marginW)*(chunksComplete/chunks)), ((mheight/2)+(mheight*.3)), colors.red)
    term.redirect(old)

    if (currentWidth < chunkWidth) then
        currentWidth = currentWidth+1;
    else
        currentWidth = 1;
        currentLength = currentLength+1;
    end

    chunksComplete = chunksComplete+1;
    
until (chunksComplete >= chunks);

repeat
    local id, message = rednet.receive(protocol, 10)
    if (id ~= nil and message == "free") then -- send free as string when done mining !!!
        for i=1, turtleTotal do
            if (turtles[i] == id) then
                turtlesFree[i] = true;
            end
        end
    end

    local allFree = true;
    for i=1, turtleTotal do
        if(turtlesFree[i] == false) then
            allFree = false;
        end
    end
    os.sleep(0.05)
until (allFree);

rednet.broadcast("end", protocol);

monitor.setCursorPos(marginW, ((mheight/2)+(mheight*.1)))
monitor.setBackgroundColour(colors.black)
monitor.clearLine()
monitor.write("Complete!")

rednet.unhost(protocol)