-- this file:
-- refuels and empties turtles
-- note for minions: they will need to attach to a modem bay and then use modem.getNameLocal(), then transmit that name via rednet to this computer so it can send fuel.

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronDock")

-- note for minions: they will need to attach to a modem bay and then use modem.getNameLocal(), then transmit that name via rednet to this computer so it can send fuel.
-- should look like message[1] = dockingRequest, message[2] = supply or tanker or miner, message[3] = modem.getNameLocal(), message[4] = true or false (for refueling)

-- refueling handling
repeat

    local id, message = nil
    repeat -- wait for a docking request
        print("\nAwaiting docking request...")
        id, message = rednet.receive(dockProtocol, 10)
    until (func.isTable(message) == true and message[1] == dockingRequest)

    -- gets the peripheral name for the docked turtle
    print("\nDocking request received")
    local turtlePeripheral = message[3]
    local inventorySize = 16
    local fuelInventory = fuelchest.size()

    if message[2] == "supply" then -- if supply docking mode, extract all items from the turtle

        for i=2, inventorySize do -- for each slot, remove all items, waiting if the items aren't able to be moved
            local itemsMoved = supplychest.pullItems(turtlePeripheral, i)
        end
        
        if message[4] == true then -- if supplier needs fuel
                
            local fuelItems = fuelchest.list()
            for slot, item in pairs(fuelItems) do -- used to only pull from slots with items
                local itemsMoved = fuelchest.pushItems(turtlePeripheral, slot, 64, 1)
                if itemsMoved == 0 or itemsMoved == 64 then -- if a full stack or nothing was moved, move on
                    break
                end
            end

        end

    elseif message[2] == "tanker" then

        for i=1, inventorySize do -- fills every slot with fuel
            local fuelItems = fuelchest.list()
            for slot, item in pairs(fuelItems) do -- used to only pull from slots with items
                local itemsMoved = fuelchest.pushItems(turtlePeripheral, slot, 64, i)
                if itemsMoved == 0 or itemsMoved == 64 then -- if a full stack or nothing was moved, move on to next slot
                    break
                end
            end
        end

    elseif message[2] == "miner" then

        if message[4] == true then -- if miner needs fuel
                
            local fuelItems = fuelchest.list()
            for slot, item in pairs(fuelItems) do -- used to only pull from slots with items
                local itemsMoved = fuelchest.pushItems(turtlePeripheral, slot, 64, 1)
                if itemsMoved == 0 or itemsMoved == 64 then -- if a full stack or nothing was moved, move on
                    break
                end
            end
        end

    end

    print("\nDocking complete, sent to " .. id)
    rednet.send(id, doneDocking, dockProtocol)
    turtlesIdle[func.matchID(turtles,id,1)] = true

until completed == true