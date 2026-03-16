local function triangulate() -- returns GPS coordinates
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

local function rednetInitTurtle()  -- Opens rednet on the computer and returns the modem peripheral
    print("\nAttempting to find modems...")
    repeat -- repeatedly search for modems and open rednet until both are complete
        local modems = peripheral.find("modem", rednet.open);
    until #modems > 0 and rednet.isOpen() end
    print("\nWireless modem found, rednet opened.")

    print("\nSearching for existing turtles...")
    local label = 0;
    repeat
        label = label+1;
        local lookup =  rednet.lookup(turtleProtocol, "" .. label);
        if (lookup ~= nil) then
            print("\nTurtle " .. label .. " found.")
        end
        os.sleep(0.05)
    until (lookup == nil);
    label = ("" .. label);

    os.setComputerLabel(label)
    print("\nComputer Label (".. label ..") successfully set.")
    return {modems, label}
end

local function refuel(x, y, z, needsFuel, centralComputer)
    if (turtle.getFuelLevel() <= 1000) then -- if fuel level low, refuel

        turtle.select(1)
        if (turtle.getItemCount() ~= 64) then -- if no fuel, request fuel
            local message = {}
            message[1] = needsFuel
            message[2] = {x,y,z}
            local supplyID = nil

            repeat -- find supply computer id
                supplyID = rednet.lookup(tankerProtocol, centralComputer)
                os.sleep(0.05)
            until (supplyID) end
            rednet.send(supplyID, message, tankerProtocol)

            repeat -- wait for fuel
                os.sleep(1)
            until (turtle.getItemCount(1) == 64);

        end

        turtle.refuel(63) -- refuel
    end
end

local function dropOff(x, y, z, needsSupply, centralComputer) -- function waits for supplier turtle to arrive, then gives all items to it
    local message = {}
    message[1] = needsSupply;
    message[2] = {x,y,z}

    local supplyID = nil;
    repeat
        supplyID = rednet.lookup(supplierProtocol, centralComputer)
        os.sleep(0.05)
    until (supplyID);
    rednet.send(supplyID, message, protocol)

    repeat
        local success = false;
        local present, block = turtle.inspectDown();
        if (present) then if (block.name == "computercraft:turtle_advanced" or block.name == "computercraft:turtle") then success = true; end end
        os.sleep(0.05)
    until (success)

    for i=2, 16 do 
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(1)
end

function turnR(facing) -- 1 = north, 2 = east, 3 = south, 4 = west
    turtle.turnRight()
    if (facing == 1) then facing = 4; else facing = facing-1; end
    return facing;
end

function turnL(facing) -- 1 = north, 2 = east, 3 = south, 4 = west
    turtle.turnLeft()
    if (facing == 4) then facing = 1; else facing = facing+1; end
    return facing;
end

function face(facing, direction) -- direction is an int
    if (direction ~= facing) then 
        if ((facing-direction) == 3) then
            facing = turnL(facing);
        elseif ((facing-direction) == -3) then
            facing = turnR(facing);
        elseif (direction > facing) then
            repeat 
                facing = turnL(facing);
            until (direction == facing);
        else
            repeat 
                facing = turnR(facing);
            until (direction == facing);
        end
    end
    return facing;
end

function fillLiquid()
    local present, block = turtle.inspectDown();
    if (present) then if (block.name == "minecraft:lava" or block.name == "minecraft:water") then
        local slot = 1
        local success = false;
        while (slot < 16 and not success) do
            slot = slot+1;
            turtle.select(slot)
            local item = turtle.getItemDetail();
            if (not (item.name == "minecraft:sand" or item.name == "minecraft:gravel")) then
                success = turtle.placeDown();
            end
        end
        turtle.select(1);
        slot = 1;
    end end
end

-- if (want to take over world) then "no" end

local function rednetInit(label)  -- Opens rednet on the computer and returns the modem peripheral
    print("\nAttempting to find modems...")
    repeat -- repeatedly search for modems and open rednet until both are complete
        local modems = peripheral.find("modem", rednet.open);
    until #modems > 0 and rednet.isOpen() end
    print("\nWireless modem found, rednet opened.")
    os.setComputerLabel(label)
    print("\nComputer Label (".. label ..") successfully set.")
    return {modems, label}
end

local function rednetHost(protocol, label) -- Hosts rednet under the given label and protocol, making the pc visible upon lookup
    print("\nHosting " .. protocol .. " rednet under the name " .. label .. "...")
    rednet.host(protocol, label)
    print("\nHosting Successful.")
end

local function monitorInit() -- Sets up monitor and readies it for use

    --finding monitor
    print("\nCreating monitor interface...")
    local monitor = peripheral.find("monitor");
    local monitor = monitor[#monitor]

    --settings
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.setTextScale(1.5)

    --clear screen
    monitor.clear();

    --calculating size and margins
    local monitorWidth, monitorHeight = monitor.getSize();
    local resolution = monitorWidth*monitorHeight;
    local marginWidth = (monitorWidth / 20);
    local marginHeight = (monitorHeight / 20);

    print("\nMonitor online.")
    return {monitor, monitorWidth, monitorHeight, resolution, marginWidth, marginHeight}
end

local function isTable(t) -- checks if t is a table, returns bool
    return (type(t) == "table")
end

local function updateTurtles(turtleProtocol, turtles, turtlesIdle) -- searches for turtles and returns a list

    -- finds list of turtles
    turtles = rednet.lookup(turtleProtocol);
        
    -- initializes idleTurtles to false
    turtlesIdle = {}
    for i=1, #turtles do 
        turtlesIdle.append(false)
    end

    -- pings idle turtles and creates a list
    rednet.broadcast("idlecheck", turtleProtocol)

    -- checking pings
    local pingIDs = {}
    repeat -- receive pings and add them to the list
        local id = nil
        local message = nil
        id, message = rednet.receive(turtleProtocol, 1)
        if (message == "idle") then -- if idle message was received add it to the list
            pingIDs.append(id)
        end
    while id ~= nil end 

    -- update idle turtle status
    for i=1, #pingIDs do
        for j=1, #turtles do
            if (pingIDs[i] == turtles[j]) then
                turtlesIdle[j] = true
            end
        end
    end

    print("\n" .. #turtles .. " turtles found.")
    return {turtles, turtlesIdle}
end

local function openOperationFile(filename) -- opens the last file and checks if it was completed, otherwise it creates a new one
    local file = nil
    local previousOperation = false
    if (fs.exists("/sauron/mining/") == false) then -- checks if doesnt directory exist
        fs.makeDir("/sauron/mining/")
    else -- if directory does exist
        if (fs.exists("/sauron/mining/" .. filename) == true) then -- checks if file exists directory exist
            previousOperation = true
        end
    end

    file = fs.open("/sauron/mining/" .. filename, "r+")
    return {file, previousOperation}
end

local function triangulate() -- returns GPS coordinates
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

local function matchID(table, id, startingIndex) -- finds id in table1 starting at startingIndex, returns index
    for i=startingIndex, #table do
        if (id == table[i]) then
            return i
        end
    end
    return 0
end

-- function list to return
return {
    triangulate = triangulate,
    rednetInitTurtle = rednetInitTurtle,
    refuel = refuel,
    dropOff = dropOff,
    turnR = turnR,
    turnL = turnL,
    face = face,
    rednetInit = rednetInit,
    rednetHost = rednetHost,
    monitorInit = monitorInit,
    isTable = isTable,
    updateTurtles = updateTurtles,
    openOperationFile = openOperationFile,
    triangulate = triangulate,
    matchID = matchID
}
