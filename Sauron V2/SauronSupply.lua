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
local needsSupply = "needSupply" -- send from turtles for supply

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


-- note for minions: they will need to attach to a modem bay and then use modem.getNameLocal(), then transmit that name via rednet to this computer so it can send fuel.

-- refueling handling
repeat

    local id, message = nil
    do -- wait for a fuel request
        id, message = nil
        id, message = rednet.receive(tankerProtocol, 10)
    until isTable(message) == true and message[1] == needsFuel end

    local tankerID = 0
    do -- find a free tanker
        if ((tankerID+1) > #turtleJobs) then tankerID = 0 end -- resets to zero when ID bigger than table
        tankerID = matchID(turtleJobs, 2, tankerID+1)
    until turtlesIdle[tankerID] == true end

    -- contact tankers with coordinates
    rednet.send(tankerID, message, tankerProtocol)
    turtlesIdle[tankerID] == false

until completed == true end