-- libs
func = require("turtlefunctions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "MinionMiner")

-- inital docking
local dockedmodem = peripheral.find("modem")
for i=1, #dockedmodem do -- find the wired modem
    if dockedmodem[i].isWireless() == true then
        dockedmodem = dockedmodem[i]
    end
end

--prepare docking message
local nameLocal = dockedmodem.getNameLocal()
local dockingmessage = {dockingRequest, "miner", nameLocal}
local askForFuel = false
if ((turtle.getItemDetail(1)).count <= 1) then
    askForFuel = true
end
dockingmessage.append(askForFuel)

-- find docking computer
local dockingID = nil
repeat -- find supply computer id
    tankerID = rednet.lookup(dockingProtocol, centralComputer)
    os.sleep(0.05)
until (dockingID ~= nil)

-- send and wait
rednet.send(dockingID, dockingmessage, dockProtocol)
repeat -- repeats until docking is complete
    local received = false
    local id, message = rednet.receive(dockingProtocol, 2)
    if message == doneDocking then -- coordinates received {"...", {x1,y1,z1}, maxheight}
        received == true
    end
until (received == true)

repeat
    -- get current coordinates
    print("\nTriangulating position...")
    local xt, yt, zt = func.triangulate()
    coords = {x=xt,y=yt,z=zt}
    print("\nPosition found.")

    -- wait for message, responding when pinged for idle
    print("\nWaiting for coordinates...")
    repeat
        local received = false
        id, message = rednet.receive(turtleProtocol, 10)
        if message == idlecheck then
            rednet.send(id, idleresponse, turtleProtocol)
        elseif message == "completed" then -- completed signal sent, skip to end of loop
            completed = true
            goto complete
        elseif func.isTable(message) == true then -- coordinates received {{x1,y1,z1},{x2,y2,z2},maxheight}
            received == true
        end
    until (received == true)
    print ("\nCoordinates received...")

    maxheight = message[3]-label
    coordsC1 = {x=message[1][1], y=message[1][2], z=message[1][3]}
    coordsC2 = {x=message[2][1], y=message[2][2], z=message[2][3]}

    facing = func.goTo(coords, coordsC1, maxheight, needsFuel, centralComputer)
    func.mineChunk(coords, coordsC1, coordsC2, maxheight, facing, needsFuel, needsSupply, centralComputer)
    facing = func.goTo(coords, coordsC1, maxheight, needsFuel, centralComputer)
    ::complete::
until (completed == true)

-- return home
func.goTo(coords, startingCoords, maxheight, needsFuel, centralComputer)