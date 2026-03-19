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
local messageindex = 0
repeat
    messageindex = messageindex+1

    repeat -- wait for a fuel request
        os.sleep(0.5)
    until (supplyrid[messageindex] ~= nil)

    local free = 0
    repeat -- find a free miner
        local minerIndex = 0
        for i=1, #turtleJobs do
            minerIndex = func.matchID(turtleJobs, 2, i)
            print("\nSearching for miner at id " .. minerIndex)
            if minerIndex ~= 0 and turtlesIdle[minerIndex] == true then
                print("\nFree miner found at index" .. minerIndex)
                free = minerIndex
                break
            end
            os.sleep(0.1)
        end
        os.sleep(0.1)
    until free ~= 0


    table.insert(supplyrmessage[messageindex], maxheight)
    local tankerID = turtles[free]
    turtlesIdle[free] = false

    -- contact tankers with coordinates
    rednet.send(tankerID, supplyrmessage[messageindex], tankerProtocol)  -- tanker receives {needsFuel, {x,y,z}, maxheight}

until (completed == true)