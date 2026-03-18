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
repeat

    local id, message = nil, nil
    repeat -- wait for a fuel request
        print("\nWaiting for supply requests...")
        id, message = rednet.receive(supplierProtocol, 10)
    until (message ~= nil and func.isTable(message) == true)

    print("\nCoordinates received.")

    local free = 0
    repeat -- find a free supplier
        for supplierIndex=1, #turtleJobs do
            supplierIndex = func.matchID(turtleJobs, 1, supplierIndex)
            print("\nSearching for supplier at id " .. supplierIndex)
            if supplierIndex ~= 0 and turtlesIdle[supplierIndex] == true then
                print("\nFree supplier found at index" .. supplierIndex)
                free = supplierIndex
                break
            end
        end
        os.sleep(2)
    until free ~= 0


    table.insert(message,maxheight)
    local supplierID = turtles[free]
    turtlesIdle[free] = false

    -- contact tankers with coordinates
    rednet.send(supplierID, message, supplierProtocol)
    

until (completed == true)