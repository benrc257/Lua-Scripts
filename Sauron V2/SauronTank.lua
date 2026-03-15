-- this file:
-- receives fuel orders
-- assigns tankers to refuel

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronTank")

-- vars
local chests = {}
fuelchest = false
local needsFuel = "needFuel" -- send from turtles for fuel

-- find fuel chest
repeat
    chests = peripheral.find("minecraft:chest")

    for i = 1, #chests do -- for each chest found

        for slot, item in pairs(chests[i].list()) do -- check all slots for fuel
            if item.name == fuelSource then -- if fuel is found, set this chest as the fuel chest
                fuelchest = chests[i]
                goto exitchests -- exit loop
            end
        end
    end
    ::exitchests::
until fuelchest ~= false end


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