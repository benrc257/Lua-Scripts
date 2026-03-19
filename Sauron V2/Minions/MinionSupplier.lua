-- libs
func = require("turtlefunctions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "MinionSupplier")

-- inital docking
local dockedmodem = {peripheral.find("modem")}
for i=1, #dockedmodem do -- find the wired modem
    if dockedmodem[i].isWireless() == false then
        dockedmodem = dockedmodem[i]
        break
    end
end

--prepare docking message
local nameLocal = dockedmodem.getNameLocal()
local dockingmessage = {dockingRequest, "supply", nameLocal}
local askForFuel = false
if ((turtle.getItemCount(1)) <= 1) then
    askForFuel = true
end
table.insert(dockingmessage,askForFuel)

-- find docking computer
local dockingID = nil
repeat -- find docking computer id
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

repeat
    -- get current coordinates
    print("\nTriangulating position...")
    local xt, yt, zt = func.triangulate()
    coords = {x=xt,y=yt,z=zt}
    print("\nPosition found.")

    -- wait for message, responding when pinged for idle
    print("\nWaiting for coordinates...")
    local id, message = nil, nil
    local received = false
    local messageProtocol = nil
    repeat
        id, message, messageProtocol = rednet.receive()
        if messageProtocol == supplierProtocol and message == needsSupply then -- coordinates received {"...", {x1,y1,z1}, maxheight}
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
    coordsT1 = {x=message[2][1], y=message[2][2]+1, z=message[2][3]}

    -- move to turtle and wait for items
    facing = func.goTo(coords, coordsT1, maxheight, needsFuel, centralComputer)
    os.sleep(10)
    func.forwardTransport(coords, facing) -- NOTE, on ascending this turtle needs to move forward first to avoid tanker collision

    -- return home
    facing = func.goTo(coords, startingCoords, maxheight, needsFuel, centralComputer)

    -- note for minions: they will need to attach to a modem bay and then use modem.getNameLocal(), then transmit that name via rednet to this computer so it can send fuel.
    -- should look like message[1] = dockingRequest, message[2] = supply or tanker, message[3] = modem.getNameLocal(), message[4] = true or false (for refueling)

    -- docking
    dockedmodem = {peripheral.find("modem")}
    for i=1, #dockedmodem do -- find the wired modem
        if dockedmodem[i].isWireless() == false then
            dockedmodem = dockedmodem[i]
            break
        end
    end


    --prepare docking message
    nameLocal = dockedmodem.getNameLocal()
    print("\nLocal Modem Name: ")
    print(nameLocal)
    dockingmessage = {dockingRequest, "supply", nameLocal}
    askForFuel = false
    if ((turtle.getItemCount(1)) <= 1) then
        askForFuel = true
    end
    table.insert(dockingmessage,askForFuel)

    -- find docking computer
    dockingID = nil
    repeat -- find docking computer id
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
    
until (completed == true)
::complete::
-- return home
coordsC1 = {x=xstart,y=ystart,z=zstart}
facing = func.goTo(coords, coordsC1, maxheight, needsFuel, centralComputer)