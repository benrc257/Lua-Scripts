modem = peripheral.find("modem", rednet.open);
print("\nWireless modem found. Opening...")

protocol = "mining";
label = "gemstone";
ID = os.computerID();
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

print("\nScanning for turtles...")
turtles = [];
turtleTotal = 1
repeat
    local searchID = rednet.lookup(protocol, ("" .. turtleTotal));
    turtleTotal = turtleTotal+1;
    table.insert(turtles, searchID)
until (searchID ~= nil)
turtlesFree = [];
for i=1, turtleTotal do 
    table.insert(turtles, 1)
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

tesseract = [];
print("\nRequesting teserract coordinates...")
print("\nEnter the teserract X coordinate: ")
tesseract[1] = read();
print("\nEnter the teserract Y coordinate: ")
tesseract[2] = read();
print("\nEnter the teserract Z coordinate: ")
tesseract[3] = read();

storage = [];
print("\nRequesting fuel storage coordinates...")
print("\nEnter the fuel storage X coordinate: ")
storage[1] = read();
print("\nEnter the fuel storage Y coordinate: ")
storage[2] = read();
print("\nEnter the fuel storage Z coordinate: ")
storage[3] = read();

multishell.launch({},"fuel.lua", storage);
multishell.launch({},"inv.lua", tesseract);

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

corners = [][]
corners[1] = originX;
corners[1][1] = originZ;

for i = 2, chunkLength do
    corners[i] = corners[i-1]-16;
    for j = 2, chunkWidth do
        corners[i][j] = corners[i-1][j-1]+16;
    end
end

monitor.setCursorPos(marginW, ((mheight/2)+(mheight*.1)))
monitor.write("Progress: ")
call(monitor, "paintutils.drawFilledBox", (mwidth-(mwidth*.9)), ((mheight/2)-(mheight*.1)), (mwidth*.9), ((mheight/2)-(mheight*.3)), colors.lightGray)

chunksComplete = 0;
currentLength = 1;
currentWidth = 1;
repeat
    local freeSlot = 0;
    repeat
        for i=1, turtleTotal do
            if (turtlesFree[i] == 1) then
                freeSlot = i;
                break;
            else freeslot = 0;
        end

        if (freeslot == 0) then
            repeat
                local free = false;
                local id, message = rednet.receive(protocol, 10)
                if (id ~= nil and message == "free") then -- send free as string when done mining !!!
                    for i=1, turtleTotal do
                        if (turtles[i] == id) then
                            turtlesFree[i] = 1;
                            freed = true;
                            break;
                        end
                    end
                end
            until (freed)
        end
    until (freeSlot > 0);
    
    local message = [] -- {"coords", x, y, z, depth, length, width}
    message[1] == "coords";
    table.insert(message, corner[currentLength])
    table.insert(message, originY)
    table.insert(message, corner[currentLength][currentWidth])
    table.insert(message, depth)
    if (currentLength == chunkLength and length%16) then
        table.insert(message, length%16)
    else
        table.insert(message, 16)
    end
    if (currentWidth == chunkWidth and width%16) then
        table.insert(message, width%16)
    else
        table.insert(message, 16)
    end
    rednet.send(turtles[freeSlot], message, protocol)

    call(monitor, "paintutils.drawFilledBox", (mwidth-(mwidth*.85)), ((mheight/2)-(mheight*.1)), (mwidth*((.85)-(mwidth*(.85*(chunksComplete/chunks))))), ((mheight/2)-(mheight*.3)), colors.red)

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
                turtlesFree[i] = 1;
            end
        end
    end

    local allFree = true;
    for i=1, turtleTotal do
        if(turtlesFree[i] == 0) then
            allFree = false;
        end
    end
until (allFree);

rednet.broadcast("end", protocol);

monitor.setCursorPos(marginW, ((mheight/2)+(mheight*.1)))
monitor.setBackgroundColour(colors.black)
monitor.clearLine()
monitor.write("Complete!")




    



