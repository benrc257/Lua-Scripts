local function triangulate() -- returns GPS coordinates
    repeat
        x, y, z = gps.locate(5)
    until (x ~= nil)
    return x, y, z
end

local function rednetInitTurtle()  -- Opens rednet on the computer and returns the modem peripheral
    print("\nAttempting to find modems...")
    repeat -- repeatedly search for modems and open rednet until both are complete
        local modems = peripheral.find("modem", rednet.open)
    until (rednet.isOpen())
    print("\nWireless modem found, rednet opened.")

    print("\nSearching for existing turtles...")
    local label = 0
    repeat
        label = label+1
        local lookup =  rednet.lookup(turtleProtocol, "" .. label)
        if (lookup ~= nil) then
            print("\nTurtle " .. label .. " found.")
        end
        os.sleep(0.05)
    until (lookup == nil)
    label = ("" .. label)

    os.setComputerLabel(label)
    print("\nComputer Label (".. label ..") successfully set.")
    return modems, label
end

local function detectTurtle(direction) -- prevents the bot from mining another turtle during transport

    repeat
        local isTurtle = false
        local present, block = nil

        -- detects the direction
        if direction == "forward" then
            present, block = turtle.inspectForward()
        elseif direction == "down" then
            present, block = turtle.inspect()
        elseif direction == "up" then
            present, block = turtle.inspectUp()
        end

        --checks if the block is a turtle
        if (present) then if (block.name == "computercraft:turtle_advanced" or block.name == "computercraft:turtle") then
            isTurtle = true -- flags if turtle is there
        end end
    until (isTurtle == false) -- runs until turtle is gone

end

local function refuel(needsFuel, centralComputer) -- requests then waits for refuel
    if (turtle.getFuelLevel() <= 1250) then -- if fuel level low, refuel

        turtle.select(1)
        if (turtle.getItemCount() ~= 64) then -- if no fuel, request fuel
            local message = {}
            message[1] = needsFuel
            local x, y, z = func.triangulate()
            message[2] = {x,y,z}
            local tankerID = nil

            repeat -- find supply computer id
                tankerID = rednet.lookup(tankerProtocol, centralComputer)
                os.sleep(0.05)
            until (tankerID)
            rednet.send(tankerID, message, tankerProtocol)

            repeat -- wait for fuel
                os.sleep(1)
            until (turtle.getItemCount(1) == 64)

            turtle.refuel(63) -- refuel

            repeat -- wait for more fuel
                local present, block = turtle.inspectUp()
                if (present == false) then break end
            until (turtle.getItemCount(1) == 64)

        end
    end
end

local function tankerRefuel(coords, startingCoords, maxheight, centralComputer) -- tanker returns to docking instead of manually refueling
    local refueled = false
    if (turtle.getFuelLevel() <= 1250) then -- if fuel level low, refuel
        refueled = true
        turtle.select(1)
        if (turtle.getItemCount() ~= 64) then -- if no fuel, request fuel
            turtle.select(16)
            if (turtle.getItemCount() ~= 64) then
                facing = func.tankerGoTo(coords, startingCoords, maxheight, nil, centralComputer)

                -- note for minions: they will need to attach to a modem bay and then use modem.getNameLocal(), then transmit that name via rednet to this computer so it can send fuel.
                -- should look like message[1] = dockingRequest, message[2] = supply or tanker, message[3] = modem.getNameLocal(), message[4] = true or false (for refueling)

                -- docking
                local dockedmodem = peripheral.find("modem")
                for i=1, #dockedmodem do -- find the wired modem
                    if dockedmodem[i].isWireless() == true then
                        dockedmodem = dockedmodem[i]
                    end
                end

                --prepare docking message
                local nameLocal = dockedmodem.getNameLocal()
                local dockingmessage = {dockingRequest, "tanker", nameLocal}
                local askForFuel = false
                if ((turtle.getItemDetail(1)).count <= 1) then
                    askForFuel = true
                end
                table.insert(dockingmessage,askForFuel)

                -- find docking computer
                local dockingID = nil
                repeat -- find supply computer id
                    tankerID = rednet.lookup(dockProtocol, centralComputer)
                    os.sleep(0.05)
                until (dockingID ~= nil)

                -- send and wait
                rednet.send(dockingID, dockingmessage, dockProtocol)
                repeat -- repeats until docking is complete
                    local received = false
                    local id, message = rednet.receive(dockProtocol, 2)
                    if message == doneDocking then -- coordinates received {"...", {x1,y1,z1}, maxheight}
                        received = true
                    end
                until (received == true)
            end
        end
        turtle.refuel(63)
    end
    return refueled
end

local function dropOff(needsSupply, centralComputer) -- function waits for supplier turtle to arrive, then gives all items to it
    local message = {}
    message[1] = needsSupply
    local x, y, z = func.triangulate()
    message[2] = {x,y,z}

    local supplyID = nil
    repeat
        supplyID = rednet.lookup(supplierProtocol, centralComputer)
        os.sleep(0.05)
    until (supplyID)
    rednet.send(supplyID, message, protocol)

    repeat
        local success = false
        local present, block = turtle.inspectUp()
        if (present) then if (block.name == "computercraft:turtle_advanced" or block.name == "computercraft:turtle") then success = true end end
        os.sleep(0.05)
    until (success)

    for i=2, 16 do 
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(1)
end

local function turnR(facing) -- 1 = north, 2 = east, 3 = south, 4 = west, turns right
    turtle.turnRight()
    if (facing == 1) then facing = 4 else facing = facing-1 end
    return facing
end

local function turnL(facing) -- 1 = north, 2 = east, 3 = south, 4 = west, turns left
    turtle.turnLeft()
    if (facing == 4) then facing = 1 else facing = facing+1 end
    return facing
end

local function face(facing, direction) -- direction is an int
    if (direction ~= facing) then 
        if ((facing-direction) == 3) then
            facing = turnL(facing)
        elseif ((facing-direction) == -3) then
            facing = turnR(facing)
        elseif (direction > facing) then
            repeat 
                facing = turnL(facing)
            until (direction == facing)
        else
            repeat 
                facing = turnR(facing)
            until (direction == facing)
        end
    end
    return facing
end

local function forward(coords, facing) -- moves forward
    -- move
    repeat turtle.dig() until turtle.forward()

    -- 1 = north, 2 = east, 3 = south, 4 = west
    --update coords
    if (facing == 1) then
        coords.z = coords.z - 1
    elseif (facing == 2) then
        coords.x = coords.x + 1
    elseif (facing == 3) then
        coords.z = coords.z + 1
    else -- facing == 4
        coords.x = coords.x - 1
    end

end

local function forwardTransport(coords, facing) -- moves forward with protections
    -- move
    repeat func.detectTurtle("forward") turtle.dig() until turtle.forward()

    -- 1 = north, 2 = east, 3 = south, 4 = west
    --update coords
    if (facing == 1) then
        coords.z = coords.z - 1
    elseif (facing == 2) then
        coords.x = coords.x + 1
    elseif (facing == 3) then
        coords.z = coords.z + 1
    else -- facing == 4
        coords.x = coords.x - 1
    end
end

local function back(coords, facing) -- moves backwards
    -- move
    repeat 
        --keep trying to go back
    until turtle.back()

    -- 1 = north, 2 = east, 3 = south, 4 = west
    --update coords
    if (facing == 1) then
        coords.z = coords.z + 1
    elseif (facing == 2) then
        coords.x = coords.x - 1
    elseif (facing == 3) then
        coords.z = coords.z - 1
    else -- facing == 4
        coords.x = coords.x + 1
    end
end

local function up(coords) -- moves up
    -- move
    repeat turtle.digUp() until turtle.up()

    --update coords
    coords.y = coords.y + 1
end

local function upTransport(coords) -- moves up with protections
    -- move
    repeat func.detectTurtle("up") turtle.digUp() until turtle.up()

    --update coords
    coords.y = coords.y + 1

end

local function down(coords) -- moves down
    -- move
    repeat turtle.digDown() until turtle.down()

    --update coords
    coords.y = coords.y - 1
end

local function downTransport(coords) -- moves down with protections
    -- move
    repeat func.detectTurtle("down") turtle.digDown() until turtle.down()

    --update coords
    coords.y = coords.y - 1
end

local function getFacing() -- direction is an int

    local facing = 0

    -- get original position
    local x1, y1, z1 = triangulate()

    -- move forward, get new position
    func.forwardTransport({x=0,y=0,z=0}, 1)
    local x2, y2, z2 = triangulate()
    turtle.back()

    -- north = -z, south = +z, west = -x, east = +x 
    -- 1 = north, 2 = east, 3 = south, 4 = west

    -- finding facing
    if (x1 ~= x2) then

        if (x2 > x1) then -- east
            facing = 2 
        else -- if (x2 < x1) then, west
            facing = 4
        end

    else -- if (z1 ~= z2) then

        if (z2 > z1) then -- south
            facing = 3
        else -- if (z2 < z1) then, north
            facing = 1
        end

    end

    -- return and print facing
    print("\nCurrently facing \"" .. facing .. ",\" 1 = north, 2 = east, 3 = south, 4 = west")
    return facing
end

local function fillLiquid() -- fills liquid beneath the turtle
    local present, block = turtle.inspectDown()
    if (present) then if (block.name == "minecraft:lava" or block.name == "minecraft:water") then
        local slot = 1
        local success = false
        while (slot < 16 and not success) do
            slot = slot+1
            turtle.select(slot)
            local item = turtle.getItemDetail()
            if (item.name == "minecraft:cobblestone" or item.name == "minecraft:dirt" or item.name == "minecraft:cobbled_deepslate") then
                success = turtle.placeDown()
            end
        end
        turtle.select(1)
    end end
end

local function rednetInit(label)  -- Opens rednet on the computer and returns the modem peripheral
    print("\nAttempting to find modems...")
    repeat -- repeatedly search for modems and open rednet until both are complete
        local modems = peripheral.find("modem", rednet.open)
    until (#modems > 0 and rednet.isOpen())
    print("\nWireless modem found, rednet opened.")
    os.setComputerLabel(label)
    print("\nComputer Label (".. label ..") successfully set.")
    return modems, label
end

local function rednetHost(protocol, label) -- Hosts rednet under the given label and protocol, making the pc visible upon lookup
    print("\nHosting " .. protocol .. " rednet under the name " .. label .. "...")
    rednet.host(protocol, label)
    print("\nHosting Successful.")
end

local function monitorInit() -- Sets up monitor and readies it for use

    --finding monitor
    print("\nCreating monitor interface...")
    local monitor = peripheral.find("monitor")
    local monitor = monitor[#monitor]

    --settings
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.setTextScale(1.5)

    --clear screen
    monitor.clear()

    --calculating size and margins
    local monitorWidth, monitorHeight = monitor.getSize()
    local resolution = monitorWidth*monitorHeight
    local marginWidth = (monitorWidth / 20)
    local marginHeight = (monitorHeight / 20)

    print("\nMonitor online.")
    return monitor, monitorWidth, monitorHeight, resolution, marginWidth, marginHeight
end

local function isTable(t) -- checks if t is a table, returns bool
    return (type(t) == "table")
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
    return file, previousOperation
end

local function matchID(table, id, startingIndex) -- finds id in table1 starting at startingIndex, returns index
    for i=startingIndex, #table do
        if (id == table[i]) then
            return i
        end
    end
    return 0
end

local function isFull(needsSupply, centralComputer) 
    local details = turtle.getItemDetail(16)

    if (details ~= nil) then
        func.dropOff(needsSupply, centralComputer)
    end
end

local function goTo(coords, coordsC1, maxheight, needsSupply, centralComputer) -- goes from coords to coords C1 in transport mode
    if (needsSupply ~= nil) then -- if needsSupply is passed
        -- check for fuel
        func.refuel(needsSupply, centralComputer)
    end

    -- ascend
    while (coords.y < maxheight) do
        func.upTransport(coords)
    end

    --find bearing
    local facing = func.getFacing()

    -- north = -z, south = +z, west = -x, east = +x 
    -- 1 = north, 2 = east, 3 = south, 4 = west

    -- move X
    if (coords.x < coordsC1.x) then
        facing = func.face(facing, 2)
        while (coords.x < coordsC1.x) do
            func.forwardTransport(coords, facing)
        end
    elseif (coords.x > coordsC1.x) then
        facing = func.face(facing, 4)
        while (coords.x > coordsC1.x) do
            func.forwardTransport(coords, facing)
        end
    end

    -- move Z
    if (coords.z < coordsC1.z) then
        facing = func.face(facing, 3)
        while (coords.z < coordsC1.z) do
            func.forwardTransport(coords, facing)
        end
    elseif (coords.z > coordsC1.z) then
        facing = func.face(facing, 1)
        while (coords.z > coordsC1.z) do
            func.forwardTransport(coords, facing)
        end
    end

    -- descend
    while (coords.y > cordsC1.y) do
        func.downTransport(coords)
    end

    return facing
end

local function tankerGoTo(coords, coordsC1, maxheight, needsSupply, centralComputer) -- goes from coords to coords C1 in transport mode
    local refueled = false
    if (needsSupply ~= nil) then
        refueled = func.tankerRefuel(coords, startingCoords, maxheight, centralComputer)
    end

    -- ascend
    while (coords.y < maxheight) do
        func.upTransport(coords)
    end

    --find bearing
    local facing = func.getFacing()

    -- north = -z, south = +z, west = -x, east = +x 
    -- 1 = north, 2 = east, 3 = south, 4 = west

    -- move X
    if (coords.x < coordsC1.x) then
        facing = func.face(facing, 2)
        while (coords.x < coordsC1.x) do
            func.forwardTransport(coords, facing)
        end
    elseif (coords.x > coordsC1.x) then
        facing = func.face(facing, 4)
        while (coords.x > coordsC1.x) do
            func.forwardTransport(coords, facing)
        end
    end

    -- move Z
    if (coords.z < coordsC1.z) then
        facing = func.face(facing, 3)
        while (coords.z < coordsC1.z) do
            func.forwardTransport(coords, facing)
        end
    elseif (coords.z > coordsC1.z) then
        facing = func.face(facing, 1)
        while (coords.z > coordsC1.z) do
            func.forwardTransport(coords, facing)
        end
    end

    -- descend
    while (coords.y > cordsC1.y) do
        func.downTransport(coords)
    end

    return facing, refueled
end

local function mine(coords, coordsC1, coordsC2, maxheight, facing, needsFuel, needsSupply, centralComputer) -- mines layers from C1 to C2

    func.upTransport(coords)

    local lengthX = math.abs(coordsC1.x-coordsC2.x)
    local depthY = math.abs(coordsC1.y-coordsC2.y)
    local widthZ = math.abs(coordsC1.z-coordsC2.z)


    -- start mining
    for depth=1, depthY do -- for each layer
        -- prepping
        func.refuel(needsFuel, centralComputer)
        
        -- north = -z, south = +z, west = -x, east = +x 
        -- 1 = north, 2 = east, 3 = south, 4 = west
        -- always face east first
        func.down(coords)
        for length=1, lengthX do -- for each line
            -- check inventory each line
            func.isFull(needsSupply, centralComputer)

            --face south
            facing = func.face(facing, 3)
            if (length > 1) then --if not the first or last line, move into the next line
                facing = func.forward(coords, facing)
            end

            -- face the direction that needs to be mined next
            if (length%2 == 1) then
                facing = func.face(facing, 2)
            else
                facing = func.face(facing, 4)
            end

            -- fill any liquid in the first spot
            func.fillLiquid()

            for width=2, widthZ do --for each block after the first
                func.fillLiquid()
                func.forward()
            end
        end
        
    end

end

-- function list to return
return {
    triangulate = triangulate,
    rednetInitTurtle = rednetInitTurtle,
    detectTurtle = detectTurtle,
    refuel = refuel,
    tankerRefuel = tankerRefuel,
    dropOff = dropOff,
    turnR = turnR,
    turnL = turnL,
    face = face,
    forward = forward,
    forwardTransport = forwardTransport,
    back = back,
    up = up,
    upTransport = upTransport,
    down = down,
    downTransport = downTransport,
    getFacing = getFacing,
    rednetInit = rednetInit,
    rednetHost = rednetHost,
    monitorInit = monitorInit,
    isTable = isTable,
    openOperationFile = openOperationFile,
    matchID = matchID,
    goTo = goTo,
    tankerGoTo = tankerGoTo,
    mine = mine
}
