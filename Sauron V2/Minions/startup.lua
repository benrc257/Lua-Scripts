-- libs
func = require("turtlefunctions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "MinionMain")

-- vars
completed = false

-- rednet vars
centralComputer = "EYE"
protocol = "sauron"  -- rednet protocol
turtleLookupProtocol = "sauronLookup"
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
func.rednetHost(turtleLookupProtocol, label)
func.rednetHost(turtleProtocol, label)
func.rednetHost(miningProtocol, label)
func.rednetHost(dockProtocol, label)
func.rednetHost(supplierProtocol, label)
func.rednetHost(tankerProtocol, label)

-- record starting position
print("\nTriangulating starting position...")
xstart, ystart, zstart = func.triangulate()
startingCoords = {x=xstart, y=ystart, z=zstart}

-- acquire job
job = nil
repeat
    local id, message = rednet.receive(turtleProtocol, 10)
    if (message == jobSearch) then
        rednet.send(id, needsJob, turtleProtocol)
        id, message = rednet.receive(turtleProtocol, 20)
        if (message == minerJob or message == tankerJob or message == supplierJob) then
            job = message
        end
    end
until (job ~= nil)

-- enables designated program
if (job == minerJob) then
    multishell.launch(_ENV,"MinionMiner.lua")
elseif (job == tankerJob) then
    multishell.launch(_ENV,"MinionTanker.lua")
elseif (job == supplierJob) then
    multishell.launch(_ENV,"MinionSupplier.lua")
end

repeat
    os.sleep(0.01) -- wait until program is complete
until (completed == true)


