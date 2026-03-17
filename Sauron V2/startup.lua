-- Look upon my works, ye mighty, and despair!

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronMain")

-- variables
completed = false -- switch to true when mining is over
turtles = {}; -- list of turtles
turtlesIdle = {}; -- list of idle turtles
turtleJobs = {} -- 1 - miner, 2 - tanker, 3 - supplier
chunkSize = 16 -- size of mined chunks
chunksComplete = 1 -- chunks left
local filename = "operations.txt" -- used for save file
local x1, x2, y1, y2, z1, z2, maxheight = nil -- used for initial coordinates
local lastchunk = nil -- used for last chunk completed in file
local file = nil -- used for operation file
local previousOperation = nil -- used to tell if there was a previous incomplete mining operation
local originX, originY, originZ = nil -- used for starting coords

-- setting vars
fuelSource = "minecraft:dried_kelp_block" -- change if you want to swap fuel sources

-- rednet vars
label = "EYE"; -- computer label
protocol = "sauron"; -- rednet protocol
turtleProtocol = "sauronTurtles"
miningProtocol = "sauronMiners"
tankerProtocol = "sauronTankers"
supplierProtocol = "sauronSuppliers"
dockProtocol = "sauronDocking"
needsSupply = "needSupply" -- send from turtles for supply
needsFuel = "needFuel" -- send from turtles for fuel
dockingRequest = "needDocking" -- send from turtles for docking
doneDocking = "doneDocking" -- send from docking computer to end docking
idlecheck = "idlecheck"
idleresponse = "idle"

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronMain")

-- initializing rednet
modem = func.rednetInit(label)
func.rednetHost(protocol, label)
func.rednetHost(turtleProtocol, label)
func.rednetHost(miningProtocol, label)
func.rednetHost(dockProtocol, label)
func.rednetHost(supplierProtocol, label)
func.rednetHost(tankerProtocol, label)

-- display setup
monitor, mwidth, mheight, resolution, marginW, marginH = func.monitorInit()

-- turtle scan
print("\nScanning for turtles...")
turtles, turtlesIdle = func.updateTurtles(turtleProtocol, turtles, turtlesIdle)
turtleJobs = {}

-- attempt to recover previous operation
print("\nSauron boot sequence complete. Searching for previous operations...")
file, previousOperation = func.openOperationFile(filename)

if (previousOperation == false) then -- if no previous operation found, request coordinates

    repeat
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
    until (confirm == "y" or confirm == "Y")

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
    repeat -- read through file to find last chunk completed
        local reading = file.readLine()
        table.insert(lastline, reading)
    until (lastline[#lastline] == nil)

    
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
for i=1, length-1 do -- chunks are partioned in order from bottom left to top right

    -- calculates corner X and Y coords
    local corner1X = originX+((i-1)*chunkSize)
    local corner1Y = originY
    local corner2X = originX+(i*(chunkSize-1))
    local corner2Y = originY-depth

    for j=1, width-1 do -- for width
        -- calculates corner Z coords
        local corner1Z = originZ+((j-1)*chunkSize)
        local corner2Z = originZ+(j*(chunkSize-1))

        -- inserts the corner coords into the array
        corners[chunksPartioned] = {}
        corners[chunksPartioned][1] = {corner1X,corner1Y,corner1Z} -- starting corner is accessed at index 1
        corners[chunksPartioned][2] = {corner2X,corner2Y,corner2Z} -- ending corner is accessed at index 2
        chunksPartioned = chunksPartioned+1
    end

    for j=width, width do -- for edge chunks, yes i just made it a for loop so i could reuse logic dont hurt me :(
        -- calculates corner Z coords
        local corner1Z = originZ+((j-2)*chunkSize)+(width%chunkSize)
        local corner2Z = originZ+((j-1)*(chunkSize-1))+(width%chunkSize)

        -- inserts the corner coords into the array
        corners[chunksPartioned] = {}
        corners[chunksPartioned][1] = {corner1X,corner1Y,corner1Z} -- starting corner is accessed at index 1
        corners[chunksPartioned][2] = {corner2X,corner2Y,corner2Z} -- ending corner is accessed at index 2
        chunksPartioned = chunksPartioned+1
    end
end

for i=length, length do -- handling of top edge chunks

    -- calculates corner X and Y coords
    local corner1X = originX+((i-1)*chunkSize)
    local corner1Y = originY
    local corner2X = originX+((i-1)*(chunkSize-1))+(originX%chunkSize)
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
    for j=width, width do -- for edge chunks, yes i just made it a for loop so i could reuse logic dont hurt me :(
        -- calculates corner Z coords
        local corner1Z = originZ+((j-1)*chunkSize)
        local corner2Z = originZ+((j-1)*(chunkSize-1))+(originZ%chunkSize)

        -- inserts the corner coords into the array
        corners[chunksPartioned] = {}
        corners[chunksPartioned][1] = {corner1X,corner1Y,corner1Z} -- starting corner is accessed at index 1
        corners[chunksPartioned][2] = {corner2X,corner2Y,corner2Z} -- ending corner is accessed at index 2
        chunksPartioned = chunksPartioned+1
    end
end

-- monitor setup
monitor.setCursorPos(marginW, ((mheight/2)-(mheight*.3)))
monitor.write("Progress: ")
old = term.redirect(monitor)
paintutils.drawFilledBox((marginW), ((mheight/2)+(mheight*.1)), (mwidth-marginW), ((mheight/2)+(mheight*.3)), colors.lightGray)
term.redirect(old)

-- launch helper programs
multishell.launch(_ENV,"SauronTank.lua") -- contacts tankers
multishell.launch(_ENV,"SauronSupply.lua") -- contacts suppliers
multishell.launch(_ENV,"SauronTurtles.lua") -- updates turtle list
multishell.launch(_ENV,"SauronDock.lua") -- docks turtles

os.sleep(10)

repeat
    local minerID = 1
    local minerIndex = 1
    repeat -- find a free miner
        if ((minerIndex) > #turtleJobs) then minerIndex = 1 end -- resets to zero when ID bigger than table
        minerID = func.matchID(turtleJobs, 1, minerIndex)
        os.sleep(1)
        print("\nSearching for miner at id " .. minerIndex)
        minerIndex = minerIndex+1
    until turtlesIdle[minerID] == true

    local nextCoordinates = {corners[chunksComplete][1],corners[chunksComplete][2],maxheight} -- THIS IS THE MESSAGE THE TURTLES RECEIVE


    -- contact miner with coordinates
    rednet.send(minerID, nextCoordinates, miningProtocol)
    print("\nSent Coordinates " .. nextCoordinates .. " to " .. minerID)
    turtlesIdle[minerID] = false

    -- progress bar
    old = term.redirect(monitor)
    paintutils.drawFilledBox((marginW), ((mheight/2)+(mheight*.1)), ((mwidth-marginW)*(chunksComplete/chunks)), ((mheight/2)+(mheight*.3)), colors.red)
    term.redirect(old)
    chunksComplete = chunksComplete+1
    file.write(nextCoordinates[1][1] .. "\n" .. nextCoordinates[1][2] .. "\n" .. nextCoordinates[1][3] .. "\n" .. nextCoordinates[2][1] .. "\n" .. nextCoordinates[2][2] .. "\n" .. nextCoordinates[2][3] .. "\n" .. maxheight .. "\n")
    file.flush()
until chunksComplete > chunks

-- close save file
closeOperationFile(file, filename)

repeat -- wait until all turtles are free
    os.sleep(10)
until (matchID(turtlesIdle, false, 1) == 0)

-- show complete on monitor
monitor.setCursorPos(marginW, ((mheight/2)+(mheight*.1)))
monitor.setBackgroundColour(colors.black)
monitor.clearLine()
monitor.write("Complete!")

-- broadcast completed to turtles
func.broadcast("completed", turtleProtocol)

-- update completed flag
completed = true













