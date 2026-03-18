-- libs
func = require("turtlefunctions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "MinionTanker")

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
print("\nLocal Modem Name: ")
print(nameLocal)
local dockingmessage = {dockingRequest, "tanker", nameLocal}
local askForFuel = false
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
    id, message = rednet.receive(dockProtocol, 2)
until message == doneDocking
id, message = nil, nil

repeat
    -- get current coordinates
    print("\nTriangulating position...")
    xt, yt, zt = func.triangulate()
    coords = {x=xt,y=yt,z=zt}
    print("\nPosition found.")

    -- wait for message, responding when pinged for idle
    print("\nWaiting for coordinates...")
    local id2, message2 = nil, nil
    local received = false
    local id, message = nil, nil
    repeat
        id, message = rednet.receive(tankerProtocol, 2)
        id2, message2 = rednet.receive(turtleProtocol, 2)
        if func.isTable(message) == true then -- coordinates received {"...", {x1,y1,z1}, maxheight}
            received = true
        elseif message2 == "completed" then -- completed signal sent, skip to end of loop
            completed = true
            goto complete
        elseif message2 == idlecheck then -- respond to idle ping
            rednet.send(id2, idleresponse, turtleProtocol)
        end
    until (received == true)
    print ("\nCoordinates received...")

    maxheight = message[3]+tonumber(label)
    coordsT1 = {x=message[2][1], y=message[2][2]+1, z=message[2][3]}

    -- move to turtle and give it fuel
    facing = func.tankerGoTo(coords, coordsT1, maxheight, needsFuel, centralComputer)
    fuelSlot = nil
    for i=2, 16 do --find fuelSlot
        local details = turtle.getItemCount(i)
        if (details == 64) then
            fuelSlot = i
            break
        end
    end
    if fuelslot <= 16 then -- fuel if found
        turtle.select(fuelSlot)
        turtle.dropDown(63)
    end
    for i=fuelSlot+1, 16 do --find second fuelSlot
        local details = turtle.getItemCount(i)
        if (details == 64) then
            fuelSlot = i
            break
        end
    end
    if fuelslot <= 16 then -- fuel if found
        turtle.select(fuelSlot)
        turtle.dropDown(63)
    end
    func.forwardTransport(coords, facing) -- NOTE, on ascending this turtle needs to move forward first to avoid tanker collision
    facing = func.tankerGoTo(coords, {coords.x, maxheight, coords.z}, maxheight, needsFuel, centralComputer)
    turtle.forwardTransport(coords)

    -- return home if needed
    if (fuelslot >= 15) then
        local refueled = false
        facing, refueled = func.tankerGoTo(coords, startingCoords, maxheight, needsFuel, centralComputer)

        if (refueled == false) then
            -- note for minions: they will need to attach to a modem bay and then use modem.getNameLocal(), then transmit that name via rednet to this computer so it can send fuel.
            -- should look like message[1] = dockingRequest, message[2] = supply or tanker, message[3] = modem.getNameLocal(), message[4] = true or false (for refueling)

            -- docking
            local dockedmodem = {peripheral.find("modem")}
            for i=1, #dockedmodem do -- find the wired modem
                if dockedmodem[i].isWireless() == false then
                    dockedmodem = dockedmodem[i]
                    break
                end
            end

            --prepare docking message
            local nameLocal = dockedmodem.getNameLocal()
            local dockingmessage = {dockingRequest, "tanker", nameLocal}
            local askForFuel = false
            if ((turtle.getItemCount(1)) <= 1) then
                askForFuel = true
            end
            table.insert(dockingmessage, askForFuel)

            -- find docking computer
            local dockingID = nil
            repeat -- find supply computer id
                dockingID = rednet.lookup(dockProtocol, centralComputer)
                os.sleep(0.05)
            until (dockingID ~= nil)

            -- send and wait
            print("\nDocking request sent")
            rednet.send(dockingID, dockingmessage, dockProtocol)
            local id, message = nil, nil
            repeat -- repeats until docking is complete
                id, message = rednet.receive(dockProtocol, 2)
            until message == doneDocking
            id, message = nil, nil
        end
    end

    
until (completed == true)
::complete::
-- return home
coordsC1 = {x=xstart,y=ystart,z=zstart}
func.tankerGoTo(coords, coordsC1, maxheight, needsFuel, centralComputer)