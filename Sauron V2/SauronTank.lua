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

-- find fuel chest
repeat
    chests = {peripheral.find("minecraft:chest")}

    for i = 1, #chests do -- for each chest found

        for slot, item in pairs(chests[i].list()) do -- check all slots for fuel
            if item.name == fuelSource then -- if fuel is found, set this chest as the fuel chest
                fuelchest = chests[i]
                goto exitchests -- exit loop
            end
        end
    end
    os.sleep(1)
    ::exitchests::
until (fuelchest ~= false)


-- refueling handling
repeat

    local id, message = nil
    repeat -- wait for a fuel request
        id, message = nil
        id, message = rednet.receive(tankerProtocol, 10)
    until (func.isTable(message) == true and message[1] == needsFuel)

    local tankerID = 1
    local tankerIndex = 1
    repeat -- find a free miner
        if ((tankerIndex) > #turtleJobs) then tankerIndex = 1 end -- resets to zero when ID bigger than table
        tankerID = func.matchID(turtleJobs, 3, tankerIndex)
        os.sleep(1)
        print("\nSearching for miner at id " .. tankerID)
        tankerIndex = tankerIndex+1
    until turtlesIdle[tankerID] == true

    table.insert(message, maxheight)

    -- contact tankers with coordinates
    rednet.send(tankerID, message, tankerProtocol)  -- tanker receives {needsFuel, {x,y,z}, maxheight}
    turtlesIdle[tankerID] = false

until (completed == true)