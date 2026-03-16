-- this file:
-- receives supply requests
-- sends suppliers to retrieve items

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronSupply")

-- vars
local chests = {}
supplychest = false


-- find fuel chest
repeat
    chests = peripheral.find("minecraft:chest")

    for i = 1, #chests do -- for each chest found

        for slot, item in pairs(chests[i].list()) do -- check all slots for fuel
            if item.name == fuelSource then -- if fuel is found, skip this chest
                goto exitchests -- exit loop
            end
        end
       supplychest = chests[i] -- if no fuel is found, use this chest for supply
    end
    ::exitchests::
until supplychest ~= false end




-- refueling handling
repeat

    local id, message = nil
    do -- wait for a fuel request
        id, message = nil
        id, message = rednet.receive(tankerProtocol, 10)
    until isTable(message) == true and message[1] == needsSupply end

    local supplierID = 0
    do -- find a free tanker
        if ((supplierID+1) > #turtleJobs) then supplierID = 0 end -- resets to zero when ID bigger than table
        supplierID = matchID(turtleJobs, 2, supplierID+1)
    until turtlesIdle[supplierID] == true end

    -- contact tankers with coordinates
    rednet.send(supplierID, message, supplierProtocol)
    turtlesIdle[supplierID] == false

until completed == true end