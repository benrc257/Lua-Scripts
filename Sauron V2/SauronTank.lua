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

    local id, message = nil, nil
    repeat -- wait for a fuel request
        id, message = rednet.receive(tankerProtocol, 10)
    until (message ~= nil and func.isTable(message) == true)

    local free = 0
    repeat -- find a free tanker
        for tankerIndex=1, #turtleJobs do
            tankerIndex = func.matchID(turtleJobs, 1, tankerIndex)
            print("\nSearching for tanker at id " .. tankerIndex)
            if tankerIndex ~= 0 and turtlesIdle[tankerIndex] == true then
                print("\nFree tanker found at index" .. tankerIndex)
                free = tankerIndex
                break
            end
        end
        os.sleep(2)
    until free ~= 0


    table.insert(message, maxheight)
    local tankerID = turtles[free]
    turtlesIdle[free] = false

    -- contact tankers with coordinates
    rednet.send(tankerID, message, tankerProtocol)  -- tanker receives {needsFuel, {x,y,z}, maxheight}

until (completed == true)