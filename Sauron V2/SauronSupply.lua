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


repeat
    chests = {peripheral.find("minecraft:chest")}

    for i = 1, #chests do -- for each chest found

        for slot, item in pairs(chests[i].list()) do -- check all slots for fuel
            if item.name == fuelSource then -- if fuel is found, skip this chest as the supply chest
                goto fuelfound
            end
        end
        supplychest = chests[i]
        ::fuelfound::
    end
    os.sleep(0.5)
until (supplychest ~= false)




-- refueling handling
local messageindex = 0
repeat

    messageindex = messageindex+1
    repeat -- wait for a fuel request
        print("\nWaiting for supply requests...")
        os.sleep(0.5)
    until (supplyrid[messageindex] ~= nil)

    print("\nCoordinates received.")

    local free = 0
    repeat -- find a free miner
        local minerIndex = 0
        for i=1, #turtleJobs do
            minerIndex = func.matchID(turtleJobs, 3, i)
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


    table.insert(supplyrmessage[messageindex],maxheight)
    local supplierID = turtles[free]
    turtlesIdle[free] = false

    -- contact tankers with coordinates
    rednet.send(supplierID, supplyrmessage[messageindex], supplierProtocol)
    

until (completed == true)