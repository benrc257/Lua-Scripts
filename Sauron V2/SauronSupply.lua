-- this file:
-- receives supply requests
-- sends suppliers to retrieve items

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronSupply")

-- vars
local chests = {}
supplychest = nil


-- find fuel chest
repeat
    chests = {peripheral.find("minecraft:chest")}

    for i = 1, #chests do -- for each chest found

        for slot, item in pairs(chests[i].list()) do -- check all slots for fuel
            if item.name == fuelSource then -- if fuel is found, skip this chest
                goto exitchests -- exit loop
            end
        end
       supplychest = chests[i] -- if no fuel is found, use this chest for supply
    end
    os.sleep(1)
    ::exitchests::
until (supplychest ~= nil)




-- refueling handling
repeat

    local id, message = nil
    repeat -- wait for a fuel request
        id, message = nil
        id, message = rednet.receive(tankerProtocol, 10)
    until (func.isTable(message) == true and message[1] == needsSupply)

    local supplierID = 1
    local supplierIndex = 1
    repeat -- find a free supplier
        if ((supplierIndex) > #turtleJobs) then supplierIndex = 1 end -- resets to zero when ID bigger than table
        supplierID = func.matchID(turtleJobs, 3, supplierIndex)
        os.sleep(1)
        print("\nSearching for supplier at id " .. supplierID)
        supplierIndex = supplierIndex+1
    until turtlesIdle[supplierID] == true

    table.insert(message,maxheight)

    -- contact tankers with coordinates
    rednet.send(supplierID, message, supplierProtocol)
    turtlesIdle[supplierID] = false

until (completed == true)