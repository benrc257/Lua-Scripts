-- libs
func = require("turtlefunctions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "MinionMiner")

-- inital docking
print("\nBeginning docking")
peripheral.getNames()  -- forces scan
local dockedmodem = {peripheral.find("modem")}
for i=1, #dockedmodem do -- find the wired modem
    if dockedmodem[i].isWireless() == false then
        dockedmodem = dockedmodem[i]
        break
    end
end

--prepare docking message
print("\nPreparing docking message")
local nameLocal = dockedmodem.getNameLocal()
print("\nLocal Modem Name: ")
print(nameLocal)
local dockingmessage = {dockingRequest, "miner", nameLocal}
local askForFuel = false
if ((turtle.getItemCount(1)) <= 1) then
    askForFuel = true
end
table.insert(dockingmessage,askForFuel)

-- find docking computer
local dockingID = nil
print("\nFinding docking computer")
repeat -- find supply computer id
    dockingID = rednet.lookup(dockProtocol, centralComputer)
    os.sleep(0.05)
until (dockingID ~= nil)

-- send and wait
print("\nDocking request sent")
rednet.send(dockingID, dockingmessage, dockProtocol)
local id, message = nil, nil
repeat -- repeats until docking is complete
    id, message = rednet.receive(dockProtocol)
until message == doneDocking
id, message = nil, nil

local coords = nil
local xt, yt, zt = nil, nil, nil
repeat
    -- get current coordinates
    print("\nTriangulating position...")
    xt, yt, zt = func.triangulate()
    coords = {x=xt,y=yt,z=zt}
    print("\nPosition found.")

    -- wait for message, responding when pinged for idle
    print("\nWaiting for coordinates...")
    local id, message = nil, nil
    local received = false
    local messageProtocol = nil
    repeat
        id, message, messageProtocol = rednet.receive()
        if messageProtocol == miningProtocol then -- coordinates received {"...", {x1,y1,z1}, maxheight}
            received = true
        elseif message == "completed" then -- completed signal sent, skip to end of loop
            completed = true
            goto complete
        elseif message == idlecheck then -- respond to idle ping
            rednet.send(id, idleresponse, turtleProtocol)
        end
    until (received == true)
    print ("\nCoordinates received...")

    maxheight = message[3]-label
    coordsC1 = {x=message[1][1], y=message[1][2], z=message[1][3]}
    coordsC2 = {x=message[2][1], y=message[2][2], z=message[2][3]}

    facing = func.goTo(coords, coordsC1, maxheight, needsFuel, centralComputer) 
    func.mine(coords, coordsC1, coordsC2, maxheight, facing, needsFuel, needsSupply, centralComputer) -- (coords, coordsC1, coordsC2, maxheight, facing, needsFuel, needsSupply, centralComputer)
    
until (completed == true)
::complete::
-- return home
facing = func.goTo(coords, startingCoords, maxheight, needsFuel, centralComputer)