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
        id, message = nil
        id, message = rednet.receive(dockingProtocol, 10)
    until (func.isTable(message) == true and message[1] == dockingRequest)

    -- gets the peripheral name for the docked turtle
    local turtlePeripheral = message[3]
    local inventorySize = turtlePeripheral.size()
    local fuelInventory = fuelchest.size()

    if message[2] == "supply" then -- if supply docking mode, extract all items from the turtle

        repeat
            for i=2, inventorySize do -- for each slot, remove all items, waiting if the items aren't able to be moved
                repeat
                    local item = turtlePeripheral.getItemDetail(i)
                    local itemCount = item.count
                    local itemsMoved = turtlePeripheral.pushItems(supplychest, i)
                until (itemCount == itemsMoved)
            end
        until ((turtlePeripheral.getItemDetail(inventorySize)) == nil)
        
        if message[4] == true then -- if supplier needs fuel
            repeat -- repeats until the first slot of the supplier is full
                
                local fuelItems = fuelchest.list()
                for slot, item in pairs(fuelItems) do -- used to only pull from slots with items
                    local itemsMoved = turtlePeripheral.pullItems(fuelChest, slot)
                    if itemsMoved == 0 or itemsMoved == 64 then -- if a full stack or nothing was moved, move on
                        break
                    end
                end

            until ((turtlePeripheral.getItemDetail(1)).count == 64)
        end

    elseif message[2] == "tanker" then

        repeat -- repeats until the last slot of the tanker is full
            for i=1, inventorySize do -- fills every slot with fuel
                local fuelItems = fuelchest.list()
                for slot, item in pairs(fuelItems) do -- used to only pull from slots with items
                    local itemsMoved = turtlePeripheral.pullItems(fuelChest, slot)
                    if itemsMoved == 0 or itemsMoved == 64 then -- if a full stack or nothing was moved, move on to next slot
                        break
                    end
                end
            end
        until ((turtlePeripheral.getItemDetail(inventorySize)).count == 64)

    elseif message[2] == miner then

        if message[4] == true then -- if miner needs fuel
            repeat -- repeats until the first slot of the miner is full
                
                local fuelItems = fuelchest.list()
                for slot, item in pairs(fuelItems) do -- used to only pull from slots with items
                    local itemsMoved = turtlePeripheral.pullItems(fuelChest, slot)
                    if itemsMoved == 0 or itemsMoved == 64 then -- if a full stack or nothing was moved, move on
                        break
                    end
                end

            until ((turtlePeripheral.getItemDetail(1)).count == 64)
        end

    end

    -- contact tankers with coordinates
    rednet.send(id, doneDocking, dockingProtocol)
    turtlesIdle[id] = true

until completed == true