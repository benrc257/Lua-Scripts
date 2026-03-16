-- libs
func = require("turtlefunctions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "MinionMain")

-- vars
id, coords = nil

-- rednet vars
centralComputer = "EYE"
protocol = "sauron"  -- rednet protocol
turtleProtocol = "sauronTurtles"
miningProtocol = "sauronMiners"
tankerProtocol = "sauronTankers"
supplierProtocol = "sauronSuppliers"
dockProtocol = "sauronDocking"
jobSearch = "employed?"
needsJob = "needjob"
minerJob = "miner"
supplierJob = "supplier"
tankerJob = "tanker"
needsSupply = "needSupply" -- send from turtles for supply
needsFuel = "needFuel" -- send from turtles for fuel
dockingRequest = "needDocking" -- send from turtles for docking
doneDocking = "doneDocking" -- send from docking computer to end docking
idlecheck = "idlecheck"
idleresponse = "idle"

-- rednet opening
modem, label = func.rednetInitTurtle()
func.rednetHost(protocol, label)
func.rednetHost(turtleProtocol, label)
func.rednetHost(dockingProtocol, label)
func.rednetHost(supplierProtocol, label)
func.rednetHost(tankerProtocol, label)

job = nil
repeat
    local id, message = rednet.receive(turtleProtocol, 10)
    if (message == jobSearch) then
        rednet.send(id, needsJob, turtleProtocol)
        repeat
            id, message = rednet.receive(turtleProtocol, 10)
            if (message == minerJob or message == tankerJob or message == supplierJob) then
                job = message
            end
        until end
    end
until job ~= nil end

-- enables correct program
if (job == minerJob) then
    multishell.launch(_ENV,"MinionMiner.lua")
elseif (job == tankerJob) then
    multishell.launch(_ENV,"MinionTanker.lua")
elseif (job == supplierJob) then
    multishell.launch(_ENV,"MinionSupplier.lua")
end




