-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronReceiver")



-- protocol = "sauron"; -- rednet protocol
-- turtleLookupProtocol = "sauronLookup"
-- turtleProtocol = "sauronTurtles"
-- miningProtocol = "sauronMiners"
-- tankerProtocol = "sauronTankers"
-- supplierProtocol = "sauronSuppliers"
-- dockProtocol = "sauronDocking"

-- receiving
repeat -- loops forever

    local rid, rmessage, rprotocol = nil, nil, nil
    rid, rmessage, rprotocol = rednet.receive()

    if (rprotocol == turtleProtocol) then
        if (rmessage == idleresponse) then
            table.insert(idlerid, rid)
            table.insert(idlermessage, rmessage)
        elseif (rmessage == needsJob) then
            table.insert(turtlesrid, rid)
            table.insert(turtlesrmessage, rmessage)
        end
    elseif (rprotocol == dockProtocol) then
        table.insert(dockrid, rid)
        table.insert(dockrmessage, rmessage)
    elseif (rprotocol == tankerProtocol) then
        table.insert(tankrid, rid)
        table.insert(tankrmessage, rmessage)
    elseif (rprotocol == supplierProtocol) then
        table.insert(supplyrid, rid)
        table.insert(supplyrmessage, rmessage)
    end

until false -- forever
