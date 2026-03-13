-- libs
func = require("functions")

-- variables
protocol = "sauron"; -- rednet protocol
turtleProtocol = "sauronTurtles"
tankerProtocol = "sauronTankers"
supplierProtocol = "sauronSuppliers"
label = "EYE"; -- computer label
turtles = {}; -- list of turtles
turtlesIdle = {}; -- list of idle turtles
chunkSize = 16 -- size of mined chunks
local x1, x2, y1, y2, z1, z2, maxheight = nil -- used for initial coordinates
local lastchunk = nil -- used for last chunk completed in file
local file = nil -- used for operation file
local previousOperation = nil -- used to tell if there was a previous incomplete mining operation
local originX, originY, originZ = nil -- used for starting coords

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronMain")

-- initializing rednet
func.rednetInit(label)
func.rednetHost(protocol, label)
func.rednetHost(turtleProtocol, label)

-- display setup
monitor, monitorWidth, monitorHeight, resolution, marginWidth, marginHeight = func.monitorInit()

-- turtle scan
print("\nScanning for turtles...")
turtles, turtlesIdle = func.updateTurtles(turtleProtocol, turtles, turtlesIdle)

-- attempt to recover previous operation
print("\nSauron boot sequence complete. Searching for previous operations...")
file, previousOperation = func.openOperationFile()

if (previousOperation == false) then -- if no previous operation found, request coordinates

    do
        print("\nNo previous operation found. Requesting coordinates...")
        print("\nEnter the first X coordinate: ")
        x1 = read()
        print("\nEnter the first Y coordinate: ")
        y1 = read()
        print("\nEnter the first Z coordinate: ")
        z1 = read()
        print("\nEnter the second X coordinate: ")
        x2 = read()
        print("\nEnter the second Y coordinate: ")
        y2 = read()
        print("\nEnter the second Z coordinate: ")
        z2 = read()
        print("\nEnter the max safe height: ")
        maxheight = read()
        print("\nEnter the max partition (chunk) size: ")
        chunkSize = read()
        print("\nContinue? (Y/N)")
        local confirm = read()
    until (confirm == "y" or confirm == "Y") end

    -- write new operation coords to file
    file.write(x1 .. "\n" .. y1 .. "\n" .. z1 .. "\n" .. x2 .. "\n" .. y2 .. "\n" .. z2 .. "\n" .. maxheight .. "\n")

else -- if previous operation found, read from file and find last chunk completed and coords

    x1 = file.readLine()
    y1 = file.readLine()
    z1 = file.readLine()
    x2 = file.readLine()
    y2 = file.readLine()
    z2 = file.readLine()
    maxheight = file.readLine()

    local lastline = {}
    do -- read through file to find last chunk completed
        lastline.append(file.readLine())
    while lastline[#lastline] ~= nil end

    
    if (lastline[1] == nil or lastline[2] == nil) then -- check if lastchunk wasn't there
        lastchunk = nil
    else -- otherwise record last chunk
        lastchunk = {lastline[(#lastline) - 2], lastline[(#lastline) - 1]}
    end

end


-- partioning chunks for jobs
print("\nPartioning...")
local length = math.abs(x1-x2)
local width = math.abs(z1-z2)
local depth = math.abs(y1-y2)

-- calculate number of chunks long
if (length%chunkSize == 0) then
    chunkLength = length/chunkSize;
else
    chunkLength = (length/chunkSize)+1;
end

-- calculate number of chunks wide
if (width%chunkSize == 0) then 
    chunkWidth = width/chunkSize;
else
    chunkWidth = (width/chunkSize)+1;
end

-- calculate total number of chunks
local chunks = chunkLength*chunkWidth;

-- calculate origin
if (x1 < x2) then
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

-- assign corners
corners = {}
local chunksPartioned = 1
for i=1, length do -- chunks are partioned in order from bottom left to top right

    -- calculates corner X and Y coords
    local corner1X = originX+((i-1)*chunkSize)
    local corner1Y = originY
    local corner2X = originX+(i*(chunkSize-1))
    local corner2Y = originY-depth

    for j=1, width do -- for width
        -- calculates corner Z coords
        local corner1Z = originZ+((j-1)*chunkSize)
        local corner2Z = originZ+(j*(chunkSize-1))

        -- inserts the corner coords into the array
        corners[chunksPartioned] = {}
        corners[chunksPartioned][1] = {corner1X,corner1Y,corner1Z} -- starting corner is accessed at index 1
        corners[chunksPartioned][2] = {corner2X,corner2Y,corner2Z} -- ending corner is accessed at index 2
        chunksPartioned = chunksPartioned+1
    end
end

-- launch helper programs
multishell.setTitle(multishell.launch("SauronTank.lua"), "SauronTank", protocol, tankerProtocol)
multishell.setTitle(multishell.launch("SauronSupply.lua"), "SauronSupply", protocol, supplierProtocol)
multishell.setTitle(multishell.launch("SauronTurtles.lua"), "SauronTurtles", protocol, turtleProtocol)













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
            if (turtlesIdle[i]) then
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
                            turtlesIdle[i] = true;
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
    if (currentLength == chunkLength and length%chunkSize) then
        message[6] = length%chunkSize;
    else
        message[6] = chunkSize;
    end
    if (currentWidth == chunkWidth and width%chunkSize) then
        message[7] = width%chunkSize;
    else
        message[7] = chunkSize;
    end
    rednet.send(turtles[freeSlot], message, protocol)
    turtlesIdle[freeslot] = false;

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
                turtlesIdle[i] = true;
            end
        end
    end

    local allFree = true;
    for i=1, turtleTotal do
        if(turtlesIdle[i] == false) then
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