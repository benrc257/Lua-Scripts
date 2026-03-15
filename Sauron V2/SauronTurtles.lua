-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronTurtles")

-- vars
local broadcasted = "employed?"
local responded = "needjob"
local miner = "miner"
local supplier = "supplier"
local tanker = "tanker"
miningjobs = 0
supplyingjobs = 0
tankerjobs = 0

-- constantly checking for new turtles or idle turtles
repeat
    turtles, turtlesIdle = updateTurtles(turtleProtocol, turtles, turtlesIdle)

    -- checking for idle turtles without jobs
    rednet.broadcast(broadcasted, turtleProtocol)
    local id, message = nil
    do -- assigns each of the turtles jobs
        ::receiving::
        id, message = rednet.receive(turtleProtocol, 5)
        if message == responded then

            if (tankerjobs == 0) then -- 0 tankers
                rednet.send(id, tanker)
                tankerjobs = tankerjobs+1

            elseif (supplyingjobs == 0) then -- 0 suppliers
                rednet.send(id, supplier)
                supplying = supplyingjobs+1

            elseif (miningjobs == 0) then -- 0 miners
                rednet.send(id, mining)
                miningjobs = miningjobs+1

            elseif (miningjobs/3 > tankerjobs) then -- add a new tanker for a set
                rednet.send(id, tanker)
                tankerjobs = tankerjobs+1

            elseif (miningjobs/3 > supplyingjobs) then -- add a new supplier for a set
                rednet.send(id, supplier)
                supplying = supplyingjobs+1
            else -- adds up miners until the next new set of three
                rednet.send(id, mining)
                miningjobs = miningjobs+1
            end


        elseif message ~= nil then
            goto receiving
        end
    until id == nil end
until completed == true end